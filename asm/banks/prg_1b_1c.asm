;===============================================================================
; PRG Banks $1B+$1C - Combined 16KB ($A000-$DFFF)
; Sangokushi 2 - Haou no Tairiku (J)
; Namco-163 Mapper 19
;
; Bank $1B at $A000-$BFFF, Bank $1C at $C000-$DFFF
;===============================================================================

.include "6502_registers.h"
.include "namco163.h"
.include "functions.h"


.segment "CODE_BANK1B"

;===============================================================================
; MapScreenFrameUpdate_Entry ($A000) - dispatch entry stub
; Jump-table stub aliasing the map-screen frame update handler. Called from
; NmiState2_MapScreen (bank $1F, $F8EF) every VBlank of the map screen with
; banks $1B+$1C mapped in (Y=$3B). Shares its handler with entry $A00C.
;===============================================================================
MapScreenFrameUpdate_Entry:  ; (dispatch callback target)
; --- Code Region ---
  JMP MapScreenFrameUpdate                ; $A000: 4C 0C A0
Loc_A003:  ; (dispatch callback target)
  JMP $DA02                               ; $A003: 4C 02 DA
Loc_A006:  ; (dispatch callback target)
  JMP $D64A                               ; $A006: 4C 4A D6
Loc_A009:  ; (dispatch callback target)
  JMP $DF25                               ; $A009: 4C 25 DF
;===============================================================================
; MapScreenFrameUpdate ($A00C-$A044)
; Per-frame map-screen update for banks $1B+$1C, invoked by NmiState2_MapScreen
; via the $A000 stub (and directly as dispatch entry $A00C):
;   1. MapRulerMarkerDraw ($DE83) - place ruler marker sprites at the camera
;      position ($6F3F=X, $6F41=Y), skipped during screen transitions ($008F)
;      or while overlays $04E4/$04A0 are active.
;   2. MapProvinceSpriteRefresh ($DF35) - rebuild the animated province marker
;      sprites in OAM page $0200 and clear the dirty bitmap $04E0-$04E3.
;   3. Banked callback to banks $19+$1A entry $A02A (JMP MapProvinceDirtyMark): marks pending
;      province $0402 in dirty bitmap $04E0-$04E3 for the next frame.
;   4. When palette/frame flag $0087 bit7 is set (animation phase tick from
;      B1F_PaletteAnimation), dispatch the frame-state handler by $0400.
;===============================================================================
MapScreenFrameUpdate:  ; (dispatch callback target)
  JSR MapRulerMarkerDraw                  ; $A00C: 20 83 DE
  JSR MapProvinceSpriteRefresh            ; $A00F: 20 35 DF
  LDY #$39                                ; $A012: A0 39     ; target banks $19+$1A
  JSR B1F_BankedCallbackTrampoline        ; $A014: 20 07 EE
  .word $A02A                             ; $A017: 2A A0 (BankedCallbackTrampoline target; bank $19 $A02A -> JMP MapProvinceDirtyMark)
  LDA a:$0087                             ; $A019: AD 87 00  ; palette/frame flag
  BMI MapScreenFrameStateDispatch         ; $A01C: 30 01     ; bit7 set: animation tick -> run state machine
  RTS                                     ; $A01E: 60        ; frame flag idle: nothing more this VBlank
MapScreenFrameStateDispatch:
  LDA $0400                               ; $A01F: AD 00 04  ; map screen frame state
  JSR B1F_CallbackDispatcher              ; $A022: 20 DE EA
MapScreenFrameStateTable:
  .word Loc_A07D                          ; $A025: 7D A0 ; state 0: sub-state dispatch by $0401
  .word Loc_A18B                          ; $A027: 8B A1 ; state 1
  .word Loc_A295                          ; $A029: 95 A2 ; state 2
  .word Loc_ADF2                          ; $A02B: F2 AD ; state 3
  .word Loc_B759                          ; $A02D: 59 B7 ; state 4
  .word Loc_BFB7                          ; $A02F: B7 BF ; state 5
  .word Loc_CADF                          ; $A031: DF CA ; state 6
  .word Loc_A07D                          ; $A033: 7D A0 ; state 7: sub-state dispatch by $0401
  .word Loc_A07D                          ; $A035: 7D A0 ; state 8: sub-state dispatch by $0401
  .word Loc_A055                          ; $A037: 55 A0 ; state 9: banked call, banks $19+$1A $A006
  .word Loc_A05D                          ; $A039: 5D A0 ; state $0A: banked call, banks $19+$1A $A009
  .word Loc_A045                          ; $A03B: 45 A0 ; state $0B: banked call, banks $19+$1A $A003
  .word Loc_A04D                          ; $A03D: 4D A0 ; state $0C: banked call, banks $19+$1A $A021
  .word Loc_A065                          ; $A03F: 65 A0 ; state $0D: banked call, banks $19+$1A $A00C
  .word Loc_A06D                          ; $A041: 6D A0 ; state $0E: banked call, B1D_1E_SceneRenderer
  .word Loc_A075                          ; $A043: 75 A0 ; state $0F: banked call, banks $19+$1A $A01E
Loc_A045:  ; (dispatch callback target)
; --- Code Region ---
  LDY #$39                                ; $A045: A0 39     ; target banks $19+$1A
  JSR B1F_BankedCallbackTrampoline        ; $A047: 20 07 EE
  .word $A003                             ; $A04A: 03 A0 (BankedCallbackTrampoline target)
  RTS                                     ; $A04C: 60
Loc_A04D:  ; (dispatch callback target)
; --- Code Region ---
  LDY #$39                                ; $A04D: A0 39     ; target banks $19+$1A
  JSR B1F_BankedCallbackTrampoline        ; $A04F: 20 07 EE
  .word $A021                             ; $A052: 21 A0 (BankedCallbackTrampoline target)
  RTS                                     ; $A054: 60
Loc_A055:
  LDY #$39                                ; $A055: A0 39     ; target banks $19+$1A
  JSR B1F_BankedCallbackTrampoline        ; $A057: 20 07 EE
  .word $A006                             ; $A059: 06 A0 (BankedCallbackTrampoline target)
  RTS                                     ; $A05B: 60
Loc_A05D:
  LDY #$39                                ; $A05D: A0 39     ; target banks $19+$1A
  JSR B1F_BankedCallbackTrampoline        ; $A05F: 20 07 EE
  .word $A009                             ; $A062: 09 A0 (BankedCallbackTrampoline target)
  RTS                                     ; $A064: 60
Loc_A065:
  LDY #$39                                ; $A065: A0 39     ; target banks $19+$1A
  JSR B1F_BankedCallbackTrampoline        ; $A067: 20 07 EE
  .word $A00C                             ; $A06A: 0C A0 (BankedCallbackTrampoline target)
  RTS                                     ; $A06C: 60
Loc_A06D:
  LDY #$3D                                ; $A06D: A0 3D     ; target banks $1D+$1E
  JSR B1F_BankedCallbackTrampoline        ; $A06F: 20 07 EE
  .word B1D_1E_SceneRenderer              ; $A072: 39 A0 (BankedCallbackTrampoline target)
  RTS                                     ; $A074: 60
Loc_A075:
  LDY #$39                                ; $A075: A0 39     ; target banks $19+$1A
  JSR B1F_BankedCallbackTrampoline        ; $A077: 20 07 EE
  .word $A01E                             ; $A07A: 1E A0 (BankedCallbackTrampoline target; bank $19 $A01E -> JMP $C435)
  RTS                                     ; $A07C: 60
Loc_A07D:
  LDA $0401                               ; $A07D: AD 01 04  ; frame sub-state
  JSR B1F_CallbackDispatcher              ; $A080: 20 DE EA
  .word MapRulerIntroInit                 ; $A083: 89 A0 ; sub-state 0
  .word MapRulerIntroCameraSync           ; $A085: DF A0 ; sub-state 1
  .word MapRulerIntroWait                 ; $A087: 79 A1 ; sub-state 2
;===============================================================================
; MapRulerIntroInit ($A089-$A0DE)
; Frame sub-state 0 of the map-screen ruler-intro sequence (shared by frame
; states 0/7/8 through the sub-dispatch at $A07D). Resets the per-intro state
; ($0470-$0472 scroll pointers, $00A4, dirty mark $04E4), then counts the
; provinces owned by the current ruler $6F03 (sram_player_id) via $DDBF:
;   - 30 provinces: the ruler owns the whole land -> frame state $0F
;     (ending/unification scene, banks $19+$1A $A01E).
;   - SRAM game-state flag $6F05 is $00 or negative (no active game):
;     frame state $0B + sub-state 0 (title/attract cycle) via B1F_SetUI4.
;   - Active game: cache the player's home province from the SRAM ruler
;     record (($EE), set up by bank $0A+$0B) into $042C, snapshot $6F05 into
;     $042F, and enter UI mode $1F for the camera focus phase.
;===============================================================================
MapRulerIntroInit:  ; (dispatch callback target)
; --- Code Region ---
  LDA #$00                                ; $A089: A9 00
  STA $0470                               ; $A08B: 8D 70 04  ; scroll ptr slot 0
  STA $0471                               ; $A08E: 8D 71 04  ; scroll ptr slot 1
  STA $0472                               ; $A091: 8D 72 04  ; scroll ptr slot 2
  STA a:$00A4                             ; $A094: 8D A4 00
  STA $04E4                               ; $A097: 8D E4 04  ; sprite dirty mark
  LDA $6F03                               ; $A09A: AD 03 6F  ; current ruler id (SRAM)
  STA a:$0010                             ; $A09D: 8D 10 00
  JSR $DDBF                               ; $A0A0: 20 BF DD  ; count ruler's provinces -> $0011
  LDA a:$0011                             ; $A0A3: AD 11 00
  CMP #$1E                                ; $A0A6: C9 1E    ; all 30 provinces owned?
  BNE $A0B0                               ; $A0A8: D0 06
  LDA #$0F                                ; $A0AA: A9 0F
  STA $0400                               ; $A0AC: 8D 00 04  ; ending/unification scene
  RTS                                     ; $A0AF: 60
Loc_A0B0:
  INC $0401                               ; $A0B0: EE 01 04  ; advance to camera sync
  LDA $6F05                               ; $A0B3: AD 05 6F  ; SRAM game state flag
  BMI $A0BA                               ; $A0B6: 30 02    ; negative: no active game
  BNE $A0C7                               ; $A0B8: D0 0D    ; non-zero: game in progress
Loc_A0BA:
  LDA #$0B                                ; $A0BA: A9 0B
  STA $0400                               ; $A0BC: 8D 00 04  ; attract/title cycle
  LDA #$00                                ; $A0BF: A9 00
  STA $0401                               ; $A0C1: 8D 01 04
  JMP $F28B                               ; $A0C4: 4C 8B F2  ; B1F_SetUI4 (no return)
Loc_A0C7:
  LDY #$00                                ; $A0C7: A0 00
  LDA ($EE),Y                             ; $A0C9: B1 EE     ; home province from SRAM ruler record
  STA $042C                               ; $A0CB: 8D 2C 04  ; intro focus province
  STY $0430                               ; $A0CE: 8C 30 04
  STY $0431                               ; $A0D1: 8C 31 04
  LDA $6F05                               ; $A0D4: AD 05 6F
  STA $042F                               ; $A0D7: 8D 2F 04  ; snapshot of game state flag
  LDA #$1F                                ; $A0DA: A9 1F
  JMP $F26D                               ; $A0DC: 4C 6D F2  ; B1F_SetUI0 mode $1F (no return)
;===============================================================================
; MapRulerIntroCameraSync ($A0DF-$A121)
; Frame sub-state 1 of the ruler-intro sequence. Each animation tick it:
;   1. Runs $DDF2 (province-sprite animation phase tick).
;   2. Banked callback to banks $1D+$1E entry $A021 (B1D_1E_SlowPeriodic:
;      slow periodic overlay refresh).
;   3. Polls input until the view settles on one of the current ruler's
;      provinces:
;        - A pressed ($0081 bit0): resolve camera $6F3F/$6F41 to a province
;          via $DEBA; if the camera is in bounds and the province belongs to
;          ruler $6F03, mark the screen dirty ($04E4) and advance frame state
;          $0400 (sub-state resets to 0).
;        - B/Select ($0081|$0082 bit2): back out to frame state $0E with
;          sub-state decremented (Loc_A161).
;        - No valid landing: stay and retry next tick.
;      (Pad-edge helper Loc_A12D and cancel helper Loc_A161 below.)
;===============================================================================
MapRulerIntroCameraSync:  ; (dispatch callback target)
; --- Code Region ---
  JSR $DDF2                               ; $A0DF: 20 F2 DD  ; province sprite animation tick
  LDY #$3D                                ; $A0E2: A0 3D     ; target banks $1D+$1E
  JSR B1F_BankedCallbackTrampoline        ; $A0E4: 20 07 EE
  .word B1D_1E_SlowPeriodic               ; $A0E7: 21 A0 (BankedCallbackTrampoline target; slow periodic overlay refresh)
; --- Code Region ---
  JSR $DDAD                               ; $A0E9: 20 AD DD  ; check intro/scene busy flags $0304/$0300
  BCC Loc_A12C                            ; $A0EC: 90 3E     ; busy: skip input this tick
  JSR Loc_A12D                            ; $A0EE: 20 2D A1  ; A-button edge: resolve camera province
  JSR Loc_A161                            ; $A0F1: 20 61 A1  ; B/Select edge: back out
  LDA a:$0081                             ; $A0F4: AD 81 00  ; pad latch 1
  AND #$01                                ; $A0F7: 29 01     ; A pressed
  BEQ Loc_A12C                            ; $A0F9: F0 31
  JSR $DEBA                               ; $A0FB: 20 BA DE  ; camera ($6F3F,$6F41) -> province id in Y
  CPY #$FF                                ; $A0FE: C0 FF     ; camera outside map
  BEQ Loc_A122                            ; $A100: F0 20     ; -> UI mode $21
  STY $0402                               ; $A102: 8C 02 04  ; pending province
  TYA                                     ; $A105: 98
  JSR B1F_GetProvinceRecordAddr           ; $A106: 20 AF F2  ; -> ($00) = province record
  LDY #$00                                ; $A109: A0 00
  LDA ($00),Y                             ; $A10B: B1 00
  AND #$07                                ; $A10D: 29 07     ; owner ruler id
  CMP $6F03                               ; $A10F: CD 03 6F  ; ruler under camera = current ruler?
  BNE Loc_A127                            ; $A112: D0 13     ; -> UI mode $22
  LDA #$FF                                ; $A114: A9 FF
  STA $04E4                               ; $A116: 8D E4 04  ; force full sprite refresh
  INC $0400                               ; $A119: EE 00 04  ; advance frame state (sub-state -> 0)
  LDA #$00                                ; $A11C: A9 00
  STA $0401                               ; $A11E: 8D 01 04
  RTS                                     ; $A121: 60
Loc_A122:
; --- Code Region ---
  LDA #$21                                ; $A122: A9 21
  JMP $F26D                               ; $A124: 4C 6D F2
Loc_A127:
  LDA #$22                                ; $A127: A9 22
  JMP $F26D                               ; $A129: 4C 6D F2
Loc_A12C:
  RTS                                     ; $A12C: 60
Loc_A12D:
  LDA a:$0081                             ; $A12D: AD 81 00
  AND #$02                                ; $A130: 29 02
  BEQ $A160                               ; $A132: F0 2C
  LDA #$00                                ; $A134: A9 00
  STA a:$0081                             ; $A136: 8D 81 00
  JSR $DEBA                               ; $A139: 20 BA DE
  CPY #$FF                                ; $A13C: C0 FF
  BEQ $A160                               ; $A13E: F0 20
  STY $0402                               ; $A140: 8C 02 04
  TYA                                     ; $A143: 98
  JSR $F2AF                               ; $A144: 20 AF F2
  LDY #$00                                ; $A147: A0 00
  LDA ($00),Y                             ; $A149: B1 00
  AND #$07                                ; $A14B: 29 07
  CMP $6F03                               ; $A14D: CD 03 6F
  BNE $A160                               ; $A150: D0 0E
  INC $0401                               ; $A152: EE 01 04
  LDA #$00                                ; $A155: A9 00
  STA $0470                               ; $A157: 8D 70 04
  STA $0471                               ; $A15A: 8D 71 04
  JMP $F28B                               ; $A15D: 4C 8B F2
Loc_A160:
  RTS                                     ; $A160: 60
Loc_A161:
  LDA a:$0081                             ; $A161: AD 81 00
  ORA a:$0082                             ; $A164: 0D 82 00
  AND #$04                                ; $A167: 29 04
  BEQ $A178                               ; $A169: F0 0D
  LDA #$00                                ; $A16B: A9 00
  STA a:$0081                             ; $A16D: 8D 81 00
  LDA #$0E                                ; $A170: A9 0E
  STA $0400                               ; $A172: 8D 00 04
  DEC $0401                               ; $A175: CE 01 04
Loc_A178:
  RTS                                     ; $A178: 60
;===============================================================================
; MapRulerIntroWait ($A179-$A18A)
; Frame sub-state 2 of the ruler-intro sequence. Waits for the transition/
; busy slot $0304 to reach $FF (idle), then hands over to frame state $0C
; (banks $19+$1A $A021) with the sub-state reset.
;===============================================================================
MapRulerIntroWait:  ; (dispatch callback target)
  LDA $0304                               ; $A179: AD 04 03  ; transition busy slot
  CMP #$FF                                ; $A17C: C9 FF
  BNE $A18A                               ; $A17E: D0 0A
  LDA #$0C                                ; $A180: A9 0C
  STA $0400                               ; $A182: 8D 00 04
  LDA #$00                                ; $A185: A9 00
  STA $0401                               ; $A187: 8D 01 04
Loc_A18A:
  RTS                                     ; $A18A: 60
Loc_A18B:  ; (dispatch callback target)
  LDA $0401                               ; $A18B: AD 01 04
  JSR $EADE                               ; $A18E: 20 DE EA
; --- Data Region ---
  .byte $95,$A1,$D0,$A1                   ; $A191: 95 A1 D0 A1
Loc_A195:  ; (dispatch callback target)
; --- Code Region ---
  LDA $0140                               ; $A195: AD 40 01
  BNE $A1CF                               ; $A198: D0 35
  LDA $0304                               ; $A19A: AD 04 03
  CMP #$FF                                ; $A19D: C9 FF
  BNE $A1CF                               ; $A19F: D0 2E
  INC $0401                               ; $A1A1: EE 01 04
  JSR $DD70                               ; $A1A4: 20 70 DD
  STA $0470                               ; $A1A7: 8D 70 04
  LDA #$01                                ; $A1AA: A9 01
  STA $0471                               ; $A1AC: 8D 71 04
  STA a:$00B3                             ; $A1AF: 8D B3 00
  LDA #$0C                                ; $A1B2: A9 0C
  STA a:$00BD                             ; $A1B4: 8D BD 00
  LDY #$80                                ; $A1B7: A0 80
  STY $0140                               ; $A1B9: 8C 40 01
  LDX #$01                                ; $A1BC: A2 01
  LDA $6F3F                               ; $A1BE: AD 3F 6F
  BMI $A1C7                               ; $A1C1: 30 04
  LDX #$81                                ; $A1C3: A2 81
  LDY #$40                                ; $A1C5: A0 40
Loc_A1C7:
  STX $0150                               ; $A1C7: 8E 50 01
  LDA #$23                                ; $A1CA: A9 23
  JMP $F26D                               ; $A1CC: 4C 6D F2
Loc_A1CF:
  RTS                                     ; $A1CF: 60
Loc_A1D0:  ; (dispatch callback target)
  LDA #$44                                ; $A1D0: A9 44
  STA a:$0010                             ; $A1D2: 8D 10 00
  LDA #$A2                                ; $A1D5: A9 A2
  STA a:$0011                             ; $A1D7: 8D 11 00
  LDA #$00                                ; $A1DA: A9 00
  STA a:$0012                             ; $A1DC: 8D 12 00
  JSR $ED28                               ; $A1DF: 20 28 ED
  LDA #$4C                                ; $A1E2: A9 4C
  STA a:$0010                             ; $A1E4: 8D 10 00
  LDA #$A2                                ; $A1E7: A9 A2
  STA a:$0011                             ; $A1E9: 8D 11 00
  LDA #$54                                ; $A1EC: A9 54
  STA a:$0000                             ; $A1EE: 8D 00 00
  LDA #$A2                                ; $A1F1: A9 A2
  STA a:$0001                             ; $A1F3: 8D 01 00
  LDA a:$0012                             ; $A1F6: AD 12 00
  JSR $EDF5                               ; $A1F9: 20 F5 ED
  JSR $DDAD                               ; $A1FC: 20 AD DD
  BCC $A243                               ; $A1FF: 90 42
  LDA $0470                               ; $A201: AD 70 04
  BEQ $A209                               ; $A204: F0 03
  JMP $A259                               ; $A206: 4C 59 A2
Loc_A209:
  LDA a:$0081                             ; $A209: AD 81 00
  AND #$30                                ; $A20C: 29 30
  BNE $A259                               ; $A20E: D0 49
  LDA a:$0081                             ; $A210: AD 81 00
  LSR                                     ; $A213: 4A
  BCC $A22B                               ; $A214: 90 15
  LDY a:$0012                             ; $A216: AC 12 00
  INY                                     ; $A219: C8
  INY                                     ; $A21A: C8
  STY $0400                               ; $A21B: 8C 00 04
  LDA #$80                                ; $A21E: A9 80
  STA $0140                               ; $A220: 8D 40 01
  LDA #$00                                ; $A223: A9 00
  STA $0401                               ; $A225: 8D 01 04
  JMP $F26D                               ; $A228: 4C 6D F2
Loc_A22B:
  LSR                                     ; $A22B: 4A
  BCC $A243                               ; $A22C: 90 15
  LDA #$00                                ; $A22E: A9 00
  STA $0400                               ; $A230: 8D 00 04
  STA $0401                               ; $A233: 8D 01 04
  LDA #$80                                ; $A236: A9 80
  STA $0140                               ; $A238: 8D 40 01
  LDA $0150                               ; $A23B: AD 50 01
  ORA #$00                                ; $A23E: 09 00
  STA $0150                               ; $A240: 8D 50 01
Loc_A243:
  RTS                                     ; $A243: 60
; --- Data Region ---
  .byte $00,$01,$02,$03,$FF,$FF,$FF,$FF,$B8,$4C,$B8,$74,$B8,$9C,$B8,$C4; $A244: 00 01 02 03 FF FF FF FF B8 4C B8 74 B8 9C B8 C4
  .byte $00,$04,$00,$00,$80               ; $A254: 00 04 00 00 80
Loc_A259:
; --- Code Region ---
  LDA $0140                               ; $A259: AD 40 01
  BNE $A243                               ; $A25C: D0 E5
  LDA $0470                               ; $A25E: AD 70 04
  BMI $A26D                               ; $A261: 30 0A
  BEQ $A273                               ; $A263: F0 0E
Loc_A265:
  CMP #$0A                                ; $A265: C9 0A
  BEQ $A27C                               ; $A267: F0 13
  INC $0470                               ; $A269: EE 70 04
  RTS                                     ; $A26C: 60
Loc_A26D:
  LDA #$00                                ; $A26D: A9 00
  STA $0470                               ; $A26F: 8D 70 04
  RTS                                     ; $A272: 60
Loc_A273:
  LDA #$80                                ; $A273: A9 80
  STA $0140                               ; $A275: 8D 40 01
  INC $0470                               ; $A278: EE 70 04
  RTS                                     ; $A27B: 60
Loc_A27C:
  LDA #$80                                ; $A27C: A9 80
  STA $0140                               ; $A27E: 8D 40 01
  LDA $0471                               ; $A281: AD 71 04
  EOR #$03                                ; $A284: 49 03
  STA $0471                               ; $A286: 8D 71 04
  ORA $0150                               ; $A289: 0D 50 01
  STA $0150                               ; $A28C: 8D 50 01
  LDA #$80                                ; $A28F: A9 80
  STA $0470                               ; $A291: 8D 70 04
  RTS                                     ; $A294: 60
Loc_A295:  ; (dispatch callback target)
  LDA $0401                               ; $A295: AD 01 04
  JSR $EADE                               ; $A298: 20 DE EA
; --- Data Region ---
  .byte $C9,$A2,$F9,$A2,$66,$A3,$CD,$A3,$71,$A4,$05,$A5,$70,$A5,$EC,$A6; $A29B: C9 A2 F9 A2 66 A3 CD A3 71 A4 05 A5 70 A5 EC A6
  .byte $7C,$A7,$CA,$A7,$24,$A8,$81,$A8,$AF,$A8,$E2,$A8,$FB,$A9,$89,$AA; $A2AB: 7C A7 CA A7 24 A8 81 A8 AF A8 E2 A8 FB A9 89 AA
  .byte $EC,$AA,$CE,$AB,$00,$AC,$2A,$AC,$7C,$AC,$90,$AC,$B8,$AC; $A2BB: EC AA CE AB 00 AC 2A AC 7C AC 90 AC B8 AC
Loc_A2C9:  ; (dispatch callback target)
; --- Code Region ---
  LDA $0140                               ; $A2C9: AD 40 01
  BNE $A2F8                               ; $A2CC: D0 2A
  LDA $0304                               ; $A2CE: AD 04 03
  CMP #$FF                                ; $A2D1: C9 FF
  BNE $A2F8                               ; $A2D3: D0 23
  INC $0401                               ; $A2D5: EE 01 04
  JSR $DD70                               ; $A2D8: 20 70 DD
  STA $0473                               ; $A2DB: 8D 73 04
  STA a:$00A4                             ; $A2DE: 8D A4 00
  LDA #$FF                                ; $A2E1: A9 FF
  STA $0481                               ; $A2E3: 8D 81 04
  LDA #$80                                ; $A2E6: A9 80
  STA $0140                               ; $A2E8: 8D 40 01
  LDA #$02                                ; $A2EB: A9 02
  ORA $0150                               ; $A2ED: 0D 50 01
  STA $0150                               ; $A2F0: 8D 50 01
  LDA #$25                                ; $A2F3: A9 25
  JMP $F26D                               ; $A2F5: 4C 6D F2
Loc_A2F8:
  RTS                                     ; $A2F8: 60
Loc_A2F9:  ; (dispatch callback target)
  LDA #$4D                                ; $A2F9: A9 4D
  STA a:$0010                             ; $A2FB: 8D 10 00
  LDA #$A3                                ; $A2FE: A9 A3
  STA a:$0011                             ; $A300: 8D 11 00
  LDA #$00                                ; $A303: A9 00
  STA a:$0012                             ; $A305: 8D 12 00
  JSR $ED1E                               ; $A308: 20 1E ED
  LDA #$55                                ; $A30B: A9 55
  STA a:$0010                             ; $A30D: 8D 10 00
  LDA #$A3                                ; $A310: A9 A3
  STA a:$0011                             ; $A312: 8D 11 00
  LDA #$61                                ; $A315: A9 61
  STA a:$0000                             ; $A317: 8D 00 00
  LDA #$A3                                ; $A31A: A9 A3
  STA a:$0001                             ; $A31C: 8D 01 00
  LDA a:$0012                             ; $A31F: AD 12 00
  JSR $EDF5                               ; $A322: 20 F5 ED
  JSR $DDAD                               ; $A325: 20 AD DD
  BCC $A34C                               ; $A328: 90 22
  LDA a:$0081                             ; $A32A: AD 81 00
  LSR                                     ; $A32D: 4A
  BCC $A33C                               ; $A32E: 90 0C
  LDA a:$0012                             ; $A330: AD 12 00
  STA $0470                               ; $A333: 8D 70 04
  INC $0401                               ; $A336: EE 01 04
  JMP $DD70                               ; $A339: 4C 70 DD
Loc_A33C:
  LSR                                     ; $A33C: 4A
  BCC $A34C                               ; $A33D: 90 0D
  JSR $D568                               ; $A33F: 20 68 D5
  LDA #$01                                ; $A342: A9 01
  STA $0400                               ; $A344: 8D 00 04
  LDA #$00                                ; $A347: A9 00
  STA $0401                               ; $A349: 8D 01 04
Loc_A34C:
  RTS                                     ; $A34C: 60
; --- Data Region ---
  .byte $00,$01,$02,$03,$04,$05,$FF,$FF,$B8,$46,$B8,$96,$C8,$46,$C8,$96; $A34D: 00 01 02 03 04 05 FF FF B8 46 B8 96 C8 46 C8 96
  .byte $D8,$46,$D8,$96,$00,$07,$00,$00,$80; $A35D: D8 46 D8 96 00 07 00 00 80
Loc_A366:  ; (dispatch callback target)
; --- Code Region ---
  LDA $0470                               ; $A366: AD 70 04
  BNE $A373                               ; $A369: D0 08
  INC $0401                               ; $A36B: EE 01 04
  LDA #$26                                ; $A36E: A9 26
  JMP $F26D                               ; $A370: 4C 6D F2
Loc_A373:
  CMP #$01                                ; $A373: C9 01
  BNE $A38A                               ; $A375: D0 13
  JSR $D568                               ; $A377: 20 68 D5
  LDA $0402                               ; $A37A: AD 02 04
  STA $0470                               ; $A37D: 8D 70 04
  LDA #$07                                ; $A380: A9 07
  STA $0401                               ; $A382: 8D 01 04
  LDA #$2E                                ; $A385: A9 2E
  JMP $F26D                               ; $A387: 4C 6D F2
Loc_A38A:
  CMP #$02                                ; $A38A: C9 02
  BNE $A3A2                               ; $A38C: D0 14
  LDA #$0B                                ; $A38E: A9 0B
  STA $0401                               ; $A390: 8D 01 04
  LDA #$80                                ; $A393: A9 80
  STA $0478                               ; $A395: 8D 78 04
  LDA #$0F                                ; $A398: A9 0F
  STA $047C                               ; $A39A: 8D 7C 04
  LDA #$27                                ; $A39D: A9 27
  JMP $F26D                               ; $A39F: 4C 6D F2
Loc_A3A2:
  CMP #$03                                ; $A3A2: C9 03
  BNE $A3B0                               ; $A3A4: D0 0A
  LDA #$11                                ; $A3A6: A9 11
  STA $0401                               ; $A3A8: 8D 01 04
  LDA #$4F                                ; $A3AB: A9 4F
  JMP $F26D                               ; $A3AD: 4C 6D F2
Loc_A3B0:
  CMP #$04                                ; $A3B0: C9 04
  BNE $A3C3                               ; $A3B2: D0 0F
  LDA #$06                                ; $A3B4: A9 06
  STA $0400                               ; $A3B6: 8D 00 04
  LDA #$00                                ; $A3B9: A9 00
  STA $0401                               ; $A3BB: 8D 01 04
  LDA #$3B                                ; $A3BE: A9 3B
  JMP $F26D                               ; $A3C0: 4C 6D F2
Loc_A3C3:
  LDA #$12                                ; $A3C3: A9 12
  STA $0401                               ; $A3C5: 8D 01 04
  LDA #$51                                ; $A3C8: A9 51
  JMP $F26D                               ; $A3CA: 4C 6D F2
Loc_A3CD:  ; (dispatch callback target)
  LDA #$5F                                ; $A3CD: A9 5F
  STA a:$0010                             ; $A3CF: 8D 10 00
  LDA #$A4                                ; $A3D2: A9 A4
  STA a:$0011                             ; $A3D4: 8D 11 00
  LDA #$00                                ; $A3D7: A9 00
  STA a:$0012                             ; $A3D9: 8D 12 00
  JSR $ED19                               ; $A3DC: 20 19 ED
  LDA #$63                                ; $A3DF: A9 63
  STA a:$0010                             ; $A3E1: 8D 10 00
  LDA #$A4                                ; $A3E4: A9 A4
  STA a:$0011                             ; $A3E6: 8D 11 00
  LDA #$69                                ; $A3E9: A9 69
  STA a:$0000                             ; $A3EB: 8D 00 00
  LDA #$A4                                ; $A3EE: A9 A4
  STA a:$0001                             ; $A3F0: 8D 01 00
  LDA a:$0012                             ; $A3F3: AD 12 00
  JSR $EDF5                               ; $A3F6: 20 F5 ED
  JSR $DDAD                               ; $A3F9: 20 AD DD
  BCC $A40C                               ; $A3FC: 90 0E
  LDA a:$0081                             ; $A3FE: AD 81 00
  LSR                                     ; $A401: 4A
  BCS $A40D                               ; $A402: B0 09
  LSR                                     ; $A404: 4A
  BCC $A40C                               ; $A405: 90 05
  LDA #$00                                ; $A407: A9 00
  STA $0401                               ; $A409: 8D 01 04
Loc_A40C:
  RTS                                     ; $A40C: 60
Loc_A40D:
  LDA $0402                               ; $A40D: AD 02 04
  JSR $F2AF                               ; $A410: 20 AF F2
  LDA #$E7                                ; $A413: A9 E7
  STA a:$0010                             ; $A415: 8D 10 00
  LDA #$03                                ; $A418: A9 03
  STA a:$0011                             ; $A41A: 8D 11 00
  LDY a:$0012                             ; $A41D: AC 12 00
  STY $0470                               ; $A420: 8C 70 04
  CPY #$02                                ; $A423: C0 02
  BNE $A431                               ; $A425: D0 0A
  LDA #$0F                                ; $A427: A9 0F
  STA a:$0010                             ; $A429: 8D 10 00
  LDA #$27                                ; $A42C: A9 27
  STA a:$0011                             ; $A42E: 8D 11 00
Loc_A431:
  LDA $A46E,Y                             ; $A431: B9 6E A4
  TAY                                     ; $A434: A8
  LDA ($00),Y                             ; $A435: B1 00
  SEC                                     ; $A437: 38
  SBC a:$0010                             ; $A438: ED 10 00
  INY                                     ; $A43B: C8
  LDA ($00),Y                             ; $A43C: B1 00
  SBC a:$0011                             ; $A43E: ED 11 00
  BCC $A44D                               ; $A441: 90 0A
  LDA #$16                                ; $A443: A9 16
  STA $0401                               ; $A445: 8D 01 04
  LDA #$A7                                ; $A448: A9 A7
  JMP $F26D                               ; $A44A: 4C 6D F2
Loc_A44D:
  LDA #$80                                ; $A44D: A9 80
  STA $0478                               ; $A44F: 8D 78 04
  LDA #$0F                                ; $A452: A9 0F
  STA $047C                               ; $A454: 8D 7C 04
  INC $0401                               ; $A457: EE 01 04
  LDA #$27                                ; $A45A: A9 27
  JMP $F26D                               ; $A45C: 4C 6D F2
; --- Data Region ---
  .byte $00,$01,$02,$FF,$B8,$58,$C8,$58,$D8,$58,$00,$07,$00,$00,$80,$08; $A45F: 00 01 02 FF B8 58 C8 58 D8 58 00 07 00 00 80 08
  .byte $0E,$06                           ; $A46F: 0E 06
Loc_A471:  ; (dispatch callback target)
; --- Code Region ---
  LDA $0478                               ; $A471: AD 78 04
  BNE $A49C                               ; $A474: D0 26
  JSR $D64A                               ; $A476: 20 4A D6
  LDA $047C                               ; $A479: AD 7C 04
  BPL $A49C                               ; $A47C: 10 1E
  CMP #$90                                ; $A47E: C9 90
  BNE $A49D                               ; $A480: D0 1B
  JSR $DD70                               ; $A482: 20 70 DD
  LDA $0470                               ; $A485: AD 70 04
  CMP #$03                                ; $A488: C9 03
  BNE $A492                               ; $A48A: D0 06
  LDA #$00                                ; $A48C: A9 00
  STA $0401                               ; $A48E: 8D 01 04
  RTS                                     ; $A491: 60
Loc_A492:
  LDA #$03                                ; $A492: A9 03
  STA $0401                               ; $A494: 8D 01 04
  LDA #$26                                ; $A497: A9 26
  JMP $F26D                               ; $A499: 4C 6D F2
; --- Data Region ---
  .byte $60                               ; $A49C: 60
Loc_A49D:
; --- Code Region ---
  JSR $D7A8                               ; $A49D: 20 A8 D7
  LDA $0481                               ; $A4A0: AD 81 04
  STA a:$0000                             ; $A4A3: 8D 00 00
  LDY #$3D                                ; $A4A6: A0 3D
  JSR $EE07                               ; $A4A8: 20 07 EE
; --- Data Region ---
  .byte $2A,$A0,$AD,$81,$04,$20,$D7,$F2,$A0,$02,$B1,$00,$8D,$82,$04,$EE; $A4AB: 2A A0 AD 81 04 20 D7 F2 A0 02 B1 00 8D 82 04 EE
  .byte $01,$04,$AD,$70,$04,$C9,$03,$F0,$0D,$A0,$39,$20,$07,$EE,$24,$A0; $A4BB: 01 04 AD 70 04 C9 03 F0 0D A0 39 20 07 EE 24 A0
  .byte $AD,$71,$04,$4C,$6D,$F2           ; $A4CB: AD 71 04 4C 6D F2
Loc_A4D1:
; --- Code Region ---
  JSR $E850                               ; $A4D1: 20 50 E8
  STA $0472                               ; $A4D4: 8D 72 04
  LDA $0482                               ; $A4D7: AD 82 04
  CMP #$51                                ; $A4DA: C9 51
  BCC $A4E3                               ; $A4DC: 90 05
  LDA #$10                                ; $A4DE: A9 10
  JMP $A4EE                               ; $A4E0: 4C EE A4
Loc_A4E3:
  CMP #$33                                ; $A4E3: C9 33
  BCC $A4EC                               ; $A4E5: 90 05
  LDA #$0D                                ; $A4E7: A9 0D
  JMP $A4EE                               ; $A4E9: 4C EE A4
Loc_A4EC:
  LDA #$0A                                ; $A4EC: A9 0A
Loc_A4EE:
  CLC                                     ; $A4EE: 18
  ADC $0472                               ; $A4EF: 6D 72 04
  STA $0472                               ; $A4F2: 8D 72 04
  STA $042C                               ; $A4F5: 8D 2C 04
  LDA #$00                                ; $A4F8: A9 00
  STA $042D                               ; $A4FA: 8D 2D 04
  STA $042E                               ; $A4FD: 8D 2E 04
  LDA #$4F                                ; $A500: A9 4F
  JMP $F26D                               ; $A502: 4C 6D F2
Loc_A505:  ; (dispatch callback target)
  LDA $0481                               ; $A505: AD 81 04
  JSR $DD5E                               ; $A508: 20 5E DD
  JSR $DDAD                               ; $A50B: 20 AD DD
  BCC $A53C                               ; $A50E: 90 2C
  JSR $D543                               ; $A510: 20 43 D5
  LDA a:$0081                             ; $A513: AD 81 00
  LSR                                     ; $A516: 4A
  BCS $A53D                               ; $A517: B0 24
  LSR                                     ; $A519: 4A
  BCC $A53C                               ; $A51A: 90 20
  LDY #$3D                                ; $A51C: A0 3D
  JSR $EE07                               ; $A51E: 20 07 EE
; --- Data Region ---
  .byte $24,$A0,$AD,$70,$04,$C9,$03,$F0,$0D,$A9,$03,$8D,$01,$04,$20,$70; $A521: 24 A0 AD 70 04 C9 03 F0 0D A9 03 8D 01 04 20 70
  .byte $DD,$A9,$26,$4C,$6D,$F2           ; $A531: DD A9 26 4C 6D F2
Loc_A537:
; --- Code Region ---
  LDA #$00                                ; $A537: A9 00
  STA $0401                               ; $A539: 8D 01 04
Loc_A53C:
  RTS                                     ; $A53C: 60
Loc_A53D:
  LDA $0402                               ; $A53D: AD 02 04
  JSR $F2AF                               ; $A540: 20 AF F2
  LDY #$02                                ; $A543: A0 02
  LDA ($00),Y                             ; $A545: B1 00
  CMP $0472                               ; $A547: CD 72 04
  BCS $A551                               ; $A54A: B0 05
  INY                                     ; $A54C: C8
  LDA ($00),Y                             ; $A54D: B1 00
  BEQ $A566                               ; $A54F: F0 15
Loc_A551:
  INC $0401                               ; $A551: EE 01 04
  LDY #$3D                                ; $A554: A0 3D
  JSR $EE07                               ; $A556: 20 07 EE
; --- Data Region ---
  .byte $24,$A0,$20,$70,$DD,$8D,$6C,$04,$A9,$29,$4C,$6D,$F2; $A559: 24 A0 20 70 DD 8D 6C 04 A9 29 4C 6D F2
Loc_A566:
; --- Code Region ---
  LDA #$16                                ; $A566: A9 16
  STA $0401                               ; $A568: 8D 01 04
  LDA #$2A                                ; $A56B: A9 2A
  JMP $F26D                               ; $A56D: 4C 6D F2
Loc_A570:  ; (dispatch callback target)
  JSR $D5BD                               ; $A570: 20 BD D5
  LDA a:$0013                             ; $A573: AD 13 00
  BEQ $A581                               ; $A576: F0 09
  CMP #$FF                                ; $A578: C9 FF
  BNE $A582                               ; $A57A: D0 06
  LDA #$00                                ; $A57C: A9 00
  STA $0401                               ; $A57E: 8D 01 04
Loc_A581:
  RTS                                     ; $A581: 60
Loc_A582:
  LDA #$00                                ; $A582: A9 00
  STA a:$0001                             ; $A584: 8D 01 00
  STA a:$0002                             ; $A587: 8D 02 00
  LDA $0472                               ; $A58A: AD 72 04
  STA a:$0000                             ; $A58D: 8D 00 00
  LDA $0482                               ; $A590: AD 82 04
  STA a:$0003                             ; $A593: 8D 03 00
  JSR $EBE9                               ; $A596: 20 E9 EB
  LDA #$64                                ; $A599: A9 64
  STA a:$0003                             ; $A59B: 8D 03 00
  LDA #$00                                ; $A59E: A9 00
  STA a:$0004                             ; $A5A0: 8D 04 00
  JSR $DB72                               ; $A5A3: 20 72 DB
  LDA $0470                               ; $A5A6: AD 70 04
  CMP #$03                                ; $A5A9: C9 03
  BEQ $A5B6                               ; $A5AB: F0 09
  JSR $E856                               ; $A5AD: 20 56 E8
  CLC                                     ; $A5B0: 18
  ADC #$0A                                ; $A5B1: 69 0A
  JMP $A5BF                               ; $A5B3: 4C BF A5
Loc_A5B6:
  JSR $E856                               ; $A5B6: 20 56 E8
  CMP #$05                                ; $A5B9: C9 05
  BCS $A5B6                               ; $A5BB: B0 F9
  ADC #$06                                ; $A5BD: 69 06
Loc_A5BF:
  STA a:$0003                             ; $A5BF: 8D 03 00
  JSR $EBE9                               ; $A5C2: 20 E9 EB
  LDA #$00                                ; $A5C5: A9 00
  STA a:$0004                             ; $A5C7: 8D 04 00
  LDA #$0A                                ; $A5CA: A9 0A
  STA a:$0003                             ; $A5CC: 8D 03 00
  JSR $DB72                               ; $A5CF: 20 72 DB
  LDA a:$0000                             ; $A5D2: AD 00 00
  BNE $A5D9                               ; $A5D5: D0 02
  LDA #$01                                ; $A5D7: A9 01
Loc_A5D9:
  STA $042C                               ; $A5D9: 8D 2C 04
  LDA #$00                                ; $A5DC: A9 00
  STA $042D                               ; $A5DE: 8D 2D 04
  STA $042E                               ; $A5E1: 8D 2E 04
  JSR $D568                               ; $A5E4: 20 68 D5
  LDA $0402                               ; $A5E7: AD 02 04
  JSR $F2AF                               ; $A5EA: 20 AF F2
  LDY #$02                                ; $A5ED: A0 02
  LDA ($00),Y                             ; $A5EF: B1 00
  SEC                                     ; $A5F1: 38
  SBC $0472                               ; $A5F2: ED 72 04
  STA ($00),Y                             ; $A5F5: 91 00
  INY                                     ; $A5F7: C8
  LDA ($00),Y                             ; $A5F8: B1 00
  SBC #$00                                ; $A5FA: E9 00
  STA ($00),Y                             ; $A5FC: 91 00
  LDA #$14                                ; $A5FE: A9 14
  STA $0401                               ; $A600: 8D 01 04
  LDA #$FF                                ; $A603: A9 FF
  STA $0481                               ; $A605: 8D 81 04
  LDA #$E7                                ; $A608: A9 E7
  STA a:$0010                             ; $A60A: 8D 10 00
  LDA #$03                                ; $A60D: A9 03
  STA a:$0011                             ; $A60F: 8D 11 00
  LDA $0470                               ; $A612: AD 70 04
  BNE $A626                               ; $A615: D0 0F
  LDY #$08                                ; $A617: A0 08
  JSR $A690                               ; $A619: 20 90 A6
  LDA #$24                                ; $A61C: A9 24
  STA $04D6                               ; $A61E: 8D D6 04
  LDA #$2B                                ; $A621: A9 2B
  JMP $F26D                               ; $A623: 4C 6D F2
Loc_A626:
  CMP #$01                                ; $A626: C9 01
  BNE $A639                               ; $A628: D0 0F
  LDY #$0E                                ; $A62A: A0 0E
  JSR $A690                               ; $A62C: 20 90 A6
  LDA #$29                                ; $A62F: A9 29
  STA $04D6                               ; $A631: 8D D6 04
  LDA #$2C                                ; $A634: A9 2C
  JMP $F26D                               ; $A636: 4C 6D F2
Loc_A639:
  CMP #$02                                ; $A639: C9 02
  BNE $A661                               ; $A63B: D0 24
  LSR $042C                               ; $A63D: 4E 2C 04
  LDA $042C                               ; $A640: AD 2C 04
  BNE $A648                               ; $A643: D0 03
  INC $042C                               ; $A645: EE 2C 04
Loc_A648:
  LDA #$0F                                ; $A648: A9 0F
  STA a:$0010                             ; $A64A: 8D 10 00
  LDA #$27                                ; $A64D: A9 27
  STA a:$0011                             ; $A64F: 8D 11 00
  LDY #$06                                ; $A652: A0 06
  JSR $A690                               ; $A654: 20 90 A6
  LDA #$2E                                ; $A657: A9 2E
  STA $04D6                               ; $A659: 8D D6 04
  LDA #$2D                                ; $A65C: A9 2D
  JMP $F26D                               ; $A65E: 4C 6D F2
Loc_A661:
  LDY #$0A                                ; $A661: A0 0A
  LDA ($00),Y                             ; $A663: B1 00
  CLC                                     ; $A665: 18
  ADC $042C                               ; $A666: 6D 2C 04
  STA ($00),Y                             ; $A669: 91 00
  SEC                                     ; $A66B: 38
  SBC #$63                                ; $A66C: E9 63
  BCC $A681                               ; $A66E: 90 11
  STA a:$0002                             ; $A670: 8D 02 00
  LDA $042C                               ; $A673: AD 2C 04
  SEC                                     ; $A676: 38
  SBC a:$0002                             ; $A677: ED 02 00
  STA $042C                               ; $A67A: 8D 2C 04
  LDA #$63                                ; $A67D: A9 63
  STA ($00),Y                             ; $A67F: 91 00
Loc_A681:
  LDA #$07                                ; $A681: A9 07
  STA $04A2                               ; $A683: 8D A2 04
  LDA #$24                                ; $A686: A9 24
  STA $04D6                               ; $A688: 8D D6 04
  LDA #$50                                ; $A68B: A9 50
  JMP $F26D                               ; $A68D: 4C 6D F2
Loc_A690:
  LDA ($00),Y                             ; $A690: B1 00
  CLC                                     ; $A692: 18
  ADC $042C                               ; $A693: 6D 2C 04
  STA ($00),Y                             ; $A696: 91 00
  STA a:$0002                             ; $A698: 8D 02 00
  INY                                     ; $A69B: C8
  LDA ($00),Y                             ; $A69C: B1 00
  ADC #$00                                ; $A69E: 69 00
  STA ($00),Y                             ; $A6A0: 91 00
  STA a:$0003                             ; $A6A2: 8D 03 00
  LDA a:$0002                             ; $A6A5: AD 02 00
  SEC                                     ; $A6A8: 38
  SBC a:$0010                             ; $A6A9: ED 10 00
  STA a:$0004                             ; $A6AC: 8D 04 00
  LDA a:$0003                             ; $A6AF: AD 03 00
  SBC a:$0011                             ; $A6B2: ED 11 00
  BCC $A6CC                               ; $A6B5: 90 15
  LDA $042C                               ; $A6B7: AD 2C 04
  SEC                                     ; $A6BA: 38
  SBC a:$0004                             ; $A6BB: ED 04 00
  STA $042C                               ; $A6BE: 8D 2C 04
  LDA a:$0011                             ; $A6C1: AD 11 00
  STA ($00),Y                             ; $A6C4: 91 00
  DEY                                     ; $A6C6: 88
  LDA a:$0010                             ; $A6C7: AD 10 00
  STA ($00),Y                             ; $A6CA: 91 00
Loc_A6CC:
  LDA #$01                                ; $A6CC: A9 01
  STA a:$0002                             ; $A6CE: 8D 02 00
  LDA $042C                               ; $A6D1: AD 2C 04
  CMP #$1F                                ; $A6D4: C9 1F
  BCC $A6DB                               ; $A6D6: 90 03
  INC a:$0002                             ; $A6D8: EE 02 00
Loc_A6DB:
  LDY #$0B                                ; $A6DB: A0 0B
  LDA ($00),Y                             ; $A6DD: B1 00
  CLC                                     ; $A6DF: 18
  ADC a:$0002                             ; $A6E0: 6D 02 00
  CMP #$64                                ; $A6E3: C9 64
  BCC $A6E9                               ; $A6E5: 90 02
  LDA #$64                                ; $A6E7: A9 64
Loc_A6E9:
  STA ($00),Y                             ; $A6E9: 91 00
  RTS                                     ; $A6EB: 60
Loc_A6EC:  ; (dispatch callback target)
  JSR $DDF2                               ; $A6EC: 20 F2 DD
  JSR $DDAD                               ; $A6EF: 20 AD DD
  BCC $A771                               ; $A6F2: 90 7D
  LDA a:$0081                             ; $A6F4: AD 81 00
  LSR                                     ; $A6F7: 4A
  BCC $A75A                               ; $A6F8: 90 60
  JSR $DEBA                               ; $A6FA: 20 BA DE
  CPY #$FF                                ; $A6FD: C0 FF
  BEQ $A772                               ; $A6FF: F0 71
  STY $0402                               ; $A701: 8C 02 04
  JSR $DD79                               ; $A704: 20 79 DD
  LDA $0402                               ; $A707: AD 02 04
  BMI $A777                               ; $A70A: 30 6B
  STA $0471                               ; $A70C: 8D 71 04
  LDA a:$0010                             ; $A70F: AD 10 00
  CMP #$07                                ; $A712: C9 07
  BEQ $A71B                               ; $A714: F0 05
  CMP $6F03                               ; $A716: CD 03 6F
  BNE $A777                               ; $A719: D0 5C
Loc_A71B:
  LDA $0471                               ; $A71B: AD 71 04
  JSR $DC6B                               ; $A71E: 20 6B DC
  CPX #$0A                                ; $A721: E0 0A
  BEQ $A777                               ; $A723: F0 52
  STX $047C                               ; $A725: 8E 7C 04
  LDA #$0A                                ; $A728: A9 0A
  SEC                                     ; $A72A: 38
  SBC $047C                               ; $A72B: ED 7C 04
  STA $047C                               ; $A72E: 8D 7C 04
  LDA $0470                               ; $A731: AD 70 04
  JSR $F2AF                               ; $A734: 20 AF F2
  JSR $DC6B                               ; $A737: 20 6B DC
  CPX $047C                               ; $A73A: EC 7C 04
  BCS $A742                               ; $A73D: B0 03
  STX $047C                               ; $A73F: 8E 7C 04
Loc_A742:
  INC $0401                               ; $A742: EE 01 04
  LDA #$FF                                ; $A745: A9 FF
  STA $04E4                               ; $A747: 8D E4 04
  LDA $0470                               ; $A74A: AD 70 04
  STA $0402                               ; $A74D: 8D 02 04
  LDA #$80                                ; $A750: A9 80
  STA $0478                               ; $A752: 8D 78 04
  LDA #$27                                ; $A755: A9 27
  JMP $F26D                               ; $A757: 4C 6D F2
Loc_A75A:
  LSR                                     ; $A75A: 4A
  BCC $A771                               ; $A75B: 90 14
  LDA #$FF                                ; $A75D: A9 FF
  STA $04E4                               ; $A75F: 8D E4 04
  JSR $DDAD                               ; $A762: 20 AD DD
  BCC $A771                               ; $A765: 90 0A
  LDA #$00                                ; $A767: A9 00
  STA $0401                               ; $A769: 8D 01 04
  LDA #$02                                ; $A76C: A9 02
  JSR $D58C                               ; $A76E: 20 8C D5
Loc_A771:
  RTS                                     ; $A771: 60
Loc_A772:
  LDA #$24                                ; $A772: A9 24
  JMP $F26D                               ; $A774: 4C 6D F2
Loc_A777:
  LDA #$2F                                ; $A777: A9 2F
  JMP $F26D                               ; $A779: 4C 6D F2
Loc_A77C:  ; (dispatch callback target)
  LDA $0478                               ; $A77C: AD 78 04
  BNE $A7C9                               ; $A77F: D0 48
  JSR $D64A                               ; $A781: 20 4A D6
  LDA $047C                               ; $A784: AD 7C 04
  BPL $A7C9                               ; $A787: 10 40
  CMP #$90                                ; $A789: C9 90
  BEQ $A7BF                               ; $A78B: F0 32
  JSR $D7A8                               ; $A78D: 20 A8 D7
  LDA #$02                                ; $A790: A9 02
  JSR $D58C                               ; $A792: 20 8C D5
  INC $0401                               ; $A795: EE 01 04
  JSR $DD70                               ; $A798: 20 70 DD
  STA $046C                               ; $A79B: 8D 6C 04
  JSR $DC6B                               ; $A79E: 20 6B DC
  STX a:$0002                             ; $A7A1: 8E 02 00
  LDX #$00                                ; $A7A4: A2 00
  LDY #$00                                ; $A7A6: A0 00
Loc_A7A8:
  LDA $0481,Y                             ; $A7A8: B9 81 04
  CMP #$FF                                ; $A7AB: C9 FF
  BEQ $A7B0                               ; $A7AD: F0 01
  INX                                     ; $A7AF: E8
Loc_A7B0:
  INY                                     ; $A7B0: C8
  CPY #$0A                                ; $A7B1: C0 0A
  BCC $A7A8                               ; $A7B3: 90 F3
  CPX a:$0002                             ; $A7B5: EC 02 00
  BNE $A806                               ; $A7B8: D0 4C
  LDA #$32                                ; $A7BA: A9 32
  JMP $F26D                               ; $A7BC: 4C 6D F2
Loc_A7BF:
  LDA #$00                                ; $A7BF: A9 00
  STA $0401                               ; $A7C1: 8D 01 04
  LDA #$02                                ; $A7C4: A9 02
  JSR $D58C                               ; $A7C6: 20 8C D5
Loc_A7C9:
  RTS                                     ; $A7C9: 60
Loc_A7CA:  ; (dispatch callback target)
  LDA #$17                                ; $A7CA: A9 17
  STA a:$0010                             ; $A7CC: 8D 10 00
  LDA #$A8                                ; $A7CF: A9 A8
  STA a:$0011                             ; $A7D1: 8D 11 00
  LDA #$00                                ; $A7D4: A9 00
  STA a:$0012                             ; $A7D6: 8D 12 00
  JSR $ED1E                               ; $A7D9: 20 1E ED
  LDA #$1B                                ; $A7DC: A9 1B
  STA a:$0010                             ; $A7DE: 8D 10 00
  LDA #$A8                                ; $A7E1: A9 A8
  STA a:$0011                             ; $A7E3: 8D 11 00
  LDA #$1F                                ; $A7E6: A9 1F
  STA a:$0000                             ; $A7E8: 8D 00 00
  LDA #$A8                                ; $A7EB: A9 A8
  STA a:$0001                             ; $A7ED: 8D 01 00
  LDA a:$0012                             ; $A7F0: AD 12 00
  JSR $EDF5                               ; $A7F3: 20 F5 ED
  JSR $DDAD                               ; $A7F6: 20 AD DD
  BCC $A816                               ; $A7F9: 90 1B
  LDA a:$0081                             ; $A7FB: AD 81 00
  LSR                                     ; $A7FE: 4A
  BCC $A80E                               ; $A7FF: 90 0D
  LDA a:$0012                             ; $A801: AD 12 00
  BNE $A811                               ; $A804: D0 0B
Loc_A806:
  INC $0401                               ; $A806: EE 01 04
  LDA #$29                                ; $A809: A9 29
  JMP $F26D                               ; $A80B: 4C 6D F2
Loc_A80E:
  LSR                                     ; $A80E: 4A
  BCC $A816                               ; $A80F: 90 05
Loc_A811:
  LDA #$00                                ; $A811: A9 00
  STA $0401                               ; $A813: 8D 01 04
Loc_A816:
  RTS                                     ; $A816: 60
; --- Data Region ---
  .byte $00,$01,$FF,$FF,$C8,$60,$C8,$B0,$00; $A817: 00 01 FF FF C8 60 C8 B0 00
Loc_A820:
  .byte $07,$00,$00,$80,$20,$BD,$D5,$AD,$13,$00,$F0,$54,$C9,$FF,$F0,$4B; $A820: 07 00 00 80 20 BD D5 AD 13 00 F0 54 C9 FF F0 4B
  .byte $20,$41,$AD,$A9,$11,$8D,$A2,$04,$A9,$32,$8D,$D6,$04,$A9,$FF,$8D; $A830: 20 41 AD A9 11 8D A2 04 A9 32 8D D6 04 A9 FF 8D
  .byte $81,$04,$20,$68,$D5,$A9,$14,$8D,$01,$04,$A9,$FF,$8D,$81,$04,$AD; $A840: 81 04 20 68 D5 A9 14 8D 01 04 A9 FF 8D 81 04 AD
  .byte $70,$04,$20,$AF,$F2,$A0,$00,$B1,$00,$8D,$10,$00,$20,$6B,$DC,$E0; $A850: 70 04 20 AF F2 A0 00 B1 00 8D 10 00 20 6B DC E0
  .byte $00,$D0,$06,$A9,$07,$A0,$00,$91,$00; $A860: 00 D0 06 A9 07 A0 00 91 00
Loc_A869:
; --- Code Region ---
  LDA $0471                               ; $A869: AD 71 04
  JSR $F2AF                               ; $A86C: 20 AF F2
  LDY #$00                                ; $A86F: A0 00
  LDA a:$0010                             ; $A871: AD 10 00
  STA ($00),Y                             ; $A874: 91 00
  LDA #$31                                ; $A876: A9 31
  JMP $F26D                               ; $A878: 4C 6D F2
Loc_A87B:
  LDA #$00                                ; $A87B: A9 00
  STA $0401                               ; $A87D: 8D 01 04
Loc_A880:
  RTS                                     ; $A880: 60
Loc_A881:  ; (dispatch callback target)
  LDA $0478                               ; $A881: AD 78 04
  BNE $A8AE                               ; $A884: D0 28
  JSR $D64A                               ; $A886: 20 4A D6
  LDA $047C                               ; $A889: AD 7C 04
  BPL $A8AE                               ; $A88C: 10 20
  CMP #$90                                ; $A88E: C9 90
  BEQ $A8A9                               ; $A890: F0 17
  JSR $D7A8                               ; $A892: 20 A8 D7
  INC $0401                               ; $A895: EE 01 04
  LDA $0481                               ; $A898: AD 81 04
  STA $0482                               ; $A89B: 8D 82 04
  JSR $DD70                               ; $A89E: 20 70 DD
  STA $046C                               ; $A8A1: 8D 6C 04
  LDA #$29                                ; $A8A4: A9 29
  JMP $F26D                               ; $A8A6: 4C 6D F2
Loc_A8A9:
  LDA #$00                                ; $A8A9: A9 00
  STA $0401                               ; $A8AB: 8D 01 04
Loc_A8AE:
  RTS                                     ; $A8AE: 60
Loc_A8AF:  ; (dispatch callback target)
  JSR $D5BD                               ; $A8AF: 20 BD D5
  LDA a:$0013                             ; $A8B2: AD 13 00
  BEQ $A8E1                               ; $A8B5: F0 2A
  CMP #$FF                                ; $A8B7: C9 FF
  BEQ $A8DC                               ; $A8B9: F0 21
  LDA #$1B                                ; $A8BB: A9 1B
  STA $04A2                               ; $A8BD: 8D A2 04
  LDA #$32                                ; $A8C0: A9 32
  STA $04D6                               ; $A8C2: 8D D6 04
  JSR $D568                               ; $A8C5: 20 68 D5
  LDA #$80                                ; $A8C8: A9 80
  STA $0473                               ; $A8CA: 8D 73 04
  LDA #$FF                                ; $A8CD: A9 FF
  STA $0481                               ; $A8CF: 8D 81 04
  LDA #$14                                ; $A8D2: A9 14
  STA $0401                               ; $A8D4: 8D 01 04
  LDA #$31                                ; $A8D7: A9 31
  JMP $F26D                               ; $A8D9: 4C 6D F2
Loc_A8DC:
  LDA #$00                                ; $A8DC: A9 00
  STA $0401                               ; $A8DE: 8D 01 04
Loc_A8E1:
  RTS                                     ; $A8E1: 60
Loc_A8E2:  ; (dispatch callback target)
  LDA $0140                               ; $A8E2: AD 40 01
  BNE $A8F6                               ; $A8E5: D0 0F
  JSR $DDAD                               ; $A8E7: 20 AD DD
  BCC $A8F6                               ; $A8EA: 90 0A
  JSR $D543                               ; $A8EC: 20 43 D5
  LDA a:$0081                             ; $A8EF: AD 81 00
  AND #$03                                ; $A8F2: 29 03
  BNE $A8F7                               ; $A8F4: D0 01
Loc_A8F6:
  RTS                                     ; $A8F6: 60
Loc_A8F7:
  LDA $0482                               ; $A8F7: AD 82 04
  STA a:$0000                             ; $A8FA: 8D 00 00
  LDY #$3D                                ; $A8FD: A0 3D
  JSR $EE07                               ; $A8FF: 20 07 EE
; --- Data Region ---
  .byte $2A,$A0,$A9,$03,$8D,$A4,$00,$AD,$82,$04,$8D,$81,$04,$20,$99,$DB; $A902: 2A A0 A9 03 8D A4 00 AD 82 04 8D 81 04 20 99 DB
  .byte $AD,$70,$04,$C9,$08,$F0,$16,$AD,$70,$04,$C9,$04,$F0,$1E,$90,$4C; $A912: AD 70 04 C9 08 F0 16 AD 70 04 C9 04 F0 1E 90 4C
  .byte $A9,$FF,$8D,$81,$04,$EE,$01,$04,$A9,$33,$4C,$6D,$F2; $A922: A9 FF 8D 81 04 EE 01 04 A9 33 4C 6D F2
Loc_A92F:
; --- Code Region ---
  LDA #$04                                ; $A92F: A9 04
  STA a:$00A4                             ; $A931: 8D A4 00
  LDA #$16                                ; $A934: A9 16
  STA $0401                               ; $A936: 8D 01 04
  LDA #$35                                ; $A939: A9 35
  JMP $F26D                               ; $A93B: 4C 6D F2
Loc_A93E:
  JSR $E850                               ; $A93E: 20 50 E8
  BEQ $A93E                               ; $A941: F0 FB
  STA $042C                               ; $A943: 8D 2C 04
  LDA #$00                                ; $A946: A9 00
  STA $042D                               ; $A948: 8D 2D 04
  STA $042E                               ; $A94B: 8D 2E 04
  LDA $0402                               ; $A94E: AD 02 04
  JSR $F2AF                               ; $A951: 20 AF F2
  LDY #$10                                ; $A954: A0 10
  LDA ($00),Y                             ; $A956: B1 00
  CLC                                     ; $A958: 18
  ADC $042C                               ; $A959: 6D 2C 04
  CMP #$63                                ; $A95C: C9 63
  BCC $A962                               ; $A95E: 90 02
Loc_A960:  ; (dispatch callback target)
  LDA #$63                                ; $A960: A9 63
Loc_A962:
  STA ($00),Y                             ; $A962: 91 00
  LDA #$16                                ; $A964: A9 16
  STA $0401                               ; $A966: 8D 01 04
  LDA #$34                                ; $A969: A9 34
  JMP $F26D                               ; $A96B: 4C 6D F2
Loc_A96E:
  LDA #$00                                ; $A96E: A9 00
  STA $042D                               ; $A970: 8D 2D 04
  STA $042E                               ; $A973: 8D 2E 04
Loc_A976:
  JSR $E843                               ; $A976: 20 43 E8
  CMP #$29                                ; $A979: C9 29
  BCS $A976                               ; $A97B: B0 F9
  STA $042C                               ; $A97D: 8D 2C 04
  LDA $0470                               ; $A980: AD 70 04
  CMP #$02                                ; $A983: C9 02
  BEQ $A9CB                               ; $A985: F0 44
  CMP #$03                                ; $A987: C9 03
  BEQ $A995                               ; $A989: F0 0A
  LDA #$B8                                ; $A98B: A9 B8
  STA a:$0010                             ; $A98D: 8D 10 00
  LDA #$1E                                ; $A990: A9 1E
  JMP $A99C                               ; $A992: 4C 9C A9
Loc_A995:
  LDA #$BA                                ; $A995: A9 BA
  STA a:$0010                             ; $A997: 8D 10 00
  LDA #$50                                ; $A99A: A9 50
Loc_A99C:
  CLC                                     ; $A99C: 18
  ADC $042C                               ; $A99D: 6D 2C 04
  STA $042C                               ; $A9A0: 8D 2C 04
  LDA $0402                               ; $A9A3: AD 02 04
  JSR $F2AF                               ; $A9A6: 20 AF F2
  LDY #$02                                ; $A9A9: A0 02
  LDA ($00),Y                             ; $A9AB: B1 00
  CLC                                     ; $A9AD: 18
  ADC $042C                               ; $A9AE: 6D 2C 04
  STA ($00),Y                             ; $A9B1: 91 00
  INY                                     ; $A9B3: C8
  LDA ($00),Y                             ; $A9B4: B1 00
  ADC $042D                               ; $A9B6: 6D 2D 04
  STA ($00),Y                             ; $A9B9: 91 00
  LDY #$02                                ; $A9BB: A0 02
  JSR $DDDC                               ; $A9BD: 20 DC DD
  LDA #$16                                ; $A9C0: A9 16
  STA $0401                               ; $A9C2: 8D 01 04
  LDA a:$0010                             ; $A9C5: AD 10 00
  JMP $F26D                               ; $A9C8: 4C 6D F2
Loc_A9CB:
  LDA #$32                                ; $A9CB: A9 32
  CLC                                     ; $A9CD: 18
  ADC $042C                               ; $A9CE: 6D 2C 04
  STA $042C                               ; $A9D1: 8D 2C 04
  LDA $0402                               ; $A9D4: AD 02 04
  JSR $F2AF                               ; $A9D7: 20 AF F2
  LDY #$04                                ; $A9DA: A0 04
  LDA ($00),Y                             ; $A9DC: B1 00
  CLC                                     ; $A9DE: 18
  ADC $042C                               ; $A9DF: 6D 2C 04
  STA ($00),Y                             ; $A9E2: 91 00
  INY                                     ; $A9E4: C8
  LDA ($00),Y                             ; $A9E5: B1 00
  ADC $042D                               ; $A9E7: 6D 2D 04
  STA ($00),Y                             ; $A9EA: 91 00
  LDY #$04                                ; $A9EC: A0 04
  JSR $DDDC                               ; $A9EE: 20 DC DD
  LDA #$16                                ; $A9F1: A9 16
  STA $0401                               ; $A9F3: 8D 01 04
  LDA #$B9                                ; $A9F6: A9 B9
  JMP $F26D                               ; $A9F8: 4C 6D F2
Loc_A9FB:  ; (dispatch callback target)
  JSR $DDAD                               ; $A9FB: 20 AD DD
  BCC $AA2F                               ; $A9FE: 90 2F
  JSR $D543                               ; $AA00: 20 43 D5
  LDA a:$0081                             ; $AA03: AD 81 00
  AND #$03                                ; $AA06: 29 03
  BEQ $AA2F                               ; $AA08: F0 25
  JSR $DD70                               ; $AA0A: 20 70 DD
  LDA #$00                                ; $AA0D: A9 00
  STA a:$00A4                             ; $AA0F: 8D A4 00
  LDA $0470                               ; $AA12: AD 70 04
  CMP #$06                                ; $AA15: C9 06
  BEQ $AA35                               ; $AA17: F0 1C
  CMP #$07                                ; $AA19: C9 07
  BEQ $AA25                               ; $AA1B: F0 08
  INC $0401                               ; $AA1D: EE 01 04
  LDA #$37                                ; $AA20: A9 37
  JMP $F26D                               ; $AA22: 4C 6D F2
Loc_AA25:
  LDA #$10                                ; $AA25: A9 10
  STA $0401                               ; $AA27: 8D 01 04
  LDA #$36                                ; $AA2A: A9 36
  JMP $F26D                               ; $AA2C: 4C 6D F2
Loc_AA2F:
  LDA $0482                               ; $AA2F: AD 82 04
  JMP $DD5E                               ; $AA32: 4C 5E DD
Loc_AA35:
  LDA #$10                                ; $AA35: A9 10
  STA $0401                               ; $AA37: 8D 01 04
  LDA $0472                               ; $AA3A: AD 72 04
  JSR $F2D7                               ; $AA3D: 20 D7 F2
  LDA a:$0000                             ; $AA40: AD 00 00
  STA a:$0010                             ; $AA43: 8D 10 00
  LDA a:$0001                             ; $AA46: AD 01 00
  STA a:$0011                             ; $AA49: 8D 11 00
  LDY #$00                                ; $AA4C: A0 00
  STY a:$0001                             ; $AA4E: 8C 01 00
  STY a:$0002                             ; $AA51: 8C 02 00
Loc_AA54:
  LDA ($10),Y                             ; $AA54: B1 10
  CLC                                     ; $AA56: 18
  ADC a:$0001                             ; $AA57: 6D 01 00
  STA a:$0001                             ; $AA5A: 8D 01 00
  LDA #$00                                ; $AA5D: A9 00
  ADC a:$0002                             ; $AA5F: 6D 02 00
  STA a:$0002                             ; $AA62: 8D 02 00
  INY                                     ; $AA65: C8
  CPY #$03                                ; $AA66: C0 03
  BCC $AA54                               ; $AA68: 90 EA
  STY a:$0003                             ; $AA6A: 8C 03 00
  LDA #$00                                ; $AA6D: A9 00
  STA a:$0004                             ; $AA6F: 8D 04 00
  STA $042E                               ; $AA72: 8D 2E 04
  JSR $EA7C                               ; $AA75: 20 7C EA
  LDA a:$0001                             ; $AA78: AD 01 00
  STA $042C                               ; $AA7B: 8D 2C 04
  LDA a:$0002                             ; $AA7E: AD 02 00
  STA $042D                               ; $AA81: 8D 2D 04
  LDA #$38                                ; $AA84: A9 38
  JMP $F26D                               ; $AA86: 4C 6D F2
Loc_AA89:  ; (dispatch callback target)
  LDA #$DF                                ; $AA89: A9 DF
  STA a:$0010                             ; $AA8B: 8D 10 00
  LDA #$AA                                ; $AA8E: A9 AA
  STA a:$0011                             ; $AA90: 8D 11 00
  LDA #$00                                ; $AA93: A9 00
  STA a:$0012                             ; $AA95: 8D 12 00
  JSR $ED1E                               ; $AA98: 20 1E ED
  LDA #$E3                                ; $AA9B: A9 E3
  STA a:$0010                             ; $AA9D: 8D 10 00
  LDA #$AA                                ; $AAA0: A9 AA
  STA a:$0011                             ; $AAA2: 8D 11 00
  LDA #$E7                                ; $AAA5: A9 E7
  STA a:$0000                             ; $AAA7: 8D 00 00
  LDA #$AA                                ; $AAAA: A9 AA
  STA a:$0001                             ; $AAAC: 8D 01 00
  LDA a:$0012                             ; $AAAF: AD 12 00
  JSR $EDF5                               ; $AAB2: 20 F5 ED
  JSR $DDAD                               ; $AAB5: 20 AD DD
  BCC $AAD9                               ; $AAB8: 90 1F
  LDA a:$0081                             ; $AABA: AD 81 00
  LSR                                     ; $AABD: 4A
  BCC $AAC8                               ; $AABE: 90 08
  LDA a:$0012                             ; $AAC0: AD 12 00
  BNE $AACB                               ; $AAC3: D0 06
  JMP $ACE0                               ; $AAC5: 4C E0 AC
Loc_AAC8:
  LSR                                     ; $AAC8: 4A
  BCC $AAD9                               ; $AAC9: 90 0E
Loc_AACB:
  LDA #$00                                ; $AACB: A9 00
  STA $0400                               ; $AACD: 8D 00 04
  STA $0401                               ; $AAD0: 8D 01 04
  JSR $D568                               ; $AAD3: 20 68 D5
  JMP $F28B                               ; $AAD6: 4C 8B F2
Loc_AAD9:
  LDA $0482                               ; $AAD9: AD 82 04
  JMP $DD5E                               ; $AADC: 4C 5E DD
; --- Data Region ---
  .byte $00,$01,$FF,$FF,$C8,$58,$C8,$98,$00,$07,$00,$00,$80; $AADF: 00 01 FF FF C8 58 C8 98 00 07 00 00 80
Loc_AAEC:  ; (dispatch callback target)
; --- Code Region ---
  LDA #$C1                                ; $AAEC: A9 C1
  STA a:$0010                             ; $AAEE: 8D 10 00
Loc_AAF1:
  LDA #$AB                                ; $AAF1: A9 AB
  STA a:$0011                             ; $AAF3: 8D 11 00
  LDA #$00                                ; $AAF6: A9 00
  STA a:$0012                             ; $AAF8: 8D 12 00
  JSR $ED1E                               ; $AAFB: 20 1E ED
  LDA #$C5                                ; $AAFE: A9 C5
  STA a:$0010                             ; $AB00: 8D 10 00
  LDA #$AB                                ; $AB03: A9 AB
  STA a:$0011                             ; $AB05: 8D 11 00
  LDA #$C9                                ; $AB08: A9 C9
  STA a:$0000                             ; $AB0A: 8D 00 00
  LDA #$AB                                ; $AB0D: A9 AB
  STA a:$0001                             ; $AB0F: 8D 01 00
  LDA a:$0012                             ; $AB12: AD 12 00
  JSR $EDF5                               ; $AB15: 20 F5 ED
  JSR $DDAD                               ; $AB18: 20 AD DD
  BCC $AB34                               ; $AB1B: 90 17
  LDA a:$0081                             ; $AB1D: AD 81 00
  LSR                                     ; $AB20: 4A
  BCS $AB3A                               ; $AB21: B0 17
  LSR                                     ; $AB23: 4A
  BCC $AB34                               ; $AB24: 90 0E
Loc_AB26:
  JSR $D568                               ; $AB26: 20 68 D5
  LDA #$00                                ; $AB29: A9 00
  STA $0400                               ; $AB2B: 8D 00 04
  STA $0401                               ; $AB2E: 8D 01 04
  JMP $F28B                               ; $AB31: 4C 8B F2
Loc_AB34:
  LDA $0482                               ; $AB34: AD 82 04
  JMP $DD5E                               ; $AB37: 4C 5E DD
Loc_AB3A:
  LDA a:$0012                             ; $AB3A: AD 12 00
  BNE $AB26                               ; $AB3D: D0 E7
  LDA $0470                               ; $AB3F: AD 70 04
  CMP #$06                                ; $AB42: C9 06
  BNE $AB69                               ; $AB44: D0 23
  LDA $0402                               ; $AB46: AD 02 04
  JSR $F2AF                               ; $AB49: 20 AF F2
  LDY #$02                                ; $AB4C: A0 02
  LDA ($00),Y                             ; $AB4E: B1 00
  STA a:$0002                             ; $AB50: 8D 02 00
  SEC                                     ; $AB53: 38
  SBC $042C                               ; $AB54: ED 2C 04
  STA ($00),Y                             ; $AB57: 91 00
  INY                                     ; $AB59: C8
  LDA ($00),Y                             ; $AB5A: B1 00
  STA a:$0003                             ; $AB5C: 8D 03 00
  SBC $042D                               ; $AB5F: ED 2D 04
  STA ($00),Y                             ; $AB62: 91 00
  BCC $ABA4                               ; $AB64: 90 3E
  JMP $ACE0                               ; $AB66: 4C E0 AC
Loc_AB69:
  LDA $0402                               ; $AB69: AD 02 04
  JSR $F2AF                               ; $AB6C: 20 AF F2
  LDX #$02                                ; $AB6F: A2 02
  LDY #$00                                ; $AB71: A0 00
  LDA ($00),Y                             ; $AB73: B1 00
  CMP $0473                               ; $AB75: CD 73 04
  BEQ $AB7C                               ; $AB78: F0 02
  LDX #$0D                                ; $AB7A: A2 0D
Loc_AB7C:
  STX a:$0000                             ; $AB7C: 8E 00 00
  JSR $E85C                               ; $AB7F: 20 5C E8
  CMP a:$0000                             ; $AB82: CD 00 00
  BCC $AB8A                               ; $AB85: 90 03
  JMP $ACE0                               ; $AB87: 4C E0 AC
Loc_AB8A:
  LDA $0472                               ; $AB8A: AD 72 04
  STA $0481                               ; $AB8D: 8D 81 04
  STA a:$0000                             ; $AB90: 8D 00 00
  LDY #$3D                                ; $AB93: A0 3D
  JSR $EE07                               ; $AB95: 20 07 EE
; --- Data Region ---
  .byte $2A,$A0,$A9,$16,$8D,$01,$04,$A9,$3A,$4C,$6D,$F2; $AB98: 2A A0 A9 16 8D 01 04 A9 3A 4C 6D F2
Loc_ABA4:
; --- Code Region ---
  LDY #$02                                ; $ABA4: A0 02
  LDA a:$0002                             ; $ABA6: AD 02 00
  STA ($00),Y                             ; $ABA9: 91 00
  INY                                     ; $ABAB: C8
  LDA a:$0003                             ; $ABAC: AD 03 00
  STA ($00),Y                             ; $ABAF: 91 00
  LDA $0482                               ; $ABB1: AD 82 04
  STA $0481                               ; $ABB4: 8D 81 04
  LDA #$16                                ; $ABB7: A9 16
  STA $0401                               ; $ABB9: 8D 01 04
  LDA #$2A                                ; $ABBC: A9 2A
  JMP $F26D                               ; $ABBE: 4C 6D F2
; --- Data Region ---
  .byte $00,$01,$FF,$FF,$D8,$58,$D8,$98,$00,$07,$00,$00,$80; $ABC1: 00 01 FF FF D8 58 D8 98 00 07 00 00 80
Loc_ABCE:  ; (dispatch callback target)
; --- Code Region ---
  LDA $0402                               ; $ABCE: AD 02 04
  JSR $F2AF                               ; $ABD1: 20 AF F2
  LDY #$0A                                ; $ABD4: A0 0A
  LDA ($00),Y                             ; $ABD6: B1 00
  SEC                                     ; $ABD8: 38
  SBC #$63                                ; $ABD9: E9 63
  BCC $ABE7                               ; $ABDB: 90 0A
  LDA #$16                                ; $ABDD: A9 16
  STA $0401                               ; $ABDF: 8D 01 04
  LDA #$A7                                ; $ABE2: A9 A7
  JMP $F26D                               ; $ABE4: 4C 6D F2
Loc_ABE7:
  LDA #$03                                ; $ABE7: A9 03
  STA $0470                               ; $ABE9: 8D 70 04
  LDA #$04                                ; $ABEC: A9 04
  STA $0401                               ; $ABEE: 8D 01 04
  LDA #$80                                ; $ABF1: A9 80
  STA $0478                               ; $ABF3: 8D 78 04
  LDA #$0F                                ; $ABF6: A9 0F
  STA $047C                               ; $ABF8: 8D 7C 04
  LDA #$27                                ; $ABFB: A9 27
  JMP $F26D                               ; $ABFD: 4C 6D F2
Loc_AC00:  ; (dispatch callback target)
  JSR $DDAD                               ; $AC00: 20 AD DD
  BCC $AC29                               ; $AC03: 90 24
  JSR $D543                               ; $AC05: 20 43 D5
  JSR $DDAD                               ; $AC08: 20 AD DD
  BCC $AC29                               ; $AC0B: 90 1C
  LDA a:$0081                             ; $AC0D: AD 81 00
  LSR                                     ; $AC10: 4A
  BCC $AC21                               ; $AC11: 90 0E
  INC $0401                               ; $AC13: EE 01 04
  JSR $DD70                               ; $AC16: 20 70 DD
  STA $046C                               ; $AC19: 8D 6C 04
  LDA #$29                                ; $AC1C: A9 29
  JMP $F26D                               ; $AC1E: 4C 6D F2
Loc_AC21:
  LSR                                     ; $AC21: 4A
  BCC $AC29                               ; $AC22: 90 05
  LDA #$00                                ; $AC24: A9 00
  STA $0401                               ; $AC26: 8D 01 04
Loc_AC29:
  RTS                                     ; $AC29: 60
Loc_AC2A:  ; (dispatch callback target)
  JSR $D5BD                               ; $AC2A: 20 BD D5
  LDA a:$0013                             ; $AC2D: AD 13 00
  BEQ $AC7B                               ; $AC30: F0 49
  CMP #$FF                                ; $AC32: C9 FF
  BEQ $AC76                               ; $AC34: F0 40
  LDY #$39                                ; $AC36: A0 39
  JSR $EE07                               ; $AC38: 20 07 EE
; --- Data Region ---
  .byte $2D,$A0,$AD,$00,$6F,$18,$69,$64,$8D,$2C,$04,$A9,$00,$69,$00,$8D; $AC3B: 2D A0 AD 00 6F 18 69 64 8D 2C 04 A9 00 69 00 8D
  .byte $2D,$04,$AD,$01,$6F,$18,$69,$01,$8D,$2F,$04,$A9,$00,$8D,$2E,$04; $AC4B: 2D 04 AD 01 6F 18 69 01 8D 2F 04 A9 00 8D 2E 04
  .byte $8D,$30,$04,$8D,$31,$04,$A9,$03,$8D,$A2,$04,$A9,$42,$8D,$D6,$04; $AC5B: 8D 30 04 8D 31 04 A9 03 8D A2 04 A9 42 8D D6 04
  .byte $20,$68,$D5,$EE,$01,$04,$A9,$52,$4C,$6D,$F2; $AC6B: 20 68 D5 EE 01 04 A9 52 4C 6D F2
Loc_AC76:
; --- Code Region ---
  LDA #$00                                ; $AC76: A9 00
  STA $0401                               ; $AC78: 8D 01 04
Loc_AC7B:
  RTS                                     ; $AC7B: 60
Loc_AC7C:  ; (dispatch callback target)
  LDA $0140                               ; $AC7C: AD 40 01
  BNE $AC8F                               ; $AC7F: D0 0E
  LDA $04A2                               ; $AC81: AD A2 04
  STA $04A0                               ; $AC84: 8D A0 04
  INC $0401                               ; $AC87: EE 01 04
  LDA #$30                                ; $AC8A: A9 30
  STA $046C                               ; $AC8C: 8D 6C 04
Loc_AC8F:
  RTS                                     ; $AC8F: 60
Loc_AC90:  ; (dispatch callback target)
  LDA $04A0                               ; $AC90: AD A0 04
  BNE $ACAD                               ; $AC93: D0 18
  LDA $0140                               ; $AC95: AD 40 01
  BNE $ACB7                               ; $AC98: D0 1D
  LDA #$02                                ; $AC9A: A9 02
  JSR $D58C                               ; $AC9C: 20 8C D5
  LDA $0473                               ; $AC9F: AD 73 04
  BPL $ACAA                               ; $ACA2: 10 06
  LDA #$0D                                ; $ACA4: A9 0D
  STA $0401                               ; $ACA6: 8D 01 04
  RTS                                     ; $ACA9: 60
Loc_ACAA:
  INC $0401                               ; $ACAA: EE 01 04
Loc_ACAD:
  LDA $0481                               ; $ACAD: AD 81 04
  CMP #$FF                                ; $ACB0: C9 FF
  BEQ $ACB7                               ; $ACB2: F0 03
  JSR $DD5E                               ; $ACB4: 20 5E DD
Loc_ACB7:
  RTS                                     ; $ACB7: 60
Loc_ACB8:  ; (dispatch callback target)
  JSR $DDAD                               ; $ACB8: 20 AD DD
  BCC $ACD5                               ; $ACBB: 90 18
  JSR $D543                               ; $ACBD: 20 43 D5
  LDA a:$0081                             ; $ACC0: AD 81 00
  AND #$03                                ; $ACC3: 29 03
  BEQ $ACD5                               ; $ACC5: F0 0E
  JSR $D568                               ; $ACC7: 20 68 D5
  LDA #$00                                ; $ACCA: A9 00
  STA $0400                               ; $ACCC: 8D 00 04
  STA $0401                               ; $ACCF: 8D 01 04
  JMP $F28B                               ; $ACD2: 4C 8B F2
Loc_ACD5:
  LDA $0481                               ; $ACD5: AD 81 04
  CMP #$FF                                ; $ACD8: C9 FF
  BEQ $ACDF                               ; $ACDA: F0 03
  JSR $DD5E                               ; $ACDC: 20 5E DD
Loc_ACDF:
  RTS                                     ; $ACDF: 60
Loc_ACE0:
  LDA $0472                               ; $ACE0: AD 72 04
  STA $0481                               ; $ACE3: 8D 81 04
  STA a:$0000                             ; $ACE6: 8D 00 00
  LDY #$3D                                ; $ACE9: A0 3D
  JSR $EE07                               ; $ACEB: 20 07 EE
; --- Data Region ---
  .byte $2A,$A0,$AD,$02,$04,$20,$AF,$F2,$20,$6B,$DC,$8A,$18,$69,$11,$A8; $ACEE: 2A A0 AD 02 04 20 AF F2 20 6B DC 8A 18 69 11 A8
  .byte $AD,$72,$04,$91,$00,$A0,$00,$B1,$00,$20,$68,$F3,$A0,$00,$B1,$00; $ACFE: AD 72 04 91 00 A0 00 B1 00 20 68 F3 A0 00 B1 00
  .byte $8D,$30,$00,$AD,$72,$04,$8D,$31,$00,$20,$D7,$F2,$A0,$0B,$B1,$00; $AD0E: 8D 30 00 AD 72 04 8D 31 00 20 D7 F2 A0 0B B1 00
  .byte $8D,$02                           ; $AD1E: 8D 02
Loc_AD20:  ; (dispatch callback target)
; --- Code Region ---
  BRK                                     ; $AD20: 00
  AND #$FC                                ; $AD21: 29 FC
  ORA #$02                                ; $AD23: 09 02
  STA ($00),Y                             ; $AD25: 91 00
  LDA a:$0002                             ; $AD27: AD 02 00
  AND #$03                                ; $AD2A: 29 03
  CMP #$01                                ; $AD2C: C9 01
  BEQ $AD37                               ; $AD2E: F0 07
  LDY #$2A                                ; $AD30: A0 2A
  JSR $EE07                               ; $AD32: 20 07 EE
; --- Data Region ---
  .byte $06,$A0                           ; $AD35: 06 A0
Loc_AD37:
; --- Code Region ---
  LDA #$16                                ; $AD37: A9 16
  STA $0401                               ; $AD39: 8D 01 04
  LDA #$39                                ; $AD3C: A9 39
  JMP $F26D                               ; $AD3E: 4C 6D F2
Loc_AD41:
  LDA $0471                               ; $AD41: AD 71 04
  JSR $F2AF                               ; $AD44: 20 AF F2
  LDX #$00                                ; $AD47: A2 00
  LDY #$11                                ; $AD49: A0 11
Loc_AD4B:
  LDA ($00),Y                             ; $AD4B: B1 00
  CMP #$FF                                ; $AD4D: C9 FF
  BEQ $AD55                               ; $AD4F: F0 04
  INY                                     ; $AD51: C8
  JMP $AD4B                               ; $AD52: 4C 4B AD
Loc_AD55:
  LDA $0481,X                             ; $AD55: BD 81 04
  CMP #$FF                                ; $AD58: C9 FF
  BEQ $AD64                               ; $AD5A: F0 08
  STA ($00),Y                             ; $AD5C: 91 00
  INX                                     ; $AD5E: E8
  INY                                     ; $AD5F: C8
Loc_AD60:  ; (dispatch callback target)
  CPX #$0A                                ; $AD60: E0 0A
  BCC $AD55                               ; $AD62: 90 F1
Loc_AD64:
  LDY #$00                                ; $AD64: A0 00
  LDA ($EE),Y                             ; $AD66: B1 EE
  STA a:$0002                             ; $AD68: 8D 02 00
  LDY #$11                                ; $AD6B: A0 11
Loc_AD6D:
  LDA ($00),Y                             ; $AD6D: B1 00
  CMP a:$0002                             ; $AD6F: CD 02 00
  BEQ $AD7C                               ; $AD72: F0 08
  INY                                     ; $AD74: C8
  CPY #$1B                                ; $AD75: C0 1B
  BCC $AD6D                               ; $AD77: 90 F4
  JMP $AD98                               ; $AD79: 4C 98 AD
Loc_AD7C:
  TYA                                     ; $AD7C: 98
  PHA                                     ; $AD7D: 48
  LDY #$11                                ; $AD7E: A0 11
  LDA ($00),Y                             ; $AD80: B1 00
  STA a:$0003                             ; $AD82: 8D 03 00
  LDA a:$0002                             ; $AD85: AD 02 00
  STA ($00),Y                             ; $AD88: 91 00
  PLA                                     ; $AD8A: 68
  TAY                                     ; $AD8B: A8
  LDA a:$0003                             ; $AD8C: AD 03 00
  STA ($00),Y                             ; $AD8F: 91 00
  LDY #$01                                ; $AD91: A0 01
  LDA $0471                               ; $AD93: AD 71 04
  STA ($EE),Y                             ; $AD96: 91 EE
Loc_AD98:
  LDA $0470                               ; $AD98: AD 70 04
  JSR $F2AF                               ; $AD9B: 20 AF F2
  LDX #$00                                ; $AD9E: A2 00
Loc_ADA0:
  LDA $0481,X                             ; $ADA0: BD 81 04
  CMP #$FF                                ; $ADA3: C9 FF
  BEQ $ADC3                               ; $ADA5: F0 1C
  STA a:$0010                             ; $ADA7: 8D 10 00
  LDY #$11                                ; $ADAA: A0 11
Loc_ADAC:
  LDA ($00),Y                             ; $ADAC: B1 00
  CMP a:$0010                             ; $ADAE: CD 10 00
  BNE $ADBA                               ; $ADB1: D0 07
  LDA #$FF                                ; $ADB3: A9 FF
  STA ($00),Y                             ; $ADB5: 91 00
  JMP $ADBE                               ; $ADB7: 4C BE AD
Loc_ADBA:
  INY                                     ; $ADBA: C8
  JMP $ADAC                               ; $ADBB: 4C AC AD
Loc_ADBE:
  INX                                     ; $ADBE: E8
  CPX #$0A                                ; $ADBF: E0 0A
  BCC $ADA0                               ; $ADC1: 90 DD
Loc_ADC3:
  LDX #$00                                ; $ADC3: A2 00
  LDA #$FF                                ; $ADC5: A9 FF
Loc_ADC7:
  STA $0481,X                             ; $ADC7: 9D 81 04
  INX                                     ; $ADCA: E8
  CPX #$0A                                ; $ADCB: E0 0A
  BCC $ADC7                               ; $ADCD: 90 F8
  LDY #$11                                ; $ADCF: A0 11
  LDX #$00                                ; $ADD1: A2 00
Loc_ADD3:
  LDA ($00),Y                             ; $ADD3: B1 00
  CMP #$FF                                ; $ADD5: C9 FF
  BEQ $ADDD                               ; $ADD7: F0 04
  STA $0481,X                             ; $ADD9: 9D 81 04
  INX                                     ; $ADDC: E8
Loc_ADDD:
  INY                                     ; $ADDD: C8
  CPY #$1B                                ; $ADDE: C0 1B
  BCC $ADD3                               ; $ADE0: 90 F1
  LDY #$11                                ; $ADE2: A0 11
  LDX #$00                                ; $ADE4: A2 00
Loc_ADE6:
  LDA $0481,X                             ; $ADE6: BD 81 04
  STA ($00),Y                             ; $ADE9: 91 00
  INX                                     ; $ADEB: E8
  INY                                     ; $ADEC: C8
  CPX #$0A                                ; $ADED: E0 0A
  BCC $ADE6                               ; $ADEF: 90 F5
  RTS                                     ; $ADF1: 60
Loc_ADF2:  ; (dispatch callback target)
  LDA $0401                               ; $ADF2: AD 01 04
  JSR $EADE                               ; $ADF5: 20 DE EA
; --- Data Region ---
  .byte $2A,$AE,$55,$AE,$12,$AF,$AE,$AF,$47,$B0,$CF,$B0,$90,$B1,$1B,$B2; $ADF8: 2A AE 55 AE 12 AF AE AF 47 B0 CF B0 90 B1 1B B2
  .byte $43,$B2,$78,$B2,$3C,$B3,$6D,$B3,$0E,$B4,$31,$B4,$5D,$B4,$7A,$B4; $AE08: 43 B2 78 B2 3C B3 6D B3 0E B4 31 B4 5D B4 7A B4
  .byte $07,$B5,$28,$B5,$92,$B5,$A6,$B5,$F1,$B6,$DC,$B5,$3E,$B7,$20,$B6; $AE18: 07 B5 28 B5 92 B5 A6 B5 F1 B6 DC B5 3E B7 20 B6
  .byte $70,$B6                           ; $AE28: 70 B6
Loc_AE2A:  ; (dispatch callback target)
; --- Code Region ---
  LDA $0140                               ; $AE2A: AD 40 01
  BNE $AE54                               ; $AE2D: D0 25
  LDA $0304                               ; $AE2F: AD 04 03
  CMP #$FF                                ; $AE32: C9 FF
  BNE $AE54                               ; $AE34: D0 1E
  INC $0401                               ; $AE36: EE 01 04
  JSR $DD70                               ; $AE39: 20 70 DD
  STA $0473                               ; $AE3C: 8D 73 04
  STA a:$00A4                             ; $AE3F: 8D A4 00
  LDA #$80                                ; $AE42: A9 80
  STA $0140                               ; $AE44: 8D 40 01
  LDA #$03                                ; $AE47: A9 03
  ORA $0150                               ; $AE49: 0D 50 01
  STA $0150                               ; $AE4C: 8D 50 01
  LDA #$60                                ; $AE4F: A9 60
  JMP $F26D                               ; $AE51: 4C 6D F2
Loc_AE54:
  RTS                                     ; $AE54: 60
Loc_AE55:  ; (dispatch callback target)
  LDA #$FF                                ; $AE55: A9 FF
  STA a:$0010                             ; $AE57: 8D 10 00
  LDA #$AE                                ; $AE5A: A9 AE
  STA a:$0011                             ; $AE5C: 8D 11 00
  LDA #$00                                ; $AE5F: A9 00
  STA a:$0012                             ; $AE61: 8D 12 00
  JSR $ED1E                               ; $AE64: 20 1E ED
  LDA #$05                                ; $AE67: A9 05
  STA a:$0010                             ; $AE69: 8D 10 00
  LDA #$AF                                ; $AE6C: A9 AF
  STA a:$0011                             ; $AE6E: 8D 11 00
  LDA #$0D                                ; $AE71: A9 0D
  STA a:$0000                             ; $AE73: 8D 00 00
  LDA #$AF                                ; $AE76: A9 AF
  STA a:$0001                             ; $AE78: 8D 01 00
  LDA a:$0012                             ; $AE7B: AD 12 00
  JSR $EDF5                               ; $AE7E: 20 F5 ED
  JSR $DDAD                               ; $AE81: 20 AD DD
  BCC $AEFE                               ; $AE84: 90 78
  LDA a:$0081                             ; $AE86: AD 81 00
  LSR                                     ; $AE89: 4A
  BCC $AEEE                               ; $AE8A: 90 62
  LDA a:$0012                             ; $AE8C: AD 12 00
  BNE $AEA2                               ; $AE8F: D0 11
  JSR $D568                               ; $AE91: 20 68 D5
  LDA $0402                               ; $AE94: AD 02 04
  STA $0470                               ; $AE97: 8D 70 04
  INC $0401                               ; $AE9A: EE 01 04
  LDA #$61                                ; $AE9D: A9 61
  JMP $F26D                               ; $AE9F: 4C 6D F2
Loc_AEA2:
  CMP #$01                                ; $AEA2: C9 01
  BNE $AEB0                               ; $AEA4: D0 0A
  LDA #$09                                ; $AEA6: A9 09
  STA $0401                               ; $AEA8: 8D 01 04
  LDA #$68                                ; $AEAB: A9 68
  JMP $F26D                               ; $AEAD: 4C 6D F2
Loc_AEB0:
  CMP #$02                                ; $AEB0: C9 02
  BNE $AEC4                               ; $AEB2: D0 10
  LDA #$0E                                ; $AEB4: A9 0E
  STA $0401                               ; $AEB6: 8D 01 04
  JSR $DD70                               ; $AEB9: 20 70 DD
  STA $046C                               ; $AEBC: 8D 6C 04
  LDA #$29                                ; $AEBF: A9 29
  JMP $F26D                               ; $AEC1: 4C 6D F2
Loc_AEC4:
  LDY #$01                                ; $AEC4: A0 01
  LDA ($EE),Y                             ; $AEC6: B1 EE
  CMP $0402                               ; $AEC8: CD 02 04
  BNE $AED7                               ; $AECB: D0 0A
  LDA #$16                                ; $AECD: A9 16
  STA $0401                               ; $AECF: 8D 01 04
  LDA #$49                                ; $AED2: A9 49
  JMP $F26D                               ; $AED4: 4C 6D F2
Loc_AED7:
  LDA #$14                                ; $AED7: A9 14
  STA $0401                               ; $AED9: 8D 01 04
  JSR $DD70                               ; $AEDC: 20 70 DD
  LDA #$80                                ; $AEDF: A9 80
  STA $0478                               ; $AEE1: 8D 78 04
  LDA #$0F                                ; $AEE4: A9 0F
  STA $047C                               ; $AEE6: 8D 7C 04
  LDA #$6C                                ; $AEE9: A9 6C
  JMP $F26D                               ; $AEEB: 4C 6D F2
Loc_AEEE:
  LSR                                     ; $AEEE: 4A
  BCC $AEFE                               ; $AEEF: 90 0D
  JSR $D568                               ; $AEF1: 20 68 D5
  LDA #$01                                ; $AEF4: A9 01
  STA $0400                               ; $AEF6: 8D 00 04
  LDA #$00                                ; $AEF9: A9 00
  STA $0401                               ; $AEFB: 8D 01 04
Loc_AEFE:
  RTS                                     ; $AEFE: 60
; --- Data Region ---
  .byte $00,$01,$02,$03,$FF,$FF,$B8,$48,$B8,$98,$C8,$48,$C8,$98,$00,$07; $AEFF: 00 01 02 03 FF FF B8 48 B8 98 C8 48 C8 98 00 07
  .byte $00,$00,$80                       ; $AF0F: 00 00 80
Loc_AF12:  ; (dispatch callback target)
; --- Code Region ---
  JSR $DDF2                               ; $AF12: 20 F2 DD
  JSR $DDAD                               ; $AF15: 20 AD DD
  BCC $AF37                               ; $AF18: 90 1D
  LDA a:$0081                             ; $AF1A: AD 81 00
  LSR                                     ; $AF1D: 4A
  BCS $AF38                               ; $AF1E: B0 18
  LSR                                     ; $AF20: 4A
  BCC $AF37                               ; $AF21: 90 14
  LDA #$FF                                ; $AF23: A9 FF
  STA $04E4                               ; $AF25: 8D E4 04
  JSR $DDAD                               ; $AF28: 20 AD DD
  BCC $AF37                               ; $AF2B: 90 0A
  LDA #$00                                ; $AF2D: A9 00
  STA $0401                               ; $AF2F: 8D 01 04
  LDA #$03                                ; $AF32: A9 03
  JSR $D58C                               ; $AF34: 20 8C D5
Loc_AF37:
  RTS                                     ; $AF37: 60
Loc_AF38:
  JSR $DEBA                               ; $AF38: 20 BA DE
  CPY #$FF                                ; $AF3B: C0 FF
  BEQ $AFA4                               ; $AF3D: F0 65
  STY $0402                               ; $AF3F: 8C 02 04
  JSR $DD79                               ; $AF42: 20 79 DD
  LDA $0402                               ; $AF45: AD 02 04
  BMI $AFA9                               ; $AF48: 30 5F
  STA $0471                               ; $AF4A: 8D 71 04
  STA $050E                               ; $AF4D: 8D 0E 05
  LDA a:$0010                             ; $AF50: AD 10 00
  CMP $6F03                               ; $AF53: CD 03 6F
  BEQ $AFA9                               ; $AF56: F0 51
  LDA $6F03                               ; $AF58: AD 03 6F
  JSR $F368                               ; $AF5B: 20 68 F3
  LDA a:$0010                             ; $AF5E: AD 10 00
  LSR                                     ; $AF61: 4A
  CLC                                     ; $AF62: 18
  ADC #$04                                ; $AF63: 69 04
  TAY                                     ; $AF65: A8
  LDA a:$0010                             ; $AF66: AD 10 00
  AND #$01                                ; $AF69: 29 01
  BEQ $AF78                               ; $AF6B: F0 0B
  LDA ($00),Y                             ; $AF6D: B1 00
  LSR                                     ; $AF6F: 4A
  LSR                                     ; $AF70: 4A
  LSR                                     ; $AF71: 4A
  LSR                                     ; $AF72: 4A
  BNE $AF9F                               ; $AF73: D0 2A
  JMP $AF7E                               ; $AF75: 4C 7E AF
Loc_AF78:
  LDA ($00),Y                             ; $AF78: B1 00
  AND #$0F                                ; $AF7A: 29 0F
  BNE $AF9F                               ; $AF7C: D0 21
Loc_AF7E:
  LDA $0470                               ; $AF7E: AD 70 04
  STA $0402                               ; $AF81: 8D 02 04
  JSR $F2AF                               ; $AF84: 20 AF F2
  JSR $DC6B                               ; $AF87: 20 6B DC
  STX $047C                               ; $AF8A: 8E 7C 04
  LDA #$FF                                ; $AF8D: A9 FF
  STA $04E4                               ; $AF8F: 8D E4 04
  INC $0401                               ; $AF92: EE 01 04
  LDA #$81                                ; $AF95: A9 81
  STA $0478                               ; $AF97: 8D 78 04
  LDA #$27                                ; $AF9A: A9 27
  JMP $F26D                               ; $AF9C: 4C 6D F2
Loc_AF9F:
  LDA #$41                                ; $AF9F: A9 41
  JMP $F26D                               ; $AFA1: 4C 6D F2
Loc_AFA4:
  LDA #$24                                ; $AFA4: A9 24
  JMP $F26D                               ; $AFA6: 4C 6D F2
Loc_AFA9:
  LDA #$62                                ; $AFA9: A9 62
  JMP $F26D                               ; $AFAB: 4C 6D F2
Loc_AFAE:  ; (dispatch callback target)
  LDA $0478                               ; $AFAE: AD 78 04
  BNE $AFD8                               ; $AFB1: D0 25
  JSR $D64A                               ; $AFB3: 20 4A D6
  LDA $047C                               ; $AFB6: AD 7C 04
  BPL $AFD8                               ; $AFB9: 10 1D
  CMP #$90                                ; $AFBB: C9 90
  BNE $AFD9                               ; $AFBD: D0 1A
  LDA #$02                                ; $AFBF: A9 02
  STA $0401                               ; $AFC1: 8D 01 04
  LDA $046D                               ; $AFC4: AD 6D 04
  STA $6F3F                               ; $AFC7: 8D 3F 6F
  LDA $046E                               ; $AFCA: AD 6E 04
  STA $6F41                               ; $AFCD: 8D 41 6F
  JSR $D568                               ; $AFD0: 20 68 D5
  LDA #$61                                ; $AFD3: A9 61
  JMP $F26D                               ; $AFD5: 4C 6D F2
Loc_AFD8:
  RTS                                     ; $AFD8: 60
Loc_AFD9:
  LDA #$03                                ; $AFD9: A9 03
  JSR $D58C                               ; $AFDB: 20 8C D5
  LDX #$00                                ; $AFDE: A2 00
  STX a:$0010                             ; $AFE0: 8E 10 00
  STX a:$0011                             ; $AFE3: 8E 11 00
Loc_AFE6:
  LDA $0481,X                             ; $AFE6: BD 81 04
  CMP #$FF                                ; $AFE9: C9 FF
  BEQ $B009                               ; $AFEB: F0 1C
  JSR $F2D7                               ; $AFED: 20 D7 F2
  LDY #$08                                ; $AFF0: A0 08
  LDA ($00),Y                             ; $AFF2: B1 00
  CLC                                     ; $AFF4: 18
  ADC a:$0010                             ; $AFF5: 6D 10 00
  STA a:$0010                             ; $AFF8: 8D 10 00
  INY                                     ; $AFFB: C8
  LDA ($00),Y                             ; $AFFC: B1 00
  ADC a:$0011                             ; $AFFE: 6D 11 00
  STA a:$0011                             ; $B001: 8D 11 00
  INX                                     ; $B004: E8
  CPX #$0A                                ; $B005: E0 0A
  BCC $AFE6                               ; $B007: 90 DD
Loc_B009:
  LDA a:$0010                             ; $B009: AD 10 00
  STA $042C                               ; $B00C: 8D 2C 04
  LDA a:$0011                             ; $B00F: AD 11 00
  STA $042D                               ; $B012: 8D 2D 04
  LDA #$00                                ; $B015: A9 00
  STA $042E                               ; $B017: 8D 2E 04
  INC $0401                               ; $B01A: EE 01 04
  LDA $0470                               ; $B01D: AD 70 04
  JSR $F2AF                               ; $B020: 20 AF F2
  JSR $DC6B                               ; $B023: 20 6B DC
  STX a:$0002                             ; $B026: 8E 02 00
  LDY #$00                                ; $B029: A0 00
  LDX #$00                                ; $B02B: A2 00
Loc_B02D:
  LDA $0481,Y                             ; $B02D: B9 81 04
  CMP #$FF                                ; $B030: C9 FF
  BEQ $B035                               ; $B032: F0 01
  INX                                     ; $B034: E8
Loc_B035:
  INY                                     ; $B035: C8
  CPY #$0A                                ; $B036: C0 0A
  BCC $B02D                               ; $B038: 90 F3
  CPX a:$0002                             ; $B03A: EC 02 00
  BNE $B08C                               ; $B03D: D0 4D
  JSR $DD70                               ; $B03F: 20 70 DD
  LDA #$32                                ; $B042: A9 32
  JMP $F26D                               ; $B044: 4C 6D F2
Loc_B047:  ; (dispatch callback target)
  LDA #$C2                                ; $B047: A9 C2
  STA a:$0010                             ; $B049: 8D 10 00
  LDA #$B0                                ; $B04C: A9 B0
  STA a:$0011                             ; $B04E: 8D 11 00
  LDA #$00                                ; $B051: A9 00
  STA a:$0012                             ; $B053: 8D 12 00
  JSR $ED1E                               ; $B056: 20 1E ED
  LDA #$C6                                ; $B059: A9 C6
  STA a:$0010                             ; $B05B: 8D 10 00
  LDA #$B0                                ; $B05E: A9 B0
  STA a:$0011                             ; $B060: 8D 11 00
  LDA #$CA                                ; $B063: A9 CA
  STA a:$0000                             ; $B065: 8D 00 00
  LDA #$B0                                ; $B068: A9 B0
  STA a:$0001                             ; $B06A: 8D 01 00
  LDA a:$0012                             ; $B06D: AD 12 00
  JSR $EDF5                               ; $B070: 20 F5 ED
  JSR $DDAD                               ; $B073: 20 AD DD
  BCC $B086                               ; $B076: 90 0E
  LDA a:$0081                             ; $B078: AD 81 00
  LSR                                     ; $B07B: 4A
  BCS $B087                               ; $B07C: B0 09
  LSR                                     ; $B07E: 4A
  BCC $B086                               ; $B07F: 90 05
Loc_B081:
  LDA #$00                                ; $B081: A9 00
  STA $0401                               ; $B083: 8D 01 04
Loc_B086:
  RTS                                     ; $B086: 60
Loc_B087:
  LDA a:$0012                             ; $B087: AD 12 00
  BNE $B081                               ; $B08A: D0 F5
Loc_B08C:
  INC $0401                               ; $B08C: EE 01 04
  JSR $DB87                               ; $B08F: 20 87 DB
  LDA $0402                               ; $B092: AD 02 04
  JSR $F2AF                               ; $B095: 20 AF F2
  LDY #$02                                ; $B098: A0 02
  LDA ($00),Y                             ; $B09A: B1 00
  STA $0498                               ; $B09C: 8D 98 04
  STA $0490                               ; $B09F: 8D 90 04
  INY                                     ; $B0A2: C8
  LDA ($00),Y                             ; $B0A3: B1 00
  STA $0499                               ; $B0A5: 8D 99 04
  STA $0491                               ; $B0A8: 8D 91 04
  LDY #$04                                ; $B0AB: A0 04
  LDA ($00),Y                             ; $B0AD: B1 00
  STA $049A                               ; $B0AF: 8D 9A 04
  INY                                     ; $B0B2: C8
  LDA ($00),Y                             ; $B0B3: B1 00
  STA $049B                               ; $B0B5: 8D 9B 04
  LDA #$00                                ; $B0B8: A9 00
  STA $0472                               ; $B0BA: 8D 72 04
  LDA #$63                                ; $B0BD: A9 63
  JMP $F26D                               ; $B0BF: 4C 6D F2
; --- Data Region ---
  .byte $00,$01,$FF,$FF,$C8,$60,$C8,$B0,$00; $B0C2: 00 01 FF FF C8 60 C8 B0 00
Loc_B0CB:
  .byte $07,$00,$00,$80,$20,$AD,$DD,$90,$52,$AD,$72,$04,$D0,$4E,$A9,$2E; $B0CB: 07 00 00 80 20 AD DD 90 52 AD 72 04 D0 4E A9 2E
  .byte $8D,$1C,$03,$A9,$23,$8D,$1D,$03,$20,$02,$DA,$AD,$81,$00,$4A,$90; $B0DB: 8D 1C 03 A9 23 8D 1D 03 20 02 DA AD 81 00 4A 90
  .byte $1B,$AD,$8E,$04,$8D,$2F,$04,$8D,$28,$05,$AD,$8F,$04,$8D,$30,$04; $B0EB: 1B AD 8E 04 8D 2F 04 8D 28 05 AD 8F 04 8D 30 04
  .byte $8D,$29,$05,$A9,$00,$8D,$31,$04,$EE,$72,$04,$60; $B0FB: 8D 29 05 A9 00 8D 31 04 EE 72 04 60
Loc_B107:
; --- Code Region ---
  LSR                                     ; $B107: 4A
  BCC $B126                               ; $B108: 90 1C
  DEC $0401                               ; $B10A: CE 01 04
  DEC $0401                               ; $B10D: CE 01 04
  LDA $0402                               ; $B110: AD 02 04
  JSR $F2AF                               ; $B113: 20 AF F2
  JSR $DC6B                               ; $B116: 20 6B DC
  STX $047C                               ; $B119: 8E 7C 04
  LDA #$81                                ; $B11C: A9 81
  STA $0478                               ; $B11E: 8D 78 04
  LDA #$27                                ; $B121: A9 27
  JMP $F26D                               ; $B123: 4C 6D F2
Loc_B126:
  RTS                                     ; $B126: 60
Loc_B127:
  CMP #$01                                ; $B127: C9 01
  BNE $B140                               ; $B129: D0 15
  JSR $DB87                               ; $B12B: 20 87 DB
  LDA $049A                               ; $B12E: AD 9A 04
  STA $0490                               ; $B131: 8D 90 04
  LDA $049B                               ; $B134: AD 9B 04
  STA $0491                               ; $B137: 8D 91 04
  INC $0472                               ; $B13A: EE 72 04
  LDA $0472                               ; $B13D: AD 72 04
Loc_B140:
  LDA #$38                                ; $B140: A9 38
  STA $031C                               ; $B142: 8D 1C 03
  LDA #$23                                ; $B145: A9 23
  STA $031D                               ; $B147: 8D 1D 03
  JSR $DA02                               ; $B14A: 20 02 DA
  LDA a:$0081                             ; $B14D: AD 81 00
  LSR                                     ; $B150: 4A
  BCC $B178                               ; $B151: 90 25
  LDA $048E                               ; $B153: AD 8E 04
  STA $0432                               ; $B156: 8D 32 04
  STA $0524                               ; $B159: 8D 24 05
  LDA $048F                               ; $B15C: AD 8F 04
  STA $0433                               ; $B15F: 8D 33 04
  STA $0525                               ; $B162: 8D 25 05
  JSR $DD70                               ; $B165: 20 70 DD
  STA $0434                               ; $B168: 8D 34 04
  STA $046C                               ; $B16B: 8D 6C 04
  LDA #$06                                ; $B16E: A9 06
  STA $0401                               ; $B170: 8D 01 04
  LDA #$65                                ; $B173: A9 65
  JMP $F26D                               ; $B175: 4C 6D F2
Loc_B178:
  LSR                                     ; $B178: 4A
  BCC $B126                               ; $B179: 90 AB
  JSR $DB87                               ; $B17B: 20 87 DB
  LDA $0498                               ; $B17E: AD 98 04
  STA $0490                               ; $B181: 8D 90 04
  LDA $0499                               ; $B184: AD 99 04
  STA $0491                               ; $B187: 8D 91 04
  LDA #$00                                ; $B18A: A9 00
  STA $0472                               ; $B18C: 8D 72 04
  RTS                                     ; $B18F: 60
Loc_B190:  ; (dispatch callback target)
  LDA #$0E                                ; $B190: A9 0E
  STA a:$0010                             ; $B192: 8D 10 00
  LDA #$B2                                ; $B195: A9 B2
  STA a:$0011                             ; $B197: 8D 11 00
  LDA #$00                                ; $B19A: A9 00
  STA a:$0012                             ; $B19C: 8D 12 00
  JSR $ED1E                               ; $B19F: 20 1E ED
  LDA #$12                                ; $B1A2: A9 12
  STA a:$0010                             ; $B1A4: 8D 10 00
  LDA #$B2                                ; $B1A7: A9 B2
  STA a:$0011                             ; $B1A9: 8D 11 00
  LDA #$16                                ; $B1AC: A9 16
  STA a:$0000                             ; $B1AE: 8D 00 00
  LDA #$B2                                ; $B1B1: A9 B2
  STA a:$0001                             ; $B1B3: 8D 01 00
  LDA a:$0012                             ; $B1B6: AD 12 00
  JSR $EDF5                               ; $B1B9: 20 F5 ED
  JSR $DDAD                               ; $B1BC: 20 AD DD
  BCC $B20D                               ; $B1BF: 90 4C
  LDA a:$0081                             ; $B1C1: AD 81 00
  LSR                                     ; $B1C4: 4A
  BCC $B205                               ; $B1C5: 90 3E
  LDA a:$0012                             ; $B1C7: AD 12 00
  BNE $B208                               ; $B1CA: D0 3C
  INC $0401                               ; $B1CC: EE 01 04
  LDY #$00                                ; $B1CF: A0 00
  LDX #$00                                ; $B1D1: A2 00
Loc_B1D3:
  LDA $0481,Y                             ; $B1D3: B9 81 04
  STA $0151,Y                             ; $B1D6: 99 51 01
  CMP #$FF                                ; $B1D9: C9 FF
  BEQ $B1DE                               ; $B1DB: F0 01
  INX                                     ; $B1DD: E8
Loc_B1DE:
  INY                                     ; $B1DE: C8
  CPY #$0A                                ; $B1DF: C0 0A
  BCC $B1D3                               ; $B1E1: 90 F0
  CPX #$02                                ; $B1E3: E0 02
  BCS $B1EA                               ; $B1E5: B0 03
  JMP $B235                               ; $B1E7: 4C 35 B2
Loc_B1EA:
  LDY #$00                                ; $B1EA: A0 00
  LDA ($EE),Y                             ; $B1EC: B1 EE
  CMP $0481                               ; $B1EE: CD 81 04
  BNE $B1F6                               ; $B1F1: D0 03
  JMP $B235                               ; $B1F3: 4C 35 B2
Loc_B1F6:
  LDA #$81                                ; $B1F6: A9 81
  STA $0478                               ; $B1F8: 8D 78 04
Loc_B1FB:
  LDA #$FF                                ; $B1FB: A9 FF
  STA $047C                               ; $B1FD: 8D 7C 04
  LDA #$66                                ; $B200: A9 66
  JMP $F26D                               ; $B202: 4C 6D F2
Loc_B205:
  LSR                                     ; $B205: 4A
  BCC $B20D                               ; $B206: 90 05
Loc_B208:
  LDA #$00                                ; $B208: A9 00
  STA $0401                               ; $B20A: 8D 01 04
Loc_B20D:
  RTS                                     ; $B20D: 60
; --- Data Region ---
  .byte $00,$01,$FF,$FF,$D8,$48,$D8,$98,$00,$07,$00,$00,$80; $B20E: 00 01 FF FF D8 48 D8 98 00 07 00 00 80
Loc_B21B:  ; (dispatch callback target)
; --- Code Region ---
  LDA $0478                               ; $B21B: AD 78 04
  BNE $B231                               ; $B21E: D0 11
  JSR $D64A                               ; $B220: 20 4A D6
  LDA $047C                               ; $B223: AD 7C 04
  BPL $B231                               ; $B226: 10 09
  CMP #$90                                ; $B228: C9 90
  BNE $B232                               ; $B22A: D0 06
  LDA #$00                                ; $B22C: A9 00
  STA $0401                               ; $B22E: 8D 01 04
  RTS                                     ; $B231: 60
; --- Data Region ---
  .byte $20,$A8,$D7                       ; $B232: 20 A8 D7
Loc_B235:
; --- Code Region ---
  INC $0401                               ; $B235: EE 01 04
  JSR $DD70                               ; $B238: 20 70 DD
  STA $046C                               ; $B23B: 8D 6C 04
  LDA #$29                                ; $B23E: A9 29
  JMP $F26D                               ; $B240: 4C 6D F2
Loc_B243:  ; (dispatch callback target)
  JSR $D5BD                               ; $B243: 20 BD D5
  LDA a:$0013                             ; $B246: AD 13 00
  BEQ $B254                               ; $B249: F0 09
  CMP #$FF                                ; $B24B: C9 FF
  BNE $B255                               ; $B24D: D0 06
  LDA #$00                                ; $B24F: A9 00
  STA $0401                               ; $B251: 8D 01 04
Loc_B254:
  RTS                                     ; $B254: 60
Loc_B255:
  LDY #$39                                ; $B255: A0 39
  JSR $EE07                               ; $B257: 20 07 EE
; --- Data Region ---
  .byte $15,$A0,$A9,$01,$8D,$A2,$04,$A9,$47,$8D,$D6,$04,$20,$68,$D5,$A9; $B25A: 15 A0 A9 01 8D A2 04 A9 47 8D D6 04 20 68 D5 A9
  .byte $12,$8D,$01,$04,$A9,$00,$8D,$73,$04,$A9,$67,$4C,$6D,$F2; $B26A: 12 8D 01 04 A9 00 8D 73 04 A9 67 4C 6D F2
Loc_B278:  ; (dispatch callback target)
; --- Code Region ---
  JSR $DDAD                               ; $B278: 20 AD DD
  BCC $B293                               ; $B27B: 90 16
  JSR $D543                               ; $B27D: 20 43 D5
  LDA a:$0081                             ; $B280: AD 81 00
  LSR                                     ; $B283: 4A
  BCS $B294                               ; $B284: B0 0E
  LSR                                     ; $B286: 4A
  BCC $B293                               ; $B287: 90 0A
  JSR $DDAD                               ; $B289: 20 AD DD
  BCC $B293                               ; $B28C: 90 05
  LDA #$00                                ; $B28E: A9 00
  STA $0401                               ; $B290: 8D 01 04
Loc_B293:
  RTS                                     ; $B293: 60
Loc_B294:
  LDA $0402                               ; $B294: AD 02 04
  JSR $F2AF                               ; $B297: 20 AF F2
  LDY #$0C                                ; $B29A: A0 0C
  LDA #$10                                ; $B29C: A9 10
  SEC                                     ; $B29E: 38
  SBC ($00),Y                             ; $B29F: F1 00
  STA a:$0010                             ; $B2A1: 8D 10 00
  INY                                     ; $B2A4: C8
  LDA #$27                                ; $B2A5: A9 27
  SBC ($00),Y                             ; $B2A7: F1 00
  STA a:$0011                             ; $B2A9: 8D 11 00
  BCS $B2B9                               ; $B2AC: B0 0B
  LDA #$00                                ; $B2AE: A9 00
  STA a:$0000                             ; $B2B0: 8D 00 00
  STA a:$0001                             ; $B2B3: 8D 01 00
  JMP $B325                               ; $B2B6: 4C 25 B3
Loc_B2B9:
  LDY #$03                                ; $B2B9: A0 03
  LDA ($00),Y                             ; $B2BB: B1 00
  STA a:$0002                             ; $B2BD: 8D 02 00
  DEY                                     ; $B2C0: 88
  LDA ($00),Y                             ; $B2C1: B1 00
  STA a:$0001                             ; $B2C3: 8D 01 00
  LDA #$14                                ; $B2C6: A9 14
  STA a:$0003                             ; $B2C8: 8D 03 00
  LDA #$00                                ; $B2CB: A9 00
  STA a:$0004                             ; $B2CD: 8D 04 00
  JSR $EA7C                               ; $B2D0: 20 7C EA
  LDA a:$0001                             ; $B2D3: AD 01 00
  STA a:$0000                             ; $B2D6: 8D 00 00
  LDA a:$0002                             ; $B2D9: AD 02 00
  STA a:$0001                             ; $B2DC: 8D 01 00
  LDA #$00                                ; $B2DF: A9 00
  STA a:$0002                             ; $B2E1: 8D 02 00
  LDA #$64                                ; $B2E4: A9 64
  STA a:$0003                             ; $B2E6: 8D 03 00
  JSR $EBE9                               ; $B2E9: 20 E9 EB
  LDA a:$0006                             ; $B2EC: AD 06 00
  STA a:$0000                             ; $B2EF: 8D 00 00
  LDA a:$0007                             ; $B2F2: AD 07 00
  STA a:$0001                             ; $B2F5: 8D 01 00
  LDA a:$0010                             ; $B2F8: AD 10 00
  SEC                                     ; $B2FB: 38
  SBC a:$0000                             ; $B2FC: ED 00 00
  LDA a:$0011                             ; $B2FF: AD 11 00
  SBC a:$0001                             ; $B302: ED 01 00
  BCS $B313                               ; $B305: B0 0C
  LDA a:$0010                             ; $B307: AD 10 00
  STA a:$0000                             ; $B30A: 8D 00 00
  LDA a:$0011                             ; $B30D: AD 11 00
  STA a:$0001                             ; $B310: 8D 01 00
Loc_B313:
  LDA #$00                                ; $B313: A9 00
  STA a:$0002                             ; $B315: 8D 02 00
  STA a:$0004                             ; $B318: 8D 04 00
  LDA #$64                                ; $B31B: A9 64
  STA a:$0003                             ; $B31D: 8D 03 00
  LDA #$00                                ; $B320: A9 00
  JSR $EAA5                               ; $B322: 20 A5 EA
Loc_B325:
  LDA a:$0000                             ; $B325: AD 00 00
  STA $0490                               ; $B328: 8D 90 04
  LDA a:$0001                             ; $B32B: AD 01 00
  STA $0491                               ; $B32E: 8D 91 04
  JSR $DB87                               ; $B331: 20 87 DB
  INC $0401                               ; $B334: EE 01 04
  LDA #$69                                ; $B337: A9 69
  JMP $F26D                               ; $B339: 4C 6D F2
Loc_B33C:  ; (dispatch callback target)
  JSR $DDAD                               ; $B33C: 20 AD DD
  BCC $B36C                               ; $B33F: 90 2B
  LDA #$D0                                ; $B341: A9 D0
  STA $031C                               ; $B343: 8D 1C 03
  LDA #$22                                ; $B346: A9 22
  STA $031D                               ; $B348: 8D 1D 03
  LDA #$02                                ; $B34B: A9 02
  JSR $DA04                               ; $B34D: 20 04 DA
  LDA a:$0081                             ; $B350: AD 81 00
  LSR                                     ; $B353: 4A
  BCC $B364                               ; $B354: 90 0E
  JSR $DD70                               ; $B356: 20 70 DD
  STA $046C                               ; $B359: 8D 6C 04
  INC $0401                               ; $B35C: EE 01 04
  LDA #$29                                ; $B35F: A9 29
  JMP $F26D                               ; $B361: 4C 6D F2
Loc_B364:
  LSR                                     ; $B364: 4A
  BCC $B36C                               ; $B365: 90 05
  LDA #$00                                ; $B367: A9 00
  STA $0401                               ; $B369: 8D 01 04
Loc_B36C:
  RTS                                     ; $B36C: 60
Loc_B36D:  ; (dispatch callback target)
  JSR $D5BD                               ; $B36D: 20 BD D5
  LDA a:$0013                             ; $B370: AD 13 00
  BEQ $B37E                               ; $B373: F0 09
  CMP #$FF                                ; $B375: C9 FF
  BNE $B37F                               ; $B377: D0 06
  LDA #$00                                ; $B379: A9 00
  STA $0401                               ; $B37B: 8D 01 04
Loc_B37E:
  RTS                                     ; $B37E: 60
Loc_B37F:
  LDA $048E                               ; $B37F: AD 8E 04
  STA a:$0000                             ; $B382: 8D 00 00
  LDA $048F                               ; $B385: AD 8F 04
  STA a:$0001                             ; $B388: 8D 01 00
  LDA #$00                                ; $B38B: A9 00
  STA a:$0002                             ; $B38D: 8D 02 00
  LDA #$14                                ; $B390: A9 14
  STA a:$0003                             ; $B392: 8D 03 00
  JSR $EBE9                               ; $B395: 20 E9 EB
  LDA a:$0006                             ; $B398: AD 06 00
  STA a:$0010                             ; $B39B: 8D 10 00
  LDA a:$0007                             ; $B39E: AD 07 00
  STA a:$0011                             ; $B3A1: 8D 11 00
  LDA $048E                               ; $B3A4: AD 8E 04
  STA a:$0000                             ; $B3A7: 8D 00 00
  LDA $048F                               ; $B3AA: AD 8F 04
  STA a:$0001                             ; $B3AD: 8D 01 00
  LDA #$00                                ; $B3B0: A9 00
  STA a:$0002                             ; $B3B2: 8D 02 00
  LDA #$64                                ; $B3B5: A9 64
  STA a:$0003                             ; $B3B7: 8D 03 00
  JSR $EBE9                               ; $B3BA: 20 E9 EB
  LDA $0402                               ; $B3BD: AD 02 04
  JSR $F2AF                               ; $B3C0: 20 AF F2
  LDY #$02                                ; $B3C3: A0 02
  LDA ($00),Y                             ; $B3C5: B1 00
  SEC                                     ; $B3C7: 38
  SBC a:$0010                             ; $B3C8: ED 10 00
  STA ($00),Y                             ; $B3CB: 91 00
  INY                                     ; $B3CD: C8
  LDA ($00),Y                             ; $B3CE: B1 00
  SBC a:$0011                             ; $B3D0: ED 11 00
  STA ($00),Y                             ; $B3D3: 91 00
  LDY #$0C                                ; $B3D5: A0 0C
  LDA ($00),Y                             ; $B3D7: B1 00
  CLC                                     ; $B3D9: 18
  ADC a:$0006                             ; $B3DA: 6D 06 00
  STA ($00),Y                             ; $B3DD: 91 00
  STA $042C                               ; $B3DF: 8D 2C 04
  INY                                     ; $B3E2: C8
  LDA ($00),Y                             ; $B3E3: B1 00
  ADC a:$0007                             ; $B3E5: 6D 07 00
  STA ($00),Y                             ; $B3E8: 91 00
  STA $042D                               ; $B3EA: 8D 2D 04
  LDA #$00                                ; $B3ED: A9 00
  STA $042E                               ; $B3EF: 8D 2E 04
  LDA #$1A                                ; $B3F2: A9 1A
  STA $04A2                               ; $B3F4: 8D A2 04
  LDA #$4D                                ; $B3F7: A9 4D
  STA $04D6                               ; $B3F9: 8D D6 04
  LDA #$12                                ; $B3FC: A9 12
  STA $0401                               ; $B3FE: 8D 01 04
  LDA #$FF                                ; $B401: A9 FF
  STA $0473                               ; $B403: 8D 73 04
  JSR $D568                               ; $B406: 20 68 D5
  LDA #$00                                ; $B409: A9 00
  JMP $F29B                               ; $B40B: 4C 9B F2
Loc_B40E:  ; (dispatch callback target)
  JSR $DDAD                               ; $B40E: 20 AD DD
  BCC $B430                               ; $B411: 90 1D
  JSR $D543                               ; $B413: 20 43 D5
  LDA a:$0081                             ; $B416: AD 81 00
  AND #$03                                ; $B419: 29 03
  BNE $B41E                               ; $B41B: D0 01
  RTS                                     ; $B41D: 60
Loc_B41E:
  LDA #$81                                ; $B41E: A9 81
  STA $0478                               ; $B420: 8D 78 04
  LDA #$10                                ; $B423: A9 10
  STA $047C                               ; $B425: 8D 7C 04
  INC $0401                               ; $B428: EE 01 04
  LDA #$6A                                ; $B42B: A9 6A
  JMP $F26D                               ; $B42D: 4C 6D F2
Loc_B430:
  RTS                                     ; $B430: 60
Loc_B431:  ; (dispatch callback target)
  LDA $0478                               ; $B431: AD 78 04
  BNE $B45C                               ; $B434: D0 26
  JSR $D64A                               ; $B436: 20 4A D6
  LDA $047C                               ; $B439: AD 7C 04
  BPL $B45C                               ; $B43C: 10 1E
  LDA $0402                               ; $B43E: AD 02 04
  JSR $F2AF                               ; $B441: 20 AF F2
  LDY #$0C                                ; $B444: A0 0C
  LDA $042C                               ; $B446: AD 2C 04
  STA ($00),Y                             ; $B449: 91 00
  INY                                     ; $B44B: C8
  LDA $042D                               ; $B44C: AD 2D 04
  STA ($00),Y                             ; $B44F: 91 00
  JSR $D568                               ; $B451: 20 68 D5
  LDA #$00                                ; $B454: A9 00
  STA $0400                               ; $B456: 8D 00 04
  STA $0401                               ; $B459: 8D 01 04
Loc_B45C:
  RTS                                     ; $B45C: 60
Loc_B45D:  ; (dispatch callback target)
  JSR $D5BD                               ; $B45D: 20 BD D5
  LDA a:$0013                             ; $B460: AD 13 00
  BEQ $B479                               ; $B463: F0 14
  CMP #$FF                                ; $B465: C9 FF
  BEQ $B474                               ; $B467: F0 0B
  INC $0401                               ; $B469: EE 01 04
  JSR $D568                               ; $B46C: 20 68 D5
  LDA #$6B                                ; $B46F: A9 6B
  JMP $F26D                               ; $B471: 4C 6D F2
Loc_B474:
  LDA #$00                                ; $B474: A9 00
  STA $0401                               ; $B476: 8D 01 04
Loc_B479:
  RTS                                     ; $B479: 60
Loc_B47A:  ; (dispatch callback target)
  JSR $DDF2                               ; $B47A: 20 F2 DD
  JSR $DDAD                               ; $B47D: 20 AD DD
  BCC $B479                               ; $B480: 90 F7
  LDA a:$0081                             ; $B482: AD 81 00
  LSR                                     ; $B485: 4A
  BCS $B4AA                               ; $B486: B0 22
  LSR                                     ; $B488: 4A
  BCC $B479                               ; $B489: 90 EE
  LDA #$FF                                ; $B48B: A9 FF
  STA $04E4                               ; $B48D: 8D E4 04
  JSR $DDAD                               ; $B490: 20 AD DD
  BCC $B479                               ; $B493: 90 E4
  LDA #$11                                ; $B495: A9 11
  STA $0401                               ; $B497: 8D 01 04
  JSR $DD70                               ; $B49A: 20 70 DD
  STA $04E4                               ; $B49D: 8D E4 04
  LDA #$6D                                ; $B4A0: A9 6D
  JMP $F26D                               ; $B4A2: 4C 6D F2
Loc_B4A5:
  LDA #$24                                ; $B4A5: A9 24
  JMP $F26D                               ; $B4A7: 4C 6D F2
Loc_B4AA:
  JSR $DEBA                               ; $B4AA: 20 BA DE
  CPY #$FF                                ; $B4AD: C0 FF
  BEQ $B4A5                               ; $B4AF: F0 F4
  STY $0402                               ; $B4B1: 8C 02 04
  TYA                                     ; $B4B4: 98
  JSR $F2AF                               ; $B4B5: 20 AF F2
  LDA #$80                                ; $B4B8: A9 80
  STA $0140                               ; $B4BA: 8D 40 01
  LDX #$01                                ; $B4BD: A2 01
  LDY #$80                                ; $B4BF: A0 80
  LDA $6F3F                               ; $B4C1: AD 3F 6F
  BMI $B4CA                               ; $B4C4: 30 04
  LDX #$81                                ; $B4C6: A2 81
  LDY #$40                                ; $B4C8: A0 40
Loc_B4CA:
  STX $0150                               ; $B4CA: 8E 50 01
  LDA #$FF                                ; $B4CD: A9 FF
  STA $04E4                               ; $B4CF: 8D E4 04
  LDA #$00                                ; $B4D2: A9 00
  STA $0472                               ; $B4D4: 8D 72 04
  LDA #$01                                ; $B4D7: A9 01
  STA $0473                               ; $B4D9: 8D 73 04
  LDY #$00                                ; $B4DC: A0 00
  LDA ($00),Y                             ; $B4DE: B1 00
  CMP #$07                                ; $B4E0: C9 07
  BNE $B4EE                               ; $B4E2: D0 0A
  LDA #$17                                ; $B4E4: A9 17
  STA $0401                               ; $B4E6: 8D 01 04
  LDA #$B7                                ; $B4E9: A9 B7
  JMP $F26D                               ; $B4EB: 4C 6D F2
Loc_B4EE:
  LDA #$00                                ; $B4EE: A9 00
  STA $0400                               ; $B4F0: 8D 00 04
  LDA #$02                                ; $B4F3: A9 02
  STA $0401                               ; $B4F5: 8D 01 04
  LDA #$03                                ; $B4F8: A9 03
  STA $0470                               ; $B4FA: 8D 70 04
  LDA #$10                                ; $B4FD: A9 10
  STA $0471                               ; $B4FF: 8D 71 04
  LDA #$00                                ; $B502: A9 00
  JMP $F26D                               ; $B504: 4C 6D F2
Loc_B507:  ; (dispatch callback target)
  LDA #$80                                ; $B507: A9 80
  STA $0140                               ; $B509: 8D 40 01
  LDX #$00                                ; $B50C: A2 00
  LDA $6F3F                               ; $B50E: AD 3F 6F
  BMI $B515                               ; $B511: 30 02
  LDX #$80                                ; $B513: A2 80
Loc_B515:
  STX $0150                               ; $B515: 8E 50 01
  JSR $DD70                               ; $B518: 20 70 DD
  INC $0401                               ; $B51B: EE 01 04
  LDA #$00                                ; $B51E: A9 00
  STA $04E4                               ; $B520: 8D E4 04
  LDA #$6D                                ; $B523: A9 6D
  JMP $F26D                               ; $B525: 4C 6D F2
Loc_B528:  ; (dispatch callback target)
  LDA #$85                                ; $B528: A9 85
  STA a:$0010                             ; $B52A: 8D 10 00
  LDA #$B5                                ; $B52D: A9 B5
  STA a:$0011                             ; $B52F: 8D 11 00
  LDA #$00                                ; $B532: A9 00
  STA a:$0012                             ; $B534: 8D 12 00
  JSR $ED1E                               ; $B537: 20 1E ED
  LDA #$89                                ; $B53A: A9 89
  STA a:$0010                             ; $B53C: 8D 10 00
  LDA #$B5                                ; $B53F: A9 B5
  STA a:$0011                             ; $B541: 8D 11 00
  LDA #$8D                                ; $B544: A9 8D
  STA a:$0000                             ; $B546: 8D 00 00
  LDA #$B5                                ; $B549: A9 B5
  STA a:$0001                             ; $B54B: 8D 01 00
  LDA a:$0012                             ; $B54E: AD 12 00
  JSR $EDF5                               ; $B551: 20 F5 ED
  JSR $DDAD                               ; $B554: 20 AD DD
  BCC $B584                               ; $B557: 90 2B
  LDA a:$0081                             ; $B559: AD 81 00
  LSR                                     ; $B55C: 4A
  BCC $B584                               ; $B55D: 90 25
  LDA a:$0012                             ; $B55F: AD 12 00
  BNE $B56E                               ; $B562: D0 0A
  LDA #$0F                                ; $B564: A9 0F
  STA $0401                               ; $B566: 8D 01 04
  LDA #$6B                                ; $B569: A9 6B
  JMP $F26D                               ; $B56B: 4C 6D F2
Loc_B56E:
  LDA $046D                               ; $B56E: AD 6D 04
  STA $6F3F                               ; $B571: 8D 3F 6F
  LDA $046E                               ; $B574: AD 6E 04
  STA $6F41                               ; $B577: 8D 41 6F
  LDA #$00                                ; $B57A: A9 00
  STA $0400                               ; $B57C: 8D 00 04
  STA $0401                               ; $B57F: 8D 01 04
  LDA #$03                                ; $B582: A9 03
Loc_B584:
  RTS                                     ; $B584: 60
; --- Data Region ---
  .byte $00,$01,$FF,$FF,$C8,$48,$C8,$98,$00,$07,$00,$00,$80; $B585: 00 01 FF FF C8 48 C8 98 00 07 00 00 80
Loc_B592:  ; (dispatch callback target)
; --- Code Region ---
  LDA $0140                               ; $B592: AD 40 01
  BNE $B5A5                               ; $B595: D0 0E
  LDA $04A2                               ; $B597: AD A2 04
  STA $04A0                               ; $B59A: 8D A0 04
  INC $0401                               ; $B59D: EE 01 04
  LDA #$20                                ; $B5A0: A9 20
  STA $046C                               ; $B5A2: 8D 6C 04
  RTS                                     ; $B5A5: 60
Loc_B5A6:  ; (dispatch callback target)
  LDA $04A0                               ; $B5A6: AD A0 04
  BNE $B5DB                               ; $B5A9: D0 30
  LDA $0140                               ; $B5AB: AD 40 01
  BNE $B5DB                               ; $B5AE: D0 2B
  LDA $0473                               ; $B5B0: AD 73 04
  BMI $B5D1                               ; $B5B3: 30 1C
  LDA $0507                               ; $B5B5: AD 07 05
  AND #$0F                                ; $B5B8: 29 0F
  CMP #$07                                ; $B5BA: C9 07
  BEQ $B5CE                               ; $B5BC: F0 10
  JSR $ECEE                               ; $B5BE: 20 EE EC
  LDY #$3D                                ; $B5C1: A0 3D
  JSR $EE07                               ; $B5C3: 20 07 EE
; --- Data Region ---
  .byte $24,$A0,$A9,$15,$8D,$01,$04,$60   ; $B5C6: 24 A0 A9 15 8D 01 04 60
Loc_B5CE:
; --- Code Region ---
  JMP $B670                               ; $B5CE: 4C 70 B6
Loc_B5D1:
  LDA #$03                                ; $B5D1: A9 03
  JSR $D58C                               ; $B5D3: 20 8C D5
  LDA #$0C                                ; $B5D6: A9 0C
  STA $0401                               ; $B5D8: 8D 01 04
Loc_B5DB:
  RTS                                     ; $B5DB: 60
Loc_B5DC:  ; (dispatch callback target)
  LDA a:$0087                             ; $B5DC: AD 87 00
  BPL $B61F                               ; $B5DF: 10 3E
  LDA #$03                                ; $B5E1: A9 03
  STA a:$007A                             ; $B5E3: 8D 7A 00
  LDA #$00                                ; $B5E6: A9 00
  STA $0401                               ; $B5E8: 8D 01 04
  LDA #$00                                ; $B5EB: A9 00
  STA $0510                               ; $B5ED: 8D 10 05
  STA $0511                               ; $B5F0: 8D 11 05
  STA $0512                               ; $B5F3: 8D 12 05
  STA $0513                               ; $B5F6: 8D 13 05
  LDA #$0A                                ; $B5F9: A9 0A
  STA $0500                               ; $B5FB: 8D 00 05
  LDA #$00                                ; $B5FE: A9 00
  STA $0501                               ; $B600: 8D 01 05
  STA $0502                               ; $B603: 8D 02 05
  STA $0503                               ; $B606: 8D 03 05
  LDA #$80                                ; $B609: A9 80
  STA $0504                               ; $B60B: 8D 04 05
  LDA #$00                                ; $B60E: A9 00
  STA $0505                               ; $B610: 8D 05 05
  LDA #$00                                ; $B613: A9 00
  STA $0506                               ; $B615: 8D 06 05
  LDY #$2C                                ; $B618: A0 2C
  JSR $EE07                               ; $B61A: 20 07 EE
; --- Data Region ---
  .byte $03,$A0,$60,$AD,$72,$04,$D0,$06,$AD,$81,$00,$4A,$90,$3C; $B61D: 03 A0 60 AD 72 04 D0 06 AD 81 00 4A 90 3C
Loc_B62B:
; --- Code Region ---
  LDA $0140                               ; $B62B: AD 40 01
  BNE $B66F                               ; $B62E: D0 3F
  LDA $0472                               ; $B630: AD 72 04
  BMI $B63F                               ; $B633: 30 0A
  BEQ $B645                               ; $B635: F0 0E
  CMP #$0A                                ; $B637: C9 0A
  BEQ $B64E                               ; $B639: F0 13
  INC $0472                               ; $B63B: EE 72 04
  RTS                                     ; $B63E: 60
Loc_B63F:
  LDA #$00                                ; $B63F: A9 00
  STA $0472                               ; $B641: 8D 72 04
  RTS                                     ; $B644: 60
Loc_B645:
  LDA #$80                                ; $B645: A9 80
  STA $0140                               ; $B647: 8D 40 01
  INC $0472                               ; $B64A: EE 72 04
  RTS                                     ; $B64D: 60
Loc_B64E:
  LDA #$80                                ; $B64E: A9 80
  STA $0140                               ; $B650: 8D 40 01
  LDA $0473                               ; $B653: AD 73 04
  EOR #$03                                ; $B656: 49 03
  STA $0473                               ; $B658: 8D 73 04
  ORA $0150                               ; $B65B: 0D 50 01
  STA $0150                               ; $B65E: 8D 50 01
  LDA #$80                                ; $B661: A9 80
  STA $0472                               ; $B663: 8D 72 04
  RTS                                     ; $B666: 60
Loc_B667:
  LSR                                     ; $B667: 4A
  BCC $B66F                               ; $B668: 90 05
  LDA #$10                                ; $B66A: A9 10
  STA $0401                               ; $B66C: 8D 01 04
Loc_B66F:
  RTS                                     ; $B66F: 60
Loc_B670:  ; (dispatch callback target)
  JSR $E57F                               ; $B670: 20 7F E5
  LDA #$81                                ; $B673: A9 81
  JSR $E673                               ; $B675: 20 73 E6
  LDA $0471                               ; $B678: AD 71 04
  JSR $F2AF                               ; $B67B: 20 AF F2
  LDY #$02                                ; $B67E: A0 02
  LDA $0526                               ; $B680: AD 26 05
  CLC                                     ; $B683: 18
  ADC $042F                               ; $B684: 6D 2F 04
  STA ($00),Y                             ; $B687: 91 00
  INY                                     ; $B689: C8
  LDA $0527                               ; $B68A: AD 27 05
  ADC $0430                               ; $B68D: 6D 30 04
  STA ($00),Y                             ; $B690: 91 00
  LDY #$02                                ; $B692: A0 02
  JSR $DDDC                               ; $B694: 20 DC DD
  LDY #$04                                ; $B697: A0 04
  LDA $0522                               ; $B699: AD 22 05
  CLC                                     ; $B69C: 18
  ADC $0432                               ; $B69D: 6D 32 04
  STA ($00),Y                             ; $B6A0: 91 00
  INY                                     ; $B6A2: C8
  LDA $0523                               ; $B6A3: AD 23 05
  ADC $0433                               ; $B6A6: 6D 33 04
  STA ($00),Y                             ; $B6A9: 91 00
  LDY #$04                                ; $B6AB: A0 04
  JSR $DDDC                               ; $B6AD: 20 DC DD
  LDY #$00                                ; $B6B0: A0 00
  LDA ($EE),Y                             ; $B6B2: B1 EE
  STA a:$000A                             ; $B6B4: 8D 0A 00
  LDY #$11                                ; $B6B7: A0 11
  LDX #$0A                                ; $B6B9: A2 0A
Loc_B6BB:
  LDA $0664,X                             ; $B6BB: BD 64 06
  CMP #$FF                                ; $B6BE: C9 FF
  BEQ $B6DA                               ; $B6C0: F0 18
  STA ($00),Y                             ; $B6C2: 91 00
  CMP a:$000A                             ; $B6C4: CD 0A 00
  BNE $B6D4                               ; $B6C7: D0 0B
  TYA                                     ; $B6C9: 98
  PHA                                     ; $B6CA: 48
  LDA $0471                               ; $B6CB: AD 71 04
  LDY #$01                                ; $B6CE: A0 01
  STA ($EE),Y                             ; $B6D0: 91 EE
  PLA                                     ; $B6D2: 68
  TAY                                     ; $B6D3: A8
Loc_B6D4:
  INX                                     ; $B6D4: E8
  INY                                     ; $B6D5: C8
  CPY #$1B                                ; $B6D6: C0 1B
  BCC $B6BB                               ; $B6D8: 90 E1
Loc_B6DA:
  LDA $0507                               ; $B6DA: AD 07 05
  LSR                                     ; $B6DD: 4A
  LSR                                     ; $B6DE: 4A
  LSR                                     ; $B6DF: 4A
  LSR                                     ; $B6E0: 4A
  LDY #$00                                ; $B6E1: A0 00
  STA ($00),Y                             ; $B6E3: 91 00
  LDA #$00                                ; $B6E5: A9 00
  STA $0400                               ; $B6E7: 8D 00 04
  STA $0401                               ; $B6EA: 8D 01 04
  JSR $D568                               ; $B6ED: 20 68 D5
  RTS                                     ; $B6F0: 60
Loc_B6F1:  ; (dispatch callback target)
  LDA $0478                               ; $B6F1: AD 78 04
  BNE $B707                               ; $B6F4: D0 11
  JSR $D64A                               ; $B6F6: 20 4A D6
  LDA $047C                               ; $B6F9: AD 7C 04
  BPL $B707                               ; $B6FC: 10 09
  CMP #$90                                ; $B6FE: C9 90
  BNE $B708                               ; $B700: D0 06
  LDA #$00                                ; $B702: A9 00
  STA $0401                               ; $B704: 8D 01 04
Loc_B707:
  RTS                                     ; $B707: 60
Loc_B708:
  JSR $D7A8                               ; $B708: 20 A8 D7
  LDA $0402                               ; $B70B: AD 02 04
  JSR $F2AF                               ; $B70E: 20 AF F2
  LDY #$11                                ; $B711: A0 11
  LDA ($00),Y                             ; $B713: B1 00
  STA a:$0010                             ; $B715: 8D 10 00
  LDY #$11                                ; $B718: A0 11
Loc_B71A:
  LDA ($00),Y                             ; $B71A: B1 00
  CMP $0481                               ; $B71C: CD 81 04
  BEQ $B725                               ; $B71F: F0 04
  INY                                     ; $B721: C8
  JMP $B71A                               ; $B722: 4C 1A B7
Loc_B725:
  LDA a:$0010                             ; $B725: AD 10 00
  STA ($00),Y                             ; $B728: 91 00
  LDY #$11                                ; $B72A: A0 11
  LDA $0481                               ; $B72C: AD 81 04
  STA ($00),Y                             ; $B72F: 91 00
  STA $042C                               ; $B731: 8D 2C 04
  LDA #$16                                ; $B734: A9 16
  STA $0401                               ; $B736: 8D 01 04
  LDA #$64                                ; $B739: A9 64
  JMP $F26D                               ; $B73B: 4C 6D F2
Loc_B73E:  ; (dispatch callback target)
  JSR $DDAD                               ; $B73E: 20 AD DD
  BCC $B758                               ; $B741: 90 15
  JSR $D543                               ; $B743: 20 43 D5
  LDA a:$0081                             ; $B746: AD 81 00
  AND #$03                                ; $B749: 29 03
  BEQ $B758                               ; $B74B: F0 0B
  JSR $D568                               ; $B74D: 20 68 D5
  LDA #$00                                ; $B750: A9 00
  STA $0400                               ; $B752: 8D 00 04
  STA $0401                               ; $B755: 8D 01 04
Loc_B758:
  RTS                                     ; $B758: 60
Loc_B759:  ; (dispatch callback target)
  LDA $0401                               ; $B759: AD 01 04
  JSR $EADE                               ; $B75C: 20 DE EA
; --- Data Region ---
  .byte $7F,$B7,$A7,$B7,$1E,$B8,$97,$B8,$7E,$B9,$04,$BA,$CE,$BA,$7D,$BB; $B75F: 7F B7 A7 B7 1E B8 97 B8 7E B9 04 BA CE BA 7D BB
  .byte $C6,$BB,$E6,$BC,$67,$BD,$19,$BE,$05,$BF,$19,$BF,$44,$BF,$69,$BF; $B76F: C6 BB E6 BC 67 BD 19 BE 05 BF 19 BF 44 BF 69 BF
Loc_B77F:  ; (dispatch callback target)
; --- Code Region ---
  LDA $0140                               ; $B77F: AD 40 01
  BNE $B7A6                               ; $B782: D0 22
  LDA $0304                               ; $B784: AD 04 03
  CMP #$FF                                ; $B787: C9 FF
  BNE $B7A6                               ; $B789: D0 1B
  INC $0401                               ; $B78B: EE 01 04
  JSR $DD70                               ; $B78E: 20 70 DD
  STA $0473                               ; $B791: 8D 73 04
  LDA #$80                                ; $B794: A9 80
  STA $0140                               ; $B796: 8D 40 01
  LDA #$04                                ; $B799: A9 04
  ORA $0150                               ; $B79B: 0D 50 01
  STA $0150                               ; $B79E: 8D 50 01
  LDA #$53                                ; $B7A1: A9 53
  JMP $F26D                               ; $B7A3: 4C 6D F2
Loc_B7A6:
  RTS                                     ; $B7A6: 60
Loc_B7A7:  ; (dispatch callback target)
  LDA #$12                                ; $B7A7: A9 12
  STA a:$0010                             ; $B7A9: 8D 10 00
  LDA #$B8                                ; $B7AC: A9 B8
  STA a:$0011                             ; $B7AE: 8D 11 00
  LDA #$00                                ; $B7B1: A9 00
  STA a:$0012                             ; $B7B3: 8D 12 00
  JSR $ED19                               ; $B7B6: 20 19 ED
  LDA #$15                                ; $B7B9: A9 15
  STA a:$0010                             ; $B7BB: 8D 10 00
  LDA #$B8                                ; $B7BE: A9 B8
  STA a:$0011                             ; $B7C0: 8D 11 00
  LDA #$19                                ; $B7C3: A9 19
  STA a:$0000                             ; $B7C5: 8D 00 00
  LDA #$B8                                ; $B7C8: A9 B8
  STA a:$0001                             ; $B7CA: 8D 01 00
  LDA a:$0012                             ; $B7CD: AD 12 00
  JSR $EDF5                               ; $B7D0: 20 F5 ED
  JSR $DDAD                               ; $B7D3: 20 AD DD
  BCC $B811                               ; $B7D6: 90 39
  LDA a:$0081                             ; $B7D8: AD 81 00
  LSR                                     ; $B7DB: 4A
  BCC $B801                               ; $B7DC: 90 23
  LDA a:$0012                             ; $B7DE: AD 12 00
  BNE $B7F4                               ; $B7E1: D0 11
  JSR $D568                               ; $B7E3: 20 68 D5
  INC $0401                               ; $B7E6: EE 01 04
  LDA $0402                               ; $B7E9: AD 02 04
  STA $0470                               ; $B7EC: 8D 70 04
  LDA #$54                                ; $B7EF: A9 54
  JMP $F26D                               ; $B7F1: 4C 6D F2
Loc_B7F4:
  LDA #$05                                ; $B7F4: A9 05
  STA $0401                               ; $B7F6: 8D 01 04
  JSR $DD70                               ; $B7F9: 20 70 DD
  LDA #$58                                ; $B7FC: A9 58
  JMP $F26D                               ; $B7FE: 4C 6D F2
Loc_B801:
  LSR                                     ; $B801: 4A
  BCC $B811                               ; $B802: 90 0D
  JSR $D568                               ; $B804: 20 68 D5
  LDA #$01                                ; $B807: A9 01
  STA $0400                               ; $B809: 8D 00 04
  LDA #$00                                ; $B80C: A9 00
  STA $0401                               ; $B80E: 8D 01 04
Loc_B811:
  RTS                                     ; $B811: 60
; --- Data Region ---
  .byte $00,$01,$FF,$B8,$48,$C8,$48,$00,$07,$00,$00,$80; $B812: 00 01 FF B8 48 C8 48 00 07 00 00 80
Loc_B81E:  ; (dispatch callback target)
; --- Code Region ---
  JSR $DDF2                               ; $B81E: 20 F2 DD
  JSR $DDAD                               ; $B821: 20 AD DD
  BCC $B83E                               ; $B824: 90 18
  LDA a:$0081                             ; $B826: AD 81 00
  LSR                                     ; $B829: 4A
  BCS $B83F                               ; $B82A: B0 13
  LSR                                     ; $B82C: 4A
  BCC $B83E                               ; $B82D: 90 0F
  LDA #$FF                                ; $B82F: A9 FF
  STA $04E4                               ; $B831: 8D E4 04
  LDA #$00                                ; $B834: A9 00
  STA $0401                               ; $B836: 8D 01 04
  LDA #$04                                ; $B839: A9 04
  JSR $D58C                               ; $B83B: 20 8C D5
Loc_B83E:
  RTS                                     ; $B83E: 60
Loc_B83F:
  JSR $DEBA                               ; $B83F: 20 BA DE
  CPY #$FF                                ; $B842: C0 FF
  BEQ $B85F                               ; $B844: F0 19
  STY $0402                               ; $B846: 8C 02 04
  JSR $DD79                               ; $B849: 20 79 DD
  LDA $0402                               ; $B84C: AD 02 04
  BMI $B864                               ; $B84F: 30 13
  STA $0471                               ; $B851: 8D 71 04
  LDA a:$0010                             ; $B854: AD 10 00
  CMP $6F03                               ; $B857: CD 03 6F
  BNE $B864                               ; $B85A: D0 08
  JMP $B869                               ; $B85C: 4C 69 B8
Loc_B85F:
  LDA #$24                                ; $B85F: A9 24
  JMP $F26D                               ; $B861: 4C 6D F2
Loc_B864:
  LDA #$55                                ; $B864: A9 55
  JMP $F26D                               ; $B866: 4C 6D F2
Loc_B869:
  LDY #$39                                ; $B869: A0 39
  JSR $EE07                               ; $B86B: 20 07 EE
; --- Data Region ---
  .byte $18,$A0,$AD,$98,$04,$8D,$90,$04,$AD,$99,$04,$8D; $B86E: 18 A0 AD 98 04 8D 90 04 AD 99 04 8D
Loc_B87A:
; --- Code Region ---
  STA ($04),Y                             ; $B87A: 91 04
  LDA #$04                                ; $B87C: A9 04
  JSR $D58C                               ; $B87E: 20 8C D5
  JSR $DB87                               ; $B881: 20 87 DB
  JSR $DD70                               ; $B884: 20 70 DD
  STA $0472                               ; $B887: 8D 72 04
  LDA #$FF                                ; $B88A: A9 FF
  STA $04E4                               ; $B88C: 8D E4 04
  INC $0401                               ; $B88F: EE 01 04
  LDA #$57                                ; $B892: A9 57
  JMP $F26D                               ; $B894: 4C 6D F2
Loc_B897:  ; (dispatch callback target)
  JSR $DDAD                               ; $B897: 20 AD DD
  BCC $B916                               ; $B89A: 90 7A
  LDA $0472                               ; $B89C: AD 72 04
  BNE $B8D2                               ; $B89F: D0 31
  LDA #$EE                                ; $B8A1: A9 EE
  STA $031C                               ; $B8A3: 8D 1C 03
  LDA #$22                                ; $B8A6: A9 22
  STA $031D                               ; $B8A8: 8D 1D 03
  JSR $DA02                               ; $B8AB: 20 02 DA
  LDA a:$0081                             ; $B8AE: AD 81 00
  LSR                                     ; $B8B1: 4A
  BCC $B8C9                               ; $B8B2: 90 15
  LDA $048E                               ; $B8B4: AD 8E 04
  STA $042C                               ; $B8B7: 8D 2C 04
  LDA $048F                               ; $B8BA: AD 8F 04
  STA $042D                               ; $B8BD: 8D 2D 04
  LDA #$00                                ; $B8C0: A9 00
  STA $042E                               ; $B8C2: 8D 2E 04
  INC $0472                               ; $B8C5: EE 72 04
  RTS                                     ; $B8C8: 60
Loc_B8C9:
  LSR                                     ; $B8C9: 4A
  BCC $B916                               ; $B8CA: 90 4A
  LDA #$00                                ; $B8CC: A9 00
  STA $0401                               ; $B8CE: 8D 01 04
  RTS                                     ; $B8D1: 60
Loc_B8D2:
  CMP #$01                                ; $B8D2: C9 01
  BNE $B8EB                               ; $B8D4: D0 15
  JSR $DB87                               ; $B8D6: 20 87 DB
  LDA $049A                               ; $B8D9: AD 9A 04
  STA $0490                               ; $B8DC: 8D 90 04
  LDA $049B                               ; $B8DF: AD 9B 04
  STA $0491                               ; $B8E2: 8D 91 04
  INC $0472                               ; $B8E5: EE 72 04
  LDA $0472                               ; $B8E8: AD 72 04
Loc_B8EB:
  CMP #$02                                ; $B8EB: C9 02
  BNE $B92F                               ; $B8ED: D0 40
  LDA #$F8                                ; $B8EF: A9 F8
  STA $031C                               ; $B8F1: 8D 1C 03
  LDA #$22                                ; $B8F4: A9 22
  STA $031D                               ; $B8F6: 8D 1D 03
  JSR $DA02                               ; $B8F9: 20 02 DA
  LDA a:$0081                             ; $B8FC: AD 81 00
  LSR                                     ; $B8FF: 4A
  BCC $B917                               ; $B900: 90 15
  LDA $048E                               ; $B902: AD 8E 04
  STA $042F                               ; $B905: 8D 2F 04
  LDA $048F                               ; $B908: AD 8F 04
  STA $0430                               ; $B90B: 8D 30 04
  LDA #$00                                ; $B90E: A9 00
  STA $0431                               ; $B910: 8D 31 04
  INC $0472                               ; $B913: EE 72 04
Loc_B916:
  RTS                                     ; $B916: 60
Loc_B917:
  LSR                                     ; $B917: 4A
  BCC $B916                               ; $B918: 90 FC
  JSR $DB87                               ; $B91A: 20 87 DB
  LDA $0498                               ; $B91D: AD 98 04
  STA $0490                               ; $B920: 8D 90 04
  LDA $0499                               ; $B923: AD 99 04
  STA $0491                               ; $B926: 8D 91 04
  LDA #$00                                ; $B929: A9 00
  STA $0472                               ; $B92B: 8D 72 04
  RTS                                     ; $B92E: 60
Loc_B92F:
  CMP #$03                                ; $B92F: C9 03
  BNE $B944                               ; $B931: D0 11
  JSR $DB87                               ; $B933: 20 87 DB
  LDA $049C                               ; $B936: AD 9C 04
  STA $0490                               ; $B939: 8D 90 04
  LDA #$00                                ; $B93C: A9 00
  STA $0491                               ; $B93E: 8D 91 04
  INC $0472                               ; $B941: EE 72 04
Loc_B944:
  LDA #$2E                                ; $B944: A9 2E
  STA $031C                               ; $B946: 8D 1C 03
  LDA #$23                                ; $B949: A9 23
  STA $031D                               ; $B94B: 8D 1D 03
  LDA #$01                                ; $B94E: A9 01
  JSR $DA04                               ; $B950: 20 04 DA
  LDA a:$0081                             ; $B953: AD 81 00
  LSR                                     ; $B956: 4A
  BCS $B962                               ; $B957: B0 09
  LSR                                     ; $B959: 4A
  BCC $B916                               ; $B95A: 90 BA
  LDA #$01                                ; $B95C: A9 01
  STA $0472                               ; $B95E: 8D 72 04
  RTS                                     ; $B961: 60
Loc_B962:
  LDA $048E                               ; $B962: AD 8E 04
  STA $0432                               ; $B965: 8D 32 04
  LDA #$00                                ; $B968: A9 00
  STA $0433                               ; $B96A: 8D 33 04
  STA $0434                               ; $B96D: 8D 34 04
  JSR $DD70                               ; $B970: 20 70 DD
  STA $046C                               ; $B973: 8D 6C 04
  INC $0401                               ; $B976: EE 01 04
  LDA #$29                                ; $B979: A9 29
  JMP $F26D                               ; $B97B: 4C 6D F2
Loc_B97E:  ; (dispatch callback target)
  JSR $D5BD                               ; $B97E: 20 BD D5
  LDA a:$0013                             ; $B981: AD 13 00
  BEQ $BA03                               ; $B984: F0 7D
  CMP #$FF                                ; $B986: C9 FF
  BEQ $B9FE                               ; $B988: F0 74
  LDA $0402                               ; $B98A: AD 02 04
  JSR $F2AF                               ; $B98D: 20 AF F2
  LDY #$02                                ; $B990: A0 02
  LDX #$00                                ; $B992: A2 00
Loc_B994:
  LDA ($00),Y                             ; $B994: B1 00
  SEC                                     ; $B996: 38
  SBC $042C,X                             ; $B997: FD 2C 04
  STA ($00),Y                             ; $B99A: 91 00
  INY                                     ; $B99C: C8
  INX                                     ; $B99D: E8
  LDA ($00),Y                             ; $B99E: B1 00
  SBC $042C,X                             ; $B9A0: FD 2C 04
  STA ($00),Y                             ; $B9A3: 91 00
  INY                                     ; $B9A5: C8
  LDX #$03                                ; $B9A6: A2 03
  CPY #$06                                ; $B9A8: C0 06
  BCC $B994                               ; $B9AA: 90 E8
  LDY #$10                                ; $B9AC: A0 10
  LDA ($00),Y                             ; $B9AE: B1 00
  SEC                                     ; $B9B0: 38
  SBC $0432                               ; $B9B1: ED 32 04
  STA ($00),Y                             ; $B9B4: 91 00
  LDA $0471                               ; $B9B6: AD 71 04
  JSR $F2AF                               ; $B9B9: 20 AF F2
  LDY #$02                                ; $B9BC: A0 02
  LDX #$00                                ; $B9BE: A2 00
Loc_B9C0:
  LDA ($00),Y                             ; $B9C0: B1 00
  CLC                                     ; $B9C2: 18
  ADC $042C,X                             ; $B9C3: 7D 2C 04
  STA ($00),Y                             ; $B9C6: 91 00
  INY                                     ; $B9C8: C8
  INX                                     ; $B9C9: E8
  LDA ($00),Y                             ; $B9CA: B1 00
  ADC $042C,X                             ; $B9CC: 7D 2C 04
  STA ($00),Y                             ; $B9CF: 91 00
  INY                                     ; $B9D1: C8
  LDX #$03                                ; $B9D2: A2 03
  CPY #$06                                ; $B9D4: C0 06
  BCC $B9C0                               ; $B9D6: 90 E8
  LDY #$10                                ; $B9D8: A0 10
  LDA ($00),Y                             ; $B9DA: B1 00
  CLC                                     ; $B9DC: 18
  ADC $0432                               ; $B9DD: 6D 32 04
  STA ($00),Y                             ; $B9E0: 91 00
  LDA #$22                                ; $B9E2: A9 22
  STA $04A2                               ; $B9E4: 8D A2 04
  LDA #$32                                ; $B9E7: A9 32
  STA $04D6                               ; $B9E9: 8D D6 04
  LDA #$FF                                ; $B9EC: A9 FF
  STA $0481                               ; $B9EE: 8D 81 04
  JSR $D568                               ; $B9F1: 20 68 D5
  LDA #$0C                                ; $B9F4: A9 0C
  STA $0401                               ; $B9F6: 8D 01 04
  LDA #$31                                ; $B9F9: A9 31
  JMP $F26D                               ; $B9FB: 4C 6D F2
Loc_B9FE:
  LDA #$00                                ; $B9FE: A9 00
  STA $0401                               ; $BA00: 8D 01 04
Loc_BA03:
  RTS                                     ; $BA03: 60
Loc_BA04:  ; (dispatch callback target)
  LDA #$C2                                ; $BA04: A9 C2
  STA a:$0010                             ; $BA06: 8D 10 00
  LDA #$BA                                ; $BA09: A9 BA
  STA a:$0011                             ; $BA0B: 8D 11 00
  LDA #$00                                ; $BA0E: A9 00
  STA a:$0012                             ; $BA10: 8D 12 00
  JSR $ED19                               ; $BA13: 20 19 ED
  LDA #$C5                                ; $BA16: A9 C5
  STA a:$0010                             ; $BA18: 8D 10 00
  LDA #$BA                                ; $BA1B: A9 BA
  STA a:$0011                             ; $BA1D: 8D 11 00
  LDA #$C9                                ; $BA20: A9 C9
  STA a:$0000                             ; $BA22: 8D 00 00
  LDA #$BA                                ; $BA25: A9 BA
  STA a:$0001                             ; $BA27: 8D 01 00
  LDA a:$0012                             ; $BA2A: AD 12 00
  JSR $EDF5                               ; $BA2D: 20 F5 ED
  JSR $DDAD                               ; $BA30: 20 AD DD
  BCC $BA43                               ; $BA33: 90 0E
  LDA a:$0081                             ; $BA35: AD 81 00
  LSR                                     ; $BA38: 4A
  BCS $BA44                               ; $BA39: B0 09
  LSR                                     ; $BA3B: 4A
  BCC $BA43                               ; $BA3C: 90 05
  LDA #$00                                ; $BA3E: A9 00
  STA $0401                               ; $BA40: 8D 01 04
Loc_BA43:
  RTS                                     ; $BA43: 60
Loc_BA44:
  JSR $DD70                               ; $BA44: 20 70 DD
  JSR $DB87                               ; $BA47: 20 87 DB
  LDA a:$0012                             ; $BA4A: AD 12 00
  BNE $BA57                               ; $BA4D: D0 08
  INC $0401                               ; $BA4F: EE 01 04
  LDA #$7E                                ; $BA52: A9 7E
  JMP $F26D                               ; $BA54: 4C 6D F2
Loc_BA57:
  LDA $0402                               ; $BA57: AD 02 04
  JSR $F2AF                               ; $BA5A: 20 AF F2
  LDY #$0B                                ; $BA5D: A0 0B
  LDA ($00),Y                             ; $BA5F: B1 00
  CMP #$64                                ; $BA61: C9 64
  BCC $BA6F                               ; $BA63: 90 0A
  LDA #$0E                                ; $BA65: A9 0E
  STA $0401                               ; $BA67: 8D 01 04
  LDA #$A7                                ; $BA6A: A9 A7
  JMP $F26D                               ; $BA6C: 4C 6D F2
Loc_BA6F:
  LDA a:$0000                             ; $BA6F: AD 00 00
  STA a:$0010                             ; $BA72: 8D 10 00
  LDA a:$0001                             ; $BA75: AD 01 00
  STA a:$0011                             ; $BA78: 8D 11 00
  LDX #$64                                ; $BA7B: A2 64
  LDY #$03                                ; $BA7D: A0 03
  LDA ($10),Y                             ; $BA7F: B1 10
  BNE $BA8B                               ; $BA81: D0 08
  DEY                                     ; $BA83: 88
  LDA ($10),Y                             ; $BA84: B1 10
  CMP #$64                                ; $BA86: C9 64
  BCS $BA8B                               ; $BA88: B0 01
  TAX                                     ; $BA8A: AA
Loc_BA8B:
  JSR $BF89                               ; $BA8B: 20 89 BF
  STX $0498                               ; $BA8E: 8E 98 04
  STX $0490                               ; $BA91: 8E 90 04
  LDX #$64                                ; $BA94: A2 64
  LDY #$05                                ; $BA96: A0 05
  LDA ($10),Y                             ; $BA98: B1 10
  BNE $BAA4                               ; $BA9A: D0 08
  DEY                                     ; $BA9C: 88
  LDA ($10),Y                             ; $BA9D: B1 10
  CMP #$64                                ; $BA9F: C9 64
  BCS $BAA4                               ; $BAA1: B0 01
  TAX                                     ; $BAA3: AA
Loc_BAA4:
  JSR $BF89                               ; $BAA4: 20 89 BF
  STX $049A                               ; $BAA7: 8E 9A 04
  LDA #$00                                ; $BAAA: A9 00
  STA $0499                               ; $BAAC: 8D 99 04
  STA $049B                               ; $BAAF: 8D 9B 04
  STA $0491                               ; $BAB2: 8D 91 04
  STA $0472                               ; $BAB5: 8D 72 04
  LDA #$0A                                ; $BAB8: A9 0A
  STA $0401                               ; $BABA: 8D 01 04
  LDA #$59                                ; $BABD: A9 59
  JMP $F26D                               ; $BABF: 4C 6D F2
; --- Data Region ---
  .byte $00,$01,$FF,$B8,$58,$C8,$58,$00,$07,$00,$00,$80; $BAC2: 00 01 FF B8 58 C8 58 00 07 00 00 80
Loc_BACE:  ; (dispatch callback target)
; --- Code Region ---
  LDA #$70                                ; $BACE: A9 70
  STA a:$0010                             ; $BAD0: 8D 10 00
Loc_BAD3:
  LDA #$BB                                ; $BAD3: A9 BB
  STA a:$0011                             ; $BAD5: 8D 11 00
  LDA #$00                                ; $BAD8: A9 00
  STA a:$0012                             ; $BADA: 8D 12 00
  JSR $ED1E                               ; $BADD: 20 1E ED
  LDA #$74                                ; $BAE0: A9 74
  STA a:$0010                             ; $BAE2: 8D 10 00
  LDA #$BB                                ; $BAE5: A9 BB
  STA a:$0011                             ; $BAE7: 8D 11 00
  LDA #$78                                ; $BAEA: A9 78
  STA a:$0000                             ; $BAEC: 8D 00 00
  LDA #$BB                                ; $BAEF: A9 BB
  STA a:$0001                             ; $BAF1: 8D 01 00
  LDA a:$0012                             ; $BAF4: AD 12 00
  JSR $EDF5                               ; $BAF7: 20 F5 ED
  JSR $DDAD                               ; $BAFA: 20 AD DD
  BCC $BB6F                               ; $BAFD: 90 70
  LDA a:$0081                             ; $BAFF: AD 81 00
  LSR                                     ; $BB02: 4A
  BCC $BB5F                               ; $BB03: 90 5A
  LDA $0402                               ; $BB05: AD 02 04
  JSR $F2AF                               ; $BB08: 20 AF F2
  LDA a:$0012                             ; $BB0B: AD 12 00
  BNE $BB36                               ; $BB0E: D0 26
  INC $0401                               ; $BB10: EE 01 04
  LDY #$03                                ; $BB13: A0 03
  LDX #$64                                ; $BB15: A2 64
  LDA ($00),Y                             ; $BB17: B1 00
  BNE $BB23                               ; $BB19: D0 08
  DEY                                     ; $BB1B: 88
  LDA ($00),Y                             ; $BB1C: B1 00
  CMP #$64                                ; $BB1E: C9 64
  BCS $BB23                               ; $BB20: B0 01
  TAX                                     ; $BB22: AA
Loc_BB23:
  JSR $BF89                               ; $BB23: 20 89 BF
  STX $0490                               ; $BB26: 8E 90 04
  LDA #$00                                ; $BB29: A9 00
  STA $0491                               ; $BB2B: 8D 91 04
  STA $0470                               ; $BB2E: 8D 70 04
  LDA #$5B                                ; $BB31: A9 5B
  JMP $F26D                               ; $BB33: 4C 6D F2
Loc_BB36:
  LDY #$10                                ; $BB36: A0 10
  LDA ($00),Y                             ; $BB38: B1 00
  BEQ $BB55                               ; $BB3A: F0 19
  LDA #$08                                ; $BB3C: A9 08
  STA $0401                               ; $BB3E: 8D 01 04
  LDA #$01                                ; $BB41: A9 01
  STA $0470                               ; $BB43: 8D 70 04
  LDA #$80                                ; $BB46: A9 80
  STA $0478                               ; $BB48: 8D 78 04
  LDA #$0F                                ; $BB4B: A9 0F
  STA $047C                               ; $BB4D: 8D 7C 04
  LDA #$5D                                ; $BB50: A9 5D
  JMP $F26D                               ; $BB52: 4C 6D F2
Loc_BB55:
  LDA #$0F                                ; $BB55: A9 0F
  STA $0401                               ; $BB57: 8D 01 04
  LDA #$AC                                ; $BB5A: A9 AC
  JMP $F26D                               ; $BB5C: 4C 6D F2
Loc_BB5F:
  LSR                                     ; $BB5F: 4A
  BCC $BB6F                               ; $BB60: 90 0D
  LDA #$05                                ; $BB62: A9 05
  STA $0401                               ; $BB64: 8D 01 04
  JSR $DD70                               ; $BB67: 20 70 DD
  LDA #$58                                ; $BB6A: A9 58
  JMP $F26D                               ; $BB6C: 4C 6D F2
Loc_BB6F:
  RTS                                     ; $BB6F: 60
; --- Data Region ---
  .byte $00,$01,$FF,$FF,$C8,$58,$C8,$A8,$00,$07,$00,$00,$80; $BB70: 00 01 FF FF C8 58 C8 A8 00 07 00 00 80
Loc_BB7D:  ; (dispatch callback target)
; --- Code Region ---
  JSR $DDAD                               ; $BB7D: 20 AD DD
  BCC $BBC5                               ; $BB80: 90 43
  LDA #$2F                                ; $BB82: A9 2F
  STA $031C                               ; $BB84: 8D 1C 03
  LDA #$23                                ; $BB87: A9 23
  STA $031D                               ; $BB89: 8D 1D 03
  LDA #$01                                ; $BB8C: A9 01
  JSR $DA04                               ; $BB8E: 20 04 DA
  LDA a:$0081                             ; $BB91: AD 81 00
  LSR                                     ; $BB94: 4A
  BCC $BBB4                               ; $BB95: 90 1D
  LDA $048E                               ; $BB97: AD 8E 04
  BEQ $BBC5                               ; $BB9A: F0 29
  JSR $BFA0                               ; $BB9C: 20 A0 BF
  INC $0401                               ; $BB9F: EE 01 04
  STA $048E                               ; $BBA2: 8D 8E 04
  LDA #$80                                ; $BBA5: A9 80
  STA $0478                               ; $BBA7: 8D 78 04
  LDA #$0F                                ; $BBAA: A9 0F
  STA $047C                               ; $BBAC: 8D 7C 04
  LDA #$5D                                ; $BBAF: A9 5D
  JMP $F26D                               ; $BBB1: 4C 6D F2
Loc_BBB4:
  LSR                                     ; $BBB4: 4A
  BCC $BBC5                               ; $BBB5: 90 0E
  DEC $0401                               ; $BBB7: CE 01 04
  JSR $DD70                               ; $BBBA: 20 70 DD
  JSR $DB87                               ; $BBBD: 20 87 DB
  LDA #$7E                                ; $BBC0: A9 7E
  JMP $F26D                               ; $BBC2: 4C 6D F2
Loc_BBC5:
  RTS                                     ; $BBC5: 60
Loc_BBC6:  ; (dispatch callback target)
  LDA $0478                               ; $BBC6: AD 78 04
  BNE $BC22                               ; $BBC9: D0 57
  JSR $D64A                               ; $BBCB: 20 4A D6
  LDA $047C                               ; $BBCE: AD 7C 04
  BPL $BC22                               ; $BBD1: 10 4F
  CMP #$90                                ; $BBD3: C9 90
  BEQ $BC12                               ; $BBD5: F0 3B
  CMP #$81                                ; $BBD7: C9 81
  BEQ $BBEC                               ; $BBD9: F0 11
  LDA $0481                               ; $BBDB: AD 81 04
  JSR $F2D7                               ; $BBDE: 20 D7 F2
  LDY #$03                                ; $BBE1: A0 03
  LDA ($00),Y                             ; $BBE3: B1 00
  CMP #$5A                                ; $BBE5: C9 5A
  BCS $BBFB                               ; $BBE7: B0 12
  JMP $BC23                               ; $BBE9: 4C 23 BC
Loc_BBEC:
  LDA #$0F                                ; $BBEC: A9 0F
  STA $047C                               ; $BBEE: 8D 7C 04
  LDA #$80                                ; $BBF1: A9 80
  STA $0478                               ; $BBF3: 8D 78 04
  LDA #$4A                                ; $BBF6: A9 4A
  JMP $F26D                               ; $BBF8: 4C 6D F2
Loc_BBFB:
  LDA $0481                               ; $BBFB: AD 81 04
  STA a:$0000                             ; $BBFE: 8D 00 00
  LDY #$3D                                ; $BC01: A0 3D
  JSR $EE07                               ; $BC03: 20 07 EE
; --- Data Region ---
  .byte $2A,$A0,$A9,$0E,$8D,$01,$04,$A9,$5E,$4C,$6D,$F2; $BC06: 2A A0 A9 0E 8D 01 04 A9 5E 4C 6D F2
Loc_BC12:
; --- Code Region ---
  LDA #$06                                ; $BC12: A9 06
  STA $0401                               ; $BC14: 8D 01 04
  JSR $DD70                               ; $BC17: 20 70 DD
  JSR $DB87                               ; $BC1A: 20 87 DB
  LDA #$7E                                ; $BC1D: A9 7E
  JMP $F26D                               ; $BC1F: 4C 6D F2
Loc_BC22:
  RTS                                     ; $BC22: 60
Loc_BC23:
  LDA $0402                               ; $BC23: AD 02 04
  JSR $DD4F                               ; $BC26: 20 4F DD
  JSR $F2D7                               ; $BC29: 20 D7 F2
  LDY #$04                                ; $BC2C: A0 04
  LDA ($00),Y                             ; $BC2E: B1 00
  STA a:$0000                             ; $BC30: 8D 00 00
  LDA $0470                               ; $BC33: AD 70 04
  BNE $BC8B                               ; $BC36: D0 53
  LDA #$00                                ; $BC38: A9 00
  STA a:$0001                             ; $BC3A: 8D 01 00
  STA a:$0002                             ; $BC3D: 8D 02 00
  STA a:$0004                             ; $BC40: 8D 04 00
  LDA #$0A                                ; $BC43: A9 0A
  STA a:$0003                             ; $BC45: 8D 03 00
  JSR $EAA5                               ; $BC48: 20 A5 EA
  LDA a:$0000                             ; $BC4B: AD 00 00
  STA $042C                               ; $BC4E: 8D 2C 04
  LDA $048E                               ; $BC51: AD 8E 04
  STA a:$0000                             ; $BC54: 8D 00 00
  LDA #$00                                ; $BC57: A9 00
  STA a:$0001                             ; $BC59: 8D 01 00
  STA a:$0002                             ; $BC5C: 8D 02 00
  STA a:$0004                             ; $BC5F: 8D 04 00
  LDA #$14                                ; $BC62: A9 14
  STA a:$0003                             ; $BC64: 8D 03 00
  JSR $EAA5                               ; $BC67: 20 A5 EA
  LDA a:$0000                             ; $BC6A: AD 00 00
  CLC                                     ; $BC6D: 18
  ADC $042C                               ; $BC6E: 6D 2C 04
  STA a:$0000                             ; $BC71: 8D 00 00
  LDA #$00                                ; $BC74: A9 00
  STA a:$0001                             ; $BC76: 8D 01 00
  STA a:$0002                             ; $BC79: 8D 02 00
  JSR $E850                               ; $BC7C: 20 50 E8
  CLC                                     ; $BC7F: 18
  ADC #$07                                ; $BC80: 69 07
  STA a:$0003                             ; $BC82: 8D 03 00
  JSR $EBE9                               ; $BC85: 20 E9 EB
  JMP $BCBF                               ; $BC88: 4C BF BC
Loc_BC8B:
  LDA #$00                                ; $BC8B: A9 00
  STA a:$0001                             ; $BC8D: 8D 01 00
  STA a:$0002                             ; $BC90: 8D 02 00
  STA a:$0004                             ; $BC93: 8D 04 00
  LDA #$0A                                ; $BC96: A9 0A
  STA a:$0003                             ; $BC98: 8D 03 00
  JSR $EAA5                               ; $BC9B: 20 A5 EA
  LDA a:$0000                             ; $BC9E: AD 00 00
  CLC                                     ; $BCA1: 18
  ADC #$03                                ; $BCA2: 69 03
  STA a:$0000                             ; $BCA4: 8D 00 00
  LDA #$00                                ; $BCA7: A9 00
  STA a:$0001                             ; $BCA9: 8D 01 00
  STA a:$0002                             ; $BCAC: 8D 02 00
Loc_BCAF:
  JSR $E856                               ; $BCAF: 20 56 E8
  CMP #$07                                ; $BCB2: C9 07
  BEQ $BCAF                               ; $BCB4: F0 F9
  CLC                                     ; $BCB6: 18
  ADC #$0A                                ; $BCB7: 69 0A
  STA a:$0003                             ; $BCB9: 8D 03 00
  JSR $EBE9                               ; $BCBC: 20 E9 EB
Loc_BCBF:
  LDA #$0A                                ; $BCBF: A9 0A
  STA a:$0003                             ; $BCC1: 8D 03 00
  LDA #$00                                ; $BCC4: A9 00
  STA a:$0004                             ; $BCC6: 8D 04 00
  JSR $DB72                               ; $BCC9: 20 72 DB
  LDA a:$0000                             ; $BCCC: AD 00 00
  STA $042C                               ; $BCCF: 8D 2C 04
  JSR $DD70                               ; $BCD2: 20 70 DD
  STA $042D                               ; $BCD5: 8D 2D 04
  STA $042E                               ; $BCD8: 8D 2E 04
  STA $046C                               ; $BCDB: 8D 6C 04
  INC $0401                               ; $BCDE: EE 01 04
  LDA #$29                                ; $BCE1: A9 29
  JMP $F26D                               ; $BCE3: 4C 6D F2
Loc_BCE6:  ; (dispatch callback target)
  JSR $D5BD                               ; $BCE6: 20 BD D5
  LDA a:$0013                             ; $BCE9: AD 13 00
  BEQ $BD66                               ; $BCEC: F0 78
  CMP #$FF                                ; $BCEE: C9 FF
  BEQ $BD61                               ; $BCF0: F0 6F
  LDA $0402                               ; $BCF2: AD 02 04
  JSR $F2AF                               ; $BCF5: 20 AF F2
  LDA $0470                               ; $BCF8: AD 70 04
  BNE $BD11                               ; $BCFB: D0 14
  LDY #$02                                ; $BCFD: A0 02
  LDA ($00),Y                             ; $BCFF: B1 00
  SEC                                     ; $BD01: 38
  SBC $048E                               ; $BD02: ED 8E 04
  STA ($00),Y                             ; $BD05: 91 00
  INY                                     ; $BD07: C8
  LDA ($00),Y                             ; $BD08: B1 00
  SBC #$00                                ; $BD0A: E9 00
  STA ($00),Y                             ; $BD0C: 91 00
  JMP $BD1A                               ; $BD0E: 4C 1A BD
Loc_BD11:
  LDY #$10                                ; $BD11: A0 10
  LDA ($00),Y                             ; $BD13: B1 00
  SEC                                     ; $BD15: 38
  SBC #$01                                ; $BD16: E9 01
  STA ($00),Y                             ; $BD18: 91 00
Loc_BD1A:
  LDA $0481                               ; $BD1A: AD 81 04
  JSR $F2D7                               ; $BD1D: 20 D7 F2
  LDY #$03                                ; $BD20: A0 03
  LDA ($00),Y                             ; $BD22: B1 00
  CLC                                     ; $BD24: 18
  ADC $042C                               ; $BD25: 6D 2C 04
  CMP #$64                                ; $BD28: C9 64
  BCC $BD3E                               ; $BD2A: 90 12
  STA a:$0002                             ; $BD2C: 8D 02 00
  LDA #$63                                ; $BD2F: A9 63
  SEC                                     ; $BD31: 38
  SBC a:$0002                             ; $BD32: ED 02 00
  CLC                                     ; $BD35: 18
  ADC $042C                               ; $BD36: 6D 2C 04
  STA $042C                               ; $BD39: 8D 2C 04
  LDA #$63                                ; $BD3C: A9 63
Loc_BD3E:
  STA ($00),Y                             ; $BD3E: 91 00
  LDA #$17                                ; $BD40: A9 17
  STA $04A2                               ; $BD42: 8D A2 04
  LDA #$29                                ; $BD45: A9 29
  STA $04D6                               ; $BD47: 8D D6 04
  LDA #$03                                ; $BD4A: A9 03
  STA a:$00A4                             ; $BD4C: 8D A4 00
  JSR $D568                               ; $BD4F: 20 68 D5
  LDA #$0C                                ; $BD52: A9 0C
  STA $0401                               ; $BD54: 8D 01 04
  LDA #$5F                                ; $BD57: A9 5F
  STA $0473                               ; $BD59: 8D 73 04
  LDA #$00                                ; $BD5C: A9 00
  JMP $F29B                               ; $BD5E: 4C 9B F2
Loc_BD61:
  LDA #$00                                ; $BD61: A9 00
  STA $0401                               ; $BD63: 8D 01 04
Loc_BD66:
  RTS                                     ; $BD66: 60
Loc_BD67:  ; (dispatch callback target)
  JSR $DDAD                               ; $BD67: 20 AD DD
  BCC $BDAB                               ; $BD6A: 90 3F
  LDA $0472                               ; $BD6C: AD 72 04
  BNE $BDAC                               ; $BD6F: D0 3B
  LDA #$2C                                ; $BD71: A9 2C
  STA $031C                               ; $BD73: 8D 1C 03
  LDA #$23                                ; $BD76: A9 23
  STA $031D                               ; $BD78: 8D 1D 03
  LDA #$01                                ; $BD7B: A9 01
  JSR $DA04                               ; $BD7D: 20 04 DA
  LDA a:$0081                             ; $BD80: AD 81 00
  LSR                                     ; $BD83: 4A
  BCC $BD9B                               ; $BD84: 90 15
  LDA $048E                               ; $BD86: AD 8E 04
  JSR $BFA0                               ; $BD89: 20 A0 BF
  STA $042C                               ; $BD8C: 8D 2C 04
  LDA #$00                                ; $BD8F: A9 00
  STA $042D                               ; $BD91: 8D 2D 04
  STA $042E                               ; $BD94: 8D 2E 04
  INC $0472                               ; $BD97: EE 72 04
  RTS                                     ; $BD9A: 60
Loc_BD9B:
  LSR                                     ; $BD9B: 4A
  BCC $BDAB                               ; $BD9C: 90 0D
  LDA #$05                                ; $BD9E: A9 05
  STA $0401                               ; $BDA0: 8D 01 04
  JSR $DD70                               ; $BDA3: 20 70 DD
  LDA #$58                                ; $BDA6: A9 58
  JMP $F26D                               ; $BDA8: 4C 6D F2
Loc_BDAB:
  RTS                                     ; $BDAB: 60
Loc_BDAC:
  CMP #$01                                ; $BDAC: C9 01
  BNE $BDC5                               ; $BDAE: D0 15
  JSR $DB87                               ; $BDB0: 20 87 DB
  LDA $049A                               ; $BDB3: AD 9A 04
  STA $0490                               ; $BDB6: 8D 90 04
  LDA $049B                               ; $BDB9: AD 9B 04
  STA $0491                               ; $BDBC: 8D 91 04
  INC $0472                               ; $BDBF: EE 72 04
  LDA $0472                               ; $BDC2: AD 72 04
Loc_BDC5:
  LDA #$36                                ; $BDC5: A9 36
  STA $031C                               ; $BDC7: 8D 1C 03
  LDA #$23                                ; $BDCA: A9 23
  STA $031D                               ; $BDCC: 8D 1D 03
  LDA #$01                                ; $BDCF: A9 01
  JSR $DA04                               ; $BDD1: 20 04 DA
  LDA a:$0081                             ; $BDD4: AD 81 00
  LSR                                     ; $BDD7: 4A
  BCC $BE01                               ; $BDD8: 90 27
  LDA $048E                               ; $BDDA: AD 8E 04
  JSR $BFA0                               ; $BDDD: 20 A0 BF
  STA $042F                               ; $BDE0: 8D 2F 04
  JSR $DD70                               ; $BDE3: 20 70 DD
  STA $0430                               ; $BDE6: 8D 30 04
  STA $0431                               ; $BDE9: 8D 31 04
  STA $046C                               ; $BDEC: 8D 6C 04
  LDA $042C                               ; $BDEF: AD 2C 04
  BNE $BDF9                               ; $BDF2: D0 05
  LDA $042F                               ; $BDF4: AD 2F 04
  BEQ $BDAB                               ; $BDF7: F0 B2
Loc_BDF9:
  INC $0401                               ; $BDF9: EE 01 04
  LDA #$29                                ; $BDFC: A9 29
  JMP $F26D                               ; $BDFE: 4C 6D F2
Loc_BE01:
  LSR                                     ; $BE01: 4A
  BCC $BDAB                               ; $BE02: 90 A7
  JSR $DB87                               ; $BE04: 20 87 DB
  LDA $0498                               ; $BE07: AD 98 04
  STA $0490                               ; $BE0A: 8D 90 04
  LDA $0499                               ; $BE0D: AD 99 04
  STA $0491                               ; $BE10: 8D 91 04
  LDA #$00                                ; $BE13: A9 00
  STA $0472                               ; $BE15: 8D 72 04
  RTS                                     ; $BE18: 60
Loc_BE19:  ; (dispatch callback target)
  JSR $D5BD                               ; $BE19: 20 BD D5
  LDA a:$0013                             ; $BE1C: AD 13 00
  BEQ $BE2A                               ; $BE1F: F0 09
  CMP #$FF                                ; $BE21: C9 FF
  BNE $BE2B                               ; $BE23: D0 06
  LDA #$00                                ; $BE25: A9 00
  STA $0401                               ; $BE27: 8D 01 04
Loc_BE2A:
  RTS                                     ; $BE2A: 60
Loc_BE2B:
  LDA $0402                               ; $BE2B: AD 02 04
  JSR $F2AF                               ; $BE2E: 20 AF F2
  LDY #$02                                ; $BE31: A0 02
  LDA ($00),Y                             ; $BE33: B1 00
  SEC                                     ; $BE35: 38
  SBC $042C                               ; $BE36: ED 2C 04
  STA ($00),Y                             ; $BE39: 91 00
  INY                                     ; $BE3B: C8
  LDA ($00),Y                             ; $BE3C: B1 00
  SBC $042D                               ; $BE3E: ED 2D 04
  STA ($00),Y                             ; $BE41: 91 00
  LDY #$04                                ; $BE43: A0 04
  LDA ($00),Y                             ; $BE45: B1 00
  SEC                                     ; $BE47: 38
  SBC $042F                               ; $BE48: ED 2F 04
  STA ($00),Y                             ; $BE4B: 91 00
  INY                                     ; $BE4D: C8
  LDA ($00),Y                             ; $BE4E: B1 00
  SBC $0430                               ; $BE50: ED 30 04
  STA ($00),Y                             ; $BE53: 91 00
  LDA $0402                               ; $BE55: AD 02 04
  JSR $F2AF                               ; $BE58: 20 AF F2
  LDY #$11                                ; $BE5B: A0 11
  LDA ($00),Y                             ; $BE5D: B1 00
  JSR $F2D7                               ; $BE5F: 20 D7 F2
  LDY #$04                                ; $BE62: A0 04
  LDA ($00),Y                             ; $BE64: B1 00
  STA a:$0003                             ; $BE66: 8D 03 00
  LDA $042C                               ; $BE69: AD 2C 04
  CLC                                     ; $BE6C: 18
  ADC $042F                               ; $BE6D: 6D 2F 04
  STA a:$0000                             ; $BE70: 8D 00 00
  LDA $042D                               ; $BE73: AD 2D 04
  ADC $0430                               ; $BE76: 6D 30 04
  STA a:$0001                             ; $BE79: 8D 01 00
  LDA #$00                                ; $BE7C: A9 00
  STA a:$0002                             ; $BE7E: 8D 02 00
  JSR $EBE9                               ; $BE81: 20 E9 EB
  LDA #$D0                                ; $BE84: A9 D0
  STA a:$0003                             ; $BE86: 8D 03 00
  LDA #$07                                ; $BE89: A9 07
  STA a:$0004                             ; $BE8B: 8D 04 00
  JSR $DB72                               ; $BE8E: 20 72 DB
Loc_BE91:
  JSR $E856                               ; $BE91: 20 56 E8
  CMP #$07                                ; $BE94: C9 07
  BEQ $BE91                               ; $BE96: F0 F9
  CLC                                     ; $BE98: 18
  ADC #$0A                                ; $BE99: 69 0A
  STA a:$0003                             ; $BE9B: 8D 03 00
  JSR $EBE9                               ; $BE9E: 20 E9 EB
  LDA #$0A                                ; $BEA1: A9 0A
  STA a:$0003                             ; $BEA3: 8D 03 00
  LDA #$00                                ; $BEA6: A9 00
  STA a:$0004                             ; $BEA8: 8D 04 00
  JSR $DB72                               ; $BEAB: 20 72 DB
  LDA a:$0000                             ; $BEAE: AD 00 00
  STA $042C                               ; $BEB1: 8D 2C 04
  LDA #$00                                ; $BEB4: A9 00
  STA $042D                               ; $BEB6: 8D 2D 04
  STA $042E                               ; $BEB9: 8D 2E 04
  LDA $0402                               ; $BEBC: AD 02 04
  JSR $F2AF                               ; $BEBF: 20 AF F2
  LDY #$0B                                ; $BEC2: A0 0B
  LDA ($00),Y                             ; $BEC4: B1 00
  CLC                                     ; $BEC6: 18
  ADC $042C                               ; $BEC7: 6D 2C 04
  STA a:$0002                             ; $BECA: 8D 02 00
  SEC                                     ; $BECD: 38
  SBC #$64                                ; $BECE: E9 64
  BCC $BEE4                               ; $BED0: 90 12
  STA a:$0002                             ; $BED2: 8D 02 00
  LDA $042C                               ; $BED5: AD 2C 04
  SEC                                     ; $BED8: 38
  SBC a:$0002                             ; $BED9: ED 02 00
  STA $042C                               ; $BEDC: 8D 2C 04
  LDA #$64                                ; $BEDF: A9 64
  STA a:$0002                             ; $BEE1: 8D 02 00
Loc_BEE4:
  LDA a:$0002                             ; $BEE4: AD 02 00
  STA ($00),Y                             ; $BEE7: 91 00
  LDA #$0C                                ; $BEE9: A9 0C
  STA $04A2                               ; $BEEB: 8D A2 04
  LDA #$29                                ; $BEEE: A9 29
  STA $04D6                               ; $BEF0: 8D D6 04
  LDA #$FF                                ; $BEF3: A9 FF
  STA $0481                               ; $BEF5: 8D 81 04
  JSR $D568                               ; $BEF8: 20 68 D5
  LDA #$0C                                ; $BEFB: A9 0C
  STA $0401                               ; $BEFD: 8D 01 04
  LDA #$5A                                ; $BF00: A9 5A
  JMP $F26D                               ; $BF02: 4C 6D F2
Loc_BF05:  ; (dispatch callback target)
  LDA $0140                               ; $BF05: AD 40 01
  BNE $BF18                               ; $BF08: D0 0E
  LDA $04A2                               ; $BF0A: AD A2 04
  STA $04A0                               ; $BF0D: 8D A0 04
  INC $0401                               ; $BF10: EE 01 04
  LDA #$60                                ; $BF13: A9 60
  STA $046C                               ; $BF15: 8D 6C 04
Loc_BF18:
  RTS                                     ; $BF18: 60
Loc_BF19:  ; (dispatch callback target)
  LDA $04A0                               ; $BF19: AD A0 04
  BNE $BF43                               ; $BF1C: D0 25
  LDA $0140                               ; $BF1E: AD 40 01
  BNE $BF43                               ; $BF21: D0 20
  LDA #$04                                ; $BF23: A9 04
  JSR $D58C                               ; $BF25: 20 8C D5
  INC $0401                               ; $BF28: EE 01 04
  LDA $0473                               ; $BF2B: AD 73 04
  BEQ $BF43                               ; $BF2E: F0 13
  LDA $0481                               ; $BF30: AD 81 04
  STA a:$0000                             ; $BF33: 8D 00 00
  LDY #$3D                                ; $BF36: A0 3D
  JSR $EE07                               ; $BF38: 20 07 EE
; --- Data Region ---
  .byte $2A,$A0,$AD,$73,$04,$4C,$6D,$F2   ; $BF3B: 2A A0 AD 73 04 4C 6D F2
Loc_BF43:
; --- Code Region ---
  RTS                                     ; $BF43: 60
Loc_BF44:  ; (dispatch callback target)
  JSR $DDAD                               ; $BF44: 20 AD DD
  BCC $BF5E                               ; $BF47: 90 15
  JSR $D543                               ; $BF49: 20 43 D5
  LDA a:$0081                             ; $BF4C: AD 81 00
  AND #$03                                ; $BF4F: 29 03
  BEQ $BF5E                               ; $BF51: F0 0B
  JSR $D568                               ; $BF53: 20 68 D5
  LDA #$00                                ; $BF56: A9 00
  STA $0400                               ; $BF58: 8D 00 04
  STA $0401                               ; $BF5B: 8D 01 04
Loc_BF5E:
  LDA $0481                               ; $BF5E: AD 81 04
  CMP #$FF                                ; $BF61: C9 FF
  BEQ $BF68                               ; $BF63: F0 03
  JSR $DD5E                               ; $BF65: 20 5E DD
Loc_BF68:
  RTS                                     ; $BF68: 60
Loc_BF69:  ; (dispatch callback target)
  JSR $DDAD                               ; $BF69: 20 AD DD
  BCC $BF88                               ; $BF6C: 90 1A
  JSR $D543                               ; $BF6E: 20 43 D5
  LDA a:$0081                             ; $BF71: AD 81 00
  AND #$03                                ; $BF74: 29 03
  BEQ $BF88                               ; $BF76: F0 10
  JSR $DD70                               ; $BF78: 20 70 DD
  JSR $DB87                               ; $BF7B: 20 87 DB
  LDA #$06                                ; $BF7E: A9 06
  STA $0401                               ; $BF80: 8D 01 04
  LDA #$7E                                ; $BF83: A9 7E
  JMP $F26D                               ; $BF85: 4C 6D F2
Loc_BF88:
  RTS                                     ; $BF88: 60
Loc_BF89:
  STX a:$0001                             ; $BF89: 8E 01 00
  LDA #$0A                                ; $BF8C: A9 0A
  STA a:$0003                             ; $BF8E: 8D 03 00
  LDA #$00                                ; $BF91: A9 00
  STA a:$0002                             ; $BF93: 8D 02 00
  STA a:$0004                             ; $BF96: 8D 04 00
  JSR $EA7C                               ; $BF99: 20 7C EA
  LDX a:$0001                             ; $BF9C: AE 01 00
  RTS                                     ; $BF9F: 60
Loc_BFA0:
  STA a:$0000                             ; $BFA0: 8D 00 00
  LDA #$00                                ; $BFA3: A9 00
  STA a:$0001                             ; $BFA5: 8D 01 00
  STA a:$0002                             ; $BFA8: 8D 02 00
  LDA #$0A                                ; $BFAB: A9 0A
  STA a:$0003                             ; $BFAD: 8D 03 00
  JSR $EBE9                               ; $BFB0: 20 E9 EB
  LDA a:$0006                             ; $BFB3: AD 06 00
  RTS                                     ; $BFB6: 60
Loc_BFB7:  ; (dispatch callback target)
  LDA $0401                               ; $BFB7: AD 01 04
  JSR $EADE                               ; $BFBA: 20 DE EA
; --- Data Region ---
  .byte $ED,$BF,$4D,$C0,$36,$C1,$C1,$C1,$C5,$C2,$39,$C3,$A0,$C3,$14,$C4; $BFBD: ED BF 4D C0 36 C1 C1 C1 C5 C2 39 C3 A0 C3 14 C4
  .byte $6A,$C4,$A8,$C4,$15,$C5,$47,$C5,$8F,$C5,$D7,$C5,$7F,$C6,$F8,$C6; $BFCD: 6A C4 A8 C4 15 C5 47 C5 8F C5 D7 C5 7F C6 F8 C6
  .byte $13,$C7,$21,$C7,$44,$C7,$6E,$C7,$1F,$C8,$0A,$C9,$D2,$C9,$EF,$C9; $BFDD: 13 C7 21 C7 44 C7 6E C7 1F C8 0A C9 D2 C9 EF C9
Loc_BFED:  ; (dispatch callback target)
  .byte $AD,$40,$01,$D0,$32,$AD,$04,$03,$C9,$FF,$D0,$2B,$EE,$01,$04,$20; $BFED: AD 40 01 D0 32 AD 04 03 C9 FF D0 2B EE 01 04 20
  .byte $70,$DD,$8D                       ; $BFFD: 70 DD 8D

.segment "CODE_BANK1C"

  .byte $73,$04,$A9,$0D,$8D,$BD,$00,$A9,$80,$8D,$40,$01,$A9,$04,$0D,$50; $C000: 73 04 A9 0D 8D BD 00 A9 80 8D 40 01 A9 04 0D 50
  .byte $01,$8D,$50,$01,$AC,$02,$04,$B9,$25,$C0,$8D,$70,$04,$A8,$B9,$43; $C010: 01 8D 50 01 AC 02 04 B9 25 C0 8D 70 04 A8 B9 43
  .byte $C0,$4C,$6D,$F2                   ; $C020: C0 4C 6D F2
Loc_C024:
; --- Code Region ---
  RTS                                     ; $C024: 60
; --- Data Region ---
  .byte $04,$01,$07,$08,$09,$01,$09,$05,$09,$01,$08,$07,$09,$07,$05,$09; $C025: 04 01 07 08 09 01 09 05 09 01 08 07 09 07 05 09
  .byte $04,$01,$02,$01,$07,$06,$03,$06,$05,$07,$09,$02,$07,$00,$AE,$AF; $C035: 04 01 02 01 07 06 03 06 05 07 09 02 07 00 AE AF
  .byte $B0,$B1,$B2,$B3,$B4,$B5,$B6,$6E   ; $C045: B0 B1 B2 B3 B4 B5 B6 6E
Loc_C04D:  ; (dispatch callback target)
; --- Code Region ---
  JSR $DCD0                               ; $C04D: 20 D0 DC
  LDA a:$0013                             ; $C050: AD 13 00
  STA a:$0010                             ; $C053: 8D 10 00
  LDA a:$0014                             ; $C056: AD 14 00
  STA a:$0011                             ; $C059: 8D 11 00
  LDA #$09                                ; $C05C: A9 09
  STA a:$0000                             ; $C05E: 8D 00 00
  LDA #$C1                                ; $C061: A9 C1
  STA a:$0001                             ; $C063: 8D 01 00
  LDA a:$0012                             ; $C066: AD 12 00
  JSR $EDF5                               ; $C069: 20 F5 ED
  JSR $DDAD                               ; $C06C: 20 AD DD
  BCC $C08A                               ; $C06F: 90 19
  LDA a:$0081                             ; $C071: AD 81 00
  LSR                                     ; $C074: 4A
  BCS $C08B                               ; $C075: B0 14
  LSR                                     ; $C077: 4A
  BCC $C08A                               ; $C078: 90 10
  JSR $D568                               ; $C07A: 20 68 D5
  LDA #$01                                ; $C07D: A9 01
  STA $0400                               ; $C07F: 8D 00 04
  LDA #$00                                ; $C082: A9 00
  STA $0401                               ; $C084: 8D 01 04
  JSR $F26D                               ; $C087: 20 6D F2
Loc_C08A:
  RTS                                     ; $C08A: 60
Loc_C08B:
  JSR $DD70                               ; $C08B: 20 70 DD
  LDA $0470                               ; $C08E: AD 70 04
  ASL                                     ; $C091: 0A
  ASL                                     ; $C092: 0A
  CLC                                     ; $C093: 18
  ADC a:$0012                             ; $C094: 6D 12 00
  TAY                                     ; $C097: A8
  LDA $C10E,Y                             ; $C098: B9 0E C1
  BEQ $C0B9                               ; $C09B: F0 1C
  CMP #$01                                ; $C09D: C9 01
  BEQ $C0CD                               ; $C09F: F0 2C
  CMP #$02                                ; $C0A1: C9 02
  BEQ $C0E1                               ; $C0A3: F0 3C
  LDA #$02                                ; $C0A5: A9 02
  STA $0401                               ; $C0A7: 8D 01 04
  LDA #$21                                ; $C0AA: A9 21
  STA $04A2                               ; $C0AC: 8D A2 04
  LDA #$2E                                ; $C0AF: A9 2E
  STA $04D6                               ; $C0B1: 8D D6 04
  LDA #$6F                                ; $C0B4: A9 6F
  JMP $F26D                               ; $C0B6: 4C 6D F2
Loc_C0B9:
  LDA #$12                                ; $C0B9: A9 12
  STA $0401                               ; $C0BB: 8D 01 04
  LDA #$80                                ; $C0BE: A9 80
  STA $0478                               ; $C0C0: 8D 78 04
  LDA #$0F                                ; $C0C3: A9 0F
  STA $047C                               ; $C0C5: 8D 7C 04
  LDA #$A4                                ; $C0C8: A9 A4
  JMP $F26D                               ; $C0CA: 4C 6D F2
Loc_C0CD:
  LDA #$0E                                ; $C0CD: A9 0E
  STA $0401                               ; $C0CF: 8D 01 04
  LDA #$80                                ; $C0D2: A9 80
  STA $0478                               ; $C0D4: 8D 78 04
  LDA #$0F                                ; $C0D7: A9 0F
  STA $047C                               ; $C0D9: 8D 7C 04
  LDA #$78                                ; $C0DC: A9 78
  JMP $F26D                               ; $C0DE: 4C 6D F2
Loc_C0E1:
  JSR $DC7C                               ; $C0E1: 20 7C DC
  LDA $0151                               ; $C0E4: AD 51 01
  CMP #$FF                                ; $C0E7: C9 FF
  BEQ $C0FF                               ; $C0E9: F0 14
  LDA #$0A                                ; $C0EB: A9 0A
  STA $0401                               ; $C0ED: 8D 01 04
  LDA #$80                                ; $C0F0: A9 80
  STA $0478                               ; $C0F2: 8D 78 04
  LDA #$FF                                ; $C0F5: A9 FF
  STA $047C                               ; $C0F7: 8D 7C 04
  LDA #$77                                ; $C0FA: A9 77
  JMP $F26D                               ; $C0FC: 4C 6D F2
Loc_C0FF:
  LDA #$11                                ; $C0FF: A9 11
  STA $0401                               ; $C101: 8D 01 04
  LDA #$AD                                ; $C104: A9 AD
  JMP $F26D                               ; $C106: 4C 6D F2
; --- Data Region ---
  .byte $00,$04,$00,$00,$80,$00,$01,$FF,$FF,$00,$02,$FF,$FF,$00,$03,$FF; $C109: 00 04 00 00 80 00 01 FF FF 00 02 FF FF 00 03 FF
  .byte $FF,$01,$02,$FF,$FF,$01,$03,$FF,$FF,$02,$03,$FF,$FF,$00,$01,$03; $C119: FF 01 02 FF FF 01 03 FF FF 02 03 FF FF 00 01 03
  .byte $FF,$00,$02,$03,$FF,$01,$02,$03,$FF,$00,$01,$02,$03; $C129: FF 00 02 03 FF 01 02 03 FF 00 01 02 03
Loc_C136:  ; (dispatch callback target)
; --- Code Region ---
  LDA #$B4                                ; $C136: A9 B4
  STA a:$0010                             ; $C138: 8D 10 00
Loc_C13B:
  LDA #$C1                                ; $C13B: A9 C1
  STA a:$0011                             ; $C13D: 8D 11 00
  LDA #$00                                ; $C140: A9 00
  STA a:$0012                             ; $C142: 8D 12 00
  JSR $ED1E                               ; $C145: 20 1E ED
  LDA #$B8                                ; $C148: A9 B8
  STA a:$0010                             ; $C14A: 8D 10 00
  LDA #$C1                                ; $C14D: A9 C1
  STA a:$0011                             ; $C14F: 8D 11 00
  LDA #$BC                                ; $C152: A9 BC
  STA a:$0000                             ; $C154: 8D 00 00
  LDA #$C1                                ; $C157: A9 C1
  STA a:$0001                             ; $C159: 8D 01 00
  LDA a:$0012                             ; $C15C: AD 12 00
  JSR $EDF5                               ; $C15F: 20 F5 ED
  JSR $DDAD                               ; $C162: 20 AD DD
  BCC $C1B3                               ; $C165: 90 4C
  LDA a:$0081                             ; $C167: AD 81 00
  LSR                                     ; $C16A: 4A
  BCC $C1AB                               ; $C16B: 90 3E
  JSR $DB87                               ; $C16D: 20 87 DB
  LDA a:$0012                             ; $C170: AD 12 00
  BNE $C180                               ; $C173: D0 0B
  INC $0401                               ; $C175: EE 01 04
  JSR $DD70                               ; $C178: 20 70 DD
  LDA #$72                                ; $C17B: A9 72
  JMP $F26D                               ; $C17D: 4C 6D F2
Loc_C180:
  LDA $0402                               ; $C180: AD 02 04
  JSR $F2AF                               ; $C183: 20 AF F2
  LDY #$10                                ; $C186: A0 10
  LDA ($00),Y                             ; $C188: B1 00
  BEQ $C1A1                               ; $C18A: F0 15
  STA $0490                               ; $C18C: 8D 90 04
  LDA #$00                                ; $C18F: A9 00
  STA $0491                               ; $C191: 8D 91 04
  LDA #$08                                ; $C194: A9 08
  STA $0401                               ; $C196: 8D 01 04
  JSR $DB87                               ; $C199: 20 87 DB
  LDA #$70                                ; $C19C: A9 70
  JMP $F26D                               ; $C19E: 4C 6D F2
Loc_C1A1:
  LDA #$11                                ; $C1A1: A9 11
  STA $0401                               ; $C1A3: 8D 01 04
  LDA #$AC                                ; $C1A6: A9 AC
  JMP $F26D                               ; $C1A8: 4C 6D F2
Loc_C1AB:
  LSR                                     ; $C1AB: 4A
  BCC $C1B3                               ; $C1AC: 90 05
  LDA #$00                                ; $C1AE: A9 00
  STA $0401                               ; $C1B0: 8D 01 04
Loc_C1B3:
  RTS                                     ; $C1B3: 60
; --- Data Region ---
  .byte $00,$01,$FF,$FF,$C8,$58,$C8,$A8,$00,$07,$00,$00,$80; $C1B4: 00 01 FF FF C8 58 C8 A8 00 07 00 00 80
Loc_C1C1:  ; (dispatch callback target)
; --- Code Region ---
  LDA #$B8                                ; $C1C1: A9 B8
  STA a:$0010                             ; $C1C3: 8D 10 00
  LDA #$C2                                ; $C1C6: A9 C2
  STA a:$0011                             ; $C1C8: 8D 11 00
  LDA #$00                                ; $C1CB: A9 00
  STA a:$0012                             ; $C1CD: 8D 12 00
  JSR $ED1E                               ; $C1D0: 20 1E ED
  LDA #$BC                                ; $C1D3: A9 BC
  STA a:$0010                             ; $C1D5: 8D 10 00
  LDA #$C2                                ; $C1D8: A9 C2
  STA a:$0011                             ; $C1DA: 8D 11 00
  LDA #$C0                                ; $C1DD: A9 C0
  STA a:$0000                             ; $C1DF: 8D 00 00
  LDA #$C2                                ; $C1E2: A9 C2
  STA a:$0001                             ; $C1E4: 8D 01 00
  LDA a:$0012                             ; $C1E7: AD 12 00
  JSR $EDF5                               ; $C1EA: 20 F5 ED
  JSR $DDAD                               ; $C1ED: 20 AD DD
  BCC $C206                               ; $C1F0: 90 14
  LDA a:$0081                             ; $C1F2: AD 81 00
  LSR                                     ; $C1F5: 4A
  BCS $C207                               ; $C1F6: B0 0F
  LSR                                     ; $C1F8: 4A
  BCC $C206                               ; $C1F9: 90 0B
  DEC $0401                               ; $C1FB: CE 01 04
  JSR $DD70                               ; $C1FE: 20 70 DD
  LDA #$6F                                ; $C201: A9 6F
  JMP $F26D                               ; $C203: 4C 6D F2
Loc_C206:
  RTS                                     ; $C206: 60
Loc_C207:
  JSR $DB87                               ; $C207: 20 87 DB
  LDY #$30                                ; $C20A: A0 30
  JSR $F25F                               ; $C20C: 20 5F F2
  LDA $0402                               ; $C20F: AD 02 04
  ASL                                     ; $C212: 0A
  CLC                                     ; $C213: 18
  ADC #$C0                                ; $C214: 69 C0
  STA a:$0002                             ; $C216: 8D 02 00
  LDA #$8F                                ; $C219: A9 8F
  ADC #$00                                ; $C21B: 69 00
  STA a:$0003                             ; $C21D: 8D 03 00
  LDA $0402                               ; $C220: AD 02 04
  JSR $F2AF                               ; $C223: 20 AF F2
  LDA a:$0012                             ; $C226: AD 12 00
  BEQ $C254                               ; $C229: F0 29
  LDY #$04                                ; $C22B: A0 04
  LDA ($00),Y                             ; $C22D: B1 00
  STA $0490                               ; $C22F: 8D 90 04
  INY                                     ; $C232: C8
  LDA ($00),Y                             ; $C233: B1 00
  STA $0491                               ; $C235: 8D 91 04
  LDY #$00                                ; $C238: A0 00
  LDA ($02),Y                             ; $C23A: B1 02
  STA $0492                               ; $C23C: 8D 92 04
  STA $042C                               ; $C23F: 8D 2C 04
  LDA #$00                                ; $C242: A9 00
  STA $042D                               ; $C244: 8D 2D 04
  STA $042E                               ; $C247: 8D 2E 04
  LDA #$06                                ; $C24A: A9 06
  STA $0401                               ; $C24C: 8D 01 04
  LDA #$74                                ; $C24F: A9 74
  JMP $F26D                               ; $C251: 4C 6D F2
Loc_C254:
  LDY #$01                                ; $C254: A0 01
  LDA ($02),Y                             ; $C256: B1 02
  STA $0492                               ; $C258: 8D 92 04
  STA $042C                               ; $C25B: 8D 2C 04
  LDA #$00                                ; $C25E: A9 00
  STA $042D                               ; $C260: 8D 2D 04
  STA $042E                               ; $C263: 8D 2E 04
  LDY #$02                                ; $C266: A0 02
  LDA ($00),Y                             ; $C268: B1 00
  STA a:$0002                             ; $C26A: 8D 02 00
  INY                                     ; $C26D: C8
  LDA ($00),Y                             ; $C26E: B1 00
  STA a:$0001                             ; $C270: 8D 01 00
  LDA a:$0002                             ; $C273: AD 02 00
  STA a:$0000                             ; $C276: 8D 00 00
  LDA #$00                                ; $C279: A9 00
  STA a:$0002                             ; $C27B: 8D 02 00
  LDA $0492                               ; $C27E: AD 92 04
  STA a:$0003                             ; $C281: 8D 03 00
  JSR $EBE9                               ; $C284: 20 E9 EB
  LDA #$64                                ; $C287: A9 64
  STA a:$0003                             ; $C289: 8D 03 00
  LDA #$00                                ; $C28C: A9 00
  STA a:$0004                             ; $C28E: 8D 04 00
  JSR $DB72                               ; $C291: 20 72 DB
  LDA a:$0005                             ; $C294: AD 05 00
  BEQ $C29E                               ; $C297: F0 05
  LDA #$01                                ; $C299: A9 01
  STA a:$0005                             ; $C29B: 8D 05 00
Loc_C29E:
  LDA a:$0000                             ; $C29E: AD 00 00
  CLC                                     ; $C2A1: 18
  ADC a:$0005                             ; $C2A2: 6D 05 00
  STA $0490                               ; $C2A5: 8D 90 04
  LDA a:$0001                             ; $C2A8: AD 01 00
  ADC #$00                                ; $C2AB: 69 00
  STA $0491                               ; $C2AD: 8D 91 04
  INC $0401                               ; $C2B0: EE 01 04
  LDA #$73                                ; $C2B3: A9 73
  JMP $F26D                               ; $C2B5: 4C 6D F2
; --- Data Region ---
  .byte $00,$01,$FF,$FF,$C8,$58,$C8,$A8,$00,$07,$00,$00,$80; $C2B8: 00 01 FF FF C8 58 C8 A8 00 07 00 00 80
Loc_C2C5:  ; (dispatch callback target)
; --- Code Region ---
  JSR $DDAD                               ; $C2C5: 20 AD DD
  BCC $C2EB                               ; $C2C8: 90 21
  LDA #$50                                ; $C2CA: A9 50
  STA $031C                               ; $C2CC: 8D 1C 03
  LDA #$23                                ; $C2CF: A9 23
  STA $031D                               ; $C2D1: 8D 1D 03
  JSR $DA02                               ; $C2D4: 20 02 DA
  LDA a:$0081                             ; $C2D7: AD 81 00
  LSR                                     ; $C2DA: 4A
  BCS $C2EC                               ; $C2DB: B0 0F
  LSR                                     ; $C2DD: 4A
  BCC $C2EB                               ; $C2DE: 90 0B
  DEC $0401                               ; $C2E0: CE 01 04
  JSR $DD70                               ; $C2E3: 20 70 DD
  LDA #$72                                ; $C2E6: A9 72
  JMP $F26D                               ; $C2E8: 4C 6D F2
Loc_C2EB:
  RTS                                     ; $C2EB: 60
Loc_C2EC:
  LDA $048E                               ; $C2EC: AD 8E 04
  STA a:$0000                             ; $C2EF: 8D 00 00
  LDA $048F                               ; $C2F2: AD 8F 04
  STA a:$0001                             ; $C2F5: 8D 01 00
  BNE $C2FF                               ; $C2F8: D0 05
  LDA a:$0000                             ; $C2FA: AD 00 00
  BEQ $C2EB                               ; $C2FD: F0 EC
Loc_C2FF:
  LDA #$00                                ; $C2FF: A9 00
  STA a:$0002                             ; $C301: 8D 02 00
  LDA #$64                                ; $C304: A9 64
  STA a:$0003                             ; $C306: 8D 03 00
  JSR $EBE9                               ; $C309: 20 E9 EB
  LDA $0492                               ; $C30C: AD 92 04
  STA a:$0003                             ; $C30F: 8D 03 00
  LDA #$00                                ; $C312: A9 00
  STA a:$0004                             ; $C314: 8D 04 00
  JSR $DB72                               ; $C317: 20 72 DB
  LDA a:$0000                             ; $C31A: AD 00 00
  STA $042C                               ; $C31D: 8D 2C 04
  LDA a:$0001                             ; $C320: AD 01 00
  STA $042D                               ; $C323: 8D 2D 04
  LDA #$00                                ; $C326: A9 00
  STA $042E                               ; $C328: 8D 2E 04
  INC $0401                               ; $C32B: EE 01 04
  JSR $DD70                               ; $C32E: 20 70 DD
  STA $046C                               ; $C331: 8D 6C 04
  LDA #$29                                ; $C334: A9 29
  JMP $F26D                               ; $C336: 4C 6D F2
Loc_C339:  ; (dispatch callback target)
  JSR $D5BD                               ; $C339: 20 BD D5
  LDA a:$0013                             ; $C33C: AD 13 00
  BEQ $C39F                               ; $C33F: F0 5E
  CMP #$FF                                ; $C341: C9 FF
  BEQ $C39A                               ; $C343: F0 55
  LDA $0402                               ; $C345: AD 02 04
  JSR $F2AF                               ; $C348: 20 AF F2
  LDY #$02                                ; $C34B: A0 02
  LDA ($00),Y                             ; $C34D: B1 00
  SEC                                     ; $C34F: 38
  SBC $042C                               ; $C350: ED 2C 04
  STA ($00),Y                             ; $C353: 91 00
  INY                                     ; $C355: C8
  LDA ($00),Y                             ; $C356: B1 00
  SBC $042D                               ; $C358: ED 2D 04
  BCS $C363                               ; $C35B: B0 06
  LDA #$00                                ; $C35D: A9 00
  DEY                                     ; $C35F: 88
  STA ($00),Y                             ; $C360: 91 00
  INY                                     ; $C362: C8
Loc_C363:
  STA ($00),Y                             ; $C363: 91 00
  LDY #$04                                ; $C365: A0 04
  LDA ($00),Y                             ; $C367: B1 00
  CLC                                     ; $C369: 18
  ADC $048E                               ; $C36A: 6D 8E 04
  STA ($00),Y                             ; $C36D: 91 00
  INY                                     ; $C36F: C8
  LDA ($00),Y                             ; $C370: B1 00
  ADC $048F                               ; $C372: 6D 8F 04
  STA ($00),Y                             ; $C375: 91 00
  LDY #$04                                ; $C377: A0 04
  JSR $DDDC                               ; $C379: 20 DC DD
  LDA $048E                               ; $C37C: AD 8E 04
  STA $042C                               ; $C37F: 8D 2C 04
  LDA $048F                               ; $C382: AD 8F 04
  STA $042D                               ; $C385: 8D 2D 04
  LDA #$00                                ; $C388: A9 00
  STA $042E                               ; $C38A: 8D 2E 04
  JSR $D568                               ; $C38D: 20 68 D5
  LDA #$0F                                ; $C390: A9 0F
  STA $0401                               ; $C392: 8D 01 04
  LDA #$75                                ; $C395: A9 75
  JMP $F26D                               ; $C397: 4C 6D F2
Loc_C39A:
  LDA #$00                                ; $C39A: A9 00
  STA $0401                               ; $C39C: 8D 01 04
Loc_C39F:
  RTS                                     ; $C39F: 60
Loc_C3A0:  ; (dispatch callback target)
  JSR $DDAD                               ; $C3A0: 20 AD DD
  BCC $C3C8                               ; $C3A3: 90 23
  LDA #$50                                ; $C3A5: A9 50
  STA $031C                               ; $C3A7: 8D 1C 03
  LDA #$23                                ; $C3AA: A9 23
  STA $031D                               ; $C3AC: 8D 1D 03
  JSR $DA02                               ; $C3AF: 20 02 DA
  LDA a:$0081                             ; $C3B2: AD 81 00
  LSR                                     ; $C3B5: 4A
  BCS $C3C9                               ; $C3B6: B0 11
  LSR                                     ; $C3B8: 4A
  BCC $C3C8                               ; $C3B9: 90 0D
  LDA #$03                                ; $C3BB: A9 03
  STA $0401                               ; $C3BD: 8D 01 04
  JSR $DD70                               ; $C3C0: 20 70 DD
  LDA #$72                                ; $C3C3: A9 72
  JMP $F26D                               ; $C3C5: 4C 6D F2
Loc_C3C8:
  RTS                                     ; $C3C8: 60
Loc_C3C9:
  LDA $048E                               ; $C3C9: AD 8E 04
  STA a:$0000                             ; $C3CC: 8D 00 00
  LDA $048F                               ; $C3CF: AD 8F 04
  STA a:$0001                             ; $C3D2: 8D 01 00
  BNE $C3DC                               ; $C3D5: D0 05
  LDA a:$0000                             ; $C3D7: AD 00 00
  BEQ $C3C8                               ; $C3DA: F0 EC
Loc_C3DC:
  LDA #$00                                ; $C3DC: A9 00
  STA a:$0002                             ; $C3DE: 8D 02 00
  LDA $0492                               ; $C3E1: AD 92 04
  STA a:$0003                             ; $C3E4: 8D 03 00
  JSR $EBE9                               ; $C3E7: 20 E9 EB
  LDA #$64                                ; $C3EA: A9 64
  STA a:$0003                             ; $C3EC: 8D 03 00
  LDA #$00                                ; $C3EF: A9 00
  STA a:$0004                             ; $C3F1: 8D 04 00
  JSR $DB72                               ; $C3F4: 20 72 DB
  LDA a:$0000                             ; $C3F7: AD 00 00
  STA $042C                               ; $C3FA: 8D 2C 04
  LDA a:$0001                             ; $C3FD: AD 01 00
  STA $042D                               ; $C400: 8D 2D 04
  JSR $DD70                               ; $C403: 20 70 DD
  STA $042E                               ; $C406: 8D 2E 04
  STA $046C                               ; $C409: 8D 6C 04
  INC $0401                               ; $C40C: EE 01 04
  LDA #$29                                ; $C40F: A9 29
  JMP $F26D                               ; $C411: 4C 6D F2
Loc_C414:  ; (dispatch callback target)
  JSR $D5BD                               ; $C414: 20 BD D5
  LDA a:$0013                             ; $C417: AD 13 00
  BEQ $C469                               ; $C41A: F0 4D
  CMP #$FF                                ; $C41C: C9 FF
  BEQ $C464                               ; $C41E: F0 44
  LDA $0402                               ; $C420: AD 02 04
  JSR $F2AF                               ; $C423: 20 AF F2
  LDY #$04                                ; $C426: A0 04
  LDA ($00),Y                             ; $C428: B1 00
  SEC                                     ; $C42A: 38
  SBC $048E                               ; $C42B: ED 8E 04
  STA ($00),Y                             ; $C42E: 91 00
  INY                                     ; $C430: C8
  LDA ($00),Y                             ; $C431: B1 00
  SBC $048F                               ; $C433: ED 8F 04
  BCS $C43E                               ; $C436: B0 06
  LDA #$00                                ; $C438: A9 00
  DEY                                     ; $C43A: 88
  STA ($00),Y                             ; $C43B: 91 00
  INY                                     ; $C43D: C8
Loc_C43E:
  STA ($00),Y                             ; $C43E: 91 00
  LDY #$02                                ; $C440: A0 02
  LDA ($00),Y                             ; $C442: B1 00
  CLC                                     ; $C444: 18
  ADC $042C                               ; $C445: 6D 2C 04
  STA ($00),Y                             ; $C448: 91 00
  INY                                     ; $C44A: C8
  LDA ($00),Y                             ; $C44B: B1 00
  ADC $042D                               ; $C44D: 6D 2D 04
  STA ($00),Y                             ; $C450: 91 00
  LDY #$02                                ; $C452: A0 02
  JSR $DDDC                               ; $C454: 20 DC DD
  JSR $D568                               ; $C457: 20 68 D5
  LDA #$0F                                ; $C45A: A9 0F
  STA $0401                               ; $C45C: 8D 01 04
  LDA #$76                                ; $C45F: A9 76
  JMP $F26D                               ; $C461: 4C 6D F2
Loc_C464:
  LDA #$00                                ; $C464: A9 00
  STA $0401                               ; $C466: 8D 01 04
Loc_C469:
  RTS                                     ; $C469: 60
Loc_C46A:  ; (dispatch callback target)
  JSR $DDAD                               ; $C46A: 20 AD DD
  BCC $C4A7                               ; $C46D: 90 38
  LDA #$30                                ; $C46F: A9 30
  STA $031C                               ; $C471: 8D 1C 03
  LDA #$23                                ; $C474: A9 23
  STA $031D                               ; $C476: 8D 1D 03
  LDA #$01                                ; $C479: A9 01
  JSR $DA04                               ; $C47B: 20 04 DA
  LDA a:$0081                             ; $C47E: AD 81 00
  LSR                                     ; $C481: 4A
  BCC $C497                               ; $C482: 90 13
  LDA $048E                               ; $C484: AD 8E 04
  BEQ $C4A7                               ; $C487: F0 1E
  INC $0401                               ; $C489: EE 01 04
  JSR $DD70                               ; $C48C: 20 70 DD
  STA $046C                               ; $C48F: 8D 6C 04
  LDA #$29                                ; $C492: A9 29
  JMP $F26D                               ; $C494: 4C 6D F2
Loc_C497:
  LSR                                     ; $C497: 4A
  BCC $C4A7                               ; $C498: 90 0D
  LDA #$02                                ; $C49A: A9 02
  STA $0401                               ; $C49C: 8D 01 04
  JSR $DD70                               ; $C49F: 20 70 DD
  LDA #$6F                                ; $C4A2: A9 6F
  JMP $F26D                               ; $C4A4: 4C 6D F2
Loc_C4A7:
  RTS                                     ; $C4A7: 60
Loc_C4A8:  ; (dispatch callback target)
  JSR $D5BD                               ; $C4A8: 20 BD D5
  LDA a:$0013                             ; $C4AB: AD 13 00
  BEQ $C514                               ; $C4AE: F0 64
  CMP #$FF                                ; $C4B0: C9 FF
  BEQ $C50F                               ; $C4B2: F0 5B
  LDA #$64                                ; $C4B4: A9 64
  STA a:$0003                             ; $C4B6: 8D 03 00
  LDA $048E                               ; $C4B9: AD 8E 04
  STA a:$0000                             ; $C4BC: 8D 00 00
  LDA #$00                                ; $C4BF: A9 00
  STA a:$0001                             ; $C4C1: 8D 01 00
  STA a:$0002                             ; $C4C4: 8D 02 00
  JSR $EBE9                               ; $C4C7: 20 E9 EB
  LDA a:$0006                             ; $C4CA: AD 06 00
  STA $042C                               ; $C4CD: 8D 2C 04
  LDA a:$0007                             ; $C4D0: AD 07 00
  STA $042D                               ; $C4D3: 8D 2D 04
  LDA #$00                                ; $C4D6: A9 00
  STA $042E                               ; $C4D8: 8D 2E 04
  LDA $0402                               ; $C4DB: AD 02 04
  JSR $F2AF                               ; $C4DE: 20 AF F2
  LDY #$10                                ; $C4E1: A0 10
  LDA ($00),Y                             ; $C4E3: B1 00
  SEC                                     ; $C4E5: 38
  SBC $048E                               ; $C4E6: ED 8E 04
  STA ($00),Y                             ; $C4E9: 91 00
  LDY #$02                                ; $C4EB: A0 02
  LDA ($00),Y                             ; $C4ED: B1 00
  CLC                                     ; $C4EF: 18
  ADC $042C                               ; $C4F0: 6D 2C 04
  STA ($00),Y                             ; $C4F3: 91 00
  INY                                     ; $C4F5: C8
  LDA ($00),Y                             ; $C4F6: B1 00
  ADC $042D                               ; $C4F8: 6D 2D 04
  STA ($00),Y                             ; $C4FB: 91 00
  LDY #$02                                ; $C4FD: A0 02
  JSR $DDDC                               ; $C4FF: 20 DC DD
  JSR $D568                               ; $C502: 20 68 D5
  LDA #$0F                                ; $C505: A9 0F
  STA $0401                               ; $C507: 8D 01 04
  LDA #$76                                ; $C50A: A9 76
  JMP $F26D                               ; $C50C: 4C 6D F2
Loc_C50F:
  LDA #$00                                ; $C50F: A9 00
  STA $0401                               ; $C511: 8D 01 04
Loc_C514:
  RTS                                     ; $C514: 60
Loc_C515:  ; (dispatch callback target)
  LDA $0478                               ; $C515: AD 78 04
  BNE $C546                               ; $C518: D0 2C
  JSR $D64A                               ; $C51A: 20 4A D6
  LDA $047C                               ; $C51D: AD 7C 04
  BPL $C546                               ; $C520: 10 24
  CMP #$90                                ; $C522: C9 90
  BEQ $C541                               ; $C524: F0 1B
  JSR $D7A8                               ; $C526: 20 A8 D7
  LDA #$00                                ; $C529: A9 00
  STA $0470                               ; $C52B: 8D 70 04
  STA $042D                               ; $C52E: 8D 2D 04
  STA $042E                               ; $C531: 8D 2E 04
  LDA #$32                                ; $C534: A9 32
  STA $042C                               ; $C536: 8D 2C 04
  INC $0401                               ; $C539: EE 01 04
  LDA #$28                                ; $C53C: A9 28
  JMP $F26D                               ; $C53E: 4C 6D F2
Loc_C541:
  LDA #$00                                ; $C541: A9 00
  STA $0401                               ; $C543: 8D 01 04
Loc_C546:
  RTS                                     ; $C546: 60
Loc_C547:  ; (dispatch callback target)
  JSR $DDAD                               ; $C547: 20 AD DD
  BCC $C58E                               ; $C54A: 90 42
  JSR $D543                               ; $C54C: 20 43 D5
  LDA a:$0081                             ; $C54F: AD 81 00
  LSR                                     ; $C552: 4A
  BCC $C581                               ; $C553: 90 2C
  LDA $0402                               ; $C555: AD 02 04
  JSR $F2AF                               ; $C558: 20 AF F2
  LDY #$02                                ; $C55B: A0 02
  LDA ($00),Y                             ; $C55D: B1 00
  CMP $042C                               ; $C55F: CD 2C 04
  BCS $C569                               ; $C562: B0 05
  INY                                     ; $C564: C8
  LDA ($00),Y                             ; $C565: B1 00
  BEQ $C577                               ; $C567: F0 0E
Loc_C569:
  INC $0401                               ; $C569: EE 01 04
  JSR $DD70                               ; $C56C: 20 70 DD
  STA $046C                               ; $C56F: 8D 6C 04
  LDA #$29                                ; $C572: A9 29
  JMP $F26D                               ; $C574: 4C 6D F2
Loc_C577:
  LDA #$11                                ; $C577: A9 11
  STA $0401                               ; $C579: 8D 01 04
  LDA #$2A                                ; $C57C: A9 2A
  JMP $F26D                               ; $C57E: 4C 6D F2
Loc_C581:
  LSR                                     ; $C581: 4A
  BCC $C58E                               ; $C582: 90 0A
  JSR $DDAD                               ; $C584: 20 AD DD
  BCC $C58E                               ; $C587: 90 05
  LDA #$00                                ; $C589: A9 00
  STA $0401                               ; $C58B: 8D 01 04
Loc_C58E:
  RTS                                     ; $C58E: 60
Loc_C58F:  ; (dispatch callback target)
  JSR $D5BD                               ; $C58F: 20 BD D5
  LDA a:$0013                             ; $C592: AD 13 00
  BEQ $C5D6                               ; $C595: F0 3F
  CMP #$FF                                ; $C597: C9 FF
  BEQ $C5D1                               ; $C599: F0 36
  LDA $0402                               ; $C59B: AD 02 04
  JSR $F2AF                               ; $C59E: 20 AF F2
  LDY #$02                                ; $C5A1: A0 02
  LDA ($00),Y                             ; $C5A3: B1 00
  SEC                                     ; $C5A5: 38
  SBC $042C                               ; $C5A6: ED 2C 04
  STA ($00),Y                             ; $C5A9: 91 00
  INY                                     ; $C5AB: C8
  LDA ($00),Y                             ; $C5AC: B1 00
  SBC #$00                                ; $C5AE: E9 00
  STA ($00),Y                             ; $C5B0: 91 00
  LDA $0481                               ; $C5B2: AD 81 04
  STA a:$0000                             ; $C5B5: 8D 00 00
  LDY #$3D                                ; $C5B8: A0 3D
  JSR $EE07                               ; $C5BA: 20 07 EE
; --- Data Region ---
  .byte $2A,$A0,$EE,$01,$04,$AD,$70,$04,$D0,$05,$A9,$7A,$4C,$6D,$F2; $C5BD: 2A A0 EE 01 04 AD 70 04 D0 05 A9 7A 4C 6D F2
Loc_C5CC:
; --- Code Region ---
  LDA #$7C                                ; $C5CC: A9 7C
  JMP $F26D                               ; $C5CE: 4C 6D F2
Loc_C5D1:
  LDA #$00                                ; $C5D1: A9 00
  STA $0401                               ; $C5D3: 8D 01 04
Loc_C5D6:
  RTS                                     ; $C5D6: 60
Loc_C5D7:  ; (dispatch callback target)
  LDA $0481                               ; $C5D7: AD 81 04
  JSR $DD5E                               ; $C5DA: 20 5E DD
  JSR $DDAD                               ; $C5DD: 20 AD DD
  BCC $C5EC                               ; $C5E0: 90 0A
  JSR $D543                               ; $C5E2: 20 43 D5
  LDA a:$0081                             ; $C5E5: AD 81 00
  AND #$03                                ; $C5E8: 29 03
  BNE $C5ED                               ; $C5EA: D0 01
Loc_C5EC:
  RTS                                     ; $C5EC: 60
Loc_C5ED:
  JSR $D568                               ; $C5ED: 20 68 D5
  LDY #$3D                                ; $C5F0: A0 3D
  JSR $EE07                               ; $C5F2: 20 07 EE
; --- Data Region ---
  .byte $24,$A0,$A9,$0F,$8D,$01,$04,$AD,$70,$04,$D0,$51; $C5F5: 24 A0 A9 0F 8D 01 04 AD 70 04 D0 51
Loc_C601:
; --- Code Region ---
  JSR $E85C                               ; $C601: 20 5C E8
  CMP #$0B                                ; $C604: C9 0B
  BCS $C601                               ; $C606: B0 F9
  CLC                                     ; $C608: 18
  ADC #$23                                ; $C609: 69 23
  STA $042C                               ; $C60B: 8D 2C 04
  LDA $0481                               ; $C60E: AD 81 04
  JSR $F387                               ; $C611: 20 87 F3
  LDY #$00                                ; $C614: A0 00
  LDA ($00),Y                             ; $C616: B1 00
  STA a:$0002                             ; $C618: 8D 02 00
  LDA $0481                               ; $C61B: AD 81 04
  JSR $F2D7                               ; $C61E: 20 D7 F2
  LDY #$00                                ; $C621: A0 00
  LDA ($00),Y                             ; $C623: B1 00
  CLC                                     ; $C625: 18
  ADC $042C                               ; $C626: 6D 2C 04
  STA ($00),Y                             ; $C629: 91 00
  SEC                                     ; $C62B: 38
  SBC a:$0002                             ; $C62C: ED 02 00
  BCC $C643                               ; $C62F: 90 12
  STA a:$0003                             ; $C631: 8D 03 00
  LDA $042C                               ; $C634: AD 2C 04
  SEC                                     ; $C637: 38
  SBC a:$0003                             ; $C638: ED 03 00
  STA $042C                               ; $C63B: 8D 2C 04
  LDA a:$0002                             ; $C63E: AD 02 00
  STA ($00),Y                             ; $C641: 91 00
Loc_C643:
  LDA #$0D                                ; $C643: A9 0D
  STA $04A2                               ; $C645: 8D A2 04
  LDA #$52                                ; $C648: A9 52
  STA $04D6                               ; $C64A: 8D D6 04
  LDA #$7B                                ; $C64D: A9 7B
  JMP $F26D                               ; $C64F: 4C 6D F2
Loc_C652:
  LDA $0481                               ; $C652: AD 81 04
  JSR $F2D7                               ; $C655: 20 D7 F2
  JSR $E856                               ; $C658: 20 56 E8
  CMP #$05                                ; $C65B: C9 05
  BCS $C652                               ; $C65D: B0 F3
  CLC                                     ; $C65F: 18
  ADC $0471                               ; $C660: 6D 71 04
  STA $042C                               ; $C663: 8D 2C 04
  LDY #$02                                ; $C666: A0 02
  LDA ($00),Y                             ; $C668: B1 00
  CLC                                     ; $C66A: 18
  ADC $042C                               ; $C66B: 6D 2C 04
  STA ($00),Y                             ; $C66E: 91 00
  LDA #$02                                ; $C670: A9 02
  STA $04A2                               ; $C672: 8D A2 04
  LDA #$52                                ; $C675: A9 52
  STA $04D6                               ; $C677: 8D D6 04
  LDA #$7D                                ; $C67A: A9 7D
  JMP $F26D                               ; $C67C: 4C 6D F2
Loc_C67F:  ; (dispatch callback target)
  LDA $0478                               ; $C67F: AD 78 04
  BNE $C6F7                               ; $C682: D0 73
  JSR $D64A                               ; $C684: 20 4A D6
  LDA $047C                               ; $C687: AD 7C 04
  BPL $C6F7                               ; $C68A: 10 6B
  CMP #$90                                ; $C68C: C9 90
  BEQ $C6F2                               ; $C68E: F0 62
  JSR $D7A8                               ; $C690: 20 A8 D7
  LDA $0481                               ; $C693: AD 81 04
  JSR $F2D7                               ; $C696: 20 D7 F2
  LDY #$02                                ; $C699: A0 02
  LDA ($00),Y                             ; $C69B: B1 00
  CMP #$50                                ; $C69D: C9 50
  BCS $C6D8                               ; $C69F: B0 37
  CMP #$3D                                ; $C6A1: C9 3D
  BCC $C6AC                               ; $C6A3: 90 07
  LDA #$0A                                ; $C6A5: A9 0A
  LDX #$06                                ; $C6A7: A2 06
  JMP $C6BB                               ; $C6A9: 4C BB C6
Loc_C6AC:
  CMP #$1F                                ; $C6AC: C9 1F
  BCC $C6B7                               ; $C6AE: 90 07
  LDA #$14                                ; $C6B0: A9 14
  LDX #$08                                ; $C6B2: A2 08
  JMP $C6BB                               ; $C6B4: 4C BB C6
Loc_C6B7:
  LDA #$1E                                ; $C6B7: A9 1E
  LDX #$05                                ; $C6B9: A2 05
Loc_C6BB:
  STA $042C                               ; $C6BB: 8D 2C 04
  STX $0471                               ; $C6BE: 8E 71 04
  LDA #$00                                ; $C6C1: A9 00
  STA $042D                               ; $C6C3: 8D 2D 04
  STA $042E                               ; $C6C6: 8D 2E 04
  LDA #$01                                ; $C6C9: A9 01
  STA $0470                               ; $C6CB: 8D 70 04
  LDA #$0B                                ; $C6CE: A9 0B
  STA $0401                               ; $C6D0: 8D 01 04
  LDA #$28                                ; $C6D3: A9 28
  JMP $F26D                               ; $C6D5: 4C 6D F2
Loc_C6D8:
  LDA $0481                               ; $C6D8: AD 81 04
  STA $0473                               ; $C6DB: 8D 73 04
  STA a:$0000                             ; $C6DE: 8D 00 00
  LDY #$3D                                ; $C6E1: A0 3D
  JSR $EE07                               ; $C6E3: 20 07 EE
; --- Data Region ---
  .byte $2A,$A0,$A9,$11,$8D,$01,$04,$A9,$79,$4C,$6D,$F2; $C6E6: 2A A0 A9 11 8D 01 04 A9 79 4C 6D F2
Loc_C6F2:
; --- Code Region ---
  LDA #$00                                ; $C6F2: A9 00
  STA $0401                               ; $C6F4: 8D 01 04
Loc_C6F7:
  RTS                                     ; $C6F7: 60
Loc_C6F8:  ; (dispatch callback target)
  LDY #$3D                                ; $C6F8: A0 3D
  JSR $EE07                               ; $C6FA: 20 07 EE
; --- Data Region ---
  .byte $24,$A0,$AD,$40,$01,$D0,$0E,$AD,$A2,$04,$8D,$A0,$04,$EE,$01,$04; $C6FD: 24 A0 AD 40 01 D0 0E AD A2 04 8D A0 04 EE 01 04
  .byte $A9,$60,$8D,$6C,$04               ; $C70D: A9 60 8D 6C 04
Loc_C712:
; --- Code Region ---
  RTS                                     ; $C712: 60
Loc_C713:  ; (dispatch callback target)
  LDA $04A0                               ; $C713: AD A0 04
  BNE $C720                               ; $C716: D0 08
  LDA #$04                                ; $C718: A9 04
  JSR $D58C                               ; $C71A: 20 8C D5
  INC $0401                               ; $C71D: EE 01 04
Loc_C720:
  RTS                                     ; $C720: 60
Loc_C721:  ; (dispatch callback target)
  JSR $DDAD                               ; $C721: 20 AD DD
  BCC $C73B                               ; $C724: 90 15
  JSR $D543                               ; $C726: 20 43 D5
  LDA a:$0081                             ; $C729: AD 81 00
  AND #$03                                ; $C72C: 29 03
  BEQ $C73B                               ; $C72E: F0 0B
  JSR $D568                               ; $C730: 20 68 D5
  LDA #$00                                ; $C733: A9 00
  STA $0400                               ; $C735: 8D 00 04
  STA $0401                               ; $C738: 8D 01 04
Loc_C73B:
  LDA $0473                               ; $C73B: AD 73 04
  BEQ $C743                               ; $C73E: F0 03
  JMP $DD5E                               ; $C740: 4C 5E DD
Loc_C743:
  RTS                                     ; $C743: 60
Loc_C744:  ; (dispatch callback target)
  LDA $0478                               ; $C744: AD 78 04
  BNE $C76D                               ; $C747: D0 24
  JSR $D64A                               ; $C749: 20 4A D6
  LDA $047C                               ; $C74C: AD 7C 04
  BPL $C76D                               ; $C74F: 10 1C
  CMP #$90                                ; $C751: C9 90
  BEQ $C768                               ; $C753: F0 13
  JSR $D7A8                               ; $C755: 20 A8 D7
  INC $0401                               ; $C758: EE 01 04
  LDA #$8C                                ; $C75B: A9 8C
  STA a:$00BD                             ; $C75D: 8D BD 00
  JSR $DD70                               ; $C760: 20 70 DD
  LDA #$A5                                ; $C763: A9 A5
  JMP $F26D                               ; $C765: 4C 6D F2
Loc_C768:
  LDA #$00                                ; $C768: A9 00
  STA $0401                               ; $C76A: 8D 01 04
Loc_C76D:
  RTS                                     ; $C76D: 60
Loc_C76E:  ; (dispatch callback target)
  LDA #$EE                                ; $C76E: A9 EE
  STA a:$0010                             ; $C770: 8D 10 00
  LDA #$C7                                ; $C773: A9 C7
  STA a:$0011                             ; $C775: 8D 11 00
  LDA #$00                                ; $C778: A9 00
  STA a:$0012                             ; $C77A: 8D 12 00
  JSR $ED1E                               ; $C77D: 20 1E ED
  LDA #$F4                                ; $C780: A9 F4
  STA a:$0010                             ; $C782: 8D 10 00
  LDA #$C7                                ; $C785: A9 C7
  STA a:$0011                             ; $C787: 8D 11 00
  LDA #$FC                                ; $C78A: A9 FC
  STA a:$0000                             ; $C78C: 8D 00 00
  LDA #$C7                                ; $C78F: A9 C7
  STA a:$0001                             ; $C791: 8D 01 00
  LDA a:$0012                             ; $C794: AD 12 00
  JSR $EDF5                               ; $C797: 20 F5 ED
  LDA a:$0081                             ; $C79A: AD 81 00
  LSR                                     ; $C79D: 4A
  BCC $C7D8                               ; $C79E: 90 38
  LDY $0402                               ; $C7A0: AC 02 04
  LDA $C801,Y                             ; $C7A3: B9 01 C8
  STA a:$0000                             ; $C7A6: 8D 00 00
  LDY #$28                                ; $C7A9: A0 28
  JSR $EE07                               ; $C7AB: 20 07 EE
; --- Data Region ---
  .byte $1E,$A0,$AD,$02,$04,$C9,$1B,$D0,$16,$AD,$4C,$04,$C9,$10,$D0,$0F; $C7AE: 1E A0 AD 02 04 C9 1B D0 16 AD 4C 04 C9 10 D0 0F
  .byte $A9,$17,$8D,$4F,$04,$A9,$90,$8D,$35,$04,$A9,$01,$8D,$36,$04; $C7BE: A9 17 8D 4F 04 A9 90 8D 35 04 A9 01 8D 36 04
Loc_C7CD:
; --- Code Region ---
  INC $0401                               ; $C7CD: EE 01 04
  JSR $DD70                               ; $C7D0: 20 70 DD
  LDA #$A6                                ; $C7D3: A9 A6
  JMP $F28B                               ; $C7D5: 4C 8B F2
Loc_C7D8:
  LSR                                     ; $C7D8: 4A
  BCC $C7ED                               ; $C7D9: 90 12
  DEC $0401                               ; $C7DB: CE 01 04
  LDA #$80                                ; $C7DE: A9 80
  STA $0478                               ; $C7E0: 8D 78 04
  LDA #$0F                                ; $C7E3: A9 0F
  STA $047C                               ; $C7E5: 8D 7C 04
  LDA #$A4                                ; $C7E8: A9 A4
  JMP $F26D                               ; $C7EA: 4C 6D F2
Loc_C7ED:
  RTS                                     ; $C7ED: 60
; --- Data Region ---
  .byte $00,$01,$02,$03,$FF,$FF,$BC,$58,$BC,$98,$CC,$58,$CC,$98,$00,$07; $C7EE: 00 01 02 03 FF FF BC 58 BC 98 CC 58 CC 98 00 07
  .byte $00,$00,$80,$00,$00,$00,$00,$01,$00,$00,$00,$01,$00,$00,$00,$01; $C7FE: 00 00 80 00 00 00 00 01 00 00 00 01 00 00 00 01
  .byte $00,$00,$02,$00,$00,$00,$00,$01,$00,$00,$00,$00,$01,$01,$00,$00; $C80E: 00 00 02 00 00 00 00 01 00 00 00 00 01 01 00 00
  .byte $01                               ; $C81E: 01
Loc_C81F:  ; (dispatch callback target)
; --- Code Region ---
  LDA $0300                               ; $C81F: AD 00 03
  CMP #$FF                                ; $C822: C9 FF
  BEQ $C827                               ; $C824: F0 01
  RTS                                     ; $C826: 60
; --- Data Region ---
  .byte $A0,$30,$20,$5F,$F2,$A0,$00,$A2,$00,$8E,$10,$00,$8E,$11,$00,$8E; $C827: A0 30 20 5F F2 A0 00 A2 00 8E 10 00 8E 11 00 8E
  .byte $12,$00,$AC,$10,$00,$B9,$4C,$04,$0A,$A8,$B9,$12,$9B,$8D,$00,$00; $C837: 12 00 AC 10 00 B9 4C 04 0A A8 B9 12 9B 8D 00 00
  .byte $C8,$B9,$12,$9B,$18,$69,$80,$8D,$01,$00,$A0,$00,$B1,$00,$8D,$BC; $C847: C8 B9 12 9B 18 69 80 8D 01 00 A0 00 B1 00 8D BC
  .byte $00,$4C,$73,$C8                   ; $C857: 00 4C 73 C8
Loc_C85B:
; --- Code Region ---
  LDY a:$0010                             ; $C85B: AC 10 00
  LDA $044C,Y                             ; $C85E: B9 4C 04
  ASL                                     ; $C861: 0A
  TAY                                     ; $C862: A8
  LDA $9B12,Y                             ; $C863: B9 12 9B
  STA a:$0000                             ; $C866: 8D 00 00
  INY                                     ; $C869: C8
  LDA $9B12,Y                             ; $C86A: B9 12 9B
  CLC                                     ; $C86D: 18
  ADC #$80                                ; $C86E: 69 80
  STA a:$0001                             ; $C870: 8D 01 00
Loc_C873:
  LDY #$00                                ; $C873: A0 00
  STY a:$0014                             ; $C875: 8C 14 00
  STY a:$0015                             ; $C878: 8C 15 00
  LDA ($00),Y                             ; $C87B: B1 00
  CMP a:$00BC                             ; $C87D: CD BC 00
  BEQ $C88A                               ; $C880: F0 08
  STA a:$00BD                             ; $C882: 8D BD 00
  LDA #$40                                ; $C885: A9 40
  STA a:$0015                             ; $C887: 8D 15 00
Loc_C88A:
  LDX a:$0012                             ; $C88A: AE 12 00
  LDA $C8FA,X                             ; $C88D: BD FA C8
  STA a:$0002                             ; $C890: 8D 02 00
  INX                                     ; $C893: E8
  LDA $C8FA,X                             ; $C894: BD FA C8
  STA a:$0003                             ; $C897: 8D 03 00
  INX                                     ; $C89A: E8
  STX a:$0012                             ; $C89B: 8E 12 00
  LDX a:$0011                             ; $C89E: AE 11 00
  LDA #$08                                ; $C8A1: A9 08
  STA $0380,X                             ; $C8A3: 9D 80 03
  INX                                     ; $C8A6: E8
  LDA a:$0003                             ; $C8A7: AD 03 00
  STA $0380,X                             ; $C8AA: 9D 80 03
  INX                                     ; $C8AD: E8
  LDA a:$0002                             ; $C8AE: AD 02 00
  STA $0380,X                             ; $C8B1: 9D 80 03
  LDA #$00                                ; $C8B4: A9 00
  STA a:$0013                             ; $C8B6: 8D 13 00
Loc_C8B9:
  INX                                     ; $C8B9: E8
  INY                                     ; $C8BA: C8
  LDA ($00),Y                             ; $C8BB: B1 00
  CLC                                     ; $C8BD: 18
  ADC a:$0015                             ; $C8BE: 6D 15 00
  STA $0380,X                             ; $C8C1: 9D 80 03
  INC a:$0013                             ; $C8C4: EE 13 00
  LDA a:$0013                             ; $C8C7: AD 13 00
  CMP #$08                                ; $C8CA: C9 08
  BCC $C8B9                               ; $C8CC: 90 EB
  INX                                     ; $C8CE: E8
  STX a:$0011                             ; $C8CF: 8E 11 00
  INC a:$0014                             ; $C8D2: EE 14 00
  LDA a:$0014                             ; $C8D5: AD 14 00
  CMP #$02                                ; $C8D8: C9 02
  BCC $C88A                               ; $C8DA: 90 AE
  INC a:$0010                             ; $C8DC: EE 10 00
  LDA a:$0010                             ; $C8DF: AD 10 00
  CMP #$04                                ; $C8E2: C9 04
  BCS $C8E9                               ; $C8E4: B0 03
  JMP $C85B                               ; $C8E6: 4C 5B C8
Loc_C8E9:
  LDA #$FF                                ; $C8E9: A9 FF
  STA $0380,X                             ; $C8EB: 9D 80 03
  LDA a:$007E                             ; $C8EE: AD 7E 00
  ORA #$04                                ; $C8F1: 09 04
  STA a:$007E                             ; $C8F3: 8D 7E 00
  INC $0401                               ; $C8F6: EE 01 04
  RTS                                     ; $C8F9: 60
; --- Data Region ---
  .byte $E3,$22,$03,$23,$F1,$22,$11,$23,$43,$23; $C8FA: E3 22 03 23 F1 22 11 23 43 23
Loc_C904:
  .byte $63,$23,$51,$23,$71,$23           ; $C904: 63 23 51 23 71 23
Loc_C90A:  ; (dispatch callback target)
; --- Code Region ---
  LDA #$BF                                ; $C90A: A9 BF
  STA a:$0010                             ; $C90C: 8D 10 00
  LDA #$C9                                ; $C90F: A9 C9
  STA a:$0011                             ; $C911: 8D 11 00
  LDA #$00                                ; $C914: A9 00
  STA a:$0012                             ; $C916: 8D 12 00
  JSR $ED1E                               ; $C919: 20 1E ED
  LDA #$C5                                ; $C91C: A9 C5
  STA a:$0010                             ; $C91E: 8D 10 00
  LDA #$C9                                ; $C921: A9 C9
  STA a:$0011                             ; $C923: 8D 11 00
  LDA #$CD                                ; $C926: A9 CD
  STA a:$0000                             ; $C928: 8D 00 00
  LDA #$C9                                ; $C92B: A9 C9
  STA a:$0001                             ; $C92D: 8D 01 00
  LDA a:$0012                             ; $C930: AD 12 00
  JSR $EDF5                               ; $C933: 20 F5 ED
  LDA a:$0081                             ; $C936: AD 81 00
  LSR                                     ; $C939: 4A
  BCS $C950                               ; $C93A: B0 14
  LSR                                     ; $C93C: 4A
  BCC $C94F                               ; $C93D: 90 10
  LDA #$13                                ; $C93F: A9 13
  STA $0471                               ; $C941: 8D 71 04
  INC $0401                               ; $C944: EE 01 04
  JSR $DD70                               ; $C947: 20 70 DD
  LDA #$A5                                ; $C94A: A9 A5
  JMP $F28B                               ; $C94C: 4C 8B F2
Loc_C94F:
  RTS                                     ; $C94F: 60
Loc_C950:
  LDY a:$0012                             ; $C950: AC 12 00
  LDA $044C,Y                             ; $C953: B9 4C 04
  STA $044C                               ; $C956: 8D 4C 04
  LDA a:$0012                             ; $C959: AD 12 00
  ASL                                     ; $C95C: 0A
  CLC                                     ; $C95D: 18
  ADC a:$0012                             ; $C95E: 6D 12 00
  TAY                                     ; $C961: A8
  LDA $042C,Y                             ; $C962: B9 2C 04
  STA a:$0010                             ; $C965: 8D 10 00
  INY                                     ; $C968: C8
  LDA $042C,Y                             ; $C969: B9 2C 04
  STA a:$0011                             ; $C96C: 8D 11 00
  LDA $0402                               ; $C96F: AD 02 04
  JSR $F2AF                               ; $C972: 20 AF F2
  LDY #$02                                ; $C975: A0 02
  LDA ($00),Y                             ; $C977: B1 00
  SEC                                     ; $C979: 38
  SBC a:$0010                             ; $C97A: ED 10 00
  INY                                     ; $C97D: C8
  LDA ($00),Y                             ; $C97E: B1 00
  SBC a:$0011                             ; $C980: ED 11 00
  BCC $C9B2                               ; $C983: 90 2D
  JSR $CA6B                               ; $C985: 20 6B CA
  BCS $C993                               ; $C988: B0 09
  LDA #$11                                ; $C98A: A9 11
  STA $0471                               ; $C98C: 8D 71 04
  INC $0401                               ; $C98F: EE 01 04
  RTS                                     ; $C992: 60
Loc_C993:
  LDA a:$0010                             ; $C993: AD 10 00
  STA $042C                               ; $C996: 8D 2C 04
  LDA a:$0011                             ; $C999: AD 11 00
  STA $042D                               ; $C99C: 8D 2D 04
  LDA #$17                                ; $C99F: A9 17
  STA $0471                               ; $C9A1: 8D 71 04
  INC $0401                               ; $C9A4: EE 01 04
  JSR $DD70                               ; $C9A7: 20 70 DD
  STA $046C                               ; $C9AA: 8D 6C 04
  LDA #$29                                ; $C9AD: A9 29
  JMP $F28B                               ; $C9AF: 4C 8B F2
Loc_C9B2:
  LDA #$11                                ; $C9B2: A9 11
  STA $0471                               ; $C9B4: 8D 71 04
  INC $0401                               ; $C9B7: EE 01 04
  LDA #$AA                                ; $C9BA: A9 AA
  JMP $F28B                               ; $C9BC: 4C 8B F2
; --- Data Region ---
  .byte $00,$01,$02,$03,$FF,$FF,$BC,$10,$BC,$80,$D4,$10,$D4,$80,$00,$07; $C9BF: 00 01 02 03 FF FF BC 10 BC 80 D4 10 D4 80 00 07
  .byte $00,$00,$80                       ; $C9CF: 00 00 80
Loc_C9D2:  ; (dispatch callback target)
; --- Code Region ---
  LDA $0300                               ; $C9D2: AD 00 03
  BNE $C9EE                               ; $C9D5: D0 17
  LDA #$0D                                ; $C9D7: A9 0D
  STA a:$00BC                             ; $C9D9: 8D BC 00
  LDA #$8C                                ; $C9DC: A9 8C
  STA a:$00BD                             ; $C9DE: 8D BD 00
  LDY #$3D                                ; $C9E1: A0 3D
  JSR $EE07                               ; $C9E3: 20 07 EE
; --- Data Region ---
  .byte $24,$A0,$AD,$71,$04,$8D,$01,$04,$60; $C9E6: 24 A0 AD 71 04 8D 01 04 60
Loc_C9EF:  ; (dispatch callback target)
; --- Code Region ---
  JSR $D5BD                               ; $C9EF: 20 BD D5
  LDA a:$0013                             ; $C9F2: AD 13 00
  BEQ $CA6A                               ; $C9F5: F0 73
  CMP #$FF                                ; $C9F7: C9 FF
  BEQ $CA65                               ; $C9F9: F0 6A
  LDA $0472                               ; $C9FB: AD 72 04
  BEQ $CA06                               ; $C9FE: F0 06
  ORA $6FE1                               ; $CA00: 0D E1 6F
  STA $6FE1                               ; $CA03: 8D E1 6F
Loc_CA06:
  LDA #$E0                                ; $CA06: A9 E0
  STA a:$0010                             ; $CA08: 8D 10 00
  LDA $044C                               ; $CA0B: AD 4C 04
  CMP #$18                                ; $CA0E: C9 18
  BCC $CA24                               ; $CA10: 90 12
  SEC                                     ; $CA12: 38
  SBC #$18                                ; $CA13: E9 18
  CLC                                     ; $CA15: 18
  ROR                                     ; $CA16: 6A
  ROR                                     ; $CA17: 6A
  ROR                                     ; $CA18: 6A
  ROR                                     ; $CA19: 6A
  AND #$E0                                ; $CA1A: 29 E0
  STA $044C                               ; $CA1C: 8D 4C 04
  LDA #$1F                                ; $CA1F: A9 1F
  STA a:$0010                             ; $CA21: 8D 10 00
Loc_CA24:
  LDA $0481                               ; $CA24: AD 81 04
  JSR $F2D7                               ; $CA27: 20 D7 F2
  LDY #$0A                                ; $CA2A: A0 0A
  LDA ($00),Y                             ; $CA2C: B1 00
  AND a:$0010                             ; $CA2E: 2D 10 00
  ORA $044C                               ; $CA31: 0D 4C 04
  STA ($00),Y                             ; $CA34: 91 00
  LDA $0402                               ; $CA36: AD 02 04
  JSR $F2AF                               ; $CA39: 20 AF F2
  LDY #$02                                ; $CA3C: A0 02
  LDA ($00),Y                             ; $CA3E: B1 00
  SEC                                     ; $CA40: 38
  SBC $042C                               ; $CA41: ED 2C 04
  STA ($00),Y                             ; $CA44: 91 00
  INY                                     ; $CA46: C8
  LDA ($00),Y                             ; $CA47: B1 00
  SBC $042D                               ; $CA49: ED 2D 04
  STA ($00),Y                             ; $CA4C: 91 00
  LDA #$08                                ; $CA4E: A9 08
  STA $04A2                               ; $CA50: 8D A2 04
  LDA #$4D                                ; $CA53: A9 4D
  STA $04D6                               ; $CA55: 8D D6 04
  JSR $D568                               ; $CA58: 20 68 D5
  LDA #$0F                                ; $CA5B: A9 0F
  STA $0401                               ; $CA5D: 8D 01 04
  LDA #$AB                                ; $CA60: A9 AB
  JMP $F26D                               ; $CA62: 4C 6D F2
Loc_CA65:
  LDA #$00                                ; $CA65: A9 00
  STA $0401                               ; $CA67: 8D 01 04
Loc_CA6A:
  RTS                                     ; $CA6A: 60
Loc_CA6B:
  LDA #$00                                ; $CA6B: A9 00
  STA $0472                               ; $CA6D: 8D 72 04
  LDA $0481                               ; $CA70: AD 81 04
  STA a:$0002                             ; $CA73: 8D 02 00
  JSR $F2D7                               ; $CA76: 20 D7 F2
  LDA $044C                               ; $CA79: AD 4C 04
  CMP #$0F                                ; $CA7C: C9 0F
  BNE $CA8C                               ; $CA7E: D0 0C
  LDA a:$0002                             ; $CA80: AD 02 00
  CMP #$26                                ; $CA83: C9 26
  BNE $CABE                               ; $CA85: D0 37
  LDA #$02                                ; $CA87: A9 02
  JMP $CAC5                               ; $CA89: 4C C5 CA
Loc_CA8C:
  CMP #$17                                ; $CA8C: C9 17
  BNE $CA9C                               ; $CA8E: D0 0C
  LDA a:$0002                             ; $CA90: AD 02 00
  CMP #$99                                ; $CA93: C9 99
  BNE $CABE                               ; $CA95: D0 27
  LDA #$04                                ; $CA97: A9 04
  JMP $CAC5                               ; $CA99: 4C C5 CA
Loc_CA9C:
  CMP #$16                                ; $CA9C: C9 16
  BNE $CAAD                               ; $CA9E: D0 0D
  LDY #$01                                ; $CAA0: A0 01
  LDA ($00),Y                             ; $CAA2: B1 00
  CMP #$5B                                ; $CAA4: C9 5B
  BCC $CABE                               ; $CAA6: 90 16
  LDA #$08                                ; $CAA8: A9 08
  JMP $CAC5                               ; $CAAA: 4C C5 CA
Loc_CAAD:
  CMP #$1E                                ; $CAAD: C9 1E
  BNE $CAD6                               ; $CAAF: D0 25
  LDY #$04                                ; $CAB1: A0 04
  LDA ($00),Y                             ; $CAB3: B1 00
  CMP #$5B                                ; $CAB5: C9 5B
  BCC $CABE                               ; $CAB7: 90 05
  LDA #$10                                ; $CAB9: A9 10
  JMP $CAC5                               ; $CABB: 4C C5 CA
Loc_CABE:
  LDA #$9A                                ; $CABE: A9 9A
  JSR $F28B                               ; $CAC0: 20 8B F2
  CLC                                     ; $CAC3: 18
  RTS                                     ; $CAC4: 60
Loc_CAC5:
  STA a:$0003                             ; $CAC5: 8D 03 00
  LDA $6FE1                               ; $CAC8: AD E1 6F
  AND a:$0003                             ; $CACB: 2D 03 00
  BNE $CAD8                               ; $CACE: D0 08
  LDA a:$0003                             ; $CAD0: AD 03 00
  STA $0472                               ; $CAD3: 8D 72 04
Loc_CAD6:
  SEC                                     ; $CAD6: 38
  RTS                                     ; $CAD7: 60
Loc_CAD8:
  LDA #$9B                                ; $CAD8: A9 9B
  JSR $F28B                               ; $CADA: 20 8B F2
  CLC                                     ; $CADD: 18
  RTS                                     ; $CADE: 60
Loc_CADF:  ; (dispatch callback target)
  LDA $0401                               ; $CADF: AD 01 04
  JSR $EADE                               ; $CAE2: 20 DE EA
; --- Data Region ---
  .byte $09,$CB,$FF,$CB,$82,$CC,$4C,$CD,$89,$CD,$8E,$CE,$AD,$CE,$F7,$CE; $CAE5: 09 CB FF CB 82 CC 4C CD 89 CD 8E CE AD CE F7 CE
  .byte $1E,$CF,$8D,$CF,$E4,$CF,$1F,$D0,$E8,$D0,$FC,$D0,$3F,$D1,$8F,$D1; $CAF5: 1E CF 8D CF E4 CF 1F D0 E8 D0 FC D0 3F D1 8F D1
  .byte $B9,$D1,$3C,$D2                   ; $CB05: B9 D1 3C D2
Loc_CB09:  ; (dispatch callback target)
; --- Code Region ---
  LDA #$EE                                ; $CB09: A9 EE
  STA a:$0010                             ; $CB0B: 8D 10 00
  LDA #$CB                                ; $CB0E: A9 CB
  STA a:$0011                             ; $CB10: 8D 11 00
  LDA #$00                                ; $CB13: A9 00
  STA a:$0012                             ; $CB15: 8D 12 00
  JSR $ED1E                               ; $CB18: 20 1E ED
  LDA #$F4                                ; $CB1B: A9 F4
  STA a:$0010                             ; $CB1D: 8D 10 00
  LDA #$CB                                ; $CB20: A9 CB
  STA a:$0011                             ; $CB22: 8D 11 00
  LDA #$FA                                ; $CB25: A9 FA
  STA a:$0000                             ; $CB27: 8D 00 00
  LDA #$CB                                ; $CB2A: A9 CB
  STA a:$0001                             ; $CB2C: 8D 01 00
  LDA a:$0012                             ; $CB2F: AD 12 00
  JSR $EDF5                               ; $CB32: 20 F5 ED
  JSR $DDAD                               ; $CB35: 20 AD DD
  BCC $CB4D                               ; $CB38: 90 13
  LDA a:$0081                             ; $CB3A: AD 81 00
  LSR                                     ; $CB3D: 4A
  BCS $CB4E                               ; $CB3E: B0 0E
  LSR                                     ; $CB40: 4A
Loc_CB41:
  BCC $CB4D                               ; $CB41: 90 0A
  LDA #$02                                ; $CB43: A9 02
  STA $0400                               ; $CB45: 8D 00 04
  LDA #$00                                ; $CB48: A9 00
  STA $0401                               ; $CB4A: 8D 01 04
Loc_CB4D:
  RTS                                     ; $CB4D: 60
Loc_CB4E:
  LDA #$3E                                ; $CB4E: A9 3E
  STA $04D6                               ; $CB50: 8D D6 04
  LDA a:$0012                             ; $CB53: AD 12 00
  BEQ $CB8C                               ; $CB56: F0 34
  CMP #$02                                ; $CB58: C9 02
  BEQ $CB7B                               ; $CB5A: F0 1F
  LDA $0402                               ; $CB5C: AD 02 04
  STA $0470                               ; $CB5F: 8D 70 04
  LDA a:$0012                             ; $CB62: AD 12 00
  CMP #$01                                ; $CB65: C9 01
  BNE $CB7B                               ; $CB67: D0 12
  LDA #$00                                ; $CB69: A9 00
  STA $0472                               ; $CB6B: 8D 72 04
  JSR $D568                               ; $CB6E: 20 68 D5
  LDA #$08                                ; $CB71: A9 08
  STA $0401                               ; $CB73: 8D 01 04
  LDA #$3E                                ; $CB76: A9 3E
  JMP $F26D                               ; $CB78: 4C 6D F2
Loc_CB7B:
  LDA $0402                               ; $CB7B: AD 02 04
  STA $0470                               ; $CB7E: 8D 70 04
  LDA #$01                                ; $CB81: A9 01
  STA $0472                               ; $CB83: 8D 72 04
  LDA #$07                                ; $CB86: A9 07
  STA $0401                               ; $CB88: 8D 01 04
  RTS                                     ; $CB8B: 60
Loc_CB8C:
  INC $0401                               ; $CB8C: EE 01 04
  LDA #$00                                ; $CB8F: A9 00
  STA $0472                               ; $CB91: 8D 72 04
  STA $048B                               ; $CB94: 8D 8B 04
  LDA #$03                                ; $CB97: A9 03
  STA $0471                               ; $CB99: 8D 71 04
  LDA #$80                                ; $CB9C: A9 80
  STA $0480                               ; $CB9E: 8D 80 04
  LDA #$22                                ; $CBA1: A9 22
  STA $0481                               ; $CBA3: 8D 81 04
  LDA $0402                               ; $CBA6: AD 02 04
  JSR $F2AF                               ; $CBA9: 20 AF F2
  LDY #$00                                ; $CBAC: A0 00
  LDA ($00),Y                             ; $CBAE: B1 00
  AND #$07                                ; $CBB0: 29 07
  STA $0470                               ; $CBB2: 8D 70 04
  LDX #$00                                ; $CBB5: A2 00
  STX a:$0010                             ; $CBB7: 8E 10 00
Loc_CBBA:
  LDA #$FF                                ; $CBBA: A9 FF
  STA $0490,X                             ; $CBBC: 9D 90 04
  TXA                                     ; $CBBF: 8A
  JSR $F368                               ; $CBC0: 20 68 F3
  LDY #$00                                ; $CBC3: A0 00
  LDA ($00),Y                             ; $CBC5: B1 00
  CMP #$FF                                ; $CBC7: C9 FF
  BEQ $CBCE                               ; $CBC9: F0 03
  INC a:$0010                             ; $CBCB: EE 10 00
Loc_CBCE:
  INX                                     ; $CBCE: E8
  CPX #$07                                ; $CBCF: E0 07
  BCC $CBBA                               ; $CBD1: 90 E7
  LDA a:$0010                             ; $CBD3: AD 10 00
  CMP #$02                                ; $CBD6: C9 02
  BCC $CBDF                               ; $CBD8: 90 05
  LDA #$3C                                ; $CBDA: A9 3C
  JMP $F26D                               ; $CBDC: 4C 6D F2
Loc_CBDF:
  LDA #$FF                                ; $CBDF: A9 FF
  STA $0473                               ; $CBE1: 8D 73 04
  LDA #$0E                                ; $CBE4: A9 0E
  STA $0401                               ; $CBE6: 8D 01 04
  LDA #$A8                                ; $CBE9: A9 A8
  JMP $F26D                               ; $CBEB: 4C 6D F2
; --- Data Region ---
  .byte $00,$01,$02,$FF,$FF,$FF,$B8,$48,$B8,$98,$C8,$48,$00,$07,$00,$00; $CBEE: 00 01 02 FF FF FF B8 48 B8 98 C8 48 00 07 00 00
  .byte $80                               ; $CBFE: 80
Loc_CBFF:  ; (dispatch callback target)
; --- Code Region ---
  LDY #$30                                ; $CBFF: A0 30
  JSR $F25F                               ; $CC01: 20 5F F2
  LDA a:$007E                             ; $CC04: AD 7E 00
  AND #$03                                ; $CC07: 29 03
  BNE $CC81                               ; $CC09: D0 76
  LDA $0471                               ; $CC0B: AD 71 04
  BNE $CC1A                               ; $CC0E: D0 0A
  INC $0401                               ; $CC10: EE 01 04
  JSR $DD70                               ; $CC13: 20 70 DD
  STA $046C                               ; $CC16: 8D 6C 04
  RTS                                     ; $CC19: 60
Loc_CC1A:
  LDY #$00                                ; $CC1A: A0 00
  LDA #$01                                ; $CC1C: A9 01
Loc_CC1E:
  STA $0160,Y                             ; $CC1E: 99 60 01
  INY                                     ; $CC21: C8
Loc_CC22:
  CPY #$40                                ; $CC22: C0 40
  BCC $CC1E                               ; $CC24: 90 F8
  LDA #$00                                ; $CC26: A9 00
  STA a:$0010                             ; $CC28: 8D 10 00
Loc_CC2B:
  LDA $0472                               ; $CC2B: AD 72 04
  CMP #$07                                ; $CC2E: C9 07
  BCS $CC52                               ; $CC30: B0 20
  CMP $0470                               ; $CC32: CD 70 04
  BEQ $CC5C                               ; $CC35: F0 25
  JSR $DD56                               ; $CC37: 20 56 DD
  CMP #$FF                                ; $CC3A: C9 FF
  BEQ $CC5C                               ; $CC3C: F0 1E
  PHA                                     ; $CC3E: 48
  LDY $048B                               ; $CC3F: AC 8B 04
  LDA $0472                               ; $CC42: AD 72 04
  STA $0490,Y                             ; $CC45: 99 90 04
  INC $048B                               ; $CC48: EE 8B 04
  PLA                                     ; $CC4B: 68
  JSR $F308                               ; $CC4C: 20 08 F3
  JSR $D472                               ; $CC4F: 20 72 D4
Loc_CC52:
  LDA a:$0010                             ; $CC52: AD 10 00
  BNE $CC62                               ; $CC55: D0 0B
  LDA #$10                                ; $CC57: A9 10
  STA a:$0010                             ; $CC59: 8D 10 00
Loc_CC5C:
  INC $0472                               ; $CC5C: EE 72 04
  JMP $CC2B                               ; $CC5F: 4C 2B CC
Loc_CC62:
  DEC $0471                               ; $CC62: CE 71 04
  INC $0472                               ; $CC65: EE 72 04
  LDA $0480                               ; $CC68: AD 80 04
  CLC                                     ; $CC6B: 18
  ADC #$40                                ; $CC6C: 69 40
  STA $0480                               ; $CC6E: 8D 80 04
  LDA $0481                               ; $CC71: AD 81 04
  ADC #$00                                ; $CC74: 69 00
  STA $0481                               ; $CC76: 8D 81 04
  LDA a:$007E                             ; $CC79: AD 7E 00
  ORA #$02                                ; $CC7C: 09 02
  STA a:$007E                             ; $CC7E: 8D 7E 00
  RTS                                     ; $CC81: 60
Loc_CC82:  ; (dispatch callback target)
  LDA $0424                               ; $CC82: AD 24 04
  STA a:$0013                             ; $CC85: 8D 13 00
  LDA $0425                               ; $CC88: AD 25 04
  STA a:$0014                             ; $CC8B: 8D 14 00
  LDA #$33                                ; $CC8E: A9 33
  STA a:$0010                             ; $CC90: 8D 10 00
  LDA #$CD                                ; $CC93: A9 CD
  STA a:$0011                             ; $CC95: 8D 11 00
  LDA #$01                                ; $CC98: A9 01
  STA a:$0012                             ; $CC9A: 8D 12 00
  JSR $ED1E                               ; $CC9D: 20 1E ED
  TAY                                     ; $CCA0: A8
  LDA $0490,Y                             ; $CCA1: B9 90 04
  BPL $CCB8                               ; $CCA4: 10 12
  LDA a:$0013                             ; $CCA6: AD 13 00
  STA $0424                               ; $CCA9: 8D 24 04
  LDA a:$0014                             ; $CCAC: AD 14 00
  STA $0425                               ; $CCAF: 8D 25 04
  LDA $046C                               ; $CCB2: AD 6C 04
  STA a:$0012                             ; $CCB5: 8D 12 00
Loc_CCB8:
  LDA #$3B                                ; $CCB8: A9 3B
  STA a:$0010                             ; $CCBA: 8D 10 00
  LDA #$CD                                ; $CCBD: A9 CD
  STA a:$0011                             ; $CCBF: 8D 11 00
  LDA #$47                                ; $CCC2: A9 47
  STA a:$0000                             ; $CCC4: 8D 00 00
  LDA #$CD                                ; $CCC7: A9 CD
  STA a:$0001                             ; $CCC9: 8D 01 00
  LDA a:$0012                             ; $CCCC: AD 12 00
  STA $046C                               ; $CCCF: 8D 6C 04
  JSR $EDF5                               ; $CCD2: 20 F5 ED
  LDA a:$0081                             ; $CCD5: AD 81 00
  AND #$03                                ; $CCD8: 29 03
  BEQ $CCF7                               ; $CCDA: F0 1B
  JSR $DD70                               ; $CCDC: 20 70 DD
  LDA a:$0081                             ; $CCDF: AD 81 00
  LSR                                     ; $CCE2: 4A
  BCS $CCF8                               ; $CCE3: B0 13
  LSR                                     ; $CCE5: 4A
  BCC $CCF7                               ; $CCE6: 90 0F
  LDA #$05                                ; $CCE8: A9 05
  STA $0401                               ; $CCEA: 8D 01 04
  LDA #$3B                                ; $CCED: A9 3B
  STA $042C                               ; $CCEF: 8D 2C 04
  LDA #$00                                ; $CCF2: A9 00
  JMP $F28B                               ; $CCF4: 4C 8B F2
Loc_CCF7:
  RTS                                     ; $CCF7: 60
Loc_CCF8:
  LDY a:$0012                             ; $CCF8: AC 12 00
  LDA $0490,Y                             ; $CCFB: B9 90 04
  STA $0471                               ; $CCFE: 8D 71 04
  LDA $0470                               ; $CD01: AD 70 04
  JSR $DD56                               ; $CD04: 20 56 DD
  LDA $0471                               ; $CD07: AD 71 04
  JSR $D4ED                               ; $CD0A: 20 ED D4
  BNE $CD21                               ; $CD0D: D0 12
  INC $0401                               ; $CD0F: EE 01 04
  LDA #$80                                ; $CD12: A9 80
  STA $0478                               ; $CD14: 8D 78 04
  LDA #$0F                                ; $CD17: A9 0F
  STA $047C                               ; $CD19: 8D 7C 04
  LDA #$27                                ; $CD1C: A9 27
  JMP $F28B                               ; $CD1E: 4C 8B F2
Loc_CD21:
  LDA #$05                                ; $CD21: A9 05
  STA $0401                               ; $CD23: 8D 01 04
  LDA #$29                                ; $CD26: A9 29
  STA $042C                               ; $CD28: 8D 2C 04
  LDA #$00                                ; $CD2B: A9 00
  STA $046C                               ; $CD2D: 8D 6C 04
  JMP $F28B                               ; $CD30: 4C 8B F2
; --- Data Region ---
  .byte $00,$01,$02,$03,$04,$05,$FF,$FF,$B8,$08,$B8,$88,$C8,$08,$C8,$88; $CD33: 00 01 02 03 04 05 FF FF B8 08 B8 88 C8 08 C8 88
  .byte $D8,$08,$D8,$88,$00,$07,$00,$00,$80; $CD43: D8 08 D8 88 00 07 00 00 80
Loc_CD4C:  ; (dispatch callback target)
; --- Code Region ---
  LDA $0478                               ; $CD4C: AD 78 04
  BNE $CD88                               ; $CD4F: D0 37
  JSR $D64A                               ; $CD51: 20 4A D6
  LDA $047C                               ; $CD54: AD 7C 04
  BPL $CD88                               ; $CD57: 10 2F
  CMP #$81                                ; $CD59: C9 81
  BNE $CD60                               ; $CD5B: D0 03
  JSR $D7A8                               ; $CD5D: 20 A8 D7
Loc_CD60:
  LDY #$3D                                ; $CD60: A0 3D
  JSR $EE07                               ; $CD62: 20 07 EE
; --- Data Region ---
  .byte $24,$A0,$20,$70,$DD,$AD,$7C,$04,$C9,$90,$F0,$0D,$EE,$01,$04,$A9; $CD65: 24 A0 20 70 DD AD 7C 04 C9 90 F0 0D EE 01 04 A9
  .byte $00,$8D,$6C,$04,$A9,$29,$4C,$6D,$F2; $CD75: 00 8D 6C 04 A9 29 4C 6D F2
Loc_CD7E:
; --- Code Region ---
  LDA #$00                                ; $CD7E: A9 00
  STA $0401                               ; $CD80: 8D 01 04
  LDA #$3B                                ; $CD83: A9 3B
  JMP $F26D                               ; $CD85: 4C 6D F2
; --- Data Region ---
  .byte $60                               ; $CD88: 60
Loc_CD89:  ; (dispatch callback target)
; --- Code Region ---
  JSR $D5BD                               ; $CD89: 20 BD D5
  LDA a:$0013                             ; $CD8C: AD 13 00
  BEQ $CDA0                               ; $CD8F: F0 0F
  CMP #$FF                                ; $CD91: C9 FF
  BNE $CDA1                               ; $CD93: D0 0C
  LDA #$02                                ; $CD95: A9 02
  STA $0400                               ; $CD97: 8D 00 04
  JSR $DD70                               ; $CD9A: 20 70 DD
  STA $0401                               ; $CD9D: 8D 01 04
Loc_CDA0:
  RTS                                     ; $CDA0: 60
Loc_CDA1:
  LDA #$19                                ; $CDA1: A9 19
  STA $04A2                               ; $CDA3: 8D A2 04
  LDA $0471                               ; $CDA6: AD 71 04
  JSR $DD56                               ; $CDA9: 20 56 DD
  STA $042C                               ; $CDAC: 8D 2C 04
  LDY #$03                                ; $CDAF: A0 03
  LDA ($00),Y                             ; $CDB1: B1 00
  CMP #$03                                ; $CDB3: C9 03
  BEQ $CDBA                               ; $CDB5: F0 03
  JMP $CE6E                               ; $CDB7: 4C 6E CE
Loc_CDBA:
  LDA $0471                               ; $CDBA: AD 71 04
  STA a:$0010                             ; $CDBD: 8D 10 00
  JSR $DDBF                               ; $CDC0: 20 BF DD
  LDA a:$0011                             ; $CDC3: AD 11 00
  STA a:$000A                             ; $CDC6: 8D 0A 00
  LDA $6F03                               ; $CDC9: AD 03 6F
  STA a:$0010                             ; $CDCC: 8D 10 00
  JSR $DDBF                               ; $CDCF: 20 BF DD
  LDA a:$0011                             ; $CDD2: AD 11 00
  SEC                                     ; $CDD5: 38
  SBC a:$000A                             ; $CDD6: ED 0A 00
  BCS $CDDD                               ; $CDD9: B0 02
  LDA #$00                                ; $CDDB: A9 00
Loc_CDDD:
  STA a:$000A                             ; $CDDD: 8D 0A 00
  LDA $042C                               ; $CDE0: AD 2C 04
  JSR $F2D7                               ; $CDE3: 20 D7 F2
  LDY #$02                                ; $CDE6: A0 02
  LDA ($00),Y                             ; $CDE8: B1 00
  STA a:$0010                             ; $CDEA: 8D 10 00
  LDA $0481                               ; $CDED: AD 81 04
  JSR $F2D7                               ; $CDF0: 20 D7 F2
  LDY #$02                                ; $CDF3: A0 02
  LDA ($00),Y                             ; $CDF5: B1 00
  STA a:$0011                             ; $CDF7: 8D 11 00
  LDY #$04                                ; $CDFA: A0 04
  LDA ($00),Y                             ; $CDFC: B1 00
  CLC                                     ; $CDFE: 18
  ADC a:$0011                             ; $CDFF: 6D 11 00
  SEC                                     ; $CE02: 38
  SBC a:$0010                             ; $CE03: ED 10 00
  BCS $CE0A                               ; $CE06: B0 02
  LDA #$00                                ; $CE08: A9 00
Loc_CE0A:
  STA a:$0001                             ; $CE0A: 8D 01 00
  LDA #$00                                ; $CE0D: A9 00
  STA a:$0002                             ; $CE0F: 8D 02 00
  STA a:$0004                             ; $CE12: 8D 04 00
  LDA #$04                                ; $CE15: A9 04
  STA a:$0003                             ; $CE17: 8D 03 00
  JSR $EA7C                               ; $CE1A: 20 7C EA
  LDA a:$0001                             ; $CE1D: AD 01 00
  CLC                                     ; $CE20: 18
  ADC a:$000A                             ; $CE21: 6D 0A 00
  BPL $CE28                               ; $CE24: 10 02
  LDA #$00                                ; $CE26: A9 00
Loc_CE28:
  STA $042F                               ; $CE28: 8D 2F 04
  JSR $E843                               ; $CE2B: 20 43 E8
  CMP $042F                               ; $CE2E: CD 2F 04
  BCC $CE4A                               ; $CE31: 90 17
  LDA #$04                                ; $CE33: A9 04
  STA a:$00A4                             ; $CE35: 8D A4 00
  JSR $D568                               ; $CE38: 20 68 D5
  LDA #$0C                                ; $CE3B: A9 0C
  STA $0401                               ; $CE3D: 8D 01 04
  LDA #$43                                ; $CE40: A9 43
  STA $0470                               ; $CE42: 8D 70 04
  LDA #$00                                ; $CE45: A9 00
  JMP $F29B                               ; $CE47: 4C 9B F2
Loc_CE4A:
  LDY #$39                                ; $CE4A: A0 39
  JSR $EE07                               ; $CE4C: 20 07 EE
; --- Data Region ---
  .byte $27,$A0,$A9,$03,$8D,$73,$04,$AD,$70,$04,$8D,$72,$04,$A9,$EC,$8D; $CE4F: 27 A0 A9 03 8D 73 04 AD 70 04 8D 72 04 A9 EC 8D
  .byte $70,$04                           ; $CE5F: 70 04
Loc_CE61:
; --- Code Region ---
  JSR $D568                               ; $CE61: 20 68 D5
  LDA #$0C                                ; $CE64: A9 0C
  STA $0401                               ; $CE66: 8D 01 04
  LDA #$00                                ; $CE69: A9 00
  JMP $F29B                               ; $CE6B: 4C 9B F2
Loc_CE6E:
  LDA $0471                               ; $CE6E: AD 71 04
  STA $0483                               ; $CE71: 8D 83 04
  LDA $0470                               ; $CE74: AD 70 04
  STA $0482                               ; $CE77: 8D 82 04
  JSR $DD56                               ; $CE7A: 20 56 DD
  STA $042D                               ; $CE7D: 8D 2D 04
  LDA $0481                               ; $CE80: AD 81 04
  STA $042E                               ; $CE83: 8D 2E 04
  LDA #$01                                ; $CE86: A9 01
  STA $0473                               ; $CE88: 8D 73 04
  JMP $CE61                               ; $CE8B: 4C 61 CE
Loc_CE8E:  ; (dispatch callback target)
  JSR $DDAD                               ; $CE8E: 20 AD DD
  BCC $CEAC                               ; $CE91: 90 19
  LDY #$3D                                ; $CE93: A0 3D
  JSR $EE07                               ; $CE95: 20 07 EE
; --- Data Region ---
  .byte $24,$A0,$EE,$01,$04,$AD,$2C,$04,$C9,$29,$F0,$05,$A0,$00,$8C,$01; $CE98: 24 A0 EE 01 04 AD 2C 04 C9 29 F0 05 A0 00 8C 01
  .byte $04                               ; $CEA8: 04
Loc_CEA9:
; --- Code Region ---
  JMP $F26D                               ; $CEA9: 4C 6D F2
Loc_CEAC:
  RTS                                     ; $CEAC: 60
Loc_CEAD:  ; (dispatch callback target)
  JSR $D5BD                               ; $CEAD: 20 BD D5
  LDA a:$0013                             ; $CEB0: AD 13 00
  BEQ $CEC6                               ; $CEB3: F0 11
  CMP #$FF                                ; $CEB5: C9 FF
  BNE $CEC7                               ; $CEB7: D0 0E
  JSR $DD70                               ; $CEB9: 20 70 DD
  LDA #$02                                ; $CEBC: A9 02
  STA $0400                               ; $CEBE: 8D 00 04
  LDA #$00                                ; $CEC1: A9 00
  STA $0401                               ; $CEC3: 8D 01 04
Loc_CEC6:
  RTS                                     ; $CEC6: 60
Loc_CEC7:
  LDA $0470                               ; $CEC7: AD 70 04
  JSR $DD56                               ; $CECA: 20 56 DD
  LDA $0471                               ; $CECD: AD 71 04
  JSR $D508                               ; $CED0: 20 08 D5
  LDA $0471                               ; $CED3: AD 71 04
  JSR $DD56                               ; $CED6: 20 56 DD
  LDA $0470                               ; $CED9: AD 70 04
  JSR $D508                               ; $CEDC: 20 08 D5
  LDA $0471                               ; $CEDF: AD 71 04
  JSR $DD56                               ; $CEE2: 20 56 DD
  STA $042C                               ; $CEE5: 8D 2C 04
  LDA #$80                                ; $CEE8: A9 80
  STA $0473                               ; $CEEA: 8D 73 04
  LDA #$0E                                ; $CEED: A9 0E
  STA $0401                               ; $CEEF: 8D 01 04
  LDA #$44                                ; $CEF2: A9 44
  JMP $F26D                               ; $CEF4: 4C 6D F2
Loc_CEF7:  ; (dispatch callback target)
  LDA $0470                               ; $CEF7: AD 70 04
  JSR $F2AF                               ; $CEFA: 20 AF F2
  JSR $DC6B                               ; $CEFD: 20 6B DC
  CPX #$0A                                ; $CF00: E0 0A
  BEQ $CF0F                               ; $CF02: F0 0B
  JSR $D568                               ; $CF04: 20 68 D5
  INC $0401                               ; $CF07: EE 01 04
  LDA #$3E                                ; $CF0A: A9 3E
  JMP $F26D                               ; $CF0C: 4C 6D F2
Loc_CF0F:
  LDA #$0E                                ; $CF0F: A9 0E
  STA $0401                               ; $CF11: 8D 01 04
  LDA #$80                                ; $CF14: A9 80
  STA $0473                               ; $CF16: 8D 73 04
  LDA #$47                                ; $CF19: A9 47
  JMP $F26D                               ; $CF1B: 4C 6D F2
Loc_CF1E:  ; (dispatch callback target)
  JSR $DDF2                               ; $CF1E: 20 F2 DD
  JSR $DDAD                               ; $CF21: 20 AD DD
  BCC $CF8C                               ; $CF24: 90 66
  LDA a:$0081                             ; $CF26: AD 81 00
  LSR                                     ; $CF29: 4A
  BCC $CF5E                               ; $CF2A: 90 32
  JSR $DEBA                               ; $CF2C: 20 BA DE
  CPY #$FF                                ; $CF2F: C0 FF
  BEQ $CF82                               ; $CF31: F0 4F
  STY $0402                               ; $CF33: 8C 02 04
  TYA                                     ; $CF36: 98
  STA $0471                               ; $CF37: 8D 71 04
  JSR $F2AF                               ; $CF3A: 20 AF F2
  LDY #$00                                ; $CF3D: A0 00
  LDA ($00),Y                             ; $CF3F: B1 00
  AND #$07                                ; $CF41: 29 07
  CMP #$07                                ; $CF43: C9 07
  BEQ $CF7D                               ; $CF45: F0 36
  CMP $6F03                               ; $CF47: CD 03 6F
  BEQ $CF87                               ; $CF4A: F0 3B
  INC $0401                               ; $CF4C: EE 01 04
  LDA #$80                                ; $CF4F: A9 80
  STA $0478                               ; $CF51: 8D 78 04
  LDA #$0F                                ; $CF54: A9 0F
  STA $047C                               ; $CF56: 8D 7C 04
  LDA #$48                                ; $CF59: A9 48
  JMP $F26D                               ; $CF5B: 4C 6D F2
Loc_CF5E:
  LSR                                     ; $CF5E: 4A
  BCC $CF8C                               ; $CF5F: 90 2B
  JSR $DDAD                               ; $CF61: 20 AD DD
  BCC $CF8C                               ; $CF64: 90 26
  LDA #$FF                                ; $CF66: A9 FF
  STA $04E4                               ; $CF68: 8D E4 04
  LDA #$02                                ; $CF6B: A9 02
  STA $0400                               ; $CF6D: 8D 00 04
  LDA #$00                                ; $CF70: A9 00
  STA $0401                               ; $CF72: 8D 01 04
  LDA #$02                                ; $CF75: A9 02
  JSR $D58C                               ; $CF77: 20 8C D5
  JMP $CF8C                               ; $CF7A: 4C 8C CF
Loc_CF7D:
  LDA #$46                                ; $CF7D: A9 46
  JMP $F26D                               ; $CF7F: 4C 6D F2
Loc_CF82:
  LDA #$24                                ; $CF82: A9 24
  JMP $F26D                               ; $CF84: 4C 6D F2
Loc_CF87:
  LDA #$40                                ; $CF87: A9 40
  JMP $F26D                               ; $CF89: 4C 6D F2
Loc_CF8C:
  RTS                                     ; $CF8C: 60
Loc_CF8D:  ; (dispatch callback target)
  LDA $0478                               ; $CF8D: AD 78 04
  BNE $CFE3                               ; $CF90: D0 51
  LDA #$FF                                ; $CF92: A9 FF
  STA $04E4                               ; $CF94: 8D E4 04
  JSR $D64A                               ; $CF97: 20 4A D6
  LDA $047C                               ; $CF9A: AD 7C 04
  BPL $CFE3                               ; $CF9D: 10 44
  CMP #$90                                ; $CF9F: C9 90
  BEQ $CFD4                               ; $CFA1: F0 31
  CMP #$81                                ; $CFA3: C9 81
  BEQ $CFC5                               ; $CFA5: F0 1E
  LDA $0481                               ; $CFA7: AD 81 04
  STA $042C                               ; $CFAA: 8D 2C 04
  INC $0401                               ; $CFAD: EE 01 04
  LDA $0470                               ; $CFB0: AD 70 04
  STA $0402                               ; $CFB3: 8D 02 04
  LDA #$80                                ; $CFB6: A9 80
  STA $0478                               ; $CFB8: 8D 78 04
  LDA #$0F                                ; $CFBB: A9 0F
  STA $047C                               ; $CFBD: 8D 7C 04
  LDA #$27                                ; $CFC0: A9 27
  JMP $F26D                               ; $CFC2: 4C 6D F2
Loc_CFC5:
  LDA #$0F                                ; $CFC5: A9 0F
  STA $047C                               ; $CFC7: 8D 7C 04
  LDA #$80                                ; $CFCA: A9 80
  STA $0478                               ; $CFCC: 8D 78 04
  LDA #$4A                                ; $CFCF: A9 4A
  JMP $F26D                               ; $CFD1: 4C 6D F2
Loc_CFD4:
  LDA #$02                                ; $CFD4: A9 02
  STA $0400                               ; $CFD6: 8D 00 04
  LDA #$00                                ; $CFD9: A9 00
  STA $0401                               ; $CFDB: 8D 01 04
  LDA #$02                                ; $CFDE: A9 02
  JSR $D58C                               ; $CFE0: 20 8C D5
Loc_CFE3:
  RTS                                     ; $CFE3: 60
Loc_CFE4:  ; (dispatch callback target)
  LDA $0478                               ; $CFE4: AD 78 04
  BNE $D01E                               ; $CFE7: D0 35
  JSR $D64A                               ; $CFE9: 20 4A D6
  LDA $047C                               ; $CFEC: AD 7C 04
  BPL $D01E                               ; $CFEF: 10 2D
  CMP #$90                                ; $CFF1: C9 90
  BEQ $D00F                               ; $CFF3: F0 1A
  CMP #$81                                ; $CFF5: C9 81
  BNE $CFFC                               ; $CFF7: D0 03
  JSR $D7A8                               ; $CFF9: 20 A8 D7
Loc_CFFC:
  LDA #$02                                ; $CFFC: A9 02
  JSR $D58C                               ; $CFFE: 20 8C D5
  INC $0401                               ; $D001: EE 01 04
  JSR $DD70                               ; $D004: 20 70 DD
  STA $046C                               ; $D007: 8D 6C 04
  LDA #$29                                ; $D00A: A9 29
  JMP $F26D                               ; $D00C: 4C 6D F2
Loc_D00F:
  LDA #$02                                ; $D00F: A9 02
  STA $0400                               ; $D011: 8D 00 04
  LDA #$00                                ; $D014: A9 00
  STA $0401                               ; $D016: 8D 01 04
  LDA #$02                                ; $D019: A9 02
  JSR $D58C                               ; $D01B: 20 8C D5
Loc_D01E:
  RTS                                     ; $D01E: 60
Loc_D01F:  ; (dispatch callback target)
  JSR $D5BD                               ; $D01F: 20 BD D5
  LDA a:$0013                             ; $D022: AD 13 00
  BEQ $D035                               ; $D025: F0 0E
  CMP #$FF                                ; $D027: C9 FF
  BNE $D036                               ; $D029: D0 0B
  LDA #$02                                ; $D02B: A9 02
  STA $0400                               ; $D02D: 8D 00 04
  LDA #$00                                ; $D030: A9 00
  STA $0401                               ; $D032: 8D 01 04
Loc_D035:
  RTS                                     ; $D035: 60
Loc_D036:
  LDA $0472                               ; $D036: AD 72 04
  BNE $D03E                               ; $D039: D0 03
  JMP $D066                               ; $D03B: 4C 66 D0
Loc_D03E:
  LDA #$13                                ; $D03E: A9 13
  STA $04A2                               ; $D040: 8D A2 04
  JSR $D2E3                               ; $D043: 20 E3 D2
  JSR $E843                               ; $D046: 20 43 E8
  CMP a:$0001                             ; $D049: CD 01 00
  BCC $D051                               ; $D04C: 90 03
  JMP $D0C3                               ; $D04E: 4C C3 D0
Loc_D051:
  JSR $D41B                               ; $D051: 20 1B D4
  LDA #$4B                                ; $D054: A9 4B
  STA $0470                               ; $D056: 8D 70 04
  LDA #$02                                ; $D059: A9 02
  STA $0473                               ; $D05B: 8D 73 04
  LDA #$03                                ; $D05E: A9 03
  STA a:$00A4                             ; $D060: 8D A4 00
  JMP $D0DB                               ; $D063: 4C DB D0
Loc_D066:
  LDA #$04                                ; $D066: A9 04
  STA $04A2                               ; $D068: 8D A2 04
  JSR $D3C5                               ; $D06B: 20 C5 D3
  JSR $E843                               ; $D06E: 20 43 E8
  CMP a:$0001                             ; $D071: CD 01 00
  BCC $D079                               ; $D074: 90 03
  JMP $D0C3                               ; $D076: 4C C3 D0
Loc_D079:
  LDA $0481                               ; $D079: AD 81 04
  JSR $F2D7                               ; $D07C: 20 D7 F2
  LDY #$02                                ; $D07F: A0 02
  LDA ($00),Y                             ; $D081: B1 00
  STA a:$0001                             ; $D083: 8D 01 00
  LDA #$14                                ; $D086: A9 14
  STA a:$0003                             ; $D088: 8D 03 00
  LDA #$00                                ; $D08B: A9 00
  STA a:$0002                             ; $D08D: 8D 02 00
  STA a:$0004                             ; $D090: 8D 04 00
  JSR $EA7C                               ; $D093: 20 7C EA
  JSR $E850                               ; $D096: 20 50 E8
  CLC                                     ; $D099: 18
  ADC a:$0001                             ; $D09A: 6D 01 00
  BEQ $D0C3                               ; $D09D: F0 24
  STA a:$0010                             ; $D09F: 8D 10 00
  LDA $042C                               ; $D0A2: AD 2C 04
  JSR $F2D7                               ; $D0A5: 20 D7 F2
  LDY #$03                                ; $D0A8: A0 03
  LDA ($00),Y                             ; $D0AA: B1 00
  SEC                                     ; $D0AC: 38
  SBC a:$0010                             ; $D0AD: ED 10 00
  BCS $D0B4                               ; $D0B0: B0 02
  LDA #$00                                ; $D0B2: A9 00
Loc_D0B4:
  STA ($00),Y                             ; $D0B4: 91 00
  LDA #$4E                                ; $D0B6: A9 4E
  STA $0470                               ; $D0B8: 8D 70 04
  LDA #$03                                ; $D0BB: A9 03
  STA a:$00A4                             ; $D0BD: 8D A4 00
  JMP $D0DB                               ; $D0C0: 4C DB D0
Loc_D0C3:
  LDA #$04                                ; $D0C3: A9 04
  STA a:$00A4                             ; $D0C5: 8D A4 00
  LDA #$4C                                ; $D0C8: A9 4C
  STA $0470                               ; $D0CA: 8D 70 04
  JMP $D0DB                               ; $D0CD: 4C DB D0
; --- Data Region ---
  .byte $AD,$81,$04,$8D,$2D,$04,$A9,$4D,$8D,$70,$04; $D0D0: AD 81 04 8D 2D 04 A9 4D 8D 70 04
Loc_D0DB:
; --- Code Region ---
  JSR $D568                               ; $D0DB: 20 68 D5
  LDA #$0C                                ; $D0DE: A9 0C
  STA $0401                               ; $D0E0: 8D 01 04
  LDA #$00                                ; $D0E3: A9 00
  JMP $F29B                               ; $D0E5: 4C 9B F2
Loc_D0E8:  ; (dispatch callback target)
  LDA $0140                               ; $D0E8: AD 40 01
  BNE $D0FB                               ; $D0EB: D0 0E
  LDA $04A2                               ; $D0ED: AD A2 04
  STA $04A0                               ; $D0F0: 8D A0 04
  INC $0401                               ; $D0F3: EE 01 04
  LDA #$60                                ; $D0F6: A9 60
  STA $046C                               ; $D0F8: 8D 6C 04
Loc_D0FB:
  RTS                                     ; $D0FB: 60
Loc_D0FC:  ; (dispatch callback target)
  LDA $04A0                               ; $D0FC: AD A0 04
  BNE $D13E                               ; $D0FF: D0 3D
  LDA #$02                                ; $D101: A9 02
  JSR $D58C                               ; $D103: 20 8C D5
  LDA $0473                               ; $D106: AD 73 04
  CMP #$01                                ; $D109: C9 01
  BNE $D11F                               ; $D10B: D0 12
  LDA #$0F                                ; $D10D: A9 0F
  STA $0401                               ; $D10F: 8D 01 04
  LDA $6F44                               ; $D112: AD 44 6F
  EOR #$01                                ; $D115: 49 01
  STA $6F44                               ; $D117: 8D 44 6F
  LDA #$E2                                ; $D11A: A9 E2
  JMP $F28B                               ; $D11C: 4C 8B F2
Loc_D11F:
  CMP #$03                                ; $D11F: C9 03
  BNE $D128                               ; $D121: D0 05
  LDA #$10                                ; $D123: A9 10
  STA $0401                               ; $D125: 8D 01 04
Loc_D128:
  INC $0401                               ; $D128: EE 01 04
  LDA $0481                               ; $D12B: AD 81 04
  STA a:$0000                             ; $D12E: 8D 00 00
  LDY #$3D                                ; $D131: A0 3D
  JSR $EE07                               ; $D133: 20 07 EE
; --- Data Region ---
  .byte $2A,$A0,$AD,$70,$04,$4C,$6D,$F2   ; $D136: 2A A0 AD 70 04 4C 6D F2
Loc_D13E:
; --- Code Region ---
  RTS                                     ; $D13E: 60
Loc_D13F:  ; (dispatch callback target)
  JSR $DDAD                               ; $D13F: 20 AD DD
  BCC $D183                               ; $D142: 90 3F
  JSR $D543                               ; $D144: 20 43 D5
  LDA a:$0081                             ; $D147: AD 81 00
  AND #$03                                ; $D14A: 29 03
  BEQ $D183                               ; $D14C: F0 35
  JSR $D568                               ; $D14E: 20 68 D5
  LDA #$00                                ; $D151: A9 00
  STA $0400                               ; $D153: 8D 00 04
  STA $0401                               ; $D156: 8D 01 04
  LDA $0473                               ; $D159: AD 73 04
  CMP #$81                                ; $D15C: C9 81
  BNE $D16B                               ; $D15E: D0 0B
  LDA $6F44                               ; $D160: AD 44 6F
  EOR #$01                                ; $D163: 49 01
  STA $6F44                               ; $D165: 8D 44 6F
  JMP $D183                               ; $D168: 4C 83 D1
Loc_D16B:
  CMP #$02                                ; $D16B: C9 02
  BNE $D183                               ; $D16D: D0 14
  LDA $0471                               ; $D16F: AD 71 04
  JSR $F2AF                               ; $D172: 20 AF F2
  LDY #$11                                ; $D175: A0 11
  LDA ($00),Y                             ; $D177: B1 00
  CMP #$FF                                ; $D179: C9 FF
  BNE $D183                               ; $D17B: D0 06
  LDY #$00                                ; $D17D: A0 00
  LDA #$07                                ; $D17F: A9 07
  STA ($00),Y                             ; $D181: 91 00
Loc_D183:
  LDA $0473                               ; $D183: AD 73 04
  BMI $D18E                               ; $D186: 30 06
  LDA $0481                               ; $D188: AD 81 04
  JSR $DD5E                               ; $D18B: 20 5E DD
Loc_D18E:
  RTS                                     ; $D18E: 60
Loc_D18F:  ; (dispatch callback target)
  JSR $DDAD                               ; $D18F: 20 AD DD
  BCC $D183                               ; $D192: 90 EF
  JSR $D543                               ; $D194: 20 43 D5
  LDA a:$0081                             ; $D197: AD 81 00
  AND #$03                                ; $D19A: 29 03
  BEQ $D1B8                               ; $D19C: F0 1A
  INC $0401                               ; $D19E: EE 01 04
  LDA #$00                                ; $D1A1: A9 00
  STA a:$00A4                             ; $D1A3: 8D A4 00
  LDA $0481                               ; $D1A6: AD 81 04
  STA a:$0000                             ; $D1A9: 8D 00 00
  LDY #$3D                                ; $D1AC: A0 3D
  JSR $EE07                               ; $D1AE: 20 07 EE
; --- Data Region ---
  .byte $2A,$A0,$A9,$EF,$4C,$6D,$F2       ; $D1B1: 2A A0 A9 EF 4C 6D F2
Loc_D1B8:
; --- Code Region ---
  RTS                                     ; $D1B8: 60
Loc_D1B9:  ; (dispatch callback target)
  LDA $0481                               ; $D1B9: AD 81 04
  JSR $DD5E                               ; $D1BC: 20 5E DD
  JSR $DDAD                               ; $D1BF: 20 AD DD
  BCC $D22E                               ; $D1C2: 90 6A
  LDA #$2F                                ; $D1C4: A9 2F
  STA a:$0010                             ; $D1C6: 8D 10 00
  LDA #$D2                                ; $D1C9: A9 D2
  STA a:$0011                             ; $D1CB: 8D 11 00
  LDA #$00                                ; $D1CE: A9 00
  STA a:$0012                             ; $D1D0: 8D 12 00
  JSR $ED1E                               ; $D1D3: 20 1E ED
  LDA #$33                                ; $D1D6: A9 33
  STA a:$0010                             ; $D1D8: 8D 10 00
  LDA #$D2                                ; $D1DB: A9 D2
  STA a:$0011                             ; $D1DD: 8D 11 00
  LDA #$37                                ; $D1E0: A9 37
  STA a:$0000                             ; $D1E2: 8D 00 00
  LDA #$D2                                ; $D1E5: A9 D2
  STA a:$0001                             ; $D1E7: 8D 01 00
  LDA a:$0012                             ; $D1EA: AD 12 00
  JSR $EDF5                               ; $D1ED: 20 F5 ED
  LDA a:$0081                             ; $D1F0: AD 81 00
  AND #$01                                ; $D1F3: 29 01
  BEQ $D22E                               ; $D1F5: F0 37
  LDA #$0E                                ; $D1F7: A9 0E
  STA $0401                               ; $D1F9: 8D 01 04
  LDA #$81                                ; $D1FC: A9 81
  STA $0473                               ; $D1FE: 8D 73 04
  LDA $042D                               ; $D201: AD 2D 04
  STA $042C                               ; $D204: 8D 2C 04
  LDA a:$0012                             ; $D207: AD 12 00
  BNE $D229                               ; $D20A: D0 1D
  LDA $0482                               ; $D20C: AD 82 04
  JSR $DD56                               ; $D20F: 20 56 DD
  LDA $0483                               ; $D212: AD 83 04
  JSR $D508                               ; $D215: 20 08 D5
  LDA $0483                               ; $D218: AD 83 04
  JSR $DD56                               ; $D21B: 20 56 DD
  LDA $0482                               ; $D21E: AD 82 04
  JSR $D508                               ; $D221: 20 08 D5
  LDA #$E4                                ; $D224: A9 E4
  JMP $F28B                               ; $D226: 4C 8B F2
Loc_D229:
  LDA #$E5                                ; $D229: A9 E5
  JMP $F28B                               ; $D22B: 4C 8B F2
Loc_D22E:
  RTS                                     ; $D22E: 60
; --- Data Region ---
  .byte $00,$01,$FF,$FF,$D0,$58,$D0       ; $D22F: 00 01 FF FF D0 58 D0
Loc_D236:
  .byte $98,$00,$07,$00,$00,$80,$AD,$81,$04,$20,$5E,$DD,$20,$AD,$DD,$90; $D236: 98 00 07 00 00 80 AD 81 04 20 5E DD 20 AD DD 90
  .byte $E7,$A9,$D6,$8D,$10,$00,$A9,$D2,$8D,$11,$00,$A9,$00,$8D,$12,$00; $D246: E7 A9 D6 8D 10 00 A9 D2 8D 11 00 A9 00 8D 12 00
  .byte $20,$1E,$ED,$A9,$DA,$8D,$10,$00,$A9,$D2,$8D,$11,$00,$A9,$DE,$8D; $D256: 20 1E ED A9 DA 8D 10 00 A9 D2 8D 11 00 A9 DE 8D
  .byte $00,$00,$A9,$D2,$8D,$01,$00,$AD,$12,$00,$20,$F5,$ED,$AD,$81,$00; $D266: 00 00 A9 D2 8D 01 00 AD 12 00 20 F5 ED AD 81 00
  .byte $29,$01,$D0,$01,$60               ; $D276: 29 01 D0 01 60
Loc_D27B:
; --- Code Region ---
  LDA #$80                                ; $D27B: A9 80
  STA $0473                               ; $D27D: 8D 73 04
  LDA #$0E                                ; $D280: A9 0E
  STA $0401                               ; $D282: 8D 01 04
  LDA a:$0012                             ; $D285: AD 12 00
  BEQ $D28F                               ; $D288: F0 05
  LDA #$E5                                ; $D28A: A9 E5
  JMP $F28B                               ; $D28C: 4C 8B F2
Loc_D28F:
  LDY #$39                                ; $D28F: A0 39
  JSR $EE07                               ; $D291: 20 07 EE
; --- Data Region ---
  .byte $30,$A0,$AD,$2D,$04,$F0,$2C,$AD,$72,$04,$20,$56,$DD,$AD,$71,$04; $D294: 30 A0 AD 2D 04 F0 2C AD 72 04 20 56 DD AD 71 04
  .byte $20,$08,$D5,$AD,$71,$04,$20,$56,$DD,$AD,$72,$04,$20,$08,$D5,$A9; $D2A4: 20 08 D5 AD 71 04 20 56 DD AD 72 04 20 08 D5 A9
  .byte $00,$8D,$73,$04,$A9,$03,$8D,$A4,$00,$A9,$02,$20,$8C,$D5,$A9,$E4; $D2B4: 00 8D 73 04 A9 03 8D A4 00 A9 02 20 8C D5 A9 E4
  .byte $4C,$8B,$F2                       ; $D2C4: 4C 8B F2
Loc_D2C7:
; --- Code Region ---
  LDX #$2A                                ; $D2C7: A2 2A
  LDA $042E                               ; $D2C9: AD 2E 04
  CMP #$F0                                ; $D2CC: C9 F0
  BEQ $D2D2                               ; $D2CE: F0 02
  LDX #$ED                                ; $D2D0: A2 ED
Loc_D2D2:
  TXA                                     ; $D2D2: 8A
  JMP $F28B                               ; $D2D3: 4C 8B F2
; --- Data Region ---
  .byte $00,$01,$FF,$FF,$D8,$57,$D8,$97,$00,$07,$00,$00,$80; $D2D6: 00 01 FF FF D8 57 D8 97 00 07 00 00 80
Loc_D2E3:
; --- Code Region ---
  LDA $042C                               ; $D2E3: AD 2C 04
  JSR $F2D7                               ; $D2E6: 20 D7 F2
  LDY #$03                                ; $D2E9: A0 03
  LDX #$00                                ; $D2EB: A2 00
  LDA ($00),Y                             ; $D2ED: B1 00
  CMP #$1F                                ; $D2EF: C9 1F
  BCC $D317                               ; $D2F1: 90 24
  LDX #$04                                ; $D2F3: A2 04
  CMP #$29                                ; $D2F5: C9 29
  BCC $D317                               ; $D2F7: 90 1E
  LDX #$08                                ; $D2F9: A2 08
  CMP #$33                                ; $D2FB: C9 33
  BCC $D317                               ; $D2FD: 90 18
  LDX #$0C                                ; $D2FF: A2 0C
  CMP #$3D                                ; $D301: C9 3D
  BCC $D317                               ; $D303: 90 12
  LDX #$10                                ; $D305: A2 10
  CMP #$47                                ; $D307: C9 47
  BCC $D317                               ; $D309: 90 0C
  LDX #$14                                ; $D30B: A2 14
  CMP #$4C                                ; $D30D: C9 4C
  BCC $D317                               ; $D30F: 90 06
  LDA #$00                                ; $D311: A9 00
  STA a:$0001                             ; $D313: 8D 01 00
  RTS                                     ; $D316: 60
Loc_D317:
  LDA $D3AD,X                             ; $D317: BD AD D3
  STA a:$0010                             ; $D31A: 8D 10 00
  LDA $D3AE,X                             ; $D31D: BD AE D3
  STA a:$0011                             ; $D320: 8D 11 00
  LDA $D3AF,X                             ; $D323: BD AF D3
  STA a:$0012                             ; $D326: 8D 12 00
  LDA $D3B0,X                             ; $D329: BD B0 D3
  STA a:$0013                             ; $D32C: 8D 13 00
  LDA $0481                               ; $D32F: AD 81 04
  JSR $F2D7                               ; $D332: 20 D7 F2
  LDY #$0B                                ; $D335: A0 0B
  LDA ($00),Y                             ; $D337: B1 00
  LSR                                     ; $D339: 4A
  LSR                                     ; $D33A: 4A
  LSR                                     ; $D33B: 4A
  LSR                                     ; $D33C: 4A
  PHA                                     ; $D33D: 48
  LDY #$02                                ; $D33E: A0 02
  LDA ($00),Y                             ; $D340: B1 00
  STA a:$0003                             ; $D342: 8D 03 00
  LDY #$04                                ; $D345: A0 04
  LDA ($00),Y                             ; $D347: B1 00
  STA a:$0000                             ; $D349: 8D 00 00
  LDA #$00                                ; $D34C: A9 00
  STA a:$0001                             ; $D34E: 8D 01 00
  STA a:$0002                             ; $D351: 8D 02 00
  JSR $EBE9                               ; $D354: 20 E9 EB
  LDA a:$0006                             ; $D357: AD 06 00
  CLC                                     ; $D35A: 18
  ADC a:$0010                             ; $D35B: 6D 10 00
  STA a:$0010                             ; $D35E: 8D 10 00
  LDA a:$0007                             ; $D361: AD 07 00
  ADC a:$0011                             ; $D364: 6D 11 00
  STA a:$0011                             ; $D367: 8D 11 00
  PLA                                     ; $D36A: 68
  STA a:$0000                             ; $D36B: 8D 00 00
  LDA #$00                                ; $D36E: A9 00
  STA a:$0001                             ; $D370: 8D 01 00
  STA a:$0002                             ; $D373: 8D 02 00
  LDA #$64                                ; $D376: A9 64
  STA a:$0003                             ; $D378: 8D 03 00
  JSR $EBE9                               ; $D37B: 20 E9 EB
  LDA a:$0006                             ; $D37E: AD 06 00
  CLC                                     ; $D381: 18
  ADC a:$0010                             ; $D382: 6D 10 00
  STA a:$0010                             ; $D385: 8D 10 00
  LDA a:$0007                             ; $D388: AD 07 00
  ADC a:$0011                             ; $D38B: 6D 11 00
  STA a:$0011                             ; $D38E: 8D 11 00
  LDA a:$0010                             ; $D391: AD 10 00
  STA a:$0001                             ; $D394: 8D 01 00
  LDA a:$0011                             ; $D397: AD 11 00
  STA a:$0002                             ; $D39A: 8D 02 00
  LDA a:$0012                             ; $D39D: AD 12 00
  STA a:$0003                             ; $D3A0: 8D 03 00
  LDA a:$0013                             ; $D3A3: AD 13 00
  STA a:$0004                             ; $D3A6: 8D 04 00
  JSR $EA7C                               ; $D3A9: 20 7C EA
  RTS                                     ; $D3AC: 60
; --- Data Region ---
  .byte $88,$13,$FA,$00,$A0,$0F,$C2,$01,$B8,$0B,$84,$03,$D0,$07,$14,$05; $D3AD: 88 13 FA 00 A0 0F C2 01 B8 0B 84 03 D0 07 14 05
  .byte $E8,$03,$D0,$07,$00,$00,$60,$09   ; $D3BD: E8 03 D0 07 00 00 60 09
Loc_D3C5:
; --- Code Region ---
  LDA $042C                               ; $D3C5: AD 2C 04
  JSR $F2D7                               ; $D3C8: 20 D7 F2
  LDY #$03                                ; $D3CB: A0 03
  LDA ($00),Y                             ; $D3CD: B1 00
  STA a:$0003                             ; $D3CF: 8D 03 00
  LDA #$62                                ; $D3D2: A9 62
  SEC                                     ; $D3D4: 38
  SBC a:$0003                             ; $D3D5: ED 03 00
  BCS $D3DC                               ; $D3D8: B0 02
  LDA #$00                                ; $D3DA: A9 00
Loc_D3DC:
  STA a:$0003                             ; $D3DC: 8D 03 00
  LDA $0481                               ; $D3DF: AD 81 04
  JSR $F2D7                               ; $D3E2: 20 D7 F2
  LDY #$02                                ; $D3E5: A0 02
  LDA ($00),Y                             ; $D3E7: B1 00
  STA a:$0004                             ; $D3E9: 8D 04 00
  LDY #$04                                ; $D3EC: A0 04
  LDA ($00),Y                             ; $D3EE: B1 00
  CLC                                     ; $D3F0: 18
  ADC a:$0004                             ; $D3F1: 6D 04 00
  STA a:$0000                             ; $D3F4: 8D 00 00
  LDA #$00                                ; $D3F7: A9 00
  STA a:$0001                             ; $D3F9: 8D 01 00
  STA a:$0002                             ; $D3FC: 8D 02 00
  JSR $EBE9                               ; $D3FF: 20 E9 EB
  LDA a:$0006                             ; $D402: AD 06 00
  STA a:$0001                             ; $D405: 8D 01 00
  LDA a:$0007                             ; $D408: AD 07 00
  STA a:$0002                             ; $D40B: 8D 02 00
  LDA #$64                                ; $D40E: A9 64
  STA a:$0003                             ; $D410: 8D 03 00
  LDA #$00                                ; $D413: A9 00
  STA a:$0004                             ; $D415: 8D 04 00
  JMP $EA7C                               ; $D418: 4C 7C EA
Loc_D41B:
  LDA $0470                               ; $D41B: AD 70 04
  JSR $F2AF                               ; $D41E: 20 AF F2
  LDY #$10                                ; $D421: A0 10
Loc_D423:
  INY                                     ; $D423: C8
  LDA ($00),Y                             ; $D424: B1 00
  CMP #$FF                                ; $D426: C9 FF
  BNE $D423                               ; $D428: D0 F9
  LDA $042C                               ; $D42A: AD 2C 04
  STA ($00),Y                             ; $D42D: 91 00
  LDA $0471                               ; $D42F: AD 71 04
  JSR $F2AF                               ; $D432: 20 AF F2
  LDY #$10                                ; $D435: A0 10
Loc_D437:
  INY                                     ; $D437: C8
  LDA ($00),Y                             ; $D438: B1 00
  CMP $042C                               ; $D43A: CD 2C 04
  BNE $D437                               ; $D43D: D0 F8
Loc_D43F:
  INY                                     ; $D43F: C8
  CPY #$1B                                ; $D440: C0 1B
  BEQ $D44D                               ; $D442: F0 09
  LDA ($00),Y                             ; $D444: B1 00
  DEY                                     ; $D446: 88
  STA ($00),Y                             ; $D447: 91 00
  INY                                     ; $D449: C8
  JMP $D43F                               ; $D44A: 4C 3F D4
Loc_D44D:
  DEY                                     ; $D44D: 88
  LDA #$FF                                ; $D44E: A9 FF
  STA ($00),Y                             ; $D450: 91 00
  LDA $042C                               ; $D452: AD 2C 04
  STA a:$0031                             ; $D455: 8D 31 00
  LDA $0470                               ; $D458: AD 70 04
  JSR $DD4F                               ; $D45B: 20 4F DD
  STA a:$0030                             ; $D45E: 8D 30 00
  LDA $0471                               ; $D461: AD 71 04
  JSR $DD4F                               ; $D464: 20 4F DD
  STA a:$0032                             ; $D467: 8D 32 00
  LDY #$2A                                ; $D46A: A0 2A
  JSR $EE07                               ; $D46C: 20 07 EE
; --- Data Region ---
  .byte $06,$A0,$60,$A0,$00,$AE,$10,$00   ; $D46F: 06 A0 60 A0 00 AE 10 00
Loc_D477:
; --- Code Region ---
  LDA ($00),Y                             ; $D477: B1 00
  BEQ $D492                               ; $D479: F0 17
  CMP #$39                                ; $D47B: C9 39
  BEQ $D489                               ; $D47D: F0 0A
  CMP #$3A                                ; $D47F: C9 3A
  BEQ $D489                               ; $D481: F0 06
  STA $0182,X                             ; $D483: 9D 82 01
  JMP $D48D                               ; $D486: 4C 8D D4
Loc_D489:
  DEX                                     ; $D489: CA
  STA $0162,X                             ; $D48A: 9D 62 01
Loc_D48D:
  INX                                     ; $D48D: E8
  INY                                     ; $D48E: C8
  JMP $D477                               ; $D48F: 4C 77 D4
Loc_D492:
  LDX a:$0010                             ; $D492: AE 10 00
  LDA $0470                               ; $D495: AD 70 04
  JSR $DD56                               ; $D498: 20 56 DD
  LDA $0472                               ; $D49B: AD 72 04
  JSR $D4ED                               ; $D49E: 20 ED D4
  BNE $D4B5                               ; $D4A1: D0 12
  LDA #$32                                ; $D4A3: A9 32
  STA $018A,X                             ; $D4A5: 9D 8A 01
  STA $018B,X                             ; $D4A8: 9D 8B 01
  STA $018C,X                             ; $D4AB: 9D 8C 01
  STA $018D,X                             ; $D4AE: 9D 8D 01
  STA $018E,X                             ; $D4B1: 9D 8E 01
  RTS                                     ; $D4B4: 60
Loc_D4B5:
  STA a:$0001                             ; $D4B5: 8D 01 00
  LDA #$00                                ; $D4B8: A9 00
  STA a:$0002                             ; $D4BA: 8D 02 00
  STA a:$0003                             ; $D4BD: 8D 03 00
  JSR $E9BA                               ; $D4C0: 20 BA E9
  LDA a:$0007                             ; $D4C3: AD 07 00
  LSR                                     ; $D4C6: 4A
  LSR                                     ; $D4C7: 4A
  LSR                                     ; $D4C8: 4A
  LSR                                     ; $D4C9: 4A
  BEQ $D4D2                               ; $D4CA: F0 06
  CLC                                     ; $D4CC: 18
  ADC #$76                                ; $D4CD: 69 76
  STA $018D,X                             ; $D4CF: 9D 8D 01
Loc_D4D2:
  LDA a:$0007                             ; $D4D2: AD 07 00
  AND #$0F                                ; $D4D5: 29 0F
  CLC                                     ; $D4D7: 18
  ADC #$76                                ; $D4D8: 69 76
  STA $018E,X                             ; $D4DA: 9D 8E 01
  LDA #$1C                                ; $D4DD: A9 1C
  STA $018A,X                             ; $D4DF: 9D 8A 01
  LDA #$0D                                ; $D4E2: A9 0D
  STA $018B,X                             ; $D4E4: 9D 8B 01
  LDA #$2B                                ; $D4E7: A9 2B
  STA $018C,X                             ; $D4E9: 9D 8C 01
  RTS                                     ; $D4EC: 60
Loc_D4ED:
  STA a:$0002                             ; $D4ED: 8D 02 00
  LSR                                     ; $D4F0: 4A
  CLC                                     ; $D4F1: 18
  ADC #$04                                ; $D4F2: 69 04
  TAY                                     ; $D4F4: A8
  LDA a:$0002                             ; $D4F5: AD 02 00
  AND #$01                                ; $D4F8: 29 01
  BNE $D501                               ; $D4FA: D0 05
  LDA ($00),Y                             ; $D4FC: B1 00
  AND #$0F                                ; $D4FE: 29 0F
  RTS                                     ; $D500: 60
Loc_D501:
  LDA ($00),Y                             ; $D501: B1 00
  LSR                                     ; $D503: 4A
  LSR                                     ; $D504: 4A
  LSR                                     ; $D505: 4A
  LSR                                     ; $D506: 4A
  RTS                                     ; $D507: 60
Loc_D508:
  STA a:$0010                             ; $D508: 8D 10 00
  LSR                                     ; $D50B: 4A
  CLC                                     ; $D50C: 18
  ADC #$04                                ; $D50D: 69 04
  TAY                                     ; $D50F: A8
  LDA $0401                               ; $D510: AD 01 04
  CMP #$06                                ; $D513: C9 06
  BEQ $D52D                               ; $D515: F0 16
  LDX #$0C                                ; $D517: A2 0C
  LDA a:$0010                             ; $D519: AD 10 00
  AND #$01                                ; $D51C: 29 01
  BEQ $D522                               ; $D51E: F0 02
  LDX #$C0                                ; $D520: A2 C0
Loc_D522:
  STX a:$0010                             ; $D522: 8E 10 00
  LDA ($00),Y                             ; $D525: B1 00
  ORA a:$0010                             ; $D527: 0D 10 00
  STA ($00),Y                             ; $D52A: 91 00
  RTS                                     ; $D52C: 60
Loc_D52D:
  LDX #$F0                                ; $D52D: A2 F0
  LDA a:$0010                             ; $D52F: AD 10 00
  AND #$01                                ; $D532: 29 01
  BEQ $D538                               ; $D534: F0 02
  LDX #$0F                                ; $D536: A2 0F
Loc_D538:
  STX a:$0010                             ; $D538: 8E 10 00
  LDA ($00),Y                             ; $D53B: B1 00
  AND a:$0010                             ; $D53D: 2D 10 00
  STA ($00),Y                             ; $D540: 91 00
  RTS                                     ; $D542: 60
Loc_D543:
  LDA a:$005E                             ; $D543: AD 5E 00
  AND #$10                                ; $D546: 29 10
  BEQ $D562                               ; $D548: F0 18
  LDA #$00                                ; $D54A: A9 00
  STA a:$0002                             ; $D54C: 8D 02 00
  STA a:$000A                             ; $D54F: 8D 0A 00
  STA a:$000C                             ; $D552: 8D 0C 00
  LDA #$63                                ; $D555: A9 63
  STA a:$0000                             ; $D557: 8D 00 00
  LDA #$D5                                ; $D55A: A9 D5
  STA a:$0001                             ; $D55C: 8D 01 00
  JMP $F1AD                               ; $D55F: 4C AD F1
Loc_D562:
  RTS                                     ; $D562: 60
; --- Data Region ---
  .byte $D9,$04,$00,$7C,$80               ; $D563: D9 04 00 7C 80
Loc_D568:
; --- Code Region ---
  LDA #$80                                ; $D568: A9 80
  STA $0140                               ; $D56A: 8D 40 01
  LDX #$00                                ; $D56D: A2 00
  LDA $6F3F                               ; $D56F: AD 3F 6F
  BMI $D576                               ; $D572: 30 02
  LDX #$80                                ; $D574: A2 80
Loc_D576:
  STX $0150                               ; $D576: 8E 50 01
  LDA $6F3F                               ; $D579: AD 3F 6F
  STA $046D                               ; $D57C: 8D 6D 04
  LDA $6F41                               ; $D57F: AD 41 6F
  STA $046E                               ; $D582: 8D 6E 04
  LDA $0402                               ; $D585: AD 02 04
  STA $046F                               ; $D588: 8D 6F 04
  RTS                                     ; $D58B: 60
Loc_D58C:
  STA $0150                               ; $D58C: 8D 50 01
  LDA $046D                               ; $D58F: AD 6D 04
  STA $6F3F                               ; $D592: 8D 3F 6F
  LDA $046E                               ; $D595: AD 6E 04
  STA $6F41                               ; $D598: 8D 41 6F
  JSR MapRulerMarkerDraw                  ; $D59B: 20 83 DE
  LDA $046F                               ; $D59E: AD 6F 04
  STA $0402                               ; $D5A1: 8D 02 04
  JSR $F2AF                               ; $D5A4: 20 AF F2
  LDY #$80                                ; $D5A7: A0 80
  STY $0140                               ; $D5A9: 8C 40 01
  LDX #$00                                ; $D5AC: A2 00
  LDA $6F3F                               ; $D5AE: AD 3F 6F
  BMI $D5B5                               ; $D5B1: 30 02
  LDX #$80                                ; $D5B3: A2 80
Loc_D5B5:
  TXA                                     ; $D5B5: 8A
  ORA $0150                               ; $D5B6: 0D 50 01
  STA $0150                               ; $D5B9: 8D 50 01
  RTS                                     ; $D5BC: 60
Loc_D5BD:
  LDA $046C                               ; $D5BD: AD 6C 04
  BNE $D614                               ; $D5C0: D0 52
  LDA #$3D                                ; $D5C2: A9 3D
  STA a:$0010                             ; $D5C4: 8D 10 00
  LDA #$D6                                ; $D5C7: A9 D6
  STA a:$0011                             ; $D5C9: 8D 11 00
  LDA #$00                                ; $D5CC: A9 00
  STA a:$0012                             ; $D5CE: 8D 12 00
  JSR $ED1E                               ; $D5D1: 20 1E ED
  LDA #$41                                ; $D5D4: A9 41
  STA a:$0010                             ; $D5D6: 8D 10 00
  LDA #$D6                                ; $D5D9: A9 D6
  STA a:$0011                             ; $D5DB: 8D 11 00
  LDA #$45                                ; $D5DE: A9 45
  STA a:$0000                             ; $D5E0: 8D 00 00
  LDA #$D6                                ; $D5E3: A9 D6
  STA a:$0001                             ; $D5E5: 8D 01 00
  LDA a:$0012                             ; $D5E8: AD 12 00
  JSR $EDF5                               ; $D5EB: 20 F5 ED
  LDA #$00                                ; $D5EE: A9 00
  STA a:$0013                             ; $D5F0: 8D 13 00
  JSR $DDAD                               ; $D5F3: 20 AD DD
  BCC $D606                               ; $D5F6: 90 0E
  LDA a:$0081                             ; $D5F8: AD 81 00
  LSR                                     ; $D5FB: 4A
  BCS $D607                               ; $D5FC: B0 09
  LSR                                     ; $D5FE: 4A
  BCC $D606                               ; $D5FF: 90 05
Loc_D601:
  LDA #$FF                                ; $D601: A9 FF
  STA a:$0013                             ; $D603: 8D 13 00
Loc_D606:
  RTS                                     ; $D606: 60
Loc_D607:
  LDA a:$0012                             ; $D607: AD 12 00
  BNE $D601                               ; $D60A: D0 F5
  LDA #$80                                ; $D60C: A9 80
  STA $046C                               ; $D60E: 8D 6C 04
  JMP $D628                               ; $D611: 4C 28 D6
Loc_D614:
  LDA $046C                               ; $D614: AD 6C 04
  CMP #$01                                ; $D617: C9 01
  BNE $D628                               ; $D619: D0 0D
  LDA #$80                                ; $D61B: A9 80
  STA a:$0013                             ; $D61D: 8D 13 00
  LDY #$3D                                ; $D620: A0 3D
  JSR $EE07                               ; $D622: 20 07 EE
; --- Data Region ---
  .byte $24,$A0,$60,$A0,$3D,$20,$07,$EE,$2D,$A0,$AD,$6C,$04,$C9,$40,$D0; $D625: 24 A0 60 A0 3D 20 07 EE 2D A0 AD 6C 04 C9 40 D0
  .byte $03,$CE,$05,$6F                   ; $D635: 03 CE 05 6F
Loc_D639:
; --- Code Region ---
  DEC $046C                               ; $D639: CE 6C 04
  RTS                                     ; $D63C: 60
; --- Data Region ---
  .byte $00,$01,$FF,$FF,$C8,$60,$C8,$A0,$00,$07,$00,$00,$80; $D63D: 00 01 FF FF C8 60 C8 A0 00 07 00 00 80
Loc_D64A:
; --- Code Region ---
  LDA $0425                               ; $D64A: AD 25 04
  STA a:$0013                             ; $D64D: 8D 13 00
  LDA #$4C                                ; $D650: A9 4C
  STA a:$0010                             ; $D652: 8D 10 00
  LDA #$D7                                ; $D655: A9 D7
  STA a:$0011                             ; $D657: 8D 11 00
  LDA #$00                                ; $D65A: A9 00
  STA a:$0012                             ; $D65C: 8D 12 00
  JSR $ED19                               ; $D65F: 20 19 ED
  LDA a:$0012                             ; $D662: AD 12 00
  CMP $047B                               ; $D665: CD 7B 04
  BEQ $D67C                               ; $D668: F0 12
  BCC $D67C                               ; $D66A: 90 10
  LDX $047B                               ; $D66C: AE 7B 04
  LDA a:$0013                             ; $D66F: AD 13 00
  BEQ $D676                               ; $D672: F0 02
  LDX #$00                                ; $D674: A2 00
Loc_D676:
  STX a:$0012                             ; $D676: 8E 12 00
  STX $0425                               ; $D679: 8E 25 04
Loc_D67C:
  LDA #$58                                ; $D67C: A9 58
  STA a:$0010                             ; $D67E: 8D 10 00
  LDA #$D7                                ; $D681: A9 D7
  STA a:$0011                             ; $D683: 8D 11 00
  LDA #$6E                                ; $D686: A9 6E
  STA a:$0000                             ; $D688: 8D 00 00
  LDA #$D7                                ; $D68B: A9 D7
  STA a:$0001                             ; $D68D: 8D 01 00
  LDA a:$0012                             ; $D690: AD 12 00
  STA $047A                               ; $D693: 8D 7A 04
  JSR $EDF5                               ; $D696: 20 F5 ED
  JSR $DDAD                               ; $D699: 20 AD DD
  BCC $D6B9                               ; $D69C: 90 1B
  LDA $047C                               ; $D69E: AD 7C 04
  CMP #$10                                ; $D6A1: C9 10
  BNE $D6A8                               ; $D6A3: D0 03
  JMP $D7C5                               ; $D6A5: 4C C5 D7
Loc_D6A8:
  LDA a:$0081                             ; $D6A8: AD 81 00
  LSR                                     ; $D6AB: 4A
  BCS $D6BA                               ; $D6AC: B0 0C
  LSR                                     ; $D6AE: 4A
  BCC $D6B9                               ; $D6AF: 90 08
  LDA #$90                                ; $D6B1: A9 90
  STA $047C                               ; $D6B3: 8D 7C 04
  JMP $D7A8                               ; $D6B6: 4C A8 D7
Loc_D6B9:
  RTS                                     ; $D6B9: 60
Loc_D6BA:
  LDA $047C                               ; $D6BA: AD 7C 04
  CMP #$0F                                ; $D6BD: C9 0F
  BEQ $D6F6                               ; $D6BF: F0 35
  LDA a:$0012                             ; $D6C1: AD 12 00
  CMP $047B                               ; $D6C4: CD 7B 04
  BNE $D6F6                               ; $D6C7: D0 2D
  LDX #$00                                ; $D6C9: A2 00
  LDY #$00                                ; $D6CB: A0 00
Loc_D6CD:
  LDA $0481,Y                             ; $D6CD: B9 81 04
  CMP #$FF                                ; $D6D0: C9 FF
  BEQ $D6E5                               ; $D6D2: F0 11
  STA $0481,X                             ; $D6D4: 9D 81 04
  STX a:$0000                             ; $D6D7: 8E 00 00
  CPY a:$0000                             ; $D6DA: CC 00 00
  BEQ $D6E4                               ; $D6DD: F0 05
  LDA #$FF                                ; $D6DF: A9 FF
  STA $0481,Y                             ; $D6E1: 99 81 04
Loc_D6E4:
  INX                                     ; $D6E4: E8
Loc_D6E5:
  INY                                     ; $D6E5: C8
  CPY #$0A                                ; $D6E6: C0 0A
  BCC $D6CD                               ; $D6E8: 90 E3
  CPX #$00                                ; $D6EA: E0 00
  BEQ $D6B9                               ; $D6EC: F0 CB
  LDA #$81                                ; $D6EE: A9 81
  STA $047C                               ; $D6F0: 8D 7C 04
  JMP $D7A8                               ; $D6F3: 4C A8 D7
Loc_D6F6:
  LDY a:$0012                             ; $D6F6: AC 12 00
  LDA $047C                               ; $D6F9: AD 7C 04
  CMP #$0F                                ; $D6FC: C9 0F
  BEQ $D72D                               ; $D6FE: F0 2D
  LDA $0481,Y                             ; $D700: B9 81 04
  CMP #$FF                                ; $D703: C9 FF
  BNE $D71D                               ; $D705: D0 16
  LDA $047C                               ; $D707: AD 7C 04
  BEQ $D6B9                               ; $D70A: F0 AD
  LDA $0151,Y                             ; $D70C: B9 51 01
  STA $0481,Y                             ; $D70F: 99 81 04
  DEC $047C                               ; $D712: CE 7C 04
  LDA #$3E                                ; $D715: A9 3E
  JSR $D773                               ; $D717: 20 73 D7
  JMP $D6B9                               ; $D71A: 4C B9 D6
Loc_D71D:
  LDA #$FF                                ; $D71D: A9 FF
  STA $0481,Y                             ; $D71F: 99 81 04
  INC $047C                               ; $D722: EE 7C 04
  LDA #$01                                ; $D725: A9 01
  JSR $D773                               ; $D727: 20 73 D7
  JMP $D6B9                               ; $D72A: 4C B9 D6
Loc_D72D:
  LDA $0151,Y                             ; $D72D: B9 51 01
  STA $0481                               ; $D730: 8D 81 04
  LDA $0402                               ; $D733: AD 02 04
  JSR $DD4F                               ; $D736: 20 4F DD
  CMP $0481                               ; $D739: CD 81 04
  BEQ $D746                               ; $D73C: F0 08
  LDA #$80                                ; $D73E: A9 80
  STA $047C                               ; $D740: 8D 7C 04
  JMP $D7A8                               ; $D743: 4C A8 D7
Loc_D746:
  LDA #$81                                ; $D746: A9 81
  STA $047C                               ; $D748: 8D 7C 04
  RTS                                     ; $D74B: 60
; --- Data Region ---
  .byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$FF,$27,$08,$37,$08; $D74C: 00 01 02 03 04 05 06 07 08 09 0A FF 27 08 37 08
  .byte $47,$08,$57,$08,$67,$08,$77,$08,$87,$08,$97,$08,$A7,$08,$B7,$08; $D75C: 47 08 57 08 67 08 77 08 87 08 97 08 A7 08 B7 08
  .byte $C7,$08,$00,$07,$00,$00,$80       ; $D76C: C7 08 00 07 00 00 80
Loc_D773:
; --- Code Region ---
  STA $031E                               ; $D773: 8D 1E 03
  LDA #$80                                ; $D776: A9 80
  STA $031F                               ; $D778: 8D 1F 03
  LDA #$40                                ; $D77B: A9 40
  STA a:$0000                             ; $D77D: 8D 00 00
  LDA #$00                                ; $D780: A9 00
  STA a:$0001                             ; $D782: 8D 01 00
  STA a:$0002                             ; $D785: 8D 02 00
  STY a:$0003                             ; $D788: 8C 03 00
  JSR $EBE9                               ; $D78B: 20 E9 EB
  LDA #$A2                                ; $D78E: A9 A2
  CLC                                     ; $D790: 18
  ADC a:$0006                             ; $D791: 6D 06 00
  STA $031C                               ; $D794: 8D 1C 03
  LDA #$24                                ; $D797: A9 24
  ADC a:$0007                             ; $D799: 6D 07 00
  STA $031D                               ; $D79C: 8D 1D 03
  LDA a:$007E                             ; $D79F: AD 7E 00
  ORA #$01                                ; $D7A2: 09 01
  STA a:$007E                             ; $D7A4: 8D 7E 00
  RTS                                     ; $D7A7: 60
Loc_D7A8:
  LDA #$00                                ; $D7A8: A9 00
  STA a:$008F                             ; $D7AA: 8D 8F 00
  LDA #$03                                ; $D7AD: A9 03
  STA a:$0061                             ; $D7AF: 8D 61 00
  LDA a:$00C2                             ; $D7B2: AD C2 00
  LDA #$00                                ; $D7B5: A9 00
  STA a:$00B2                             ; $D7B7: 8D B2 00
  LDA #$05                                ; $D7BA: A9 05
  STA a:$00B3                             ; $D7BC: 8D B3 00
  LDA #$09                                ; $D7BF: A9 09
  STA a:$00B4                             ; $D7C1: 8D B4 00
  RTS                                     ; $D7C4: 60
Loc_D7C5:
  LDA a:$0012                             ; $D7C5: AD 12 00
  CMP $047B                               ; $D7C8: CD 7B 04
  BEQ $D7D7                               ; $D7CB: F0 0A
  LDA a:$0081                             ; $D7CD: AD 81 00
  AND #$C0                                ; $D7D0: 29 C0
  BNE $D805                               ; $D7D2: D0 31
  JMP $D908                               ; $D7D4: 4C 08 D9
Loc_D7D7:
  LDA a:$0081                             ; $D7D7: AD 81 00
  LSR                                     ; $D7DA: 4A
  BCS $D7E0                               ; $D7DB: B0 03
  JMP $D908                               ; $D7DD: 4C 08 D9
Loc_D7E0:
  LDA #$80                                ; $D7E0: A9 80
  STA $047C                               ; $D7E2: 8D 7C 04
  LDA #$00                                ; $D7E5: A9 00
  STA a:$0090                             ; $D7E7: 8D 90 00
  STA a:$008F                             ; $D7EA: 8D 8F 00
  LDA #$03                                ; $D7ED: A9 03
  STA a:$0061                             ; $D7EF: 8D 61 00
  LDA a:$00C2                             ; $D7F2: AD C2 00
  LDA #$00                                ; $D7F5: A9 00
  STA a:$00B2                             ; $D7F7: 8D B2 00
  LDA #$05                                ; $D7FA: A9 05
  STA a:$00B3                             ; $D7FC: 8D B3 00
  LDA #$09                                ; $D7FF: A9 09
  STA a:$00B4                             ; $D801: 8D B4 00
  RTS                                     ; $D804: 60
Loc_D805:
  LDA $0402                               ; $D805: AD 02 04
  JSR $F2AF                               ; $D808: 20 AF F2
  LDA a:$0012                             ; $D80B: AD 12 00
  CLC                                     ; $D80E: 18
  ADC #$11                                ; $D80F: 69 11
  TAY                                     ; $D811: A8
  LDA ($00),Y                             ; $D812: B1 00
  JSR $F2D7                               ; $D814: 20 D7 F2
  LDY #$08                                ; $D817: A0 08
  LDA ($00),Y                             ; $D819: B1 00
  STA a:$0002                             ; $D81B: 8D 02 00
  INY                                     ; $D81E: C8
  LDA ($00),Y                             ; $D81F: B1 00
  STA a:$0003                             ; $D821: 8D 03 00
  LDA a:$0081                             ; $D824: AD 81 00
  ASL                                     ; $D827: 0A
  BCC $D874                               ; $D828: 90 4A
  LDA #$E7                                ; $D82A: A9 E7
  SEC                                     ; $D82C: 38
  SBC a:$0002                             ; $D82D: ED 02 00
  LDA #$03                                ; $D830: A9 03
  SBC a:$0003                             ; $D832: ED 03 00
  BCC $D871                               ; $D835: 90 3A
  JSR $D987                               ; $D837: 20 87 D9
  LDX #$64                                ; $D83A: A2 64
  LDA $042D                               ; $D83C: AD 2D 04
  BNE $D84B                               ; $D83F: D0 0A
  LDA $042C                               ; $D841: AD 2C 04
  CMP #$64                                ; $D844: C9 64
  BCS $D84B                               ; $D846: B0 03
  LDX $042C                               ; $D848: AE 2C 04
Loc_D84B:
  STX a:$0002                             ; $D84B: 8E 02 00
  LDY #$08                                ; $D84E: A0 08
  LDA ($00),Y                             ; $D850: B1 00
  CLC                                     ; $D852: 18
  ADC a:$0002                             ; $D853: 6D 02 00
  STA ($00),Y                             ; $D856: 91 00
  INY                                     ; $D858: C8
  LDA ($00),Y                             ; $D859: B1 00
  ADC #$00                                ; $D85B: 69 00
  STA ($00),Y                             ; $D85D: 91 00
  LDA $042C                               ; $D85F: AD 2C 04
  SEC                                     ; $D862: 38
  SBC a:$0002                             ; $D863: ED 02 00
  STA $042C                               ; $D866: 8D 2C 04
  LDA $042D                               ; $D869: AD 2D 04
  SBC #$00                                ; $D86C: E9 00
  STA $042D                               ; $D86E: 8D 2D 04
Loc_D871:
  JMP $D8B4                               ; $D871: 4C B4 D8
Loc_D874:
  LDA a:$0003                             ; $D874: AD 03 00
  BNE $D87E                               ; $D877: D0 05
  LDA a:$0002                             ; $D879: AD 02 00
  BEQ $D8B4                               ; $D87C: F0 36
Loc_D87E:
  JSR $D987                               ; $D87E: 20 87 D9
  LDA a:$0005                             ; $D881: AD 05 00
  BNE $D8B4                               ; $D884: D0 2E
  LDA $042C                               ; $D886: AD 2C 04
  SEC                                     ; $D889: 38
  SBC #$AD                                ; $D88A: E9 AD
  LDA $042D                               ; $D88C: AD 2D 04
  SBC #$26                                ; $D88F: E9 26
  BCS $D8B4                               ; $D891: B0 21
  LDY #$08                                ; $D893: A0 08
  LDA ($00),Y                             ; $D895: B1 00
  SEC                                     ; $D897: 38
  SBC #$64                                ; $D898: E9 64
  STA ($00),Y                             ; $D89A: 91 00
  INY                                     ; $D89C: C8
  LDA ($00),Y                             ; $D89D: B1 00
  SBC #$00                                ; $D89F: E9 00
  STA ($00),Y                             ; $D8A1: 91 00
  LDA $042C                               ; $D8A3: AD 2C 04
  CLC                                     ; $D8A6: 18
  ADC #$64                                ; $D8A7: 69 64
  STA $042C                               ; $D8A9: 8D 2C 04
  LDA $042D                               ; $D8AC: AD 2D 04
  ADC #$00                                ; $D8AF: 69 00
  STA $042D                               ; $D8B1: 8D 2D 04
Loc_D8B4:
  LDY #$08                                ; $D8B4: A0 08
  LDA ($00),Y                             ; $D8B6: B1 00
  STA a:$0003                             ; $D8B8: 8D 03 00
  INY                                     ; $D8BB: C8
  LDA ($00),Y                             ; $D8BC: B1 00
  STA a:$0002                             ; $D8BE: 8D 02 00
  LDA a:$0003                             ; $D8C1: AD 03 00
  STA a:$0001                             ; $D8C4: 8D 01 00
  LDA #$00                                ; $D8C7: A9 00
  STA a:$0003                             ; $D8C9: 8D 03 00
  JSR $E9BA                               ; $D8CC: 20 BA E9
  LDY #$01                                ; $D8CF: A0 01
  STY a:$000A                             ; $D8D1: 8C 0A 00
  LDX #$00                                ; $D8D4: A2 00
  JSR $D94E                               ; $D8D6: 20 4E D9
  LDA #$80                                ; $D8D9: A9 80
  STA $031E,X                             ; $D8DB: 9D 1E 03
  LDA #$40                                ; $D8DE: A9 40
  STA a:$0000                             ; $D8E0: 8D 00 00
  LDA #$00                                ; $D8E3: A9 00
  STA a:$0001                             ; $D8E5: 8D 01 00
  STA a:$0002                             ; $D8E8: 8D 02 00
  LDA a:$0012                             ; $D8EB: AD 12 00
  STA a:$0003                             ; $D8EE: 8D 03 00
  JSR $EBE9                               ; $D8F1: 20 E9 EB
  LDA a:$0006                             ; $D8F4: AD 06 00
  CLC                                     ; $D8F7: 18
  ADC #$BB                                ; $D8F8: 69 BB
  STA $031C                               ; $D8FA: 8D 1C 03
  LDA a:$0007                             ; $D8FD: AD 07 00
  ADC #$24                                ; $D900: 69 24
  STA $031D                               ; $D902: 8D 1D 03
  JMP $D93D                               ; $D905: 4C 3D D9
Loc_D908:
  LDA $042C                               ; $D908: AD 2C 04
  STA a:$0001                             ; $D90B: 8D 01 00
  LDA $042D                               ; $D90E: AD 2D 04
  STA a:$0002                             ; $D911: 8D 02 00
  LDA #$00                                ; $D914: A9 00
  STA a:$0003                             ; $D916: 8D 03 00
  JSR $E9BA                               ; $D919: 20 BA E9
  LDX #$00                                ; $D91C: A2 00
  LDY #$01                                ; $D91E: A0 01
  STY a:$000A                             ; $D920: 8C 0A 00
  LDA a:$0009                             ; $D923: AD 09 00
  AND #$0F                                ; $D926: 29 0F
  JSR $D96F                               ; $D928: 20 6F D9
  JSR $D94E                               ; $D92B: 20 4E D9
  LDA #$80                                ; $D92E: A9 80
  STA $031E,X                             ; $D930: 9D 1E 03
  LDA #$3A                                ; $D933: A9 3A
  STA $031C                               ; $D935: 8D 1C 03
  LDA #$27                                ; $D938: A9 27
  STA $031D                               ; $D93A: 8D 1D 03
Loc_D93D:
  LDA #$01                                ; $D93D: A9 01
  STA $0303                               ; $D93F: 8D 03 03
  STA $030C                               ; $D942: 8D 0C 03
  LDA a:$007E                             ; $D945: AD 7E 00
  ORA #$01                                ; $D948: 09 01
  STA a:$007E                             ; $D94A: 8D 7E 00
  RTS                                     ; $D94D: 60
Loc_D94E:
  LDA a:$0007,Y                           ; $D94E: B9 07 00
  LSR                                     ; $D951: 4A
  LSR                                     ; $D952: 4A
  LSR                                     ; $D953: 4A
  LSR                                     ; $D954: 4A
  JSR $D96F                               ; $D955: 20 6F D9
  CPY #$00                                ; $D958: C0 00
  BNE $D961                               ; $D95A: D0 05
  LDA #$76                                ; $D95C: A9 76
  STA a:$000A                             ; $D95E: 8D 0A 00
Loc_D961:
  LDA a:$0007,Y                           ; $D961: B9 07 00
  AND #$0F                                ; $D964: 29 0F
  JSR $D96F                               ; $D966: 20 6F D9
  DEY                                     ; $D969: 88
  CPY #$FF                                ; $D96A: C0 FF
  BNE $D94E                               ; $D96C: D0 E0
  RTS                                     ; $D96E: 60
Loc_D96F:
  BEQ $D97F                               ; $D96F: F0 0E
  CLC                                     ; $D971: 18
  ADC #$76                                ; $D972: 69 76
  STA $031E,X                             ; $D974: 9D 1E 03
  LDA #$76                                ; $D977: A9 76
  STA a:$000A                             ; $D979: 8D 0A 00
  JMP $D985                               ; $D97C: 4C 85 D9
Loc_D97F:
  LDA a:$000A                             ; $D97F: AD 0A 00
  STA $031E,X                             ; $D982: 9D 1E 03
Loc_D985:
  INX                                     ; $D985: E8
  RTS                                     ; $D986: 60
Loc_D987:
  LDA a:$0000                             ; $D987: AD 00 00
  STA a:$0010                             ; $D98A: 8D 10 00
  LDA a:$0001                             ; $D98D: AD 01 00
  STA a:$0011                             ; $D990: 8D 11 00
  LDA a:$0002                             ; $D993: AD 02 00
  STA a:$0001                             ; $D996: 8D 01 00
  LDA a:$0003                             ; $D999: AD 03 00
  STA a:$0002                             ; $D99C: 8D 02 00
  LDA #$64                                ; $D99F: A9 64
  STA a:$0003                             ; $D9A1: 8D 03 00
  LDA #$00                                ; $D9A4: A9 00
  STA a:$0004                             ; $D9A6: 8D 04 00
  JSR $EA7C                               ; $D9A9: 20 7C EA
  LDA a:$0005                             ; $D9AC: AD 05 00
  BEQ $D9E4                               ; $D9AF: F0 33
  CLC                                     ; $D9B1: 18
  ADC $042C                               ; $D9B2: 6D 2C 04
  STA $042C                               ; $D9B5: 8D 2C 04
  LDA #$00                                ; $D9B8: A9 00
  ADC $042D                               ; $D9BA: 6D 2D 04
  STA $042D                               ; $D9BD: 8D 2D 04
  LDA $042C                               ; $D9C0: AD 2C 04
  SEC                                     ; $D9C3: 38
  SBC #$10                                ; $D9C4: E9 10
  STA a:$0006                             ; $D9C6: 8D 06 00
  LDA $042D                               ; $D9C9: AD 2D 04
  SBC #$27                                ; $D9CC: E9 27
  BCC $D9E4                               ; $D9CE: 90 14
  LDA #$10                                ; $D9D0: A9 10
  STA $042C                               ; $D9D2: 8D 2C 04
  LDA #$27                                ; $D9D5: A9 27
  STA $042D                               ; $D9D7: 8D 2D 04
  LDA a:$0005                             ; $D9DA: AD 05 00
  SEC                                     ; $D9DD: 38
  SBC a:$0006                             ; $D9DE: ED 06 00
  STA a:$0005                             ; $D9E1: 8D 05 00
Loc_D9E4:
  LDA a:$0010                             ; $D9E4: AD 10 00
  STA a:$0000                             ; $D9E7: 8D 00 00
  LDA a:$0011                             ; $D9EA: AD 11 00
  STA a:$0001                             ; $D9ED: 8D 01 00
  LDY #$08                                ; $D9F0: A0 08
  LDA ($00),Y                             ; $D9F2: B1 00
  SEC                                     ; $D9F4: 38
  SBC a:$0005                             ; $D9F5: ED 05 00
  STA ($00),Y                             ; $D9F8: 91 00
  INY                                     ; $D9FA: C8
  LDA ($00),Y                             ; $D9FB: B1 00
  SBC #$00                                ; $D9FD: E9 00
  STA ($00),Y                             ; $D9FF: 91 00
  RTS                                     ; $DA01: 60
Loc_DA02:
  LDA #$03                                ; $DA02: A9 03
Loc_DA04:
  STA a:$001F                             ; $DA04: 8D 1F 00
  LDA $048E                               ; $DA07: AD 8E 04
  STA a:$0014                             ; $DA0A: 8D 14 00
  LDA $048F                               ; $DA0D: AD 8F 04
  STA a:$0015                             ; $DA10: 8D 15 00
  LDA a:$0081                             ; $DA13: AD 81 00
  ASL                                     ; $DA16: 0A
  BCC $DA24                               ; $DA17: 90 0B
  LDA $048B                               ; $DA19: AD 8B 04
  BEQ $DA91                               ; $DA1C: F0 73
  DEC $048B                               ; $DA1E: CE 8B 04
  JMP $DA91                               ; $DA21: 4C 91 DA
Loc_DA24:
  ASL                                     ; $DA24: 0A
  BCC $DA35                               ; $DA25: 90 0E
  LDA $048B                               ; $DA27: AD 8B 04
  CMP a:$001F                             ; $DA2A: CD 1F 00
  BEQ $DA91                               ; $DA2D: F0 62
  INC $048B                               ; $DA2F: EE 8B 04
  JMP $DA91                               ; $DA32: 4C 91 DA
Loc_DA35:
  ASL                                     ; $DA35: 0A
  BCC $DA51                               ; $DA36: 90 19
  JSR $DB09                               ; $DA38: 20 09 DB
  LDA $048E                               ; $DA3B: AD 8E 04
  SEC                                     ; $DA3E: 38
  SBC a:$0000                             ; $DA3F: ED 00 00
  STA $048E                               ; $DA42: 8D 8E 04
  LDA $048F                               ; $DA45: AD 8F 04
  SBC a:$0001                             ; $DA48: ED 01 00
  STA $048F                               ; $DA4B: 8D 8F 04
  JMP $DA6A                               ; $DA4E: 4C 6A DA
Loc_DA51:
  ASL                                     ; $DA51: 0A
  BCC $DA91                               ; $DA52: 90 3D
  JSR $DB09                               ; $DA54: 20 09 DB
  LDA $048E                               ; $DA57: AD 8E 04
  CLC                                     ; $DA5A: 18
  ADC a:$0000                             ; $DA5B: 6D 00 00
  STA $048E                               ; $DA5E: 8D 8E 04
  LDA $048F                               ; $DA61: AD 8F 04
  ADC a:$0001                             ; $DA64: 6D 01 00
  STA $048F                               ; $DA67: 8D 8F 04
Loc_DA6A:
  LDA $048E                               ; $DA6A: AD 8E 04
  STA a:$0000                             ; $DA6D: 8D 00 00
  LDA $048F                               ; $DA70: AD 8F 04
  STA a:$0001                             ; $DA73: 8D 01 00
  LDA $0490                               ; $DA76: AD 90 04
  SEC                                     ; $DA79: 38
  SBC a:$0000                             ; $DA7A: ED 00 00
  LDA $0491                               ; $DA7D: AD 91 04
  SBC a:$0001                             ; $DA80: ED 01 00
  BCS $DA91                               ; $DA83: B0 0C
  LDA a:$0014                             ; $DA85: AD 14 00
  STA $048E                               ; $DA88: 8D 8E 04
  LDA a:$0015                             ; $DA8B: AD 15 00
  STA $048F                               ; $DA8E: 8D 8F 04
Loc_DA91:
  JSR $DDAD                               ; $DA91: 20 AD DD
  BCC $DB08                               ; $DA94: 90 72
  LDA a:$0081                             ; $DA96: AD 81 00
  AND #$03                                ; $DA99: 29 03
  STA a:$0013                             ; $DA9B: 8D 13 00
  LDA $048E                               ; $DA9E: AD 8E 04
  STA a:$0001                             ; $DAA1: 8D 01 00
  LDA $048F                               ; $DAA4: AD 8F 04
  STA a:$0002                             ; $DAA7: 8D 02 00
  LDA #$00                                ; $DAAA: A9 00
  STA a:$0003                             ; $DAAC: 8D 03 00
  JSR $E9BA                               ; $DAAF: 20 BA E9
  LDA a:$0007                             ; $DAB2: AD 07 00
  STA $048C                               ; $DAB5: 8D 8C 04
  LDA a:$0008                             ; $DAB8: AD 08 00
  STA $048D                               ; $DABB: 8D 8D 04
  LDA #$03                                ; $DABE: A9 03
  SEC                                     ; $DAC0: 38
  SBC $048B                               ; $DAC1: ED 8B 04
  STA a:$0011                             ; $DAC4: 8D 11 00
  LDA #$01                                ; $DAC7: A9 01
  STA a:$0010                             ; $DAC9: 8D 10 00
  LDY #$02                                ; $DACC: A0 02
  LDX #$00                                ; $DACE: A2 00
Loc_DAD0:
  LDA $048B,Y                             ; $DAD0: B9 8B 04
  LSR                                     ; $DAD3: 4A
  LSR                                     ; $DAD4: 4A
  LSR                                     ; $DAD5: 4A
  LSR                                     ; $DAD6: 4A
  JSR $DB35                               ; $DAD7: 20 35 DB
  CPY #$01                                ; $DADA: C0 01
  BNE $DAE3                               ; $DADC: D0 05
  LDA #$76                                ; $DADE: A9 76
  STA a:$0010                             ; $DAE0: 8D 10 00
Loc_DAE3:
  LDA $048B,Y                             ; $DAE3: B9 8B 04
  AND #$0F                                ; $DAE6: 29 0F
  JSR $DB35                               ; $DAE8: 20 35 DB
  DEY                                     ; $DAEB: 88
  CPY #$00                                ; $DAEC: C0 00
  BNE $DAD0                               ; $DAEE: D0 E0
  LDA #$80                                ; $DAF0: A9 80
  STA $031E,X                             ; $DAF2: 9D 1E 03
  LDA #$01                                ; $DAF5: A9 01
  STA $0303                               ; $DAF7: 8D 03 03
  STA $030C                               ; $DAFA: 8D 0C 03
  INC $046C                               ; $DAFD: EE 6C 04
  LDA a:$007E                             ; $DB00: AD 7E 00
  ORA #$01                                ; $DB03: 09 01
  STA a:$007E                             ; $DB05: 8D 7E 00
Loc_DB08:
  RTS                                     ; $DB08: 60
Loc_DB09:
  LDA #$00                                ; $DB09: A9 00
  STA a:$0001                             ; $DB0B: 8D 01 00
  LDA $048B                               ; $DB0E: AD 8B 04
  BNE $DB18                               ; $DB11: D0 05
  LDA #$01                                ; $DB13: A9 01
  JMP $DB31                               ; $DB15: 4C 31 DB
Loc_DB18:
  CMP #$01                                ; $DB18: C9 01
  BNE $DB21                               ; $DB1A: D0 05
  LDA #$0A                                ; $DB1C: A9 0A
  JMP $DB31                               ; $DB1E: 4C 31 DB
Loc_DB21:
  CMP #$02                                ; $DB21: C9 02
  BNE $DB2A                               ; $DB23: D0 05
  LDA #$64                                ; $DB25: A9 64
  JMP $DB31                               ; $DB27: 4C 31 DB
Loc_DB2A:
  LDA #$03                                ; $DB2A: A9 03
  STA a:$0001                             ; $DB2C: 8D 01 00
  LDA #$E8                                ; $DB2F: A9 E8
Loc_DB31:
  STA a:$0000                             ; $DB31: 8D 00 00
  RTS                                     ; $DB34: 60
Loc_DB35:
  BEQ $DB45                               ; $DB35: F0 0E
  CLC                                     ; $DB37: 18
  ADC #$76                                ; $DB38: 69 76
  STA $031E,X                             ; $DB3A: 9D 1E 03
  LDA #$76                                ; $DB3D: A9 76
  STA a:$0010                             ; $DB3F: 8D 10 00
  JMP $DB5A                               ; $DB42: 4C 5A DB
Loc_DB45:
  LDA a:$0013                             ; $DB45: AD 13 00
  BNE $DB54                               ; $DB48: D0 0A
  CPX a:$0011                             ; $DB4A: EC 11 00
  BCC $DB54                               ; $DB4D: 90 05
  LDA #$76                                ; $DB4F: A9 76
  STA a:$0010                             ; $DB51: 8D 10 00
Loc_DB54:
  LDA a:$0010                             ; $DB54: AD 10 00
  STA $031E,X                             ; $DB57: 9D 1E 03
Loc_DB5A:
  LDA a:$0013                             ; $DB5A: AD 13 00
  BNE $DB70                               ; $DB5D: D0 11
  CPX a:$0011                             ; $DB5F: EC 11 00
  BNE $DB70                               ; $DB62: D0 0C
  LDA $046C                               ; $DB64: AD 6C 04
  AND #$08                                ; $DB67: 29 08
  BNE $DB70                               ; $DB69: D0 05
  LDA #$01                                ; $DB6B: A9 01
  STA $031E,X                             ; $DB6D: 9D 1E 03
Loc_DB70:
  INX                                     ; $DB70: E8
  RTS                                     ; $DB71: 60
Loc_DB72:
  LDA a:$0006                             ; $DB72: AD 06 00
  STA a:$0000                             ; $DB75: 8D 00 00
  LDA a:$0007                             ; $DB78: AD 07 00
  STA a:$0001                             ; $DB7B: 8D 01 00
  LDA a:$0008                             ; $DB7E: AD 08 00
  STA a:$0002                             ; $DB81: 8D 02 00
  JMP $EAA5                               ; $DB84: 4C A5 EA
Loc_DB87:
  LDA #$00                                ; $DB87: A9 00
  STA $048B                               ; $DB89: 8D 8B 04
  STA $048C                               ; $DB8C: 8D 8C 04
  STA $048D                               ; $DB8F: 8D 8D 04
  STA $048E                               ; $DB92: 8D 8E 04
  STA $048F                               ; $DB95: 8D 8F 04
  RTS                                     ; $DB98: 60
Loc_DB99:
  LDA #$00                                ; $DB99: A9 00
  STA a:$0011                             ; $DB9B: 8D 11 00
  LDA $0402                               ; $DB9E: AD 02 04
  JSR $F2AF                               ; $DBA1: 20 AF F2
  JSR $DC6B                               ; $DBA4: 20 6B DC
  CPX #$0A                                ; $DBA7: E0 0A
  BNE $DBB0                               ; $DBA9: D0 05
  LDA #$80                                ; $DBAB: A9 80
  STA a:$0011                             ; $DBAD: 8D 11 00
Loc_DBB0:
  JSR $E856                               ; $DBB0: 20 56 E8
  STA a:$0010                             ; $DBB3: 8D 10 00
  LDA $0481                               ; $DBB6: AD 81 04
  JSR $F2D7                               ; $DBB9: 20 D7 F2
  LDY #$04                                ; $DBBC: A0 04
  LDA ($00),Y                             ; $DBBE: B1 00
  CMP #$29                                ; $DBC0: C9 29
  BCC $DBCC                               ; $DBC2: 90 08
  LDX #$18                                ; $DBC4: A2 18
  CMP #$51                                ; $DBC6: C9 51
  BCC $DBCC                               ; $DBC8: 90 02
  LDX #$30                                ; $DBCA: A2 30
Loc_DBCC:
  LDY #$02                                ; $DBCC: A0 02
  LDA ($00),Y                             ; $DBCE: B1 00
  CMP #$29                                ; $DBD0: C9 29
  BCC $DBE5                               ; $DBD2: 90 11
  CMP #$51                                ; $DBD4: C9 51
  BCS $DBE0                               ; $DBD6: B0 08
  TXA                                     ; $DBD8: 8A
  CLC                                     ; $DBD9: 18
  ADC #$08                                ; $DBDA: 69 08
  TAX                                     ; $DBDC: AA
  JMP $DBE5                               ; $DBDD: 4C E5 DB
Loc_DBE0:
  TXA                                     ; $DBE0: 8A
  CLC                                     ; $DBE1: 18
  ADC #$10                                ; $DBE2: 69 10
  TAX                                     ; $DBE4: AA
Loc_DBE5:
  TXA                                     ; $DBE5: 8A
  CLC                                     ; $DBE6: 18
  ADC a:$0010                             ; $DBE7: 6D 10 00
  TAY                                     ; $DBEA: A8
  LDA $DC23,Y                             ; $DBEB: B9 23 DC
  STA $0470                               ; $DBEE: 8D 70 04
  LDA a:$0011                             ; $DBF1: AD 11 00
  BEQ $DC07                               ; $DBF4: F0 11
  LDA $0470                               ; $DBF6: AD 70 04
  CMP #$05                                ; $DBF9: C9 05
  BCS $DBFE                               ; $DBFB: B0 01
  RTS                                     ; $DBFD: 60
Loc_DBFE:
  JSR $E856                               ; $DBFE: 20 56 E8
  STA a:$0010                             ; $DC01: 8D 10 00
  JMP $DBE5                               ; $DC04: 4C E5 DB
Loc_DC07:
  LDA $0470                               ; $DC07: AD 70 04
  CMP #$05                                ; $DC0A: C9 05
  BCC $DC15                               ; $DC0C: 90 07
  CMP #$08                                ; $DC0E: C9 08
  BEQ $DC15                               ; $DC10: F0 03
  JMP $DC16                               ; $DC12: 4C 16 DC
Loc_DC15:
  RTS                                     ; $DC15: 60
Loc_DC16:
  LDY #$39                                ; $DC16: A0 39
  JSR $EE07                               ; $DC18: 20 07 EE
; --- Data Region ---
  .byte $1B,$A0,$AD,$11,$00,$30,$DC,$60,$01,$01,$08,$08,$08,$08,$08,$08; $DC1B: 1B A0 AD 11 00 30 DC 60 01 01 08 08 08 08 08 08
  .byte $01,$01,$02,$02,$08,$08,$08,$08,$02,$03,$03,$04,$04,$04,$08,$08; $DC2B: 01 01 02 02 08 08 08 08 02 03 03 04 04 04 08 08
  .byte $01,$01,$02,$06,$06,$08,$08,$08,$02,$02,$06,$06,$06,$08,$08,$08; $DC3B: 01 01 02 06 06 08 08 08 02 02 06 06 06 08 08 08
  .byte $03,$04,$04,$06,$06,$06,$08,$08,$01,$01,$01,$05,$06,$06,$08,$08; $DC4B: 03 04 04 06 06 06 08 08 01 01 01 05 06 06 08 08
  .byte $03,$03,$05,$05,$06,$06,$06,$08,$03,$03,$04,$04,$05,$05,$05,$08; $DC5B: 03 03 05 05 06 06 06 08 03 03 04 04 05 05 05 08
Loc_DC6B:
; --- Code Region ---
  LDY #$11                                ; $DC6B: A0 11
  LDX #$00                                ; $DC6D: A2 00
Loc_DC6F:
  LDA ($00),Y                             ; $DC6F: B1 00
  CMP #$FF                                ; $DC71: C9 FF
  BEQ $DC76                               ; $DC73: F0 01
  INX                                     ; $DC75: E8
Loc_DC76:
  INY                                     ; $DC76: C8
  CPY #$1B                                ; $DC77: C0 1B
  BCC $DC6F                               ; $DC79: 90 F4
  RTS                                     ; $DC7B: 60
Loc_DC7C:
  LDY #$11                                ; $DC7C: A0 11
  LDA #$FF                                ; $DC7E: A9 FF
Loc_DC80:
  STA $0140,Y                             ; $DC80: 99 40 01
  INY                                     ; $DC83: C8
  CPY #$1B                                ; $DC84: C0 1B
  BCC $DC80                               ; $DC86: 90 F8
  LDA $0402                               ; $DC88: AD 02 04
  JSR $F2AF                               ; $DC8B: 20 AF F2
  LDA a:$0000                             ; $DC8E: AD 00 00
  STA a:$0010                             ; $DC91: 8D 10 00
  LDA a:$0001                             ; $DC94: AD 01 00
  STA a:$0011                             ; $DC97: 8D 11 00
  LDX #$11                                ; $DC9A: A2 11
  STX a:$0012                             ; $DC9C: 8E 12 00
Loc_DC9F:
  LDY a:$0012                             ; $DC9F: AC 12 00
  LDA ($10),Y                             ; $DCA2: B1 10
  STA a:$000A                             ; $DCA4: 8D 0A 00
  JSR $F387                               ; $DCA7: 20 87 F3
  LDY #$00                                ; $DCAA: A0 00
  LDA ($00),Y                             ; $DCAC: B1 00
  STA a:$000B                             ; $DCAE: 8D 0B 00
  LDA a:$000A                             ; $DCB1: AD 0A 00
  JSR $F2D7                               ; $DCB4: 20 D7 F2
  LDA ($00),Y                             ; $DCB7: B1 00
  CMP a:$000B                             ; $DCB9: CD 0B 00
  BEQ $DCC5                               ; $DCBC: F0 07
  LDA a:$000A                             ; $DCBE: AD 0A 00
  STA $0140,X                             ; $DCC1: 9D 40 01
  INX                                     ; $DCC4: E8
Loc_DCC5:
  INC a:$0012                             ; $DCC5: EE 12 00
  LDA a:$0012                             ; $DCC8: AD 12 00
  CMP #$1B                                ; $DCCB: C9 1B
  BCC $DC9F                               ; $DCCD: 90 D0
  RTS                                     ; $DCCF: 60
; --- Data Region ---
  .byte $AD,$70,$04,$C9,$06,$90,$1B,$C9,$09,$90,$2E,$A9,$35,$8D,$10,$00; $DCD0: AD 70 04 C9 06 90 1B C9 09 90 2E A9 35 8D 10 00
  .byte $A9,$DD,$8D,$11,$00,$A9,$47,$8D,$13,$00,$A9,$DD,$8D,$14,$00,$4C; $DCE0: A9 DD 8D 11 00 A9 47 8D 13 00 A9 DD 8D 14 00 4C
  .byte $1D,$DD                           ; $DCF0: 1D DD
Loc_DCF2:
; --- Code Region ---
  LDA #$25                                ; $DCF2: A9 25
  STA a:$0010                             ; $DCF4: 8D 10 00
  LDA #$DD                                ; $DCF7: A9 DD
  STA a:$0011                             ; $DCF9: 8D 11 00
  LDA #$3D                                ; $DCFC: A9 3D
  STA a:$0013                             ; $DCFE: 8D 13 00
  LDA #$DD                                ; $DD01: A9 DD
  STA a:$0014                             ; $DD03: 8D 14 00
  JMP $DD1D                               ; $DD06: 4C 1D DD
Loc_DD09:
  LDA #$2D                                ; $DD09: A9 2D
  STA a:$0010                             ; $DD0B: 8D 10 00
  LDA #$DD                                ; $DD0E: A9 DD
  STA a:$0011                             ; $DD10: 8D 11 00
  LDA #$41                                ; $DD13: A9 41
  STA a:$0013                             ; $DD15: 8D 13 00
  LDA #$DD                                ; $DD18: A9 DD
  STA a:$0014                             ; $DD1A: 8D 14 00
Loc_DD1D:
  LDA #$00                                ; $DD1D: A9 00
  STA a:$0012                             ; $DD1F: 8D 12 00
  JMP $ED28                               ; $DD22: 4C 28 ED
; --- Data Region ---
  .byte $00,$01,$FF,$FF,$FF,$FF,$FF,$FF,$00,$01,$02,$FF,$FF,$FF,$FF,$FF; $DD25: 00 01 FF FF FF FF FF FF 00 01 02 FF FF FF FF FF
  .byte $00,$01,$02,$03,$FF,$FF,$FF,$FF,$C0,$78,$C0,$A8,$C0,$60,$C0,$90; $DD35: 00 01 02 03 FF FF FF FF C0 78 C0 A8 C0 60 C0 90
  .byte $C0,$C0,$C0,$60,$C0,$80,$C0,$A0,$C0,$C0; $DD45: C0 C0 C0 60 C0 80 C0 A0 C0 C0
Loc_DD4F:
; --- Code Region ---
  JSR $F2AF                               ; $DD4F: 20 AF F2
  LDY #$00                                ; $DD52: A0 00
  LDA ($00),Y                             ; $DD54: B1 00
Loc_DD56:
  JSR $F368                               ; $DD56: 20 68 F3
  LDY #$00                                ; $DD59: A0 00
  LDA ($00),Y                             ; $DD5B: B1 00
  RTS                                     ; $DD5D: 60
Loc_DD5E:
  STA a:$0000                             ; $DD5E: 8D 00 00
  LDX #$00                                ; $DD61: A2 00
  LDA #$A7                                ; $DD63: A9 A7
  STA a:$000A                             ; $DD65: 8D 0A 00
  LDY #$39                                ; $DD68: A0 39
  JSR $EE07                               ; $DD6A: 20 07 EE
; --- Data Region ---
  .byte $00,$A0,$60,$A9,$00,$8D,$24,$04,$8D,$25,$04,$60; $DD6D: 00 A0 60 A9 00 8D 24 04 8D 25 04 60
Loc_DD79:
; --- Code Region ---
  LDY #$30                                ; $DD79: A0 30
  JSR $F25F                               ; $DD7B: 20 5F F2
  LDA $0470                               ; $DD7E: AD 70 04
  CMP $0402                               ; $DD81: CD 02 04
  BEQ $DD9A                               ; $DD84: F0 14
  ASL                                     ; $DD86: 0A
  ASL                                     ; $DD87: 0A
  ASL                                     ; $DD88: 0A
  TAY                                     ; $DD89: A8
Loc_DD8A:
  LDA $9D72,Y                             ; $DD8A: B9 72 9D
  CMP #$FF                                ; $DD8D: C9 FF
  BEQ $DD9A                               ; $DD8F: F0 09
  CMP $0402                               ; $DD91: CD 02 04
  BEQ $DDA0                               ; $DD94: F0 0A
  INY                                     ; $DD96: C8
  JMP $DD8A                               ; $DD97: 4C 8A DD
Loc_DD9A:
  LDA #$80                                ; $DD9A: A9 80
  STA $0402                               ; $DD9C: 8D 02 04
  RTS                                     ; $DD9F: 60
Loc_DDA0:
  JSR $F2AF                               ; $DDA0: 20 AF F2
  LDY #$00                                ; $DDA3: A0 00
  LDA ($00),Y                             ; $DDA5: B1 00
  AND #$07                                ; $DDA7: 29 07
  STA a:$0010                             ; $DDA9: 8D 10 00
  RTS                                     ; $DDAC: 60
Loc_DDAD:
  LDA $0304                               ; $DDAD: AD 04 03
  CMP #$FF                                ; $DDB0: C9 FF
  BNE $DDBD                               ; $DDB2: D0 09
  LDA $0300                               ; $DDB4: AD 00 03
  CMP #$FF                                ; $DDB7: C9 FF
  BNE $DDBD                               ; $DDB9: D0 02
  SEC                                     ; $DDBB: 38
  RTS                                     ; $DDBC: 60
Loc_DDBD:
  CLC                                     ; $DDBD: 18
  RTS                                     ; $DDBE: 60
Loc_DDBF:
  LDX #$00                                ; $DDBF: A2 00
  STX a:$0011                             ; $DDC1: 8E 11 00
Loc_DDC4:
  TXA                                     ; $DDC4: 8A
  JSR $F2AF                               ; $DDC5: 20 AF F2
  LDY #$00                                ; $DDC8: A0 00
  LDA ($00),Y                             ; $DDCA: B1 00
  AND #$07                                ; $DDCC: 29 07
  CMP a:$0010                             ; $DDCE: CD 10 00
  BNE $DDD6                               ; $DDD1: D0 03
  INC a:$0011                             ; $DDD3: EE 11 00
Loc_DDD6:
  INX                                     ; $DDD6: E8
  CPX #$1E                                ; $DDD7: E0 1E
  BCC $DDC4                               ; $DDD9: 90 E9
  RTS                                     ; $DDDB: 60
Loc_DDDC:
  LDA ($00),Y                             ; $DDDC: B1 00
  SEC                                     ; $DDDE: 38
  SBC #$10                                ; $DDDF: E9 10
  INY                                     ; $DDE1: C8
  LDA ($00),Y                             ; $DDE2: B1 00
  SBC #$27                                ; $DDE4: E9 27
  BCC $DDF1                               ; $DDE6: 90 09
  LDA #$27                                ; $DDE8: A9 27
  STA ($00),Y                             ; $DDEA: 91 00
  DEY                                     ; $DDEC: 88
  LDA #$0F                                ; $DDED: A9 0F
  STA ($00),Y                             ; $DDEF: 91 00
Loc_DDF1:
  RTS                                     ; $DDF1: 60
Loc_DDF2:
  LDA #$00                                ; $DDF2: A9 00
  STA $04E4                               ; $DDF4: 8D E4 04
  LDA $0318                               ; $DDF7: AD 18 03
  STA a:$0000                             ; $DDFA: 8D 00 00
  LDA a:$0083                             ; $DDFD: AD 83 00
  AND #$F0                                ; $DE00: 29 F0
  STA $0318                               ; $DE02: 8D 18 03
  BEQ $DE23                               ; $DE05: F0 1C
  CMP a:$0000                             ; $DE07: CD 00 00
  BNE $DE29                               ; $DE0A: D0 1D
  INC $0319                               ; $DE0C: EE 19 03
  LDA $0319                               ; $DE0F: AD 19 03
  CMP #$0F                                ; $DE12: C9 0F
  BCC $DE22                               ; $DE14: 90 0C
  LDA #$0F                                ; $DE16: A9 0F
  STA $0319                               ; $DE18: 8D 19 03
  LDA a:$005E                             ; $DE1B: AD 5E 00
  AND #$03                                ; $DE1E: 29 03
  BEQ $DE2E                               ; $DE20: F0 0C
Loc_DE22:
  RTS                                     ; $DE22: 60
Loc_DE23:
  LDA #$00                                ; $DE23: A9 00
  STA $0319                               ; $DE25: 8D 19 03
  RTS                                     ; $DE28: 60
Loc_DE29:
  LDA #$00                                ; $DE29: A9 00
  STA $0319                               ; $DE2B: 8D 19 03
Loc_DE2E:
  LDA a:$0083                             ; $DE2E: AD 83 00
  BPL $DE45                               ; $DE31: 10 12
  LDX $6F3F                               ; $DE33: AE 3F 6F
  CPX #$F8                                ; $DE36: E0 F8
  BCS $DE45                               ; $DE38: B0 0B
  PHA                                     ; $DE3A: 48
  LDA $6F3F                               ; $DE3B: AD 3F 6F
  CLC                                     ; $DE3E: 18
  ADC #$08                                ; $DE3F: 69 08
  STA $6F3F                               ; $DE41: 8D 3F 6F
  PLA                                     ; $DE44: 68
Loc_DE45:
  ASL                                     ; $DE45: 0A
  BPL $DE5A                               ; $DE46: 10 12
  LDX $6F3F                               ; $DE48: AE 3F 6F
  CPX #$10                                ; $DE4B: E0 10
  BCC $DE5A                               ; $DE4D: 90 0B
  PHA                                     ; $DE4F: 48
  LDA $6F3F                               ; $DE50: AD 3F 6F
  SEC                                     ; $DE53: 38
  SBC #$08                                ; $DE54: E9 08
  STA $6F3F                               ; $DE56: 8D 3F 6F
  PLA                                     ; $DE59: 68
Loc_DE5A:
  ASL                                     ; $DE5A: 0A
  BPL $DE6F                               ; $DE5B: 10 12
  LDX $6F41                               ; $DE5D: AE 41 6F
  CPX #$94                                ; $DE60: E0 94
  BCS $DE6F                               ; $DE62: B0 0B
  PHA                                     ; $DE64: 48
  LDA $6F41                               ; $DE65: AD 41 6F
  CLC                                     ; $DE68: 18
  ADC #$08                                ; $DE69: 69 08
  STA $6F41                               ; $DE6B: 8D 41 6F
  PLA                                     ; $DE6E: 68
Loc_DE6F:
  ASL                                     ; $DE6F: 0A
  BPL $DE82                               ; $DE70: 10 10
  LDX $6F41                               ; $DE72: AE 41 6F
  CPX #$10                                ; $DE75: E0 10
Loc_DE77:
  BCC $DE82                               ; $DE77: 90 09
  LDA $6F41                               ; $DE79: AD 41 6F
Loc_DE7C:
  SEC                                     ; $DE7C: 38
  SBC #$08                                ; $DE7D: E9 08
  STA $6F41                               ; $DE7F: 8D 41 6F
Loc_DE82:
  RTS                                     ; $DE82: 60
;-------------------------------------------------------------------------------
; MapRulerMarkerDraw ($DE83-$DEB0)
; Draws the ruler marker sprite at the camera position: loads marker template
; $DEB1 into $0000/$0001, passes camera X ($6F3F) and Y ($6F41) in $000C/$000A
; and tail-calls B1F_SpriteOamWriterSimple. Skipped while a screen transition
; ($008F) is active or overlays $04E4/$04A0 are busy.
;-------------------------------------------------------------------------------
MapRulerMarkerDraw:
  LDA a:$008F                             ; $DE83: AD 8F 00  ; screen transition flag
  BNE $DEB0                               ; $DE86: D0 28
  LDA $04E4                               ; $DE88: AD E4 04
  BNE $DEB0                               ; $DE8B: D0 23
  LDA $04A0                               ; $DE8D: AD A0 04
  BNE $DEB0                               ; $DE90: D0 1E
  LDA $6F41                               ; $DE92: AD 41 6F
  STA a:$000A                             ; $DE95: 8D 0A 00
  LDA $6F3F                               ; $DE98: AD 3F 6F
  STA a:$000C                             ; $DE9B: 8D 0C 00
  LDA #$B1                                ; $DE9E: A9 B1
  STA a:$0000                             ; $DEA0: 8D 00 00
  LDA #$DE                                ; $DEA3: A9 DE
Loc_DEA5:
  STA a:$0001                             ; $DEA5: 8D 01 00
  LDA #$00                                ; $DEA8: A9 00
  STA a:$0002                             ; $DEAA: 8D 02 00
  JMP $F1AD                               ; $DEAD: 4C AD F1
Loc_DEB0:
  RTS                                     ; $DEB0: 60
; --- Data Region ---
  .byte $00,$05,$00,$00,$08,$06,$00,$00,$80; $DEB1: 00 05 00 00 08 06 00 00 80
Loc_DEBA:
; --- Code Region ---
  LDA $6F3F                               ; $DEBA: AD 3F 6F
  CMP #$20                                ; $DEBD: C9 20
  BCS $DECB                               ; $DEBF: B0 0A
  LDA $6F41                               ; $DEC1: AD 41 6F
  CMP #$20                                ; $DEC4: C9 20
  BCS $DECB                               ; $DEC6: B0 03
  LDY #$FF                                ; $DEC8: A0 FF
  RTS                                     ; $DECA: 60
Loc_DECB:
  LDY #$1E                                ; $DECB: A0 1E
Loc_DECD:
  LDA $6F3F                               ; $DECD: AD 3F 6F
  SEC                                     ; $DED0: 38
  SBC $DEE9,Y                             ; $DED1: F9 E9 DE
  CMP #$10                                ; $DED4: C9 10
  BCS $DEE3                               ; $DED6: B0 0B
  LDA $6F41                               ; $DED8: AD 41 6F
  SEC                                     ; $DEDB: 38
  SBC $DF07,Y                             ; $DEDC: F9 07 DF
  CMP #$10                                ; $DEDF: C9 10
  BCC $DEE8                               ; $DEE1: 90 05
Loc_DEE3:
  DEY                                     ; $DEE3: 88
  BPL $DECD                               ; $DEE4: 10 E7
  LDY #$FF                                ; $DEE6: A0 FF
Loc_DEE8:
  RTS                                     ; $DEE8: 60
; --- Data Region ---
  .byte $E8,$B0,$90,$D0,$A8,$68,$38,$58,$70,$38,$D0,$B0,$90,$80,$A8,$D8; $DEE9: E8 B0 90 D0 A8 68 38 58 70 38 D0 B0 90 80 A8 D8
  .byte $C0,$D0,$B8,$68,$A8,$88,$70,$98,$80,$50,$38,$58,$40,$10,$10,$17; $DEF9: C0 D0 B8 68 A8 88 70 98 80 50 38 58 40 10 10 17
  .byte $1F,$28,$38,$17,$28,$38,$40,$40,$40,$48,$48,$50,$58,$60,$60; $DF09: 1F 28 38 17 28 38 40 40 40 48 48 50 58 60 60
Loc_DF18:
  .byte $70,$88,$88,$68,$68,$70,$78,$80,$50,$60; $DF18: 70 88 88 68 68 70 78 80 50 60
  .byte $68,$78,$78                       ; $DF22: 68 78 78
Loc_DF25:
; --- Code Region ---
  LDY a:$000A                             ; $DF25: AC 0A 00
  LDA $DEE9,Y                             ; $DF28: B9 E9 DE
Loc_DF2B:
  STA a:$000B                             ; $DF2B: 8D 0B 00
  LDA $DF07,Y                             ; $DF2E: B9 07 DF
  STA a:$000C                             ; $DF31: 8D 0C 00
  RTS                                     ; $DF34: 60
;-------------------------------------------------------------------------------
; MapProvinceSpriteRefresh ($DF35-$DF61)
; Rebuilds the animated province marker sprites in OAM page $0200. Iterates the
; 29 map zones ($000F = $1D down to 0), filters by zone flag table $DFD0 masked
; with animation frame $0420 and dirty bitmap $04E0-$04E3, then emits 4-byte
; OAM entries (tile $DFC0, attribute $DFC8, zone origin $DEE9/$DF07) via
; B1F_GetProvinceRecordAddr lookups. Clears the dirty bitmap on exit.
;-------------------------------------------------------------------------------
MapProvinceSpriteRefresh:
  LDA $0420                               ; $DF35: AD 20 04  ; animation frame mask
  STA a:$000E                             ; $DF38: 8D 0E 00
  LDA #$1D                                ; $DF3B: A9 1D
  STA a:$000F                             ; $DF3D: 8D 0F 00
  LDA a:$008F                             ; $DF40: AD 8F 00
  BNE $DF53                               ; $DF43: D0 0E
  LDX a:$007C                             ; $DF45: AE 7C 00
Loc_DF48:
  JSR $DF62                               ; $DF48: 20 62 DF
  DEC a:$000F                             ; $DF4B: CE 0F 00
  BPL $DF48                               ; $DF4E: 10 F8
  STX a:$007C                             ; $DF50: 8E 7C 00
Loc_DF53:
  LDA #$00                                ; $DF53: A9 00
  STA $04E0                               ; $DF55: 8D E0 04
  STA $04E1                               ; $DF58: 8D E1 04
  STA $04E2                               ; $DF5B: 8D E2 04
  STA $04E3                               ; $DF5E: 8D E3 04
  RTS                                     ; $DF61: 60
Loc_DF62:
  LDA a:$000F                             ; $DF62: AD 0F 00
  AND #$07                                ; $DF65: 29 07
  TAY                                     ; $DF67: A8
  LDA $DFEE,Y                             ; $DF68: B9 EE DF
  STA a:$0000                             ; $DF6B: 8D 00 00
Loc_DF6E:
  LDA a:$000F                             ; $DF6E: AD 0F 00
  LSR                                     ; $DF71: 4A
  LSR                                     ; $DF72: 4A
  LSR                                     ; $DF73: 4A
  TAY                                     ; $DF74: A8
  LDA $04E0,Y                             ; $DF75: B9 E0 04
  AND a:$0000                             ; $DF78: 2D 00 00
  BEQ $DF84                               ; $DF7B: F0 07
  LDA a:$005E                             ; $DF7D: AD 5E 00
  AND #$08                                ; $DF80: 29 08
  BNE $DFBF                               ; $DF82: D0 3B
Loc_DF84:
  LDY a:$000F                             ; $DF84: AC 0F 00
  LDA $DFD0,Y                             ; $DF87: B9 D0 DF
  AND a:$000E                             ; $DF8A: 2D 0E 00
  BNE $DFBF                               ; $DF8D: D0 30
  LDA a:$000F                             ; $DF8F: AD 0F 00
  JSR $F2AF                               ; $DF92: 20 AF F2
  LDY #$00                                ; $DF95: A0 00
Loc_DF97:
  LDA ($00),Y                             ; $DF97: B1 00
  AND #$07                                ; $DF99: 29 07
  TAY                                     ; $DF9B: A8
  LDA $DFC0,Y                             ; $DF9C: B9 C0 DF
  STA $0201,X                             ; $DF9F: 9D 01 02
  LDA $DFC8,Y                             ; $DFA2: B9 C8 DF
  STA $0202,X                             ; $DFA5: 9D 02 02
  LDA a:$000F                             ; $DFA8: AD 0F 00
  AND #$1F                                ; $DFAB: 29 1F
  TAY                                     ; $DFAD: A8
  LDA $DEE9,Y                             ; $DFAE: B9 E9 DE
  STA $0203,X                             ; $DFB1: 9D 03 02
  LDA $DF07,Y                             ; $DFB4: B9 07 DF
  STA $0200,X                             ; $DFB7: 9D 00 02
  INX                                     ; $DFBA: E8
  INX                                     ; $DFBB: E8
  INX                                     ; $DFBC: E8
  INX                                     ; $DFBD: E8
  RTS                                     ; $DFBE: 60
Loc_DFBF:
  RTS                                     ; $DFBF: 60
; --- Data Region ---
  .byte $00,$01,$00,$01,$08,$09,$0A,$0B,$00,$00,$01,$01,$00,$00,$00,$00; $DFC0: 00 01 00 01 08 09 0A 0B 00 00 01 01 00 00 00 00
  .byte $00,$00,$40,$40,$40,$00,$80,$80,$80,$80,$40,$40,$40,$40,$40,$40; $DFD0: 00 00 40 40 40 00 80 80 80 80 40 40 40 40 40 40
  .byte $40,$40,$40,$80,$40,$40,$80,$40,$40,$80,$80,$80,$80,$80,$01,$02; $DFE0: 40 40 40 80 40 40 80 40 40 80 80 80 80 80 01 02
  .byte $04,$08,$10,$20,$40,$80,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DFF0: 04 08 10 20 40 80 FF FF FF FF FF FF FF FF FF FF
