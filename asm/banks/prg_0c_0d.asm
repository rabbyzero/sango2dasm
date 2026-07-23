;===============================================================================
; PRG Banks $0C+$0D - Combined 16KB ($A000-$DFFF)
; Sangokushi 2 - Haou no Tairiku (J)
; Namco-163 Mapper 19
;
; Bank $0C at $A000-$BFFF, Bank $0D at $C000-$DFFF
;===============================================================================

.include "6502_registers.h"
.include "namco163.h"
.include "functions.h"

.segment "CODE_BANK0C"

Loc_A000:  ; (dispatch callback target)
  JMP $A009                             ; $A000: 4C 09 A0
Loc_A003:
  JMP $DC99                             ; $A003: 4C 99 DC
Loc_A006:  ; (dispatch callback target)
  JMP $C766                             ; $A006: 4C 66 C7
Loc_A009:  ; (dispatch callback target)
  JSR $DF88                             ; $A009: 20 88 DF
Loc_A00C:  ; (dispatch callback target)
  LDY #$28                              ; $A00C: A0 28
  JSR $EE07                             ; $A00E: 20 07 EE
; --- Data Region ---
  .byte $12,$A0,$A0,$28                   ; $A011: 12 A0 A0 28
Loc_A015:  ; (dispatch callback target)
; --- Code Region ---
  JSR $EE07                             ; $A015: 20 07 EE
; --- Data Region ---
  .byte $21,$A0,$20                       ; $A018: 21 A0 20
Loc_A01B:  ; (dispatch callback target)
; --- Code Region ---
  PLP                                   ; $A01B: 28
  LDY #$20                              ; $A01C: A0 20
  AND $A0DF,Y                           ; $A01E: 39 DF A0
Loc_A021:  ; (dispatch callback target)
  PLP                                   ; $A021: 28
Loc_A022:
  JSR $EE07                             ; $A022: 20 07 EE
; --- Data Region ---
  .byte $15,$A0,$60,$AD,$00               ; $A025: 15 A0 60 AD 00
Loc_A02A:  ; (dispatch callback target)
; --- Code Region ---
  ORA $20                               ; $A02A: 05 20
  DEC $4EEA,X                           ; $A02C: DE EA 4E
; --- Data Region ---
  .byte $A0,$1B,$A2,$93,$A2,$93,$A2,$4D,$A4,$7C,$A8,$4A,$B9,$93,$BC,$7E; $A02F: A0 1B A2 93 A2 93 A2 4D A4 7C A8 4A B9 93 BC 7E
  .byte $BE,$FC,$C1,$04,$C2,$91,$C6,$8C,$C9,$16,$CD,$CD,$D2,$F0,$D4; $A03F: BE FC C1 04 C2 91 C6 8C C9 16 CD CD D2 F0 D4
Loc_A04E:  ; (dispatch callback target)
; --- Code Region ---
  LDA $0501                             ; $A04E: AD 01 05
  JSR $EADE                             ; $A051: 20 DE EA
; --- Data Region ---
  .byte $5E,$A0,$8D,$A0,$BB,$A0,$18,$A1,$B8,$A1; $A054: 5E A0 8D A0 BB A0 18 A1 B8 A1
Loc_A05E:  ; (dispatch callback target)
; --- Code Region ---
  JSR $DD72                             ; $A05E: 20 72 DD
  LDA $050F                             ; $A061: AD 0F 05
  CMP #$03                              ; $A064: C9 03
  BNE $A07A                             ; $A066: D0 12
  LDA $0505                             ; $A068: AD 05 05
  BEQ $A086                             ; $A06B: F0 19
  BMI $A086                             ; $A06D: 30 17
  LDA #$08                              ; $A06F: A9 08
  STA $0500                             ; $A071: 8D 00 05
  LDA #$00                              ; $A074: A9 00
  STA $0501                             ; $A076: 8D 01 05
  RTS                                   ; $A079: 60
; --- Data Region ---
  .byte $20,$27,$DF,$90,$0D,$AD,$05,$05,$F0,$02,$10,$03; $A07A: 20 27 DF 90 0D AD 05 05 F0 02 10 03
Loc_A086:
; --- Code Region ---
  JMP $BDC0                             ; $A086: 4C C0 BD
Loc_A089:
  INC $0501                             ; $A089: EE 01 05
Loc_A08C:
  RTS                                   ; $A08C: 60
Loc_A08D:  ; (dispatch callback target)
  JSR $D5EE                             ; $A08D: 20 EE D5
  LDA $0508                             ; $A090: AD 08 05
  BNE $A0BA                             ; $A093: D0 25
  LDA $007E                             ; $A095: AD 7E 00
  BNE $A0BA                             ; $A098: D0 20
  INC $0501                             ; $A09A: EE 01 05
  LDA #$C0                              ; $A09D: A9 C0
  JSR $F293                             ; $A09F: 20 93 F2
  LDA $0507                             ; $A0A2: AD 07 05
  LDY $0504                             ; $A0A5: AC 04 05
  BPL $A0AE                             ; $A0A8: 10 04
  LSR                                   ; $A0AA: 4A
  LSR                                   ; $A0AB: 4A
  LSR                                   ; $A0AC: 4A
  LSR                                   ; $A0AD: 4A
Loc_A0AE:
  AND #$0F                              ; $A0AE: 29 0F
  JSR $F368                             ; $A0B0: 20 68 F3
  LDY #$00                              ; $A0B3: A0 00
  LDA ($00),Y                           ; $A0B5: B1 00
  STA $042C                             ; $A0B7: 8D 2C 04
Loc_A0BA:
  RTS                                   ; $A0BA: 60
Loc_A0BB:  ; (dispatch callback target)
  JSR $D5EE                             ; $A0BB: 20 EE D5
  JSR $D657                             ; $A0BE: 20 57 D6
  JSR $DF27                             ; $A0C1: 20 27 DF
  BCS $A0C7                             ; $A0C4: B0 01
  RTS                                   ; $A0C6: 60
Loc_A0C7:
  JSR $D4FB                             ; $A0C7: 20 FB D4
  LDA $81                               ; $A0CA: A5 81
  AND #$01                              ; $A0CC: 29 01
  BEQ $A0FB                             ; $A0CE: F0 2B
  JSR $D68A                             ; $A0D0: 20 8A D6
  TYA                                   ; $A0D3: 98
  BMI $A0FB                             ; $A0D4: 30 25
  JSR $DC4B                             ; $A0D6: 20 4B DC
  CMP #$FF                              ; $A0D9: C9 FF
  BEQ $A0FB                             ; $A0DB: F0 1E
  STY $0509                             ; $A0DD: 8C 09 05
  STY $050A                             ; $A0E0: 8C 0A 05
  INC $0501                             ; $A0E3: EE 01 05
  LDY #$3D                              ; $A0E6: A0 3D
  JSR $EE07                             ; $A0E8: 20 07 EE
; --- Data Region ---
  .byte $27,$A0,$A9,$C1,$20,$83,$F2,$A9,$00,$8D,$24,$04,$8D,$25,$04,$60; $A0EB: 27 A0 A9 C1 20 83 F2 A9 00 8D 24 04 8D 25 04 60
Loc_A0FB:
; --- Code Region ---
  LDA $81                               ; $A0FB: A5 81
  AND #$02                              ; $A0FD: 29 02
  BEQ $A117                             ; $A0FF: F0 16
  JSR $D68A                             ; $A101: 20 8A D6
  TYA                                   ; $A104: 98
  BMI $A117                             ; $A105: 30 10
  STY $0509                             ; $A107: 8C 09 05
  STY $050A                             ; $A10A: 8C 0A 05
  LDA #$01                              ; $A10D: A9 01
  STA $0500                             ; $A10F: 8D 00 05
  LDA #$00                              ; $A112: A9 00
  STA $0501                             ; $A114: 8D 01 05
Loc_A117:
  RTS                                   ; $A117: 60
Loc_A118:  ; (dispatch callback target)
  LDA #$00                              ; $A118: A9 00
  STA $00A4                             ; $A11A: 8D A4 00
  JSR $DC33                             ; $A11D: 20 33 DC
  JSR $A1DE                             ; $A120: 20 DE A1
  LDA #$93                              ; $A123: A9 93
  STA $10                               ; $A125: 85 10
  LDA #$A1                              ; $A127: A9 A1
  STA $11                               ; $A129: 85 11
  LDA #$00                              ; $A12B: A9 00
  STA $12                               ; $A12D: 85 12
  JSR $ED1E                             ; $A12F: 20 1E ED
  LDA #$9B                              ; $A132: A9 9B
  STA $10                               ; $A134: 85 10
  LDA #$A1                              ; $A136: A9 A1
  STA $11                               ; $A138: 85 11
  LDA #$A7                              ; $A13A: A9 A7
  STA $00                               ; $A13C: 85 00
  LDA #$A1                              ; $A13E: A9 A1
  STA $01                               ; $A140: 85 01
  LDA $12                               ; $A142: A5 12
  JSR $EDF5                             ; $A144: 20 F5 ED
  JSR $DF27                             ; $A147: 20 27 DF
  BCC $A117                             ; $A14A: 90 CB
  LDA $81                               ; $A14C: A5 81
  AND #$02                              ; $A14E: 29 02
  BEQ $A15A                             ; $A150: F0 08
  LDA #$00                              ; $A152: A9 00
  STA $0501                             ; $A154: 8D 01 05
  JMP $A1F7                             ; $A157: 4C F7 A1
Loc_A15A:
  LDA $81                               ; $A15A: A5 81
  AND #$01                              ; $A15C: 29 01
  BEQ $A192                             ; $A15E: F0 32
  LDY $12                               ; $A160: A4 12
  BNE $A174                             ; $A162: D0 10
  LDX $0509                             ; $A164: AE 09 05
  LDA $0650,X                           ; $A167: BD 50 06
  BEQ $A174                             ; $A16A: F0 08
  INC $0501                             ; $A16C: EE 01 05
  LDA #$BC                              ; $A16F: A9 BC
  JMP $F283                             ; $A171: 4C 83 F2
Loc_A174:
  CPY #$01                              ; $A174: C0 01
  BNE $A17F                             ; $A176: D0 07
  LDA $0505                             ; $A178: AD 05 05
  CMP #$02                              ; $A17B: C9 02
  BCC $A192                             ; $A17D: 90 13
Loc_A17F:
  LDA $A1AC,Y                           ; $A17F: B9 AC A1
  STA $0500                             ; $A182: 8D 00 05
  LDA $A1B2,Y                           ; $A185: B9 B2 A1
  STA $0501                             ; $A188: 8D 01 05
  LDA #$01                              ; $A18B: A9 01
  STA $12                               ; $A18D: 85 12
  JSR $D6CC                             ; $A18F: 20 CC D6
Loc_A192:
  RTS                                   ; $A192: 60
; --- Data Region ---
  .byte $00,$01,$02,$03,$04,$FF,$FF,$FF,$A8,$47,$A8,$97,$B8,$47,$B8,$97; $A193: 00 01 02 03 04 FF FF FF A8 47 A8 97 B8 47 B8 97
  .byte $C8,$47,$C8,$97,$00,$07,$00,$00,$80,$04,$03,$05,$07,$06,$00,$00; $A1A3: C8 47 C8 97 00 07 00 00 80 04 03 05 07 06 00 00
  .byte $00,$00,$00,$00,$00               ; $A1B3: 00 00 00 00 00
Loc_A1B8:  ; (dispatch callback target)
; --- Code Region ---
  LDA #$00                              ; $A1B8: A9 00
  STA $00A4                             ; $A1BA: 8D A4 00
  JSR $DC33                             ; $A1BD: 20 33 DC
  JSR $A1DE                             ; $A1C0: 20 DE A1
  JSR $DF27                             ; $A1C3: 20 27 DF
  BCC $A1DD                             ; $A1C6: 90 15
  JSR $DC63                             ; $A1C8: 20 63 DC
  LDA $81                               ; $A1CB: A5 81
  AND #$03                              ; $A1CD: 29 03
  BEQ $A1DD                             ; $A1CF: F0 0C
  LDA #$01                              ; $A1D1: A9 01
  STA $0501                             ; $A1D3: 8D 01 05
  LDA #$01                              ; $A1D6: A9 01
  STA $12                               ; $A1D8: 85 12
  JSR $D6CC                             ; $A1DA: 20 CC D6
Loc_A1DD:
  RTS                                   ; $A1DD: 60
Loc_A1DE:
  LDA $005E                             ; $A1DE: AD 5E 00
  AND #$07                              ; $A1E1: 29 07
  BNE $A1F6                             ; $A1E3: D0 11
  LDA $007E                             ; $A1E5: AD 7E 00
  AND #$04                              ; $A1E8: 29 04
  BNE $A1F6                             ; $A1EA: D0 0A
  LDA $005E                             ; $A1EC: AD 5E 00
  AND #$10                              ; $A1EF: 29 10
  STA $12                               ; $A1F1: 85 12
  JSR $D6CC                             ; $A1F3: 20 CC D6
Loc_A1F6:
  RTS                                   ; $A1F6: 60
Loc_A1F7:
  LDA #$05                              ; $A1F7: A9 05
  JSR $F293                             ; $A1F9: 20 93 F2
  LDA #$01                              ; $A1FC: A9 01
  STA $12                               ; $A1FE: 85 12
  JSR $D6CC                             ; $A200: 20 CC D6
  LDA #$00                              ; $A203: A9 00
  STA $0424                             ; $A205: 8D 24 04
  STA $0425                             ; $A208: 8D 25 04
  RTS                                   ; $A20B: 60
Loc_A20C:
  LDA #$00                              ; $A20C: A9 00
  STA $0501                             ; $A20E: 8D 01 05
  STA $0500                             ; $A211: 8D 00 05
  STA $0424                             ; $A214: 8D 24 04
  STA $0425                             ; $A217: 8D 25 04
  RTS                                   ; $A21A: 60
Loc_A21B:  ; (dispatch callback target)
  LDA $0501                             ; $A21B: AD 01 05
  JSR $EADE                             ; $A21E: 20 DE EA
; --- Data Region ---
  .byte $27,$A2,$44,$A2,$7B,$A2           ; $A221: 27 A2 44 A2 7B A2
Loc_A227:  ; (dispatch callback target)
; --- Code Region ---
  INC $0501                             ; $A227: EE 01 05
  LDA #$08                              ; $A22A: A9 08
  STA $BA                               ; $A22C: 85 BA
  LDA #$06                              ; $A22E: A9 06
  STA $BB                               ; $A230: 85 BB
  LDA #$00                              ; $A232: A9 00
  STA $040C                             ; $A234: 8D 0C 04
  STA $040D                             ; $A237: 8D 0D 04
  LDY $0509                             ; $A23A: AC 09 05
  LDA $0664,Y                           ; $A23D: B9 64 06
  STA $0410                             ; $A240: 8D 10 04
  RTS                                   ; $A243: 60
Loc_A244:  ; (dispatch callback target)
  JSR $A1DE                             ; $A244: 20 DE A1
  LDA #$A7                              ; $A247: A9 A7
  STA $0A                               ; $A249: 85 0A
  LDA $0410                             ; $A24B: AD 10 04
  STA $00                               ; $A24E: 85 00
  LDA #$00                              ; $A250: A9 00
  STA $00A4                             ; $A252: 8D A4 00
  LDY #$39                              ; $A255: A0 39
  JSR $EE07                             ; $A257: 20 07 EE
; --- Data Region ---
  .byte $00,$A0,$A9,$06,$85,$BB,$A0,$39,$20,$07,$EE,$12,$A0,$20,$27,$DF; $A25A: 00 A0 A9 06 85 BB A0 39 20 07 EE 12 A0 20 27 DF
  .byte $90,$0E,$A5,$81,$29,$03,$F0,$08,$EE,$01,$05,$A9,$05,$20,$93,$F2; $A26A: 90 0E A5 81 29 03 F0 08 EE 01 05 A9 05 20 93 F2
Loc_A27A:
; --- Code Region ---
  RTS                                   ; $A27A: 60
Loc_A27B:  ; (dispatch callback target)
  JSR $A1DE                             ; $A27B: 20 DE A1
  JSR $DF27                             ; $A27E: 20 27 DF
  BCC $A292                             ; $A281: 90 0F
  LDA #$09                              ; $A283: A9 09
  STA $BB                               ; $A285: 85 BB
  LDA #$00                              ; $A287: A9 00
  STA $0500                             ; $A289: 8D 00 05
  STA $0501                             ; $A28C: 8D 01 05
  JSR $A1F7                             ; $A28F: 20 F7 A1
Loc_A292:
  RTS                                   ; $A292: 60
Loc_A293:  ; (dispatch callback target)
  LDY $050A                             ; $A293: AC 0A 05
  JSR $DC36                             ; $A296: 20 36 DC
  LDA $0501                             ; $A299: AD 01 05
  JSR $EADE                             ; $A29C: 20 DE EA
; --- Data Region ---
  .byte $A7,$A2,$BB,$A2,$0C,$A3,$25,$A3,$A9,$C3,$20,$83,$F2,$EE,$01,$05; $A29F: A7 A2 BB A2 0C A3 25 A3 A9 C3 20 83 F2 EE 01 05
  .byte $AD,$09,$05,$8D,$0A,$05,$A9,$00,$8D,$A4,$00,$60; $A2AF: AD 09 05 8D 0A 05 A9 00 8D A4 00 60
Loc_A2BB:  ; (dispatch callback target)
; --- Code Region ---
  LDA $050A                             ; $A2BB: AD 0A 05
  STA $0509                             ; $A2BE: 8D 09 05
  JSR $A1DE                             ; $A2C1: 20 DE A1
  JSR $D4FB                             ; $A2C4: 20 FB D4
  JSR $D657                             ; $A2C7: 20 57 D6
  JSR $DF27                             ; $A2CA: 20 27 DF
  BCC $A30B                             ; $A2CD: 90 3C
  LDA $81                               ; $A2CF: A5 81
  AND #$02                              ; $A2D1: 29 02
  BEQ $A2E2                             ; $A2D3: F0 0D
  LDA #$00                              ; $A2D5: A9 00
  STA $0501                             ; $A2D7: 8D 01 05
  LDA #$00                              ; $A2DA: A9 00
  STA $0500                             ; $A2DC: 8D 00 05
  JMP $A1F7                             ; $A2DF: 4C F7 A1
Loc_A2E2:
  LDA $81                               ; $A2E2: A5 81
  AND #$01                              ; $A2E4: 29 01
  BEQ $A30B                             ; $A2E6: F0 23
  JSR $D68A                             ; $A2E8: 20 8A D6
  TYA                                   ; $A2EB: 98
  BMI $A30B                             ; $A2EC: 30 1D
  JSR $DC4B                             ; $A2EE: 20 4B DC
  CMP #$FF                              ; $A2F1: C9 FF
  BNE $A30B                             ; $A2F3: D0 16
  STY $0509                             ; $A2F5: 8C 09 05
  JSR $A368                             ; $A2F8: 20 68 A3
  TXA                                   ; $A2FB: 8A
  BMI $A30B                             ; $A2FC: 30 0D
  INC $0501                             ; $A2FE: EE 01 05
  LDA #$02                              ; $A301: A9 02
  STA $00A4                             ; $A303: 8D A4 00
  LDA #$CB                              ; $A306: A9 CB
  JSR $F283                             ; $A308: 20 83 F2
Loc_A30B:
  RTS                                   ; $A30B: 60
Loc_A30C:  ; (dispatch callback target)
  JSR $DC63                             ; $A30C: 20 63 DC
  LDA $81                               ; $A30F: A5 81
  AND #$01                              ; $A311: 29 01
  BEQ $A324                             ; $A313: F0 0F
  JSR $ECEE                             ; $A315: 20 EE EC
  INC $0501                             ; $A318: EE 01 05
  DEC $0505                             ; $A31B: CE 05 05
  DEC $0505                             ; $A31E: CE 05 05
  JSR $A3D2                             ; $A321: 20 D2 A3
Loc_A324:
  RTS                                   ; $A324: 60
Loc_A325:  ; (dispatch callback target)
  LDA $0087                             ; $A325: AD 87 00
  BPL $A367                             ; $A328: 10 3D
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
  JSR $DB46                             ; $A361: 20 46 DB
  STA $0544                             ; $A364: 8D 44 05
Loc_A367:
  RTS                                   ; $A367: 60
Loc_A368:
  LDX $050A                             ; $A368: AE 0A 05
  LDA $0600,X                           ; $A36B: BD 00 06
  SEC                                   ; $A36E: 38
  SBC #$01                              ; $A36F: E9 01
  CMP $0600,Y                           ; $A371: D9 00 06
  BNE $A37F                             ; $A374: D0 09
  LDA $0614,X                           ; $A376: BD 14 06
  CMP $0614,Y                           ; $A379: D9 14 06
  BNE $A37F                             ; $A37C: D0 01
Loc_A37E:
  RTS                                   ; $A37E: 60
Loc_A37F:
  LDX $050A                             ; $A37F: AE 0A 05
  LDA $0600,X                           ; $A382: BD 00 06
  CLC                                   ; $A385: 18
  ADC #$01                              ; $A386: 69 01
  CMP $0600,Y                           ; $A388: D9 00 06
  BNE $A395                             ; $A38B: D0 08
  LDA $0614,X                           ; $A38D: BD 14 06
  CMP $0614,Y                           ; $A390: D9 14 06
  BEQ $A37E                             ; $A393: F0 E9
Loc_A395:
  LDX $050A                             ; $A395: AE 0A 05
  LDA $0600,X                           ; $A398: BD 00 06
  CMP $0600,Y                           ; $A39B: D9 00 06
  BNE $A3B2                             ; $A39E: D0 12
  LDA $0614,X                           ; $A3A0: BD 14 06
  SEC                                   ; $A3A3: 38
  SBC #$01                              ; $A3A4: E9 01
  CMP #$0F                              ; $A3A6: C9 0F
  BNE $A3AD                             ; $A3A8: D0 03
  SEC                                   ; $A3AA: 38
  SBC #$01                              ; $A3AB: E9 01
Loc_A3AD:
  CMP $0614,Y                           ; $A3AD: D9 14 06
  BEQ $A37E                             ; $A3B0: F0 CC
Loc_A3B2:
  LDX $050A                             ; $A3B2: AE 0A 05
  LDA $0600,X                           ; $A3B5: BD 00 06
  CMP $0600,Y                           ; $A3B8: D9 00 06
  BNE $A3CF                             ; $A3BB: D0 12
  LDA $0614,X                           ; $A3BD: BD 14 06
  CLC                                   ; $A3C0: 18
  ADC #$01                              ; $A3C1: 69 01
  CMP #$0F                              ; $A3C3: C9 0F
  BNE $A3CA                             ; $A3C5: D0 03
  CLC                                   ; $A3C7: 18
  ADC #$01                              ; $A3C8: 69 01
Loc_A3CA:
  CMP $0614,Y                           ; $A3CA: D9 14 06
  BEQ $A37E                             ; $A3CD: F0 AF
Loc_A3CF:
  LDX #$FF                              ; $A3CF: A2 FF
  RTS                                   ; $A3D1: 60
Loc_A3D2:
  LDA #$00                              ; $A3D2: A9 00
  STA $0544                             ; $A3D4: 8D 44 05
  LDY $050A                             ; $A3D7: AC 0A 05
  LDX #$00                              ; $A3DA: A2 00
  JSR $A433                             ; $A3DC: 20 33 A4
  LDY $0509                             ; $A3DF: AC 09 05
  LDX #$01                              ; $A3E2: A2 01
  LDA #$00                              ; $A3E4: A9 00
  STA $0650,Y                           ; $A3E6: 99 50 06
  JSR $A433                             ; $A3E9: 20 33 A4
  LDA $0504                             ; $A3EC: AD 04 05
  BMI $A406                             ; $A3EF: 30 15
  LDA $0507                             ; $A3F1: AD 07 05
  AND #$0F                              ; $A3F4: 29 0F
  STA $0564                             ; $A3F6: 8D 64 05
  LDA $0507                             ; $A3F9: AD 07 05
  LSR                                   ; $A3FC: 4A
  LSR                                   ; $A3FD: 4A
  LSR                                   ; $A3FE: 4A
  LSR                                   ; $A3FF: 4A
  STA $0565                             ; $A400: 8D 65 05
  JMP $A418                             ; $A403: 4C 18 A4
Loc_A406:
  LDA $0507                             ; $A406: AD 07 05
  AND #$0F                              ; $A409: 29 0F
  STA $0565                             ; $A40B: 8D 65 05
  LDA $0507                             ; $A40E: AD 07 05
  LSR                                   ; $A411: 4A
  LSR                                   ; $A412: 4A
  LSR                                   ; $A413: 4A
  LSR                                   ; $A414: 4A
  STA $0564                             ; $A415: 8D 64 05
Loc_A418:
  LDA $0564                             ; $A418: AD 64 05
  JSR $F368                             ; $A41B: 20 68 F3
  LDY #$03                              ; $A41E: A0 03
  LDA ($00),Y                           ; $A420: B1 00
  STA $0562                             ; $A422: 8D 62 05
  LDA $0565                             ; $A425: AD 65 05
  JSR $F368                             ; $A428: 20 68 F3
  LDY #$03                              ; $A42B: A0 03
  LDA ($00),Y                           ; $A42D: B1 00
  STA $0563                             ; $A42F: 8D 63 05
  RTS                                   ; $A432: 60
Loc_A433:
  LDA $0664,Y                           ; $A433: B9 64 06
  STA $0560,X                           ; $A436: 9D 60 05
  JSR $F2D7                             ; $A439: 20 D7 F2
  LDY #$0B                              ; $A43C: A0 0B
  LDA ($00),Y                           ; $A43E: B1 00
  AND #$F0                              ; $A440: 29 F0
  STA $052C,X                           ; $A442: 9D 2C 05
  LDY #$01                              ; $A445: A0 01
  LDA ($00),Y                           ; $A447: B1 00
  STA $052E,X                           ; $A449: 9D 2E 05
  RTS                                   ; $A44C: 60
Loc_A44D:  ; (dispatch callback target)
  LDA $0501                             ; $A44D: AD 01 05
  CMP #$02                              ; $A450: C9 02
  BCS $A45C                             ; $A452: B0 08
  LDA #$00                              ; $A454: A9 00
  STA $00A4                             ; $A456: 8D A4 00
  JSR $DC33                             ; $A459: 20 33 DC
Loc_A45C:
  LDA $0501                             ; $A45C: AD 01 05
  JSR $EADE                             ; $A45F: 20 DE EA
; --- Data Region ---
  .byte $70,$A4,$7E,$A4,$B5,$A4,$1F,$A5,$35,$A5,$CE,$A5,$17,$A6,$A9,$C6; $A462: 70 A4 7E A4 B5 A4 1F A5 35 A5 CE A5 17 A6 A9 C6
  .byte $20,$83,$F2,$EE,$01,$05,$A9,$00,$8D,$0A,$05,$60; $A472: 20 83 F2 EE 01 05 A9 00 8D 0A 05 60
Loc_A47E:  ; (dispatch callback target)
; --- Code Region ---
  JSR $A1DE                             ; $A47E: 20 DE A1
  JSR $A64A                             ; $A481: 20 4A A6
  LDY $0509                             ; $A484: AC 09 05
  LDA $0600,Y                           ; $A487: B9 00 06
  STA $00                               ; $A48A: 85 00
  LDA $0614,Y                           ; $A48C: B9 14 06
  STA $02                               ; $A48F: 85 02
  JSR $DA5A                             ; $A491: 20 5A DA
  LDA $00                               ; $A494: A5 00
  STA $6F3F                             ; $A496: 8D 3F 6F
  LDA $01                               ; $A499: A5 01
  STA $6F40                             ; $A49B: 8D 40 6F
  LDA $02                               ; $A49E: A5 02
  STA $6F41                             ; $A4A0: 8D 41 6F
  LDA $03                               ; $A4A3: A5 03
  STA $6F42                             ; $A4A5: 8D 42 6F
  JSR $D5EE                             ; $A4A8: 20 EE D5
  LDA $81                               ; $A4AB: A5 81
  AND #$01                              ; $A4AD: 29 01
  BEQ $A4B4                             ; $A4AF: F0 03
  INC $0501                             ; $A4B1: EE 01 05
Loc_A4B4:
  RTS                                   ; $A4B4: 60
Loc_A4B5:  ; (dispatch callback target)
  LDY $0509                             ; $A4B5: AC 09 05
  LDA $0600,Y                           ; $A4B8: B9 00 06
  STA $10                               ; $A4BB: 85 10
  LDA $0614,Y                           ; $A4BD: B9 14 06
  STA $11                               ; $A4C0: 85 11
  LDA $0504                             ; $A4C2: AD 04 05
  BPL $A4D6                             ; $A4C5: 10 0F
  JSR $DB46                             ; $A4C7: 20 46 DB
  CMP #$05                              ; $A4CA: C9 05
  BNE $A4D6                             ; $A4CC: D0 08
  LDY #$28                              ; $A4CE: A0 28
  JSR $EE07                             ; $A4D0: 20 07 EE
; --- Data Region ---
  .byte $27,$A0,$60,$AD,$0F,$05,$C9,$03,$F0,$27,$A0,$31,$20,$5F,$F2,$AD; $A4D3: 27 A0 60 AD 0F 05 C9 03 F0 27 A0 31 20 5F F2 AD
  .byte $0E,$05,$0A,$85,$00,$0A,$18,$65,$00,$A8,$A2,$00; $A4E3: 0E 05 0A 85 00 0A 18 65 00 A8 A2 00
Loc_A4EF:
; --- Code Region ---
  LDA $9BA4,Y                           ; $A4EF: B9 A4 9B
  CMP $10                               ; $A4F2: C5 10
  BNE $A4FD                             ; $A4F4: D0 07
  LDA $9BA5,Y                           ; $A4F6: B9 A5 9B
  CMP $11                               ; $A4F9: C5 11
  BEQ $A508                             ; $A4FB: F0 0B
Loc_A4FD:
  INY                                   ; $A4FD: C8
  INY                                   ; $A4FE: C8
  INX                                   ; $A4FF: E8
  CPX #$03                              ; $A500: E0 03
  BCC $A4EF                             ; $A502: 90 EB
Loc_A504:
  INC $0501                             ; $A504: EE 01 05
  RTS                                   ; $A507: 60
Loc_A508:
  STX $0470                             ; $A508: 8E 70 04
  LDA #$01                              ; $A50B: A9 01
  STA $12                               ; $A50D: 85 12
  JSR $D6CC                             ; $A50F: 20 CC D6
  LDA #$09                              ; $A512: A9 09
  STA $0500                             ; $A514: 8D 00 05
  STA $0501                             ; $A517: 8D 01 05
  LDA #$A7                              ; $A51A: A9 A7
  JMP $F293                             ; $A51C: 4C 93 F2
Loc_A51F:  ; (dispatch callback target)
  LDA $6F8B                             ; $A51F: AD 8B 6F
  CMP #$FF                              ; $A522: C9 FF
  BNE $A534                             ; $A524: D0 0E
  LDA #$01                              ; $A526: A9 01
  STA $6F8B                             ; $A528: 8D 8B 6F
  LDA $0509                             ; $A52B: AD 09 05
  STA $6F8C                             ; $A52E: 8D 8C 6F
  INC $0501                             ; $A531: EE 01 05
Loc_A534:
  RTS                                   ; $A534: 60
Loc_A535:  ; (dispatch callback target)
  LDA $6F8B                             ; $A535: AD 8B 6F
  CMP #$FF                              ; $A538: C9 FF
  BEQ $A53D                             ; $A53A: F0 01
  RTS                                   ; $A53C: 60
Loc_A53D:
  LDA $6F8F                             ; $A53D: AD 8F 6F
  BEQ $A545                             ; $A540: F0 03
  JMP $A634                             ; $A542: 4C 34 A6
Loc_A545:
  INC $0501                             ; $A545: EE 01 05
  LDA $042C                             ; $A548: AD 2C 04
  STA $0B                               ; $A54B: 85 0B
  LDA $042D                             ; $A54D: AD 2D 04
  STA $0C                               ; $A550: 85 0C
  LDY #$04                              ; $A552: A0 04
  LDA $0504                             ; $A554: AD 04 05
  BPL $A55B                             ; $A557: 10 02
  LDY #$00                              ; $A559: A0 00
Loc_A55B:
  LDA $04D8,Y                           ; $A55B: B9 D8 04
  TAY                                   ; $A55E: A8
  LDA $0664,Y                           ; $A55F: B9 64 06
  STA $0A                               ; $A562: 85 0A
  JSR $F2D7                             ; $A564: 20 D7 F2
  LDY #$0B                              ; $A567: A0 0B
  LDA ($00),Y                           ; $A569: B1 00
  AND #$F0                              ; $A56B: 29 F0
  STA $052C                             ; $A56D: 8D 2C 05
  LDY #$01                              ; $A570: A0 01
  LDA ($00),Y                           ; $A572: B1 00
  STA $052E                             ; $A574: 8D 2E 05
  LDY #$2E                              ; $A577: A0 2E
  JSR $EE07                             ; $A579: 20 07 EE
; --- Data Region ---
  .byte $06,$A0,$20,$03,$DB,$AD,$09,$05,$8D,$0A,$05,$AC,$8C,$6F,$B9,$A1; $A57C: 06 A0 20 03 DB AD 09 05 8D 0A 05 AC 8C 6F B9 A1
  .byte $6F,$C9,$FF,$F0,$19,$A0,$04,$AD,$04,$05,$10,$02,$A0,$00; $A58C: 6F C9 FF F0 19 A0 04 AD 04 05 10 02 A0 00
Loc_A59A:
; --- Code Region ---
  LDA $04D8,Y                           ; $A59A: B9 D8 04
  STA $0509                             ; $A59D: 8D 09 05
  LDA #$04                              ; $A5A0: A9 04
  STA $00A4                             ; $A5A2: 8D A4 00
  LDA #$B9                              ; $A5A5: A9 B9
  JMP $A5B6                             ; $A5A7: 4C B6 A5
Loc_A5AA:
  LDA #$03                              ; $A5AA: A9 03
  STA $00A4                             ; $A5AC: 8D A4 00
  LDA #$00                              ; $A5AF: A9 00
  STA $052E                             ; $A5B1: 8D 2E 05
  LDA #$B8                              ; $A5B4: A9 B8
Loc_A5B6:
  JSR $F283                             ; $A5B6: 20 83 F2
  LDY #$3D                              ; $A5B9: A0 3D
  JSR $EE07                             ; $A5BB: 20 07 EE
; --- Data Region ---
  .byte $27,$A0,$AD,$09,$05,$AA,$AD,$0A,$05,$8D,$09,$05,$8E,$0A,$05,$60; $A5BE: 27 A0 AD 09 05 AA AD 0A 05 8D 09 05 8E 0A 05 60
Loc_A5CE:  ; (dispatch callback target)
; --- Code Region ---
  LDA #$03                              ; $A5CE: A9 03
  STA $00A4                             ; $A5D0: 8D A4 00
  LDY $050A                             ; $A5D3: AC 0A 05
  JSR $DC36                             ; $A5D6: 20 36 DC
  JSR $A1DE                             ; $A5D9: 20 DE A1
  JSR $DF27                             ; $A5DC: 20 27 DF
  BCC $A616                             ; $A5DF: 90 35
  JSR $DC63                             ; $A5E1: 20 63 DC
  LDA $81                               ; $A5E4: A5 81
  AND #$03                              ; $A5E6: 29 03
  BEQ $A616                             ; $A5E8: F0 2C
  LDY #$04                              ; $A5EA: A0 04
  LDA $0504                             ; $A5EC: AD 04 05
  BPL $A5F3                             ; $A5EF: 10 02
  LDY #$00                              ; $A5F1: A0 00
Loc_A5F3:
  LDA #$FF                              ; $A5F3: A9 FF
  STA $04D8,Y                           ; $A5F5: 99 D8 04
  LDA $052E                             ; $A5F8: AD 2E 05
  BEQ $A634                             ; $A5FB: F0 37
  LDY $050A                             ; $A5FD: AC 0A 05
  LDA $0664,Y                           ; $A600: B9 64 06
  STA $042C                             ; $A603: 8D 2C 04
  JSR $DEE9                             ; $A606: 20 E9 DE
  BCC $A634                             ; $A609: 90 29
  INC $0501                             ; $A60B: EE 01 05
  JSR $E57F                             ; $A60E: 20 7F E5
  LDA #$7B                              ; $A611: A9 7B
  JSR $E68B                             ; $A613: 20 8B E6
Loc_A616:
  RTS                                   ; $A616: 60
Loc_A617:  ; (dispatch callback target)
  JSR $DF27                             ; $A617: 20 27 DF
  BCC $A63F                             ; $A61A: 90 23
  JSR $DC63                             ; $A61C: 20 63 DC
  LDA $81                               ; $A61F: A5 81
  AND #$03                              ; $A621: 29 03
  BEQ $A63F                             ; $A623: F0 1A
  LDA $042D                             ; $A625: AD 2D 04
  CMP #$FF                              ; $A628: C9 FF
  BNE $A640                             ; $A62A: D0 14
  JSR $E57F                             ; $A62C: 20 7F E5
  LDA #$1D                              ; $A62F: A9 1D
  JSR $E673                             ; $A631: 20 73 E6
Loc_A634:
  LDA #$00                              ; $A634: A9 00
  STA $0500                             ; $A636: 8D 00 05
  STA $0501                             ; $A639: 8D 01 05
  JSR $A1F7                             ; $A63C: 20 F7 A1
Loc_A63F:
  RTS                                   ; $A63F: 60
Loc_A640:
  LDA #$FF                              ; $A640: A9 FF
  STA $042D                             ; $A642: 8D 2D 04
  LDA #$4B                              ; $A645: A9 4B
  JMP $F293                             ; $A647: 4C 93 F2
Loc_A64A:
  LDA $81                               ; $A64A: A5 81
  AND #$02                              ; $A64C: 29 02
  BEQ $A682                             ; $A64E: F0 32
  LDY $050A                             ; $A650: AC 0A 05
  BEQ $A682                             ; $A653: F0 2D
  LDA #$00                              ; $A655: A9 00
  STA $12                               ; $A657: 85 12
  JSR $D6CC                             ; $A659: 20 CC D6
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
Loc_A682:
  LDA $81                               ; $A682: A5 81
  ASL                                   ; $A684: 0A
  BPL $A6CE                             ; $A685: 10 47
  LDY $0509                             ; $A687: AC 09 05
  LDA $0600,Y                           ; $A68A: B9 00 06
  SEC                                   ; $A68D: 38
  SBC #$01                              ; $A68E: E9 01
  BCC $A6CE                             ; $A690: 90 3C
  STA $00                               ; $A692: 85 00
  LDA $0614,Y                           ; $A694: B9 14 06
  STA $01                               ; $A697: 85 01
  JSR $D6B6                             ; $A699: 20 B6 D6
  TYA                                   ; $A69C: 98
  BPL $A6CE                             ; $A69D: 10 2F
  LDY $0509                             ; $A69F: AC 09 05
  LDA $0600,Y                           ; $A6A2: B9 00 06
  SEC                                   ; $A6A5: 38
  SBC #$01                              ; $A6A6: E9 01
  STA $10                               ; $A6A8: 85 10
  LDA $0614,Y                           ; $A6AA: B9 14 06
  STA $11                               ; $A6AD: 85 11
  JSR $DB46                             ; $A6AF: 20 46 DB
  JSR $A7E7                             ; $A6B2: 20 E7 A7
  BCC $A6CE                             ; $A6B5: 90 17
  STA $0505                             ; $A6B7: 8D 05 05
  TXA                                   ; $A6BA: 8A
  PHA                                   ; $A6BB: 48
  LDA #$00                              ; $A6BC: A9 00
  STA $12                               ; $A6BE: 85 12
  JSR $D6CC                             ; $A6C0: 20 CC D6
  PLA                                   ; $A6C3: 68
  JSR $A85B                             ; $A6C4: 20 5B A8
  LDX $0509                             ; $A6C7: AE 09 05
  DEC $0600,X                           ; $A6CA: DE 00 06
  RTS                                   ; $A6CD: 60
Loc_A6CE:
  LDA $81                               ; $A6CE: A5 81
  BPL $A71B                             ; $A6D0: 10 49
  LDY $0509                             ; $A6D2: AC 09 05
  LDA $0600,Y                           ; $A6D5: B9 00 06
  CLC                                   ; $A6D8: 18
  ADC #$01                              ; $A6D9: 69 01
  CMP #$20                              ; $A6DB: C9 20
  BCS $A71B                             ; $A6DD: B0 3C
  STA $00                               ; $A6DF: 85 00
  LDA $0614,Y                           ; $A6E1: B9 14 06
  STA $01                               ; $A6E4: 85 01
  JSR $D6B6                             ; $A6E6: 20 B6 D6
  TYA                                   ; $A6E9: 98
  BPL $A71B                             ; $A6EA: 10 2F
  LDY $0509                             ; $A6EC: AC 09 05
  LDA $0600,Y                           ; $A6EF: B9 00 06
  CLC                                   ; $A6F2: 18
  ADC #$01                              ; $A6F3: 69 01
  STA $10                               ; $A6F5: 85 10
  LDA $0614,Y                           ; $A6F7: B9 14 06
  STA $11                               ; $A6FA: 85 11
  JSR $DB46                             ; $A6FC: 20 46 DB
  JSR $A7E7                             ; $A6FF: 20 E7 A7
  BCC $A71B                             ; $A702: 90 17
  STA $0505                             ; $A704: 8D 05 05
  TXA                                   ; $A707: 8A
  PHA                                   ; $A708: 48
  LDA #$00                              ; $A709: A9 00
  STA $12                               ; $A70B: 85 12
  JSR $D6CC                             ; $A70D: 20 CC D6
  PLA                                   ; $A710: 68
  JSR $A85B                             ; $A711: 20 5B A8
  LDX $0509                             ; $A714: AE 09 05
  INC $0600,X                           ; $A717: FE 00 06
  RTS                                   ; $A71A: 60
Loc_A71B:
  LDA $81                               ; $A71B: A5 81
  ASL                                   ; $A71D: 0A
  ASL                                   ; $A71E: 0A
  ASL                                   ; $A71F: 0A
  BPL $A780                             ; $A720: 10 5E
  LDY $0509                             ; $A722: AC 09 05
  LDA $0600,Y                           ; $A725: B9 00 06
  STA $00                               ; $A728: 85 00
  LDA $0614,Y                           ; $A72A: B9 14 06
  SEC                                   ; $A72D: 38
  SBC #$01                              ; $A72E: E9 01
  BMI $A780                             ; $A730: 30 4E
  CMP #$0F                              ; $A732: C9 0F
  BNE $A739                             ; $A734: D0 03
  SEC                                   ; $A736: 38
  SBC #$01                              ; $A737: E9 01
Loc_A739:
  STA $01                               ; $A739: 85 01
  JSR $D6B6                             ; $A73B: 20 B6 D6
  TYA                                   ; $A73E: 98
  BPL $A780                             ; $A73F: 10 3F
  LDY $0509                             ; $A741: AC 09 05
  LDA $0600,Y                           ; $A744: B9 00 06
  STA $10                               ; $A747: 85 10
  LDA $0614,Y                           ; $A749: B9 14 06
  SEC                                   ; $A74C: 38
  SBC #$01                              ; $A74D: E9 01
  CMP #$0F                              ; $A74F: C9 0F
  BNE $A756                             ; $A751: D0 03
  SEC                                   ; $A753: 38
  SBC #$01                              ; $A754: E9 01
Loc_A756:
  STA $11                               ; $A756: 85 11
  JSR $DB46                             ; $A758: 20 46 DB
  JSR $A7E7                             ; $A75B: 20 E7 A7
  BCC $A780                             ; $A75E: 90 20
  STA $0505                             ; $A760: 8D 05 05
  TXA                                   ; $A763: 8A
  PHA                                   ; $A764: 48
  LDA #$00                              ; $A765: A9 00
  STA $12                               ; $A767: 85 12
  JSR $D6CC                             ; $A769: 20 CC D6
  PLA                                   ; $A76C: 68
  JSR $A85B                             ; $A76D: 20 5B A8
  LDX $0509                             ; $A770: AE 09 05
  DEC $0614,X                           ; $A773: DE 14 06
  LDA $0614,X                           ; $A776: BD 14 06
  CMP #$0F                              ; $A779: C9 0F
  BNE $A780                             ; $A77B: D0 03
  DEC $0614,X                           ; $A77D: DE 14 06
Loc_A780:
  LDA $81                               ; $A780: A5 81
  ASL                                   ; $A782: 0A
  ASL                                   ; $A783: 0A
  BPL $A7E6                             ; $A784: 10 60
  LDY $0509                             ; $A786: AC 09 05
  LDA $0600,Y                           ; $A789: B9 00 06
  STA $00                               ; $A78C: 85 00
  LDA $0614,Y                           ; $A78E: B9 14 06
  CLC                                   ; $A791: 18
  ADC #$01                              ; $A792: 69 01
  CMP #$14                              ; $A794: C9 14
  BCS $A7E6                             ; $A796: B0 4E
  CMP #$0F                              ; $A798: C9 0F
  BNE $A79F                             ; $A79A: D0 03
  CLC                                   ; $A79C: 18
  ADC #$01                              ; $A79D: 69 01
Loc_A79F:
  STA $01                               ; $A79F: 85 01
  JSR $D6B6                             ; $A7A1: 20 B6 D6
  TYA                                   ; $A7A4: 98
  BPL $A7E6                             ; $A7A5: 10 3F
  LDY $0509                             ; $A7A7: AC 09 05
Loc_A7AA:
  LDA $0600,Y                           ; $A7AA: B9 00 06
  STA $10                               ; $A7AD: 85 10
  LDA $0614,Y                           ; $A7AF: B9 14 06
  CLC                                   ; $A7B2: 18
  ADC #$01                              ; $A7B3: 69 01
  CMP #$0F                              ; $A7B5: C9 0F
  BNE $A7BC                             ; $A7B7: D0 03
  CLC                                   ; $A7B9: 18
  ADC #$01                              ; $A7BA: 69 01
Loc_A7BC:
  STA $11                               ; $A7BC: 85 11
  JSR $DB46                             ; $A7BE: 20 46 DB
  JSR $A7E7                             ; $A7C1: 20 E7 A7
  BCC $A7E6                             ; $A7C4: 90 20
  STA $0505                             ; $A7C6: 8D 05 05
  TXA                                   ; $A7C9: 8A
  PHA                                   ; $A7CA: 48
  LDA #$00                              ; $A7CB: A9 00
  STA $12                               ; $A7CD: 85 12
  JSR $D6CC                             ; $A7CF: 20 CC D6
  PLA                                   ; $A7D2: 68
  JSR $A85B                             ; $A7D3: 20 5B A8
  LDX $0509                             ; $A7D6: AE 09 05
  INC $0614,X                           ; $A7D9: FE 14 06
  LDA $0614,X                           ; $A7DC: BD 14 06
  CMP #$0F                              ; $A7DF: C9 0F
  BNE $A7E6                             ; $A7E1: D0 03
  INC $0614,X                           ; $A7E3: FE 14 06
Loc_A7E6:
  RTS                                   ; $A7E6: 60
Loc_A7E7:
  PHA                                   ; $A7E7: 48
  LDY $0509                             ; $A7E8: AC 09 05
  LDA $0664,Y                           ; $A7EB: B9 64 06
  JSR $F2D7                             ; $A7EE: 20 D7 F2
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
  BCC $A817                             ; $A809: 90 0C
  LDA $A823,Y                           ; $A80B: B9 23 A8
  TAX                                   ; $A80E: AA
  LDA $0505                             ; $A80F: AD 05 05
  SEC                                   ; $A812: 38
  SBC $A823,Y                           ; $A813: F9 23 A8
  RTS                                   ; $A816: 60
Loc_A817:
  LDA $A83F,Y                           ; $A817: B9 3F A8
  TAX                                   ; $A81A: AA
  LDA $0505                             ; $A81B: AD 05 05
  SEC                                   ; $A81E: 38
  SBC $A83F,Y                           ; $A81F: F9 3F A8
  RTS                                   ; $A822: 60
; --- Data Region ---
  .byte $03,$05,$05,$00,$04,$04,$04,$00,$02,$03,$03,$00,$05,$06,$03,$00; $A823: 03 05 05 00 04 04 04 00 02 03 03 00 05 06 03 00
  .byte $05,$03,$06,$00,$06,$06,$06,$00,$06,$06,$06,$00,$02,$03,$03,$00; $A833: 05 03 06 00 06 06 06 00 06 06 06 00 02 03 03 00
  .byte $03,$03,$03,$00,$01,$02,$02,$00,$03,$05,$02,$00,$03,$02,$04,$00; $A843: 03 03 03 00 01 02 02 00 03 05 02 00 03 02 04 00
  .byte $04,$04,$04,$00,$04,$04,$04,$00   ; $A853: 04 04 04 00 04 04 04 00
Loc_A85B:
; --- Code Region ---
  PHA                                   ; $A85B: 48
  LDY $050A                             ; $A85C: AC 0A 05
  LDX $0509                             ; $A85F: AE 09 05
  LDA $0600,X                           ; $A862: BD 00 06
  STA $0540,Y                           ; $A865: 99 40 05
Loc_A868:  ; (dispatch callback target)
  LDA $0614,X                           ; $A868: BD 14 06
  STA $0541,Y                           ; $A86B: 99 41 05
  PLA                                   ; $A86E: 68
  STA $0542,Y                           ; $A86F: 99 42 05
  INC $050A                             ; $A872: EE 0A 05
  INC $050A                             ; $A875: EE 0A 05
  INC $050A                             ; $A878: EE 0A 05
  RTS                                   ; $A87B: 60
Loc_A87C:  ; (dispatch callback target)
  LDY $050A                             ; $A87C: AC 0A 05
  JSR $DC36                             ; $A87F: 20 36 DC
  LDA $0501                             ; $A882: AD 01 05
  JSR $EADE                             ; $A885: 20 DE EA
; --- Data Region ---
  .byte $9E,$A8,$C1,$A8,$D8,$A8,$17,$A9,$DD,$A9,$2E,$AA,$6C,$AA,$A7,$AA; $A888: 9E A8 C1 A8 D8 A8 17 A9 DD A9 2E AA 6C AA A7 AA
  .byte $2A,$AB,$52,$AB,$90,$AB           ; $A898: 2A AB 52 AB 90 AB
Loc_A89E:  ; (dispatch callback target)
; --- Code Region ---
  LDA #$F3                              ; $A89E: A9 F3
  STA $0310                             ; $A8A0: 8D 10 03
  LDA #$00                              ; $A8A3: A9 00
  STA $0300                             ; $A8A5: 8D 00 03
  STA $050B                             ; $A8A8: 8D 0B 05
  LDY #$03                              ; $A8AB: A0 03
Loc_A8AD:
  LDA $6F3F,Y                           ; $A8AD: B9 3F 6F
  STA $046C,Y                           ; $A8B0: 99 6C 04
  DEY                                   ; $A8B3: 88
  BPL $A8AD                             ; $A8B4: 10 F7
  INC $0501                             ; $A8B6: EE 01 05
  LDY #$28                              ; $A8B9: A0 28
  JSR $EE07                             ; $A8BB: 20 07 EE
; --- Data Region ---
  .byte $1B,$A0,$60                       ; $A8BE: 1B A0 60
Loc_A8C1:  ; (dispatch callback target)
; --- Code Region ---
  JSR $DF27                             ; $A8C1: 20 27 DF
  BCC $A8D7                             ; $A8C4: 90 11
  JSR $ABD9                             ; $A8C6: 20 D9 AB
  LDA $050B                             ; $A8C9: AD 0B 05
  INC $050B                             ; $A8CC: EE 0B 05
  CMP $0542                             ; $A8CF: CD 42 05
  BCC $A8D7                             ; $A8D2: 90 03
  INC $0501                             ; $A8D4: EE 01 05
Loc_A8D7:
  RTS                                   ; $A8D7: 60
Loc_A8D8:  ; (dispatch callback target)
  LDA #$C7                              ; $A8D8: A9 C7
  JSR $F283                             ; $A8DA: 20 83 F2
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
  STA $0424                             ; $A910: 8D 24 04
  STA $0425                             ; $A913: 8D 25 04
  RTS                                   ; $A916: 60
Loc_A917:  ; (dispatch callback target)
  LDA #$5B                              ; $A917: A9 5B
  STA $B2                               ; $A919: 85 B2
  LDA $0542                             ; $A91B: AD 42 05
  ASL                                   ; $A91E: 0A
  TAY                                   ; $A91F: A8
  LDA $BA9F,Y                           ; $A920: B9 9F BA
  STA $10                               ; $A923: 85 10
  LDA $BAA0,Y                           ; $A925: B9 A0 BA
  STA $11                               ; $A928: 85 11
  LDA #$00                              ; $A92A: A9 00
  STA $12                               ; $A92C: 85 12
  JSR $ED1E                             ; $A92E: 20 1E ED
  LDA #$A4                              ; $A931: A9 A4
  STA $10                               ; $A933: 85 10
  LDA #$AB                              ; $A935: A9 AB
  STA $11                               ; $A937: 85 11
  LDA #$C4                              ; $A939: A9 C4
  STA $00                               ; $A93B: 85 00
  LDA #$AB                              ; $A93D: A9 AB
  STA $01                               ; $A93F: 85 01
  LDA $12                               ; $A941: A5 12
  JSR $EDF5                             ; $A943: 20 F5 ED
  JSR $DF27                             ; $A946: 20 27 DF
  BCC $A99F                             ; $A949: 90 54
  LDA $81                               ; $A94B: A5 81
  AND #$01                              ; $A94D: 29 01
  BEQ $A968                             ; $A94F: F0 17
  LDY $12                               ; $A951: A4 12
  LDA $0580,Y                           ; $A953: B9 80 05
  STA $0543                             ; $A956: 8D 43 05
  LDA $0505                             ; $A959: AD 05 05
  LDY $12                               ; $A95C: A4 12
  CMP $ABC9,Y                           ; $A95E: D9 C9 AB
  BCC $A966                             ; $A961: 90 03
  JMP $A9A0                             ; $A963: 4C A0 A9
Loc_A966:
  LDA #$00                              ; $A966: A9 00
Loc_A968:
  LDA $81                               ; $A968: A5 81
  AND #$02                              ; $A96A: 29 02
  BEQ $A99F                             ; $A96C: F0 31
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
  JMP $A1F7                             ; $A99C: 4C F7 A1
Loc_A99F:
  RTS                                   ; $A99F: 60
Loc_A9A0:
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
  BNE $A9D4                             ; $A9C9: D0 09
  LDY $050A                             ; $A9CB: AC 0A 05
  INC $0501                             ; $A9CE: EE 01 05
  JMP $AA03                             ; $A9D1: 4C 03 AA
Loc_A9D4:
  LDA #$F4                              ; $A9D4: A9 F4
  JSR $F283                             ; $A9D6: 20 83 F2
  INC $0501                             ; $A9D9: EE 01 05
  RTS                                   ; $A9DC: 60
Loc_A9DD:  ; (dispatch callback target)
  JSR $D4FB                             ; $A9DD: 20 FB D4
  JSR $D5EE                             ; $A9E0: 20 EE D5
  JSR $D657                             ; $A9E3: 20 57 D6
  JSR $DF27                             ; $A9E6: 20 27 DF
  BCC $AA28                             ; $A9E9: 90 3D
  LDA $81                               ; $A9EB: A5 81
  LSR                                   ; $A9ED: 4A
  BCS $A9F6                             ; $A9EE: B0 06
  LSR                                   ; $A9F0: 4A
  BCS $AA23                             ; $A9F1: B0 30
  JMP $AA28                             ; $A9F3: 4C 28 AA
Loc_A9F6:
  JSR $D68A                             ; $A9F6: 20 8A D6
  TYA                                   ; $A9F9: 98
  BMI $AA28                             ; $A9FA: 30 2C
  JSR $DC4B                             ; $A9FC: 20 4B DC
  CMP #$FF                              ; $A9FF: C9 FF
  BNE $AA28                             ; $AA01: D0 25
Loc_AA03:
  STY $0509                             ; $AA03: 8C 09 05
  JSR $B860                             ; $AA06: 20 60 B8
  CMP #$06                              ; $AA09: C9 06
  BCS $AA29                             ; $AA0B: B0 1C
  JSR $AD80                             ; $AA0D: 20 80 AD
  BCS $AA1D                             ; $AA10: B0 0B
  LDA #$0A                              ; $AA12: A9 0A
  STA $0501                             ; $AA14: 8D 01 05
  LDA #$F7                              ; $AA17: A9 F7
  JSR $F283                             ; $AA19: 20 83 F2
  RTS                                   ; $AA1C: 60
Loc_AA1D:
  INC $0501                             ; $AA1D: EE 01 05
  JMP $AD63                             ; $AA20: 4C 63 AD
Loc_AA23:
  LDA #$00                              ; $AA23: A9 00
  STA $0501                             ; $AA25: 8D 01 05
Loc_AA28:
  RTS                                   ; $AA28: 60
Loc_AA29:
  LDA #$4C                              ; $AA29: A9 4C
  JMP $F283                             ; $AA2B: 4C 83 F2
Loc_AA2E:  ; (dispatch callback target)
  JSR $DC63                             ; $AA2E: 20 63 DC
  JSR $D657                             ; $AA31: 20 57 D6
  JSR $DF27                             ; $AA34: 20 27 DF
  BCC $AA6B                             ; $AA37: 90 32
  LDA $81                               ; $AA39: A5 81
  AND #$01                              ; $AA3B: 29 01
  BEQ $AA6B                             ; $AA3D: F0 2C
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
  STA $04C8                             ; $AA5E: 8D C8 04
  LDA #$05                              ; $AA61: A9 05
  STA $0310                             ; $AA63: 8D 10 03
  LDA #$00                              ; $AA66: A9 00
  STA $0300                             ; $AA68: 8D 00 03
Loc_AA6B:
  RTS                                   ; $AA6B: 60
Loc_AA6C:  ; (dispatch callback target)
  LDA $04C8                             ; $AA6C: AD C8 04
  BNE $AAA6                             ; $AA6F: D0 35
  LDY $050A                             ; $AA71: AC 0A 05
  LDA $0664,Y                           ; $AA74: B9 64 06
  JSR $F2D7                             ; $AA77: 20 D7 F2
  LDY #$0B                              ; $AA7A: A0 0B
  LDA ($00),Y                           ; $AA7C: B1 00
  AND #$F0                              ; $AA7E: 29 F0
  STA $052C                             ; $AA80: 8D 2C 05
  LDY #$01                              ; $AA83: A0 01
  LDA ($00),Y                           ; $AA85: B1 00
  STA $052E                             ; $AA87: 8D 2E 05
  LDY $0543                             ; $AA8A: AC 43 05
  LDA $ABC9,Y                           ; $AA8D: B9 C9 AB
  STA $00                               ; $AA90: 85 00
  LDA $0505                             ; $AA92: AD 05 05
  SEC                                   ; $AA95: 38
  SBC $00                               ; $AA96: E5 00
  STA $0505                             ; $AA98: 8D 05 05
  JSR $B02B                             ; $AA9B: 20 2B B0
  JSR $DB03                             ; $AA9E: 20 03 DB
  LDA #$00                              ; $AAA1: A9 00
  STA $050B                             ; $AAA3: 8D 0B 05
Loc_AAA6:
  RTS                                   ; $AAA6: 60
Loc_AAA7:  ; (dispatch callback target)
  LDA $007E                             ; $AAA7: AD 7E 00
  BNE $AAE2                             ; $AAAA: D0 36
  LDA $050B                             ; $AAAC: AD 0B 05
  STA $0509                             ; $AAAF: 8D 09 05
  LDA #$01                              ; $AAB2: A9 01
  STA $12                               ; $AAB4: 85 12
  JSR $D6CC                             ; $AAB6: 20 CC D6
  INC $050B                             ; $AAB9: EE 0B 05
  LDA $050B                             ; $AABC: AD 0B 05
  CMP #$14                              ; $AABF: C9 14
  BCC $AAE2                             ; $AAC1: 90 1F
  INC $0501                             ; $AAC3: EE 01 05
  LDA $0544                             ; $AAC6: AD 44 05
  BEQ $AAE3                             ; $AAC9: F0 18
  LDA #$04                              ; $AACB: A9 04
  STA $00A4                             ; $AACD: 8D A4 00
  LDA #$73                              ; $AAD0: A9 73
  JSR $F283                             ; $AAD2: 20 83 F2
Loc_AAD5:
  LDA $050A                             ; $AAD5: AD 0A 05
  STA $0509                             ; $AAD8: 8D 09 05
  LDY #$3D                              ; $AADB: A0 3D
  JSR $EE07                             ; $AADD: 20 07 EE
; --- Data Region ---
  .byte $27,$A0,$60,$A9,$03,$8D,$A4,$00,$AD,$43,$05,$29,$0F,$A8,$C0,$01; $AAE0: 27 A0 60 A9 03 8D A4 00 AD 43 05 29 0F A8 C0 01
  .byte $F0,$10,$C0,$09,$D0,$1B,$AD,$2C,$04,$D0,$07,$AD,$2D,$04,$D0,$02; $AAF0: F0 10 C0 09 D0 1B AD 2C 04 D0 07 AD 2D 04 D0 02
  .byte $A0,$01                           ; $AB00: A0 01
Loc_AB02:
; --- Code Region ---
  LDA $0432                             ; $AB02: AD 32 04
  CMP #$FF                              ; $AB05: C9 FF
  BEQ $AB11                             ; $AB07: F0 08
  STA $042C                             ; $AB09: 8D 2C 04
  LDA #$4E                              ; $AB0C: A9 4E
  JMP $F293                             ; $AB0E: 4C 93 F2
Loc_AB11:
  LDA $AB1A,Y                           ; $AB11: B9 1A AB
  JSR $F283                             ; $AB14: 20 83 F2
  JMP $AAD5                             ; $AB17: 4C D5 AA
; --- Data Region ---
  .byte $6C,$6D,$6E,$6C,$6C,$6F,$6C,$6C,$70,$BB,$71,$BA,$6C,$6C,$6C,$72; $AB1A: 6C 6D 6E 6C 6C 6F 6C 6C 70 BB 71 BA 6C 6C 6C 72
Loc_AB2A:  ; (dispatch callback target)
; --- Code Region ---
  JSR $DF27                             ; $AB2A: 20 27 DF
  BCC $AB51                             ; $AB2D: 90 22
  JSR $DC63                             ; $AB2F: 20 63 DC
  LDA $81                               ; $AB32: A5 81
  AND #$01                              ; $AB34: 29 01
  BEQ $AB51                             ; $AB36: F0 19
  LDY $050A                             ; $AB38: AC 0A 05
  LDA $0664,Y                           ; $AB3B: B9 64 06
  STA $042C                             ; $AB3E: 8D 2C 04
  JSR $DEE9                             ; $AB41: 20 E9 DE
  BCC $AB6F                             ; $AB44: 90 29
  INC $0501                             ; $AB46: EE 01 05
  JSR $E57F                             ; $AB49: 20 7F E5
  LDA #$7B                              ; $AB4C: A9 7B
  JSR $E68B                             ; $AB4E: 20 8B E6
Loc_AB51:
  RTS                                   ; $AB51: 60
Loc_AB52:  ; (dispatch callback target)
  JSR $DF27                             ; $AB52: 20 27 DF
  BCC $AB85                             ; $AB55: 90 2E
  JSR $DC63                             ; $AB57: 20 63 DC
  LDA $81                               ; $AB5A: A5 81
  AND #$01                              ; $AB5C: 29 01
  BEQ $AB85                             ; $AB5E: F0 25
  LDA $042D                             ; $AB60: AD 2D 04
  CMP #$FF                              ; $AB63: C9 FF
  BNE $AB86                             ; $AB65: D0 1F
  JSR $E57F                             ; $AB67: 20 7F E5
  LDA #$1D                              ; $AB6A: A9 1D
  JSR $E673                             ; $AB6C: 20 73 E6
Loc_AB6F:
  LDY #$03                              ; $AB6F: A0 03
Loc_AB71:
  LDA $046C,Y                           ; $AB71: B9 6C 04
  STA $6F3F,Y                           ; $AB74: 99 3F 6F
  DEY                                   ; $AB77: 88
  BPL $AB71                             ; $AB78: 10 F7
  LDA #$00                              ; $AB7A: A9 00
  STA $0501                             ; $AB7C: 8D 01 05
  STA $0500                             ; $AB7F: 8D 00 05
  JMP $A1F7                             ; $AB82: 4C F7 A1
Loc_AB85:
  RTS                                   ; $AB85: 60
Loc_AB86:
  LDA #$FF                              ; $AB86: A9 FF
  STA $042D                             ; $AB88: 8D 2D 04
  LDA #$4B                              ; $AB8B: A9 4B
  JMP $F293                             ; $AB8D: 4C 93 F2
Loc_AB90:  ; (dispatch callback target)
  JSR $DF27                             ; $AB90: 20 27 DF
  BCC $ABA3                             ; $AB93: 90 0E
  JSR $DC63                             ; $AB95: 20 63 DC
  LDA $81                               ; $AB98: A5 81
  AND #$01                              ; $AB9A: 29 01
  BEQ $ABA3                             ; $AB9C: F0 05
  LDA #$00                              ; $AB9E: A9 00
  STA $0501                             ; $ABA0: 8D 01 05
Loc_ABA3:
  RTS                                   ; $ABA3: 60
; --- Data Region ---
  .byte $1E,$18,$1E,$98,$2E,$18,$2E,$98,$3E,$18,$3E,$98,$4E,$18,$4E,$98; $ABA4: 1E 18 1E 98 2E 18 2E 98 3E 18 3E 98 4E 18 4E 98
  .byte $5E,$18,$5E,$98,$6E,$18,$6E,$98,$7E,$18,$7E,$98,$8E,$18,$8E,$98; $ABB4: 5E 18 5E 98 6E 18 6E 98 7E 18 7E 98 8E 18 8E 98
  .byte $00,$07,$00,$00,$80,$06,$05,$04,$06,$07,$08,$08,$08,$0A,$09,$09; $ABC4: 00 07 00 00 80 06 05 04 06 07 08 08 08 0A 09 09
  .byte $0A,$0A,$08,$0C,$0A               ; $ABD4: 0A 0A 08 0C 0A
Loc_ABD9:
; --- Code Region ---
  LDY $050B                             ; $ABD9: AC 0B 05
  LDA $0580,Y                           ; $ABDC: B9 80 05
  ASL                                   ; $ABDF: 0A
  TAY                                   ; $ABE0: A8
  LDA $AC91,Y                           ; $ABE1: B9 91 AC
  STA $00                               ; $ABE4: 85 00
  LDA $AC92,Y                           ; $ABE6: B9 92 AC
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
  LDA $AC52,Y                           ; $AC00: B9 52 AC
  STA $0380,X                           ; $AC03: 9D 80 03
  INX                                   ; $AC06: E8
  LDA $AC51,Y                           ; $AC07: B9 51 AC
  STA $0380,X                           ; $AC0A: 9D 80 03
  INX                                   ; $AC0D: E8
  LDY #$01                              ; $AC0E: A0 01
Loc_AC10:
  LDA ($00),Y                           ; $AC10: B1 00
  STA $0380,X                           ; $AC12: 9D 80 03
  INX                                   ; $AC15: E8
  INY                                   ; $AC16: C8
  DEC $03                               ; $AC17: C6 03
  BNE $AC10                             ; $AC19: D0 F5
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
Loc_AC38:
  LDA ($00),Y                           ; $AC38: B1 00
  STA $0380,X                           ; $AC3A: 9D 80 03
  INX                                   ; $AC3D: E8
  INY                                   ; $AC3E: C8
  DEC $03                               ; $AC3F: C6 03
  BNE $AC38                             ; $AC41: D0 F5
  LDA #$FF                              ; $AC43: A9 FF
  STA $0380,X                           ; $AC45: 9D 80 03
  LDA $007E                             ; $AC48: AD 7E 00
  ORA #$04                              ; $AC4B: 09 04
  STA $007E                             ; $AC4D: 8D 7E 00
  RTS                                   ; $AC50: 60
; --- Data Region ---
  .byte $A4,$25,$C4,$25,$B4,$25,$D4,$25,$E4,$25,$04,$26,$F4,$25,$14,$26; $AC51: A4 25 C4 25 B4 25 D4 25 E4 25 04 26 F4 25 14 26
  .byte $24,$26,$44,$26,$34,$26,$54,$26,$64,$26,$84,$26,$74,$26,$94,$26; $AC61: 24 26 44 26 34 26 54 26 64 26 84 26 74 26 94 26
  .byte $A4,$26,$C4,$26,$B4,$26,$D4,$26,$E4,$26,$04,$27,$F4,$26,$14,$27; $AC71: A4 26 C4 26 B4 26 D4 26 E4 26 04 27 F4 26 14 27
  .byte $24,$27,$44,$27,$34,$27,$54,$27,$64,$27,$84,$27,$74,$27,$94,$27; $AC81: 24 27 44 27 34 27 54 27 64 27 84 27 74 27 94 27
  .byte $B1,$AC,$BB,$AC,$C5,$AC,$CF,$AC,$D9,$AC,$E3,$AC,$ED,$AC,$FD,$AC; $AC91: B1 AC BB AC C5 AC CF AC D9 AC E3 AC ED AC FD AC
  .byte $07,$AD,$11,$AD,$1B,$AD,$25,$AD,$35,$AD,$3F,$AD,$49,$AD,$53,$AD; $ACA1: 07 AD 11 AD 1B AD 25 AD 35 AD 3F AD 49 AD 53 AD
  .byte $04,$40,$41,$42,$43,$04,$50,$51,$52,$53,$04,$44,$45,$46,$47,$04; $ACB1: 04 40 41 42 43 04 50 51 52 53 04 44 45 46 47 04
  .byte $54,$55,$56,$57,$04,$48,$49,$4A,$4B,$04,$58,$59,$5A,$5B,$04,$4C; $ACC1: 54 55 56 57 04 48 49 4A 4B 04 58 59 5A 5B 04 4C
  .byte $4D,$4E,$4F,$04,$5C,$5D,$5E,$5F,$04,$60,$61,$62,$63,$04,$70,$71; $ACD1: 4D 4E 4F 04 5C 5D 5E 5F 04 60 61 62 63 04 70 71
  .byte $72,$73,$04,$40,$41,$64,$65,$04,$50,$51,$74,$75,$07,$66,$67,$68; $ACE1: 72 73 04 40 41 64 65 04 50 51 74 75 07 66 67 68
  .byte $69,$6A,$6B,$6C,$07,$76,$77,$78,$79,$7A,$7B,$7C,$04,$6D,$6E,$6F; $ACF1: 69 6A 6B 6C 07 76 77 78 79 7A 7B 7C 04 6D 6E 6F
  .byte $C0,$04,$7D,$7E,$7F,$D0,$04,$C1,$C2; $AD01: C0 04 7D 7E 7F D0 04 C1 C2
Loc_AD0A:
; --- Code Region ---
  DCP ($C4,X)                           ; $AD0A: C3 C4
  NOP $D1                               ; $AD0C: 04 D1
  JAM                                   ; $AD0E: D2
  DCP ($D4),Y                           ; $AD0F: D3 D4
  NOP $C5                               ; $AD11: 04 C5
  DEC $C7                               ; $AD13: C6 C7
  INY                                   ; $AD15: C8
  NOP $D5                               ; $AD16: 04 D5
  DEC $D7,X                             ; $AD18: D6 D7
  CLD                                   ; $AD1A: D8
  NOP $C9                               ; $AD1B: 04 C9
  DEX                                   ; $AD1D: CA
  AXS #$CC                              ; $AD1E: CB CC
  NOP $D9                               ; $AD20: 04 D9
  NOP                                   ; $AD22: DA
  DCP $07DC,Y                           ; $AD23: DB DC 07
  CMP $CFCE                             ; $AD26: CD CE CF
  CPX #$E1                              ; $AD29: E0 E1
  NOP #$E3                              ; $AD2B: E2 E3
  SLO $DD                               ; $AD2D: 07 DD
  DEC $F0DF,X                           ; $AD2F: DE DF F0
  SBC ($F2),Y                           ; $AD32: F1 F2
  ISB ($04),Y                           ; $AD34: F3 04
  JAM                                   ; $AD36: 62
  RRA ($E4,X)                           ; $AD37: 63 E4
  SBC $04                               ; $AD39: E5 04
  JAM                                   ; $AD3B: 72
Loc_AD3C:
  RRA ($F4),Y                           ; $AD3C: 73 F4
  SBC $04,X                             ; $AD3E: F5 04
  CMP #$CA                              ; $AD40: C9 CA
  INC $E7                               ; $AD42: E6 E7
  NOP $D9                               ; $AD44: 04 D9
  NOP                                   ; $AD46: DA
  INC $F7,X                             ; $AD47: F6 F7
  NOP $E8                               ; $AD49: 04 E8
  SBC #$40                              ; $AD4B: E9 40
  EOR ($04,X)                           ; $AD4D: 41 04
  SED                                   ; $AD4F: F8
  SBC $5150,Y                           ; $AD50: F9 50 51
  SLO $EA                               ; $AD53: 07 EA
  SBC #$EC                              ; $AD55: EB EC
  SBC $EFEE                             ; $AD57: ED EE EF
  BMI $AD63                             ; $AD5A: 30 07
  NOP                                   ; $AD5C: FA
  ISB $FDFC,Y                           ; $AD5D: FB FC FD
Loc_AD60:  ; (dispatch callback target)
  INC $31FF,X                           ; $AD60: FE FF 31
Loc_AD63:
  LDA $0543                             ; $AD63: AD 43 05
  AND #$0F                              ; $AD66: 29 0F
  TAY                                   ; $AD68: A8
  LDA $AD70,Y                           ; $AD69: B9 70 AD
  JSR $F283                             ; $AD6C: 20 83 F2
  RTS                                   ; $AD6F: 60
; --- Data Region ---
  .byte $FB,$FC,$FD,$FE,$60,$61,$62,$63,$64,$65,$66,$67,$68,$69,$6A,$6B; $AD70: FB FC FD FE 60 61 62 63 64 65 66 67 68 69 6A 6B
Loc_AD80:
; --- Code Region ---
  LDY $0509                             ; $AD80: AC 09 05
  LDA $0600,Y                           ; $AD83: B9 00 06
  STA $10                               ; $AD86: 85 10
  LDA $0614,Y                           ; $AD88: B9 14 06
  STA $11                               ; $AD8B: 85 11
  JSR $DB46                             ; $AD8D: 20 46 DB
  STA $0A                               ; $AD90: 85 0A
  LDY $050A                             ; $AD92: AC 0A 05
  LDA $0600,Y                           ; $AD95: B9 00 06
  STA $10                               ; $AD98: 85 10
  LDA $0614,Y                           ; $AD9A: B9 14 06
  STA $11                               ; $AD9D: 85 11
  JSR $DB46                             ; $AD9F: 20 46 DB
  STA $0B                               ; $ADA2: 85 0B
  LDA $0543                             ; $ADA4: AD 43 05
  AND #$0F                              ; $ADA7: 29 0F
  JSR $EADE                             ; $ADA9: 20 DE EA
; --- Data Region ---
  .byte $CC,$AD,$D8,$AD,$D8,$AD,$D8,$AD,$E4,$AD,$EE,$AD,$FB,$AD,$68,$AE; $ADAC: CC AD D8 AD D8 AD D8 AD E4 AD EE AD FB AD 68 AE
  .byte $C4,$AE,$CE,$AE,$0A,$AF,$73,$AF,$0A,$AF,$A1,$AF,$D3,$AF,$1D,$B0; $ADBC: C4 AE CE AE 0A AF 73 AF 0A AF A1 AF D3 AF 1D B0
Loc_ADCC:  ; (dispatch callback target)
; --- Code Region ---
  LDA $0A                               ; $ADCC: A5 0A
  BEQ $ADD6                             ; $ADCE: F0 06
  CMP #$02                              ; $ADD0: C9 02
  BEQ $ADD6                             ; $ADD2: F0 02
  CLC                                   ; $ADD4: 18
  RTS                                   ; $ADD5: 60
Loc_ADD6:
  SEC                                   ; $ADD6: 38
  RTS                                   ; $ADD7: 60
Loc_ADD8:  ; (dispatch callback target)
  LDA $0A                               ; $ADD8: A5 0A
  BEQ $ADE2                             ; $ADDA: F0 06
  CMP #$04                              ; $ADDC: C9 04
  BEQ $ADE2                             ; $ADDE: F0 02
  CLC                                   ; $ADE0: 18
  RTS                                   ; $ADE1: 60
Loc_ADE2:
  SEC                                   ; $ADE2: 38
  RTS                                   ; $ADE3: 60
Loc_ADE4:  ; (dispatch callback target)
  LDA $0A                               ; $ADE4: A5 0A
  CMP #$03                              ; $ADE6: C9 03
  BEQ $ADEC                             ; $ADE8: F0 02
  CLC                                   ; $ADEA: 18
  RTS                                   ; $ADEB: 60
Loc_ADEC:
  SEC                                   ; $ADEC: 38
  RTS                                   ; $ADED: 60
Loc_ADEE:  ; (dispatch callback target)
  LDY $0509                             ; $ADEE: AC 09 05
  BEQ $ADF9                             ; $ADF1: F0 06
  CPY #$0A                              ; $ADF3: C0 0A
  BEQ $ADF9                             ; $ADF5: F0 02
  CLC                                   ; $ADF7: 18
  RTS                                   ; $ADF8: 60
Loc_ADF9:
  SEC                                   ; $ADF9: 38
  RTS                                   ; $ADFA: 60
Loc_ADFB:  ; (dispatch callback target)
  LDY $0A                               ; $ADFB: A4 0A
  CPY #$05                              ; $ADFD: C0 05
  BNE $AE29                             ; $ADFF: D0 28
  JSR $AE2D                             ; $AE01: 20 2D AE
  INC $00                               ; $AE04: E6 00
  JSR $AE42                             ; $AE06: 20 42 AE
  BCS $AE2B                             ; $AE09: B0 20
  JSR $AE2D                             ; $AE0B: 20 2D AE
  DEC $00                               ; $AE0E: C6 00
  JSR $AE42                             ; $AE10: 20 42 AE
  BCS $AE2B                             ; $AE13: B0 16
  JSR $AE2D                             ; $AE15: 20 2D AE
  INC $01                               ; $AE18: E6 01
  JSR $AE42                             ; $AE1A: 20 42 AE
  BCS $AE2B                             ; $AE1D: B0 0C
  JSR $AE2D                             ; $AE1F: 20 2D AE
  DEC $01                               ; $AE22: C6 01
  JSR $AE42                             ; $AE24: 20 42 AE
  BCS $AE2B                             ; $AE27: B0 02
Loc_AE29:
  CLC                                   ; $AE29: 18
  RTS                                   ; $AE2A: 60
Loc_AE2B:
  SEC                                   ; $AE2B: 38
  RTS                                   ; $AE2C: 60
Loc_AE2D:
  LDY $0509                             ; $AE2D: AC 09 05
  LDA $0600,Y                           ; $AE30: B9 00 06
  STA $00                               ; $AE33: 85 00
  LDA $0614,Y                           ; $AE35: B9 14 06
  CMP #$10                              ; $AE38: C9 10
  BCC $AE3F                             ; $AE3A: 90 03
  SEC                                   ; $AE3C: 38
  SBC #$01                              ; $AE3D: E9 01
Loc_AE3F:
  STA $01                               ; $AE3F: 85 01
  RTS                                   ; $AE41: 60
Loc_AE42:
  LDA $00                               ; $AE42: A5 00
  CMP #$20                              ; $AE44: C9 20
  BCS $AE29                             ; $AE46: B0 E1
  LDA $01                               ; $AE48: A5 01
  CMP #$14                              ; $AE4A: C9 14
  BCS $AE29                             ; $AE4C: B0 DB
  LDY $050A                             ; $AE4E: AC 0A 05
  LDA $0600,Y                           ; $AE51: B9 00 06
  CMP $00                               ; $AE54: C5 00
  BNE $AE29                             ; $AE56: D0 D1
  LDA $0614,Y                           ; $AE58: B9 14 06
  CMP #$10                              ; $AE5B: C9 10
  BCC $AE62                             ; $AE5D: 90 03
  SEC                                   ; $AE5F: 38
  SBC #$01                              ; $AE60: E9 01
Loc_AE62:
  CMP $01                               ; $AE62: C5 01
  BNE $AE29                             ; $AE64: D0 C3
  SEC                                   ; $AE66: 38
  RTS                                   ; $AE67: 60
Loc_AE68:  ; (dispatch callback target)
  LDY $0A                               ; $AE68: A4 0A
  BEQ $AE70                             ; $AE6A: F0 04
  CPY #$04                              ; $AE6C: C0 04
  BNE $AEA2                             ; $AE6E: D0 32
Loc_AE70:
  JSR $AE2D                             ; $AE70: 20 2D AE
  INC $00                               ; $AE73: E6 00
  JSR $AEA4                             ; $AE75: 20 A4 AE
  CMP #$FF                              ; $AE78: C9 FF
  BEQ $AEA0                             ; $AE7A: F0 24
  JSR $AE2D                             ; $AE7C: 20 2D AE
  DEC $00                               ; $AE7F: C6 00
  JSR $AEA4                             ; $AE81: 20 A4 AE
  CMP #$FF                              ; $AE84: C9 FF
  BEQ $AEA0                             ; $AE86: F0 18
  JSR $AE2D                             ; $AE88: 20 2D AE
  INC $01                               ; $AE8B: E6 01
  JSR $AEA4                             ; $AE8D: 20 A4 AE
  CMP #$FF                              ; $AE90: C9 FF
  BEQ $AEA0                             ; $AE92: F0 0C
  JSR $AE2D                             ; $AE94: 20 2D AE
  DEC $01                               ; $AE97: C6 01
  JSR $AEA4                             ; $AE99: 20 A4 AE
  CMP #$FF                              ; $AE9C: C9 FF
  BNE $AEA2                             ; $AE9E: D0 02
Loc_AEA0:
  SEC                                   ; $AEA0: 38
  RTS                                   ; $AEA1: 60
Loc_AEA2:
  CLC                                   ; $AEA2: 18
  RTS                                   ; $AEA3: 60
Loc_AEA4:
  LDA $00                               ; $AEA4: A5 00
  CMP #$20                              ; $AEA6: C9 20
  BCS $AEC1                             ; $AEA8: B0 17
  LDA $01                               ; $AEAA: A5 01
  CMP #$14                              ; $AEAC: C9 14
  BCS $AEC1                             ; $AEAE: B0 11
  CMP #$0F                              ; $AEB0: C9 0F
  BNE $AEB7                             ; $AEB2: D0 03
  INC $0001                             ; $AEB4: EE 01 00
Loc_AEB7:
  JSR $D6B6                             ; $AEB7: 20 B6 D6
  TYA                                   ; $AEBA: 98
  BMI $AEC1                             ; $AEBB: 30 04
  JSR $DC4B                             ; $AEBD: 20 4B DC
  RTS                                   ; $AEC0: 60
Loc_AEC1:
  LDA #$00                              ; $AEC1: A9 00
  RTS                                   ; $AEC3: 60
Loc_AEC4:  ; (dispatch callback target)
  LDA $0A                               ; $AEC4: A5 0A
  CMP #$05                              ; $AEC6: C9 05
  BNE $AECC                             ; $AEC8: D0 02
  CLC                                   ; $AECA: 18
  RTS                                   ; $AECB: 60
Loc_AECC:
  SEC                                   ; $AECC: 38
  RTS                                   ; $AECD: 60
Loc_AECE:  ; (dispatch callback target)
  LDA $0B                               ; $AECE: A5 0B
  CMP #$04                              ; $AED0: C9 04
  BEQ $AED8                             ; $AED2: F0 04
  CMP #$05                              ; $AED4: C9 05
  BNE $AF08                             ; $AED6: D0 30
Loc_AED8:
  JSR $AE2D                             ; $AED8: 20 2D AE
  INC $00                               ; $AEDB: E6 00
  JSR $AE42                             ; $AEDD: 20 42 AE
  BCS $AF00                             ; $AEE0: B0 1E
  JSR $AE2D                             ; $AEE2: 20 2D AE
  DEC $00                               ; $AEE5: C6 00
  JSR $AE42                             ; $AEE7: 20 42 AE
  BCS $AF00                             ; $AEEA: B0 14
  JSR $AE2D                             ; $AEEC: 20 2D AE
  INC $01                               ; $AEEF: E6 01
  JSR $AE42                             ; $AEF1: 20 42 AE
  BCS $AF00                             ; $AEF4: B0 0A
  JSR $AE2D                             ; $AEF6: 20 2D AE
  DEC $01                               ; $AEF9: C6 01
  JSR $AE42                             ; $AEFB: 20 42 AE
  BCC $AF08                             ; $AEFE: 90 08
Loc_AF00:
  LDA $0A                               ; $AF00: A5 0A
  CMP #$05                              ; $AF02: C9 05
  BEQ $AF08                             ; $AF04: F0 02
  SEC                                   ; $AF06: 38
  RTS                                   ; $AF07: 60
Loc_AF08:
  CLC                                   ; $AF08: 18
  RTS                                   ; $AF09: 60
Loc_AF0A:  ; (dispatch callback target)
  LDY $0A                               ; $AF0A: A4 0A
  CPY #$03                              ; $AF0C: C0 03
  BNE $AF42                             ; $AF0E: D0 32
  JSR $AE2D                             ; $AF10: 20 2D AE
  INC $00                               ; $AF13: E6 00
  JSR $AF44                             ; $AF15: 20 44 AF
  CMP #$03                              ; $AF18: C9 03
  BEQ $AF40                             ; $AF1A: F0 24
  JSR $AE2D                             ; $AF1C: 20 2D AE
  DEC $00                               ; $AF1F: C6 00
  JSR $AF44                             ; $AF21: 20 44 AF
  CMP #$03                              ; $AF24: C9 03
  BEQ $AF40                             ; $AF26: F0 18
  JSR $AE2D                             ; $AF28: 20 2D AE
  INC $01                               ; $AF2B: E6 01
  JSR $AF44                             ; $AF2D: 20 44 AF
  CMP #$03                              ; $AF30: C9 03
  BEQ $AF40                             ; $AF32: F0 0C
  JSR $AE2D                             ; $AF34: 20 2D AE
  DEC $01                               ; $AF37: C6 01
  JSR $AF44                             ; $AF39: 20 44 AF
  CMP #$03                              ; $AF3C: C9 03
  BNE $AF42                             ; $AF3E: D0 02
Loc_AF40:
  SEC                                   ; $AF40: 38
  RTS                                   ; $AF41: 60
Loc_AF42:
  CLC                                   ; $AF42: 18
  RTS                                   ; $AF43: 60
Loc_AF44:
  LDA $00                               ; $AF44: A5 00
  CMP #$20                              ; $AF46: C9 20
  BCS $AF70                             ; $AF48: B0 26
  LDA $01                               ; $AF4A: A5 01
  CMP #$14                              ; $AF4C: C9 14
  BCS $AF70                             ; $AF4E: B0 20
  CMP #$0F                              ; $AF50: C9 0F
  BNE $AF57                             ; $AF52: D0 03
  INC $0001                             ; $AF54: EE 01 00
Loc_AF57:
  JSR $D6B6                             ; $AF57: 20 B6 D6
  TYA                                   ; $AF5A: 98
  BMI $AF70                             ; $AF5B: 30 13
  JSR $DC4B                             ; $AF5D: 20 4B DC
  CMP #$FF                              ; $AF60: C9 FF
  BNE $AF70                             ; $AF62: D0 0C
  LDA $00                               ; $AF64: A5 00
  STA $10                               ; $AF66: 85 10
  LDA $01                               ; $AF68: A5 01
  STA $11                               ; $AF6A: 85 11
  JSR $DB46                             ; $AF6C: 20 46 DB
  RTS                                   ; $AF6F: 60
Loc_AF70:
  LDA #$FF                              ; $AF70: A9 FF
  RTS                                   ; $AF72: 60
Loc_AF73:  ; (dispatch callback target)
  LDA $0B                               ; $AF73: A5 0B
  BNE $AF9D                             ; $AF75: D0 26
  LDY $050A                             ; $AF77: AC 0A 05
  LDA $0664,Y                           ; $AF7A: B9 64 06
  JSR $F2D7                             ; $AF7D: 20 D7 F2
  LDY #$09                              ; $AF80: A0 09
  LDA ($00),Y                           ; $AF82: B1 00
  BNE $AF8D                             ; $AF84: D0 07
  DEY                                   ; $AF86: 88
  LDA ($00),Y                           ; $AF87: B1 00
  CMP #$64                              ; $AF89: C9 64
  BCC $AF9D                             ; $AF8B: 90 10
Loc_AF8D:
  LDY #$00                              ; $AF8D: A0 00
  LDA $0504                             ; $AF8F: AD 04 05
  BPL $AF96                             ; $AF92: 10 02
  LDY #$04                              ; $AF94: A0 04
Loc_AF96:
  LDA $04D8,Y                           ; $AF96: B9 D8 04
  CMP #$FF                              ; $AF99: C9 FF
  BEQ $AF9F                             ; $AF9B: F0 02
Loc_AF9D:
  CLC                                   ; $AF9D: 18
  RTS                                   ; $AF9E: 60
Loc_AF9F:
  SEC                                   ; $AF9F: 38
  RTS                                   ; $AFA0: 60
Loc_AFA1:  ; (dispatch callback target)
  LDY $0B                               ; $AFA1: A4 0B
  CPY #$05                              ; $AFA3: C0 05
  BNE $AFD1                             ; $AFA5: D0 2A
  JSR $AE2D                             ; $AFA7: 20 2D AE
  INC $00                               ; $AFAA: E6 00
  JSR $AE42                             ; $AFAC: 20 42 AE
  BCS $AFCF                             ; $AFAF: B0 1E
  JSR $AE2D                             ; $AFB1: 20 2D AE
  DEC $00                               ; $AFB4: C6 00
  JSR $AE42                             ; $AFB6: 20 42 AE
  BCS $AFCF                             ; $AFB9: B0 14
  JSR $AE2D                             ; $AFBB: 20 2D AE
  INC $01                               ; $AFBE: E6 01
  JSR $AE42                             ; $AFC0: 20 42 AE
  BCS $AFCF                             ; $AFC3: B0 0A
  JSR $AE2D                             ; $AFC5: 20 2D AE
  DEC $01                               ; $AFC8: C6 01
  JSR $AE42                             ; $AFCA: 20 42 AE
  BCC $AFD1                             ; $AFCD: 90 02
Loc_AFCF:
  SEC                                   ; $AFCF: 38
  RTS                                   ; $AFD0: 60
Loc_AFD1:
  CLC                                   ; $AFD1: 18
  RTS                                   ; $AFD2: 60
Loc_AFD3:  ; (dispatch callback target)
  LDY $0A                               ; $AFD3: A4 0A
  CPY #$05                              ; $AFD5: C0 05
  BEQ $B01B                             ; $AFD7: F0 42
  JSR $AE2D                             ; $AFD9: 20 2D AE
  INC $00                               ; $AFDC: E6 00
  JSR $AF44                             ; $AFDE: 20 44 AF
  CMP #$FF                              ; $AFE1: C9 FF
  BEQ $AFE9                             ; $AFE3: F0 04
  CMP #$05                              ; $AFE5: C9 05
  BNE $B019                             ; $AFE7: D0 30
Loc_AFE9:
  JSR $AE2D                             ; $AFE9: 20 2D AE
  DEC $00                               ; $AFEC: C6 00
  JSR $AF44                             ; $AFEE: 20 44 AF
  CMP #$FF                              ; $AFF1: C9 FF
  BEQ $AFF9                             ; $AFF3: F0 04
  CMP #$05                              ; $AFF5: C9 05
  BNE $B019                             ; $AFF7: D0 20
Loc_AFF9:
  JSR $AE2D                             ; $AFF9: 20 2D AE
  INC $01                               ; $AFFC: E6 01
  JSR $AF44                             ; $AFFE: 20 44 AF
  CMP #$FF                              ; $B001: C9 FF
  BEQ $B009                             ; $B003: F0 04
  CMP #$05                              ; $B005: C9 05
  BNE $B019                             ; $B007: D0 10
Loc_B009:
  JSR $AE2D                             ; $B009: 20 2D AE
  DEC $01                               ; $B00C: C6 01
  JSR $AF44                             ; $B00E: 20 44 AF
  CMP #$FF                              ; $B011: C9 FF
  BEQ $B01B                             ; $B013: F0 06
  CMP #$05                              ; $B015: C9 05
  BEQ $B01B                             ; $B017: F0 02
Loc_B019:
  SEC                                   ; $B019: 38
  RTS                                   ; $B01A: 60
Loc_B01B:
  CLC                                   ; $B01B: 18
  RTS                                   ; $B01C: 60
Loc_B01D:  ; (dispatch callback target)
  LDY $0A                               ; $B01D: A4 0A
  CPY #$03                              ; $B01F: C0 03
  BEQ $B029                             ; $B021: F0 06
  CPY #$05                              ; $B023: C0 05
  BEQ $B029                             ; $B025: F0 02
  SEC                                   ; $B027: 38
  RTS                                   ; $B028: 60
Loc_B029:
  CLC                                   ; $B029: 18
  RTS                                   ; $B02A: 60
Loc_B02B:
  LDY #$00                              ; $B02B: A0 00
  LDA #$00                              ; $B02D: A9 00
Loc_B02F:
  STA $042C,Y                           ; $B02F: 99 2C 04
  INY                                   ; $B032: C8
  CPY #$09                              ; $B033: C0 09
  BCC $B02F                             ; $B035: 90 F8
  STA $0544                             ; $B037: 8D 44 05
  LDA $0543                             ; $B03A: AD 43 05
  AND #$0F                              ; $B03D: 29 0F
  JSR $EADE                             ; $B03F: 20 DE EA
; --- Data Region ---
  .byte $62,$B0,$DD,$B0,$55,$B1,$7A,$B1,$D5,$B1,$43,$B2,$62,$B0,$CD,$B2; $B042: 62 B0 DD B0 55 B1 7A B1 D5 B1 43 B2 62 B0 CD B2
  .byte $1C,$B3,$B6,$B3,$D0,$B3,$2A,$B4,$66,$B4,$B8,$B4,$0C,$B5,$A6,$B5; $B052: 1C B3 B6 B3 D0 B3 2A B4 66 B4 B8 B4 0C B5 A6 B5
  .byte $20,$BE,$B7,$B0,$09,$EE,$01,$05,$A9,$FF,$8D,$44,$05,$60; $B062: 20 BE B7 B0 09 EE 01 05 A9 FF 8D 44 05 60
Loc_B070:
; --- Code Region ---
  LDY $050A                             ; $B070: AC 0A 05
  LDA $0664,Y                           ; $B073: B9 64 06
  JSR $F2D7                             ; $B076: 20 D7 F2
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
  JSR $E862                             ; $B098: 20 62 E8
  CLC                                   ; $B09B: 18
Loc_B09C:
  ADC #$09                              ; $B09C: 69 09
  STA $03                               ; $B09E: 85 03
  JSR $EBE9                             ; $B0A0: 20 E9 EB
  LDA $06                               ; $B0A3: A5 06
  STA $01                               ; $B0A5: 85 01
  LDA $07                               ; $B0A7: A5 07
Loc_B0A9:  ; (dispatch callback target)
  STA $02                               ; $B0A9: 85 02
  LDA #$0A                              ; $B0AB: A9 0A
  STA $03                               ; $B0AD: 85 03
  LDA #$00                              ; $B0AF: A9 00
  STA $04                               ; $B0B1: 85 04
  JSR $EA7C                             ; $B0B3: 20 7C EA
  PLA                                   ; $B0B6: 68
Loc_B0B7:  ; (dispatch callback target)
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
  JSR $F2D7                             ; $B0D3: 20 D7 F2
  JSR $B68B                             ; $B0D6: 20 8B B6
  INC $0501                             ; $B0D9: EE 01 05
  RTS                                   ; $B0DC: 60
Loc_B0DD:  ; (dispatch callback target)
  JSR $B7BE                             ; $B0DD: 20 BE B7
  BCS $B0EB                             ; $B0E0: B0 09
  INC $0501                             ; $B0E2: EE 01 05
  LDA #$FF                              ; $B0E5: A9 FF
  STA $0544                             ; $B0E7: 8D 44 05
  RTS                                   ; $B0EA: 60
Loc_B0EB:
  LDY $050A                             ; $B0EB: AC 0A 05
  LDA $0664,Y                           ; $B0EE: B9 64 06
  JSR $F2D7                             ; $B0F1: 20 D7 F2
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
  JSR $EA7C                             ; $B112: 20 7C EA
  PLA                                   ; $B115: 68
  CLC                                   ; $B116: 18
  ADC $01                               ; $B117: 65 01
  STA $00                               ; $B119: 85 00
  LDA #$00                              ; $B11B: A9 00
  STA $01                               ; $B11D: 85 01
  STA $02                               ; $B11F: 85 02
  LDA #$03                              ; $B121: A9 03
  JSR $E862                             ; $B123: 20 62 E8
  CLC                                   ; $B126: 18
  ADC #$05                              ; $B127: 69 05
  STA $03                               ; $B129: 85 03
  JSR $EBE9                             ; $B12B: 20 E9 EB
  LDA $06                               ; $B12E: A5 06
  STA $01                               ; $B130: 85 01
  LDA $07                               ; $B132: A5 07
  STA $02                               ; $B134: 85 02
  LDA #$0A                              ; $B136: A9 0A
  STA $03                               ; $B138: 85 03
  LDA #$00                              ; $B13A: A9 00
  STA $04                               ; $B13C: 85 04
  JSR $EA7C                             ; $B13E: 20 7C EA
  LDA $01                               ; $B141: A5 01
  STA $02                               ; $B143: 85 02
  LDY $0509                             ; $B145: AC 09 05
  LDA $0664,Y                           ; $B148: B9 64 06
  JSR $F2D7                             ; $B14B: 20 D7 F2
  JSR $B5D8                             ; $B14E: 20 D8 B5
  INC $0501                             ; $B151: EE 01 05
  RTS                                   ; $B154: 60
Loc_B155:  ; (dispatch callback target)
  JSR $B7BE                             ; $B155: 20 BE B7
  BCS $B163                             ; $B158: B0 09
  INC $0501                             ; $B15A: EE 01 05
  LDA #$FF                              ; $B15D: A9 FF
  STA $0544                             ; $B15F: 8D 44 05
  RTS                                   ; $B162: 60
Loc_B163:
  LDA #$02                              ; $B163: A9 02
  STA $00                               ; $B165: 85 00
  LDA $0504                             ; $B167: AD 04 05
  BPL $B16E                             ; $B16A: 10 02
  INC $00                               ; $B16C: E6 00
Loc_B16E:
  LDY $0509                             ; $B16E: AC 09 05
  LDA $00                               ; $B171: A5 00
  STA $0650,Y                           ; $B173: 99 50 06
  INC $0501                             ; $B176: EE 01 05
  RTS                                   ; $B179: 60
Loc_B17A:  ; (dispatch callback target)
  JSR $B7BE                             ; $B17A: 20 BE B7
  BCS $B188                             ; $B17D: B0 09
  INC $0501                             ; $B17F: EE 01 05
  LDA #$FF                              ; $B182: A9 FF
  STA $0544                             ; $B184: 8D 44 05
  RTS                                   ; $B187: 60
Loc_B188:
  LDY $050A                             ; $B188: AC 0A 05
  LDA $0664,Y                           ; $B18B: B9 64 06
  JSR $F2D7                             ; $B18E: 20 D7 F2
  LDY #$01                              ; $B191: A0 01
  LDA ($00),Y                           ; $B193: B1 00
  STA $00                               ; $B195: 85 00
  LDA #$00                              ; $B197: A9 00
  STA $01                               ; $B199: 85 01
  STA $02                               ; $B19B: 85 02
  LDA #$07                              ; $B19D: A9 07
  JSR $E862                             ; $B19F: 20 62 E8
  CLC                                   ; $B1A2: 18
  ADC #$0E                              ; $B1A3: 69 0E
  STA $03                               ; $B1A5: 85 03
  JSR $EBE9                             ; $B1A7: 20 E9 EB
  LDA $06                               ; $B1AA: A5 06
  STA $01                               ; $B1AC: 85 01
  LDA $07                               ; $B1AE: A5 07
  STA $02                               ; $B1B0: 85 02
  LDA #$0A                              ; $B1B2: A9 0A
  STA $03                               ; $B1B4: 85 03
  LDA #$00                              ; $B1B6: A9 00
  STA $04                               ; $B1B8: 85 04
  JSR $EA7C                             ; $B1BA: 20 7C EA
  LDA $02                               ; $B1BD: A5 02
  STA $03                               ; $B1BF: 85 03
  LDA $01                               ; $B1C1: A5 01
  STA $02                               ; $B1C3: 85 02
  LDY $0509                             ; $B1C5: AC 09 05
  LDA $0664,Y                           ; $B1C8: B9 64 06
  JSR $F2D7                             ; $B1CB: 20 D7 F2
  JSR $B68B                             ; $B1CE: 20 8B B6
  INC $0501                             ; $B1D1: EE 01 05
  RTS                                   ; $B1D4: 60
Loc_B1D5:  ; (dispatch callback target)
  JSR $B7BE                             ; $B1D5: 20 BE B7
  BCS $B1E3                             ; $B1D8: B0 09
  INC $0501                             ; $B1DA: EE 01 05
  LDA #$FF                              ; $B1DD: A9 FF
  STA $0544                             ; $B1DF: 8D 44 05
  RTS                                   ; $B1E2: 60
Loc_B1E3:
  LDY $050A                             ; $B1E3: AC 0A 05
  LDA $0664,Y                           ; $B1E6: B9 64 06
  JSR $F2D7                             ; $B1E9: 20 D7 F2
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
  JSR $E862                             ; $B203: 20 62 E8
  CLC                                   ; $B206: 18
  ADC #$14                              ; $B207: 69 14
  STA $03                               ; $B209: 85 03
  JSR $EBE9                             ; $B20B: 20 E9 EB
  LDA $06                               ; $B20E: A5 06
  STA $01                               ; $B210: 85 01
  LDA $07                               ; $B212: A5 07
  STA $02                               ; $B214: 85 02
  LDA #$0A                              ; $B216: A9 0A
  STA $03                               ; $B218: 85 03
  LDA #$00                              ; $B21A: A9 00
  STA $04                               ; $B21C: 85 04
  JSR $EA7C                             ; $B21E: 20 7C EA
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
  JSR $F2D7                             ; $B239: 20 D7 F2
  JSR $B68B                             ; $B23C: 20 8B B6
  INC $0501                             ; $B23F: EE 01 05
  RTS                                   ; $B242: 60
Loc_B243:  ; (dispatch callback target)
  JSR $B7BE                             ; $B243: 20 BE B7
  BCS $B251                             ; $B246: B0 09
  INC $0501                             ; $B248: EE 01 05
  LDA #$FF                              ; $B24B: A9 FF
  STA $0544                             ; $B24D: 8D 44 05
  RTS                                   ; $B250: 60
Loc_B251:
  LDA #$05                              ; $B251: A9 05
  JSR $E862                             ; $B253: 20 62 E8
  CLC                                   ; $B256: 18
  ADC #$0A                              ; $B257: 69 0A
  STA $03                               ; $B259: 85 03
  LDY #$00                              ; $B25B: A0 00
  LDA $0504                             ; $B25D: AD 04 05
  BMI $B264                             ; $B260: 30 02
  LDY #$02                              ; $B262: A0 02
Loc_B264:
  LDA $0522,Y                           ; $B264: B9 22 05
  STA $00                               ; $B267: 85 00
  LDA $0523,Y                           ; $B269: B9 23 05
  STA $01                               ; $B26C: 85 01
  LDA #$00                              ; $B26E: A9 00
  STA $02                               ; $B270: 85 02
  JSR $EBE9                             ; $B272: 20 E9 EB
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
  JSR $EAA5                             ; $B289: 20 A5 EA
  LDA $00                               ; $B28C: A5 00
  STA $10                               ; $B28E: 85 10
  LDA $01                               ; $B290: A5 01
  STA $11                               ; $B292: 85 11
  LDY $050A                             ; $B294: AC 0A 05
  LDA $0664,Y                           ; $B297: B9 64 06
  JSR $F2D7                             ; $B29A: 20 D7 F2
  LDY #$02                              ; $B29D: A0 02
  LDA ($00),Y                           ; $B29F: B1 00
  STA $01                               ; $B2A1: 85 01
  LDA #$00                              ; $B2A3: A9 00
  STA $02                               ; $B2A5: 85 02
  STA $04                               ; $B2A7: 85 04
  LDA #$05                              ; $B2A9: A9 05
  STA $03                               ; $B2AB: 85 03
  JSR $EA7C                             ; $B2AD: 20 7C EA
  LDA $01                               ; $B2B0: A5 01
  CLC                                   ; $B2B2: 18
  ADC $10                               ; $B2B3: 65 10
  STA $10                               ; $B2B5: 85 10
  LDA $11                               ; $B2B7: A5 11
  ADC #$00                              ; $B2B9: 69 00
  STA $11                               ; $B2BB: 85 11
  LDY #$00                              ; $B2BD: A0 00
  LDA $0504                             ; $B2BF: AD 04 05
  BMI $B2C6                             ; $B2C2: 30 02
  LDY #$02                              ; $B2C4: A0 02
Loc_B2C6:
  JSR $B6F0                             ; $B2C6: 20 F0 B6
  INC $0501                             ; $B2C9: EE 01 05
  RTS                                   ; $B2CC: 60
Loc_B2CD:  ; (dispatch callback target)
  JSR $B7BE                             ; $B2CD: 20 BE B7
  BCS $B2DB                             ; $B2D0: B0 09
  INC $0501                             ; $B2D2: EE 01 05
  LDA #$FF                              ; $B2D5: A9 FF
  STA $0544                             ; $B2D7: 8D 44 05
  RTS                                   ; $B2DA: 60
Loc_B2DB:
  JSR $B070                             ; $B2DB: 20 70 B0
  JSR $B67B                             ; $B2DE: 20 7B B6
  DEC $10                               ; $B2E1: C6 10
  JSR $B304                             ; $B2E3: 20 04 B3
  JSR $B67B                             ; $B2E6: 20 7B B6
  INC $10                               ; $B2E9: E6 10
  JSR $B304                             ; $B2EB: 20 04 B3
  JSR $B67B                             ; $B2EE: 20 7B B6
  DEC $11                               ; $B2F1: C6 11
  JSR $B304                             ; $B2F3: 20 04 B3
  JSR $B67B                             ; $B2F6: 20 7B B6
  INC $11                               ; $B2F9: E6 11
  JSR $B304                             ; $B2FB: 20 04 B3
  LDA #$07                              ; $B2FE: A9 07
  STA $0501                             ; $B300: 8D 01 05
  RTS                                   ; $B303: 60
Loc_B304:
  JSR $B643                             ; $B304: 20 43 B6
  BEQ $B31B                             ; $B307: F0 12
  CMP #$FE                              ; $B309: C9 FE
  BEQ $B31B                             ; $B30B: F0 0E
  LDA $0509                             ; $B30D: AD 09 05
  PHA                                   ; $B310: 48
  STY $0509                             ; $B311: 8C 09 05
  JSR $B070                             ; $B314: 20 70 B0
  PLA                                   ; $B317: 68
  STA $0509                             ; $B318: 8D 09 05
Loc_B31B:
  RTS                                   ; $B31B: 60
Loc_B31C:  ; (dispatch callback target)
  JSR $B72B                             ; $B31C: 20 2B B7
  BCS $B32A                             ; $B31F: B0 09
  INC $0501                             ; $B321: EE 01 05
  LDA #$FF                              ; $B324: A9 FF
  STA $0544                             ; $B326: 8D 44 05
  RTS                                   ; $B329: 60
Loc_B32A:
  LDY $0509                             ; $B32A: AC 09 05
  JSR $C886                             ; $B32D: 20 86 C8
  LDY $0509                             ; $B330: AC 09 05
  LDA $0628,Y                           ; $B333: B9 28 06
  EOR #$80                              ; $B336: 49 80
  STA $0628,Y                           ; $B338: 99 28 06
  LDA $0664,Y                           ; $B33B: B9 64 06
  STA $042C                             ; $B33E: 8D 2C 04
  LDA #$FF                              ; $B341: A9 FF
  CPY $04D8                             ; $B343: CC D8 04
  BNE $B34B                             ; $B346: D0 03
  STA $04D8                             ; $B348: 8D D8 04
Loc_B34B:
  CPY $04DC                             ; $B34B: CC DC 04
  BNE $B353                             ; $B34E: D0 03
  STA $04DC                             ; $B350: 8D DC 04
Loc_B353:
  LDA $6FA1,Y                           ; $B353: B9 A1 6F
  CMP #$FF                              ; $B356: C9 FF
  BNE $B362                             ; $B358: D0 08
  LDA #$04                              ; $B35A: A9 04
  STA $6FA1,Y                           ; $B35C: 99 A1 6F
  JMP $B367                             ; $B35F: 4C 67 B3
Loc_B362:
  LDA #$FF                              ; $B362: A9 FF
  STA $6FA1,Y                           ; $B364: 99 A1 6F
Loc_B367:
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
  BPL $B383                             ; $B37F: 10 02
  LDX $11                               ; $B381: A6 11
Loc_B383:
  TXA                                   ; $B383: 8A
  JSR $F368                             ; $B384: 20 68 F3
  LDY #$00                              ; $B387: A0 00
  LDA ($00),Y                           ; $B389: B1 00
  STA $30                               ; $B38B: 85 30
  LDX $11                               ; $B38D: A6 11
  LDY $0509                             ; $B38F: AC 09 05
  LDA $0628,Y                           ; $B392: B9 28 06
  BPL $B399                             ; $B395: 10 02
  LDX $10                               ; $B397: A6 10
Loc_B399:
  TXA                                   ; $B399: 8A
  JSR $F368                             ; $B39A: 20 68 F3
  LDY #$00                              ; $B39D: A0 00
  LDA ($00),Y                           ; $B39F: B1 00
  STA $32                               ; $B3A1: 85 32
  LDY $0509                             ; $B3A3: AC 09 05
  LDA $0664,Y                           ; $B3A6: B9 64 06
  STA $31                               ; $B3A9: 85 31
  LDY #$2A                              ; $B3AB: A0 2A
  JSR $EE07                             ; $B3AD: 20 07 EE
; --- Data Region ---
  .byte $06,$A0,$EE,$01,$05,$60           ; $B3B0: 06 A0 EE 01 05 60
Loc_B3B6:  ; (dispatch callback target)
; --- Code Region ---
  JSR $B7BE                             ; $B3B6: 20 BE B7
  BCS $B3C4                             ; $B3B9: B0 09
  INC $0501                             ; $B3BB: EE 01 05
  LDA #$FF                              ; $B3BE: A9 FF
  STA $0544                             ; $B3C0: 8D 44 05
  RTS                                   ; $B3C3: 60
Loc_B3C4:
  JSR $B0EB                             ; $B3C4: 20 EB B0
  JSR $B188                             ; $B3C7: 20 88 B1
  LDA #$07                              ; $B3CA: A9 07
  STA $0501                             ; $B3CC: 8D 01 05
  RTS                                   ; $B3CF: 60
Loc_B3D0:  ; (dispatch callback target)
  JSR $B7BE                             ; $B3D0: 20 BE B7
  BCS $B3DE                             ; $B3D3: B0 09
  INC $0501                             ; $B3D5: EE 01 05
  LDA #$FF                              ; $B3D8: A9 FF
  STA $0544                             ; $B3DA: 8D 44 05
  RTS                                   ; $B3DD: 60
Loc_B3DE:
  JSR $B8A1                             ; $B3DE: 20 A1 B8
  LDY #$00                              ; $B3E1: A0 00
Loc_B3E3:
  LDA $6FC9,Y                           ; $B3E3: B9 C9 6F
  CMP #$FF                              ; $B3E6: C9 FF
  BEQ $B3F3                             ; $B3E8: F0 09
  STA $12                               ; $B3EA: 85 12
  TYA                                   ; $B3EC: 98
  PHA                                   ; $B3ED: 48
  JSR $B3FE                             ; $B3EE: 20 FE B3
  PLA                                   ; $B3F1: 68
  TAY                                   ; $B3F2: A8
Loc_B3F3:
  INY                                   ; $B3F3: C8
  CPY #$14                              ; $B3F4: C0 14
  BCC $B3E3                             ; $B3F6: 90 EB
  LDA #$07                              ; $B3F8: A9 07
  STA $0501                             ; $B3FA: 8D 01 05
  RTS                                   ; $B3FD: 60
Loc_B3FE:
  LDY $12                               ; $B3FE: A4 12
  LDA $0600,Y                           ; $B400: B9 00 06
  STA $10                               ; $B403: 85 10
  LDA $0614,Y                           ; $B405: B9 14 06
  STA $11                               ; $B408: 85 11
  JSR $DB46                             ; $B40A: 20 46 DB
  CMP #$03                              ; $B40D: C9 03
  BNE $B429                             ; $B40F: D0 18
  LDA #$02                              ; $B411: A9 02
  JSR $E862                             ; $B413: 20 62 E8
  CLC                                   ; $B416: 18
  ADC #$03                              ; $B417: 69 03
  STA $00                               ; $B419: 85 00
  LDA $0504                             ; $B41B: AD 04 05
  BPL $B422                             ; $B41E: 10 02
  INC $00                               ; $B420: E6 00
Loc_B422:
  LDY $12                               ; $B422: A4 12
  LDA $00                               ; $B424: A5 00
  STA $0650,Y                           ; $B426: 99 50 06
Loc_B429:
  RTS                                   ; $B429: 60
Loc_B42A:  ; (dispatch callback target)
  LDX #$00                              ; $B42A: A2 00
  LDA $0504                             ; $B42C: AD 04 05
  BPL $B433                             ; $B42F: 10 02
  LDX #$04                              ; $B431: A2 04
Loc_B433:
  LDY $050A                             ; $B433: AC 0A 05
  LDA $0600,Y                           ; $B436: B9 00 06
  STA $04D9,X                           ; $B439: 9D D9 04
  LDA $0614,Y                           ; $B43C: B9 14 06
  STA $04DA,X                           ; $B43F: 9D DA 04
  LDA #$05                              ; $B442: A9 05
  STA $04DB,X                           ; $B444: 9D DB 04
  TYA                                   ; $B447: 98
  STA $04D8,X                           ; $B448: 9D D8 04
  TAY                                   ; $B44B: A8
  LDA $0664,Y                           ; $B44C: B9 64 06
  JSR $F2D7                             ; $B44F: 20 D7 F2
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
Loc_B466:  ; (dispatch callback target)
  JSR $B7BE                             ; $B466: 20 BE B7
  BCS $B474                             ; $B469: B0 09
  INC $0501                             ; $B46B: EE 01 05
  LDA #$FF                              ; $B46E: A9 FF
  STA $0544                             ; $B470: 8D 44 05
  RTS                                   ; $B473: 60
Loc_B474:
  JSR $B8A1                             ; $B474: 20 A1 B8
  LDY #$00                              ; $B477: A0 00
Loc_B479:
  LDA $6FC9,Y                           ; $B479: B9 C9 6F
  CMP #$FF                              ; $B47C: C9 FF
  BEQ $B489                             ; $B47E: F0 09
  STA $12                               ; $B480: 85 12
  TYA                                   ; $B482: 98
  PHA                                   ; $B483: 48
  JSR $B494                             ; $B484: 20 94 B4
  PLA                                   ; $B487: 68
  TAY                                   ; $B488: A8
Loc_B489:
  INY                                   ; $B489: C8
  CPY #$14                              ; $B48A: C0 14
  BCC $B479                             ; $B48C: 90 EB
  LDA #$07                              ; $B48E: A9 07
  STA $0501                             ; $B490: 8D 01 05
  RTS                                   ; $B493: 60
Loc_B494:
  LDY $12                               ; $B494: A4 12
  LDA $0600,Y                           ; $B496: B9 00 06
  STA $10                               ; $B499: 85 10
  LDA $0614,Y                           ; $B49B: B9 14 06
  STA $11                               ; $B49E: 85 11
  JSR $DB46                             ; $B4A0: 20 46 DB
  CMP #$03                              ; $B4A3: C9 03
  BNE $B4B7                             ; $B4A5: D0 10
  LDY $12                               ; $B4A7: A4 12
  LDA $0509                             ; $B4A9: AD 09 05
  PHA                                   ; $B4AC: 48
  STY $0509                             ; $B4AD: 8C 09 05
  JSR $B1E3                             ; $B4B0: 20 E3 B1
  PLA                                   ; $B4B3: 68
  STA $0509                             ; $B4B4: 8D 09 05
Loc_B4B7:
  RTS                                   ; $B4B7: 60
Loc_B4B8:  ; (dispatch callback target)
  JSR $B7BE                             ; $B4B8: 20 BE B7
  BCS $B4C6                             ; $B4BB: B0 09
  INC $0501                             ; $B4BD: EE 01 05
  LDA #$FF                              ; $B4C0: A9 FF
  STA $0544                             ; $B4C2: 8D 44 05
  RTS                                   ; $B4C5: 60
Loc_B4C6:
  LDY $050A                             ; $B4C6: AC 0A 05
  LDA $0664,Y                           ; $B4C9: B9 64 06
  JSR $F2D7                             ; $B4CC: 20 D7 F2
  LDA #$00                              ; $B4CF: A9 00
  STA $02                               ; $B4D1: 85 02
  STA $03                               ; $B4D3: 85 03
Loc_B4D5:
  JSR $E87A                             ; $B4D5: 20 7A E8
  CMP #$C8                              ; $B4D8: C9 C8
  BCS $B4D5                             ; $B4DA: B0 F9
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
  JSR $F2D7                             ; $B502: 20 D7 F2
  JSR $B68B                             ; $B505: 20 8B B6
  INC $0501                             ; $B508: EE 01 05
  RTS                                   ; $B50B: 60
Loc_B50C:  ; (dispatch callback target)
  JSR $B7BE                             ; $B50C: 20 BE B7
  BCS $B51A                             ; $B50F: B0 09
  INC $0501                             ; $B511: EE 01 05
  LDA #$FF                              ; $B514: A9 FF
  STA $0544                             ; $B516: 8D 44 05
  RTS                                   ; $B519: 60
Loc_B51A:
  JSR $B8A1                             ; $B51A: 20 A1 B8
  LDY #$00                              ; $B51D: A0 00
Loc_B51F:
  LDA $6FC9,Y                           ; $B51F: B9 C9 6F
  CMP #$FF                              ; $B522: C9 FF
  BEQ $B52F                             ; $B524: F0 09
  STA $12                               ; $B526: 85 12
  TYA                                   ; $B528: 98
  PHA                                   ; $B529: 48
  JSR $B538                             ; $B52A: 20 38 B5
  PLA                                   ; $B52D: 68
  TAY                                   ; $B52E: A8
Loc_B52F:
  INY                                   ; $B52F: C8
  CPY #$14                              ; $B530: C0 14
  BCC $B51F                             ; $B532: 90 EB
  INC $0501                             ; $B534: EE 01 05
  RTS                                   ; $B537: 60
Loc_B538:
  LDY $12                               ; $B538: A4 12
  LDA $0600,Y                           ; $B53A: B9 00 06
  STA $10                               ; $B53D: 85 10
  LDA $0614,Y                           ; $B53F: B9 14 06
  STA $11                               ; $B542: 85 11
  JSR $DB46                             ; $B544: 20 46 DB
  CMP #$05                              ; $B547: C9 05
  BEQ $B55B                             ; $B549: F0 10
  LDY $12                               ; $B54B: A4 12
  LDA $0509                             ; $B54D: AD 09 05
  PHA                                   ; $B550: 48
  STY $0509                             ; $B551: 8C 09 05
  JSR $B55C                             ; $B554: 20 5C B5
  PLA                                   ; $B557: 68
  STA $0509                             ; $B558: 8D 09 05
Loc_B55B:
  RTS                                   ; $B55B: 60
Loc_B55C:
  LDY $050A                             ; $B55C: AC 0A 05
  LDA $0664,Y                           ; $B55F: B9 64 06
  JSR $F2D7                             ; $B562: 20 D7 F2
  LDA #$06                              ; $B565: A9 06
  JSR $E862                             ; $B567: 20 62 E8
  CLC                                   ; $B56A: 18
  ADC #$1E                              ; $B56B: 69 1E
  STA $03                               ; $B56D: 85 03
  LDY #$02                              ; $B56F: A0 02
  LDA ($00),Y                           ; $B571: B1 00
  STA $00                               ; $B573: 85 00
  LDA #$00                              ; $B575: A9 00
  STA $01                               ; $B577: 85 01
  STA $02                               ; $B579: 85 02
  JSR $EBE9                             ; $B57B: 20 E9 EB
  LDA $06                               ; $B57E: A5 06
  STA $01                               ; $B580: 85 01
  LDA $07                               ; $B582: A5 07
  STA $02                               ; $B584: 85 02
  LDA #$0A                              ; $B586: A9 0A
  STA $03                               ; $B588: 85 03
  LDA #$00                              ; $B58A: A9 00
  STA $04                               ; $B58C: 85 04
  JSR $EA7C                             ; $B58E: 20 7C EA
  LDA $02                               ; $B591: A5 02
  STA $03                               ; $B593: 85 03
  LDA $01                               ; $B595: A5 01
  STA $02                               ; $B597: 85 02
  LDY $0509                             ; $B599: AC 09 05
  LDA $0664,Y                           ; $B59C: B9 64 06
  JSR $F2D7                             ; $B59F: 20 D7 F2
  JSR $B68B                             ; $B5A2: 20 8B B6
  RTS                                   ; $B5A5: 60
Loc_B5A6:  ; (dispatch callback target)
  JSR $B7BE                             ; $B5A6: 20 BE B7
  BCS $B5B4                             ; $B5A9: B0 09
  INC $0501                             ; $B5AB: EE 01 05
  LDA #$FF                              ; $B5AE: A9 FF
  STA $0544                             ; $B5B0: 8D 44 05
  RTS                                   ; $B5B3: 60
Loc_B5B4:
  JSR $E850                             ; $B5B4: 20 50 E8
  CLC                                   ; $B5B7: 18
  ADC #$05                              ; $B5B8: 69 05
  ASL                                   ; $B5BA: 0A
  ASL                                   ; $B5BB: 0A
  ASL                                   ; $B5BC: 0A
  ASL                                   ; $B5BD: 0A
  STA $00                               ; $B5BE: 85 00
  LDA $0504                             ; $B5C0: AD 04 05
  BPL $B5CC                             ; $B5C3: 10 07
  LDA $00                               ; $B5C5: A5 00
  CLC                                   ; $B5C7: 18
  ADC #$10                              ; $B5C8: 69 10
  STA $00                               ; $B5CA: 85 00
Loc_B5CC:
  LDY $0509                             ; $B5CC: AC 09 05
  LDA $00                               ; $B5CF: A5 00
  STA $0650,Y                           ; $B5D1: 99 50 06
  INC $0501                             ; $B5D4: EE 01 05
  RTS                                   ; $B5D7: 60
Loc_B5D8:
  LDY #$00                              ; $B5D8: A0 00
  LDA ($00),Y                           ; $B5DA: B1 00
  STA $04                               ; $B5DC: 85 04
  SEC                                   ; $B5DE: 38
  SBC $02                               ; $B5DF: E5 02
  STA $06                               ; $B5E1: 85 06
  BCS $B5ED                             ; $B5E3: B0 08
  LDA $04                               ; $B5E5: A5 04
  STA $02                               ; $B5E7: 85 02
  LDA #$00                              ; $B5E9: A9 00
  STA $06                               ; $B5EB: 85 06
Loc_B5ED:
  LDY #$00                              ; $B5ED: A0 00
  LDA $06                               ; $B5EF: A5 06
  STA ($00),Y                           ; $B5F1: 91 00
  LDA $02                               ; $B5F3: A5 02
  STA $042F                             ; $B5F5: 8D 2F 04
  LDA #$00                              ; $B5F8: A9 00
  STA $0430                             ; $B5FA: 8D 30 04
  STA $0431                             ; $B5FD: 8D 31 04
  LDA #$FF                              ; $B600: A9 FF
  STA $0432                             ; $B602: 8D 32 04
  LDA $06                               ; $B605: A5 06
  BNE $B642                             ; $B607: D0 39
  LDY #$0B                              ; $B609: A0 0B
  LDA ($00),Y                           ; $B60B: B1 00
  ORA #$03                              ; $B60D: 09 03
  STA ($00),Y                           ; $B60F: 91 00
  LDA #$00                              ; $B611: A9 00
  STA $12                               ; $B613: 85 12
  JSR $D6CC                             ; $B615: 20 CC D6
  LDY $050A                             ; $B618: AC 0A 05
  LDA $0664,Y                           ; $B61B: B9 64 06
  STA $0A                               ; $B61E: 85 0A
  LDY $0509                             ; $B620: AC 09 05
  LDA $0664,Y                           ; $B623: B9 64 06
  STA $0B                               ; $B626: 85 0B
  LDY #$2E                              ; $B628: A0 2E
  JSR $EE07                             ; $B62A: 20 07 EE
; --- Data Region ---
  .byte $09,$A0,$AC,$09,$05,$B9,$64,$06,$8D,$32,$04,$8C,$00,$00,$A0,$28; $B62D: 09 A0 AC 09 05 B9 64 06 8D 32 04 8C 00 00 A0 28
  .byte $20,$07,$EE,$2A,$A0,$60,$A5,$11,$C9,$0F,$D0,$11,$A5,$01,$C9,$0E; $B63D: 20 07 EE 2A A0 60 A5 11 C9 0F D0 11 A5 01 C9 0E
  .byte $F0,$07,$A9,$0E,$85,$11,$4C,$5A,$B6; $B64D: F0 07 A9 0E 85 11 4C 5A B6
Loc_B656:
; --- Code Region ---
  LDA #$10                              ; $B656: A9 10
  STA $11                               ; $B658: 85 11
Loc_B65A:
  LDA $10                               ; $B65A: A5 10
  STA $00                               ; $B65C: 85 00
  LDA $11                               ; $B65E: A5 11
  STA $01                               ; $B660: 85 01
  LDA $00                               ; $B662: A5 00
  CMP #$20                              ; $B664: C9 20
  BCS $B678                             ; $B666: B0 10
  LDA $01                               ; $B668: A5 01
  CMP #$14                              ; $B66A: C9 14
  BCS $B678                             ; $B66C: B0 0A
  JSR $D6B6                             ; $B66E: 20 B6 D6
  TYA                                   ; $B671: 98
  BMI $B678                             ; $B672: 30 04
  JSR $DC4B                             ; $B674: 20 4B DC
  RTS                                   ; $B677: 60
Loc_B678:
  LDA #$FE                              ; $B678: A9 FE
  RTS                                   ; $B67A: 60
Loc_B67B:
  LDY $0509                             ; $B67B: AC 09 05
  LDA $0600,Y                           ; $B67E: B9 00 06
  STA $10                               ; $B681: 85 10
  LDA $0614,Y                           ; $B683: B9 14 06
  STA $11                               ; $B686: 85 11
  STA $01                               ; $B688: 85 01
  RTS                                   ; $B68A: 60
Loc_B68B:
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
  BCS $B6B5                             ; $B6A5: B0 0E
  LDA $04                               ; $B6A7: A5 04
  STA $02                               ; $B6A9: 85 02
  LDA $05                               ; $B6AB: A5 05
  STA $03                               ; $B6AD: 85 03
  LDA #$00                              ; $B6AF: A9 00
  STA $06                               ; $B6B1: 85 06
  STA $07                               ; $B6B3: 85 07
Loc_B6B5:
  LDY #$08                              ; $B6B5: A0 08
  LDA $06                               ; $B6B7: A5 06
  STA ($00),Y                           ; $B6B9: 91 00
  INY                                   ; $B6BB: C8
  LDA $07                               ; $B6BC: A5 07
  STA ($00),Y                           ; $B6BE: 91 00
  LDA $02                               ; $B6C0: A5 02
  CLC                                   ; $B6C2: 18
  ADC $042C                             ; $B6C3: 6D 2C 04
  STA $042C                             ; $B6C6: 8D 2C 04
  LDA $03                               ; $B6C9: A5 03
  ADC $042D                             ; $B6CB: 6D 2D 04
  STA $042D                             ; $B6CE: 8D 2D 04
  LDA #$00                              ; $B6D1: A9 00
  STA $042E                             ; $B6D3: 8D 2E 04
  LDY $050A                             ; $B6D6: AC 0A 05
  LDA $0664,Y                           ; $B6D9: B9 64 06
  STA $0A                               ; $B6DC: 85 0A
  LDA $042C                             ; $B6DE: AD 2C 04
  STA $0B                               ; $B6E1: 85 0B
  LDA $042D                             ; $B6E3: AD 2D 04
  STA $0C                               ; $B6E6: 85 0C
  LDY #$2E                              ; $B6E8: A0 2E
  JSR $EE07                             ; $B6EA: 20 07 EE
; --- Data Region ---
  .byte $06,$A0,$60,$B9,$22,$05,$38,$E5,$10,$85,$12,$B9,$23,$05,$E5,$11; $B6ED: 06 A0 60 B9 22 05 38 E5 10 85 12 B9 23 05 E5 11
  .byte $85,$13,$B0,$10,$B9,$22,$05,$85,$10,$B9,$23,$05,$85,$11,$A9,$00; $B6FD: 85 13 B0 10 B9 22 05 85 10 B9 23 05 85 11 A9 00
  .byte $85,$12,$85,$13                   ; $B70D: 85 12 85 13
Loc_B711:
; --- Code Region ---
  LDA $12                               ; $B711: A5 12
  STA $0522,Y                           ; $B713: 99 22 05
  LDA $13                               ; $B716: A5 13
  STA $0523,Y                           ; $B718: 99 23 05
  LDA $10                               ; $B71B: A5 10
  STA $042C                             ; $B71D: 8D 2C 04
  LDA $11                               ; $B720: A5 11
  STA $042D                             ; $B722: 8D 2D 04
  LDA #$00                              ; $B725: A9 00
  STA $042E                             ; $B727: 8D 2E 04
  RTS                                   ; $B72A: 60
Loc_B72B:
  JSR $B860                             ; $B72B: 20 60 B8
  CMP #$06                              ; $B72E: C9 06
  BCC $B735                             ; $B730: 90 03
  JMP $B7B6                             ; $B732: 4C B6 B7
Loc_B735:
  LDY $0509                             ; $B735: AC 09 05
  LDA $0664,Y                           ; $B738: B9 64 06
  JSR $F2D7                             ; $B73B: 20 D7 F2
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
  BCC $B75E                             ; $B750: 90 0C
  INX                                   ; $B752: E8
  CMP #$33                              ; $B753: C9 33
  BCC $B75E                             ; $B755: 90 07
  INX                                   ; $B757: E8
  CMP #$47                              ; $B758: C9 47
  BCC $B75E                             ; $B75A: 90 02
  CLC                                   ; $B75C: 18
  RTS                                   ; $B75D: 60
Loc_B75E:
  LDA $B7BA,X                           ; $B75E: BD BA B7
  STA $10                               ; $B761: 85 10
  LDY $050A                             ; $B763: AC 0A 05
  LDA $0664,Y                           ; $B766: B9 64 06
  JSR $F2D7                             ; $B769: 20 D7 F2
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
  BPL $B783                             ; $B77F: 10 02
  LDA #$00                              ; $B781: A9 00
Loc_B783:
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
  JSR $EA7C                             ; $B79F: 20 7C EA
  LDA $01                               ; $B7A2: A5 01
  CLC                                   ; $B7A4: 18
  ADC $10                               ; $B7A5: 65 10
  ADC $11                               ; $B7A7: 65 11
  STA $00                               ; $B7A9: 85 00
Loc_B7AB:
  JSR $E87A                             ; $B7AB: 20 7A E8
  CMP #$64                              ; $B7AE: C9 64
  BCS $B7AB                             ; $B7B0: B0 F9
  CMP $00                               ; $B7B2: C5 00
  BCC $B7B8                             ; $B7B4: 90 02
Loc_B7B6:
  CLC                                   ; $B7B6: 18
  RTS                                   ; $B7B7: 60
Loc_B7B8:
  SEC                                   ; $B7B8: 38
  RTS                                   ; $B7B9: 60
; --- Data Region ---
  .byte $3C,$1E,$0A,$05                   ; $B7BA: 3C 1E 0A 05
Loc_B7BE:
; --- Code Region ---
  LDY $0509                             ; $B7BE: AC 09 05
  LDA $0664,Y                           ; $B7C1: B9 64 06
  JSR $F2D7                             ; $B7C4: 20 D7 F2
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
  JSR $F2D7                             ; $B7DD: 20 D7 F2
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
  BCS $B7F9                             ; $B7F5: B0 02
  LDA #$00                              ; $B7F7: A9 00
Loc_B7F9:
  STA $10                               ; $B7F9: 85 10
  LDA $13                               ; $B7FB: A5 13
  SEC                                   ; $B7FD: 38
  SBC $11                               ; $B7FE: E5 11
  BCS $B804                             ; $B800: B0 02
  LDA #$00                              ; $B802: A9 00
Loc_B804:
  ASL                                   ; $B804: 0A
  STA $11                               ; $B805: 85 11
  JSR $B860                             ; $B807: 20 60 B8
  TAY                                   ; $B80A: A8
  CPY #$06                              ; $B80B: C0 06
  BCS $B856                             ; $B80D: B0 47
  LDA $B85A,Y                           ; $B80F: B9 5A B8
  STA $12                               ; $B812: 85 12
  LDX #$0A                              ; $B814: A2 0A
  LDA $050F                             ; $B816: AD 0F 05
  CMP #$03                              ; $B819: C9 03
  BNE $B82C                             ; $B81B: D0 0F
  LDA $6F02                             ; $B81D: AD 02 6F
  CMP #$01                              ; $B820: C9 01
  BEQ $B82C                             ; $B822: F0 08
  LDX #$14                              ; $B824: A2 14
  CMP #$02                              ; $B826: C9 02
  BEQ $B82C                             ; $B828: F0 02
  LDX #$05                              ; $B82A: A2 05
Loc_B82C:
  STX $14                               ; $B82C: 86 14
  LDA $12                               ; $B82E: A5 12
  CLC                                   ; $B830: 18
  ADC $10                               ; $B831: 65 10
  CLC                                   ; $B833: 18
  ADC $11                               ; $B834: 65 11
  CLC                                   ; $B836: 18
  ADC $14                               ; $B837: 65 14
  BPL $B83D                             ; $B839: 10 02
  LDA #$00                              ; $B83B: A9 00
Loc_B83D:
  CMP #$5F                              ; $B83D: C9 5F
  BCC $B843                             ; $B83F: 90 02
  LDA #$5F                              ; $B841: A9 5F
Loc_B843:
  CMP #$05                              ; $B843: C9 05
  BCS $B849                             ; $B845: B0 02
  LDA #$05                              ; $B847: A9 05
Loc_B849:
  STA $00                               ; $B849: 85 00
Loc_B84B:
  JSR $E87A                             ; $B84B: 20 7A E8
  CMP #$64                              ; $B84E: C9 64
  BCS $B84B                             ; $B850: B0 F9
  CMP $00                               ; $B852: C5 00
  BCC $B858                             ; $B854: 90 02
Loc_B856:
  CLC                                   ; $B856: 18
  RTS                                   ; $B857: 60
Loc_B858:
  SEC                                   ; $B858: 38
  RTS                                   ; $B859: 60
; --- Data Region ---
  .byte $0F,$0A,$05,$00,$FB,$F6           ; $B85A: 0F 0A 05 00 FB F6
Loc_B860:
; --- Code Region ---
  LDY $0509                             ; $B860: AC 09 05
  LDA $0614,Y                           ; $B863: B9 14 06
  CMP #$10                              ; $B866: C9 10
  BCC $B86C                             ; $B868: 90 02
  SBC #$01                              ; $B86A: E9 01
Loc_B86C:
  STA $00                               ; $B86C: 85 00
  LDY $050A                             ; $B86E: AC 0A 05
  LDA $0614,Y                           ; $B871: B9 14 06
  CMP #$10                              ; $B874: C9 10
  BCC $B87A                             ; $B876: 90 02
  SBC #$01                              ; $B878: E9 01
Loc_B87A:
  SEC                                   ; $B87A: 38
  SBC $00                               ; $B87B: E5 00
  BCS $B884                             ; $B87D: B0 05
  EOR #$FF                              ; $B87F: 49 FF
  CLC                                   ; $B881: 18
  ADC #$01                              ; $B882: 69 01
Loc_B884:
  STA $00                               ; $B884: 85 00
  LDY $050A                             ; $B886: AC 0A 05
  LDA $0600,Y                           ; $B889: B9 00 06
  SEC                                   ; $B88C: 38
  LDY $0509                             ; $B88D: AC 09 05
  SBC $0600,Y                           ; $B890: F9 00 06
  BCS $B89A                             ; $B893: B0 05
  EOR #$FF                              ; $B895: 49 FF
  CLC                                   ; $B897: 18
  ADC #$01                              ; $B898: 69 01
Loc_B89A:
  CMP $00                               ; $B89A: C5 00
  BCS $B8A0                             ; $B89C: B0 02
  LDA $00                               ; $B89E: A5 00
Loc_B8A0:
  RTS                                   ; $B8A0: 60
Loc_B8A1:
  LDY #$00                              ; $B8A1: A0 00
  LDA #$FF                              ; $B8A3: A9 FF
Loc_B8A5:
  STA $6FC9,Y                           ; $B8A5: 99 C9 6F
  INY                                   ; $B8A8: C8
  CPY #$14                              ; $B8A9: C0 14
  BCC $B8A5                             ; $B8AB: 90 F8
  LDA $0509                             ; $B8AD: AD 09 05
  STA $6FC9                             ; $B8B0: 8D C9 6F
  TAY                                   ; $B8B3: A8
  JSR $B8CE                             ; $B8B4: 20 CE B8
  LDX #$01                              ; $B8B7: A2 01
Loc_B8B9:
  LDA $6FC9,X                           ; $B8B9: BD C9 6F
  CMP #$FF                              ; $B8BC: C9 FF
  BEQ $B8CD                             ; $B8BE: F0 0D
  TAY                                   ; $B8C0: A8
  TXA                                   ; $B8C1: 8A
  PHA                                   ; $B8C2: 48
  JSR $B8CE                             ; $B8C3: 20 CE B8
  PLA                                   ; $B8C6: 68
  TAX                                   ; $B8C7: AA
  INX                                   ; $B8C8: E8
  CPX #$14                              ; $B8C9: E0 14
  BCC $B8B9                             ; $B8CB: 90 EC
Loc_B8CD:
  RTS                                   ; $B8CD: 60
Loc_B8CE:
  LDA $0600,Y                           ; $B8CE: B9 00 06
  STA $12                               ; $B8D1: 85 12
  LDA $0614,Y                           ; $B8D3: B9 14 06
  CMP #$10                              ; $B8D6: C9 10
  BCC $B8DD                             ; $B8D8: 90 03
  SEC                                   ; $B8DA: 38
  SBC #$01                              ; $B8DB: E9 01
Loc_B8DD:
  STA $13                               ; $B8DD: 85 13
  INC $12                               ; $B8DF: E6 12
  JSR $B8FA                             ; $B8E1: 20 FA B8
  DEC $12                               ; $B8E4: C6 12
  DEC $12                               ; $B8E6: C6 12
  JSR $B8FA                             ; $B8E8: 20 FA B8
  INC $12                               ; $B8EB: E6 12
  INC $13                               ; $B8ED: E6 13
  JSR $B8FA                             ; $B8EF: 20 FA B8
  DEC $13                               ; $B8F2: C6 13
  DEC $13                               ; $B8F4: C6 13
  JSR $B8FA                             ; $B8F6: 20 FA B8
  RTS                                   ; $B8F9: 60
Loc_B8FA:
  LDY #$00                              ; $B8FA: A0 00
Loc_B8FC:
  LDA $0600,Y                           ; $B8FC: B9 00 06
  CMP $12                               ; $B8FF: C5 12
  BNE $B918                             ; $B901: D0 15
  LDA $0614,Y                           ; $B903: B9 14 06
  CMP #$10                              ; $B906: C9 10
  BCC $B90D                             ; $B908: 90 03
  SEC                                   ; $B90A: 38
  SBC #$01                              ; $B90B: E9 01
Loc_B90D:
  CMP $13                               ; $B90D: C5 13
  BNE $B918                             ; $B90F: D0 07
  JSR $DC4B                             ; $B911: 20 4B DC
  CMP #$FF                              ; $B914: C9 FF
  BEQ $B91E                             ; $B916: F0 06
Loc_B918:
  INY                                   ; $B918: C8
  CPY #$14                              ; $B919: C0 14
  BCC $B8FC                             ; $B91B: 90 DF
  RTS                                   ; $B91D: 60
Loc_B91E:
  STY $14                               ; $B91E: 84 14
  LDA $0600,Y                           ; $B920: B9 00 06
  STA $10                               ; $B923: 85 10
  LDA $0614,Y                           ; $B925: B9 14 06
  STA $11                               ; $B928: 85 11
  JSR $DB46                             ; $B92A: 20 46 DB
  CMP #$05                              ; $B92D: C9 05
  BEQ $B949                             ; $B92F: F0 18
  LDY #$00                              ; $B931: A0 00
Loc_B933:
  LDA $6FC9,Y                           ; $B933: B9 C9 6F
  CMP #$FF                              ; $B936: C9 FF
  BNE $B940                             ; $B938: D0 06
  LDA $14                               ; $B93A: A5 14
  STA $6FC9,Y                           ; $B93C: 99 C9 6F
  RTS                                   ; $B93F: 60
Loc_B940:
  CMP $14                               ; $B940: C5 14
  BNE $B945                             ; $B942: D0 01
  RTS                                   ; $B944: 60
Loc_B945:
  INY                                   ; $B945: C8
  JMP $B933                             ; $B946: 4C 33 B9
Loc_B949:
  RTS                                   ; $B949: 60
Loc_B94A:  ; (dispatch callback target)
  LDA #$00                              ; $B94A: A9 00
  STA $00A4                             ; $B94C: 8D A4 00
  JSR $DC33                             ; $B94F: 20 33 DC
  LDA $0501                             ; $B952: AD 01 05
  JSR $EADE                             ; $B955: 20 DE EA
; --- Data Region ---
  .byte $64,$B9,$6D,$B9,$B6,$B9,$30,$BA,$64,$BA,$83,$BA,$A9,$D6,$20,$83; $B958: 64 B9 6D B9 B6 B9 30 BA 64 BA 83 BA A9 D6 20 83
  .byte $F2,$EE,$01,$05,$60               ; $B968: F2 EE 01 05 60
Loc_B96D:  ; (dispatch callback target)
; --- Code Region ---
  JSR $DC70                             ; $B96D: 20 70 DC
  JSR $A1DE                             ; $B970: 20 DE A1
  JSR $DF27                             ; $B973: 20 27 DF
  BCC $B9B5                             ; $B976: 90 3D
  LDA $81                               ; $B978: A5 81
  AND #$02                              ; $B97A: 29 02
  BEQ $B98B                             ; $B97C: F0 0D
  LDA #$00                              ; $B97E: A9 00
  STA $0501                             ; $B980: 8D 01 05
  LDA #$00                              ; $B983: A9 00
  STA $0500                             ; $B985: 8D 00 05
  JMP $A1F7                             ; $B988: 4C F7 A1
Loc_B98B:
  LDA $81                               ; $B98B: A5 81
  AND #$01                              ; $B98D: 29 01
  BEQ $B9B5                             ; $B98F: F0 24
  INC $0501                             ; $B991: EE 01 05
  LDA #$D7                              ; $B994: A9 D7
  JSR $F283                             ; $B996: 20 83 F2
  LDA #$00                              ; $B999: A9 00
  STA $0424                             ; $B99B: 8D 24 04
  STA $0425                             ; $B99E: 8D 25 04
  JSR $BB84                             ; $B9A1: 20 84 BB
  LDA $050A                             ; $B9A4: AD 0A 05
  CMP #$FF                              ; $B9A7: C9 FF
  BNE $B9B5                             ; $B9A9: D0 0A
  LDA #$05                              ; $B9AB: A9 05
  STA $0501                             ; $B9AD: 8D 01 05
  LDA #$D9                              ; $B9B0: A9 D9
  JSR $F283                             ; $B9B2: 20 83 F2
Loc_B9B5:
  RTS                                   ; $B9B5: 60
Loc_B9B6:  ; (dispatch callback target)
  JSR $A1DE                             ; $B9B6: 20 DE A1
  LDA $050A                             ; $B9B9: AD 0A 05
  ASL                                   ; $B9BC: 0A
  TAY                                   ; $B9BD: A8
  LDA $BA9F,Y                           ; $B9BE: B9 9F BA
  STA $10                               ; $B9C1: 85 10
  LDA $BAA0,Y                           ; $B9C3: B9 A0 BA
  STA $11                               ; $B9C6: 85 11
  LDA #$00                              ; $B9C8: A9 00
  STA $12                               ; $B9CA: 85 12
  JSR $ED1E                             ; $B9CC: 20 1E ED
  LDA #$6F                              ; $B9CF: A9 6F
  STA $10                               ; $B9D1: 85 10
  LDA #$BB                              ; $B9D3: A9 BB
  STA $11                               ; $B9D5: 85 11
  LDA #$7F                              ; $B9D7: A9 7F
  STA $00                               ; $B9D9: 85 00
  LDA #$BB                              ; $B9DB: A9 BB
  STA $01                               ; $B9DD: 85 01
  LDA $12                               ; $B9DF: A5 12
  JSR $EDF5                             ; $B9E1: 20 F5 ED
  JSR $DF27                             ; $B9E4: 20 27 DF
  BCC $B9B5                             ; $B9E7: 90 CC
  LDA $81                               ; $B9E9: A5 81
  AND #$02                              ; $B9EB: 29 02
  BEQ $B9FC                             ; $B9ED: F0 0D
  LDA #$00                              ; $B9EF: A9 00
  STA $0501                             ; $B9F1: 8D 01 05
  LDA #$00                              ; $B9F4: A9 00
  STA $0500                             ; $B9F6: 8D 00 05
  JMP $A1F7                             ; $B9F9: 4C F7 A1
Loc_B9FC:
  LDA $81                               ; $B9FC: A5 81
  AND #$01                              ; $B9FE: 29 01
  BEQ $BA19                             ; $BA00: F0 17
  LDY $12                               ; $BA02: A4 12
  LDA $042C,Y                           ; $BA04: B9 2C 04
  STA $050B                             ; $BA07: 8D 0B 05
  JSR $BC11                             ; $BA0A: 20 11 BC
  BCC $BA1A                             ; $BA0D: 90 0B
  LDA #$01                              ; $BA0F: A9 01
  STA $0501                             ; $BA11: 8D 01 05
  LDA #$DA                              ; $BA14: A9 DA
  JSR $F283                             ; $BA16: 20 83 F2
Loc_BA19:
  RTS                                   ; $BA19: 60
Loc_BA1A:
  INC $0501                             ; $BA1A: EE 01 05
  LDA $0509                             ; $BA1D: AD 09 05
  BEQ $BA26                             ; $BA20: F0 04
  CMP #$0A                              ; $BA22: C9 0A
  BNE $BA2B                             ; $BA24: D0 05
Loc_BA26:
  LDA #$52                              ; $BA26: A9 52
  JMP $F283                             ; $BA28: 4C 83 F2
Loc_BA2B:
  LDA #$C8                              ; $BA2B: A9 C8
  JMP $F283                             ; $BA2D: 4C 83 F2
Loc_BA30:  ; (dispatch callback target)
  JSR $DC70                             ; $BA30: 20 70 DC
  JSR $A1DE                             ; $BA33: 20 DE A1
  JSR $DF27                             ; $BA36: 20 27 DF
  BCC $BA63                             ; $BA39: 90 28
  LDA $81                               ; $BA3B: A5 81
  AND #$02                              ; $BA3D: 29 02
  BEQ $BA4E                             ; $BA3F: F0 0D
  LDA #$00                              ; $BA41: A9 00
  STA $0501                             ; $BA43: 8D 01 05
  LDA #$00                              ; $BA46: A9 00
  STA $0500                             ; $BA48: 8D 00 05
  JMP $A1F7                             ; $BA4B: 4C F7 A1
Loc_BA4E:
  LDA $81                               ; $BA4E: A5 81
  AND #$01                              ; $BA50: 29 01
  BEQ $BA63                             ; $BA52: F0 0F
  INC $0501                             ; $BA54: EE 01 05
  LDA #$00                              ; $BA57: A9 00
  STA $12                               ; $BA59: 85 12
  JSR $D6CC                             ; $BA5B: 20 CC D6
  LDA #$D8                              ; $BA5E: A9 D8
  JSR $F293                             ; $BA60: 20 93 F2
Loc_BA63:
  RTS                                   ; $BA63: 60
Loc_BA64:  ; (dispatch callback target)
  JSR $DF27                             ; $BA64: 20 27 DF
  BCC $BA82                             ; $BA67: 90 19
  JSR $DC70                             ; $BA69: 20 70 DC
  LDA $81                               ; $BA6C: A5 81
  AND #$01                              ; $BA6E: 29 01
  BEQ $BA82                             ; $BA70: F0 10
  JSR $BC2A                             ; $BA72: 20 2A BC
  LDA #$00                              ; $BA75: A9 00
  STA $0501                             ; $BA77: 8D 01 05
  LDA #$00                              ; $BA7A: A9 00
  STA $0500                             ; $BA7C: 8D 00 05
  JMP $A1F7                             ; $BA7F: 4C F7 A1
Loc_BA82:
  RTS                                   ; $BA82: 60
Loc_BA83:  ; (dispatch callback target)
  JSR $DF27                             ; $BA83: 20 27 DF
  BCC $BA9E                             ; $BA86: 90 16
  JSR $DC70                             ; $BA88: 20 70 DC
  LDA $81                               ; $BA8B: A5 81
  AND #$01                              ; $BA8D: 29 01
  BEQ $BA9E                             ; $BA8F: F0 0D
  LDA #$00                              ; $BA91: A9 00
  STA $0501                             ; $BA93: 8D 01 05
  LDA #$00                              ; $BA96: A9 00
  STA $0500                             ; $BA98: 8D 00 05
  JMP $A1F7                             ; $BA9B: 4C F7 A1
Loc_BA9E:
  RTS                                   ; $BA9E: 60
; --- Data Region ---
  .byte $6B,$BB,$13,$BB,$65,$BB,$0D,$BB,$5D,$BB,$05,$BB,$53,$BB,$FB,$BA; $BA9F: 6B BB 13 BB 65 BB 0D BB 5D BB 05 BB 53 BB FB BA
  .byte $47,$BB,$EF,$BA,$39,$BB,$E1,$BA,$29,$BB,$D1,$BA,$17,$BB,$BF,$BA; $BAAF: 47 BB EF BA 39 BB E1 BA 29 BB D1 BA 17 BB BF BA
  .byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F; $BABF: 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
  .byte $FF,$FF,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D; $BACF: FF FF 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D
  .byte $FF,$FF,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$FF,$FF; $BADF: FF FF 00 01 02 03 04 05 06 07 08 09 0A 0B FF FF
  .byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$FF,$FF,$00,$01,$02,$03; $BAEF: 00 01 02 03 04 05 06 07 08 09 FF FF 00 01 02 03
  .byte $04,$05,$06,$07,$FF,$FF,$00,$01,$02,$03,$04,$05,$FF,$FF,$00,$01; $BAFF: 04 05 06 07 FF FF 00 01 02 03 04 05 FF FF 00 01
  .byte $02,$03,$FF,$FF,$00,$01,$FF,$FF,$00,$01,$02,$03,$04,$05,$06,$07; $BB0F: 02 03 FF FF 00 01 FF FF 00 01 02 03 04 05 06 07
  .byte $08,$09,$0A,$0B,$0C,$0D,$0E,$FF,$FF,$FF,$00,$01,$02,$03,$04,$05; $BB1F: 08 09 0A 0B 0C 0D 0E FF FF FF 00 01 02 03 04 05
  .byte $06,$07,$08,$09,$0A,$0B,$0C,$FF,$FF,$FF,$00,$01,$02,$03,$04,$05; $BB2F: 06 07 08 09 0A 0B 0C FF FF FF 00 01 02 03 04 05
  .byte $06,$07,$08,$09,$0A,$FF,$FF,$FF,$00,$01,$02,$03,$04,$05,$06,$07; $BB3F: 06 07 08 09 0A FF FF FF 00 01 02 03 04 05 06 07
  .byte $08,$FF,$FF,$FF,$00,$01,$02,$03,$04,$05,$06,$FF,$FF,$FF,$00,$01; $BB4F: 08 FF FF FF 00 01 02 03 04 05 06 FF FF FF 00 01
  .byte $02,$03,$04,$FF,$FF,$FF,$00,$01,$02,$FF,$FF,$FF,$00,$FF,$FF,$FF; $BB5F: 02 03 04 FF FF FF 00 01 02 FF FF FF 00 FF FF FF
  .byte $A6,$48,$A6,$98,$B6,$48,$B6,$98,$C6,$48,$C6,$98,$D6,$48,$D6,$98; $BB6F: A6 48 A6 98 B6 48 B6 98 C6 48 C6 98 D6 48 D6 98
  .byte $00,$07,$00,$00,$80               ; $BB7F: 00 07 00 00 80
Loc_BB84:
; --- Code Region ---
  LDA #$FF                              ; $BB84: A9 FF
  STA $050A                             ; $BB86: 8D 0A 05
  LDY #$3F                              ; $BB89: A0 3F
  LDA #$FF                              ; $BB8B: A9 FF
Loc_BB8D:
  STA $042C,Y                           ; $BB8D: 99 2C 04
  DEY                                   ; $BB90: 88
  BPL $BB8D                             ; $BB91: 10 FA
  LDY #$0F                              ; $BB93: A0 0F
  LDA #$FF                              ; $BB95: A9 FF
Loc_BB97:
  STA $0550,Y                           ; $BB97: 99 50 05
  DEY                                   ; $BB9A: 88
  BPL $BB97                             ; $BB9B: 10 FA
  LDA $0507                             ; $BB9D: AD 07 05
  LDY $0504                             ; $BBA0: AC 04 05
  BPL $BBA9                             ; $BBA3: 10 04
  LSR                                   ; $BBA5: 4A
  LSR                                   ; $BBA6: 4A
  LSR                                   ; $BBA7: 4A
  LSR                                   ; $BBA8: 4A
Loc_BBA9:
  AND #$0F                              ; $BBA9: 29 0F
  STA $02                               ; $BBAB: 85 02
  LDY #$30                              ; $BBAD: A0 30
  JSR $F25F                             ; $BBAF: 20 5F F2
  LDA $050E                             ; $BBB2: AD 0E 05
  ASL                                   ; $BBB5: 0A
  ASL                                   ; $BBB6: 0A
  ASL                                   ; $BBB7: 0A
  TAY                                   ; $BBB8: A8
  LDX #$00                              ; $BBB9: A2 00
Loc_BBBB:
  LDA $9D72,Y                           ; $BBBB: B9 72 9D
  BMI $BC08                             ; $BBBE: 30 48
  STA $03                               ; $BBC0: 85 03
  STY $04                               ; $BBC2: 84 04
  JSR $F2AF                             ; $BBC4: 20 AF F2
  LDY #$00                              ; $BBC7: A0 00
  LDA ($00),Y                           ; $BBC9: B1 00
  AND #$07                              ; $BBCB: 29 07
  CMP #$07                              ; $BBCD: C9 07
  BEQ $BBD5                             ; $BBCF: F0 04
  CMP $02                               ; $BBD1: C5 02
  BNE $BC00                             ; $BBD3: D0 2B
Loc_BBD5:
  TXA                                   ; $BBD5: 8A
  PHA                                   ; $BBD6: 48
  INC $050A                             ; $BBD7: EE 0A 05
  LDY $050A                             ; $BBDA: AC 0A 05
  LDA $03                               ; $BBDD: A5 03
  STA $042C,Y                           ; $BBDF: 99 2C 04
  JSR $BC14                             ; $BBE2: 20 14 BC
  LDY $050A                             ; $BBE5: AC 0A 05
  LDA $BC09,Y                           ; $BBE8: B9 09 BC
  TAY                                   ; $BBEB: A8
  LDA #$00                              ; $BBEC: A9 00
  STA $042D,Y                           ; $BBEE: 99 2D 04
  STA $042E,Y                           ; $BBF1: 99 2E 04
  TXA                                   ; $BBF4: 8A
  STA $042C,Y                           ; $BBF5: 99 2C 04
  LDY $050A                             ; $BBF8: AC 0A 05
  STA $0550,Y                           ; $BBFB: 99 50 05
  PLA                                   ; $BBFE: 68
  TAX                                   ; $BBFF: AA
Loc_BC00:
  LDY $04                               ; $BC00: A4 04
  INY                                   ; $BC02: C8
  INX                                   ; $BC03: E8
  CPX #$08                              ; $BC04: E0 08
  BCC $BBBB                             ; $BC06: 90 B3
Loc_BC08:
  RTS                                   ; $BC08: 60
; --- Data Region ---
  .byte $20,$23,$26,$29,$2C,$2F,$32,$35   ; $BC09: 20 23 26 29 2C 2F 32 35
Loc_BC11:
; --- Code Region ---
  LDA $050B                             ; $BC11: AD 0B 05
Loc_BC14:
  JSR $F2AF                             ; $BC14: 20 AF F2
  LDY #$11                              ; $BC17: A0 11
  LDX #$00                              ; $BC19: A2 00
Loc_BC1B:
  LDA ($00),Y                           ; $BC1B: B1 00
  CMP #$FF                              ; $BC1D: C9 FF
  BEQ $BC28                             ; $BC1F: F0 07
  INX                                   ; $BC21: E8
  INY                                   ; $BC22: C8
  CPY #$1B                              ; $BC23: C0 1B
  BCC $BC1B                             ; $BC25: 90 F4
  RTS                                   ; $BC27: 60
Loc_BC28:
  CLC                                   ; $BC28: 18
  RTS                                   ; $BC29: 60
Loc_BC2A:
  JSR $C91E                             ; $BC2A: 20 1E C9
  JSR $BC11                             ; $BC2D: 20 11 BC
  LDX $0509                             ; $BC30: AE 09 05
  BEQ $BC39                             ; $BC33: F0 04
  CPX #$0A                              ; $BC35: E0 0A
  BNE $BC45                             ; $BC37: D0 0C
Loc_BC39:
  LDA $0664,X                           ; $BC39: BD 64 06
  STA $052B                             ; $BC3C: 8D 2B 05
  LDA $050B                             ; $BC3F: AD 0B 05
  STA $052C                             ; $BC42: 8D 2C 05
Loc_BC45:
  LDA $0664,X                           ; $BC45: BD 64 06
  STA ($00),Y                           ; $BC48: 91 00
  LDA #$FF                              ; $BC4A: A9 FF
  STA $0600,X                           ; $BC4C: 9D 00 06
  STA $0614,X                           ; $BC4F: 9D 14 06
  STA $0628,X                           ; $BC52: 9D 28 06
  STA $063C,X                           ; $BC55: 9D 3C 06
  STA $0650,X                           ; $BC58: 9D 50 06
  STA $0664,X                           ; $BC5B: 9D 64 06
  CPX $04D8                             ; $BC5E: EC D8 04
  BNE $BC66                             ; $BC61: D0 03
  STA $04D8                             ; $BC63: 8D D8 04
Loc_BC66:
  CPX $04DC                             ; $BC66: EC DC 04
  BNE $BC6E                             ; $BC69: D0 03
  STA $04DC                             ; $BC6B: 8D DC 04
Loc_BC6E:
  LDY #$00                              ; $BC6E: A0 00
  LDA ($00),Y                           ; $BC70: B1 00
  AND #$07                              ; $BC72: 29 07
  CMP #$07                              ; $BC74: C9 07
  BNE $BC92                             ; $BC76: D0 1A
  LDA $0507                             ; $BC78: AD 07 05
  LDY $0504                             ; $BC7B: AC 04 05
  BPL $BC84                             ; $BC7E: 10 04
  LSR                                   ; $BC80: 4A
  LSR                                   ; $BC81: 4A
  LSR                                   ; $BC82: 4A
  LSR                                   ; $BC83: 4A
Loc_BC84:
  AND #$0F                              ; $BC84: 29 0F
  STA $02                               ; $BC86: 85 02
  LDY #$00                              ; $BC88: A0 00
  LDA ($00),Y                           ; $BC8A: B1 00
  AND #$F0                              ; $BC8C: 29 F0
  ORA $02                               ; $BC8E: 05 02
  STA ($00),Y                           ; $BC90: 91 00
Loc_BC92:
  RTS                                   ; $BC92: 60
Loc_BC93:  ; (dispatch callback target)
  LDA $0501                             ; $BC93: AD 01 05
  CMP #$04                              ; $BC96: C9 04
  BCS $BC9D                             ; $BC98: B0 03
  JSR $DC33                             ; $BC9A: 20 33 DC
Loc_BC9D:
  LDA $0501                             ; $BC9D: AD 01 05
  JSR $EADE                             ; $BCA0: 20 DE EA
; --- Data Region ---
  .byte $B3,$BC,$C1,$BC,$F6,$BC,$13,$BD,$2C,$BD,$41,$BD,$6F,$BD,$ED,$BC; $BCA3: B3 BC C1 BC F6 BC 13 BD 2C BD 41 BD 6F BD ED BC
Loc_BCB3:  ; (dispatch callback target)
; --- Code Region ---
  LDA #$00                              ; $BCB3: A9 00
  STA $00A4                             ; $BCB5: 8D A4 00
  LDA #$CA                              ; $BCB8: A9 CA
  JSR $F283                             ; $BCBA: 20 83 F2
  INC $0501                             ; $BCBD: EE 01 05
  RTS                                   ; $BCC0: 60
Loc_BCC1:  ; (dispatch callback target)
  JSR $DF27                             ; $BCC1: 20 27 DF
  BCC $BCEC                             ; $BCC4: 90 26
  JSR $DC63                             ; $BCC6: 20 63 DC
  LDA $81                               ; $BCC9: A5 81
  AND #$02                              ; $BCCB: 29 02
  BEQ $BCDC                             ; $BCCD: F0 0D
  LDA #$00                              ; $BCCF: A9 00
  STA $0501                             ; $BCD1: 8D 01 05
  LDA #$00                              ; $BCD4: A9 00
  STA $0500                             ; $BCD6: 8D 00 05
  JMP $A1F7                             ; $BCD9: 4C F7 A1
Loc_BCDC:
  LDA $81                               ; $BCDC: A5 81
  AND #$01                              ; $BCDE: 29 01
  BEQ $BCEC                             ; $BCE0: F0 0A
  LDA #$07                              ; $BCE2: A9 07
  STA $0501                             ; $BCE4: 8D 01 05
  LDA #$05                              ; $BCE7: A9 05
  JSR $F293                             ; $BCE9: 20 93 F2
Loc_BCEC:
  RTS                                   ; $BCEC: 60
Loc_BCED:  ; (dispatch callback target)
  JSR $DF27                             ; $BCED: 20 27 DF
  BCC $BCF5                             ; $BCF0: 90 03
  JMP $BDC0                             ; $BCF2: 4C C0 BD
Loc_BCF5:
  RTS                                   ; $BCF5: 60
Loc_BCF6:  ; (dispatch callback target)
  LDY #$3D                              ; $BCF6: A0 3D
  JSR $EE07                             ; $BCF8: 20 07 EE
; --- Data Region ---
  .byte $27,$A0,$AD,$2C,$04,$20,$68,$F3,$A0,$00,$B1,$00,$8D,$2C,$04,$EE; $BCFB: 27 A0 AD 2C 04 20 68 F3 A0 00 B1 00 8D 2C 04 EE
  .byte $01,$05,$AD,$0A,$05,$4C,$83,$F2   ; $BD0B: 01 05 AD 0A 05 4C 83 F2
Loc_BD13:  ; (dispatch callback target)
; --- Code Region ---
  JSR $DF27                             ; $BD13: 20 27 DF
  BCC $BD2B                             ; $BD16: 90 13
  JSR $DC63                             ; $BD18: 20 63 DC
  LDA $81                               ; $BD1B: A5 81
  AND #$03                              ; $BD1D: 29 03
  BEQ $BD2B                             ; $BD1F: F0 0A
  LDA #$0C                              ; $BD21: A9 0C
  STA $0500                             ; $BD23: 8D 00 05
  LDA #$00                              ; $BD26: A9 00
  STA $0501                             ; $BD28: 8D 01 05
Loc_BD2B:
  RTS                                   ; $BD2B: 60
Loc_BD2C:  ; (dispatch callback target)
  LDA #$01                              ; $BD2C: A9 01
  STA $12                               ; $BD2E: 85 12
  JSR $D6CC                             ; $BD30: 20 CC D6
  INC $0509                             ; $BD33: EE 09 05
  LDA $0509                             ; $BD36: AD 09 05
  CMP #$14                              ; $BD39: C9 14
  BCC $BD40                             ; $BD3B: 90 03
  INC $0501                             ; $BD3D: EE 01 05
Loc_BD40:
  RTS                                   ; $BD40: 60
Loc_BD41:  ; (dispatch callback target)
  LDA $052E                             ; $BD41: AD 2E 05
  BNE $BD49                             ; $BD44: D0 03
  JMP $BD97                             ; $BD46: 4C 97 BD
Loc_BD49:
  LDY $052F                             ; $BD49: AC 2F 05
  LDA $6FA1,Y                           ; $BD4C: B9 A1 6F
  CMP #$FF                              ; $BD4F: C9 FF
  BEQ $BD56                             ; $BD51: F0 03
  JMP $BD97                             ; $BD53: 4C 97 BD
Loc_BD56:
  LDA #$6D                              ; $BD56: A9 6D
  STA $042C                             ; $BD58: 8D 2C 04
  JSR $DEE9                             ; $BD5B: 20 E9 DE
  BCS $BD63                             ; $BD5E: B0 03
  JMP $BD97                             ; $BD60: 4C 97 BD
Loc_BD63:
  INC $0501                             ; $BD63: EE 01 05
  JSR $E57F                             ; $BD66: 20 7F E5
  LDA #$7B                              ; $BD69: A9 7B
  JSR $E68B                             ; $BD6B: 20 8B E6
  RTS                                   ; $BD6E: 60
Loc_BD6F:  ; (dispatch callback target)
  JSR $DF27                             ; $BD6F: 20 27 DF
  BCC $BD8E                             ; $BD72: 90 1A
  JSR $DC63                             ; $BD74: 20 63 DC
  LDA $81                               ; $BD77: A5 81
  AND #$03                              ; $BD79: 29 03
  BEQ $BD8E                             ; $BD7B: F0 11
  LDA $042D                             ; $BD7D: AD 2D 04
  CMP #$FF                              ; $BD80: C9 FF
  BEQ $BD8F                             ; $BD82: F0 0B
  LDA #$FF                              ; $BD84: A9 FF
  STA $042D                             ; $BD86: 8D 2D 04
  LDA #$4B                              ; $BD89: A9 4B
  JMP $F293                             ; $BD8B: 4C 93 F2
Loc_BD8E:
  RTS                                   ; $BD8E: 60
Loc_BD8F:
  JSR $E57F                             ; $BD8F: 20 7F E5
  LDA #$1D                              ; $BD92: A9 1D
  JSR $E673                             ; $BD94: 20 73 E6
Loc_BD97:
  LDA $0470                             ; $BD97: AD 70 04
  STA $00                               ; $BD9A: 85 00
  LDA $0471                             ; $BD9C: AD 71 04
  STA $02                               ; $BD9F: 85 02
  JSR $DA5A                             ; $BDA1: 20 5A DA
  LDA $00                               ; $BDA4: A5 00
  STA $6F3F                             ; $BDA6: 8D 3F 6F
  LDA $01                               ; $BDA9: A5 01
  STA $6F40                             ; $BDAB: 8D 40 6F
  LDA $02                               ; $BDAE: A5 02
  STA $6F41                             ; $BDB0: 8D 41 6F
  LDA $03                               ; $BDB3: A5 03
  STA $6F42                             ; $BDB5: 8D 42 6F
  LDA #$05                              ; $BDB8: A9 05
  JSR $F293                             ; $BDBA: 20 93 F2
  JMP $A20C                             ; $BDBD: 4C 0C A2
Loc_BDC0:
  LDA $0505                             ; $BDC0: AD 05 05
  BPL $BDCA                             ; $BDC3: 10 05
  LDA #$00                              ; $BDC5: A9 00
  STA $0505                             ; $BDC7: 8D 05 05
Loc_BDCA:
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
  BEQ $BE33                             ; $BDE5: F0 4C
  LDA $0507                             ; $BDE7: AD 07 05
  LSR                                   ; $BDEA: 4A
  LSR                                   ; $BDEB: 4A
  LSR                                   ; $BDEC: 4A
  LSR                                   ; $BDED: 4A
  JSR $F368                             ; $BDEE: 20 68 F3
  LDY #$03                              ; $BDF1: A0 03
  LDA ($00),Y                           ; $BDF3: B1 00
  STA $050F                             ; $BDF5: 8D 0F 05
  LDA $0505                             ; $BDF8: AD 05 05
  STA $050C                             ; $BDFB: 8D 0C 05
  JSR $C5A0                             ; $BDFE: 20 A0 C5
  INC $0506                             ; $BE01: EE 06 05
  LDA $050D                             ; $BE04: AD 0D 05
  STA $0505                             ; $BE07: 8D 05 05
  LDY #$28                              ; $BE0A: A0 28
  JSR $EE07                             ; $BE0C: 20 07 EE
; --- Data Region ---
  .byte $0F,$A0,$AD,$0A,$05,$F0,$0B,$A9,$07,$8D,$00,$05,$A9,$02,$8D,$01; $BE0F: 0F A0 AD 0A 05 F0 0B A9 07 8D 00 05 A9 02 8D 01
  .byte $05                               ; $BE1F: 05
Loc_BE20:  ; (dispatch callback target)
; --- Code Region ---
  RTS                                   ; $BE20: 60
; --- Data Region ---
  .byte $20,$03,$DB,$AD,$0A,$06,$8D,$70,$04,$AD,$1E,$06,$8D,$71,$04,$4C; $BE21: 20 03 DB AD 0A 06 8D 70 04 AD 1E 06 8D 71 04 4C
  .byte $5A,$BE                           ; $BE31: 5A BE
Loc_BE33:
; --- Code Region ---
  LDA $0507                             ; $BE33: AD 07 05
  AND #$0F                              ; $BE36: 29 0F
  JSR $F368                             ; $BE38: 20 68 F3
  LDY #$03                              ; $BE3B: A0 03
  LDA ($00),Y                           ; $BE3D: B1 00
  STA $050F                             ; $BE3F: 8D 0F 05
  LDA $0505                             ; $BE42: AD 05 05
  STA $050D                             ; $BE45: 8D 0D 05
  LDA $050C                             ; $BE48: AD 0C 05
  STA $0505                             ; $BE4B: 8D 05 05
  LDA $0600                             ; $BE4E: AD 00 06
  STA $0470                             ; $BE51: 8D 70 04
  LDA $0614                             ; $BE54: AD 14 06
  STA $0471                             ; $BE57: 8D 71 04
Loc_BE5A:
  LDA $050F                             ; $BE5A: AD 0F 05
  CMP #$03                              ; $BE5D: C9 03
  BEQ $BE67                             ; $BE5F: F0 06
  STA $6F44                             ; $BE61: 8D 44 6F
  JMP $BE6E                             ; $BE64: 4C 6E BE
Loc_BE67:
  LDY #$28                              ; $BE67: A0 28
  JSR $EE07                             ; $BE69: 20 07 EE
; --- Data Region ---
  .byte $0C,$A0                           ; $BE6C: 0C A0
Loc_BE6E:
; --- Code Region ---
  LDA #$04                              ; $BE6E: A9 04
  STA $0501                             ; $BE70: 8D 01 05
  LDA #$07                              ; $BE73: A9 07
  STA $0500                             ; $BE75: 8D 00 05
  LDA #$00                              ; $BE78: A9 00
  STA $0509                             ; $BE7A: 8D 09 05
  RTS                                   ; $BE7D: 60
Loc_BE7E:  ; (dispatch callback target)
  LDA $0501                             ; $BE7E: AD 01 05
  JSR $EADE                             ; $BE81: 20 DE EA
; --- Data Region ---
  .byte $A6,$BE,$BA,$BE,$01,$BF,$19,$BF,$7C,$BF,$98,$BF,$B8,$BF,$DC,$BF; $BE84: A6 BE BA BE 01 BF 19 BF 7C BF 98 BF B8 BF DC BF
  .byte $04,$C0,$54,$C0,$7D,$C0,$10,$C1,$3B,$C1,$49,$C1,$78,$C1,$D1,$C1; $BE94: 04 C0 54 C0 7D C0 10 C1 3B C1 49 C1 78 C1 D1 C1
  .byte $EB,$C1                           ; $BEA4: EB C1
Loc_BEA6:  ; (dispatch callback target)
; --- Code Region ---
  LDA $0087                             ; $BEA6: AD 87 00
  BPL $BEB9                             ; $BEA9: 10 0E
  LDA #$00                              ; $BEAB: A9 00
  STA $6F8B                             ; $BEAD: 8D 8B 6F
  STA $6F8D                             ; $BEB0: 8D 8D 6F
  STA $6F8E                             ; $BEB3: 8D 8E 6F
  INC $0501                             ; $BEB6: EE 01 05
Loc_BEB9:
  RTS                                   ; $BEB9: 60
Loc_BEBA:  ; (dispatch callback target)
  LDA $6F8B                             ; $BEBA: AD 8B 6F
  CMP #$FF                              ; $BEBD: C9 FF
  BNE $BF00                             ; $BEBF: D0 3F
  LDA $6F8F                             ; $BEC1: AD 8F 6F
  CMP #$03                              ; $BEC4: C9 03
  BEQ $BEFD                             ; $BEC6: F0 35
  LDA $6F8C                             ; $BEC8: AD 8C 6F
  STA $0509                             ; $BECB: 8D 09 05
  TAY                                   ; $BECE: A8
  LDA $0600,Y                           ; $BECF: B9 00 06
  STA $00                               ; $BED2: 85 00
  LDA $0614,Y                           ; $BED4: B9 14 06
  STA $02                               ; $BED7: 85 02
  JSR $DA5A                             ; $BED9: 20 5A DA
  LDA $00                               ; $BEDC: A5 00
  STA $6F3F                             ; $BEDE: 8D 3F 6F
  LDA $01                               ; $BEE1: A5 01
  STA $6F40                             ; $BEE3: 8D 40 6F
  LDA $02                               ; $BEE6: A5 02
  STA $6F41                             ; $BEE8: 8D 41 6F
  LDA $03                               ; $BEEB: A5 03
  STA $6F42                             ; $BEED: 8D 42 6F
  JSR $D5EE                             ; $BEF0: 20 EE D5
  LDA $0508                             ; $BEF3: AD 08 05
  BNE $BF00                             ; $BEF6: D0 08
  LDA $007E                             ; $BEF8: AD 7E 00
  BNE $BF00                             ; $BEFB: D0 03
Loc_BEFD:
  INC $0501                             ; $BEFD: EE 01 05
Loc_BF00:
  RTS                                   ; $BF00: 60
Loc_BF01:  ; (dispatch callback target)
  LDY $6F8F                             ; $BF01: AC 8F 6F
  LDA $BF14,Y                           ; $BF04: B9 14 BF
  STA $0501                             ; $BF07: 8D 01 05
  CMP #$0C                              ; $BF0A: C9 0C
  BNE $BF13                             ; $BF0C: D0 05
  LDA #$05                              ; $BF0E: A9 05
  JSR $F293                             ; $BF10: 20 93 F2
Loc_BF13:
  RTS                                   ; $BF13: 60
; --- Data Region ---
  .byte $03,$05,$08,$0C,$0D               ; $BF14: 03 05 08 0C 0D
Loc_BF19:  ; (dispatch callback target)
; --- Code Region ---
  LDA $007E                             ; $BF19: AD 7E 00
  BEQ $BF1F                             ; $BF1C: F0 01
  RTS                                   ; $BF1E: 60
; --- Data Region ---
  .byte $A9,$00,$85,$12,$20,$CC,$D6,$A9,$00,$85,$00,$85,$01,$A9,$01,$85; $BF1F: A9 00 85 12 20 CC D6 A9 00 85 00 85 01 A9 01 85
  .byte $02,$AD,$8D,$6F,$29,$01,$D0,$04,$A9,$FF,$85,$02; $BF2F: 02 AD 8D 6F 29 01 D0 04 A9 FF 85 02
Loc_BF3B:
; --- Code Region ---
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
  BNE $BF78                             ; $BF60: D0 16
  LDA $01                               ; $BF62: A5 01
  BMI $BF6F                             ; $BF64: 30 09
  LDA $0614,Y                           ; $BF66: B9 14 06
  CLC                                   ; $BF69: 18
  ADC #$01                              ; $BF6A: 69 01
  JMP $BF75                             ; $BF6C: 4C 75 BF
Loc_BF6F:
  LDA $0614,Y                           ; $BF6F: B9 14 06
  SEC                                   ; $BF72: 38
  SBC #$01                              ; $BF73: E9 01
Loc_BF75:
  STA $0614,Y                           ; $BF75: 99 14 06
Loc_BF78:
  INC $0501                             ; $BF78: EE 01 05
  RTS                                   ; $BF7B: 60
Loc_BF7C:  ; (dispatch callback target)
  LDA #$01                              ; $BF7C: A9 01
  STA $12                               ; $BF7E: 85 12
  JSR $D6CC                             ; $BF80: 20 CC D6
  LDA $0505                             ; $BF83: AD 05 05
  SEC                                   ; $BF86: 38
  SBC $6F97                             ; $BF87: ED 97 6F
  STA $0505                             ; $BF8A: 8D 05 05
  LDA #$04                              ; $BF8D: A9 04
  STA $0500                             ; $BF8F: 8D 00 05
  LDA #$02                              ; $BF92: A9 02
  STA $0501                             ; $BF94: 8D 01 05
  RTS                                   ; $BF97: 60
Loc_BF98:  ; (dispatch callback target)
  LDA $6F8D                             ; $BF98: AD 8D 6F
  STA $0509                             ; $BF9B: 8D 09 05
  LDY #$3D                              ; $BF9E: A0 3D
  JSR $EE07                             ; $BFA0: 20 07 EE
; --- Data Region ---
  .byte $27,$A0,$A9,$02,$8D,$A4,$00,$CE,$05,$05,$CE,$05,$05,$EE,$01,$05; $BFA3: 27 A0 A9 02 8D A4 00 CE 05 05 CE 05 05 EE 01 05
  .byte $A9,$A0,$4C,$83,$F2               ; $BFB3: A9 A0 4C 83 F2
Loc_BFB8:  ; (dispatch callback target)
; --- Code Region ---
  LDY $6F8D                             ; $BFB8: AC 8D 6F
  JSR $DC36                             ; $BFBB: 20 36 DC
  LDA $6F8C                             ; $BFBE: AD 8C 6F
  STA $0509                             ; $BFC1: 8D 09 05
  JSR $A1DE                             ; $BFC4: 20 DE A1
  JSR $DF27                             ; $BFC7: 20 27 DF
  BCC $BFDB                             ; $BFCA: 90 0F
  JSR $DC63                             ; $BFCC: 20 63 DC
  LDA $81                               ; $BFCF: A5 81
  AND #$01                              ; $BFD1: 29 01
  BEQ $BFDB                             ; $BFD3: F0 06
  INC $0501                             ; $BFD5: EE 01 05
  JSR $ECEE                             ; $BFD8: 20 EE EC
Loc_BFDB:
  RTS                                   ; $BFDB: 60
Loc_BFDC:  ; (dispatch callback target)
  LDY $6F8D                             ; $BFDC: AC 8D 6F
  JSR $DC36                             ; $BFDF: 20 36 DC
  LDA $0087                             ; $BFE2: AD 87 00
  BPL $C003                             ; $BFE5: 10 1C
  LDA $6F8D                             ; $BFE7: AD 8D 6F
  STA $0509                             ; $BFEA: 8D 09 05
  LDA $6F8C                             ; $BFED: AD 8C 6F
  STA $050A                             ; $BFF0: 8D 0A 05
  LDA #$03                              ; $BFF3: A9 03
  STA $0500                             ; $BFF5: 8D 00 05
  STA $0501                             ; $BFF8: 8D 01 05
  LDA #$00                              ; $BFFB: A9 00
  STA $00A4                             ; $BFFD: 8D A4 00
  JMP $A3D2                             ; $C000: 4C D2 A3
Loc_C003:
  RTS                                   ; $C003: 60
Loc_C004:  ; (dispatch callback target)
  LDA $6F8D                             ; $C004: AD 8D 6F
  CMP #$0B                              ; $C007: C9 0B
  BNE $C00E                             ; $C009: D0 03
  JMP $C1AF                             ; $C00B: 4C AF C1
Loc_C00E:
  LDA $6F8E                             ; $C00E: AD 8E 6F
  STA $0509                             ; $C011: 8D 09 05
  LDY #$3D                              ; $C014: A0 3D
  JSR $EE07                             ; $C016: 20 07 EE
; --- Data Region ---
  .byte $27,$A0,$AC,$8D,$6F,$AD,$05,$05,$38,$F9,$44,$C0,$8D,$05,$05,$AD; $C019: 27 A0 AC 8D 6F AD 05 05 38 F9 44 C0 8D 05 05 AD
  .byte $8D,$6F,$8D,$2C,$04,$A9,$00,$8D,$2D,$04,$8D,$2E,$04,$A9,$A1,$20; $C029: 8D 6F 8D 2C 04 A9 00 8D 2D 04 8D 2E 04 A9 A1 20
  .byte $83,$F2,$A9,$65,$20,$9B,$E6,$EE,$01,$05,$60,$06,$05,$04,$06,$07; $C039: 83 F2 A9 65 20 9B E6 EE 01 05 60 06 05 04 06 07
  .byte $08,$08,$0C,$0A,$09,$09,$0F,$0E,$0F,$19,$14; $C049: 08 08 0C 0A 09 09 0F 0E 0F 19 14
Loc_C054:  ; (dispatch callback target)
; --- Code Region ---
  INC $042D                             ; $C054: EE 2D 04
  LDA #$00                              ; $C057: A9 00
  STA $00A4                             ; $C059: 8D A4 00
  LDY $6F8E                             ; $C05C: AC 8E 6F
  JSR $DC36                             ; $C05F: 20 36 DC
  LDA $6F8C                             ; $C062: AD 8C 6F
  STA $0509                             ; $C065: 8D 09 05
  JSR $A1DE                             ; $C068: 20 DE A1
  JSR $DF27                             ; $C06B: 20 27 DF
  BCC $C07C                             ; $C06E: 90 0C
  JSR $DC63                             ; $C070: 20 63 DC
  LDA $81                               ; $C073: A5 81
  AND #$03                              ; $C075: 29 03
  BEQ $C07C                             ; $C077: F0 03
  INC $0501                             ; $C079: EE 01 05
Loc_C07C:
  RTS                                   ; $C07C: 60
Loc_C07D:  ; (dispatch callback target)
  LDY $6F8E                             ; $C07D: AC 8E 6F
  JSR $DC36                             ; $C080: 20 36 DC
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
  JSR $DB03                             ; $C0A0: 20 03 DB
  LDA #$01                              ; $C0A3: A9 01
  STA $12                               ; $C0A5: 85 12
  JSR $D6CC                             ; $C0A7: 20 CC D6
  LDA #$0B                              ; $C0AA: A9 0B
  STA $0501                             ; $C0AC: 8D 01 05
  LDA $0544                             ; $C0AF: AD 44 05
  BEQ $C0BE                             ; $C0B2: F0 0A
  LDA #$03                              ; $C0B4: A9 03
  STA $00A4                             ; $C0B6: 8D A4 00
  LDA #$A2                              ; $C0B9: A9 A2
  JMP $F283                             ; $C0BB: 4C 83 F2
Loc_C0BE:
  LDA #$04                              ; $C0BE: A9 04
  STA $00A4                             ; $C0C0: 8D A4 00
  LDA $0543                             ; $C0C3: AD 43 05
  AND #$0F                              ; $C0C6: 29 0F
  TAY                                   ; $C0C8: A8
  CPY #$08                              ; $C0C9: C0 08
  BEQ $C0FB                             ; $C0CB: F0 2E
  CPY #$01                              ; $C0CD: C0 01
  BEQ $C0E1                             ; $C0CF: F0 10
  CPY #$09                              ; $C0D1: C0 09
  BNE $C0F5                             ; $C0D3: D0 20
  LDA $042C                             ; $C0D5: AD 2C 04
  BNE $C0E1                             ; $C0D8: D0 07
  LDA $042D                             ; $C0DA: AD 2D 04
  BNE $C0E1                             ; $C0DD: D0 02
  LDY #$01                              ; $C0DF: A0 01
Loc_C0E1:
  LDA $0432                             ; $C0E1: AD 32 04
  CMP #$FF                              ; $C0E4: C9 FF
  BEQ $C0F5                             ; $C0E6: F0 0D
  STA $042C                             ; $C0E8: 8D 2C 04
  LDA #$0F                              ; $C0EB: A9 0F
  STA $0501                             ; $C0ED: 8D 01 05
  LDA #$4E                              ; $C0F0: A9 4E
  JMP $F293                             ; $C0F2: 4C 93 F2
Loc_C0F5:
  LDA $C100,Y                           ; $C0F5: B9 00 C1
  JMP $F283                             ; $C0F8: 4C 83 F2
Loc_C0FB:
  LDA #$B7                              ; $C0FB: A9 B7
  JMP $F293                             ; $C0FD: 4C 93 F2
; --- Data Region ---
  .byte $A3,$A4,$A5,$A3,$A3,$A6,$A3,$A3,$B7,$4F,$A5,$A3,$A3,$A3,$A3,$B6; $C100: A3 A4 A5 A3 A3 A6 A3 A3 B7 4F A5 A3 A3 A3 A3 B6
Loc_C110:  ; (dispatch callback target)
; --- Code Region ---
  LDY $6F8E                             ; $C110: AC 8E 6F
  JSR $DC36                             ; $C113: 20 36 DC
  LDA $6F8C                             ; $C116: AD 8C 6F
  STA $0509                             ; $C119: 8D 09 05
  JSR $A1DE                             ; $C11C: 20 DE A1
  JSR $DF27                             ; $C11F: 20 27 DF
  BCC $C13A                             ; $C122: 90 16
  JSR $DC63                             ; $C124: 20 63 DC
  LDA $81                               ; $C127: A5 81
  AND #$03                              ; $C129: 29 03
  BEQ $C13A                             ; $C12B: F0 0D
  JSR $A1F7                             ; $C12D: 20 F7 A1
  LDA #$05                              ; $C130: A9 05
  JSR $F293                             ; $C132: 20 93 F2
  LDA #$10                              ; $C135: A9 10
  STA $0501                             ; $C137: 8D 01 05
Loc_C13A:
  RTS                                   ; $C13A: 60
Loc_C13B:  ; (dispatch callback target)
  JSR $DF27                             ; $C13B: 20 27 DF
  BCC $C13A                             ; $C13E: 90 FA
  LDA $6F8C                             ; $C140: AD 8C 6F
  STA $0509                             ; $C143: 8D 09 05
  JMP $BDC0                             ; $C146: 4C C0 BD
Loc_C149:  ; (dispatch callback target)
  LDY #$00                              ; $C149: A0 00
  LDA $0504                             ; $C14B: AD 04 05
  BMI $C152                             ; $C14E: 30 02
  LDY #$0A                              ; $C150: A0 0A
Loc_C152:
  TYA                                   ; $C152: 98
  STA $0509                             ; $C153: 8D 09 05
  LDY #$3D                              ; $C156: A0 3D
  JSR $EE07                             ; $C158: 20 07 EE
; --- Data Region ---
  .byte $27,$A0,$AD,$09,$05,$8D,$0A,$05,$AD,$8C,$6F,$8D,$09,$05,$A8,$B9; $C15B: 27 A0 AD 09 05 8D 0A 05 AD 8C 6F 8D 09 05 A8 B9
  .byte $64,$06,$8D,$2C,$04,$EE,$01,$05,$A9,$BD,$4C,$83,$F2; $C16B: 64 06 8D 2C 04 EE 01 05 A9 BD 4C 83 F2
Loc_C178:  ; (dispatch callback target)
; --- Code Region ---
  LDA #$00                              ; $C178: A9 00
  STA $00A4                             ; $C17A: 8D A4 00
  LDY $050A                             ; $C17D: AC 0A 05
  JSR $DC36                             ; $C180: 20 36 DC
  JSR $A1DE                             ; $C183: 20 DE A1
  JSR $DF27                             ; $C186: 20 27 DF
  BCC $C13A                             ; $C189: 90 AF
  JSR $DC63                             ; $C18B: 20 63 DC
  LDA $81                               ; $C18E: A5 81
  AND #$03                              ; $C190: 29 03
  BEQ $C1AE                             ; $C192: F0 1A
  LDA #$00                              ; $C194: A9 00
  STA $12                               ; $C196: 85 12
  JSR $D6CC                             ; $C198: 20 CC D6
  LDA $6F8D                             ; $C19B: AD 8D 6F
  STA $050B                             ; $C19E: 8D 0B 05
  JSR $BC2A                             ; $C1A1: 20 2A BC
  LDA #$05                              ; $C1A4: A9 05
  JSR $F293                             ; $C1A6: 20 93 F2
Loc_C1A9:  ; (dispatch callback target)
  LDA #$10                              ; $C1A9: A9 10
  STA $0501                             ; $C1AB: 8D 01 05
Loc_C1AE:
  RTS                                   ; $C1AE: 60
Loc_C1AF:
  LDA $6F8D                             ; $C1AF: AD 8D 6F
  STA $0543                             ; $C1B2: 8D 43 05
  LDA $6F8C                             ; $C1B5: AD 8C 6F
  STA $0509                             ; $C1B8: 8D 09 05
  STA $050A                             ; $C1BB: 8D 0A 05
  JSR $B02B                             ; $C1BE: 20 2B B0
  JSR $DB03                             ; $C1C1: 20 03 DB
  LDA #$01                              ; $C1C4: A9 01
  STA $12                               ; $C1C6: 85 12
  JSR $D6CC                             ; $C1C8: 20 CC D6
  JSR $A1F7                             ; $C1CB: 20 F7 A1
  JMP $C1F0                             ; $C1CE: 4C F0 C1
Loc_C1D1:  ; (dispatch callback target)
  JSR $DF27                             ; $C1D1: 20 27 DF
  BCC $C1EA                             ; $C1D4: 90 14
  JSR $DC63                             ; $C1D6: 20 63 DC
  LDA $81                               ; $C1D9: A5 81
  AND #$03                              ; $C1DB: 29 03
  BEQ $C1EA                             ; $C1DD: F0 0B
  JSR $A1F7                             ; $C1DF: 20 F7 A1
  LDA #$05                              ; $C1E2: A9 05
  JSR $F293                             ; $C1E4: 20 93 F2
  INC $0501                             ; $C1E7: EE 01 05
Loc_C1EA:
  RTS                                   ; $C1EA: 60
Loc_C1EB:  ; (dispatch callback target)
  JSR $DF27                             ; $C1EB: 20 27 DF
  BCC $C1FB                             ; $C1EE: 90 0B
Loc_C1F0:
  LDA #$00                              ; $C1F0: A9 00
  STA $0500                             ; $C1F2: 8D 00 05
  STA $0501                             ; $C1F5: 8D 01 05
  STA $00A4                             ; $C1F8: 8D A4 00
Loc_C1FB:
  RTS                                   ; $C1FB: 60
Loc_C1FC:  ; (dispatch callback target)
  LDY #$28                              ; $C1FC: A0 28
  JSR $EE07                             ; $C1FE: 20 07 EE
; --- Data Region ---
  .byte $09,$A0,$60,$AD,$01,$05,$20,$DE,$EA,$18,$C2,$4F,$C2,$8A,$C2,$CD; $C201: 09 A0 60 AD 01 05 20 DE EA 18 C2 4F C2 8A C2 CD
  .byte $C2,$F7,$C2,$0E,$C3,$50,$C3       ; $C211: C2 F7 C2 0E C3 50 C3
Loc_C218:  ; (dispatch callback target)
; --- Code Region ---
  JSR $C620                             ; $C218: 20 20 C6
  INC $0501                             ; $C21B: EE 01 05
  LDA $060A                             ; $C21E: AD 0A 06
  STA $00                               ; $C221: 85 00
  LDA $061E                             ; $C223: AD 1E 06
  STA $02                               ; $C226: 85 02
  JSR $DA5A                             ; $C228: 20 5A DA
  LDA $00                               ; $C22B: A5 00
  STA $6F3F                             ; $C22D: 8D 3F 6F
  LDA $01                               ; $C230: A5 01
  STA $6F40                             ; $C232: 8D 40 6F
  LDA $02                               ; $C235: A5 02
  STA $6F41                             ; $C237: 8D 41 6F
  LDA $03                               ; $C23A: A5 03
  STA $6F42                             ; $C23C: 8D 42 6F
  JSR $C5A0                             ; $C23F: 20 A0 C5
  INC $0506                             ; $C242: EE 06 05
  LDA $050D                             ; $C245: AD 0D 05
  STA $0505                             ; $C248: 8D 05 05
  JSR $DC1E                             ; $C24B: 20 1E DC
  RTS                                   ; $C24E: 60
Loc_C24F:  ; (dispatch callback target)
  LDA $0507                             ; $C24F: AD 07 05
  AND #$0F                              ; $C252: 29 0F
  JSR $F368                             ; $C254: 20 68 F3
  LDY #$03                              ; $C257: A0 03
  LDA ($00),Y                           ; $C259: B1 00
  CMP #$03                              ; $C25B: C9 03
  BEQ $C286                             ; $C25D: F0 27
  STA $6F44                             ; $C25F: 8D 44 6F
  LDA #$04                              ; $C262: A9 04
  STA $0501                             ; $C264: 8D 01 05
  LDA #$02                              ; $C267: A9 02
  STA $050B                             ; $C269: 8D 0B 05
  LDA #$00                              ; $C26C: A9 00
  STA $0509                             ; $C26E: 8D 09 05
  LDA #$F9                              ; $C271: A9 F9
  JSR $F293                             ; $C273: 20 93 F2
  LDA $0507                             ; $C276: AD 07 05
  AND #$0F                              ; $C279: 29 0F
  JSR $F368                             ; $C27B: 20 68 F3
  LDY #$00                              ; $C27E: A0 00
  LDA ($00),Y                           ; $C280: B1 00
  STA $042C                             ; $C282: 8D 2C 04
  RTS                                   ; $C285: 60
Loc_C286:
  INC $0501                             ; $C286: EE 01 05
  RTS                                   ; $C289: 60
Loc_C28A:  ; (dispatch callback target)
  LDA $0507                             ; $C28A: AD 07 05
  LSR                                   ; $C28D: 4A
  LSR                                   ; $C28E: 4A
  LSR                                   ; $C28F: 4A
  LSR                                   ; $C290: 4A
  AND #$0F                              ; $C291: 29 0F
  JSR $F368                             ; $C293: 20 68 F3
  LDY #$03                              ; $C296: A0 03
  LDA ($00),Y                           ; $C298: B1 00
  CMP #$03                              ; $C29A: C9 03
  BEQ $C2C9                             ; $C29C: F0 2B
  STA $6F44                             ; $C29E: 8D 44 6F
  LDA #$04                              ; $C2A1: A9 04
  STA $0501                             ; $C2A3: 8D 01 05
  LDA #$03                              ; $C2A6: A9 03
  STA $050B                             ; $C2A8: 8D 0B 05
  LDA #$0A                              ; $C2AB: A9 0A
  STA $0509                             ; $C2AD: 8D 09 05
  LDA #$F9                              ; $C2B0: A9 F9
  JSR $F293                             ; $C2B2: 20 93 F2
  LDA $0507                             ; $C2B5: AD 07 05
  LSR                                   ; $C2B8: 4A
  LSR                                   ; $C2B9: 4A
  LSR                                   ; $C2BA: 4A
  LSR                                   ; $C2BB: 4A
  AND #$0F                              ; $C2BC: 29 0F
  JSR $F368                             ; $C2BE: 20 68 F3
  LDY #$00                              ; $C2C1: A0 00
  LDA ($00),Y                           ; $C2C3: B1 00
  STA $042C                             ; $C2C5: 8D 2C 04
  RTS                                   ; $C2C8: 60
Loc_C2C9:
  INC $0501                             ; $C2C9: EE 01 05
  RTS                                   ; $C2CC: 60
Loc_C2CD:  ; (dispatch callback target)
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
  JSR $F368                             ; $C2EC: 20 68 F3
  LDY #$03                              ; $C2EF: A0 03
  LDA ($00),Y                           ; $C2F1: B1 00
  STA $050F                             ; $C2F3: 8D 0F 05
  RTS                                   ; $C2F6: 60
Loc_C2F7:  ; (dispatch callback target)
  JSR $DF27                             ; $C2F7: 20 27 DF
  BCC $C30D                             ; $C2FA: 90 11
  JSR $DC63                             ; $C2FC: 20 63 DC
  LDA $81                               ; $C2FF: A5 81
  AND #$01                              ; $C301: 29 01
  BEQ $C30D                             ; $C303: F0 08
  INC $0501                             ; $C305: EE 01 05
  LDA #$FF                              ; $C308: A9 FF
  STA $050A                             ; $C30A: 8D 0A 05
Loc_C30D:
  RTS                                   ; $C30D: 60
Loc_C30E:  ; (dispatch callback target)
  INC $050A                             ; $C30E: EE 0A 05
  LDA $050A                             ; $C311: AD 0A 05
  CMP #$0A                              ; $C314: C9 0A
  BCC $C328                             ; $C316: 90 10
  LDA #$09                              ; $C318: A9 09
  STA $BB                               ; $C31A: 85 BB
  LDA $050B                             ; $C31C: AD 0B 05
  STA $0501                             ; $C31F: 8D 01 05
  LDA #$05                              ; $C322: A9 05
  JMP $F293                             ; $C324: 4C 93 F2
; --- Data Region ---
  .byte $60                               ; $C327: 60
Loc_C328:
; --- Code Region ---
  LDY $0509                             ; $C328: AC 09 05
  LDA $0664,Y                           ; $C32B: B9 64 06
  CMP #$FF                              ; $C32E: C9 FF
  BNE $C338                             ; $C330: D0 06
  INC $0509                             ; $C332: EE 09 05
  JMP $C30E                             ; $C335: 4C 0E C3
Loc_C338:
  STA $0410                             ; $C338: 8D 10 04
  LDA #$08                              ; $C33B: A9 08
  STA $BA                               ; $C33D: 85 BA
  LDA #$00                              ; $C33F: A9 00
  STA $040C                             ; $C341: 8D 0C 04
  LDA #$00                              ; $C344: A9 00
  STA $040D                             ; $C346: 8D 0D 04
  INC $0501                             ; $C349: EE 01 05
  JSR $C3CB                             ; $C34C: 20 CB C3
  RTS                                   ; $C34F: 60
Loc_C350:  ; (dispatch callback target)
  LDA #$A7                              ; $C350: A9 A7
  STA $0A                               ; $C352: 85 0A
  LDA $0410                             ; $C354: AD 10 04
  STA $00                               ; $C357: 85 00
  LDA #$00                              ; $C359: A9 00
  STA $00A4                             ; $C35B: 8D A4 00
  LDY #$39                              ; $C35E: A0 39
  JSR $EE07                             ; $C360: 20 07 EE
; --- Data Region ---
  .byte $00,$A0,$AC,$09,$05,$B9,$00,$06,$85,$00,$B9,$14,$06,$85,$02,$20; $C363: 00 A0 AC 09 05 B9 00 06 85 00 B9 14 06 85 02 20
  .byte $5A,$DA,$A5,$00,$8D,$3F,$6F,$A5,$01,$8D,$40,$6F,$A5,$02,$8D,$41; $C373: 5A DA A5 00 8D 3F 6F A5 01 8D 40 6F A5 02 8D 41
  .byte $6F,$A5,$03,$8D,$42,$6F,$20,$EE,$D5,$AD,$08,$05,$D0,$39,$AD,$7E; $C383: 6F A5 03 8D 42 6F 20 EE D5 AD 08 05 D0 39 AD 7E
  .byte $00,$D0,$34,$A9,$06,$85,$BB,$A0,$39,$20,$07,$EE,$12,$A0,$20,$DE; $C393: 00 D0 34 A9 06 85 BB A0 39 20 07 EE 12 A0 20 DE
  .byte $A1,$AD,$0D,$04,$C9,$FF           ; $C3A3: A1 AD 0D 04 C9 FF
Loc_C3A9:  ; (dispatch callback target)
; --- Code Region ---
  BNE $C3CA                             ; $C3A9: D0 1F
  JSR $C4B1                             ; $C3AB: 20 B1 C4
  JSR $DF27                             ; $C3AE: 20 27 DF
  BCC $C3CA                             ; $C3B1: 90 17
  LDA $81                               ; $C3B3: A5 81
  CMP #$10                              ; $C3B5: C9 10
  BCS $C3CA                             ; $C3B7: B0 11
  AND #$01                              ; $C3B9: 29 01
  BEQ $C3CA                             ; $C3BB: F0 0D
  DEC $0501                             ; $C3BD: CE 01 05
  LDA #$01                              ; $C3C0: A9 01
  STA $12                               ; $C3C2: 85 12
  JSR $D6CC                             ; $C3C4: 20 CC D6
  INC $0509                             ; $C3C7: EE 09 05
Loc_C3CA:
  RTS                                   ; $C3CA: 60
Loc_C3CB:
  LDA $050B                             ; $C3CB: AD 0B 05
  CMP #$02                              ; $C3CE: C9 02
  BNE $C41C                             ; $C3D0: D0 4A
  JSR $DEBF                             ; $C3D2: 20 BF DE
  ASL                                   ; $C3D5: 0A
  ASL                                   ; $C3D6: 0A
  ASL                                   ; $C3D7: 0A
  ASL                                   ; $C3D8: 0A
  ASL                                   ; $C3D9: 0A
  STA $18                               ; $C3DA: 85 18
  LDY #$26                              ; $C3DC: A0 26
  JSR $F25F                             ; $C3DE: 20 5F F2
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
Loc_C3F5:
  LDY #$00                              ; $C3F5: A0 00
Loc_C3F7:
  LDA ($10),Y                           ; $C3F7: B1 10
  STA $01                               ; $C3F9: 85 01
  INY                                   ; $C3FB: C8
  LDA ($10),Y                           ; $C3FC: B1 10
  STA $00                               ; $C3FE: 85 00
  INY                                   ; $C400: C8
  STY $12                               ; $C401: 84 12
  JSR $D6B6                             ; $C403: 20 B6 D6
  TYA                                   ; $C406: 98
  BMI $C40E                             ; $C407: 30 05
  LDY $12                               ; $C409: A4 12
  JMP $C3F7                             ; $C40B: 4C F7 C3
Loc_C40E:
  LDY $0509                             ; $C40E: AC 09 05
  LDA $00                               ; $C411: A5 00
  STA $0600,Y                           ; $C413: 99 00 06
  LDA $01                               ; $C416: A5 01
  STA $0614,Y                           ; $C418: 99 14 06
  RTS                                   ; $C41B: 60
Loc_C41C:
  JSR $DE9E                             ; $C41C: 20 9E DE
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
  JSR $F25F                             ; $C42D: 20 5F F2
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
  JMP $C3F5                             ; $C444: 4C F5 C3
Loc_C447:
  LDA $050B                             ; $C447: AD 0B 05
  CMP #$02                              ; $C44A: C9 02
  BNE $C48E                             ; $C44C: D0 40
  JSR $DEBF                             ; $C44E: 20 BF DE
  ASL                                   ; $C451: 0A
  ASL                                   ; $C452: 0A
  STA $18                               ; $C453: 85 18
  LDY #$26                              ; $C455: A0 26
  JSR $F25F                             ; $C457: 20 5F F2
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
Loc_C46E:
  LDY #$00                              ; $C46E: A0 00
  LDA $01                               ; $C470: A5 01
  CMP ($10),Y                           ; $C472: D1 10
  BCC $C48C                             ; $C474: 90 16
  LDY #$02                              ; $C476: A0 02
  CMP ($10),Y                           ; $C478: D1 10
  BCS $C48C                             ; $C47A: B0 10
  LDY #$01                              ; $C47C: A0 01
  LDA $00                               ; $C47E: A5 00
  CMP ($10),Y                           ; $C480: D1 10
  BCC $C48C                             ; $C482: 90 08
  LDY #$03                              ; $C484: A0 03
  CMP ($10),Y                           ; $C486: D1 10
  BCS $C48C                             ; $C488: B0 02
  SEC                                   ; $C48A: 38
  RTS                                   ; $C48B: 60
Loc_C48C:
  CLC                                   ; $C48C: 18
  RTS                                   ; $C48D: 60
Loc_C48E:
  JSR $DE9E                             ; $C48E: 20 9E DE
  ASL                                   ; $C491: 0A
  ASL                                   ; $C492: 0A
  STA $18                               ; $C493: 85 18
  LDY #$26                              ; $C495: A0 26
  JSR $F25F                             ; $C497: 20 5F F2
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
  JMP $C46E                             ; $C4AE: 4C 6E C4
Loc_C4B1:
  LDA $040D                             ; $C4B1: AD 0D 04
  CMP #$FF                              ; $C4B4: C9 FF
  BEQ $C4B9                             ; $C4B6: F0 01
  RTS                                   ; $C4B8: 60
Loc_C4B9:
  LDA $81                               ; $C4B9: A5 81
  ASL                                   ; $C4BB: 0A
  BPL $C4E9                             ; $C4BC: 10 2B
  LDY $0509                             ; $C4BE: AC 09 05
  LDA $0600,Y                           ; $C4C1: B9 00 06
  SEC                                   ; $C4C4: 38
  SBC #$01                              ; $C4C5: E9 01
  BCC $C4E9                             ; $C4C7: 90 20
  STA $00                               ; $C4C9: 85 00
  LDA $0614,Y                           ; $C4CB: B9 14 06
  STA $01                               ; $C4CE: 85 01
  JSR $D6B6                             ; $C4D0: 20 B6 D6
  TYA                                   ; $C4D3: 98
  BPL $C4E9                             ; $C4D4: 10 13
  JSR $C447                             ; $C4D6: 20 47 C4
  BCC $C4E9                             ; $C4D9: 90 0E
  LDA #$00                              ; $C4DB: A9 00
  STA $12                               ; $C4DD: 85 12
  JSR $D6CC                             ; $C4DF: 20 CC D6
  LDX $0509                             ; $C4E2: AE 09 05
  DEC $0600,X                           ; $C4E5: DE 00 06
  RTS                                   ; $C4E8: 60
Loc_C4E9:
  LDA $81                               ; $C4E9: A5 81
  BPL $C51A                             ; $C4EB: 10 2D
  LDY $0509                             ; $C4ED: AC 09 05
  LDA $0600,Y                           ; $C4F0: B9 00 06
  CLC                                   ; $C4F3: 18
  ADC #$01                              ; $C4F4: 69 01
  CMP #$1F                              ; $C4F6: C9 1F
  BCS $C51A                             ; $C4F8: B0 20
  STA $00                               ; $C4FA: 85 00
  LDA $0614,Y                           ; $C4FC: B9 14 06
  STA $01                               ; $C4FF: 85 01
  JSR $D6B6                             ; $C501: 20 B6 D6
  TYA                                   ; $C504: 98
  BPL $C51A                             ; $C505: 10 13
  JSR $C447                             ; $C507: 20 47 C4
  BCC $C51A                             ; $C50A: 90 0E
  LDA #$00                              ; $C50C: A9 00
  STA $12                               ; $C50E: 85 12
  JSR $D6CC                             ; $C510: 20 CC D6
  LDX $0509                             ; $C513: AE 09 05
  INC $0600,X                           ; $C516: FE 00 06
  RTS                                   ; $C519: 60
Loc_C51A:
  LDA $81                               ; $C51A: A5 81
  ASL                                   ; $C51C: 0A
  ASL                                   ; $C51D: 0A
  ASL                                   ; $C51E: 0A
  BPL $C55C                             ; $C51F: 10 3B
  LDY $0509                             ; $C521: AC 09 05
  LDA $0600,Y                           ; $C524: B9 00 06
  STA $00                               ; $C527: 85 00
  LDA $0614,Y                           ; $C529: B9 14 06
  SEC                                   ; $C52C: 38
  SBC #$01                              ; $C52D: E9 01
  BMI $C55C                             ; $C52F: 30 2B
  CMP #$0F                              ; $C531: C9 0F
  BNE $C538                             ; $C533: D0 03
  SEC                                   ; $C535: 38
  SBC #$01                              ; $C536: E9 01
Loc_C538:
  STA $01                               ; $C538: 85 01
  JSR $D6B6                             ; $C53A: 20 B6 D6
  TYA                                   ; $C53D: 98
  BPL $C55C                             ; $C53E: 10 1C
  JSR $C447                             ; $C540: 20 47 C4
  BCC $C55C                             ; $C543: 90 17
  LDA #$00                              ; $C545: A9 00
  STA $12                               ; $C547: 85 12
  JSR $D6CC                             ; $C549: 20 CC D6
  LDX $0509                             ; $C54C: AE 09 05
  DEC $0614,X                           ; $C54F: DE 14 06
  LDA $0614,X                           ; $C552: BD 14 06
  CMP #$0F                              ; $C555: C9 0F
  BNE $C55C                             ; $C557: D0 03
  DEC $0614,X                           ; $C559: DE 14 06
Loc_C55C:
  LDA $81                               ; $C55C: A5 81
  ASL                                   ; $C55E: 0A
  ASL                                   ; $C55F: 0A
  BPL $C59F                             ; $C560: 10 3D
  LDY $0509                             ; $C562: AC 09 05
  LDA $0600,Y                           ; $C565: B9 00 06
  STA $00                               ; $C568: 85 00
  LDA $0614,Y                           ; $C56A: B9 14 06
  CLC                                   ; $C56D: 18
  ADC #$01                              ; $C56E: 69 01
  CMP #$14                              ; $C570: C9 14
  BCS $C59F                             ; $C572: B0 2B
  CMP #$0F                              ; $C574: C9 0F
  BNE $C57B                             ; $C576: D0 03
  CLC                                   ; $C578: 18
  ADC #$01                              ; $C579: 69 01
Loc_C57B:
  STA $01                               ; $C57B: 85 01
  JSR $D6B6                             ; $C57D: 20 B6 D6
  TYA                                   ; $C580: 98
  BPL $C59F                             ; $C581: 10 1C
  JSR $C447                             ; $C583: 20 47 C4
  BCC $C59F                             ; $C586: 90 17
  LDA #$00                              ; $C588: A9 00
  STA $12                               ; $C58A: 85 12
  JSR $D6CC                             ; $C58C: 20 CC D6
  LDX $0509                             ; $C58F: AE 09 05
  INC $0614,X                           ; $C592: FE 14 06
  LDA $0614,X                           ; $C595: BD 14 06
  CMP #$0F                              ; $C598: C9 0F
  BNE $C59F                             ; $C59A: D0 03
  INC $0614,X                           ; $C59C: FE 14 06
Loc_C59F:
  RTS                                   ; $C59F: 60
Loc_C5A0:
  JSR $DB03                             ; $C5A0: 20 03 DB
  JSR $DA83                             ; $C5A3: 20 83 DA
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
  JSR $EAA5                             ; $C5BA: 20 A5 EA
  LDY $00                               ; $C5BD: A4 00
  LDA $C606,Y                           ; $C5BF: B9 06 C6
  CLC                                   ; $C5C2: 18
  ADC $050C                             ; $C5C3: 6D 0C 05
  STA $050C                             ; $C5C6: 8D 0C 05
  CMP $C613,Y                           ; $C5C9: D9 13 C6
  BCC $C5D4                             ; $C5CC: 90 06
  LDA $C613,Y                           ; $C5CE: B9 13 C6
  STA $050C                             ; $C5D1: 8D 0C 05
Loc_C5D4:
  JSR $DAC3                             ; $C5D4: 20 C3 DA
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
  JSR $EAA5                             ; $C5EB: 20 A5 EA
  LDY $00                               ; $C5EE: A4 00
  LDA $C606,Y                           ; $C5F0: B9 06 C6
  CLC                                   ; $C5F3: 18
  ADC $050D                             ; $C5F4: 6D 0D 05
  STA $050D                             ; $C5F7: 8D 0D 05
  CMP $C613,Y                           ; $C5FA: D9 13 C6
  BCC $C605                             ; $C5FD: 90 06
  LDA $C613,Y                           ; $C5FF: B9 13 C6
  STA $050D                             ; $C602: 8D 0D 05
Loc_C605:
  RTS                                   ; $C605: 60
; --- Data Region ---
  .byte $0A,$10,$14,$18,$1C,$20,$23,$25,$28,$2A,$2A,$2A,$2A,$14,$1A,$20; $C606: 0A 10 14 18 1C 20 23 25 28 2A 2A 2A 2A 14 1A 20
  .byte $24,$2A,$2E,$33,$35,$3A,$3C       ; $C616: 24 2A 2E 33 35 3A 3C
Loc_C61D:
; --- Code Region ---
  NOP $3C3C,X                           ; $C61D: 3C 3C 3C
  LDA #$00                              ; $C620: A9 00
  STA $051A                             ; $C622: 8D 1A 05
  STA $051B                             ; $C625: 8D 1B 05
  STA $051E                             ; $C628: 8D 1E 05
Loc_C62B:
  TAY                                   ; $C62B: A8
  PHA                                   ; $C62C: 48
  LDA $0664,Y                           ; $C62D: B9 64 06
  CMP #$FF                              ; $C630: C9 FF
  BEQ $C650                             ; $C632: F0 1C
  JSR $F2D7                             ; $C634: 20 D7 F2
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
Loc_C650:
  PLA                                   ; $C650: 68
  CLC                                   ; $C651: 18
  ADC #$01                              ; $C652: 69 01
  CMP #$0A                              ; $C654: C9 0A
  BCC $C62B                             ; $C656: 90 D3
  LDA #$00                              ; $C658: A9 00
  STA $051C                             ; $C65A: 8D 1C 05
  STA $051D                             ; $C65D: 8D 1D 05
  STA $051F                             ; $C660: 8D 1F 05
Loc_C663:
  TAY                                   ; $C663: A8
  PHA                                   ; $C664: 48
  LDA $066E,Y                           ; $C665: B9 6E 06
  CMP #$FF                              ; $C668: C9 FF
  BEQ $C688                             ; $C66A: F0 1C
  JSR $F2D7                             ; $C66C: 20 D7 F2
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
Loc_C688:
  PLA                                   ; $C688: 68
  CLC                                   ; $C689: 18
  ADC #$01                              ; $C68A: 69 01
  CMP #$0A                              ; $C68C: C9 0A
  BCC $C663                             ; $C68E: 90 D3
  RTS                                   ; $C690: 60
Loc_C691:  ; (dispatch callback target)
  LDA $0501                             ; $C691: AD 01 05
  JSR $EADE                             ; $C694: 20 DE EA
; --- Data Region ---
  .byte $9F,$C6,$AC,$C6,$B9,$C6,$BC,$C6   ; $C697: 9F C6 AC C6 B9 C6 BC C6
Loc_C69F:  ; (dispatch callback target)
; --- Code Region ---
  LDA $0514                             ; $C69F: AD 14 05
  STA $10                               ; $C6A2: 85 10
  LDA #$01                              ; $C6A4: A9 01
  STA $0470                             ; $C6A6: 8D 70 04
Loc_C6A9:  ; (dispatch callback target)
  JMP $C6EA                             ; $C6A9: 4C EA C6
Loc_C6AC:  ; (dispatch callback target)
  LDA $0516                             ; $C6AC: AD 16 05
  STA $10                               ; $C6AF: 85 10
  LDA #$02                              ; $C6B1: A9 02
  STA $0470                             ; $C6B3: 8D 70 04
  JMP $C6EA                             ; $C6B6: 4C EA C6
Loc_C6B9:  ; (dispatch callback target)
  JMP $A20C                             ; $C6B9: 4C 0C A2
Loc_C6BC:  ; (dispatch callback target)
  JSR $DF27                             ; $C6BC: 20 27 DF
  BCC $C6DF                             ; $C6BF: 90 1E
  JSR $DC63                             ; $C6C1: 20 63 DC
  LDA $81                               ; $C6C4: A5 81
  AND #$01                              ; $C6C6: 29 01
  BEQ $C6DF                             ; $C6C8: F0 15
  LDA $042D                             ; $C6CA: AD 2D 04
  CMP #$FF                              ; $C6CD: C9 FF
  BNE $C6E0                             ; $C6CF: D0 0F
  JSR $E57F                             ; $C6D1: 20 7F E5
  LDA #$1D                              ; $C6D4: A9 1D
  JSR $E673                             ; $C6D6: 20 73 E6
  LDA $0470                             ; $C6D9: AD 70 04
  STA $0501                             ; $C6DC: 8D 01 05
Loc_C6DF:
  RTS                                   ; $C6DF: 60
Loc_C6E0:
  LDA #$FF                              ; $C6E0: A9 FF
  STA $042D                             ; $C6E2: 8D 2D 04
  LDA #$4B                              ; $C6E5: A9 4B
  JMP $F293                             ; $C6E7: 4C 93 F2
Loc_C6EA:
  LDY #$00                              ; $C6EA: A0 00
  LDA $10                               ; $C6EC: A5 10
  CMP $0560                             ; $C6EE: CD 60 05
  BEQ $C6F5                             ; $C6F1: F0 02
  LDY #$01                              ; $C6F3: A0 01
Loc_C6F5:
  LDA $052E,Y                           ; $C6F5: B9 2E 05
  STA $11                               ; $C6F8: 85 11
  LDA $052C,Y                           ; $C6FA: B9 2C 05
  STA $12                               ; $C6FD: 85 12
  LDA $10                               ; $C6FF: A5 10
  STA $042C                             ; $C701: 8D 2C 04
  JSR $C75B                             ; $C704: 20 5B C7
  CPY #$FF                              ; $C707: C0 FF
  BEQ $C712                             ; $C709: F0 07
  LDA $6FA1,Y                           ; $C70B: B9 A1 6F
  CMP #$FF                              ; $C70E: C9 FF
  BEQ $C716                             ; $C710: F0 04
Loc_C712:
  INC $0501                             ; $C712: EE 01 05
  RTS                                   ; $C715: 60
Loc_C716:
  LDA $042C                             ; $C716: AD 2C 04
  JSR $F2D7                             ; $C719: 20 D7 F2
  LDY #$0B                              ; $C71C: A0 0B
  LDA ($00),Y                           ; $C71E: B1 00
  AND #$F0                              ; $C720: 29 F0
  CMP $12                               ; $C722: C5 12
  BEQ $C712                             ; $C724: F0 EC
  LDY #$01                              ; $C726: A0 01
  LDA ($00),Y                           ; $C728: B1 00
  SEC                                   ; $C72A: 38
  SBC $11                               ; $C72B: E5 11
  STA $042F                             ; $C72D: 8D 2F 04
  LDA #$00                              ; $C730: A9 00
  STA $042D                             ; $C732: 8D 2D 04
  STA $0430                             ; $C735: 8D 30 04
  STA $0431                             ; $C738: 8D 31 04
  LDY #$28                              ; $C73B: A0 28
  JSR $EE07                             ; $C73D: 20 07 EE
; --- Data Region ---
  .byte $18,$A0,$A9,$03,$8D,$01,$05,$20,$7F,$E5,$A9,$7B,$20,$8B,$E6,$A9; $C740: 18 A0 A9 03 8D 01 05 20 7F E5 A9 7B 20 8B E6 A9
  .byte $4A,$AC,$2F,$04,$D0,$02,$A9,$4D   ; $C750: 4A AC 2F 04 D0 02 A9 4D
Loc_C758:
; --- Code Region ---
  JMP $F293                             ; $C758: 4C 93 F2
Loc_C75B:
  LDY #$13                              ; $C75B: A0 13
Loc_C75D:
  CMP $0664,Y                           ; $C75D: D9 64 06
  BEQ $C765                             ; $C760: F0 03
  DEY                                   ; $C762: 88
  BPL $C75D                             ; $C763: 10 F8
Loc_C765:
  RTS                                   ; $C765: 60
Loc_C766:
  JSR $DB03                             ; $C766: 20 03 DB
  LDA $0514                             ; $C769: AD 14 05
  JSR $C75B                             ; $C76C: 20 5B C7
  LDA $0515                             ; $C76F: AD 15 05
  JSR $C782                             ; $C772: 20 82 C7
  LDA $0516                             ; $C775: AD 16 05
  JSR $C75B                             ; $C778: 20 5B C7
  LDA $0517                             ; $C77B: AD 17 05
  JSR $C782                             ; $C77E: 20 82 C7
  RTS                                   ; $C781: 60
Loc_C782:
  AND #$07                              ; $C782: 29 07
  JSR $EADE                             ; $C784: 20 DE EA
; --- Data Region ---
  .byte $97,$C7,$98,$C7,$99,$C7,$DB,$C7,$1F,$C8,$1F,$C8,$1F,$C8,$1F,$C8; $C787: 97 C7 98 C7 99 C7 DB C7 1F C8 1F C8 1F C8 1F C8
Loc_C797:  ; (dispatch callback target)
; --- Code Region ---
  RTS                                   ; $C797: 60
Loc_C798:  ; (dispatch callback target)
  RTS                                   ; $C798: 60
Loc_C799:  ; (dispatch callback target)
  TYA                                   ; $C799: 98
  PHA                                   ; $C79A: 48
  LDA $0664,Y                           ; $C79B: B9 64 06
  STA $0B                               ; $C79E: 85 0B
  LDA $0514                             ; $C7A0: AD 14 05
  CMP $0664,Y                           ; $C7A3: D9 64 06
  BNE $C7AB                             ; $C7A6: D0 03
  LDA $0516                             ; $C7A8: AD 16 05
Loc_C7AB:
  STA $0A                               ; $C7AB: 85 0A
  LDY #$2E                              ; $C7AD: A0 2E
  JSR $EE07                             ; $C7AF: 20 07 EE
; --- Data Region ---
  .byte $09,$A0,$68,$A8,$98,$48,$B9,$64,$06,$20,$D7,$F2,$A0,$0B,$B1,$00; $C7B2: 09 A0 68 A8 98 48 B9 64 06 20 D7 F2 A0 0B B1 00
  .byte $09,$03,$91,$00,$68,$A8,$B9,$28,$06,$10,$03,$4C,$D0,$C7; $C7C2: 09 03 91 00 68 A8 B9 28 06 10 03 4C D0 C7
Loc_C7D0:
; --- Code Region ---
  STY $0000                             ; $C7D0: 8C 00 00
  LDY #$28                              ; $C7D3: A0 28
  JSR $EE07                             ; $C7D5: 20 07 EE
; --- Data Region ---
  .byte $2A,$A0,$60,$B9,$28,$06,$10,$19,$A2,$00; $C7D8: 2A A0 60 B9 28 06 10 19 A2 00
Loc_C7E2:
; --- Code Region ---
  LDA $6F47,X                           ; $C7E2: BD 47 6F
  CMP #$FF                              ; $C7E5: C9 FF
  BEQ $C7ED                             ; $C7E7: F0 04
  INX                                   ; $C7E9: E8
  JMP $C7E2                             ; $C7EA: 4C E2 C7
Loc_C7ED:
  LDA $0664,Y                           ; $C7ED: B9 64 06
  STA $6F47,X                           ; $C7F0: 9D 47 6F
  INC $0520                             ; $C7F3: EE 20 05
  JMP $C80F                             ; $C7F6: 4C 0F C8
Loc_C7F9:
  LDX #$00                              ; $C7F9: A2 00
Loc_C7FB:
  LDA $6F5B,X                           ; $C7FB: BD 5B 6F
  CMP #$FF                              ; $C7FE: C9 FF
  BEQ $C806                             ; $C800: F0 04
  INX                                   ; $C802: E8
  JMP $C7FB                             ; $C803: 4C FB C7
Loc_C806:
  LDA $0664,Y                           ; $C806: B9 64 06
  STA $6F5B,X                           ; $C809: 9D 5B 6F
  INC $0521                             ; $C80C: EE 21 05
Loc_C80F:
  STA $20                               ; $C80F: 85 20
  STY $12                               ; $C811: 84 12
  LDY #$2A                              ; $C813: A0 2A
  JSR $EE07                             ; $C815: 20 07 EE
; --- Data Region ---
  .byte $0C,$A0,$A4,$12,$4C,$D0,$C7       ; $C818: 0C A0 A4 12 4C D0 C7
Loc_C81F:  ; (dispatch callback target)
; --- Code Region ---
  JSR $C886                             ; $C81F: 20 86 C8
  LDA $0628,Y                           ; $C822: B9 28 06
  EOR #$80                              ; $C825: 49 80
  STA $0628,Y                           ; $C827: 99 28 06
  LDA #$FF                              ; $C82A: A9 FF
  CPY $04D8                             ; $C82C: CC D8 04
  BNE $C834                             ; $C82F: D0 03
  STA $04D8                             ; $C831: 8D D8 04
Loc_C834:
  CPY $04DC                             ; $C834: CC DC 04
  BNE $C83C                             ; $C837: D0 03
  STA $04DC                             ; $C839: 8D DC 04
Loc_C83C:
  LDA $6FA1,Y                           ; $C83C: B9 A1 6F
  CMP #$FF                              ; $C83F: C9 FF
  BNE $C84B                             ; $C841: D0 08
  LDA #$04                              ; $C843: A9 04
  STA $6FA1,Y                           ; $C845: 99 A1 6F
  JMP $C850                             ; $C848: 4C 50 C8
Loc_C84B:
  LDA #$FF                              ; $C84B: A9 FF
  STA $6FA1,Y                           ; $C84D: 99 A1 6F
Loc_C850:
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
  BPL $C86D                             ; $C869: 10 02
  LDX $11                               ; $C86B: A6 11
Loc_C86D:
  TXA                                   ; $C86D: 8A
  JSR $F368                             ; $C86E: 20 68 F3
  LDY #$00                              ; $C871: A0 00
  LDA ($00),Y                           ; $C873: B1 00
  STA $30                               ; $C875: 85 30
  LDY $12                               ; $C877: A4 12
  LDA $0664,Y                           ; $C879: B9 64 06
  STA $31                               ; $C87C: 85 31
  LDY #$2A                              ; $C87E: A0 2A
  JSR $EE07                             ; $C880: 20 07 EE
; --- Data Region ---
  .byte $06,$A0,$60                       ; $C883: 06 A0 60
Loc_C886:
; --- Code Region ---
  TYA                                   ; $C886: 98
  TAX                                   ; $C887: AA
  PHA                                   ; $C888: 48
  LDA $0628,X                           ; $C889: BD 28 06
  BMI $C8D6                             ; $C88C: 30 48
  DEC $051E                             ; $C88E: CE 1E 05
  LDA $0664,X                           ; $C891: BD 64 06
  JSR $F2D7                             ; $C894: 20 D7 F2
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
  BCS $C8BF                             ; $C8B5: B0 08
  LDA #$00                              ; $C8B7: A9 00
  STA $051A                             ; $C8B9: 8D 1A 05
  STA $051B                             ; $C8BC: 8D 1B 05
Loc_C8BF:
  INC $051F                             ; $C8BF: EE 1F 05
  LDA $051C                             ; $C8C2: AD 1C 05
  CLC                                   ; $C8C5: 18
  ADC $02                               ; $C8C6: 65 02
  STA $051C                             ; $C8C8: 8D 1C 05
  LDA $051D                             ; $C8CB: AD 1D 05
  ADC $03                               ; $C8CE: 65 03
  STA $051D                             ; $C8D0: 8D 1D 05
  JMP $C91B                             ; $C8D3: 4C 1B C9
Loc_C8D6:
  DEC $051F                             ; $C8D6: CE 1F 05
  LDA $0664,X                           ; $C8D9: BD 64 06
  JSR $F2D7                             ; $C8DC: 20 D7 F2
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
  BCS $C907                             ; $C8FD: B0 08
  LDA #$00                              ; $C8FF: A9 00
Loc_C901:  ; (dispatch callback target)
  STA $051C                             ; $C901: 8D 1C 05
  STA $051D                             ; $C904: 8D 1D 05
Loc_C907:
  INC $051E                             ; $C907: EE 1E 05
  LDA $051A                             ; $C90A: AD 1A 05
  CLC                                   ; $C90D: 18
  ADC $02                               ; $C90E: 65 02
  STA $051A                             ; $C910: 8D 1A 05
  LDA $051B                             ; $C913: AD 1B 05
  ADC $03                               ; $C916: 65 03
  STA $051B                             ; $C918: 8D 1B 05
Loc_C91B:
  PLA                                   ; $C91B: 68
  TAY                                   ; $C91C: A8
  RTS                                   ; $C91D: 60
Loc_C91E:
  LDX $0509                             ; $C91E: AE 09 05
  LDA $0628,X                           ; $C921: BD 28 06
  BMI $C95A                             ; $C924: 30 34
  DEC $051E                             ; $C926: CE 1E 05
  LDA $0664,X                           ; $C929: BD 64 06
  JSR $F2D7                             ; $C92C: 20 D7 F2
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
  BCS $C98B                             ; $C94D: B0 3C
  LDA #$00                              ; $C94F: A9 00
  STA $051A                             ; $C951: 8D 1A 05
  STA $051B                             ; $C954: 8D 1B 05
  JMP $C98B                             ; $C957: 4C 8B C9
Loc_C95A:
  DEC $051F                             ; $C95A: CE 1F 05
  LDA $0664,X                           ; $C95D: BD 64 06
  JSR $F2D7                             ; $C960: 20 D7 F2
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
  BCS $C98B                             ; $C981: B0 08
  LDA #$00                              ; $C983: A9 00
  STA $051C                             ; $C985: 8D 1C 05
  STA $051D                             ; $C988: 8D 1D 05
Loc_C98B:
  RTS                                   ; $C98B: 60
Loc_C98C:  ; (dispatch callback target)
  LDA $0501                             ; $C98C: AD 01 05
  JSR $EADE                             ; $C98F: 20 DE EA
; --- Data Region ---
  .byte $9E,$C9,$AD,$C9,$C3,$C9,$FE,$C9,$13,$CA,$2F,$CA; $C992: 9E C9 AD C9 C3 C9 FE C9 13 CA 2F CA
Loc_C99E:  ; (dispatch callback target)
; --- Code Region ---
  JSR $E57F                             ; $C99E: 20 7F E5
  LDA #$D5                              ; $C9A1: A9 D5
  JSR $F293                             ; $C9A3: 20 93 F2
  JSR $CAF8                             ; $C9A6: 20 F8 CA
  INC $0501                             ; $C9A9: EE 01 05
  RTS                                   ; $C9AC: 60
Loc_C9AD:  ; (dispatch callback target)
  JSR $DF27                             ; $C9AD: 20 27 DF
  BCC $C9C2                             ; $C9B0: 90 10
  LDA $007E                             ; $C9B2: AD 7E 00
  BNE $C9C2                             ; $C9B5: D0 0B
  INC $0501                             ; $C9B7: EE 01 05
  JSR $CA53                             ; $C9BA: 20 53 CA
  LDA #$04                              ; $C9BD: A9 04
  JSR $F28B                             ; $C9BF: 20 8B F2
Loc_C9C2:
  RTS                                   ; $C9C2: 60
Loc_C9C3:  ; (dispatch callback target)
  LDA $007E                             ; $C9C3: AD 7E 00
  BNE $C9C2                             ; $C9C6: D0 FA
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
Loc_C9E4:
  STA $044C,X                           ; $C9E4: 9D 4C 04
  DEX                                   ; $C9E7: CA
  BPL $C9E4                             ; $C9E8: 10 FA
  LDA #$00                              ; $C9EA: A9 00
  STA $8E                               ; $C9EC: 85 8E
  LDA #$50                              ; $C9EE: A9 50
  STA $90                               ; $C9F0: 85 90
  INC $0501                             ; $C9F2: EE 01 05
  JSR $CA41                             ; $C9F5: 20 41 CA
  LDA #$18                              ; $C9F8: A9 18
  JSR $E683                             ; $C9FA: 20 83 E6
  RTS                                   ; $C9FD: 60
Loc_C9FE:  ; (dispatch callback target)
  JSR $CC29                             ; $C9FE: 20 29 CC
  JSR $DF27                             ; $CA01: 20 27 DF
  BCC $CA12                             ; $CA04: 90 0C
  JSR $DC63                             ; $CA06: 20 63 DC
  LDA $81                               ; $CA09: A5 81
  AND #$01                              ; $CA0B: 29 01
  BEQ $CA12                             ; $CA0D: F0 03
  INC $0501                             ; $CA0F: EE 01 05
Loc_CA12:
  RTS                                   ; $CA12: 60
Loc_CA13:  ; (dispatch callback target)
  JSR $CC29                             ; $CA13: 20 29 CC
  JSR $CA51                             ; $CA16: 20 51 CA
  BCC $CA26                             ; $CA19: 90 0B
  LDA #$0F                              ; $CA1B: A9 0F
  STA $0500                             ; $CA1D: 8D 00 05
  LDA #$00                              ; $CA20: A9 00
  STA $0501                             ; $CA22: 8D 01 05
  RTS                                   ; $CA25: 60
Loc_CA26:
  INC $0501                             ; $CA26: EE 01 05
  LDA #$D5                              ; $CA29: A9 D5
  JSR $F293                             ; $CA2B: 20 93 F2
  RTS                                   ; $CA2E: 60
Loc_CA2F:  ; (dispatch callback target)
  JSR $CC29                             ; $CA2F: 20 29 CC
  JSR $DF27                             ; $CA32: 20 27 DF
  BCC $CA40                             ; $CA35: 90 09
  LDA $81                               ; $CA37: A5 81
  AND #$01                              ; $CA39: 29 01
  BEQ $CA40                             ; $CA3B: F0 03
  DEC $0501                             ; $CA3D: CE 01 05
Loc_CA40:
  RTS                                   ; $CA40: 60
Loc_CA41:
  LDA #$E0                              ; $CA41: A9 E0
  STA $0310                             ; $CA43: 8D 10 03
  LDA #$DB                              ; $CA46: A9 DB
  STA $0311                             ; $CA48: 8D 11 03
  LDA #$00                              ; $CA4B: A9 00
  STA $0300                             ; $CA4D: 8D 00 03
  RTS                                   ; $CA50: 60
Loc_CA51:
  SEC                                   ; $CA51: 38
  RTS                                   ; $CA52: 60
Loc_CA53:
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
Loc_CA70:
  LDA ($00),Y                           ; $CA70: B1 00
  STA $0380,X                           ; $CA72: 9D 80 03
  INX                                   ; $CA75: E8
  INY                                   ; $CA76: C8
  CPY #$0E                              ; $CA77: C0 0E
  BCC $CA70                             ; $CA79: 90 F5
  LDY #$00                              ; $CA7B: A0 00
Loc_CA7D:
  LDA ($02),Y                           ; $CA7D: B1 02
  STA $0380,X                           ; $CA7F: 9D 80 03
  INX                                   ; $CA82: E8
  INY                                   ; $CA83: C8
  CPY #$0F                              ; $CA84: C0 0F
  BCC $CA7D                             ; $CA86: 90 F5
  LDA $007E                             ; $CA88: AD 7E 00
  ORA #$04                              ; $CA8B: 09 04
  STA $007E                             ; $CA8D: 8D 7E 00
  RTS                                   ; $CA90: 60
; --- Data Region ---
  .byte $A1,$CA,$AF,$CA,$BD,$CA,$BD,$CA,$DA,$CA,$CB,$CA,$E9; $CA91: A1 CA AF CA BD CA BD CA DA CA CB CA E9
Loc_CA9E:
; --- Code Region ---
  DEX                                   ; $CA9E: CA
  SBC #$CA                              ; $CA9F: E9 CA
  NOP $25                               ; $CAA1: 04 25
  NOP                                   ; $CAA3: EA
  CPX #$E1                              ; $CAA4: E0 E1
  NOP #$E3                              ; $CAA6: E2 E3
  NOP $26                               ; $CAA8: 04 26
  ASL                                   ; $CAAA: 0A
  BEQ $CA9E                             ; $CAAB: F0 F1
  JAM                                   ; $CAAD: F2
  ISB ($04),Y                           ; $CAAE: F3 04
  AND $EA                               ; $CAB0: 25 EA
  CPX $E5                               ; $CAB2: E4 E5
  INC $E7                               ; $CAB4: E6 E7
  NOP $26                               ; $CAB6: 04 26
  ASL                                   ; $CAB8: 0A
  NOP $F5,X                             ; $CAB9: F4 F5
  INC $F7,X                             ; $CABB: F6 F7
  NOP $25                               ; $CABD: 04 25
  NOP                                   ; $CABF: EA
  CPX $EEED                             ; $CAC0: EC ED EE
  ISB $2604                             ; $CAC3: EF 04 26
  ASL                                   ; $CAC6: 0A
  NOP $FEFD,X                           ; $CAC7: FC FD FE
  INC $2504,X                           ; $CACA: FE 04 25
  SED                                   ; $CACD: F8
  INX                                   ; $CACE: E8
  SBC #$EA                              ; $CACF: E9 EA
  SBC #$04                              ; $CAD1: EB 04
  ROL $18                               ; $CAD3: 26 18
  SED                                   ; $CAD5: F8
  SBC $FBFA,Y                           ; $CAD6: F9 FA FB
  ISB $2504,X                           ; $CAD9: FF 04 25
  SED                                   ; $CADC: F8
  CPX $E5                               ; $CADD: E4 E5
  INC $E7                               ; $CADF: E6 E7
  NOP $26                               ; $CAE1: 04 26
  CLC                                   ; $CAE3: 18
  NOP $F5,X                             ; $CAE4: F4 F5
  INC $F7,X                             ; $CAE6: F6 F7
  ISB $2504,X                           ; $CAE8: FF 04 25
  SED                                   ; $CAEB: F8
  CPX $EEED                             ; $CAEC: EC ED EE
  ISB $2604                             ; $CAEF: EF 04 26
  CLC                                   ; $CAF2: 18
  NOP $FEFD,X                           ; $CAF3: FC FD FE
  INC $20FF,X                           ; $CAF6: FE FF 20
  ROR $ADCB                             ; $CAF9: 6E CB AD
  NOP                                   ; $CAFC: 1A
  ORA $8D                               ; $CAFD: 05 8D
  SRE $AD04                             ; $CAFF: 4F 04 AD
  SLO $8D05,Y                           ; $CB02: 1B 05 8D
  BVC $CB0B                             ; $CB05: 50 04
  LDA #$00                              ; $CB07: A9 00
  STA $044E                             ; $CB09: 8D 4E 04
  STA $0451                             ; $CB0C: 8D 51 04
  LDA $051C                             ; $CB0F: AD 1C 05
  STA $044C                             ; $CB12: 8D 4C 04
  LDA $051D                             ; $CB15: AD 1D 05
  STA $044D                             ; $CB18: 8D 4D 04
  LDA $051E                             ; $CB1B: AD 1E 05
  STA $0455                             ; $CB1E: 8D 55 04
  LDA $051F                             ; $CB21: AD 1F 05
  STA $0452                             ; $CB24: 8D 52 04
  LDA #$00                              ; $CB27: A9 00
  STA $0453                             ; $CB29: 8D 53 04
  STA $0454                             ; $CB2C: 8D 54 04
  STA $0456                             ; $CB2F: 8D 56 04
  STA $0457                             ; $CB32: 8D 57 04
  LDY #$00                              ; $CB35: A0 00
  LDX #$00                              ; $CB37: A2 00
Loc_CB39:
  LDA $6F47,Y                           ; $CB39: B9 47 6F
  CMP #$FF                              ; $CB3C: C9 FF
  BEQ $CB41                             ; $CB3E: F0 01
  INX                                   ; $CB40: E8
Loc_CB41:
  INY                                   ; $CB41: C8
  CPY #$14                              ; $CB42: C0 14
  BCC $CB39                             ; $CB44: 90 F3
  STX $045B                             ; $CB46: 8E 5B 04
  LDX #$00                              ; $CB49: A2 00
  STX $045C                             ; $CB4B: 8E 5C 04
  STX $045D                             ; $CB4E: 8E 5D 04
  LDY #$00                              ; $CB51: A0 00
  LDX #$00                              ; $CB53: A2 00
Loc_CB55:
  LDA $6F5B,Y                           ; $CB55: B9 5B 6F
  CMP #$FF                              ; $CB58: C9 FF
  BEQ $CB5D                             ; $CB5A: F0 01
  INX                                   ; $CB5C: E8
Loc_CB5D:
  INY                                   ; $CB5D: C8
  CPY #$14                              ; $CB5E: C0 14
  BCC $CB55                             ; $CB60: 90 F3
  STX $0458                             ; $CB62: 8E 58 04
  LDX #$00                              ; $CB65: A2 00
  STX $0459                             ; $CB67: 8E 59 04
  STX $045A                             ; $CB6A: 8E 5A 04
  RTS                                   ; $CB6D: 60
; --- Data Region ---
  .byte $A9,$00,$85,$0A,$85,$0B,$85,$0C   ; $CB6E: A9 00 85 0A 85 0B 85 0C
Loc_CB76:
; --- Code Region ---
  TAY                                   ; $CB76: A8
  PHA                                   ; $CB77: 48
  LDA $0628,Y                           ; $CB78: B9 28 06
  BMI $CB9B                             ; $CB7B: 30 1E
  LDA $0664,Y                           ; $CB7D: B9 64 06
  CMP #$FF                              ; $CB80: C9 FF
  BEQ $CB9B                             ; $CB82: F0 17
  JSR $F2D7                             ; $CB84: 20 D7 F2
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
Loc_CB9B:
  PLA                                   ; $CB9B: 68
  CLC                                   ; $CB9C: 18
  ADC #$01                              ; $CB9D: 69 01
  CMP #$14                              ; $CB9F: C9 14
  BCC $CB76                             ; $CBA1: 90 D3
  LDA $051A                             ; $CBA3: AD 1A 05
  SEC                                   ; $CBA6: 38
  SBC $0A                               ; $CBA7: E5 0A
  STA $051A                             ; $CBA9: 8D 1A 05
  LDA $051B                             ; $CBAC: AD 1B 05
  SBC $0B                               ; $CBAF: E5 0B
  STA $051B                             ; $CBB1: 8D 1B 05
  BCS $CBBE                             ; $CBB4: B0 08
  LDA #$00                              ; $CBB6: A9 00
  STA $051A                             ; $CBB8: 8D 1A 05
  STA $051B                             ; $CBBB: 8D 1B 05
Loc_CBBE:
  LDA $051E                             ; $CBBE: AD 1E 05
  SEC                                   ; $CBC1: 38
  SBC $0C                               ; $CBC2: E5 0C
  BCS $CBC8                             ; $CBC4: B0 02
  LDA #$00                              ; $CBC6: A9 00
Loc_CBC8:
  STA $051E                             ; $CBC8: 8D 1E 05
  LDA #$00                              ; $CBCB: A9 00
  STA $0A                               ; $CBCD: 85 0A
  STA $0B                               ; $CBCF: 85 0B
  STA $0C                               ; $CBD1: 85 0C
Loc_CBD3:
  TAY                                   ; $CBD3: A8
  PHA                                   ; $CBD4: 48
  LDA $0628,Y                           ; $CBD5: B9 28 06
  BPL $CBF8                             ; $CBD8: 10 1E
  LDA $0664,Y                           ; $CBDA: B9 64 06
  CMP #$FF                              ; $CBDD: C9 FF
  BEQ $CBF8                             ; $CBDF: F0 17
  JSR $F2D7                             ; $CBE1: 20 D7 F2
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
Loc_CBF8:
  PLA                                   ; $CBF8: 68
  CLC                                   ; $CBF9: 18
  ADC #$01                              ; $CBFA: 69 01
  CMP #$14                              ; $CBFC: C9 14
  BCC $CBD3                             ; $CBFE: 90 D3
  LDA $051C                             ; $CC00: AD 1C 05
  SEC                                   ; $CC03: 38
  SBC $0A                               ; $CC04: E5 0A
  STA $051C                             ; $CC06: 8D 1C 05
  LDA $051D                             ; $CC09: AD 1D 05
  SBC $0B                               ; $CC0C: E5 0B
  STA $051D                             ; $CC0E: 8D 1D 05
  BCS $CC1B                             ; $CC11: B0 08
  LDA #$00                              ; $CC13: A9 00
  STA $051C                             ; $CC15: 8D 1C 05
  STA $051D                             ; $CC18: 8D 1D 05
Loc_CC1B:
  LDA $051F                             ; $CC1B: AD 1F 05
  SEC                                   ; $CC1E: 38
  SBC $0C                               ; $CC1F: E5 0C
  BCS $CC25                             ; $CC21: B0 02
  LDA #$00                              ; $CC23: A9 00
Loc_CC25:
  STA $051F                             ; $CC25: 8D 1F 05
  RTS                                   ; $CC28: 60
Loc_CC29:
  LDY #$31                              ; $CC29: A0 31
  JSR $F25F                             ; $CC2B: 20 5F F2
  LDA #$00                              ; $CC2E: A9 00
  STA $0A                               ; $CC30: 85 0A
  LDA $005E                             ; $CC32: AD 5E 00
  AND #$01                              ; $CC35: 29 01
  BNE $CC3F                             ; $CC37: D0 06
  JSR $CC45                             ; $CC39: 20 45 CC
  JMP $CC5A                             ; $CC3C: 4C 5A CC
Loc_CC3F:
  JSR $CC5A                             ; $CC3F: 20 5A CC
  JMP $CC45                             ; $CC42: 4C 45 CC
Loc_CC45:
  LDA #$40                              ; $CC45: A9 40
  STA $0B                               ; $CC47: 85 0B
  LDA #$00                              ; $CC49: A9 00
  STA $0C                               ; $CC4B: 85 0C
  LDA $0507                             ; $CC4D: AD 07 05
  LSR                                   ; $CC50: 4A
  LSR                                   ; $CC51: 4A
  LSR                                   ; $CC52: 4A
  LSR                                   ; $CC53: 4A
  JSR $CC6D                             ; $CC54: 20 6D CC
  STA $AF                               ; $CC57: 85 AF
  RTS                                   ; $CC59: 60
Loc_CC5A:
  LDA #$80                              ; $CC5A: A9 80
  STA $0B                               ; $CC5C: 85 0B
  LDA #$70                              ; $CC5E: A9 70
  STA $0C                               ; $CC60: 85 0C
  LDA $0507                             ; $CC62: AD 07 05
  AND #$0F                              ; $CC65: 29 0F
  JSR $CC6D                             ; $CC67: 20 6D CC
  STA $B0                               ; $CC6A: 85 B0
  RTS                                   ; $CC6C: 60
Loc_CC6D:
  JSR $F368                             ; $CC6D: 20 68 F3
  LDY #$00                              ; $CC70: A0 00
  LDA ($00),Y                           ; $CC72: B1 00
  STA $00                               ; $CC74: 85 00
  LDA #$00                              ; $CC76: A9 00
  STA $01                               ; $CC78: 85 01
  STA $02                               ; $CC7A: 85 02
  LDA #$0D                              ; $CC7C: A9 0D
  STA $03                               ; $CC7E: 85 03
  JSR $EBE9                             ; $CC80: 20 E9 EB
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
  JSR $CCDF                             ; $CC95: 20 DF CC
  LDA #$00                              ; $CC98: A9 00
Loc_CC9A:
  PHA                                   ; $CC9A: 48
  JSR $CCAA                             ; $CC9B: 20 AA CC
  PLA                                   ; $CC9E: 68
  INC $0A                               ; $CC9F: E6 0A
  CLC                                   ; $CCA1: 18
  ADC #$01                              ; $CCA2: 69 01
  CMP #$0C                              ; $CCA4: C9 0C
  BCC $CC9A                             ; $CCA6: 90 F2
  PLA                                   ; $CCA8: 68
  RTS                                   ; $CCA9: 60
Loc_CCAA:
  LDY #$00                              ; $CCAA: A0 00
  LDA ($06),Y                           ; $CCAC: B1 06
  JSR $CCDF                             ; $CCAE: 20 DF CC
  CMP #$FF                              ; $CCB1: C9 FF
  BEQ $CCDE                             ; $CCB3: F0 29
  LDY $0A                               ; $CCB5: A4 0A
  LDX $007C                             ; $CCB7: AE 7C 00
  CLC                                   ; $CCBA: 18
  ADC $0B                               ; $CCBB: 65 0B
  STA $0201,X                           ; $CCBD: 9D 01 02
  LDA $CCE6,Y                           ; $CCC0: B9 E6 CC
  SEC                                   ; $CCC3: 38
Loc_CCC4:
  SBC #$01                              ; $CCC4: E9 01
  STA $0200,X                           ; $CCC6: 9D 00 02
  LDA $CCFE,Y                           ; $CCC9: B9 FE CC
  CLC                                   ; $CCCC: 18
  ADC $0C                               ; $CCCD: 65 0C
  STA $0203,X                           ; $CCCF: 9D 03 02
  LDA #$00                              ; $CCD2: A9 00
  STA $0202,X                           ; $CCD4: 9D 02 02
  INX                                   ; $CCD7: E8
  INX                                   ; $CCD8: E8
  INX                                   ; $CCD9: E8
Loc_CCDA:
  INX                                   ; $CCDA: E8
  STX $007C                             ; $CCDB: 8E 7C 00
Loc_CCDE:
  RTS                                   ; $CCDE: 60
Loc_CCDF:
  INC $06                               ; $CCDF: E6 06
  BNE $CCE5                             ; $CCE1: D0 02
  INC $07                               ; $CCE3: E6 07
Loc_CCE5:
  RTS                                   ; $CCE5: 60
; --- Data Region ---
  .byte $10,$10,$18,$18,$10,$10,$18,$18,$10,$10,$18,$18,$10,$10,$18,$18; $CCE6: 10 10 18 18 10 10 18 18 10 10 18 18 10 10 18 18
  .byte $10,$10                           ; $CCF6: 10 10
Loc_CCF8:
; --- Code Region ---
  CLC                                   ; $CCF8: 18
  CLC                                   ; $CCF9: 18
  BPL $CD0C                             ; $CCFA: 10 10
Loc_CCFC:
  CLC                                   ; $CCFC: 18
  CLC                                   ; $CCFD: 18
  PLP                                   ; $CCFE: 28
  BMI $CD29                             ; $CCFF: 30 28
  BMI $CD3B                             ; $CD01: 30 38
  RTI                                   ; $CD03: 40
Loc_CD04:
  SEC                                   ; $CD04: 38
  RTI                                   ; $CD05: 40
; --- Data Region ---
  .byte $48,$50                           ; $CD06: 48 50
Loc_CD08:
; --- Code Region ---
  PHA                                   ; $CD08: 48
  BVC $CD33                             ; $CD09: 50 28
  BMI $CD35                             ; $CD0B: 30 28
  BMI $CD47                             ; $CD0D: 30 38
  RTI                                   ; $CD0F: 40
; --- Data Region ---
  .byte $38,$40,$48,$50,$48,$50           ; $CD10: 38 40 48 50 48 50
Loc_CD16:  ; (dispatch callback target)
; --- Code Region ---
  LDA $0501                             ; $CD16: AD 01 05
  JSR $EADE                             ; $CD19: 20 DE EA
; --- Data Region ---
  .byte $2A,$CD,$52,$CD,$F2,$CD,$56,$CE,$76,$CE,$9E,$CE,$09,$CF; $CD1C: 2A CD 52 CD F2 CD 56 CE 76 CE 9E CE 09 CF
Loc_CD2A:  ; (dispatch callback target)
; --- Code Region ---
  JSR $CC29                             ; $CD2A: 20 29 CC
  JSR $D0E1                             ; $CD2D: 20 E1 D0
  LDA #$FF                              ; $CD30: A9 FF
  STA $042C,X                           ; $CD32: 9D 2C 04
Loc_CD35:
  TXA                                   ; $CD35: 8A
  BNE $CD46                             ; $CD36: D0 0E
Loc_CD38:
  LDA $050B                             ; $CD38: AD 0B 05
Loc_CD3B:
  AND #$0F                              ; $CD3B: 29 0F
  STA $0501                             ; $CD3D: 8D 01 05
  LDA #$0F                              ; $CD40: A9 0F
  STA $0500                             ; $CD42: 8D 00 05
  RTS                                   ; $CD45: 60
Loc_CD46:
  LDA #$DC                              ; $CD46: A9 DC
  JSR $F293                             ; $CD48: 20 93 F2
  JSR $D0C3                             ; $CD4B: 20 C3 D0
  INC $0501                             ; $CD4E: EE 01 05
Loc_CD51:
  RTS                                   ; $CD51: 60
Loc_CD52:  ; (dispatch callback target)
  JSR $CC29                             ; $CD52: 20 29 CC
  JSR $DF27                             ; $CD55: 20 27 DF
  BCC $CD63                             ; $CD58: 90 09
  JSR $DC63                             ; $CD5A: 20 63 DC
Loc_CD5D:
  LDA $81                               ; $CD5D: A5 81
  AND #$01                              ; $CD5F: 29 01
  BNE $CD64                             ; $CD61: D0 01
Loc_CD63:
  RTS                                   ; $CD63: 60
Loc_CD64:
  INC $0501                             ; $CD64: EE 01 05
  LDA #$00                              ; $CD67: A9 00
  STA $0424                             ; $CD69: 8D 24 04
  STA $0425                             ; $CD6C: 8D 25 04
  LDA $050B                             ; $CD6F: AD 0B 05
  AND #$10                              ; $CD72: 29 10
  ASL                                   ; $CD74: 0A
  ASL                                   ; $CD75: 0A
  ASL                                   ; $CD76: 0A
  STA $0504                             ; $CD77: 8D 04 05
  JSR $BB84                             ; $CD7A: 20 84 BB
  INC $050A                             ; $CD7D: EE 0A 05
  LDA $050A                             ; $CD80: AD 0A 05
  BEQ $CD9C                             ; $CD83: F0 17
  TAY                                   ; $CD85: A8
  LDA #$1E                              ; $CD86: A9 1E
  STA $042C,Y                           ; $CD88: 99 2C 04
  DEY                                   ; $CD8B: 88
Loc_CD8C:
  LDA $0550,Y                           ; $CD8C: B9 50 05
  CMP #$0A                              ; $CD8F: C9 0A
  BCS $CD99                             ; $CD91: B0 06
  LDA #$D7                              ; $CD93: A9 D7
  JSR $F283                             ; $CD95: 20 83 F2
  RTS                                   ; $CD98: 60
Loc_CD99:
  DEY                                   ; $CD99: 88
  BPL $CD8C                             ; $CD9A: 10 F0
Loc_CD9C:
  LDA $0507                             ; $CD9C: AD 07 05
  LDY $050B                             ; $CD9F: AC 0B 05
  CPY #$02                              ; $CDA2: C0 02
  BEQ $CDAA                             ; $CDA4: F0 04
  LSR                                   ; $CDA6: 4A
  LSR                                   ; $CDA7: 4A
  LSR                                   ; $CDA8: 4A
  LSR                                   ; $CDA9: 4A
Loc_CDAA:
  AND #$0F                              ; $CDAA: 29 0F
  JSR $F368                             ; $CDAC: 20 68 F3
  LDY #$00                              ; $CDAF: A0 00
  LDA ($00),Y                           ; $CDB1: B1 00
  STA $03                               ; $CDB3: 85 03
  JSR $D0E1                             ; $CDB5: 20 E1 D0
  LDX #$00                              ; $CDB8: A2 00
Loc_CDBA:
  LDA $042C,X                           ; $CDBA: BD 2C 04
  CMP #$FE                              ; $CDBD: C9 FE
  BCS $CDDB                             ; $CDBF: B0 1A
  CMP $03                               ; $CDC1: C5 03
  BEQ $CDE3                             ; $CDC3: F0 1E
  JSR $F2D7                             ; $CDC5: 20 D7 F2
  LDY #$0B                              ; $CDC8: A0 0B
  LDA ($00),Y                           ; $CDCA: B1 00
  AND #$FC                              ; $CDCC: 29 FC
  STA ($00),Y                           ; $CDCE: 91 00
  LDY #$05                              ; $CDD0: A0 05
  LDA $050E                             ; $CDD2: AD 0E 05
  STA ($00),Y                           ; $CDD5: 91 00
  INX                                   ; $CDD7: E8
  JMP $CDBA                             ; $CDD8: 4C BA CD
Loc_CDDB:
  LDA #$00                              ; $CDDB: A9 00
  STA $0501                             ; $CDDD: 8D 01 05
  JMP $CD38                             ; $CDE0: 4C 38 CD
Loc_CDE3:
  JSR $F2D7                             ; $CDE3: 20 D7 F2
  LDY #$0B                              ; $CDE6: A0 0B
  LDA ($00),Y                           ; $CDE8: B1 00
  ORA #$03                              ; $CDEA: 09 03
  STA ($00),Y                           ; $CDEC: 91 00
  INX                                   ; $CDEE: E8
  JMP $CDBA                             ; $CDEF: 4C BA CD
Loc_CDF2:  ; (dispatch callback target)
  JSR $CC29                             ; $CDF2: 20 29 CC
  LDA $050A                             ; $CDF5: AD 0A 05
  ASL                                   ; $CDF8: 0A
  TAY                                   ; $CDF9: A8
  LDA $BA9F,Y                           ; $CDFA: B9 9F BA
  STA $10                               ; $CDFD: 85 10
  LDA $BAA0,Y                           ; $CDFF: B9 A0 BA
  STA $11                               ; $CE02: 85 11
  LDA #$00                              ; $CE04: A9 00
  STA $12                               ; $CE06: 85 12
  JSR $ED1E                             ; $CE08: 20 1E ED
  LDA #$6F                              ; $CE0B: A9 6F
  STA $10                               ; $CE0D: 85 10
  LDA #$BB                              ; $CE0F: A9 BB
  STA $11                               ; $CE11: 85 11
  LDA #$7F                              ; $CE13: A9 7F
  STA $00                               ; $CE15: 85 00
  LDA #$BB                              ; $CE17: A9 BB
  STA $01                               ; $CE19: 85 01
  LDA $12                               ; $CE1B: A5 12
  JSR $EDF5                             ; $CE1D: 20 F5 ED
  JSR $DF27                             ; $CE20: 20 27 DF
  BCC $CE55                             ; $CE23: 90 30
  LDA $81                               ; $CE25: A5 81
  AND #$01                              ; $CE27: 29 01
  BEQ $CE55                             ; $CE29: F0 2A
  LDY $12                               ; $CE2B: A4 12
  LDA $042C,Y                           ; $CE2D: B9 2C 04
  STA $0540                             ; $CE30: 8D 40 05
  STY $0541                             ; $CE33: 8C 41 05
  CMP #$1E                              ; $CE36: C9 1E
  BEQ $CE41                             ; $CE38: F0 07
  LDA $0550,Y                           ; $CE3A: B9 50 05
  CMP #$0A                              ; $CE3D: C9 0A
  BCS $CE55                             ; $CE3F: B0 14
Loc_CE41:
  INC $0501                             ; $CE41: EE 01 05
  LDA #$DD                              ; $CE44: A9 DD
  LDY $0540                             ; $CE46: AC 40 05
  CPY #$1E                              ; $CE49: C0 1E
  BNE $CE4F                             ; $CE4B: D0 02
  LDA #$E5                              ; $CE4D: A9 E5
Loc_CE4F:
  JSR $F283                             ; $CE4F: 20 83 F2
  JSR $D0C3                             ; $CE52: 20 C3 D0
Loc_CE55:
  RTS                                   ; $CE55: 60
Loc_CE56:  ; (dispatch callback target)
  JSR $CC29                             ; $CE56: 20 29 CC
  JSR $DF27                             ; $CE59: 20 27 DF
  BCC $CE75                             ; $CE5C: 90 17
  JSR $DC63                             ; $CE5E: 20 63 DC
  LDA $81                               ; $CE61: A5 81
  AND #$01                              ; $CE63: 29 01
  BEQ $CE75                             ; $CE65: F0 0E
  JSR $D0E1                             ; $CE67: 20 E1 D0
  STX $050A                             ; $CE6A: 8E 0A 05
  LDA #$DE                              ; $CE6D: A9 DE
  JSR $F28B                             ; $CE6F: 20 8B F2
  INC $0501                             ; $CE72: EE 01 05
Loc_CE75:
  RTS                                   ; $CE75: 60
Loc_CE76:  ; (dispatch callback target)
  JSR $CC29                             ; $CE76: 20 29 CC
  JSR $DF27                             ; $CE79: 20 27 DF
  BCC $CE9D                             ; $CE7C: 90 1F
  LDX $050A                             ; $CE7E: AE 0A 05
  LDA #$FF                              ; $CE81: A9 FF
  STA $042C,X                           ; $CE83: 9D 2C 04
  LDA #$E0                              ; $CE86: A9 E0
  STA $E6                               ; $CE88: 85 E6
  STA $E7                               ; $CE8A: 85 E7
  INC $0501                             ; $CE8C: EE 01 05
  LDA #$00                              ; $CE8F: A9 00
  STA $8E                               ; $CE91: 85 8E
  STA $90                               ; $CE93: 85 90
  LDA #$00                              ; $CE95: A9 00
  STA $0424                             ; $CE97: 8D 24 04
  STA $0425                             ; $CE9A: 8D 25 04
Loc_CE9D:
  RTS                                   ; $CE9D: 60
Loc_CE9E:  ; (dispatch callback target)
  LDA $050A                             ; $CE9E: AD 0A 05
  ASL                                   ; $CEA1: 0A
  TAY                                   ; $CEA2: A8
  LDA $CF5E,Y                           ; $CEA3: B9 5E CF
  STA $10                               ; $CEA6: 85 10
  LDA $CF5F,Y                           ; $CEA8: B9 5F CF
  STA $11                               ; $CEAB: 85 11
  LDA #$00                              ; $CEAD: A9 00
  STA $12                               ; $CEAF: 85 12
  JSR $ED23                             ; $CEB1: 20 23 ED
  LDA #$34                              ; $CEB4: A9 34
  STA $10                               ; $CEB6: 85 10
  LDA #$CF                              ; $CEB8: A9 CF
  STA $11                               ; $CEBA: 85 11
  LDA #$04                              ; $CEBC: A9 04
  STA $00                               ; $CEBE: 85 00
  LDA #$CF                              ; $CEC0: A9 CF
  STA $01                               ; $CEC2: 85 01
  LDA $12                               ; $CEC4: A5 12
  STA $0508                             ; $CEC6: 8D 08 05
  JSR $EDF5                             ; $CEC9: 20 F5 ED
  JSR $D167                             ; $CECC: 20 67 D1
  JSR $D1BC                             ; $CECF: 20 BC D1
  LDA $81                               ; $CED2: A5 81
  AND #$01                              ; $CED4: 29 01
  BEQ $CF03                             ; $CED6: F0 2B
  LDA $050A                             ; $CED8: AD 0A 05
  CMP $0508                             ; $CEDB: CD 08 05
  BNE $CF03                             ; $CEDE: D0 23
  LDY #$00                              ; $CEE0: A0 00
  LDX #$00                              ; $CEE2: A2 00
Loc_CEE4:
  LDA $0580,Y                           ; $CEE4: B9 80 05
  BMI $CEEA                             ; $CEE7: 30 01
  INX                                   ; $CEE9: E8
Loc_CEEA:
  INY                                   ; $CEEA: C8
  CPY #$14                              ; $CEEB: C0 14
  BCC $CEE4                             ; $CEED: 90 F5
  TXA                                   ; $CEEF: 8A
  BEQ $CF1A                             ; $CEF0: F0 28
  LDA #$D8                              ; $CEF2: A9 D8
  LDY $0540                             ; $CEF4: AC 40 05
  CPY #$1E                              ; $CEF7: C0 1E
  BNE $CEFD                             ; $CEF9: D0 02
  LDA #$E6                              ; $CEFB: A9 E6
Loc_CEFD:
  JSR $F283                             ; $CEFD: 20 83 F2
  INC $0501                             ; $CF00: EE 01 05
Loc_CF03:
  RTS                                   ; $CF03: 60
; --- Data Region ---
  .byte $00,$07                           ; $CF04: 00 07
Loc_CF06:
; --- Code Region ---
  BRK                                   ; $CF06: 00
  SED                                   ; $CF07: F8
  NOP #$20                              ; $CF08: 80 20
  LDY $20D1,X                           ; $CF0A: BC D1 20
Loc_CF0D:
  RLA $DF                               ; $CF0D: 27 DF
  BCC $CF33                             ; $CF0F: 90 22
  JSR $DC63                             ; $CF11: 20 63 DC
Loc_CF14:
  LDA $81                               ; $CF14: A5 81
  AND #$01                              ; $CF16: 29 01
  BEQ $CF33                             ; $CF18: F0 19
Loc_CF1A:
  LDA #$E1                              ; $CF1A: A9 E1
  STA $E6                               ; $CF1C: 85 E6
  STA $E7                               ; $CF1E: 85 E7
  LDA #$00                              ; $CF20: A9 00
  STA $8E                               ; $CF22: 85 8E
  LDA #$50                              ; $CF24: A9 50
  STA $90                               ; $CF26: 85 90
  LDA #$00                              ; $CF28: A9 00
  STA $0501                             ; $CF2A: 8D 01 05
  JSR $D1F9                             ; $CF2D: 20 F9 D1
  JMP $CD2A                             ; $CF30: 4C 2A CD
Loc_CF33:
  RTS                                   ; $CF33: 60
; --- Data Region ---
  .byte $16,$20,$16,$68,$16,$B0,$26,$20,$26,$68,$26,$B0,$36,$20,$36,$68; $CF34: 16 20 16 68 16 B0 26 20 26 68 26 B0 36 20 36 68
  .byte $36,$B0,$46,$20,$46,$68,$46,$B0,$56,$20,$56,$68,$56; $CF44: 36 B0 46 20 46 68 46 B0 56 20 56 68 56
Loc_CF51:
; --- Code Region ---
  BCS $CFB9                             ; $CF51: B0 66
  JSR $6866                             ; $CF53: 20 66 68
  ROR $B0                               ; $CF56: 66 B0
  ROR $20,X                             ; $CF58: 76 20
  ROR $68,X                             ; $CF5A: 76 68
  ROR $B0,X                             ; $CF5C: 76 B0
  LDA $B7D0,X                           ; $CF5E: BD D0 B7
  BNE $CF14                             ; $CF61: D0 B1
  BNE $CF0D                             ; $CF63: D0 A8
  BNE $CF06                             ; $CF65: D0 9F
  BNE $CEFF                             ; $CF67: D0 96
  BNE $CEF5                             ; $CF69: D0 8A
  BNE $CFEB                             ; $CF6B: D0 7E
  BNE $CFE1                             ; $CF6D: D0 72
  BNE $CFD4                             ; $CF6F: D0 63
  BNE $CFC7                             ; $CF71: D0 54
  BNE $CFBA                             ; $CF73: D0 45
  BNE $CFAA                             ; $CF75: D0 33
Loc_CF77:
  BNE $CF9A                             ; $CF77: D0 21
  BNE $CF8A                             ; $CF79: D0 0F
  BNE $CF77                             ; $CF7B: D0 FA
  DCP $CFE5                             ; $CF7D: CF E5 CF
  BNE $CF51                             ; $CF80: D0 CF
  CLV                                   ; $CF82: B8
  DCP $CFA0                             ; $CF83: CF A0 CF
  DEY                                   ; $CF86: 88
  DCP $0100                             ; $CF87: CF 00 01
Loc_CF8A:
  JAM                                   ; $CF8A: 02
  SLO ($04,X)                           ; $CF8B: 03 04
  ORA $06                               ; $CF8D: 05 06
  SLO $08                               ; $CF8F: 07 08
  ORA #$0A                              ; $CF91: 09 0A
  ANC #$0C                              ; $CF93: 0B 0C
  ORA $0F0E                             ; $CF95: 0D 0E 0F
  BPL $CFAB                             ; $CF98: 10 11
Loc_CF9A:
  JAM                                   ; $CF9A: 12
  SLO ($14),Y                           ; $CF9B: 13 14
  ISB $FFFF,X                           ; $CF9D: FF FF FF
  BRK                                   ; $CFA0: 00
  ORA ($02,X)                           ; $CFA1: 01 02
  SLO ($04,X)                           ; $CFA3: 03 04
  ORA $06                               ; $CFA5: 05 06
  SLO $08                               ; $CFA7: 07 08
  ORA #$0A                              ; $CFA9: 09 0A
Loc_CFAB:
  ANC #$0C                              ; $CFAB: 0B 0C
  ORA $0F0E                             ; $CFAD: 0D 0E 0F
  BPL $CFC3                             ; $CFB0: 10 11
  JAM                                   ; $CFB2: 12
  SLO ($FF),Y                           ; $CFB3: 13 FF
  ISB $FFFF,X                           ; $CFB5: FF FF FF
  BRK                                   ; $CFB8: 00
  ORA ($02,X)                           ; $CFB9: 01 02
  SLO ($04,X)                           ; $CFBB: 03 04
  ORA $06                               ; $CFBD: 05 06
  SLO $08                               ; $CFBF: 07 08
  ORA #$0A                              ; $CFC1: 09 0A
Loc_CFC3:
  ANC #$0C                              ; $CFC3: 0B 0C
  ORA $0F0E                             ; $CFC5: 0D 0E 0F
  BPL $CFDB                             ; $CFC8: 10 11
  JAM                                   ; $CFCA: 12
  ISB $FFFF,X                           ; $CFCB: FF FF FF
  ISB $00FF,X                           ; $CFCE: FF FF 00
  ORA ($02,X)                           ; $CFD1: 01 02
  SLO ($04,X)                           ; $CFD3: 03 04
  ORA $06                               ; $CFD5: 05 06
  SLO $08                               ; $CFD7: 07 08
  ORA #$0A                              ; $CFD9: 09 0A
Loc_CFDB:
  ANC #$0C                              ; $CFDB: 0B 0C
  ORA $0F0E                             ; $CFDD: 0D 0E 0F
  BPL $CFF3                             ; $CFE0: 10 11
  ISB $FFFF,X                           ; $CFE2: FF FF FF
  BRK                                   ; $CFE5: 00
  ORA ($02,X)                           ; $CFE6: 01 02
  SLO ($04,X)                           ; $CFE8: 03 04
  ORA $06                               ; $CFEA: 05 06
  SLO $08                               ; $CFEC: 07 08
  ORA #$0A                              ; $CFEE: 09 0A
  ANC #$0C                              ; $CFF0: 0B 0C
  ORA $0F0E                             ; $CFF2: 0D 0E 0F
  BPL $CFF6                             ; $CFF5: 10 FF
  ISB $FFFF,X                           ; $CFF7: FF FF FF
  BRK                                   ; $CFFA: 00
  ORA ($02,X)                           ; $CFFB: 01 02
  SLO ($04,X)                           ; $CFFD: 03 04
  ORA $06                               ; $CFFF: 05 06
  SLO $08                               ; $D001: 07 08
  ORA #$0A                              ; $D003: 09 0A
  ANC #$0C                              ; $D005: 0B 0C
  ORA $0F0E                             ; $D007: 0D 0E 0F
  ISB $FFFF,X                           ; $D00A: FF FF FF
  ISB $00FF,X                           ; $D00D: FF FF 00
  ORA ($02,X)                           ; $D010: 01 02
  SLO ($04,X)                           ; $D012: 03 04
  ORA $06                               ; $D014: 05 06
  SLO $08                               ; $D016: 07 08
  ORA #$0A                              ; $D018: 09 0A
  ANC #$0C                              ; $D01A: 0B 0C
  ORA $FF0E                             ; $D01C: 0D 0E FF
  ISB $00FF,X                           ; $D01F: FF FF 00
  ORA ($02,X)                           ; $D022: 01 02
  SLO ($04,X)                           ; $D024: 03 04
  ORA $06                               ; $D026: 05 06
  SLO $08                               ; $D028: 07 08
  ORA #$0A                              ; $D02A: 09 0A
  ANC #$0C                              ; $D02C: 0B 0C
  ORA $FFFF                             ; $D02E: 0D FF FF
  ISB $00FF,X                           ; $D031: FF FF 00
  ORA ($02,X)                           ; $D034: 01 02
  SLO ($04,X)                           ; $D036: 03 04
  ORA $06                               ; $D038: 05 06
  SLO $08                               ; $D03A: 07 08
  ORA #$0A                              ; $D03C: 09 0A
  ANC #$0C                              ; $D03E: 0B 0C
  ISB $FFFF,X                           ; $D040: FF FF FF
  ISB $00FF,X                           ; $D043: FF FF 00
  ORA ($02,X)                           ; $D046: 01 02
  SLO ($04,X)                           ; $D048: 03 04
  ORA $06                               ; $D04A: 05 06
  SLO $08                               ; $D04C: 07 08
  ORA #$0A                              ; $D04E: 09 0A
  ANC #$FF                              ; $D050: 0B FF
  ISB $00FF,X                           ; $D052: FF FF 00
  ORA ($02,X)                           ; $D055: 01 02
  SLO ($04,X)                           ; $D057: 03 04
  ORA $06                               ; $D059: 05 06
  SLO $08                               ; $D05B: 07 08
  ORA #$0A                              ; $D05D: 09 0A
  ISB $FFFF,X                           ; $D05F: FF FF FF
  ISB $0100,X                           ; $D062: FF 00 01
  JAM                                   ; $D065: 02
  SLO ($04,X)                           ; $D066: 03 04
  ORA $06                               ; $D068: 05 06
  SLO $08                               ; $D06A: 07 08
  ORA #$FF                              ; $D06C: 09 FF
  ISB $FFFF,X                           ; $D06E: FF FF FF
  ISB $0100,X                           ; $D071: FF 00 01
  JAM                                   ; $D074: 02
  SLO ($04,X)                           ; $D075: 03 04
  ORA $06                               ; $D077: 05 06
  SLO $08                               ; $D079: 07 08
  ISB $FFFF,X                           ; $D07B: FF FF FF
  BRK                                   ; $D07E: 00
  ORA ($02,X)                           ; $D07F: 01 02
  SLO ($04,X)                           ; $D081: 03 04
  ORA $06                               ; $D083: 05 06
  SLO $FF                               ; $D085: 07 FF
  ISB $FFFF,X                           ; $D087: FF FF FF
  BRK                                   ; $D08A: 00
  ORA ($02,X)                           ; $D08B: 01 02
  SLO ($04,X)                           ; $D08D: 03 04
  ORA $06                               ; $D08F: 05 06
  ISB $FFFF,X                           ; $D091: FF FF FF
  ISB $00FF,X                           ; $D094: FF FF 00
  ORA ($02,X)                           ; $D097: 01 02
  SLO ($04,X)                           ; $D099: 03 04
  ORA $FF                               ; $D09B: 05 FF
  ISB $00FF,X                           ; $D09D: FF FF 00
  ORA ($02,X)                           ; $D0A0: 01 02
  SLO ($04,X)                           ; $D0A2: 03 04
  ISB $FFFF,X                           ; $D0A4: FF FF FF
  ISB $0100,X                           ; $D0A7: FF 00 01
  JAM                                   ; $D0AA: 02
  SLO ($FF,X)                           ; $D0AB: 03 FF
  ISB $FFFF,X                           ; $D0AD: FF FF FF
  ISB $0100,X                           ; $D0B0: FF 00 01
  JAM                                   ; $D0B3: 02
  ISB $FFFF,X                           ; $D0B4: FF FF FF
  BRK                                   ; $D0B7: 00
  ORA ($FF,X)                           ; $D0B8: 01 FF
  ISB $FFFF,X                           ; $D0BA: FF FF FF
  BRK                                   ; $D0BD: 00
  ISB $FFFF,X                           ; $D0BE: FF FF FF
  ISB $ACFF,X                           ; $D0C1: FF FF AC
  SLO $05                               ; $D0C4: 07 05
  LDA $050B                             ; $D0C6: AD 0B 05
  AND #$F0                              ; $D0C9: 29 F0
  BEQ $D0D3                             ; $D0CB: F0 06
  TYA                                   ; $D0CD: 98
  LSR                                   ; $D0CE: 4A
  LSR                                   ; $D0CF: 4A
  LSR                                   ; $D0D0: 4A
  LSR                                   ; $D0D1: 4A
  TAY                                   ; $D0D2: A8
Loc_D0D3:
  TYA                                   ; $D0D3: 98
  AND #$0F                              ; $D0D4: 29 0F
  JSR $F368                             ; $D0D6: 20 68 F3
  LDY #$00                              ; $D0D9: A0 00
  LDA ($00),Y                           ; $D0DB: B1 00
  STA $044C                             ; $D0DD: 8D 4C 04
  RTS                                   ; $D0E0: 60
Loc_D0E1:
  LDY #$20                              ; $D0E1: A0 20
  LDA #$FF                              ; $D0E3: A9 FF
Loc_D0E5:
  STA $0580,Y                           ; $D0E5: 99 80 05
  DEY                                   ; $D0E8: 88
  BPL $D0E5                             ; $D0E9: 10 FA
  LDA #$FF                              ; $D0EB: A9 FF
  STA $050A                             ; $D0ED: 8D 0A 05
  LDY #$1F                              ; $D0F0: A0 1F
  LDA #$FF                              ; $D0F2: A9 FF
Loc_D0F4:
  STA $042C,Y                           ; $D0F4: 99 2C 04
  DEY                                   ; $D0F7: 88
  BPL $D0F4                             ; $D0F8: 10 FA
  LDA $050B                             ; $D0FA: AD 0B 05
  AND #$10                              ; $D0FD: 29 10
  BNE $D134                             ; $D0FF: D0 33
  LDY #$00                              ; $D101: A0 00
  LDX #$00                              ; $D103: A2 00
Loc_D105:
  LDA $0628,Y                           ; $D105: B9 28 06
  AND #$80                              ; $D108: 29 80
  BNE $D117                             ; $D10A: D0 0B
  LDA $0664,Y                           ; $D10C: B9 64 06
  CMP #$FF                              ; $D10F: C9 FF
  BEQ $D117                             ; $D111: F0 04
  STA $042C,X                           ; $D113: 9D 2C 04
  INX                                   ; $D116: E8
Loc_D117:
  INY                                   ; $D117: C8
  CPY #$14                              ; $D118: C0 14
  BCC $D105                             ; $D11A: 90 E9
  LDY #$00                              ; $D11C: A0 00
Loc_D11E:
  LDA $6F47,Y                           ; $D11E: B9 47 6F
  CMP #$FF                              ; $D121: C9 FF
  BEQ $D129                             ; $D123: F0 04
  STA $042C,X                           ; $D125: 9D 2C 04
  INX                                   ; $D128: E8
Loc_D129:
  INY                                   ; $D129: C8
  CPY #$14                              ; $D12A: C0 14
  BCC $D11E                             ; $D12C: 90 F0
  LDA #$FE                              ; $D12E: A9 FE
  STA $042C,X                           ; $D130: 9D 2C 04
  RTS                                   ; $D133: 60
Loc_D134:
  LDY #$00                              ; $D134: A0 00
  LDX #$00                              ; $D136: A2 00
Loc_D138:
  LDA $0628,Y                           ; $D138: B9 28 06
  AND #$80                              ; $D13B: 29 80
  BEQ $D14A                             ; $D13D: F0 0B
  LDA $0664,Y                           ; $D13F: B9 64 06
  CMP #$FF                              ; $D142: C9 FF
  BEQ $D14A                             ; $D144: F0 04
  STA $042C,X                           ; $D146: 9D 2C 04
  INX                                   ; $D149: E8
Loc_D14A:
  INY                                   ; $D14A: C8
  CPY #$14                              ; $D14B: C0 14
  BCC $D138                             ; $D14D: 90 E9
  LDY #$00                              ; $D14F: A0 00
Loc_D151:
  LDA $6F5B,Y                           ; $D151: B9 5B 6F
  CMP #$FF                              ; $D154: C9 FF
  BEQ $D15C                             ; $D156: F0 04
  STA $042C,X                           ; $D158: 9D 2C 04
  INX                                   ; $D15B: E8
Loc_D15C:
  INY                                   ; $D15C: C8
  CPY #$14                              ; $D15D: C0 14
  BCC $D151                             ; $D15F: 90 F0
  LDA #$FE                              ; $D161: A9 FE
  STA $042C,X                           ; $D163: 9D 2C 04
  RTS                                   ; $D166: 60
Loc_D167:
  LDX #$00                              ; $D167: A2 00
  LDY #$1F                              ; $D169: A0 1F
Loc_D16B:
  LDA $0580,Y                           ; $D16B: B9 80 05
  CMP #$FF                              ; $D16E: C9 FF
  BEQ $D173                             ; $D170: F0 01
  INX                                   ; $D172: E8
Loc_D173:
  DEY                                   ; $D173: 88
  BPL $D16B                             ; $D174: 10 F5
  LDA $81                               ; $D176: A5 81
  AND #$01                              ; $D178: 29 01
  BEQ $D1BB                             ; $D17A: F0 3F
  LDY $0508                             ; $D17C: AC 08 05
  CPY $050A                             ; $D17F: CC 0A 05
  BEQ $D1BB                             ; $D182: F0 37
  LDA $0580,Y                           ; $D184: B9 80 05
  BEQ $D1B6                             ; $D187: F0 2D
  LDA $0540                             ; $D189: AD 40 05
  CMP #$1E                              ; $D18C: C9 1E
  BNE $D19E                             ; $D18E: D0 0E
  JSR $D0C3                             ; $D190: 20 C3 D0
  LDY $0508                             ; $D193: AC 08 05
  CMP $042C,Y                           ; $D196: D9 2C 04
  BEQ $D1BB                             ; $D199: F0 20
  JMP $D1AD                             ; $D19B: 4C AD D1
Loc_D19E:
  STX $00                               ; $D19E: 86 00
  LDY $0541                             ; $D1A0: AC 41 05
  LDA #$09                              ; $D1A3: A9 09
  SEC                                   ; $D1A5: 38
  SBC $0550,Y                           ; $D1A6: F9 50 05
  CMP $00                               ; $D1A9: C5 00
  BCC $D1BB                             ; $D1AB: 90 0E
Loc_D1AD:
  LDY $0508                             ; $D1AD: AC 08 05
  LDA #$00                              ; $D1B0: A9 00
  STA $0580,Y                           ; $D1B2: 99 80 05
  RTS                                   ; $D1B5: 60
Loc_D1B6:
  LDA #$FF                              ; $D1B6: A9 FF
  STA $0580,Y                           ; $D1B8: 99 80 05
Loc_D1BB:
  RTS                                   ; $D1BB: 60
Loc_D1BC:
  LDA #$08                              ; $D1BC: A9 08
  STA $00AF                             ; $D1BE: 8D AF 00
  LDA #$36                              ; $D1C1: A9 36
  STA $0115                             ; $D1C3: 8D 15 01
  LDA #$16                              ; $D1C6: A9 16
  STA $0117                             ; $D1C8: 8D 17 01
  LDY #$00                              ; $D1CB: A0 00
Loc_D1CD:
  LDA $0580,Y                           ; $D1CD: B9 80 05
  BMI $D1D9                             ; $D1D0: 30 07
  TYA                                   ; $D1D2: 98
  PHA                                   ; $D1D3: 48
  JSR $D1DF                             ; $D1D4: 20 DF D1
  PLA                                   ; $D1D7: 68
  TAY                                   ; $D1D8: A8
Loc_D1D9:
  INY                                   ; $D1D9: C8
  CPY #$14                              ; $D1DA: C0 14
  BCC $D1CD                             ; $D1DC: 90 EF
  RTS                                   ; $D1DE: 60
Loc_D1DF:
  LDA #$34                              ; $D1DF: A9 34
  STA $10                               ; $D1E1: 85 10
  LDA #$CF                              ; $D1E3: A9 CF
  STA $11                               ; $D1E5: 85 11
  LDA #$F4                              ; $D1E7: A9 F4
  STA $00                               ; $D1E9: 85 00
  LDA #$D1                              ; $D1EB: A9 D1
  STA $01                               ; $D1ED: 85 01
  TYA                                   ; $D1EF: 98
  JSR $EDF5                             ; $D1F0: 20 F5 ED
  RTS                                   ; $D1F3: 60
; --- Data Region ---
  .byte $00,$7E,$01,$00,$80               ; $D1F4: 00 7E 01 00 80
Loc_D1F9:
; --- Code Region ---
  LDY #$00                              ; $D1F9: A0 00
Loc_D1FB:
  LDA $0580,Y                           ; $D1FB: B9 80 05
  BMI $D207                             ; $D1FE: 30 07
  TYA                                   ; $D200: 98
  PHA                                   ; $D201: 48
  JSR $D20D                             ; $D202: 20 0D D2
  PLA                                   ; $D205: 68
  TAY                                   ; $D206: A8
Loc_D207:
  INY                                   ; $D207: C8
  CPY #$14                              ; $D208: C0 14
  BCC $D1FB                             ; $D20A: 90 EF
  RTS                                   ; $D20C: 60
Loc_D20D:
  LDA $0540                             ; $D20D: AD 40 05
  CMP #$1E                              ; $D210: C9 1E
  BNE $D249                             ; $D212: D0 35
  LDA $042C,Y                           ; $D214: B9 2C 04
  PHA                                   ; $D217: 48
  JSR $F2D7                             ; $D218: 20 D7 F2
  LDY #$0B                              ; $D21B: A0 0B
  LDA ($00),Y                           ; $D21D: B1 00
  AND #$FC                              ; $D21F: 29 FC
  STA ($00),Y                           ; $D221: 91 00
  LDY #$30                              ; $D223: A0 30
  JSR $F266                             ; $D225: 20 66 F2
  LDA $050E                             ; $D228: AD 0E 05
  ASL                                   ; $D22B: 0A
  ASL                                   ; $D22C: 0A
  ASL                                   ; $D22D: 0A
  STA $0002                             ; $D22E: 8D 02 00
  JSR $E856                             ; $D231: 20 56 E8
  CLC                                   ; $D234: 18
  ADC $0002                             ; $D235: 6D 02 00
  TAY                                   ; $D238: A8
  LDA $9D72,Y                           ; $D239: B9 72 9D
  BPL $D241                             ; $D23C: 10 03
  LDA $050E                             ; $D23E: AD 0E 05
Loc_D241:
  LDY #$05                              ; $D241: A0 05
  STA ($00),Y                           ; $D243: 91 00
  PLA                                   ; $D245: 68
  JMP $D299                             ; $D246: 4C 99 D2
Loc_D249:
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
  LDA $042C,X                           ; $D25E: BD 2C 04
  CMP $052B                             ; $D261: CD 2B 05
  BNE $D26C                             ; $D264: D0 06
  LDX $0540                             ; $D266: AE 40 05
  STX $052C                             ; $D269: 8E 2C 05
Loc_D26C:
  STA ($00),Y                           ; $D26C: 91 00
  PHA                                   ; $D26E: 48
  LDY #$00                              ; $D26F: A0 00
  LDA ($00),Y                           ; $D271: B1 00
  AND #$07                              ; $D273: 29 07
  CMP #$07                              ; $D275: C9 07
  BNE $D298                             ; $D277: D0 1F
  LDY $0507                             ; $D279: AC 07 05
  LDA $050B                             ; $D27C: AD 0B 05
  AND #$F0                              ; $D27F: 29 F0
  BEQ $D289                             ; $D281: F0 06
  TYA                                   ; $D283: 98
  LSR                                   ; $D284: 4A
  LSR                                   ; $D285: 4A
  LSR                                   ; $D286: 4A
  LSR                                   ; $D287: 4A
  TAY                                   ; $D288: A8
Loc_D289:
  TYA                                   ; $D289: 98
  AND #$0F                              ; $D28A: 29 0F
  STA $02                               ; $D28C: 85 02
  LDY #$00                              ; $D28E: A0 00
  LDA ($00),Y                           ; $D290: B1 00
  AND #$F0                              ; $D292: 29 F0
  ORA $02                               ; $D294: 05 02
  STA ($00),Y                           ; $D296: 91 00
Loc_D298:
  PLA                                   ; $D298: 68
Loc_D299:
  LDX #$00                              ; $D299: A2 00
Loc_D29B:
  CMP $0664,X                           ; $D29B: DD 64 06
  BEQ $D2B2                             ; $D29E: F0 12
  INX                                   ; $D2A0: E8
  CPX #$14                              ; $D2A1: E0 14
  BCC $D29B                             ; $D2A3: 90 F6
  LDX #$00                              ; $D2A5: A2 00
Loc_D2A7:
  CMP $6F47,X                           ; $D2A7: DD 47 6F
Loc_D2AA:
  BEQ $D2C7                             ; $D2AA: F0 1B
  INX                                   ; $D2AC: E8
  CPX #$28                              ; $D2AD: E0 28
  BCC $D2A7                             ; $D2AF: 90 F6
  RTS                                   ; $D2B1: 60
Loc_D2B2:
  LDA #$FF                              ; $D2B2: A9 FF
  STA $0600,X                           ; $D2B4: 9D 00 06
  STA $0614,X                           ; $D2B7: 9D 14 06
  STA $0628,X                           ; $D2BA: 9D 28 06
  STA $063C,X                           ; $D2BD: 9D 3C 06
  STA $0650,X                           ; $D2C0: 9D 50 06
  STA $0664,X                           ; $D2C3: 9D 64 06
  RTS                                   ; $D2C6: 60
Loc_D2C7:
  LDA #$FF                              ; $D2C7: A9 FF
  STA $6F47,X                           ; $D2C9: 9D 47 6F
  RTS                                   ; $D2CC: 60
Loc_D2CD:  ; (dispatch callback target)
  LDA $0501                             ; $D2CD: AD 01 05
  JSR $EADE                             ; $D2D0: 20 DE EA
; --- Data Region ---
  .byte $E1,$D2,$10,$D3,$4B,$D3,$AF,$D3,$D7,$D3,$F7,$D3,$62,$D4; $D2D3: E1 D2 10 D3 4B D3 AF D3 D7 D3 F7 D3 62 D4
Loc_D2E1:  ; (dispatch callback target)
; --- Code Region ---
  JSR $CC29                             ; $D2E1: 20 29 CC
  JSR $D0E1                             ; $D2E4: 20 E1 D0
  LDA #$FF                              ; $D2E7: A9 FF
  STA $042C,X                           ; $D2E9: 9D 2C 04
  STX $050A                             ; $D2EC: 8E 0A 05
  CPX #$0B                              ; $D2EF: E0 0B
  BCS $D304                             ; $D2F1: B0 11
  JSR $D48D                             ; $D2F3: 20 8D D4
  LDA #$0F                              ; $D2F6: A9 0F
  STA $0500                             ; $D2F8: 8D 00 05
  LDA $050B                             ; $D2FB: AD 0B 05
  AND #$0F                              ; $D2FE: 29 0F
  STA $0501                             ; $D300: 8D 01 05
  RTS                                   ; $D303: 60
Loc_D304:
  LDA #$DF                              ; $D304: A9 DF
  JSR $F293                             ; $D306: 20 93 F2
  JSR $D0C3                             ; $D309: 20 C3 D0
  INC $0501                             ; $D30C: EE 01 05
  RTS                                   ; $D30F: 60
Loc_D310:  ; (dispatch callback target)
  JSR $CC29                             ; $D310: 20 29 CC
  JSR $DF27                             ; $D313: 20 27 DF
  BCC $D34A                             ; $D316: 90 32
  JSR $DC63                             ; $D318: 20 63 DC
  LDA $81                               ; $D31B: A5 81
  AND #$01                              ; $D31D: 29 01
  BEQ $D34A                             ; $D31F: F0 29
  INC $0501                             ; $D321: EE 01 05
  LDA #$D7                              ; $D324: A9 D7
  JSR $F283                             ; $D326: 20 83 F2
  LDA #$00                              ; $D329: A9 00
  STA $0424                             ; $D32B: 8D 24 04
  STA $0425                             ; $D32E: 8D 25 04
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
  STA $042C,Y                           ; $D347: 99 2C 04
Loc_D34A:
  RTS                                   ; $D34A: 60
Loc_D34B:  ; (dispatch callback target)
  JSR $CC29                             ; $D34B: 20 29 CC
  LDA $050A                             ; $D34E: AD 0A 05
  ASL                                   ; $D351: 0A
  TAY                                   ; $D352: A8
  LDA $BA9F,Y                           ; $D353: B9 9F BA
  STA $10                               ; $D356: 85 10
  LDA $BAA0,Y                           ; $D358: B9 A0 BA
  STA $11                               ; $D35B: 85 11
  LDA #$00                              ; $D35D: A9 00
  STA $12                               ; $D35F: 85 12
  JSR $ED1E                             ; $D361: 20 1E ED
  LDA #$6F                              ; $D364: A9 6F
  STA $10                               ; $D366: 85 10
  LDA #$BB                              ; $D368: A9 BB
  STA $11                               ; $D36A: 85 11
  LDA #$7F                              ; $D36C: A9 7F
  STA $00                               ; $D36E: 85 00
  LDA #$BB                              ; $D370: A9 BB
  STA $01                               ; $D372: 85 01
  LDA $12                               ; $D374: A5 12
  JSR $EDF5                             ; $D376: 20 F5 ED
  JSR $DF27                             ; $D379: 20 27 DF
  BCC $D34A                             ; $D37C: 90 CC
  LDA $81                               ; $D37E: A5 81
  AND #$01                              ; $D380: 29 01
  BEQ $D3AE                             ; $D382: F0 2A
  LDY $12                               ; $D384: A4 12
  LDA $042C,Y                           ; $D386: B9 2C 04
  STA $0540                             ; $D389: 8D 40 05
  STY $0541                             ; $D38C: 8C 41 05
  CMP #$1E                              ; $D38F: C9 1E
  BEQ $D39A                             ; $D391: F0 07
  LDA $0550,Y                           ; $D393: B9 50 05
  CMP #$0A                              ; $D396: C9 0A
  BCS $D3AE                             ; $D398: B0 14
Loc_D39A:
  INC $0501                             ; $D39A: EE 01 05
  LDA #$DD                              ; $D39D: A9 DD
  LDY $0540                             ; $D39F: AC 40 05
  CPY #$1E                              ; $D3A2: C0 1E
  BNE $D3A8                             ; $D3A4: D0 02
  LDA #$E5                              ; $D3A6: A9 E5
Loc_D3A8:
  JSR $F283                             ; $D3A8: 20 83 F2
  JSR $D0C3                             ; $D3AB: 20 C3 D0
Loc_D3AE:
  RTS                                   ; $D3AE: 60
Loc_D3AF:  ; (dispatch callback target)
  JSR $CC29                             ; $D3AF: 20 29 CC
  JSR $DF27                             ; $D3B2: 20 27 DF
  BCC $D3D6                             ; $D3B5: 90 1F
  JSR $DC63                             ; $D3B7: 20 63 DC
  LDA $81                               ; $D3BA: A5 81
  AND #$01                              ; $D3BC: 29 01
  BEQ $D3D6                             ; $D3BE: F0 16
  LDA #$00                              ; $D3C0: A9 00
  STA $0424                             ; $D3C2: 8D 24 04
  STA $0425                             ; $D3C5: 8D 25 04
  JSR $D0E1                             ; $D3C8: 20 E1 D0
  STX $050A                             ; $D3CB: 8E 0A 05
  LDA #$DE                              ; $D3CE: A9 DE
  JSR $F28B                             ; $D3D0: 20 8B F2
  INC $0501                             ; $D3D3: EE 01 05
Loc_D3D6:
  RTS                                   ; $D3D6: 60
Loc_D3D7:  ; (dispatch callback target)
  JSR $CC29                             ; $D3D7: 20 29 CC
  JSR $DF27                             ; $D3DA: 20 27 DF
  BCC $D3F6                             ; $D3DD: 90 17
  LDX $050A                             ; $D3DF: AE 0A 05
  LDA #$FF                              ; $D3E2: A9 FF
  STA $042C,X                           ; $D3E4: 9D 2C 04
  LDA #$E0                              ; $D3E7: A9 E0
  STA $E6                               ; $D3E9: 85 E6
  STA $E7                               ; $D3EB: 85 E7
  INC $0501                             ; $D3ED: EE 01 05
  LDA #$00                              ; $D3F0: A9 00
  STA $8E                               ; $D3F2: 85 8E
  STA $90                               ; $D3F4: 85 90
Loc_D3F6:
  RTS                                   ; $D3F6: 60
Loc_D3F7:  ; (dispatch callback target)
  LDA $050A                             ; $D3F7: AD 0A 05
  ASL                                   ; $D3FA: 0A
  TAY                                   ; $D3FB: A8
  LDA $CF5E,Y                           ; $D3FC: B9 5E CF
  STA $10                               ; $D3FF: 85 10
  LDA $CF5F,Y                           ; $D401: B9 5F CF
  STA $11                               ; $D404: 85 11
  LDA #$00                              ; $D406: A9 00
  STA $12                               ; $D408: 85 12
  JSR $ED23                             ; $D40A: 20 23 ED
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
  JSR $EDF5                             ; $D422: 20 F5 ED
  JSR $D167                             ; $D425: 20 67 D1
  JSR $D1BC                             ; $D428: 20 BC D1
  LDA $81                               ; $D42B: A5 81
  AND #$01                              ; $D42D: 29 01
  BEQ $D45C                             ; $D42F: F0 2B
  LDA $050A                             ; $D431: AD 0A 05
  CMP $0508                             ; $D434: CD 08 05
  BNE $D45C                             ; $D437: D0 23
  LDY #$00                              ; $D439: A0 00
  LDX #$00                              ; $D43B: A2 00
Loc_D43D:
  LDA $0580,Y                           ; $D43D: B9 80 05
  BMI $D443                             ; $D440: 30 01
  INX                                   ; $D442: E8
Loc_D443:
  INY                                   ; $D443: C8
  CPY #$14                              ; $D444: C0 14
  BCC $D43D                             ; $D446: 90 F5
  TXA                                   ; $D448: 8A
  BEQ $D473                             ; $D449: F0 28
  LDA #$D8                              ; $D44B: A9 D8
  LDY $0540                             ; $D44D: AC 40 05
  CPY #$1E                              ; $D450: C0 1E
  BNE $D456                             ; $D452: D0 02
  LDA #$E6                              ; $D454: A9 E6
Loc_D456:
  JSR $F283                             ; $D456: 20 83 F2
  INC $0501                             ; $D459: EE 01 05
Loc_D45C:
  RTS                                   ; $D45C: 60
; --- Data Region ---
  .byte $00,$07,$00,$F8,$80               ; $D45D: 00 07 00 F8 80
Loc_D462:  ; (dispatch callback target)
; --- Code Region ---
  JSR $D1BC                             ; $D462: 20 BC D1
  JSR $DF27                             ; $D465: 20 27 DF
  BCC $D48C                             ; $D468: 90 22
  JSR $DC63                             ; $D46A: 20 63 DC
  LDA $81                               ; $D46D: A5 81
  AND #$01                              ; $D46F: 29 01
  BEQ $D48C                             ; $D471: F0 19
Loc_D473:
  LDA #$E1                              ; $D473: A9 E1
  STA $E6                               ; $D475: 85 E6
  STA $E7                               ; $D477: 85 E7
  LDA #$00                              ; $D479: A9 00
  STA $8E                               ; $D47B: 85 8E
  LDA #$50                              ; $D47D: A9 50
  STA $90                               ; $D47F: 85 90
  LDA #$00                              ; $D481: A9 00
  STA $0501                             ; $D483: 8D 01 05
  JSR $D1F9                             ; $D486: 20 F9 D1
  JMP $D2E1                             ; $D489: 4C E1 D2
Loc_D48C:
  RTS                                   ; $D48C: 60
Loc_D48D:
  LDY #$00                              ; $D48D: A0 00
Loc_D48F:
  LDA $042C,Y                           ; $D48F: B9 2C 04
  CMP #$FF                              ; $D492: C9 FF
  BEQ $D49D                             ; $D494: F0 07
  TYA                                   ; $D496: 98
  PHA                                   ; $D497: 48
  JSR $D4A3                             ; $D498: 20 A3 D4
  PLA                                   ; $D49B: 68
  TAY                                   ; $D49C: A8
Loc_D49D:
  INY                                   ; $D49D: C8
  CPY #$14                              ; $D49E: C0 14
  BCC $D48F                             ; $D4A0: 90 ED
  RTS                                   ; $D4A2: 60
Loc_D4A3:
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
  LDA $042C,X                           ; $D4B7: BD 2C 04
  STA ($00),Y                           ; $D4BA: 91 00
  LDX #$00                              ; $D4BC: A2 00
Loc_D4BE:
  CMP $0664,X                           ; $D4BE: DD 64 06
  BEQ $D4D5                             ; $D4C1: F0 12
  INX                                   ; $D4C3: E8
  CPX #$14                              ; $D4C4: E0 14
  BCC $D4BE                             ; $D4C6: 90 F6
  LDX #$00                              ; $D4C8: A2 00
Loc_D4CA:
  CMP $6F47,X                           ; $D4CA: DD 47 6F
  BEQ $D4EA                             ; $D4CD: F0 1B
  INX                                   ; $D4CF: E8
  CPX #$28                              ; $D4D0: E0 28
  BCC $D4CA                             ; $D4D2: 90 F6
  RTS                                   ; $D4D4: 60
Loc_D4D5:
  LDA #$FF                              ; $D4D5: A9 FF
  STA $0600,X                           ; $D4D7: 9D 00 06
  STA $0614,X                           ; $D4DA: 9D 14 06
  STA $0628,X                           ; $D4DD: 9D 28 06
  STA $063C,X                           ; $D4E0: 9D 3C 06
  STA $0650,X                           ; $D4E3: 9D 50 06
  STA $0664,X                           ; $D4E6: 9D 64 06
  RTS                                   ; $D4E9: 60
Loc_D4EA:
  LDA #$FF                              ; $D4EA: A9 FF
  STA $6F47,X                           ; $D4EC: 9D 47 6F
  RTS                                   ; $D4EF: 60
Loc_D4F0:  ; (dispatch callback target)
  JSR $CC29                             ; $D4F0: 20 29 CC
  LDY #$28                              ; $D4F3: A0 28
  JSR $EE07                             ; $D4F5: 20 07 EE
; --- Data Region ---
  .byte $06,$A0,$60,$AD,$18,$03,$85,$00,$AD,$83,$00,$29,$F0,$8D,$18,$03; $D4F8: 06 A0 60 AD 18 03 85 00 AD 83 00 29 F0 8D 18 03
  .byte $F0,$1B,$C5,$00,$D0,$1D,$EE,$19,$03,$AD,$19,$03,$C9,$0F,$90,$0C; $D508: F0 1B C5 00 D0 1D EE 19 03 AD 19 03 C9 0F 90 0C
  .byte $A9,$0F,$8D,$19,$03,$AD,$5E,$00,$29,$03,$F0,$0C; $D518: A9 0F 8D 19 03 AD 5E 00 29 03 F0 0C
Loc_D524:
; --- Code Region ---
  RTS                                   ; $D524: 60
Loc_D525:
  LDA #$00                              ; $D525: A9 00
  STA $0319                             ; $D527: 8D 19 03
  RTS                                   ; $D52A: 60
Loc_D52B:
  LDA #$00                              ; $D52B: A9 00
  STA $0319                             ; $D52D: 8D 19 03
Loc_D530:
  LDA $0083                             ; $D530: AD 83 00
  BPL $D560                             ; $D533: 10 2B
  LDX $6F40                             ; $D535: AE 40 6F
  CPX #$01                              ; $D538: E0 01
  BNE $D543                             ; $D53A: D0 07
  LDX $6F3F                             ; $D53C: AE 3F 6F
  CPX #$F0                              ; $D53F: E0 F0
  BCS $D560                             ; $D541: B0 1D
Loc_D543:
  PHA                                   ; $D543: 48
  LDA $6F3F                             ; $D544: AD 3F 6F
  SEC                                   ; $D547: 38
  SBC $8E                               ; $D548: E5 8E
  CMP #$F0                              ; $D54A: C9 F0
  BCS $D55F                             ; $D54C: B0 11
  LDA $6F3F                             ; $D54E: AD 3F 6F
  CLC                                   ; $D551: 18
  ADC #$10                              ; $D552: 69 10
  STA $6F3F                             ; $D554: 8D 3F 6F
  LDA $6F40                             ; $D557: AD 40 6F
  ADC #$00                              ; $D55A: 69 00
  STA $6F40                             ; $D55C: 8D 40 6F
Loc_D55F:
  PLA                                   ; $D55F: 68
Loc_D560:
  ASL                                   ; $D560: 0A
  BPL $D58A                             ; $D561: 10 27
  LDX $6F40                             ; $D563: AE 40 6F
  BNE $D56D                             ; $D566: D0 05
  LDX $6F3F                             ; $D568: AE 3F 6F
  BEQ $D58A                             ; $D56B: F0 1D
Loc_D56D:
  PHA                                   ; $D56D: 48
  LDA $6F3F                             ; $D56E: AD 3F 6F
  SEC                                   ; $D571: 38
  SBC $8E                               ; $D572: E5 8E
  CMP #$10                              ; $D574: C9 10
  BCC $D589                             ; $D576: 90 11
  LDA $6F3F                             ; $D578: AD 3F 6F
  SEC                                   ; $D57B: 38
  SBC #$10                              ; $D57C: E9 10
  STA $6F3F                             ; $D57E: 8D 3F 6F
  LDA $6F40                             ; $D581: AD 40 6F
  SBC #$00                              ; $D584: E9 00
  STA $6F40                             ; $D586: 8D 40 6F
Loc_D589:
  PLA                                   ; $D589: 68
Loc_D58A:
  ASL                                   ; $D58A: 0A
  BPL $D5BF                             ; $D58B: 10 32
  PHA                                   ; $D58D: 48
  LDA $6F42                             ; $D58E: AD 42 6F
  BEQ $D59A                             ; $D591: F0 07
  LDA $6F41                             ; $D593: AD 41 6F
  CMP #$40                              ; $D596: C9 40
  BCS $D5BE                             ; $D598: B0 24
Loc_D59A:
  LDA $6F41                             ; $D59A: AD 41 6F
  SEC                                   ; $D59D: 38
  SBC $0090                             ; $D59E: ED 90 00
  CMP #$A0                              ; $D5A1: C9 A0
  BCS $D5BE                             ; $D5A3: B0 19
  LDA $6F41                             ; $D5A5: AD 41 6F
  CLC                                   ; $D5A8: 18
  ADC #$10                              ; $D5A9: 69 10
  CMP #$F0                              ; $D5AB: C9 F0
  BCC $D5B3                             ; $D5AD: 90 04
  CLC                                   ; $D5AF: 18
  ADC #$10                              ; $D5B0: 69 10
  SEC                                   ; $D5B2: 38
Loc_D5B3:
  STA $6F41                             ; $D5B3: 8D 41 6F
  LDA $6F42                             ; $D5B6: AD 42 6F
  ADC #$00                              ; $D5B9: 69 00
  STA $6F42                             ; $D5BB: 8D 42 6F
Loc_D5BE:
  PLA                                   ; $D5BE: 68
Loc_D5BF:
  ASL                                   ; $D5BF: 0A
  BPL $D5ED                             ; $D5C0: 10 2B
  LDX $6F42                             ; $D5C2: AE 42 6F
  BNE $D5CE                             ; $D5C5: D0 07
  LDX $6F41                             ; $D5C7: AE 41 6F
  CPX #$10                              ; $D5CA: E0 10
  BCC $D5ED                             ; $D5CC: 90 1F
Loc_D5CE:
  LDA $6F41                             ; $D5CE: AD 41 6F
  SEC                                   ; $D5D1: 38
  SBC $0090                             ; $D5D2: ED 90 00
  CMP #$10                              ; $D5D5: C9 10
  BCC $D5ED                             ; $D5D7: 90 14
  LDA $6F41                             ; $D5D9: AD 41 6F
  SEC                                   ; $D5DC: 38
  SBC #$10                              ; $D5DD: E9 10
  STA $6F41                             ; $D5DF: 8D 41 6F
  BCS $D5ED                             ; $D5E2: B0 09
  SEC                                   ; $D5E4: 38
  SBC #$10                              ; $D5E5: E9 10
  STA $6F41                             ; $D5E7: 8D 41 6F
  DEC $6F42                             ; $D5EA: CE 42 6F
Loc_D5ED:
  RTS                                   ; $D5ED: 60
Loc_D5EE:
  JSR $DA17                             ; $D5EE: 20 17 DA
  LDA #$00                              ; $D5F1: A9 00
  STA $04                               ; $D5F3: 85 04
  LDA $0002                             ; $D5F5: AD 02 00
  SEC                                   ; $D5F8: 38
  SBC $0000                             ; $D5F9: ED 00 00
  BCC $D602                             ; $D5FC: 90 04
  CMP #$03                              ; $D5FE: C9 03
  BCS $D60F                             ; $D600: B0 0D
Loc_D602:
  LDY $0090                             ; $D602: AC 90 00
  BEQ $D60F                             ; $D605: F0 08
  LDA #$20                              ; $D607: A9 20
  STA $0004                             ; $D609: 8D 04 00
  JMP $D61F                             ; $D60C: 4C 1F D6
Loc_D60F:
  CMP #$07                              ; $D60F: C9 07
  BCC $D61F                             ; $D611: 90 0C
  LDY $0090                             ; $D613: AC 90 00
  CPY #$8E                              ; $D616: C0 8E
  BCS $D61F                             ; $D618: B0 05
  LDA #$10                              ; $D61A: A9 10
  STA $0004                             ; $D61C: 8D 04 00
Loc_D61F:
  LDA $0003                             ; $D61F: AD 03 00
  SEC                                   ; $D622: 38
  SBC $0001                             ; $D623: ED 01 00
  BCC $D62C                             ; $D626: 90 04
  CMP #$04                              ; $D628: C9 04
  BCS $D63B                             ; $D62A: B0 0F
Loc_D62C:
  LDY $8E                               ; $D62C: A4 8E
  BEQ $D63B                             ; $D62E: F0 0B
  LDA $0004                             ; $D630: AD 04 00
  ORA #$40                              ; $D633: 09 40
  STA $0004                             ; $D635: 8D 04 00
  JMP $D64D                             ; $D638: 4C 4D D6
Loc_D63B:
  CMP #$0C                              ; $D63B: C9 0C
  BCC $D64D                             ; $D63D: 90 0E
  LDY $8E                               ; $D63F: A4 8E
  CPY #$FE                              ; $D641: C0 FE
  BCS $D64D                             ; $D643: B0 08
  LDA $0004                             ; $D645: AD 04 00
  ORA #$80                              ; $D648: 09 80
  STA $0004                             ; $D64A: 8D 04 00
Loc_D64D:
  LDA $0508                             ; $D64D: AD 08 05
  ORA $0004                             ; $D650: 0D 04 00
  STA $0508                             ; $D653: 8D 08 05
  RTS                                   ; $D656: 60
Loc_D657:
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
  JMP $F092                             ; $D67E: 4C 92 F0
; --- Data Region ---
  .byte $00,$05,$00,$04,$08,$06,$00,$04,$80; $D681: 00 05 00 04 08 06 00 04 80
Loc_D68A:
; --- Code Region ---
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
Loc_D6A9:  ; (dispatch callback target)
  LSR                                   ; $D6A9: 4A
  ROR $0001                             ; $D6AA: 6E 01 00
  ROR $0001                             ; $D6AD: 6E 01 00
  ROR $0001                             ; $D6B0: 6E 01 00
  ROR $0001                             ; $D6B3: 6E 01 00
Loc_D6B6:
  LDY #$13                              ; $D6B6: A0 13
Loc_D6B8:
  LDA $0600,Y                           ; $D6B8: B9 00 06
  CMP $0000                             ; $D6BB: CD 00 00
  BNE $D6C8                             ; $D6BE: D0 08
  LDA $0614,Y                           ; $D6C0: B9 14 06
  CMP $0001                             ; $D6C3: CD 01 00
  BEQ $D6CB                             ; $D6C6: F0 03
Loc_D6C8:
  DEY                                   ; $D6C8: 88
  BPL $D6B8                             ; $D6C9: 10 ED
Loc_D6CB:
  RTS                                   ; $D6CB: 60
Loc_D6CC:
  JMP $D6D0                             ; $D6CC: 4C D0 D6
Loc_D6CF:
  RTS                                   ; $D6CF: 60
Loc_D6D0:
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
  BCS $D6CF                             ; $D6ED: B0 E0
  LDA $8E                               ; $D6EF: A5 8E
  CLC                                   ; $D6F1: 18
  ADC #$04                              ; $D6F2: 69 04
  BCC $D6FB                             ; $D6F4: 90 05
  LDA #$10                              ; $D6F6: A9 10
  JMP $D6FF                             ; $D6F8: 4C FF D6
Loc_D6FB:
  LSR                                   ; $D6FB: 4A
  LSR                                   ; $D6FC: 4A
  LSR                                   ; $D6FD: 4A
  LSR                                   ; $D6FE: 4A
Loc_D6FF:
  STA $00                               ; $D6FF: 85 00
  LDA $10                               ; $D701: A5 10
  SEC                                   ; $D703: 38
  SBC $00                               ; $D704: E5 00
  CMP #$10                              ; $D706: C9 10
  BCS $D6CF                             ; $D708: B0 C5
  LDY #$00                              ; $D70A: A0 00
  LDA $10                               ; $D70C: A5 10
  CMP #$10                              ; $D70E: C9 10
  BCC $D714                             ; $D710: 90 02
  LDY #$01                              ; $D712: A0 01
Loc_D714:
  LDA $11                               ; $D714: A5 11
  CMP #$10                              ; $D716: C9 10
  BCC $D71E                             ; $D718: 90 04
  TYA                                   ; $D71A: 98
  ORA #$02                              ; $D71B: 09 02
  TAY                                   ; $D71D: A8
Loc_D71E:
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
  JSR $EE07                             ; $D72E: 20 07 EE
; --- Data Region ---
  .byte $12,$A0,$A5,$10,$29,$0F,$85,$08,$A2,$00,$A5,$11,$0A,$0A,$0A,$0A; $D731: 12 A0 A5 10 29 0F 85 08 A2 00 A5 11 0A 0A 0A 0A
  .byte $48                               ; $D741: 48
Loc_D742:
; --- Code Region ---
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
  BEQ $D7DB                             ; $D7AC: F0 2D
  LDA $0509                             ; $D7AE: AD 09 05
  STA $00                               ; $D7B1: 85 00
  LDY #$37                              ; $D7B3: A0 37
  JSR $EE07                             ; $D7B5: 20 07 EE
; --- Data Region ---
  .byte $18,$A0,$A9,$B0,$85,$00,$A9,$01,$85,$01,$A0,$00,$B1,$00,$8D,$83; $D7B8: 18 A0 A9 B0 85 00 A9 01 85 01 A0 00 B1 00 8D 83
  .byte $03,$C8,$B1,$00,$8D,$84,$03,$C8,$B1,$00,$8D,$88,$03,$C8,$B1,$00; $D7C8: 03 C8 B1 00 8D 84 03 C8 B1 00 8D 88 03 C8 B1 00
  .byte $8D,$89,$03                       ; $D7D8: 8D 89 03
Loc_D7DB:
; --- Code Region ---
  PLA                                   ; $D7DB: 68
  STA $00                               ; $D7DC: 85 00
  LDY #$37                              ; $D7DE: A0 37
  JSR $EE07                             ; $D7E0: 20 07 EE
; --- Data Region ---
  .byte $15,$A0,$A5,$10,$29,$0E,$4A,$85,$08,$A5,$11,$29,$0E,$0A,$0A,$05; $D7E3: 15 A0 A5 10 29 0E 4A 85 08 A5 11 29 0E 0A 0A 05
  .byte $08,$A8,$B1,$00,$85,$0A,$68,$85,$00,$A5,$8E,$18,$69,$04,$90,$05; $D7F3: 08 A8 B1 00 85 0A 68 85 00 A5 8E 18 69 04 90 05
  .byte $A9,$10,$4C,$0C,$D8               ; $D803: A9 10 4C 0C D8
Loc_D808:
; --- Code Region ---
  LSR                                   ; $D808: 4A
  LSR                                   ; $D809: 4A
  LSR                                   ; $D80A: 4A
  LSR                                   ; $D80B: 4A
Loc_D80C:
  TAX                                   ; $D80C: AA
  AND #$01                              ; $D80D: 29 01
  BEQ $D856                             ; $D80F: F0 45
  TXA                                   ; $D811: 8A
  AND #$1F                              ; $D812: 29 1F
  STA $04                               ; $D814: 85 04
  LDA $10                               ; $D816: A5 10
  SEC                                   ; $D818: 38
  SBC $04                               ; $D819: E5 04
  BNE $D839                             ; $D81B: D0 1C
  LDA $0A                               ; $D81D: A5 0A
  AND #$CC                              ; $D81F: 29 CC
  STA $0A                               ; $D821: 85 0A
  TYA                                   ; $D823: 98
  PHA                                   ; $D824: 48
  LDY #$37                              ; $D825: A0 37
  JSR $EE07                             ; $D827: 20 07 EE
; --- Data Region ---
  .byte $15,$A0,$68,$A8,$B1,$00,$29,$33,$05,$0A,$85,$0A,$4C,$56,$D8; $D82A: 15 A0 68 A8 B1 00 29 33 05 0A 85 0A 4C 56 D8
Loc_D839:
; --- Code Region ---
  CMP #$0F                              ; $D839: C9 0F
  BNE $D856                             ; $D83B: D0 19
  LDA $0A                               ; $D83D: A5 0A
  AND #$33                              ; $D83F: 29 33
  STA $0A                               ; $D841: 85 0A
  TYA                                   ; $D843: 98
  PHA                                   ; $D844: 48
  LDY #$37                              ; $D845: A0 37
  JSR $EE07                             ; $D847: 20 07 EE
; --- Data Region ---
  .byte $15,$A0,$68,$A8,$B1,$00,$29,$CC,$05,$0A,$85,$0A; $D84A: 15 A0 68 A8 B1 00 29 CC 05 0A 85 0A
Loc_D856:
; --- Code Region ---
  LDA $0A                               ; $D856: A5 0A
  STA $00                               ; $D858: 85 00
  JSR $D88E                             ; $D85A: 20 8E D8
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
Loc_D88E:
  LDA $10                               ; $D88E: A5 10
  AND #$1E                              ; $D890: 29 1E
  STA $02                               ; $D892: 85 02
  LDA $11                               ; $D894: A5 11
  AND #$1E                              ; $D896: 29 1E
  STA $03                               ; $D898: 85 03
  LDY #$13                              ; $D89A: A0 13
Loc_D89C:
  LDA $12                               ; $D89C: A5 12
  BNE $D8A5                             ; $D89E: D0 05
  CPY $0509                             ; $D8A0: CC 09 05
  BEQ $D8A8                             ; $D8A3: F0 03
Loc_D8A5:
  JSR $D8AC                             ; $D8A5: 20 AC D8
Loc_D8A8:
  DEY                                   ; $D8A8: 88
  BPL $D89C                             ; $D8A9: 10 F1
  RTS                                   ; $D8AB: 60
Loc_D8AC:
  LDA $8E                               ; $D8AC: A5 8E
  CLC                                   ; $D8AE: 18
  ADC #$04                              ; $D8AF: 69 04
  BCC $D8B8                             ; $D8B1: 90 05
  LDA #$10                              ; $D8B3: A9 10
  JMP $D8BC                             ; $D8B5: 4C BC D8
Loc_D8B8:
  LSR                                   ; $D8B8: 4A
  LSR                                   ; $D8B9: 4A
  LSR                                   ; $D8BA: 4A
  LSR                                   ; $D8BB: 4A
Loc_D8BC:
  TAX                                   ; $D8BC: AA
  AND #$01                              ; $D8BD: 29 01
  BEQ $D8D7                             ; $D8BF: F0 16
  TXA                                   ; $D8C1: 8A
  AND #$1F                              ; $D8C2: 29 1F
  STA $04                               ; $D8C4: 85 04
  LDA $10                               ; $D8C6: A5 10
  SEC                                   ; $D8C8: 38
  SBC $04                               ; $D8C9: E5 04
  BNE $D8D0                             ; $D8CB: D0 03
  JMP $D9A7                             ; $D8CD: 4C A7 D9
Loc_D8D0:
  CMP #$0F                              ; $D8D0: C9 0F
  BNE $D8D7                             ; $D8D2: D0 03
  JMP $D938                             ; $D8D4: 4C 38 D9
Loc_D8D7:
  LDA $02                               ; $D8D7: A5 02
  CMP $0600,Y                           ; $D8D9: D9 00 06
  BNE $D8ED                             ; $D8DC: D0 0F
  LDA $03                               ; $D8DE: A5 03
  CMP $0614,Y                           ; $D8E0: D9 14 06
  BNE $D8ED                             ; $D8E3: D0 08
  LDA $00                               ; $D8E5: A5 00
  AND #$FC                              ; $D8E7: 29 FC
  ORA #$02                              ; $D8E9: 09 02
  STA $00                               ; $D8EB: 85 00
Loc_D8ED:
  INC $02                               ; $D8ED: E6 02
  LDA $02                               ; $D8EF: A5 02
  CMP $0600,Y                           ; $D8F1: D9 00 06
  BNE $D905                             ; $D8F4: D0 0F
  LDA $03                               ; $D8F6: A5 03
  CMP $0614,Y                           ; $D8F8: D9 14 06
  BNE $D905                             ; $D8FB: D0 08
  LDA $00                               ; $D8FD: A5 00
  AND #$F3                              ; $D8FF: 29 F3
  ORA #$08                              ; $D901: 09 08
  STA $00                               ; $D903: 85 00
Loc_D905:
  INC $03                               ; $D905: E6 03
  LDA $02                               ; $D907: A5 02
  CMP $0600,Y                           ; $D909: D9 00 06
  BNE $D91D                             ; $D90C: D0 0F
  LDA $03                               ; $D90E: A5 03
  CMP $0614,Y                           ; $D910: D9 14 06
  BNE $D91D                             ; $D913: D0 08
  LDA $00                               ; $D915: A5 00
  AND #$3F                              ; $D917: 29 3F
  ORA #$80                              ; $D919: 09 80
  STA $00                               ; $D91B: 85 00
Loc_D91D:
  DEC $02                               ; $D91D: C6 02
  LDA $02                               ; $D91F: A5 02
  CMP $0600,Y                           ; $D921: D9 00 06
  BNE $D935                             ; $D924: D0 0F
  LDA $03                               ; $D926: A5 03
  CMP $0614,Y                           ; $D928: D9 14 06
  BNE $D935                             ; $D92B: D0 08
  LDA $00                               ; $D92D: A5 00
  AND #$CF                              ; $D92F: 29 CF
  ORA #$20                              ; $D931: 09 20
  STA $00                               ; $D933: 85 00
Loc_D935:
  DEC $03                               ; $D935: C6 03
  RTS                                   ; $D937: 60
Loc_D938:
  LDA $10                               ; $D938: A5 10
  STA $02                               ; $D93A: 85 02
  LDA $02                               ; $D93C: A5 02
  CMP $0600,Y                           ; $D93E: D9 00 06
  BNE $D952                             ; $D941: D0 0F
  LDA $03                               ; $D943: A5 03
  CMP $0614,Y                           ; $D945: D9 14 06
  BNE $D952                             ; $D948: D0 08
  LDA $00                               ; $D94A: A5 00
  AND #$FC                              ; $D94C: 29 FC
  ORA #$02                              ; $D94E: 09 02
  STA $00                               ; $D950: 85 00
Loc_D952:
  INC $03                               ; $D952: E6 03
  LDA $02                               ; $D954: A5 02
  CMP $0600,Y                           ; $D956: D9 00 06
  BNE $D96A                             ; $D959: D0 0F
  LDA $03                               ; $D95B: A5 03
  CMP $0614,Y                           ; $D95D: D9 14 06
  BNE $D96A                             ; $D960: D0 08
  LDA $00                               ; $D962: A5 00
  AND #$CF                              ; $D964: 29 CF
  ORA #$20                              ; $D966: 09 20
  STA $00                               ; $D968: 85 00
Loc_D96A:
  LDA $02                               ; $D96A: A5 02
  SEC                                   ; $D96C: 38
  SBC #$0F                              ; $D96D: E9 0F
  STA $02                               ; $D96F: 85 02
  LDA $02                               ; $D971: A5 02
  CMP $0600,Y                           ; $D973: D9 00 06
  BNE $D987                             ; $D976: D0 0F
  LDA $03                               ; $D978: A5 03
  CMP $0614,Y                           ; $D97A: D9 14 06
  BNE $D987                             ; $D97D: D0 08
  LDA $00                               ; $D97F: A5 00
  AND #$3F                              ; $D981: 29 3F
  ORA #$80                              ; $D983: 09 80
  STA $00                               ; $D985: 85 00
Loc_D987:
  DEC $03                               ; $D987: C6 03
  LDA $02                               ; $D989: A5 02
  CMP $0600,Y                           ; $D98B: D9 00 06
  BNE $D99F                             ; $D98E: D0 0F
  LDA $03                               ; $D990: A5 03
  CMP $0614,Y                           ; $D992: D9 14 06
  BNE $D99F                             ; $D995: D0 08
  LDA $00                               ; $D997: A5 00
  AND #$F3                              ; $D999: 29 F3
  ORA #$08                              ; $D99B: 09 08
  STA $00                               ; $D99D: 85 00
Loc_D99F:
  LDA $02                               ; $D99F: A5 02
  CLC                                   ; $D9A1: 18
  ADC #$0F                              ; $D9A2: 69 0F
  STA $02                               ; $D9A4: 85 02
  RTS                                   ; $D9A6: 60
Loc_D9A7:
  LDA $10                               ; $D9A7: A5 10
  STA $02                               ; $D9A9: 85 02
  LDA $02                               ; $D9AB: A5 02
  CLC                                   ; $D9AD: 18
  ADC #$0F                              ; $D9AE: 69 0F
  STA $02                               ; $D9B0: 85 02
  LDA $02                               ; $D9B2: A5 02
  CMP $0600,Y                           ; $D9B4: D9 00 06
  BNE $D9C8                             ; $D9B7: D0 0F
  LDA $03                               ; $D9B9: A5 03
  CMP $0614,Y                           ; $D9BB: D9 14 06
  BNE $D9C8                             ; $D9BE: D0 08
  LDA $00                               ; $D9C0: A5 00
  AND #$FC                              ; $D9C2: 29 FC
  ORA #$02                              ; $D9C4: 09 02
  STA $00                               ; $D9C6: 85 00
Loc_D9C8:
  INC $03                               ; $D9C8: E6 03
  LDA $02                               ; $D9CA: A5 02
  CMP $0600,Y                           ; $D9CC: D9 00 06
  BNE $D9E0                             ; $D9CF: D0 0F
  LDA $03                               ; $D9D1: A5 03
  CMP $0614,Y                           ; $D9D3: D9 14 06
  BNE $D9E0                             ; $D9D6: D0 08
  LDA $00                               ; $D9D8: A5 00
  AND #$CF                              ; $D9DA: 29 CF
  ORA #$20                              ; $D9DC: 09 20
  STA $00                               ; $D9DE: 85 00
Loc_D9E0:
  LDA $02                               ; $D9E0: A5 02
  SEC                                   ; $D9E2: 38
  SBC #$0F                              ; $D9E3: E9 0F
  STA $02                               ; $D9E5: 85 02
  LDA $02                               ; $D9E7: A5 02
  CMP $0600,Y                           ; $D9E9: D9 00 06
  BNE $D9FE                             ; $D9EC: D0 10
  LDA $03                               ; $D9EE: A5 03
  CMP $0614,Y                           ; $D9F0: D9 14 06
  BNE $D9FE                             ; $D9F3: D0 09
  LDA $00                               ; $D9F5: A5 00
  AND #$3F                              ; $D9F7: 29 3F
  ORA #$80                              ; $D9F9: 09 80
  STA $0000                             ; $D9FB: 8D 00 00
Loc_D9FE:
  DEC $03                               ; $D9FE: C6 03
  LDA $02                               ; $DA00: A5 02
  CMP $0600,Y                           ; $DA02: D9 00 06
  BNE $DA16                             ; $DA05: D0 0F
  LDA $03                               ; $DA07: A5 03
  CMP $0614,Y                           ; $DA09: D9 14 06
  BNE $DA16                             ; $DA0C: D0 08
  LDA $00                               ; $DA0E: A5 00
  AND #$F3                              ; $DA10: 29 F3
  ORA #$08                              ; $DA12: 09 08
  STA $00                               ; $DA14: 85 00
Loc_DA16:
  RTS                                   ; $DA16: 60
Loc_DA17:
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
Loc_DA5A:
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
Loc_DA83:
  LDA #$00                              ; $DA83: A9 00
  STA $000A                             ; $DA85: 8D 0A 00
  STA $000B                             ; $DA88: 8D 0B 00
  STA $000C                             ; $DA8B: 8D 0C 00
  LDX #$13                              ; $DA8E: A2 13
Loc_DA90:
  LDA $0628,X                           ; $DA90: BD 28 06
  BMI $DABF                             ; $DA93: 30 2A
  LDA $0664,X                           ; $DA95: BD 64 06
  CMP #$FF                              ; $DA98: C9 FF
  BEQ $DABF                             ; $DA9A: F0 23
  JSR $F2D7                             ; $DA9C: 20 D7 F2
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
Loc_DABF:
  DEX                                   ; $DABF: CA
  BPL $DA90                             ; $DAC0: 10 CE
  RTS                                   ; $DAC2: 60
Loc_DAC3:
  LDA #$00                              ; $DAC3: A9 00
  STA $000A                             ; $DAC5: 8D 0A 00
  STA $000B                             ; $DAC8: 8D 0B 00
  STA $000C                             ; $DACB: 8D 0C 00
  LDX #$13                              ; $DACE: A2 13
Loc_DAD0:
  LDA $0628,X                           ; $DAD0: BD 28 06
  BPL $DAFF                             ; $DAD3: 10 2A
  LDA $0664,X                           ; $DAD5: BD 64 06
  CMP #$FF                              ; $DAD8: C9 FF
  BEQ $DAFF                             ; $DADA: F0 23
  JSR $F2D7                             ; $DADC: 20 D7 F2
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
Loc_DAFF:
  DEX                                   ; $DAFF: CA
  BPL $DAD0                             ; $DB00: 10 CE
  RTS                                   ; $DB02: 60
Loc_DB03:
  LDY #$31                              ; $DB03: A0 31
  JSR $F25F                             ; $DB05: 20 5F F2
  LDX #$13                              ; $DB08: A2 13
Loc_DB0A:
  LDA $0664,X                           ; $DB0A: BD 64 06
  CMP #$FF                              ; $DB0D: C9 FF
  BEQ $DB3F                             ; $DB0F: F0 2E
  JSR $F2D7                             ; $DB11: 20 D7 F2
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
  JSR $EAA5                             ; $DB37: 20 A5 EA
  PLA                                   ; $DB3A: 68
  TAX                                   ; $DB3B: AA
  LDA $0000                             ; $DB3C: AD 00 00
Loc_DB3F:
  STA $063C,X                           ; $DB3F: 9D 3C 06
  DEX                                   ; $DB42: CA
  BPL $DB0A                             ; $DB43: 10 C5
  RTS                                   ; $DB45: 60
Loc_DB46:
  JSR $DB50                             ; $DB46: 20 50 DB
  CMP #$06                              ; $DB49: C9 06
  BCC $DB4F                             ; $DB4B: 90 02
  LDA #$02                              ; $DB4D: A9 02
Loc_DB4F:
  RTS                                   ; $DB4F: 60
Loc_DB50:
  LDY #$00                              ; $DB50: A0 00
  LDA $0010                             ; $DB52: AD 10 00
  CMP #$10                              ; $DB55: C9 10
  BCC $DB5B                             ; $DB57: 90 02
  LDY #$01                              ; $DB59: A0 01
Loc_DB5B:
  LDA $0011                             ; $DB5B: AD 11 00
  CMP #$10                              ; $DB5E: C9 10
  BCC $DB66                             ; $DB60: 90 04
  TYA                                   ; $DB62: 98
  ORA #$02                              ; $DB63: 09 02
  TAY                                   ; $DB65: A8
Loc_DB66:
  LDA ($A8),Y                           ; $DB66: B1 A8
  STA $0000                             ; $DB68: 8D 00 00
  LDY #$37                              ; $DB6B: A0 37
  JSR $EE07                             ; $DB6D: 20 07 EE
; --- Data Region ---
  .byte $12,$A0,$A9,$9E,$8D,$02,$00,$A9,$DB,$8D,$03,$00,$AD,$10,$00,$29; $DB70: 12 A0 A9 9E 8D 02 00 A9 DB 8D 03 00 AD 10 00 29
  .byte $0F,$8D,$08,$00,$A2,$00,$AD,$11,$00,$0A,$0A,$0A,$0A,$0D,$08,$00; $DB80: 0F 8D 08 00 A2 00 AD 11 00 0A 0A 0A 0A 0D 08 00
  .byte $A8,$B1,$00,$A8,$C9,$80,$90,$03,$A9,$00,$60; $DB90: A8 B1 00 A8 C9 80 90 03 A9 00 60
Loc_DB9B:
; --- Code Region ---
  LDA ($02),Y                           ; $DB9B: B1 02
  RTS                                   ; $DB9D: 60
; --- Data Region ---
  .byte $00,$01,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03; $DB9E: 00 01 03 03 03 03 03 03 03 03 03 03 03 03 03 03
  .byte $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$02,$02,$02,$02; $DBAE: 03 03 03 03 03 03 03 03 03 03 03 03 02 02 02 02
  .byte $04,$04,$02,$04,$04,$02,$04,$02,$04,$04,$04,$02,$00,$00,$02,$02; $DBBE: 04 04 02 04 04 02 04 02 04 04 04 02 00 00 02 02
  .byte $02,$02,$02,$02,$02,$02,$00,$00,$00,$02,$00,$00,$00,$00,$00,$00; $DBCE: 02 02 02 02 02 02 00 00 00 02 00 00 00 00 00 00
  .byte $03,$03,$03,$03,$03,$03,$03,$03,$02,$00,$00,$00,$02,$02,$02,$02; $DBDE: 03 03 03 03 03 03 03 03 02 00 00 00 02 02 02 02
  .byte $02,$02,$02,$02,$02,$02,$04,$02,$02,$04,$02,$04,$04,$04,$03,$00; $DBEE: 02 02 02 02 02 02 04 02 02 04 02 04 04 04 03 00
  .byte $00,$05,$05,$05,$05,$03,$00,$03,$03,$03,$01,$01,$01,$01,$02,$02; $DBFE: 00 05 05 05 05 03 00 03 03 03 01 01 01 01 02 02
  .byte $01,$02,$02,$02,$01,$02,$02,$03,$03,$06,$07,$08,$00,$00,$00,$00; $DC0E: 01 02 02 02 01 02 02 03 03 06 07 08 00 00 00 00
Loc_DC1E:
; --- Code Region ---
  LDY #$13                              ; $DC1E: A0 13
Loc_DC20:
  LDA $0664,Y                           ; $DC20: B9 64 06
  CMP #$FF                              ; $DC23: C9 FF
  BNE $DC2F                             ; $DC25: D0 08
  LDA #$FF                              ; $DC27: A9 FF
  STA $0600,Y                           ; $DC29: 99 00 06
  STA $0614,Y                           ; $DC2C: 99 14 06
Loc_DC2F:
  DEY                                   ; $DC2F: 88
  BPL $DC20                             ; $DC30: 10 EE
  RTS                                   ; $DC32: 60
Loc_DC33:
  LDY $0509                             ; $DC33: AC 09 05
Loc_DC36:
  LDA $0664,Y                           ; $DC36: B9 64 06
  STA $0000                             ; $DC39: 8D 00 00
  LDA #$A7                              ; $DC3C: A9 A7
  STA $000A                             ; $DC3E: 8D 0A 00
  LDX #$00                              ; $DC41: A2 00
  LDY #$39                              ; $DC43: A0 39
  JSR $EE07                             ; $DC45: 20 07 EE
; --- Data Region ---
  .byte $00,$A0,$60,$AD,$04,$05,$30,$0B,$B9,$28,$06,$30,$03,$A9,$00,$60; $DC48: 00 A0 60 AD 04 05 30 0B B9 28 06 30 03 A9 00 60
Loc_DC58:
; --- Code Region ---
  LDA #$FF                              ; $DC58: A9 FF
  RTS                                   ; $DC5A: 60
Loc_DC5B:
  LDA $0628,Y                           ; $DC5B: B9 28 06
  BPL $DC58                             ; $DC5E: 10 F8
  LDA #$00                              ; $DC60: A9 00
  RTS                                   ; $DC62: 60
Loc_DC63:
  LDA #$D8                              ; $DC63: A9 D8
  STA $000A                             ; $DC65: 8D 0A 00
  LDA #$A0                              ; $DC68: A9 A0
  STA $000C                             ; $DC6A: 8D 0C 00
  JMP $DC7A                             ; $DC6D: 4C 7A DC
Loc_DC70:
  LDA #$E0                              ; $DC70: A9 E0
  STA $000A                             ; $DC72: 8D 0A 00
  LDA #$A0                              ; $DC75: A9 A0
  STA $000C                             ; $DC77: 8D 0C 00
Loc_DC7A:
  LDA $005E                             ; $DC7A: AD 5E 00
  AND #$10                              ; $DC7D: 29 10
  BNE $DC93                             ; $DC7F: D0 12
  LDA #$94                              ; $DC81: A9 94
  STA $0000                             ; $DC83: 8D 00 00
  LDA #$DC                              ; $DC86: A9 DC
  STA $0001                             ; $DC88: 8D 01 00
  LDA #$00                              ; $DC8B: A9 00
  STA $0002                             ; $DC8D: 8D 02 00
  JMP $F1AD                             ; $DC90: 4C AD F1
Loc_DC93:
  RTS                                   ; $DC93: 60
; --- Data Region ---
  .byte $00,$04,$00,$00,$80               ; $DC94: 00 04 00 00 80
Loc_DC99:
; --- Code Region ---
  LDY #$31                              ; $DC99: A0 31
  JSR $F25F                             ; $DC9B: 20 5F F2
  LDA $0402                             ; $DC9E: AD 02 04
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
  BCS $DCBF                             ; $DCB5: B0 08
  LDA #$00                              ; $DCB7: A9 00
  STA $0512                             ; $DCB9: 8D 12 05
  STA $0513                             ; $DCBC: 8D 13 05
Loc_DCBF:
  LDA $0513                             ; $DCBF: AD 13 05
  BEQ $DCCE                             ; $DCC2: F0 0A
  LDA #$FE                              ; $DCC4: A9 FE
  STA $0512                             ; $DCC6: 8D 12 05
  LDA #$00                              ; $DCC9: A9 00
  STA $0513                             ; $DCCB: 8D 13 05
Loc_DCCE:
  LDA $9D58,Y                           ; $DCCE: B9 58 9D
  SEC                                   ; $DCD1: 38
  SBC #$60                              ; $DCD2: E9 60
  STA $0510                             ; $DCD4: 8D 10 05
  LDA $9D59,Y                           ; $DCD7: B9 59 9D
  SBC #$00                              ; $DCDA: E9 00
  STA $0511                             ; $DCDC: 8D 11 05
  BCS $DCE9                             ; $DCDF: B0 08
  LDA #$00                              ; $DCE1: A9 00
  STA $0510                             ; $DCE3: 8D 10 05
  STA $0511                             ; $DCE6: 8D 11 05
Loc_DCE9:
  LDA $0510                             ; $DCE9: AD 10 05
  CMP #$90                              ; $DCEC: C9 90
  BCC $DCFA                             ; $DCEE: 90 0A
  LDA #$8E                              ; $DCF0: A9 8E
  STA $0510                             ; $DCF2: 8D 10 05
  LDA #$00                              ; $DCF5: A9 00
  STA $0511                             ; $DCF7: 8D 11 05
Loc_DCFA:
  LDA $0402                             ; $DCFA: AD 02 04
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
Loc_DD29:
  STA $6F47,Y                           ; $DD29: 99 47 6F
  DEY                                   ; $DD2C: 88
  BPL $DD29                             ; $DD2D: 10 FA
  LDX #$13                              ; $DD2F: A2 13
Loc_DD31:
  LDA $0664,X                           ; $DD31: BD 64 06
  CMP #$FF                              ; $DD34: C9 FF
  BEQ $DD5C                             ; $DD36: F0 24
  JSR $F2D7                             ; $DD38: 20 D7 F2
  LDA #$FF                              ; $DD3B: A9 FF
  STA $0600,X                           ; $DD3D: 9D 00 06
  STA $0614,X                           ; $DD40: 9D 14 06
  LDY #$0B                              ; $DD43: A0 0B
  LDA ($00),Y                           ; $DD45: B1 00
  LSR                                   ; $DD47: 4A
  LSR                                   ; $DD48: 4A
  AND #$03                              ; $DD49: 29 03
  CPX #$0A                              ; $DD4B: E0 0A
  BCC $DD51                             ; $DD4D: 90 02
  ORA #$80                              ; $DD4F: 09 80
Loc_DD51:
  STA $0628,X                           ; $DD51: 9D 28 06
  LDA #$00                              ; $DD54: A9 00
  STA $0650,X                           ; $DD56: 9D 50 06
  JMP $DD6B                             ; $DD59: 4C 6B DD
Loc_DD5C:
  STA $0600,X                           ; $DD5C: 9D 00 06
  STA $0614,X                           ; $DD5F: 9D 14 06
  STA $0628,X                           ; $DD62: 9D 28 06
  STA $063C,X                           ; $DD65: 9D 3C 06
  STA $0650,X                           ; $DD68: 9D 50 06
Loc_DD6B:
  DEX                                   ; $DD6B: CA
  BPL $DD31                             ; $DD6C: 10 C3
  JSR $DB03                             ; $DD6E: 20 03 DB
  RTS                                   ; $DD71: 60
; --- Data Region ---
  .byte $A2,$00,$AD,$64,$06,$C9,$FF,$F0,$05,$AD,$28,$06,$10,$0F; $DD72: A2 00 AD 64 06 C9 FF F0 05 AD 28 06 10 0F
Loc_DD80:
; --- Code Region ---
  LDA #$00                              ; $DD80: A9 00
  STA $0514                             ; $DD82: 8D 14 05
  LDA $052B                             ; $DD85: AD 2B 05
  CMP #$FF                              ; $DD88: C9 FF
  BNE $DDAC                             ; $DD8A: D0 20
  JMP $DDB9                             ; $DD8C: 4C B9 DD
Loc_DD8F:
  INX                                   ; $DD8F: E8
  LDA $066E                             ; $DD90: AD 6E 06
  CMP #$FF                              ; $DD93: C9 FF
  BEQ $DD9C                             ; $DD95: F0 05
  LDA $0632                             ; $DD97: AD 32 06
  BMI $DDAB                             ; $DD9A: 30 0F
Loc_DD9C:
  LDA #$01                              ; $DD9C: A9 01
  STA $0514                             ; $DD9E: 8D 14 05
  LDA $052B                             ; $DDA1: AD 2B 05
  CMP #$FF                              ; $DDA4: C9 FF
  BNE $DDAC                             ; $DDA6: D0 04
  JMP $DE14                             ; $DDA8: 4C 14 DE
Loc_DDAB:
  RTS                                   ; $DDAB: 60
Loc_DDAC:
  LDA #$0C                              ; $DDAC: A9 0C
  STA $0500                             ; $DDAE: 8D 00 05
  LDA #$00                              ; $DDB1: A9 00
  STA $0501                             ; $DDB3: 8D 01 05
  PLA                                   ; $DDB6: 68
  PLA                                   ; $DDB7: 68
  RTS                                   ; $DDB8: 60
Loc_DDB9:
  LDA #$07                              ; $DDB9: A9 07
  STA $0500                             ; $DDBB: 8D 00 05
  LDA #$02                              ; $DDBE: A9 02
  STA $0501                             ; $DDC0: 8D 01 05
  PLA                                   ; $DDC3: 68
  PLA                                   ; $DDC4: 68
  LDA $0507                             ; $DDC5: AD 07 05
  AND #$0F                              ; $DDC8: 29 0F
  STA $042C                             ; $DDCA: 8D 2C 04
  LDA #$00                              ; $DDCD: A9 00
  JSR $DE82                             ; $DDCF: 20 82 DE
  BCS $DDD7                             ; $DDD2: B0 03
  JMP $DE6D                             ; $DDD4: 4C 6D DE
Loc_DDD7:
  STY $0509                             ; $DDD7: 8C 09 05
  LDA $0507                             ; $DDDA: AD 07 05
  LSR                                   ; $DDDD: 4A
  LSR                                   ; $DDDE: 4A
  LSR                                   ; $DDDF: 4A
  LSR                                   ; $DDE0: 4A
  JSR $F368                             ; $DDE1: 20 68 F3
  LDY #$03                              ; $DDE4: A0 03
  LDA ($00),Y                           ; $DDE6: B1 00
  CMP #$03                              ; $DDE8: C9 03
  BNE $DDF7                             ; $DDEA: D0 0B
  LDA #$04                              ; $DDEC: A9 04
  STA $00A4                             ; $DDEE: 8D A4 00
  LDA #$54                              ; $DDF1: A9 54
  STA $050A                             ; $DDF3: 8D 0A 05
  RTS                                   ; $DDF6: 60
Loc_DDF7:
  STA $6F44                             ; $DDF7: 8D 44 6F
  LDA $0507                             ; $DDFA: AD 07 05
  LSR                                   ; $DDFD: 4A
  LSR                                   ; $DDFE: 4A
  LSR                                   ; $DDFF: 4A
  LSR                                   ; $DE00: 4A
  STA $042C                             ; $DE01: 8D 2C 04
  LDA #$0A                              ; $DE04: A9 0A
  STA $0509                             ; $DE06: 8D 09 05
  LDA #$03                              ; $DE09: A9 03
  STA $00A4                             ; $DE0B: 8D A4 00
  LDA #$53                              ; $DE0E: A9 53
  STA $050A                             ; $DE10: 8D 0A 05
  RTS                                   ; $DE13: 60
Loc_DE14:
  LDA #$07                              ; $DE14: A9 07
  STA $0500                             ; $DE16: 8D 00 05
  LDA #$02                              ; $DE19: A9 02
  STA $0501                             ; $DE1B: 8D 01 05
  PLA                                   ; $DE1E: 68
  PLA                                   ; $DE1F: 68
Loc_DE20:  ; (dispatch callback target)
  LDA $0507                             ; $DE20: AD 07 05
  LSR                                   ; $DE23: 4A
  LSR                                   ; $DE24: 4A
  LSR                                   ; $DE25: 4A
  LSR                                   ; $DE26: 4A
  STA $042C                             ; $DE27: 8D 2C 04
  LDA #$80                              ; $DE2A: A9 80
  JSR $DE82                             ; $DE2C: 20 82 DE
  BCS $DE34                             ; $DE2F: B0 03
  JMP $DE6D                             ; $DE31: 4C 6D DE
Loc_DE34:
  STY $0509                             ; $DE34: 8C 09 05
  LDA $0507                             ; $DE37: AD 07 05
  AND #$0F                              ; $DE3A: 29 0F
  JSR $F368                             ; $DE3C: 20 68 F3
  LDY #$03                              ; $DE3F: A0 03
  LDA ($00),Y                           ; $DE41: B1 00
  CMP #$03                              ; $DE43: C9 03
  BNE $DE52                             ; $DE45: D0 0B
  LDA #$04                              ; $DE47: A9 04
  STA $00A4                             ; $DE49: 8D A4 00
  LDA #$54                              ; $DE4C: A9 54
  STA $050A                             ; $DE4E: 8D 0A 05
  RTS                                   ; $DE51: 60
Loc_DE52:
  STA $6F44                             ; $DE52: 8D 44 6F
  LDA $0507                             ; $DE55: AD 07 05
  AND #$0F                              ; $DE58: 29 0F
  STA $042C                             ; $DE5A: 8D 2C 04
  LDA #$00                              ; $DE5D: A9 00
  STA $0509                             ; $DE5F: 8D 09 05
  LDA #$03                              ; $DE62: A9 03
  STA $00A4                             ; $DE64: 8D A4 00
  LDA #$53                              ; $DE67: A9 53
  STA $050A                             ; $DE69: 8D 0A 05
  RTS                                   ; $DE6C: 60
Loc_DE6D:
  LDA $042C                             ; $DE6D: AD 2C 04
  JSR $F368                             ; $DE70: 20 68 F3
  LDY #$00                              ; $DE73: A0 00
  LDA ($00),Y                           ; $DE75: B1 00
  STA $042C                             ; $DE77: 8D 2C 04
  INC $0501                             ; $DE7A: EE 01 05
  LDA #$55                              ; $DE7D: A9 55
  JMP $F293                             ; $DE7F: 4C 93 F2
Loc_DE82:
  STA $0002                             ; $DE82: 8D 02 00
  LDY #$00                              ; $DE85: A0 00
Loc_DE87:
  LDA $0628,Y                           ; $DE87: B9 28 06
  CMP #$FF                              ; $DE8A: C9 FF
  BEQ $DE95                             ; $DE8C: F0 07
  AND #$80                              ; $DE8E: 29 80
  CMP $0002                             ; $DE90: CD 02 00
  BEQ $DE9C                             ; $DE93: F0 07
Loc_DE95:
  INY                                   ; $DE95: C8
  CPY #$14                              ; $DE96: C0 14
  BCC $DE87                             ; $DE98: 90 ED
  CLC                                   ; $DE9A: 18
  RTS                                   ; $DE9B: 60
Loc_DE9C:
  SEC                                   ; $DE9C: 38
  RTS                                   ; $DE9D: 60
Loc_DE9E:
  LDY #$30                              ; $DE9E: A0 30
  JSR $F25F                             ; $DEA0: 20 5F F2
  LDA $050E                             ; $DEA3: AD 0E 05
  ASL                                   ; $DEA6: 0A
  ASL                                   ; $DEA7: 0A
  ASL                                   ; $DEA8: 0A
  TAY                                   ; $DEA9: A8
Loc_DEAA:
  LDA $9D72,Y                           ; $DEAA: B9 72 9D
  BMI $DEBC                             ; $DEAD: 30 0D
  CMP $052A                             ; $DEAF: CD 2A 05
  BEQ $DEB8                             ; $DEB2: F0 04
  INY                                   ; $DEB4: C8
  JMP $DEAA                             ; $DEB5: 4C AA DE
Loc_DEB8:
  LDA $9E62,Y                           ; $DEB8: B9 62 9E
  RTS                                   ; $DEBB: 60
Loc_DEBC:
  LDA #$00                              ; $DEBC: A9 00
  RTS                                   ; $DEBE: 60
Loc_DEBF:
  LDY #$30                              ; $DEBF: A0 30
  JSR $F25F                             ; $DEC1: 20 5F F2
  LDA $050E                             ; $DEC4: AD 0E 05
  ASL                                   ; $DEC7: 0A
  ASL                                   ; $DEC8: 0A
  ASL                                   ; $DEC9: 0A
  TAY                                   ; $DECA: A8
Loc_DECB:
  LDA $9D72,Y                           ; $DECB: B9 72 9D
  BMI $DEE6                             ; $DECE: 30 16
  CMP $052A                             ; $DED0: CD 2A 05
  BEQ $DED9                             ; $DED3: F0 04
  INY                                   ; $DED5: C8
  JMP $DECB                             ; $DED6: 4C CB DE
Loc_DED9:
  TYA                                   ; $DED9: 98
  PHA                                   ; $DEDA: 48
  LDY #$31                              ; $DEDB: A0 31
  JSR $F25F                             ; $DEDD: 20 5F F2
  PLA                                   ; $DEE0: 68
  TAY                                   ; $DEE1: A8
  LDA $9AB4,Y                           ; $DEE2: B9 B4 9A
  RTS                                   ; $DEE5: 60
Loc_DEE6:
  LDA #$00                              ; $DEE6: A9 00
  RTS                                   ; $DEE8: 60
Loc_DEE9:
  LDA $042C                             ; $DEE9: AD 2C 04
  JSR $F2D7                             ; $DEEC: 20 D7 F2
  LDY #$0B                              ; $DEEF: A0 0B
  LDA ($00),Y                           ; $DEF1: B1 00
  AND #$F0                              ; $DEF3: 29 F0
  CMP $052C                             ; $DEF5: CD 2C 05
  BEQ $DF25                             ; $DEF8: F0 2B
  LDY #$01                              ; $DEFA: A0 01
  LDA ($00),Y                           ; $DEFC: B1 00
  SEC                                   ; $DEFE: 38
  SBC $052E                             ; $DEFF: ED 2E 05
  STA $042F                             ; $DF02: 8D 2F 04
  LDA #$00                              ; $DF05: A9 00
  STA $042D                             ; $DF07: 8D 2D 04
  STA $0430                             ; $DF0A: 8D 30 04
  STA $0431                             ; $DF0D: 8D 31 04
  LDY #$28                              ; $DF10: A0 28
  JSR $EE07                             ; $DF12: 20 07 EE
; --- Data Region ---
  .byte $18,$A0,$A9,$4A,$AC,$2F,$04,$D0,$02,$A9,$4D; $DF15: 18 A0 A9 4A AC 2F 04 D0 02 A9 4D
Loc_DF20:
; --- Code Region ---
  JSR $F293                             ; $DF20: 20 93 F2
  SEC                                   ; $DF23: 38
  RTS                                   ; $DF24: 60
Loc_DF25:
  CLC                                   ; $DF25: 18
  RTS                                   ; $DF26: 60
Loc_DF27:
  LDA $0304                             ; $DF27: AD 04 03
  CMP #$FF                              ; $DF2A: C9 FF
  BNE $DF37                             ; $DF2C: D0 09
  LDA $0300                             ; $DF2E: AD 00 03
  CMP #$FF                              ; $DF31: C9 FF
  BNE $DF37                             ; $DF33: D0 02
  SEC                                   ; $DF35: 38
  RTS                                   ; $DF36: 60
Loc_DF37:
  CLC                                   ; $DF37: 18
  RTS                                   ; $DF38: 60
Loc_DF39:
  LDA $0518                             ; $DF39: AD 18 05
  BNE $DF6F                             ; $DF3C: D0 31
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
Loc_DF6F:
  LDA $0518                             ; $DF6F: AD 18 05
  CMP #$01                              ; $DF72: C9 01
  BNE $DF87                             ; $DF74: D0 11
  LDA #$72                              ; $DF76: A9 72
  STA $68                               ; $DF78: 85 68
  LDA #$AF                              ; $DF7A: A9 AF
  STA $69                               ; $DF7C: 85 69
  LDA #$05                              ; $DF7E: A9 05
  STA $61                               ; $DF80: 85 61
  LDA #$FF                              ; $DF82: A9 FF
  STA $0518                             ; $DF84: 8D 18 05
Loc_DF87:
  RTS                                   ; $DF87: 60
Loc_DF88:
  LDA $61                               ; $DF88: A5 61
  CMP #$05                              ; $DF8A: C9 05
  BNE $DF9D                             ; $DF8C: D0 0F
  LDA $8E                               ; $DF8E: A5 8E
  CMP #$10                              ; $DF90: C9 10
  BCS $DF99                             ; $DF92: B0 05
  LDA #$72                              ; $DF94: A9 72
  STA $68                               ; $DF96: 85 68
  RTS                                   ; $DF98: 60
Loc_DF99:
  LDA #$74                              ; $DF99: A9 74
  STA $68                               ; $DF9B: 85 68
Loc_DF9D:
  RTS                                   ; $DF9D: 60
; --- Data Region ---
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DF9E: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DFAE: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DFBE: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DFCE: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DFDE: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DFEE: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF                           ; $DFFE: FF FF
