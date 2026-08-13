;===============================================================================
; PRG Banks $0E+$0F - Combined 16KB ($A000-$DFFF)
; Sangokushi 2 - Haou no Tairiku (J)
; Namco-163 Mapper 19
;
; Bank $0E at $A000-$BFFF, Bank $0F at $C000-$DFFF
;===============================================================================

.include "6502_registers.h"
.include "namco163.h"
.include "functions.h"


.segment "CODE_BANK0E"

BattleVBlankFrameUpdate_Entry:  ; (dispatch callback target)
  JMP BattleVBlankFrameUpdate             ; $A000: 4C 0F A0
Loc_A003:  ; (dispatch callback target)
  JMP $D8D4                               ; $A003: 4C D4 D8
Loc_A006:
  JMP $D7FB                               ; $A006: 4C FB D7
Loc_A009:
  JMP $D8B0                               ; $A009: 4C B0 D8
Loc_A00C:
  JMP $DF6E                               ; $A00C: 4C 6E DF
;===============================================================================
; $A00F: BattleVBlankFrameUpdate
; Battle-scene VBlank frame hook (entry 5 of the bank jump table, dispatched
; via BattleVBlankFrameUpdate_Entry at $A000), called from prg_1f.asm
; NmiState3_Battle ($F945, bank $19 pair). Applies the CHR bank animation,
; runs the battle overlay state machine BattleOverlayDispatch (phases 0-2
; also redraw the overlay strips), then banked-calls B1D_1E_MenuUpdate with
; input suppressed ($057B=0 is temporarily swapped into the input flags at
; $0081). Resumes after the inline trampoline target word.
;===============================================================================
.proc BattleVBlankFrameUpdate
  JSR BattleChrBankAnimate                ; $A00F: 20 1B C0
  LDA #$00                                ; $A012: A9 00
  STA $057B                               ; $A014: 8D 7B 05
  JSR BattleOverlayDispatch               ; $A017: 20 30 A0
  LDA a:$0081                             ; $A01A: AD 81 00
  PHA                                     ; $A01D: 48
  LDA $057B                               ; $A01E: AD 7B 05
  STA a:$0081                             ; $A021: 8D 81 00
  LDY #$3D                                ; $A024: A0 3D
  JSR B1F_BankedCallbackTrampoline        ; $A026: 20 07 EE
; --- BankedCallbackTrampoline target ---
  .word B1D_1E_MenuUpdate                 ; $A029: 03 A0
  PLA                                     ; $A02B: 68
  STA a:$0081                             ; $A02C: 8D 81 00
  RTS                                     ; $A02F: 60
.endproc
;===============================================================================
; $A030: BattleOverlayDispatch
; Battle overlay state-machine dispatcher, run every VBlank from
; BattleVBlankFrameUpdate. Phase = $0540, sub-phase = $0541.
;
; Phases 0-2 first redraw both overlay strips via banked calls into bank $19
; (X selects the strip: 0 uses buffer ptr $0560, 1 uses $0561 with row param
; $04BC=$D0); the second trampoline resumes directly into the phase dispatch.
; All phases then dispatch through the inline 11-entry phase table ($A06F)
; via B1F_CallbackDispatcher; every phase handler sub-dispatches on $0541.
; Phase 0 (battle intro) sub-states 0-4 are the Loc_A095..Loc_A137 handlers;
; sub-state 4 ends by advancing to phase 1. Phase 1 (next-actor selection)
; sub-states 0-2 are Phase1CycleInit/Phase1NextActorSelect/Phase1RoundPass.
; Phase 2 (acting-unit command resolution) sub-states 0-$A are the
; Phase2ActionGate..Phase2ActionDoneWait handlers ($A4F7-$AA22).
; Phase 3 (acting-unit command selection, player-request entry) sub-states
; 0-4 are the Phase3CommandPanelInit..Phase3CommandResultWait handlers
; ($AA23-$ACC4); it resumes at the latched phase/sub in $054B/$054C.
; Phase 4 (defeat/retreat result) sub-states 0-6 are the
; Phase4ResultAdvance..Phase4ResultConfirmInput handlers; it is entered at
; sub 0 by BattleDefeatEventCheck and at sub 3 by BattleRetreatEventCheck.
; Phase 8 (point-spend panel) sub-states 0-4 are the
; Phase8PanelInit..Phase8PanelAdvanceWait handlers ($ACC5-$AEAD); it is
; entered from Phase3CommandInput::@Commit when the step-0 action slot is 4
; and no side status counters $0574-$0577 are pending. The panel spends the
; per-side point budget $0572[$0549]; B-cancel and A-confirm return to
; phase 3 sub 3, row effects route to sub 3/sub 4 or on to phase 9.
; Phase 8 (point-spend panel) enters phase 9 via its $B09C entry (SFX $F1);
; phase 9 (formation advance) runs the animated advance sweep and returns to
; the phase-8 sub-dispatch at sub-state 3 (Phase9AdvanceComplete).
;===============================================================================
.proc BattleOverlayDispatch
  LDA $0540                               ; $A030: AD 40 05
  BEQ @RedrawOverlayStrips                ; $A033: F0 0B
  CMP #$01                                ; $A035: C9 01
  BEQ @RedrawOverlayStrips                ; $A037: F0 07
  CMP #$02                                ; $A039: C9 02
  BEQ @RedrawOverlayStrips                ; $A03B: F0 03
  JMP @PhaseDispatch                      ; $A03D: 4C 69 A0
@RedrawOverlayStrips:
; Strip 0: buffer ptr lo from $0560 (hi fixed $A5), X=0
  LDA $0560                               ; $A040: AD 60 05
  STA $00                                 ; $A043: 85 00
  LDA #$A5                                ; $A045: A9 A5
  STA $0A                                 ; $A047: 85 0A
  LDX #$00                                ; $A049: A2 00
  LDY #$39                                ; $A04B: A0 39
  JSR B1F_BankedCallbackTrampoline        ; $A04D: 20 07 EE
; --- BankedCallbackTrampoline target (bank $19) ---
  .word $A000                             ; $A050: 00 A0 ; B19_OverlayStripRender_Entry
; Strip 1: row param $04BC=$D0, buffer ptr lo from $0561, X=1
  LDA #$D0                                ; $A052: A9 D0
  STA $04BC                               ; $A054: 8D BC 04
  LDA $0561                               ; $A057: AD 61 05
  STA $00                                 ; $A05A: 85 00
  LDA #$A5                                ; $A05C: A9 A5
  STA $0A                                 ; $A05E: 85 0A
  LDX #$01                                ; $A060: A2 01
  LDY #$39                                ; $A062: A0 39
  JSR B1F_BankedCallbackTrampoline        ; $A064: 20 07 EE
; --- BankedCallbackTrampoline target (bank $19); resumes at @PhaseDispatch ---
  .word $A000                             ; $A067: 00 A0 ; B19_OverlayStripRender_Entry
@PhaseDispatch:
  LDA $0540                               ; $A069: AD 40 05
  JSR B1F_CallbackDispatcher              ; $A06C: 20 DE EA
; --- CallbackDispatcher phase table, indexed by $0540 ---
  .word Phase0IntroSubDispatch            ; $A06F: 85 A0 ; phase 0: intro sub-dispatch ($A085)
  .word Phase1NextActorSubDispatch        ; $A071: 5F A1 ; phase 1: next-actor select ($A15F)
  .word Phase2ActionSubDispatch           ; $A073: F7 A4 ; phase 2: command resolution ($A4F7)
  .word Phase3CommandSubDispatch          ; $A075: 23 AA ; phase 3: command selection ($AA23)
  .word Phase4ResultSubDispatch           ; $A077: BC A3 ; phase 4: defeat/retreat result ($A3BC)
  .word Loc_CD43                          ; $A079: 43 CD ; phase 5
  .word Loc_CE25                          ; $A07B: 25 CE ; phase 6
  .word Loc_CF67                          ; $A07D: 67 CF ; phase 7
  .word Phase8PanelSubDispatch            ; $A07F: C5 AC ; phase 8: point-spend panel ($ACC5)
  .word Phase9AdvanceSubDispatch          ; $A081: EC B1 ; phase 9: formation advance ($B1EC)
  .word Loc_D6BA                          ; $A083: BA D6 ; phase $A
.endproc
;===============================================================================
; $A085: Phase0IntroSubDispatch
; Phase-0 handler entry (battle intro): sub-dispatch on $0541 through the
; inline 5-entry table below, covering intro sub-states 0-4.
;===============================================================================
.proc Phase0IntroSubDispatch
  LDA $0541                               ; $A085: AD 41 05
  JSR B1F_CallbackDispatcher              ; $A088: 20 DE EA
; --- CallbackDispatcher sub-phase table, indexed by $0541 ---
  .word BattleOverlayIntroSkipCheck       ; $A08B: 95 A0 ; sub 0
  .word BattleOverlayIntroRosterWalk      ; $A08D: D3 A0 ; sub 1
  .word BattleOverlayIntroAnimQueue       ; $A08F: F9 A0 ; sub 2
  .word BattleOverlayIntroDataFormatTop   ; $A091: 19 A1 ; sub 3
  .word BattleOverlayIntroDataFormatBottomAndAdvance ; $A093: 37 A1 ; sub 4
.endproc
;===============================================================================
; $A095: BattleOverlayIntroSkipCheck
; Intro sub-state 0. If $0087 bit7 is set, skip the intro entirely: jump to
; phase 6 with all per-unit/per-side status slots ($0550-$0557, $0574-$0577)
; and the roster index $0548 cleared, then run $C926 (phase-6 setup).
;===============================================================================
.proc BattleOverlayIntroSkipCheck
  LDA a:$0087                             ; $A095: AD 87 00
  BPL @Done                               ; $A098: 10 38 ; bit7 clear: no skip
  LDA #$06                                ; $A09A: A9 06
  STA $0540                               ; $A09C: 8D 40 05 ; phase <- 6
  LDA #$00                                ; $A09F: A9 00
  STA $0541                               ; $A0A1: 8D 41 05 ; sub-phase <- 0
  LDA #$00                                ; $A0A4: A9 00
  STA $0550                               ; $A0A6: 8D 50 05
  STA $0551                               ; $A0A9: 8D 51 05
  STA $0552                               ; $A0AC: 8D 52 05
  STA $0553                               ; $A0AF: 8D 53 05
  STA $0554                               ; $A0B2: 8D 54 05
  STA $0555                               ; $A0B5: 8D 55 05
  STA $0556                               ; $A0B8: 8D 56 05
  STA $0557                               ; $A0BB: 8D 57 05
  STA $0574                               ; $A0BE: 8D 74 05
  STA $0575                               ; $A0C1: 8D 75 05
  STA $0576                               ; $A0C4: 8D 76 05
  STA $0577                               ; $A0C7: 8D 77 05
  LDA #$00                                ; $A0CA: A9 00
  STA $0548                               ; $A0CC: 8D 48 05
  JSR $C926                               ; $A0CF: 20 26 C9
@Done:
  RTS                                     ; $A0D2: 60
.endproc
;===============================================================================
; $A0D3: BattleOverlayIntroRosterWalk
; Intro sub-state 1. Waits for the animation queue to idle ($B870, C=1 idle),
; then draws one roster entry per frame: entry $0548 of the 22-slot list at
; $0580 is passed to $B882 (skipping $FF slots) with zp $12/$13 params. When
; all $16 entries are walked, advances to sub-state 2.
;===============================================================================
.proc BattleOverlayIntroRosterWalk
  JSR $B870                               ; $A0D3: 20 70 B8 ; anim queue idle check
  BCC @Done                               ; $A0D6: 90 20 ; still busy: wait
  LDA #$10                                ; $A0D8: A9 10
  STA $12                                 ; $A0DA: 85 12
  LDY $0548                               ; $A0DC: AC 48 05
  STY $13                                 ; $A0DF: 84 13
  LDA $0580,Y                             ; $A0E1: B9 80 05
  CMP #$FF                                ; $A0E4: C9 FF
  BEQ @Advance                            ; $A0E6: F0 03 ; empty slot: skip draw
  JSR $B882                               ; $A0E8: 20 82 B8 ; draw roster entry
@Advance:
  INC $0548                               ; $A0EB: EE 48 05
  LDA $0548                               ; $A0EE: AD 48 05
  CMP #$16                                ; $A0F1: C9 16
  BCC @Done                               ; $A0F3: 90 03
  INC $0541                               ; $A0F5: EE 41 05 ; all entries: sub-state <- 2
@Done:
  RTS                                     ; $A0F8: 60
.endproc
;===============================================================================
; $A0F9: BattleOverlayIntroAnimQueue
; Intro sub-state 2. Waits for the animation queue to idle, then enqueues the
; $E8/$E9 tile animation ($0310/$0311, slot $0300=0), sets panel param
; $00BC=5, submits via $CBF1 and advances to sub-state 3.
;===============================================================================
.proc BattleOverlayIntroAnimQueue
  JSR $B870                               ; $A0F9: 20 70 B8 ; anim queue idle check
  BCC @Done                               ; $A0FC: 90 1A ; still busy: wait
  LDA #$E8                                ; $A0FE: A9 E8
  STA $0310                               ; $A100: 8D 10 03
  LDA #$E9                                ; $A103: A9 E9
  STA $0311                               ; $A105: 8D 11 03
  LDA #$00                                ; $A108: A9 00
  STA $0300                               ; $A10A: 8D 00 03
  INC $0541                               ; $A10D: EE 41 05 ; sub-state <- 3
  LDA #$05                                ; $A110: A9 05
  STA a:$00BC                             ; $A112: 8D BC 00
  JSR $CBF1                               ; $A115: 20 F1 CB
@Done:
  RTS                                     ; $A118: 60
.endproc
;===============================================================================
; $A119: BattleOverlayIntroDataFormatTop
; Intro sub-state 3. Waits for the animation queue to idle, then banked-calls
; B1D_1E_DataFormatter (bank $1D, Y=$3D) with buffer ptr $00/$01 = $0560/0
; and param $00BB=9 to format the top panel. Advances to sub-state 4.
;===============================================================================
.proc BattleOverlayIntroDataFormatTop
  JSR $B870                               ; $A119: 20 70 B8 ; anim queue idle check
  BCC @Done                               ; $A11C: 90 18 ; still busy: wait
  LDA #$09                                ; $A11E: A9 09
  STA a:$00BB                             ; $A120: 8D BB 00
  LDA $0560                               ; $A123: AD 60 05
  STA $00                                 ; $A126: 85 00
  LDA #$00                                ; $A128: A9 00
  STA $01                                 ; $A12A: 85 01
  LDY #$3D                                ; $A12C: A0 3D
  JSR B1F_BankedCallbackTrampoline        ; $A12E: 20 07 EE
; --- BankedCallbackTrampoline target (banks $1D+$1E) ---
  .word B1D_1E_DataFormatter              ; $A131: 3C A0
  INC $0541                               ; $A133: EE 41 05 ; sub-state <- 4
@Done:
  RTS                                     ; $A136: 60
.endproc
;===============================================================================
; $A137: BattleOverlayIntroDataFormatBottomAndAdvance
; Intro sub-state 4. If $007E is clear, banked-calls B1D_1E_DataFormatter
; (bank $1D) with buffer ptr $00/$01 = $0561/1 to format the bottom panel,
; then ends the intro: phase <- 1, sub-phase <- 0, clear handoff flags
; $0568/$0569.
;===============================================================================
.proc BattleOverlayIntroDataFormatBottomAndAdvance
  LDA a:$007E                             ; $A137: AD 7E 00
  BNE @Done                               ; $A13A: D0 22
  LDA $0561                               ; $A13C: AD 61 05
  STA $00                                 ; $A13F: 85 00
  LDA #$01                                ; $A141: A9 01
  STA $01                                 ; $A143: 85 01
  LDY #$3D                                ; $A145: A0 3D
  JSR B1F_BankedCallbackTrampoline        ; $A147: 20 07 EE
; --- BankedCallbackTrampoline target (banks $1D+$1E) ---
  .word B1D_1E_DataFormatter              ; $A14A: 3C A0
  LDA #$01                                ; $A14C: A9 01
  STA $0540                               ; $A14E: 8D 40 05 ; phase <- 1 (intro done)
  LDA #$00                                ; $A151: A9 00
  STA $0541                               ; $A153: 8D 41 05 ; sub-phase <- 0
  LDA #$00                                ; $A156: A9 00
  STA $0568                               ; $A158: 8D 68 05
  STA $0569                               ; $A15B: 8D 69 05
@Done:
  RTS                                     ; $A15E: 60
.endproc
;===============================================================================
; $A15F: Phase1NextActorSubDispatch
; Phase-1 handler entry (next-actor selection): redraws the packed per-side
; status counters $0574-$0577 via BattleSideStatusCounterDraw every frame,
; then sub-dispatches on $0541 through the inline 3-entry table below.
; Sub 0 initializes the scan cursor, sub 1 picks the next acting unit, and
; sub 2 passes the round (incrementing the pass counter $057A and ticking
; the status counters) when a full roster scan found nobody.
;===============================================================================
.proc Phase1NextActorSubDispatch
  JSR BattleSideStatusCounterDraw         ; $A15F: 20 4C BF
  LDA $0541                               ; $A162: AD 41 05
  JSR B1F_CallbackDispatcher              ; $A165: 20 DE EA
; --- CallbackDispatcher sub-phase table, indexed by $0541 ---
  .word Phase1CycleInit                   ; $A168: 6E A1 ; sub 0
  .word Phase1NextActorSelect             ; $A16A: 83 A1 ; sub 1
  .word Phase1RoundPass                   ; $A16C: 35 A2 ; sub 2
.endproc
;===============================================================================
; $A16E: Phase1CycleInit
; Sub-phase 0. Advances to sub-phase 1, clears the roster-scan cursor
; ($0545=column, $0546=side-group row, $0547=frame wait) and the round-pass
; counter $057A, then refreshes the side panels via $D067.
;===============================================================================
.proc Phase1CycleInit
  INC $0541                               ; $A16E: EE 41 05 ; sub-phase <- 1
  LDA #$00                                ; $A171: A9 00
  STA $0545                               ; $A173: 8D 45 05 ; scan column <- 0
  STA $0546                               ; $A176: 8D 46 05 ; side-group row <- 0
  STA $0547                               ; $A179: 8D 47 05 ; frame wait <- 0
  STA $057A                               ; $A17C: 8D 7A 05 ; round-pass counter <- 0
  JSR $D067                               ; $A17F: 20 67 D0 ; side panel refresh
  RTS                                     ; $A182: 60
.endproc
;===============================================================================
; $A183: Phase1NextActorSelect
; Sub-phase 1. Battle-end event checks first: BattleRetreatEventCheck (side
; event flags $0580/$058B == $FE) and BattleDefeatEventCheck (== $FF) abort
; the frame straight into phase 4. Next, a queued player request (handoff
; flags $0568/$0569, set from BattlePlayerRequestPoll controller polling) advances to phase 3
; with $0549 <- $0569 and $054B/$054C <- 1. Otherwise scans the 22-slot
; battle roster $05C2 column by column ($0545) through the side groups in
; priority order 3,2,1,0 ($A231 table, row index $0546): the first unit
; whose low nibble matches the current side group advances to phase 2; its
; action slot $0550[unit&$0F (+4 for roster columns >= $0B)] is copied to
; $054F, and slot value $80 is rerolled via B1F_RandomByte bit0 to 0 or 2.
; A full scan without a match clears $0547 and advances to sub-phase 2
; (round pass).
;===============================================================================
.proc Phase1NextActorSelect
  JSR BattleRetreatEventCheck             ; $A183: 20 2F A3 ; $FE side event -> phase 4
  JSR BattleDefeatEventCheck              ; $A186: 20 A9 A2 ; $FF side event -> phase 4
  LDA $0568                               ; $A189: AD 68 05
  ORA $0569                               ; $A18C: 0D 69 05
  BEQ @ScanRoster                         ; $A18F: F0 23 ; no player request
  LDA $0569                               ; $A191: AD 69 05
  STA $0549                               ; $A194: 8D 49 05 ; request param
  LDA #$03                                ; $A197: A9 03
  STA $0540                               ; $A199: 8D 40 05 ; phase <- 3
  LDA #$00                                ; $A19C: A9 00
  STA $0541                               ; $A19E: 8D 41 05 ; sub-phase <- 0
  LDA #$01                                ; $A1A1: A9 01
  STA $054B                               ; $A1A3: 8D 4B 05
  LDA #$01                                ; $A1A6: A9 01
  STA $054C                               ; $A1A8: 8D 4C 05
  LDA #$00                                ; $A1AB: A9 00
  STA $0568                               ; $A1AD: 8D 68 05 ; consume request flags
  STA $0569                               ; $A1B0: 8D 69 05
  RTS                                     ; $A1B3: 60
@ScanRoster:
  LDA #$00                                ; $A1B4: A9 00
  STA $0568                               ; $A1B6: 8D 68 05
  STA $0569                               ; $A1B9: 8D 69 05
@NextCell:
  LDY $0546                               ; $A1BC: AC 46 05 ; side-group row
  LDA Phase1SidePriorityOrder,Y           ; $A1BF: B9 31 A2 ; side id for this row
  STA $00                                 ; $A1C2: 85 00
  LDY $0545                               ; $A1C4: AC 45 05 ; roster column
  LDA $05C2,Y                             ; $A1C7: B9 C2 05 ; roster entry
  CMP #$FF                                ; $A1CA: C9 FF
  BEQ @AdvanceCell                        ; $A1CC: F0 41 ; empty slot
  AND #$0F                                ; $A1CE: 29 0F ; unit side
  CMP $00                                 ; $A1D0: C5 00
  BNE @AdvanceCell                        ; $A1D2: D0 3B ; not this side group
  LDA #$02                                ; $A1D4: A9 02
  STA $0540                               ; $A1D6: 8D 40 05 ; phase <- 2
  LDA #$00                                ; $A1D9: A9 00
  STA $0541                               ; $A1DB: 8D 41 05 ; sub-phase <- 0
  LDA #$00                                ; $A1DE: A9 00
  LDY $0545                               ; $A1E0: AC 45 05
  CPY #$0B                                ; $A1E3: C0 0B
  BCC @SlotBase                           ; $A1E5: 90 02 ; columns 0-10: slots 0-3
  LDA #$04                                ; $A1E7: A9 04 ; columns 11-21: slots 4-7
@SlotBase:
  STA $00                                 ; $A1E9: 85 00
  LDA $05C2,Y                             ; $A1EB: B9 C2 05
  AND #$0F                                ; $A1EE: 29 0F ; unit slot
  ORA $00                                 ; $A1F0: 05 00
  TAY                                     ; $A1F2: A8
  LDA $0550,Y                             ; $A1F3: B9 50 05 ; action slot value
  STA $054F                               ; $A1F6: 8D 4F 05
  CMP #$80                                ; $A1F9: C9 80
  BNE @Done                               ; $A1FB: D0 11 ; valid value: keep
  LDA #$00                                ; $A1FD: A9 00
  STA $054F                               ; $A1FF: 8D 4F 05
  JSR B1F_RandomByte                      ; $A202: 20 7A E8
  AND #$01                                ; $A205: 29 01
  BNE @Done                               ; $A207: D0 05 ; odd: leave 0
  LDA #$02                                ; $A209: A9 02
  STA $054F                               ; $A20B: 8D 4F 05 ; even: 2
@Done:
  RTS                                     ; $A20E: 60
@AdvanceCell:
  LDA #$00                                ; $A20F: A9 00
  STA $0547                               ; $A211: 8D 47 05 ; frame wait <- 0
  INC $0545                               ; $A214: EE 45 05 ; next column
  LDA $0545                               ; $A217: AD 45 05
  CMP #$16                                ; $A21A: C9 16 ; 22 roster columns
  BCC @NextCell                           ; $A21C: 90 9E
  LDA #$00                                ; $A21E: A9 00
  STA $0545                               ; $A220: 8D 45 05 ; column wrap
  INC $0546                               ; $A223: EE 46 05 ; next side group
  LDA $0546                               ; $A226: AD 46 05
  CMP #$04                                ; $A229: C9 04 ; 4 side groups
  BCC @NextCell                           ; $A22B: 90 8F
  INC $0541                               ; $A22D: EE 41 05 ; full scan: sub-phase <- 2
  RTS                                     ; $A230: 60
.endproc
; --- Phase 1 side-group priority order, indexed by scan row $0546 ---
Phase1SidePriorityOrder:
  .byte $03,$02,$01,$00                   ; $A231: 03 02 01 00
;===============================================================================
; $A235: Phase1RoundPass
; Sub-phase 2, entered when a full roster scan found no acting unit. Re-arms
; sub-phase 1 (the cycle resumes with another scan next frame) and, once the
; animation queue idles ($B870, C=1 idle), enqueues the $E9 tile animation
; ($0310=$E9, slot $0300=0) via $CBF1. Then walks the same 22x4 roster grid
; as Phase1NextActorSelect but only for side groups 0 and 1: cells of side
; groups 2/3 advance immediately, while the first side-0/1 cell stalls one
; frame ($0547 counts 0 -> 1) before the walk resumes one cell per visit.
; After the full walk: round-pass counter $057A is incremented, the packed
; side status counters $0574-$0577 are ticked down via
; BattleSideStatusCountersDecrement, and both side panels are refreshed
; ($D0AE, $D067).
;===============================================================================
.proc Phase1RoundPass
  LDA #$01                                ; $A235: A9 01
  STA $0541                               ; $A237: 8D 41 05 ; sub-phase <- 1 (resume scan next frame)
  JSR $B870                               ; $A23A: 20 70 B8 ; anim queue idle check
  BCC @ScanGrid                           ; $A23D: 90 0D ; still busy: skip enqueue
  LDA #$E9                                ; $A23F: A9 E9
  STA $0310                               ; $A241: 8D 10 03 ; anim id
  LDA #$00                                ; $A244: A9 00
  STA $0300                               ; $A246: 8D 00 03 ; anim slot
  JSR $CBF1                               ; $A249: 20 F1 CB ; enqueue anim
@ScanGrid:
  LDA $0546                               ; $A24C: AD 46 05
  CMP #$04                                ; $A24F: C9 04
  BCS @PassComplete                       ; $A251: B0 39 ; all side groups walked
  LDY $0546                               ; $A253: AC 46 05
  LDA Phase1SidePriorityOrder,Y           ; $A256: B9 31 A2 ; side id for this row
  CMP #$02                                ; $A259: C9 02
  BEQ @AdvanceCell                        ; $A25B: F0 0E ; side 2: skip wait
  CMP #$03                                ; $A25D: C9 03
  BEQ @AdvanceCell                        ; $A25F: F0 0A ; side 3: skip wait
  INC $0547                               ; $A261: EE 47 05 ; side 0/1: frame wait
  LDA $0547                               ; $A264: AD 47 05
  CMP #$01                                ; $A267: C9 01
  BEQ @Done                               ; $A269: F0 3D ; first visit: stall one frame
@AdvanceCell:
  LDA #$00                                ; $A26B: A9 00
  STA $0547                               ; $A26D: 8D 47 05 ; frame wait <- 0
  INC $0545                               ; $A270: EE 45 05 ; next column
  LDA $0545                               ; $A273: AD 45 05
  CMP #$16                                ; $A276: C9 16 ; 22 roster columns
  BCC @Done                               ; $A278: 90 2E
  LDA #$00                                ; $A27A: A9 00
  STA $0545                               ; $A27C: 8D 45 05 ; column wrap
  STA $0547                               ; $A27F: 8D 47 05
  INC $0546                               ; $A282: EE 46 05 ; next side group
  LDA $0546                               ; $A285: AD 46 05
  CMP #$04                                ; $A288: C9 04
  BCC @Done                               ; $A28A: 90 1C
@PassComplete:
  LDA #$00                                ; $A28C: A9 00
  STA $0545                               ; $A28E: 8D 45 05 ; cursor reset
  STA $0546                               ; $A291: 8D 46 05
  INC $057A                               ; $A294: EE 7A 05 ; round-pass counter++
  JSR BattleSideStatusCountersDecrement   ; $A297: 20 5B B1 ; tick $0574-$0577
  JSR $D0AE                               ; $A29A: 20 AE D0 ; side panel update
  JSR $D067                               ; $A29D: 20 67 D0 ; side panel refresh
  LDA #$00                                ; $A2A0: A9 00
  STA $0545                               ; $A2A2: 8D 45 05
  STA $0546                               ; $A2A5: 8D 46 05
@Done:
  RTS                                     ; $A2A8: 60
.endproc
;===============================================================================
; $A2A9: BattleDefeatEventCheck
; Checks the per-side battle event flags ($0580 = side A, $058B = side B)
; for the defeat value $FF. When a side is defeated, loads the overlay strip
; buffer pointers $0560/$0561 into the panel parameter block $042C and
; $0514-$0517 (side A: $0515=2/$0517=0, side B: $0515=0/$0517=2), jumps to
; phase 4 sub 0, plays SFX $D3 ($F28B), runs $E57F/$E683 (A=$71), then pops
; both return addresses so the rest of the current frame is skipped.
;===============================================================================
.proc BattleDefeatEventCheck
  LDA $0580                               ; $A2A9: AD 80 05 ; side A event flag
  CMP #$FF                                ; $A2AC: C9 FF
  BNE @SideB                              ; $A2AE: D0 3C
  LDA $05AC                               ; $A2B0: AD AC 05
  BEQ @SideADefeated                      ; $A2B3: F0 04
  CMP #$FF                                ; $A2B5: C9 FF
  BNE @SideB                              ; $A2B7: D0 33
@SideADefeated:
  LDA $0560                               ; $A2B9: AD 60 05 ; strip 0 buffer ptr
  STA $042C                               ; $A2BC: 8D 2C 04
  STA $0514                               ; $A2BF: 8D 14 05
  LDA #$02                                ; $A2C2: A9 02
  STA $0515                               ; $A2C4: 8D 15 05
  LDA $0561                               ; $A2C7: AD 61 05 ; strip 1 buffer ptr
  STA $0516                               ; $A2CA: 8D 16 05
  LDA #$00                                ; $A2CD: A9 00
  STA $0517                               ; $A2CF: 8D 17 05
@GotoPhase4:
  LDA #$04                                ; $A2D2: A9 04
  STA $0540                               ; $A2D4: 8D 40 05 ; phase <- 4
  LDA #$00                                ; $A2D7: A9 00
  STA $0541                               ; $A2D9: 8D 41 05 ; sub-phase <- 0
  LDA #$D3                                ; $A2DC: A9 D3
  JSR $F28B                               ; $A2DE: 20 8B F2 ; SFX
  JSR $E57F                               ; $A2E1: 20 7F E5
  LDA #$71                                ; $A2E4: A9 71
  JSR $E683                               ; $A2E6: 20 83 E6
  PLA                                     ; $A2E9: 68 ; drop caller return addr
  PLA                                     ; $A2EA: 68
  RTS                                     ; $A2EB: 60 ; skip rest of frame
@SideB:
  LDA $058B                               ; $A2EC: AD 8B 05 ; side B event flag
  CMP #$FF                                ; $A2EF: C9 FF
  BNE @Done                               ; $A2F1: D0 3B
  LDA $05B7                               ; $A2F3: AD B7 05
  BEQ @SideBDefeated                      ; $A2F6: F0 04
  CMP #$FF                                ; $A2F8: C9 FF
  BNE @Done                               ; $A2FA: D0 32
@SideBDefeated:
  LDA $0560                               ; $A2FC: AD 60 05 ; strip 0 buffer ptr
  STA $0514                               ; $A2FF: 8D 14 05
  LDA #$00                                ; $A302: A9 00
  STA $0515                               ; $A304: 8D 15 05
  LDA $0561                               ; $A307: AD 61 05 ; strip 1 buffer ptr
  STA $042C                               ; $A30A: 8D 2C 04
  STA $0516                               ; $A30D: 8D 16 05
  LDA #$02                                ; $A310: A9 02
  STA $0517                               ; $A312: 8D 17 05
  LDA #$04                                ; $A315: A9 04
  STA $0540                               ; $A317: 8D 40 05 ; phase <- 4
  LDA #$00                                ; $A31A: A9 00
  STA $0541                               ; $A31C: 8D 41 05 ; sub-phase <- 0
  LDA #$D3                                ; $A31F: A9 D3
  JSR $F28B                               ; $A321: 20 8B F2 ; SFX
  JSR $E57F                               ; $A324: 20 7F E5
  LDA #$71                                ; $A327: A9 71
  JSR $E683                               ; $A329: 20 83 E6
  PLA                                     ; $A32C: 68 ; drop caller return addr
  PLA                                     ; $A32D: 68
@Done:
  RTS                                     ; $A32E: 60
.endproc
;===============================================================================
; $A32F: BattleRetreatEventCheck
; Checks the per-side battle event flags ($0580 = side A, $058B = side B)
; for the retreat value $FE. When a side retreats, loads the overlay strip
; buffer pointers $0560/$0561 into the panel parameter block ($0514-$0517,
; mirrored layout per side; side A also clears the scan column $0545 while
; side B sets it to 1), jumps to phase 4 sub 3, plays SFX $FA ($F28B), then
; pops both return addresses so the rest of the current frame is skipped.
;===============================================================================
.proc BattleRetreatEventCheck
  LDA $0580                               ; $A32F: AD 80 05 ; side A event flag
  CMP #$FE                                ; $A332: C9 FE
  BNE @SideB                              ; $A334: D0 30
  LDA $0560                               ; $A336: AD 60 05 ; strip 0 buffer ptr
  STA $042C                               ; $A339: 8D 2C 04
  STA $0514                               ; $A33C: 8D 14 05
  LDA #$01                                ; $A33F: A9 01
  STA $0515                               ; $A341: 8D 15 05
  LDA $0561                               ; $A344: AD 61 05 ; strip 1 buffer ptr
  STA $0516                               ; $A347: 8D 16 05
  LDA #$00                                ; $A34A: A9 00
  STA $0517                               ; $A34C: 8D 17 05
  LDA #$00                                ; $A34F: A9 00
  STA $0545                               ; $A351: 8D 45 05 ; scan column <- 0
@GotoPhase4:
  LDA #$04                                ; $A354: A9 04
  STA $0540                               ; $A356: 8D 40 05 ; phase <- 4
  LDA #$03                                ; $A359: A9 03
  STA $0541                               ; $A35B: 8D 41 05 ; sub-phase <- 3
  LDA #$FA                                ; $A35E: A9 FA
  JSR $F28B                               ; $A360: 20 8B F2 ; SFX
  PLA                                     ; $A363: 68 ; drop caller return addr
  PLA                                     ; $A364: 68
  RTS                                     ; $A365: 60 ; skip rest of frame
@SideB:
  LDA $058B                               ; $A366: AD 8B 05 ; side B event flag
  CMP #$FE                                ; $A369: C9 FE
  BNE @Done                               ; $A36B: D0 2F
  LDA $0560                               ; $A36D: AD 60 05 ; strip 0 buffer ptr
  STA $0514                               ; $A370: 8D 14 05
  LDA #$00                                ; $A373: A9 00
  STA $0515                               ; $A375: 8D 15 05
  LDA $0561                               ; $A378: AD 61 05 ; strip 1 buffer ptr
  STA $042C                               ; $A37B: 8D 2C 04
  STA $0516                               ; $A37E: 8D 16 05
  LDA #$01                                ; $A381: A9 01
  STA $0517                               ; $A383: 8D 17 05
  LDA #$04                                ; $A386: A9 04
  STA $0540                               ; $A388: 8D 40 05 ; phase <- 4
  LDA #$03                                ; $A38B: A9 03
  STA $0541                               ; $A38D: 8D 41 05 ; sub-phase <- 3
  LDA #$FA                                ; $A390: A9 FA
  JSR $F28B                               ; $A392: 20 8B F2 ; SFX
  LDA #$01                                ; $A395: A9 01
  STA $0545                               ; $A397: 8D 45 05 ; scan column <- 1
  PLA                                     ; $A39A: 68 ; drop caller return addr
  PLA                                     ; $A39B: 68
@Done:
  RTS                                     ; $A39C: 60
.endproc
;===============================================================================
; $A39D: BattlePlayerRequestPoll
; Called every frame from the phase-2 handler inline code ($A4F7). Fetches the
; mode-filtered input state of each controller via BattlePadStateFetch and,
; on an A-button edge (bit0 of $0001), latches the player-request handoff
; flags $0568 (pad 1) / $0569 (pad 2). Phase1NextActorSelect consumes them:
; any request aborts the automatic actor scan and jumps to phase 3 (player
; command input) with $0549 <- $0569 selecting the acting player.
;===============================================================================
.proc BattlePlayerRequestPoll
  LDA #$00                                ; $A39D: A9 00 ; pad 1
  JSR BattlePadStateFetch                 ; $A39F: 20 DE CC
  LDA $01                                 ; $A3A2: A5 01 ; mode-filtered edge flags
  LSR                                     ; $A3A4: 4A ; bit0 = A button
  BCC @PollPad2                           ; $A3A5: 90 05
  LDA #$01                                ; $A3A7: A9 01
  STA $0568                               ; $A3A9: 8D 68 05 ; pad 1 request flag
@PollPad2:
  LDA #$01                                ; $A3AC: A9 01 ; pad 2
  JSR BattlePadStateFetch                 ; $A3AE: 20 DE CC
  LDA $01                                 ; $A3B1: A5 01
  LSR                                     ; $A3B3: 4A ; bit0 = A button
  BCC @Done                               ; $A3B4: 90 05
  LDA #$01                                ; $A3B6: A9 01
  STA $0569                               ; $A3B8: 8D 69 05 ; pad 2 request flag
@Done:
  RTS                                     ; $A3BB: 60
.endproc
;===============================================================================
; $A3BC: Phase4ResultSubDispatch
; Phase 4 (battle result: defeat/retreat resolution) handler of
; BattleOverlayDispatch, run once per VBlank while $0540 = 4. Entered at
; sub 0 by BattleDefeatEventCheck ($A2A9) and at sub 3 by
; BattleRetreatEventCheck ($A32F). Runs a random damage-roll cycle that
; drains one side's strength ($05AC side A / $05B7 side B, selected by scan
; column $0545) and ends by advancing to phase 5. Sub-phases via inline
; 7-entry table at $A3C4 indexed by $0541:
;   0 Phase4ResultAdvance        ($A3D0) stall one frame
;   1 Phase4ResultDefeatInputWait($A3D4) wait anim-idle + A/B edge -> sub 2
;   2 Phase4ResultFlashTrigger   ($A3F2) $0087 bit7 -> flash $0500=$0B, $007A <- 3
;   3 Phase4ResultRetreatInputWait($A407) wait anim-idle + A/B edge, then
;                                         roll [0,100): <32 -> sub 2 retry,
;                                         else damage = roll2+5 -> sub 4
;                                         (roll continuation at $A42F)
;   4 Phase4ResultDamageApply    ($A488) apply damage, confirm -> sub 2
;   5 Phase4ResultConfirmInput   ($A4B5) A/B edge -> sub 2 (loop) with SFX $D3
;   6 Phase4ResultFlashTrigger   ($A3F2) shared with sub 2
;===============================================================================
.proc Phase4ResultSubDispatch
  LDA $0541                               ; $A3BC: AD 41 05 ; sub-phase index
  JSR B1F_CallbackDispatcher              ; $A3BF: 20 DE EA
; --- CallbackDispatcher sub-phase table, indexed by $0541 ---
  .word Phase4ResultAdvance               ; $A3C4: D0 A3 ; sub 0
  .word Phase4ResultDefeatInputWait       ; $A3C6: D4 A3 ; sub 1
  .word Phase4ResultFlashTrigger          ; $A3C8: F2 A3 ; sub 2
  .word Phase4ResultRetreatInputWait      ; $A3CA: 07 A4 ; sub 3
  .word Phase4ResultDamageApply           ; $A3CC: 88 A4 ; sub 4
  .word Phase4ResultConfirmInput          ; $A3CE: B5 A4 ; sub 5
  .word Phase4ResultFlashTrigger          ; $A3D0: F2 A3 ; sub 6
.endproc
;===============================================================================
; $A3D0: Phase4ResultAdvance
; Sub 0 (defeat entry point): stalls one frame by advancing to sub 1.
;===============================================================================
.proc Phase4ResultAdvance
  INC $0541                               ; $A3D0: EE 41 05 ; sub-phase <- 1
  RTS                                     ; $A3D3: 60
.endproc
;===============================================================================
; $A3D4: Phase4ResultDefeatInputWait
; Sub 1: waits for the animation queue to idle ($B870 carry set) and an
; A/B button edge on either pad ($CCA8 -> $CD22, bits 0-1 of merged $0001),
; then advances to sub 2 via B1F_PaletteCopyBuffer + BattleOverlayTotalRefresh.
;===============================================================================
.proc Phase4ResultDefeatInputWait
  JSR BattleBothPadsStateFetch            ; $A3D4: 20 22 CD ; merge both pads -> $0000/$0001
  JSR $B870                               ; $A3D7: 20 70 B8 ; anim queue idle check
  BCC @Done                               ; $A3DA: 90 15 ; busy: wait
  JSR $CCA8                               ; $A3DC: 20 A8 CC ; panel input check setup
  JSR BattleBothPadsStateFetch            ; $A3DF: 20 22 CD ; re-fetch merged pad state
  LDA $01                                 ; $A3E2: A5 01 ; merged raw state
  AND #$03                                ; $A3E4: 29 03 ; A or B edge?
  BEQ @Done                               ; $A3E6: F0 09
  JSR B1F_PaletteCopyBuffer               ; $A3E8: 20 EE EC ; palette refresh
  INC $0541                               ; $A3EB: EE 41 05 ; sub-phase <- 2
  JSR $CA3F                               ; $A3EE: 20 3F CA ; overlay total refresh
@Done:
  RTS                                     ; $A3F1: 60
.endproc
;===============================================================================
; $A3F2: Phase4ResultFlashTrigger
; Sub 2 and sub 6 shared handler: waits on $0087 bit7 (palette/frame flag);
; while clear, stalls. When set, arms a screen flash ($0500 <- $0B,
; $0501 <- 0, flash counter $007A <- 3) and falls through.
;===============================================================================
.proc Phase4ResultFlashTrigger
  LDA a:$0087                             ; $A3F2: AD 87 00 ; palette/frame flag
  BPL @Done                               ; $A3F5: 10 0F ; bit7 clear: wait
  LDA #$0B                                ; $A3F7: A9 0B
  STA $0500                               ; $A3F9: 8D 00 05 ; flash id
  LDA #$00                                ; $A3FC: A9 00
  STA $0501                               ; $A3FE: 8D 01 05
  LDA #$03                                ; $A401: A9 03
  STA a:$007A                             ; $A403: 8D 7A 00 ; flash counter
@Done:
  RTS                                     ; $A406: 60
.endproc
;===============================================================================
; $A407: Phase4ResultRetreatInputWait
; Sub 3 (retreat entry point): same anim-idle + A/B edge gate as sub 1, but
; on input rolls a random value [0,100) (B1F_RandomBelowThreshold): < $20
; re-routes to sub 2 (flash/retry via B1F_PaletteCopyBuffer +
; BattleOverlayTotalRefresh), otherwise stores roll+5 as pending damage
; amount $0548 (mirror $042F), clears $0430/$0431, plays SFX $7E and
; advances to sub 4.
;===============================================================================
.proc Phase4ResultRetreatInputWait
  JSR BattleBothPadsStateFetch            ; $A407: 20 22 CD ; merge both pads
  JSR $B870                               ; $A40A: 20 70 B8 ; anim queue idle check
  BCC @Done                               ; $A40D: 90 5D ; busy: wait
  JSR $CCA8                               ; $A40F: 20 A8 CC ; panel input check setup
  JSR BattleBothPadsStateFetch            ; $A412: 20 22 CD ; re-fetch merged pad state
  LDA $01                                 ; $A415: A5 01 ; merged raw state
  AND #$03                                ; $A417: 29 03 ; A or B edge?
  BEQ @Done                               ; $A419: F0 51
  LDA #$64                                ; $A41B: A9 64 ; threshold 100
  JSR B1F_RandomBelowThreshold            ; $A41D: 20 62 E8 ; roll [0,100)
  CMP #$20                                ; $A420: C9 20
  BCS @RollAccepted                       ; $A422: B0 0B ; roll >= 32: apply
  JSR B1F_PaletteCopyBuffer               ; $A424: 20 EE EC ; retry path
  LDA #$02                                ; $A427: A9 02
  STA $0541                               ; $A429: 8D 41 05 ; sub-phase <- 2
  JMP $CA3F                               ; $A42C: 4C 3F CA ; overlay total refresh
@RollAccepted:
  INC $0541                               ; $A42F: EE 41 05 ; sub-phase <- 4
  LDA #$0A                                ; $A432: A9 0A ; threshold 10
  JSR B1F_RandomBelowThreshold            ; $A434: 20 62 E8 ; roll [0,10)
  CLC                                     ; $A437: 18
  ADC #$05                                ; $A438: 69 05 ; damage = roll+5 (5..14)
  STA $042F                               ; $A43A: 8D 2F 04 ; panel param mirror
  STA $0548                               ; $A43D: 8D 48 05 ; pending damage amount
  LDA #$00                                ; $A440: A9 00
  STA $0430                               ; $A442: 8D 30 04
  STA $0431                               ; $A445: 8D 31 04
  LDA #$7E                                ; $A448: A9 7E
  JSR $F28B                               ; $A44A: 20 8B F2 ; SFX
  LDA $0545                               ; $A44D: AD 45 05 ; scan column selects side
  BNE @SideB                              ; $A450: D0 1B
  LDA $0514                               ; $A452: AD 14 05 ; strip 0 buffer ptr
  STA $042C                               ; $A455: 8D 2C 04
  LDA $05AC                               ; $A458: AD AC 05 ; side A strength
  SEC                                     ; $A45B: 38
  SBC $0548                               ; $A45C: ED 48 05
  BCS @StoreSideA                         ; $A45F: B0 08 ; no underflow
  LDA $05AC                               ; $A461: AD AC 05 ; clamp: drain all
  STA $042F                               ; $A464: 8D 2F 04 ; damage = full strength
  LDA #$00                                ; $A467: A9 00
@StoreSideA:
  STA $05AC                               ; $A469: 8D AC 05
@Done:
  RTS                                     ; $A46C: 60
@SideB:
  LDA $0516                               ; $A46D: AD 16 05 ; strip 1 buffer ptr
  STA $042C                               ; $A470: 8D 2C 04
  LDA $05B7                               ; $A473: AD B7 05 ; side B strength
  SEC                                     ; $A476: 38
  SBC $0548                               ; $A477: ED 48 05
  BCS @StoreSideB                         ; $A47A: B0 08 ; no underflow
  LDA $05B7                               ; $A47C: AD B7 05 ; clamp: drain all
  STA $042F                               ; $A47F: 8D 2F 04 ; damage = full strength
  LDA #$00                                ; $A482: A9 00
@StoreSideB:
  STA $05B7                               ; $A484: 8D B7 05
  RTS                                     ; $A487: 60
.endproc
;===============================================================================
; $A488: Phase4ResultDamageApply
; Sub 4: anim-idle + A/B edge gate; on input, Phase4ResultColumnDamageSelect
; returns the current strength of the scanned side (0 if fully drained).
; Non-zero confirms (B1F_PaletteCopyBuffer, sub <- 2, BattleOverlayTotalRefresh);
; zero advances to sub 5 with SFX $D3.
;===============================================================================
.proc Phase4ResultDamageApply
  JSR BattleBothPadsStateFetch            ; $A488: 20 22 CD ; merge both pads
  JSR $B870                               ; $A48B: 20 70 B8 ; anim queue idle check
  BCC @Done                               ; $A48E: 90 24 ; busy: wait
  JSR $CCA8                               ; $A490: 20 A8 CC ; panel input check setup
  JSR BattleBothPadsStateFetch            ; $A493: 20 22 CD ; re-fetch merged pad state
  LDA $01                                 ; $A496: A5 01 ; merged raw state
  AND #$03                                ; $A498: 29 03 ; A or B edge?
  BEQ @Done                               ; $A49A: F0 18
  JSR Phase4ResultColumnDamageSelect      ; $A49C: 20 D8 A4 ; strength of scanned side
  BEQ @Advance                            ; $A49F: F0 0B ; fully drained
  JSR B1F_PaletteCopyBuffer               ; $A4A1: 20 EE EC ; confirm path
  LDA #$02                                ; $A4A4: A9 02
  STA $0541                               ; $A4A6: 8D 41 05 ; sub-phase <- 2
  JMP $CA3F                               ; $A4A9: 4C 3F CA ; overlay total refresh
@Advance:
  INC $0541                               ; $A4AC: EE 41 05 ; sub-phase <- 5
  LDA #$D3                                ; $A4AF: A9 D3
  JSR $F28B                               ; $A4B1: 20 8B F2 ; SFX
@Done:
  RTS                                     ; $A4B4: 60
.endproc
;===============================================================================
; $A4B5: Phase4ResultConfirmInput
; Sub 5: anim-idle + A/B edge gate; on input, Phase4ResultColumnStripSelect
; marks the drained side's strip flag ($0515 side A / $0517 side B <- 2),
; then loops to sub 2 via B1F_PaletteCopyBuffer + BattleOverlayTotalRefresh.
;===============================================================================
.proc Phase4ResultConfirmInput
  JSR BattleBothPadsStateFetch            ; $A4B5: 20 22 CD ; merge both pads
  JSR $B870                               ; $A4B8: 20 70 B8 ; anim queue idle check
  BCC @Done                               ; $A4BB: 90 1A ; busy: wait
  JSR $CCA8                               ; $A4BD: 20 A8 CC ; panel input check setup
  JSR BattleBothPadsStateFetch            ; $A4C0: 20 22 CD ; re-fetch merged pad state
  LDA $01                                 ; $A4C3: A5 01 ; merged raw state
  AND #$03                                ; $A4C5: 29 03 ; A or B edge?
  BEQ @Done                               ; $A4C7: F0 0E
  JSR Phase4ResultColumnStripSelect       ; $A4C9: 20 E6 A4 ; mark drained side strip
  JSR B1F_PaletteCopyBuffer               ; $A4CC: 20 EE EC ; palette refresh
  LDA #$02                                ; $A4CF: A9 02
  STA $0541                               ; $A4D1: 8D 41 05 ; sub-phase <- 2
  JMP $CA3F                               ; $A4D4: 4C 3F CA ; overlay total refresh
@Done:
  RTS                                     ; $A4D7: 60
.endproc
;===============================================================================
; $A4D8: Phase4ResultColumnDamageSelect
; Helper for Phase4ResultDamageApply: returns A = strength of the side
; selected by scan column $0545 (0 -> side A $05AC, non-zero -> side B
; $05B7); Z flag set when the side is fully drained.
;===============================================================================
.proc Phase4ResultColumnDamageSelect
  LDA $05AC                               ; $A4D8: AD AC 05 ; side A strength
  LDY $0545                               ; $A4DB: AC 45 05 ; scan column
  BEQ @Compare                            ; $A4DE: F0 03 ; column 0: side A
  LDA $05B7                               ; $A4E0: AD B7 05 ; side B strength
@Compare:
  CMP #$00                                ; $A4E3: C9 00 ; set Z if drained
  RTS                                     ; $A4E5: 60
.endproc
;===============================================================================
; $A4E6: Phase4ResultColumnStripSelect
; Helper for Phase4ResultConfirmInput: sets the strip flag of the side
; selected by scan column $0545: column 0 -> $0515 (side A), else $0517
; (side B) <- 2.
;===============================================================================
.proc Phase4ResultColumnStripSelect
  LDY $0545                               ; $A4E6: AC 45 05 ; scan column
  BEQ @SideA                              ; $A4E9: F0 06 ; column 0: side A
  LDA #$02                                ; $A4EB: A9 02
  STA $0517                               ; $A4ED: 8D 17 05 ; side B strip flag
  RTS                                     ; $A4F0: 60
@SideA:
  LDA #$02                                ; $A4F1: A9 02
  STA $0515                               ; $A4F3: 8D 15 05 ; side A strip flag
  RTS                                     ; $A4F6: 60
.endproc
;===============================================================================
; $A4F7: Phase2ActionSubDispatch
; Phase 2 (acting-unit command resolution) handler of BattleOverlayDispatch,
; run once per VBlank while $0540 = 2. Redraws the side status counters
; ($0574-$0577), polls both pads for player takeover requests
; (BattlePlayerRequestPoll), then sub-dispatches on $0541 through the inline
; 11-entry table below. Sub-state flow: sub 0 routes on the acting unit's
; command value $054F to the attack path (subs 6-9), the move path (subs
; 3-5) or the cursor-walk/pass path (subs 1-2); subs 5 and $A wait out the
; action animation before returning to phase 1 sub 2 (Phase1RoundPass).
;===============================================================================
.proc Phase2ActionSubDispatch
  JSR BattleSideStatusCounterDraw         ; $A4F7: 20 4C BF ; redraw $0574-$0577
  JSR BattlePlayerRequestPoll             ; $A4FA: 20 9D A3 ; player takeover poll
  LDA $0541                               ; $A4FD: AD 41 05 ; sub-phase index
  JSR B1F_CallbackDispatcher              ; $A500: 20 DE EA
; --- CallbackDispatcher sub-phase table, indexed by $0541 ---
  .word Phase2ActionGate                  ; $A503: 19 A5 ; sub 0
  .word Phase2CursorWalkInit              ; $A505: C4 A5 ; sub 1
  .word Phase2CursorWalkStep              ; $A507: F3 A5 ; sub 2
  .word Phase2MoveEventCheck              ; $A509: 1D A6 ; sub 3
  .word Phase2MoveCommit                  ; $A50B: 54 A6 ; sub 4
  .word Phase2ActionEndWait               ; $A50D: E4 A6 ; sub 5
  .word Phase2AttackSetup                 ; $A50F: 02 A7 ; sub 6
  .word Phase2AttackArrowAnim             ; $A511: 2E A7 ; sub 7
  .word Phase2AttackAnimCount             ; $A513: 4A A7 ; sub 8
  .word Phase2AttackDamageApply           ; $A515: 5B A7 ; sub 9
  .word Phase2ActionDoneWait              ; $A517: E0 A7 ; sub $A
.endproc
;===============================================================================
; $A519: Phase2ActionGate
; Sub 0: routes the acting unit's command value $054F (copied from action
; slot $0550 by Phase1NextActorSelect). First clears the frame counter $0548
; and the recorded-status byte $054C. Command 1 goes straight to the
; selection gate. Otherwise the cursor column's status $05C2[$0545] decides:
; action bits == 2 takes the attack route (status recorded into $054C,
; actor id encoded into the status high nibble, sub <- 6), anything else the
; move route (status into $054B, sub <- 3); command 3 with action bits 0
; also falls to the selection gate, as does a missing actor ($0549 bit7).
; Selection gate: command 2 passes the turn outright; otherwise the side
; status counter $0574 nybble for the scanned board half (low for columns
; 0-$A, high for columns $B-$15) must be clear to select - non-zero passes
; the turn. Selection clears $FE/$FF markers via Phase2ColumnResetCheck,
; runs $C064, encodes the actor into the column status and advances to the
; cursor walk (sub 1).
;===============================================================================
.proc Phase2ActionGate
  LDA #$00                                ; $A519: A9 00
  STA $0548                               ; $A51B: 8D 48 05 ; frame counter <- 0
  LDA #$00                                ; $A51E: A9 00
  STA $054C                               ; $A520: 8D 4C 05 ; recorded status <- 0
  LDA $054F                               ; $A523: AD 4F 05 ; command value
  CMP #$01                                ; $A526: C9 01
  BEQ @SelectGate                         ; $A528: F0 62 ; command 1: selection gate
  LDY $0545                               ; $A52A: AC 45 05 ; cursor column
  LDA $05C2,Y                             ; $A52D: B9 C2 05 ; column status
  AND #$0F                                ; $A530: 29 0F ; action bits
  CMP #$02                                ; $A532: C9 02
  BNE @MoveRoute                          ; $A534: D0 2B
  JSR $C30F                               ; $A536: 20 0F C3 ; attack-route setup
  LDA $0549                               ; $A539: AD 49 05 ; acting unit id
  BMI @MoveRoute                          ; $A53C: 30 23 ; no actor: move route
  LDA $054F                               ; $A53E: AD 4F 05
  CMP #$03                                ; $A541: C9 03
  BNE @AttackRoute                        ; $A543: D0 07
  LDA $05C2,X                             ; $A545: BD C2 05
  AND #$03                                ; $A548: 29 03
  BEQ @MoveRoute                          ; $A54A: F0 15 ; cmd 3, bits 0: move route
@AttackRoute:
  LDY $0545                               ; $A54C: AC 45 05
  LDA $05C2,Y                             ; $A54F: B9 C2 05 ; column status
  STA $054C                               ; $A552: 8D 4C 05 ; record for commit
  LDA $0549                               ; $A555: AD 49 05 ; acting unit id
  JSR Phase2ColumnStatusEncode            ; $A558: 20 0F AA ; encode into status
  LDA #$06                                ; $A55B: A9 06
  STA $0541                               ; $A55D: 8D 41 05 ; sub-phase <- 6 (attack)
  RTS                                     ; $A560: 60
@MoveRoute:
  JSR $C20F                               ; $A561: 20 0F C2 ; move-route setup
  LDA $0549                               ; $A564: AD 49 05
  BMI @SelectGate                         ; $A567: 30 23 ; no actor: selection gate
  LDA $054F                               ; $A569: AD 4F 05
  CMP #$03                                ; $A56C: C9 03
  BNE @MoveRecord                         ; $A56E: D0 07
  LDA $05C2,X                             ; $A570: BD C2 05
  AND #$03                                ; $A573: 29 03
  BEQ @SelectGate                         ; $A575: F0 15 ; cmd 3, bits 0: gate
@MoveRecord:
  LDY $0545                               ; $A577: AC 45 05
  LDA $05C2,Y                             ; $A57A: B9 C2 05 ; column status
  STA $054B                               ; $A57D: 8D 4B 05 ; record for commit
  LDA $0549                               ; $A580: AD 49 05 ; acting unit id
  JSR Phase2ColumnStatusEncode            ; $A583: 20 0F AA ; encode into status
  LDA #$03                                ; $A586: A9 03
  STA $0541                               ; $A588: 8D 41 05 ; sub-phase <- 3 (move)
  RTS                                     ; $A58B: 60
@SelectGate:
  LDA $054F                               ; $A58C: AD 4F 05
  CMP #$02                                ; $A58F: C9 02
  BEQ @PassTurn                           ; $A591: F0 2E ; command 2: pass
  LDY $0545                               ; $A593: AC 45 05 ; cursor column
  BEQ @CounterUpper                       ; $A596: F0 0D ; column 0: high nybble
  CPY #$0B                                ; $A598: C0 0B
  BNE @Select                             ; $A59A: D0 10 ; inner columns: select
  LDA $0574                               ; $A59C: AD 74 05 ; side status counter
  AND #$0F                                ; $A59F: 29 0F ; lower-half nybble
  BNE @PassTurn                           ; $A5A1: D0 1E
  BEQ @Select                             ; $A5A3: F0 07
@CounterUpper:
  LDA $0574                               ; $A5A5: AD 74 05 ; side status counter
  AND #$F0                                ; $A5A8: 29 F0 ; upper-half nybble
  BNE @PassTurn                           ; $A5AA: D0 15
@Select:
  JSR Phase2ColumnResetCheck              ; $A5AC: 20 FE A7 ; clear $FE/$FF markers
  JSR $C064                               ; $A5AF: 20 64 C0
  LDA $0549                               ; $A5B2: AD 49 05 ; acting unit id
  BMI @PassTurn                           ; $A5B5: 30 0A ; no actor: pass turn
  INC $0541                               ; $A5B7: EE 41 05 ; sub-phase <- 1 (walk)
  LDA $0549                               ; $A5BA: AD 49 05
  JSR Phase2ColumnStatusEncode            ; $A5BD: 20 0F AA ; encode actor
@Done:
  RTS                                     ; $A5C0: 60
@PassTurn:
  JMP Phase2TurnPassReset                 ; $A5C1: 4C 06 A6
.endproc
;===============================================================================
; $A5C4: Phase2CursorWalkInit
; Sub 1: un-highlights the cursor column ($12=0/$13=column -> $B882),
; advances to sub 2, clears the frame counter $0548 and latches the acting
; column's row markers: $054A <- $0580[$0545]<<4, $054B <- $0596[$0545]<<4.
; Draws the first cursor-arrow frame via $BB8F.
;===============================================================================
.proc Phase2CursorWalkInit
  LDA #$00                                ; $A5C4: A9 00
  STA $12                                 ; $A5C6: 85 12 ; un-highlight
  LDA $0545                               ; $A5C8: AD 45 05 ; cursor column
  STA $13                                 ; $A5CB: 85 13
  JSR $B882                               ; $A5CD: 20 82 B8 ; column tile update
  INC $0541                               ; $A5D0: EE 41 05 ; sub-phase <- 2
  LDA #$00                                ; $A5D3: A9 00
  STA $0548                               ; $A5D5: 8D 48 05 ; frame counter <- 0
  LDY $0545                               ; $A5D8: AC 45 05
  LDA $0580,Y                             ; $A5DB: B9 80 05 ; row marker
  ASL                                     ; $A5DE: 0A
  ASL                                     ; $A5DF: 0A
  ASL                                     ; $A5E0: 0A
  ASL                                     ; $A5E1: 0A
  STA $054A                               ; $A5E2: 8D 4A 05 ; walk row << 4
  LDA $0596,Y                             ; $A5E5: B9 96 05 ; row marker
  ASL                                     ; $A5E8: 0A
  ASL                                     ; $A5E9: 0A
  ASL                                     ; $A5EA: 0A
  ASL                                     ; $A5EB: 0A
  STA $054B                               ; $A5EC: 8D 4B 05 ; walk column << 4
  JSR $BB8F                               ; $A5EF: 20 8F BB ; cursor arrow draw
  RTS                                     ; $A5F2: 60
.endproc
;===============================================================================
; $A5F3: Phase2CursorWalkStep
; Sub 2: animates the cursor walk - redraws the arrow ($BB8F) and steps the
; walk position one cell per frame in the direction for acting side $0549
; (Phase2CursorStep). After $10 frames calls Phase2CommitMarkerAdjust, whose
; RTS lands in Phase2TurnPassReset; while walking, the wait loop branches to
; Phase2TurnPassReset's shared Phase2WalkExit RTS.
;===============================================================================
.proc Phase2CursorWalkStep
  JSR $BB8F                               ; $A5F3: 20 8F BB ; cursor arrow draw
  JSR Phase2CursorStep                    ; $A5F6: 20 A0 A9 ; step walk position
  INC $0548                               ; $A5F9: EE 48 05 ; frame counter++
  LDA $0548                               ; $A5FC: AD 48 05
  CMP #$10                                ; $A5FF: C9 10
  BCC Phase2WalkExit                      ; $A601: 90 19 ; still walking
  JSR Phase2CommitMarkerAdjust            ; $A603: 20 BD A9 ; commit; falls through
.endproc
;===============================================================================
; $A606: Phase2TurnPassReset
; Turn-pass reset, entered two ways: fall-through from Phase2CursorWalkStep
; (after the walk completes) and via JMP from Phase2ActionGate's pass-turn
; paths. Re-highlights the cursor column ($12=$10/$13=column -> $B882) and
; returns to phase 1 sub 2 (Phase1RoundPass).
;===============================================================================
.proc Phase2TurnPassReset
  LDA #$10                                ; $A606: A9 10
  STA $12                                 ; $A608: 85 12 ; highlight
  LDA $0545                               ; $A60A: AD 45 05 ; cursor column
  STA $13                                 ; $A60D: 85 13
  JSR $B882                               ; $A60F: 20 82 B8 ; column tile update
  LDA #$01                                ; $A612: A9 01
  STA $0540                               ; $A614: 8D 40 05 ; phase <- 1
  LDA #$02                                ; $A617: A9 02
  STA $0541                               ; $A619: 8D 41 05 ; sub <- 2 (Phase1RoundPass)
.endproc
;-------------------------------------------------------------------------------
; $A61C: Phase2WalkExit - shared RTS at the tail of Phase2TurnPassReset,
; branched to by Phase2CursorWalkStep's wait loop.
; Practice: a shared RTS has exactly one byte, so its label cannot live in
; two procs; ca65 scopes every label inside .proc (plain cross-proc refs,
; Proc::Label, anonymous :-, and .global all fail to reach it), so shared
; exit labels must stay bare globals between procs.
;-------------------------------------------------------------------------------
Phase2WalkExit:
  RTS                                     ; $A61C: 60
;===============================================================================
; $A61D: Phase2MoveEventCheck
; Sub 3 (move path first step): end-battle event gate - when the cursor
; column is one of the side-event columns (0 or $0B) and the latched walk
; position ($054A) is also 0 or $0B, a pending side event routes straight
; to phase 5 sub 0. Otherwise re-highlights the cursor column, advances to
; sub 4, clears the frame counter $0548 and plays SFX $5E (move start).
;===============================================================================
.proc Phase2MoveEventCheck
  LDA $0545                               ; $A61D: AD 45 05 ; cursor column
  BEQ @EventColumnCheck                   ; $A620: F0 04 ; column 0
  CMP #$0B                                ; $A622: C9 0B
  BNE @CommitPrep                         ; $A624: D0 14 ; inner column
@EventColumnCheck:
  LDA $054A                               ; $A626: AD 4A 05 ; walk row << 4
  BEQ @GotoPhase5                         ; $A629: F0 04
  CMP #$0B                                ; $A62B: C9 0B
  BNE @CommitPrep                         ; $A62D: D0 0B
@GotoPhase5:
  LDA #$05                                ; $A62F: A9 05
  STA $0540                               ; $A631: 8D 40 05 ; phase <- 5
  LDA #$00                                ; $A634: A9 00
  STA $0541                               ; $A636: 8D 41 05 ; sub-phase <- 0
  RTS                                     ; $A639: 60
@CommitPrep:
  LDA #$10                                ; $A63A: A9 10
  STA $12                                 ; $A63C: 85 12 ; highlight
  LDA $0545                               ; $A63E: AD 45 05 ; cursor column
  STA $13                                 ; $A641: 85 13
  JSR $B882                               ; $A643: 20 82 B8 ; column tile update
  INC $0541                               ; $A646: EE 41 05 ; sub-phase <- 4
  LDA #$00                                ; $A649: A9 00
  STA $0548                               ; $A64B: 8D 48 05 ; frame counter <- 0
  LDA #$5E                                ; $A64E: A9 5E
  JSR B1F_SoundNotePlayer                 ; $A650: 20 09 E6 ; SFX move start
.endproc
;-------------------------------------------------------------------------------
; $A653: Phase2AnimWaitExit - shared RTS at the tail of Phase2MoveEventCheck,
; branched to by Phase2MoveCommit's animation wait loop.
; Bare global between procs by necessity: see Phase2WalkExit ($A61C).
;-------------------------------------------------------------------------------
Phase2AnimWaitExit:
  RTS                                     ; $A653: 60
;===============================================================================
; $A654: Phase2MoveCommit
; Sub 4: draws the cursor arrow ($BE15) each frame and blinks the target
; column (Phase2CursorBlinkIfActive, Y = walk row $054A) while the frame
; counter $0548 counts to $20. Then writes the recorded column status $054B
; back to $05C2[$0545] and computes the damage inflicted on column $054A:
; if its action bits are 2, Phase2AttackComputeDefended (60% base), else
; Phase2AttackDamageCompute. The damage ($00) is subtracted from the column
; HP $05AC[$054A]; a drained column is eliminated (panel update with amount
; $01, un-highlight, roster slots $0580/$0596/$05AC/$05C2 <- $FF), a
; surviving column is redrawn highlighted. Either way advances to sub 5.
;===============================================================================
.proc Phase2MoveCommit
  JSR $BE15                               ; $A654: 20 15 BE ; cursor arrow draw
  LDY $054A                               ; $A657: AC 4A 05 ; target column
  JSR Phase2CursorBlinkIfActive           ; $A65A: 20 D0 A6 ; blink target
  INC $0548                               ; $A65D: EE 48 05 ; frame counter++
  LDA $0548                               ; $A660: AD 48 05
  CMP #$20                                ; $A663: C9 20
  BCC Phase2AnimWaitExit                  ; $A665: 90 EC ; still animating
  LDY $0545                               ; $A667: AC 45 05 ; cursor column
  LDA $054B                               ; $A66A: AD 4B 05 ; recorded status
  STA $05C2,Y                             ; $A66D: 99 C2 05 ; commit new status
  LDY $0545                               ; $A670: AC 45 05
  LDA $05C2,Y                             ; $A673: B9 C2 05
  AND #$0F                                ; $A676: 29 0F ; action bits
  CMP #$02                                ; $A678: C9 02
  BNE @PlainDamage                        ; $A67A: D0 06
  JSR Phase2AttackComputeDefended         ; $A67C: 20 4D A8 ; 60% base damage
  JMP @ApplyDamage                        ; $A67F: 4C 85 A6
@PlainDamage:
  JSR Phase2AttackDamageCompute           ; $A682: 20 F2 A8 ; full damage
@ApplyDamage:
  LDY $054A                               ; $A685: AC 4A 05 ; target column
  LDA $05AC,Y                             ; $A688: B9 AC 05 ; target HP
  SEC                                     ; $A68B: 38
  SBC $00                                 ; $A68C: E5 00 ; subtract damage
  STA $05AC,Y                             ; $A68E: 99 AC 05
  BEQ @Eliminated                         ; $A691: F0 02 ; exactly drained
  BCS @Survived                           ; $A693: B0 28 ; HP left
@Eliminated:
  LDA $01                                 ; $A695: A5 01 ; computed amount
  STA $00                                 ; $A697: 85 00
  JSR Phase2DamagePanelUpdate             ; $A699: 20 C5 A7 ; panel damage number
  LDA #$00                                ; $A69C: A9 00
  STA $12                                 ; $A69E: 85 12 ; un-highlight
  LDA $054A                               ; $A6A0: AD 4A 05 ; target column
  STA $13                                 ; $A6A3: 85 13
  JSR $B882                               ; $A6A5: 20 82 B8 ; column tile update
  LDY $054A                               ; $A6A8: AC 4A 05
  LDA #$FF                                ; $A6AB: A9 FF
  STA $0580,Y                             ; $A6AD: 99 80 05 ; empty slot
  STA $0596,Y                             ; $A6B0: 99 96 05
  STA $05AC,Y                             ; $A6B3: 99 AC 05
  STA $05C2,Y                             ; $A6B6: 99 C2 05
  INC $0541                               ; $A6B9: EE 41 05 ; sub-phase <- 5
  RTS                                     ; $A6BC: 60
@Survived:
  JSR Phase2DamagePanelUpdate             ; $A6BD: 20 C5 A7 ; panel damage number
  LDA #$10                                ; $A6C0: A9 10
  STA $12                                 ; $A6C2: 85 12 ; highlight
  LDA $054A                               ; $A6C4: AD 4A 05 ; target column
  STA $13                                 ; $A6C7: 85 13
  JSR $B882                               ; $A6C9: 20 82 B8 ; column tile update
  INC $0541                               ; $A6CC: EE 41 05 ; sub-phase <- 5
@Done:
  RTS                                     ; $A6CF: 60
.endproc
;===============================================================================
; $A6D0: Phase2CursorBlinkIfActive
; Conditional column blink: when $005E bits 0-1 are set (frame phase),
; bit 3 selects the highlight mode into $12 and the column index (Y) into
; $13, then updates the column tile via $B882.
;===============================================================================
.proc Phase2CursorBlinkIfActive
  LDA a:$005E                             ; $A6D0: AD 5E 00 ; frame phase flags
  AND #$03                                ; $A6D3: 29 03
  BEQ @Done                               ; $A6D5: F0 0C ; not a blink frame
  LDA a:$005E                             ; $A6D7: AD 5E 00
  AND #$08                                ; $A6DA: 29 08 ; highlight mode
  STA $12                                 ; $A6DC: 85 12
  STY $13                                 ; $A6DE: 84 13 ; column index
  JSR $B882                               ; $A6E0: 20 82 B8 ; column tile update
@Done:
  RTS                                     ; $A6E3: 60
.endproc
;===============================================================================
; $A6E4: Phase2ActionEndWait
; Sub 5: waits for $007E bit2 (action animation done); then re-highlights
; the cursor column and returns to phase 1 sub 2 (Phase1RoundPass).
;===============================================================================
.proc Phase2ActionEndWait
  LDA a:$007E                             ; $A6E4: AD 7E 00 ; action status
  AND #$04                                ; $A6E7: 29 04 ; done flag
  BNE @Done                               ; $A6E9: D0 16 ; not yet: wait
  LDA #$10                                ; $A6EB: A9 10
  STA $12                                 ; $A6ED: 85 12 ; highlight
  LDA $0545                               ; $A6EF: AD 45 05 ; cursor column
  STA $13                                 ; $A6F2: 85 13
  JSR $B882                               ; $A6F4: 20 82 B8 ; column tile update
  LDA #$01                                ; $A6F7: A9 01
  STA $0540                               ; $A6F9: 8D 40 05 ; phase <- 1
  LDA #$02                                ; $A6FC: A9 02
  STA $0541                               ; $A6FE: 8D 41 05 ; sub <- 2 (Phase1RoundPass)
@Done:
  RTS                                     ; $A701: 60
.endproc
;===============================================================================
; $A702: Phase2AttackSetup
; Sub 6: re-highlights the cursor column, advances to sub 7, latches the
; acting column's row markers ($054A <- $0580[Y]<<4, $054B <- $0596[Y]<<4)
; and plays SFX $5A (attack start).
;===============================================================================
.proc Phase2AttackSetup
  LDA #$10                                ; $A702: A9 10
  STA $12                                 ; $A704: 85 12 ; highlight
  LDA $0545                               ; $A706: AD 45 05 ; cursor column
  STA $13                                 ; $A709: 85 13
  JSR $B882                               ; $A70B: 20 82 B8 ; column tile update
  INC $0541                               ; $A70E: EE 41 05 ; sub-phase <- 7
  LDY $0545                               ; $A711: AC 45 05
  LDA $0580,Y                             ; $A714: B9 80 05 ; row marker
  ASL                                     ; $A717: 0A
  ASL                                     ; $A718: 0A
  ASL                                     ; $A719: 0A
  ASL                                     ; $A71A: 0A
  STA $054A                               ; $A71B: 8D 4A 05 ; target row << 4
  LDA $0596,Y                             ; $A71E: B9 96 05 ; row marker
  ASL                                     ; $A721: 0A
  ASL                                     ; $A722: 0A
  ASL                                     ; $A723: 0A
  ASL                                     ; $A724: 0A
  STA $054B                               ; $A725: 8D 4B 05 ; target column << 4
  LDA #$5A                                ; $A728: A9 5A
  JSR B1F_SoundWrapperF                   ; $A72A: 20 9B E6 ; SFX attack start
@Done:
  RTS                                     ; $A72D: 60
.endproc
;===============================================================================
; $A72E: Phase2AttackArrowAnim
; Sub 7: submits the attack arrow ($BE76) and fast-steps the cursor position
; (Phase2CursorStepFast) each frame, decrementing the frame counter $0548
; by 2; when it goes negative, resets it to 8, advances to sub 8 and plays
; SFX $5D.
;===============================================================================
.proc Phase2AttackArrowAnim
  JSR $BE76                               ; $A72E: 20 76 BE ; attack arrow draw
  JSR Phase2CursorStepFast                ; $A731: 20 E6 A9 ; step x2
  DEC $0548                               ; $A734: CE 48 05 ; frame counter -= 2
  DEC $0548                               ; $A737: CE 48 05
  BPL Phase2DamageAnimExit                ; $A73A: 10 75 ; still animating
  LDA #$08                                ; $A73C: A9 08
  STA $0548                               ; $A73E: 8D 48 05 ; counter <- 8
  INC $0541                               ; $A741: EE 41 05 ; sub-phase <- 8
  LDA #$5D                                ; $A744: A9 5D
  JSR B1F_SoundNotePlayer                 ; $A746: 20 09 E6 ; SFX
@Done:
  RTS                                     ; $A749: 60
.endproc
;===============================================================================
; $A74A: Phase2AttackAnimCount
; Sub 8: submits the attack arrow ($BF15) each frame, decrementing the frame
; counter $0548; when it goes negative, resets it to $18 and advances to
; sub 9 (damage apply delay).
;===============================================================================
.proc Phase2AttackAnimCount
  JSR $BF15                               ; $A74A: 20 15 BF ; attack arrow draw
  DEC $0548                               ; $A74D: CE 48 05 ; frame counter--
  BPL @Done                               ; $A750: 10 08 ; still animating
  LDA #$18                                ; $A752: A9 18
  STA $0548                               ; $A754: 8D 48 05 ; counter <- $18
  INC $0541                               ; $A757: EE 41 05 ; sub-phase <- 9
@Done:
  RTS                                     ; $A75A: 60
.endproc
;===============================================================================
; $A75B: Phase2AttackDamageApply
; Sub 9: blinks the target column (Phase2CursorBlinkIfActive, Y = $054D)
; while the frame counter $0548 counts down from $18. Then writes the
; recorded status $054C to $05C2[$0545], copies the target column $054D to
; $054A, recomputes the column highlight with attack bonus
; (Phase2AttackComputeWithBonus), and subtracts the damage ($00) from HP
; $05AC[$054D]. A drained column is eliminated (panel update, un-highlight,
; roster slots <- $FF); a surviving column is redrawn highlighted. Either
; way advances to sub $A.
;===============================================================================
.proc Phase2AttackDamageApply
  LDY $054D                               ; $A75B: AC 4D 05 ; target column
  JSR Phase2CursorBlinkIfActive           ; $A75E: 20 D0 A6 ; blink target
  DEC $0548                               ; $A761: CE 48 05 ; frame counter--
  BPL Phase2DamageAnimExit                ; $A764: 10 4B ; still waiting
  LDY $0545                               ; $A766: AC 45 05 ; cursor column
  LDA $054C                               ; $A769: AD 4C 05 ; recorded status
  STA $05C2,Y                             ; $A76C: 99 C2 05 ; commit new status
  LDA $054D                               ; $A76F: AD 4D 05 ; target column
  STA $054A                               ; $A772: 8D 4A 05
  JSR Phase2AttackComputeWithBonus        ; $A775: 20 71 A8 ; damage + bonus
  LDY $054D                               ; $A778: AC 4D 05 ; target column
  LDA $05AC,Y                             ; $A77B: B9 AC 05 ; target HP
  STA $01                                 ; $A77E: 85 01 ; keep pre-damage HP
  SEC                                     ; $A780: 38
  SBC $00                                 ; $A781: E5 00 ; subtract damage
  STA $05AC,Y                             ; $A783: 99 AC 05
  BEQ @Eliminated                         ; $A786: F0 02 ; exactly drained
  BCS Phase2DamageSurvived                ; $A788: B0 28 ; HP left
@Eliminated:
  LDA $01                                 ; $A78A: A5 01 ; pre-damage HP
  STA $00                                 ; $A78C: 85 00
  JSR Phase2DamagePanelUpdate             ; $A78E: 20 C5 A7 ; panel damage number
  LDA #$00                                ; $A791: A9 00
  STA $12                                 ; $A793: 85 12 ; un-highlight
  LDA $054D                               ; $A795: AD 4D 05 ; target column
  STA $13                                 ; $A798: 85 13
  JSR $B882                               ; $A79A: 20 82 B8 ; column tile update
  LDY $054D                               ; $A79D: AC 4D 05
  LDA #$FF                                ; $A7A0: A9 FF
  STA $0580,Y                             ; $A7A2: 99 80 05 ; empty slot
  STA $0596,Y                             ; $A7A5: 99 96 05
  STA $05AC,Y                             ; $A7A8: 99 AC 05
  STA $05C2,Y                             ; $A7AB: 99 C2 05
  INC $0541                               ; $A7AE: EE 41 05 ; sub-phase <- $A
.endproc
;-------------------------------------------------------------------------------
; $A7B1: Phase2DamageAnimExit - shared RTS at the tail of the eliminated
; path of Phase2AttackDamageApply, branched to by the sub 7/sub 9
; animation wait loops.
; Bare global between procs by necessity: see Phase2WalkExit ($A61C).
;-------------------------------------------------------------------------------
Phase2DamageAnimExit:
  RTS                                     ; $A7B1: 60
;===============================================================================
; $A7B2: Phase2DamageSurvived
; Survived path of Phase2AttackDamageApply: updates the damage panel,
; re-highlights the target column and advances to sub $A.
;===============================================================================
.proc Phase2DamageSurvived
  JSR Phase2DamagePanelUpdate             ; $A7B2: 20 C5 A7 ; panel damage number
  LDA #$10                                ; $A7B5: A9 10
  STA $12                                 ; $A7B7: 85 12 ; highlight
  LDA $054D                               ; $A7B9: AD 4D 05 ; target column
  STA $13                                 ; $A7BC: 85 13
  JSR $B882                               ; $A7BE: 20 82 B8 ; column tile update
  INC $0541                               ; $A7C1: EE 41 05 ; sub-phase <- $A
  RTS                                     ; $A7C4: 60
.endproc
;===============================================================================
; $A7C5: Phase2DamagePanelUpdate
; Sets up the damage-number panel update: amount $00 into $0B (high byte
; $0C <- 0), overlay strip buffer pointer $0560 into $0A (or $0561 for
; cursor columns >= $0B), then submits via $D7FB.
;===============================================================================
.proc Phase2DamagePanelUpdate
  LDA $00                                 ; $A7C5: A5 00 ; damage amount
  STA $0B                                 ; $A7C7: 85 0B
  LDA #$00                                ; $A7C9: A9 00
  STA $0C                                 ; $A7CB: 85 0C
  LDA $0560                               ; $A7CD: AD 60 05 ; strip 0 buffer ptr
  LDY $0545                               ; $A7D0: AC 45 05 ; cursor column
  CPY #$0B                                ; $A7D3: C0 0B
  BCC @Submit                             ; $A7D5: 90 03 ; columns 0-$A
  LDA $0561                               ; $A7D7: AD 61 05 ; strip 1 buffer ptr
@Submit:
  STA $0A                                 ; $A7DA: 85 0A
  JSR $D7FB                               ; $A7DC: 20 FB D7 ; panel number update
@Done:
  RTS                                     ; $A7DF: 60
.endproc
;===============================================================================
; $A7E0: Phase2ActionDoneWait
; Sub $A: waits for $007E bit2 (action animation done); then re-highlights
; the cursor column and returns to phase 1 sub 2 (Phase1RoundPass).
;===============================================================================
.proc Phase2ActionDoneWait
  LDA a:$007E                             ; $A7E0: AD 7E 00 ; action status
  AND #$04                                ; $A7E3: 29 04 ; done flag
  BNE @Done                               ; $A7E5: D0 16 ; not yet: wait
  LDA #$10                                ; $A7E7: A9 10
  STA $12                                 ; $A7E9: 85 12 ; highlight
  LDA $0545                               ; $A7EB: AD 45 05 ; cursor column
  STA $13                                 ; $A7EE: 85 13
  JSR $B882                               ; $A7F0: 20 82 B8 ; column tile update
  LDA #$01                                ; $A7F3: A9 01
  STA $0540                               ; $A7F5: 8D 40 05 ; phase <- 1
  LDA #$02                                ; $A7F8: A9 02
  STA $0541                               ; $A7FA: 8D 41 05 ; sub <- 2 (Phase1RoundPass)
@Done:
  RTS                                     ; $A7FD: 60
.endproc
;===============================================================================
; $A7FE: Phase2ColumnResetCheck
; If the cursor column holds a pending side event (command 1 with marker
; $0580[$0545] == 0 for columns 0-$A, or low nibble $F for columns >= $0B),
; un-highlights the column, returns the overlay machine to phase 1 sub 2
; (Phase1RoundPass), marks the column slots cleared ($0580/$0596 <- $FE,
; $05C2 <- $FF) and pops the caller return address so the rest of the frame
; is skipped.
;===============================================================================
.proc Phase2ColumnResetCheck
  LDY $0545                               ; $A7FE: AC 45 05 ; cursor column
  CPY #$0B                                ; $A801: C0 0B
  BCS @UpperColumns                       ; $A803: B0 0F ; columns $B-$15
  LDA $054F                               ; $A805: AD 4F 05 ; command value
  CMP #$01                                ; $A808: C9 01
  BNE @Done                               ; $A80A: D0 40 ; not command 1
  LDA $0580,Y                             ; $A80C: B9 80 05 ; side event marker
  BNE @Done                               ; $A80F: D0 3B ; non-zero: keep
  JMP @ResetColumn                        ; $A811: 4C 24 A8
@UpperColumns:
  LDA $054F                               ; $A814: AD 4F 05 ; command value
  CMP #$01                                ; $A817: C9 01
  BNE @Done                               ; $A819: D0 31 ; not command 1
  LDA $0580,Y                             ; $A81B: B9 80 05 ; side event marker
  AND #$0F                                ; $A81E: 29 0F
  CMP #$0F                                ; $A820: C9 0F
  BNE @Done                               ; $A822: D0 28 ; not $F: keep
@ResetColumn:
  LDA #$00                                ; $A824: A9 00
  STA $12                                 ; $A826: 85 12 ; un-highlight
  LDA $0545                               ; $A828: AD 45 05 ; cursor column
  STA $13                                 ; $A82B: 85 13
  JSR $B882                               ; $A82D: 20 82 B8 ; column tile update
  LDA #$01                                ; $A830: A9 01
  STA $0540                               ; $A832: 8D 40 05 ; phase <- 1
  LDA #$02                                ; $A835: A9 02
  STA $0541                               ; $A837: 8D 41 05 ; sub <- 2 (Phase1RoundPass)
  LDY $0545                               ; $A83A: AC 45 05
  LDA #$FE                                ; $A83D: A9 FE
  STA $0580,Y                             ; $A83F: 99 80 05 ; cleared marker
  STA $0596,Y                             ; $A842: 99 96 05
  LDA #$FF                                ; $A845: A9 FF
  STA $05C2,Y                             ; $A847: 99 C2 05 ; empty roster slot
  PLA                                     ; $A84A: 68 ; drop caller return addr
  PLA                                     ; $A84B: 68
@Done:
  RTS                                     ; $A84C: 60
.endproc
;===============================================================================
; $A84D: Phase2AttackComputeDefended
; Damage compute for a defended target (column action bits == 2): saves the
; side attack values $056A/$056B, scales each to 60% via
; Phase2PercentScale, computes the damage through
; Phase2AttackDamageCompute (result in $00), then restores the original
; values.
;===============================================================================
.proc Phase2AttackComputeDefended
  LDA $056A                               ; $A84D: AD 6A 05 ; side A attack value
  PHA                                     ; $A850: 48
  LDY #$3C                                ; $A851: A0 3C ; 60 percent
  JSR Phase2PercentScale                  ; $A853: 20 CF A8
  STA $056A                               ; $A856: 8D 6A 05
  LDA $056B                               ; $A859: AD 6B 05 ; side B attack value
  PHA                                     ; $A85C: 48
  LDY #$3C                                ; $A85D: A0 3C ; 60 percent
  JSR Phase2PercentScale                  ; $A85F: 20 CF A8
  STA $056B                               ; $A862: 8D 6B 05
  JSR Phase2AttackDamageCompute           ; $A865: 20 F2 A8 ; damage -> $00
  PLA                                     ; $A868: 68
  STA $056B                               ; $A869: 8D 6B 05 ; restore
  PLA                                     ; $A86C: 68
  STA $056A                               ; $A86D: 8D 6A 05
@Done:
  RTS                                     ; $A870: 60
.endproc
;===============================================================================
; $A871: Phase2AttackComputeWithBonus
; Damage compute for the main attack: saves $056A/$056B, scales each to 70%
; via Phase2PercentScale, then - when the matching nybble of the packed
; counter $0577 (low for side A, high for side B) is set - adds a random
; bonus of 0-9 (B1F_RandomByte low nibble, capped at 100). Computes the
; damage through Phase2AttackDamageCompute and restores the originals.
;===============================================================================
.proc Phase2AttackComputeWithBonus
  LDA $056A                               ; $A871: AD 6A 05 ; side A attack value
  PHA                                     ; $A874: 48
  LDY #$46                                ; $A875: A0 46 ; 70 percent
  JSR Phase2PercentScale                  ; $A877: 20 CF A8
  STA $056A                               ; $A87A: 8D 6A 05
  LDA $0577                               ; $A87D: AD 77 05 ; packed bonus counter
  AND #$0F                                ; $A880: 29 0F ; side A nybble
  BEQ @ScaleSideB                         ; $A882: F0 16 ; no bonus
@BonusSideA:
  JSR B1F_RandomByte                      ; $A884: 20 7A E8
  AND #$0F                                ; $A887: 29 0F ; bonus 0-$F
  CMP #$0A                                ; $A889: C9 0A
  BCS @BonusSideA                         ; $A88B: B0 F7 ; reroll >= 10
  CLC                                     ; $A88D: 18
  ADC $056A                               ; $A88E: 6D 6A 05
  CMP #$64                                ; $A891: C9 64 ; cap 100
  BCC @StoreSideA                         ; $A893: 90 02
  LDA #$64                                ; $A895: A9 64
@StoreSideA:
  STA $056A                               ; $A897: 8D 6A 05
@ScaleSideB:
  LDA $056B                               ; $A89A: AD 6B 05 ; side B attack value
  PHA                                     ; $A89D: 48
  LDY #$46                                ; $A89E: A0 46 ; 70 percent
  JSR Phase2PercentScale                  ; $A8A0: 20 CF A8
  STA $056B                               ; $A8A3: 8D 6B 05
  LDA $0577                               ; $A8A6: AD 77 05 ; packed bonus counter
  AND #$F0                                ; $A8A9: 29 F0 ; side B nybble
  BEQ @Compute                            ; $A8AB: F0 16 ; no bonus
@BonusSideB:
  JSR B1F_RandomByte                      ; $A8AD: 20 7A E8
  AND #$0F                                ; $A8B0: 29 0F ; bonus 0-$F
  CMP #$0A                                ; $A8B2: C9 0A
  BCS @BonusSideB                         ; $A8B4: B0 F7 ; reroll >= 10
  CLC                                     ; $A8B6: 18
  ADC $056B                               ; $A8B7: 6D 6B 05
  CMP #$64                                ; $A8BA: C9 64 ; cap 100
  BCC @StoreSideB                         ; $A8BC: 90 02
  LDA #$64                                ; $A8BE: A9 64
@StoreSideB:
  STA $056B                               ; $A8C0: 8D 6B 05
@Compute:
  JSR Phase2AttackDamageCompute           ; $A8C3: 20 F2 A8 ; damage -> $00
  PLA                                     ; $A8C6: 68
  STA $056B                               ; $A8C7: 8D 6B 05 ; restore
  PLA                                     ; $A8CA: 68
  STA $056A                               ; $A8CB: 8D 6A 05
@Done:
  RTS                                     ; $A8CE: 60
.endproc
;===============================================================================
; $A8CF: Phase2PercentScale
; Returns A = A * Y / 100 (value in A, percent in Y) using
; B1F_MathMul24x8 + B1F_MathDiv16.
;===============================================================================
.proc Phase2PercentScale
  STY $03                                 ; $A8CF: 84 03 ; percent
  STA $00                                 ; $A8D1: 85 00 ; value
  LDA #$00                                ; $A8D3: A9 00
  STA $01                                 ; $A8D5: 85 01
  STA $02                                 ; $A8D7: 85 02
  JSR B1F_MathMul24x8                     ; $A8D9: 20 E9 EB ; value * percent
  LDA $06                                 ; $A8DC: A5 06
  STA $01                                 ; $A8DE: 85 01
  LDA $07                                 ; $A8E0: A5 07
  STA $02                                 ; $A8E2: 85 02
  LDA #$64                                ; $A8E4: A9 64 ; divisor 100
  STA $03                                 ; $A8E6: 85 03
  LDA #$00                                ; $A8E8: A9 00
  STA $04                                 ; $A8EA: 85 04
  JSR B1F_MathDiv16                       ; $A8EC: 20 7C EA ; / 100
  LDA $01                                 ; $A8EF: A5 01 ; quotient low
@Done:
  RTS                                     ; $A8F1: 60
.endproc
;===============================================================================
; $A8F2: Phase2AttackDamageCompute
; Core damage computation, result in $00. Base value = side attack value
; $056A (cursor column < $0B, plus bonus $0570 when column 0) or $056B
; (columns >= $0B, plus bonus $0571 when column $0B), scaled by a tier
; percentage chosen from the target HP $05AC[$0545] (tier table 20/40/50/
; 70/85/95/100 for HP < 15/35/60/80/90/100). Then an adjustment keyed on
; index column $054A: edge columns 0/$0B subtract the defense value
; $056E/$056F from half the damage (floor 0); a column whose action bits
; are 1 scales the damage to 3/4.
;===============================================================================
.proc Phase2AttackDamageCompute
  LDY $0545                               ; $A8F2: AC 45 05 ; cursor column
  CPY #$0B                                ; $A8F5: C0 0B
  BCS @SideBBase                          ; $A8F7: B0 0E ; columns $B-$15
  LDA $056A                               ; $A8F9: AD 6A 05 ; side A attack value
  CPY #$00                                ; $A8FC: C0 00
  BNE @ScaleByTier                        ; $A8FE: D0 15
  CLC                                     ; $A900: 18
  ADC $0570                               ; $A901: 6D 70 05 ; column-0 bonus
  JMP @ScaleByTier                        ; $A904: 4C 15 A9
@SideBBase:
  LDA $056B                               ; $A907: AD 6B 05 ; side B attack value
  CPY #$0B                                ; $A90A: C0 0B
  BNE @ScaleByTier                        ; $A90C: D0 07
  CLC                                     ; $A90E: 18
  ADC $0571                               ; $A90F: 6D 71 05 ; column-$B bonus
  JMP @ScaleByTier                        ; $A912: 4C 15 A9 ; redundant jump (ROM artifact)
@ScaleByTier:
  PHA                                     ; $A915: 48 ; base attack value
  LDA $05AC,Y                             ; $A916: B9 AC 05 ; target HP
  LDY #$14                                ; $A919: A0 14 ; 20 percent
  CMP #$0F                                ; $A91B: C9 0F
  BCC @DoScale                            ; $A91D: 90 20 ; HP < 15
  LDY #$28                                ; $A91F: A0 28 ; 40 percent
  CMP #$23                                ; $A921: C9 23
  BCC @DoScale                            ; $A923: 90 1A ; HP < 35
  LDY #$32                                ; $A925: A0 32 ; 50 percent
  CMP #$3C                                ; $A927: C9 3C
  BCC @DoScale                            ; $A929: 90 14 ; HP < 60
  LDY #$46                                ; $A92B: A0 46 ; 70 percent
  CMP #$50                                ; $A92D: C9 50
  BCC @DoScale                            ; $A92F: 90 0E ; HP < 80
  LDY #$55                                ; $A931: A0 55 ; 85 percent
  CMP #$5A                                ; $A933: C9 5A
  BCC @DoScale                            ; $A935: 90 08 ; HP < 90
  LDY #$5F                                ; $A937: A0 5F ; 95 percent
  CMP #$64                                ; $A939: C9 64
  BCC @DoScale                            ; $A93B: 90 02 ; HP < 100
  LDY #$64                                ; $A93D: A0 64 ; 100 percent
@DoScale:
  STY $03                                 ; $A93F: 84 03 ; tier percent
  PLA                                     ; $A941: 68 ; base attack value
  STA $00                                 ; $A942: 85 00
  LDA #$00                                ; $A944: A9 00
  STA $01                                 ; $A946: 85 01
  STA $02                                 ; $A948: 85 02
  JSR B1F_MathMul24x8                     ; $A94A: 20 E9 EB ; base * tier
  LDA $06                                 ; $A94D: A5 06
  STA $01                                 ; $A94F: 85 01
  LDA $07                                 ; $A951: A5 07
  STA $02                                 ; $A953: 85 02
  LDA #$64                                ; $A955: A9 64 ; divisor 100
  STA $03                                 ; $A957: 85 03
  LDA #$00                                ; $A959: A9 00
  STA $04                                 ; $A95B: 85 04
  JSR B1F_MathDiv16                       ; $A95D: 20 7C EA ; / 100
  LDA $01                                 ; $A960: A5 01 ; scaled damage
  STA $00                                 ; $A962: 85 00
  LDY $054A                               ; $A964: AC 4A 05 ; index column
  BEQ @EdgeColumnAdjust                   ; $A967: F0 10 ; column 0
  CPY #$0B                                ; $A969: C0 0B
  BEQ @EdgeColumnAdjust                   ; $A96B: F0 0C ; column $B
  LDA $05C2,Y                             ; $A96D: B9 C2 05 ; column status
  AND #$0F                                ; $A970: 29 0F ; action bits
  CMP #$01                                ; $A972: C9 01
  BEQ @CounterAdjust                      ; $A974: F0 1E ; bits 1: x3/4
  JMP @Done                               ; $A976: 4C 9F A9 ; else: keep
@EdgeColumnAdjust:
  LDA $00                                 ; $A979: A5 00 ; scaled damage
  LSR                                     ; $A97B: 4A ; / 2
  PHA                                     ; $A97C: 48
  LDA $056E                               ; $A97D: AD 6E 05 ; defense value A
  CPY #$0B                                ; $A980: C0 0B
  BCC @SubtractDefense                    ; $A982: 90 03
  LDA $056F                               ; $A984: AD 6F 05 ; defense value B
@SubtractDefense:
  STA $00                                 ; $A987: 85 00
  PLA                                     ; $A989: 68 ; damage / 2
  SEC                                     ; $A98A: 38
  SBC $00                                 ; $A98B: E5 00 ; - defense
  BCS @Store                              ; $A98D: B0 0E ; no underflow
  LDA #$00                                ; $A98F: A9 00 ; floor 0
  JMP @Store                              ; $A991: 4C 9D A9
@CounterAdjust:
  LDA $00                                 ; $A994: A5 00 ; scaled damage
  LSR                                     ; $A996: 4A ; / 2
  STA $00                                 ; $A997: 85 00
  LSR                                     ; $A999: 4A ; / 4
  CLC                                     ; $A99A: 18
  ADC $00                                 ; $A99B: 65 00 ; dmg/2 + dmg/4
@Store:
  STA $00                                 ; $A99D: 85 00 ; final damage
@Done:
  RTS                                     ; $A99F: 60
.endproc
;===============================================================================
; $A9A0: Phase2CursorStep
; Steps the walk position ($054A column / $054B row) one cell per the
; acting side $0549: 0 -> row--, 1 -> row++, 2 -> column--, 3 -> column++.
;===============================================================================
.proc Phase2CursorStep
  LDA $0549                               ; $A9A0: AD 49 05 ; acting side
  BNE @Side1                              ; $A9A3: D0 04
  DEC $054B                               ; $A9A5: CE 4B 05 ; row--
@Done:
  RTS                                     ; $A9A8: 60
@Side1:
  CMP #$01                                ; $A9A9: C9 01
  BNE @Side2                              ; $A9AB: D0 04
  INC $054B                               ; $A9AD: EE 4B 05 ; row++
  RTS                                     ; $A9B0: 60
@Side2:
  CMP #$02                                ; $A9B1: C9 02
  BNE @Side3                              ; $A9B3: D0 04
  DEC $054A                               ; $A9B5: CE 4A 05 ; column--
  RTS                                     ; $A9B8: 60
@Side3:
  INC $054A                               ; $A9B9: EE 4A 05 ; column++
  RTS                                     ; $A9BC: 60
.endproc
;===============================================================================
; $A9BD: Phase2CommitMarkerAdjust
; Commits the walk into the acting column's row markers, per acting side
; $0549: 0 -> $0596[X]--, 1 -> $0596[X]++, 2 -> $0580[X]--, 3 -> $0580[X]++
; (X = cursor column $0545).
;===============================================================================
.proc Phase2CommitMarkerAdjust
  LDA $0549                               ; $A9BD: AD 49 05 ; acting side
  BNE @Side1                              ; $A9C0: D0 07
  LDX $0545                               ; $A9C2: AE 45 05 ; cursor column
  DEC $0596,X                             ; $A9C5: DE 96 05 ; marker--
@Done:
  RTS                                     ; $A9C8: 60
@Side1:
  CMP #$01                                ; $A9C9: C9 01
  BNE @Side2                              ; $A9CB: D0 07
  LDX $0545                               ; $A9CD: AE 45 05
  INC $0596,X                             ; $A9D0: FE 96 05 ; marker++
  RTS                                     ; $A9D3: 60
@Side2:
  CMP #$02                                ; $A9D4: C9 02
  BNE @Side3                              ; $A9D6: D0 07
  LDX $0545                               ; $A9D8: AE 45 05
  DEC $0580,X                             ; $A9DB: DE 80 05 ; marker--
  RTS                                     ; $A9DE: 60
@Side3:
  LDX $0545                               ; $A9DF: AE 45 05
  INC $0580,X                             ; $A9E2: FE 80 05 ; marker++
  RTS                                     ; $A9E5: 60
.endproc
;===============================================================================
; $A9E6: Phase2CursorStepFast
; Double step variant of Phase2CursorStep (two cells per call), used by the
; attack arrow animation.
;===============================================================================
.proc Phase2CursorStepFast
  LDA $0549                               ; $A9E6: AD 49 05 ; acting side
  BNE @Side1                              ; $A9E9: D0 07
  DEC $054B                               ; $A9EB: CE 4B 05 ; row -= 2
  DEC $054B                               ; $A9EE: CE 4B 05
@Done:
  RTS                                     ; $A9F1: 60
@Side1:
  CMP #$01                                ; $A9F2: C9 01
  BNE @Side2                              ; $A9F4: D0 07
  INC $054B                               ; $A9F6: EE 4B 05 ; row += 2
  INC $054B                               ; $A9F9: EE 4B 05
  RTS                                     ; $A9FC: 60
@Side2:
  CMP #$02                                ; $A9FD: C9 02
  BNE @Side3                              ; $A9FF: D0 07
  DEC $054A                               ; $AA01: CE 4A 05 ; column -= 2
  DEC $054A                               ; $AA04: CE 4A 05
  RTS                                     ; $AA07: 60
@Side3:
  INC $054A                               ; $AA08: EE 4A 05 ; column += 2
  INC $054A                               ; $AA0B: EE 4A 05
  RTS                                     ; $AA0E: 60
.endproc
;===============================================================================
; $AA0F: Phase2ColumnStatusEncode
; Encodes the acting unit id (A) into the high nibble of the cursor
; column's roster status $05C2[$0545], preserving the low nibble (action
; bits).
;===============================================================================
.proc Phase2ColumnStatusEncode
  ASL                                     ; $AA0F: 0A ; id << 4
  ASL                                     ; $AA10: 0A
  ASL                                     ; $AA11: 0A
  ASL                                     ; $AA12: 0A
  STA $00                                 ; $AA13: 85 00
  LDY $0545                               ; $AA15: AC 45 05 ; cursor column
  LDA $05C2,Y                             ; $AA18: B9 C2 05 ; column status
  AND #$0F                                ; $AA1B: 29 0F ; keep action bits
  ORA $00                                 ; $AA1D: 05 00 ; merge id
  STA $05C2,Y                             ; $AA1F: 99 C2 05
@Done:
  RTS                                     ; $AA22: 60
.endproc
;===============================================================================
; $AA23: Phase3CommandSubDispatch
; Phase 3 (acting-unit command selection), entered from Phase1NextActorSelect
; on a queued player request (handoff flags $0568/$0569) with $0549 = acting
; side and the resume latch $054B/$054C <- 1/1. First redraws the acting
; side's overlay strip via a banked call into bank $19 (buffer ptr lo from
; $0560[$0549], X=0), then dispatches on $0541 via B1F_CallbackDispatcher
; through the inline 5-entry sub table ($AA40):
;   sub 0 Phase3CommandPanelInit   - command panel field setup
;   sub 1 Phase3CommandAnimStep    - marker step animation + officer display re-render
;   sub 2 Phase3CommandInput       - player command input (A/B/directions)
;   sub 3 Phase3CommandConfirmWait - confirm panel reformat wait
;   sub 4 Phase3CommandResultWait  - result strip reformat, then resumes the
;                                    latched phase/sub at $054B/$054C
;===============================================================================
.proc Phase3CommandSubDispatch
  LDY $0549                               ; $AA23: AC 49 05 ; acting side
  LDA $0560,Y                             ; $AA26: B9 60 05 ; strip buffer ptr lo
  STA a:$0000                             ; $AA29: 8D 00 00
  LDA #$A5                                ; $AA2C: A9 A5 ; ptr hi
  STA a:$000A                             ; $AA2E: 8D 0A 00
  LDX #$00                                ; $AA31: A2 00 ; strip 0
  LDY #$39                                ; $AA33: A0 39
  JSR B1F_BankedCallbackTrampoline        ; $AA35: 20 07 EE
; --- BankedCallbackTrampoline target (bank $19) ---
  .word $A000                             ; $AA38: 00 A0 ; B19_OverlayStripRender_Entry
  LDA $0541                               ; $AA3A: AD 41 05 ; sub-phase
  JSR B1F_CallbackDispatcher              ; $AA3D: 20 DE EA
; --- CallbackDispatcher sub table, indexed by $0541 ---
  .word Phase3CommandPanelInit            ; $AA40: 4A AA ; sub 0 ($AA4A)
  .word Phase3CommandAnimStep             ; $AA42: BD AA ; sub 1 ($AABD)
  .word Phase3CommandInput                ; $AA44: F0 AA ; sub 2 ($AAF0)
  .word Phase3CommandConfirmWait          ; $AA46: 75 AB ; sub 3 ($AB75)
  .word Phase3CommandResultWait           ; $AA48: 9A AB ; sub 4 ($AB9A)
.endproc
;===============================================================================
; $AA4A: Phase3CommandPanelInit
; Sub 0. Advances to sub 1, clears the menu step $0548 and $054A, sets UI
; mode $D1 (B1F_SetUI0) and resolves the acting unit id $0560[$0549] to its
; officer record pointer ($00) via B1F_GetOfficerRecordAddr. Then fills the
; command panel field block $044C-$0457: base value = column-0 strength of
; side A ($05AC) or side B ($05B7) per acting side, overridden from record
; field [0] unless the resume latch $054B == 1; record fields [2]/[1]/[3]
; go to $044F/$0452/$0455, and field [3] == 100 forces $0457 <- $FE. Panel
; param $00BD <- 6.
;===============================================================================
.proc Phase3CommandPanelInit
  INC $0541                               ; $AA4A: EE 41 05 ; sub-phase <- 1
  LDA #$00                                ; $AA4D: A9 00
  STA $0548                               ; $AA4F: 8D 48 05 ; menu step <- 0
  STA $054A                               ; $AA52: 8D 4A 05
  LDA #$D1                                ; $AA55: A9 D1
  JSR B1F_SetUI0                          ; $AA57: 20 6D F2 ; UI mode
  LDY $0549                               ; $AA5A: AC 49 05 ; acting side
  LDA $0560,Y                             ; $AA5D: B9 60 05 ; acting unit id
  JSR B1F_GetOfficerRecordAddr            ; $AA60: 20 D7 F2 ; record ptr -> ($00)
  LDA $05AC                               ; $AA63: AD AC 05 ; side A column-0 strength
  LDY $0549                               ; $AA66: AC 49 05
  BEQ @StoreTotal                         ; $AA69: F0 03
  LDA $05B7                               ; $AA6B: AD B7 05 ; side B column-0 strength
@StoreTotal:
  STA $044C                               ; $AA6E: 8D 4C 04 ; panel base value
  LDX $054B                               ; $AA71: AE 4B 05 ; resume latch phase
  CPX #$01                                ; $AA74: E0 01
  BEQ @FieldCopy                          ; $AA76: F0 07 ; latch 1: keep total
  LDY #$00                                ; $AA78: A0 00
  LDA ($00),Y                             ; $AA7A: B1 00 ; record field [0]
  STA $044C                               ; $AA7C: 8D 4C 04 ; override base value
@FieldCopy:
  LDY #$02                                ; $AA7F: A0 02
  LDA ($00),Y                             ; $AA81: B1 00 ; record field [2]
  STA $044F                               ; $AA83: 8D 4F 04
  LDY #$01                                ; $AA86: A0 01
  LDA ($00),Y                             ; $AA88: B1 00 ; record field [1]
  STA $0452                               ; $AA8A: 8D 52 04
  LDA #$00                                ; $AA8D: A9 00
  STA $044D                               ; $AA8F: 8D 4D 04 ; clear field ext bytes
  STA $044E                               ; $AA92: 8D 4E 04
  STA $0450                               ; $AA95: 8D 50 04
  STA $0451                               ; $AA98: 8D 51 04
  STA $0453                               ; $AA9B: 8D 53 04
  STA $0454                               ; $AA9E: 8D 54 04
  STA $0456                               ; $AAA1: 8D 56 04
  STA $0457                               ; $AAA4: 8D 57 04
  LDY #$03                                ; $AAA7: A0 03
  LDA ($00),Y                             ; $AAA9: B1 00 ; record field [3]
  STA $0455                               ; $AAAB: 8D 55 04
  CMP #$64                                ; $AAAE: C9 64 ; full 100
  BNE @SetPanelParam                      ; $AAB0: D0 05
  LDA #$FE                                ; $AAB2: A9 FE
  STA $0457                               ; $AAB4: 8D 57 04 ; full-strength marker
@SetPanelParam:
  LDA #$06                                ; $AAB7: A9 06
  STA a:$00BD                             ; $AAB9: 8D BD 00 ; panel param
  RTS                                     ; $AABC: 60
.endproc
;===============================================================================
; $AABD: Phase3CommandAnimStep
; Sub 1. Waits while the animation queue is busy ($B870 carry clear) or
; input flag $007E bit2 is set (both wait paths exit at the trailing RTS).
; Otherwise, per frame, refreshes the target marker
; (Phase3CommandMarkerUpdate) and counts the menu step $0548 up to 4;
; then advances to sub 2, resets $0548 and banked-calls
; B1D_1E_OfficerDisplay_Render (Y=$3D) with buffer ptr $0000 <-
; $0560[$0549] to re-render the officer display.
;===============================================================================
.proc Phase3CommandAnimStep
  JSR $B870                               ; $AABD: 20 70 B8 ; anim queue idle check
  BCC @Done                               ; $AAC0: 90 2D ; still busy: wait
  LDA a:$007E                             ; $AAC2: AD 7E 00
  AND #$04                                ; $AAC5: 29 04
  BNE @Done                               ; $AAC7: D0 26 ; input busy: wait
  LDA $0548                               ; $AAC9: AD 48 05 ; menu step
  CMP #$04                                ; $AACC: C9 04
  BCS @Advance                            ; $AACE: B0 07 ; animation done
  JSR Phase3CommandMarkerUpdate           ; $AAD0: 20 A8 AC ; marker step
  INC $0548                               ; $AAD3: EE 48 05 ; step++
  RTS                                     ; $AAD6: 60
@Advance:
  INC $0541                               ; $AAD7: EE 41 05 ; sub-phase <- 2
  LDA #$00                                ; $AADA: A9 00
  STA $0548                               ; $AADC: 8D 48 05 ; menu step <- 0
  LDY $0549                               ; $AADF: AC 49 05 ; acting side
  LDA $0560,Y                             ; $AAE2: B9 60 05 ; strip buffer ptr lo
  STA a:$0000                             ; $AAE5: 8D 00 00
  LDY #$3D                                ; $AAE8: A0 3D
  JSR B1F_BankedCallbackTrampoline        ; $AAEA: 20 07 EE
; --- BankedCallbackTrampoline target (banks $1D+$1E) ---
  .word B1D_1E_OfficerDisplay_Render      ; $AAED: 30 A0
@Done:
  RTS                                     ; $AAEF: 60
.endproc
;===============================================================================
; $AAF0: Phase3CommandInput
; Sub 2. Player command input for the acting side $0549 (pad state via
; BattlePadStateFetch; AI-controlled sides get zeros). B (raw bit1) toggles
; battle flag $008F. A (raw bit0) resolves the current action slot
; $0550[$0549*4+$0548]: slot value 4 with no pending side status counters
; $0574-$0577 (own side's nibble clear) commits straight to phase 8 sub 0
; with the slot <- 2; any other value advances to sub 3, queueing the
; $E8/$E9 tile animation ($0310/$0311, slot $0300=0) via $CBF1 when the
; resume latch $054B == 1 (player-request entry), else handing control off
; at Phase3CommandResultWait::Phase3CommandResumeHandoff. Every frame also
; runs Phase3CommandDirInput + Phase3CommandArrowDraw.
;===============================================================================
.proc Phase3CommandInput
  LDA $0549                               ; $AAF0: AD 49 05 ; acting side
  JSR BattlePadStateFetch                 ; $AAF3: 20 DE CC
  LDA a:$0001                             ; $AAF6: AD 01 00 ; pad raw state
  AND #$02                                ; $AAF9: 29 02 ; B button
  BEQ @ACheck                             ; $AAFB: F0 08
  LDA a:$008F                             ; $AAFD: AD 8F 00 ; battle flag
  EOR #$01                                ; $AB00: 49 01
  STA a:$008F                             ; $AB02: 8D 8F 00 ; toggle
@ACheck:
  LDA $0549                               ; $AB05: AD 49 05
  JSR BattlePadStateFetch                 ; $AB08: 20 DE CC
  LDA a:$0001                             ; $AB0B: AD 01 00
  AND #$01                                ; $AB0E: 29 01 ; A button
  BEQ @FrameUpdate                        ; $AB10: F0 5C ; no A: per-frame path
  LDA $0549                               ; $AB12: AD 49 05
  ASL                                     ; $AB15: 0A
  ASL                                     ; $AB16: 0A
  TAY                                     ; $AB17: A8 ; Y = side * 4
  LDA $0550,Y                             ; $AB18: B9 50 05 ; step-0 action slot
  CMP #$04                                ; $AB1B: C9 04
  BNE @ConfirmAnim                        ; $AB1D: D0 32 ; slot != 4
  LDA $0574                               ; $AB1F: AD 74 05 ; side status counters
  ORA $0575                               ; $AB22: 0D 75 05
  ORA $0576                               ; $AB25: 0D 76 05
  ORA $0577                               ; $AB28: 0D 77 05
  LDY $0549                               ; $AB2B: AC 49 05 ; acting side
  BEQ @SideANibble                        ; $AB2E: F0 07
  AND #$F0                                ; $AB30: 29 F0 ; side B nibble
  BNE @FrameUpdate                        ; $AB32: D0 3A ; counters pending
  JMP @Commit                             ; $AB34: 4C 3B AB
@SideANibble:
  AND #$0F                                ; $AB37: 29 0F ; side A nibble
  BNE @FrameUpdate                        ; $AB39: D0 33 ; counters pending
@Commit:
  LDA #$08                                ; $AB3B: A9 08
  STA $0540                               ; $AB3D: 8D 40 05 ; phase <- 8
  LDA #$00                                ; $AB40: A9 00
  STA $0541                               ; $AB42: 8D 41 05 ; sub-phase <- 0
  LDA $0549                               ; $AB45: AD 49 05
  ASL                                     ; $AB48: 0A
  ASL                                     ; $AB49: 0A
  TAY                                     ; $AB4A: A8
  LDA #$02                                ; $AB4B: A9 02
  STA $0550,Y                             ; $AB4D: 99 50 05 ; slot <- 2
  RTS                                     ; $AB50: 60
@ConfirmAnim:
  INC $0541                               ; $AB51: EE 41 05 ; sub-phase <- 3
  LDA $054B                               ; $AB54: AD 4B 05 ; resume latch phase
  CMP #$01                                ; $AB57: C9 01
  BNE Phase3CommandResumeHandoff          ; $AB59: D0 56 ; hand off
  LDA #$E8                                ; $AB5B: A9 E8
  STA $0310                               ; $AB5D: 8D 10 03 ; anim id lo
  LDA #$E9                                ; $AB60: A9 E9
  STA $0311                               ; $AB62: 8D 11 03 ; anim id hi
  LDA #$00                                ; $AB65: A9 00
  STA $0300                               ; $AB67: 8D 00 03 ; anim slot 0
  JSR $CBF1                               ; $AB6A: 20 F1 CB ; queue animation
  RTS                                     ; $AB6D: 60
@FrameUpdate:
  JSR Phase3CommandDirInput               ; $AB6E: 20 C3 AB ; direction buttons
  JSR Phase3CommandArrowDraw              ; $AB71: 20 73 AC ; arrow sprite
  RTS                                     ; $AB74: 60
.endproc
;===============================================================================
; $AB75: Phase3CommandConfirmWait
; Sub 3. Sets panel param $00BD <- 6 and waits for the animation queue to
; idle ($B870 carry clear); then sets panel param $00BB <- 9 and
; banked-calls B1D_1E_DataFormatter (Y=$3D) with buffer ptr ($0000) <-
; $0560/0 to reformat the confirm panel, advancing to sub 4.
;===============================================================================
.proc Phase3CommandConfirmWait
  LDA #$06                                ; $AB75: A9 06
  STA a:$00BD                             ; $AB77: 8D BD 00 ; panel param
  JSR $B870                               ; $AB7A: 20 70 B8 ; anim queue idle check
  BCC @Done                               ; $AB7D: 90 1A ; still busy: wait
  LDA #$09                                ; $AB7F: A9 09
  STA a:$00BB                             ; $AB81: 8D BB 00 ; panel param
  LDA $0560                               ; $AB84: AD 60 05 ; strip 0 buffer ptr lo
  STA a:$0000                             ; $AB87: 8D 00 00
  LDA #$00                                ; $AB8A: A9 00
  STA a:$0001                             ; $AB8C: 8D 01 00 ; ptr hi
  LDY #$3D                                ; $AB8F: A0 3D
  JSR B1F_BankedCallbackTrampoline        ; $AB91: 20 07 EE
; --- BankedCallbackTrampoline target (banks $1D+$1E) ---
  .word B1D_1E_DataFormatter              ; $AB94: 3C A0
  INC $0541                               ; $AB96: EE 41 05 ; sub-phase <- 4
@Done:
  RTS                                     ; $AB99: 60
.endproc
;===============================================================================
; $AB9A: Phase3CommandResultWait
; Sub 4. Waits while input flag $007E is set; then banked-calls
; B1D_1E_DataFormatter (Y=$3D) with buffer ptr ($0000) <- $0561/1 to
; reformat the result strip and falls through into
; Phase3CommandResumeHandoff. That path is also entered directly from
; Phase3CommandInput's confirm branch: it clears battle flag $008F and
; resumes the latched phase/sub-phase from $054B/$054C (player-request
; entry latches 1/1, returning to Phase1NextActorSelect sub 1).
;===============================================================================
.proc Phase3CommandResultWait
  LDA a:$007E                             ; $AB9A: AD 7E 00 ; input busy flag
  BNE Phase3CommandResultDone             ; $AB9D: D0 23 ; still busy: wait
  LDA $0561                               ; $AB9F: AD 61 05 ; strip 1 buffer ptr lo
  STA a:$0000                             ; $ABA2: 8D 00 00
  LDA #$01                                ; $ABA5: A9 01
  STA a:$0001                             ; $ABA7: 8D 01 00 ; ptr hi
  LDY #$3D                                ; $ABAA: A0 3D
  JSR B1F_BankedCallbackTrampoline        ; $ABAC: 20 07 EE
; --- BankedCallbackTrampoline target (banks $1D+$1E) ---
  .word B1D_1E_DataFormatter              ; $ABAF: 3C A0
.endproc
; Resume handoff: fall-through tail of Phase3CommandResultWait, also entered
; directly from Phase3CommandInput's confirm branch.
Phase3CommandResumeHandoff:
  LDA #$00                                ; $ABB1: A9 00
  STA a:$008F                             ; $ABB3: 8D 8F 00 ; battle flag <- 0
  LDA $054B                               ; $ABB6: AD 4B 05 ; resume latch phase
  STA $0540                               ; $ABB9: 8D 40 05
  LDA $054C                               ; $ABBC: AD 4C 05 ; resume latch sub-phase
  STA $0541                               ; $ABBF: 8D 41 05
Phase3CommandResultDone:
  RTS                                     ; $ABC2: 60
;===============================================================================
; $ABC3: Phase3CommandDirInput
; Direction-button handler for the phase-3 command menu (acting side $0549,
; pad raw bits via BattlePadStateFetch): right $80 / left $40 adjust the
; action slot value $0550[$0549*4+$0548], down $20 / up $10 cycle the menu
; step $0548 through 0-3. Slot values run 0-3, extended to 4/5 at step 0
; while the resume latch $054B == 1 (player-request entry): right underflow
; wraps to 4 there (else 3), left caps at 5 there (else 4, wrapping to 0).
; Any change refreshes the marker via Phase3CommandMarkerUpdate.
;===============================================================================
.proc Phase3CommandDirInput
  LDA $0549                               ; $ABC3: AD 49 05 ; acting side
  JSR BattlePadStateFetch                 ; $ABC6: 20 DE CC
  LDA a:$0001                             ; $ABC9: AD 01 00 ; pad raw state
  AND #$80                                ; $ABCC: 29 80 ; right
  BEQ @LeftPress                          ; $ABCE: F0 2A
  LDA $0549                               ; $ABD0: AD 49 05
  ASL                                     ; $ABD3: 0A
  ASL                                     ; $ABD4: 0A
  ORA $0548                               ; $ABD5: 0D 48 05 ; + menu step
  TAY                                     ; $ABD8: A8 ; slot index
  LDA $0550,Y                             ; $ABD9: B9 50 05 ; action slot value
  SEC                                     ; $ABDC: 38
  SBC #$01                                ; $ABDD: E9 01 ; value--
  BCS @StoreSlot                          ; $ABDF: B0 13 ; no underflow
  LDA #$03                                ; $ABE1: A9 03 ; default wrap
  CPY #$00                                ; $ABE3: C0 00 ; side A step 0
  BEQ @UnderflowLatchCheck                ; $ABE5: F0 04
  CPY #$04                                ; $ABE7: C0 04 ; side B step 0
  BNE @StoreSlot                          ; $ABE9: D0 09
@UnderflowLatchCheck:
  LDX $054B                               ; $ABEB: AE 4B 05 ; resume latch phase
  CPX #$01                                ; $ABEE: E0 01
  BNE @StoreSlot                          ; $ABF0: D0 02
  LDA #$04                                ; $ABF2: A9 04 ; extended wrap
@StoreSlot:
  STA $0550,Y                             ; $ABF4: 99 50 05
  JMP @MarkerUpdate                       ; $ABF7: 4C 6F AC
@LeftPress:
  LDA $0549                               ; $ABFA: AD 49 05
  JSR BattlePadStateFetch                 ; $ABFD: 20 DE CC
  LDA a:$0001                             ; $AC00: AD 01 00
  AND #$40                                ; $AC03: 29 40 ; left
  BEQ @DownPress                          ; $AC05: F0 32
  LDA $0549                               ; $AC07: AD 49 05
  ASL                                     ; $AC0A: 0A
  ASL                                     ; $AC0B: 0A
  ORA $0548                               ; $AC0C: 0D 48 05 ; + menu step
  TAY                                     ; $AC0F: A8 ; slot index
  LDA #$04                                ; $AC10: A9 04 ; default cap
  CPY #$00                                ; $AC12: C0 00 ; side A step 0
  BEQ @CapLatchCheck                      ; $AC14: F0 04
  CPY #$04                                ; $AC16: C0 04 ; side B step 0
  BNE @CapValue                           ; $AC18: D0 09
@CapLatchCheck:
  LDX $054B                               ; $AC1A: AE 4B 05 ; resume latch phase
  CPX #$01                                ; $AC1D: E0 01
  BNE @CapValue                           ; $AC1F: D0 02
  LDA #$05                                ; $AC21: A9 05 ; extended cap
@CapValue:
  STA a:$0000                             ; $AC23: 8D 00 00 ; cap
  LDA $0550,Y                             ; $AC26: B9 50 05 ; action slot value
  CLC                                     ; $AC29: 18
  ADC #$01                                ; $AC2A: 69 01 ; value++
  CMP a:$0000                             ; $AC2C: CD 00 00
  BCC @StoreSlot2                         ; $AC2F: 90 02 ; below cap
  LDA #$00                                ; $AC31: A9 00 ; wrap to 0
@StoreSlot2:
  STA $0550,Y                             ; $AC33: 99 50 05
  JMP @MarkerUpdate                       ; $AC36: 4C 6F AC
@DownPress:
  LDA $0549                               ; $AC39: AD 49 05
  JSR BattlePadStateFetch                 ; $AC3C: 20 DE CC
  LDA a:$0001                             ; $AC3F: AD 01 00
  AND #$20                                ; $AC42: 29 20 ; down
  BEQ @UpPress                            ; $AC44: F0 12
  INC $0548                               ; $AC46: EE 48 05 ; menu step++
  LDA $0548                               ; $AC49: AD 48 05
  CMP #$04                                ; $AC4C: C9 04
  BCC @StepChanged                        ; $AC4E: 90 05 ; steps 0-3
  LDA #$00                                ; $AC50: A9 00
  STA $0548                               ; $AC52: 8D 48 05 ; wrap 4 -> 0
@StepChanged:
  JMP @MarkerUpdate                       ; $AC55: 4C 6F AC
@UpPress:
  LDA $0549                               ; $AC58: AD 49 05
  JSR BattlePadStateFetch                 ; $AC5B: 20 DE CC
  LDA a:$0001                             ; $AC5E: AD 01 00
  AND #$10                                ; $AC61: 29 10 ; up
  BEQ @Done                               ; $AC63: F0 0D ; no button
  DEC $0548                               ; $AC65: CE 48 05 ; menu step--
  BPL @MarkerUpdate                       ; $AC68: 10 05 ; steps 0-3
  LDA #$03                                ; $AC6A: A9 03
  STA $0548                               ; $AC6C: 8D 48 05 ; wrap <0 -> 3
@MarkerUpdate:
  JSR Phase3CommandMarkerUpdate           ; $AC6F: 20 A8 AC
@Done:
  RTS                                     ; $AC72: 60
.endproc
;===============================================================================
; $AC73: Phase3CommandArrowDraw
; Submits the command-menu selection arrow sprite for the current menu step
; $0548: table pointer ($0000) <- Phase3CommandArrowTiles, tile id from the
; step table, row param $000C <- $80, direct placement through
; B1F_SpriteOamWriterSimple (tail call).
;===============================================================================
.proc Phase3CommandArrowDraw
  LDA #$A3                                ; $AC73: A9 A3
  STA a:$0000                             ; $AC75: 8D 00 00 ; table ptr lo
  LDA #$AC                                ; $AC78: A9 AC
  STA a:$0001                             ; $AC7A: 8D 01 00 ; table ptr hi
  LDY $0548                               ; $AC7D: AC 48 05 ; menu step
  LDA Phase3CommandArrowTiles,Y           ; $AC80: B9 9B AC ; tile id
  STA a:$000A                             ; $AC83: 8D 0A 00
  LDA #$80                                ; $AC86: A9 80
  STA a:$000C                             ; $AC88: 8D 0C 00 ; row param
  LDA #$00                                ; $AC8B: A9 00
  STA a:$000B                             ; $AC8D: 8D 0B 00
  STA a:$000D                             ; $AC90: 8D 0D 00
  LDA #$00                                ; $AC93: A9 00
  STA a:$0002                             ; $AC95: 8D 02 00
  JMP B1F_SpriteOamWriterSimple           ; $AC98: 4C AD F1 ; direct placement
;===============================================================================
; $AC9B: Phase3CommandArrowTiles
; Selection-arrow tile ids per menu step: two identical groups of
; $A6/$B6/$C6/$D6 (steps 0-3), followed by filler bytes.
;===============================================================================
Phase3CommandArrowTiles:
  .byte $A6,$B6,$C6,$D6,$A6,$B6,$C6,$D6 ; $AC9B: A6 B6 C6 D6 A6 B6 C6 D6 ; steps 0-3 (x2)
  .byte $00,$07,$00,$00,$80              ; $ACA3: 00 07 00 00 80 ; filler
.endproc
;===============================================================================
; $ACA8: Phase3CommandMarkerUpdate
; Refreshes the command-menu target marker: menu step $0548 into $0000 and
; the current action slot value $0550[$0549*4+$0548] into $0001/$0002,
; then updates via $C839.
;===============================================================================
.proc Phase3CommandMarkerUpdate
  LDA $0548                               ; $ACA8: AD 48 05 ; menu step
  STA a:$0000                             ; $ACAB: 8D 00 00
  LDA $0549                               ; $ACAE: AD 49 05 ; acting side
  ASL                                     ; $ACB1: 0A
  ASL                                     ; $ACB2: 0A
  CLC                                     ; $ACB3: 18
  ADC $0548                               ; $ACB4: 6D 48 05 ; + menu step
  TAY                                     ; $ACB7: A8 ; slot index
  LDA $0550,Y                             ; $ACB8: B9 50 05 ; action slot value
  STA a:$0001                             ; $ACBB: 8D 01 00
  STA a:$0002                             ; $ACBE: 8D 02 00
  JSR $C839                               ; $ACC1: 20 39 C8 ; marker update
  RTS                                     ; $ACC4: 60
.endproc
;===============================================================================
; $ACC5: Phase8PanelSubDispatch
; Phase-8 handler entry (point-spend panel). First redraws the acting side's
; overlay strip (buffer ptr lo from $0560[$0549], hi fixed $A5, X=0) via
; bank $19 $A000, then sub-dispatches on $0541 through the inline 5-entry
; table below: sub-states 0-4 are the Phase8PanelInit..
; Phase8PanelAdvanceWait handlers.
;===============================================================================
.proc Phase8PanelSubDispatch
  LDY $0549                               ; $ACC5: AC 49 05 ; acting side
  LDA $0560,Y                             ; $ACC8: B9 60 05 ; strip buffer ptr lo
  STA a:$0000                             ; $ACCB: 8D 00 00
  LDA #$A5                                ; $ACCE: A9 A5
  STA a:$000A                             ; $ACD0: 8D 0A 00 ; buffer ptr hi
  LDX #$00                                ; $ACD3: A2 00 ; strip 0
  LDY #$39                                ; $ACD5: A0 39
  JSR B1F_BankedCallbackTrampoline        ; $ACD7: 20 07 EE
; --- BankedCallbackTrampoline target (bank $19) ---
  .word $A000                             ; $ACDA: 00 A0 ; B19_OverlayStripRender_Entry
  LDA $0541                               ; $ACDC: AD 41 05 ; sub-phase
  JSR B1F_CallbackDispatcher              ; $ACDF: 20 DE EA
; --- CallbackDispatcher sub-phase table, indexed by $0541 ---
  .word Phase8PanelInit                   ; $ACE2: EC AC ; sub 0 ($ACEC)
  .word Phase8PanelScriptStep             ; $ACE4: 3C AD ; sub 1 ($AD3C)
  .word Phase8PanelMenuInput              ; $ACE6: 5D AD ; sub 2 ($AD5D)
  .word Phase8PanelConfirmWait            ; $ACE8: 11 AE ; sub 3 ($AE11)
  .word Phase8PanelAdvanceWait            ; $ACEA: 8E AE ; sub 4 ($AE8E)
.endproc
;===============================================================================
; $ACEC: Phase8PanelInit
; Sub 0. Advances to sub 1 and clears the row cursor $0548, then computes
; the point tier $054A (0-5) from the per-side point budget $0572[$0549]
; through the threshold ladder <5/<7/<8/<$A/<$C. Sets UI mode $E7 and fills
; the panel field block: base value $044C <- budget, extension bytes
; $044D/$044E cleared, panel param $00BD <- $57, menu cursor $0424/$0425
; cleared. The tier selects the row count (tier+1) for sub 1/sub 2.
;===============================================================================
.proc Phase8PanelInit
  INC $0541                               ; $ACEC: EE 41 05 ; sub-phase <- 1
  LDA #$00                                ; $ACEF: A9 00
  STA $0548                               ; $ACF1: 8D 48 05 ; row cursor <- 0
  LDY $0549                               ; $ACF4: AC 49 05 ; acting side
  LDA $0572,Y                             ; $ACF7: B9 72 05 ; point budget
  LDY #$00                                ; $ACFA: A0 00 ; tier
  CMP #$05                                ; $ACFC: C9 05
  BCC @StoreTier                          ; $ACFE: 90 15
  INY                                     ; $AD00: C8
  CMP #$07                                ; $AD01: C9 07
  BCC @StoreTier                          ; $AD03: 90 10
  INY                                     ; $AD05: C8
  CMP #$08                                ; $AD06: C9 08
  BCC @StoreTier                          ; $AD08: 90 0B
  INY                                     ; $AD0A: C8
  CMP #$0A                                ; $AD0B: C9 0A
  BCC @StoreTier                          ; $AD0D: 90 06
  INY                                     ; $AD0F: C8
  CMP #$0C                                ; $AD10: C9 0C
  BCC @StoreTier                          ; $AD12: 90 01
  INY                                     ; $AD14: C8 ; tier <- 5
@StoreTier:
  STY $054A                               ; $AD15: 8C 4A 05 ; point tier
  LDA #$E7                                ; $AD18: A9 E7
  JSR B1F_SetUI0                          ; $AD1A: 20 6D F2 ; UI mode $E7
  LDY $0549                               ; $AD1D: AC 49 05 ; acting side
  LDA $0572,Y                             ; $AD20: B9 72 05 ; point budget
  STA $044C                               ; $AD23: 8D 4C 04 ; panel base value
  LDA #$00                                ; $AD26: A9 00
  STA $044D                               ; $AD28: 8D 4D 04 ; clear field ext bytes
  STA $044E                               ; $AD2B: 8D 4E 04
  LDA #$57                                ; $AD2E: A9 57
  STA a:$00BD                             ; $AD30: 8D BD 00 ; panel param
  LDA #$00                                ; $AD33: A9 00
  STA $0424                               ; $AD35: 8D 24 04 ; menu cursor col <- 0
  STA $0425                               ; $AD38: 8D 25 04 ; menu cursor page <- 0
  RTS                                     ; $AD3B: 60
.endproc
;===============================================================================
; $AD3C: Phase8PanelScriptStep
; Sub 1. Waits while the animation queue is busy ($B870 carry clear) or a
; row script is still displayed ($007E != 0). Otherwise queues the row
; script line $0548 (row text table via Loc_B0AC, script id $00BB <- 9) and
; counts $0548 up to the point tier $054A; then advances to sub 2.
;===============================================================================
.proc Phase8PanelScriptStep
  JSR $B870                               ; $AD3C: 20 70 B8 ; anim queue idle check
  BCC @Done                               ; $AD3F: 90 1B ; still busy: wait
  LDA a:$007E                             ; $AD41: AD 7E 00 ; script busy flag
  BNE @Done                               ; $AD44: D0 16 ; script pending: wait
  LDA #$09                                ; $AD46: A9 09
  STA a:$00BB                             ; $AD48: 8D BB 00 ; script id
  JSR $B0AC                               ; $AD4B: 20 AC B0 ; queue row script $0548
  LDA $0548                               ; $AD4E: AD 48 05 ; row cursor
  INC $0548                               ; $AD51: EE 48 05 ; row++
  CMP $054A                               ; $AD54: CD 4A 05 ; vs point tier
  BCC @Done                               ; $AD57: 90 03 ; more rows
  INC $0541                               ; $AD59: EE 41 05 ; sub-phase <- 2
@Done:
  RTS                                     ; $AD5C: 60
.endproc
;===============================================================================
; $AD5D: Phase8PanelMenuInput
; Sub 2. Row selection for the point-spend panel. Saves the pad latch
; $0083/$0081 on the stack, refetches the acting side's pad state and
; latches it back, then steps the row cursor $0012 over the current tier's
; FF-terminated row list (Phase8TierRowPtrTable[$054A]) via B1F_MenuStep2
; and draws the selection cursor sprite through B1F_PointerTableLookup
; (coords Phase8RowCursorCoords, params Phase8RowCursorParams). When the
; animation queue idles ($B870 carry set):
;   A: if the budget $0572[$0549] covers the row cost
;      (@RowCostTable[$0012] = 3/5/7/8/$A/$C), deducts it and applies the
;      row effect via Phase8RowEffectDispatch (Phase8RowCoinFlip..
;      Phase8RowAdvance);
;   B: cancels back to phase 3 sub 3 (queueing the $E8/$E9 tile animation
;      slot 0 via $CBF1).
;===============================================================================
.proc Phase8PanelMenuInput
  LDA a:$0083                             ; $AD5D: AD 83 00 ; pad latch hi
@PadLatchPush:
  PHA                                     ; $AD60: 48
  LDA a:$0081                             ; $AD61: AD 81 00 ; pad latch lo
  PHA                                     ; $AD64: 48
  LDA $0549                               ; $AD65: AD 49 05 ; acting side
  JSR BattlePadStateFetch                 ; $AD68: 20 DE CC
  LDA a:$0000                             ; $AD6B: AD 00 00
  STA a:$0083                             ; $AD6E: 8D 83 00 ; relatch hi
  LDA a:$0001                             ; $AD71: AD 01 00
  STA a:$0081                             ; $AD74: 8D 81 00 ; relatch lo
  LDA $054A                               ; $AD77: AD 4A 05 ; point tier
  ASL                                     ; $AD7A: 0A
  TAY                                     ; $AD7B: A8
  LDA Phase8TierRowPtrTable,Y             ; $AD7C: B9 D0 AE ; row list ptr lo
  STA a:$0010                             ; $AD7F: 8D 10 00
  LDA Phase8TierRowPtrTable+1,Y           ; $AD82: B9 D1 AE ; row list ptr hi
  STA a:$0011                             ; $AD85: 8D 11 00
  LDA #$00                                ; $AD88: A9 00
  STA a:$0012                             ; $AD8A: 8D 12 00 ; selected row <- 0
  JSR B1F_MenuStep2                       ; $AD8D: 20 1E ED ; D-pad row stepping
  LDA #$00                                ; $AD90: A9 00
  STA a:$0010                             ; $AD92: 8D 10 00 ; cursor table ptr <- $AF00
  LDA #$AF                                ; $AD95: A9 AF
  STA a:$0011                             ; $AD97: 8D 11 00
  LDA #$0C                                ; $AD9A: A9 0C ; cursor param ptr <- $AF0C
  STA a:$0000                             ; $AD9C: 8D 00 00
  LDA #$AF                                ; $AD9F: A9 AF
  STA a:$0001                             ; $ADA1: 8D 01 00
  LDA a:$0012                             ; $ADA4: AD 12 00 ; selected row
  JSR B1F_PointerTableLookup              ; $ADA7: 20 F5 ED ; cursor sprite write
  PLA                                     ; $ADAA: 68
  STA a:$0081                             ; $ADAB: 8D 81 00 ; restore pad latch lo
  PLA                                     ; $ADAE: 68
  STA a:$0083                             ; $ADAF: 8D 83 00 ; restore pad latch hi
  JSR $B870                               ; $ADB2: 20 70 B8 ; anim queue idle check
  BCC @Done                               ; $ADB5: 90 59 ; still busy: wait
  LDA $0549                               ; $ADB7: AD 49 05
  JSR BattlePadStateFetch                 ; $ADBA: 20 DE CC
  LDA a:$0001                             ; $ADBD: AD 01 00
  AND #$01                                ; $ADC0: 29 01 ; A button
  BEQ @BCancelCheck                       ; $ADC2: F0 23
  LDY $0549                               ; $ADC4: AC 49 05 ; acting side
  LDA $0572,Y                             ; $ADC7: B9 72 05 ; point budget
  LDY a:$0012                             ; $ADCA: AC 12 00 ; selected row
  CMP @RowCostTable,Y                     ; $ADCD: D9 DF AD ; afford check
  BCC @BCancelCheck                       ; $ADD0: 90 15 ; too expensive
  SEC                                     ; $ADD2: 38
  SBC @RowCostTable,Y                     ; $ADD3: F9 DF AD ; deduct cost
  LDY $0549                               ; $ADD6: AC 49 05
  STA $0572,Y                             ; $ADD9: 99 72 05 ; budget -= cost
  JMP Phase8RowEffectDispatch             ; $ADDC: 4C 11 AF ; apply row effect
; --- Row cost per selected row index (last two entries unused padding) ---
@RowCostTable:
  .byte $03,$05,$07,$08,$0A,$0C,$0C,$0C   ; $ADDF: 03 05 07 08 0A 0C 0C 0C
@BCancelCheck:
  LDA $0549                               ; $ADE7: AD 49 05
  JSR BattlePadStateFetch                 ; $ADEA: 20 DE CC
  LDA a:$0001                             ; $ADED: AD 01 00
  AND #$02                                ; $ADF0: 29 02 ; B button
  BEQ @Done                               ; $ADF2: F0 1C ; no button
  LDA #$03                                ; $ADF4: A9 03
  STA $0540                               ; $ADF6: 8D 40 05 ; phase <- 3
  LDA #$03                                ; $ADF9: A9 03
  STA $0541                               ; $ADFB: 8D 41 05 ; sub-phase <- 3
  LDA #$E8                                ; $ADFE: A9 E8
  STA $0310                               ; $AE00: 8D 10 03 ; anim id lo
  LDA #$E9                                ; $AE03: A9 E9
  STA $0311                               ; $AE05: 8D 11 03 ; anim id hi
  LDA #$00                                ; $AE08: A9 00
  STA $0300                               ; $AE0A: 8D 00 03 ; anim slot 0
  JSR $CBF1                               ; $AE0D: 20 F1 CB ; enqueue anim
@Done:
  RTS                                     ; $AE10: 60
.endproc
;===============================================================================
; $AE11: Phase8PanelConfirmWait
; Sub 3. Waits for the animation queue to idle ($B870 carry set) and an A
; button edge, then returns to phase 3 sub 3 (queueing the $E8/$E9 tile
; animation slot 0 via $CBF1). If the side control flag $0562[$0549] == 3
; (player-request entry), both pads are merged via
; BattleBothPadsStateFetch and the resume latch $054B/$054C is set to 1/1
; so phase 3 hands control back afterwards.
;===============================================================================
.proc Phase8PanelConfirmWait
  JSR $CCA8                               ; $AE11: 20 A8 CC ; panel input check setup
  LDY $0549                               ; $AE14: AC 49 05 ; acting side
  LDA $0562,Y                             ; $AE17: B9 62 05 ; side control flag
  CMP #$03                                ; $AE1A: C9 03 ; player-request entry
  BNE @SinglePadFetch                     ; $AE1C: D0 06
  JSR BattleBothPadsStateFetch            ; $AE1E: 20 22 CD
  JMP @InputCheck                         ; $AE21: 4C 2A AE
@SinglePadFetch:
  LDA $0549                               ; $AE24: AD 49 05
  JSR BattlePadStateFetch                 ; $AE27: 20 DE CC
@InputCheck:
  JSR $B870                               ; $AE2A: 20 70 B8 ; anim queue idle check
  BCC @Done                               ; $AE2D: 90 3C ; still busy: wait
  LDA a:$0001                             ; $AE2F: AD 01 00
  AND #$01                                ; $AE32: 29 01 ; A button
  BEQ @Done                               ; $AE34: F0 35 ; no A: wait
  LDY $0549                               ; $AE36: AC 49 05 ; acting side
  LDA $0562,Y                             ; $AE39: B9 62 05 ; side control flag
  CMP #$03                                ; $AE3C: C9 03
  BNE Phase8PanelReturnToCommand          ; $AE3E: D0 2C ; plain return
  LDA #$03                                ; $AE40: A9 03
  STA $0540                               ; $AE42: 8D 40 05 ; phase <- 3
  LDA #$03                                ; $AE45: A9 03
  STA $0541                               ; $AE47: 8D 41 05 ; sub-phase <- 3
  LDA #$E8                                ; $AE4A: A9 E8
  STA $0310                               ; $AE4C: 8D 10 03 ; anim id lo
  LDA #$E9                                ; $AE4F: A9 E9
  STA $0311                               ; $AE51: 8D 11 03 ; anim id hi
  LDA #$00                                ; $AE54: A9 00
  STA $0300                               ; $AE56: 8D 00 03 ; anim slot 0
  LDA #$00                                ; $AE59: A9 00
  STA $0310                               ; $AE5B: 8D 10 03 ; clear anim id lo
  LDA #$01                                ; $AE5E: A9 01
  STA $054B                               ; $AE60: 8D 4B 05 ; resume latch phase <- 1
  LDA #$01                                ; $AE63: A9 01
  STA $054C                               ; $AE65: 8D 4C 05 ; resume latch sub <- 1
  JSR $CBF1                               ; $AE68: 20 F1 CB ; enqueue anim
@Done:
  RTS                                     ; $AE6B: 60
.endproc
;===============================================================================
; $AE6C: Phase8PanelReturnToCommand
; Returns to phase 3 sub 3: sets the phase/sub, queues the $E8/$E9 tile
; animation (slot 0, anim id lo cleared afterwards) via $CBF1.
;===============================================================================
.proc Phase8PanelReturnToCommand
  LDA #$03                                ; $AE6C: A9 03
  STA $0540                               ; $AE6E: 8D 40 05 ; phase <- 3
  LDA #$03                                ; $AE71: A9 03
  STA $0541                               ; $AE73: 8D 41 05 ; sub-phase <- 3
  LDA #$E8                                ; $AE76: A9 E8
  STA $0310                               ; $AE78: 8D 10 03 ; anim id lo
  LDA #$E9                                ; $AE7B: A9 E9
  STA $0311                               ; $AE7D: 8D 11 03 ; anim id hi
  LDA #$00                                ; $AE80: A9 00
  STA $0300                               ; $AE82: 8D 00 03 ; anim slot 0
  LDA #$00                                ; $AE85: A9 00
  STA $0310                               ; $AE87: 8D 10 03 ; clear anim id lo
  JSR $CBF1                               ; $AE8A: 20 F1 CB ; enqueue anim
  RTS                                     ; $AE8D: 60
.endproc
;===============================================================================
; $AE8E: Phase8PanelAdvanceWait
; Sub 4. Waits for the animation queue to idle ($B870 carry set) and an A
; button edge, then advances to phase 5 sub 0 (battle resolution).
;===============================================================================
.proc Phase8PanelAdvanceWait
  JSR $CCA8                               ; $AE8E: 20 A8 CC ; panel input check setup
  LDA $0549                               ; $AE91: AD 49 05 ; acting side
  JSR BattlePadStateFetch                 ; $AE94: 20 DE CC
  JSR $B870                               ; $AE97: 20 70 B8 ; anim queue idle check
  BCC @Done                               ; $AE9A: 90 11 ; still busy: wait
  LDA a:$0001                             ; $AE9C: AD 01 00
  AND #$01                                ; $AE9F: 29 01 ; A button
  BEQ @Done                               ; $AEA1: F0 0A ; no A: wait
  LDA #$05                                ; $AEA3: A9 05
  STA $0540                               ; $AEA5: 8D 40 05 ; phase <- 5
  LDA #$00                                ; $AEA8: A9 00
  STA $0541                               ; $AEAA: 8D 41 05 ; sub-phase <- 0
@Done:
  RTS                                     ; $AEAD: 60
.endproc
;===============================================================================
; $AEAE: Phase8PanelReturnToCommandDup
; Unreferenced duplicate of Phase8PanelReturnToCommand without the $0300
; clear (identical effect, the slot byte is written last in the other
; copy). Retained as code for ROM byte-exactness.
;===============================================================================
.proc Phase8PanelReturnToCommandDup
  LDA #$03                                ; $AEAE: A9 03
  STA $0540                               ; $AEB0: 8D 40 05 ; phase <- 3
  LDA #$03                                ; $AEB3: A9 03
  STA $0541                               ; $AEB5: 8D 41 05 ; sub-phase <- 3
  LDA #$E8                                ; $AEB8: A9 E8
  STA $0310                               ; $AEBA: 8D 10 03 ; anim id lo
  LDA #$E9                                ; $AEBD: A9 E9
  STA $0311                               ; $AEBF: 8D 11 03 ; anim id hi
  LDA #$00                                ; $AEC2: A9 00
  STA $0300                               ; $AEC4: 8D 00 03 ; anim slot 0
  LDA #$00                                ; $AEC7: A9 00
  STA $0310                               ; $AEC9: 8D 10 03 ; clear anim id lo
  JSR $CBF1                               ; $AECC: 20 F1 CB ; enqueue anim
  RTS                                     ; $AECF: 60
.endproc
;===============================================================================
; $AED0: Phase8TierRowPtrTable
; FF-terminated selectable-row lists per point tier $054A: tier t exposes
; rows 0..t (up to 6 rows), each padded with extra $FF terminators.
;===============================================================================
Phase8TierRowPtrTable:
  .word Phase8Tier0Rows                   ; $AED0: FC AE ; tier 0
  .word Phase8Tier1Rows                   ; $AED2: F8 AE ; tier 1
  .word Phase8Tier2Rows                   ; $AED4: F2 AE ; tier 2
  .word Phase8Tier3Rows                   ; $AED6: EC AE ; tier 3
  .word Phase8Tier4Rows                   ; $AED8: E4 AE ; tier 4
  .word Phase8Tier5Rows                   ; $AEDA: DC AE ; tier 5
Phase8Tier5Rows:
  .byte $00,$01,$02,$03,$04,$05,$FF,$FF  ; $AEDC: 00 01 02 03 04 05 FF FF ; rows 0-5
Phase8Tier4Rows:
  .byte $00,$01,$02,$03,$04,$FF,$FF,$FF  ; $AEE4: 00 01 02 03 04 FF FF FF ; rows 0-4
Phase8Tier3Rows:
  .byte $00,$01,$02,$03,$FF,$FF          ; $AEEC: 00 01 02 03 FF FF ; rows 0-3
Phase8Tier2Rows:
  .byte $00,$01,$02,$FF,$FF,$FF          ; $AEF2: 00 01 02 FF FF FF ; rows 0-2
Phase8Tier1Rows:
  .byte $00,$01,$FF,$FF                  ; $AEF8: 00 01 FF FF ; rows 0-1
Phase8Tier0Rows:
  .byte $00,$FF,$FF,$FF                  ; $AEFC: 00 FF FF FF ; row 0 only
;===============================================================================
; $AF00: Phase8RowCursorCoords
; Selection-cursor sprite coordinates per selected row (word = y,x):
; a 2-column x 3-row grid (x=$48/$88, y=$B4/$C4/$D4). Phase8RowCursorParams
; is the parameter block passed alongside through B1F_PointerTableLookup.
;===============================================================================
Phase8RowCursorCoords:
  .word $48B4                             ; $AF00: B4 48 ; row 0: y=$B4 x=$48
  .word $88B4                             ; $AF02: B4 88 ; row 1: y=$B4 x=$88
  .word $48C4                             ; $AF04: C4 48 ; row 2: y=$C4 x=$48
  .word $88C4                             ; $AF06: C4 88 ; row 3: y=$C4 x=$88
  .word $48D4                             ; $AF08: D4 48 ; row 4: y=$D4 x=$48
  .word $88D4                             ; $AF0A: D4 88 ; row 5: y=$D4 x=$88
Phase8RowCursorParams:
  .byte $00,$07,$00,$00,$80              ; $AF0C: 00 07 00 00 80 ; cursor params
;===============================================================================
; $AF11: Phase8RowEffectDispatch
; Applies the purchased row effect after the cost deduction in
; Phase8PanelMenuInput: dispatches on the selected row ($0012, mirrored to
; $0548) through the inline 6-entry table below. Rows 0/2/3/4 set timed
; side status counters $0574-$0577 (the acting side's nibble) - row 3 also
; saves and advances the periodic reload value $056A/$056B; row 1 rolls an
; officer-stat chance check (success skips to sub 4, failure to sub 3);
; row 0 is a coin flip that targets the opposing unit $042C; row 5 advances
; to phase 9 (formation advance).
;===============================================================================
.proc Phase8RowEffectDispatch
  LDA a:$0012                             ; $AF11: AD 12 00 ; selected row
  STA $0548                               ; $AF14: 8D 48 05 ; mirror to row slot
  JSR B1F_CallbackDispatcher              ; $AF17: 20 DE EA
; --- CallbackDispatcher row-effect table, indexed by selected row ---
  .word Phase8RowCoinFlip                 ; $AF1A: D2 AF ; row 0 ($AFD2)
  .word Phase8RowStatCheck                ; $AF1C: 26 AF ; row 1 ($AF26)
  .word Phase8RowCounter575               ; $AF1E: 0E B0 ; row 2 ($B00E)
  .word Phase8RowCounter576               ; $AF20: 2E B0 ; row 3 ($B02E)
  .word Phase8RowCounter577               ; $AF22: 7C B0 ; row 4 ($B07C)
  .word Phase8RowAdvance                  ; $AF24: 9C B0 ; row 5 ($B09C)
.endproc
;===============================================================================
; $AF26: Phase8RowStatCheck
; Row 1. Auto-fails while the battle scene phase $0544 == 5 on side A.
; Otherwise reads both officers' records (B1F_GetOfficerRecordAddr on the
; side unit ids $0560/$0561): field [$B]>>4 (rank/aptitude) and field [2]
; (troops), swaps the pairs when side B acts so ($000A,$000C) describe the
; acting side. Chance = floor(2 * max(0, rank edge) / 10) + 32 - opponent
; troops (B1F_MathDiv16 with divisor 10); if B1F_RandomBelowThreshold(100)
; lands below the chance, succeeds (UI $EA, sub-phase <- 4 = advance wait),
; otherwise fails at @Fail (UI $EB, sub-phase++ = confirm wait).
;===============================================================================
.proc Phase8RowStatCheck
  LDA $0544                               ; $AF26: AD 44 05 ; battle scene phase
  CMP #$05                                ; $AF29: C9 05
  BNE @SideCheck                          ; $AF2B: D0 08
  LDA $0549                               ; $AF2D: AD 49 05 ; acting side
  BNE @SideCheck                          ; $AF30: D0 03
  JMP @Fail                               ; $AF32: 4C C9 AF ; phase 5 side A: no go
@SideCheck:
  LDA $0560                               ; $AF35: AD 60 05 ; side A unit id
  JSR B1F_GetOfficerRecordAddr            ; $AF38: 20 D7 F2 ; record ptr -> ($00)
  LDY #$0B                                ; $AF3B: A0 0B
  LDA ($00),Y                             ; $AF3D: B1 00 ; record field [$B]
  LSR                                     ; $AF3F: 4A
  LSR                                     ; $AF40: 4A
  LSR                                     ; $AF41: 4A
  LSR                                     ; $AF42: 4A ; >>4: rank/aptitude
  STA a:$000A                             ; $AF43: 8D 0A 00 ; side A rank
  LDY #$02                                ; $AF46: A0 02
  LDA ($00),Y                             ; $AF48: B1 00 ; record field [2]
  STA a:$000C                             ; $AF4A: 8D 0C 00 ; side A troops
  LDA $0561                               ; $AF4D: AD 61 05 ; side B unit id
  JSR B1F_GetOfficerRecordAddr            ; $AF50: 20 D7 F2 ; record ptr -> ($00)
  LDY #$0B                                ; $AF53: A0 0B
  LDA ($00),Y                             ; $AF55: B1 00 ; record field [$B]
  LSR                                     ; $AF57: 4A
  LSR                                     ; $AF58: 4A
  LSR                                     ; $AF59: 4A
  LSR                                     ; $AF5A: 4A ; >>4: rank/aptitude
  STA a:$000B                             ; $AF5B: 8D 0B 00 ; side B rank
  LDY #$02                                ; $AF5E: A0 02
  LDA ($00),Y                             ; $AF60: B1 00 ; record field [2]
  STA a:$000D                             ; $AF62: 8D 0D 00 ; side B troops
  LDA $0549                               ; $AF65: AD 49 05 ; acting side
  BEQ @RankEdge                           ; $AF68: F0 18 ; side A: keep order
  LDY a:$000A                             ; $AF6A: AC 0A 00
  LDA a:$000B                             ; $AF6D: AD 0B 00
  STA a:$000A                             ; $AF70: 8D 0A 00 ; own rank
  STY a:$000B                             ; $AF73: 8C 0B 00 ; opp rank
  LDY a:$000C                             ; $AF76: AC 0C 00
  LDA a:$000D                             ; $AF79: AD 0D 00
  STA a:$000C                             ; $AF7C: 8D 0C 00 ; own troops
  STY a:$000D                             ; $AF7F: 8C 0D 00 ; opp troops
@RankEdge:
  LDA a:$000A                             ; $AF82: AD 0A 00 ; own rank
  SEC                                     ; $AF85: 38
  SBC a:$000B                             ; $AF86: ED 0B 00 ; - opp rank
  BCS @ScaleEdge                          ; $AF89: B0 02 ; no underflow
  LDA #$00                                ; $AF8B: A9 00 ; clamp at 0
@ScaleEdge:
  ASL                                     ; $AF8D: 0A ; edge * 2
  STA a:$000A                             ; $AF8E: 8D 0A 00 ; dividend lo
  LDA a:$000D                             ; $AF91: AD 0D 00 ; opponent troops
  STA a:$0001                             ; $AF94: 8D 01 00 ; scratch for later
  LDA #$0A                                ; $AF97: A9 0A
  STA a:$0003                             ; $AF99: 8D 03 00 ; divisor <- 10
  LDA #$00                                ; $AF9C: A9 00
  STA a:$0002                             ; $AF9E: 8D 02 00 ; dividend hi <- 0
  STA a:$0004                             ; $AFA1: 8D 04 00 ; divisor hi <- 0
  JSR B1F_MathDiv16                       ; $AFA4: 20 7C EA ; edge * 2 / 10
  LDA a:$000A                             ; $AFA7: AD 0A 00 ; quotient
  CLC                                     ; $AFAA: 18
  ADC #$20                                ; $AFAB: 69 20 ; + 32 base chance
  SEC                                     ; $AFAD: 38
  SBC a:$0001                             ; $AFAE: ED 01 00 ; - opponent troops
  STA a:$000A                             ; $AFB1: 8D 0A 00 ; success chance
  LDA #$64                                ; $AFB4: A9 64 ; threshold 100
  JSR B1F_RandomBelowThreshold            ; $AFB6: 20 62 E8 ; rand [0,100)
  CMP a:$000A                             ; $AFB9: CD 0A 00
  BCS @Fail                               ; $AFBC: B0 0B ; rand >= chance
  LDA #$EA                                ; $AFBE: A9 EA
  JSR B1F_SetUI0                          ; $AFC0: 20 6D F2 ; UI $EA: success
  LDA #$04                                ; $AFC3: A9 04
  STA $0541                               ; $AFC5: 8D 41 05 ; sub-phase <- 4
  RTS                                     ; $AFC8: 60
@Fail:
  LDA #$EB                                ; $AFC9: A9 EB
  JSR B1F_SetUI0                          ; $AFCB: 20 6D F2 ; UI $EB: failure
  INC $0541                               ; $AFCE: EE 41 05 ; sub-phase <- 3
  RTS                                     ; $AFD1: 60
.endproc
;===============================================================================
; $AFD2: Phase8RowCoinFlip
; Row 0. Coin flip on B1F_RandomByte bit 0. Miss (bit clear): UI $ED and
; back to the confirm wait (sub-phase++). Hit (bit set): UI $EC, stores the
; opposing side's unit id $0560[$0549^1] into $042C as the effect target,
; then falls through into Phase8RowCounter574.
;===============================================================================
.proc Phase8RowCoinFlip
  JSR B1F_RandomByte                      ; $AFD2: 20 7A E8
  AND #$01                                ; $AFD5: 29 01 ; coin bit
  BNE @Hit                                ; $AFD7: D0 09
  INC $0541                               ; $AFD9: EE 41 05 ; sub-phase <- 3
  LDA #$ED                                ; $AFDC: A9 ED
  JSR B1F_SetUI0                          ; $AFDE: 20 6D F2 ; UI $ED: miss
  RTS                                     ; $AFE1: 60
@Hit:
  LDA #$EC                                ; $AFE2: A9 EC
  JSR B1F_SetUI0                          ; $AFE4: 20 6D F2 ; UI $EC: hit
  LDA $0549                               ; $AFE7: AD 49 05 ; acting side
  EOR #$01                                ; $AFEA: 49 01 ; opposing side
  TAY                                     ; $AFEC: A8
  LDA $0560,Y                             ; $AFED: B9 60 05 ; opposing unit id
  STA $042C                               ; $AFF0: 8D 2C 04 ; effect target
  INC $0541                               ; $AFF3: EE 41 05 ; sub-phase <- 3
.endproc
;===============================================================================
; $AFF6: Phase8RowCounter574
; Sets status counter $0574 to 4 in the acting side's nibble (side A: low
; nibble, side B: high nibble), preserving the other side's nibble. Fall-
; through tail of Phase8RowCoinFlip.
;===============================================================================
.proc Phase8RowCounter574
  LDA $0574                               ; $AFF6: AD 74 05 ; status counter 574
  LDY $0549                               ; $AFF9: AC 49 05 ; acting side
  BNE @SideB                              ; $AFFC: D0 08
  AND #$F0                                ; $AFFE: 29 F0 ; keep side B nibble
  ORA #$04                                ; $B000: 09 04 ; side A counter <- 4
  STA $0574                               ; $B002: 8D 74 05
  RTS                                     ; $B005: 60
@SideB:
  AND #$0F                                ; $B006: 29 0F ; keep side A nibble
  ORA #$40                                ; $B008: 09 40 ; side B counter <- 4
  STA $0574                               ; $B00A: 8D 74 05
  RTS                                     ; $B00D: 60
.endproc
;===============================================================================
; $B00E: Phase8RowCounter575
; Row 2. UI $EE, sub-phase++, then sets status counter $0575 to 3 in the
; acting side's nibble.
;===============================================================================
.proc Phase8RowCounter575
  LDA #$EE                                ; $B00E: A9 EE
  JSR B1F_SetUI0                          ; $B010: 20 6D F2 ; UI $EE
  INC $0541                               ; $B013: EE 41 05 ; sub-phase <- 3
  LDA $0575                               ; $B016: AD 75 05 ; status counter 575
  LDY $0549                               ; $B019: AC 49 05 ; acting side
  BNE @SideB                              ; $B01C: D0 08
  AND #$F0                                ; $B01E: 29 F0 ; keep side B nibble
  ORA #$03                                ; $B020: 09 03 ; side A counter <- 3
  STA $0575                               ; $B022: 8D 75 05
  RTS                                     ; $B025: 60
@SideB:
  AND #$0F                                ; $B026: 29 0F ; keep side A nibble
  ORA #$30                                ; $B028: 09 30 ; side B counter <- 3
  STA $0575                               ; $B02A: 8D 75 05
  RTS                                     ; $B02D: 60
.endproc
;===============================================================================
; $B02E: Phase8RowCounter576
; Row 3. UI $EF, sub-phase++, sets status counter $0576 to 4 in the acting
; side's nibble, then advances the side's periodic reload value: the
; current $056A/$056B is saved into the reload latch $0578/$0579 and
; replaced by itself + 5 + rand[0,5) (Phase8RowReloadRoll). When a $0576
; nibble expires, BattleSideStatusCountersDecrement latches the saved
; values back into $056A/$056B.
;===============================================================================
.proc Phase8RowCounter576
  LDA #$EF                                ; $B02E: A9 EF
  JSR B1F_SetUI0                          ; $B030: 20 6D F2 ; UI $EF
  INC $0541                               ; $B033: EE 41 05 ; sub-phase <- 3
  LDA $0576                               ; $B036: AD 76 05 ; status counter 576
  LDY $0549                               ; $B039: AC 49 05 ; acting side
  BEQ @SideA                              ; $B03C: F0 14
  AND #$0F                                ; $B03E: 29 0F ; keep side A nibble
  ORA #$40                                ; $B040: 09 40 ; side B counter <- 4
  STA $0576                               ; $B042: 8D 76 05
  LDA $056B                               ; $B045: AD 6B 05 ; side B reload value
  STA $0579                               ; $B048: 8D 79 05 ; save to reload latch
  JSR Phase8RowReloadRoll                 ; $B04B: 20 66 B0 ; + 5 + rand[0,5)
  STA $056B                               ; $B04E: 8D 6B 05 ; advance reload
  RTS                                     ; $B051: 60
@SideA:
  AND #$F0                                ; $B052: 29 F0 ; keep side B nibble
  ORA #$04                                ; $B054: 09 04 ; side A counter <- 4
  STA $0576                               ; $B056: 8D 76 05
  LDA $056A                               ; $B059: AD 6A 05 ; side A reload value
  STA $0578                               ; $B05C: 8D 78 05 ; save to reload latch
  JSR Phase8RowReloadRoll                 ; $B05F: 20 66 B0 ; + 5 + rand[0,5)
  STA $056A                               ; $B062: 8D 6A 05 ; advance reload
  RTS                                     ; $B065: 60
.endproc
;===============================================================================
; $B066: Phase8RowReloadRoll
; Returns A + 5 + rand[0,5): rolls B1F_RandomByte & 7 until below 5, then
; adds 5 and the roll to the input value.
;===============================================================================
.proc Phase8RowReloadRoll
  PHA                                     ; $B066: 48 ; input value
@RollLoop:
  JSR B1F_RandomByte                      ; $B067: 20 7A E8
  AND #$07                                ; $B06A: 29 07 ; rand [0,8)
  CMP #$05                                ; $B06C: C9 05
  BCS @RollLoop                           ; $B06E: B0 F7 ; reject 5-7
  STA a:$0000                             ; $B070: 8D 00 00 ; roll
  PLA                                     ; $B073: 68 ; input value
  CLC                                     ; $B074: 18
  ADC #$05                                ; $B075: 69 05 ; + 5
  CLC                                     ; $B077: 18
  ADC a:$0000                             ; $B078: 6D 00 00 ; + roll
  RTS                                     ; $B07B: 60
.endproc
;===============================================================================
; $B07C: Phase8RowCounter577
; Row 4. UI $F0, sub-phase++, then sets status counter $0577 to 3 in the
; acting side's nibble.
;===============================================================================
.proc Phase8RowCounter577
  LDA #$F0                                ; $B07C: A9 F0
  JSR B1F_SetUI0                          ; $B07E: 20 6D F2 ; UI $F0
  INC $0541                               ; $B081: EE 41 05 ; sub-phase <- 3
  LDA $0577                               ; $B084: AD 77 05 ; status counter 577
  LDY $0549                               ; $B087: AC 49 05 ; acting side
  BNE @SideB                              ; $B08A: D0 08
  AND #$F0                                ; $B08C: 29 F0 ; keep side B nibble
  ORA #$03                                ; $B08E: 09 03 ; side A counter <- 3
  STA $0577                               ; $B090: 8D 77 05
  RTS                                     ; $B093: 60
@SideB:
  AND #$0F                                ; $B094: 29 0F ; keep side A nibble
  ORA #$30                                ; $B096: 09 30 ; side B counter <- 3
  STA $0577                               ; $B098: 8D 77 05
  RTS                                     ; $B09B: 60
.endproc
;===============================================================================
; $B09C: Phase8RowAdvance
; Row 5. Leaves the panel: phase <- 9 (formation advance), sub-phase <- 0,
; UI mode $F1.
;===============================================================================
.proc Phase8RowAdvance
  LDA #$09                                ; $B09C: A9 09
  STA $0540                               ; $B09E: 8D 40 05 ; phase <- 9
  LDA #$00                                ; $B0A1: A9 00
  STA $0541                               ; $B0A3: 8D 41 05 ; sub-phase <- 0
  LDA #$F1                                ; $B0A6: A9 F1
  JSR B1F_SetUI0                          ; $B0A8: 20 6D F2 ; UI $F1
  RTS                                     ; $B0AB: 60
.endproc
;===============================================================================
; $B0AC: Phase8RowScriptQueue
; Copies the FF-terminated row script Phase8RowScriptTable[$0548] into the
; script buffer $0380 and marks the script pending ($007E bit 2). Called by
; Phase8PanelScriptStep with the script id $00BB already set.
;===============================================================================
.proc Phase8RowScriptQueue
  LDA $0548                               ; $B0AC: AD 48 05 ; row cursor
  ASL                                     ; $B0AF: 0A
  TAY                                     ; $B0B0: A8 ; table index * 2
  LDA Phase8RowScriptTable,Y              ; $B0B1: B9 D5 B0 ; script ptr lo
  STA a:$0000                             ; $B0B4: 8D 00 00
  LDA Phase8RowScriptTable+1,Y            ; $B0B7: B9 D6 B0 ; script ptr hi
  STA a:$0001                             ; $B0BA: 8D 01 00
  LDY #$00                                ; $B0BD: A0 00
@CopyLoop:
  LDA ($00),Y                             ; $B0BF: B1 00 ; script byte
  CMP #$FF                                ; $B0C1: C9 FF ; terminator
  STA $0380,Y                             ; $B0C3: 99 80 03 ; script buffer
  BEQ @Done                               ; $B0C6: F0 04
  INY                                     ; $B0C8: C8
  JMP @CopyLoop                           ; $B0C9: 4C BF B0
@Done:
  LDA a:$007E                             ; $B0CC: AD 7E 00 ; script busy flag
  ORA #$04                                ; $B0CF: 09 04 ; script pending bit
  STA a:$007E                             ; $B0D1: 8D 7E 00
  RTS                                     ; $B0D4: 60
.endproc
;===============================================================================
; $B0D5: Phase8RowScriptTable
; Pointers to the FF-terminated row scripts displayed by
; Phase8PanelScriptStep (row index 0-5). Scripts carry a segment header
; (length byte, nametable row $22/$23) followed by tile runs and $01 fill;
; physical order below is row 1, 0, 2, 3, 4, 5.
;===============================================================================
Phase8RowScriptTable:
  .word Phase8RowScript0                  ; $B0D5: F7 B0 ; row 0 ($B0F7)
  .word Phase8RowScript1                  ; $B0D7: E1 B0 ; row 1 ($B0E1)
  .word Phase8RowScript2                  ; $B0D9: 08 B1 ; row 2 ($B108)
  .word Phase8RowScript3                  ; $B0DB: 19 B1 ; row 3 ($B119)
  .word Phase8RowScript4                  ; $B0DD: 33 B1 ; row 4 ($B133)
  .word Phase8RowScript5                  ; $B0DF: 45 B1 ; row 5 ($B145)
Phase8RowScript1:
  .byte $04,$22,$D2,$C0,$C1,$C2,$C3,$0B,$22,$F2,$D0,$D1,$D2,$D3,$01,$01; $B0E1: 04 22 D2 C0 C1 C2 C3 0B 22 F2 D0 D1 D2 D3 01 01
  .byte $01,$01,$01,$01,$7B,$FF          ; $B0F1: 01 01 01 01 7B FF
Phase8RowScript0:
  .byte $04,$22,$CA,$C4,$C5,$C6,$C7,$06,$22,$EA,$D4,$D5,$D6,$D7,$01,$79; $B0F7: 04 22 CA C4 C5 C6 C7 06 22 EA D4 D5 D6 D7 01 79
  .byte $FF                               ; $B107: FF
Phase8RowScript2:
  .byte $04,$23,$0A,$C8,$C9,$CA,$CB,$06,$23,$2A,$D8,$D9,$DA,$DB,$01,$7D; $B108: 04 23 0A C8 C9 CA CB 06 23 2A D8 D9 DA DB 01 7D
  .byte $FF                               ; $B118: FF
Phase8RowScript3:
  .byte $08,$23,$12,$CC,$CD,$CE,$CF,$E0,$E1,$E2,$E3,$0B,$23,$32,$DC,$DD; $B119: 08 23 12 CC CD CE CF E0 E1 E2 E3 0B 23 32 DC DD
  .byte $DE,$DF,$F0,$F1,$F2,$F3,$01,$01,$7E,$FF; $B129: DE DF F0 F1 F2 F3 01 01 7E FF
Phase8RowScript4:
  .byte $04,$23,$4A,$E4,$E5,$E6,$E7,$07,$23,$6A,$F4,$F5,$F6,$F7,$01,$77; $B133: 04 23 4A E4 E5 E6 E7 07 23 6A F4 F5 F6 F7 01 77
  .byte $76,$FF                           ; $B143: 76 FF
Phase8RowScript5:
  .byte $04,$23,$52,$E8,$E9,$EA,$EB,$0B,$23,$72,$F8,$F9,$FA,$FB,$01,$01; $B145: 04 23 52 E8 E9 EA EB 0B 23 72 F8 F9 FA FB 01 01
  .byte $01,$01,$01,$77,$78,$FF          ; $B155: 01 01 01 77 78 FF
;===============================================================================
; $B15B: BattleSideStatusCountersDecrement
; Ticks down the packed per-side status counters $0574-$0577 once per
; round pass (each byte holds two nibble counters). $0574/$0575/$0577 use
; @NibbleDecrement; $0576 uses @CounterDecrementLatch instead: when one of
; its nibbles reaches zero, the reload values $0578/$0579 are latched into
; $056A/$056B.
;===============================================================================
.proc BattleSideStatusCountersDecrement
  LDA $0574                               ; $B15B: AD 74 05
  STA a:$0000                             ; $B15E: 8D 00 00
  JSR @NibbleDecrement                    ; $B161: 20 98 B1
  LDA a:$0000                             ; $B164: AD 00 00
  STA $0574                               ; $B167: 8D 74 05
  LDA $0575                               ; $B16A: AD 75 05
  STA a:$0000                             ; $B16D: 8D 00 00
  JSR @NibbleDecrement                    ; $B170: 20 98 B1
  LDA a:$0000                             ; $B173: AD 00 00
  STA $0575                               ; $B176: 8D 75 05
  LDA $0576                               ; $B179: AD 76 05
  STA a:$0000                             ; $B17C: 8D 00 00
  JSR @CounterDecrementLatch              ; $B17F: 20 B7 B1
  LDA a:$0000                             ; $B182: AD 00 00
  STA $0576                               ; $B185: 8D 76 05
  LDA $0577                               ; $B188: AD 77 05
  STA a:$0000                             ; $B18B: 8D 00 00
  JSR @NibbleDecrement                    ; $B18E: 20 98 B1
  LDA a:$0000                             ; $B191: AD 00 00
  STA $0577                               ; $B194: 8D 77 05
  RTS                                     ; $B197: 60
; --- Decrement both nibbles of $0000 independently, clamped at zero ---
@NibbleDecrement:
  LDA a:$0000                             ; $B198: AD 00 00
  AND #$0F                                ; $B19B: 29 0F
  BEQ @LowDone                            ; $B19D: F0 07 ; low nibble already 0
  LDY a:$0000                             ; $B19F: AC 00 00
  DEY                                     ; $B1A2: 88
  STY a:$0000                             ; $B1A3: 8C 00 00
@LowDone:
  LDA a:$0000                             ; $B1A6: AD 00 00
  AND #$F0                                ; $B1A9: 29 F0
  BEQ @Done                               ; $B1AB: F0 09 ; high nibble already 0
  LDA a:$0000                             ; $B1AD: AD 00 00
  SEC                                     ; $B1B0: 38
  SBC #$10                                ; $B1B1: E9 10
  STA a:$0000                             ; $B1B3: 8D 00 00
@Done:
  RTS                                     ; $B1B6: 60
; --- Like @NibbleDecrement, but latches reloads when a nibble hits zero ---
@CounterDecrementLatch:
  LDA a:$0000                             ; $B1B7: AD 00 00
  AND #$0F                                ; $B1BA: 29 0F
  BEQ @HighCheck                          ; $B1BC: F0 13
  LDA a:$0000                             ; $B1BE: AD 00 00
  SEC                                     ; $B1C1: 38
  SBC #$01                                ; $B1C2: E9 01
  STA a:$0000                             ; $B1C4: 8D 00 00
  AND #$0F                                ; $B1C7: 29 0F
  BNE @HighCheck                          ; $B1C9: D0 06 ; not yet zero
  LDA $0578                               ; $B1CB: AD 78 05
  STA $056A                               ; $B1CE: 8D 6A 05 ; low-counter reload latch
@HighCheck:
  LDA a:$0000                             ; $B1D1: AD 00 00
  AND #$F0                                ; $B1D4: 29 F0
  BEQ @LatchDone                          ; $B1D6: F0 13
  LDA a:$0000                             ; $B1D8: AD 00 00
  SEC                                     ; $B1DB: 38
  SBC #$10                                ; $B1DC: E9 10
  STA a:$0000                             ; $B1DE: 8D 00 00
  AND #$F0                                ; $B1E1: 29 F0
  BNE @LatchDone                          ; $B1E3: D0 06 ; not yet zero
  LDA $0579                               ; $B1E5: AD 79 05
  STA $056B                               ; $B1E8: 8D 6B 05 ; high-counter reload latch
@LatchDone:
  RTS                                     ; $B1EB: 60
.endproc
;===============================================================================
; $B1EC: Phase9AdvanceSubDispatch
; Phase-9 handler entry (formation advance), entered from the phase-8 row-
; effect dispatch row 5 ($B09C, SFX $F1). Redraws the acting side's overlay
; strip (buffer ptr lo from $0560[$0549], hi fixed $A5, X=0) via bank $19
; $A000, then sub-dispatches on $0541 through the inline 4-entry table
; below: sub-states 0-3 are the Phase9AdvanceInit..
; Phase9AdvanceRosterSweep handlers.
;===============================================================================
.proc Phase9AdvanceSubDispatch
  LDY $0549                               ; $B1EC: AC 49 05 ; acting side
  LDA $0560,Y                             ; $B1EF: B9 60 05 ; strip buffer ptr lo
  STA a:$0000                             ; $B1F2: 8D 00 00
  LDA #$A5                                ; $B1F5: A9 A5
  STA a:$000A                             ; $B1F7: 8D 0A 00 ; buffer ptr hi
  LDX #$00                                ; $B1FA: A2 00 ; strip 0
  LDY #$39                                ; $B1FC: A0 39
  JSR B1F_BankedCallbackTrampoline        ; $B1FE: 20 07 EE
; --- BankedCallbackTrampoline target (bank $19) ---
  .word $A000                             ; $B201: 00 A0 ; B19_OverlayStripRender_Entry
  LDA $0541                               ; $B203: AD 41 05 ; sub-phase
  JSR B1F_CallbackDispatcher              ; $B206: 20 DE EA
; --- CallbackDispatcher sub-phase table, indexed by $0541 ---
  .word Phase9AdvanceInit                 ; $B209: 11 B2 ; sub 0 ($B211)
  .word Phase9AdvanceAnimFrame            ; $B20B: 5B B2 ; sub 1 ($B25B)
  .word Phase9AdvanceContactTick          ; $B20D: F5 B2 ; sub 2 ($B2F5)
  .word Phase9AdvanceRosterSweep          ; $B20F: EF B3 ; sub 3 ($B3EF)
.endproc
;===============================================================================
; $B211: Phase9AdvanceInit
; Sub 0. Blanks the five marker OAM rows ($00B1/$00C1/$00D1/$00C9/$00D9 <-
; $7F), resets the advance frame counter $0548, advances to sub 1 and loads
; the advance parameters from the acting side's roster base slot ($0558 <-
; 0 for side 0, $0B for side 1): direction code $0559 (roster byte $05C2
; high nibble), start row $055A (unit row $0596 << 4) and start column
; $055B (unit column $0580 << 4). Clears the battle flag $008F.
;===============================================================================
.proc Phase9AdvanceInit
  LDA #$7F                                ; $B211: A9 7F
  STA a:$00B1                             ; $B213: 8D B1 00 ; marker OAM row blank
  STA a:$00C1                             ; $B216: 8D C1 00
  STA a:$00D1                             ; $B219: 8D D1 00
  STA a:$00C9                             ; $B21C: 8D C9 00
  STA a:$00D9                             ; $B21F: 8D D9 00
  LDA #$00                                ; $B222: A9 00
  STA $0548                               ; $B224: 8D 48 05 ; frame counter <- 0
  INC $0541                               ; $B227: EE 41 05 ; sub-phase <- 1
  LDA #$00                                ; $B22A: A9 00
  LDY $0549                               ; $B22C: AC 49 05 ; acting side
  BEQ @StoreBase                          ; $B22F: F0 02
  LDA #$0B                                ; $B231: A9 0B ; side 1 roster base
@StoreBase:
  STA $0558                               ; $B233: 8D 58 05 ; roster base slot
  TAY                                     ; $B236: A8
  LDA $05C2,Y                             ; $B237: B9 C2 05 ; roster base byte
  LSR                                     ; $B23A: 4A
  LSR                                     ; $B23B: 4A
  LSR                                     ; $B23C: 4A
  LSR                                     ; $B23D: 4A ; high nibble
  STA $0559                               ; $B23E: 8D 59 05 ; direction code
  LDA $0596,Y                             ; $B241: B9 96 05 ; unit row (tiles)
  ASL                                     ; $B244: 0A
  ASL                                     ; $B245: 0A
  ASL                                     ; $B246: 0A
  ASL                                     ; $B247: 0A ; x16
  STA $055A                               ; $B248: 8D 5A 05 ; start row
  LDA $0580,Y                             ; $B24B: B9 80 05 ; unit column (tiles)
  ASL                                     ; $B24E: 0A
  ASL                                     ; $B24F: 0A
  ASL                                     ; $B250: 0A
  ASL                                     ; $B251: 0A ; x16
  STA $055B                               ; $B252: 8D 5B 05 ; start column
  LDA #$00                                ; $B255: A9 00
  STA a:$008F                             ; $B257: 8D 8F 00 ; battle flag <- 0
  RTS                                     ; $B25A: 60
.endproc
;===============================================================================
; $B25B: Phase9AdvanceAnimFrame
; Sub 1. Runs the 32-frame advance animation. Each frame steps the marker
; position one unit in direction $0559 (0 row up, 1 row down, 2 column left,
; 3 column right); leaving the strip bounds (row >= $A0, column wrap
; through $FF/0) finishes the advance via Phase9AdvanceComplete. Every 8
; frames the marker render picks the next wobble offset from
; Phase9AdvanceWobbleOffsetTable, then draws the descriptor at
; Phase9AdvanceStripDrawDesc through B1F_SpriteOamWriterScroll_NoInit at
; (row $055A - wobble, column $055B).
;===============================================================================
.proc Phase9AdvanceAnimFrame
  INC $0548                               ; $B25B: EE 48 05 ; frame counter +1
  LDA $0548                               ; $B25E: AD 48 05
  CMP #$20                                ; $B261: C9 20
  BCC @MoveMarker                         ; $B263: 90 08 ; 32 frames not done
  LDA #$00                                ; $B265: A9 00
  STA $0548                               ; $B267: 8D 48 05 ; frame counter <- 0
  INC $0541                               ; $B26A: EE 41 05 ; sub-phase <- 2
@MoveMarker:
  LDA $0559                               ; $B26D: AD 59 05 ; direction code
  BNE @DirDown                            ; $B270: D0 0D
  DEC $055A                               ; $B272: CE 5A 05 ; dir 0: row -1
  LDA $055A                               ; $B275: AD 5A 05
  CMP #$A0                                ; $B278: C9 A0
  BCS Phase9AdvanceComplete               ; $B27A: B0 2D ; off-strip
  JMP Phase9AdvanceMarkerRender           ; $B27C: 4C AC B2
@DirDown:
  CMP #$01                                ; $B27F: C9 01
  BNE @DirLeft                            ; $B281: D0 0D
  INC $055A                               ; $B283: EE 5A 05 ; dir 1: row +1
  LDA $055A                               ; $B286: AD 5A 05
  CMP #$A0                                ; $B289: C9 A0
  BCS Phase9AdvanceComplete               ; $B28B: B0 1C ; off-strip
  JMP Phase9AdvanceMarkerRender           ; $B28D: 4C AC B2
@DirLeft:
  CMP #$02                                ; $B290: C9 02
  BNE @DirRight                           ; $B292: D0 0D
  DEC $055B                               ; $B294: CE 5B 05 ; dir 2: column -1
  LDA $055B                               ; $B297: AD 5B 05
  CMP #$FF                                ; $B29A: C9 FF
  BEQ Phase9AdvanceComplete               ; $B29C: F0 0B ; wrapped off-strip
  JMP Phase9AdvanceMarkerRender           ; $B29E: 4C AC B2
@DirRight:
  INC $055B                               ; $B2A1: EE 5B 05 ; dir 3: column +1
  LDA $055B                               ; $B2A4: AD 5B 05
  BNE Phase9AdvanceMarkerRender           ; $B2A7: D0 03 ; still on-strip
.endproc
;===============================================================================
; $B2A9: Phase9AdvanceComplete
; Shared off-strip exit of the advance animation: routes through
; Phase9AdvanceFinish back to the phase-8 row-effect dispatch.
;===============================================================================
.proc Phase9AdvanceComplete
  JMP Phase9AdvanceFinish                 ; $B2A9: 4C 40 B4
.endproc
;===============================================================================
; $B2AC: Phase9AdvanceMarkerRender
; Draws the advance marker: descriptor ptr ($0000/$0001) <-
; Phase9AdvanceStripDrawDesc, sprite row <- marker row $055A minus the
; wobble offset (Phase9AdvanceWobbleOffsetTable indexed by frame/4),
; sprite column <- $055B; writer preset $0003=0/$0004=$A0. Exits through
; B1F_SpriteOamWriterScroll_NoInit.
;===============================================================================
.proc Phase9AdvanceMarkerRender
  LDA #$E8                                ; $B2AC: A9 E8
  STA a:$0000                             ; $B2AE: 8D 00 00 ; descriptor ptr lo
  LDA #$B2                                ; $B2B1: A9 B2
  STA a:$0001                             ; $B2B3: 8D 01 00 ; descriptor ptr hi
  LDA #$00                                ; $B2B6: A9 00
  STA a:$0002                             ; $B2B8: 8D 02 00
  LDA $0548                               ; $B2BB: AD 48 05 ; frame counter
  LSR                                     ; $B2BE: 4A
  LSR                                     ; $B2BF: 4A ; /4
  AND #$07                                ; $B2C0: 29 07 ; 8-step wobble cycle
  TAY                                     ; $B2C2: A8
  LDA $055A                               ; $B2C3: AD 5A 05 ; marker row
  SEC                                     ; $B2C6: 38
  SBC Phase9AdvanceWobbleOffsetTable,Y   ; $B2C7: F9 ED B2 ; - wobble
  STA a:$000A                             ; $B2CA: 8D 0A 00 ; sprite Y
  LDA $055B                               ; $B2CD: AD 5B 05 ; marker column
  STA a:$000C                             ; $B2D0: 8D 0C 00 ; sprite X
  LDA #$00                                ; $B2D3: A9 00
  STA a:$000B                             ; $B2D5: 8D 0B 00
  STA a:$000D                             ; $B2D8: 8D 0D 00
  LDA #$00                                ; $B2DB: A9 00
  STA a:$0003                             ; $B2DD: 8D 03 00 ; writer preset
  LDA #$A0                                ; $B2E0: A9 A0
  STA a:$0004                             ; $B2E2: 8D 04 00 ; writer preset
  JMP B1F_SpriteOamWriterScroll_NoInit    ; $B2E5: 4C 9C F0
.endproc
; --- Data Region ---
Phase9AdvanceStripDrawDesc:
  .byte $00,$C4,$02,$00,$80               ; $B2E8: 00 C4 02 00 80 ; marker strip draw descriptor (5-byte head)
Phase9AdvanceWobbleOffsetTable:
  .byte $00,$01,$02,$03,$03,$02,$01,$00  ; $B2ED: 00 01 02 03 03 02 01 00 ; 8-step marker wobble ramp (overlaps descriptor tail)
;===============================================================================
; $B2F5: Phase9AdvanceContactTick
; Sub 2. Contact-damage tick while the animation settles: runs only when the
; $005E low-nibble frame phase is 0; every 4 ticks applies
; Phase9AdvanceContactScan, then advances to sub 3 with the frame counter
; reset. Between ticks it re-renders the marker at its current position
; using the frame entry from Phase9AdvanceFramePtrTable.
;===============================================================================
.proc Phase9AdvanceContactTick
  LDA a:$005E                             ; $B2F5: AD 5E 00 ; frame phase flags
  AND #$0F                                ; $B2F8: 29 0F
  BNE @RenderFrame                        ; $B2FA: D0 16 ; not a tick frame
  INC $0548                               ; $B2FC: EE 48 05 ; tick counter +1
  LDA $0548                               ; $B2FF: AD 48 05
  CMP #$04                                ; $B302: C9 04
  BCC @RenderFrame                        ; $B304: 90 0C ; 4 ticks not done
  JSR Phase9AdvanceContactScan            ; $B306: 20 4B B4
  INC $0541                               ; $B309: EE 41 05 ; sub-phase <- 3
  LDA #$00                                ; $B30C: A9 00
  STA $0548                               ; $B30E: 8D 48 05 ; tick counter <- 0
  RTS                                     ; $B311: 60
@RenderFrame:
  LDA $0548                               ; $B312: AD 48 05 ; tick counter
  ASL                                     ; $B315: 0A ; word index
  TAY                                     ; $B316: A8
  LDA Phase9AdvanceFramePtrTable,Y        ; $B317: B9 49 B3 ; frame ptr lo
  STA a:$0000                             ; $B31A: 8D 00 00
  LDA Phase9AdvanceFramePtrTable+1,Y      ; $B31D: B9 4A B3 ; frame ptr hi
  STA a:$0001                             ; $B320: 8D 01 00
  LDA #$00                                ; $B323: A9 00
  STA a:$0002                             ; $B325: 8D 02 00
  LDA $055A                               ; $B328: AD 5A 05 ; marker row
  STA a:$000A                             ; $B32B: 8D 0A 00 ; sprite Y
  LDA $055B                               ; $B32E: AD 5B 05 ; marker column
  STA a:$000C                             ; $B331: 8D 0C 00 ; sprite X
  LDA #$00                                ; $B334: A9 00
  STA a:$000B                             ; $B336: 8D 0B 00
  STA a:$000D                             ; $B339: 8D 0D 00
  LDA #$00                                ; $B33C: A9 00
  STA a:$0003                             ; $B33E: 8D 03 00 ; writer preset
  LDA #$A0                                ; $B341: A9 A0
  STA a:$0004                             ; $B343: 8D 04 00 ; writer preset
  JMP B1F_SpriteOamWriterScroll_NoInit    ; $B346: 4C 9C F0
.endproc
; --- Data Region ---
; Phase9AdvanceFramePtrTable ($B349-$B3EE, 166 bytes): per-frame strip
; animation data used by Phase9AdvanceContactTick. The leading word entries
; (indexed by tick counter x2) point into this very block at the per-tick
; render records; the remaining bytes are the record payloads.
Phase9AdvanceFramePtrTable:
  .byte $55,$B3,$66,$B3,$66,$B3,$66,$B3,$66,$B3,$66,$B3,$00,$E9,$02,$00; $B349: 55 B3 66 B3 66 B3 66 B3 66 B3 66 B3 00 E9 02 00
  .byte $00,$EA,$02,$08,$08,$F9,$02,$00,$08,$FA,$02,$08,$80,$F0,$C5,$02; $B359: 00 EA 02 08 08 F9 02 00 08 FA 02 08 80 F0 C5 02
  .byte $F8,$F8,$D4,$02,$F0,$F8,$D5,$02,$F8,$F0,$E6,$02,$00,$F0,$E6,$42; $B369: F8 F8 D4 02 F0 F8 D5 02 F8 F0 E6 02 00 F0 E6 42
  .byte $08,$F8,$F6,$02,$00,$F8,$E8,$02,$08,$F0,$C5,$42,$10,$F8,$D5,$42; $B379: 08 F8 F6 02 00 F8 E8 02 08 F0 C5 42 10 F8 D5 42
  .byte $10,$F8,$D4,$42,$18,$00,$E4,$02,$F0,$00,$E5,$02,$F8,$08,$F4,$02; $B389: 10 F8 D4 42 18 00 E4 02 F0 00 E5 02 F8 08 F4 02
  .byte $F0,$08,$F5,$02,$F8,$00,$E7,$02,$00,$00,$E8,$02,$08,$08,$F7,$02; $B399: F0 08 F5 02 F8 00 E7 02 00 00 E8 02 08 08 F7 02
  .byte $00,$08,$C9,$02,$08,$00,$E5,$42,$10,$00,$E4,$42,$18,$08,$F5,$42; $B3A9: 00 08 C9 02 08 00 E5 42 10 00 E4 42 18 08 F5 42
  .byte $10,$08,$F4,$42,$18,$10,$C6,$02,$F0,$10,$C7,$02,$F8,$18,$D6,$02; $B3B9: 10 08 F4 42 18 10 C6 02 F0 10 C7 02 F8 18 D6 02
  .byte $F0,$18,$D7,$02,$F8,$10,$C8,$02,$00,$10,$D9,$02,$08,$18,$D8,$02; $B3C9: F0 18 D7 02 F8 10 C8 02 00 10 D9 02 08 18 D8 02
  .byte $00,$18,$D8,$42,$08,$10,$C7,$42,$10,$10,$C6,$42,$18,$18,$D7,$42; $B3D9: 00 18 D8 42 08 10 C7 42 10 10 C6 42 18 18 D7 42
  .byte $10,$18,$D6,$42,$18,$80                       ; $B3E9: 10 18 D6 42 18 80
;===============================================================================
; $B3EF: Phase9AdvanceRosterSweep
; Sub 3. Sweeps the acting side's 11 roster slots ($0558+$0548, slot index
; $0548 = 0..$0A): dead units ($05AC == 0) are cleared from the OAM via $B882
; ($0012=0) and removed from the event/row/column/roster arrays ($FF);
; living units get their strip sprite refreshed ($0012=1). When all slots
; are processed the advance finishes via Phase9AdvanceFinish.
;===============================================================================
.proc Phase9AdvanceRosterSweep
  LDA #$00                                ; $B3EF: A9 00
  LDY $0549                               ; $B3F1: AC 49 05 ; acting side
  BNE @SideB                              ; $B3F4: D0 02
  LDA #$0B                                ; $B3F6: A9 0B ; side 1 roster base
@SideB:
  CLC                                     ; $B3F8: 18
  ADC $0548                               ; $B3F9: 6D 48 05 ; + slot cursor
  TAY                                     ; $B3FC: A8 ; roster slot index
  LDA $05C2,Y                             ; $B3FD: B9 C2 05 ; roster entry
  CMP #$FF                                ; $B400: C9 FF
  BEQ @NextSlot                           ; $B402: F0 32 ; empty slot
  LDA $05AC,Y                             ; $B404: B9 AC 05 ; unit HP
  BNE @UpdateSprite                       ; $B407: D0 22 ; still alive
  LDA #$00                                ; $B409: A9 00
  STA a:$0012                             ; $B40B: 8D 12 00 ; clear-sprite flag
  STY a:$0013                             ; $B40E: 8C 13 00 ; slot param
  TYA                                     ; $B411: 98
  PHA                                     ; $B412: 48
  JSR $B882                               ; $B413: 20 82 B8 ; strip sprite clear
  PLA                                     ; $B416: 68
  TAY                                     ; $B417: A8
  LDA #$FF                                ; $B418: A9 FF
  STA $0580,Y                             ; $B41A: 99 80 05 ; event byte <- $FF
  STA $0596,Y                             ; $B41D: 99 96 05 ; row <- $FF
  STA $05C2,Y                             ; $B420: 99 C2 05 ; roster <- $FF
  LDA #$00                                ; $B423: A9 00
  STA $05AC,Y                             ; $B425: 99 AC 05 ; HP <- 0
  JMP @NextSlot                           ; $B428: 4C 36 B4
@UpdateSprite:
  LDA #$01                                ; $B42B: A9 01
  STA a:$0012                             ; $B42D: 8D 12 00 ; refresh-sprite flag
  STY a:$0013                             ; $B430: 8C 13 00 ; slot param
  JSR $B882                               ; $B433: 20 82 B8 ; strip sprite update
@NextSlot:
  INC $0548                               ; $B436: EE 48 05 ; slot cursor +1
  LDA $0548                               ; $B439: AD 48 05
  CMP #$0B                                ; $B43C: C9 0B
  BCC Phase9AdvanceReturn                 ; $B43E: 90 0A ; 11 slots not done
.endproc
;===============================================================================
; $B440: Phase9AdvanceFinish
; Shared advance-finish block (also the fall-through exit of
; Phase9AdvanceRosterSweep): re-enters the phase-8 row-effect dispatch at
; entry 3 ($0540 <- 8, $0541 <- 3).
;===============================================================================
.proc Phase9AdvanceFinish
  LDA #$08                                ; $B440: A9 08
  STA $0540                               ; $B442: 8D 40 05 ; phase <- 8
  LDA #$03                                ; $B445: A9 03
  STA $0541                               ; $B447: 8D 41 05 ; row-effect entry 3
.endproc
Phase9AdvanceReturn:
  RTS                                     ; $B44A: 60
;===============================================================================
; $B44B: Phase9AdvanceContactScan
; Contact-damage scan: converts the marker position $055A/$055B to tile
; coordinates ($001A row, $001B column) and scans the OPPOSING side's 11
; roster slots (side 0 -> slots $0B-$15, side 1 -> slots 0-$0A, cursor
; $001C); units within 2 tiles on both axes take contact damage
; (Phase9AdvanceContactApply).
;===============================================================================
.proc Phase9AdvanceContactScan
  LDA $055A                               ; $B44B: AD 5A 05 ; marker row
  LSR                                     ; $B44E: 4A
  LSR                                     ; $B44F: 4A
  LSR                                     ; $B450: 4A
  LSR                                     ; $B451: 4A ; /16
  STA a:$001A                             ; $B452: 8D 1A 00 ; marker tile row
  LDA $055B                               ; $B455: AD 5B 05 ; marker column
  LSR                                     ; $B458: 4A
  LSR                                     ; $B459: 4A
  LSR                                     ; $B45A: 4A
  LSR                                     ; $B45B: 4A ; /16
  STA a:$001B                             ; $B45C: 8D 1B 00 ; marker tile column
  LDY $0549                               ; $B45F: AC 49 05 ; acting side
  BNE @ScanSideA                          ; $B462: D0 13
  LDA #$0B                                ; $B464: A9 0B ; opposing base (side B)
  STA a:$001C                             ; $B466: 8D 1C 00 ; slot cursor
@ScanSideB:
  JSR Phase9AdvanceContactCheck           ; $B469: 20 8A B4
  INC a:$001C                             ; $B46C: EE 1C 00
  LDA a:$001C                             ; $B46F: AD 1C 00
  CMP #$16                                ; $B472: C9 16 ; 11 slots
  BCC @ScanSideB                          ; $B474: 90 F3
  RTS                                     ; $B476: 60
@ScanSideA:
  LDA #$00                                ; $B477: A9 00 ; opposing base (side A)
  STA a:$001C                             ; $B479: 8D 1C 00 ; slot cursor
@ScanSideALoop:
  JSR Phase9AdvanceContactCheck           ; $B47C: 20 8A B4
  INC a:$001C                             ; $B47F: EE 1C 00
  LDA a:$001C                             ; $B482: AD 1C 00
  CMP #$0B                                ; $B485: C9 0B ; 11 slots
  BCC @ScanSideALoop                      ; $B487: 90 F3
  RTS                                     ; $B489: 60
.endproc
;===============================================================================
; $B48A: Phase9AdvanceContactCheck
; Proximity check for roster slot $001C: |unit row $0596 - marker row $001A|
; <= 2 and |unit column $0580 - marker column $001B| <= 2 (both via biased
; unsigned compare) triggers Phase9AdvanceContactApply.
;===============================================================================
.proc Phase9AdvanceContactCheck
  LDY a:$001C                             ; $B48A: AC 1C 00 ; slot cursor
  LDA $0596,Y                             ; $B48D: B9 96 05 ; unit row
  SEC                                     ; $B490: 38
  SBC a:$001A                             ; $B491: ED 1A 00 ; - marker row
  CLC                                     ; $B494: 18
  ADC #$01                                ; $B495: 69 01 ; bias +1
  CMP #$03                                ; $B497: C9 03
  BCS @NoContact                          ; $B499: B0 0E ; row too far
  LDA $0580,Y                             ; $B49B: B9 80 05 ; unit column
  SEC                                     ; $B49E: 38
  SBC a:$001B                             ; $B49F: ED 1B 00 ; - marker column
  CLC                                     ; $B4A2: 18
  ADC #$01                                ; $B4A3: 69 01 ; bias +1
  CMP #$03                                ; $B4A5: C9 03
  BCC Phase9AdvanceContactApply           ; $B4A7: 90 01 ; in contact
@NoContact:
  RTS                                     ; $B4A9: 60
.endproc
;===============================================================================
; $B4AA: Phase9AdvanceContactApply
; Applies the rolled contact damage (Phase9AdvanceDamageRoll result $0000)
; to unit HP $05AC[$001C] (clamped at zero; on clamp the pre-damage HP is
; reported instead), then feeds the damage into the acting-side strip
; buffer ($000A <- $0560[$0549], $000B <- damage, $000C <- 0) and exits
; through the strip sprite update at $D7FB.
;===============================================================================
.proc Phase9AdvanceContactApply
  JSR Phase9AdvanceDamageRoll             ; $B4AA: 20 E3 B4
  LDY a:$001C                             ; $B4AD: AC 1C 00 ; slot cursor
  LDA $05AC,Y                             ; $B4B0: B9 AC 05 ; unit HP
  STA a:$0001                             ; $B4B3: 8D 01 00 ; old HP
  SEC                                     ; $B4B6: 38
  SBC a:$0000                             ; $B4B7: ED 00 00 ; - damage
  STA $05AC,Y                             ; $B4BA: 99 AC 05 ; new HP
  BEQ @StripUpdate                        ; $B4BD: F0 0D ; exactly zero
  BCS @StripUpdate                        ; $B4BF: B0 0B ; no underflow
  LDA #$00                                ; $B4C1: A9 00
  STA $05AC,Y                             ; $B4C3: 99 AC 05 ; clamp at zero
  LDA a:$0001                             ; $B4C6: AD 01 00
  STA a:$0000                             ; $B4C9: 8D 00 00 ; report old HP
@StripUpdate:
  LDA a:$0000                             ; $B4CC: AD 00 00 ; damage dealt
  STA a:$000B                             ; $B4CF: 8D 0B 00
  LDA #$00                                ; $B4D2: A9 00
  STA a:$000C                             ; $B4D4: 8D 0C 00
  LDY $0549                               ; $B4D7: AC 49 05 ; acting side
  LDA $0560,Y                             ; $B4DA: B9 60 05 ; strip buffer ptr lo
  STA a:$000A                             ; $B4DD: 8D 0A 00
  JMP $D7FB                               ; $B4E0: 4C FB D7 ; strip sprite update
.endproc
;===============================================================================
; $B4E3: Phase9AdvanceDamageRoll
; Contact-damage roll for slot $001C. Base damage = B1F_RandomBelowThreshold
; ($0A) + 2 subtracted from the acting-side officer record byte +2 (via
; B1F_GetOfficerRecordAddr on $0560[$0549]), clamped at zero then +1 (so
; 1..12). Commander slots (0 and $0B) take half damage; roster unit type 1
; ($05C2 low nibble) takes one third via B1F_MathDiv16 doubled. Result in
; $0000.
;===============================================================================
.proc Phase9AdvanceDamageRoll
  LDY $0549                               ; $B4E3: AC 49 05 ; acting side
  LDA $0560,Y                             ; $B4E6: B9 60 05 ; officer id
  JSR B1F_GetOfficerRecordAddr            ; $B4E9: 20 D7 F2 ; ($00) <- record
  LDY #$02                                ; $B4EC: A0 02
  LDA ($00),Y                             ; $B4EE: B1 00 ; record byte 2 (max)
  PHA                                     ; $B4F0: 48
  LDA #$0A                                ; $B4F1: A9 0A
  JSR B1F_RandomBelowThreshold            ; $B4F3: 20 62 E8 ; rand [0,$0A)
  CLC                                     ; $B4F6: 18
  ADC #$02                                ; $B4F7: 69 02 ; rand +2
  STA a:$0000                             ; $B4F9: 8D 00 00 ; damage roll
  PLA                                     ; $B4FC: 68
  SEC                                     ; $B4FD: 38
  SBC a:$0000                             ; $B4FE: ED 00 00 ; max - roll
  BCS @ClampDone                          ; $B501: B0 02
  LDA #$00                                ; $B503: A9 00 ; clamp at zero
@ClampDone:
  CLC                                     ; $B505: 18
  ADC #$01                                ; $B506: 69 01 ; min damage 1
  STA a:$0000                             ; $B508: 8D 00 00 ; base damage
  LDY a:$001C                             ; $B50B: AC 1C 00 ; slot cursor
  BEQ @CommanderSlot                      ; $B50E: F0 10 ; slot 0
  CPY #$0B                                ; $B510: C0 0B
  BEQ @CommanderSlot                      ; $B512: F0 0C ; slot $0B
  LDA $05C2,Y                             ; $B514: B9 C2 05 ; roster entry
  AND #$0F                                ; $B517: 29 0F ; unit type
  CMP #$01                                ; $B519: C9 01
  BEQ @Type1Unit                          ; $B51B: F0 0D
  JMP @DamageDone                         ; $B51D: 4C 47 B5 ; type != 1: as-is
@CommanderSlot:
  LDA a:$0000                             ; $B520: AD 00 00
  LSR                                     ; $B523: 4A ; halve
  STA a:$0000                             ; $B524: 8D 00 00
  JMP @DamageDone                         ; $B527: 4C 47 B5
@Type1Unit:
  LDA a:$0000                             ; $B52A: AD 00 00
  STA a:$0001                             ; $B52D: 8D 01 00 ; dividend
  LDA #$03                                ; $B530: A9 03
  STA a:$0003                             ; $B532: 8D 03 00 ; divisor
  LDA #$00                                ; $B535: A9 00
  STA a:$0002                             ; $B537: 8D 02 00 ; dividend hi
  STA a:$0004                             ; $B53A: 8D 04 00
  JSR B1F_MathDiv16                       ; $B53D: 20 7C EA ; /3
  LDA a:$0001                             ; $B540: AD 01 00 ; quotient
  ASL                                     ; $B543: 0A ; x2
  STA a:$0000                             ; $B544: 8D 00 00
@DamageDone:
  RTS                                     ; $B547: 60
.endproc
Loc_B548:
  LDY #$57                                ; $B548: A0 57
  LDA #$FF                                ; $B54A: A9 FF
Loc_B54C:
  STA $0580,Y                             ; $B54C: 99 80 05
  DEY                                     ; $B54F: 88
  BPL $B54C                               ; $B550: 10 FA
  LDA $0560                               ; $B552: AD 60 05
  JSR $F2D7                               ; $B555: 20 D7 F2
  LDY #$00                                ; $B558: A0 00
  LDA ($00),Y                             ; $B55A: B1 00
  STA $05AC                               ; $B55C: 8D AC 05
  LDY #$0B                                ; $B55F: A0 0B
  LDA ($00),Y                             ; $B561: B1 00
  PHA                                     ; $B563: 48
  LDY #$01                                ; $B564: A0 01
  LDA ($00),Y                             ; $B566: B1 00
  PHA                                     ; $B568: 48
  LDY #$09                                ; $B569: A0 09
  LDA ($00),Y                             ; $B56B: B1 00
  PHA                                     ; $B56D: 48
  STA a:$0002                             ; $B56E: 8D 02 00
  DEY                                     ; $B571: 88
  LDA ($00),Y                             ; $B572: B1 00
  PHA                                     ; $B574: 48
  STA a:$0001                             ; $B575: 8D 01 00
  LDA #$64                                ; $B578: A9 64
  STA a:$0003                             ; $B57A: 8D 03 00
  LDA #$00                                ; $B57D: A9 00
  STA a:$0004                             ; $B57F: 8D 04 00
  JSR $EA7C                               ; $B582: 20 7C EA
  LDA a:$0005                             ; $B585: AD 05 00
  BEQ $B58D                               ; $B588: F0 03
  INC a:$0001                             ; $B58A: EE 01 00
Loc_B58D:
  LDA a:$0001                             ; $B58D: AD 01 00
  STA $0566                               ; $B590: 8D 66 05
  STA a:$0003                             ; $B593: 8D 03 00
  PLA                                     ; $B596: 68
  STA a:$0001                             ; $B597: 8D 01 00
  PLA                                     ; $B59A: 68
  STA a:$0002                             ; $B59B: 8D 02 00
  LDA #$00                                ; $B59E: A9 00
  STA a:$0004                             ; $B5A0: 8D 04 00
  JSR $EA7C                               ; $B5A3: 20 7C EA
  LDY #$00                                ; $B5A6: A0 00
  INC a:$0001                             ; $B5A8: EE 01 00
  LDA a:$0001                             ; $B5AB: AD 01 00
Loc_B5AE:
  CPY a:$0005                             ; $B5AE: CC 05 00
  BCS $B5BE                               ; $B5B1: B0 0B
  STA $05AD,Y                             ; $B5B3: 99 AD 05
  INY                                     ; $B5B6: C8
  CPY $0566                               ; $B5B7: CC 66 05
  BCC $B5AE                               ; $B5BA: 90 F2
  BCS $B5CA                               ; $B5BC: B0 0C
Loc_B5BE:
  SEC                                     ; $B5BE: 38
  SBC #$01                                ; $B5BF: E9 01
Loc_B5C1:
  STA $05AD,Y                             ; $B5C1: 99 AD 05
  INY                                     ; $B5C4: C8
  CPY $0566                               ; $B5C5: CC 66 05
  BCC $B5C1                               ; $B5C8: 90 F7
Loc_B5CA:
  LDA $056C                               ; $B5CA: AD 6C 05
  AND #$03                                ; $B5CD: 29 03
  ASL                                     ; $B5CF: 0A
  TAY                                     ; $B5D0: A8
  LDA $B794,Y                             ; $B5D1: B9 94 B7
  STA a:$000A                             ; $B5D4: 8D 0A 00
  LDA $B795,Y                             ; $B5D7: B9 95 B7
  STA a:$000B                             ; $B5DA: 8D 0B 00
  LDA $B7A0,Y                             ; $B5DD: B9 A0 B7
  STA a:$000C                             ; $B5E0: 8D 0C 00
  LDA $B7A1,Y                             ; $B5E3: B9 A1 B7
  STA a:$000D                             ; $B5E6: 8D 0D 00
  LDY #$00                                ; $B5E9: A0 00
  PLA                                     ; $B5EB: 68
  CMP #$50                                ; $B5EC: C9 50
  BCS $B5F6                               ; $B5EE: B0 06
  INY                                     ; $B5F0: C8
  CMP #$32                                ; $B5F1: C9 32
  BCS $B5F6                               ; $B5F3: B0 01
  INY                                     ; $B5F5: C8
Loc_B5F6:
  STY a:$0000                             ; $B5F6: 8C 00 00
  PLA                                     ; $B5F9: 68
  LSR                                     ; $B5FA: 4A
  LSR                                     ; $B5FB: 4A
  LSR                                     ; $B5FC: 4A
  LSR                                     ; $B5FD: 4A
  ASL                                     ; $B5FE: 0A
  ASL                                     ; $B5FF: 0A
  ORA a:$0000                             ; $B600: 0D 00 00
  ASL                                     ; $B603: 0A
  TAY                                     ; $B604: A8
  LDA $B7AC,Y                             ; $B605: B9 AC B7
  STA a:$0001                             ; $B608: 8D 01 00
  LDA $B7AD,Y                             ; $B60B: B9 AD B7
  STA a:$0002                             ; $B60E: 8D 02 00
  LDA $0566                               ; $B611: AD 66 05
  STA a:$0000                             ; $B614: 8D 00 00
  INC a:$0000                             ; $B617: EE 00 00
  LDY #$00                                ; $B61A: A0 00
Loc_B61C:
  LDA #$30                                ; $B61C: A9 30
  CPY #$00                                ; $B61E: C0 00
  BEQ $B632                               ; $B620: F0 10
  LDA #$33                                ; $B622: A9 33
  CPY a:$0001                             ; $B624: CC 01 00
  BCC $B632                               ; $B627: 90 09
  LDA #$32                                ; $B629: A9 32
  CPY a:$0002                             ; $B62B: CC 02 00
  BCC $B632                               ; $B62E: 90 02
  LDA #$31                                ; $B630: A9 31
Loc_B632:
  STA $05C2,Y                             ; $B632: 99 C2 05
  LDA ($0A),Y                             ; $B635: B1 0A
  STA $0580,Y                             ; $B637: 99 80 05
  LDA ($0C),Y                             ; $B63A: B1 0C
  STA $0596,Y                             ; $B63C: 99 96 05
  INY                                     ; $B63F: C8
  CPY a:$0000                             ; $B640: CC 00 00
  BCC $B61C                               ; $B643: 90 D7
  LDA $0561                               ; $B645: AD 61 05
  JSR $F2D7                               ; $B648: 20 D7 F2
  LDY #$00                                ; $B64B: A0 00
  LDA ($00),Y                             ; $B64D: B1 00
  STA $05B7                               ; $B64F: 8D B7 05
  LDY #$0B                                ; $B652: A0 0B
  LDA ($00),Y                             ; $B654: B1 00
  PHA                                     ; $B656: 48
  LDY #$01                                ; $B657: A0 01
  LDA ($00),Y                             ; $B659: B1 00
  PHA                                     ; $B65B: 48
  LDY #$09                                ; $B65C: A0 09
  LDA ($00),Y                             ; $B65E: B1 00
  PHA                                     ; $B660: 48
  STA a:$0002                             ; $B661: 8D 02 00
  DEY                                     ; $B664: 88
  LDA ($00),Y                             ; $B665: B1 00
  PHA                                     ; $B667: 48
  STA a:$0001                             ; $B668: 8D 01 00
  LDA #$64                                ; $B66B: A9 64
  STA a:$0003                             ; $B66D: 8D 03 00
  LDA #$00                                ; $B670: A9 00
  STA a:$0004                             ; $B672: 8D 04 00
  JSR $EA7C                               ; $B675: 20 7C EA
  LDA a:$0005                             ; $B678: AD 05 00
  BEQ $B680                               ; $B67B: F0 03
  INC a:$0001                             ; $B67D: EE 01 00
Loc_B680:
  LDA a:$0001                             ; $B680: AD 01 00
  STA $0567                               ; $B683: 8D 67 05
  STA a:$0003                             ; $B686: 8D 03 00
  PLA                                     ; $B689: 68
  STA a:$0001                             ; $B68A: 8D 01 00
  PLA                                     ; $B68D: 68
  STA a:$0002                             ; $B68E: 8D 02 00
  LDA #$00                                ; $B691: A9 00
  STA a:$0004                             ; $B693: 8D 04 00
  JSR $EA7C                               ; $B696: 20 7C EA
  LDY #$00                                ; $B699: A0 00
  INC a:$0001                             ; $B69B: EE 01 00
  LDA a:$0001                             ; $B69E: AD 01 00
Loc_B6A1:
  CPY a:$0005                             ; $B6A1: CC 05 00
  BCS $B6B1                               ; $B6A4: B0 0B
  STA $05B8,Y                             ; $B6A6: 99 B8 05
  INY                                     ; $B6A9: C8
  CPY $0567                               ; $B6AA: CC 67 05
  BCC $B6A1                               ; $B6AD: 90 F2
  BCS $B6BD                               ; $B6AF: B0 0C
Loc_B6B1:
  SEC                                     ; $B6B1: 38
  SBC #$01                                ; $B6B2: E9 01
Loc_B6B4:
  STA $05B8,Y                             ; $B6B4: 99 B8 05
  INY                                     ; $B6B7: C8
  CPY $0567                               ; $B6B8: CC 67 05
  BCC $B6B4                               ; $B6BB: 90 F7
Loc_B6BD:
  LDA #$04                                ; $B6BD: A9 04
  LDY $0544                               ; $B6BF: AC 44 05
  CPY #$05                                ; $B6C2: C0 05
  BEQ $B6CB                               ; $B6C4: F0 05
  LDA $056D                               ; $B6C6: AD 6D 05
  AND #$03                                ; $B6C9: 29 03
Loc_B6CB:
  ASL                                     ; $B6CB: 0A
  TAY                                     ; $B6CC: A8
  LDA $B794,Y                             ; $B6CD: B9 94 B7
  STA a:$000A                             ; $B6D0: 8D 0A 00
  LDA $B795,Y                             ; $B6D3: B9 95 B7
  STA a:$000B                             ; $B6D6: 8D 0B 00
  LDA $B7A0,Y                             ; $B6D9: B9 A0 B7
  STA a:$000C                             ; $B6DC: 8D 0C 00
  LDA $B7A1,Y                             ; $B6DF: B9 A1 B7
  STA a:$000D                             ; $B6E2: 8D 0D 00
  LDA $B796,Y                             ; $B6E5: B9 96 B7
  STA a:$001A                             ; $B6E8: 8D 1A 00
  LDA $B797,Y                             ; $B6EB: B9 97 B7
  STA a:$001B                             ; $B6EE: 8D 1B 00
  LDA $B7A2,Y                             ; $B6F1: B9 A2 B7
  STA a:$001C                             ; $B6F4: 8D 1C 00
  LDA $B7A3,Y                             ; $B6F7: B9 A3 B7
  STA a:$001D                             ; $B6FA: 8D 1D 00
  LDY #$00                                ; $B6FD: A0 00
  PLA                                     ; $B6FF: 68
  CMP #$50                                ; $B700: C9 50
  BCS $B70A                               ; $B702: B0 06
  INY                                     ; $B704: C8
  CMP #$32                                ; $B705: C9 32
  BCS $B70A                               ; $B707: B0 01
  INY                                     ; $B709: C8
Loc_B70A:
  STY a:$0000                             ; $B70A: 8C 00 00
  PLA                                     ; $B70D: 68
  LSR                                     ; $B70E: 4A
  LSR                                     ; $B70F: 4A
  LSR                                     ; $B710: 4A
  LSR                                     ; $B711: 4A
  ASL                                     ; $B712: 0A
  ASL                                     ; $B713: 0A
  ORA a:$0000                             ; $B714: 0D 00 00
  ASL                                     ; $B717: 0A
  TAY                                     ; $B718: A8
  LDA $B7AC,Y                             ; $B719: B9 AC B7
  STA a:$0001                             ; $B71C: 8D 01 00
  LDA $B7AD,Y                             ; $B71F: B9 AD B7
  STA a:$0002                             ; $B722: 8D 02 00
  LDA $0544                               ; $B725: AD 44 05
  CMP #$05                                ; $B728: C9 05
  BNE $B731                               ; $B72A: D0 05
  LDA #$00                                ; $B72C: A9 00
  STA a:$0001                             ; $B72E: 8D 01 00
Loc_B731:
  LDA $0567                               ; $B731: AD 67 05
  STA a:$0000                             ; $B734: 8D 00 00
  INC a:$0000                             ; $B737: EE 00 00
  LDY #$00                                ; $B73A: A0 00
Loc_B73C:
  LDA #$20                                ; $B73C: A9 20
  CPY #$00                                ; $B73E: C0 00
  BEQ $B752                               ; $B740: F0 10
  LDA #$23                                ; $B742: A9 23
  CPY a:$0001                             ; $B744: CC 01 00
  BCC $B752                               ; $B747: 90 09
  LDA #$22                                ; $B749: A9 22
  CPY a:$0002                             ; $B74B: CC 02 00
  BCC $B752                               ; $B74E: 90 02
  LDA #$21                                ; $B750: A9 21
Loc_B752:
  STA $05CD,Y                             ; $B752: 99 CD 05
  CMP #$22                                ; $B755: C9 22
  BEQ $B77A                               ; $B757: F0 21
  LDA $0544                               ; $B759: AD 44 05
  CMP #$05                                ; $B75C: C9 05
  BNE $B77A                               ; $B75E: D0 1A
  LDA ($1A),Y                             ; $B760: B1 1A
  STA a:$0003                             ; $B762: 8D 03 00
  LDA #$0F                                ; $B765: A9 0F
  SEC                                     ; $B767: 38
  SBC a:$0003                             ; $B768: ED 03 00
  STA $058B,Y                             ; $B76B: 99 8B 05
  LDA ($1C),Y                             ; $B76E: B1 1C
  STA $05A1,Y                             ; $B770: 99 A1 05
  INY                                     ; $B773: C8
  CPY a:$0000                             ; $B774: CC 00 00
  BCC $B73C                               ; $B777: 90 C3
  RTS                                     ; $B779: 60
Loc_B77A:
  LDA ($0A),Y                             ; $B77A: B1 0A
  STA a:$0003                             ; $B77C: 8D 03 00
  LDA #$0F                                ; $B77F: A9 0F
  SEC                                     ; $B781: 38
  SBC a:$0003                             ; $B782: ED 03 00
  STA $058B,Y                             ; $B785: 99 8B 05
  LDA ($0C),Y                             ; $B788: B1 0C
  STA $05A1,Y                             ; $B78A: 99 A1 05
  INY                                     ; $B78D: C8
  CPY a:$0000                             ; $B78E: CC 00 00
  BCC $B73C                               ; $B791: 90 A9
  RTS                                     ; $B793: 60
; --- Data Region ---
  .byte $EC,$B7,$F7,$B7,$02,$B8,$0D,$B8,$18,$B8,$23,$B8,$2E,$B8,$39,$B8; $B794: EC B7 F7 B7 02 B8 0D B8 18 B8 23 B8 2E B8 39 B8
  .byte $44,$B8,$4F,$B8,$5A,$B8,$65,$B8,$06,$09,$08,$0A,$08,$0B,$00,$00; $B7A4: 44 B8 4F B8 5A B8 65 B8 06 09 08 0A 08 0B 00 00
  .byte $05,$09,$07,$0A,$07,$0B,$00,$00,$05,$08,$06,$09,$06,$0A,$00,$00; $B7B4: 05 09 07 0A 07 0B 00 00 05 08 06 09 06 0A 00 00
  .byte $04,$07,$05,$08,$06,$09,$00,$00,$03,$06,$04,$08,$05,$09,$00,$00; $B7C4: 04 07 05 08 06 09 00 00 03 06 04 08 05 09 00 00
  .byte $02,$06,$04,$07,$04,$08,$00,$00,$02,$05,$03,$06,$04,$07,$00,$00; $B7D4: 02 06 04 07 04 08 00 00 02 05 03 06 04 07 00 00
  .byte $01,$05,$02,$06,$03,$07,$00,$00,$01,$02,$02,$02,$03,$03,$03,$04; $B7E4: 01 05 02 06 03 07 00 00 01 02 02 02 03 03 03 04
  .byte $04,$05,$03,$01,$04,$04,$02,$02,$03,$03,$04,$04,$05,$05,$01,$03; $B7F4: 04 05 03 01 04 04 02 02 03 03 04 04 05 05 01 03
  .byte $02,$02,$02,$02,$03,$03,$04,$04,$05,$01,$02,$02,$03,$03,$03,$04; $B804: 02 02 02 02 03 03 04 04 05 01 02 02 03 03 03 04
  .byte $04,$05,$05,$05,$01,$03,$03,$08,$08,$06,$06,$07,$07,$07,$07,$01; $B814: 04 05 05 05 01 03 03 08 08 06 06 07 07 07 07 01
  .byte $03,$03,$08,$08,$01,$01,$03,$03,$02,$02,$05,$01,$02,$03,$04,$05; $B824: 03 03 08 08 01 01 03 03 02 02 05 01 02 03 04 05
  .byte $06,$07,$08,$09,$09,$05,$04,$06,$04,$06,$03,$07,$02,$08,$01,$09; $B834: 06 07 08 09 09 05 04 06 04 06 03 07 02 08 01 09
  .byte $05,$05,$04,$06,$02,$08,$03,$07,$04,$06,$05,$05,$04,$06,$03,$05; $B844: 05 05 04 06 02 08 03 07 04 06 05 05 04 06 03 05
  .byte $07,$04,$06,$03,$05,$07,$05,$04,$06,$02,$08,$02,$08,$01,$09,$02; $B854: 07 04 06 03 05 07 05 04 06 02 08 02 08 01 09 02
  .byte $08,$05,$04,$06,$02,$08,$03,$07,$02,$08,$01,$09; $B864: 08 05 04 06 02 08 03 07 02 08 01 09
Loc_B870:
; --- Code Region ---
  LDA $0304                               ; $B870: AD 04 03
  CMP #$FF                                ; $B873: C9 FF
  BNE $B880                               ; $B875: D0 09
  LDA $0300                               ; $B877: AD 00 03
  CMP #$FF                                ; $B87A: C9 FF
  BNE $B880                               ; $B87C: D0 02
  SEC                                     ; $B87E: 38
  RTS                                     ; $B87F: 60
Loc_B880:
  CLC                                     ; $B880: 18
  RTS                                     ; $B881: 60
Loc_B882:
  LDY a:$0013                             ; $B882: AC 13 00
  LDA $0580,Y                             ; $B885: B9 80 05
  STA a:$0010                             ; $B888: 8D 10 00
  LDA $0596,Y                             ; $B88B: B9 96 05
  STA a:$0011                             ; $B88E: 8D 11 00
  LDA $0544                               ; $B891: AD 44 05
  PHA                                     ; $B894: 48
  PHA                                     ; $B895: 48
  TAY                                     ; $B896: A8
  LDA $BB48,Y                             ; $B897: B9 48 BB
  TAY                                     ; $B89A: A8
  JSR $F25F                               ; $B89B: 20 5F F2
  PLA                                     ; $B89E: 68
  ASL                                     ; $B89F: 0A
  TAY                                     ; $B8A0: A8
  LDA $BB1E,Y                             ; $B8A1: B9 1E BB
  STA a:$0000                             ; $B8A4: 8D 00 00
  LDA $BB1F,Y                             ; $B8A7: B9 1F BB
  STA a:$0001                             ; $B8AA: 8D 01 00
  LDA $BB2C,Y                             ; $B8AD: B9 2C BB
  STA a:$0002                             ; $B8B0: 8D 02 00
  LDA $BB2D,Y                             ; $B8B3: B9 2D BB
  STA a:$0003                             ; $B8B6: 8D 03 00
  LDA a:$0010                             ; $B8B9: AD 10 00
  STA a:$0008                             ; $B8BC: 8D 08 00
  LDX #$00                                ; $B8BF: A2 00
  LDA a:$0011                             ; $B8C1: AD 11 00
  ASL                                     ; $B8C4: 0A
  ASL                                     ; $B8C5: 0A
  ASL                                     ; $B8C6: 0A
  ASL                                     ; $B8C7: 0A
  PHA                                     ; $B8C8: 48
  ORA a:$0010                             ; $B8C9: 0D 10 00
  TAY                                     ; $B8CC: A8
  LDA #$00                                ; $B8CD: A9 00
  STA a:$0004                             ; $B8CF: 8D 04 00
  LDA ($00),Y                             ; $B8D2: B1 00
  ASL                                     ; $B8D4: 0A
  ROL a:$0004                             ; $B8D5: 2E 04 00
  ASL                                     ; $B8D8: 0A
  ROL a:$0004                             ; $B8D9: 2E 04 00
  CLC                                     ; $B8DC: 18
  ADC a:$0002                             ; $B8DD: 6D 02 00
  STA a:$0002                             ; $B8E0: 8D 02 00
  LDA a:$0003                             ; $B8E3: AD 03 00
  ADC a:$0004                             ; $B8E6: 6D 04 00
  STA a:$0003                             ; $B8E9: 8D 03 00
  LDY #$00                                ; $B8EC: A0 00
  LDA ($02),Y                             ; $B8EE: B1 02
  STA $0383                               ; $B8F0: 8D 83 03
  STA $0391                               ; $B8F3: 8D 91 03
  INY                                     ; $B8F6: C8
  LDA ($02),Y                             ; $B8F7: B1 02
  STA $0384                               ; $B8F9: 8D 84 03
  STA $0392                               ; $B8FC: 8D 92 03
  INY                                     ; $B8FF: C8
  LDA ($02),Y                             ; $B900: B1 02
  STA $0388                               ; $B902: 8D 88 03
  STA $0396                               ; $B905: 8D 96 03
  INY                                     ; $B908: C8
  LDA ($02),Y                             ; $B909: B1 02
  STA $0389                               ; $B90B: 8D 89 03
  STA $0397                               ; $B90E: 8D 97 03
  ASL a:$0008                             ; $B911: 0E 08 00
  LDA #$00                                ; $B914: A9 00
  STA a:$000B                             ; $B916: 8D 0B 00
  PLA                                     ; $B919: 68
  ASL                                     ; $B91A: 0A
  ROL a:$000B                             ; $B91B: 2E 0B 00
  ASL                                     ; $B91E: 0A
  ROL a:$000B                             ; $B91F: 2E 0B 00
  CLC                                     ; $B922: 18
  ADC a:$0008                             ; $B923: 6D 08 00
  STA $0382                               ; $B926: 8D 82 03
  STA $0390                               ; $B929: 8D 90 03
  LDA a:$000B                             ; $B92C: AD 0B 00
  ORA #$20                                ; $B92F: 09 20
  STA $0381                               ; $B931: 8D 81 03
  ORA #$04                                ; $B934: 09 04
  STA $038F                               ; $B936: 8D 8F 03
  LDA $0382                               ; $B939: AD 82 03
  CLC                                     ; $B93C: 18
  ADC #$20                                ; $B93D: 69 20
  STA $0387                               ; $B93F: 8D 87 03
  STA $0395                               ; $B942: 8D 95 03
  LDA $0381                               ; $B945: AD 81 03
  ADC #$00                                ; $B948: 69 00
  STA $0386                               ; $B94A: 8D 86 03
  ORA #$04                                ; $B94D: 09 04
  STA $0394                               ; $B94F: 8D 94 03
  LDA #$02                                ; $B952: A9 02
  STA $0380                               ; $B954: 8D 80 03
  STA $0385                               ; $B957: 8D 85 03
  STA $038E                               ; $B95A: 8D 8E 03
  STA $0393                               ; $B95D: 8D 93 03
  LDA a:$0012                             ; $B960: AD 12 00
  BEQ $B9A9                               ; $B963: F0 44
  LDY a:$0013                             ; $B965: AC 13 00
  LDA $05C2,Y                             ; $B968: B9 C2 05
  AND #$03                                ; $B96B: 29 03
  STA a:$0000                             ; $B96D: 8D 00 00
  LDA $05C2,Y                             ; $B970: B9 C2 05
  AND #$F0                                ; $B973: 29 F0
  LSR                                     ; $B975: 4A
  LSR                                     ; $B976: 4A
  ORA a:$0000                             ; $B977: 0D 00 00
  CMP #$10                                ; $B97A: C9 10
  BCC $B97F                               ; $B97C: 90 01
  NOP                                     ; $B97E: EA
Loc_B97F:
  ASL                                     ; $B97F: 0A
  ASL                                     ; $B980: 0A
  TAY                                     ; $B981: A8
  LDA $BB4F,Y                             ; $B982: B9 4F BB
  STA $0383                               ; $B985: 8D 83 03
  STA $0391                               ; $B988: 8D 91 03
  LDA $BB50,Y                             ; $B98B: B9 50 BB
  STA $0384                               ; $B98E: 8D 84 03
  STA $0392                               ; $B991: 8D 92 03
  LDA $BB51,Y                             ; $B994: B9 51 BB
  STA $0388                               ; $B997: 8D 88 03
  STA $0396                               ; $B99A: 8D 96 03
  LDA $BB52,Y                             ; $B99D: B9 52 BB
  STA $0389                               ; $B9A0: 8D 89 03
  STA $0397                               ; $B9A3: 8D 97 03
  JSR $BA18                               ; $B9A6: 20 18 BA
Loc_B9A9:
  PLA                                     ; $B9A9: 68
  ASL                                     ; $B9AA: 0A
  TAY                                     ; $B9AB: A8
  LDA $BB3A,Y                             ; $B9AC: B9 3A BB
  STA a:$0000                             ; $B9AF: 8D 00 00
  LDA $BB3B,Y                             ; $B9B2: B9 3B BB
  STA a:$0001                             ; $B9B5: 8D 01 00
  LDA a:$0010                             ; $B9B8: AD 10 00
  AND #$0E                                ; $B9BB: 29 0E
  LSR                                     ; $B9BD: 4A
  STA a:$0008                             ; $B9BE: 8D 08 00
  LDA a:$0011                             ; $B9C1: AD 11 00
  AND #$0E                                ; $B9C4: 29 0E
  ASL                                     ; $B9C6: 0A
  ASL                                     ; $B9C7: 0A
  ORA a:$0008                             ; $B9C8: 0D 08 00
  TAY                                     ; $B9CB: A8
  LDA ($00),Y                             ; $B9CC: B1 00
  STA a:$0000                             ; $B9CE: 8D 00 00
  JSR $BA56                               ; $B9D1: 20 56 BA
  LDA a:$0000                             ; $B9D4: AD 00 00
  STA $038D                               ; $B9D7: 8D 8D 03
  STA $039B                               ; $B9DA: 8D 9B 03
  LDA a:$0010                             ; $B9DD: AD 10 00
  AND #$0E                                ; $B9E0: 29 0E
  LSR                                     ; $B9E2: 4A
  STA a:$0000                             ; $B9E3: 8D 00 00
  LDA a:$0011                             ; $B9E6: AD 11 00
  AND #$0E                                ; $B9E9: 29 0E
  ASL                                     ; $B9EB: 0A
  ASL                                     ; $B9EC: 0A
  ORA a:$0000                             ; $B9ED: 0D 00 00
  ORA #$C0                                ; $B9F0: 09 C0
  STA $038C                               ; $B9F2: 8D 8C 03
  STA $039A                               ; $B9F5: 8D 9A 03
  LDA #$23                                ; $B9F8: A9 23
  STA $038B                               ; $B9FA: 8D 8B 03
  LDA #$27                                ; $B9FD: A9 27
  STA $0399                               ; $B9FF: 8D 99 03
  LDA #$01                                ; $BA02: A9 01
  STA $038A                               ; $BA04: 8D 8A 03
  STA $0398                               ; $BA07: 8D 98 03
  LDA #$FF                                ; $BA0A: A9 FF
  STA $039C                               ; $BA0C: 8D 9C 03
  LDA a:$007E                             ; $BA0F: AD 7E 00
  ORA #$04                                ; $BA12: 09 04
  STA a:$007E                             ; $BA14: 8D 7E 00
  RTS                                     ; $BA17: 60
Loc_BA18:
  LDY a:$0013                             ; $BA18: AC 13 00
  LDA $05AC,Y                             ; $BA1B: B9 AC 05
  STA a:$0001                             ; $BA1E: 8D 01 00
  LDA #$00                                ; $BA21: A9 00
  STA a:$0002                             ; $BA23: 8D 02 00
  STA a:$0003                             ; $BA26: 8D 03 00
  JSR $E9BA                               ; $BA29: 20 BA E9
  LDA a:$0007                             ; $BA2C: AD 07 00
  LSR                                     ; $BA2F: 4A
  LSR                                     ; $BA30: 4A
  LSR                                     ; $BA31: 4A
  LSR                                     ; $BA32: 4A
  CLC                                     ; $BA33: 18
  ADC #$B4                                ; $BA34: 69 B4
  STA $0396                               ; $BA36: 8D 96 03
  LDA a:$0007                             ; $BA39: AD 07 00
  AND #$0F                                ; $BA3C: 29 0F
  CLC                                     ; $BA3E: 18
  ADC #$B4                                ; $BA3F: 69 B4
  STA $0397                               ; $BA41: 8D 97 03
  LDA a:$0008                             ; $BA44: AD 08 00
  AND #$0F                                ; $BA47: 29 0F
  BEQ $BA55                               ; $BA49: F0 0A
  LDA #$BE                                ; $BA4B: A9 BE
  STA $0396                               ; $BA4D: 8D 96 03
  LDA #$BF                                ; $BA50: A9 BF
  STA $0397                               ; $BA52: 8D 97 03
Loc_BA55:
  RTS                                     ; $BA55: 60
Loc_BA56:
  LDA a:$0010                             ; $BA56: AD 10 00
  AND #$0E                                ; $BA59: 29 0E
  STA a:$0002                             ; $BA5B: 8D 02 00
  LDA a:$0011                             ; $BA5E: AD 11 00
  AND #$0E                                ; $BA61: 29 0E
  STA a:$0003                             ; $BA63: 8D 03 00
  LDY #$15                                ; $BA66: A0 15
Loc_BA68:
  LDA a:$0012                             ; $BA68: AD 12 00
  BNE $BA72                               ; $BA6B: D0 05
  CPY a:$0013                             ; $BA6D: CC 13 00
  BEQ $BA75                               ; $BA70: F0 03
Loc_BA72:
  JSR $BA79                               ; $BA72: 20 79 BA
Loc_BA75:
  DEY                                     ; $BA75: 88
  BPL $BA68                               ; $BA76: 10 F0
  RTS                                     ; $BA78: 60
Loc_BA79:
  LDA #$01                                ; $BA79: A9 01
  STA a:$000A                             ; $BA7B: 8D 0A 00
  LDA #$04                                ; $BA7E: A9 04
  STA a:$000B                             ; $BA80: 8D 0B 00
  LDA #$10                                ; $BA83: A9 10
  STA a:$000C                             ; $BA85: 8D 0C 00
  LDA #$40                                ; $BA88: A9 40
  STA a:$000D                             ; $BA8A: 8D 0D 00
  CPY #$0B                                ; $BA8D: C0 0B
  BCS $BAA5                               ; $BA8F: B0 14
  LDA #$03                                ; $BA91: A9 03
  STA a:$000A                             ; $BA93: 8D 0A 00
  LDA #$0C                                ; $BA96: A9 0C
  STA a:$000B                             ; $BA98: 8D 0B 00
  LDA #$30                                ; $BA9B: A9 30
  STA a:$000C                             ; $BA9D: 8D 0C 00
  LDA #$C0                                ; $BAA0: A9 C0
  STA a:$000D                             ; $BAA2: 8D 0D 00
Loc_BAA5:
  LDA a:$0002                             ; $BAA5: AD 02 00
  CMP $0580,Y                             ; $BAA8: D9 80 05
  BNE $BAC0                               ; $BAAB: D0 13
  LDA a:$0003                             ; $BAAD: AD 03 00
  CMP $0596,Y                             ; $BAB0: D9 96 05
  BNE $BAC0                               ; $BAB3: D0 0B
  LDA a:$0000                             ; $BAB5: AD 00 00
  AND #$FC                                ; $BAB8: 29 FC
  ORA a:$000A                             ; $BABA: 0D 0A 00
  STA a:$0000                             ; $BABD: 8D 00 00
Loc_BAC0:
  INC a:$0002                             ; $BAC0: EE 02 00
  LDA a:$0002                             ; $BAC3: AD 02 00
  CMP $0580,Y                             ; $BAC6: D9 80 05
  BNE $BADE                               ; $BAC9: D0 13
  LDA a:$0003                             ; $BACB: AD 03 00
  CMP $0596,Y                             ; $BACE: D9 96 05
  BNE $BADE                               ; $BAD1: D0 0B
  LDA a:$0000                             ; $BAD3: AD 00 00
  AND #$F3                                ; $BAD6: 29 F3
  ORA a:$000B                             ; $BAD8: 0D 0B 00
  STA a:$0000                             ; $BADB: 8D 00 00
Loc_BADE:
  INC a:$0003                             ; $BADE: EE 03 00
  LDA a:$0002                             ; $BAE1: AD 02 00
  CMP $0580,Y                             ; $BAE4: D9 80 05
  BNE $BAFC                               ; $BAE7: D0 13
  LDA a:$0003                             ; $BAE9: AD 03 00
  CMP $0596,Y                             ; $BAEC: D9 96 05
  BNE $BAFC                               ; $BAEF: D0 0B
  LDA a:$0000                             ; $BAF1: AD 00 00
  AND #$3F                                ; $BAF4: 29 3F
  ORA a:$000D                             ; $BAF6: 0D 0D 00
  STA a:$0000                             ; $BAF9: 8D 00 00
Loc_BAFC:
  DEC a:$0002                             ; $BAFC: CE 02 00
  LDA a:$0002                             ; $BAFF: AD 02 00
  CMP $0580,Y                             ; $BB02: D9 80 05
  BNE $BB1A                               ; $BB05: D0 13
  LDA a:$0003                             ; $BB07: AD 03 00
  CMP $0596,Y                             ; $BB0A: D9 96 05
  BNE $BB1A                               ; $BB0D: D0 0B
  LDA a:$0000                             ; $BB0F: AD 00 00
  AND #$CF                                ; $BB12: 29 CF
  ORA a:$000C                             ; $BB14: 0D 0C 00
  STA a:$0000                             ; $BB17: 8D 00 00
Loc_BB1A:
  DEC a:$0003                             ; $BB1A: CE 03 00
  RTS                                     ; $BB1D: 60
; --- Data Region ---
  .byte $40,$84,$70,$85,$A0,$86,$D0,$87,$00,$89,$30,$8A,$60,$8B,$00,$80; $BB1E: 40 84 70 85 A0 86 D0 87 00 89 30 8A 60 8B 00 80
  .byte $00,$80,$00,$80,$00,$80,$00,$80,$00,$80,$00,$80,$00,$84,$30,$85; $BB2E: 00 80 00 80 00 80 00 80 00 80 00 80 00 84 30 85
  .byte $60,$86,$90,$87,$C0,$88,$F0,$89,$20,$8B,$21,$21,$21,$21,$21,$21; $BB3E: 60 86 90 87 C0 88 F0 89 20 8B 21 21 21 21 21 21
  .byte $21,$FD,$63,$72,$73,$62,$63,$72,$73,$48,$49,$58,$59,$4E,$4F,$5E; $BB4E: 21 FD 63 72 73 62 63 72 73 48 49 58 59 4E 4F 5E
  .byte $5F,$60,$FC,$70,$71,$60,$61,$70,$71,$4A,$4B,$5A,$5B,$4C,$4D,$5C; $BB5E: 5F 60 FC 70 71 60 61 70 71 4A 4B 5A 5B 4C 4D 5C
  .byte $5D,$46,$47,$54,$55,$44,$45,$54,$55,$40,$41,$50,$51,$42,$43,$52; $BB6E: 5D 46 47 54 55 44 45 54 55 40 41 50 51 42 43 52
  .byte $53,$56,$57,$66,$67,$64,$65,$66,$67,$6C,$6D,$6E,$6F,$68,$69,$6A; $BB7E: 53 56 57 66 67 64 65 66 67 6C 6D 6E 6F 68 69 6A
  .byte $6B                               ; $BB8E: 6B
Loc_BB8F:
; --- Code Region ---
  LDA a:$005E                             ; $BB8F: AD 5E 00
  LSR                                     ; $BB92: 4A
  LSR                                     ; $BB93: 4A
  AND #$03                                ; $BB94: 29 03
  STA a:$0001                             ; $BB96: 8D 01 00
  LDY $0545                               ; $BB99: AC 45 05
  LDA $05C2,Y                             ; $BB9C: B9 C2 05
  AND #$03                                ; $BB9F: 29 03
  STA a:$0000                             ; $BBA1: 8D 00 00
  LDA $05C2,Y                             ; $BBA4: B9 C2 05
  AND #$F0                                ; $BBA7: 29 F0
  LSR                                     ; $BBA9: 4A
  LSR                                     ; $BBAA: 4A
  ORA a:$0000                             ; $BBAB: 0D 00 00
  ASL                                     ; $BBAE: 0A
  ASL                                     ; $BBAF: 0A
  ORA a:$0001                             ; $BBB0: 0D 01 00
  ASL                                     ; $BBB3: 0A
  TAY                                     ; $BBB4: A8
  LDA $BBFD,Y                             ; $BBB5: B9 FD BB
  STA a:$0000                             ; $BBB8: 8D 00 00
  LDA $BBFE,Y                             ; $BBBB: B9 FE BB
  STA a:$0001                             ; $BBBE: 8D 01 00
  LDA $054A                               ; $BBC1: AD 4A 05
  CLC                                     ; $BBC4: 18
  ADC #$08                                ; $BBC5: 69 08
  STA a:$000C                             ; $BBC7: 8D 0C 00
  LDA $054B                               ; $BBCA: AD 4B 05
  STA a:$000A                             ; $BBCD: 8D 0A 00
  LDA #$00                                ; $BBD0: A9 00
  STA a:$000B                             ; $BBD2: 8D 0B 00
  STA a:$000D                             ; $BBD5: 8D 0D 00
  LDA #$00                                ; $BBD8: A9 00
  STA a:$0002                             ; $BBDA: 8D 02 00
  LDY $0545                               ; $BBDD: AC 45 05
  LDA $05C2,Y                             ; $BBE0: B9 C2 05
  LSR                                     ; $BBE3: 4A
  LSR                                     ; $BBE4: 4A
  LSR                                     ; $BBE5: 4A
  LSR                                     ; $BBE6: 4A
  CMP #$03                                ; $BBE7: C9 03
  BNE $BBF0                               ; $BBE9: D0 05
  LDA #$40                                ; $BBEB: A9 40
  STA a:$0002                             ; $BBED: 8D 02 00
Loc_BBF0:
  LDY $0545                               ; $BBF0: AC 45 05
  CPY #$0B                                ; $BBF3: C0 0B
  BCS $BBFA                               ; $BBF5: B0 03
  INC a:$0002                             ; $BBF7: EE 02 00
Loc_BBFA:
  JMP $F092                               ; $BBFA: 4C 92 F0
; --- Data Region ---
  .byte $05,$BD,$16,$BD,$05,$BD,$16,$BD,$27,$BD,$38,$BD,$27,$BD,$38,$BD; $BBFD: 05 BD 16 BD 05 BD 16 BD 27 BD 38 BD 27 BD 38 BD
  .byte $49,$BD,$5A,$BD,$49,$BD,$5A,$BD,$6B,$BD,$7C,$BD,$6B,$BD,$7C,$BD; $BC0D: 49 BD 5A BD 49 BD 5A BD 6B BD 7C BD 6B BD 7C BD
  .byte $7D,$BC,$8E,$BC,$7D,$BC,$8E,$BC,$9F,$BC,$B0,$BC,$9F,$BC,$B0,$BC; $BC1D: 7D BC 8E BC 7D BC 8E BC 9F BC B0 BC 9F BC B0 BC
  .byte $C1,$BC,$D2,$BC,$C1,$BC,$D2,$BC,$E3,$BC,$F4,$BC,$E3,$BC,$F4,$BC; $BC2D: C1 BC D2 BC C1 BC D2 BC E3 BC F4 BC E3 BC F4 BC
  .byte $8D,$BD,$9E,$BD,$8D,$BD,$9E,$BD,$AF,$BD,$C0,$BD,$AF,$BD,$C0,$BD; $BC3D: 8D BD 9E BD 8D BD 9E BD AF BD C0 BD AF BD C0 BD
  .byte $D1,$BD,$E2,$BD,$D1,$BD,$E2,$BD,$F3,$BD,$04,$BE,$F3,$BD,$04,$BE; $BC4D: D1 BD E2 BD D1 BD E2 BD F3 BD 04 BE F3 BD 04 BE
  .byte $8D,$BD,$9E,$BD,$8D,$BD,$9E,$BD,$AF,$BD,$C0,$BD,$AF,$BD,$C0,$BD; $BC5D: 8D BD 9E BD 8D BD 9E BD AF BD C0 BD AF BD C0 BD
  .byte $D1,$BD,$E2,$BD,$D1,$BD,$E2,$BD,$F3,$BD,$04,$BE,$F3,$BD,$04,$BE; $BC6D: D1 BD E2 BD D1 BD E2 BD F3 BD 04 BE F3 BD 04 BE
  .byte $00,$40,$00,$F8,$00,$41,$00,$00,$08,$50,$00; $BC7D: 00 40 00 F8 00 41 00 00 08 50 00
Loc_BC88:
; --- Code Region ---
  SED                                     ; $BC88: F8
  PHP                                     ; $BC89: 08
  EOR ($00),Y                             ; $BC8A: 51 00
  BRK                                     ; $BC8C: 00
Loc_BC8D:  ; (dispatch callback target)
; --- Data Region ---
  .byte $80,$00,$60                       ; $BC8D: 80 00 60
  .byte $00,$F8,$00,$61,$00,$00,$08,$70,$00; $BC90: 00 F8 00 61 00 00 08 70 00
Loc_BC99:
  .byte $F8,$08,$71,$00,$00,$80,$00,$40   ; $BC99: F8 08 71 00 00 80 00 40
  .byte $00,$F8,$00,$41,$00,$00,$08,$50,$00; $BCA1: 00 F8 00 41 00 00 08 50 00
Loc_BCAA:
  .byte $F8,$08,$51,$00,$00,$80,$00,$60   ; $BCAA: F8 08 51 00 00 80 00 60
  .byte $00,$F8,$00,$61,$00,$00,$08,$70,$00; $BCB2: 00 F8 00 61 00 00 08 70 00
Loc_BCBB:
  .byte $F8,$08,$71,$00,$00,$80,$00,$08,$00,$F8,$00,$09,$00,$00,$08,$18; $BCBB: F8 08 71 00 00 80 00 08 00 F8 00 09 00 00 08 18
  .byte $00,$F8,$08,$19,$00,$00,$80,$00,$08,$00,$F8,$00,$09,$00,$00,$08; $BCCB: 00 F8 08 19 00 00 80 00 08 00 F8 00 09 00 00 08
  .byte $38,$00,$F8,$08,$39,$00,$00,$80,$00,$0C,$00,$F8,$00,$0D,$00,$00; $BCDB: 38 00 F8 08 39 00 00 80 00 0C 00 F8 00 0D 00 00
  .byte $08,$1C,$00,$F8,$08,$1D,$00,$00,$80,$00,$2C,$00,$F8,$00,$2D,$00; $BCEB: 08 1C 00 F8 08 1D 00 00 80 00 2C 00 F8 00 2D 00
  .byte $00,$08,$3C,$00,$F8,$08,$3D,$00,$00,$80,$00,$42,$00,$F8,$00,$43; $BCFB: 00 08 3C 00 F8 08 3D 00 00 80 00 42 00 F8 00 43
  .byte $00,$00,$08,$52,$00,$F8,$08,$53,$00,$00,$80,$00,$62,$00,$F8,$00; $BD0B: 00 00 08 52 00 F8 08 53 00 00 80 00 62 00 F8 00
  .byte $63,$00,$00,$08,$72,$00,$F8,$08,$73,$00,$00,$80,$00,$42,$00,$F8; $BD1B: 63 00 00 08 72 00 F8 08 73 00 00 80 00 42 00 F8
  .byte $00,$43,$00,$00,$08,$52,$00,$F8,$08,$53,$00,$00,$80,$00,$62,$00; $BD2B: 00 43 00 00 08 52 00 F8 08 53 00 00 80 00 62 00
  .byte $F8,$00,$63,$00,$00,$08,$72,$00,$F8,$08,$73,$00,$00,$80,$00,$0A; $BD3B: F8 00 63 00 00 08 72 00 F8 08 73 00 00 80 00 0A
  .byte $00,$F8,$00,$0B,$00,$00,$08,$1A,$00,$F8,$08,$1B,$00,$00,$80,$00; $BD4B: 00 F8 00 0B 00 00 08 1A 00 F8 08 1B 00 00 80 00
  .byte $0A,$00,$F8,$00,$0B,$00,$00,$08,$3A,$00,$F8,$08,$3B,$00,$00,$80; $BD5B: 0A 00 F8 00 0B 00 00 08 3A 00 F8 08 3B 00 00 80
  .byte $00,$0E,$00,$F8,$00,$0F,$00,$00,$08,$1E,$00,$F8,$08,$1F,$00,$00; $BD6B: 00 0E 00 F8 00 0F 00 00 08 1E 00 F8 08 1F 00 00
  .byte $80,$00,$2E,$00,$F8,$00,$2F,$00,$00,$08,$3E,$00,$F8,$08,$3F,$00; $BD7B: 80 00 2E 00 F8 00 2F 00 00 08 3E 00 F8 08 3F 00
  .byte $00,$80,$00,$06,$00,$F8,$00,$07,$00,$00,$08,$14,$00,$F8,$08,$15; $BD8B: 00 80 00 06 00 F8 00 07 00 00 08 14 00 F8 08 15
  .byte $00,$00,$80,$00,$26,$00,$F8,$00,$27,$00,$00,$08,$34,$00,$F8,$08; $BD9B: 00 00 80 00 26 00 F8 00 27 00 00 08 34 00 F8 08
  .byte $35,$00,$00,$80,$00,$04,$00,$F8,$00,$05,$00,$00,$08,$14,$00,$F8; $BDAB: 35 00 00 80 00 04 00 F8 00 05 00 00 08 14 00 F8
  .byte $08,$15,$00,$00,$80,$00,$24,$00,$F8,$00,$05,$00,$00,$08,$34,$00; $BDBB: 08 15 00 00 80 00 24 00 F8 00 05 00 00 08 34 00
  .byte $F8,$08,$35,$00,$00,$80,$00,$00,$00,$F8,$00,$01,$00,$00,$08,$10; $BDCB: F8 08 35 00 00 80 00 00 00 F8 00 01 00 00 08 10
  .byte $00                               ; $BDDB: 00
Loc_BDDC:
  .byte $F8,$08,$11,$00,$00,$80,$00,$20,$00,$F8,$00,$21,$00,$00,$08,$30; $BDDC: F8 08 11 00 00 80 00 20 00 F8 00 21 00 00 08 30
  .byte $00                               ; $BDEC: 00
Loc_BDED:
  .byte $F8,$08,$31,$00,$00,$80,$00,$02,$00,$F8,$00,$03,$00,$00,$08,$12; $BDED: F8 08 31 00 00 80 00 02 00 F8 00 03 00 00 08 12
  .byte $00,$F8,$08,$13,$00,$00,$80,$00,$22,$00,$F8,$00,$23,$00,$00,$08; $BDFD: 00 F8 08 13 00 00 80 00 22 00 F8 00 23 00 00 08
  .byte $32,$00,$F8,$08,$33,$00,$00,$80,$AC,$45,$05,$B9,$80,$05,$0A,$0A; $BE0D: 32 00 F8 08 33 00 00 80 AC 45 05 B9 80 05 0A 0A
  .byte $0A,$0A,$8D,$0C,$00,$B9,$96,$05,$0A,$0A,$0A,$0A,$8D,$0A,$00,$A9; $BE1D: 0A 0A 8D 0C 00 B9 96 05 0A 0A 0A 0A 8D 0A 00 A9
  .byte $65,$8D,$00,$00,$A9,$BE,$8D,$01,$00,$AC,$49,$05,$AD,$0C,$00,$18; $BE2D: 65 8D 00 00 A9 BE 8D 01 00 AC 49 05 AD 0C 00 18
  .byte $79,$5D,$BE,$8D,$0C,$00,$AD,$0A,$00,$18,$79,$61,$BE,$8D,$0A,$00; $BE3D: 79 5D BE 8D 0C 00 AD 0A 00 18 79 61 BE 8D 0A 00
  .byte $A9,$00,$8D,$0B,$00,$8D,$0D,$00,$A9,$00,$8D,$02,$00,$4C,$92,$F0; $BE4D: A9 00 8D 0B 00 8D 0D 00 A9 00 8D 02 00 4C 92 F0
  .byte $00,$00,$F8,$08,$F8,$08,$00,$00,$00,$86,$02,$00,$00,$87,$02,$08; $BE5D: 00 00 F8 08 F8 08 00 00 00 86 02 00 00 87 02 08
  .byte $08,$96,$02,$00,$08,$97,$02,$08,$80; $BE6D: 08 96 02 00 08 97 02 08 80
Loc_BE76:
; --- Code Region ---
  LDA $0545                               ; $BE76: AD 45 05
  CMP #$0B                                ; $BE79: C9 0B
  BCC $BE8D                               ; $BE7B: 90 10
  LDA $0577                               ; $BE7D: AD 77 05
  AND #$F0                                ; $BE80: 29 F0
  BEQ $BE9D                               ; $BE82: F0 19
  LDA $0549                               ; $BE84: AD 49 05
  CLC                                     ; $BE87: 18
  ADC #$04                                ; $BE88: 69 04
  JMP $BEA0                               ; $BE8A: 4C A0 BE
Loc_BE8D:
  LDA $0577                               ; $BE8D: AD 77 05
  AND #$0F                                ; $BE90: 29 0F
  BEQ $BE9D                               ; $BE92: F0 09
  LDA $0549                               ; $BE94: AD 49 05
  CLC                                     ; $BE97: 18
  ADC #$04                                ; $BE98: 69 04
  JMP $BEA0                               ; $BE9A: 4C A0 BE
Loc_BE9D:
  LDA $0549                               ; $BE9D: AD 49 05
Loc_BEA0:
  ASL                                     ; $BEA0: 0A
  TAY                                     ; $BEA1: A8
  LDA $BEDD,Y                             ; $BEA2: B9 DD BE
  STA a:$0000                             ; $BEA5: 8D 00 00
  LDA $BEDE,Y                             ; $BEA8: B9 DE BE
  STA a:$0001                             ; $BEAB: 8D 01 00
  LDY $0549                               ; $BEAE: AC 49 05
  LDA $054A                               ; $BEB1: AD 4A 05
  CLC                                     ; $BEB4: 18
  ADC $BED5,Y                             ; $BEB5: 79 D5 BE
  STA a:$000C                             ; $BEB8: 8D 0C 00
  LDA $054B                               ; $BEBB: AD 4B 05
  CLC                                     ; $BEBE: 18
  ADC $BED9,Y                             ; $BEBF: 79 D9 BE
  STA a:$000A                             ; $BEC2: 8D 0A 00
  LDA #$00                                ; $BEC5: A9 00
  STA a:$000B                             ; $BEC7: 8D 0B 00
  STA a:$000D                             ; $BECA: 8D 0D 00
  LDA #$00                                ; $BECD: A9 00
  STA a:$0002                             ; $BECF: 8D 02 00
  JMP $F092                               ; $BED2: 4C 92 F0
; --- Data Region ---
  .byte $00,$00,$F8,$08,$F8,$08,$00,$00,$ED,$BE,$F2,$BE,$F7,$BE,$FC,$BE; $BED5: 00 00 F8 08 F8 08 00 00 ED BE F2 BE F7 BE FC BE
  .byte $01,$BF,$06,$BF,$0B,$BF,$10,$BF,$04,$84,$02,$04,$80,$04,$94,$02; $BEE5: 01 BF 06 BF 0B BF 10 BF 04 84 02 04 80 04 94 02
  .byte $04,$80,$04,$A4,$42,$04,$80,$04,$A4,$02,$04,$80,$04,$85,$02,$04; $BEF5: 04 80 04 A4 42 04 80 04 A4 02 04 80 04 85 02 04
  .byte $80,$04,$95,$02,$04,$80,$04,$A5,$42,$04,$80,$04,$A5,$02,$04,$80; $BF05: 80 04 95 02 04 80 04 A5 42 04 80 04 A5 02 04 80
Loc_BF15:
; --- Code Region ---
  LDA #$3B                                ; $BF15: A9 3B
  STA a:$0000                             ; $BF17: 8D 00 00
  LDA #$BF                                ; $BF1A: A9 BF
  STA a:$0001                             ; $BF1C: 8D 01 00
  LDA $054A                               ; $BF1F: AD 4A 05
  STA a:$000C                             ; $BF22: 8D 0C 00
  LDA $054B                               ; $BF25: AD 4B 05
  STA a:$000A                             ; $BF28: 8D 0A 00
  LDA #$00                                ; $BF2B: A9 00
  STA a:$000B                             ; $BF2D: 8D 0B 00
  STA a:$000D                             ; $BF30: 8D 0D 00
  LDA #$00                                ; $BF33: A9 00
  STA a:$0002                             ; $BF35: 8D 02 00
  JMP $F092                               ; $BF38: 4C 92 F0
; --- Data Region ---
  .byte $00,$86,$02,$00,$00,$87,$02,$08,$08,$96,$02,$00,$08,$97,$02,$08; $BF3B: 00 86 02 00 00 87 02 08 08 96 02 00 08 97 02 08
  .byte $80                               ; $BF4B: 80
;===============================================================================
; $BF4C: BattleSideStatusCounterDraw
; Redraws the four packed per-side status counter bytes $0574-$0577 (two
; one-digit counters per byte). For each counter, the high nibble is drawn
; in row X=$80 and the low nibble in row X=$70; the per-counter PPU stream
; pointer comes from the $BFCF table (Y = counter index * 2) and the digit
; tile base is $D0. Submission goes through $F092 with $00B7=$91. Zero
; nibbles are skipped. Called every frame by Phase1NextActorSubDispatch.
;===============================================================================
.proc BattleSideStatusCounterDraw
  LDY #$00                                ; $BF4C: A0 00 ; counter 0 ($0574)
  LDA $0574                               ; $BF4E: AD 74 05
  LDX #$80                                ; $BF51: A2 80
  JSR @DrawHighNibble                     ; $BF53: 20 9D BF
  LDY #$00                                ; $BF56: A0 00
  LDA $0574                               ; $BF58: AD 74 05
  LDX #$70                                ; $BF5B: A2 70
  JSR @DrawLowNibble                      ; $BF5D: 20 A1 BF
  LDY #$02                                ; $BF60: A0 02 ; counter 1 ($0575)
  LDA $0575                               ; $BF62: AD 75 05
  LDX #$80                                ; $BF65: A2 80
  JSR @DrawHighNibble                     ; $BF67: 20 9D BF
  LDY #$02                                ; $BF6A: A0 02
  LDA $0575                               ; $BF6C: AD 75 05
  LDX #$70                                ; $BF6F: A2 70
  JSR @DrawLowNibble                      ; $BF71: 20 A1 BF
  LDY #$04                                ; $BF74: A0 04 ; counter 2 ($0576)
  LDA $0576                               ; $BF76: AD 76 05
  LDX #$80                                ; $BF79: A2 80
  JSR @DrawHighNibble                     ; $BF7B: 20 9D BF
  LDY #$04                                ; $BF7E: A0 04
  LDA $0576                               ; $BF80: AD 76 05
  LDX #$70                                ; $BF83: A2 70
  JSR @DrawLowNibble                      ; $BF85: 20 A1 BF
  LDY #$06                                ; $BF88: A0 06 ; counter 3 ($0577)
  LDA $0577                               ; $BF8A: AD 77 05
  LDX #$80                                ; $BF8D: A2 80
  JSR @DrawHighNibble                     ; $BF8F: 20 9D BF
  LDY #$06                                ; $BF92: A0 06
  LDA $0577                               ; $BF94: AD 77 05
  LDX #$70                                ; $BF97: A2 70
  JSR @DrawLowNibble                      ; $BF99: 20 A1 BF
  RTS                                     ; $BF9C: 60
@DrawHighNibble:
  LSR                                     ; $BF9D: 4A ; nibble -> bits 0-3
  LSR                                     ; $BF9E: 4A
  LSR                                     ; $BF9F: 4A
  LSR                                     ; $BFA0: 4A
@DrawLowNibble:
  AND #$0F                                ; $BFA1: 29 0F
  BEQ @Done                               ; $BFA3: F0 29 ; zero: nothing to draw
  STX a:$000C                             ; $BFA5: 8E 0C 00 ; row parameter
  LDA $BFCF,Y                             ; $BFA8: B9 CF BF ; PPU stream ptr lo
  STA a:$0000                             ; $BFAB: 8D 00 00
  LDA $BFD0,Y                             ; $BFAE: B9 D0 BF ; PPU stream ptr hi
  STA a:$0001                             ; $BFB1: 8D 01 00
  LDA #$D0                                ; $BFB4: A9 D0
  STA a:$000A                             ; $BFB6: 8D 0A 00 ; digit tile base
  LDA #$00                                ; $BFB9: A9 00
  STA a:$000B                             ; $BFBB: 8D 0B 00
  STA a:$000D                             ; $BFBE: 8D 0D 00
  LDA #$00                                ; $BFC1: A9 00
  STA a:$0002                             ; $BFC3: 8D 02 00
  JSR $F092                               ; $BFC6: 20 92 F0 ; submit PPU update
  LDA #$91                                ; $BFC9: A9 91
  STA a:$00B7                             ; $BFCB: 8D B7 00
@Done:
  RTS                                     ; $BFCE: 60
.endproc
; --- Per-counter PPU stream pointers, indexed Y = counter * 2 ($BF4C) ---
  .byte $D7,$BF,$E8,$BF,$F9,$BF,$0A,$C0,$00,$69,$00,$00,$00,$6A,$00,$08; $BFCF: D7 BF E8 BF F9 BF 0A C0 00 69 00 00 00 6A 00 08
  .byte $08,$79,$00,$00,$08,$7A,$00,$08,$80,$00,$70,$00; $BFDF: 08 79 00 00 08 7A 00 08 80 00 70 00
Loc_BFEB:
  .byte $00,$00,$71,$00,$08,$08,$72,$00,$00,$08,$73,$00,$08,$80,$00,$6B; $BFEB: 00 00 71 00 08 08 72 00 00 08 73 00 08 80 00 6B
  .byte $00,$00,$00,$6C,$00               ; $BFFB: 00 00 00 6C 00

.segment "CODE_BANK0F"

  .byte $08                               ; $C000: 08
  .byte $08,$7B,$00,$00,$08,$7C,$00,$08,$80,$00,$6D,$02,$00,$00,$6E,$02; $C001: 08 7B 00 00 08 7C 00 08 80 00 6D 02 00 00 6E 02
  .byte $08,$08,$7D,$02,$00,$08,$7E,$02,$08,$80; $C011: 08 08 7D 02 00 08 7E 02 08 80
;===============================================================================
; $C01B: BattleChrBankAnimate
; Animates the battle CHR banks once per VBlank. Row index = bits 3-4 of the
; frame tick counter $005E (advances every 8 frames); battle scene phase 3
; ($0544) selects the second half of the table. Writes the chosen pair of CHR
; bank numbers to all five shadow copies of CHR bank 5 ($00B3/$00C3/$00CB/
; $00D3/$00DB) and CHR bank 7 ($00B5/$00C5/$00CD/$00D5/$00DD); the primary
; copies at $00AE-$00B5 are pushed to the Namco-163 by B1F ChrBankSwitch.
; Called only from BattleVBlankFrameUpdate.
;===============================================================================
.proc BattleChrBankAnimate
frame_tick     = $005E  ; frame tick counter (incremented by NmiEpilogue)
battle_phase   = $0544  ; battle scene phase

  LDA a:frame_tick                        ; $C01B: AD 5E 00
  LSR                                     ; $C01E: 4A
  LSR                                     ; $C01F: 4A
  LSR                                     ; $C020: 4A
  AND #$03                                ; $C021: 29 03
  TAY                                     ; $C023: A8
  LDA battle_phase                        ; $C024: AD 44 05
  CMP #$03                                ; $C027: C9 03
  BNE @select                             ; $C029: D0 04
  INY                                     ; $C02B: C8
  INY                                     ; $C02C: C8
  INY                                     ; $C02D: C8
  INY                                     ; $C02E: C8
@select:
  LDA BattleChrBankAnimTable,Y            ; $C02F: B9 54 C0
  STA a:$00B3                             ; $C032: 8D B3 00
  STA a:$00C3                             ; $C035: 8D C3 00
  STA a:$00CB                             ; $C038: 8D CB 00
  STA a:$00D3                             ; $C03B: 8D D3 00
  STA a:$00DB                             ; $C03E: 8D DB 00
  LDA BattleChrBankAnimTable+8,Y          ; $C041: B9 5C C0
  STA a:$00B5                             ; $C044: 8D B5 00
  STA a:$00C5                             ; $C047: 8D C5 00
  STA a:$00CD                             ; $C04A: 8D CD 00
  STA a:$00D5                             ; $C04D: 8D D5 00
  STA a:$00DD                             ; $C050: 8D DD 00
  RTS                                     ; $C053: 60
; CHR bank pairs per animation row: [bank for CHR slot 5] then [CHR slot 7]
BattleChrBankAnimTable:
  .byte $78,$79,$78,$79,$7A,$7B,$7A,$7B,$18,$19,$18,$19,$18,$19,$18,$19; $C054: 78 79 78 79 7A 7B 7A 7B 18 19 18 19 18 19 18 19
.endproc
Loc_C064:
; --- Code Region ---
  LDA #$00                                ; $C064: A9 00
  STA a:$0012                             ; $C066: 8D 12 00
  LDA $054F                               ; $C069: AD 4F 05
  CMP #$01                                ; $C06C: C9 01
  BEQ $C095                               ; $C06E: F0 25
  LDA $0545                               ; $C070: AD 45 05
  CMP #$0B                                ; $C073: C9 0B
  BCS $C086                               ; $C075: B0 0F
  LDA $058B                               ; $C077: AD 8B 05
  STA a:$0010                             ; $C07A: 8D 10 00
  LDA $05A1                               ; $C07D: AD A1 05
  STA a:$0011                             ; $C080: 8D 11 00
  JMP $C0B8                               ; $C083: 4C B8 C0
Loc_C086:
  LDA $0580                               ; $C086: AD 80 05
  STA a:$0010                             ; $C089: 8D 10 00
  LDA $0596                               ; $C08C: AD 96 05
  STA a:$0011                             ; $C08F: 8D 11 00
  JMP $C0B8                               ; $C092: 4C B8 C0
Loc_C095:
  LDA $0545                               ; $C095: AD 45 05
  CMP #$0B                                ; $C098: C9 0B
  BCS $C0AA                               ; $C09A: B0 0E
  LDA #$FF                                ; $C09C: A9 FF
  STA a:$0010                             ; $C09E: 8D 10 00
  LDA $05A1                               ; $C0A1: AD A1 05
  STA a:$0011                             ; $C0A4: 8D 11 00
  JMP $C0B8                               ; $C0A7: 4C B8 C0
Loc_C0AA:
  LDA #$20                                ; $C0AA: A9 20
  STA a:$0010                             ; $C0AC: 8D 10 00
  LDA $0596                               ; $C0AF: AD 96 05
  STA a:$0011                             ; $C0B2: 8D 11 00
  JMP $C0B8                               ; $C0B5: 4C B8 C0
Loc_C0B8:
  LDA $0580,Y                             ; $C0B8: B9 80 05
  SEC                                     ; $C0BB: 38
  SBC a:$0010                             ; $C0BC: ED 10 00
  STA a:$0010                             ; $C0BF: 8D 10 00
  BCS $C0C9                               ; $C0C2: B0 05
  EOR #$FF                                ; $C0C4: 49 FF
  CLC                                     ; $C0C6: 18
  ADC #$01                                ; $C0C7: 69 01
Loc_C0C9:
  STA a:$0000                             ; $C0C9: 8D 00 00
  LDA $0596,Y                             ; $C0CC: B9 96 05
  SEC                                     ; $C0CF: 38
  SBC a:$0011                             ; $C0D0: ED 11 00
  STA a:$0011                             ; $C0D3: 8D 11 00
  BCS $C0DD                               ; $C0D6: B0 05
  EOR #$FF                                ; $C0D8: 49 FF
  CLC                                     ; $C0DA: 18
  ADC #$01                                ; $C0DB: 69 01
Loc_C0DD:
  STA a:$0001                             ; $C0DD: 8D 01 00
  LDA $05C2,Y                             ; $C0E0: B9 C2 05
  AND #$0F                                ; $C0E3: 29 0F
  BEQ $C109                               ; $C0E5: F0 22
  CMP #$03                                ; $C0E7: C9 03
  BEQ $C109                               ; $C0E9: F0 1E
  CMP #$02                                ; $C0EB: C9 02
  BEQ $C0FC                               ; $C0ED: F0 0D
  LDA a:$0000                             ; $C0EF: AD 00 00
  CMP #$02                                ; $C0F2: C9 02
  BCC $C0F9                               ; $C0F4: 90 03
  JMP $C123                               ; $C0F6: 4C 23 C1
Loc_C0F9:
  JMP $C178                               ; $C0F9: 4C 78 C1
Loc_C0FC:
  LDA a:$0001                             ; $C0FC: AD 01 00
  CMP #$02                                ; $C0FF: C9 02
  BCC $C106                               ; $C101: 90 03
  JMP $C178                               ; $C103: 4C 78 C1
Loc_C106:
  JMP $C123                               ; $C106: 4C 23 C1
Loc_C109:
  LDA a:$0001                             ; $C109: AD 01 00
  CMP a:$0000                             ; $C10C: CD 00 00
  BEQ $C116                               ; $C10F: F0 05
  BCC $C120                               ; $C111: 90 0D
  JMP $C178                               ; $C113: 4C 78 C1
Loc_C116:
  JSR $E87A                               ; $C116: 20 7A E8
  AND #$01                                ; $C119: 29 01
  BEQ $C120                               ; $C11B: F0 03
  JMP $C178                               ; $C11D: 4C 78 C1
Loc_C120:
  JMP $C123                               ; $C120: 4C 23 C1
Loc_C123:
  LDA a:$0010                             ; $C123: AD 10 00
  BEQ $C12C                               ; $C126: F0 04
  BMI $C14D                               ; $C128: 30 23
  BPL $C133                               ; $C12A: 10 07
Loc_C12C:
  JSR $E87A                               ; $C12C: 20 7A E8
  AND #$80                                ; $C12F: 29 80
  BNE $C14D                               ; $C131: D0 1A
Loc_C133:
  LDA #$FF                                ; $C133: A9 FF
  STA a:$0000                             ; $C135: 8D 00 00
  LDA #$00                                ; $C138: A9 00
  STA a:$0001                             ; $C13A: 8D 01 00
  JSR $C1CD                               ; $C13D: 20 CD C1
  BCC $C167                               ; $C140: 90 25
  JSR $CAF9                               ; $C142: 20 F9 CA
  BNE $C167                               ; $C145: D0 20
  LDA #$02                                ; $C147: A9 02
  STA $0549                               ; $C149: 8D 49 05
  RTS                                     ; $C14C: 60
Loc_C14D:
  LDA #$01                                ; $C14D: A9 01
  STA a:$0000                             ; $C14F: 8D 00 00
  LDA #$00                                ; $C152: A9 00
  STA a:$0001                             ; $C154: 8D 01 00
  JSR $C1CD                               ; $C157: 20 CD C1
  BCC $C167                               ; $C15A: 90 0B
  JSR $CAF9                               ; $C15C: 20 F9 CA
  BNE $C167                               ; $C15F: D0 06
  LDA #$03                                ; $C161: A9 03
  STA $0549                               ; $C163: 8D 49 05
  RTS                                     ; $C166: 60
Loc_C167:
  LDA a:$0012                             ; $C167: AD 12 00
  BNE $C172                               ; $C16A: D0 06
  INC a:$0012                             ; $C16C: EE 12 00
  JMP $C178                               ; $C16F: 4C 78 C1
Loc_C172:
  LDA #$FF                                ; $C172: A9 FF
  STA $0549                               ; $C174: 8D 49 05
  RTS                                     ; $C177: 60
Loc_C178:
  LDA a:$0011                             ; $C178: AD 11 00
  BEQ $C181                               ; $C17B: F0 04
  BMI $C1A2                               ; $C17D: 30 23
  BPL $C188                               ; $C17F: 10 07
Loc_C181:
  JSR $E87A                               ; $C181: 20 7A E8
  AND #$80                                ; $C184: 29 80
  BNE $C1A2                               ; $C186: D0 1A
Loc_C188:
  LDA #$00                                ; $C188: A9 00
  STA a:$0000                             ; $C18A: 8D 00 00
  LDA #$FF                                ; $C18D: A9 FF
  STA a:$0001                             ; $C18F: 8D 01 00
  JSR $C1CD                               ; $C192: 20 CD C1
  BCC $C1BC                               ; $C195: 90 25
  JSR $CAF9                               ; $C197: 20 F9 CA
  BNE $C1BC                               ; $C19A: D0 20
  LDA #$00                                ; $C19C: A9 00
  STA $0549                               ; $C19E: 8D 49 05
  RTS                                     ; $C1A1: 60
Loc_C1A2:
  LDA #$00                                ; $C1A2: A9 00
  STA a:$0000                             ; $C1A4: 8D 00 00
  LDA #$01                                ; $C1A7: A9 01
  STA a:$0001                             ; $C1A9: 8D 01 00
  JSR $C1CD                               ; $C1AC: 20 CD C1
  BCC $C1BC                               ; $C1AF: 90 0B
  JSR $CAF9                               ; $C1B1: 20 F9 CA
  BNE $C1BC                               ; $C1B4: D0 06
  LDA #$01                                ; $C1B6: A9 01
  STA $0549                               ; $C1B8: 8D 49 05
  RTS                                     ; $C1BB: 60
Loc_C1BC:
  LDA a:$0012                             ; $C1BC: AD 12 00
  BNE $C1C7                               ; $C1BF: D0 06
  INC a:$0012                             ; $C1C1: EE 12 00
  JMP $C123                               ; $C1C4: 4C 23 C1
Loc_C1C7:
  LDA #$FF                                ; $C1C7: A9 FF
  STA $0549                               ; $C1C9: 8D 49 05
  RTS                                     ; $C1CC: 60
Loc_C1CD:
  LDY $0545                               ; $C1CD: AC 45 05
  LDA $0580,Y                             ; $C1D0: B9 80 05
  CLC                                     ; $C1D3: 18
  ADC a:$0000                             ; $C1D4: 6D 00 00
  STA a:$0000                             ; $C1D7: 8D 00 00
  CMP #$10                                ; $C1DA: C9 10
  BCS $C206                               ; $C1DC: B0 28
  LDA $0596,Y                             ; $C1DE: B9 96 05
  CLC                                     ; $C1E1: 18
  ADC a:$0001                             ; $C1E2: 6D 01 00
  STA a:$0001                             ; $C1E5: 8D 01 00
  CMP #$0A                                ; $C1E8: C9 0A
  BCS $C206                               ; $C1EA: B0 1A
  LDX #$15                                ; $C1EC: A2 15
Loc_C1EE:
  LDA $0580,X                             ; $C1EE: BD 80 05
  CMP a:$0000                             ; $C1F1: CD 00 00
  BNE $C20A                               ; $C1F4: D0 14
  LDA $0596,X                             ; $C1F6: BD 96 05
  CMP a:$0001                             ; $C1F9: CD 01 00
  BNE $C20A                               ; $C1FC: D0 0C
  LDA $0545                               ; $C1FE: AD 45 05
  JSR $C827                               ; $C201: 20 27 C8
  CLC                                     ; $C204: 18
  RTS                                     ; $C205: 60
Loc_C206:
  LDA #$00                                ; $C206: A9 00
  CLC                                     ; $C208: 18
  RTS                                     ; $C209: 60
Loc_C20A:
  DEX                                     ; $C20A: CA
  BPL $C1EE                               ; $C20B: 10 E1
  SEC                                     ; $C20D: 38
  RTS                                     ; $C20E: 60
Loc_C20F:
  LDA #$00                                ; $C20F: A9 00
  STA a:$0010                             ; $C211: 8D 10 00
  STA a:$0011                             ; $C214: 8D 11 00
  JSR $E87A                               ; $C217: 20 7A E8
  AND #$01                                ; $C21A: 29 01
  BEQ $C221                               ; $C21C: F0 03
  JMP $C298                               ; $C21E: 4C 98 C2
Loc_C221:
  JSR $E87A                               ; $C221: 20 7A E8
  AND #$80                                ; $C224: 29 80
  BNE $C260                               ; $C226: D0 38
Loc_C228:
  LDA #$FF                                ; $C228: A9 FF
  STA a:$0000                             ; $C22A: 8D 00 00
  LDA #$00                                ; $C22D: A9 00
  STA a:$0001                             ; $C22F: 8D 01 00
  JSR $C1CD                               ; $C232: 20 CD C1
  BCS $C243                               ; $C235: B0 0C
  TAY                                     ; $C237: A8
  BEQ $C243                               ; $C238: F0 09
  STX $054A                               ; $C23A: 8E 4A 05
  LDA #$02                                ; $C23D: A9 02
  STA $0549                               ; $C23F: 8D 49 05
  RTS                                     ; $C242: 60
Loc_C243:
  LDA a:$0010                             ; $C243: AD 10 00
  CMP #$03                                ; $C246: C9 03
  BNE $C250                               ; $C248: D0 06
  LDA #$FF                                ; $C24A: A9 FF
  STA $0549                               ; $C24C: 8D 49 05
  RTS                                     ; $C24F: 60
Loc_C250:
  CMP #$01                                ; $C250: C9 01
  BNE $C25A                               ; $C252: D0 06
  INC a:$0010                             ; $C254: EE 10 00
  JMP $C298                               ; $C257: 4C 98 C2
Loc_C25A:
  INC a:$0010                             ; $C25A: EE 10 00
  JMP $C260                               ; $C25D: 4C 60 C2
Loc_C260:
  LDA #$01                                ; $C260: A9 01
  STA a:$0000                             ; $C262: 8D 00 00
  LDA #$00                                ; $C265: A9 00
  STA a:$0001                             ; $C267: 8D 01 00
  JSR $C1CD                               ; $C26A: 20 CD C1
  BCS $C27B                               ; $C26D: B0 0C
  TAY                                     ; $C26F: A8
  BEQ $C27B                               ; $C270: F0 09
  STX $054A                               ; $C272: 8E 4A 05
  LDA #$03                                ; $C275: A9 03
  STA $0549                               ; $C277: 8D 49 05
  RTS                                     ; $C27A: 60
Loc_C27B:
  LDA a:$0010                             ; $C27B: AD 10 00
  CMP #$03                                ; $C27E: C9 03
  BNE $C288                               ; $C280: D0 06
  LDA #$FF                                ; $C282: A9 FF
  STA $0549                               ; $C284: 8D 49 05
  RTS                                     ; $C287: 60
Loc_C288:
  CMP #$01                                ; $C288: C9 01
  BNE $C292                               ; $C28A: D0 06
  INC a:$0010                             ; $C28C: EE 10 00
  JMP $C298                               ; $C28F: 4C 98 C2
Loc_C292:
  INC a:$0010                             ; $C292: EE 10 00
  JMP $C228                               ; $C295: 4C 28 C2
Loc_C298:
  JSR $E87A                               ; $C298: 20 7A E8
  AND #$80                                ; $C29B: 29 80
  BNE $C2D7                               ; $C29D: D0 38
Loc_C29F:
  LDA #$00                                ; $C29F: A9 00
  STA a:$0000                             ; $C2A1: 8D 00 00
  LDA #$FF                                ; $C2A4: A9 FF
  STA a:$0001                             ; $C2A6: 8D 01 00
  JSR $C1CD                               ; $C2A9: 20 CD C1
  BCS $C2BA                               ; $C2AC: B0 0C
  TAY                                     ; $C2AE: A8
  BEQ $C2BA                               ; $C2AF: F0 09
  STX $054A                               ; $C2B1: 8E 4A 05
  LDA #$00                                ; $C2B4: A9 00
  STA $0549                               ; $C2B6: 8D 49 05
  RTS                                     ; $C2B9: 60
Loc_C2BA:
  LDA a:$0010                             ; $C2BA: AD 10 00
  CMP #$03                                ; $C2BD: C9 03
  BNE $C2C7                               ; $C2BF: D0 06
  LDA #$FF                                ; $C2C1: A9 FF
  STA $0549                               ; $C2C3: 8D 49 05
  RTS                                     ; $C2C6: 60
Loc_C2C7:
  CMP #$01                                ; $C2C7: C9 01
  BNE $C2D1                               ; $C2C9: D0 06
  INC a:$0010                             ; $C2CB: EE 10 00
  JMP $C221                               ; $C2CE: 4C 21 C2
Loc_C2D1:
  INC a:$0010                             ; $C2D1: EE 10 00
  JMP $C2D7                               ; $C2D4: 4C D7 C2
Loc_C2D7:
  LDA #$00                                ; $C2D7: A9 00
  STA a:$0000                             ; $C2D9: 8D 00 00
  LDA #$01                                ; $C2DC: A9 01
  STA a:$0001                             ; $C2DE: 8D 01 00
  JSR $C1CD                               ; $C2E1: 20 CD C1
  BCS $C2F2                               ; $C2E4: B0 0C
  TAY                                     ; $C2E6: A8
  BEQ $C2F2                               ; $C2E7: F0 09
  STX $054A                               ; $C2E9: 8E 4A 05
  LDA #$01                                ; $C2EC: A9 01
  STA $0549                               ; $C2EE: 8D 49 05
  RTS                                     ; $C2F1: 60
Loc_C2F2:
  LDA a:$0010                             ; $C2F2: AD 10 00
  CMP #$03                                ; $C2F5: C9 03
  BNE $C2FF                               ; $C2F7: D0 06
  LDA #$FF                                ; $C2F9: A9 FF
  STA $0549                               ; $C2FB: 8D 49 05
  RTS                                     ; $C2FE: 60
Loc_C2FF:
  CMP #$01                                ; $C2FF: C9 01
  BNE $C309                               ; $C301: D0 06
  INC a:$0010                             ; $C303: EE 10 00
  JMP $C221                               ; $C306: 4C 21 C2
Loc_C309:
  INC a:$0010                             ; $C309: EE 10 00
  JMP $C29F                               ; $C30C: 4C 9F C2
Loc_C30F:
  LDA #$00                                ; $C30F: A9 00
  STA a:$0010                             ; $C311: 8D 10 00
  STA a:$0011                             ; $C314: 8D 11 00
  JSR $E87A                               ; $C317: 20 7A E8
  AND #$01                                ; $C31A: 29 01
  BEQ $C321                               ; $C31C: F0 03
  JMP $C5A4                               ; $C31E: 4C A4 C5
Loc_C321:
  JSR $E87A                               ; $C321: 20 7A E8
  AND #$80                                ; $C324: 29 80
  BNE $C32B                               ; $C326: D0 03
  JMP $C469                               ; $C328: 4C 69 C4
Loc_C32B:
  LDA #$FF                                ; $C32B: A9 FF
  STA a:$0000                             ; $C32D: 8D 00 00
  LDA #$00                                ; $C330: A9 00
  STA a:$0001                             ; $C332: 8D 01 00
  JSR $CAC8                               ; $C335: 20 C8 CA
  TAY                                     ; $C338: A8
  BEQ $C33E                               ; $C339: F0 03
  JMP $C44C                               ; $C33B: 4C 4C C4
Loc_C33E:
  LDA #$FF                                ; $C33E: A9 FF
  STA a:$0000                             ; $C340: 8D 00 00
  LDA #$00                                ; $C343: A9 00
  STA a:$0001                             ; $C345: 8D 01 00
  JSR $C1CD                               ; $C348: 20 CD C1
  BCS $C353                               ; $C34B: B0 06
  TAY                                     ; $C34D: A8
  BEQ $C353                               ; $C34E: F0 03
  JMP $C44C                               ; $C350: 4C 4C C4
Loc_C353:
  LDA #$FE                                ; $C353: A9 FE
  STA a:$0000                             ; $C355: 8D 00 00
  LDA #$00                                ; $C358: A9 00
  STA a:$0001                             ; $C35A: 8D 01 00
  JSR $CAC8                               ; $C35D: 20 C8 CA
  TAY                                     ; $C360: A8
  BEQ $C366                               ; $C361: F0 03
  JMP $C44C                               ; $C363: 4C 4C C4
Loc_C366:
  LDA #$FE                                ; $C366: A9 FE
  STA a:$0000                             ; $C368: 8D 00 00
  LDA #$00                                ; $C36B: A9 00
  STA a:$0001                             ; $C36D: 8D 01 00
  JSR $C1CD                               ; $C370: 20 CD C1
  BCS $C37D                               ; $C373: B0 08
  TAY                                     ; $C375: A8
  BEQ $C37D                               ; $C376: F0 05
  LDA #$1C                                ; $C378: A9 1C
  JMP $C440                               ; $C37A: 4C 40 C4
Loc_C37D:
  LDA #$FD                                ; $C37D: A9 FD
  STA a:$0000                             ; $C37F: 8D 00 00
  LDA #$00                                ; $C382: A9 00
  STA a:$0001                             ; $C384: 8D 01 00
  JSR $CAC8                               ; $C387: 20 C8 CA
  TAY                                     ; $C38A: A8
  BEQ $C390                               ; $C38B: F0 03
  JMP $C44C                               ; $C38D: 4C 4C C4
Loc_C390:
  LDA #$FD                                ; $C390: A9 FD
  STA a:$0000                             ; $C392: 8D 00 00
  LDA #$00                                ; $C395: A9 00
  STA a:$0001                             ; $C397: 8D 01 00
  JSR $C1CD                               ; $C39A: 20 CD C1
  BCS $C3A7                               ; $C39D: B0 08
  TAY                                     ; $C39F: A8
  BEQ $C3A7                               ; $C3A0: F0 05
  LDA #$2C                                ; $C3A2: A9 2C
  JMP $C440                               ; $C3A4: 4C 40 C4
Loc_C3A7:
  LDA #$FC                                ; $C3A7: A9 FC
  STA a:$0000                             ; $C3A9: 8D 00 00
  LDA #$00                                ; $C3AC: A9 00
  STA a:$0001                             ; $C3AE: 8D 01 00
  JSR $CAC8                               ; $C3B1: 20 C8 CA
  TAY                                     ; $C3B4: A8
  BEQ $C3BA                               ; $C3B5: F0 03
  JMP $C44C                               ; $C3B7: 4C 4C C4
Loc_C3BA:
  LDA #$FC                                ; $C3BA: A9 FC
  STA a:$0000                             ; $C3BC: 8D 00 00
  LDA #$00                                ; $C3BF: A9 00
  STA a:$0001                             ; $C3C1: 8D 01 00
  JSR $C1CD                               ; $C3C4: 20 CD C1
  BCS $C3D1                               ; $C3C7: B0 08
  TAY                                     ; $C3C9: A8
  BEQ $C3D1                               ; $C3CA: F0 05
  LDA #$3C                                ; $C3CC: A9 3C
  JMP $C440                               ; $C3CE: 4C 40 C4
Loc_C3D1:
  LDA $0545                               ; $C3D1: AD 45 05
  CMP #$0B                                ; $C3D4: C9 0B
  BCC $C3E2                               ; $C3D6: 90 0A
  LDA $0575                               ; $C3D8: AD 75 05
  AND #$F0                                ; $C3DB: 29 F0
  BNE $C3EC                               ; $C3DD: D0 0D
  JMP $C44C                               ; $C3DF: 4C 4C C4
Loc_C3E2:
  LDA $0575                               ; $C3E2: AD 75 05
  AND #$0F                                ; $C3E5: 29 0F
  BNE $C3EC                               ; $C3E7: D0 03
  JMP $C44C                               ; $C3E9: 4C 4C C4
Loc_C3EC:
  LDA #$FB                                ; $C3EC: A9 FB
  STA a:$0000                             ; $C3EE: 8D 00 00
  LDA #$00                                ; $C3F1: A9 00
  STA a:$0001                             ; $C3F3: 8D 01 00
  JSR $CAC8                               ; $C3F6: 20 C8 CA
  TAY                                     ; $C3F9: A8
  BEQ $C3FF                               ; $C3FA: F0 03
  JMP $C44C                               ; $C3FC: 4C 4C C4
Loc_C3FF:
  LDA #$FB                                ; $C3FF: A9 FB
  STA a:$0000                             ; $C401: 8D 00 00
  LDA #$00                                ; $C404: A9 00
  STA a:$0001                             ; $C406: 8D 01 00
  JSR $C1CD                               ; $C409: 20 CD C1
  BCS $C416                               ; $C40C: B0 08
  TAY                                     ; $C40E: A8
  BEQ $C416                               ; $C40F: F0 05
  LDA #$4C                                ; $C411: A9 4C
  JMP $C440                               ; $C413: 4C 40 C4
Loc_C416:
  LDA #$FA                                ; $C416: A9 FA
  STA a:$0000                             ; $C418: 8D 00 00
  LDA #$00                                ; $C41B: A9 00
  STA a:$0001                             ; $C41D: 8D 01 00
  JSR $CAC8                               ; $C420: 20 C8 CA
  TAY                                     ; $C423: A8
  BEQ $C429                               ; $C424: F0 03
  JMP $C44C                               ; $C426: 4C 4C C4
Loc_C429:
  LDA #$FA                                ; $C429: A9 FA
  STA a:$0000                             ; $C42B: 8D 00 00
  LDA #$00                                ; $C42E: A9 00
  STA a:$0001                             ; $C430: 8D 01 00
  JSR $C1CD                               ; $C433: 20 CD C1
  BCS $C44C                               ; $C436: B0 14
  TAY                                     ; $C438: A8
  BEQ $C44C                               ; $C439: F0 11
  LDA #$5C                                ; $C43B: A9 5C
  JMP $C440                               ; $C43D: 4C 40 C4
Loc_C440:
  STX $054D                               ; $C440: 8E 4D 05
  STA $0548                               ; $C443: 8D 48 05
  LDA #$02                                ; $C446: A9 02
  STA $0549                               ; $C448: 8D 49 05
  RTS                                     ; $C44B: 60
Loc_C44C:
  LDA a:$0010                             ; $C44C: AD 10 00
  CMP #$03                                ; $C44F: C9 03
  BNE $C459                               ; $C451: D0 06
  LDA #$FF                                ; $C453: A9 FF
  STA $0549                               ; $C455: 8D 49 05
  RTS                                     ; $C458: 60
Loc_C459:
  CMP #$01                                ; $C459: C9 01
  BNE $C463                               ; $C45B: D0 06
  INC a:$0010                             ; $C45D: EE 10 00
  JMP $C5A4                               ; $C460: 4C A4 C5
Loc_C463:
  INC a:$0010                             ; $C463: EE 10 00
  JMP $C44C                               ; $C466: 4C 4C C4
Loc_C469:
  LDA #$01                                ; $C469: A9 01
  STA a:$0000                             ; $C46B: 8D 00 00
  LDA #$00                                ; $C46E: A9 00
  STA a:$0001                             ; $C470: 8D 01 00
  JSR $CAC8                               ; $C473: 20 C8 CA
  TAY                                     ; $C476: A8
  BEQ $C47C                               ; $C477: F0 03
  JMP $C587                               ; $C479: 4C 87 C5
Loc_C47C:
  LDA #$01                                ; $C47C: A9 01
  STA a:$0000                             ; $C47E: 8D 00 00
  LDA #$00                                ; $C481: A9 00
  STA a:$0001                             ; $C483: 8D 01 00
  JSR $C1CD                               ; $C486: 20 CD C1
  BCS $C491                               ; $C489: B0 06
  TAY                                     ; $C48B: A8
  BEQ $C491                               ; $C48C: F0 03
  JMP $C587                               ; $C48E: 4C 87 C5
Loc_C491:
  LDA #$02                                ; $C491: A9 02
  STA a:$0000                             ; $C493: 8D 00 00
  LDA #$00                                ; $C496: A9 00
  STA a:$0001                             ; $C498: 8D 01 00
  JSR $CAC8                               ; $C49B: 20 C8 CA
  TAY                                     ; $C49E: A8
  BEQ $C4A4                               ; $C49F: F0 03
  JMP $C587                               ; $C4A1: 4C 87 C5
Loc_C4A4:
  LDA #$02                                ; $C4A4: A9 02
  STA a:$0000                             ; $C4A6: 8D 00 00
  LDA #$00                                ; $C4A9: A9 00
  STA a:$0001                             ; $C4AB: 8D 01 00
  JSR $C1CD                               ; $C4AE: 20 CD C1
  BCS $C4BB                               ; $C4B1: B0 08
  TAY                                     ; $C4B3: A8
  BEQ $C4BB                               ; $C4B4: F0 05
  LDA #$1C                                ; $C4B6: A9 1C
  JMP $C57B                               ; $C4B8: 4C 7B C5
Loc_C4BB:
  LDA #$03                                ; $C4BB: A9 03
  STA a:$0000                             ; $C4BD: 8D 00 00
  LDA #$00                                ; $C4C0: A9 00
  STA a:$0001                             ; $C4C2: 8D 01 00
  JSR $CAC8                               ; $C4C5: 20 C8 CA
  TAY                                     ; $C4C8: A8
  BEQ $C4CE                               ; $C4C9: F0 03
  JMP $C587                               ; $C4CB: 4C 87 C5
Loc_C4CE:
  LDA #$03                                ; $C4CE: A9 03
  STA a:$0000                             ; $C4D0: 8D 00 00
  LDA #$00                                ; $C4D3: A9 00
  STA a:$0001                             ; $C4D5: 8D 01 00
  JSR $C1CD                               ; $C4D8: 20 CD C1
  BCS $C4E5                               ; $C4DB: B0 08
  TAY                                     ; $C4DD: A8
  BEQ $C4E5                               ; $C4DE: F0 05
  LDA #$2C                                ; $C4E0: A9 2C
  JMP $C57B                               ; $C4E2: 4C 7B C5
Loc_C4E5:
  LDA #$04                                ; $C4E5: A9 04
  STA a:$0000                             ; $C4E7: 8D 00 00
  LDA #$00                                ; $C4EA: A9 00
  STA a:$0001                             ; $C4EC: 8D 01 00
  JSR $CAC8                               ; $C4EF: 20 C8 CA
  TAY                                     ; $C4F2: A8
  BEQ $C4F8                               ; $C4F3: F0 03
  JMP $C587                               ; $C4F5: 4C 87 C5
Loc_C4F8:
  LDA #$04                                ; $C4F8: A9 04
  STA a:$0000                             ; $C4FA: 8D 00 00
  LDA #$00                                ; $C4FD: A9 00
  STA a:$0001                             ; $C4FF: 8D 01 00
  JSR $C1CD                               ; $C502: 20 CD C1
  BCS $C50F                               ; $C505: B0 08
  TAY                                     ; $C507: A8
  BEQ $C50F                               ; $C508: F0 05
  LDA #$3C                                ; $C50A: A9 3C
  JMP $C57B                               ; $C50C: 4C 7B C5
Loc_C50F:
  LDA $0545                               ; $C50F: AD 45 05
  CMP #$0B                                ; $C512: C9 0B
  BCC $C520                               ; $C514: 90 0A
  LDA $0575                               ; $C516: AD 75 05
  AND #$F0                                ; $C519: 29 F0
  BNE $C52A                               ; $C51B: D0 0D
  JMP $C587                               ; $C51D: 4C 87 C5
Loc_C520:
  LDA $0575                               ; $C520: AD 75 05
  AND #$0F                                ; $C523: 29 0F
  BNE $C52A                               ; $C525: D0 03
  JMP $C587                               ; $C527: 4C 87 C5
Loc_C52A:
  LDA #$05                                ; $C52A: A9 05
  STA a:$0000                             ; $C52C: 8D 00 00
  LDA #$00                                ; $C52F: A9 00
  STA a:$0001                             ; $C531: 8D 01 00
  JSR $CAC8                               ; $C534: 20 C8 CA
  TAY                                     ; $C537: A8
  BEQ $C53D                               ; $C538: F0 03
  JMP $C587                               ; $C53A: 4C 87 C5
Loc_C53D:
  LDA #$05                                ; $C53D: A9 05
  STA a:$0000                             ; $C53F: 8D 00 00
  LDA #$00                                ; $C542: A9 00
  STA a:$0001                             ; $C544: 8D 01 00
  JSR $C1CD                               ; $C547: 20 CD C1
  BCS $C554                               ; $C54A: B0 08
  TAY                                     ; $C54C: A8
  BEQ $C554                               ; $C54D: F0 05
  LDA #$4C                                ; $C54F: A9 4C
  JMP $C57B                               ; $C551: 4C 7B C5
Loc_C554:
  LDA #$06                                ; $C554: A9 06
  STA a:$0000                             ; $C556: 8D 00 00
  LDA #$00                                ; $C559: A9 00
  STA a:$0001                             ; $C55B: 8D 01 00
  JSR $CAC8                               ; $C55E: 20 C8 CA
  TAY                                     ; $C561: A8
  BEQ $C567                               ; $C562: F0 03
  JMP $C587                               ; $C564: 4C 87 C5
Loc_C567:
  LDA #$06                                ; $C567: A9 06
  STA a:$0000                             ; $C569: 8D 00 00
  LDA #$00                                ; $C56C: A9 00
  STA a:$0001                             ; $C56E: 8D 01 00
  JSR $C1CD                               ; $C571: 20 CD C1
  BCS $C587                               ; $C574: B0 11
  TAY                                     ; $C576: A8
  BEQ $C587                               ; $C577: F0 0E
  LDA #$5C                                ; $C579: A9 5C
Loc_C57B:
  STX $054D                               ; $C57B: 8E 4D 05
  STA $0548                               ; $C57E: 8D 48 05
  LDA #$03                                ; $C581: A9 03
  STA $0549                               ; $C583: 8D 49 05
  RTS                                     ; $C586: 60
Loc_C587:
  LDA a:$0010                             ; $C587: AD 10 00
  CMP #$03                                ; $C58A: C9 03
  BNE $C594                               ; $C58C: D0 06
  LDA #$FF                                ; $C58E: A9 FF
  STA $0549                               ; $C590: 8D 49 05
  RTS                                     ; $C593: 60
Loc_C594:
  CMP #$01                                ; $C594: C9 01
  BNE $C59E                               ; $C596: D0 06
  INC a:$0010                             ; $C598: EE 10 00
  JMP $C5A4                               ; $C59B: 4C A4 C5
Loc_C59E:
  INC a:$0010                             ; $C59E: EE 10 00
  JMP $C32B                               ; $C5A1: 4C 2B C3
Loc_C5A4:
  JSR $E87A                               ; $C5A4: 20 7A E8
  AND #$80                                ; $C5A7: 29 80
  BNE $C5AE                               ; $C5A9: D0 03
  JMP $C6EC                               ; $C5AB: 4C EC C6
Loc_C5AE:
  LDA #$00                                ; $C5AE: A9 00
  STA a:$0000                             ; $C5B0: 8D 00 00
  LDA #$FF                                ; $C5B3: A9 FF
  STA a:$0001                             ; $C5B5: 8D 01 00
  JSR $CAC8                               ; $C5B8: 20 C8 CA
  TAY                                     ; $C5BB: A8
  BEQ $C5C1                               ; $C5BC: F0 03
  JMP $C6CF                               ; $C5BE: 4C CF C6
Loc_C5C1:
  LDA #$00                                ; $C5C1: A9 00
  STA a:$0000                             ; $C5C3: 8D 00 00
  LDA #$FF                                ; $C5C6: A9 FF
  STA a:$0001                             ; $C5C8: 8D 01 00
  JSR $C1CD                               ; $C5CB: 20 CD C1
  BCS $C5D6                               ; $C5CE: B0 06
  TAY                                     ; $C5D0: A8
  BEQ $C5D6                               ; $C5D1: F0 03
  JMP $C6CF                               ; $C5D3: 4C CF C6
Loc_C5D6:
  LDA #$00                                ; $C5D6: A9 00
  STA a:$0000                             ; $C5D8: 8D 00 00
  LDA #$FE                                ; $C5DB: A9 FE
  STA a:$0001                             ; $C5DD: 8D 01 00
  JSR $CAC8                               ; $C5E0: 20 C8 CA
  TAY                                     ; $C5E3: A8
  BEQ $C5E9                               ; $C5E4: F0 03
  JMP $C6CF                               ; $C5E6: 4C CF C6
Loc_C5E9:
  LDA #$00                                ; $C5E9: A9 00
  STA a:$0000                             ; $C5EB: 8D 00 00
  LDA #$FE                                ; $C5EE: A9 FE
  STA a:$0001                             ; $C5F0: 8D 01 00
  JSR $C1CD                               ; $C5F3: 20 CD C1
  BCS $C600                               ; $C5F6: B0 08
  TAY                                     ; $C5F8: A8
  BEQ $C600                               ; $C5F9: F0 05
  LDA #$1C                                ; $C5FB: A9 1C
  JMP $C6C3                               ; $C5FD: 4C C3 C6
Loc_C600:
  LDA #$00                                ; $C600: A9 00
  STA a:$0000                             ; $C602: 8D 00 00
  LDA #$FD                                ; $C605: A9 FD
  STA a:$0001                             ; $C607: 8D 01 00
  JSR $CAC8                               ; $C60A: 20 C8 CA
  TAY                                     ; $C60D: A8
  BEQ $C613                               ; $C60E: F0 03
  JMP $C6CF                               ; $C610: 4C CF C6
Loc_C613:
  LDA #$00                                ; $C613: A9 00
  STA a:$0000                             ; $C615: 8D 00 00
  LDA #$FD                                ; $C618: A9 FD
  STA a:$0001                             ; $C61A: 8D 01 00
  JSR $C1CD                               ; $C61D: 20 CD C1
  BCS $C62A                               ; $C620: B0 08
  TAY                                     ; $C622: A8
  BEQ $C62A                               ; $C623: F0 05
  LDA #$2C                                ; $C625: A9 2C
  JMP $C6C3                               ; $C627: 4C C3 C6
Loc_C62A:
  LDA #$00                                ; $C62A: A9 00
  STA a:$0000                             ; $C62C: 8D 00 00
  LDA #$FC                                ; $C62F: A9 FC
  STA a:$0001                             ; $C631: 8D 01 00
  JSR $CAC8                               ; $C634: 20 C8 CA
  TAY                                     ; $C637: A8
  BEQ $C63D                               ; $C638: F0 03
  JMP $C6CF                               ; $C63A: 4C CF C6
Loc_C63D:
  LDA #$00                                ; $C63D: A9 00
  STA a:$0000                             ; $C63F: 8D 00 00
  LDA #$FC                                ; $C642: A9 FC
  STA a:$0001                             ; $C644: 8D 01 00
  JSR $C1CD                               ; $C647: 20 CD C1
  BCS $C654                               ; $C64A: B0 08
  TAY                                     ; $C64C: A8
  BEQ $C654                               ; $C64D: F0 05
  LDA #$3C                                ; $C64F: A9 3C
  JMP $C6C3                               ; $C651: 4C C3 C6
Loc_C654:
  LDA $0545                               ; $C654: AD 45 05
  CMP #$0B                                ; $C657: C9 0B
  BCC $C665                               ; $C659: 90 0A
  LDA $0575                               ; $C65B: AD 75 05
  AND #$F0                                ; $C65E: 29 F0
  BNE $C66F                               ; $C660: D0 0D
  JMP $C6CF                               ; $C662: 4C CF C6
Loc_C665:
  LDA $0575                               ; $C665: AD 75 05
  AND #$0F                                ; $C668: 29 0F
  BNE $C66F                               ; $C66A: D0 03
  JMP $C6CF                               ; $C66C: 4C CF C6
Loc_C66F:
  LDA #$00                                ; $C66F: A9 00
  STA a:$0000                             ; $C671: 8D 00 00
  LDA #$FB                                ; $C674: A9 FB
  STA a:$0001                             ; $C676: 8D 01 00
  JSR $CAC8                               ; $C679: 20 C8 CA
  TAY                                     ; $C67C: A8
  BEQ $C682                               ; $C67D: F0 03
  JMP $C6CF                               ; $C67F: 4C CF C6
Loc_C682:
  LDA #$00                                ; $C682: A9 00
  STA a:$0000                             ; $C684: 8D 00 00
  LDA #$FB                                ; $C687: A9 FB
  STA a:$0001                             ; $C689: 8D 01 00
  JSR $C1CD                               ; $C68C: 20 CD C1
  BCS $C699                               ; $C68F: B0 08
  TAY                                     ; $C691: A8
  BEQ $C699                               ; $C692: F0 05
  LDA #$4C                                ; $C694: A9 4C
  JMP $C6C3                               ; $C696: 4C C3 C6
Loc_C699:
  LDA #$00                                ; $C699: A9 00
  STA a:$0000                             ; $C69B: 8D 00 00
  LDA #$FA                                ; $C69E: A9 FA
  STA a:$0001                             ; $C6A0: 8D 01 00
  JSR $CAC8                               ; $C6A3: 20 C8 CA
  TAY                                     ; $C6A6: A8
  BEQ $C6AC                               ; $C6A7: F0 03
  JMP $C6CF                               ; $C6A9: 4C CF C6
Loc_C6AC:
  LDA #$00                                ; $C6AC: A9 00
  STA a:$0000                             ; $C6AE: 8D 00 00
  LDA #$FA                                ; $C6B1: A9 FA
  STA a:$0001                             ; $C6B3: 8D 01 00
  JSR $C1CD                               ; $C6B6: 20 CD C1
  BCS $C6CF                               ; $C6B9: B0 14
  TAY                                     ; $C6BB: A8
  BEQ $C6CF                               ; $C6BC: F0 11
  LDA #$5C                                ; $C6BE: A9 5C
  JMP $C6C3                               ; $C6C0: 4C C3 C6
Loc_C6C3:
  STX $054D                               ; $C6C3: 8E 4D 05
  STA $0548                               ; $C6C6: 8D 48 05
  LDA #$00                                ; $C6C9: A9 00
  STA $0549                               ; $C6CB: 8D 49 05
  RTS                                     ; $C6CE: 60
Loc_C6CF:
  LDA a:$0010                             ; $C6CF: AD 10 00
  CMP #$03                                ; $C6D2: C9 03
  BNE $C6DC                               ; $C6D4: D0 06
  LDA #$FF                                ; $C6D6: A9 FF
  STA $0549                               ; $C6D8: 8D 49 05
  RTS                                     ; $C6DB: 60
Loc_C6DC:
  CMP #$01                                ; $C6DC: C9 01
  BNE $C6E6                               ; $C6DE: D0 06
  INC a:$0010                             ; $C6E0: EE 10 00
  JMP $C321                               ; $C6E3: 4C 21 C3
Loc_C6E6:
  INC a:$0010                             ; $C6E6: EE 10 00
  JMP $C6EC                               ; $C6E9: 4C EC C6
Loc_C6EC:
  LDA #$00                                ; $C6EC: A9 00
  STA a:$0000                             ; $C6EE: 8D 00 00
  LDA #$01                                ; $C6F1: A9 01
  STA a:$0001                             ; $C6F3: 8D 01 00
  JSR $CAC8                               ; $C6F6: 20 C8 CA
  TAY                                     ; $C6F9: A8
  BEQ $C6FF                               ; $C6FA: F0 03
  JMP $C80A                               ; $C6FC: 4C 0A C8
Loc_C6FF:
  LDA #$00                                ; $C6FF: A9 00
  STA a:$0000                             ; $C701: 8D 00 00
  LDA #$01                                ; $C704: A9 01
  STA a:$0001                             ; $C706: 8D 01 00
  JSR $C1CD                               ; $C709: 20 CD C1
  BCS $C714                               ; $C70C: B0 06
  TAY                                     ; $C70E: A8
  BEQ $C714                               ; $C70F: F0 03
  JMP $C80A                               ; $C711: 4C 0A C8
Loc_C714:
  LDA #$00                                ; $C714: A9 00
  STA a:$0000                             ; $C716: 8D 00 00
  LDA #$02                                ; $C719: A9 02
  STA a:$0001                             ; $C71B: 8D 01 00
  JSR $CAC8                               ; $C71E: 20 C8 CA
  TAY                                     ; $C721: A8
  BEQ $C727                               ; $C722: F0 03
  JMP $C80A                               ; $C724: 4C 0A C8
Loc_C727:
  LDA #$00                                ; $C727: A9 00
  STA a:$0000                             ; $C729: 8D 00 00
  LDA #$02                                ; $C72C: A9 02
  STA a:$0001                             ; $C72E: 8D 01 00
  JSR $C1CD                               ; $C731: 20 CD C1
  BCS $C73E                               ; $C734: B0 08
  TAY                                     ; $C736: A8
  BEQ $C73E                               ; $C737: F0 05
  LDA #$1C                                ; $C739: A9 1C
  JMP $C7FE                               ; $C73B: 4C FE C7
Loc_C73E:
  LDA #$00                                ; $C73E: A9 00
  STA a:$0000                             ; $C740: 8D 00 00
  LDA #$03                                ; $C743: A9 03
  STA a:$0001                             ; $C745: 8D 01 00
  JSR $CAC8                               ; $C748: 20 C8 CA
  TAY                                     ; $C74B: A8
  BEQ $C751                               ; $C74C: F0 03
  JMP $C80A                               ; $C74E: 4C 0A C8
Loc_C751:
  LDA #$00                                ; $C751: A9 00
  STA a:$0000                             ; $C753: 8D 00 00
  LDA #$03                                ; $C756: A9 03
  STA a:$0001                             ; $C758: 8D 01 00
  JSR $C1CD                               ; $C75B: 20 CD C1
  BCS $C768                               ; $C75E: B0 08
  TAY                                     ; $C760: A8
  BEQ $C768                               ; $C761: F0 05
  LDA #$2C                                ; $C763: A9 2C
  JMP $C7FE                               ; $C765: 4C FE C7
Loc_C768:
  LDA #$00                                ; $C768: A9 00
  STA a:$0000                             ; $C76A: 8D 00 00
  LDA #$04                                ; $C76D: A9 04
  STA a:$0001                             ; $C76F: 8D 01 00
  JSR $CAC8                               ; $C772: 20 C8 CA
  TAY                                     ; $C775: A8
  BEQ $C77B                               ; $C776: F0 03
  JMP $C80A                               ; $C778: 4C 0A C8
Loc_C77B:
  LDA #$00                                ; $C77B: A9 00
  STA a:$0000                             ; $C77D: 8D 00 00
  LDA #$04                                ; $C780: A9 04
  STA a:$0001                             ; $C782: 8D 01 00
  JSR $C1CD                               ; $C785: 20 CD C1
  BCS $C792                               ; $C788: B0 08
  TAY                                     ; $C78A: A8
  BEQ $C792                               ; $C78B: F0 05
  LDA #$3C                                ; $C78D: A9 3C
  JMP $C7FE                               ; $C78F: 4C FE C7
Loc_C792:
  LDA $0545                               ; $C792: AD 45 05
  CMP #$0B                                ; $C795: C9 0B
  BCC $C7A3                               ; $C797: 90 0A
  LDA $0575                               ; $C799: AD 75 05
  AND #$F0                                ; $C79C: 29 F0
  BNE $C7AD                               ; $C79E: D0 0D
  JMP $C80A                               ; $C7A0: 4C 0A C8
Loc_C7A3:
  LDA $0575                               ; $C7A3: AD 75 05
  AND #$0F                                ; $C7A6: 29 0F
  BNE $C7AD                               ; $C7A8: D0 03
  JMP $C80A                               ; $C7AA: 4C 0A C8
Loc_C7AD:
  LDA #$00                                ; $C7AD: A9 00
  STA a:$0000                             ; $C7AF: 8D 00 00
  LDA #$05                                ; $C7B2: A9 05
  STA a:$0001                             ; $C7B4: 8D 01 00
  JSR $CAC8                               ; $C7B7: 20 C8 CA
  TAY                                     ; $C7BA: A8
  BEQ $C7C0                               ; $C7BB: F0 03
  JMP $C80A                               ; $C7BD: 4C 0A C8
Loc_C7C0:
  LDA #$00                                ; $C7C0: A9 00
  STA a:$0000                             ; $C7C2: 8D 00 00
  LDA #$05                                ; $C7C5: A9 05
  STA a:$0001                             ; $C7C7: 8D 01 00
  JSR $C1CD                               ; $C7CA: 20 CD C1
  BCS $C7D7                               ; $C7CD: B0 08
  TAY                                     ; $C7CF: A8
  BEQ $C7D7                               ; $C7D0: F0 05
  LDA #$4C                                ; $C7D2: A9 4C
  JMP $C7FE                               ; $C7D4: 4C FE C7
Loc_C7D7:
  LDA #$00                                ; $C7D7: A9 00
  STA a:$0000                             ; $C7D9: 8D 00 00
  LDA #$06                                ; $C7DC: A9 06
  STA a:$0001                             ; $C7DE: 8D 01 00
  JSR $CAC8                               ; $C7E1: 20 C8 CA
  TAY                                     ; $C7E4: A8
  BEQ $C7EA                               ; $C7E5: F0 03
  JMP $C80A                               ; $C7E7: 4C 0A C8
Loc_C7EA:
  LDA #$00                                ; $C7EA: A9 00
  STA a:$0000                             ; $C7EC: 8D 00 00
  LDA #$06                                ; $C7EF: A9 06
  STA a:$0001                             ; $C7F1: 8D 01 00
  JSR $C1CD                               ; $C7F4: 20 CD C1
  BCS $C80A                               ; $C7F7: B0 11
  TAY                                     ; $C7F9: A8
  BEQ $C80A                               ; $C7FA: F0 0E
  LDA #$5C                                ; $C7FC: A9 5C
Loc_C7FE:
  STX $054D                               ; $C7FE: 8E 4D 05
  STA $0548                               ; $C801: 8D 48 05
  LDA #$01                                ; $C804: A9 01
  STA $0549                               ; $C806: 8D 49 05
  RTS                                     ; $C809: 60
Loc_C80A:
  LDA a:$0010                             ; $C80A: AD 10 00
  CMP #$03                                ; $C80D: C9 03
  BNE $C817                               ; $C80F: D0 06
  LDA #$FF                                ; $C811: A9 FF
  STA $0549                               ; $C813: 8D 49 05
  RTS                                     ; $C816: 60
Loc_C817:
  CMP #$01                                ; $C817: C9 01
  BNE $C821                               ; $C819: D0 06
  INC a:$0010                             ; $C81B: EE 10 00
  JMP $C321                               ; $C81E: 4C 21 C3
Loc_C821:
  INC a:$0010                             ; $C821: EE 10 00
  JMP $C5AE                               ; $C824: 4C AE C5
Loc_C827:
  CPX #$0B                                ; $C827: E0 0B
  BCS $C832                               ; $C829: B0 07
  CMP #$0B                                ; $C82B: C9 0B
  BCS $C836                               ; $C82D: B0 07
Loc_C82F:
  LDA #$00                                ; $C82F: A9 00
  RTS                                     ; $C831: 60
Loc_C832:
  CMP #$0B                                ; $C832: C9 0B
  BCS $C82F                               ; $C834: B0 F9
Loc_C836:
  LDA #$01                                ; $C836: A9 01
  RTS                                     ; $C838: 60
Loc_C839:
  LDA a:$0000                             ; $C839: AD 00 00
  ASL                                     ; $C83C: 0A
  ASL                                     ; $C83D: 0A
  TAY                                     ; $C83E: A8
  LDA $C8BC,Y                             ; $C83F: B9 BC C8
  STA $0381                               ; $C842: 8D 81 03
  LDA $C8BB,Y                             ; $C845: B9 BB C8
  STA $0382                               ; $C848: 8D 82 03
  LDA $C8BE,Y                             ; $C84B: B9 BE C8
  STA $0389                               ; $C84E: 8D 89 03
  LDA $C8BD,Y                             ; $C851: B9 BD C8
  STA $038A                               ; $C854: 8D 8A 03
  LDA a:$0001                             ; $C857: AD 01 00
  ASL                                     ; $C85A: 0A
  ASL                                     ; $C85B: 0A
  CLC                                     ; $C85C: 18
  ADC a:$0001                             ; $C85D: 6D 01 00
  ASL                                     ; $C860: 0A
  TAY                                     ; $C861: A8
  LDA $C8CB,Y                             ; $C862: B9 CB C8
  STA $0383                               ; $C865: 8D 83 03
  LDA $C8CC,Y                             ; $C868: B9 CC C8
  STA $0384                               ; $C86B: 8D 84 03
  LDA $C8CD,Y                             ; $C86E: B9 CD C8
  STA $0385                               ; $C871: 8D 85 03
  LDA $C8CE,Y                             ; $C874: B9 CE C8
  STA $0386                               ; $C877: 8D 86 03
  LDA $C8CF,Y                             ; $C87A: B9 CF C8
  STA $0387                               ; $C87D: 8D 87 03
  LDA $C8D0,Y                             ; $C880: B9 D0 C8
  STA $038B                               ; $C883: 8D 8B 03
  LDA $C8D1,Y                             ; $C886: B9 D1 C8
  STA $038C                               ; $C889: 8D 8C 03
  LDA $C8D2,Y                             ; $C88C: B9 D2 C8
  STA $038D                               ; $C88F: 8D 8D 03
  LDA $C8D3,Y                             ; $C892: B9 D3 C8
  STA $038E                               ; $C895: 8D 8E 03
  LDA $C8D4,Y                             ; $C898: B9 D4 C8
  STA $038F                               ; $C89B: 8D 8F 03
  LDA #$05                                ; $C89E: A9 05
  STA $0380                               ; $C8A0: 8D 80 03
  LDA #$05                                ; $C8A3: A9 05
  STA $0388                               ; $C8A5: 8D 88 03
  LDA #$FF                                ; $C8A8: A9 FF
  STA $0390                               ; $C8AA: 8D 90 03
  LDA a:$007E                             ; $C8AD: AD 7E 00
  ORA #$04                                ; $C8B0: 09 04
  STA a:$007E                             ; $C8B2: 8D 7E 00
  LDA #$77                                ; $C8B5: A9 77
  STA a:$00BB                             ; $C8B7: 8D BB 00
  RTS                                     ; $C8BA: 60
; --- Data Region ---
  .byte $94,$22,$B4,$22,$D4,$22,$F4,$22,$14,$23,$34,$23,$54,$23,$74,$23; $C8BB: 94 22 B4 22 D4 22 F4 22 14 23 34 23 54 23 74 23
  .byte $40,$41,$42,$43,$01,$50,$51,$52   ; $C8CB: 40 41 42 43 01 50 51 52
Loc_C8D3:
  .byte $53,$01,$60                       ; $C8D3: 53 01 60
  .byte $61,$62,$63,$01,$70,$71,$72,$73,$01,$64,$65,$66,$67,$01,$74,$75; $C8D6: 61 62 63 01 70 71 72 73 01 64 65 66 67 01 74 75
  .byte $68,$69,$01,$48,$49,$4A,$4B,$01,$58,$59,$5A,$5B,$01,$44,$45,$46; $C8E6: 68 69 01 48 49 4A 4B 01 58 59 5A 5B 01 44 45 46
  .byte $47,$01,$54,$55,$56,$57,$01       ; $C8F6: 47 01 54 55 56 57 01
Loc_C8FD:
; --- Code Region ---
  LDA a:$005E                             ; $C8FD: AD 5E 00
  AND #$10                                ; $C900: 29 10
  BNE $C920                               ; $C902: D0 1C
  LDA #$D8                                ; $C904: A9 D8
  STA a:$000A                             ; $C906: 8D 0A 00
  LDA #$A0                                ; $C909: A9 A0
  STA a:$000C                             ; $C90B: 8D 0C 00
  LDA #$21                                ; $C90E: A9 21
  STA a:$0000                             ; $C910: 8D 00 00
  LDA #$C9                                ; $C913: A9 C9
  STA a:$0001                             ; $C915: 8D 01 00
  LDA #$00                                ; $C918: A9 00
  STA a:$0002                             ; $C91A: 8D 02 00
  JMP $F1AD                               ; $C91D: 4C AD F1
; --- Data Region ---
  .byte $60,$00,$04                       ; $C920: 60 00 04
Loc_C923:
  .byte $00,$00,$80,$AD,$60,$05,$20,$D7,$F2,$20,$91,$C9,$8D,$6A,$05,$8D; $C923: 00 00 80 AD 60 05 20 D7 F2 20 91 C9 8D 6A 05 8D
  .byte $C1,$04,$8C,$70,$05,$8E,$6E,$05,$AD,$60,$05,$20,$D7,$F2,$A0,$02; $C933: C1 04 8C 70 05 8E 6E 05 AD 60 05 20 D7 F2 A0 02
  .byte $B1,$00,$8D,$00,$00,$A9,$00,$8D,$01,$00; $C943: B1 00 8D 00 00 A9 00 8D 01 00
Loc_C94D:
; --- Code Region ---
  LDA #$0D                                ; $C94D: A9 0D
  STA a:$0003                             ; $C94F: 8D 03 00
  JSR $EBCA                               ; $C952: 20 CA EB
  LDA a:$0000                             ; $C955: AD 00 00
  STA $0572                               ; $C958: 8D 72 05
  LDA $0561                               ; $C95B: AD 61 05
  JSR $F2D7                               ; $C95E: 20 D7 F2
  JSR $C991                               ; $C961: 20 91 C9
  STA $056B                               ; $C964: 8D 6B 05
  STA $04C2                               ; $C967: 8D C2 04
  STY $0571                               ; $C96A: 8C 71 05
  STX $056F                               ; $C96D: 8E 6F 05
  LDA $0561                               ; $C970: AD 61 05
  JSR $F2D7                               ; $C973: 20 D7 F2
  LDY #$02                                ; $C976: A0 02
  LDA ($00),Y                             ; $C978: B1 00
  STA a:$0000                             ; $C97A: 8D 00 00
  LDA #$00                                ; $C97D: A9 00
  STA a:$0001                             ; $C97F: 8D 01 00
  LDA #$0D                                ; $C982: A9 0D
  STA a:$0003                             ; $C984: 8D 03 00
  JSR $EBCA                               ; $C987: 20 CA EB
  LDA a:$0000                             ; $C98A: AD 00 00
  STA $0573                               ; $C98D: 8D 73 05
  RTS                                     ; $C990: 60
Loc_C991:
  LDY #$0A                                ; $C991: A0 0A
  LDA ($00),Y                             ; $C993: B1 00
  PHA                                     ; $C995: 48
  LDY #$01                                ; $C996: A0 01
  LDA ($00),Y                             ; $C998: B1 00
  LDY #$2D                                ; $C99A: A0 2D
  CMP #$32                                ; $C99C: C9 32
  BCC $C9C0                               ; $C99E: 90 20
  LDY #$2D                                ; $C9A0: A0 2D
  CMP #$41                                ; $C9A2: C9 41
  BCC $C9C0                               ; $C9A4: 90 1A
  LDY #$32                                ; $C9A6: A0 32
  CMP #$50                                ; $C9A8: C9 50
  BCC $C9C0                               ; $C9AA: 90 14
  LDY #$37                                ; $C9AC: A0 37
  CMP #$57                                ; $C9AE: C9 57
  BCC $C9C0                               ; $C9B0: 90 0E
  LDY #$3C                                ; $C9B2: A0 3C
  CMP #$5C                                ; $C9B4: C9 5C
  BCC $C9C0                               ; $C9B6: 90 08
  LDY #$41                                ; $C9B8: A0 41
  CMP #$61                                ; $C9BA: C9 61
  BCC $C9C0                               ; $C9BC: 90 02
  LDY #$46                                ; $C9BE: A0 46
Loc_C9C0:
  STY a:$0003                             ; $C9C0: 8C 03 00
  STA a:$0000                             ; $C9C3: 8D 00 00
  LDA #$00                                ; $C9C6: A9 00
  STA a:$0001                             ; $C9C8: 8D 01 00
  STA a:$0002                             ; $C9CB: 8D 02 00
  JSR $EBE9                               ; $C9CE: 20 E9 EB
  LDA a:$0006                             ; $C9D1: AD 06 00
  STA a:$0001                             ; $C9D4: 8D 01 00
  LDA a:$0007                             ; $C9D7: AD 07 00
  STA a:$0002                             ; $C9DA: 8D 02 00
  LDA #$64                                ; $C9DD: A9 64
  STA a:$0003                             ; $C9DF: 8D 03 00
  LDA #$00                                ; $C9E2: A9 00
  STA a:$0004                             ; $C9E4: 8D 04 00
  JSR $EA7C                               ; $C9E7: 20 7C EA
Loc_C9EA:
  JSR $E87A                               ; $C9EA: 20 7A E8
  AND #$0F                                ; $C9ED: 29 0F
  CMP #$09                                ; $C9EF: C9 09
  BCS $C9EA                               ; $C9F1: B0 F7
  STA a:$0002                             ; $C9F3: 8D 02 00
  LDA a:$0001                             ; $C9F6: AD 01 00
  CLC                                     ; $C9F9: 18
  ADC #$09                                ; $C9FA: 69 09
  SEC                                     ; $C9FC: 38
  SBC a:$0002                             ; $C9FD: ED 02 00
  BCS $CA04                               ; $CA00: B0 02
  LDA #$01                                ; $CA02: A9 01
Loc_CA04:
  STA a:$0001                             ; $CA04: 8D 01 00
  PLA                                     ; $CA07: 68
  PHA                                     ; $CA08: 48
  AND #$1F                                ; $CA09: 29 1F
  TAY                                     ; $CA0B: A8
  LDA $CA1F,Y                             ; $CA0C: B9 1F CA
  TAY                                     ; $CA0F: A8
  PLA                                     ; $CA10: 68
  LSR                                     ; $CA11: 4A
  LSR                                     ; $CA12: 4A
  LSR                                     ; $CA13: 4A
  LSR                                     ; $CA14: 4A
  LSR                                     ; $CA15: 4A
  TAX                                     ; $CA16: AA
  LDA $CA37,X                             ; $CA17: BD 37 CA
  TAX                                     ; $CA1A: AA
  LDA a:$0001                             ; $CA1B: AD 01 00
  RTS                                     ; $CA1E: 60
; --- Data Region ---
  .byte $03,$04,$07,$09,$0D,$0F,$10,$11,$04,$05,$08,$0A,$0C,$0B,$11,$13; $CA1F: 03 04 07 09 0D 0F 10 11 04 05 08 0A 0C 0B 11 13
  .byte $05,$06,$07,$0A,$0B,$10,$12,$14,$02,$03,$05,$07,$08,$0A,$0B,$0C; $CA2F: 05 06 07 0A 0B 10 12 14 02 03 05 07 08 0A 0B 0C
Loc_CA3F:
; --- Code Region ---
  LDA $0560                               ; $CA3F: AD 60 05
  JSR $F2D7                               ; $CA42: 20 D7 F2
  LDA $05AC                               ; $CA45: AD AC 05
  LDY #$00                                ; $CA48: A0 00
  STA ($00),Y                             ; $CA4A: 91 00
  LDY #$00                                ; $CA4C: A0 00
  STY a:$0002                             ; $CA4E: 8C 02 00
  STY a:$0003                             ; $CA51: 8C 03 00
Loc_CA54:
  LDA $05AD,Y                             ; $CA54: B9 AD 05
  CMP #$FF                                ; $CA57: C9 FF
  BEQ $CA6D                               ; $CA59: F0 12
  LDA $05AD,Y                             ; $CA5B: B9 AD 05
  CLC                                     ; $CA5E: 18
  ADC a:$0002                             ; $CA5F: 6D 02 00
  STA a:$0002                             ; $CA62: 8D 02 00
  LDA a:$0003                             ; $CA65: AD 03 00
  ADC #$00                                ; $CA68: 69 00
  STA a:$0003                             ; $CA6A: 8D 03 00
Loc_CA6D:
  INY                                     ; $CA6D: C8
  CPY #$0A                                ; $CA6E: C0 0A
  BCC $CA54                               ; $CA70: 90 E2
  LDY #$08                                ; $CA72: A0 08
  LDA a:$0002                             ; $CA74: AD 02 00
  STA ($00),Y                             ; $CA77: 91 00
  INY                                     ; $CA79: C8
  LDA ($00),Y                             ; $CA7A: B1 00
  AND #$FC                                ; $CA7C: 29 FC
  ORA a:$0003                             ; $CA7E: 0D 03 00
  STA ($00),Y                             ; $CA81: 91 00
  LDA $0561                               ; $CA83: AD 61 05
  JSR $F2D7                               ; $CA86: 20 D7 F2
  LDA $05B7                               ; $CA89: AD B7 05
  LDY #$00                                ; $CA8C: A0 00
  STA ($00),Y                             ; $CA8E: 91 00
  LDY #$00                                ; $CA90: A0 00
  STY a:$0002                             ; $CA92: 8C 02 00
  STY a:$0003                             ; $CA95: 8C 03 00
Loc_CA98:
  LDA $05B8,Y                             ; $CA98: B9 B8 05
  CMP #$FF                                ; $CA9B: C9 FF
  BEQ $CAB1                               ; $CA9D: F0 12
  LDA $05B8,Y                             ; $CA9F: B9 B8 05
  CLC                                     ; $CAA2: 18
  ADC a:$0002                             ; $CAA3: 6D 02 00
  STA a:$0002                             ; $CAA6: 8D 02 00
  LDA a:$0003                             ; $CAA9: AD 03 00
  ADC #$00                                ; $CAAC: 69 00
  STA a:$0003                             ; $CAAE: 8D 03 00
Loc_CAB1:
  INY                                     ; $CAB1: C8
  CPY #$0A                                ; $CAB2: C0 0A
  BCC $CA98                               ; $CAB4: 90 E2
  LDY #$08                                ; $CAB6: A0 08
  LDA a:$0002                             ; $CAB8: AD 02 00
  STA ($00),Y                             ; $CABB: 91 00
  INY                                     ; $CABD: C8
  LDA ($00),Y                             ; $CABE: B1 00
  AND #$FC                                ; $CAC0: 29 FC
  ORA a:$0003                             ; $CAC2: 0D 03 00
  STA ($00),Y                             ; $CAC5: 91 00
  RTS                                     ; $CAC7: 60
Loc_CAC8:
  LDY $0545                               ; $CAC8: AC 45 05
  LDA $0580,Y                             ; $CACB: B9 80 05
  CLC                                     ; $CACE: 18
  ADC a:$0000                             ; $CACF: 6D 00 00
  STA a:$0000                             ; $CAD2: 8D 00 00
  CMP #$10                                ; $CAD5: C9 10
  BCS $CAE7                               ; $CAD7: B0 0E
  LDA $0596,Y                             ; $CAD9: B9 96 05
  CLC                                     ; $CADC: 18
  ADC a:$0001                             ; $CADD: 6D 01 00
  STA a:$0001                             ; $CAE0: 8D 01 00
  CMP #$0A                                ; $CAE3: C9 0A
  BCC $CAEA                               ; $CAE5: 90 03
Loc_CAE7:
  LDA #$01                                ; $CAE7: A9 01
  RTS                                     ; $CAE9: 60
Loc_CAEA:
  JSR $CAF9                               ; $CAEA: 20 F9 CA
  CMP #$04                                ; $CAED: C9 04
  BEQ $CAF5                               ; $CAEF: F0 04
  CMP #$05                                ; $CAF1: C9 05
  BNE $CAF7                               ; $CAF3: D0 02
Loc_CAF5:
  LDA #$00                                ; $CAF5: A9 00
Loc_CAF7:
  TAY                                     ; $CAF7: A8
  RTS                                     ; $CAF8: 60
Loc_CAF9:
  LDA $0544                               ; $CAF9: AD 44 05
  PHA                                     ; $CAFC: 48
  TAY                                     ; $CAFD: A8
  LDA $BB48,Y                             ; $CAFE: B9 48 BB
  TAY                                     ; $CB01: A8
  JSR $F25F                               ; $CB02: 20 5F F2
  PLA                                     ; $CB05: 68
  ASL                                     ; $CB06: 0A
  TAY                                     ; $CB07: A8
  LDA $BB1E,Y                             ; $CB08: B9 1E BB
  STA a:$0002                             ; $CB0B: 8D 02 00
  LDA $BB1F,Y                             ; $CB0E: B9 1F BB
  STA a:$0003                             ; $CB11: 8D 03 00
  LDA a:$0001                             ; $CB14: AD 01 00
  ASL                                     ; $CB17: 0A
  ASL                                     ; $CB18: 0A
  ASL                                     ; $CB19: 0A
  ASL                                     ; $CB1A: 0A
  ORA a:$0000                             ; $CB1B: 0D 00 00
  TAY                                     ; $CB1E: A8
  LDA ($02),Y                             ; $CB1F: B1 02
  TAY                                     ; $CB21: A8
  LDA $CB59,Y                             ; $CB22: B9 59 CB
  BEQ $CB57                               ; $CB25: F0 30
  CMP #$01                                ; $CB27: C9 01
  BEQ $CB57                               ; $CB29: F0 2C
  CMP #$05                                ; $CB2B: C9 05
  BEQ $CB57                               ; $CB2D: F0 28
  PHA                                     ; $CB2F: 48
  LDY #$00                                ; $CB30: A0 00
  LDA $0545                               ; $CB32: AD 45 05
  CMP #$0B                                ; $CB35: C9 0B
  BCC $CB3A                               ; $CB37: 90 01
  INY                                     ; $CB39: C8
Loc_CB3A:
  LDA $0560,Y                             ; $CB3A: B9 60 05
  JSR $F2D7                               ; $CB3D: 20 D7 F2
  LDY #$0B                                ; $CB40: A0 0B
  LDA ($00),Y                             ; $CB42: B1 00
  LSR                                     ; $CB44: 4A
  LSR                                     ; $CB45: 4A
  AND #$03                                ; $CB46: 29 03
  TAY                                     ; $CB48: A8
  PLA                                     ; $CB49: 68
  TAX                                     ; $CB4A: AA
  CMP $CBE9,Y                             ; $CB4B: D9 E9 CB
  BEQ $CB55                               ; $CB4E: F0 05
  CMP $CBED,Y                             ; $CB50: D9 ED CB
  BNE $CB57                               ; $CB53: D0 02
Loc_CB55:
  LDA #$00                                ; $CB55: A9 00
Loc_CB57:
  TAY                                     ; $CB57: A8
  RTS                                     ; $CB58: 60
; --- Data Region ---
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; $CB59: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; $CB69: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; $CB79: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; $CB89: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; $CB99: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$05,$05,$00,$05,$00,$00,$05,$05; $CBA9: 00 00 00 00 00 00 00 00 05 05 00 05 00 00 05 05
  .byte $05,$05,$05,$05,$05,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; $CBB9: 05 05 05 05 05 00 00 00 00 00 00 00 00 00 00 00
  .byte $00,$00,$00,$00,$00,$03,$04,$02,$00,$00,$00,$00,$00,$00,$00,$01; $CBC9: 00 00 00 00 00 03 04 02 00 00 00 00 00 00 00 01
  .byte $01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00; $CBD9: 01 01 01 01 01 01 01 00 00 00 00 00 00 00 00 00
  .byte $00,$02,$03,$00,$00,$02,$04,$00   ; $CBE9: 00 02 03 00 00 02 04 00
Loc_CBF1:
; --- Code Region ---
  LDY #$20                                ; $CBF1: A0 20
  LDA #$00                                ; $CBF3: A9 00
Loc_CBF5:
  STA $044C,Y                             ; $CBF5: 99 4C 04
  DEY                                     ; $CBF8: 88
  BPL $CBF5                               ; $CBF9: 10 FA
  LDA $05AC                               ; $CBFB: AD AC 05
  STA $044C                               ; $CBFE: 8D 4C 04
  LDA $05B7                               ; $CC01: AD B7 05
  STA $044F                               ; $CC04: 8D 4F 04
  LDA #$01                                ; $CC07: A9 01
  LDY #$00                                ; $CC09: A0 00
  JSR $CC7A                               ; $CC0B: 20 7A CC
  LDA a:$0001                             ; $CC0E: AD 01 00
  STA $0452                               ; $CC11: 8D 52 04
  LDA a:$0002                             ; $CC14: AD 02 00
  STA $0453                               ; $CC17: 8D 53 04
  LDA #$01                                ; $CC1A: A9 01
  LDY #$0B                                ; $CC1C: A0 0B
  JSR $CC7A                               ; $CC1E: 20 7A CC
  LDA a:$0001                             ; $CC21: AD 01 00
  STA $0455                               ; $CC24: 8D 55 04
  LDA a:$0002                             ; $CC27: AD 02 00
  STA $0456                               ; $CC2A: 8D 56 04
  LDA #$02                                ; $CC2D: A9 02
  LDY #$00                                ; $CC2F: A0 00
  JSR $CC7A                               ; $CC31: 20 7A CC
  LDA a:$0001                             ; $CC34: AD 01 00
  STA $0458                               ; $CC37: 8D 58 04
  LDA a:$0002                             ; $CC3A: AD 02 00
  STA $0459                               ; $CC3D: 8D 59 04
  LDA #$02                                ; $CC40: A9 02
  LDY #$0B                                ; $CC42: A0 0B
  JSR $CC7A                               ; $CC44: 20 7A CC
  LDA a:$0001                             ; $CC47: AD 01 00
  STA $045B                               ; $CC4A: 8D 5B 04
  LDA a:$0002                             ; $CC4D: AD 02 00
  STA $045C                               ; $CC50: 8D 5C 04
  LDA #$03                                ; $CC53: A9 03
  LDY #$00                                ; $CC55: A0 00
  JSR $CC7A                               ; $CC57: 20 7A CC
  LDA a:$0001                             ; $CC5A: AD 01 00
  STA $045E                               ; $CC5D: 8D 5E 04
  LDA a:$0002                             ; $CC60: AD 02 00
  STA $045F                               ; $CC63: 8D 5F 04
  LDA #$03                                ; $CC66: A9 03
  LDY #$0B                                ; $CC68: A0 0B
  JSR $CC7A                               ; $CC6A: 20 7A CC
  LDA a:$0001                             ; $CC6D: AD 01 00
  STA $0461                               ; $CC70: 8D 61 04
  LDA a:$0002                             ; $CC73: AD 02 00
  STA $0462                               ; $CC76: 8D 62 04
  RTS                                     ; $CC79: 60
Loc_CC7A:
  STA a:$0000                             ; $CC7A: 8D 00 00
  LDA #$00                                ; $CC7D: A9 00
  STA a:$0001                             ; $CC7F: 8D 01 00
  STA a:$0002                             ; $CC82: 8D 02 00
  LDX #$0A                                ; $CC85: A2 0A
Loc_CC87:
  LDA $05C2,Y                             ; $CC87: B9 C2 05
  AND #$0F                                ; $CC8A: 29 0F
  CMP a:$0000                             ; $CC8C: CD 00 00
  BNE $CCA3                               ; $CC8F: D0 12
  LDA $05AC,Y                             ; $CC91: B9 AC 05
  CLC                                     ; $CC94: 18
  ADC a:$0001                             ; $CC95: 6D 01 00
  STA a:$0001                             ; $CC98: 8D 01 00
  LDA a:$0002                             ; $CC9B: AD 02 00
  ADC #$00                                ; $CC9E: 69 00
  STA a:$0002                             ; $CCA0: 8D 02 00
Loc_CCA3:
  INY                                     ; $CCA3: C8
  DEX                                     ; $CCA4: CA
  BPL $CC87                               ; $CCA5: 10 E0
  RTS                                     ; $CCA7: 60
Loc_CCA8:
  LDA #$D8                                ; $CCA8: A9 D8
  STA a:$000A                             ; $CCAA: 8D 0A 00
  LDA #$A0                                ; $CCAD: A9 A0
  STA a:$000C                             ; $CCAF: 8D 0C 00
  JMP $CCBF                               ; $CCB2: 4C BF CC
; --- Data Region ---
  .byte $A9,$E0,$8D,$0A,$00,$A9,$A0,$8D,$0C,$00; $CCB5: A9 E0 8D 0A 00 A9 A0 8D 0C 00
Loc_CCBF:
; --- Code Region ---
  LDA a:$005E                             ; $CCBF: AD 5E 00
  AND #$10                                ; $CCC2: 29 10
  BNE $CCD8                               ; $CCC4: D0 12
  LDA #$D9                                ; $CCC6: A9 D9
  STA a:$0000                             ; $CCC8: 8D 00 00
  LDA #$CC                                ; $CCCB: A9 CC
  STA a:$0001                             ; $CCCD: 8D 01 00
  LDA #$00                                ; $CCD0: A9 00
  STA a:$0002                             ; $CCD2: 8D 02 00
  JMP $F1AD                               ; $CCD5: 4C AD F1
Loc_CCD8:
  RTS                                     ; $CCD8: 60
; --- Data Region ---
  .byte $00,$04,$00,$00,$80               ; $CCD9: 00 04 00 00 80
;===============================================================================
; $CCDE: BattlePadStateFetch
; Mode-filtered controller state fetch. Input: A = pad index (0/1). The input
; source mode is taken from $0562 (pad 1) / $0563 (pad 2):
;   mode 1: $0000 <- pad 2 edge ($0085), $0001 <- pad 2 raw ($0082)
;   mode 3: $0000/$0001 <- 0 (AI-controlled side: physical input ignored)
;   other : $0000 <- pad 1 edge ($0083), $0001 <- pad 1 raw ($0081)
; (pad edge/raw semantics per ControllerRead $E6C6.) Except for mode 3, the
; raw byte is OR-latched into $057B, which BattleVBlankFrameUpdate swaps into
; $0081 to feed B1D_1E_MenuUpdate.
;===============================================================================
.proc BattlePadStateFetch
; --- Code Region ---
  CMP #$00                                ; $CCDE: C9 00 ; pad index
  BNE @Pad2Mode                           ; $CCE0: D0 06
  LDA $0562                               ; $CCE2: AD 62 05 ; pad 1 input mode
  JMP @ModeDispatch                       ; $CCE5: 4C EB CC
@Pad2Mode:
  LDA $0563                               ; $CCE8: AD 63 05 ; pad 2 input mode
@ModeDispatch:
  CMP #$01                                ; $CCEB: C9 01
  BEQ @Pad2State                          ; $CCED: F0 17
  CMP #$03                                ; $CCEF: C9 03
  BEQ @NoInput                            ; $CCF1: F0 26
  LDA a:$0083                             ; $CCF3: AD 83 00 ; pad 1 edge
  STA a:$0000                             ; $CCF6: 8D 00 00
  LDA a:$0081                             ; $CCF9: AD 81 00 ; pad 1 raw
  STA a:$0001                             ; $CCFC: 8D 01 00
  ORA $057B                               ; $CCFF: 0D 7B 05
  STA $057B                               ; $CD02: 8D 7B 05 ; latch into menu input mask
  RTS                                     ; $CD05: 60
@Pad2State:
  LDA a:$0085                             ; $CD06: AD 85 00 ; pad 2 edge
  STA a:$0000                             ; $CD09: 8D 00 00
  LDA a:$0082                             ; $CD0C: AD 82 00 ; pad 2 raw
  STA a:$0001                             ; $CD0F: 8D 01 00
  ORA $057B                               ; $CD12: 0D 7B 05
  STA $057B                               ; $CD15: 8D 7B 05
  RTS                                     ; $CD18: 60
@NoInput:
  LDA #$00                                ; $CD19: A9 00 ; AI side: no physical input
  STA a:$0000                             ; $CD1B: 8D 00 00
  STA a:$0001                             ; $CD1E: 8D 01 00
  RTS                                     ; $CD21: 60
.endproc
;===============================================================================
; $CD22: BattleBothPadsStateFetch
; Fetches both pads' mode-filtered states via BattlePadStateFetch and merges
; them: $0000 = pad1 edge | pad2 edge, $0001 = pad1 raw | pad2 raw. Used by
; the phase-4 result handlers to accept an A/B edge from either controller.
;===============================================================================
.proc BattleBothPadsStateFetch
  LDA #$00                                ; $CD22: A9 00 ; pad 1
  JSR BattlePadStateFetch                 ; $CD24: 20 DE CC
  LDA a:$0000                             ; $CD27: AD 00 00
  PHA                                     ; $CD2A: 48
  LDA a:$0001                             ; $CD2B: AD 01 00
  PHA                                     ; $CD2E: 48
  LDA #$01                                ; $CD2F: A9 01
  JSR BattlePadStateFetch                 ; $CD31: 20 DE CC
  PLA                                     ; $CD34: 68
  ORA a:$0001                             ; $CD35: 0D 01 00
  STA a:$0001                             ; $CD38: 8D 01 00
  PLA                                     ; $CD3B: 68
  ORA a:$0000                             ; $CD3C: 0D 00 00
  STA a:$0000                             ; $CD3F: 8D 00 00
  RTS                                     ; $CD42: 60
.endproc
; --- Data Region ---
Loc_CD43:  ; (dispatch callback target - phase 5 handler, undecoded)
  .byte $AD,$41,$05,$20,$DE,$EA,$4F,$CD,$59,$CD,$CF,$CD; $CD43: AD 41 05 20 DE EA 4F CD 59 CD CF CD
Loc_CD4F:  ; (dispatch callback target)
; --- Code Region ---
  JSR $ECEE                               ; $CD4F: 20 EE EC
  INC $0541                               ; $CD52: EE 41 05
  JSR $CA3F                               ; $CD55: 20 3F CA
Loc_CD58:
  RTS                                     ; $CD58: 60
Loc_CD59:  ; (dispatch callback target)
  LDA a:$0087                             ; $CD59: AD 87 00
  BPL $CD58                               ; $CD5C: 10 FA
  JSR $E768                               ; $CD5E: 20 68 E7
  INC $0541                               ; $CD61: EE 41 05
  LDA #$07                                ; $CD64: A9 07
  STA a:$007A                             ; $CD66: 8D 7A 00
  LDA #$00                                ; $CD69: A9 00
  STA $04A8                               ; $CD6B: 8D A8 04
  STA $04A9                               ; $CD6E: 8D A9 04
  STA $04AA                               ; $CD71: 8D AA 04
  LDA $0562                               ; $CD74: AD 62 05
  BEQ $CD85                               ; $CD77: F0 0C
  LDA $0563                               ; $CD79: AD 63 05
  BEQ $CDAA                               ; $CD7C: F0 2C
  LDA $0563                               ; $CD7E: AD 63 05
  CMP #$01                                ; $CD81: C9 01
  BEQ $CDAA                               ; $CD83: F0 25
Loc_CD85:
  LDA $0560                               ; $CD85: AD 60 05
  STA $04AD                               ; $CD88: 8D AD 04
  LDA $0561                               ; $CD8B: AD 61 05
  STA $04AE                               ; $CD8E: 8D AE 04
  LDA $0562                               ; $CD91: AD 62 05
  CMP #$03                                ; $CD94: C9 03
  BNE $CD9A                               ; $CD96: D0 02
  LDA #$80                                ; $CD98: A9 80
Loc_CD9A:
  STA $04AB                               ; $CD9A: 8D AB 04
  LDA $0563                               ; $CD9D: AD 63 05
  CMP #$03                                ; $CDA0: C9 03
  BNE $CDA6                               ; $CDA2: D0 02
  LDA #$80                                ; $CDA4: A9 80
Loc_CDA6:
  STA $04AC                               ; $CDA6: 8D AC 04
  RTS                                     ; $CDA9: 60
Loc_CDAA:
  LDA $0560                               ; $CDAA: AD 60 05
  STA $04AE                               ; $CDAD: 8D AE 04
  LDA $0561                               ; $CDB0: AD 61 05
  STA $04AD                               ; $CDB3: 8D AD 04
  LDA $0562                               ; $CDB6: AD 62 05
  CMP #$03                                ; $CDB9: C9 03
  BNE $CDBF                               ; $CDBB: D0 02
  LDA #$80                                ; $CDBD: A9 80
Loc_CDBF:
  STA $04AC                               ; $CDBF: 8D AC 04
  LDA $0563                               ; $CDC2: AD 63 05
  CMP #$03                                ; $CDC5: C9 03
  BNE $CDCB                               ; $CDC7: D0 02
  LDA #$80                                ; $CDC9: A9 80
Loc_CDCB:
  STA $04AB                               ; $CDCB: 8D AB 04
  RTS                                     ; $CDCE: 60
Loc_CDCF:  ; (dispatch callback target)
  LDA a:$0087                             ; $CDCF: AD 87 00
  BPL $CE0F                               ; $CDD2: 10 3B
  LDA $0560                               ; $CDD4: AD 60 05
  JSR $F2D7                               ; $CDD7: 20 D7 F2
  LDY #$00                                ; $CDDA: A0 00
  LDA ($00),Y                             ; $CDDC: B1 00
  STA $05AC                               ; $CDDE: 8D AC 05
  LDA $0561                               ; $CDE1: AD 61 05
  JSR $F2D7                               ; $CDE4: 20 D7 F2
  LDY #$00                                ; $CDE7: A0 00
  LDA ($00),Y                             ; $CDE9: B1 00
  STA $05B7                               ; $CDEB: 8D B7 05
  LDA #$00                                ; $CDEE: A9 00
  STA $0540                               ; $CDF0: 8D 40 05
  LDA #$01                                ; $CDF3: A9 01
  STA $0541                               ; $CDF5: 8D 41 05
  LDA #$00                                ; $CDF8: A9 00
Loc_CDFA:
  STA $0548                               ; $CDFA: 8D 48 05
  LDA $0514                               ; $CDFD: AD 14 05
  LDY $0515                               ; $CE00: AC 15 05
  JSR $CE10                               ; $CE03: 20 10 CE
  LDA $0516                               ; $CE06: AD 16 05
  LDY $0517                               ; $CE09: AC 17 05
  JSR $CE10                               ; $CE0C: 20 10 CE
Loc_CE0F:
  RTS                                     ; $CE0F: 60
Loc_CE10:
  CPY #$01                                ; $CE10: C0 01
  BNE $CE24                               ; $CE12: D0 10
  CMP $0560                               ; $CE14: CD 60 05
  BNE $CE1F                               ; $CE17: D0 06
  LDA #$01                                ; $CE19: A9 01
  STA $0550                               ; $CE1B: 8D 50 05
  RTS                                     ; $CE1E: 60
Loc_CE1F:
  LDA #$01                                ; $CE1F: A9 01
  STA $0554                               ; $CE21: 8D 54 05
Loc_CE24:
  RTS                                     ; $CE24: 60
; --- Data Region ---
Loc_CE25:  ; (dispatch callback target - phase 6 handler, undecoded)
  .byte $AD,$41,$05,$20,$DE,$EA,$33,$CE,$68,$CE,$AE,$CE,$FA,$CE; $CE25: AD 41 05 20 DE EA 33 CE 68 CE AE CE FA CE
Loc_CE33:  ; (dispatch callback target)
; --- Code Region ---
  JSR $E87A                               ; $CE33: 20 7A E8
  AND #$03                                ; $CE36: 29 03
  STA $056C                               ; $CE38: 8D 6C 05
  LDA $0562                               ; $CE3B: AD 62 05
  CMP #$03                                ; $CE3E: C9 03
  BNE $CE45                               ; $CE40: D0 03
  JMP $CEFA                               ; $CE42: 4C FA CE
Loc_CE45:
  LDA #$D4                                ; $CE45: A9 D4
  JSR $F26D                               ; $CE47: 20 6D F2
  INC $0541                               ; $CE4A: EE 41 05
  LDA $0560                               ; $CE4D: AD 60 05
  STA a:$0000                             ; $CE50: 8D 00 00
  LDY #$3D                                ; $CE53: A0 3D
  JSR $EE07                               ; $CE55: 20 07 EE
; --- Data Region ---
  .byte $30,$A0,$A9,$00,$8D,$24,$04,$8D,$25,$04,$A9,$7D,$8D,$BC,$00,$60; $CE58: 30 A0 A9 00 8D 24 04 8D 25 04 A9 7D 8D BC 00 60
Loc_CE68:  ; (dispatch callback target)
; --- Code Region ---
  LDA $0560                               ; $CE68: AD 60 05
  STA a:$0000                             ; $CE6B: 8D 00 00
  LDA #$A5                                ; $CE6E: A9 A5
  STA a:$000A                             ; $CE70: 8D 0A 00
  LDX #$00                                ; $CE73: A2 00
  LDY #$39                                ; $CE75: A0 39
  JSR $EE07                               ; $CE77: 20 07 EE
; --- Data Region ---
  .byte $00,$A0,$A0,$00,$20,$05,$CF,$AD,$12,$00,$8D,$6C,$05,$A9,$00,$20; $CE7A: 00 A0 A0 00 20 05 CF AD 12 00 8D 6C 05 A9 00 20
  .byte $DE,$CC,$20,$70,$B8,$90,$1C,$AD,$01,$00,$29,$01,$F0,$15,$EE,$41; $CE8A: DE CC 20 70 B8 90 1C AD 01 00 29 01 F0 15 EE 41
  .byte $05,$A9,$D2,$20,$6D,$F2,$AD,$64,$05,$20,$68,$F3,$A0,$00,$B1,$00; $CE9A: 05 A9 D2 20 6D F2 AD 64 05 20 68 F3 A0 00 B1 00
  .byte $8D,$2C,$04                       ; $CEAA: 8D 2C 04
Loc_CEAD:
; --- Code Region ---
  RTS                                     ; $CEAD: 60
Loc_CEAE:  ; (dispatch callback target)
  LDA $0560                               ; $CEAE: AD 60 05
  STA a:$0000                             ; $CEB1: 8D 00 00
  LDA #$A5                                ; $CEB4: A9 A5
  STA a:$000A                             ; $CEB6: 8D 0A 00
  LDX #$00                                ; $CEB9: A2 00
  LDY #$39                                ; $CEBB: A0 39
  JSR $EE07                               ; $CEBD: 20 07 EE
; --- Data Region ---
  .byte $00,$A0,$A9,$00,$20,$DE,$CC,$20,$70,$B8,$90,$2D,$20,$FD,$C8,$A9; $CEC0: 00 A0 A9 00 20 DE CC 20 70 B8 90 2D 20 FD C8 A9
  .byte $00,$20,$DE,$CC,$AD,$01,$00,$29,$01,$F0,$1E,$A9,$03,$8D,$40,$05; $CED0: 00 20 DE CC AD 01 00 29 01 F0 1E A9 03 8D 40 05
  .byte $A9,$00,$8D,$41,$05,$A9,$06,$8D,$4B,$05,$A9,$03,$8D,$4C,$05,$A9; $CEE0: A9 00 8D 41 05 A9 06 8D 4B 05 A9 03 8D 4C 05 A9
  .byte $00,$8D,$49,$05,$A9,$05,$8D,$BC,$00; $CEF0: 00 8D 49 05 A9 05 8D BC 00
Loc_CEF9:
; --- Code Region ---
  RTS                                     ; $CEF9: 60
Loc_CEFA:  ; (dispatch callback target)
  LDA #$07                                ; $CEFA: A9 07
  STA $0540                               ; $CEFC: 8D 40 05
  LDA #$00                                ; $CEFF: A9 00
  STA $0541                               ; $CF01: 8D 41 05
  RTS                                     ; $CF04: 60
Loc_CF05:
  LDA a:$0083                             ; $CF05: AD 83 00
  PHA                                     ; $CF08: 48
  LDA a:$0081                             ; $CF09: AD 81 00
  PHA                                     ; $CF0C: 48
  TYA                                     ; $CF0D: 98
  JSR BattlePadStateFetch                 ; $CF0E: 20 DE CC
  LDA a:$0000                             ; $CF11: AD 00 00
  STA a:$0083                             ; $CF14: 8D 83 00
  LDA a:$0001                             ; $CF17: AD 01 00
  STA a:$0081                             ; $CF1A: 8D 81 00
  LDA #$52                                ; $CF1D: A9 52
  STA a:$0010                             ; $CF1F: 8D 10 00
  LDA #$CF                                ; $CF22: A9 CF
  STA a:$0011                             ; $CF24: 8D 11 00
  LDA #$00                                ; $CF27: A9 00
  STA a:$0012                             ; $CF29: 8D 12 00
  JSR $ED28                               ; $CF2C: 20 28 ED
  LDA #$5A                                ; $CF2F: A9 5A
  STA a:$0010                             ; $CF31: 8D 10 00
  LDA #$CF                                ; $CF34: A9 CF
  STA a:$0011                             ; $CF36: 8D 11 00
  LDA #$62                                ; $CF39: A9 62
  STA a:$0000                             ; $CF3B: 8D 00 00
  LDA #$CF                                ; $CF3E: A9 CF
  STA a:$0001                             ; $CF40: 8D 01 00
  LDA a:$0012                             ; $CF43: AD 12 00
  JSR $EDF5                               ; $CF46: 20 F5 ED
  PLA                                     ; $CF49: 68
  STA a:$0081                             ; $CF4A: 8D 81 00
  PLA                                     ; $CF4D: 68
  STA a:$0083                             ; $CF4E: 8D 83 00
  RTS                                     ; $CF51: 60
; --- Data Region ---
  .byte $00,$01,$02,$03,$FF               ; $CF52: 00 01 02 03 FF
Loc_CF57:
  .byte $FF,$FF,$FF,$B6,$4C,$B6,$74,$B6,$9C,$B6,$C4,$00,$04,$00,$00,$80; $CF57: FF FF FF B6 4C B6 74 B6 9C B6 C4 00 04 00 00 80
Loc_CF67:  ; (dispatch callback target - phase 7 handler, undecoded)
  .byte $AD,$41,$05,$20,$DE,$EA           ; $CF67: AD 41 05 20 DE EA
  .byte $77,$CF,$9D,$CF,$C2,$CF,$08,$D0,$54,$D0; $CF6D: 77 CF 9D CF C2 CF 08 D0 54 D0
Loc_CF77:  ; (dispatch callback target)
; --- Code Region ---
  JSR $E87A                               ; $CF77: 20 7A E8
  AND #$03                                ; $CF7A: 29 03
  STA $056D                               ; $CF7C: 8D 6D 05
  LDA $0563                               ; $CF7F: AD 63 05
  CMP #$03                                ; $CF82: C9 03
  BNE $CF89                               ; $CF84: D0 03
  JMP $D054                               ; $CF86: 4C 54 D0
Loc_CF89:
  LDA #$00                                ; $CF89: A9 00
  STA $0310                               ; $CF8B: 8D 10 03
  STA $0300                               ; $CF8E: 8D 00 03
  INC $0541                               ; $CF91: EE 41 05
  LDA #$00                                ; $CF94: A9 00
  STA $0424                               ; $CF96: 8D 24 04
  STA $0425                               ; $CF99: 8D 25 04
  RTS                                     ; $CF9C: 60
Loc_CF9D:  ; (dispatch callback target)
  JSR $B870                               ; $CF9D: 20 70 B8
  BCC $CFC1                               ; $CFA0: 90 1F
  LDA #$D4                                ; $CFA2: A9 D4
  JSR $F26D                               ; $CFA4: 20 6D F2
  INC $0541                               ; $CFA7: EE 41 05
  LDA $0561                               ; $CFAA: AD 61 05
  STA a:$0000                             ; $CFAD: 8D 00 00
  LDY #$3D                                ; $CFB0: A0 3D
  JSR $EE07                               ; $CFB2: 20 07 EE
; --- Data Region ---
  .byte $30,$A0,$A9,$09,$8D,$BB,$00,$A9,$7D,$8D,$BC,$00; $CFB5: 30 A0 A9 09 8D BB 00 A9 7D 8D BC 00
Loc_CFC1:
; --- Code Region ---
  RTS                                     ; $CFC1: 60
Loc_CFC2:  ; (dispatch callback target)
  LDA $0561                               ; $CFC2: AD 61 05
  STA a:$0000                             ; $CFC5: 8D 00 00
  LDA #$A5                                ; $CFC8: A9 A5
  STA a:$000A                             ; $CFCA: 8D 0A 00
  LDX #$00                                ; $CFCD: A2 00
  LDY #$39                                ; $CFCF: A0 39
  JSR $EE07                               ; $CFD1: 20 07 EE
; --- Data Region ---
  .byte $00,$A0,$A0,$01,$20,$05,$CF,$AD   ; $CFD4: 00 A0 A0 01 20 05 CF AD
Loc_CFDC:
  .byte $12,$00,$8D,$6D,$05,$A9,$01,$20,$DE,$CC,$20,$70,$B8,$90,$1C,$AD; $CFDC: 12 00 8D 6D 05 A9 01 20 DE CC 20 70 B8 90 1C AD
  .byte $01,$00,$29,$01,$F0,$15,$EE,$41,$05,$A9,$D2,$20,$6D,$F2,$AD,$65; $CFEC: 01 00 29 01 F0 15 EE 41 05 A9 D2 20 6D F2 AD 65
  .byte $05,$20,$68,$F3,$A0,$00,$B1,$00,$8D,$2C,$04; $CFFC: 05 20 68 F3 A0 00 B1 00 8D 2C 04
Loc_D007:
; --- Code Region ---
  RTS                                     ; $D007: 60
Loc_D008:  ; (dispatch callback target)
  LDA $0561                               ; $D008: AD 61 05
  STA a:$0000                             ; $D00B: 8D 00 00
  LDA #$A5                                ; $D00E: A9 A5
  STA a:$000A                             ; $D010: 8D 0A 00
  LDX #$00                                ; $D013: A2 00
  LDY #$39                                ; $D015: A0 39
  JSR $EE07                               ; $D017: 20 07 EE
; --- Data Region ---
  .byte $00,$A0,$A9,$01,$20,$DE,$CC,$20,$70,$B8,$90,$2D,$20,$FD,$C8,$A9; $D01A: 00 A0 A9 01 20 DE CC 20 70 B8 90 2D 20 FD C8 A9
  .byte $01,$20,$DE,$CC,$AD,$01,$00,$29,$01,$F0,$1E,$A9,$03,$8D,$40,$05; $D02A: 01 20 DE CC AD 01 00 29 01 F0 1E A9 03 8D 40 05
  .byte $A9,$00,$8D,$41,$05,$A9,$07,$8D,$4B,$05,$A9,$04,$8D,$4C,$05,$A9; $D03A: A9 00 8D 41 05 A9 07 8D 4B 05 A9 04 8D 4C 05 A9
  .byte $01,$8D,$49,$05,$A9,$05,$8D,$BC,$00; $D04A: 01 8D 49 05 A9 05 8D BC 00
Loc_D053:
; --- Code Region ---
  RTS                                     ; $D053: 60
Loc_D054:  ; (dispatch callback target)
  LDA #$00                                ; $D054: A9 00
  STA $0540                               ; $D056: 8D 40 05
  LDA #$01                                ; $D059: A9 01
  STA $0541                               ; $D05B: 8D 41 05
  LDA #$00                                ; $D05E: A9 00
  STA $0548                               ; $D060: 8D 48 05
  JSR $B548                               ; $D063: 20 48 B5
  RTS                                     ; $D066: 60
Loc_D067:
  JSR $D0CB                               ; $D067: 20 CB D0
  LDA $057A                               ; $D06A: AD 7A 05
  CMP #$04                                ; $D06D: C9 04
  BCC $D089                               ; $D06F: 90 18
  LDA $0562                               ; $D071: AD 62 05
  CMP #$03                                ; $D074: C9 03
  BNE $D07D                               ; $D076: D0 05
  LDY #$00                                ; $D078: A0 00
  JSR $D1D8                               ; $D07A: 20 D8 D1
Loc_D07D:
  LDA $0563                               ; $D07D: AD 63 05
  CMP #$03                                ; $D080: C9 03
  BNE $D089                               ; $D082: D0 05
  LDY #$0B                                ; $D084: A0 0B
  JSR $D1D8                               ; $D086: 20 D8 D1
Loc_D089:
  LDA #$00                                ; $D089: A9 00
  STA $0545                               ; $D08B: 8D 45 05
  LDA $057A                               ; $D08E: AD 7A 05
  CMP #$04                                ; $D091: C9 04
  BCC $D0AD                               ; $D093: 90 18
  LDA $0562                               ; $D095: AD 62 05
  CMP #$03                                ; $D098: C9 03
  BNE $D0A1                               ; $D09A: D0 05
  LDY #$00                                ; $D09C: A0 00
  JSR $D2D4                               ; $D09E: 20 D4 D2
Loc_D0A1:
  LDA $0563                               ; $D0A1: AD 63 05
  CMP #$03                                ; $D0A4: C9 03
  BNE $D0AD                               ; $D0A6: D0 05
  LDY #$0B                                ; $D0A8: A0 0B
  JSR $D2D4                               ; $D0AA: 20 D4 D2
Loc_D0AD:
  RTS                                     ; $D0AD: 60
Loc_D0AE:
  LDA $0562                               ; $D0AE: AD 62 05
  CMP #$03                                ; $D0B1: C9 03
  BNE $D0BC                               ; $D0B3: D0 07
  LDX #$00                                ; $D0B5: A2 00
  LDY #$00                                ; $D0B7: A0 00
  JSR $D3C7                               ; $D0B9: 20 C7 D3
Loc_D0BC:
  LDA $0563                               ; $D0BC: AD 63 05
  CMP #$03                                ; $D0BF: C9 03
  BNE $D0CA                               ; $D0C1: D0 07
  LDX #$01                                ; $D0C3: A2 01
  LDY #$0B                                ; $D0C5: A0 0B
  JSR $D3C7                               ; $D0C7: 20 C7 D3
Loc_D0CA:
  RTS                                     ; $D0CA: 60
Loc_D0CB:
  LDA $0562                               ; $D0CB: AD 62 05
  CMP #$03                                ; $D0CE: C9 03
  BNE $D0E6                               ; $D0D0: D0 14
  LDA $0550                               ; $D0D2: AD 50 05
  CMP #$01                                ; $D0D5: C9 01
  BEQ $D0E6                               ; $D0D7: F0 0D
  LDA $0560                               ; $D0D9: AD 60 05
  STA a:$000C                             ; $D0DC: 8D 0C 00
  LDA #$00                                ; $D0DF: A9 00
  LDX #$00                                ; $D0E1: A2 00
  JSR $D102                               ; $D0E3: 20 02 D1
Loc_D0E6:
  LDA $0563                               ; $D0E6: AD 63 05
  CMP #$03                                ; $D0E9: C9 03
  BNE $D101                               ; $D0EB: D0 14
  LDA $0554                               ; $D0ED: AD 54 05
  CMP #$01                                ; $D0F0: C9 01
  BEQ $D101                               ; $D0F2: F0 0D
  LDA $0561                               ; $D0F4: AD 61 05
  STA a:$000C                             ; $D0F7: 8D 0C 00
  LDA #$04                                ; $D0FA: A9 04
  LDX #$01                                ; $D0FC: A2 01
  JSR $D102                               ; $D0FE: 20 02 D1
Loc_D101:
  RTS                                     ; $D101: 60
Loc_D102:
  STA a:$000A                             ; $D102: 8D 0A 00
  STX a:$000B                             ; $D105: 8E 0B 00
  LDA a:$000C                             ; $D108: AD 0C 00
  JSR $F2D7                               ; $D10B: 20 D7 F2
  LDY #$0B                                ; $D10E: A0 0B
  LDA ($00),Y                             ; $D110: B1 00
  LSR                                     ; $D112: 4A
  LSR                                     ; $D113: 4A
  AND #$03                                ; $D114: 29 03
  ASL                                     ; $D116: 0A
  ASL                                     ; $D117: 0A
  ASL                                     ; $D118: 0A
  CLC                                     ; $D119: 18
  ADC $0544                               ; $D11A: 6D 44 05
  TAY                                     ; $D11D: A8
  LDA $D1B0,Y                             ; $D11E: B9 B0 D1
  STA a:$000D                             ; $D121: 8D 0D 00
  LDA $057A                               ; $D124: AD 7A 05
  CMP #$04                                ; $D127: C9 04
  BCC $D134                               ; $D129: 90 09
  LDA a:$000D                             ; $D12B: AD 0D 00
  CLC                                     ; $D12E: 18
  ADC #$04                                ; $D12F: 69 04
  STA a:$000D                             ; $D131: 8D 0D 00
Loc_D134:
  LDX a:$000D                             ; $D134: AE 0D 00
  LDY a:$000A                             ; $D137: AC 0A 00
  LDA $0544                               ; $D13A: AD 44 05
  CMP #$05                                ; $D13D: C9 05
  BEQ $D15A                               ; $D13F: F0 19
  LDA $D1C8,X                             ; $D141: BD C8 D1
  STA $0550,Y                             ; $D144: 99 50 05
  LDA $D1C9,X                             ; $D147: BD C9 D1
  STA $0551,Y                             ; $D14A: 99 51 05
  LDA $D1CA,X                             ; $D14D: BD CA D1
  STA $0552,Y                             ; $D150: 99 52 05
  LDA $D1CB,X                             ; $D153: BD CB D1
  STA $0553,Y                             ; $D156: 99 53 05
  RTS                                     ; $D159: 60
Loc_D15A:
  CPY #$04                                ; $D15A: C0 04
  BCS $D17B                               ; $D15C: B0 1D
  LDA #$02                                ; $D15E: A9 02
  STA $0550,Y                             ; $D160: 99 50 05
  LDA #$00                                ; $D163: A9 00
  STA $0551,Y                             ; $D165: 99 51 05
  STA $0552,Y                             ; $D168: 99 52 05
  STA $0553,Y                             ; $D16B: 99 53 05
  LDA $057A                               ; $D16E: AD 7A 05
  CMP #$04                                ; $D171: C9 04
  BCC $D17A                               ; $D173: 90 05
  LDA #$00                                ; $D175: A9 00
  STA $0550,Y                             ; $D177: 99 50 05
Loc_D17A:
  RTS                                     ; $D17A: 60
Loc_D17B:
  LDA #$02                                ; $D17B: A9 02
  STA $0550,Y                             ; $D17D: 99 50 05
  STA $0551,Y                             ; $D180: 99 51 05
  STA $0552,Y                             ; $D183: 99 52 05
  STA $0553,Y                             ; $D186: 99 53 05
  LDA $057A                               ; $D189: AD 7A 05
  CMP #$06                                ; $D18C: C9 06
  BCC $D195                               ; $D18E: 90 05
  LDA #$00                                ; $D190: A9 00
  STA $0551,Y                             ; $D192: 99 51 05
Loc_D195:
  LDY #$01                                ; $D195: A0 01
  LDX #$00                                ; $D197: A2 00
Loc_D199:
  LDA $0580,Y                             ; $D199: B9 80 05
  CMP #$08                                ; $D19C: C9 08
  BCS $D1A1                               ; $D19E: B0 01
  INX                                     ; $D1A0: E8
Loc_D1A1:
  INY                                     ; $D1A1: C8
  CPY #$0B                                ; $D1A2: C0 0B
  BCC $D199                               ; $D1A4: 90 F3
  CPX #$00                                ; $D1A6: E0 00
  BNE $D1AF                               ; $D1A8: D0 05
  LDA #$00                                ; $D1AA: A9 00
  STA $0556                               ; $D1AC: 8D 56 05
Loc_D1AF:
  RTS                                     ; $D1AF: 60
; --- Data Region ---
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$08,$00,$00,$00; $D1B0: 00 00 00 00 00 00 00 00 00 00 00 00 08 00 00 00
  .byte $00,$00,$00,$08,$00,$00,$00,$00,$02,$80,$80,$00,$80,$00,$00,$00; $D1C0: 00 00 00 08 00 00 00 00 02 80 80 00 80 00 00 00
  .byte $02,$00,$00,$00,$80,$00,$00,$00   ; $D1D0: 02 00 00 00 80 00 00 00
Loc_D1D8:
; --- Code Region ---
  STY $0545                               ; $D1D8: 8C 45 05
  LDA $05AC,Y                             ; $D1DB: B9 AC 05
  LDY $6F02                               ; $D1DE: AC 02 6F
  CMP $D1E7,Y                             ; $D1E1: D9 E7 D1
  BCC $D1ED                               ; $D1E4: 90 07
  RTS                                     ; $D1E6: 60
; --- Data Region ---
  .byte $2D,$28,$1E,$37,$32,$1E           ; $D1E7: 2D 28 1E 37 32 1E
Loc_D1ED:
; --- Code Region ---
  LDA #$00                                ; $D1ED: A9 00
  STA $0548                               ; $D1EF: 8D 48 05
  LDA #$01                                ; $D1F2: A9 01
  STA a:$0000                             ; $D1F4: 8D 00 00
  LDA #$00                                ; $D1F7: A9 00
  STA a:$0001                             ; $D1F9: 8D 01 00
  JSR $C1CD                               ; $D1FC: 20 CD C1
  BCS $D207                               ; $D1FF: B0 06
  TAY                                     ; $D201: A8
  BEQ $D207                               ; $D202: F0 03
  INC $0548                               ; $D204: EE 48 05
Loc_D207:
  LDA #$FF                                ; $D207: A9 FF
  STA a:$0000                             ; $D209: 8D 00 00
  LDA #$00                                ; $D20C: A9 00
  STA a:$0001                             ; $D20E: 8D 01 00
  JSR $C1CD                               ; $D211: 20 CD C1
  BCS $D21C                               ; $D214: B0 06
  TAY                                     ; $D216: A8
  BEQ $D21C                               ; $D217: F0 03
  INC $0548                               ; $D219: EE 48 05
Loc_D21C:
  LDA #$00                                ; $D21C: A9 00
  STA a:$0000                             ; $D21E: 8D 00 00
  LDA #$FF                                ; $D221: A9 FF
  STA a:$0001                             ; $D223: 8D 01 00
  JSR $C1CD                               ; $D226: 20 CD C1
  BCS $D231                               ; $D229: B0 06
  TAY                                     ; $D22B: A8
  BEQ $D231                               ; $D22C: F0 03
  INC $0548                               ; $D22E: EE 48 05
Loc_D231:
  LDA #$00                                ; $D231: A9 00
  STA a:$0000                             ; $D233: 8D 00 00
  LDA #$01                                ; $D236: A9 01
  STA a:$0001                             ; $D238: 8D 01 00
  JSR $C1CD                               ; $D23B: 20 CD C1
  BCS $D246                               ; $D23E: B0 06
  TAY                                     ; $D240: A8
  BEQ $D246                               ; $D241: F0 03
  INC $0548                               ; $D243: EE 48 05
Loc_D246:
  LDA $0548                               ; $D246: AD 48 05
  CMP #$02                                ; $D249: C9 02
  BCS $D24E                               ; $D24B: B0 01
Loc_D24D:
  RTS                                     ; $D24D: 60
Loc_D24E:
  LDA $0560                               ; $D24E: AD 60 05
  LDY $0545                               ; $D251: AC 45 05
  CPY #$0B                                ; $D254: C0 0B
  BCC $D25B                               ; $D256: 90 03
  LDA $0561                               ; $D258: AD 61 05
Loc_D25B:
  JSR $F2D7                               ; $D25B: 20 D7 F2
  LDY #$03                                ; $D25E: A0 03
  LDA ($00),Y                             ; $D260: B1 00
  CMP #$64                                ; $D262: C9 64
  BEQ $D24D                               ; $D264: F0 E7
  LDA #$64                                ; $D266: A9 64
  JSR $E862                               ; $D268: 20 62 E8
  LDY $6F02                               ; $D26B: AC 02 6F
  CMP $D1EA,Y                             ; $D26E: D9 EA D1
  BCS $D24D                               ; $D271: B0 DA
  PLA                                     ; $D273: 68
  PLA                                     ; $D274: 68
  JSR $E57F                               ; $D275: 20 7F E5
  LDA #$6C                                ; $D278: A9 6C
  JSR $E683                               ; $D27A: 20 83 E6
  LDA $0545                               ; $D27D: AD 45 05
  BNE $D2AB                               ; $D280: D0 29
  LDA $0560                               ; $D282: AD 60 05
  STA $042C                               ; $D285: 8D 2C 04
  STA $0514                               ; $D288: 8D 14 05
  LDA #$03                                ; $D28B: A9 03
  STA $0515                               ; $D28D: 8D 15 05
  LDA $0561                               ; $D290: AD 61 05
  STA $0516                               ; $D293: 8D 16 05
  LDA #$00                                ; $D296: A9 00
  STA $0517                               ; $D298: 8D 17 05
  LDA #$04                                ; $D29B: A9 04
  STA $0540                               ; $D29D: 8D 40 05
  LDA #$00                                ; $D2A0: A9 00
  STA $0541                               ; $D2A2: 8D 41 05
  LDA #$7D                                ; $D2A5: A9 7D
  JSR $F28B                               ; $D2A7: 20 8B F2
  RTS                                     ; $D2AA: 60
Loc_D2AB:
  LDA $0561                               ; $D2AB: AD 61 05
  STA $042C                               ; $D2AE: 8D 2C 04
  STA $0514                               ; $D2B1: 8D 14 05
  LDA #$03                                ; $D2B4: A9 03
  STA $0515                               ; $D2B6: 8D 15 05
  LDA $0561                               ; $D2B9: AD 61 05
  STA $0516                               ; $D2BC: 8D 16 05
  LDA #$00                                ; $D2BF: A9 00
  STA $0517                               ; $D2C1: 8D 17 05
  LDA #$04                                ; $D2C4: A9 04
  STA $0540                               ; $D2C6: 8D 40 05
  LDA #$00                                ; $D2C9: A9 00
  STA $0541                               ; $D2CB: 8D 41 05
  LDA #$7D                                ; $D2CE: A9 7D
  JSR $F28B                               ; $D2D0: 20 8B F2
  RTS                                     ; $D2D3: 60
Loc_D2D4:
  STY $0545                               ; $D2D4: 8C 45 05
  LDA $0545                               ; $D2D7: AD 45 05
  BNE $D2E5                               ; $D2DA: D0 09
  LDA $0550                               ; $D2DC: AD 50 05
  CMP #$01                                ; $D2DF: C9 01
  BNE $D2ED                               ; $D2E1: D0 0A
  BEQ $D2EC                               ; $D2E3: F0 07
Loc_D2E5:
  LDA $0554                               ; $D2E5: AD 54 05
  CMP #$01                                ; $D2E8: C9 01
  BNE $D2ED                               ; $D2EA: D0 01
Loc_D2EC:
  RTS                                     ; $D2EC: 60
Loc_D2ED:
  JSR $D32A                               ; $D2ED: 20 2A D3
  TYA                                     ; $D2F0: 98
  BNE $D317                               ; $D2F1: D0 24
  LDA #$64                                ; $D2F3: A9 64
  JSR $E862                               ; $D2F5: 20 62 E8
  LDY $6F02                               ; $D2F8: AC 02 6F
  CMP $D327,Y                             ; $D2FB: D9 27 D3
  BCS $D317                               ; $D2FE: B0 17
  PLA                                     ; $D300: 68
  PLA                                     ; $D301: 68
  PLA                                     ; $D302: 68
  PLA                                     ; $D303: 68
  LDA $0545                               ; $D304: AD 45 05
  BNE $D318                               ; $D307: D0 0F
  LDA #$01                                ; $D309: A9 01
  STA $0550                               ; $D30B: 8D 50 05
  STA $0551                               ; $D30E: 8D 51 05
  STA $0552                               ; $D311: 8D 52 05
  STA $0553                               ; $D314: 8D 53 05
Loc_D317:
  RTS                                     ; $D317: 60
Loc_D318:
  LDA #$01                                ; $D318: A9 01
  STA $0554                               ; $D31A: 8D 54 05
  STA $0555                               ; $D31D: 8D 55 05
  STA $0556                               ; $D320: 8D 56 05
  STA $0557                               ; $D323: 8D 57 05
  RTS                                     ; $D326: 60
; --- Data Region ---
  .byte $1E,$28,$2D                       ; $D327: 1E 28 2D
Loc_D32A:
; --- Code Region ---
  LDY #$00                                ; $D32A: A0 00
  LDX #$00                                ; $D32C: A2 00
  STX a:$0000                             ; $D32E: 8E 00 00
  STX a:$0001                             ; $D331: 8E 01 00
Loc_D334:
  LDA $0581,Y                             ; $D334: B9 81 05
  BMI $D34B                               ; $D337: 30 12
  LDA $05AD,Y                             ; $D339: B9 AD 05
  CLC                                     ; $D33C: 18
  ADC a:$0000                             ; $D33D: 6D 00 00
  STA a:$0000                             ; $D340: 8D 00 00
  LDA a:$0001                             ; $D343: AD 01 00
  ADC #$00                                ; $D346: 69 00
  STA a:$0001                             ; $D348: 8D 01 00
Loc_D34B:
  INY                                     ; $D34B: C8
  INX                                     ; $D34C: E8
  CPX #$0A                                ; $D34D: E0 0A
  BCC $D334                               ; $D34F: 90 E3
  LDY #$00                                ; $D351: A0 00
  LDX #$00                                ; $D353: A2 00
  STX a:$0002                             ; $D355: 8E 02 00
  STX a:$0003                             ; $D358: 8E 03 00
Loc_D35B:
  LDA $058C,Y                             ; $D35B: B9 8C 05
  BMI $D372                               ; $D35E: 30 12
  LDA $05B8,Y                             ; $D360: B9 B8 05
  CLC                                     ; $D363: 18
  ADC a:$0002                             ; $D364: 6D 02 00
  STA a:$0002                             ; $D367: 8D 02 00
  LDA a:$0003                             ; $D36A: AD 03 00
  ADC #$00                                ; $D36D: 69 00
  STA a:$0003                             ; $D36F: 8D 03 00
Loc_D372:
  INY                                     ; $D372: C8
  INX                                     ; $D373: E8
  CPX #$0A                                ; $D374: E0 0A
  BCC $D35B                               ; $D376: 90 E3
  LDA $0545                               ; $D378: AD 45 05
  BEQ $D395                               ; $D37B: F0 18
  LDX a:$0000                             ; $D37D: AE 00 00
  LDY a:$0001                             ; $D380: AC 01 00
  LDA a:$0002                             ; $D383: AD 02 00
  STA a:$0000                             ; $D386: 8D 00 00
  LDA a:$0003                             ; $D389: AD 03 00
  STA a:$0001                             ; $D38C: 8D 01 00
  STX a:$0002                             ; $D38F: 8E 02 00
  STY a:$0003                             ; $D392: 8C 03 00
Loc_D395:
  LDA a:$0001                             ; $D395: AD 01 00
  BNE $D3C4                               ; $D398: D0 2A
  LDA a:$0000                             ; $D39A: AD 00 00
  CMP #$C8                                ; $D39D: C9 C8
  BCS $D3C4                               ; $D39F: B0 23
  LDA a:$0000                             ; $D3A1: AD 00 00
  CLC                                     ; $D3A4: 18
  ADC #$90                                ; $D3A5: 69 90
  STA a:$0000                             ; $D3A7: 8D 00 00
  LDA a:$0001                             ; $D3AA: AD 01 00
  ADC #$01                                ; $D3AD: 69 01
  STA a:$0001                             ; $D3AF: 8D 01 00
  LDA a:$0000                             ; $D3B2: AD 00 00
  SEC                                     ; $D3B5: 38
  SBC a:$0002                             ; $D3B6: ED 02 00
  LDA a:$0001                             ; $D3B9: AD 01 00
  SBC a:$0003                             ; $D3BC: ED 03 00
  BCS $D3C4                               ; $D3BF: B0 03
  LDY #$00                                ; $D3C1: A0 00
  RTS                                     ; $D3C3: 60
Loc_D3C4:
  LDY #$FF                                ; $D3C4: A0 FF
  RTS                                     ; $D3C6: 60
Loc_D3C7:
  STX $057C                               ; $D3C7: 8E 7C 05
  STX $0549                               ; $D3CA: 8E 49 05
  STY $0545                               ; $D3CD: 8C 45 05
  LDA $0574                               ; $D3D0: AD 74 05
  ORA $0575                               ; $D3D3: 0D 75 05
  ORA $0576                               ; $D3D6: 0D 76 05
  ORA $0577                               ; $D3D9: 0D 77 05
  LDX $0572                               ; $D3DC: AE 72 05
  CPY #$00                                ; $D3DF: C0 00
  BEQ $D3EA                               ; $D3E1: F0 07
  LSR                                     ; $D3E3: 4A
  LSR                                     ; $D3E4: 4A
  LSR                                     ; $D3E5: 4A
  LSR                                     ; $D3E6: 4A
  LDX $0573                               ; $D3E7: AE 73 05
Loc_D3EA:
  STX $0548                               ; $D3EA: 8E 48 05
  AND #$0F                                ; $D3ED: 29 0F
  BEQ $D3F2                               ; $D3EF: F0 01
  RTS                                     ; $D3F1: 60
Loc_D3F2:
  LDX $0548                               ; $D3F2: AE 48 05
  CPX #$0C                                ; $D3F5: E0 0C
  BCC $D3FC                               ; $D3F7: 90 03
  JSR $D42F                               ; $D3F9: 20 2F D4
Loc_D3FC:
  LDX $0548                               ; $D3FC: AE 48 05
  CPX #$0A                                ; $D3FF: E0 0A
  BCC $D406                               ; $D401: 90 03
  JSR $D506                               ; $D403: 20 06 D5
Loc_D406:
  LDX $0548                               ; $D406: AE 48 05
  CPX #$08                                ; $D409: E0 08
  BCC $D410                               ; $D40B: 90 03
  JSR $D5A0                               ; $D40D: 20 A0 D5
Loc_D410:
  LDX $0548                               ; $D410: AE 48 05
  CPX #$07                                ; $D413: E0 07
  BCC $D41A                               ; $D415: 90 03
  JSR $D5BC                               ; $D417: 20 BC D5
Loc_D41A:
  LDX $0548                               ; $D41A: AE 48 05
  CPX #$05                                ; $D41D: E0 05
  BCC $D424                               ; $D41F: 90 03
  JSR $D652                               ; $D421: 20 52 D6
Loc_D424:
  LDX $0548                               ; $D424: AE 48 05
  CPX #$03                                ; $D427: E0 03
  BCC $D42E                               ; $D429: 90 03
  JSR $D612                               ; $D42B: 20 12 D6
Loc_D42E:
  RTS                                     ; $D42E: 60
Loc_D42F:
  LDY $0545                               ; $D42F: AC 45 05
  LDA $05C2,Y                             ; $D432: B9 C2 05
  LSR                                     ; $D435: 4A
  LSR                                     ; $D436: 4A
  LSR                                     ; $D437: 4A
  LSR                                     ; $D438: 4A
  STA $057D                               ; $D439: 8D 7D 05
  LDA #$00                                ; $D43C: A9 00
  STA $057E                               ; $D43E: 8D 7E 05
Loc_D441:
  PHA                                     ; $D441: 48
  TAY                                     ; $D442: A8
  LDA $057D                               ; $D443: AD 7D 05
  ASL                                     ; $D446: 0A
  TAX                                     ; $D447: AA
  LDA $D4AA,X                             ; $D448: BD AA D4
  STA a:$000A                             ; $D44B: 8D 0A 00
  LDA $D4AB,X                             ; $D44E: BD AB D4
  STA a:$000B                             ; $D451: 8D 0B 00
  LDA ($0A),Y                             ; $D454: B1 0A
  STA a:$0000                             ; $D456: 8D 00 00
  TYA                                     ; $D459: 98
  CLC                                     ; $D45A: 18
  ADC #$09                                ; $D45B: 69 09
  TAY                                     ; $D45D: A8
  LDA ($0A),Y                             ; $D45E: B1 0A
  STA a:$0001                             ; $D460: 8D 01 00
  JSR $C1CD                               ; $D463: 20 CD C1
  BCS $D46E                               ; $D466: B0 06
  TAY                                     ; $D468: A8
  BEQ $D46E                               ; $D469: F0 03
  INC $057E                               ; $D46B: EE 7E 05
Loc_D46E:
  PLA                                     ; $D46E: 68
  CLC                                     ; $D46F: 18
  ADC #$01                                ; $D470: 69 01
  CMP #$09                                ; $D472: C9 09
  BCC $D441                               ; $D474: 90 CB
  LDY $057E                               ; $D476: AC 7E 05
  LDA $D4FA,Y                             ; $D479: B9 FA D4
  BEQ $D48B                               ; $D47C: F0 0D
  STA a:$000A                             ; $D47E: 8D 0A 00
  LDA #$64                                ; $D481: A9 64
  JSR $E862                               ; $D483: 20 62 E8
  CMP a:$000A                             ; $D486: CD 0A 00
  BCC $D48C                               ; $D489: 90 01
Loc_D48B:
  RTS                                     ; $D48B: 60
Loc_D48C:
  PLA                                     ; $D48C: 68
  PLA                                     ; $D48D: 68
  LDA #$09                                ; $D48E: A9 09
  STA $0540                               ; $D490: 8D 40 05
  LDA #$00                                ; $D493: A9 00
  STA $0541                               ; $D495: 8D 41 05
  LDA #$F1                                ; $D498: A9 F1
  JSR $F26D                               ; $D49A: 20 6D F2
  LDY $057C                               ; $D49D: AC 7C 05
  LDA $0572,Y                             ; $D4A0: B9 72 05
  SEC                                     ; $D4A3: 38
  SBC #$0C                                ; $D4A4: E9 0C
  STA $0572,Y                             ; $D4A6: 99 72 05
  RTS                                     ; $D4A9: 60
; --- Data Region ---
  .byte $B2,$D4,$C4,$D4,$D6,$D4,$E8,$D4,$FF,$FF,$FF,$00,$00,$00,$01,$01; $D4AA: B2 D4 C4 D4 D6 D4 E8 D4 FF FF FF 00 00 00 01 01
  .byte $01,$01,$02,$03,$01,$02,$03,$01,$02,$03,$FF,$FF,$FF,$00,$00,$00; $D4BA: 01 01 02 03 01 02 03 01 02 03 FF FF FF 00 00 00
  .byte $01,$01,$01,$FF,$FE,$FD,$FF,$FE,$FD,$FF,$FE,$FD,$FF,$FF,$FF,$FE; $D4CA: 01 01 01 FF FE FD FF FE FD FF FE FD FF FF FF FE
  .byte $FE,$FE,$FD,$FD,$FD,$FF,$00,$01,$FF,$00,$01,$FF,$00,$01,$01,$01; $D4DA: FE FE FD FD FD FF 00 01 FF 00 01 FF 00 01 01 01
  .byte $01,$02,$02,$02,$03,$03,$03,$FF,$00,$01,$FF,$00,$01,$FF,$00,$01; $D4EA: 01 02 02 02 03 03 03 FF 00 01 FF 00 01 FF 00 01
  .byte $00,$00,$28,$46,$64,$64,$64,$64,$64,$64,$64,$64; $D4FA: 00 00 28 46 64 64 64 64 64 64 64 64
Loc_D506:
; --- Code Region ---
  LDA #$00                                ; $D506: A9 00
  STA $057E                               ; $D508: 8D 7E 05
  LDA $0545                               ; $D50B: AD 45 05
  PHA                                     ; $D50E: 48
Loc_D50F:
  LDY $0545                               ; $D50F: AC 45 05
  LDA $05C2,Y                             ; $D512: B9 C2 05
  AND #$0F                                ; $D515: 29 0F
  CMP #$02                                ; $D517: C9 02
  BNE $D51E                               ; $D519: D0 03
  JSR $D558                               ; $D51B: 20 58 D5
Loc_D51E:
  INC $0545                               ; $D51E: EE 45 05
  LDA $0545                               ; $D521: AD 45 05
  CMP #$0B                                ; $D524: C9 0B
  BEQ $D52C                               ; $D526: F0 04
  CMP #$16                                ; $D528: C9 16
  BNE $D50F                               ; $D52A: D0 E3
Loc_D52C:
  PLA                                     ; $D52C: 68
  STA $0545                               ; $D52D: 8D 45 05
  LDY $057E                               ; $D530: AC 7E 05
  LDA $D594,Y                             ; $D533: B9 94 D5
  BEQ $D545                               ; $D536: F0 0D
  STA a:$000A                             ; $D538: 8D 0A 00
  LDA #$64                                ; $D53B: A9 64
  JSR $E862                               ; $D53D: 20 62 E8
  CMP a:$000A                             ; $D540: CD 0A 00
  BCC $D546                               ; $D543: 90 01
Loc_D545:
  RTS                                     ; $D545: 60
Loc_D546:
  JSR $B084                               ; $D546: 20 84 B0
  LDY $057C                               ; $D549: AC 7C 05
  LDA $0572,Y                             ; $D54C: B9 72 05
  SEC                                     ; $D54F: 38
  SBC #$0A                                ; $D550: E9 0A
  STA $0572,Y                             ; $D552: 99 72 05
  PLA                                     ; $D555: 68
  PLA                                     ; $D556: 68
  RTS                                     ; $D557: 60
Loc_D558:
  LDA #$00                                ; $D558: A9 00
Loc_D55A:
  PHA                                     ; $D55A: 48
  TAY                                     ; $D55B: A8
  LDA $D57C,Y                             ; $D55C: B9 7C D5
  STA a:$0000                             ; $D55F: 8D 00 00
  LDA $D588,Y                             ; $D562: B9 88 D5
  STA a:$0001                             ; $D565: 8D 01 00
  JSR $C1CD                               ; $D568: 20 CD C1
  BCS $D573                               ; $D56B: B0 06
  TAY                                     ; $D56D: A8
  BEQ $D573                               ; $D56E: F0 03
  INC $057E                               ; $D570: EE 7E 05
Loc_D573:
  PLA                                     ; $D573: 68
  CLC                                     ; $D574: 18
  ADC #$01                                ; $D575: 69 01
  CMP #$09                                ; $D577: C9 09
  BCC $D55A                               ; $D579: 90 DF
  RTS                                     ; $D57B: 60
; --- Data Region ---
  .byte $00,$00,$00,$00,$00,$00,$FE,$FD,$FC,$02,$03,$04,$02,$03,$04,$FE; $D57C: 00 00 00 00 00 00 FE FD FC 02 03 04 02 03 04 FE
  .byte $FD,$FC,$00,$00,$00,$00,$00,$00,$00,$00,$28,$46,$64,$64,$64,$64; $D58C: FD FC 00 00 00 00 00 00 00 00 28 46 64 64 64 64
  .byte $64,$64,$64,$64                   ; $D59C: 64 64 64 64
Loc_D5A0:
; --- Code Region ---
  LDA #$64                                ; $D5A0: A9 64
  JSR $E862                               ; $D5A2: 20 62 E8
  CMP #$14                                ; $D5A5: C9 14
  BCC $D5AA                               ; $D5A7: 90 01
  RTS                                     ; $D5A9: 60
Loc_D5AA:
  JSR $B036                               ; $D5AA: 20 36 B0
  LDY $057C                               ; $D5AD: AC 7C 05
  LDA $0572,Y                             ; $D5B0: B9 72 05
  SEC                                     ; $D5B3: 38
  SBC #$08                                ; $D5B4: E9 08
  STA $0572,Y                             ; $D5B6: 99 72 05
  PLA                                     ; $D5B9: 68
  PLA                                     ; $D5BA: 68
  RTS                                     ; $D5BB: 60
Loc_D5BC:
  JSR $D5F3                               ; $D5BC: 20 F3 D5
  LDY a:$0000                             ; $D5BF: AC 00 00
  BEQ $D5D4                               ; $D5C2: F0 10
  LDA $D5E7,Y                             ; $D5C4: B9 E7 D5
  STA a:$000A                             ; $D5C7: 8D 0A 00
  LDA #$64                                ; $D5CA: A9 64
  JSR $E862                               ; $D5CC: 20 62 E8
  CMP a:$000A                             ; $D5CF: CD 0A 00
  BCC $D5D5                               ; $D5D2: 90 01
Loc_D5D4:
  RTS                                     ; $D5D4: 60
Loc_D5D5:
  JSR $B016                               ; $D5D5: 20 16 B0
  LDY $057C                               ; $D5D8: AC 7C 05
  LDA $0572,Y                             ; $D5DB: B9 72 05
  SEC                                     ; $D5DE: 38
  SBC #$07                                ; $D5DF: E9 07
  STA $0572,Y                             ; $D5E1: 99 72 05
  PLA                                     ; $D5E4: 68
  PLA                                     ; $D5E5: 68
  RTS                                     ; $D5E6: 60
; --- Data Region ---
  .byte $00,$00,$30,$50,$80,$80,$80,$80,$80,$80,$80,$80; $D5E7: 00 00 30 50 80 80 80 80 80 80 80 80
Loc_D5F3:
; --- Code Region ---
  LDY $0545                               ; $D5F3: AC 45 05
  LDX #$00                                ; $D5F6: A2 00
  STX a:$0000                             ; $D5F8: 8E 00 00
Loc_D5FB:
  LDA $05C2,Y                             ; $D5FB: B9 C2 05
  CMP #$FF                                ; $D5FE: C9 FF
  BEQ $D60B                               ; $D600: F0 09
  AND #$0F                                ; $D602: 29 0F
  CMP #$02                                ; $D604: C9 02
  BNE $D60B                               ; $D606: D0 03
  INC a:$0000                             ; $D608: EE 00 00
Loc_D60B:
  INY                                     ; $D60B: C8
  INX                                     ; $D60C: E8
  CPX #$0B                                ; $D60D: E0 0B
  BCC $D5FB                               ; $D60F: 90 EA
  RTS                                     ; $D611: 60
Loc_D612:
  LDA $0545                               ; $D612: AD 45 05
  PHA                                     ; $D615: 48
  LDA $057C                               ; $D616: AD 7C 05
  EOR #$01                                ; $D619: 49 01
  STA $0545                               ; $D61B: 8D 45 05
  JSR $D32A                               ; $D61E: 20 2A D3
  PLA                                     ; $D621: 68
  STA $0545                               ; $D622: 8D 45 05
  TYA                                     ; $D625: 98
  BNE $D631                               ; $D626: D0 09
  LDA #$64                                ; $D628: A9 64
  JSR $E862                               ; $D62A: 20 62 E8
  CMP #$32                                ; $D62D: C9 32
  BCC $D632                               ; $D62F: 90 01
Loc_D631:
  RTS                                     ; $D631: 60
Loc_D632:
  LDY $057C                               ; $D632: AC 7C 05
  LDA $0572,Y                             ; $D635: B9 72 05
  SEC                                     ; $D638: 38
  SBC #$03                                ; $D639: E9 03
Loc_D63B:
  STA $0572,Y                             ; $D63B: 99 72 05
  JSR $E87A                               ; $D63E: 20 7A E8
  AND #$01                                ; $D641: 29 01
  BNE $D631                               ; $D643: D0 EC
  PLA                                     ; $D645: 68
  PLA                                     ; $D646: 68
  LDA #$0A                                ; $D647: A9 0A
  STA $0540                               ; $D649: 8D 40 05
  LDA #$00                                ; $D64C: A9 00
  STA $0541                               ; $D64E: 8D 41 05
  RTS                                     ; $D651: 60
Loc_D652:
  LDA $0570                               ; $D652: AD 70 05
  STA a:$000A                             ; $D655: 8D 0A 00
  LDA $0571                               ; $D658: AD 71 05
  STA a:$000B                             ; $D65B: 8D 0B 00
  LDA $05AC                               ; $D65E: AD AC 05
  STA a:$000C                             ; $D661: 8D 0C 00
  LDA $05B7                               ; $D664: AD B7 05
  STA a:$000D                             ; $D667: 8D 0D 00
  LDA $0545                               ; $D66A: AD 45 05
  BEQ $D687                               ; $D66D: F0 18
  LDX a:$000A                             ; $D66F: AE 0A 00
  LDA a:$000B                             ; $D672: AD 0B 00
  STA a:$000A                             ; $D675: 8D 0A 00
  STX a:$000B                             ; $D678: 8E 0B 00
  LDX a:$000C                             ; $D67B: AE 0C 00
  LDA a:$000D                             ; $D67E: AD 0D 00
  STA a:$000C                             ; $D681: 8D 0C 00
  STX a:$000D                             ; $D684: 8E 0D 00
Loc_D687:
  LDA a:$000A                             ; $D687: AD 0A 00
  CMP a:$000B                             ; $D68A: CD 0B 00
  BCC $D697                               ; $D68D: 90 08
  LDA a:$000C                             ; $D68F: AD 0C 00
  CMP a:$000D                             ; $D692: CD 0D 00
  BCS $D698                               ; $D695: B0 01
Loc_D697:
  RTS                                     ; $D697: 60
Loc_D698:
  LDA #$64                                ; $D698: A9 64
  JSR $E862                               ; $D69A: 20 62 E8
  CMP #$28                                ; $D69D: C9 28
  BCS $D697                               ; $D69F: B0 F6
  PLA                                     ; $D6A1: 68
  PLA                                     ; $D6A2: 68
  LDA #$0A                                ; $D6A3: A9 0A
  STA $0540                               ; $D6A5: 8D 40 05
  LDA #$04                                ; $D6A8: A9 04
  STA $0541                               ; $D6AA: 8D 41 05
  LDY $057C                               ; $D6AD: AC 7C 05
  LDA $0572,Y                             ; $D6B0: B9 72 05
  SEC                                     ; $D6B3: 38
  SBC #$05                                ; $D6B4: E9 05
  STA $0572,Y                             ; $D6B6: 99 72 05
  RTS                                     ; $D6B9: 60
; --- Data Region ---
Loc_D6BA:  ; (dispatch callback target - phase $A handler, undecoded)
  .byte $AD,$41,$05,$20,$DE,$EA,$CC,$D6,$DD,$D6,$2A,$D7,$2A,$D7,$43,$D7; $D6BA: AD 41 05 20 DE EA CC D6 DD D6 2A D7 2A D7 43 D7
  .byte $7F,$D7                           ; $D6CA: 7F D7
Loc_D6CC:  ; (dispatch callback target)
; --- Code Region ---
  INC $0541                               ; $D6CC: EE 41 05
  LDA #$00                                ; $D6CF: A9 00
  STA $0548                               ; $D6D1: 8D 48 05
  LDA #$7B                                ; $D6D4: A9 7B
  JSR $F26D                               ; $D6D6: 20 6D F2
  JSR $AFF6                               ; $D6D9: 20 F6 AF
  RTS                                     ; $D6DC: 60
Loc_D6DD:  ; (dispatch callback target)
  LDA $057C                               ; $D6DD: AD 7C 05
  PHA                                     ; $D6E0: 48
  EOR #$01                                ; $D6E1: 49 01
  STA $057C                               ; $D6E3: 8D 7C 05
  JSR $D72B                               ; $D6E6: 20 2B D7
  PLA                                     ; $D6E9: 68
  STA $057C                               ; $D6EA: 8D 7C 05
  JSR $CD22                               ; $D6ED: 20 22 CD
  JSR $B870                               ; $D6F0: 20 70 B8
  BCC $D72A                               ; $D6F3: 90 35
  LDA a:$0001                             ; $D6F5: AD 01 00
  AND #$01                                ; $D6F8: 29 01
  BEQ $D72A                               ; $D6FA: F0 2E
Loc_D6FC:
  LDA #$03                                ; $D6FC: A9 03
  STA $0540                               ; $D6FE: 8D 40 05
  LDA #$03                                ; $D701: A9 03
  STA $0541                               ; $D703: 8D 41 05
  LDA #$00                                ; $D706: A9 00
  STA $0545                               ; $D708: 8D 45 05
  STA $0546                               ; $D70B: 8D 46 05
  LDA #$01                                ; $D70E: A9 01
  STA $054B                               ; $D710: 8D 4B 05
  LDA #$01                                ; $D713: A9 01
  STA $054C                               ; $D715: 8D 4C 05
  LDA #$E8                                ; $D718: A9 E8
  STA $0310                               ; $D71A: 8D 10 03
  LDA #$E9                                ; $D71D: A9 E9
  STA $0311                               ; $D71F: 8D 11 03
  LDA #$00                                ; $D722: A9 00
  STA $0300                               ; $D724: 8D 00 03
  JSR $CBF1                               ; $D727: 20 F1 CB
Loc_D72A:  ; (dispatch callback target)
  RTS                                     ; $D72A: 60
Loc_D72B:
  LDY $057C                               ; $D72B: AC 7C 05
  LDA $0560,Y                             ; $D72E: B9 60 05
  STA a:$0000                             ; $D731: 8D 00 00
  LDA #$A5                                ; $D734: A9 A5
  STA a:$000A                             ; $D736: 8D 0A 00
  LDX #$00                                ; $D739: A2 00
  LDY #$39                                ; $D73B: A0 39
  JSR $EE07                               ; $D73D: 20 07 EE
; --- Data Region ---
  .byte $00,$A0,$60                       ; $D740: 00 A0 60
Loc_D743:  ; (dispatch callback target)
; --- Code Region ---
  INC $0541                               ; $D743: EE 41 05
  LDA #$00                                ; $D746: A9 00
  STA $0548                               ; $D748: 8D 48 05
  LDA #$7C                                ; $D74B: A9 7C
  JSR $F26D                               ; $D74D: 20 6D F2
  LDY $057C                               ; $D750: AC 7C 05
  LDA $0560,Y                             ; $D753: B9 60 05
  STA $042C                               ; $D756: 8D 2C 04
  LDA #$09                                ; $D759: A9 09
  STA a:$00BB                             ; $D75B: 8D BB 00
  LDA $057C                               ; $D75E: AD 7C 05
  EOR #$01                                ; $D761: 49 01
  TAY                                     ; $D763: A8
  LDA $0560,Y                             ; $D764: B9 60 05
  STA a:$0000                             ; $D767: 8D 00 00
  LDA #$00                                ; $D76A: A9 00
  STA a:$0001                             ; $D76C: 8D 01 00
  LDY #$3D                                ; $D76F: A0 3D
  JSR $EE07                               ; $D771: 20 07 EE
; --- Data Region ---
  .byte $3C,$A0,$A9,$00,$8D,$24,$04,$8D,$25,$04,$60; $D774: 3C A0 A9 00 8D 24 04 8D 25 04 60
Loc_D77F:  ; (dispatch callback target)
; --- Code Region ---
  LDA $057C                               ; $D77F: AD 7C 05
  PHA                                     ; $D782: 48
  EOR #$01                                ; $D783: 49 01
  STA $057C                               ; $D785: 8D 7C 05
  JSR $D72B                               ; $D788: 20 2B D7
  PLA                                     ; $D78B: 68
  STA $057C                               ; $D78C: 8D 7C 05
  LDA a:$0081                             ; $D78F: AD 81 00
  PHA                                     ; $D792: 48
  JSR $CD22                               ; $D793: 20 22 CD
  LDA a:$0001                             ; $D796: AD 01 00
  STA a:$0081                             ; $D799: 8D 81 00
  LDA #$EE                                ; $D79C: A9 EE
  STA a:$0010                             ; $D79E: 8D 10 00
  LDA #$D7                                ; $D7A1: A9 D7
  STA a:$0011                             ; $D7A3: 8D 11 00
  LDA #$00                                ; $D7A6: A9 00
  STA a:$0012                             ; $D7A8: 8D 12 00
  JSR $ED1E                               ; $D7AB: 20 1E ED
  PLA                                     ; $D7AE: 68
  STA a:$0081                             ; $D7AF: 8D 81 00
  LDA #$F2                                ; $D7B2: A9 F2
  STA a:$0010                             ; $D7B4: 8D 10 00
  LDA #$D7                                ; $D7B7: A9 D7
  STA a:$0011                             ; $D7B9: 8D 11 00
  LDA #$F6                                ; $D7BC: A9 F6
  STA a:$0000                             ; $D7BE: 8D 00 00
  LDA #$D7                                ; $D7C1: A9 D7
  STA a:$0001                             ; $D7C3: 8D 01 00
  LDA a:$0012                             ; $D7C6: AD 12 00
  JSR $EDF5                               ; $D7C9: 20 F5 ED
  JSR $B870                               ; $D7CC: 20 70 B8
  BCC $D7ED                               ; $D7CF: 90 1C
  JSR $CD22                               ; $D7D1: 20 22 CD
  LDA a:$0001                             ; $D7D4: AD 01 00
  AND #$01                                ; $D7D7: 29 01
  BEQ $D7ED                               ; $D7D9: F0 12
  LDA a:$0012                             ; $D7DB: AD 12 00
  BEQ $D7E3                               ; $D7DE: F0 03
  JMP $D6FC                               ; $D7E0: 4C FC D6
Loc_D7E3:
  LDA #$05                                ; $D7E3: A9 05
  STA $0540                               ; $D7E5: 8D 40 05
  LDA #$00                                ; $D7E8: A9 00
  STA $0541                               ; $D7EA: 8D 41 05
Loc_D7ED:
  RTS                                     ; $D7ED: 60
; --- Data Region ---
  .byte $00,$01,$FF,$FF,$CE,$48,$CE,$88,$00,$07,$00,$00,$80; $D7EE: 00 01 FF FF CE 48 CE 88 00 07 00 00 80
Loc_D7FB:
; --- Code Region ---
  LDA a:$000A                             ; $D7FB: AD 0A 00
  JSR $F2D7                               ; $D7FE: 20 D7 F2
  LSR a:$000C                             ; $D801: 4E 0C 00
  ROR a:$000B                             ; $D804: 6E 0B 00
  LDY #$06                                ; $D807: A0 06
  LDA ($00),Y                             ; $D809: B1 00
  CLC                                     ; $D80B: 18
  ADC a:$000B                             ; $D80C: 6D 0B 00
  STA a:$000D                             ; $D80F: 8D 0D 00
  STA ($00),Y                             ; $D812: 91 00
  INY                                     ; $D814: C8
  LDA ($00),Y                             ; $D815: B1 00
  ADC a:$000C                             ; $D817: 6D 0C 00
  STA a:$000E                             ; $D81A: 8D 0E 00
  STA ($00),Y                             ; $D81D: 91 00
  LDY #$06                                ; $D81F: A0 06
  LDA ($00),Y                             ; $D821: B1 00
  SEC                                     ; $D823: 38
  SBC #$4F                                ; $D824: E9 4F
  INY                                     ; $D826: C8
  LDA ($00),Y                             ; $D827: B1 00
  SBC #$C3                                ; $D829: E9 C3
  BCC $D838                               ; $D82B: 90 0B
  LDY #$06                                ; $D82D: A0 06
  LDA #$4F                                ; $D82F: A9 4F
  STA ($00),Y                             ; $D831: 91 00
  INY                                     ; $D833: C8
  LDA #$C3                                ; $D834: A9 C3
  STA ($00),Y                             ; $D836: 91 00
Loc_D838:
  LDY #$0B                                ; $D838: A0 0B
  LDA ($00),Y                             ; $D83A: B1 00
  AND #$F0                                ; $D83C: 29 F0
  LSR                                     ; $D83E: 4A
  LSR                                     ; $D83F: 4A
  LSR                                     ; $D840: 4A
  CMP #$0E                                ; $D841: C9 0E
  BCS $D855                               ; $D843: B0 10
  TAY                                     ; $D845: A8
  LDA a:$000D                             ; $D846: AD 0D 00
  SEC                                     ; $D849: 38
  SBC $D85B,Y                             ; $D84A: F9 5B D8
  LDA a:$000E                             ; $D84D: AD 0E 00
  SBC $D85C,Y                             ; $D850: F9 5C D8
  BCS $D869                               ; $D853: B0 14
Loc_D855:
  LDA #$00                                ; $D855: A9 00
  STA a:$000F                             ; $D857: 8D 0F 00
  RTS                                     ; $D85A: 60
; --- Data Region ---
  .byte $E8,$03,$D0,$07,$AC,$0D,$88,$13,$4C,$1D,$10,$27,$98,$3A; $D85B: E8 03 D0 07 AC 0D 88 13 4C 1D 10 27 98 3A
Loc_D869:
; --- Code Region ---
  TYA                                     ; $D869: 98
  LSR                                     ; $D86A: 4A
  CLC                                     ; $D86B: 18
  ADC #$01                                ; $D86C: 69 01
  ASL                                     ; $D86E: 0A
  ASL                                     ; $D86F: 0A
  ASL                                     ; $D870: 0A
  ASL                                     ; $D871: 0A
  STA a:$000F                             ; $D872: 8D 0F 00
  LDY #$0B                                ; $D875: A0 0B
  LDA ($00),Y                             ; $D877: B1 00
  AND #$F0                                ; $D879: 29 F0
  CMP a:$000F                             ; $D87B: CD 0F 00
  BCS $D855                               ; $D87E: B0 D5
  LDY #$0B                                ; $D880: A0 0B
  LDA ($00),Y                             ; $D882: B1 00
  AND #$0F                                ; $D884: 29 0F
  ORA a:$000F                             ; $D886: 0D 0F 00
  STA ($00),Y                             ; $D889: 91 00
  LDY #$01                                ; $D88B: A0 01
  LDA ($00),Y                             ; $D88D: B1 00
  LDY #$06                                ; $D88F: A0 06
  CMP #$33                                ; $D891: C9 33
  BCC $D8A7                               ; $D893: 90 12
  LDY #$05                                ; $D895: A0 05
  CMP #$47                                ; $D897: C9 47
  BCC $D8A7                               ; $D899: 90 0C
  LDY #$04                                ; $D89B: A0 04
  CMP #$51                                ; $D89D: C9 51
  BCC $D8A7                               ; $D89F: 90 06
  LDY #$02                                ; $D8A1: A0 02
  CMP #$5A                                ; $D8A3: C9 5A
  BCS $D8AF                               ; $D8A5: B0 08
Loc_D8A7:
  TYA                                     ; $D8A7: 98
  LDY #$01                                ; $D8A8: A0 01
  CLC                                     ; $D8AA: 18
  ADC ($00),Y                             ; $D8AB: 71 00
  STA ($00),Y                             ; $D8AD: 91 00
Loc_D8AF:
  RTS                                     ; $D8AF: 60
Loc_D8B0:
  LDA a:$000B                             ; $D8B0: AD 0B 00
  JSR $F2D7                               ; $D8B3: 20 D7 F2
  LDA #$00                                ; $D8B6: A9 00
  STA a:$000B                             ; $D8B8: 8D 0B 00
  STA a:$000C                             ; $D8BB: 8D 0C 00
  LDY #$01                                ; $D8BE: A0 01
  LDA ($00),Y                             ; $D8C0: B1 00
  INY                                     ; $D8C2: C8
  CLC                                     ; $D8C3: 18
  ADC ($00),Y                             ; $D8C4: 71 00
  STA a:$000B                             ; $D8C6: 8D 0B 00
  LDA a:$000C                             ; $D8C9: AD 0C 00
  ADC #$00                                ; $D8CC: 69 00
  STA a:$000C                             ; $D8CE: 8D 0C 00
  JMP $D7FB                               ; $D8D1: 4C FB D7
Loc_D8D4:
  LDY #$22                                ; $D8D4: A0 22
  JSR $F25F                               ; $D8D6: 20 5F F2
  LDA #$23                                ; $D8D9: A9 23
  STA a:$00E2                             ; $D8DB: 8D E2 00
  ORA #$C0                                ; $D8DE: 09 C0
  STA $E800                               ; $D8E0: 8D 00 E8
  LDA #$00                                ; $D8E3: A9 00
  STA $07F2                               ; $D8E5: 8D F2 07
  INC $07F9                               ; $D8E8: EE F9 07
Loc_D8EB:
  TAX                                     ; $D8EB: AA
  LDA $0701,X                             ; $D8EC: BD 01 07
  AND #$07                                ; $D8EF: 29 07
  STA $07F3                               ; $D8F1: 8D F3 07
  TAY                                     ; $D8F4: A8
  ASL                                     ; $D8F5: 0A
  ASL                                     ; $D8F6: 0A
  STA $07F5                               ; $D8F7: 8D F5 07
  LDA $DD56,Y                             ; $D8FA: B9 56 DD
  STA $07F4                               ; $D8FD: 8D F4 07
  LDA $0700,X                             ; $D900: BD 00 07
  BEQ $D958                               ; $D903: F0 53
  CMP #$FF                                ; $D905: C9 FF
  BEQ $D94F                               ; $D907: F0 46
  JSR $DCD8                               ; $D909: 20 D8 DC
  INC $070E,X                             ; $D90C: FE 0E 07
  LDA $070E,X                             ; $D90F: BD 0E 07
  CMP $070D,X                             ; $D912: DD 0D 07
  BCC $D91D                               ; $D915: 90 06
  LDA $070D,X                             ; $D917: BD 0D 07
  STA $070E,X                             ; $D91A: 9D 0E 07
Loc_D91D:
  DEC $0705,X                             ; $D91D: DE 05 07
  BPL $D93A                               ; $D920: 10 18
  LDA $0704,X                             ; $D922: BD 04 07
  AND #$0F                                ; $D925: 29 0F
  STA $0705,X                             ; $D927: 9D 05 07
  JSR $DC90                               ; $D92A: 20 90 DC
  LDA $0715,X                             ; $D92D: BD 15 07
  BEQ $D935                               ; $D930: F0 03
  DEC $0715,X                             ; $D932: DE 15 07
Loc_D935:
  DEC $0708,X                             ; $D935: DE 08 07
  BEQ $D940                               ; $D938: F0 06
Loc_D93A:
  JSR $DF6E                               ; $D93A: 20 6E DF
  JMP $D943                               ; $D93D: 4C 43 D9
Loc_D940:
  JSR $D99B                               ; $D940: 20 9B D9
Loc_D943:
  LDY $07F3                               ; $D943: AC F3 07
  LDA $DD4E,Y                             ; $D946: B9 4E DD
  ORA $07F2                               ; $D949: 0D F2 07
  STA $07F2                               ; $D94C: 8D F2 07
Loc_D94F:
  TXA                                     ; $D94F: 8A
  CLC                                     ; $D950: 18
  ADC #$16                                ; $D951: 69 16
  CMP #$F2                                ; $D953: C9 F2
  BNE $D8EB                               ; $D955: D0 94
  RTS                                     ; $D957: 60
Loc_D958:
  LDA $0702,X                             ; $D958: BD 02 07
  STA a:$00F0                             ; $D95B: 8D F0 00
  LDA $0703,X                             ; $D95E: BD 03 07
  STA a:$00F1                             ; $D961: 8D F1 00
  LDY #$00                                ; $D964: A0 00
  LDA ($F0),Y                             ; $D966: B1 F0
  AND #$0F                                ; $D968: 29 0F
  STA $0704,X                             ; $D96A: 9D 04 07
  STA $0705,X                             ; $D96D: 9D 05 07
  INY                                     ; $D970: C8
  JSR $DC3F                               ; $D971: 20 3F DC
  INY                                     ; $D974: C8
  LDA ($F0),Y                             ; $D975: B1 F0
  ORA $07F7                               ; $D977: 0D F7 07
  STA $0706,X                             ; $D97A: 9D 06 07
  STA $0707,X                             ; $D97D: 9D 07 07
  INY                                     ; $D980: C8
  LDA ($F0),Y                             ; $D981: B1 F0
  STA $0709,X                             ; $D983: 9D 09 07
  LDA #$00                                ; $D986: A9 00
  STA $070A,X                             ; $D988: 9D 0A 07
  STA $070B,X                             ; $D98B: 9D 0B 07
  STA $070C,X                             ; $D98E: 9D 0C 07
  STA $070F,X                             ; $D991: 9D 0F 07
  LDA #$02                                ; $D994: A9 02
  STA $0700,X                             ; $D996: 9D 00 07
  BNE $D940                               ; $D999: D0 A5
Loc_D99B:
  LDA $0714,X                             ; $D99B: BD 14 07
  STA $0715,X                             ; $D99E: 9D 15 07
  LDY #$00                                ; $D9A1: A0 00
  STY a:$00F1                             ; $D9A3: 8C F1 00
  LDA $0700,X                             ; $D9A6: BD 00 07
  ASL                                     ; $D9A9: 0A
  ROL a:$00F1                             ; $D9AA: 2E F1 00
  ADC $0702,X                             ; $D9AD: 7D 02 07
  STA a:$00F0                             ; $D9B0: 8D F0 00
  LDA $0703,X                             ; $D9B3: BD 03 07
  ADC a:$00F1                             ; $D9B6: 6D F1 00
  STA a:$00F1                             ; $D9B9: 8D F1 00
  DEY                                     ; $D9BC: 88
Loc_D9BD:
  INY                                     ; $D9BD: C8
  LDA ($F0),Y                             ; $D9BE: B1 F0
  INC $0700,X                             ; $D9C0: FE 00 07
  INY                                     ; $D9C3: C8
  CMP #$F0                                ; $D9C4: C9 F0
  BCS $D9E2                               ; $D9C6: B0 1A
  CMP #$E0                                ; $D9C8: C9 E0
  BCS $D9F9                               ; $D9CA: B0 2D
  CMP #$D0                                ; $D9CC: C9 D0
  BCS $DA03                               ; $D9CE: B0 33
  CMP #$C0                                ; $D9D0: C9 C0
  BCS $DA18                               ; $D9D2: B0 44
  CMP #$B0                                ; $D9D4: C9 B0
  BCS $DA37                               ; $D9D6: B0 5F
  CMP #$A0                                ; $D9D8: C9 A0
  BCC $D9DF                               ; $D9DA: 90 03
  JMP $DA65                               ; $D9DC: 4C 65 DA
Loc_D9DF:
  JMP $DB21                               ; $D9DF: 4C 21 DB
Loc_D9E2:
  CMP #$FD                                ; $D9E2: C9 FD
  BNE $D9EF                               ; $D9E4: D0 09
  LDA $0700,X                             ; $D9E6: BD 00 07
  STA $0713,X                             ; $D9E9: 9D 13 07
Loc_D9EC:
  JMP $D9BD                               ; $D9EC: 4C BD D9
Loc_D9EF:
  CMP #$FF                                ; $D9EF: C9 FF
  BNE $D9EC                               ; $D9F1: D0 F9
  STA $0700,X                             ; $D9F3: 9D 00 07
  JMP $DBF1                               ; $D9F6: 4C F1 DB
Loc_D9F9:
  AND #$0F                                ; $D9F9: 29 0F
  EOR #$FF                                ; $D9FB: 49 FF
  CLC                                     ; $D9FD: 18
  ADC #$01                                ; $D9FE: 69 01
  JMP $DA05                               ; $DA00: 4C 05 DA
Loc_DA03:
  AND #$0F                                ; $DA03: 29 0F
Loc_DA05:
  BIT $07F4                               ; $DA05: 2C F4 07
  BMI $DA15                               ; $DA08: 30 0B
  STA $070F,X                             ; $DA0A: 9D 0F 07
  LDA ($F0),Y                             ; $DA0D: B1 F0
  STA $0710,X                             ; $DA0F: 9D 10 07
  STA $0711,X                             ; $DA12: 9D 11 07
Loc_DA15:
  JMP $D9BD                               ; $DA15: 4C BD D9
Loc_DA18:
  AND #$0F                                ; $DA18: 29 0F
  STA $07F7                               ; $DA1A: 8D F7 07
  BIT $07F4                               ; $DA1D: 2C F4 07
  BMI $DA34                               ; $DA20: 30 12
  LDA $0706,X                             ; $DA22: BD 06 07
  AND #$10                                ; $DA25: 29 10
  BEQ $DA34                               ; $DA27: F0 0B
  LDA ($F0),Y                             ; $DA29: B1 F0
  STA $070D,X                             ; $DA2B: 9D 0D 07
  LDA $07F7                               ; $DA2E: AD F7 07
  STA $070C,X                             ; $DA31: 9D 0C 07
Loc_DA34:
  JMP $D9BD                               ; $DA34: 4C BD D9
Loc_DA37:
  AND #$0F                                ; $DA37: 29 0F
  BEQ $DA58                               ; $DA39: F0 1D
  PHA                                     ; $DA3B: 48
  LDA ($F0),Y                             ; $DA3C: B1 F0
  BNE $DA4D                               ; $DA3E: D0 0D
  PLA                                     ; $DA40: 68
  DEC $070A,X                             ; $DA41: DE 0A 07
  BEQ $DA62                               ; $DA44: F0 1C
  BPL $DA58                               ; $DA46: 10 10
  STA $070A,X                             ; $DA48: 9D 0A 07
  BMI $DA58                               ; $DA4B: 30 0B
Loc_DA4D:
  PLA                                     ; $DA4D: 68
  DEC $070B,X                             ; $DA4E: DE 0B 07
  BEQ $DA62                               ; $DA51: F0 0F
  BPL $DA58                               ; $DA53: 10 03
  STA $070B,X                             ; $DA55: 9D 0B 07
Loc_DA58:
  LDA ($F0),Y                             ; $DA58: B1 F0
  BNE $DA5F                               ; $DA5A: D0 03
  LDA $0713,X                             ; $DA5C: BD 13 07
Loc_DA5F:
  STA $0700,X                             ; $DA5F: 9D 00 07
Loc_DA62:
  JMP $D99B                               ; $DA62: 4C 9B D9
Loc_DA65:
  BNE $DA76                               ; $DA65: D0 0F
  BIT $07F4                               ; $DA67: 2C F4 07
  BMI $DA7F                               ; $DA6A: 30 13
  LDA $0706,X                             ; $DA6C: BD 06 07
  AND #$C0                                ; $DA6F: 29 C0
  ORA ($F0),Y                             ; $DA71: 11 F0
  JMP $DA93                               ; $DA73: 4C 93 DA
Loc_DA76:
  CMP #$A1                                ; $DA76: C9 A1
  BNE $DA82                               ; $DA78: D0 08
  LDA ($F0),Y                             ; $DA7A: B1 F0
  STA $0709,X                             ; $DA7C: 9D 09 07
Loc_DA7F:
  JMP $D9BD                               ; $DA7F: 4C BD D9
Loc_DA82:
  CMP #$A2                                ; $DA82: C9 A2
  BNE $DA9C                               ; $DA84: D0 16
  JSR $DC3F                               ; $DA86: 20 3F DC
  BCS $DA93                               ; $DA89: B0 08
  LDA $0706,X                             ; $DA8B: BD 06 07
  AND #$1F                                ; $DA8E: 29 1F
  ORA $07F7                               ; $DA90: 0D F7 07
Loc_DA93:
  STA $0706,X                             ; $DA93: 9D 06 07
  STA $0707,X                             ; $DA96: 9D 07 07
  JMP $D9BD                               ; $DA99: 4C BD D9
Loc_DA9C:
  CMP #$A3                                ; $DA9C: C9 A3
  BNE $DABC                               ; $DA9E: D0 1C
  LDA ($F0),Y                             ; $DAA0: B1 F0
  BMI $DAC0                               ; $DAA2: 30 1C
  PHA                                     ; $DAA4: 48
  AND #$0F                                ; $DAA5: 29 0F
  ASL                                     ; $DAA7: 0A
  STA $0714,X                             ; $DAA8: 9D 14 07
  STA $0715,X                             ; $DAAB: 9D 15 07
  PLA                                     ; $DAAE: 68
  AND #$70                                ; $DAAF: 29 70
  ORA $0701,X                             ; $DAB1: 1D 01 07
  ORA #$80                                ; $DAB4: 09 80
  STA $0701,X                             ; $DAB6: 9D 01 07
  JMP $D9BD                               ; $DAB9: 4C BD D9
Loc_DABC:
  CMP #$A4                                ; $DABC: C9 A4
  BNE $DACB                               ; $DABE: D0 0B
Loc_DAC0:
  LDA $0701,X                             ; $DAC0: BD 01 07
  AND #$07                                ; $DAC3: 29 07
  STA $0701,X                             ; $DAC5: 9D 01 07
  JMP $D9BD                               ; $DAC8: 4C BD D9
Loc_DACB:
  CMP #$AD                                ; $DACB: C9 AD
  BNE $DAF8                               ; $DACD: D0 29
  LDA ($F0),Y                             ; $DACF: B1 F0
  PHA                                     ; $DAD1: 48
  LDA #$00                                ; $DAD2: A9 00
  STA a:$00F1                             ; $DAD4: 8D F1 00
  LDA $0700,X                             ; $DAD7: BD 00 07
  ASL                                     ; $DADA: 0A
  ROL a:$00F1                             ; $DADB: 2E F1 00
  ADC $0702,X                             ; $DADE: 7D 02 07
  STA $0702,X                             ; $DAE1: 9D 02 07
  LDA $0703,X                             ; $DAE4: BD 03 07
  ADC a:$00F1                             ; $DAE7: 6D F1 00
  STA $0703,X                             ; $DAEA: 9D 03 07
  LDA #$00                                ; $DAED: A9 00
  STA $0700,X                             ; $DAEF: 9D 00 07
  PLA                                     ; $DAF2: 68
  BNE $DB05                               ; $DAF3: D0 10
  JMP $D958                               ; $DAF5: 4C 58 D9
Loc_DAF8:
  CMP #$AE                                ; $DAF8: C9 AE
  BNE $DB08                               ; $DAFA: D0 0C
  ASL $0704,X                             ; $DAFC: 1E 04 07
  LDA ($F0),Y                             ; $DAFF: B1 F0
  ASL                                     ; $DB01: 0A
  ROR $0704,X                             ; $DB02: 7E 04 07
Loc_DB05:
  JMP $D9BD                               ; $DB05: 4C BD D9
Loc_DB08:
  CMP #$AF                                ; $DB08: C9 AF
  BNE $DB1E                               ; $DB0A: D0 12
  LDA ($F0),Y                             ; $DB0C: B1 F0
  AND #$0F                                ; $DB0E: 29 0F
  STA $0705,X                             ; $DB10: 9D 05 07
  LDA $0704,X                             ; $DB13: BD 04 07
  AND #$F0                                ; $DB16: 29 F0
  ORA $0705,X                             ; $DB18: 1D 05 07
  STA $0704,X                             ; $DB1B: 9D 04 07
Loc_DB1E:
  JMP $D9BD                               ; $DB1E: 4C BD D9
Loc_DB21:
  STA $07F7                               ; $DB21: 8D F7 07
  LDA ($F0),Y                             ; $DB24: B1 F0
  STA $0708,X                             ; $DB26: 9D 08 07
  LDA $07F7                               ; $DB29: AD F7 07
  BIT $07F4                               ; $DB2C: 2C F4 07
  BVC $DB34                               ; $DB2F: 50 03
  JMP $DBE2                               ; $DB31: 4C E2 DB
Loc_DB34:
  PHA                                     ; $DB34: 48
  AND #$0F                                ; $DB35: 29 0F
  CMP #$0C                                ; $DB37: C9 0C
  BCC $DB3E                               ; $DB39: 90 03
  JMP $DBF0                               ; $DB3B: 4C F0 DB
Loc_DB3E:
  ASL                                     ; $DB3E: 0A
  TAY                                     ; $DB3F: A8
  LDA $0704,X                             ; $DB40: BD 04 07
  BPL $DB4A                               ; $DB43: 10 05
  TYA                                     ; $DB45: 98
  CLC                                     ; $DB46: 18
  ADC #$18                                ; $DB47: 69 18
  TAY                                     ; $DB49: A8
Loc_DB4A:
  LDA $07F3                               ; $DB4A: AD F3 07
  CMP #$04                                ; $DB4D: C9 04
  BCC $DB56                               ; $DB4F: 90 05
  TYA                                     ; $DB51: 98
  CLC                                     ; $DB52: 18
  ADC #$30                                ; $DB53: 69 30
  TAY                                     ; $DB55: A8
Loc_DB56:
  LDA $DD06,Y                             ; $DB56: B9 06 DD
  STA $07F7                               ; $DB59: 8D F7 07
  LDA $DD07,Y                             ; $DB5C: B9 07 DD
  STA $07F8                               ; $DB5F: 8D F8 07
  PLA                                     ; $DB62: 68
  AND #$70                                ; $DB63: 29 70
  LDY $07F3                               ; $DB65: AC F3 07
  CPY #$04                                ; $DB68: C0 04
  BCC $DB86                               ; $DB6A: 90 1A
  CMP #$40                                ; $DB6C: C9 40
  BNE $DB79                               ; $DB6E: D0 09
  ASL $07F7                               ; $DB70: 0E F7 07
  ROL $07F8                               ; $DB73: 2E F8 07
  JMP $DB96                               ; $DB76: 4C 96 DB
Loc_DB79:
  SBC #$30                                ; $DB79: E9 30
  BEQ $DB86                               ; $DB7B: F0 09
  BCC $DB81                               ; $DB7D: 90 02
  LDA #$B0                                ; $DB7F: A9 B0
Loc_DB81:
  EOR #$FF                                ; $DB81: 49 FF
  CLC                                     ; $DB83: 18
  ADC #$01                                ; $DB84: 69 01
Loc_DB86:
  LSR                                     ; $DB86: 4A
  LSR                                     ; $DB87: 4A
  LSR                                     ; $DB88: 4A
  LSR                                     ; $DB89: 4A
  BEQ $DB96                               ; $DB8A: F0 0A
  TAY                                     ; $DB8C: A8
Loc_DB8D:
  LSR $07F8                               ; $DB8D: 4E F8 07
  ROR $07F7                               ; $DB90: 6E F7 07
  DEY                                     ; $DB93: 88
  BNE $DB8D                               ; $DB94: D0 F7
Loc_DB96:
  LDA #$00                                ; $DB96: A9 00
  STA $070E,X                             ; $DB98: 9D 0E 07
  LDA $0707,X                             ; $DB9B: BD 07 07
  STA $0706,X                             ; $DB9E: 9D 06 07
  JSR $DC31                               ; $DBA1: 20 31 DC
  CPY #$04                                ; $DBA4: C0 04
  BCS $DBB4                               ; $DBA6: B0 0C
  LDA $DD4E,Y                             ; $DBA8: B9 4E DD
  ORA $07F6                               ; $DBAB: 0D F6 07
  STA $07F6                               ; $DBAE: 8D F6 07
  STA $4015                               ; $DBB1: 8D 15 40
Loc_DBB4:
  LDA $07F8                               ; $DBB4: AD F8 07
  PHA                                     ; $DBB7: 48
  LDA $07F7                               ; $DBB8: AD F7 07
  PHA                                     ; $DBBB: 48
  JSR $DF71                               ; $DBBC: 20 71 DF
  CPY #$10                                ; $DBBF: C0 10
  BCS $DBC9                               ; $DBC1: B0 06
  LDA $0709,X                             ; $DBC3: BD 09 07
  STA $4001,Y                             ; $DBC6: 99 01 40
Loc_DBC9:
  PLA                                     ; $DBC9: 68
  JSR $DC03                               ; $DBCA: 20 03 DC
  CMP #$02                                ; $DBCD: C9 02
  BCC $DBD9                               ; $DBCF: 90 08
  CMP #$FE                                ; $DBD1: C9 FE
  BCC $DBDB                               ; $DBD3: 90 06
  LDA #$FD                                ; $DBD5: A9 FD
  BNE $DBDB                               ; $DBD7: D0 02
Loc_DBD9:
  LDA #$02                                ; $DBD9: A9 02
Loc_DBDB:
  STA $0712,X                             ; $DBDB: 9D 12 07
  PLA                                     ; $DBDE: 68
  JMP $DC18                               ; $DBDF: 4C 18 DC
Loc_DBE2:
  CMP #$10                                ; $DBE2: C9 10
  BCS $DBF1                               ; $DBE4: B0 0B
  STA $07F7                               ; $DBE6: 8D F7 07
  LDA #$00                                ; $DBE9: A9 00
  STA $07F8                               ; $DBEB: 8D F8 07
  BEQ $DB96                               ; $DBEE: F0 A6
Loc_DBF0:
  PLA                                     ; $DBF0: 68
Loc_DBF1:
  LDA $0706,X                             ; $DBF1: BD 06 07
  AND #$C0                                ; $DBF4: 29 C0
  BIT $07F4                               ; $DBF6: 2C F4 07
  BPL $DBFD                               ; $DBF9: 10 02
  LDA #$00                                ; $DBFB: A9 00
Loc_DBFD:
  STA $0706,X                             ; $DBFD: 9D 06 07
  JMP $DF6E                               ; $DC00: 4C 6E DF
Loc_DC03:
  CPY #$10                                ; $DC03: C0 10
  BCS $DC0B                               ; $DC05: B0 04
  STA $4002,Y                             ; $DC07: 99 02 40
  RTS                                     ; $DC0A: 60
Loc_DC0B:
  PHA                                     ; $DC0B: 48
  TYA                                     ; $DC0C: 98
  ASL                                     ; $DC0D: 0A
  ORA #$60                                ; $DC0E: 09 60
  STA $F800                               ; $DC10: 8D 00 F8
  PLA                                     ; $DC13: 68
  STA $4800                               ; $DC14: 8D 00 48
  RTS                                     ; $DC17: 60
Loc_DC18:
  CPY #$10                                ; $DC18: C0 10
  BCS $DC24                               ; $DC1A: B0 08
  AND #$07                                ; $DC1C: 29 07
  ORA #$08                                ; $DC1E: 09 08
  STA $4003,Y                             ; $DC20: 99 03 40
  RTS                                     ; $DC23: 60
Loc_DC24:
  PHA                                     ; $DC24: 48
  TYA                                     ; $DC25: 98
  ASL                                     ; $DC26: 0A
  ORA #$62                                ; $DC27: 09 62
  STA $F800                               ; $DC29: 8D 00 F8
  PLA                                     ; $DC2C: 68
  STA $4800                               ; $DC2D: 8D 00 48
  RTS                                     ; $DC30: 60
Loc_DC31:
  LDY $07F3                               ; $DC31: AC F3 07
  LDA $DD4E,Y                             ; $DC34: B9 4E DD
  BIT $07F2                               ; $DC37: 2C F2 07
  BEQ $DC3E                               ; $DC3A: F0 02
  PLA                                     ; $DC3C: 68
  PLA                                     ; $DC3D: 68
Loc_DC3E:
  RTS                                     ; $DC3E: 60
Loc_DC3F:
  BIT $07F4                               ; $DC3F: 2C F4 07
  BMI $DC50                               ; $DC42: 30 0C
  LDA ($F0),Y                             ; $DC44: B1 F0
  ROR                                     ; $DC46: 6A
  ROR                                     ; $DC47: 6A
  ROR                                     ; $DC48: 6A
  AND #$C0                                ; $DC49: 29 C0
  STA $07F7                               ; $DC4B: 8D F7 07
  CLC                                     ; $DC4E: 18
  RTS                                     ; $DC4F: 60
Loc_DC50:
  LDA ($F0),Y                             ; $DC50: B1 F0
  AND #$7F                                ; $DC52: 29 7F
  STA $07F7                               ; $DC54: 8D F7 07
  SEC                                     ; $DC57: 38
  RTS                                     ; $DC58: 60
; --- Data Region ---
  .byte $0A,$0A,$0A,$0A,$48,$A9,$00,$8D,$F7,$07,$BD,$0E,$07,$A0,$03; $DC59: 0A 0A 0A 0A 48 A9 00 8D F7 07 BD 0E 07 A0 03
Loc_DC68:
; --- Code Region ---
  ASL                                     ; $DC68: 0A
  CMP $070D,X                             ; $DC69: DD 0D 07
  BCC $DC71                               ; $DC6C: 90 03
  SBC $070D,X                             ; $DC6E: FD 0D 07
Loc_DC71:
  ROL $07F7                               ; $DC71: 2E F7 07
  DEY                                     ; $DC74: 88
  BPL $DC68                               ; $DC75: 10 F1
  PLA                                     ; $DC77: 68
  ORA $07F7                               ; $DC78: 0D F7 07
  TAY                                     ; $DC7B: A8
  LDA $0706,X                             ; $DC7C: BD 06 07
  AND #$0F                                ; $DC7F: 29 0F
  ORA $DDCE,Y                             ; $DC81: 19 CE DD
  TAY                                     ; $DC84: A8
  LDA $0706,X                             ; $DC85: BD 06 07
  AND #$C0                                ; $DC88: 29 C0
  ORA $DE6E,Y                             ; $DC8A: 19 6E DE
  JMP $DF87                               ; $DC8D: 4C 87 DF
Loc_DC90:
  BIT $07F4                               ; $DC90: 2C F4 07
  BMI $DCC6                               ; $DC93: 30 31
  LDA $070F,X                             ; $DC95: BD 0F 07
  BEQ $DCC6                               ; $DC98: F0 2C
  DEC $0711,X                             ; $DC9A: DE 11 07
  BNE $DCC6                               ; $DC9D: D0 27
  LDA $0710,X                             ; $DC9F: BD 10 07
  STA $0711,X                             ; $DCA2: 9D 11 07
  LDA $0706,X                             ; $DCA5: BD 06 07
  AND #$1F                                ; $DCA8: 29 1F
  STA $07F7                               ; $DCAA: 8D F7 07
  AND #$10                                ; $DCAD: 29 10
  BEQ $DCC6                               ; $DCAF: F0 15
  LDA $070F,X                             ; $DCB1: BD 0F 07
  BMI $DCC7                               ; $DCB4: 30 11
  DEC $070F,X                             ; $DCB6: DE 0F 07
  LDA $07F7                               ; $DCB9: AD F7 07
  CMP #$1F                                ; $DCBC: C9 1F
  BEQ $DCC6                               ; $DCBE: F0 06
  INC $0706,X                             ; $DCC0: FE 06 07
  INC $0707,X                             ; $DCC3: FE 07 07
Loc_DCC6:
  RTS                                     ; $DCC6: 60
Loc_DCC7:
  INC $070F,X                             ; $DCC7: FE 0F 07
  LDA $07F7                               ; $DCCA: AD F7 07
  CMP #$10                                ; $DCCD: C9 10
  BEQ $DCC6                               ; $DCCF: F0 F5
  DEC $0706,X                             ; $DCD1: DE 06 07
  DEC $0707,X                             ; $DCD4: DE 07 07
  RTS                                     ; $DCD7: 60
Loc_DCD8:
  JSR $DC31                               ; $DCD8: 20 31 DC
  BIT $07F4                               ; $DCDB: 2C F4 07
  BVS $DD05                               ; $DCDE: 70 25
  LDA $0715,X                             ; $DCE0: BD 15 07
  BNE $DD05                               ; $DCE3: D0 20
  LDA $0701,X                             ; $DCE5: BD 01 07
  BPL $DD05                               ; $DCE8: 10 1B
  AND #$70                                ; $DCEA: 29 70
  STA $07F7                               ; $DCEC: 8D F7 07
  LDA $07F9                               ; $DCEF: AD F9 07
  AND #$0F                                ; $DCF2: 29 0F
  ORA $07F7                               ; $DCF4: 0D F7 07
  TAY                                     ; $DCF7: A8
  LDA $DD5E,Y                             ; $DCF8: B9 5E DD
  CLC                                     ; $DCFB: 18
  ADC $0712,X                             ; $DCFC: 7D 12 07
  LDY $07F5                               ; $DCFF: AC F5 07
  STA $4002,Y                             ; $DD02: 99 02 40
Loc_DD05:
  RTS                                     ; $DD05: 60
; --- Data Region ---
  .byte $AE,$06,$4E,$06,$F4,$05,$9E,$05,$4D,$05,$01,$05,$B9,$04,$75,$04; $DD06: AE 06 4E 06 F4 05 9E 05 4D 05 01 05 B9 04 75 04
  .byte $35,$04,$F9,$03,$C0,$03,$8A,$03,$7E,$06,$21,$06,$C9,$05,$76,$05; $DD16: 35 04 F9 03 C0 03 8A 03 7E 06 21 06 C9 05 76 05
  .byte $27,$05,$DD,$04,$96,$04,$55,$04,$17,$04,$DD,$03,$A5,$03,$71,$03; $DD26: 27 05 DD 04 96 04 55 04 17 04 DD 03 A5 03 71 03
  .byte $D9,$47,$10,$4C,$A5,$50,$71,$55,$86,$5A,$E8,$5F,$9C,$65,$A7,$6B; $DD36: D9 47 10 4C A5 50 71 55 86 5A E8 5F 9C 65 A7 6B
  .byte $0D,$72,$D5,$78,$05,$80,$A2,$87,$01,$02,$04,$08,$10,$20,$40,$80; $DD46: 0D 72 D5 78 05 80 A2 87 01 02 04 08 10 20 40 80
  .byte $00,$01,$82,$43,$04,$05,$06,$07,$00,$00,$01,$01,$00,$00,$FF,$FF; $DD56: 00 01 82 43 04 05 06 07 00 00 01 01 00 00 FF FF
Loc_DD66:
  .byte $00,$00,$01,$01,$00,$00,$FF,$FF,$00,$00,$00,$00,$01,$01; $DD66: 00 00 01 01 00 00 FF FF 00 00 00 00 01 01
Loc_DD74:
; --- Code Region ---
  ORA ($01,X)                             ; $DD74: 01 01
  BRK                                     ; $DD76: 00
Loc_DD77:
; --- Data Region ---
  .byte $00,$00,$00,$FF,$FF,$FF,$FF,$00,$01,$02,$01,$00,$FF,$FE,$FF,$00; $DD77: 00 00 00 FF FF FF FF 00 01 02 01 00 FF FE FF 00
  .byte $01,$02,$01,$00,$FF,$FE,$FF,$00   ; $DD87: 01 02 01 00 FF FE FF 00
Loc_DD8F:
  .byte $00,$01,$01,$02,$02,$01,$01,$00,$00,$FF,$FF,$FE,$FE,$FF,$FF,$FF; $DD8F: 00 01 01 02 02 01 01 00 00 FF FF FE FE FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FE; $DD9F: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FE
  .byte $FE,$FE,$FE,$FE,$FE,$FE,$FE,$FE,$FE,$FE,$FE,$FE,$FE,$FE,$FE,$01; $DDAF: FE FE FE FE FE FE FE FE FE FE FE FE FE FE FE 01
  .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01; $DDBF: 01 01 01 01 01 01 01 01 01 01 01 01
Loc_DDCB:
  .byte $01,$01,$01,$02,$02,$02           ; $DDCB: 01 01 01 02 02 02
Loc_DDD1:
  .byte $02                               ; $DDD1: 02
Loc_DDD2:
  .byte $02                               ; $DDD2: 02
Loc_DDD3:
  .byte $02,$02,$02,$02,$02,$02           ; $DDD3: 02 02 02 02 02 02
Loc_DDD9:
  .byte $02,$02,$02,$02                   ; $DDD9: 02 02 02 02
Loc_DDDD:
  .byte $02,$F0,$E0,$D0,$C0,$B0,$A0,$90,$80,$70,$60,$50,$40,$30,$20,$10; $DDDD: 02 F0 E0 D0 C0 B0 A0 90 80 70 60 50 40 30 20 10
  .byte $00                               ; $DDED: 00
Loc_DDEE:
; --- Code Region ---
  BRK                                     ; $DDEE: 00
Loc_DDEF:
  BPL $DE11                               ; $DDEF: 10 20
  BMI $DE33                               ; $DDF1: 30 40
  BVC $DE55                               ; $DDF3: 50 60
Loc_DDF5:
  BVS $DD77                               ; $DDF5: 70 80
Loc_DDF7:
  BCC $DD99                               ; $DDF7: 90 A0
  BCS $DDBB                               ; $DDF9: B0 C0
  BNE $DDDD                               ; $DDFB: D0 E0
  BEQ $DDEF                               ; $DDFD: F0 F0
  CPX #$D0                                ; $DDFF: E0 D0
Loc_DE01:
  CPY #$B0                                ; $DE01: C0 B0
  LDY #$90                                ; $DE03: A0 90
Loc_DE05:
; --- Data Region ---
  .byte $80,$80                           ; $DE05: 80 80
Loc_DE07:
; --- Code Region ---
  BCC $DDA9                               ; $DE07: 90 A0
  BCS $DDCB                               ; $DE09: B0 C0
  BNE $DDED                               ; $DE0B: D0 E0
Loc_DE0D:
  BEQ $DD8F                               ; $DE0D: F0 80
  BCC $DDB1                               ; $DE0F: 90 A0
Loc_DE11:
  BCS $DDD3                               ; $DE11: B0 C0
  BNE $DDF5                               ; $DE13: D0 E0
Loc_DE15:
; --- Data Region ---
  .byte $F0,$F0,$E0,$D0,$C0,$B0,$A0,$90,$80,$F0,$D0,$B0,$90,$70,$50,$30; $DE15: F0 F0 E0 D0 C0 B0 A0 90 80 F0 D0 B0 90 70 50 30
  .byte $10,$E0,$C0,$A0,$80,$60           ; $DE25: 10 E0 C0 A0 80 60
  .byte $40,$20,$00,$F0,$E0,$D0,$C0,$C0   ; $DE2B: 40 20 00 F0 E0 D0 C0 C0
Loc_DE33:
; --- Code Region ---
  BNE $DE15                               ; $DE33: D0 E0
  BNE $DDF7                               ; $DE35: D0 C0
  LDY #$80                                ; $DE37: A0 80
  RTS                                     ; $DE39: 60
; --- Data Region ---
  .byte $40,$20,$10,$00,$F0,$D0,$B0,$90,$A0,$B0,$90,$70,$60,$50; $DE3A: 40 20 10 00 F0 D0 B0 90 A0 B0 90 70 60 50
Loc_DE48:
; --- Code Region ---
  RTI                                     ; $DE48: 40
; --- Data Region ---
  .byte $30,$20,$10,$10,$00,$40,$40,$40,$40,$40,$40,$40; $DE49: 30 20 10 10 00 40 40 40 40 40 40 40
Loc_DE55:
; --- Code Region ---
  RTS                                     ; $DE55: 60
; --- Data Region ---
  .byte $60,$70,$80,$A0,$C0,$F0,$B0       ; $DE56: 60 70 80 A0 C0 F0 B0
Loc_DE5D:
  .byte $80,$F0,$F0,$A0,$80,$F0,$F0,$A0,$80,$70,$70,$60,$60; $DE5D: 80 F0 F0 A0 80 F0 F0 A0 80 70 70 60 60
  .byte $50                               ; $DE6A: 50
Loc_DE6B:
  .byte $50,$40,$20,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30; $DE6B: 50 40 20 30 30 30 30 30 30 30 30 30 30 30 30 30
  .byte $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$31,$31,$31,$31,$31; $DE7B: 30 30 30 30 30 30 30 30 30 30 30 31 31 31 31 31
  .byte $31,$31,$31,$30,$30,$30,$30,$31,$31,$31,$31,$31,$31,$31,$31,$32; $DE8B: 31 31 31 30 30 30 30 31 31 31 31 31 31 31 31 32
  .byte $32,$32,$32,$30,$30,$30,$31       ; $DE9B: 32 32 32 30 30 30 31
Loc_DEA2:
; --- Code Region ---
  AND ($31),Y                             ; $DEA2: 31 31
Loc_DEA4:
  AND ($31),Y                             ; $DEA4: 31 31
Loc_DEA6:
; --- Data Region ---
  .byte $32,$32                           ; $DEA6: 32 32
Loc_DEA8:
  .byte $32,$32                           ; $DEA8: 32 32
Loc_DEAA:
  .byte $32,$33,$33,$33,$30,$30,$31,$31,$31,$31,$32,$32; $DEAA: 32 33 33 33 30 30 31 31 31 31 32 32
Loc_DEB6:
  .byte $32,$32,$33,$33,$33,$33           ; $DEB6: 32 32 33 33 33 33
Loc_DEBC:
  .byte $34,$34,$30,$30                   ; $DEBC: 34 34 30 30
Loc_DEC0:
; --- Code Region ---
  AND ($31),Y                             ; $DEC0: 31 31
Loc_DEC2:
; --- Data Region ---
  .byte $31,$32,$32,$32,$33,$33,$33,$34,$34,$34,$35,$35,$30,$30; $DEC2: 31 32 32 32 33 33 33 34 34 34 35 35 30 30
Loc_DED0:
  .byte $31,$31,$32                       ; $DED0: 31 31 32
Loc_DED3:
  .byte $32,$32,$33,$33,$34,$34,$34,$35,$35,$36,$36,$30,$30,$31,$31,$32; $DED3: 32 32 33 33 34 34 34 35 35 36 36 30 30 31 31 32
  .byte $32,$33,$33,$34,$34,$35,$35,$36,$36,$37,$37,$30,$31; $DEE3: 32 33 33 34 34 35 35 36 36 37 37 30 31
Loc_DEF0:
  .byte $31,$32,$32,$33,$33,$34,$34,$35,$35,$36,$36,$37,$37,$38,$30,$31; $DEF0: 31 32 32 33 33 34 34 35 35 36 36 37 37 38 30 31
Loc_DF00:
  .byte $31,$32,$32,$33,$34,$34,$35,$35,$36,$37,$37,$38,$38,$39,$30,$31; $DF00: 31 32 32 33 34 34 35 35 36 37 37 38 38 39 30 31
  .byte $31,$32                           ; $DF10: 31 32
Loc_DF12:
  .byte $33,$33,$34,$35,$35,$36,$37,$37,$38,$39,$39,$3A,$30,$31,$31,$32; $DF12: 33 33 34 35 35 36 37 37 38 39 39 3A 30 31 31 32
  .byte $33,$34,$34,$35,$36,$37,$37,$38,$39,$3A,$3A,$3B,$30,$31,$32; $DF22: 33 34 34 35 36 37 37 38 39 3A 3A 3B 30 31 32
Loc_DF31:
  .byte $32,$33,$34,$35,$36,$36,$37,$38,$39,$3A,$3A,$3B,$3C,$30,$31,$32; $DF31: 32 33 34 35 36 36 37 38 39 3A 3A 3B 3C 30 31 32
  .byte $33,$33,$34,$35,$36,$37,$38,$39,$3A,$3A,$3B,$3C,$3D,$30,$31,$32; $DF41: 33 33 34 35 36 37 38 39 3A 3A 3B 3C 3D 30 31 32
Loc_DF51:
  .byte $33,$34,$35,$36,$37,$37,$38,$39,$3A,$3B,$3C,$3D,$3E,$30,$31,$32; $DF51: 33 34 35 36 37 37 38 39 3A 3B 3C 3D 3E 30 31 32
  .byte $33,$34,$35,$36,$37,$38,$39,$3A,$3B,$3C,$3D,$3E,$3F,$20,$31,$DC; $DF61: 33 34 35 36 37 38 39 3A 3B 3C 3D 3E 3F 20 31 DC
  .byte $2C,$F4,$07,$30,$3F,$BD,$0C,$07,$F0,$03,$4C,$59,$DC,$BD; $DF71: 2C F4 07 30 3F BD 0C 07 F0 03 4C 59 DC BD
  .byte $06,$07                           ; $DF7F: 06 07
Loc_DF81:
; --- Code Region ---
  AND #$10                                ; $DF81: 29 10
  ASL                                     ; $DF83: 0A
  ORA $0706,X                             ; $DF84: 1D 06 07
Loc_DF87:
  LDY $07F5                               ; $DF87: AC F5 07
  CPY #$10                                ; $DF8A: C0 10
  BCS $DF92                               ; $DF8C: B0 04
  STA $4000,Y                             ; $DF8E: 99 00 40
Loc_DF91:
  RTS                                     ; $DF91: 60
Loc_DF92:
  PHA                                     ; $DF92: 48
  PHA                                     ; $DF93: 48
  TYA                                     ; $DF94: 98
  ASL                                     ; $DF95: 0A
  ORA #$67                                ; $DF96: 09 67
  TAY                                     ; $DF98: A8
  STA $F800                               ; $DF99: 8D 00 F8
  PLA                                     ; $DF9C: 68
  AND #$0F                                ; $DF9D: 29 0F
  ORA #$30                                ; $DF9F: 09 30
  STA $4800                               ; $DFA1: 8D 00 48
  DEY                                     ; $DFA4: 88
  STY $F800                               ; $DFA5: 8C 00 F8
  PLA                                     ; $DFA8: 68
  AND #$C0                                ; $DFA9: 29 C0
  LSR                                     ; $DFAB: 4A
  LSR                                     ; $DFAC: 4A
  LSR                                     ; $DFAD: 4A
  STA $4800                               ; $DFAE: 8D 00 48
  LDY $07F5                               ; $DFB1: AC F5 07
  RTS                                     ; $DFB4: 60
; --- Data Region ---
  .byte $AC,$F5,$07,$BD,$06,$07,$99,$00,$40,$60,$FF,$FF,$FF,$FF,$FF,$FF; $DFB5: AC F5 07 BD 06 07 99 00 40 60 FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DFC5: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DFD5: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DFE5: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DFF5: FF FF FF FF FF FF FF FF FF FF FF
