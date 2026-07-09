Loc_A000:
  JMP $A048                             ; $A000: 4C 48 A0
Loc_A003:
  JMP $A154                             ; $A003: 4C 54 A1
Loc_A006:
  JMP $A11B                             ; $A006: 4C 1B A1
Loc_A009:
  JMP $ABD2                             ; $A009: 4C D2 AB
Loc_A00C:
  JMP $B29F                             ; $A00C: 4C 9F B2
Loc_A00F:
  JMP $B989                             ; $A00F: 4C 89 B9
Loc_A012:
  JMP $BC41                             ; $A012: 4C 41 BC
Loc_A015:  ; (dispatch callback target)
  JMP $DBB1                             ; $A015: 4C B1 DB
Loc_A018:
  JMP $DD8B                             ; $A018: 4C 8B DD
Loc_A01B:
  JMP $DE7E                             ; $A01B: 4C 7E DE
Loc_A01E:
  JMP $A6B6                             ; $A01E: 4C B6 A6
Loc_A021:
  JMP $A77F                             ; $A021: 4C 7F A7
Loc_A024:
  JMP $A7B2                             ; $A024: 4C B2 A7
Loc_A027:
  JMP $A830                             ; $A027: 4C 30 A8
Loc_A02A:
  JMP $A890                             ; $A02A: 4C 90 A8
Loc_A02D:
  JMP $A78A                             ; $A02D: 4C 8A A7
Loc_A030:
  JMP $A8A4                             ; $A030: 4C A4 A8
Loc_A033:
  JMP $A8FD                             ; $A033: 4C FD A8
Loc_A036:
  JMP $BC66                             ; $A036: 4C 66 BC
Loc_A039:
  JMP $BC71                             ; $A039: 4C 71 BC
Loc_A03C:
  JMP $A991                             ; $A03C: 4C 91 A9
Loc_A03F:
  JMP $BE36                             ; $A03F: 4C 36 BE
Loc_A042:
  JMP $AA37                             ; $A042: 4C 37 AA
Loc_A045:
  JMP $DEB9                             ; $A045: 4C B9 DE
Loc_A048:
  LDA $007E                             ; $A048: AD 7E 00
  AND #$04                              ; $A04B: 29 04
  BEQ $A050                             ; $A04D: F0 01
  RTS                                   ; $A04F: 60
Loc_A050:
  LDA $0303                             ; $A050: AD 03 03
  BEQ $A058                             ; $A053: F0 03
  JMP $A0C4                             ; $A055: 4C C4 A0
Loc_A058:
  LDA $0308                             ; $A058: AD 08 03
  BEQ $A060                             ; $A05B: F0 03
  JMP $A0C4                             ; $A05D: 4C C4 A0
Loc_A060:
  LDA $005E                             ; $A060: AD 5E 00
  AND $0305                             ; $A063: 2D 05 03
  BEQ $A06B                             ; $A066: F0 03
  JMP $EE72                             ; $A068: 4C 72 EE
Loc_A06B:
  LDY $0304                             ; $A06B: AC 04 03
  LDA $034E,Y                           ; $A06E: B9 4E 03
  CMP #$80                              ; $A071: C9 80
  BEQ $A0B6                             ; $A073: F0 41
  LDA $2002                             ; $A075: AD 02 20
  LDA $031D                             ; $A078: AD 1D 03
  STA $2006                             ; $A07B: 8D 06 20
  LDA $031C                             ; $A07E: AD 1C 03
  CLC                                   ; $A081: 18
  ADC $0304                             ; $A082: 6D 04 03
  STA $2006                             ; $A085: 8D 06 20
  LDY $0304                             ; $A088: AC 04 03
  LDA $031E,Y                           ; $A08B: B9 1E 03
  STA $2007                             ; $A08E: 8D 07 20
  LDA $030C                             ; $A091: AD 0C 03
  BNE $A0B2                             ; $A094: D0 1C
  LDA $2002                             ; $A096: AD 02 20
  LDA $034D                             ; $A099: AD 4D 03
  STA $2006                             ; $A09C: 8D 06 20
  LDA $034C                             ; $A09F: AD 4C 03
  CLC                                   ; $A0A2: 18
  ADC $0304                             ; $A0A3: 6D 04 03
  STA $2006                             ; $A0A6: 8D 06 20
  LDY $0304                             ; $A0A9: AC 04 03
  LDA $034E,Y                           ; $A0AC: B9 4E 03
  STA $2007                             ; $A0AF: 8D 07 20
Loc_A0B2:
  INC $0304                             ; $A0B2: EE 04 03
  RTS                                   ; $A0B5: 60
Loc_A0B6:
  LDA #$FF                              ; $A0B6: A9 FF
  STA $0304                             ; $A0B8: 8D 04 03
  LDA $007E                             ; $A0BB: AD 7E 00
  AND #$FE                              ; $A0BE: 29 FE
  STA $007E                             ; $A0C0: 8D 7E 00
  RTS                                   ; $A0C3: 60
Loc_A0C4:
  LDA $2002                             ; $A0C4: AD 02 20
  LDA $031D                             ; $A0C7: AD 1D 03
  STA $2006                             ; $A0CA: 8D 06 20
  LDA $031C                             ; $A0CD: AD 1C 03
  STA $2006                             ; $A0D0: 8D 06 20
  LDY #$00                              ; $A0D3: A0 00
Loc_A0D5:
  LDA $031E,Y                           ; $A0D5: B9 1E 03
  CMP #$80                              ; $A0D8: C9 80
  BEQ $A0E3                             ; $A0DA: F0 07
  STA $2007                             ; $A0DC: 8D 07 20
  INY                                   ; $A0DF: C8
  JMP $A0D5                             ; $A0E0: 4C D5 A0
Loc_A0E3:
  LDA $030C                             ; $A0E3: AD 0C 03
  BNE $A107                             ; $A0E6: D0 1F
  LDA $2002                             ; $A0E8: AD 02 20
  LDA $034D                             ; $A0EB: AD 4D 03
  STA $2006                             ; $A0EE: 8D 06 20
  LDA $034C                             ; $A0F1: AD 4C 03
  STA $2006                             ; $A0F4: 8D 06 20
  LDY #$00                              ; $A0F7: A0 00
Loc_A0F9:
  LDA $034E,Y                           ; $A0F9: B9 4E 03
  CMP #$80                              ; $A0FC: C9 80
  BEQ $A107                             ; $A0FE: F0 07
  STA $2007                             ; $A100: 8D 07 20
  INY                                   ; $A103: C8
  JMP $A0F9                             ; $A104: 4C F9 A0
Loc_A107:
  JMP $A0B6                             ; $A107: 4C B6 A0
; --- Data Region ---
  .byte $A9,$FF,$8D,$00,$03,$8D,$04,$03,$AD,$7E,$00,$29,$FE,$8D,$7E,$00; $A10A: A9 FF 8D 00 03 8D 04 03 AD 7E 00 29 FE 8D 7E 00
  .byte $60                               ; $A11A: 60
Loc_A11B:
; --- Code Region ---
  LDA $008B                             ; $A11B: AD 8B 00
  AND #$FB                              ; $A11E: 29 FB
  STA $2000                             ; $A120: 8D 00 20
  LDA #$80                              ; $A123: A9 80
  STA $0000                             ; $A125: 8D 00 00
  LDA #$03                              ; $A128: A9 03
  STA $0001                             ; $A12A: 8D 01 00
  LDA $2002                             ; $A12D: AD 02 20
  LDY #$00                              ; $A130: A0 00
Loc_A132:
  LDA ($00),Y                           ; $A132: B1 00
  CMP #$FF                              ; $A134: C9 FF
  BEQ $A152                             ; $A136: F0 1A
  INY                                   ; $A138: C8
  TAX                                   ; $A139: AA
  LDA ($00),Y                           ; $A13A: B1 00
  STA $2006                             ; $A13C: 8D 06 20
  INY                                   ; $A13F: C8
  LDA ($00),Y                           ; $A140: B1 00
  STA $2006                             ; $A142: 8D 06 20
  INY                                   ; $A145: C8
Loc_A146:
  LDA ($00),Y                           ; $A146: B1 00
  STA $2007                             ; $A148: 8D 07 20
  INY                                   ; $A14B: C8
  DEX                                   ; $A14C: CA
  BNE $A146                             ; $A14D: D0 F7
  JMP $A132                             ; $A14F: 4C 32 A1
Loc_A152:
  RTS                                   ; $A152: 60
Loc_A153:
  RTS                                   ; $A153: 60
Loc_A154:
  JSR $A158                             ; $A154: 20 58 A1
  RTS                                   ; $A157: 60
Loc_A158:
  LDA $0081                             ; $A158: AD 81 00
  AND #$01                              ; $A15B: 29 01
  BEQ $A164                             ; $A15D: F0 05
  LDA #$01                              ; $A15F: A9 01
  STA $0308                             ; $A161: 8D 08 03
Loc_A164:
  LDA $0300                             ; $A164: AD 00 03
  CMP #$FF                              ; $A167: C9 FF
  BEQ $A153                             ; $A169: F0 E8
  LDA $007E                             ; $A16B: AD 7E 00
  AND #$01                              ; $A16E: 29 01
  BNE $A153                             ; $A170: D0 E1
  LDA #$00                              ; $A172: A9 00
  STA $0304                             ; $A174: 8D 04 03
  JSR $A690                             ; $A177: 20 90 A6
  LDA $0300                             ; $A17A: AD 00 03
  BNE $A1AC                             ; $A17D: D0 2D
  JSR $A61D                             ; $A17F: 20 1D A6
  LDY #$00                              ; $A182: A0 00
  LDA ($A6),Y                           ; $A184: B1 A6
  STA $0306                             ; $A186: 8D 06 03
  JSR $A1DF                             ; $A189: 20 DF A1
  LDA ($A6),Y                           ; $A18C: B1 A6
  STA $0307                             ; $A18E: 8D 07 03
  JSR $A1DF                             ; $A191: 20 DF A1
  LDA #$01                              ; $A194: A9 01
  STA $0300                             ; $A196: 8D 00 03
  LDA #$00                              ; $A199: A9 00
  STA $0303                             ; $A19B: 8D 03 03
  STA $0308                             ; $A19E: 8D 08 03
  STA $030C                             ; $A1A1: 8D 0C 03
  STA $030F                             ; $A1A4: 8D 0F 03
  LDA #$03                              ; $A1A7: A9 03
  STA $0305                             ; $A1A9: 8D 05 03
Loc_A1AC:
  JSR $A60F                             ; $A1AC: 20 0F A6
  LDA $0306                             ; $A1AF: AD 06 03
  STA $031C                             ; $A1B2: 8D 1C 03
  SEC                                   ; $A1B5: 38
  SBC #$20                              ; $A1B6: E9 20
  STA $034C                             ; $A1B8: 8D 4C 03
  LDA $0307                             ; $A1BB: AD 07 03
  STA $031D                             ; $A1BE: 8D 1D 03
  SBC #$00                              ; $A1C1: E9 00
  STA $034D                             ; $A1C3: 8D 4D 03
  LDX #$02                              ; $A1C6: A2 02
Loc_A1C8:
  LDY #$00                              ; $A1C8: A0 00
  LDA ($A6),Y                           ; $A1CA: B1 A6
  JSR $A1DF                             ; $A1CC: 20 DF A1
  STA $0012                             ; $A1CF: 8D 12 00
  TAY                                   ; $A1D2: A8
  BPL $A1D9                             ; $A1D3: 10 04
  CMP #$C0                              ; $A1D5: C9 C0
  BCC $A202                             ; $A1D7: 90 29
Loc_A1D9:
  JSR $A1E8                             ; $A1D9: 20 E8 A1
  JMP $A1C8                             ; $A1DC: 4C C8 A1
Loc_A1DF:
  INC $00A6                             ; $A1DF: EE A6 00
  BNE $A1E7                             ; $A1E2: D0 03
  INC $00A7                             ; $A1E4: EE A7 00
Loc_A1E7:
  RTS                                   ; $A1E7: 60
Loc_A1E8:
  LDY $030C                             ; $A1E8: AC 0C 03
  BNE $A1F5                             ; $A1EB: D0 08
  CMP #$39                              ; $A1ED: C9 39
  BEQ $A1FE                             ; $A1EF: F0 0D
  CMP #$3A                              ; $A1F1: C9 3A
  BEQ $A1FE                             ; $A1F3: F0 09
Loc_A1F5:
  CLC                                   ; $A1F5: 18
  ADC $030F                             ; $A1F6: 6D 0F 03
  STA $031C,X                           ; $A1F9: 9D 1C 03
  INX                                   ; $A1FC: E8
  RTS                                   ; $A1FD: 60
Loc_A1FE:
  STA $034B,X                           ; $A1FE: 9D 4B 03
  RTS                                   ; $A201: 60
Loc_A202:
  SEC                                   ; $A202: 38
  SBC #$80                              ; $A203: E9 80
  JSR $EADE                             ; $A205: 20 DE EA
; --- Data Region ---
  .byte $48,$A2,$81,$A2,$A3,$A2,$C2,$A2,$DD,$A2,$E5,$A2,$ED,$A2,$10,$A3; $A208: 48 A2 81 A2 A3 A2 C2 A2 DD A2 E5 A2 ED A2 10 A3
  .byte $18,$A3,$20,$A3,$ED,$A2,$ED,$A2,$ED,$A2,$ED,$A2,$ED,$A2,$ED,$A2; $A218: 18 A3 20 A3 ED A2 ED A2 ED A2 ED A2 ED A2 ED A2
  .byte $2D,$A3,$2D,$A3,$2D,$A3,$2D,$A3,$2D,$A3,$2D,$A3,$2D,$A3,$2D,$A3; $A228: 2D A3 2D A3 2D A3 2D A3 2D A3 2D A3 2D A3 2D A3
  .byte $B1,$A3,$B1,$A3,$B1,$A3,$B1,$A3,$26,$A4,$B0,$A4,$3E,$A5,$97,$A3; $A238: B1 A3 B1 A3 B1 A3 B1 A3 26 A4 B0 A4 3E A5 97 A3
Loc_A248:  ; (dispatch callback target)
; --- Code Region ---
  LDA #$FF                              ; $A248: A9 FF
  STA $0300                             ; $A24A: 8D 00 03
  LDA #$80                              ; $A24D: A9 80
  STA $031C,X                           ; $A24F: 9D 1C 03
  STA $034C,X                           ; $A252: 9D 4C 03
  LDA $007E                             ; $A255: AD 7E 00
  ORA #$01                              ; $A258: 09 01
  STA $007E                             ; $A25A: 8D 7E 00
  LDA $0311                             ; $A25D: AD 11 03
  STA $0310                             ; $A260: 8D 10 03
  LDA $0312                             ; $A263: AD 12 03
  STA $0311                             ; $A266: 8D 11 03
  LDA $0313                             ; $A269: AD 13 03
  STA $0312                             ; $A26C: 8D 12 03
  LDA #$FF                              ; $A26F: A9 FF
  STA $0313                             ; $A271: 8D 13 03
  LDA $0310                             ; $A274: AD 10 03
  CMP #$FF                              ; $A277: C9 FF
  BEQ $A280                             ; $A279: F0 05
  LDA #$00                              ; $A27B: A9 00
  STA $0300                             ; $A27D: 8D 00 03
Loc_A280:
  RTS                                   ; $A280: 60
Loc_A281:  ; (dispatch callback target)
  LDA #$80                              ; $A281: A9 80
  STA $031C,X                           ; $A283: 9D 1C 03
  STA $034C,X                           ; $A286: 9D 4C 03
  LDA $0306                             ; $A289: AD 06 03
  CLC                                   ; $A28C: 18
  ADC #$40                              ; $A28D: 69 40
  STA $0306                             ; $A28F: 8D 06 03
  LDA $0307                             ; $A292: AD 07 03
  ADC #$00                              ; $A295: 69 00
  STA $0307                             ; $A297: 8D 07 03
  LDA $007E                             ; $A29A: AD 7E 00
  ORA #$01                              ; $A29D: 09 01
  STA $007E                             ; $A29F: 8D 7E 00
  RTS                                   ; $A2A2: 60
Loc_A2A3:  ; (dispatch callback target)
  LDA $0310                             ; $A2A3: AD 10 03
  STA $0309                             ; $A2A6: 8D 09 03
  LDA $00A6                             ; $A2A9: AD A6 00
  STA $030A                             ; $A2AC: 8D 0A 03
  LDA $00A7                             ; $A2AF: AD A7 00
  STA $030B                             ; $A2B2: 8D 0B 03
  LDY #$00                              ; $A2B5: A0 00
  LDA ($A6),Y                           ; $A2B7: B1 A6
  STA $0310                             ; $A2B9: 8D 10 03
  JSR $A61D                             ; $A2BC: 20 1D A6
  JMP $A1C8                             ; $A2BF: 4C C8 A1
Loc_A2C2:  ; (dispatch callback target)
  LDA $0309                             ; $A2C2: AD 09 03
  STA $0310                             ; $A2C5: 8D 10 03
  JSR $A61D                             ; $A2C8: 20 1D A6
  LDA $030A                             ; $A2CB: AD 0A 03
  STA $00A6                             ; $A2CE: 8D A6 00
  LDA $030B                             ; $A2D1: AD 0B 03
  STA $00A7                             ; $A2D4: 8D A7 00
  JSR $A1DF                             ; $A2D7: 20 DF A1
  JMP $A1C8                             ; $A2DA: 4C C8 A1
Loc_A2DD:  ; (dispatch callback target)
  LDA #$80                              ; $A2DD: A9 80
  STA $0303                             ; $A2DF: 8D 03 03
  JMP $A1C8                             ; $A2E2: 4C C8 A1
Loc_A2E5:  ; (dispatch callback target)
  LDA #$00                              ; $A2E5: A9 00
  STA $0303                             ; $A2E7: 8D 03 03
  JMP $A1C8                             ; $A2EA: 4C C8 A1
Loc_A2ED:  ; (dispatch callback target)
  LDY #$00                              ; $A2ED: A0 00
  LDA ($A6),Y                           ; $A2EF: B1 A6
  STA $0306                             ; $A2F1: 8D 06 03
  JSR $A1DF                             ; $A2F4: 20 DF A1
  LDA ($A6),Y                           ; $A2F7: B1 A6
  STA $0307                             ; $A2F9: 8D 07 03
  JSR $A1DF                             ; $A2FC: 20 DF A1
  LDA #$80                              ; $A2FF: A9 80
  STA $031C,X                           ; $A301: 9D 1C 03
  STA $034C,X                           ; $A304: 9D 4C 03
  LDA $007E                             ; $A307: AD 7E 00
  ORA #$01                              ; $A30A: 09 01
  STA $007E                             ; $A30C: 8D 7E 00
  RTS                                   ; $A30F: 60
Loc_A310:  ; (dispatch callback target)
  LDA #$01                              ; $A310: A9 01
  STA $030C                             ; $A312: 8D 0C 03
  JMP $A1C8                             ; $A315: 4C C8 A1
Loc_A318:  ; (dispatch callback target)
  LDA #$00                              ; $A318: A9 00
  STA $030C                             ; $A31A: 8D 0C 03
  JMP $A1C8                             ; $A31D: 4C C8 A1
Loc_A320:  ; (dispatch callback target)
  LDY #$00                              ; $A320: A0 00
  LDA ($A6),Y                           ; $A322: B1 A6
  STA $030F                             ; $A324: 8D 0F 03
  JSR $A1DF                             ; $A327: 20 DF A1
  JMP $A1C8                             ; $A32A: 4C C8 A1
Loc_A32D:  ; (dispatch callback target)
  LDA $00E1                             ; $A32D: AD E1 00
  PHA                                   ; $A330: 48
  LDY #$30                              ; $A331: A0 30
  JSR $F25F                             ; $A333: 20 5F F2
  LDA #$00                              ; $A336: A9 00
  STA $0001                             ; $A338: 8D 01 00
  LDA $0012                             ; $A33B: AD 12 00
  SEC                                   ; $A33E: 38
  SBC #$90                              ; $A33F: E9 90
Loc_A341:
  TAY                                   ; $A341: A8
  LDA #$00                              ; $A342: A9 00
  STA $0001                             ; $A344: 8D 01 00
  LDA $042C,Y                           ; $A347: B9 2C 04
  ASL                                   ; $A34A: 0A
  ROL $0001                             ; $A34B: 2E 01 00
  ASL                                   ; $A34E: 0A
  ROL $0001                             ; $A34F: 2E 01 00
  CLC                                   ; $A352: 18
  ADC $042C,Y                           ; $A353: 79 2C 04
  STA $0000                             ; $A356: 8D 00 00
  LDA $0001                             ; $A359: AD 01 00
  ADC #$00                              ; $A35C: 69 00
  STA $0001                             ; $A35E: 8D 01 00
  ASL $0000                             ; $A361: 0E 00 00
  ROL $0001                             ; $A364: 2E 01 00
  LDA $0000                             ; $A367: AD 00 00
  CLC                                   ; $A36A: 18
  ADC #$1A                              ; $A36B: 69 1A
  STA $0000                             ; $A36D: 8D 00 00
  LDA $0001                             ; $A370: AD 01 00
  ADC #$90                              ; $A373: 69 90
  STA $0001                             ; $A375: 8D 01 00
  LDY #$00                              ; $A378: A0 00
Loc_A37A:
  LDA ($00),Y                           ; $A37A: B1 00
  BEQ $A38F                             ; $A37C: F0 11
  STA $0002                             ; $A37E: 8D 02 00
  TYA                                   ; $A381: 98
  PHA                                   ; $A382: 48
  LDA $0002                             ; $A383: AD 02 00
  JSR $A1E8                             ; $A386: 20 E8 A1
  PLA                                   ; $A389: 68
  TAY                                   ; $A38A: A8
  INY                                   ; $A38B: C8
  JMP $A37A                             ; $A38C: 4C 7A A3
Loc_A38F:
  PLA                                   ; $A38F: 68
  TAY                                   ; $A390: A8
  JSR $F25F                             ; $A391: 20 5F F2
  JMP $A1C8                             ; $A394: 4C C8 A1
Loc_A397:  ; (dispatch callback target)
  LDA $00E1                             ; $A397: AD E1 00
  PHA                                   ; $A39A: 48
  LDY #$00                              ; $A39B: A0 00
  LDA ($A6),Y                           ; $A39D: B1 A6
  PHA                                   ; $A39F: 48
  JSR $A1DF                             ; $A3A0: 20 DF A1
  LDY #$30                              ; $A3A3: A0 30
  JSR $F25F                             ; $A3A5: 20 5F F2
  LDA #$00                              ; $A3A8: A9 00
  STA $0001                             ; $A3AA: 8D 01 00
  PLA                                   ; $A3AD: 68
  JMP $A341                             ; $A3AE: 4C 41 A3
Loc_A3B1:  ; (dispatch callback target)
  LDA $0012                             ; $A3B1: AD 12 00
  SEC                                   ; $A3B4: 38
  SBC #$98                              ; $A3B5: E9 98
  STA $0000                             ; $A3B7: 8D 00 00
  ASL                                   ; $A3BA: 0A
  CLC                                   ; $A3BB: 18
  ADC $0000                             ; $A3BC: 6D 00 00
  TAY                                   ; $A3BF: A8
  LDA $042C,Y                           ; $A3C0: B9 2C 04
  STA $0001                             ; $A3C3: 8D 01 00
  LDA $042D,Y                           ; $A3C6: B9 2D 04
  STA $0002                             ; $A3C9: 8D 02 00
  LDA $042E,Y                           ; $A3CC: B9 2E 04
  STA $0003                             ; $A3CF: 8D 03 00
  TXA                                   ; $A3D2: 8A
  PHA                                   ; $A3D3: 48
  JSR $E9BA                             ; $A3D4: 20 BA E9
  PLA                                   ; $A3D7: 68
  TAX                                   ; $A3D8: AA
  LDA #$00                              ; $A3D9: A9 00
  STA $0000                             ; $A3DB: 8D 00 00
  LDA $0009                             ; $A3DE: AD 09 00
  LSR                                   ; $A3E1: 4A
  LSR                                   ; $A3E2: 4A
  LSR                                   ; $A3E3: 4A
  LSR                                   ; $A3E4: 4A
  JSR $A411                             ; $A3E5: 20 11 A4
  LDA $0009                             ; $A3E8: AD 09 00
  JSR $A411                             ; $A3EB: 20 11 A4
  LDA $0008                             ; $A3EE: AD 08 00
  LSR                                   ; $A3F1: 4A
  LSR                                   ; $A3F2: 4A
  LSR                                   ; $A3F3: 4A
  LSR                                   ; $A3F4: 4A
  JSR $A411                             ; $A3F5: 20 11 A4
  LDA $0008                             ; $A3F8: AD 08 00
  JSR $A411                             ; $A3FB: 20 11 A4
  LDA $0007                             ; $A3FE: AD 07 00
  LSR                                   ; $A401: 4A
  LSR                                   ; $A402: 4A
  LSR                                   ; $A403: 4A
  LSR                                   ; $A404: 4A
  JSR $A411                             ; $A405: 20 11 A4
  LDA $0007                             ; $A408: AD 07 00
  JSR $A41A                             ; $A40B: 20 1A A4
  JMP $A1C8                             ; $A40E: 4C C8 A1
Loc_A411:
  LDY $0000                             ; $A411: AC 00 00
  BNE $A41A                             ; $A414: D0 04
  AND #$0F                              ; $A416: 29 0F
  BEQ $A425                             ; $A418: F0 0B
Loc_A41A:
  AND #$0F                              ; $A41A: 29 0F
  CLC                                   ; $A41C: 18
  ADC #$76                              ; $A41D: 69 76
  JSR $A1E8                             ; $A41F: 20 E8 A1
  INC $0000                             ; $A422: EE 00 00
Loc_A425:
  RTS                                   ; $A425: 60
Loc_A426:  ; (dispatch callback target)
  LDA $00E1                             ; $A426: AD E1 00
  PHA                                   ; $A429: 48
  LDY #$00                              ; $A42A: A0 00
  LDA ($A6),Y                           ; $A42C: B1 A6
  PHA                                   ; $A42E: 48
  JSR $A1DF                             ; $A42F: 20 DF A1
  LDY #$30                              ; $A432: A0 30
  JSR $F25F                             ; $A434: 20 5F F2
  LDA #$00                              ; $A437: A9 00
  STA $0001                             ; $A439: 8D 01 00
  PLA                                   ; $A43C: 68
  TAY                                   ; $A43D: A8
  LDA #$00                              ; $A43E: A9 00
  STA $0001                             ; $A440: 8D 01 00
  LDA $042C,Y                           ; $A443: B9 2C 04
  BPL $A460                             ; $A446: 10 18
  LDA #$00                              ; $A448: A9 00
Loc_A44A:
  PHA                                   ; $A44A: 48
  LDA #$01                              ; $A44B: A9 01
  JSR $A1E8                             ; $A44D: 20 E8 A1
  PLA                                   ; $A450: 68
  CLC                                   ; $A451: 18
  ADC #$01                              ; $A452: 69 01
  CMP #$06                              ; $A454: C9 06
  BCC $A44A                             ; $A456: 90 F2
  PLA                                   ; $A458: 68
  TAY                                   ; $A459: A8
  JSR $F25F                             ; $A45A: 20 5F F2
  JMP $A1C8                             ; $A45D: 4C C8 A1
Loc_A460:
  ASL                                   ; $A460: 0A
  ASL                                   ; $A461: 0A
  ASL                                   ; $A462: 0A
  CLC                                   ; $A463: 18
  ADC #$1A                              ; $A464: 69 1A
  STA $0000                             ; $A466: 8D 00 00
  LDA #$00                              ; $A469: A9 00
  ADC #$9A                              ; $A46B: 69 9A
  STA $0001                             ; $A46D: 8D 01 00
  LDY #$00                              ; $A470: A0 00
  STY $0003                             ; $A472: 8C 03 00
Loc_A475:
  LDA ($00),Y                           ; $A475: B1 00
  BNE $A47B                             ; $A477: D0 02
  LDA #$01                              ; $A479: A9 01
Loc_A47B:
  STA $0002                             ; $A47B: 8D 02 00
  TYA                                   ; $A47E: 98
  PHA                                   ; $A47F: 48
  LDA $0002                             ; $A480: AD 02 00
  CMP #$39                              ; $A483: C9 39
  BEQ $A48B                             ; $A485: F0 04
  CMP #$3A                              ; $A487: C9 3A
  BNE $A48E                             ; $A489: D0 03
Loc_A48B:
  INC $0003                             ; $A48B: EE 03 00
Loc_A48E:
  JSR $A1E8                             ; $A48E: 20 E8 A1
  PLA                                   ; $A491: 68
  TAY                                   ; $A492: A8
  INY                                   ; $A493: C8
  CPY #$06                              ; $A494: C0 06
  BCC $A475                             ; $A496: 90 DD
Loc_A498:
  LDA $0003                             ; $A498: AD 03 00
  BEQ $A4A8                             ; $A49B: F0 0B
  LDA #$01                              ; $A49D: A9 01
  JSR $A1E8                             ; $A49F: 20 E8 A1
  DEC $0003                             ; $A4A2: CE 03 00
  JMP $A498                             ; $A4A5: 4C 98 A4
Loc_A4A8:
  PLA                                   ; $A4A8: 68
  TAY                                   ; $A4A9: A8
  JSR $F25F                             ; $A4AA: 20 5F F2
  JMP $A1C8                             ; $A4AD: 4C C8 A1
Loc_A4B0:  ; (dispatch callback target)
  LDA $00E1                             ; $A4B0: AD E1 00
  PHA                                   ; $A4B3: 48
  LDY #$00                              ; $A4B4: A0 00
  LDA ($A6),Y                           ; $A4B6: B1 A6
  PHA                                   ; $A4B8: 48
  JSR $A1DF                             ; $A4B9: 20 DF A1
  LDY #$30                              ; $A4BC: A0 30
  JSR $F25F                             ; $A4BE: 20 5F F2
  LDA #$00                              ; $A4C1: A9 00
  STA $0001                             ; $A4C3: 8D 01 00
  PLA                                   ; $A4C6: 68
  TAY                                   ; $A4C7: A8
  LDA #$00                              ; $A4C8: A9 00
  STA $0001                             ; $A4CA: 8D 01 00
  LDA $042C,Y                           ; $A4CD: B9 2C 04
  ASL                                   ; $A4D0: 0A
  ROL $0001                             ; $A4D1: 2E 01 00
  ASL                                   ; $A4D4: 0A
  ROL $0001                             ; $A4D5: 2E 01 00
  CLC                                   ; $A4D8: 18
  ADC $042C,Y                           ; $A4D9: 79 2C 04
  STA $0000                             ; $A4DC: 8D 00 00
  LDA $0001                             ; $A4DF: AD 01 00
  ADC #$00                              ; $A4E2: 69 00
  STA $0001                             ; $A4E4: 8D 01 00
  ASL $0000                             ; $A4E7: 0E 00 00
  ROL $0001                             ; $A4EA: 2E 01 00
  LDA $0000                             ; $A4ED: AD 00 00
  CLC                                   ; $A4F0: 18
  ADC #$1A                              ; $A4F1: 69 1A
  STA $0000                             ; $A4F3: 8D 00 00
  LDA $0001                             ; $A4F6: AD 01 00
  ADC #$90                              ; $A4F9: 69 90
  STA $0001                             ; $A4FB: 8D 01 00
  LDY #$00                              ; $A4FE: A0 00
  STY $0003                             ; $A500: 8C 03 00
Loc_A503:
  LDA ($00),Y                           ; $A503: B1 00
  BNE $A509                             ; $A505: D0 02
  LDA #$01                              ; $A507: A9 01
Loc_A509:
  STA $0002                             ; $A509: 8D 02 00
  TYA                                   ; $A50C: 98
  PHA                                   ; $A50D: 48
  LDA $0002                             ; $A50E: AD 02 00
  CMP #$39                              ; $A511: C9 39
  BEQ $A519                             ; $A513: F0 04
  CMP #$3A                              ; $A515: C9 3A
  BNE $A51C                             ; $A517: D0 03
Loc_A519:
  INC $0003                             ; $A519: EE 03 00
Loc_A51C:
  JSR $A1E8                             ; $A51C: 20 E8 A1
  PLA                                   ; $A51F: 68
  TAY                                   ; $A520: A8
  INY                                   ; $A521: C8
  CPY #$07                              ; $A522: C0 07
  BCC $A503                             ; $A524: 90 DD
Loc_A526:
  LDA $0003                             ; $A526: AD 03 00
  BEQ $A536                             ; $A529: F0 0B
  LDA #$01                              ; $A52B: A9 01
  JSR $A1E8                             ; $A52D: 20 E8 A1
  DEC $0003                             ; $A530: CE 03 00
  JMP $A526                             ; $A533: 4C 26 A5
Loc_A536:
  PLA                                   ; $A536: 68
  TAY                                   ; $A537: A8
  JSR $F25F                             ; $A538: 20 5F F2
  JMP $A1C8                             ; $A53B: 4C C8 A1
Loc_A53E:  ; (dispatch callback target)
  LDA #$00                              ; $A53E: A9 00
  STA $0010                             ; $A540: 8D 10 00
  LDY #$00                              ; $A543: A0 00
  LDA ($A6),Y                           ; $A545: B1 A6
  PHA                                   ; $A547: 48
  JSR $A1DF                             ; $A548: 20 DF A1
  PLA                                   ; $A54B: 68
  STA $0000                             ; $A54C: 8D 00 00
  ASL                                   ; $A54F: 0A
  CLC                                   ; $A550: 18
  ADC $0000                             ; $A551: 6D 00 00
  TAY                                   ; $A554: A8
  LDA $044C,Y                           ; $A555: B9 4C 04
  STA $0001                             ; $A558: 8D 01 00
  LDA $044D,Y                           ; $A55B: B9 4D 04
  STA $0002                             ; $A55E: 8D 02 00
  LDA $044E,Y                           ; $A561: B9 4E 04
  CMP #$FE                              ; $A564: C9 FE
  BNE $A57D                             ; $A566: D0 15
  LDA #$01                              ; $A568: A9 01
  JSR $A1E8                             ; $A56A: 20 E8 A1
  LDA #$6F                              ; $A56D: A9 6F
  JSR $A1E8                             ; $A56F: 20 E8 A1
  LDA #$6F                              ; $A572: A9 6F
  JSR $A1E8                             ; $A574: 20 E8 A1
  JSR $A1DF                             ; $A577: 20 DF A1
  JMP $A1C8                             ; $A57A: 4C C8 A1
Loc_A57D:
  CMP #$FF                              ; $A57D: C9 FF
  BNE $A58C                             ; $A57F: D0 0B
  INC $0010                             ; $A581: EE 10 00
  LDA #$00                              ; $A584: A9 00
  STA $0001                             ; $A586: 8D 01 00
  STA $0002                             ; $A589: 8D 02 00
Loc_A58C:
  STA $0003                             ; $A58C: 8D 03 00
  TXA                                   ; $A58F: 8A
  PHA                                   ; $A590: 48
  JSR $E9BA                             ; $A591: 20 BA E9
  PLA                                   ; $A594: 68
  TAX                                   ; $A595: AA
  LDY #$00                              ; $A596: A0 00
  LDA ($A6),Y                           ; $A598: B1 A6
  PHA                                   ; $A59A: 48
  JSR $A1DF                             ; $A59B: 20 DF A1
  PLA                                   ; $A59E: 68
  TAY                                   ; $A59F: A8
  LDA $A607,Y                           ; $A5A0: B9 07 A6
  STA $0001                             ; $A5A3: 8D 01 00
  LDA #$00                              ; $A5A6: A9 00
  STA $0000                             ; $A5A8: 8D 00 00
  LDA $0009                             ; $A5AB: AD 09 00
  LSR                                   ; $A5AE: 4A
  LSR                                   ; $A5AF: 4A
  LSR                                   ; $A5B0: 4A
  LSR                                   ; $A5B1: 4A
  JSR $A5DE                             ; $A5B2: 20 DE A5
  LDA $0009                             ; $A5B5: AD 09 00
  JSR $A5DE                             ; $A5B8: 20 DE A5
  LDA $0008                             ; $A5BB: AD 08 00
  LSR                                   ; $A5BE: 4A
  LSR                                   ; $A5BF: 4A
  LSR                                   ; $A5C0: 4A
  LSR                                   ; $A5C1: 4A
  JSR $A5DE                             ; $A5C2: 20 DE A5
  LDA $0008                             ; $A5C5: AD 08 00
  JSR $A5DE                             ; $A5C8: 20 DE A5
  LDA $0007                             ; $A5CB: AD 07 00
  LSR                                   ; $A5CE: 4A
  LSR                                   ; $A5CF: 4A
  LSR                                   ; $A5D0: 4A
  LSR                                   ; $A5D1: 4A
  JSR $A5DE                             ; $A5D2: 20 DE A5
  LDA $0007                             ; $A5D5: AD 07 00
  JSR $A5F4                             ; $A5D8: 20 F4 A5
  JMP $A1C8                             ; $A5DB: 4C C8 A1
Loc_A5DE:
  DEC $0001                             ; $A5DE: CE 01 00
  LDY $0000                             ; $A5E1: AC 00 00
  BNE $A5F4                             ; $A5E4: D0 0E
  AND #$0F                              ; $A5E6: 29 0F
  BNE $A5F4                             ; $A5E8: D0 0A
  LDY $0001                             ; $A5EA: AC 01 00
  BPL $A606                             ; $A5ED: 10 17
  LDA #$01                              ; $A5EF: A9 01
  JMP $A1E8                             ; $A5F1: 4C E8 A1
Loc_A5F4:
  AND #$0F                              ; $A5F4: 29 0F
  CLC                                   ; $A5F6: 18
  ADC #$76                              ; $A5F7: 69 76
  LDY $0010                             ; $A5F9: AC 10 00
  BEQ $A600                             ; $A5FC: F0 02
  LDA #$01                              ; $A5FE: A9 01
Loc_A600:
  JSR $A1E8                             ; $A600: 20 E8 A1
  INC $0000                             ; $A603: EE 00 00
Loc_A606:
  RTS                                   ; $A606: 60
; --- Data Region ---
  .byte $05,$05,$04,$03,$02,$01,$00,$00   ; $A607: 05 05 04 03 02 01 00 00
Loc_A60F:
; --- Code Region ---
  LDY #$28                              ; $A60F: A0 28
  LDA #$01                              ; $A611: A9 01
Loc_A613:
  STA $031C,Y                           ; $A613: 99 1C 03
  STA $034C,Y                           ; $A616: 99 4C 03
  DEY                                   ; $A619: 88
  BNE $A613                             ; $A61A: D0 F7
  RTS                                   ; $A61C: 60
Loc_A61D:
  LDA $0310                             ; $A61D: AD 10 03
  STA $0000                             ; $A620: 8D 00 00
  LDA #$00                              ; $A623: A9 00
  STA $0001                             ; $A625: 8D 01 00
  ASL $0000                             ; $A628: 0E 00 00
  ROL $0001                             ; $A62B: 2E 01 00
  JSR $A690                             ; $A62E: 20 90 A6
  PHA                                   ; $A631: 48
  ASL                                   ; $A632: 0A
  TAY                                   ; $A633: A8
  LDA $0000                             ; $A634: AD 00 00
  CLC                                   ; $A637: 18
  ADC $A672,Y                           ; $A638: 79 72 A6
  STA $0000                             ; $A63B: 8D 00 00
  LDA $0001                             ; $A63E: AD 01 00
  ADC $A673,Y                           ; $A641: 79 73 A6
  STA $0001                             ; $A644: 8D 01 00
  PLA                                   ; $A647: 68
  CMP #$09                              ; $A648: C9 09
  BCS $A650                             ; $A64A: B0 04
  CMP #$03                              ; $A64C: C9 03
  BCS $A661                             ; $A64E: B0 11
Loc_A650:
  LDY #$00                              ; $A650: A0 00
  LDA ($00),Y                           ; $A652: B1 00
  STA $00A6                             ; $A654: 8D A6 00
  INY                                   ; $A657: C8
  LDA ($00),Y                           ; $A658: B1 00
  CLC                                   ; $A65A: 18
  ADC #$20                              ; $A65B: 69 20
  STA $00A7                             ; $A65D: 8D A7 00
  RTS                                   ; $A660: 60
Loc_A661:
  LDY #$00                              ; $A661: A0 00
  LDA ($00),Y                           ; $A663: B1 00
  STA $00A6                             ; $A665: 8D A6 00
  INY                                   ; $A668: C8
  LDA ($00),Y                           ; $A669: B1 00
  CLC                                   ; $A66B: 18
  ADC #$40                              ; $A66C: 69 40
  STA $00A7                             ; $A66E: 8D A7 00
  RTS                                   ; $A671: 60
; --- Data Region ---
  .byte $00,$80,$00,$80,$00,$80,$00,$80,$00,$80,$00,$80,$00,$80,$00,$80; $A672: 00 80 00 80 00 80 00 80 00 80 00 80 00 80 00 80
  .byte $00,$80,$00,$80,$00,$80,$00,$80,$00,$80,$00,$80,$00,$80; $A682: 00 80 00 80 00 80 00 80 00 80 00 80 00 80
Loc_A690:
; --- Code Region ---
  LDA #$00                              ; $A690: A9 00
  LDY $0310                             ; $A692: AC 10 03
  CPY #$20                              ; $A695: C0 20
  BCC $A69C                             ; $A697: 90 03
  LDA $007A                             ; $A699: AD 7A 00
Loc_A69C:
  PHA                                   ; $A69C: 48
  TAY                                   ; $A69D: A8
  LDA $A6A7,Y                           ; $A69E: B9 A7 A6
  TAY                                   ; $A6A1: A8
  JSR $F25F                             ; $A6A2: 20 5F F2
  PLA                                   ; $A6A5: 68
  RTS                                   ; $A6A6: 60
; --- Data Region ---
  .byte $33,$33,$33,$32,$32,$32,$32,$32,$32,$33,$33,$33,$33,$33,$33; $A6A7: 33 33 33 32 32 32 32 32 32 33 33 33 33 33 33
Loc_A6B6:
; --- Code Region ---
  LDA $6F00                             ; $A6B6: AD 00 6F
  CLC                                   ; $A6B9: 18
  ADC #$64                              ; $A6BA: 69 64
  STA $0001                             ; $A6BC: 8D 01 00
  LDA #$00                              ; $A6BF: A9 00
  ADC #$00                              ; $A6C1: 69 00
  STA $0002                             ; $A6C3: 8D 02 00
  LDA #$00                              ; $A6C6: A9 00
  STA $0003                             ; $A6C8: 8D 03 00
  JSR $E9BA                             ; $A6CB: 20 BA E9
  LDA $0008                             ; $A6CE: AD 08 00
  AND #$0F                              ; $A6D1: 29 0F
  CLC                                   ; $A6D3: 18
  ADC #$04                              ; $A6D4: 69 04
  STA $0383                             ; $A6D6: 8D 83 03
  CLC                                   ; $A6D9: 18
  ADC #$10                              ; $A6DA: 69 10
  STA $038D                             ; $A6DC: 8D 8D 03
  LDA $0007                             ; $A6DF: AD 07 00
  LSR                                   ; $A6E2: 4A
  LSR                                   ; $A6E3: 4A
  LSR                                   ; $A6E4: 4A
  LSR                                   ; $A6E5: 4A
  CLC                                   ; $A6E6: 18
  ADC #$04                              ; $A6E7: 69 04
  STA $0384                             ; $A6E9: 8D 84 03
  CLC                                   ; $A6EC: 18
  ADC #$10                              ; $A6ED: 69 10
  STA $038E                             ; $A6EF: 8D 8E 03
  LDA $0007                             ; $A6F2: AD 07 00
  AND #$0F                              ; $A6F5: 29 0F
  CLC                                   ; $A6F7: 18
  ADC #$04                              ; $A6F8: 69 04
  STA $0385                             ; $A6FA: 8D 85 03
  CLC                                   ; $A6FD: 18
  ADC #$10                              ; $A6FE: 69 10
  STA $038F                             ; $A700: 8D 8F 03
  LDA $6F01                             ; $A703: AD 01 6F
  CLC                                   ; $A706: 18
  ADC #$01                              ; $A707: 69 01
  STA $0001                             ; $A709: 8D 01 00
  LDA #$00                              ; $A70C: A9 00
  STA $0002                             ; $A70E: 8D 02 00
  STA $0003                             ; $A711: 8D 03 00
  JSR $E9BA                             ; $A714: 20 BA E9
  LDA $0007                             ; $A717: AD 07 00
  LSR                                   ; $A71A: 4A
  LSR                                   ; $A71B: 4A
  LSR                                   ; $A71C: 4A
  LSR                                   ; $A71D: 4A
  BNE $A722                             ; $A71E: D0 02
  LDA #$0E                              ; $A720: A9 0E
Loc_A722:
  CLC                                   ; $A722: 18
  ADC #$04                              ; $A723: 69 04
  STA $0388                             ; $A725: 8D 88 03
  CLC                                   ; $A728: 18
  ADC #$10                              ; $A729: 69 10
  STA $0392                             ; $A72B: 8D 92 03
  LDA $0007                             ; $A72E: AD 07 00
  AND #$0F                              ; $A731: 29 0F
  CLC                                   ; $A733: 18
  ADC #$04                              ; $A734: 69 04
  STA $0389                             ; $A736: 8D 89 03
  CLC                                   ; $A739: 18
  ADC #$10                              ; $A73A: 69 10
  STA $0393                             ; $A73C: 8D 93 03
  LDA #$07                              ; $A73F: A9 07
  STA $0380                             ; $A741: 8D 80 03
  LDA #$20                              ; $A744: A9 20
  STA $0381                             ; $A746: 8D 81 03
  LDA #$43                              ; $A749: A9 43
  STA $0382                             ; $A74B: 8D 82 03
  LDA #$07                              ; $A74E: A9 07
  STA $038A                             ; $A750: 8D 8A 03
  LDA #$20                              ; $A753: A9 20
  STA $038B                             ; $A755: 8D 8B 03
  LDA #$63                              ; $A758: A9 63
  STA $038C                             ; $A75A: 8D 8C 03
  LDA #$12                              ; $A75D: A9 12
  STA $0387                             ; $A75F: 8D 87 03
  LDA #$22                              ; $A762: A9 22
  STA $0391                             ; $A764: 8D 91 03
  LDA #$0E                              ; $A767: A9 0E
  STA $0386                             ; $A769: 8D 86 03
  LDA #$1E                              ; $A76C: A9 1E
  STA $0390                             ; $A76E: 8D 90 03
  LDA #$FF                              ; $A771: A9 FF
  STA $0394                             ; $A773: 8D 94 03
  LDA $007E                             ; $A776: AD 7E 00
  ORA #$04                              ; $A779: 09 04
  STA $007E                             ; $A77B: 8D 7E 00
  RTS                                   ; $A77E: 60
Loc_A77F:
  LDA $005E                             ; $A77F: AD 5E 00
  CLC                                   ; $A782: 18
  ADC #$05                              ; $A783: 69 05
  AND #$0F                              ; $A785: 29 0F
  BEQ $A7B2                             ; $A787: F0 29
  RTS                                   ; $A789: 60
Loc_A78A:
  LDA $005E                             ; $A78A: AD 5E 00
  CLC                                   ; $A78D: 18
  ADC #$01                              ; $A78E: 69 01
  AND #$03                              ; $A790: 29 03
  BNE $A7B1                             ; $A792: D0 1D
  LDA $005E                             ; $A794: AD 5E 00
  CLC                                   ; $A797: 18
  ADC #$01                              ; $A798: 69 01
  AND #$04                              ; $A79A: 29 04
  BNE $A7B2                             ; $A79C: D0 14
  LDY #$3A                              ; $A79E: A0 3A
Loc_A7A0:
  LDA $A7F6,Y                           ; $A7A0: B9 F6 A7
  STA $0380,Y                           ; $A7A3: 99 80 03
  DEY                                   ; $A7A6: 88
  BPL $A7A0                             ; $A7A7: 10 F7
  LDA $007E                             ; $A7A9: AD 7E 00
  ORA #$04                              ; $A7AC: 09 04
  STA $007E                             ; $A7AE: 8D 7E 00
Loc_A7B1:
  RTS                                   ; $A7B1: 60
Loc_A7B2:
  LDA #$00                              ; $A7B2: A9 00
  STA $0002                             ; $A7B4: 8D 02 00
  LDA $6F05                             ; $A7B7: AD 05 6F
  STA $0001                             ; $A7BA: 8D 01 00
  LDA #$00                              ; $A7BD: A9 00
  STA $0002                             ; $A7BF: 8D 02 00
  STA $0003                             ; $A7C2: 8D 03 00
  JSR $E9BA                             ; $A7C5: 20 BA E9
  LDY #$3A                              ; $A7C8: A0 3A
Loc_A7CA:
  LDA $A7F6,Y                           ; $A7CA: B9 F6 A7
  STA $0380,Y                           ; $A7CD: 99 80 03
  DEY                                   ; $A7D0: 88
  BPL $A7CA                             ; $A7D1: 10 F7
  LDA $0007                             ; $A7D3: AD 07 00
  LSR                                   ; $A7D6: 4A
  LSR                                   ; $A7D7: 4A
  LSR                                   ; $A7D8: 4A
  LSR                                   ; $A7D9: 4A
  BEQ $A7E2                             ; $A7DA: F0 06
  CLC                                   ; $A7DC: 18
  ADC #$76                              ; $A7DD: 69 76
  STA $03AA                             ; $A7DF: 8D AA 03
Loc_A7E2:
  LDA $0007                             ; $A7E2: AD 07 00
  AND #$0F                              ; $A7E5: 29 0F
  CLC                                   ; $A7E7: 18
  ADC #$76                              ; $A7E8: 69 76
  STA $03AB                             ; $A7EA: 8D AB 03
  LDA $007E                             ; $A7ED: AD 7E 00
  ORA #$04                              ; $A7F0: 09 04
  STA $007E                             ; $A7F2: 8D 7E 00
  RTS                                   ; $A7F5: 60
; --- Data Region ---
  .byte $04,$22,$A2,$01,$01,$01,$01,$04,$22,$C2,$01,$01,$01,$01,$04,$22; $A7F6: 04 22 A2 01 01 01 01 04 22 C2 01 01 01 01 04 22
  .byte $E2,$01,$01,$01,$01,$04,$23,$02,$01,$01,$01,$01,$04,$23,$22,$A4; $A806: E2 01 01 01 01 04 23 02 01 01 01 01 04 23 22 A4
  .byte $A5,$01,$01,$08,$23,$40,$01,$01,$A6,$A7,$01,$01,$A8,$01,$08,$23; $A816: A5 01 01 08 23 40 01 01 A6 A7 01 01 A8 01 08 23
  .byte $60,$01,$01,$01,$01,$01,$01,$01,$01,$FF; $A826: 60 01 01 01 01 01 01 01 01 FF
Loc_A830:
; --- Code Region ---
  LDY #$3A                              ; $A830: A0 3A
Loc_A832:
  LDA $A856,Y                           ; $A832: B9 56 A8
  STA $0380,Y                           ; $A835: 99 80 03
  DEY                                   ; $A838: 88
  BPL $A832                             ; $A839: 10 F7
  LDY $0509                             ; $A83B: AC 09 05
  LDA $0664,Y                           ; $A83E: B9 64 06
  JSR $A957                             ; $A841: 20 57 A9
  LDY $0509                             ; $A844: AC 09 05
  LDA $0664,Y                           ; $A847: B9 64 06
  JSR $A976                             ; $A84A: 20 76 A9
  LDA $007E                             ; $A84D: AD 7E 00
  ORA #$04                              ; $A850: 09 04
  STA $007E                             ; $A852: 8D 7E 00
  RTS                                   ; $A855: 60
; --- Data Region ---
  .byte $04,$24,$22,$00,$00,$00,$00,$04,$24,$42,$00,$00,$00,$00,$04,$24; $A856: 04 24 22 00 00 00 00 04 24 42 00 00 00 00 04 24
  .byte $62,$00,$00,$00,$00,$04,$24,$82,$00,$00,$00,$00,$04,$24,$A2,$00; $A866: 62 00 00 00 00 04 24 82 00 00 00 00 04 24 A2 00
  .byte $00,$00,$00,$08,$24,$C0,$01,$01,$01,$01,$01,$01,$01,$01,$08,$24; $A876: 00 00 00 08 24 C0 01 01 01 01 01 01 01 01 08 24
  .byte $E0,$01,$01,$01,$01,$01,$01,$01,$01,$FF; $A886: E0 01 01 01 01 01 01 01 01 FF
Loc_A890:
; --- Code Region ---
  LDA $0000                             ; $A890: AD 00 00
  PHA                                   ; $A893: 48
  LDA #$00                              ; $A894: A9 00
  STA $0000                             ; $A896: 8D 00 00
  LDY #$3D                              ; $A899: A0 3D
  JSR $EE07                             ; $A89B: 20 07 EE
; --- Data Region ---
  .byte $15,$A0,$68,$8D,$00,$00           ; $A89E: 15 A0 68 8D 00 00
Loc_A8A4:
; --- Code Region ---
  LDY #$3A                              ; $A8A4: A0 3A
Loc_A8A6:
  LDA $A8C3,Y                           ; $A8A6: B9 C3 A8
  STA $0380,Y                           ; $A8A9: 99 80 03
  DEY                                   ; $A8AC: 88
  BPL $A8A6                             ; $A8AD: 10 F7
  LDA $0000                             ; $A8AF: AD 00 00
  PHA                                   ; $A8B2: 48
  JSR $A957                             ; $A8B3: 20 57 A9
  PLA                                   ; $A8B6: 68
  JSR $A976                             ; $A8B7: 20 76 A9
  LDA $007E                             ; $A8BA: AD 7E 00
  ORA #$04                              ; $A8BD: 09 04
  STA $007E                             ; $A8BF: 8D 7E 00
  RTS                                   ; $A8C2: 60
; --- Data Region ---
  .byte $04,$22,$A2,$00,$00,$00,$00,$04,$22,$C2,$00,$00,$00,$00,$04,$22; $A8C3: 04 22 A2 00 00 00 00 04 22 C2 00 00 00 00 04 22
  .byte $E2,$00,$00,$00,$00,$04,$23,$02,$00,$00,$00,$00,$04,$23,$22,$00; $A8D3: E2 00 00 00 00 04 23 02 00 00 00 00 04 23 22 00
  .byte $00,$00,$00,$08,$23,$40,$01,$01,$01,$01,$01,$01,$01,$01,$08,$23; $A8E3: 00 00 00 08 23 40 01 01 01 01 01 01 01 01 08 23
  .byte $60,$01,$01,$01,$01,$01,$01,$01,$01,$FF; $A8F3: 60 01 01 01 01 01 01 01 01 FF
Loc_A8FD:
; --- Code Region ---
  LDY #$3A                              ; $A8FD: A0 3A
Loc_A8FF:
  LDA $A91D,Y                           ; $A8FF: B9 1D A9
  STA $0380,Y                           ; $A902: 99 80 03
  DEY                                   ; $A905: 88
  BPL $A8FF                             ; $A906: 10 F7
  LDA $04AE                             ; $A908: AD AE 04
  JSR $A957                             ; $A90B: 20 57 A9
  LDA $04AE                             ; $A90E: AD AE 04
  JSR $A976                             ; $A911: 20 76 A9
  LDA $007E                             ; $A914: AD 7E 00
  ORA #$04                              ; $A917: 09 04
  STA $007E                             ; $A919: 8D 7E 00
  RTS                                   ; $A91C: 60
; --- Data Region ---
  .byte $04,$22,$B9,$00,$00,$00,$00,$04,$22,$D9,$00,$00,$00,$00,$04,$22; $A91D: 04 22 B9 00 00 00 00 04 22 D9 00 00 00 00 04 22
  .byte $F9,$00,$00,$00,$00,$04,$23,$19,$00,$00,$00,$00,$04,$23,$39,$00; $A92D: F9 00 00 00 00 04 23 19 00 00 00 00 04 23 39 00
  .byte $00,$00,$00,$08,$23,$57,$01,$01,$01,$01,$01,$01,$01,$01,$08,$23; $A93D: 00 00 00 08 23 57 01 01 01 01 01 01 01 01 08 23
  .byte $77,$01,$01,$01,$01,$01,$01,$01,$01,$FF; $A94D: 77 01 01 01 01 01 01 01 01 FF
Loc_A957:
; --- Code Region ---
  JSR $F308                             ; $A957: 20 08 F3
  TAX                                   ; $A95A: AA
  LDY #$00                              ; $A95B: A0 00
Loc_A95D:
  LDA ($00),Y                           ; $A95D: B1 00
  BEQ $A96E                             ; $A95F: F0 0D
  CMP #$39                              ; $A961: C9 39
  BEQ $A96F                             ; $A963: F0 0A
  CMP #$3A                              ; $A965: C9 3A
  BEQ $A96F                             ; $A967: F0 06
  INY                                   ; $A969: C8
  INX                                   ; $A96A: E8
  JMP $A95D                             ; $A96B: 4C 5D A9
Loc_A96E:
  RTS                                   ; $A96E: 60
Loc_A96F:
  STA $03A5,X                           ; $A96F: 9D A5 03
  INY                                   ; $A972: C8
  JMP $A95D                             ; $A973: 4C 5D A9
Loc_A976:
  JSR $F308                             ; $A976: 20 08 F3
  TAX                                   ; $A979: AA
  LDY #$00                              ; $A97A: A0 00
Loc_A97C:
  LDA ($00),Y                           ; $A97C: B1 00
  BEQ $A990                             ; $A97E: F0 10
  CMP #$39                              ; $A980: C9 39
  BEQ $A98C                             ; $A982: F0 08
  CMP #$3A                              ; $A984: C9 3A
  BEQ $A98C                             ; $A986: F0 04
  STA $03B1,X                           ; $A988: 9D B1 03
  INX                                   ; $A98B: E8
Loc_A98C:
  INY                                   ; $A98C: C8
  JMP $A97C                             ; $A98D: 4C 7C A9
Loc_A990:
  RTS                                   ; $A990: 60
Loc_A991:
  LDA $0001                             ; $A991: AD 01 00
  BNE $A9A4                             ; $A994: D0 0E
  LDY #$3A                              ; $A996: A0 3A
Loc_A998:
  LDA $A9FD,Y                           ; $A998: B9 FD A9
  STA $0380,Y                           ; $A99B: 99 80 03
  DEY                                   ; $A99E: 88
  BPL $A998                             ; $A99F: 10 F7
  JMP $A9AF                             ; $A9A1: 4C AF A9
Loc_A9A4:
  LDY #$3A                              ; $A9A4: A0 3A
Loc_A9A6:
  LDA $A9C3,Y                           ; $A9A6: B9 C3 A9
  STA $0380,Y                           ; $A9A9: 99 80 03
  DEY                                   ; $A9AC: 88
  BPL $A9A6                             ; $A9AD: 10 F7
Loc_A9AF:
  LDA $0000                             ; $A9AF: AD 00 00
  PHA                                   ; $A9B2: 48
  JSR $A957                             ; $A9B3: 20 57 A9
  PLA                                   ; $A9B6: 68
  JSR $A976                             ; $A9B7: 20 76 A9
  LDA $007E                             ; $A9BA: AD 7E 00
  ORA #$04                              ; $A9BD: 09 04
  STA $007E                             ; $A9BF: 8D 7E 00
  RTS                                   ; $A9C2: 60
; --- Data Region ---
  .byte $04,$22,$BA,$00,$00,$00,$00,$04,$22,$DA,$00,$00,$00,$00,$04,$22; $A9C3: 04 22 BA 00 00 00 00 04 22 DA 00 00 00 00 04 22
  .byte $FA,$00,$00,$00,$00,$04,$23,$1A,$00,$00,$00,$00,$04,$23,$3A,$00; $A9D3: FA 00 00 00 00 04 23 1A 00 00 00 00 04 23 3A 00
  .byte $00,$00,$00,$08,$23,$58,$01,$01,$01,$01,$01,$01,$01,$01,$08,$23; $A9E3: 00 00 00 08 23 58 01 01 01 01 01 01 01 01 08 23
  .byte $78,$01,$01,$01,$01,$01,$01,$01,$01,$FF,$04,$22,$A2,$00,$00,$00; $A9F3: 78 01 01 01 01 01 01 01 01 FF 04 22 A2 00 00 00
  .byte $00,$04,$22,$C2,$00,$00,$00,$00,$04,$22,$E2,$00,$00,$00,$00,$04; $AA03: 00 04 22 C2 00 00 00 00 04 22 E2 00 00 00 00 04
  .byte $23,$02,$00,$00,$00,$00,$04,$23,$22,$00,$00,$00,$00,$08,$23,$40; $AA13: 23 02 00 00 00 00 04 23 22 00 00 00 00 08 23 40
  .byte $01,$01,$01,$01,$01,$01,$01,$01,$08,$23,$60,$01,$01,$01,$01,$01; $AA23: 01 01 01 01 01 01 01 01 08 23 60 01 01 01 01 01
  .byte $01,$01,$01,$FF                   ; $AA33: 01 01 01 FF
Loc_AA37:
; --- Code Region ---
  LDA $000A                             ; $AA37: AD 0A 00
  PHA                                   ; $AA3A: 48
  LDA $000B                             ; $AA3B: AD 0B 00
  PHA                                   ; $AA3E: 48
  LDA $000C                             ; $AA3F: AD 0C 00
  PHA                                   ; $AA42: 48
  LDA $000B                             ; $AA43: AD 0B 00
  CMP #$FF                              ; $AA46: C9 FF
  BEQ $AA4D                             ; $AA48: F0 03
  JSR $AB38                             ; $AA4A: 20 38 AB
Loc_AA4D:
  PLA                                   ; $AA4D: 68
  STA $000C                             ; $AA4E: 8D 0C 00
  PLA                                   ; $AA51: 68
  STA $000B                             ; $AA52: 8D 0B 00
  PLA                                   ; $AA55: 68
  STA $000A                             ; $AA56: 8D 0A 00
  LDA $000C                             ; $AA59: AD 0C 00
  BEQ $AA5F                             ; $AA5C: F0 01
  RTS                                   ; $AA5E: 60
Loc_AA5F:
  LDY #$30                              ; $AA5F: A0 30
  LDA #$01                              ; $AA61: A9 01
Loc_AA63:
  STA $0380,Y                           ; $AA63: 99 80 03
  DEY                                   ; $AA66: 88
  BPL $AA63                             ; $AA67: 10 FA
  LDA $000A                             ; $AA69: AD 0A 00
  CMP #$FF                              ; $AA6C: C9 FF
  BNE $AA73                             ; $AA6E: D0 03
  JMP $AADE                             ; $AA70: 4C DE AA
Loc_AA73:
  ASL                                   ; $AA73: 0A
  CLC                                   ; $AA74: 18
  ADC $000A                             ; $AA75: 6D 0A 00
  ASL                                   ; $AA78: 0A
  ASL                                   ; $AA79: 0A
  TAY                                   ; $AA7A: A8
  LDA $AB08,Y                           ; $AA7B: B9 08 AB
  STA $038D                             ; $AA7E: 8D 8D 03
  LDA $AB09,Y                           ; $AA81: B9 09 AB
  STA $038E                             ; $AA84: 8D 8E 03
  LDA $AB0A,Y                           ; $AA87: B9 0A AB
  STA $038F                             ; $AA8A: 8D 8F 03
  LDA $AB0B,Y                           ; $AA8D: B9 0B AB
  STA $0390                             ; $AA90: 8D 90 03
  LDA $AB0C,Y                           ; $AA93: B9 0C AB
  STA $0391                             ; $AA96: 8D 91 03
  LDA $AB0D,Y                           ; $AA99: B9 0D AB
  STA $0392                             ; $AA9C: 8D 92 03
  LDA $AB0E,Y                           ; $AA9F: B9 0E AB
  STA $03A0                             ; $AAA2: 8D A0 03
  LDA $AB0F,Y                           ; $AAA5: B9 0F AB
  STA $03A1                             ; $AAA8: 8D A1 03
  LDA $AB10,Y                           ; $AAAB: B9 10 AB
  STA $03A2                             ; $AAAE: 8D A2 03
  LDA $AB11,Y                           ; $AAB1: B9 11 AB
  STA $03A3                             ; $AAB4: 8D A3 03
  LDA $AB12,Y                           ; $AAB7: B9 12 AB
  STA $03A4                             ; $AABA: 8D A4 03
  LDA $AB13,Y                           ; $AABD: B9 13 AB
  STA $03A5                             ; $AAC0: 8D A5 03
  LDA #$76                              ; $AAC3: A9 76
  STA $00BD                             ; $AAC5: 8D BD 00
  LDA #$C0                              ; $AAC8: A9 C0
  STA $0389                             ; $AACA: 8D 89 03
  LDA #$C1                              ; $AACD: A9 C1
  STA $038A                             ; $AACF: 8D 8A 03
  LDA #$D0                              ; $AAD2: A9 D0
  STA $039C                             ; $AAD4: 8D 9C 03
  LDA #$D1                              ; $AAD7: A9 D1
  STA $039D                             ; $AAD9: 8D 9D 03
  LDA #$FF                              ; $AADC: A9 FF
Loc_AADE:
  LDA #$10                              ; $AADE: A9 10
  STA $0380                             ; $AAE0: 8D 80 03
  STA $0393                             ; $AAE3: 8D 93 03
  LDA #$22                              ; $AAE6: A9 22
  STA $0381                             ; $AAE8: 8D 81 03
  LDA #$C8                              ; $AAEB: A9 C8
  STA $0382                             ; $AAED: 8D 82 03
  LDA #$22                              ; $AAF0: A9 22
  STA $0394                             ; $AAF2: 8D 94 03
  LDA #$E8                              ; $AAF5: A9 E8
  STA $0395                             ; $AAF7: 8D 95 03
  LDA #$FF                              ; $AAFA: A9 FF
  STA $03A6                             ; $AAFC: 8D A6 03
  LDA $007E                             ; $AAFF: AD 7E 00
  ORA #$04                              ; $AB02: 09 04
  STA $007E                             ; $AB04: 8D 7E 00
  RTS                                   ; $AB07: 60
; --- Data Region ---
  .byte $C2,$C3,$C4,$C5,$C6,$C7,$D2,$D3,$D4,$D5,$D6,$D7,$C8,$C9,$CA,$CB; $AB08: C2 C3 C4 C5 C6 C7 D2 D3 D4 D5 D6 D7 C8 C9 CA CB
  .byte $01,$01,$D8,$D9,$DA,$DB,$01,$01,$C2,$C3,$CC,$CD,$C6,$C7,$D2,$D3; $AB18: 01 01 D8 D9 DA DB 01 01 C2 C3 CC CD C6 C7 D2 D3
  .byte $DC,$DD,$D6,$D7,$CE,$CF,$E0,$E1,$01,$01,$DE,$DF,$F0,$F1,$01,$01; $AB28: DC DD D6 D7 CE CF E0 E1 01 01 DE DF F0 F1 01 01
Loc_AB38:
; --- Code Region ---
  LDY #$31                              ; $AB38: A0 31
  JSR $F25F                             ; $AB3A: 20 5F F2
  LDA $000B                             ; $AB3D: AD 0B 00
  STA $0000                             ; $AB40: 8D 00 00
  LDA #$00                              ; $AB43: A9 00
  STA $0001                             ; $AB45: 8D 01 00
  STA $0002                             ; $AB48: 8D 02 00
  LDA #$0D                              ; $AB4B: A9 0D
  STA $0003                             ; $AB4D: 8D 03 00
  JSR $EBE9                             ; $AB50: 20 E9 EB
  LDA $0006                             ; $AB53: AD 06 00
  CLC                                   ; $AB56: 18
  ADC #$B4                              ; $AB57: 69 B4
  STA $0000                             ; $AB59: 8D 00 00
  LDA $0007                             ; $AB5C: AD 07 00
  ADC #$8D                              ; $AB5F: 69 8D
  STA $0001                             ; $AB61: 8D 01 00
  LDY #$00                              ; $AB64: A0 00
  LDA ($00),Y                           ; $AB66: B1 00
  STA $00B9                             ; $AB68: 8D B9 00
  LDX #$30                              ; $AB6B: A2 30
  LDY #$01                              ; $AB6D: A0 01
Loc_AB6F:
  LDA ($00),Y                           ; $AB6F: B1 00
  CMP #$FF                              ; $AB71: C9 FF
  BEQ $AB82                             ; $AB73: F0 0D
  TXA                                   ; $AB75: 8A
  SEC                                   ; $AB76: 38
  SBC #$10                              ; $AB77: E9 10
  TAX                                   ; $AB79: AA
  INY                                   ; $AB7A: C8
  INY                                   ; $AB7B: C8
  INY                                   ; $AB7C: C8
  INY                                   ; $AB7D: C8
  CPY #$0D                              ; $AB7E: C0 0D
  BCC $AB6F                             ; $AB80: 90 ED
Loc_AB82:
  STX $0002                             ; $AB82: 8E 02 00
  LDX $007C                             ; $AB85: AE 7C 00
  LDY #$01                              ; $AB88: A0 01
Loc_AB8A:
  LDA ($00),Y                           ; $AB8A: B1 00
  CMP #$FF                              ; $AB8C: C9 FF
  BEQ $ABB4                             ; $AB8E: F0 24
  CLC                                   ; $AB90: 18
  ADC #$C0                              ; $AB91: 69 C0
  STA $0201,X                           ; $AB93: 9D 01 02
  LDA $ABB8,Y                           ; $AB96: B9 B8 AB
  STA $0200,X                           ; $AB99: 9D 00 02
  LDA $ABC5,Y                           ; $AB9C: B9 C5 AB
  CLC                                   ; $AB9F: 18
  ADC $0002                             ; $ABA0: 6D 02 00
  STA $0203,X                           ; $ABA3: 9D 03 02
  LDA #$01                              ; $ABA6: A9 01
  STA $0202,X                           ; $ABA8: 9D 02 02
  INX                                   ; $ABAB: E8
  INX                                   ; $ABAC: E8
  INX                                   ; $ABAD: E8
  INX                                   ; $ABAE: E8
  INY                                   ; $ABAF: C8
  CPY #$0D                              ; $ABB0: C0 0D
  BCC $AB8A                             ; $ABB2: 90 D6
Loc_ABB4:
  STX $007C                             ; $ABB4: 8E 7C 00
  RTS                                   ; $ABB7: 60
; --- Data Region ---
  .byte $F0,$AF,$AF,$B7,$B7,$AF,$AF,$B7,$B7,$AF,$AF,$B7,$B7,$F0,$38,$40; $ABB8: F0 AF AF B7 B7 AF AF B7 B7 AF AF B7 B7 F0 38 40
  .byte $38,$40,$48,$50,$48,$50,$58,$60,$58,$60; $ABC8: 38 40 48 50 48 50 58 60 58 60
Loc_ABD2:
; --- Code Region ---
  LDA $037C                             ; $ABD2: AD 7C 03
  BEQ $ABF4                             ; $ABD5: F0 1D
  LDY #$31                              ; $ABD7: A0 31
  JSR $F25F                             ; $ABD9: 20 5F F2
  LDA $037D                             ; $ABDC: AD 7D 03
  CMP #$FF                              ; $ABDF: C9 FF
  BEQ $ABE8                             ; $ABE1: F0 05
  LDA #$01                              ; $ABE3: A9 01
  JSR $B14C                             ; $ABE5: 20 4C B1
Loc_ABE8:
  LDA $037E                             ; $ABE8: AD 7E 03
  CMP #$FF                              ; $ABEB: C9 FF
  BEQ $ABF4                             ; $ABED: F0 05
  LDA #$02                              ; $ABEF: A9 02
  JSR $B14C                             ; $ABF1: 20 4C B1
Loc_ABF4:
  LDA $0140                             ; $ABF4: AD 40 01
  BEQ $AC38                             ; $ABF7: F0 3F
  LDA $0140                             ; $ABF9: AD 40 01
  BMI $AC39                             ; $ABFC: 30 3B
  AND #$0F                              ; $ABFE: 29 0F
  CMP #$01                              ; $AC00: C9 01
  BEQ $AC18                             ; $AC02: F0 14
  LDA $007E                             ; $AC04: AD 7E 00
  AND #$08                              ; $AC07: 29 08
  BNE $AC38                             ; $AC09: D0 2D
  LDA $0150                             ; $AC0B: AD 50 01
  AND #$0F                              ; $AC0E: 29 0F
  BNE $AC15                             ; $AC10: D0 03
  JMP $AEC9                             ; $AC12: 4C C9 AE
Loc_AC15:
  JMP $ADF3                             ; $AC15: 4C F3 AD
Loc_AC18:
  LDA #$00                              ; $AC18: A9 00
  STA $0140                             ; $AC1A: 8D 40 01
  LDA $0150                             ; $AC1D: AD 50 01
  AND #$0F                              ; $AC20: 29 0F
  BNE $AC27                             ; $AC22: D0 03
  STA $0420                             ; $AC24: 8D 20 04
Loc_AC27:
  CMP #$01                              ; $AC27: C9 01
  BNE $AC30                             ; $AC29: D0 05
  LDA #$FF                              ; $AC2B: A9 FF
  STA $037C                             ; $AC2D: 8D 7C 03
Loc_AC30:
  LDA $0150                             ; $AC30: AD 50 01
  AND #$80                              ; $AC33: 29 80
  STA $0150                             ; $AC35: 8D 50 01
Loc_AC38:
  RTS                                   ; $AC38: 60
Loc_AC39:
  LDA #$00                              ; $AC39: A9 00
  STA $037C                             ; $AC3B: 8D 7C 03
  LDA #$05                              ; $AC3E: A9 05
  STA $0140                             ; $AC40: 8D 40 01
  LDA #$00                              ; $AC43: A9 00
  STA $0143                             ; $AC45: 8D 43 01
  LDA #$80                              ; $AC48: A9 80
  STA $0144                             ; $AC4A: 8D 44 01
  LDA #$38                              ; $AC4D: A9 38
  STA $0154                             ; $AC4F: 8D 54 01
  LDA $0150                             ; $AC52: AD 50 01
  AND #$0F                              ; $AC55: 29 0F
  BNE $AC5C                             ; $AC57: D0 03
  JMP $AD92                             ; $AC59: 4C 92 AD
Loc_AC5C:
  LDA #$83                              ; $AC5C: A9 83
  STA $0152                             ; $AC5E: 8D 52 01
  LDA #$B6                              ; $AC61: A9 B6
  STA $0153                             ; $AC63: 8D 53 01
  LDA #$09                              ; $AC66: A9 09
  STA $00B4                             ; $AC68: 8D B4 00
  STA $00C4                             ; $AC6B: 8D C4 00
  STA $00CC                             ; $AC6E: 8D CC 00
  STA $00D4                             ; $AC71: 8D D4 00
  STA $00DC                             ; $AC74: 8D DC 00
  LDY #$80                              ; $AC77: A0 80
  LDA $0150                             ; $AC79: AD 50 01
  BPL $AC80                             ; $AC7C: 10 02
  LDY #$40                              ; $AC7E: A0 40
Loc_AC80:
  STY $0420                             ; $AC80: 8C 20 04
  AND #$0F                              ; $AC83: 29 0F
  CMP #$01                              ; $AC85: C9 01
  BEQ $ACCD                             ; $AC87: F0 44
  CMP #$02                              ; $AC89: C9 02
  BEQ $AC95                             ; $AC8B: F0 08
  CMP #$03                              ; $AC8D: C9 03
  BEQ $ACAF                             ; $AC8F: F0 1E
  CMP #$04                              ; $AC91: C9 04
  BEQ $ACBE                             ; $AC93: F0 29
Loc_AC95:
  LDA #$E5                              ; $AC95: A9 E5
  STA $0149                             ; $AC97: 8D 49 01
  LDA #$B3                              ; $AC9A: A9 B3
  STA $014A                             ; $AC9C: 8D 4A 01
  LDA #$01                              ; $AC9F: A9 01
  STA $00B3                             ; $ACA1: 8D B3 00
  STA $00C3                             ; $ACA4: 8D C3 00
  STA $00CB                             ; $ACA7: 8D CB 00
  LDA #$05                              ; $ACAA: A9 05
  JMP $AD1F                             ; $ACAC: 4C 1F AD
Loc_ACAF:
  LDA #$C1                              ; $ACAF: A9 C1
  STA $0149                             ; $ACB1: 8D 49 01
  LDA #$B4                              ; $ACB4: A9 B4
  STA $014A                             ; $ACB6: 8D 4A 01
  LDA #$05                              ; $ACB9: A9 05
  JMP $AD16                             ; $ACBB: 4C 16 AD
Loc_ACBE:
  LDA #$9C                              ; $ACBE: A9 9C
  STA $0149                             ; $ACC0: 8D 49 01
  LDA #$B5                              ; $ACC3: A9 B5
  STA $014A                             ; $ACC5: 8D 4A 01
  LDA #$05                              ; $ACC8: A9 05
  JMP $AD16                             ; $ACCA: 4C 16 AD
Loc_ACCD:
  LDA #$05                              ; $ACCD: A9 05
  STA $0149                             ; $ACCF: 8D 49 01
  LDA #$B3                              ; $ACD2: A9 B3
  STA $014A                             ; $ACD4: 8D 4A 01
  LDA $0402                             ; $ACD7: AD 02 04
  JSR $F2AF                             ; $ACDA: 20 AF F2
  LDY #$11                              ; $ACDD: A0 11
  LDA ($00),Y                           ; $ACDF: B1 00
  STA $037E                             ; $ACE1: 8D 7E 03
  LDY #$00                              ; $ACE4: A0 00
  LDA ($00),Y                           ; $ACE6: B1 00
  CMP #$07                              ; $ACE8: C9 07
  BNE $ACF1                             ; $ACEA: D0 05
  LDA #$FF                              ; $ACEC: A9 FF
  JMP $AD03                             ; $ACEE: 4C 03 AD
Loc_ACF1:
  ASL                                   ; $ACF1: 0A
  TAY                                   ; $ACF2: A8
  LDA $AD84,Y                           ; $ACF3: B9 84 AD
  STA $0000                             ; $ACF6: 8D 00 00
  LDA $AD85,Y                           ; $ACF9: B9 85 AD
  STA $0001                             ; $ACFC: 8D 01 00
  LDY #$00                              ; $ACFF: A0 00
  LDA ($00),Y                           ; $AD01: B1 00
Loc_AD03:
  STA $037D                             ; $AD03: 8D 7D 03
  LDA #$08                              ; $AD06: A9 08
  STA $00B4                             ; $AD08: 8D B4 00
  STA $00C4                             ; $AD0B: 8D C4 00
  STA $00CC                             ; $AD0E: 8D CC 00
  STA $00D4                             ; $AD11: 8D D4 00
  LDA #$01                              ; $AD14: A9 01
Loc_AD16:
  STA $00B3                             ; $AD16: 8D B3 00
  STA $00C3                             ; $AD19: 8D C3 00
  STA $00CB                             ; $AD1C: 8D CB 00
Loc_AD1F:
  STA $00D3                             ; $AD1F: 8D D3 00
  STA $00DB                             ; $AD22: 8D DB 00
  LDA #$00                              ; $AD25: A9 00
  STA $00C2                             ; $AD27: 8D C2 00
  STA $00CA                             ; $AD2A: 8D CA 00
  STA $00D2                             ; $AD2D: 8D D2 00
  STA $00DA                             ; $AD30: 8D DA 00
  LDA $0150                             ; $AD33: AD 50 01
  LDA #$20                              ; $AD36: A9 20
  STA $0142                             ; $AD38: 8D 42 01
  LDA #$23                              ; $AD3B: A9 23
  STA $0148                             ; $AD3D: 8D 48 01
  LDA $0150                             ; $AD40: AD 50 01
  BPL $AD5B                             ; $AD43: 10 16
  LDA #$C4                              ; $AD45: A9 C4
  STA $0147                             ; $AD47: 8D 47 01
  LDA #$7F                              ; $AD4A: A9 7F
  STA $0145                             ; $AD4C: 8D 45 01
  LDA #$B6                              ; $AD4F: A9 B6
  STA $0146                             ; $AD51: 8D 46 01
  LDX #$10                              ; $AD54: A2 10
  LDY #$CC                              ; $AD56: A0 CC
  JMP $AD6E                             ; $AD58: 4C 6E AD
Loc_AD5B:
  LDA #$C0                              ; $AD5B: A9 C0
  STA $0147                             ; $AD5D: 8D 47 01
  LDA #$7B                              ; $AD60: A9 7B
  STA $0145                             ; $AD62: 8D 45 01
  LDA #$B6                              ; $AD65: A9 B6
  STA $0146                             ; $AD67: 8D 46 01
  LDX #$02                              ; $AD6A: A2 02
  LDY #$C8                              ; $AD6C: A0 C8
Loc_AD6E:
  STX $0141                             ; $AD6E: 8E 41 01
  TYA                                   ; $AD71: 98
  CLC                                   ; $AD72: 18
  ADC $0143                             ; $AD73: 6D 43 01
  STA $0143                             ; $AD76: 8D 43 01
  LDA #$03                              ; $AD79: A9 03
  ADC $0144                             ; $AD7B: 6D 44 01
  STA $0144                             ; $AD7E: 8D 44 01
  JMP $ADF3                             ; $AD81: 4C F3 AD
; --- Data Region ---
  .byte $07,$6F,$0F,$6F,$17,$6F,$1F,$6F,$27,$6F,$2F,$6F,$37,$6F; $AD84: 07 6F 0F 6F 17 6F 1F 6F 27 6F 2F 6F 37 6F
Loc_AD92:
; --- Code Region ---
  LDA #$22                              ; $AD92: A9 22
  STA $0142                             ; $AD94: 8D 42 01
  LDA #$03                              ; $AD97: A9 03
  STA $0146                             ; $AD99: 8D 46 01
  LDA #$23                              ; $AD9C: A9 23
  STA $0148                             ; $AD9E: 8D 48 01
  LDA #$00                              ; $ADA1: A9 00
  STA $037C                             ; $ADA3: 8D 7C 03
  LDA $0150                             ; $ADA6: AD 50 01
  BPL $ADBC                             ; $ADA9: 10 11
  LDA #$E4                              ; $ADAB: A9 E4
  STA $0145                             ; $ADAD: 8D 45 01
  LDA #$EC                              ; $ADB0: A9 EC
  STA $0147                             ; $ADB2: 8D 47 01
  LDX #$90                              ; $ADB5: A2 90
  LDY #$10                              ; $ADB7: A0 10
  JMP $ADCA                             ; $ADB9: 4C CA AD
Loc_ADBC:
  LDA #$E0                              ; $ADBC: A9 E0
  STA $0145                             ; $ADBE: 8D 45 01
  LDA #$E8                              ; $ADC1: A9 E8
  STA $0147                             ; $ADC3: 8D 47 01
  LDX #$82                              ; $ADC6: A2 82
  LDY #$02                              ; $ADC8: A0 02
Loc_ADCA:
  STX $0141                             ; $ADCA: 8E 41 01
  LDA $0143                             ; $ADCD: AD 43 01
  CLC                                   ; $ADD0: 18
  ADC $0145                             ; $ADD1: 6D 45 01
  STA $0145                             ; $ADD4: 8D 45 01
  LDA $0146                             ; $ADD7: AD 46 01
  ADC $0144                             ; $ADDA: 6D 44 01
  STA $0146                             ; $ADDD: 8D 46 01
  TYA                                   ; $ADE0: 98
  CLC                                   ; $ADE1: 18
  ADC $0143                             ; $ADE2: 6D 43 01
  STA $0143                             ; $ADE5: 8D 43 01
  LDA $0144                             ; $ADE8: AD 44 01
  ADC #$02                              ; $ADEB: 69 02
  STA $0144                             ; $ADED: 8D 44 01
  JMP $AEC9                             ; $ADF0: 4C C9 AE
Loc_ADF3:
  DEC $0140                             ; $ADF3: CE 40 01
  LDY #$30                              ; $ADF6: A0 30
  JSR $F25F                             ; $ADF8: 20 5F F2
  LDA $0149                             ; $ADFB: AD 49 01
  STA $0010                             ; $ADFE: 8D 10 00
  LDA $014A                             ; $AE01: AD 4A 01
  STA $0011                             ; $AE04: 8D 11 00
  LDY #$00                              ; $AE07: A0 00
  LDX #$00                              ; $AE09: A2 00
Loc_AE0B:
  LDA ($10),Y                           ; $AE0B: B1 10
  CMP #$F0                              ; $AE0D: C9 F0
  BCS $AE19                             ; $AE0F: B0 08
  STA $0160,X                           ; $AE11: 9D 60 01
  INY                                   ; $AE14: C8
  INX                                   ; $AE15: E8
  JMP $AE1C                             ; $AE16: 4C 1C AE
Loc_AE19:
  JSR $AF77                             ; $AE19: 20 77 AF
Loc_AE1C:
  CPX #$38                              ; $AE1C: E0 38
  BCC $AE0B                             ; $AE1E: 90 EB
  TYA                                   ; $AE20: 98
  LDY #$09                              ; $AE21: A0 09
  JSR $AF66                             ; $AE23: 20 66 AF
  LDA $0145                             ; $AE26: AD 45 01
  STA $0010                             ; $AE29: 8D 10 00
  LDA $0146                             ; $AE2C: AD 46 01
  STA $0011                             ; $AE2F: 8D 11 00
  LDA $0143                             ; $AE32: AD 43 01
  STA $0012                             ; $AE35: 8D 12 00
  LDA $0144                             ; $AE38: AD 44 01
  STA $0013                             ; $AE3B: 8D 13 00
  LDY #$00                              ; $AE3E: A0 00
  LDA ($12),Y                           ; $AE40: B1 12
  AND #$33                              ; $AE42: 29 33
  ORA ($10),Y                           ; $AE44: 11 10
  STA $014B,Y                           ; $AE46: 99 4B 01
  INY                                   ; $AE49: C8
Loc_AE4A:
  LDA ($10),Y                           ; $AE4A: B1 10
  STA $014B,Y                           ; $AE4C: 99 4B 01
  INY                                   ; $AE4F: C8
  CPY #$03                              ; $AE50: C0 03
  BCC $AE4A                             ; $AE52: 90 F6
  LDA ($12),Y                           ; $AE54: B1 12
  AND #$CC                              ; $AE56: 29 CC
  ORA ($10),Y                           ; $AE58: 11 10
  STA $014B,Y                           ; $AE5A: 99 4B 01
  LDA #$08                              ; $AE5D: A9 08
  LDY #$07                              ; $AE5F: A0 07
  JSR $AF66                             ; $AE61: 20 66 AF
  LDA #$08                              ; $AE64: A9 08
  LDY #$03                              ; $AE66: A0 03
  JSR $AF66                             ; $AE68: 20 66 AF
  LDA #$80                              ; $AE6B: A9 80
  LDY #$01                              ; $AE6D: A0 01
  JSR $AF66                             ; $AE6F: 20 66 AF
  LDA $0150                             ; $AE72: AD 50 01
  AND #$0F                              ; $AE75: 29 0F
  CMP #$01                              ; $AE77: C9 01
  BNE $AEC0                             ; $AE79: D0 45
  LDA $0140                             ; $AE7B: AD 40 01
  CMP #$04                              ; $AE7E: C9 04
  BNE $AE85                             ; $AE80: D0 03
  JSR $B0AB                             ; $AE82: 20 AB B0
Loc_AE85:
  LDA $0402                             ; $AE85: AD 02 04
  JSR $F2AF                             ; $AE88: 20 AF F2
  LDY #$00                              ; $AE8B: A0 00
  LDA ($00),Y                           ; $AE8D: B1 00
  CMP #$07                              ; $AE8F: C9 07
  BEQ $AEC0                             ; $AE91: F0 2D
  LDA $0140                             ; $AE93: AD 40 01
  CMP #$04                              ; $AE96: C9 04
  BEQ $AEA5                             ; $AE98: F0 0B
  CMP #$03                              ; $AE9A: C9 03
  BEQ $AEAD                             ; $AE9C: F0 0F
  CMP #$02                              ; $AE9E: C9 02
  BEQ $AEB8                             ; $AEA0: F0 16
  JMP $AEC0                             ; $AEA2: 4C C0 AE
Loc_AEA5:
  LDA #$00                              ; $AEA5: A9 00
  JSR $B23A                             ; $AEA7: 20 3A B2
  JMP $AEC0                             ; $AEAA: 4C C0 AE
Loc_AEAD:
  LDA #$01                              ; $AEAD: A9 01
  JSR $B23A                             ; $AEAF: 20 3A B2
  JSR $B27A                             ; $AEB2: 20 7A B2
  JMP $AEC0                             ; $AEB5: 4C C0 AE
Loc_AEB8:
  LDA #$02                              ; $AEB8: A9 02
  STA $000F                             ; $AEBA: 8D 0F 00
  JSR $B27A                             ; $AEBD: 20 7A B2
Loc_AEC0:
  LDA $007E                             ; $AEC0: AD 7E 00
  ORA #$08                              ; $AEC3: 09 08
  STA $007E                             ; $AEC5: 8D 7E 00
  RTS                                   ; $AEC8: 60
Loc_AEC9:
  DEC $0140                             ; $AEC9: CE 40 01
  LDY #$30                              ; $AECC: A0 30
  JSR $F25F                             ; $AECE: 20 5F F2
  LDA $0143                             ; $AED1: AD 43 01
  STA $0010                             ; $AED4: 8D 10 00
  LDA $0144                             ; $AED7: AD 44 01
  STA $0011                             ; $AEDA: 8D 11 00
  LDX #$00                              ; $AEDD: A2 00
Loc_AEDF:
  LDY #$00                              ; $AEDF: A0 00
Loc_AEE1:
  LDA ($10),Y                           ; $AEE1: B1 10
  STA $0160,X                           ; $AEE3: 9D 60 01
  INY                                   ; $AEE6: C8
  INX                                   ; $AEE7: E8
  CPY #$0E                              ; $AEE8: C0 0E
  BCC $AEE1                             ; $AEEA: 90 F5
  LDA $0010                             ; $AEEC: AD 10 00
  CLC                                   ; $AEEF: 18
  ADC #$20                              ; $AEF0: 69 20
  STA $0010                             ; $AEF2: 8D 10 00
  LDA $0011                             ; $AEF5: AD 11 00
  ADC #$00                              ; $AEF8: 69 00
  STA $0011                             ; $AEFA: 8D 11 00
  CPX #$38                              ; $AEFD: E0 38
  BCC $AEDF                             ; $AEFF: 90 DE
  LDA $0143                             ; $AF01: AD 43 01
  SEC                                   ; $AF04: 38
  SBC #$80                              ; $AF05: E9 80
  STA $0143                             ; $AF07: 8D 43 01
  LDA $0144                             ; $AF0A: AD 44 01
  SBC #$00                              ; $AF0D: E9 00
  STA $0144                             ; $AF0F: 8D 44 01
  LDA $0145                             ; $AF12: AD 45 01
  STA $0010                             ; $AF15: 8D 10 00
  LDA $0146                             ; $AF18: AD 46 01
  STA $0011                             ; $AF1B: 8D 11 00
  LDY #$00                              ; $AF1E: A0 00
Loc_AF20:
  LDA ($10),Y                           ; $AF20: B1 10
  STA $014B,Y                           ; $AF22: 99 4B 01
  INY                                   ; $AF25: C8
  CPY #$04                              ; $AF26: C0 04
  BCC $AF20                             ; $AF28: 90 F6
  LDA $0145                             ; $AF2A: AD 45 01
  SEC                                   ; $AF2D: 38
  SBC #$08                              ; $AF2E: E9 08
  STA $0145                             ; $AF30: 8D 45 01
  LDA $0146                             ; $AF33: AD 46 01
  SBC #$00                              ; $AF36: E9 00
  STA $0146                             ; $AF38: 8D 46 01
  LDA $0147                             ; $AF3B: AD 47 01
  SEC                                   ; $AF3E: 38
  SBC #$08                              ; $AF3F: E9 08
  STA $0147                             ; $AF41: 8D 47 01
  LDA $0148                             ; $AF44: AD 48 01
  SBC #$00                              ; $AF47: E9 00
  STA $0148                             ; $AF49: 8D 48 01
  LDA $0141                             ; $AF4C: AD 41 01
  SEC                                   ; $AF4F: 38
  SBC #$80                              ; $AF50: E9 80
  STA $0141                             ; $AF52: 8D 41 01
  LDA $0142                             ; $AF55: AD 42 01
  SBC #$00                              ; $AF58: E9 00
  STA $0142                             ; $AF5A: 8D 42 01
  LDA $007E                             ; $AF5D: AD 7E 00
  ORA #$08                              ; $AF60: 09 08
  STA $007E                             ; $AF62: 8D 7E 00
  RTS                                   ; $AF65: 60
Loc_AF66:
  CLC                                   ; $AF66: 18
  ADC $0140,Y                           ; $AF67: 79 40 01
  STA $0140,Y                           ; $AF6A: 99 40 01
  INY                                   ; $AF6D: C8
  LDA #$00                              ; $AF6E: A9 00
  ADC $0140,Y                           ; $AF70: 79 40 01
  STA $0140,Y                           ; $AF73: 99 40 01
  RTS                                   ; $AF76: 60
Loc_AF77:
  STA $0012                             ; $AF77: 8D 12 00
  INY                                   ; $AF7A: C8
  LDA ($10),Y                           ; $AF7B: B1 10
  STA $0013                             ; $AF7D: 8D 13 00
  INY                                   ; $AF80: C8
  TYA                                   ; $AF81: 98
  PHA                                   ; $AF82: 48
  LDA $0402                             ; $AF83: AD 02 04
  JSR $F2AF                             ; $AF86: 20 AF F2
  PLA                                   ; $AF89: 68
  TAY                                   ; $AF8A: A8
  LDA ($10),Y                           ; $AF8B: B1 10
  INY                                   ; $AF8D: C8
  CLC                                   ; $AF8E: 18
  ADC $0000                             ; $AF8F: 6D 00 00
  STA $0017                             ; $AF92: 8D 17 00
  LDA $0001                             ; $AF95: AD 01 00
  ADC #$00                              ; $AF98: 69 00
  STA $0018                             ; $AF9A: 8D 18 00
  TYA                                   ; $AF9D: 98
  PHA                                   ; $AF9E: 48
  LDA $0012                             ; $AF9F: AD 12 00
  CMP #$F0                              ; $AFA2: C9 F0
  BEQ $AFD3                             ; $AFA4: F0 2D
  CMP #$F1                              ; $AFA6: C9 F1
  BEQ $AFC0                             ; $AFA8: F0 16
  CMP #$F3                              ; $AFAA: C9 F3
  BEQ $AFEF                             ; $AFAC: F0 41
  LDY #$00                              ; $AFAE: A0 00
  LDA ($17),Y                           ; $AFB0: B1 17
  STA $0001                             ; $AFB2: 8D 01 00
  LDA #$00                              ; $AFB5: A9 00
  STA $0002                             ; $AFB7: 8D 02 00
  STA $0003                             ; $AFBA: 8D 03 00
  JMP $B032                             ; $AFBD: 4C 32 B0
Loc_AFC0:
  LDY #$00                              ; $AFC0: A0 00
  STY $0003                             ; $AFC2: 8C 03 00
  LDA ($17),Y                           ; $AFC5: B1 17
  STA $0001                             ; $AFC7: 8D 01 00
  INY                                   ; $AFCA: C8
  LDA ($17),Y                           ; $AFCB: B1 17
  STA $0002                             ; $AFCD: 8D 02 00
  JMP $B032                             ; $AFD0: 4C 32 B0
Loc_AFD3:
  LDY #$00                              ; $AFD3: A0 00
  STY $0003                             ; $AFD5: 8C 03 00
  STY $0002                             ; $AFD8: 8C 02 00
  STY $0001                             ; $AFDB: 8C 01 00
Loc_AFDE:
  LDA ($17),Y                           ; $AFDE: B1 17
  CMP #$FF                              ; $AFE0: C9 FF
  BEQ $AFE7                             ; $AFE2: F0 03
  INC $0001                             ; $AFE4: EE 01 00
Loc_AFE7:
  INY                                   ; $AFE7: C8
  CPY #$0A                              ; $AFE8: C0 0A
  BCC $AFDE                             ; $AFEA: 90 F2
  JMP $B032                             ; $AFEC: 4C 32 B0
Loc_AFEF:
  LDY #$00                              ; $AFEF: A0 00
  STY $0002                             ; $AFF1: 8C 02 00
  STY $0003                             ; $AFF4: 8C 03 00
  STY $0004                             ; $AFF7: 8C 04 00
Loc_AFFA:
  LDA ($17),Y                           ; $AFFA: B1 17
  CMP #$FF                              ; $AFFC: C9 FF
  BEQ $B021                             ; $AFFE: F0 21
  JSR $F2D7                             ; $B000: 20 D7 F2
  LDY #$08                              ; $B003: A0 08
  LDA ($00),Y                           ; $B005: B1 00
  CLC                                   ; $B007: 18
  ADC $0002                             ; $B008: 6D 02 00
  STA $0002                             ; $B00B: 8D 02 00
  INY                                   ; $B00E: C8
  LDA ($00),Y                           ; $B00F: B1 00
  ADC $0003                             ; $B011: 6D 03 00
  STA $0003                             ; $B014: 8D 03 00
  INC $0004                             ; $B017: EE 04 00
  LDY $0004                             ; $B01A: AC 04 00
  CPY #$0A                              ; $B01D: C0 0A
  BCC $AFFA                             ; $B01F: 90 D9
Loc_B021:
  LDA $0002                             ; $B021: AD 02 00
  STA $0001                             ; $B024: 8D 01 00
  LDA $0003                             ; $B027: AD 03 00
  STA $0002                             ; $B02A: 8D 02 00
  LDA #$00                              ; $B02D: A9 00
  STA $0003                             ; $B02F: 8D 03 00
Loc_B032:
  TXA                                   ; $B032: 8A
  PHA                                   ; $B033: 48
  JSR $E9BA                             ; $B034: 20 BA E9
  PLA                                   ; $B037: 68
  TAX                                   ; $B038: AA
  PLA                                   ; $B039: 68
  TAY                                   ; $B03A: A8
  LDA #$B6                              ; $B03B: A9 B6
  STA $0017                             ; $B03D: 8D 17 00
Loc_B040:
  LDA #$01                              ; $B040: A9 01
  STA $0016                             ; $B042: 8D 16 00
  LDA $0013                             ; $B045: AD 13 00
  CMP #$02                              ; $B048: C9 02
  BEQ $B07C                             ; $B04A: F0 30
  CMP #$03                              ; $B04C: C9 03
  BEQ $B074                             ; $B04E: F0 24
  CMP #$04                              ; $B050: C9 04
  BEQ $B06A                             ; $B052: F0 16
  CMP #$05                              ; $B054: C9 05
  BEQ $B062                             ; $B056: F0 0A
  LDA $0009                             ; $B058: AD 09 00
  LSR                                   ; $B05B: 4A
  LSR                                   ; $B05C: 4A
  LSR                                   ; $B05D: 4A
  LSR                                   ; $B05E: 4A
  JSR $B091                             ; $B05F: 20 91 B0
Loc_B062:
  LDA $0009                             ; $B062: AD 09 00
  AND #$0F                              ; $B065: 29 0F
  JSR $B091                             ; $B067: 20 91 B0
Loc_B06A:
  LDA $0008                             ; $B06A: AD 08 00
  LSR                                   ; $B06D: 4A
  LSR                                   ; $B06E: 4A
  LSR                                   ; $B06F: 4A
  LSR                                   ; $B070: 4A
  JSR $B091                             ; $B071: 20 91 B0
Loc_B074:
  LDA $0008                             ; $B074: AD 08 00
  AND #$0F                              ; $B077: 29 0F
  JSR $B091                             ; $B079: 20 91 B0
Loc_B07C:
  LDA $0007                             ; $B07C: AD 07 00
  LSR                                   ; $B07F: 4A
  LSR                                   ; $B080: 4A
  LSR                                   ; $B081: 4A
  LSR                                   ; $B082: 4A
  JSR $B091                             ; $B083: 20 91 B0
  LDA $0017                             ; $B086: AD 17 00
  STA $0016                             ; $B089: 8D 16 00
  LDA $0007                             ; $B08C: AD 07 00
  AND #$0F                              ; $B08F: 29 0F
Loc_B091:
  BNE $B09C                             ; $B091: D0 09
  LDA $0016                             ; $B093: AD 16 00
  STA $0160,X                           ; $B096: 9D 60 01
  JMP $B0A9                             ; $B099: 4C A9 B0
Loc_B09C:
  CLC                                   ; $B09C: 18
  ADC $0017                             ; $B09D: 6D 17 00
  STA $0160,X                           ; $B0A0: 9D 60 01
  LDA $0017                             ; $B0A3: AD 17 00
  STA $0016                             ; $B0A6: 8D 16 00
Loc_B0A9:
  INX                                   ; $B0A9: E8
  RTS                                   ; $B0AA: 60
Loc_B0AB:
  LDA #$00                              ; $B0AB: A9 00
  STA $0000                             ; $B0AD: 8D 00 00
  STA $0001                             ; $B0B0: 8D 01 00
  LDA $0402                             ; $B0B3: AD 02 04
  ASL                                   ; $B0B6: 0A
  CLC                                   ; $B0B7: 18
  ADC $0402                             ; $B0B8: 6D 02 04
  ASL                                   ; $B0BB: 0A
  ASL                                   ; $B0BC: 0A
  ROL $0001                             ; $B0BD: 2E 01 00
  CLC                                   ; $B0C0: 18
  ADC $0402                             ; $B0C1: 6D 02 04
  STA $0000                             ; $B0C4: 8D 00 00
  LDA $0001                             ; $B0C7: AD 01 00
  ADC #$00                              ; $B0CA: 69 00
  STA $0001                             ; $B0CC: 8D 01 00
  LDA $0000                             ; $B0CF: AD 00 00
  CLC                                   ; $B0D2: 18
  ADC $0152                             ; $B0D3: 6D 52 01
  STA $0000                             ; $B0D6: 8D 00 00
  LDA $0001                             ; $B0D9: AD 01 00
  ADC $0153                             ; $B0DC: 6D 53 01
  STA $0001                             ; $B0DF: 8D 01 00
  LDY #$00                              ; $B0E2: A0 00
  LDA ($00),Y                           ; $B0E4: B1 00
  STA $00B2                             ; $B0E6: 8D B2 00
  STA $00C2                             ; $B0E9: 8D C2 00
  STA $00CA                             ; $B0EC: 8D CA 00
  STA $00D2                             ; $B0EF: 8D D2 00
  STA $00DA                             ; $B0F2: 8D DA 00
  INY                                   ; $B0F5: C8
  LDX #$00                              ; $B0F6: A2 00
Loc_B0F8:
  LDA ($00),Y                           ; $B0F8: B1 00
  STA $016F,X                           ; $B0FA: 9D 6F 01
  INY                                   ; $B0FD: C8
  INX                                   ; $B0FE: E8
  CPY #$07                              ; $B0FF: C0 07
  BCC $B0F8                             ; $B101: 90 F5
  LDX #$00                              ; $B103: A2 00
Loc_B105:
  LDA ($00),Y                           ; $B105: B1 00
  STA $017D,X                           ; $B107: 9D 7D 01
  INY                                   ; $B10A: C8
  INX                                   ; $B10B: E8
  CPY #$0D                              ; $B10C: C0 0D
  BCC $B105                             ; $B10E: 90 F5
  LDY #$30                              ; $B110: A0 30
  JSR $F25F                             ; $B112: 20 5F F2
  LDA $0402                             ; $B115: AD 02 04
  ASL                                   ; $B118: 0A
  ASL                                   ; $B119: 0A
  ASL                                   ; $B11A: 0A
  CLC                                   ; $B11B: 18
  ADC #$1A                              ; $B11C: 69 1A
  STA $0000                             ; $B11E: 8D 00 00
  LDA #$9A                              ; $B121: A9 9A
  ADC #$00                              ; $B123: 69 00
  STA $0001                             ; $B125: 8D 01 00
  LDY #$00                              ; $B128: A0 00
  LDX #$00                              ; $B12A: A2 00
Loc_B12C:
  LDA ($00),Y                           ; $B12C: B1 00
  BEQ $B14B                             ; $B12E: F0 1B
  CLC                                   ; $B130: 18
  ADC #$80                              ; $B131: 69 80
  CMP #$B9                              ; $B133: C9 B9
  BEQ $B141                             ; $B135: F0 0A
  CMP #$BA                              ; $B137: C9 BA
  BEQ $B141                             ; $B139: F0 06
  STA $0183,X                           ; $B13B: 9D 83 01
  JMP $B145                             ; $B13E: 4C 45 B1
Loc_B141:
  DEX                                   ; $B141: CA
  STA $0175,X                           ; $B142: 9D 75 01
Loc_B145:
  INY                                   ; $B145: C8
  INX                                   ; $B146: E8
  CPY #$08                              ; $B147: C0 08
  BCC $B12C                             ; $B149: 90 E1
Loc_B14B:
  RTS                                   ; $B14B: 60
Loc_B14C:
  STA $0006                             ; $B14C: 8D 06 00
  LDX #$00                              ; $B14F: A2 00
  LDA $0150                             ; $B151: AD 50 01
  BPL $B158                             ; $B154: 10 02
  LDX #$70                              ; $B156: A2 70
Loc_B158:
  STX $0005                             ; $B158: 8E 05 00
  LDY $0006                             ; $B15B: AC 06 00
  LDX $0006                             ; $B15E: AE 06 00
  LDA #$40                              ; $B161: A9 40
  STA $0007                             ; $B163: 8D 07 00
  LDA #$00                              ; $B166: A9 00
  CPY #$01                              ; $B168: C0 01
  BEQ $B173                             ; $B16A: F0 07
  LDA #$80                              ; $B16C: A9 80
  STA $0007                             ; $B16E: 8D 07 00
  LDA #$20                              ; $B171: A9 20
Loc_B173:
  STA $0006                             ; $B173: 8D 06 00
  LDA $037C,Y                           ; $B176: B9 7C 03
  STA $0000                             ; $B179: 8D 00 00
  LDA #$00                              ; $B17C: A9 00
  STA $0001                             ; $B17E: 8D 01 00
  LDA $0000                             ; $B181: AD 00 00
  ASL                                   ; $B184: 0A
  ROL $0001                             ; $B185: 2E 01 00
  CLC                                   ; $B188: 18
  ADC $037C,Y                           ; $B189: 79 7C 03
  STA $0000                             ; $B18C: 8D 00 00
  LDA $0001                             ; $B18F: AD 01 00
  ADC #$00                              ; $B192: 69 00
  STA $0001                             ; $B194: 8D 01 00
  LDA $0000                             ; $B197: AD 00 00
  ASL                                   ; $B19A: 0A
  ROL $0001                             ; $B19B: 2E 01 00
  ASL                                   ; $B19E: 0A
  ROL $0001                             ; $B19F: 2E 01 00
  CLC                                   ; $B1A2: 18
  ADC $037C,Y                           ; $B1A3: 79 7C 03
  STA $0000                             ; $B1A6: 8D 00 00
  LDA $0001                             ; $B1A9: AD 01 00
  ADC #$00                              ; $B1AC: 69 00
  STA $0001                             ; $B1AE: 8D 01 00
  LDA #$B4                              ; $B1B1: A9 B4
  CLC                                   ; $B1B3: 18
  ADC $0000                             ; $B1B4: 6D 00 00
  STA $0000                             ; $B1B7: 8D 00 00
  LDA #$8D                              ; $B1BA: A9 8D
  ADC $0001                             ; $B1BC: 6D 01 00
  STA $0001                             ; $B1BF: 8D 01 00
  LDA #$22                              ; $B1C2: A9 22
  STA $0002                             ; $B1C4: 8D 02 00
  LDA #$B2                              ; $B1C7: A9 B2
  STA $0003                             ; $B1C9: 8D 03 00
  LDY #$00                              ; $B1CC: A0 00
  STY $0004                             ; $B1CE: 8C 04 00
  LDA ($00),Y                           ; $B1D1: B1 00
  STA $00AE,X                           ; $B1D3: 9D AE 00
  STA $00BE,X                           ; $B1D6: 9D BE 00
  STA $00C6,X                           ; $B1D9: 9D C6 00
  STA $00CE,X                           ; $B1DC: 9D CE 00
  STA $00D6,X                           ; $B1DF: 9D D6 00
  LDX $007C                             ; $B1E2: AE 7C 00
Loc_B1E5:
  INY                                   ; $B1E5: C8
  LDA ($00),Y                           ; $B1E6: B1 00
  CMP #$FF                              ; $B1E8: C9 FF
  BEQ $B21E                             ; $B1EA: F0 32
  CLC                                   ; $B1EC: 18
  ADC $0007                             ; $B1ED: 6D 07 00
  STA $0201,X                           ; $B1F0: 9D 01 02
  LDA #$01                              ; $B1F3: A9 01
  STA $0202,X                           ; $B1F5: 9D 02 02
  TYA                                   ; $B1F8: 98
  PHA                                   ; $B1F9: 48
  LDY $0004                             ; $B1FA: AC 04 00
  LDA ($02),Y                           ; $B1FD: B1 02
  CLC                                   ; $B1FF: 18
  ADC $0005                             ; $B200: 6D 05 00
  STA $0203,X                           ; $B203: 9D 03 02
  INY                                   ; $B206: C8
  LDA ($02),Y                           ; $B207: B1 02
  CLC                                   ; $B209: 18
  ADC $0006                             ; $B20A: 6D 06 00
  STA $0200,X                           ; $B20D: 9D 00 02
  INY                                   ; $B210: C8
  STY $0004                             ; $B211: 8C 04 00
  INX                                   ; $B214: E8
  INX                                   ; $B215: E8
  INX                                   ; $B216: E8
  INX                                   ; $B217: E8
  PLA                                   ; $B218: 68
  TAY                                   ; $B219: A8
  CPY #$0C                              ; $B21A: C0 0C
  BCC $B1E5                             ; $B21C: 90 C7
Loc_B21E:
  STX $007C                             ; $B21E: 8E 7C 00
  RTS                                   ; $B221: 60
; --- Data Region ---
  .byte $40,$48,$48,$48,$40,$50,$48,$50,$50,$48,$58,$48,$50,$50,$58,$50; $B222: 40 48 48 48 40 50 48 50 50 48 58 48 50 50 58 50
  .byte $60,$48,$68,$48,$60,$50,$68,$50   ; $B232: 60 48 68 48 60 50 68 50
Loc_B23A:
; --- Code Region ---
  STA $000F                             ; $B23A: 8D 0F 00
  LDA $0402                             ; $B23D: AD 02 04
  JSR $F2AF                             ; $B240: 20 AF F2
  LDY #$00                              ; $B243: A0 00
  LDA ($00),Y                           ; $B245: B1 00
  CMP #$07                              ; $B247: C9 07
  BEQ $B279                             ; $B249: F0 2E
  LDY #$01                              ; $B24B: A0 01
  LDA $000F                             ; $B24D: AD 0F 00
  BEQ $B254                             ; $B250: F0 02
  LDY #$02                              ; $B252: A0 02
Loc_B254:
  LDA $037C,Y                           ; $B254: B9 7C 03
  JSR $F308                             ; $B257: 20 08 F3
  LDY #$00                              ; $B25A: A0 00
  LDX #$00                              ; $B25C: A2 00
Loc_B25E:
  LDA ($00),Y                           ; $B25E: B1 00
  BEQ $B279                             ; $B260: F0 17
  CMP #$39                              ; $B262: C9 39
  BEQ $B26D                             ; $B264: F0 07
  CMP #$3A                              ; $B266: C9 3A
  BEQ $B26D                             ; $B268: F0 03
  JMP $B274                             ; $B26A: 4C 74 B2
Loc_B26D:
  DEX                                   ; $B26D: CA
  CLC                                   ; $B26E: 18
  ADC #$80                              ; $B26F: 69 80
Loc_B271:
  STA $0190,X                           ; $B271: 9D 90 01
Loc_B274:
  INX                                   ; $B274: E8
  INY                                   ; $B275: C8
  JMP $B25E                             ; $B276: 4C 5E B2
Loc_B279:
  RTS                                   ; $B279: 60
Loc_B27A:
  LDY $000F                             ; $B27A: AC 0F 00
  LDA $037C,Y                           ; $B27D: B9 7C 03
Loc_B280:
  JSR $F308                             ; $B280: 20 08 F3
  LDY #$00                              ; $B283: A0 00
  LDX #$00                              ; $B285: A2 00
Loc_B287:
  LDA ($00),Y                           ; $B287: B1 00
  BEQ $B29E                             ; $B289: F0 13
  CMP #$39                              ; $B28B: C9 39
  BEQ $B29A                             ; $B28D: F0 0B
  CMP #$3A                              ; $B28F: C9 3A
  BEQ $B29A                             ; $B291: F0 07
Loc_B293:
  CLC                                   ; $B293: 18
  ADC #$80                              ; $B294: 69 80
  STA $0166,X                           ; $B296: 9D 66 01
  INX                                   ; $B299: E8
Loc_B29A:
  INY                                   ; $B29A: C8
  JMP $B287                             ; $B29B: 4C 87 B2
Loc_B29E:
  RTS                                   ; $B29E: 60
Loc_B29F:
  LDA $008B                             ; $B29F: AD 8B 00
  AND #$FB                              ; $B2A2: 29 FB
  STA $2000                             ; $B2A4: 8D 00 20
  LDA $2002                             ; $B2A7: AD 02 20
  LDA $0142                             ; $B2AA: AD 42 01
  STA $2006                             ; $B2AD: 8D 06 20
  STA $0001                             ; $B2B0: 8D 01 00
  LDA $0141                             ; $B2B3: AD 41 01
  STA $2006                             ; $B2B6: 8D 06 20
  STA $0000                             ; $B2B9: 8D 00 00
  LDX #$00                              ; $B2BC: A2 00
Loc_B2BE:
  LDY #$00                              ; $B2BE: A0 00
Loc_B2C0:
  LDA $0160,X                           ; $B2C0: BD 60 01
  STA $2007                             ; $B2C3: 8D 07 20
  INY                                   ; $B2C6: C8
  INX                                   ; $B2C7: E8
  CPY #$0E                              ; $B2C8: C0 0E
  BCC $B2C0                             ; $B2CA: 90 F4
  LDA $0000                             ; $B2CC: AD 00 00
  CLC                                   ; $B2CF: 18
  ADC #$20                              ; $B2D0: 69 20
  STA $0000                             ; $B2D2: 8D 00 00
  LDA $0001                             ; $B2D5: AD 01 00
  ADC #$00                              ; $B2D8: 69 00
  STA $0001                             ; $B2DA: 8D 01 00
  STA $2006                             ; $B2DD: 8D 06 20
  LDA $0000                             ; $B2E0: AD 00 00
  STA $2006                             ; $B2E3: 8D 06 20
  CPX $0154                             ; $B2E6: EC 54 01
  BCC $B2BE                             ; $B2E9: 90 D3
  LDA $0148                             ; $B2EB: AD 48 01
  STA $2006                             ; $B2EE: 8D 06 20
  LDA $0147                             ; $B2F1: AD 47 01
  STA $2006                             ; $B2F4: 8D 06 20
  LDY #$00                              ; $B2F7: A0 00
Loc_B2F9:
  LDA $014B,Y                           ; $B2F9: B9 4B 01
  STA $2007                             ; $B2FC: 8D 07 20
  INY                                   ; $B2FF: C8
  CPY #$04                              ; $B300: C0 04
  BCC $B2F9                             ; $B302: 90 F5
  RTS                                   ; $B304: 60
; --- Data Region ---
  .byte $10,$12,$12,$12,$12,$12,$12,$12,$12,$12,$12,$12,$12,$11,$13,$01; $B305: 10 12 12 12 12 12 12 12 12 12 12 12 12 11 13 01
  .byte $01,$01,$01,$01                   ; $B315: 01 01 01 01
Loc_B319:
; --- Code Region ---
  ORA ($01,X)                           ; $B319: 01 01
  ORA ($01,X)                           ; $B31B: 01 01
  ORA ($01,X)                           ; $B31D: 01 01
  ORA ($23,X)                           ; $B31F: 01 23
  SLO ($01),Y                           ; $B321: 13 01
  ORA ($01,X)                           ; $B323: 01 01
  ORA ($01,X)                           ; $B325: 01 01
  ORA ($01,X)                           ; $B327: 01 01
  ORA ($01,X)                           ; $B329: 01 01
  ORA ($01,X)                           ; $B32B: 01 01
  ORA ($23,X)                           ; $B32D: 01 23
  SLO ($01),Y                           ; $B32F: 13 01
  ORA ($01,X)                           ; $B331: 01 01
  ORA ($01,X)                           ; $B333: 01 01
  ORA ($01,X)                           ; $B335: 01 01
  ORA ($01,X)                           ; $B337: 01 01
  ORA ($01,X)                           ; $B339: 01 01
  ORA ($23,X)                           ; $B33B: 01 23
  SLO ($01),Y                           ; $B33D: 13 01
  ORA ($01,X)                           ; $B33F: 01 01
  ORA ($01,X)                           ; $B341: 01 01
  ORA ($01,X)                           ; $B343: 01 01
  ORA ($01,X)                           ; $B345: 01 01
  ORA ($01,X)                           ; $B347: 01 01
  ORA ($23,X)                           ; $B349: 01 23
  SLO ($60),Y                           ; $B34B: 13 60
  ADC ($62,X)                           ; $B34D: 61 62
  RRA ($01,X)                           ; $B34F: 63 01
  ORA ($01,X)                           ; $B351: 01 01
  ORA ($01,X)                           ; $B353: 01 01
  ORA ($01,X)                           ; $B355: 01 01
  ORA ($23,X)                           ; $B357: 01 23
  SLO ($70),Y                           ; $B359: 13 70
  ADC ($72),Y                           ; $B35B: 71 72
  RRA ($01),Y                           ; $B35D: 73 01
  ORA ($01,X)                           ; $B35F: 01 01
  ORA ($01,X)                           ; $B361: 01 01
  ORA ($01,X)                           ; $B363: 01 01
  ORA ($23,X)                           ; $B365: 01 23
  SLO ($01),Y                           ; $B367: 13 01
  ORA ($01,X)                           ; $B369: 01 01
  ORA ($01,X)                           ; $B36B: 01 01
  ORA ($01,X)                           ; $B36D: 01 01
  ORA ($01,X)                           ; $B36F: 01 01
  ORA ($01,X)                           ; $B371: 01 01
  ORA ($23,X)                           ; $B373: 01 23
  SLO ($01),Y                           ; $B375: 13 01
  ORA ($01,X)                           ; $B377: 01 01
  ORA ($01,X)                           ; $B379: 01 01
  ORA ($01,X)                           ; $B37B: 01 01
  ORA ($01,X)                           ; $B37D: 01 01
  ORA ($01,X)                           ; $B37F: 01 01
  ORA ($23,X)                           ; $B381: 01 23
  SLO ($64),Y                           ; $B383: 13 64
  ADC $66                               ; $B385: 65 66
  RRA $01                               ; $B387: 67 01
  ORA ($01,X)                           ; $B389: 01 01
  ORA ($01,X)                           ; $B38B: 01 01
  ORA ($01,X)                           ; $B38D: 01 01
  ORA ($23,X)                           ; $B38F: 01 23
  SLO ($74),Y                           ; $B391: 13 74
  ADC $76,X                             ; $B393: 75 76
  RRA $01,X                             ; $B395: 77 01
  ORA ($01,X)                           ; $B397: 01 01
  ORA ($01,X)                           ; $B399: 01 01
  ORA ($01,X)                           ; $B39B: 01 01
  ORA ($23,X)                           ; $B39D: 01 23
  SLO ($01),Y                           ; $B39F: 13 01
  ORA ($01,X)                           ; $B3A1: 01 01
  ORA ($01,X)                           ; $B3A3: 01 01
  ORA ($01,X)                           ; $B3A5: 01 01
  ORA ($01,X)                           ; $B3A7: 01 01
  ORA ($01,X)                           ; $B3A9: 01 01
  ORA ($23,X)                           ; $B3AB: 01 23
  SLO ($01),Y                           ; $B3AD: 13 01
  ORA ($01,X)                           ; $B3AF: 01 01
  ORA ($01,X)                           ; $B3B1: 01 01
  ORA ($01,X)                           ; $B3B3: 01 01
  ORA ($01,X)                           ; $B3B5: 01 01
  ORA ($01,X)                           ; $B3B7: 01 01
  ORA ($23,X)                           ; $B3B9: 01 23
  SLO ($68),Y                           ; $B3BB: 13 68
  ADC #$6A                              ; $B3BD: 69 6A
  ARR #$6C                              ; $B3BF: 6B 6C
  ADC $0101                             ; $B3C1: 6D 01 01
  ORA ($01,X)                           ; $B3C4: 01 01
  ORA ($01,X)                           ; $B3C6: 01 01
  RLA ($13,X)                           ; $B3C8: 23 13
  SEI                                   ; $B3CA: 78
  ADC $7B7A,Y                           ; $B3CB: 79 7A 7B
  NOP $017D,X                           ; $B3CE: 7C 7D 01
  ORA ($01,X)                           ; $B3D1: 01 01
  JAM                                   ; $B3D3: F2
  SLO ($0B,X)                           ; $B3D4: 03 0B
  RLA ($20,X)                           ; $B3D6: 23 20
  JAM                                   ; $B3D8: 22
  JAM                                   ; $B3D9: 22
  JAM                                   ; $B3DA: 22
  JAM                                   ; $B3DB: 22
  JAM                                   ; $B3DC: 22
  JAM                                   ; $B3DD: 22
  JAM                                   ; $B3DE: 22
  JAM                                   ; $B3DF: 22
  JAM                                   ; $B3E0: 22
  JAM                                   ; $B3E1: 22
  JAM                                   ; $B3E2: 22
  JAM                                   ; $B3E3: 22
  AND ($10,X)                           ; $B3E4: 21 10
  JAM                                   ; $B3E6: 12
  JAM                                   ; $B3E7: 12
  JAM                                   ; $B3E8: 12
  JAM                                   ; $B3E9: 12
  JAM                                   ; $B3EA: 12
  JAM                                   ; $B3EB: 12
  JAM                                   ; $B3EC: 12
  JAM                                   ; $B3ED: 12
  JAM                                   ; $B3EE: 12
  JAM                                   ; $B3EF: 12
  JAM                                   ; $B3F0: 12
  JAM                                   ; $B3F1: 12
  ORA ($13),Y                           ; $B3F2: 11 13
  RTI                                   ; $B3F4: 40
; --- Data Region ---
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
  .byte $F0,$02,$11,$23                   ; $B495: F0 02 11 23
Loc_B499:
; --- Code Region ---
  SLO ($48),Y                           ; $B499: 13 48
  EOR #$4A                              ; $B49B: 49 4A
  ALR #$01                              ; $B49D: 4B 01
  ORA ($01,X)                           ; $B49F: 01 01
  ORA ($01,X)                           ; $B4A1: 01 01
  ORA ($01,X)                           ; $B4A3: 01 01
  ORA ($23,X)                           ; $B4A5: 01 23
  SLO ($58),Y                           ; $B4A7: 13 58
  EOR $5B5A,Y                           ; $B4A9: 59 5A 5B
  ORA ($01,X)                           ; $B4AC: 01 01
  ORA ($F3,X)                           ; $B4AE: 01 F3
  ORA $11                               ; $B4B0: 05 11
  RLA ($20,X)                           ; $B4B2: 23 20
  JAM                                   ; $B4B4: 22
  JAM                                   ; $B4B5: 22
  JAM                                   ; $B4B6: 22
  JAM                                   ; $B4B7: 22
  JAM                                   ; $B4B8: 22
  JAM                                   ; $B4B9: 22
  JAM                                   ; $B4BA: 22
  JAM                                   ; $B4BB: 22
  JAM                                   ; $B4BC: 22
  JAM                                   ; $B4BD: 22
  JAM                                   ; $B4BE: 22
  JAM                                   ; $B4BF: 22
  AND ($10,X)                           ; $B4C0: 21 10
  JAM                                   ; $B4C2: 12
  JAM                                   ; $B4C3: 12
  JAM                                   ; $B4C4: 12
  JAM                                   ; $B4C5: 12
  JAM                                   ; $B4C6: 12
  JAM                                   ; $B4C7: 12
  JAM                                   ; $B4C8: 12
  JAM                                   ; $B4C9: 12
  JAM                                   ; $B4CA: 12
  JAM                                   ; $B4CB: 12
  JAM                                   ; $B4CC: 12
  JAM                                   ; $B4CD: 12
  ORA ($13),Y                           ; $B4CE: 11 13
  RTI                                   ; $B4D0: 40
; --- Data Region ---
  .byte $41,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$23,$13,$50,$51,$01; $B4D1: 41 01 01 01 01 01 01 01 01 01 01 23 13 50 51 01
  .byte $01,$01,$01,$01,$01,$F1,$04,$02,$23,$13,$42,$43,$01,$01,$01,$01; $B4E1: 01 01 01 01 01 F1 04 02 23 13 42 43 01 01 01 01
  .byte $01,$01,$01,$01,$01,$01,$23,$13,$52,$53,$01,$01,$01,$01,$01,$01; $B4F1: 01 01 01 01 01 01 23 13 52 53 01 01 01 01 01 01
  .byte $F1,$04,$04,$23,$13,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01; $B501: F1 04 04 23 13 01 01 01 01 01 01 01 01 01 01 01
  .byte $01,$23,$13,$44,$45,$46,$47,$01,$01,$01,$01,$01,$01,$01,$01,$23; $B511: 01 23 13 44 45 46 47 01 01 01 01 01 01 01 01 23
  .byte $13,$54,$55,$56,$57,$01,$01,$01,$01,$01,$01,$F0,$02,$11,$23; $B521: 13 54 55 56 57 01 01 01 01 01 01 F0 02 11 23
Loc_B530:
; --- Code Region ---
  SLO ($01),Y                           ; $B530: 13 01
  ORA ($01,X)                           ; $B532: 01 01
  ORA ($01,X)                           ; $B534: 01 01
  ORA ($01,X)                           ; $B536: 01 01
  ORA ($01,X)                           ; $B538: 01 01
  ORA ($01,X)                           ; $B53A: 01 01
  ORA ($23,X)                           ; $B53C: 01 23
  SLO ($48),Y                           ; $B53E: 13 48
  EOR #$4A                              ; $B540: 49 4A
  ALR #$4C                              ; $B542: 4B 4C
  EOR $0101                             ; $B544: 4D 01 01
  ORA ($01,X)                           ; $B547: 01 01
  ORA ($01,X)                           ; $B549: 01 01
  RLA ($13,X)                           ; $B54B: 23 13
  CLI                                   ; $B54D: 58
  EOR $5B5A,Y                           ; $B54E: 59 5A 5B
  NOP $015D,X                           ; $B551: 5C 5D 01
  ORA ($01,X)                           ; $B554: 01 01
  ORA ($01,X)                           ; $B556: 01 01
  ORA ($23,X)                           ; $B558: 01 23
  SLO ($69),Y                           ; $B55A: 13 69
  ORA ($01,X)                           ; $B55C: 01 01
  ORA ($01,X)                           ; $B55E: 01 01
  ORA ($01,X)                           ; $B560: 01 01
  ORA ($01,X)                           ; $B562: 01 01
  ORA ($01,X)                           ; $B564: 01 01
  ORA ($23,X)                           ; $B566: 01 23
  SLO ($68),Y                           ; $B568: 13 68
  ROR                                   ; $B56A: 6A
  ARR #$6C                              ; $B56B: 6B 6C
  ORA ($01,X)                           ; $B56D: 01 01
  ORA ($F3,X)                           ; $B56F: 01 F3
  ORA $11                               ; $B571: 05 11
  RLA ($13,X)                           ; $B573: 23 13
  ORA ($01,X)                           ; $B575: 01 01
  ORA ($01,X)                           ; $B577: 01 01
  ORA ($01,X)                           ; $B579: 01 01
  ORA ($01,X)                           ; $B57B: 01 01
  ORA ($01,X)                           ; $B57D: 01 01
  ORA ($01,X)                           ; $B57F: 01 01
  RLA ($13,X)                           ; $B581: 23 13
  ADC $6F6E                             ; $B583: 6D 6E 6F
  ORA ($01,X)                           ; $B586: 01 01
  ORA ($01,X)                           ; $B588: 01 01
  SBC ($05),Y                           ; $B58A: F1 05
  NOP $2023                             ; $B58C: 0C 23 20
  JAM                                   ; $B58F: 22
  JAM                                   ; $B590: 22
  JAM                                   ; $B591: 22
  JAM                                   ; $B592: 22
  JAM                                   ; $B593: 22
  JAM                                   ; $B594: 22
  JAM                                   ; $B595: 22
  JAM                                   ; $B596: 22
  JAM                                   ; $B597: 22
  JAM                                   ; $B598: 22
  JAM                                   ; $B599: 22
  JAM                                   ; $B59A: 22
  AND ($10,X)                           ; $B59B: 21 10
  JAM                                   ; $B59D: 12
  JAM                                   ; $B59E: 12
  JAM                                   ; $B59F: 12
  JAM                                   ; $B5A0: 12
  JAM                                   ; $B5A1: 12
  JAM                                   ; $B5A2: 12
  JAM                                   ; $B5A3: 12
  JAM                                   ; $B5A4: 12
  JAM                                   ; $B5A5: 12
  JAM                                   ; $B5A6: 12
  JAM                                   ; $B5A7: 12
  JAM                                   ; $B5A8: 12
  ORA ($13),Y                           ; $B5A9: 11 13
  RTI                                   ; $B5AB: 40
; --- Data Region ---
  .byte $41,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$23,$13,$50,$51,$01; $B5AC: 41 01 01 01 01 01 01 01 01 01 01 23 13 50 51 01
  .byte $01,$01,$01,$01,$01,$F1,$04,$02,$23,$13,$01,$01,$01,$01,$01,$01; $B5BC: 01 01 01 01 01 F1 04 02 23 13 01 01 01 01 01 01
  .byte $01,$01,$01,$01,$01,$01,$23,$13,$42,$43,$01,$01,$01,$01,$01,$01; $B5CC: 01 01 01 01 01 01 23 13 42 43 01 01 01 01 01 01
  .byte $01,$01,$01,$01,$23,$13,$52,$53,$01,$01,$01,$01,$01,$01,$F1,$04; $B5DC: 01 01 01 01 23 13 52 53 01 01 01 01 01 01 F1 04
  .byte $04,$23,$13,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$23; $B5EC: 04 23 13 01 01 01 01 01 01 01 01 01 01 01 01 23
  .byte $13,$4E,$4F,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$23,$13,$5E; $B5FC: 13 4E 4F 01 01 01 01 01 01 01 01 01 01 23 13 5E
  .byte $5F,$01,$01,$01,$01,$01,$01,$01,$01,$F2,$02,$10,$23,$13,$01,$01; $B60C: 5F 01 01 01 01 01 01 01 01 F2 02 10 23 13 01 01
  .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$23,$13,$01,$01,$01,$01; $B61C: 01 01 01 01 01 01 01 01 01 01 23 13 01 01 01 01
  .byte $01,$01,$01,$01,$01,$01,$01,$01,$23,$13,$01,$01,$01,$01,$01,$01; $B62C: 01 01 01 01 01 01 01 01 23 13 01 01 01 01 01 01
Loc_B63C:
; --- Code Region ---
  ORA ($01,X)                           ; $B63C: 01 01
  ORA ($01,X)                           ; $B63E: 01 01
  ORA ($01,X)                           ; $B640: 01 01
  RLA ($13,X)                           ; $B642: 23 13
  ORA ($01,X)                           ; $B644: 01 01
  ORA ($01,X)                           ; $B646: 01 01
  ORA ($01,X)                           ; $B648: 01 01
  ORA ($01,X)                           ; $B64A: 01 01
  ORA ($01,X)                           ; $B64C: 01 01
  ORA ($01,X)                           ; $B64E: 01 01
  RLA ($13,X)                           ; $B650: 23 13
  ORA ($01,X)                           ; $B652: 01 01
  ORA ($01,X)                           ; $B654: 01 01
  ORA ($01,X)                           ; $B656: 01 01
  ORA ($01,X)                           ; $B658: 01 01
  ORA ($01,X)                           ; $B65A: 01 01
  ORA ($01,X)                           ; $B65C: 01 01
  RLA ($13,X)                           ; $B65E: 23 13
  ORA ($01,X)                           ; $B660: 01 01
  ORA ($01,X)                           ; $B662: 01 01
  ORA ($01,X)                           ; $B664: 01 01
  ORA ($01,X)                           ; $B666: 01 01
  ORA ($01,X)                           ; $B668: 01 01
  ORA ($01,X)                           ; $B66A: 01 01
  RLA ($20,X)                           ; $B66C: 23 20
  JAM                                   ; $B66E: 22
  JAM                                   ; $B66F: 22
  JAM                                   ; $B670: 22
  JAM                                   ; $B671: 22
  JAM                                   ; $B672: 22
  JAM                                   ; $B673: 22
  JAM                                   ; $B674: 22
  JAM                                   ; $B675: 22
  JAM                                   ; $B676: 22
  JAM                                   ; $B677: 22
  JAM                                   ; $B678: 22
  JAM                                   ; $B679: 22
  AND ($88,X)                           ; $B67A: 21 88
  TAX                                   ; $B67C: AA
  TAX                                   ; $B67D: AA
  TAX                                   ; $B67E: AA
  TAX                                   ; $B67F: AA
  TAX                                   ; $B680: AA
  TAX                                   ; $B681: AA
  JAM                                   ; $B682: 22
  NOP $2928,X                           ; $B683: 5C 28 29
  ROL                                   ; $B686: 2A
  ANC #$01                              ; $B687: 2B 01
  ORA ($38,X)                           ; $B689: 01 38
  AND $3B3A,Y                           ; $B68B: 39 3A 3B
  ORA ($01,X)                           ; $B68E: 01 01
  BRK                                   ; $B690: 00
  BIT $25                               ; $B691: 24 25
  ROL $27                               ; $B693: 26 27
  ORA ($01,X)                           ; $B695: 01 01
  NOP $35,X                             ; $B697: 34 35
  ROL $37,X                             ; $B699: 36 37
  ORA ($01,X)                           ; $B69B: 01 01
  BRK                                   ; $B69D: 00
  PLP                                   ; $B69E: 28
  AND #$26                              ; $B69F: 29 26
  RLA $01                               ; $B6A1: 27 01
  ORA ($38,X)                           ; $B6A3: 01 38
  AND $3736,Y                           ; $B6A5: 39 36 37
  ORA ($01,X)                           ; $B6A8: 01 01
  BRK                                   ; $B6AA: 00
  ROL                                   ; $B6AB: 2A
  ANC #$26                              ; $B6AC: 2B 26
  RLA $01                               ; $B6AE: 27 01
  ORA ($3A,X)                           ; $B6B0: 01 3A
  RLA $3736,Y                           ; $B6B2: 3B 36 37
  ORA ($01,X)                           ; $B6B5: 01 01
  BRK                                   ; $B6B7: 00
  BIT $262D                             ; $B6B8: 2C 2D 26
  RLA $01                               ; $B6BB: 27 01
  ORA ($3C,X)                           ; $B6BD: 01 3C
  AND $3736,X                           ; $B6BF: 3D 36 37
  ORA ($01,X)                           ; $B6C2: 01 01
  EOR $2524,Y                           ; $B6C4: 59 24 25
  ROL $27                               ; $B6C7: 26 27
  PLP                                   ; $B6C9: 28
  AND #$34                              ; $B6CA: 29 34
  AND $36,X                             ; $B6CC: 35 36
  RLA $38,X                             ; $B6CE: 37 38
  AND $2E00,Y                           ; $B6D0: 39 00 2E
  RLA $2726                             ; $B6D3: 2F 26 27
  ORA ($01,X)                           ; $B6D6: 01 01
  ROL $363F,X                           ; $B6D8: 3E 3F 36
  RLA $01,X                             ; $B6DB: 37 01
  ORA ($59,X)                           ; $B6DD: 01 59
  ROL $27                               ; $B6DF: 26 27
  ROL                                   ; $B6E1: 2A
  ANC #$01                              ; $B6E2: 2B 01
  ORA ($36,X)                           ; $B6E4: 01 36
  RLA $3A,X                             ; $B6E6: 37 3A
  RLA $0101,Y                           ; $B6E8: 3B 01 01
  EOR $2F2E,Y                           ; $B6EB: 59 2E 2F
  ROL $27                               ; $B6EE: 26 27
  ORA ($01,X)                           ; $B6F0: 01 01
  ROL $363F,X                           ; $B6F2: 3E 3F 36
  RLA $01,X                             ; $B6F5: 37 01
  ORA ($5A,X)                           ; $B6F7: 01 5A
  BIT $25                               ; $B6F9: 24 25
  ROL $27                               ; $B6FB: 26 27
  PLP                                   ; $B6FD: 28
  AND #$34                              ; $B6FE: 29 34
  AND $36,X                             ; $B700: 35 36
  RLA $38,X                             ; $B702: 37 38
  AND $2858,Y                           ; $B704: 39 58 28
  AND #$26                              ; $B707: 29 26
  RLA $01                               ; $B709: 27 01
  ORA ($38,X)                           ; $B70B: 01 38
  AND $3736,Y                           ; $B70D: 39 36 37
  ORA ($01,X)                           ; $B710: 01 01
  CLI                                   ; $B712: 58
  ROL                                   ; $B713: 2A
  ANC #$26                              ; $B714: 2B 26
  RLA $01                               ; $B716: 27 01
  ORA ($3A,X)                           ; $B718: 01 3A
  RLA $3736,Y                           ; $B71A: 3B 36 37
  ORA ($01,X)                           ; $B71D: 01 01
  SRE $2524,Y                           ; $B71F: 5B 24 25
  ROL $27                               ; $B722: 26 27
  ORA ($01,X)                           ; $B724: 01 01
  NOP $35,X                             ; $B726: 34 35
  ROL $37,X                             ; $B728: 36 37
  ORA ($01,X)                           ; $B72A: 01 01
  NOP $2D2C,X                           ; $B72C: 5C 2C 2D
  ROL $012F                             ; $B72F: 2E 2F 01
  ORA ($3C,X)                           ; $B732: 01 3C
  AND $3F3E,X                           ; $B734: 3D 3E 3F
  ORA ($01,X)                           ; $B737: 01 01
  CLI                                   ; $B739: 58
  BIT $262D                             ; $B73A: 2C 2D 26
  RLA $01                               ; $B73D: 27 01
  ORA ($3C,X)                           ; $B73F: 01 3C
  AND $3736,X                           ; $B741: 3D 36 37
  ORA ($01,X)                           ; $B744: 01 01
  EOR $2D2C,Y                           ; $B746: 59 2C 2D
  BMI $B77C                             ; $B749: 30 31
  ORA ($01,X)                           ; $B74B: 01 01
  NOP $323D,X                           ; $B74D: 3C 3D 32
  RLA ($01),Y                           ; $B750: 33 01
  ORA ($00,X)                           ; $B752: 01 00
  BMI $B787                             ; $B754: 30 31
  ROL $27                               ; $B756: 26 27
  ORA ($01,X)                           ; $B758: 01 01
  JAM                                   ; $B75A: 32
  RLA ($36),Y                           ; $B75B: 33 36
  RLA $01,X                             ; $B75D: 37 01
  ORA ($59,X)                           ; $B75F: 01 59
  BIT $262D                             ; $B761: 2C 2D 26
  RLA $01                               ; $B764: 27 01
  ORA ($3C,X)                           ; $B766: 01 3C
  AND $3736,X                           ; $B768: 3D 36 37
  ORA ($01,X)                           ; $B76B: 01 01
  CLI                                   ; $B76D: 58
  BIT $25                               ; $B76E: 24 25
  ROL $27                               ; $B770: 26 27
  ORA ($01,X)                           ; $B772: 01 01
  NOP $35,X                             ; $B774: 34 35
  ROL $37,X                             ; $B776: 36 37
  ORA ($01,X)                           ; $B778: 01 01
  NOP                                   ; $B77A: 5A
  ROL                                   ; $B77B: 2A
Loc_B77C:
  ANC #$2C                              ; $B77C: 2B 2C
  AND $0101                             ; $B77E: 2D 01 01
  NOP                                   ; $B781: 3A
  RLA $3D3C,Y                           ; $B782: 3B 3C 3D
  ORA ($01,X)                           ; $B785: 01 01
Loc_B787:
  NOP                                   ; $B787: 5A
  ROL $302F                             ; $B788: 2E 2F 30
  AND ($01),Y                           ; $B78B: 31 01
  ORA ($3E,X)                           ; $B78D: 01 3E
  RLA $3332,X                           ; $B78F: 3F 32 33
  ORA ($01,X)                           ; $B792: 01 01
  CLI                                   ; $B794: 58
  ROL $262F                             ; $B795: 2E 2F 26
  RLA $01                               ; $B798: 27 01
  ORA ($3E,X)                           ; $B79A: 01 3E
  RLA $3736,X                           ; $B79C: 3F 36 37
  ORA ($01,X)                           ; $B79F: 01 01
  SRE $2928,Y                           ; $B7A1: 5B 28 29
  ROL $27                               ; $B7A4: 26 27
  ORA ($01,X)                           ; $B7A6: 01 01
  SEC                                   ; $B7A8: 38
  AND $3736,Y                           ; $B7A9: 39 36 37
  ORA ($01,X)                           ; $B7AC: 01 01
  NOP $2524,X                           ; $B7AE: 5C 24 25
  ROL $27                               ; $B7B1: 26 27
  ORA ($01,X)                           ; $B7B3: 01 01
  NOP $35,X                             ; $B7B5: 34 35
  ROL $37,X                             ; $B7B7: 36 37
  ORA ($01,X)                           ; $B7B9: 01 01
  SRE $2F2E,Y                           ; $B7BB: 5B 2E 2F
  BIT $012D                             ; $B7BE: 2C 2D 01
  ORA ($3E,X)                           ; $B7C1: 01 3E
  RLA $3D3C,X                           ; $B7C3: 3F 3C 3D
  ORA ($01,X)                           ; $B7C6: 01 01
  EOR $2524,X                           ; $B7C8: 5D 24 25
  ROL $27                               ; $B7CB: 26 27
  ORA ($01,X)                           ; $B7CD: 01 01
  NOP $35,X                             ; $B7CF: 34 35
  ROL $37,X                             ; $B7D1: 36 37
  ORA ($01,X)                           ; $B7D3: 01 01
  EOR $2928,X                           ; $B7D5: 5D 28 29
  ROL                                   ; $B7D8: 2A
  ANC #$01                              ; $B7D9: 2B 01
  ORA ($38,X)                           ; $B7DB: 01 38
  AND $3B3A,Y                           ; $B7DD: 39 3A 3B
  ORA ($01,X)                           ; $B7E0: 01 01
  SRE $2B2A,Y                           ; $B7E2: 5B 2A 2B
  BIT $012D                             ; $B7E5: 2C 2D 01
  ORA ($3A,X)                           ; $B7E8: 01 3A
  RLA $3D3C,Y                           ; $B7EA: 3B 3C 3D
  ORA ($01,X)                           ; $B7ED: 01 01
  EOR $2F2E,X                           ; $B7EF: 5D 2E 2F
  BMI $B825                             ; $B7F2: 30 31
  ORA ($01,X)                           ; $B7F4: 01 01
  ROL $323F,X                           ; $B7F6: 3E 3F 32
  RLA ($01),Y                           ; $B7F9: 33 01
  ORA ($5E,X)                           ; $B7FB: 01 5E
  BIT $25                               ; $B7FD: 24 25
  ROL $27                               ; $B7FF: 26 27
  ORA ($01,X)                           ; $B801: 01 01
  NOP $35,X                             ; $B803: 34 35
  ROL $37,X                             ; $B805: 36 37
Loc_B807:
  ORA ($01,X)                           ; $B807: 01 01
  ORA ($01,X)                           ; $B809: 01 01
  ORA ($01,X)                           ; $B80B: 01 01
  ORA ($01,X)                           ; $B80D: 01 01
  ORA ($01,X)                           ; $B80F: 01 01
  ORA ($01,X)                           ; $B811: 01 01
  ORA ($01,X)                           ; $B813: 01 01
  ORA ($01,X)                           ; $B815: 01 01
  ORA ($01,X)                           ; $B817: 01 01
  ORA ($01,X)                           ; $B819: 01 01
  ORA ($01,X)                           ; $B81B: 01 01
  ORA ($01,X)                           ; $B81D: 01 01
  ORA ($01,X)                           ; $B81F: 01 01
  ORA ($01,X)                           ; $B821: 01 01
  ORA ($01,X)                           ; $B823: 01 01
Loc_B825:
  ORA ($01,X)                           ; $B825: 01 01
  ORA ($01,X)                           ; $B827: 01 01
  ORA ($01,X)                           ; $B829: 01 01
  ORA ($01,X)                           ; $B82B: 01 01
  ORA ($01,X)                           ; $B82D: 01 01
  ORA ($01,X)                           ; $B82F: 01 01
  ORA ($01,X)                           ; $B831: 01 01
  ORA ($01,X)                           ; $B833: 01 01
  ORA ($01,X)                           ; $B835: 01 01
  ORA ($01,X)                           ; $B837: 01 01
  ORA ($01,X)                           ; $B839: 01 01
  ORA ($01,X)                           ; $B83B: 01 01
  ORA ($01,X)                           ; $B83D: 01 01
  ORA ($01,X)                           ; $B83F: 01 01
  ORA ($01,X)                           ; $B841: 01 01
  ORA ($01,X)                           ; $B843: 01 01
  ORA ($01,X)                           ; $B845: 01 01
  ORA ($01,X)                           ; $B847: 01 01
  ORA ($01,X)                           ; $B849: 01 01
  ORA ($01,X)                           ; $B84B: 01 01
  ORA ($01,X)                           ; $B84D: 01 01
  ORA ($01,X)                           ; $B84F: 01 01
  ORA ($01,X)                           ; $B851: 01 01
  ORA ($80,X)                           ; $B853: 01 80
  STA ($01,X)                           ; $B855: 81 01
  STY $85                               ; $B857: 84 85
  ORA ($82,X)                           ; $B859: 01 82
  SAX ($01,X)                           ; $B85B: 83 01
  DEY                                   ; $B85D: 88
  NOP #$01                              ; $B85E: 89 01
  ORA ($8A,X)                           ; $B860: 01 8A
  XAA #$01                              ; $B862: 8B 01
  ORA ($A6,X)                           ; $B864: 01 A6
  LAX $01                               ; $B866: A7 01
  ORA ($01,X)                           ; $B868: 01 01
  ORA ($01,X)                           ; $B86A: 01 01
  ORA ($01,X)                           ; $B86C: 01 01
  ORA ($01,X)                           ; $B86E: 01 01
  ORA ($01,X)                           ; $B870: 01 01
  ORA ($01,X)                           ; $B872: 01 01
  BCC $B807                             ; $B874: 90 91
  ORA ($94,X)                           ; $B876: 01 94
  STA $01,X                             ; $B878: 95 01
  JAM                                   ; $B87A: 92
  AHX ($01),Y                           ; $B87B: 93 01
  TYA                                   ; $B87D: 98
  STA $0101,Y                           ; $B87E: 99 01 01
  TXS                                   ; $B881: 9A
  TAS $0101,Y                           ; $B882: 9B 01 01
  TAY                                   ; $B885: A8
  LDA #$01                              ; $B886: A9 01
  ORA ($01,X)                           ; $B888: 01 01
  ORA ($01,X)                           ; $B88A: 01 01
  ORA ($01,X)                           ; $B88C: 01 01
  ORA ($01,X)                           ; $B88E: 01 01
  ORA ($01,X)                           ; $B890: 01 01
  ORA ($01,X)                           ; $B892: 01 01
  ORA ($01,X)                           ; $B894: 01 01
  ORA ($01,X)                           ; $B896: 01 01
  ORA ($01,X)                           ; $B898: 01 01
  ORA ($01,X)                           ; $B89A: 01 01
  ORA ($01,X)                           ; $B89C: 01 01
  ORA ($01,X)                           ; $B89E: 01 01
  ORA ($01,X)                           ; $B8A0: 01 01
  ORA ($01,X)                           ; $B8A2: 01 01
  ORA ($01,X)                           ; $B8A4: 01 01
  ORA ($01,X)                           ; $B8A6: 01 01
  ORA ($01,X)                           ; $B8A8: 01 01
  ORA ($01,X)                           ; $B8AA: 01 01
  PHA                                   ; $B8AC: 48
  RRA $016B                             ; $B8AD: 6F 6B 01
  ORA ($01,X)                           ; $B8B0: 01 01
  ORA ($01,X)                           ; $B8B2: 01 01
  ORA ($01,X)                           ; $B8B4: 01 01
  ORA ($01,X)                           ; $B8B6: 01 01
  ORA ($01,X)                           ; $B8B8: 01 01
  ORA ($01,X)                           ; $B8BA: 01 01
  ORA ($01,X)                           ; $B8BC: 01 01
  ORA ($01,X)                           ; $B8BE: 01 01
  ORA ($01,X)                           ; $B8C0: 01 01
  ORA ($01,X)                           ; $B8C2: 01 01
  ORA ($01,X)                           ; $B8C4: 01 01
  ORA ($01,X)                           ; $B8C6: 01 01
  ORA ($01,X)                           ; $B8C8: 01 01
  ORA ($01,X)                           ; $B8CA: 01 01
  ORA ($01,X)                           ; $B8CC: 01 01
  ORA ($01,X)                           ; $B8CE: 01 01
  ORA ($01,X)                           ; $B8D0: 01 01
  ORA ($01,X)                           ; $B8D2: 01 01
  ORA ($01,X)                           ; $B8D4: 01 01
  ORA ($01,X)                           ; $B8D6: 01 01
  ORA ($01,X)                           ; $B8D8: 01 01
  ORA ($01,X)                           ; $B8DA: 01 01
  ORA ($01,X)                           ; $B8DC: 01 01
  ORA ($01,X)                           ; $B8DE: 01 01
  ORA ($01,X)                           ; $B8E0: 01 01
  ORA ($01,X)                           ; $B8E2: 01 01
  ORA ($01,X)                           ; $B8E4: 01 01
  ORA ($01,X)                           ; $B8E6: 01 01
  ORA ($01,X)                           ; $B8E8: 01 01
  ORA ($01,X)                           ; $B8EA: 01 01
  ORA ($01,X)                           ; $B8EC: 01 01
  ORA ($01,X)                           ; $B8EE: 01 01
  ORA ($01,X)                           ; $B8F0: 01 01
  ORA ($01,X)                           ; $B8F2: 01 01
  ORA ($01,X)                           ; $B8F4: 01 01
  ORA ($01,X)                           ; $B8F6: 01 01
  ORA ($01,X)                           ; $B8F8: 01 01
  ORA ($01,X)                           ; $B8FA: 01 01
  ORA ($01,X)                           ; $B8FC: 01 01
  ORA ($01,X)                           ; $B8FE: 01 01
  ORA ($01,X)                           ; $B900: 01 01
  ORA ($01,X)                           ; $B902: 01 01
  ORA ($01,X)                           ; $B904: 01 01
  ORA ($01,X)                           ; $B906: 01 01
  ORA ($01,X)                           ; $B908: 01 01
  ORA ($01,X)                           ; $B90A: 01 01
  ORA ($01,X)                           ; $B90C: 01 01
  ORA ($01,X)                           ; $B90E: 01 01
  ORA ($01,X)                           ; $B910: 01 01
  ORA ($01,X)                           ; $B912: 01 01
  NOP #$81                              ; $B914: 80 81
  ORA ($84,X)                           ; $B916: 01 84
  STA $01                               ; $B918: 85 01
  NOP #$83                              ; $B91A: 82 83
  ORA ($88,X)                           ; $B91C: 01 88
  NOP #$01                              ; $B91E: 89 01
  STX $87                               ; $B920: 86 87
  ORA ($01,X)                           ; $B922: 01 01
  TXA                                   ; $B924: 8A
  XAA #$01                              ; $B925: 8B 01
  ORA ($01,X)                           ; $B927: 01 01
  ORA ($01,X)                           ; $B929: 01 01
  ORA ($01,X)                           ; $B92B: 01 01
  ORA ($01,X)                           ; $B92D: 01 01
  ORA ($01,X)                           ; $B92F: 01 01
  ORA ($01,X)                           ; $B931: 01 01
  ORA ($90,X)                           ; $B933: 01 90
  STA ($01),Y                           ; $B935: 91 01
  STY $95,X                             ; $B937: 94 95
  ORA ($92,X)                           ; $B939: 01 92
  AHX ($01),Y                           ; $B93B: 93 01
  TYA                                   ; $B93D: 98
  STA $9601,Y                           ; $B93E: 99 01 96
  SAX $01,Y                             ; $B941: 97 01
  ORA ($9A,X)                           ; $B943: 01 9A
  TAS $0101,Y                           ; $B945: 9B 01 01
  ORA ($01,X)                           ; $B948: 01 01
  ORA ($01,X)                           ; $B94A: 01 01
  ORA ($01,X)                           ; $B94C: 01 01
  ORA ($01,X)                           ; $B94E: 01 01
  ORA ($01,X)                           ; $B950: 01 01
  ORA ($01,X)                           ; $B952: 01 01
  ORA ($01,X)                           ; $B954: 01 01
  ORA ($01,X)                           ; $B956: 01 01
  ORA ($01,X)                           ; $B958: 01 01
  ORA ($01,X)                           ; $B95A: 01 01
  ORA ($01,X)                           ; $B95C: 01 01
  ORA ($01,X)                           ; $B95E: 01 01
  ORA ($01,X)                           ; $B960: 01 01
  ORA ($01,X)                           ; $B962: 01 01
  ORA ($01,X)                           ; $B964: 01 01
  ORA ($01,X)                           ; $B966: 01 01
  ORA ($01,X)                           ; $B968: 01 01
  ORA ($01,X)                           ; $B96A: 01 01
  PHA                                   ; $B96C: 48
  RRA $016B                             ; $B96D: 6F 6B 01
  ORA ($01,X)                           ; $B970: 01 01
  ORA ($01,X)                           ; $B972: 01 01
  ORA ($01,X)                           ; $B974: 01 01
  ORA ($01,X)                           ; $B976: 01 01
  ORA ($01,X)                           ; $B978: 01 01
  ORA ($01,X)                           ; $B97A: 01 01
  ORA ($01,X)                           ; $B97C: 01 01
  ORA ($01,X)                           ; $B97E: 01 01
  ORA ($01,X)                           ; $B980: 01 01
  ORA ($01,X)                           ; $B982: 01 01
  ORA ($01,X)                           ; $B984: 01 01
  ORA ($01,X)                           ; $B986: 01 01
  ORA ($AD,X)                           ; $B988: 01 AD
  RTI                                   ; $B98A: 40
; --- Data Region ---
  .byte $01,$D0,$40,$AD,$7E,$00,$29,$02,$D0,$39,$AD,$78,$04,$F0,$34,$10; $B98B: 01 D0 40 AD 7E 00 29 02 D0 39 AD 78 04 F0 34 10
  .byte $03,$4C,$0E,$BA                   ; $B99B: 03 4C 0E BA
Loc_B99F:
; --- Code Region ---
  CMP #$10                              ; $B99F: C9 10
  BEQ $B9CF                             ; $B9A1: F0 2C
  CMP #$02                              ; $B9A3: C9 02
  BCC $B9CB                             ; $B9A5: 90 24
  CMP #$0C                              ; $B9A7: C9 0C
  BCS $B9CB                             ; $B9A9: B0 20
  LDY $047A                             ; $B9AB: AC 7A 04
  INC $047A                             ; $B9AE: EE 7A 04
  LDA $0151,Y                           ; $B9B1: B9 51 01
  CMP #$FF                              ; $B9B4: C9 FF
  BEQ $B9CB                             ; $B9B6: F0 13
  TAX                                   ; $B9B8: AA
  JSR $F2D7                             ; $B9B9: 20 D7 F2
  LDA $0000                             ; $B9BC: AD 00 00
  STA $001C                             ; $B9BF: 8D 1C 00
  LDA $0001                             ; $B9C2: AD 01 00
  STA $001D                             ; $B9C5: 8D 1D 00
  JMP $BB28                             ; $B9C8: 4C 28 BB
Loc_B9CB:
  JMP $BA9D                             ; $B9CB: 4C 9D BA
Loc_B9CE:
  RTS                                   ; $B9CE: 60
Loc_B9CF:
  LDA #$00                              ; $B9CF: A9 00
  STA $0478                             ; $B9D1: 8D 78 04
  STA $047A                             ; $B9D4: 8D 7A 04
  STA $0480                             ; $B9D7: 8D 80 04
  STA $0424                             ; $B9DA: 8D 24 04
  STA $0425                             ; $B9DD: 8D 25 04
  LDA $047C                             ; $B9E0: AD 7C 04
  CMP #$0F                              ; $B9E3: C9 0F
  BNE $B9EA                             ; $B9E5: D0 03
  DEC $047B                             ; $B9E7: CE 7B 04
Loc_B9EA:
  LDA #$06                              ; $B9EA: A9 06
  STA $0061                             ; $B9EC: 8D 61 00
  LDA #$08                              ; $B9EF: A9 08
  STA $00B2                             ; $B9F1: 8D B2 00
  LDA #$09                              ; $B9F4: A9 09
  STA $00B3                             ; $B9F6: 8D B3 00
  LDA #$06                              ; $B9F9: A9 06
  STA $00B4                             ; $B9FB: 8D B4 00
  LDY #$01                              ; $B9FE: A0 01
  STY $008F                             ; $BA00: 8C 8F 00
  LDA #$FF                              ; $BA03: A9 FF
Loc_BA05:
  STA $0480,Y                           ; $BA05: 99 80 04
  INY                                   ; $BA08: C8
  CPY #$0B                              ; $BA09: C0 0B
  BCC $BA05                             ; $BA0B: 90 F8
  RTS                                   ; $BA0D: 60
Loc_BA0E:
  LDA $0478                             ; $BA0E: AD 78 04
  AND #$0F                              ; $BA11: 29 0F
  STA $0479                             ; $BA13: 8D 79 04
  LDA #$00                              ; $BA16: A9 00
  STA $0478                             ; $BA18: 8D 78 04
  STA $047A                             ; $BA1B: 8D 7A 04
  STA $047B                             ; $BA1E: 8D 7B 04
  STA $0486                             ; $BA21: 8D 86 04
  LDA #$C0                              ; $BA24: A9 C0
  STA $0480                             ; $BA26: 8D 80 04
  LDA #$23                              ; $BA29: A9 23
  STA $0481                             ; $BA2B: 8D 81 04
  LDY #$30                              ; $BA2E: A0 30
  JSR $F25F                             ; $BA30: 20 5F F2
  LDA $047C                             ; $BA33: AD 7C 04
  CMP #$FF                              ; $BA36: C9 FF
  BNE $BA53                             ; $BA38: D0 19
  AND #$0F                              ; $BA3A: 29 0F
  STA $047C                             ; $BA3C: 8D 7C 04
  LDY #$00                              ; $BA3F: A0 00
Loc_BA41:
  LDA $0151,Y                           ; $BA41: B9 51 01
  CMP #$FF                              ; $BA44: C9 FF
  BEQ $BA4B                             ; $BA46: F0 03
  INC $047B                             ; $BA48: EE 7B 04
Loc_BA4B:
  INY                                   ; $BA4B: C8
  CPY #$0A                              ; $BA4C: C0 0A
  BCC $BA41                             ; $BA4E: 90 F1
  JMP $BA7E                             ; $BA50: 4C 7E BA
Loc_BA53:
  LDA $0402                             ; $BA53: AD 02 04
  LDY $0479                             ; $BA56: AC 79 04
  CPY #$02                              ; $BA59: C0 02
  BNE $BA65                             ; $BA5B: D0 08
  LDA #$00                              ; $BA5D: A9 00
  STA $0479                             ; $BA5F: 8D 79 04
  LDA $040C                             ; $BA62: AD 0C 04
Loc_BA65:
  JSR $F2AF                             ; $BA65: 20 AF F2
  LDY #$11                              ; $BA68: A0 11
  LDX #$00                              ; $BA6A: A2 00
Loc_BA6C:
  LDA ($00),Y                           ; $BA6C: B1 00
  STA $0151,X                           ; $BA6E: 9D 51 01
  CMP #$FF                              ; $BA71: C9 FF
  BEQ $BA78                             ; $BA73: F0 03
  INC $047B                             ; $BA75: EE 7B 04
Loc_BA78:
  INX                                   ; $BA78: E8
  INY                                   ; $BA79: C8
  CPX #$0A                              ; $BA7A: E0 0A
  BCC $BA6C                             ; $BA7C: 90 EE
Loc_BA7E:
  LDA $0479                             ; $BA7E: AD 79 04
  BEQ $BA90                             ; $BA81: F0 0D
  LDA #$09                              ; $BA83: A9 09
  STA $0482                             ; $BA85: 8D 82 04
  LDA #$B8                              ; $BA88: A9 B8
  STA $0483                             ; $BA8A: 8D 83 04
  JMP $BA9D                             ; $BA8D: 4C 9D BA
Loc_BA90:
  LDA #$C9                              ; $BA90: A9 C9
  STA $0482                             ; $BA92: 8D 82 04
  LDA #$B8                              ; $BA95: A9 B8
  STA $0483                             ; $BA97: 8D 83 04
  JMP $BA9D                             ; $BA9A: 4C 9D BA
Loc_BA9D:
  LDA $0478                             ; $BA9D: AD 78 04
  CMP #$0F                              ; $BAA0: C9 0F
  BEQ $BB03                             ; $BAA2: F0 5F
  CMP #$02                              ; $BAA4: C9 02
  BCC $BAB7                             ; $BAA6: 90 0F
  LDA $0486                             ; $BAA8: AD 86 04
  BNE $BAE3                             ; $BAAB: D0 36
  INC $0486                             ; $BAAD: EE 86 04
  LDA $047C                             ; $BAB0: AD 7C 04
  CMP #$0F                              ; $BAB3: C9 0F
  BEQ $BAE3                             ; $BAB5: F0 2C
Loc_BAB7:
  LDA $0482                             ; $BAB7: AD 82 04
  STA $001A                             ; $BABA: 8D 1A 00
  LDA $0483                             ; $BABD: AD 83 04
  STA $001B                             ; $BAC0: 8D 1B 00
  LDY #$00                              ; $BAC3: A0 00
Loc_BAC5:
  LDA ($1A),Y                           ; $BAC5: B1 1A
  STA $0160,Y                           ; $BAC7: 99 60 01
  INY                                   ; $BACA: C8
  CPY #$40                              ; $BACB: C0 40
  BCC $BAC5                             ; $BACD: 90 F6
  LDA $0482                             ; $BACF: AD 82 04
  CLC                                   ; $BAD2: 18
  ADC #$40                              ; $BAD3: 69 40
  STA $0482                             ; $BAD5: 8D 82 04
  LDA $0483                             ; $BAD8: AD 83 04
  ADC #$00                              ; $BADB: 69 00
  STA $0483                             ; $BADD: 8D 83 04
  JMP $BAEF                             ; $BAE0: 4C EF BA
Loc_BAE3:
  LDA #$01                              ; $BAE3: A9 01
  LDY #$00                              ; $BAE5: A0 00
Loc_BAE7:
  STA $0160,Y                           ; $BAE7: 99 60 01
  INY                                   ; $BAEA: C8
  CPY #$40                              ; $BAEB: C0 40
  BCC $BAE7                             ; $BAED: 90 F8
Loc_BAEF:
  LDA $0480                             ; $BAEF: AD 80 04
  CLC                                   ; $BAF2: 18
  ADC #$40                              ; $BAF3: 69 40
  STA $0480                             ; $BAF5: 8D 80 04
  LDA $0481                             ; $BAF8: AD 81 04
  ADC #$00                              ; $BAFB: 69 00
  STA $0481                             ; $BAFD: 8D 81 04
  JMP $BB1C                             ; $BB00: 4C 1C BB
Loc_BB03:
  LDY #$00                              ; $BB03: A0 00
  LDA #$AA                              ; $BB05: A9 AA
Loc_BB07:
  STA $0160,Y                           ; $BB07: 99 60 01
  INY                                   ; $BB0A: C8
  CPY #$40                              ; $BB0B: C0 40
  BCC $BB07                             ; $BB0D: 90 F8
  LDA #$C0                              ; $BB0F: A9 C0
  STA $0480                             ; $BB11: 8D 80 04
  LDA #$27                              ; $BB14: A9 27
  STA $0481                             ; $BB16: 8D 81 04
  JMP $BB1C                             ; $BB19: 4C 1C BB
Loc_BB1C:
  INC $0478                             ; $BB1C: EE 78 04
  LDA $007E                             ; $BB1F: AD 7E 00
  ORA #$02                              ; $BB22: 09 02
  STA $007E                             ; $BB24: 8D 7E 00
  RTS                                   ; $BB27: 60
Loc_BB28:
  LDA #$01                              ; $BB28: A9 01
  LDY #$00                              ; $BB2A: A0 00
Loc_BB2C:
  STA $0160,Y                           ; $BB2C: 99 60 01
  INY                                   ; $BB2F: C8
  CPY #$40                              ; $BB30: C0 40
  BCC $BB2C                             ; $BB32: 90 F8
  TXA                                   ; $BB34: 8A
  JSR $F308                             ; $BB35: 20 08 F3
  LDY #$00                              ; $BB38: A0 00
  LDX #$00                              ; $BB3A: A2 00
Loc_BB3C:
  LDA ($00),Y                           ; $BB3C: B1 00
  BEQ $BB57                             ; $BB3E: F0 17
  CMP #$39                              ; $BB40: C9 39
  BEQ $BB4E                             ; $BB42: F0 0A
  CMP #$3A                              ; $BB44: C9 3A
  BEQ $BB4E                             ; $BB46: F0 06
  STA $0183,X                           ; $BB48: 9D 83 01
  JMP $BB52                             ; $BB4B: 4C 52 BB
Loc_BB4E:
  DEX                                   ; $BB4E: CA
  STA $0163,X                           ; $BB4F: 9D 63 01
Loc_BB52:
  INX                                   ; $BB52: E8
  INY                                   ; $BB53: C8
  JMP $BB3C                             ; $BB54: 4C 3C BB
Loc_BB57:
  LDA #$76                              ; $BB57: A9 76
  STA $0017                             ; $BB59: 8D 17 00
  LDA #$02                              ; $BB5C: A9 02
  STA $0013                             ; $BB5E: 8D 13 00
  LDA #$2B                              ; $BB61: A9 2B
  STA $0014                             ; $BB63: 8D 14 00
  LDY #$00                              ; $BB66: A0 00
Loc_BB68:
  LDA #$00                              ; $BB68: A9 00
  STA $0002                             ; $BB6A: 8D 02 00
  STA $0003                             ; $BB6D: 8D 03 00
  LDA ($1C),Y                           ; $BB70: B1 1C
  STA $0001                             ; $BB72: 8D 01 00
  CMP #$64                              ; $BB75: C9 64
  BNE $BB80                             ; $BB77: D0 07
  CPY #$03                              ; $BB79: C0 03
  BNE $BB80                             ; $BB7B: D0 03
  JMP $BC32                             ; $BB7D: 4C 32 BC
Loc_BB80:
  JSR $E9BA                             ; $BB80: 20 BA E9
  LDX $0014                             ; $BB83: AE 14 00
  JSR $B040                             ; $BB86: 20 40 B0
Loc_BB89:
  LDA $0014                             ; $BB89: AD 14 00
  CLC                                   ; $BB8C: 18
  ADC #$03                              ; $BB8D: 69 03
  STA $0014                             ; $BB8F: 8D 14 00
  INY                                   ; $BB92: C8
  CPY #$04                              ; $BB93: C0 04
  BCC $BB68                             ; $BB95: 90 D1
  LDA $0479                             ; $BB97: AD 79 04
  BNE $BBB3                             ; $BB9A: D0 17
  LDA #$00                              ; $BB9C: A9 00
  STA $0002                             ; $BB9E: 8D 02 00
  STA $0003                             ; $BBA1: 8D 03 00
  LDY #$04                              ; $BBA4: A0 04
  LDA ($1C),Y                           ; $BBA6: B1 1C
  STA $0001                             ; $BBA8: 8D 01 00
  JSR $E9BA                             ; $BBAB: 20 BA E9
  LDX #$37                              ; $BBAE: A2 37
  JSR $B040                             ; $BBB0: 20 40 B0
Loc_BBB3:
  LDY #$06                              ; $BBB3: A0 06
  LDA ($1C),Y                           ; $BBB5: B1 1C
  STA $0001                             ; $BBB7: 8D 01 00
  INY                                   ; $BBBA: C8
  LDA ($1C),Y                           ; $BBBB: B1 1C
  STA $0002                             ; $BBBD: 8D 02 00
  LDA #$00                              ; $BBC0: A9 00
  STA $0003                             ; $BBC2: 8D 03 00
  ASL $0001                             ; $BBC5: 0E 01 00
  ROL $0002                             ; $BBC8: 2E 02 00
  ROL $0003                             ; $BBCB: 2E 03 00
  JSR $E9BA                             ; $BBCE: 20 BA E9
  LDA $0008                             ; $BBD1: AD 08 00
  STA $0007                             ; $BBD4: 8D 07 00
  LDA $0009                             ; $BBD7: AD 09 00
  STA $0008                             ; $BBDA: 8D 08 00
  LDA #$03                              ; $BBDD: A9 03
  STA $0013                             ; $BBDF: 8D 13 00
  LDX #$37                              ; $BBE2: A2 37
  LDA $0479                             ; $BBE4: AD 79 04
  BNE $BBF1                             ; $BBE7: D0 08
  LDX #$3A                              ; $BBE9: A2 3A
  JSR $B040                             ; $BBEB: 20 40 B0
  JMP $BC15                             ; $BBEE: 4C 15 BC
Loc_BBF1:
  JSR $B040                             ; $BBF1: 20 40 B0
  LDY #$08                              ; $BBF4: A0 08
  LDA ($1C),Y                           ; $BBF6: B1 1C
  STA $0001                             ; $BBF8: 8D 01 00
  INY                                   ; $BBFB: C8
  LDA ($1C),Y                           ; $BBFC: B1 1C
  AND #$03                              ; $BBFE: 29 03
  STA $0002                             ; $BC00: 8D 02 00
  LDA #$00                              ; $BC03: A9 00
  STA $0003                             ; $BC05: 8D 03 00
  JSR $E9BA                             ; $BC08: 20 BA E9
  LDA #$04                              ; $BC0B: A9 04
  STA $0013                             ; $BC0D: 8D 13 00
  LDX #$3B                              ; $BC10: A2 3B
  JSR $B040                             ; $BC12: 20 40 B0
Loc_BC15:
  LDA $0480                             ; $BC15: AD 80 04
  CLC                                   ; $BC18: 18
  ADC #$40                              ; $BC19: 69 40
  STA $0480                             ; $BC1B: 8D 80 04
  LDA $0481                             ; $BC1E: AD 81 04
  ADC #$00                              ; $BC21: 69 00
  STA $0481                             ; $BC23: 8D 81 04
  INC $0478                             ; $BC26: EE 78 04
  LDA $007E                             ; $BC29: AD 7E 00
  ORA #$02                              ; $BC2C: 09 02
  STA $007E                             ; $BC2E: 8D 7E 00
  RTS                                   ; $BC31: 60
Loc_BC32:
  LDX $0014                             ; $BC32: AE 14 00
  LDA #$32                              ; $BC35: A9 32
  STA $0160,X                           ; $BC37: 9D 60 01
  INX                                   ; $BC3A: E8
  STA $0160,X                           ; $BC3B: 9D 60 01
  JMP $BB89                             ; $BC3E: 4C 89 BB
Loc_BC41:
  LDA $008B                             ; $BC41: AD 8B 00
  AND #$FB                              ; $BC44: 29 FB
  STA $2000                             ; $BC46: 8D 00 20
  LDA $2002                             ; $BC49: AD 02 20
  LDA $0481                             ; $BC4C: AD 81 04
  STA $2006                             ; $BC4F: 8D 06 20
  LDA $0480                             ; $BC52: AD 80 04
  STA $2006                             ; $BC55: 8D 06 20
  LDY #$00                              ; $BC58: A0 00
Loc_BC5A:
  LDA $0160,Y                           ; $BC5A: B9 60 01
  STA $2007                             ; $BC5D: 8D 07 20
  INY                                   ; $BC60: C8
  CPY #$40                              ; $BC61: C0 40
  BCC $BC5A                             ; $BC63: 90 F5
  RTS                                   ; $BC65: 60
Loc_BC66:
  LDY #$3F                              ; $BC66: A0 3F
  LDA #$00                              ; $BC68: A9 00
Loc_BC6A:
  STA $0140,Y                           ; $BC6A: 99 40 01
  DEY                                   ; $BC6D: 88
  BPL $BC6A                             ; $BC6E: 10 FA
  RTS                                   ; $BC70: 60
Loc_BC71:
  LDA $0401                             ; $BC71: AD 01 04
  JSR $EADE                             ; $BC74: 20 DE EA
; --- Data Region ---
  .byte $83,$BC,$9B,$BC,$03,$BD,$38,$BD,$60,$BD,$92,$BD; $BC77: 83 BC 9B BC 03 BD 38 BD 60 BD 92 BD
Loc_BC83:  ; (dispatch callback target)
; --- Code Region ---
  LDA #$00                              ; $BC83: A9 00
  STA $0470                             ; $BC85: 8D 70 04
  LDA #$88                              ; $BC88: A9 88
  STA $0471                             ; $BC8A: 8D 71 04
  LDA #$00                              ; $BC8D: A9 00
  STA $0472                             ; $BC8F: 8D 72 04
  LDA #$24                              ; $BC92: A9 24
  STA $0473                             ; $BC94: 8D 73 04
  INC $0401                             ; $BC97: EE 01 04
  RTS                                   ; $BC9A: 60
Loc_BC9B:  ; (dispatch callback target)
  LDY #$30                              ; $BC9B: A0 30
  JSR $F25F                             ; $BC9D: 20 5F F2
  LDA #$40                              ; $BCA0: A9 40
  STA $0380                             ; $BCA2: 8D 80 03
  LDA $0473                             ; $BCA5: AD 73 04
  STA $0381                             ; $BCA8: 8D 81 03
  LDA $0472                             ; $BCAB: AD 72 04
  STA $0382                             ; $BCAE: 8D 82 03
  LDA $0470                             ; $BCB1: AD 70 04
  STA $0000                             ; $BCB4: 8D 00 00
  LDA $0471                             ; $BCB7: AD 71 04
  STA $0001                             ; $BCBA: 8D 01 00
  LDY #$00                              ; $BCBD: A0 00
Loc_BCBF:
  LDA ($00),Y                           ; $BCBF: B1 00
  STA $0383,Y                           ; $BCC1: 99 83 03
  INY                                   ; $BCC4: C8
  CPY #$40                              ; $BCC5: C0 40
  BCC $BCBF                             ; $BCC7: 90 F6
  LDA #$FF                              ; $BCC9: A9 FF
  STA $0383,Y                           ; $BCCB: 99 83 03
  LDA $0470                             ; $BCCE: AD 70 04
  CLC                                   ; $BCD1: 18
  ADC #$40                              ; $BCD2: 69 40
  STA $0470                             ; $BCD4: 8D 70 04
  LDA $0471                             ; $BCD7: AD 71 04
  ADC #$00                              ; $BCDA: 69 00
  STA $0471                             ; $BCDC: 8D 71 04
  LDA $0472                             ; $BCDF: AD 72 04
  CLC                                   ; $BCE2: 18
  ADC #$40                              ; $BCE3: 69 40
  STA $0472                             ; $BCE5: 8D 72 04
  LDA $0473                             ; $BCE8: AD 73 04
  ADC #$00                              ; $BCEB: 69 00
  STA $0473                             ; $BCED: 8D 73 04
  CMP #$28                              ; $BCF0: C9 28
  BNE $BCFA                             ; $BCF2: D0 06
  INC $0401                             ; $BCF4: EE 01 04
  JSR $ECEE                             ; $BCF7: 20 EE EC
Loc_BCFA:
  LDA $007E                             ; $BCFA: AD 7E 00
  ORA #$04                              ; $BCFD: 09 04
  STA $007E                             ; $BCFF: 8D 7E 00
  RTS                                   ; $BD02: 60
Loc_BD03:  ; (dispatch callback target)
  LDA $0087                             ; $BD03: AD 87 00
  BPL $BD37                             ; $BD06: 10 2F
  LDA #$0A                              ; $BD08: A9 0A
  STA $00B3                             ; $BD0A: 8D B3 00
  LDA #$0B                              ; $BD0D: A9 0B
  STA $00C3                             ; $BD0F: 8D C3 00
  LDA #$0E                              ; $BD12: A9 0E
  STA $00CB                             ; $BD14: 8D CB 00
  LDA #$14                              ; $BD17: A9 14
  STA $00D3                             ; $BD19: 8D D3 00
  LDA #$15                              ; $BD1C: A9 15
  STA $00DB                             ; $BD1E: 8D DB 00
  LDA #$E1                              ; $BD21: A9 E1
  STA $00E6                             ; $BD23: 8D E6 00
  LDA #$00                              ; $BD26: A9 00
  STA $0000                             ; $BD28: 8D 00 00
  JSR $DBB1                             ; $BD2B: 20 B1 DB
  INC $0401                             ; $BD2E: EE 01 04
  JSR $BDFE                             ; $BD31: 20 FE BD
  JMP $ECBF                             ; $BD34: 4C BF EC
Loc_BD37:
  RTS                                   ; $BD37: 60
Loc_BD38:  ; (dispatch callback target)
  LDA #$F0                              ; $BD38: A9 F0
  STA $0200                             ; $BD3A: 8D 00 02
  STA $0204                             ; $BD3D: 8D 04 02
  LDA $0087                             ; $BD40: AD 87 00
  BPL $BD5F                             ; $BD43: 10 1A
  LDA $0081                             ; $BD45: AD 81 00
  ORA $0082                             ; $BD48: 0D 82 00
  AND #$04                              ; $BD4B: 29 04
  BEQ $BD5F                             ; $BD4D: F0 10
  LDA $0083                             ; $BD4F: AD 83 00
  CMP #$1C                              ; $BD52: C9 1C
  BNE $BD59                             ; $BD54: D0 03
  JSR $BDF1                             ; $BD56: 20 F1 BD
Loc_BD59:
  INC $0401                             ; $BD59: EE 01 04
  JMP $ECEE                             ; $BD5C: 4C EE EC
Loc_BD5F:
  RTS                                   ; $BD5F: 60
Loc_BD60:  ; (dispatch callback target)
  LDA #$F0                              ; $BD60: A9 F0
  STA $0200                             ; $BD62: 8D 00 02
  STA $0204                             ; $BD65: 8D 04 02
  LDA $0087                             ; $BD68: AD 87 00
  BPL $BD91                             ; $BD6B: 10 24
  LDA #$01                              ; $BD6D: A9 01
  STA $00B3                             ; $BD6F: 8D B3 00
  STA $00C3                             ; $BD72: 8D C3 00
  STA $00CB                             ; $BD75: 8D CB 00
  STA $00D3                             ; $BD78: 8D D3 00
  STA $00DB                             ; $BD7B: 8D DB 00
  LDA #$E0                              ; $BD7E: A9 E0
  STA $00E6                             ; $BD80: 8D E6 00
  LDA #$00                              ; $BD83: A9 00
  STA $0000                             ; $BD85: 8D 00 00
  JSR $DBB1                             ; $BD88: 20 B1 DB
  INC $0401                             ; $BD8B: EE 01 04
  JMP $ECBF                             ; $BD8E: 4C BF EC
Loc_BD91:
  RTS                                   ; $BD91: 60
Loc_BD92:  ; (dispatch callback target)
  LDA $0087                             ; $BD92: AD 87 00
  BPL $BDF0                             ; $BD95: 10 59
  LDA #$40                              ; $BD97: A9 40
  STA $0380                             ; $BD99: 8D 80 03
  LDA #$27                              ; $BD9C: A9 27
  STA $0381                             ; $BD9E: 8D 81 03
  LDA #$C0                              ; $BDA1: A9 C0
  STA $0382                             ; $BDA3: 8D 82 03
  LDY #$39                              ; $BDA6: A0 39
  LDA #$AA                              ; $BDA8: A9 AA
Loc_BDAA:
  STA $0383,Y                           ; $BDAA: 99 83 03
  DEY                                   ; $BDAD: 88
  BPL $BDAA                             ; $BDAE: 10 FA
  LDA #$FF                              ; $BDB0: A9 FF
  STA $03C3                             ; $BDB2: 8D C3 03
  LDA $007E                             ; $BDB5: AD 7E 00
  ORA #$04                              ; $BDB8: 09 04
  STA $007E                             ; $BDBA: 8D 7E 00
  LDA #$40                              ; $BDBD: A9 40
  STA $0068                             ; $BDBF: 8D 68 00
  LDA #$14                              ; $BDC2: A9 14
  STA $006A                             ; $BDC4: 8D 6A 00
  LDA #$1E                              ; $BDC7: A9 1E
  STA $006C                             ; $BDC9: 8D 6C 00
  LDA #$20                              ; $BDCC: A9 20
  STA $006E                             ; $BDCE: 8D 6E 00
  LDA #$F2                              ; $BDD1: A9 F2
  STA $006F                             ; $BDD3: 8D 6F 00
  LDA #$0D                              ; $BDD6: A9 0D
  STA $0070                             ; $BDD8: 8D 70 00
  LDA #$F2                              ; $BDDB: A9 F2
  STA $0071                             ; $BDDD: 8D 71 00
  LDA #$00                              ; $BDE0: A9 00
  STA $0400                             ; $BDE2: 8D 00 04
  STA $0401                             ; $BDE5: 8D 01 04
  LDY #$03                              ; $BDE8: A0 03
Loc_BDEA:
  STA $0470,Y                           ; $BDEA: 99 70 04
  DEY                                   ; $BDED: 88
  BPL $BDEA                             ; $BDEE: 10 FA
Loc_BDF0:
  RTS                                   ; $BDF0: 60
Loc_BDF1:
  LDA $6F05                             ; $BDF1: AD 05 6F
  CMP #$02                              ; $BDF4: C9 02
  BCC $BDFD                             ; $BDF6: 90 05
  LDA #$01                              ; $BDF8: A9 01
  STA $6F05                             ; $BDFA: 8D 05 6F
Loc_BDFD:
  RTS                                   ; $BDFD: 60
Loc_BDFE:
  LDA #$03                              ; $BDFE: A9 03
  STA $0061                             ; $BE00: 8D 61 00
  LDA #$28                              ; $BE03: A9 28
  STA $0068                             ; $BE05: 8D 68 00
  LDA #$E9                              ; $BE08: A9 E9
  STA $0069                             ; $BE0A: 8D 69 00
  LDA #$20                              ; $BE0D: A9 20
  STA $006A                             ; $BE0F: 8D 6A 00
  LDA #$F2                              ; $BE12: A9 F2
  STA $006B                             ; $BE14: 8D 6B 00
  LDA #$20                              ; $BE17: A9 20
  STA $006C                             ; $BE19: 8D 6C 00
  LDA #$F2                              ; $BE1C: A9 F2
  STA $006D                             ; $BE1E: 8D 6D 00
  LDA #$20                              ; $BE21: A9 20
  STA $006E                             ; $BE23: 8D 6E 00
  LDA #$F2                              ; $BE26: A9 F2
  STA $006F                             ; $BE28: 8D 6F 00
  LDA #$F0                              ; $BE2B: A9 F0
  STA $0070                             ; $BE2D: 8D 70 00
  LDA #$F1                              ; $BE30: A9 F1
  STA $0071                             ; $BE32: 8D 71 00
  RTS                                   ; $BE35: 60
Loc_BE36:
  LDA $04A0                             ; $BE36: AD A0 04
  BNE $BE3C                             ; $BE39: D0 01
  RTS                                   ; $BE3B: 60
Loc_BE3C:
  BMI $BE5D                             ; $BE3C: 30 1F
  STA $04A2                             ; $BE3E: 8D A2 04
  DEC $04A2                             ; $BE41: CE A2 04
  LDA #$00                              ; $BE44: A9 00
  STA $04A1                             ; $BE46: 8D A1 04
  LDX #$40                              ; $BE49: A2 40
  LDA $0150                             ; $BE4B: AD 50 01
  BMI $BE52                             ; $BE4E: 30 02
  LDX #$80                              ; $BE50: A2 80
Loc_BE52:
  STX $0420                             ; $BE52: 8E 20 04
  LDA #$80                              ; $BE55: A9 80
  STA $04A0                             ; $BE57: 8D A0 04
  JMP $C9C2                             ; $BE5A: 4C C2 C9
Loc_BE5D:
  AND #$0F                              ; $BE5D: 29 0F
  BNE $BE64                             ; $BE5F: D0 03
  JMP $C9C2                             ; $BE61: 4C C2 C9
Loc_BE64:
  INC $04A3                             ; $BE64: EE A3 04
  INC $04D0                             ; $BE67: EE D0 04
  LDY #$36                              ; $BE6A: A0 36
  JSR $F25F                             ; $BE6C: 20 5F F2
  LDA $04A2                             ; $BE6F: AD A2 04
  JSR $EADE                             ; $BE72: 20 DE EA
; --- Data Region ---
  .byte $BB,$BE,$EB,$BE,$2F,$BF,$70,$BF,$BF,$BF,$F3,$BF,$46,$C0,$90,$C0; $BE75: BB BE EB BE 2F BF 70 BF BF BF F3 BF 46 C0 90 C0
  .byte $C8,$C0,$23,$C1,$68,$C1,$AC,$C1,$FA,$C1,$5D,$C2,$DD,$C2,$3D,$C3; $BE85: C8 C0 23 C1 68 C1 AC C1 FA C1 5D C2 DD C2 3D C3
  .byte $A2,$C3,$F6,$C3,$3E,$C4,$E1,$C4,$11,$C5,$56,$C5,$B1,$C5,$F7,$C5; $BE95: A2 C3 F6 C3 3E C4 E1 C4 11 C5 56 C5 B1 C5 F7 C5
  .byte $36,$C6,$7D,$C6,$C6,$C6,$5F,$C7,$D1,$C7,$00,$C8,$30,$C8,$7D,$C8; $BEA5: 36 C6 7D C6 C6 C6 5F C7 D1 C7 00 C8 30 C8 7D C8
  .byte $B4,$C8,$F1,$C8,$26,$C9,$AD,$A1,$04,$D0,$09,$A9,$E8,$20,$6D,$C9; $BEB5: B4 C8 F1 C8 26 C9 AD A1 04 D0 09 A9 E8 20 6D C9
  .byte $EE,$A1,$04,$60                   ; $BEC5: EE A1 04 60
Loc_BEC9:
; --- Code Region ---
  LDA #$00                              ; $BEC9: A9 00
  STA $0010                             ; $BECB: 8D 10 00
  LDA #$80                              ; $BECE: A9 80
  STA $0011                             ; $BED0: 8D 11 00
  LDY $04A1                             ; $BED3: AC A1 04
  JSR $C994                             ; $BED6: 20 94 C9
  LDA $04A3                             ; $BED9: AD A3 04
  AND #$04                              ; $BEDC: 29 04
  BEQ $BEE2                             ; $BEDE: F0 02
  LDA #$01                              ; $BEE0: A9 01
Loc_BEE2:
  STA $04A1                             ; $BEE2: 8D A1 04
  INC $04A1                             ; $BEE5: EE A1 04
  JMP $C934                             ; $BEE8: 4C 34 C9
Loc_BEEB:  ; (dispatch callback target)
  LDA $04A1                             ; $BEEB: AD A1 04
  BNE $BEFE                             ; $BEEE: D0 0E
  LDA #$DC                              ; $BEF0: A9 DC
  JSR $C96D                             ; $BEF2: 20 6D C9
  LDA #$DF                              ; $BEF5: A9 DF
  JSR $C98A                             ; $BEF7: 20 8A C9
  INC $04A1                             ; $BEFA: EE A1 04
  RTS                                   ; $BEFD: 60
Loc_BEFE:
  LDA #$F6                              ; $BEFE: A9 F6
  STA $0010                             ; $BF00: 8D 10 00
  LDA #$80                              ; $BF03: A9 80
  STA $0011                             ; $BF05: 8D 11 00
  LDY $04A1                             ; $BF08: AC A1 04
  JSR $C994                             ; $BF0B: 20 94 C9
  LDA $04A3                             ; $BF0E: AD A3 04
  LSR                                   ; $BF11: 4A
  LSR                                   ; $BF12: 4A
  LSR                                   ; $BF13: 4A
  AND #$07                              ; $BF14: 29 07
  CMP #$06                              ; $BF16: C9 06
  BNE $BF1F                             ; $BF18: D0 05
  LDA #$00                              ; $BF1A: A9 00
  STA $04A3                             ; $BF1C: 8D A3 04
Loc_BF1F:
  TAY                                   ; $BF1F: A8
  LDA $BF29,Y                           ; $BF20: B9 29 BF
  STA $04A1                             ; $BF23: 8D A1 04
  JMP $C934                             ; $BF26: 4C 34 C9
; --- Data Region ---
  .byte $01,$02,$03,$04,$03,$02           ; $BF29: 01 02 03 04 03 02
Loc_BF2F:  ; (dispatch callback target)
; --- Code Region ---
  LDA $04A1                             ; $BF2F: AD A1 04
  BNE $BF3D                             ; $BF32: D0 09
  LDA #$E1                              ; $BF34: A9 E1
  JSR $C96D                             ; $BF36: 20 6D C9
  INC $04A1                             ; $BF39: EE A1 04
  RTS                                   ; $BF3C: 60
Loc_BF3D:
  LDA #$72                              ; $BF3D: A9 72
  STA $0010                             ; $BF3F: 8D 10 00
  LDA #$81                              ; $BF42: A9 81
  STA $0011                             ; $BF44: 8D 11 00
  LDY #$01                              ; $BF47: A0 01
  JSR $C994                             ; $BF49: 20 94 C9
  LDA $04A3                             ; $BF4C: AD A3 04
  LSR                                   ; $BF4F: 4A
  LSR                                   ; $BF50: 4A
  LSR                                   ; $BF51: 4A
  AND #$1F                              ; $BF52: 29 1F
  CMP #$15                              ; $BF54: C9 15
  BCS $BF6D                             ; $BF56: B0 15
  ASL                                   ; $BF58: 0A
  ASL                                   ; $BF59: 0A
  STA $0000                             ; $BF5A: 8D 00 00
  LDY #$54                              ; $BF5D: A0 54
  LDA #$F0                              ; $BF5F: A9 F0
Loc_BF61:
  STA $0200,Y                           ; $BF61: 99 00 02
  DEY                                   ; $BF64: 88
  DEY                                   ; $BF65: 88
  DEY                                   ; $BF66: 88
  DEY                                   ; $BF67: 88
  CPY $0000                             ; $BF68: CC 00 00
  BNE $BF61                             ; $BF6B: D0 F4
Loc_BF6D:
  JMP $C934                             ; $BF6D: 4C 34 C9
Loc_BF70:  ; (dispatch callback target)
  LDA $04A1                             ; $BF70: AD A1 04
  BNE $BF88                             ; $BF73: D0 13
  LDA #$E9                              ; $BF75: A9 E9
  JSR $C96D                             ; $BF77: 20 6D C9
  LDA #$EA                              ; $BF7A: A9 EA
  JSR $C98A                             ; $BF7C: 20 8A C9
  INC $04A1                             ; $BF7F: EE A1 04
  LDA #$03                              ; $BF82: A9 03
  STA $04A4                             ; $BF84: 8D A4 04
  RTS                                   ; $BF87: 60
Loc_BF88:
  LDA #$CD                              ; $BF88: A9 CD
  STA $0010                             ; $BF8A: 8D 10 00
  LDA #$81                              ; $BF8D: A9 81
  STA $0011                             ; $BF8F: 8D 11 00
  LDY $04A1                             ; $BF92: AC A1 04
  JSR $C994                             ; $BF95: 20 94 C9
  LDY $04A4                             ; $BF98: AC A4 04
  JSR $C994                             ; $BF9B: 20 94 C9
  LDA $04A3                             ; $BF9E: AD A3 04
  LSR                                   ; $BFA1: 4A
  LSR                                   ; $BFA2: 4A
  LSR                                   ; $BFA3: 4A
  LSR                                   ; $BFA4: 4A
  STA $0000                             ; $BFA5: 8D 00 00
  AND #$01                              ; $BFA8: 29 01
  CLC                                   ; $BFAA: 18
  ADC #$01                              ; $BFAB: 69 01
  STA $04A1                             ; $BFAD: 8D A1 04
  LDA $0000                             ; $BFB0: AD 00 00
  LSR                                   ; $BFB3: 4A
  AND #$01                              ; $BFB4: 29 01
  CLC                                   ; $BFB6: 18
  ADC #$03                              ; $BFB7: 69 03
  STA $04A4                             ; $BFB9: 8D A4 04
  JMP $C934                             ; $BFBC: 4C 34 C9
Loc_BFBF:  ; (dispatch callback target)
  LDA $04A1                             ; $BFBF: AD A1 04
  BNE $BFD2                             ; $BFC2: D0 0E
  LDA #$D1                              ; $BFC4: A9 D1
  JSR $C96D                             ; $BFC6: 20 6D C9
  INC $04A1                             ; $BFC9: EE A1 04
  LDA #$80                              ; $BFCC: A9 80
  STA $04CC                             ; $BFCE: 8D CC 04
  RTS                                   ; $BFD1: 60
Loc_BFD2:
  LDA #$39                              ; $BFD2: A9 39
  STA $0010                             ; $BFD4: 8D 10 00
  LDA #$82                              ; $BFD7: A9 82
  STA $0011                             ; $BFD9: 8D 11 00
  LDY $04A1                             ; $BFDC: AC A1 04
  JSR $C994                             ; $BFDF: 20 94 C9
  LDA $04A3                             ; $BFE2: AD A3 04
  LSR                                   ; $BFE5: 4A
  LSR                                   ; $BFE6: 4A
  LSR                                   ; $BFE7: 4A
  AND #$01                              ; $BFE8: 29 01
  STA $04A1                             ; $BFEA: 8D A1 04
  INC $04A1                             ; $BFED: EE A1 04
  JMP $C934                             ; $BFF0: 4C 34 C9
Loc_BFF3:  ; (dispatch callback target)
  LDA $04A1                             ; $BFF3: AD A1 04
  BNE $C010                             ; $BFF6: D0 18
  LDA #$C6                              ; $BFF8: A9 C6
  JSR $C96D                             ; $BFFA: 20 6D C9
  LDA #$CF                              ; $BFFD: A9 CF
  JSR $C98A                             ; $BFFF: 20 8A C9
  INC $04A1                             ; $C002: EE A1 04
  LDA #$03                              ; $C005: A9 03
  STA $04A4                             ; $C007: 8D A4 04
  LDA #$80                              ; $C00A: A9 80
  STA $04CC                             ; $C00C: 8D CC 04
  RTS                                   ; $C00F: 60
Loc_C010:
  LDA #$A7                              ; $C010: A9 A7
  STA $0010                             ; $C012: 8D 10 00
  LDA #$82                              ; $C015: A9 82
  STA $0011                             ; $C017: 8D 11 00
  LDY $04A1                             ; $C01A: AC A1 04
  JSR $C994                             ; $C01D: 20 94 C9
  LDY $04A4                             ; $C020: AC A4 04
  JSR $C994                             ; $C023: 20 94 C9
  LDA $04A3                             ; $C026: AD A3 04
  LSR                                   ; $C029: 4A
  LSR                                   ; $C02A: 4A
  LSR                                   ; $C02B: 4A
  STA $0000                             ; $C02C: 8D 00 00
  AND #$01                              ; $C02F: 29 01
  CLC                                   ; $C031: 18
  ADC #$01                              ; $C032: 69 01
  STA $04A1                             ; $C034: 8D A1 04
  LDA $0000                             ; $C037: AD 00 00
  LSR                                   ; $C03A: 4A
  AND #$01                              ; $C03B: 29 01
  CLC                                   ; $C03D: 18
  ADC #$03                              ; $C03E: 69 03
  STA $04A4                             ; $C040: 8D A4 04
  JMP $C934                             ; $C043: 4C 34 C9
Loc_C046:  ; (dispatch callback target)
  LDA $04A1                             ; $C046: AD A1 04
  BNE $C05E                             ; $C049: D0 13
  LDA #$EA                              ; $C04B: A9 EA
  JSR $C96D                             ; $C04D: 20 6D C9
  LDA #$EB                              ; $C050: A9 EB
  JSR $C98A                             ; $C052: 20 8A C9
  INC $04A1                             ; $C055: EE A1 04
  LDA #$78                              ; $C058: A9 78
  STA $04A3                             ; $C05A: 8D A3 04
  RTS                                   ; $C05D: 60
Loc_C05E:
  LDA #$83                              ; $C05E: A9 83
  STA $0010                             ; $C060: 8D 10 00
  LDA #$83                              ; $C063: A9 83
  STA $0011                             ; $C065: 8D 11 00
  LDY $04A1                             ; $C068: AC A1 04
  JSR $C994                             ; $C06B: 20 94 C9
  LDA $04A3                             ; $C06E: AD A3 04
  LSR                                   ; $C071: 4A
  LSR                                   ; $C072: 4A
  LSR                                   ; $C073: 4A
  AND #$0F                              ; $C074: 29 0F
  TAY                                   ; $C076: A8
  LDA $C080,Y                           ; $C077: B9 80 C0
  STA $04A1                             ; $C07A: 8D A1 04
  JMP $C934                             ; $C07D: 4C 34 C9
; --- Data Region ---
  .byte $01,$02,$03,$03,$03,$03,$03,$02,$02,$02,$02,$01,$01,$01,$01,$01; $C080: 01 02 03 03 03 03 03 02 02 02 02 01 01 01 01 01
Loc_C090:  ; (dispatch callback target)
; --- Code Region ---
  LDA $04A1                             ; $C090: AD A1 04
  BNE $C09E                             ; $C093: D0 09
  LDA #$B7                              ; $C095: A9 B7
  JSR $C96D                             ; $C097: 20 6D C9
  INC $04A1                             ; $C09A: EE A1 04
  RTS                                   ; $C09D: 60
Loc_C09E:
  LDA #$54                              ; $C09E: A9 54
  STA $0010                             ; $C0A0: 8D 10 00
  LDA #$84                              ; $C0A3: A9 84
  STA $0011                             ; $C0A5: 8D 11 00
  LDY $04A1                             ; $C0A8: AC A1 04
  JSR $C994                             ; $C0AB: 20 94 C9
  LDA $04A1                             ; $C0AE: AD A1 04
  CMP #$03                              ; $C0B1: C9 03
  BEQ $C0C5                             ; $C0B3: F0 10
  LDA $04A3                             ; $C0B5: AD A3 04
  LSR                                   ; $C0B8: 4A
  LSR                                   ; $C0B9: 4A
  LSR                                   ; $C0BA: 4A
  LSR                                   ; $C0BB: 4A
  LSR                                   ; $C0BC: 4A
  AND #$03                              ; $C0BD: 29 03
  CLC                                   ; $C0BF: 18
  ADC #$01                              ; $C0C0: 69 01
  STA $04A1                             ; $C0C2: 8D A1 04
Loc_C0C5:
  JMP $C934                             ; $C0C5: 4C 34 C9
Loc_C0C8:  ; (dispatch callback target)
  LDA $04A1                             ; $C0C8: AD A1 04
  BNE $C0E7                             ; $C0CB: D0 1A
  LDA #$CA                              ; $C0CD: A9 CA
  JSR $C96D                             ; $C0CF: 20 6D C9
  INC $04A1                             ; $C0D2: EE A1 04
  LDA #$03                              ; $C0D5: A9 03
  STA $04A4                             ; $C0D7: 8D A4 04
  LDA $04D6                             ; $C0DA: AD D6 04
  CMP #$47                              ; $C0DD: C9 47
  BEQ $C0E6                             ; $C0DF: F0 05
  LDA #$80                              ; $C0E1: A9 80
  STA $04CC                             ; $C0E3: 8D CC 04
Loc_C0E6:
  RTS                                   ; $C0E6: 60
Loc_C0E7:
  LDA #$59                              ; $C0E7: A9 59
  STA $0010                             ; $C0E9: 8D 10 00
  LDA #$85                              ; $C0EC: A9 85
  STA $0011                             ; $C0EE: 8D 11 00
  LDY $04A1                             ; $C0F1: AC A1 04
  JSR $C994                             ; $C0F4: 20 94 C9
  LDY $04A4                             ; $C0F7: AC A4 04
  JSR $C994                             ; $C0FA: 20 94 C9
  LDA $04A3                             ; $C0FD: AD A3 04
  LSR                                   ; $C100: 4A
  LSR                                   ; $C101: 4A
  LSR                                   ; $C102: 4A
  STA $0000                             ; $C103: 8D 00 00
  LSR                                   ; $C106: 4A
  AND #$01                              ; $C107: 29 01
  CLC                                   ; $C109: 18
  ADC #$01                              ; $C10A: 69 01
  STA $04A1                             ; $C10C: 8D A1 04
  LDA $0000                             ; $C10F: AD 00 00
  AND #$03                              ; $C112: 29 03
  CMP #$03                              ; $C114: C9 03
  BNE $C11A                             ; $C116: D0 02
  LDA #$01                              ; $C118: A9 01
Loc_C11A:
  CLC                                   ; $C11A: 18
  ADC #$03                              ; $C11B: 69 03
  STA $04A4                             ; $C11D: 8D A4 04
  JMP $C934                             ; $C120: 4C 34 C9
Loc_C123:  ; (dispatch callback target)
  LDA $04A1                             ; $C123: AD A1 04
  BNE $C136                             ; $C126: D0 0E
  LDA #$F1                              ; $C128: A9 F1
  JSR $C96D                             ; $C12A: 20 6D C9
  LDA #$F2                              ; $C12D: A9 F2
  JSR $C98A                             ; $C12F: 20 8A C9
  INC $04A1                             ; $C132: EE A1 04
  RTS                                   ; $C135: 60
Loc_C136:
  LDA #$3C                              ; $C136: A9 3C
  STA $0010                             ; $C138: 8D 10 00
  LDA #$86                              ; $C13B: A9 86
  STA $0011                             ; $C13D: 8D 11 00
  LDY $04A1                             ; $C140: AC A1 04
  JSR $C994                             ; $C143: 20 94 C9
  LDA $04A3                             ; $C146: AD A3 04
  LSR                                   ; $C149: 4A
  LSR                                   ; $C14A: 4A
  LSR                                   ; $C14B: 4A
  AND #$0F                              ; $C14C: 29 0F
  TAY                                   ; $C14E: A8
  LDA $C158,Y                           ; $C14F: B9 58 C1
  STA $04A1                             ; $C152: 8D A1 04
  JMP $C934                             ; $C155: 4C 34 C9
; --- Data Region ---
  .byte $01,$02,$03,$03,$03,$04,$04,$04,$03,$03,$03,$04,$04,$04,$02,$01; $C158: 01 02 03 03 03 04 04 04 03 03 03 04 04 04 02 01
Loc_C168:  ; (dispatch callback target)
; --- Code Region ---
  LDA $04A1                             ; $C168: AD A1 04
  BNE $C17B                             ; $C16B: D0 0E
  LDA #$F0                              ; $C16D: A9 F0
  JSR $C96D                             ; $C16F: 20 6D C9
  INC $04A1                             ; $C172: EE A1 04
  LDA #$28                              ; $C175: A9 28
  STA $04A3                             ; $C177: 8D A3 04
  RTS                                   ; $C17A: 60
Loc_C17B:
  LDA #$60                              ; $C17B: A9 60
  STA $0010                             ; $C17D: 8D 10 00
  LDA #$87                              ; $C180: A9 87
  STA $0011                             ; $C182: 8D 11 00
  LDY $04A1                             ; $C185: AC A1 04
  JSR $C994                             ; $C188: 20 94 C9
  LDA $04A3                             ; $C18B: AD A3 04
  LSR                                   ; $C18E: 4A
  LSR                                   ; $C18F: 4A
  AND #$0F                              ; $C190: 29 0F
  TAY                                   ; $C192: A8
  LDA $C19C,Y                           ; $C193: B9 9C C1
  STA $04A1                             ; $C196: 8D A1 04
  JMP $C934                             ; $C199: 4C 34 C9
; --- Data Region ---
  .byte $01,$02,$03,$03,$03,$03,$03,$03,$02,$02,$02,$02,$01,$01,$01,$01; $C19C: 01 02 03 03 03 03 03 03 02 02 02 02 01 01 01 01
Loc_C1AC:  ; (dispatch callback target)
; --- Code Region ---
  LDA $04A1                             ; $C1AC: AD A1 04
  BNE $C1CA                             ; $C1AF: D0 19
  LDA #$E9                              ; $C1B1: A9 E9
  JSR $C96D                             ; $C1B3: 20 6D C9
  LDA #$EB                              ; $C1B6: A9 EB
  JSR $C98A                             ; $C1B8: 20 8A C9
  LDA #$C3                              ; $C1BB: A9 C3
  STA $00C1                             ; $C1BD: 8D C1 00
  STA $00C9                             ; $C1C0: 8D C9 00
  STA $00D1                             ; $C1C3: 8D D1 00
  INC $04A1                             ; $C1C6: EE A1 04
  RTS                                   ; $C1C9: 60
Loc_C1CA:
  LDA #$D1                              ; $C1CA: A9 D1
  STA $0010                             ; $C1CC: 8D 10 00
  LDA #$87                              ; $C1CF: A9 87
  STA $0011                             ; $C1D1: 8D 11 00
  LDY $04A1                             ; $C1D4: AC A1 04
  JSR $C994                             ; $C1D7: 20 94 C9
  LDY #$04                              ; $C1DA: A0 04
  JSR $C994                             ; $C1DC: 20 94 C9
  LDA $04A3                             ; $C1DF: AD A3 04
  LSR                                   ; $C1E2: 4A
  LSR                                   ; $C1E3: 4A
  LSR                                   ; $C1E4: 4A
  LSR                                   ; $C1E5: 4A
  AND #$07                              ; $C1E6: 29 07
  TAY                                   ; $C1E8: A8
  LDA $C1F2,Y                           ; $C1E9: B9 F2 C1
  STA $04A1                             ; $C1EC: 8D A1 04
  JMP $C934                             ; $C1EF: 4C 34 C9
; --- Data Region ---
  .byte $02,$03,$02,$03,$01,$01,$01,$01   ; $C1F2: 02 03 02 03 01 01 01 01
Loc_C1FA:  ; (dispatch callback target)
; --- Code Region ---
  LDA $04A1                             ; $C1FA: AD A1 04
  BNE $C218                             ; $C1FD: D0 19
  LDA #$F8                              ; $C1FF: A9 F8
  JSR $C96D                             ; $C201: 20 6D C9
  LDA #$F9                              ; $C204: A9 F9
  JSR $C98A                             ; $C206: 20 8A C9
  LDA #$FA                              ; $C209: A9 FA
  STA $00C1                             ; $C20B: 8D C1 00
  STA $00C9                             ; $C20E: 8D C9 00
  STA $00D1                             ; $C211: 8D D1 00
  INC $04A1                             ; $C214: EE A1 04
  RTS                                   ; $C217: 60
Loc_C218:
  LDA #$D5                              ; $C218: A9 D5
  STA $0010                             ; $C21A: 8D 10 00
  LDA #$88                              ; $C21D: A9 88
  STA $0011                             ; $C21F: 8D 11 00
  LDY $04A1                             ; $C222: AC A1 04
  JSR $C994                             ; $C225: 20 94 C9
  LDA $04A3                             ; $C228: AD A3 04
  LSR                                   ; $C22B: 4A
  LSR                                   ; $C22C: 4A
  LSR                                   ; $C22D: 4A
  AND #$0F                              ; $C22E: 29 0F
  TAY                                   ; $C230: A8
  CMP #$0A                              ; $C231: C9 0A
  BNE $C23A                             ; $C233: D0 05
  LDA #$00                              ; $C235: A9 00
  STA $04A3                             ; $C237: 8D A3 04
Loc_C23A:
  LDA $C252,Y                           ; $C23A: B9 52 C2
  STA $04A1                             ; $C23D: 8D A1 04
  LDA $04A3                             ; $C240: AD A3 04
  LSR                                   ; $C243: 4A
  LSR                                   ; $C244: 4A
  LSR                                   ; $C245: 4A
  AND #$01                              ; $C246: 29 01
  CLC                                   ; $C248: 18
  ADC #$05                              ; $C249: 69 05
  TAY                                   ; $C24B: A8
  JSR $C994                             ; $C24C: 20 94 C9
  JMP $C934                             ; $C24F: 4C 34 C9
; --- Data Region ---
  .byte $01,$02,$03,$04,$04,$03,$04,$04,$03,$02,$01; $C252: 01 02 03 04 04 03 04 04 03 02 01
Loc_C25D:  ; (dispatch callback target)
; --- Code Region ---
  LDA $04A1                             ; $C25D: AD A1 04
  BNE $C28A                             ; $C260: D0 28
  LDA #$F7                              ; $C262: A9 F7
  JSR $C96D                             ; $C264: 20 6D C9
  INC $04A1                             ; $C267: EE A1 04
  LDY #$00                              ; $C26A: A0 00
  LDX #$00                              ; $C26C: A2 00
  LDA $0150                             ; $C26E: AD 50 01
  BPL $C275                             ; $C271: 10 02
  LDX #$0D                              ; $C273: A2 0D
Loc_C275:
  LDA $C2C3,X                           ; $C275: BD C3 C2
  STA $0380,Y                           ; $C278: 99 80 03
  INX                                   ; $C27B: E8
  INY                                   ; $C27C: C8
  CPY #$0D                              ; $C27D: C0 0D
  BCC $C275                             ; $C27F: 90 F4
  LDA $007E                             ; $C281: AD 7E 00
  ORA #$04                              ; $C284: 09 04
  STA $007E                             ; $C286: 8D 7E 00
  RTS                                   ; $C289: 60
Loc_C28A:
  LDA #$B7                              ; $C28A: A9 B7
  STA $0010                             ; $C28C: 8D 10 00
  LDA #$89                              ; $C28F: A9 89
  STA $0011                             ; $C291: 8D 11 00
  LDY $04A1                             ; $C294: AC A1 04
  JSR $C994                             ; $C297: 20 94 C9
  LDA $04A3                             ; $C29A: AD A3 04
  LSR                                   ; $C29D: 4A
  LSR                                   ; $C29E: 4A
  LSR                                   ; $C29F: 4A
  LSR                                   ; $C2A0: 4A
  STA $0000                             ; $C2A1: 8D 00 00
  AND #$03                              ; $C2A4: 29 03
  CMP #$03                              ; $C2A6: C9 03
  BNE $C2AC                             ; $C2A8: D0 02
  LDA #$01                              ; $C2AA: A9 01
Loc_C2AC:
  STA $04A1                             ; $C2AC: 8D A1 04
  INC $04A1                             ; $C2AF: EE A1 04
  LDY #$04                              ; $C2B2: A0 04
  LDA $0000                             ; $C2B4: AD 00 00
  AND #$02                              ; $C2B7: 29 02
  BEQ $C2BD                             ; $C2B9: F0 02
  LDY #$05                              ; $C2BB: A0 05
Loc_C2BD:
  JSR $C994                             ; $C2BD: 20 94 C9
  JMP $C934                             ; $C2C0: 4C 34 C9
; --- Data Region ---
  .byte $03,$23,$D1,$0F,$0F,$8B,$03,$23,$D9,$00,$00,$88,$FF,$03,$23,$D4; $C2C3: 03 23 D1 0F 0F 8B 03 23 D9 00 00 88 FF 03 23 D4
  .byte $2E,$0F,$0F,$03,$23,$DC,$22,$00,$00,$FF; $C2D3: 2E 0F 0F 03 23 DC 22 00 00 FF
Loc_C2DD:  ; (dispatch callback target)
; --- Code Region ---
  LDA $04A1                             ; $C2DD: AD A1 04
  BNE $C2F0                             ; $C2E0: D0 0E
  LDA #$F3                              ; $C2E2: A9 F3
  JSR $C96D                             ; $C2E4: 20 6D C9
  LDA #$F4                              ; $C2E7: A9 F4
  JSR $C98A                             ; $C2E9: 20 8A C9
  INC $04A1                             ; $C2EC: EE A1 04
  RTS                                   ; $C2EF: 60
; --- Data Region ---
  .byte $A9,$52,$8D,$10,$00,$A9,$8A,$8D,$11,$00,$AC,$A1,$04,$20,$94,$C9; $C2F0: A9 52 8D 10 00 A9 8A 8D 11 00 AC A1 04 20 94 C9
  .byte $AD,$A3,$04,$4A,$4A,$4A,$8D,$00,$00,$29,$0F,$A8,$C9,$0A,$D0,$05; $C300: AD A3 04 4A 4A 4A 8D 00 00 29 0F A8 C9 0A D0 05
  .byte $A9,$00,$8D,$A3,$04               ; $C310: A9 00 8D A3 04
Loc_C315:
; --- Code Region ---
  LDA $C332,Y                           ; $C315: B9 32 C3
  STA $04A1                             ; $C318: 8D A1 04
  LDY #$01                              ; $C31B: A0 01
  LDA $0000                             ; $C31D: AD 00 00
  AND #$0F                              ; $C320: 29 0F
  CMP #$05                              ; $C322: C9 05
  BCS $C32C                             ; $C324: B0 06
  AND #$01                              ; $C326: 29 01
  BEQ $C32C                             ; $C328: F0 02
  LDY #$02                              ; $C32A: A0 02
Loc_C32C:
  JSR $C994                             ; $C32C: 20 94 C9
  JMP $C934                             ; $C32F: 4C 34 C9
; --- Data Region ---
  .byte $03,$03,$03,$03,$03,$03,$04,$05,$05,$04,$03; $C332: 03 03 03 03 03 03 04 05 05 04 03
Loc_C33D:  ; (dispatch callback target)
; --- Code Region ---
  LDA $04A1                             ; $C33D: AD A1 04
  BNE $C350                             ; $C340: D0 0E
  LDA #$F0                              ; $C342: A9 F0
  JSR $C96D                             ; $C344: 20 6D C9
  INC $04A1                             ; $C347: EE A1 04
  LDA #$20                              ; $C34A: A9 20
  STA $04A4                             ; $C34C: 8D A4 04
  RTS                                   ; $C34F: 60
Loc_C350:
  INC $04A5                             ; $C350: EE A5 04
  LDA #$55                              ; $C353: A9 55
  STA $0010                             ; $C355: 8D 10 00
  LDA #$8B                              ; $C358: A9 8B
  STA $0011                             ; $C35A: 8D 11 00
  LDY $04A1                             ; $C35D: AC A1 04
  LDX $04A4                             ; $C360: AE A4 04
  JSR $C996                             ; $C363: 20 96 C9
  LDA $04A3                             ; $C366: AD A3 04
  LSR                                   ; $C369: 4A
  LSR                                   ; $C36A: 4A
  LSR                                   ; $C36B: 4A
  LSR                                   ; $C36C: 4A
  STA $0000                             ; $C36D: 8D 00 00
  AND #$03                              ; $C370: 29 03
  CMP #$03                              ; $C372: C9 03
  BNE $C378                             ; $C374: D0 02
  LDA #$01                              ; $C376: A9 01
Loc_C378:
  CLC                                   ; $C378: 18
  ADC #$01                              ; $C379: 69 01
  CMP $04A1                             ; $C37B: CD A1 04
  BEQ $C383                             ; $C37E: F0 03
  DEC $04A4                             ; $C380: CE A4 04
Loc_C383:
  STA $04A1                             ; $C383: 8D A1 04
  LDA $04A5                             ; $C386: AD A5 04
  LSR                                   ; $C389: 4A
  LSR                                   ; $C38A: 4A
  LSR                                   ; $C38B: 4A
  LSR                                   ; $C38C: 4A
  AND #$03                              ; $C38D: 29 03
  CMP #$03                              ; $C38F: C9 03
  BNE $C398                             ; $C391: D0 05
  LDA #$00                              ; $C393: A9 00
  STA $04A5                             ; $C395: 8D A5 04
Loc_C398:
  CLC                                   ; $C398: 18
  ADC #$04                              ; $C399: 69 04
  TAY                                   ; $C39B: A8
  JSR $C994                             ; $C39C: 20 94 C9
  JMP $C934                             ; $C39F: 4C 34 C9
Loc_C3A2:  ; (dispatch callback target)
  LDA $04A1                             ; $C3A2: AD A1 04
  BNE $C3BA                             ; $C3A5: D0 13
  LDA #$D0                              ; $C3A7: A9 D0
  JSR $C96D                             ; $C3A9: 20 6D C9
  LDA #$D1                              ; $C3AC: A9 D1
  JSR $C98A                             ; $C3AE: 20 8A C9
  INC $04A1                             ; $C3B1: EE A1 04
  LDA #$20                              ; $C3B4: A9 20
  STA $04A5                             ; $C3B6: 8D A5 04
  RTS                                   ; $C3B9: 60
Loc_C3BA:
  LDA #$03                              ; $C3BA: A9 03
  STA $0010                             ; $C3BC: 8D 10 00
  LDA #$8C                              ; $C3BF: A9 8C
  STA $0011                             ; $C3C1: 8D 11 00
  LDY $04A1                             ; $C3C4: AC A1 04
  JSR $C994                             ; $C3C7: 20 94 C9
  LDY #$05                              ; $C3CA: A0 05
  LDX $04A5                             ; $C3CC: AE A5 04
  JSR $C996                             ; $C3CF: 20 96 C9
  LDA $04A3                             ; $C3D2: AD A3 04
  LSR                                   ; $C3D5: 4A
  LSR                                   ; $C3D6: 4A
  LSR                                   ; $C3D7: 4A
  AND #$03                              ; $C3D8: 29 03
  CLC                                   ; $C3DA: 18
  ADC #$01                              ; $C3DB: 69 01
  STA $04A1                             ; $C3DD: 8D A1 04
  LDA $04A3                             ; $C3E0: AD A3 04
  AND #$0F                              ; $C3E3: 29 0F
  CMP #$08                              ; $C3E5: C9 08
  BNE $C3F3                             ; $C3E7: D0 0A
  LDA $04A3                             ; $C3E9: AD A3 04
  AND #$10                              ; $C3EC: 29 10
  BEQ $C3F3                             ; $C3EE: F0 03
  DEC $04A5                             ; $C3F0: CE A5 04
Loc_C3F3:
  JMP $C934                             ; $C3F3: 4C 34 C9
Loc_C3F6:  ; (dispatch callback target)
  LDA $04A1                             ; $C3F6: AD A1 04
  BNE $C414                             ; $C3F9: D0 19
  LDA #$F5                              ; $C3FB: A9 F5
  JSR $C96D                             ; $C3FD: 20 6D C9
  LDA #$F7                              ; $C400: A9 F7
  JSR $C98A                             ; $C402: 20 8A C9
  LDA #$D7                              ; $C405: A9 D7
  STA $00C1                             ; $C407: 8D C1 00
  STA $00C9                             ; $C40A: 8D C9 00
  STA $00D1                             ; $C40D: 8D D1 00
  INC $04A1                             ; $C410: EE A1 04
  RTS                                   ; $C413: 60
Loc_C414:
  LDA #$2E                              ; $C414: A9 2E
  STA $0010                             ; $C416: 8D 10 00
  LDA #$8D                              ; $C419: A9 8D
  STA $0011                             ; $C41B: 8D 11 00
  LDY $04A1                             ; $C41E: AC A1 04
  JSR $C994                             ; $C421: 20 94 C9
  LDA $04A3                             ; $C424: AD A3 04
  LSR                                   ; $C427: 4A
  LSR                                   ; $C428: 4A
  LSR                                   ; $C429: 4A
  AND #$07                              ; $C42A: 29 07
  TAY                                   ; $C42C: A8
  LDA $C436,Y                           ; $C42D: B9 36 C4
  STA $04A1                             ; $C430: 8D A1 04
  JMP $C934                             ; $C433: 4C 34 C9
; --- Data Region ---
  .byte $01,$02,$03,$03,$03,$03,$02,$01   ; $C436: 01 02 03 03 03 03 02 01
Loc_C43E:  ; (dispatch callback target)
; --- Code Region ---
  LDA $04A1                             ; $C43E: AD A1 04
  BNE $C47A                             ; $C441: D0 37
  LDA #$F8                              ; $C443: A9 F8
  JSR $C96D                             ; $C445: 20 6D C9
  LDA #$FA                              ; $C448: A9 FA
  JSR $C98A                             ; $C44A: 20 8A C9
  LDA #$00                              ; $C44D: A9 00
  STA $04A3                             ; $C44F: 8D A3 04
  STA $04A4                             ; $C452: 8D A4 04
  LDA #$05                              ; $C455: A9 05
  STA $04A1                             ; $C457: 8D A1 04
  LDY #$00                              ; $C45A: A0 00
  LDX #$00                              ; $C45C: A2 00
  LDA $0150                             ; $C45E: AD 50 01
  BPL $C465                             ; $C461: 10 02
  LDX #$10                              ; $C463: A2 10
Loc_C465:
  LDA $C4C1,X                           ; $C465: BD C1 C4
  STA $0380,Y                           ; $C468: 99 80 03
  INX                                   ; $C46B: E8
  INY                                   ; $C46C: C8
  CPY #$10                              ; $C46D: C0 10
  BCC $C465                             ; $C46F: 90 F4
  LDA $007E                             ; $C471: AD 7E 00
  ORA #$04                              ; $C474: 09 04
  STA $007E                             ; $C476: 8D 7E 00
  RTS                                   ; $C479: 60
Loc_C47A:
  LDA #$37                              ; $C47A: A9 37
  STA $0010                             ; $C47C: 8D 10 00
  LDA #$8E                              ; $C47F: A9 8E
  STA $0011                             ; $C481: 8D 11 00
  LDY $04A1                             ; $C484: AC A1 04
  JSR $C994                             ; $C487: 20 94 C9
  LDA $04A3                             ; $C48A: AD A3 04
  BPL $C494                             ; $C48D: 10 05
  LDA #$06                              ; $C48F: A9 06
  STA $04A1                             ; $C491: 8D A1 04
Loc_C494:
  INC $04A4                             ; $C494: EE A4 04
  LDA $04A4                             ; $C497: AD A4 04
  BMI $C4A1                             ; $C49A: 30 05
  LDY #$01                              ; $C49C: A0 01
  JMP $C4AC                             ; $C49E: 4C AC C4
Loc_C4A1:
  CMP #$85                              ; $C4A1: C9 85
  BCC $C4AA                             ; $C4A3: 90 05
  LDA #$00                              ; $C4A5: A9 00
  STA $04A4                             ; $C4A7: 8D A4 04
Loc_C4AA:
  LDY #$02                              ; $C4AA: A0 02
Loc_C4AC:
  JSR $C994                             ; $C4AC: 20 94 C9
  LDA $04A3                             ; $C4AF: AD A3 04
  LSR                                   ; $C4B2: 4A
  LSR                                   ; $C4B3: 4A
  LSR                                   ; $C4B4: 4A
  AND #$01                              ; $C4B5: 29 01
  CLC                                   ; $C4B7: 18
  ADC #$03                              ; $C4B8: 69 03
  TAY                                   ; $C4BA: A8
  JSR $C994                             ; $C4BB: 20 94 C9
  JMP $C934                             ; $C4BE: 4C 34 C9
; --- Data Region ---
  .byte $02,$23,$C9,$AA,$FA,$02,$23,$D1,$AF,$FF,$02,$23,$D9,$AA,$FF,$FF; $C4C1: 02 23 C9 AA FA 02 23 D1 AF FF 02 23 D9 AA FF FF
  .byte $02,$23,$CC,$AA,$EA,$02,$23,$D4,$AE,$EF,$02,$23,$DC,$AA,$EE,$FF; $C4D1: 02 23 CC AA EA 02 23 D4 AE EF 02 23 DC AA EE FF
Loc_C4E1:  ; (dispatch callback target)
; --- Code Region ---
  LDA $04A1                             ; $C4E1: AD A1 04
  BNE $C4EF                             ; $C4E4: D0 09
  LDA #$E7                              ; $C4E6: A9 E7
  JSR $C96D                             ; $C4E8: 20 6D C9
  INC $04A1                             ; $C4EB: EE A1 04
  RTS                                   ; $C4EE: 60
Loc_C4EF:
  LDA #$DD                              ; $C4EF: A9 DD
  STA $0010                             ; $C4F1: 8D 10 00
  LDA #$8E                              ; $C4F4: A9 8E
  STA $0011                             ; $C4F6: 8D 11 00
  LDY $04A1                             ; $C4F9: AC A1 04
  JSR $C994                             ; $C4FC: 20 94 C9
  LDA $04A3                             ; $C4FF: AD A3 04
  LSR                                   ; $C502: 4A
  LSR                                   ; $C503: 4A
  LSR                                   ; $C504: 4A
  LSR                                   ; $C505: 4A
  AND #$01                              ; $C506: 29 01
  CLC                                   ; $C508: 18
  ADC #$01                              ; $C509: 69 01
  STA $04A1                             ; $C50B: 8D A1 04
  JMP $C934                             ; $C50E: 4C 34 C9
Loc_C511:  ; (dispatch callback target)
  LDA $04A1                             ; $C511: AD A1 04
  BNE $C524                             ; $C514: D0 0E
  LDA #$FB                              ; $C516: A9 FB
  JSR $C96D                             ; $C518: 20 6D C9
  LDA #$FC                              ; $C51B: A9 FC
  JSR $C98A                             ; $C51D: 20 8A C9
  INC $04A1                             ; $C520: EE A1 04
  RTS                                   ; $C523: 60
Loc_C524:
  LDA #$6B                              ; $C524: A9 6B
  STA $0010                             ; $C526: 8D 10 00
  LDA #$8F                              ; $C529: A9 8F
  STA $0011                             ; $C52B: 8D 11 00
  LDY $04A1                             ; $C52E: AC A1 04
  JSR $C994                             ; $C531: 20 94 C9
  LDA $04A3                             ; $C534: AD A3 04
  LSR                                   ; $C537: 4A
  LSR                                   ; $C538: 4A
  LSR                                   ; $C539: 4A
  AND #$0F                              ; $C53A: 29 0F
  TAY                                   ; $C53C: A8
  LDA $C546,Y                           ; $C53D: B9 46 C5
  STA $04A1                             ; $C540: 8D A1 04
  JMP $C934                             ; $C543: 4C 34 C9
; --- Data Region ---
  .byte $01,$03,$01,$03,$02,$03,$01,$03,$02,$01,$01,$04,$04,$04,$04,$04; $C546: 01 03 01 03 02 03 01 03 02 01 01 04 04 04 04 04
Loc_C556:  ; (dispatch callback target)
; --- Code Region ---
  LDA $04A1                             ; $C556: AD A1 04
  BNE $C579                             ; $C559: D0 1E
  LDA #$EA                              ; $C55B: A9 EA
  JSR $C96D                             ; $C55D: 20 6D C9
  LDA #$EB                              ; $C560: A9 EB
  JSR $C98A                             ; $C562: 20 8A C9
  LDA #$ED                              ; $C565: A9 ED
  STA $00C1                             ; $C567: 8D C1 00
  STA $00C9                             ; $C56A: 8D C9 00
  STA $00D1                             ; $C56D: 8D D1 00
  INC $04A1                             ; $C570: EE A1 04
  LDA #$20                              ; $C573: A9 20
  STA $04A5                             ; $C575: 8D A5 04
  RTS                                   ; $C578: 60
Loc_C579:
  LDA #$77                              ; $C579: A9 77
  STA $0010                             ; $C57B: 8D 10 00
  LDA #$90                              ; $C57E: A9 90
  STA $0011                             ; $C580: 8D 11 00
  LDX $04A5                             ; $C583: AE A5 04
  LDY $04A1                             ; $C586: AC A1 04
  JSR $C996                             ; $C589: 20 96 C9
  LDA $04A3                             ; $C58C: AD A3 04
  LSR                                   ; $C58F: 4A
  LSR                                   ; $C590: 4A
  LSR                                   ; $C591: 4A
  AND #$03                              ; $C592: 29 03
  CMP #$03                              ; $C594: C9 03
  BNE $C59D                             ; $C596: D0 05
  LDA #$00                              ; $C598: A9 00
  STA $04A3                             ; $C59A: 8D A3 04
Loc_C59D:
  CLC                                   ; $C59D: 18
  ADC #$01                              ; $C59E: 69 01
  STA $04A1                             ; $C5A0: 8D A1 04
  CMP $04A4                             ; $C5A3: CD A4 04
  BEQ $C5AE                             ; $C5A6: F0 06
  STA $04A4                             ; $C5A8: 8D A4 04
  DEC $04A5                             ; $C5AB: CE A5 04
Loc_C5AE:
  JMP $C934                             ; $C5AE: 4C 34 C9
Loc_C5B1:  ; (dispatch callback target)
  LDA $04A1                             ; $C5B1: AD A1 04
  BNE $C5C4                             ; $C5B4: D0 0E
  LDA #$F6                              ; $C5B6: A9 F6
  JSR $C96D                             ; $C5B8: 20 6D C9
  INC $04A1                             ; $C5BB: EE A1 04
  LDA #$03                              ; $C5BE: A9 03
  STA $04A4                             ; $C5C0: 8D A4 04
  RTS                                   ; $C5C3: 60
Loc_C5C4:
  LDA #$40                              ; $C5C4: A9 40
  STA $0010                             ; $C5C6: 8D 10 00
  LDA #$91                              ; $C5C9: A9 91
  STA $0011                             ; $C5CB: 8D 11 00
  LDY $04A1                             ; $C5CE: AC A1 04
  JSR $C994                             ; $C5D1: 20 94 C9
  LDY $04A4                             ; $C5D4: AC A4 04
  JSR $C994                             ; $C5D7: 20 94 C9
  LDA $04A3                             ; $C5DA: AD A3 04
  LSR                                   ; $C5DD: 4A
  LSR                                   ; $C5DE: 4A
  LSR                                   ; $C5DF: 4A
  AND #$01                              ; $C5E0: 29 01
  CLC                                   ; $C5E2: 18
  ADC #$01                              ; $C5E3: 69 01
  STA $04A1                             ; $C5E5: 8D A1 04
  LDA $04A3                             ; $C5E8: AD A3 04
  AND #$40                              ; $C5EB: 29 40
  BEQ $C5F4                             ; $C5ED: F0 05
  LDA #$04                              ; $C5EF: A9 04
  STA $04A4                             ; $C5F1: 8D A4 04
Loc_C5F4:
  JMP $C934                             ; $C5F4: 4C 34 C9
Loc_C5F7:  ; (dispatch callback target)
  LDA $04A1                             ; $C5F7: AD A1 04
  BNE $C60A                             ; $C5FA: D0 0E
  LDA #$F7                              ; $C5FC: A9 F7
  JSR $C96D                             ; $C5FE: 20 6D C9
  LDA #$DF                              ; $C601: A9 DF
  JSR $C98A                             ; $C603: 20 8A C9
  INC $04A1                             ; $C606: EE A1 04
  RTS                                   ; $C609: 60
Loc_C60A:
  LDA #$DC                              ; $C60A: A9 DC
  STA $0010                             ; $C60C: 8D 10 00
  LDA #$91                              ; $C60F: A9 91
  STA $0011                             ; $C611: 8D 11 00
  LDY $04A1                             ; $C614: AC A1 04
  JSR $C994                             ; $C617: 20 94 C9
  LDA $04A1                             ; $C61A: AD A1 04
  CLC                                   ; $C61D: 18
  ADC #$02                              ; $C61E: 69 02
  TAY                                   ; $C620: A8
  JSR $C994                             ; $C621: 20 94 C9
  LDA $04A3                             ; $C624: AD A3 04
  LSR                                   ; $C627: 4A
  LSR                                   ; $C628: 4A
  LSR                                   ; $C629: 4A
  LSR                                   ; $C62A: 4A
  AND #$01                              ; $C62B: 29 01
  CLC                                   ; $C62D: 18
  ADC #$01                              ; $C62E: 69 01
  STA $04A1                             ; $C630: 8D A1 04
  JMP $C934                             ; $C633: 4C 34 C9
Loc_C636:  ; (dispatch callback target)
  LDA $04A1                             ; $C636: AD A1 04
  BNE $C644                             ; $C639: D0 09
  LDA #$C5                              ; $C63B: A9 C5
  JSR $C96D                             ; $C63D: 20 6D C9
  INC $04A1                             ; $C640: EE A1 04
  RTS                                   ; $C643: 60
Loc_C644:
  LDA #$A0                              ; $C644: A9 A0
  STA $0010                             ; $C646: 8D 10 00
  LDA #$92                              ; $C649: A9 92
  STA $0011                             ; $C64B: 8D 11 00
  LDY $04A1                             ; $C64E: AC A1 04
  JSR $C994                             ; $C651: 20 94 C9
  LDA $04A1                             ; $C654: AD A1 04
  CLC                                   ; $C657: 18
  ADC #$02                              ; $C658: 69 02
  TAY                                   ; $C65A: A8
  JSR $C994                             ; $C65B: 20 94 C9
  LDA $04A3                             ; $C65E: AD A3 04
  ROL                                   ; $C661: 2A
  ROL                                   ; $C662: 2A
  ROL                                   ; $C663: 2A
  ROL                                   ; $C664: 2A
  AND #$01                              ; $C665: 29 01
  CLC                                   ; $C667: 18
  ADC #$03                              ; $C668: 69 03
  STA $04A1                             ; $C66A: 8D A1 04
  LDY #$01                              ; $C66D: A0 01
  LDA $04A3                             ; $C66F: AD A3 04
  CMP #$60                              ; $C672: C9 60
  BCC $C677                             ; $C674: 90 01
  INY                                   ; $C676: C8
Loc_C677:
  JSR $C994                             ; $C677: 20 94 C9
  JMP $C934                             ; $C67A: 4C 34 C9
Loc_C67D:  ; (dispatch callback target)
  LDA $04A1                             ; $C67D: AD A1 04
  BNE $C69B                             ; $C680: D0 19
  LDA #$F4                              ; $C682: A9 F4
  JSR $C96D                             ; $C684: 20 6D C9
  LDA #$F5                              ; $C687: A9 F5
  JSR $C98A                             ; $C689: 20 8A C9
  LDA #$D4                              ; $C68C: A9 D4
  STA $00C1                             ; $C68E: 8D C1 00
  STA $00C9                             ; $C691: 8D C9 00
  STA $00D1                             ; $C694: 8D D1 00
  INC $04A1                             ; $C697: EE A1 04
  RTS                                   ; $C69A: 60
Loc_C69B:
  LDA #$42                              ; $C69B: A9 42
  STA $0010                             ; $C69D: 8D 10 00
  LDA #$93                              ; $C6A0: A9 93
  STA $0011                             ; $C6A2: 8D 11 00
  LDY $04A1                             ; $C6A5: AC A1 04
  JSR $C994                             ; $C6A8: 20 94 C9
  LDA $04A3                             ; $C6AB: AD A3 04
  LSR                                   ; $C6AE: 4A
  LSR                                   ; $C6AF: 4A
  LSR                                   ; $C6B0: 4A
  LSR                                   ; $C6B1: 4A
  AND #$07                              ; $C6B2: 29 07
  TAY                                   ; $C6B4: A8
  LDA $C6BE,Y                           ; $C6B5: B9 BE C6
  STA $04A1                             ; $C6B8: 8D A1 04
  JMP $C934                             ; $C6BB: 4C 34 C9
; --- Data Region ---
  .byte $01,$02,$01,$02,$01,$03,$03,$03   ; $C6BE: 01 02 01 02 01 03 03 03
Loc_C6C6:  ; (dispatch callback target)
; --- Code Region ---
  LDA $04A1                             ; $C6C6: AD A1 04
  BNE $C6FD                             ; $C6C9: D0 32
  LDA #$C1                              ; $C6CB: A9 C1
  JSR $C96D                             ; $C6CD: 20 6D C9
  INC $04A1                             ; $C6D0: EE A1 04
  LDA #$01                              ; $C6D3: A9 01
  STA $04A4                             ; $C6D5: 8D A4 04
  LDA #$20                              ; $C6D8: A9 20
  STA $04A5                             ; $C6DA: 8D A5 04
  LDY #$00                              ; $C6DD: A0 00
  LDX #$00                              ; $C6DF: A2 00
  LDA $0150                             ; $C6E1: AD 50 01
  BPL $C6E8                             ; $C6E4: 10 02
  LDX #$13                              ; $C6E6: A2 13
Loc_C6E8:
  LDA $C739,X                           ; $C6E8: BD 39 C7
  STA $0380,Y                           ; $C6EB: 99 80 03
  INX                                   ; $C6EE: E8
  INY                                   ; $C6EF: C8
  CPY #$13                              ; $C6F0: C0 13
  BCC $C6E8                             ; $C6F2: 90 F4
  LDA $007E                             ; $C6F4: AD 7E 00
  ORA #$04                              ; $C6F7: 09 04
  STA $007E                             ; $C6F9: 8D 7E 00
  RTS                                   ; $C6FC: 60
Loc_C6FD:
  LDA #$77                              ; $C6FD: A9 77
  STA $0010                             ; $C6FF: 8D 10 00
  LDA #$94                              ; $C702: A9 94
  STA $0011                             ; $C704: 8D 11 00
  LDX $04A5                             ; $C707: AE A5 04
  LDY $04A1                             ; $C70A: AC A1 04
  JSR $C996                             ; $C70D: 20 96 C9
  LDA $04A3                             ; $C710: AD A3 04
  LSR                                   ; $C713: 4A
  LSR                                   ; $C714: 4A
  LSR                                   ; $C715: 4A
  LSR                                   ; $C716: 4A
  STA $0000                             ; $C717: 8D 00 00
  AND #$07                              ; $C71A: 29 07
  TAY                                   ; $C71C: A8
  LDA $C731,Y                           ; $C71D: B9 31 C7
  STA $04A1                             ; $C720: 8D A1 04
  CMP $04A4                             ; $C723: CD A4 04
  BEQ $C72E                             ; $C726: F0 06
  STA $04A4                             ; $C728: 8D A4 04
  DEC $04A5                             ; $C72B: CE A5 04
Loc_C72E:
  JMP $C934                             ; $C72E: 4C 34 C9
; --- Data Region ---
  .byte $01,$02,$03,$04,$01,$02,$05,$06,$03,$23,$C9,$FA,$FA,$BA,$03,$23; $C731: 01 02 03 04 01 02 05 06 03 23 C9 FA FA BA 03 23
  .byte $D1,$0F,$0F,$8B,$03,$23,$D9,$50,$50,$98,$FF,$03,$23,$CC,$EA,$FA; $C741: D1 0F 0F 8B 03 23 D9 50 50 98 FF 03 23 CC EA FA
  .byte $FA,$03,$23,$D4,$2E,$0F,$0F,$03,$23,$DC,$62,$50,$50,$FF; $C751: FA 03 23 D4 2E 0F 0F 03 23 DC 62 50 50 FF
Loc_C75F:  ; (dispatch callback target)
; --- Code Region ---
  LDA $04A1                             ; $C75F: AD A1 04
  BNE $C78C                             ; $C762: D0 28
  LDA #$FC                              ; $C764: A9 FC
  JSR $C96D                             ; $C766: 20 6D C9
  INC $04A1                             ; $C769: EE A1 04
  LDY #$00                              ; $C76C: A0 00
  LDX #$00                              ; $C76E: A2 00
  LDA $0150                             ; $C770: AD 50 01
  BPL $C777                             ; $C773: 10 02
  LDX #$0D                              ; $C775: A2 0D
Loc_C777:
  LDA $C7B7,X                           ; $C777: BD B7 C7
  STA $0380,Y                           ; $C77A: 99 80 03
  INX                                   ; $C77D: E8
  INY                                   ; $C77E: C8
  CPY #$0D                              ; $C77F: C0 0D
  BCC $C777                             ; $C781: 90 F4
  LDA $007E                             ; $C783: AD 7E 00
  ORA #$04                              ; $C786: 09 04
  STA $007E                             ; $C788: 8D 7E 00
  RTS                                   ; $C78B: 60
; --- Data Region ---
  .byte $A9,$91,$8D,$10,$00,$A9,$96,$8D,$11,$00,$AC,$A1,$04,$20; $C78C: A9 91 8D 10 00 A9 96 8D 11 00 AC A1 04 20
Loc_C79A:
; --- Code Region ---
  STY $C9,X                             ; $C79A: 94 C9
  LDA $04A3                             ; $C79C: AD A3 04
  LSR                                   ; $C79F: 4A
  LSR                                   ; $C7A0: 4A
  LSR                                   ; $C7A1: 4A
  LSR                                   ; $C7A2: 4A
  AND #$03                              ; $C7A3: 29 03
  CMP #$03                              ; $C7A5: C9 03
  BNE $C7AE                             ; $C7A7: D0 05
  LDA #$00                              ; $C7A9: A9 00
  STA $04A3                             ; $C7AB: 8D A3 04
Loc_C7AE:
  CLC                                   ; $C7AE: 18
  ADC #$01                              ; $C7AF: 69 01
  STA $04A1                             ; $C7B1: 8D A1 04
  JMP $C934                             ; $C7B4: 4C 34 C9
; --- Data Region ---
  .byte $03,$23,$C9,$0A,$0A,$8A,$03,$23,$D1; $C7B7: 03 23 C9 0A 0A 8A 03 23 D1
Loc_C7C0:
; --- Code Region ---
  BEQ $C7B2                             ; $C7C0: F0 F0
  CLV                                   ; $C7C2: B8
  ISB $2303,X                           ; $C7C3: FF 03 23
  CPY $0A2A                             ; $C7C6: CC 2A 0A
  ASL                                   ; $C7C9: 0A
  SLO ($23,X)                           ; $C7CA: 03 23
  NOP $E2,X                             ; $C7CC: D4 E2
  BEQ $C7C0                             ; $C7CE: F0 F0
  ISB $A1AD,X                           ; $C7D0: FF AD A1
  NOP $D0                               ; $C7D3: 04 D0
  ORA #$A9                              ; $C7D5: 09 A9
  NOP #$20                              ; $C7D7: C2 20
  ADC $EEC9                             ; $C7D9: 6D C9 EE
  LDA ($04,X)                           ; $C7DC: A1 04
  RTS                                   ; $C7DE: 60
; --- Data Region ---
  .byte $A9,$33,$8D,$10,$00,$A9,$97,$8D,$11,$00,$AC,$A1,$04,$20,$94,$C9; $C7DF: A9 33 8D 10 00 A9 97 8D 11 00 AC A1 04 20 94 C9
  .byte $AD,$A3,$04,$4A,$4A,$4A,$29,$01,$18,$69,$01,$8D,$A1,$04,$4C,$34; $C7EF: AD A3 04 4A 4A 4A 29 01 18 69 01 8D A1 04 4C 34
  .byte $C9                               ; $C7FF: C9
Loc_C800:  ; (dispatch callback target)
; --- Code Region ---
  LDA $04A1                             ; $C800: AD A1 04
  BNE $C80E                             ; $C803: D0 09
  LDA #$D1                              ; $C805: A9 D1
  JSR $C96D                             ; $C807: 20 6D C9
  INC $04A1                             ; $C80A: EE A1 04
  RTS                                   ; $C80D: 60
Loc_C80E:
  LDA #$69                              ; $C80E: A9 69
  STA $0010                             ; $C810: 8D 10 00
  LDA #$97                              ; $C813: A9 97
  STA $0011                             ; $C815: 8D 11 00
  LDY $04A1                             ; $C818: AC A1 04
  JSR $C994                             ; $C81B: 20 94 C9
  LDA $04A3                             ; $C81E: AD A3 04
  LSR                                   ; $C821: 4A
  LSR                                   ; $C822: 4A
  LSR                                   ; $C823: 4A
  LSR                                   ; $C824: 4A
  AND #$01                              ; $C825: 29 01
  STA $04A1                             ; $C827: 8D A1 04
  INC $04A1                             ; $C82A: EE A1 04
  JMP $C934                             ; $C82D: 4C 34 C9
Loc_C830:  ; (dispatch callback target)
  LDA $04A1                             ; $C830: AD A1 04
  BNE $C843                             ; $C833: D0 0E
  LDA #$C6                              ; $C835: A9 C6
  JSR $C96D                             ; $C837: 20 6D C9
  INC $04A1                             ; $C83A: EE A1 04
  LDA #$03                              ; $C83D: A9 03
  STA $04A4                             ; $C83F: 8D A4 04
  RTS                                   ; $C842: 60
Loc_C843:
  LDA #$1F                              ; $C843: A9 1F
  STA $0010                             ; $C845: 8D 10 00
  LDA #$98                              ; $C848: A9 98
  STA $0011                             ; $C84A: 8D 11 00
  LDY $04A1                             ; $C84D: AC A1 04
  JSR $C994                             ; $C850: 20 94 C9
  LDY $04A4                             ; $C853: AC A4 04
  JSR $C994                             ; $C856: 20 94 C9
  LDA $04A3                             ; $C859: AD A3 04
  LSR                                   ; $C85C: 4A
  LSR                                   ; $C85D: 4A
  LSR                                   ; $C85E: 4A
  STA $0000                             ; $C85F: 8D 00 00
  AND #$01                              ; $C862: 29 01
  STA $04A1                             ; $C864: 8D A1 04
  INC $04A1                             ; $C867: EE A1 04
  LDY #$03                              ; $C86A: A0 03
  LDA $0000                             ; $C86C: AD 00 00
  AND #$07                              ; $C86F: 29 07
  CMP #$07                              ; $C871: C9 07
  BNE $C877                             ; $C873: D0 02
  LDY #$04                              ; $C875: A0 04
Loc_C877:
  STY $04A4                             ; $C877: 8C A4 04
  JMP $C934                             ; $C87A: 4C 34 C9
Loc_C87D:  ; (dispatch callback target)
  LDA $04A1                             ; $C87D: AD A1 04
  BNE $C88B                             ; $C880: D0 09
  LDA #$BD                              ; $C882: A9 BD
  JSR $C96D                             ; $C884: 20 6D C9
  INC $04A1                             ; $C887: EE A1 04
  RTS                                   ; $C88A: 60
Loc_C88B:
  LDA #$93                              ; $C88B: A9 93
  STA $0010                             ; $C88D: 8D 10 00
  LDA #$98                              ; $C890: A9 98
  STA $0011                             ; $C892: 8D 11 00
  LDY $04A1                             ; $C895: AC A1 04
  JSR $C994                             ; $C898: 20 94 C9
  LDA $04A1                             ; $C89B: AD A1 04
  CMP #$04                              ; $C89E: C9 04
  BEQ $C8B1                             ; $C8A0: F0 0F
  LDA $04A3                             ; $C8A2: AD A3 04
  LSR                                   ; $C8A5: 4A
  LSR                                   ; $C8A6: 4A
  LSR                                   ; $C8A7: 4A
  LSR                                   ; $C8A8: 4A
  AND #$03                              ; $C8A9: 29 03
  CLC                                   ; $C8AB: 18
  ADC #$01                              ; $C8AC: 69 01
  STA $04A1                             ; $C8AE: 8D A1 04
Loc_C8B1:
  JMP $C934                             ; $C8B1: 4C 34 C9
Loc_C8B4:  ; (dispatch callback target)
  LDA $04A1                             ; $C8B4: AD A1 04
  BNE $C8C7                             ; $C8B7: D0 0E
  LDA #$B7                              ; $C8B9: A9 B7
  JSR $C96D                             ; $C8BB: 20 6D C9
  LDA #$B7                              ; $C8BE: A9 B7
  JSR $C98A                             ; $C8C0: 20 8A C9
  INC $04A1                             ; $C8C3: EE A1 04
  RTS                                   ; $C8C6: 60
Loc_C8C7:
  LDA #$DF                              ; $C8C7: A9 DF
  STA $0010                             ; $C8C9: 8D 10 00
  LDA #$99                              ; $C8CC: A9 99
  STA $0011                             ; $C8CE: 8D 11 00
  LDY $04A1                             ; $C8D1: AC A1 04
  JSR $C994                             ; $C8D4: 20 94 C9
  LDA $04A1                             ; $C8D7: AD A1 04
  CMP #$03                              ; $C8DA: C9 03
  BEQ $C8EE                             ; $C8DC: F0 10
  LDA $04A3                             ; $C8DE: AD A3 04
  LSR                                   ; $C8E1: 4A
  LSR                                   ; $C8E2: 4A
  LSR                                   ; $C8E3: 4A
  LSR                                   ; $C8E4: 4A
  LSR                                   ; $C8E5: 4A
  AND #$03                              ; $C8E6: 29 03
  CLC                                   ; $C8E8: 18
  ADC #$01                              ; $C8E9: 69 01
  STA $04A1                             ; $C8EB: 8D A1 04
Loc_C8EE:
  JMP $C934                             ; $C8EE: 4C 34 C9
Loc_C8F1:  ; (dispatch callback target)
  LDA $04A1                             ; $C8F1: AD A1 04
  BNE $C904                             ; $C8F4: D0 0E
  LDA #$AA                              ; $C8F6: A9 AA
  JSR $C96D                             ; $C8F8: 20 6D C9
  LDA #$AB                              ; $C8FB: A9 AB
  JSR $C98A                             ; $C8FD: 20 8A C9
  INC $04A1                             ; $C900: EE A1 04
  RTS                                   ; $C903: 60
Loc_C904:
  LDA #$E4                              ; $C904: A9 E4
  STA $0010                             ; $C906: 8D 10 00
  LDA #$9A                              ; $C909: A9 9A
  STA $0011                             ; $C90B: 8D 11 00
  LDY $04A1                             ; $C90E: AC A1 04
  JSR $C994                             ; $C911: 20 94 C9
  LDA $04A3                             ; $C914: AD A3 04
  LSR                                   ; $C917: 4A
  LSR                                   ; $C918: 4A
  LSR                                   ; $C919: 4A
  LSR                                   ; $C91A: 4A
  AND #$01                              ; $C91B: 29 01
  STA $04A1                             ; $C91D: 8D A1 04
  INC $04A1                             ; $C920: EE A1 04
  JMP $C934                             ; $C923: 4C 34 C9
Loc_C926:  ; (dispatch callback target)
  LDA $0140                             ; $C926: AD 40 01
  BNE $C933                             ; $C929: D0 08
  LDA #$00                              ; $C92B: A9 00
  STA $04A0                             ; $C92D: 8D A0 04
  STA $04A2                             ; $C930: 8D A2 04
Loc_C933:
  RTS                                   ; $C933: 60
Loc_C934:
  LDA $04D0                             ; $C934: AD D0 04
  CMP $04CC                             ; $C937: CD CC 04
  BCC $C96C                             ; $C93A: 90 30
  LDA $04A2                             ; $C93C: AD A2 04
  BEQ $C951                             ; $C93F: F0 10
  CMP #$04                              ; $C941: C9 04
  BEQ $C951                             ; $C943: F0 0C
  CMP #$08                              ; $C945: C9 08
  BEQ $C951                             ; $C947: F0 08
  JSR $E57F                             ; $C949: 20 7F E5
  LDA #$81                              ; $C94C: A9 81
  JSR $E673                             ; $C94E: 20 73 E6
Loc_C951:
  LDA #$01                              ; $C951: A9 01
  STA $007D                             ; $C953: 8D 7D 00
  LDA #$00                              ; $C956: A9 00
  STA $0000                             ; $C958: 8D 00 00
  LDY #$3D                              ; $C95B: A0 3D
  JSR $EE07                             ; $C95D: 20 07 EE
; --- Data Region ---
  .byte $15,$A0,$A9,$80,$8D,$40,$01,$A9,$22,$8D,$A2,$04; $C960: 15 A0 A9 80 8D 40 01 A9 22 8D A2 04
Loc_C96C:
; --- Code Region ---
  RTS                                   ; $C96C: 60
Loc_C96D:
  STA $00BF                             ; $C96D: 8D BF 00
  STA $00C7                             ; $C970: 8D C7 00
  STA $00CF                             ; $C973: 8D CF 00
  LDY #$0C                              ; $C976: A0 0C
Loc_C978:
  LDA $0120,Y                           ; $C978: B9 20 01
  STA $0100,Y                           ; $C97B: 99 00 01
  LDA $0130,Y                           ; $C97E: B9 30 01
  STA $0110,Y                           ; $C981: 99 10 01
  INY                                   ; $C984: C8
  CPY #$10                              ; $C985: C0 10
  BCC $C978                             ; $C987: 90 EF
  RTS                                   ; $C989: 60
Loc_C98A:
  STA $00C0                             ; $C98A: 8D C0 00
  STA $00C8                             ; $C98D: 8D C8 00
  STA $00D0                             ; $C990: 8D D0 00
  RTS                                   ; $C993: 60
Loc_C994:
  LDX #$20                              ; $C994: A2 20
Loc_C996:
  DEY                                   ; $C996: 88
  TYA                                   ; $C997: 98
  ASL                                   ; $C998: 0A
  TAY                                   ; $C999: A8
  LDA ($10),Y                           ; $C99A: B1 10
  STA $0000                             ; $C99C: 8D 00 00
  INY                                   ; $C99F: C8
  LDA ($10),Y                           ; $C9A0: B1 10
  SEC                                   ; $C9A2: 38
  SBC #$40                              ; $C9A3: E9 40
  STA $0001                             ; $C9A5: 8D 01 00
  LDA $0150                             ; $C9A8: AD 50 01
  BPL $C9B2                             ; $C9AB: 10 05
  TXA                                   ; $C9AD: 8A
  CLC                                   ; $C9AE: 18
  ADC #$70                              ; $C9AF: 69 70
  TAX                                   ; $C9B1: AA
Loc_C9B2:
  STX $000C                             ; $C9B2: 8E 0C 00
  LDA #$2F                              ; $C9B5: A9 2F
  STA $000A                             ; $C9B7: 8D 0A 00
  LDA #$03                              ; $C9BA: A9 03
  STA $0002                             ; $C9BC: 8D 02 00
  JMP $F1AD                             ; $C9BF: 4C AD F1
Loc_C9C2:
  LDA $04A1                             ; $C9C2: AD A1 04
  JSR $EADE                             ; $C9C5: 20 DE EA
; --- Data Region ---
  .byte $E8,$C9,$D0,$C9,$4E,$CA,$52,$CB   ; $C9C8: E8 C9 D0 C9 4E CA 52 CB
Loc_C9D0:  ; (dispatch callback target)
; --- Code Region ---
  LDA #$01                              ; $C9D0: A9 01
  STA $007D                             ; $C9D2: 8D 7D 00
  LDY #$0C                              ; $C9D5: A0 0C
  LDA #$0F                              ; $C9D7: A9 0F
Loc_C9D9:
  STA $0100,Y                           ; $C9D9: 99 00 01
  STA $0110,Y                           ; $C9DC: 99 10 01
  INY                                   ; $C9DF: C8
  CPY #$10                              ; $C9E0: C0 10
  BCC $C9D9                             ; $C9E2: 90 F5
  INC $04A1                             ; $C9E4: EE A1 04
  RTS                                   ; $C9E7: 60
Loc_C9E8:  ; (dispatch callback target)
  LDA #$40                              ; $C9E8: A9 40
  STA $0000                             ; $C9EA: 8D 00 00
  LDA #$CC                              ; $C9ED: A9 CC
  STA $0001                             ; $C9EF: 8D 01 00
  LDA $0150                             ; $C9F2: AD 50 01
  BPL $CA08                             ; $C9F5: 10 11
  LDA $0000                             ; $C9F7: AD 00 00
  CLC                                   ; $C9FA: 18
  ADC #$1C                              ; $C9FB: 69 1C
  STA $0000                             ; $C9FD: 8D 00 00
  LDA $0001                             ; $CA00: AD 01 00
  ADC #$00                              ; $CA03: 69 00
  STA $0001                             ; $CA05: 8D 01 00
Loc_CA08:
  LDY #$00                              ; $CA08: A0 00
Loc_CA0A:
  LDA ($00),Y                           ; $CA0A: B1 00
  STA $0380,Y                           ; $CA0C: 99 80 03
  INY                                   ; $CA0F: C8
  CPY #$1C                              ; $CA10: C0 1C
  BCC $CA0A                             ; $CA12: 90 F6
  LDA #$FF                              ; $CA14: A9 FF
  STA $0380,Y                           ; $CA16: 99 80 03
  LDA $007E                             ; $CA19: AD 7E 00
  ORA #$04                              ; $CA1C: 09 04
  STA $007E                             ; $CA1E: 8D 7E 00
  LDA #$78                              ; $CA21: A9 78
  STA $04D4                             ; $CA23: 8D D4 04
  LDA #$CC                              ; $CA26: A9 CC
  STA $04D5                             ; $CA28: 8D D5 04
  LDX #$02                              ; $CA2B: A2 02
  LDA $0150                             ; $CA2D: AD 50 01
  BPL $CA34                             ; $CA30: 10 02
  LDX #$10                              ; $CA32: A2 10
Loc_CA34:
  STX $04D2                             ; $CA34: 8E D2 04
  LDA #$02                              ; $CA37: A9 02
  STA $00C4                             ; $CA39: 8D C4 00
  STA $00CC                             ; $CA3C: 8D CC 00
  STA $00D4                             ; $CA3F: 8D D4 00
  STA $00DC                             ; $CA42: 8D DC 00
  LDA #$04                              ; $CA45: A9 04
  STA $04A3                             ; $CA47: 8D A3 04
  INC $04A1                             ; $CA4A: EE A1 04
  RTS                                   ; $CA4D: 60
Loc_CA4E:  ; (dispatch callback target)
  DEC $04A3                             ; $CA4E: CE A3 04
  LDA $04A3                             ; $CA51: AD A3 04
  BPL $CA59                             ; $CA54: 10 03
  JMP $CAC5                             ; $CA56: 4C C5 CA
Loc_CA59:
  LDA $04D4                             ; $CA59: AD D4 04
  STA $0000                             ; $CA5C: 8D 00 00
  LDA $04D5                             ; $CA5F: AD D5 04
  STA $0001                             ; $CA62: 8D 01 00
  LDY #$00                              ; $CA65: A0 00
  LDX #$00                              ; $CA67: A2 00
Loc_CA69:
  LDA #$0E                              ; $CA69: A9 0E
  STA $0380,X                           ; $CA6B: 9D 80 03
  INX                                   ; $CA6E: E8
  LDA ($00),Y                           ; $CA6F: B1 00
  CMP #$FF                              ; $CA71: C9 FF
  BNE $CA7C                             ; $CA73: D0 07
  DEX                                   ; $CA75: CA
  STA $0380,X                           ; $CA76: 9D 80 03
  JMP $CABC                             ; $CA79: 4C BC CA
Loc_CA7C:
  STA $0380,X                           ; $CA7C: 9D 80 03
  INX                                   ; $CA7F: E8
  INY                                   ; $CA80: C8
  LDA ($00),Y                           ; $CA81: B1 00
  CLC                                   ; $CA83: 18
  ADC $04D2                             ; $CA84: 6D D2 04
  STA $0380,X                           ; $CA87: 9D 80 03
  INX                                   ; $CA8A: E8
  INY                                   ; $CA8B: C8
  LDA #$00                              ; $CA8C: A9 00
  STA $0002                             ; $CA8E: 8D 02 00
Loc_CA91:
  LDA ($00),Y                           ; $CA91: B1 00
  STA $0380,X                           ; $CA93: 9D 80 03
  INX                                   ; $CA96: E8
  INY                                   ; $CA97: C8
  INC $0002                             ; $CA98: EE 02 00
  LDA $0002                             ; $CA9B: AD 02 00
  CMP #$0E                              ; $CA9E: C9 0E
  BCC $CA91                             ; $CAA0: 90 EF
  CPY #$50                              ; $CAA2: C0 50
  BCC $CA69                             ; $CAA4: 90 C3
  LDA #$FF                              ; $CAA6: A9 FF
  STA $0380,X                           ; $CAA8: 9D 80 03
  LDA $0000                             ; $CAAB: AD 00 00
  CLC                                   ; $CAAE: 18
  ADC #$50                              ; $CAAF: 69 50
  STA $04D4                             ; $CAB1: 8D D4 04
  LDA $0001                             ; $CAB4: AD 01 00
  ADC #$00                              ; $CAB7: 69 00
  STA $04D5                             ; $CAB9: 8D D5 04
Loc_CABC:
  LDA $007E                             ; $CABC: AD 7E 00
  ORA #$04                              ; $CABF: 09 04
  STA $007E                             ; $CAC1: 8D 7E 00
  RTS                                   ; $CAC4: 60
Loc_CAC5:
  LDA #$20                              ; $CAC5: A9 20
  STA $04D3                             ; $CAC7: 8D D3 04
  LDX #$C4                              ; $CACA: A2 C4
  LDA $0150                             ; $CACC: AD 50 01
  BPL $CAD3                             ; $CACF: 10 02
  LDX #$D2                              ; $CAD1: A2 D2
Loc_CAD3:
  STX $04D2                             ; $CAD3: 8E D2 04
  LDX $04A2                             ; $CAD6: AE A2 04
  STX $0003                             ; $CAD9: 8E 03 00
  LDA #$6C                              ; $CADC: A9 6C
  STA $0000                             ; $CADE: 8D 00 00
  LDA #$00                              ; $CAE1: A9 00
  STA $0001                             ; $CAE3: 8D 01 00
  STA $0002                             ; $CAE6: 8D 02 00
  JSR $EBE9                             ; $CAE9: 20 E9 EB
  LDA #$59                              ; $CAEC: A9 59
  CLC                                   ; $CAEE: 18
  ADC $0006                             ; $CAEF: 6D 06 00
  STA $0000                             ; $CAF2: 8D 00 00
  LDA #$CD                              ; $CAF5: A9 CD
  ADC $0007                             ; $CAF7: 6D 07 00
  STA $0001                             ; $CAFA: 8D 01 00
  LDY #$00                              ; $CAFD: A0 00
  LDA ($00),Y                           ; $CAFF: B1 00
  STA $00C3                             ; $CB01: 8D C3 00
  STA $00CB                             ; $CB04: 8D CB 00
  STA $00D3                             ; $CB07: 8D D3 00
  INY                                   ; $CB0A: C8
  LDA ($00),Y                           ; $CB0B: B1 00
  STA $00C2                             ; $CB0D: 8D C2 00
  STA $00CA                             ; $CB10: 8D CA 00
  STA $00D2                             ; $CB13: 8D D2 00
  INY                                   ; $CB16: C8
  LDX #$0D                              ; $CB17: A2 0D
Loc_CB19:
  LDA ($00),Y                           ; $CB19: B1 00
  STA $0120,X                           ; $CB1B: 9D 20 01
  INX                                   ; $CB1E: E8
  INY                                   ; $CB1F: C8
  CPY #$05                              ; $CB20: C0 05
  BCC $CB19                             ; $CB22: 90 F5
  LDX #$1D                              ; $CB24: A2 1D
Loc_CB26:
  LDA ($00),Y                           ; $CB26: B1 00
  STA $0120,X                           ; $CB28: 9D 20 01
  INX                                   ; $CB2B: E8
  INY                                   ; $CB2C: C8
  CPY #$08                              ; $CB2D: C0 08
  BCC $CB26                             ; $CB2F: 90 F5
  LDA #$0F                              ; $CB31: A9 0F
  STA $010C                             ; $CB33: 8D 0C 01
  STA $011C                             ; $CB36: 8D 1C 01
  TYA                                   ; $CB39: 98
  CLC                                   ; $CB3A: 18
  ADC $0000                             ; $CB3B: 6D 00 00
  STA $04D4                             ; $CB3E: 8D D4 04
  LDA #$00                              ; $CB41: A9 00
  ADC $0001                             ; $CB43: 6D 01 00
  STA $04D5                             ; $CB46: 8D D5 04
  LDA #$01                              ; $CB49: A9 01
  STA $04A3                             ; $CB4B: 8D A3 04
  INC $04A1                             ; $CB4E: EE A1 04
  RTS                                   ; $CB51: 60
Loc_CB52:  ; (dispatch callback target)
  LDA $04D2                             ; $CB52: AD D2 04
  STA $0002                             ; $CB55: 8D 02 00
  LDA $04D3                             ; $CB58: AD D3 04
  STA $0003                             ; $CB5B: 8D 03 00
  LDA $04D4                             ; $CB5E: AD D4 04
  STA $0000                             ; $CB61: 8D 00 00
  LDA $04D5                             ; $CB64: AD D5 04
  STA $0001                             ; $CB67: 8D 01 00
  LDX #$00                              ; $CB6A: A2 00
  LDY #$00                              ; $CB6C: A0 00
Loc_CB6E:
  LDA #$0A                              ; $CB6E: A9 0A
  STA $0380,X                           ; $CB70: 9D 80 03
  INX                                   ; $CB73: E8
  LDA $0003                             ; $CB74: AD 03 00
  STA $0380,X                           ; $CB77: 9D 80 03
  INX                                   ; $CB7A: E8
  LDA $0002                             ; $CB7B: AD 02 00
  STA $0380,X                           ; $CB7E: 9D 80 03
  INX                                   ; $CB81: E8
  LDY #$00                              ; $CB82: A0 00
Loc_CB84:
  LDA ($00),Y                           ; $CB84: B1 00
  STA $0380,X                           ; $CB86: 9D 80 03
  INX                                   ; $CB89: E8
  INY                                   ; $CB8A: C8
  CPY #$0A                              ; $CB8B: C0 0A
  BCC $CB84                             ; $CB8D: 90 F5
  LDA $0000                             ; $CB8F: AD 00 00
  CLC                                   ; $CB92: 18
  ADC #$0A                              ; $CB93: 69 0A
  STA $0000                             ; $CB95: 8D 00 00
  LDA $0001                             ; $CB98: AD 01 00
  ADC #$00                              ; $CB9B: 69 00
  STA $0001                             ; $CB9D: 8D 01 00
  LDA $0002                             ; $CBA0: AD 02 00
  CLC                                   ; $CBA3: 18
  ADC #$20                              ; $CBA4: 69 20
  STA $0002                             ; $CBA6: 8D 02 00
  LDA $0003                             ; $CBA9: AD 03 00
  ADC #$00                              ; $CBAC: 69 00
  STA $0003                             ; $CBAE: 8D 03 00
  CPX #$41                              ; $CBB1: E0 41
  BCC $CB6E                             ; $CBB3: 90 B9
  LDA #$FF                              ; $CBB5: A9 FF
  STA $0380,X                           ; $CBB7: 9D 80 03
  LDA $0002                             ; $CBBA: AD 02 00
  STA $04D2                             ; $CBBD: 8D D2 04
  LDA $0003                             ; $CBC0: AD 03 00
  STA $04D3                             ; $CBC3: 8D D3 04
  LDA $0000                             ; $CBC6: AD 00 00
  STA $04D4                             ; $CBC9: 8D D4 04
  LDA $0001                             ; $CBCC: AD 01 00
  STA $04D5                             ; $CBCF: 8D D5 04
  DEC $04A3                             ; $CBD2: CE A3 04
  LDA $04A3                             ; $CBD5: AD A3 04
  BPL $CC00                             ; $CBD8: 10 26
  LDA $04A2                             ; $CBDA: AD A2 04
  CMP #$04                              ; $CBDD: C9 04
  BEQ $CBEB                             ; $CBDF: F0 0A
  CMP #$05                              ; $CBE1: C9 05
  BEQ $CBEB                             ; $CBE3: F0 06
  JSR $E57F                             ; $CBE5: 20 7F E5
  JSR $CC09                             ; $CBE8: 20 09 CC
Loc_CBEB:
  LDA #$81                              ; $CBEB: A9 81
  STA $04A0                             ; $CBED: 8D A0 04
  LDA #$FF                              ; $CBF0: A9 FF
  STA $04CC                             ; $CBF2: 8D CC 04
  LDA #$00                              ; $CBF5: A9 00
  STA $04A1                             ; $CBF7: 8D A1 04
  STA $04A3                             ; $CBFA: 8D A3 04
  STA $04D0                             ; $CBFD: 8D D0 04
Loc_CC00:
  LDA $007E                             ; $CC00: AD 7E 00
  ORA #$04                              ; $CC03: 09 04
  STA $007E                             ; $CC05: 8D 7E 00
  RTS                                   ; $CC08: 60
Loc_CC09:
  LDA $04D6                             ; $CC09: AD D6 04
  CMP #$32                              ; $CC0C: C9 32
  BEQ $CC3D                             ; $CC0E: F0 2D
  CMP #$47                              ; $CC10: C9 47
  BEQ $CC3D                             ; $CC12: F0 29
  CMP #$2E                              ; $CC14: C9 2E
  BEQ $CC3A                             ; $CC16: F0 22
  CMP #$3E                              ; $CC18: C9 3E
  BEQ $CC3A                             ; $CC1A: F0 1E
  CMP #$52                              ; $CC1C: C9 52
  BEQ $CC3A                             ; $CC1E: F0 1A
  CMP #$A2                              ; $CC20: C9 A2
  BEQ $CC3A                             ; $CC22: F0 16
  CMP #$A6                              ; $CC24: C9 A6
  BEQ $CC3A                             ; $CC26: F0 12
  CMP #$38                              ; $CC28: C9 38
  BEQ $CC37                             ; $CC2A: F0 0B
  CMP #$3B                              ; $CC2C: C9 3B
  BEQ $CC37                             ; $CC2E: F0 07
  CMP #$9F                              ; $CC30: C9 9F
  BEQ $CC37                             ; $CC32: F0 03
  JMP $E683                             ; $CC34: 4C 83 E6
Loc_CC37:
  JMP $E693                             ; $CC37: 4C 93 E6
Loc_CC3A:
  JMP $E68B                             ; $CC3A: 4C 8B E6
Loc_CC3D:
  JMP $E67B                             ; $CC3D: 4C 7B E6
; --- Data Region ---
  .byte $04,$23,$C8,$99,$FA,$FA,$BA,$04,$23,$D0,$99,$FF,$FF,$BB,$04,$23; $CC40: 04 23 C8 99 FA FA BA 04 23 D0 99 FF FF BB 04 23
  .byte $D8,$99,$FF,$FF,$BB,$04,$23,$E0,$59,$5A,$5A,$0A,$04,$23,$CC,$EA; $CC50: D8 99 FF FF BB 04 23 E0 59 5A 5A 0A 04 23 CC EA
  .byte $FA,$FA,$22,$04,$23,$D4,$EE,$FF,$FF,$22,$04,$23,$DC,$EE,$FF,$FF; $CC60: FA FA 22 04 23 D4 EE FF FF 22 04 23 DC EE FF FF
  .byte $22,$04,$23,$E4,$0A,$0A,$0A,$02,$20,$80,$9B,$9C,$BE,$BF,$84,$84; $CC70: 22 04 23 E4 0A 0A 0A 02 20 80 9B 9C BE BF 84 84
  .byte $84,$84,$84,$84,$85,$86,$87,$88,$20,$A0,$89,$8A,$8B,$8C,$8C,$8C; $CC80: 84 84 84 84 85 86 87 88 20 A0 89 8A 8B 8C 8C 8C
  .byte $8C,$8C,$8C,$8C,$8C,$8D,$8E,$8F,$20,$C0,$90,$91,$00,$00,$00,$00; $CC90: 8C 8C 8C 8C 8C 8D 8E 8F 20 C0 90 91 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$92,$93,$20,$E0,$94,$91,$00,$00,$00,$00; $CCA0: 00 00 00 00 00 00 92 93 20 E0 94 91 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$92,$95,$21,$00,$96,$97,$00,$00,$00,$00; $CCB0: 00 00 00 00 00 00 92 95 21 00 96 97 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$98,$99,$21,$20,$96,$97,$00,$00,$00,$00; $CCC0: 00 00 00 00 00 00 98 99 21 20 96 97 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$98,$99,$21,$40,$96,$97,$00,$00,$00,$00; $CCD0: 00 00 00 00 00 00 98 99 21 40 96 97 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$98,$99,$21,$60,$96,$97,$00,$00,$00,$00; $CCE0: 00 00 00 00 00 00 98 99 21 60 96 97 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$98,$99,$21,$80,$96,$97,$00,$00,$00,$00; $CCF0: 00 00 00 00 00 00 98 99 21 80 96 97 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$98,$99,$21,$A0,$96,$97,$00,$00,$00,$00; $CD00: 00 00 00 00 00 00 98 99 21 A0 96 97 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$98,$99,$21,$C0,$9A,$97,$00,$00,$00,$00; $CD10: 00 00 00 00 00 00 98 99 21 C0 9A 97 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$98,$9D,$21,$E0,$9E,$97,$00,$00,$00,$00; $CD20: 00 00 00 00 00 00 98 9D 21 E0 9E 97 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$98,$9F,$22,$00,$A0,$A1,$A2,$A3,$A3,$A3; $CD30: 00 00 00 00 00 00 98 9F 22 00 A0 A1 A2 A3 A3 A3
  .byte $A3,$A3,$A3,$A3,$A3,$A4,$A5,$A6,$22,$20,$A7,$A8,$A9,$AA,$AB,$AB; $CD40: A3 A3 A3 A3 A3 A4 A5 A6 22 20 A7 A8 A9 AA AB AB
  .byte $AB,$AB,$AB,$AB,$AC,$AD,$AE,$AF,$FF,$C4,$00,$36,$26,$17,$16,$07; $CD50: AB AB AB AB AC AD AE AF FF C4 00 36 26 17 16 07
  .byte $17,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$40,$41; $CD60: 17 7E 7E 7E 7E 7E 7E 7E 7E 7E 7E 7E 7E 7E 40 41
  .byte $42,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$43,$44,$45,$46,$47,$48,$7E,$7E; $CD70: 42 7E 7E 7E 7E 7E 7E 7E 43 44 45 46 47 48 7E 7E
  .byte $7E,$7E,$49,$4A,$4B,$4C,$4D,$4E,$7E,$7E,$4F,$50,$51,$52,$53,$54; $CD80: 7E 7E 49 4A 4B 4C 4D 4E 7E 7E 4F 50 51 52 53 54
  .byte $55,$56,$7E,$7E,$58,$59,$5A,$5B,$5C,$5D,$5E,$5F,$7E,$7E,$7E,$60; $CD90: 55 56 7E 7E 58 59 5A 5B 5C 5D 5E 5F 7E 7E 7E 60
  .byte $61,$62,$63,$64,$65,$66,$7E,$7E,$7E,$67,$68,$69,$6A,$6B,$6C,$6D; $CDA0: 61 62 63 64 65 66 7E 7E 7E 67 68 69 6A 6B 6C 6D
  .byte $6E,$7E,$7E,$6F,$70,$71,$72,$73,$74,$75,$7E,$7E,$7E,$76,$77,$78; $CDB0: 6E 7E 7E 6F 70 71 72 73 74 75 7E 7E 7E 76 77 78
  .byte $79,$7A,$7B,$7C,$7D,$C9,$00,$36,$16,$26,$36,$16,$26,$01,$01,$01; $CDC0: 79 7A 7B 7C 7D C9 00 36 16 26 36 16 26 01 01 01
  .byte $01,$40,$41,$52,$53,$01,$01,$01,$01,$01,$01,$67,$6B,$00,$71,$01; $CDD0: 01 40 41 52 53 01 01 01 01 01 01 67 6B 00 71 01
  .byte $01,$01,$01,$01,$01,$00,$00,$72,$73,$42,$01,$01,$01,$01,$43,$00; $CDE0: 01 01 01 01 01 00 00 72 73 42 01 01 01 01 43 00
  .byte $00,$00,$44,$45,$46,$01,$47,$48,$49,$00,$00,$4A,$02,$02,$02,$4C; $CDF0: 00 00 44 45 46 01 47 48 49 00 00 4A 02 02 02 4C
  .byte $4D,$4E,$4F,$50,$02,$02,$02,$02,$54,$55,$56,$57,$58,$59,$4B,$02; $CE00: 4D 4E 4F 50 02 02 02 02 54 55 56 57 58 59 4B 02
  .byte $5A,$5B,$5C,$5D,$5E,$5F,$60,$61,$62,$63,$64,$65,$66,$03,$5D,$68; $CE10: 5A 5B 5C 5D 5E 5F 60 61 62 63 64 65 66 03 5D 68
  .byte $69,$6A,$03,$6C,$6D,$6E,$6F,$03,$03,$70,$03,$03,$03,$74; $CE20: 69 6A 03 6C 6D 6E 6F 03 03 70 03 03 03 74
Loc_CE2E:
; --- Code Region ---
  EOR ($75),Y                           ; $CE2E: 51 75
  ROR $E0,X                             ; $CE30: 76 E0
  BRK                                   ; $CE32: 00
  BMI $CE45                             ; $CE33: 30 10
  SLO $16,X                             ; $CE35: 17 16
  BPL $CE50                             ; $CE37: 10 17
  RTI                                   ; $CE39: 40
; --- Data Region ---
  .byte $40,$40,$40,$40,$40,$40,$40,$40,$40,$41,$42; $CE3A: 40 40 40 40 40 40 40 40 40 41 42
Loc_CE45:
; --- Code Region ---
  RTI                                   ; $CE45: 40
; --- Data Region ---
  .byte $40,$40,$40,$40,$40,$40,$40,$43,$44,$45; $CE46: 40 40 40 40 40 40 40 43 44 45
Loc_CE50:
; --- Code Region ---
  ADC $75,X                             ; $CE50: 75 75
  LSR $47                               ; $CE52: 46 47
  PHA                                   ; $CE54: 48
  RTI                                   ; $CE55: 40
; --- Data Region ---
  .byte $40,$53,$49,$4A,$4B,$53,$53,$53,$4C,$4D,$4E,$53,$4F,$50,$51,$52; $CE56: 40 53 49 4A 4B 53 53 53 4C 4D 4E 53 4F 50 51 52
  .byte $53,$53,$53,$53,$53,$53,$53,$54,$55,$56,$57,$58,$53,$53,$53,$53; $CE66: 53 53 53 53 53 53 53 54 55 56 57 58 53 53 53 53
  .byte $53,$59,$5A,$5B,$5C,$5D,$5E,$5F,$60,$53,$53,$53,$61,$62,$63,$64; $CE76: 53 59 5A 5B 5C 5D 5E 5F 60 53 53 53 61 62 63 64
  .byte $65,$66,$67,$53,$53,$53,$68,$69,$6A,$6B,$6C,$6D,$6E,$53,$53,$53; $CE86: 65 66 67 53 53 53 68 69 6A 6B 6C 6D 6E 53 53 53
  .byte $6F,$70,$71,$72,$73,$74,$75,$C7,$C5,$30,$16,$36,$30,$16,$36,$41; $CE96: 6F 70 71 72 73 74 75 C7 C5 30 16 36 30 16 36 41
  .byte $41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$40,$40,$40,$41,$41,$42; $CEA6: 41 41 41 41 41 41 41 41 41 41 40 40 40 41 41 42
Loc_CEB6:
; --- Code Region ---
  SRE ($44,X)                           ; $CEB6: 43 44
  EOR ($41,X)                           ; $CEB8: 41 41
Loc_CEBA:
  RTI                                   ; $CEBA: 40
; --- Data Region ---
  .byte $40,$40,$41,$41,$45,$46,$47,$41,$41,$40,$40,$40,$48,$49,$40,$4A; $CEBB: 40 40 41 41 45 46 47 41 41 40 40 40 48 49 40 4A
  .byte $4B,$41,$4C,$4D,$40,$40,$4E,$4F,$50,$51,$52,$53,$54,$55,$56,$57; $CECB: 4B 41 4C 4D 40 40 4E 4F 50 51 52 53 54 55 56 57
  .byte $58,$59,$5A,$5B,$5C,$5D,$5E,$5F,$60,$61,$62,$63,$64,$65,$66,$67; $CEDB: 58 59 5A 5B 5C 5D 5E 5F 60 61 62 63 64 65 66 67
  .byte $68,$69,$6A,$6B,$6C,$6D,$6E,$6F,$70,$71,$72,$73,$74,$75,$76,$77; $CEEB: 68 69 6A 6B 6C 6D 6E 6F 70 71 72 73 74 75 76 77
  .byte $78,$79,$7A,$7B,$41,$7C,$7D,$7E,$7F,$39,$3A,$3B,$3C,$3D,$B8,$00; $CEFB: 78 79 7A 7B 41 7C 7D 7E 7F 39 3A 3B 3C 3D B8 00
  .byte $10,$36,$17,$10,$36,$17,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40; $CF0B: 10 36 17 10 36 17 40 40 40 40 40 40 40 40 40 40
  .byte $40,$40,$40,$40,$40,$40,$42,$43,$40,$40,$40,$44,$40,$40,$40,$40; $CF1B: 40 40 40 40 40 40 42 43 40 40 40 44 40 40 40 40
  .byte $45,$46,$47,$48,$00,$49,$4A,$00,$00,$00,$4B,$4C,$00,$4D,$00,$4E; $CF2B: 45 46 47 48 00 49 4A 00 00 00 4B 4C 00 4D 00 4E
  .byte $00,$4F,$00,$00,$00,$50,$51,$52   ; $CF3B: 00 4F 00 00 00 50 51 52
Loc_CF43:
; --- Code Region ---
  BRK                                   ; $CF43: 00
  BRK                                   ; $CF44: 00
  BRK                                   ; $CF45: 00
  SRE ($54),Y                           ; $CF46: 53 54
  EOR $56,X                             ; $CF48: 55 56
  SRE $58,X                             ; $CF4A: 57 58
  EOR $5B5A,Y                           ; $CF4C: 59 5A 5B
  NOP $5E5D,X                           ; $CF4F: 5C 5D 5E
  SRE $6160,X                           ; $CF52: 5F 60 61
  JAM                                   ; $CF55: 62
  RRA ($64,X)                           ; $CF56: 63 64
  ADC $66                               ; $CF58: 65 66
  RRA $68                               ; $CF5A: 67 68
  ADC #$6A                              ; $CF5C: 69 6A
  ARR #$6C                              ; $CF5E: 6B 6C
  ADC $6F6E                             ; $CF60: 6D 6E 6F
  BVS $CFD6                             ; $CF63: 70 71
  JAM                                   ; $CF65: 72
Loc_CF66:
  RRA ($74),Y                           ; $CF66: 73 74
  ADC $76,X                             ; $CF68: 75 76
  RRA $41,X                             ; $CF6A: 77 41
  EOR ($78,X)                           ; $CF6C: 41 78
  ADC $7B7A,Y                           ; $CF6E: 79 7A 7B
  EOR ($7C,X)                           ; $CF71: 41 7C
  ADC $C37E,X                           ; $CF73: 7D 7E C3
  BRK                                   ; $CF76: 00
  AND ($36),Y                           ; $CF77: 31 36
  SLO $31,X                             ; $CF79: 17 31
  ROL $17,X                             ; $CF7B: 36 17
  EOR ($41,X)                           ; $CF7D: 41 41
  JAM                                   ; $CF7F: 42
  SRE ($44,X)                           ; $CF80: 43 44
  RTI                                   ; $CF82: 40
; --- Data Region ---
  .byte $40,$40,$40,$41,$41,$41,$45,$46,$40,$40,$40,$40,$40,$41,$41,$47; $CF83: 40 40 40 41 41 41 45 46 40 40 40 40 40 41 41 47
Loc_CF93:
; --- Code Region ---
  PHA                                   ; $CF93: 48
  EOR #$40                              ; $CF94: 49 40
  RTI                                   ; $CF96: 40
; --- Data Region ---
  .byte $40,$40,$40,$41,$4A,$4B,$4C,$4D,$40,$40,$40,$40,$40,$41,$4E,$4F; $CF97: 40 40 40 41 4A 4B 4C 4D 40 40 40 40 40 41 4E 4F
  .byte $50,$51,$52,$40,$40,$40,$40       ; $CFA7: 50 51 52 40 40 40 40
Loc_CFAE:
; --- Code Region ---
  EOR ($53,X)                           ; $CFAE: 41 53
  EOR ($54,X)                           ; $CFB0: 41 54
  EOR $56,X                             ; $CFB2: 55 56
  SRE $58,X                             ; $CFB4: 57 58
  RTI                                   ; $CFB6: 40
; --- Data Region ---
  .byte $40,$41,$41,$41,$59,$5A,$5B,$5C,$5D,$5E,$41,$41,$41,$41,$5F,$60; $CFB7: 40 41 41 41 59 5A 5B 5C 5D 5E 41 41 41 41 5F 60
  .byte $61,$62,$40,$63,$41,$41,$41,$41,$41,$64,$65,$66,$67,$68,$69; $CFC7: 61 62 40 63 41 41 41 41 41 64 65 66 67 68 69
Loc_CFD6:
; --- Code Region ---
  EOR ($41,X)                           ; $CFD6: 41 41
  EOR ($41,X)                           ; $CFD8: 41 41
  ROR                                   ; $CFDA: 6A
  ARR #$6C                              ; $CFDB: 6B 6C
  ADC $6F6E                             ; $CFDD: 6D 6E 6F
  BVS $CFAE                             ; $CFE0: 70 CC
  BRK                                   ; $CFE2: 00
  BMI $D006                             ; $CFE3: 30 21
  RLA $16                               ; $CFE5: 27 16
  ORA #$36                              ; $CFE7: 09 36
  RTI                                   ; $CFE9: 40
; --- Data Region ---
  .byte $40,$40,$41,$42,$43,$40,$40,$44,$45,$46,$46,$46,$46,$46,$46,$46; $CFEA: 40 40 41 42 43 40 40 44 45 46 46 46 46 46 46 46
  .byte $46,$47,$48,$49,$4A,$4B,$4C,$4D,$4E,$4F; $CFFA: 46 47 48 49 4A 4B 4C 4D 4E 4F
Loc_D004:  ; (dispatch callback target)
; --- Code Region ---
  RTI                                   ; $D004: 40
; --- Data Region ---
  .byte $62                               ; $D005: 62
Loc_D006:
; --- Code Region ---
  RTI                                   ; $D006: 40
; --- Data Region ---
  .byte $50,$51,$52,$53,$54,$62,$40,$55,$56,$40,$57,$58,$59,$5A,$62,$40; $D007: 50 51 52 53 54 62 40 55 56 40 57 58 59 5A 62 40
  .byte $5B,$40,$5C,$5D,$5E,$5F,$62,$40,$60,$40,$61,$62,$40,$63,$64,$65; $D017: 5B 40 5C 5D 5E 5F 62 40 60 40 61 62 40 63 64 65
  .byte $66,$6A,$67,$68,$69,$40,$40,$6A,$6B,$6C,$6D,$6E,$6F,$70,$71,$6A; $D027: 66 6A 67 68 69 40 40 6A 6B 6C 6D 6E 6F 70 71 6A
  .byte $72,$72,$73,$74,$75,$76,$77,$78,$62,$79,$7A,$7A,$7B,$7C,$6E,$6E; $D037: 72 72 73 74 75 76 77 78 62 79 7A 7A 7B 7C 6E 6E
  .byte $62,$40,$40,$7D,$7E,$7F,$B6,$B7,$30,$36,$17,$30,$36,$17,$41,$42; $D047: 62 40 40 7D 7E 7F B6 B7 30 36 17 30 36 17 41 42
  .byte $43,$44,$41                       ; $D057: 43 44 41
Loc_D05A:
; --- Code Region ---
  EOR ($45,X)                           ; $D05A: 41 45
  LSR $47                               ; $D05C: 46 47
  PHA                                   ; $D05E: 48
  EOR ($49,X)                           ; $D05F: 41 49
  LSR                                   ; $D061: 4A
  ALR #$41                              ; $D062: 4B 41
  EOR ($4C,X)                           ; $D064: 41 4C
  EOR $4F4E                             ; $D066: 4D 4E 4F
  EOR ($50,X)                           ; $D069: 41 50
  EOR ($52),Y                           ; $D06B: 51 52
  EOR ($41,X)                           ; $D06D: 41 41
  SRE ($54),Y                           ; $D06F: 53 54
  EOR $56,X                             ; $D071: 55 56
  SRE $58,X                             ; $D073: 57 58
  EOR $5B5A,Y                           ; $D075: 59 5A 5B
  NOP $5E5D,X                           ; $D078: 5C 5D 5E
  SRE $6160,X                           ; $D07B: 5F 60 61
  JAM                                   ; $D07E: 62
  RRA ($64,X)                           ; $D07F: 63 64
  ADC $40                               ; $D081: 65 40
  RTI                                   ; $D083: 40
; --- Data Region ---
  .byte $40,$66,$67                       ; $D084: 40 66 67
Loc_D087:
; --- Code Region ---
  PLA                                   ; $D087: 68
  ADC #$6A                              ; $D088: 69 6A
  ARR #$6C                              ; $D08A: 6B 6C
  RTI                                   ; $D08C: 40
; --- Data Region ---
  .byte $40,$40,$6D,$6E,$6F,$70,$71,$72,$40,$40,$40,$40,$41,$73,$74,$75; $D08D: 40 40 6D 6E 6F 70 71 72 40 40 40 40 41 73 74 75
  .byte $76,$40,$40,$40,$40,$40,$77,$78,$79,$7A; $D09D: 76 40 40 40 40 40 77 78 79 7A
Loc_D0A7:
; --- Code Region ---
  RRA $4040,Y                           ; $D0A7: 7B 40 40
  NOP $7E7D,X                           ; $D0AA: 7C 7D 7E
  EOR ($40,X)                           ; $D0AD: 41 40
  RRA $0100,X                           ; $D0AF: 7F 00 01
  RTI                                   ; $D0B2: 40
; --- Data Region ---
  .byte $40,$02,$41,$41,$41,$40,$C8,$00,$16,$36,$17,$16,$36,$17,$40,$40; $D0B3: 40 02 41 41 41 40 C8 00 16 36 17 16 36 17 40 40
  .byte $40,$41,$41,$41,$41,$41,$42,$43,$41,$40,$40,$41,$41,$44,$45,$46; $D0C3: 40 41 41 41 41 41 42 43 41 40 40 41 41 44 45 46
  .byte $41,$41,$47,$48,$40,$40,$49,$4A,$4B,$4C,$4D,$41,$41,$4E,$4F,$40; $D0D3: 41 41 47 48 40 40 49 4A 4B 4C 4D 41 41 4E 4F 40
  .byte $40,$50,$51,$52,$53,$54,$55,$56,$57,$41,$40,$58,$59,$5A,$5B,$41; $D0E3: 40 50 51 52 53 54 55 56 57 41 40 58 59 5A 5B 41
  .byte $5C,$5D,$5E,$5F,$60,$61,$62,$63,$64,$41,$65,$66,$67,$68,$69,$6A; $D0F3: 5C 5D 5E 5F 60 61 62 63 64 41 65 66 67 68 69 6A
  .byte $6B,$6C                           ; $D103: 6B 6C
Loc_D105:
; --- Code Region ---
  ADC $6F6E                             ; $D105: 6D 6E 6F
  BVS $D17B                             ; $D108: 70 71
  JAM                                   ; $D10A: 72
  RRA ($74),Y                           ; $D10B: 73 74
  ADC $76,X                             ; $D10D: 75 76
  RRA $78,X                             ; $D10F: 77 78
  EOR ($40,X)                           ; $D111: 41 40
  ADC $4040,Y                           ; $D113: 79 40 40
  NOP                                   ; $D116: 7A
  RTI                                   ; $D117: 40
; --- Data Region ---
  .byte $40,$40,$7B,$41,$40,$7C,$7D,$7E,$7F,$40,$40,$40,$40,$D2,$00,$2A; $D118: 40 40 7B 41 40 7C 7D 7E 7F 40 40 40 40 D2 00 2A
  .byte $21,$16,$30,$25,$27,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40; $D128: 21 16 30 25 27 40 40 40 40 40 40 40 40 40 40
Loc_D137:
; --- Code Region ---
  RTI                                   ; $D137: 40
; --- Data Region ---
  .byte $40,$40,$40,$40,$40,$40,$40,$42,$43,$44,$45,$46,$47,$46,$47,$48; $D138: 40 40 40 40 40 40 40 42 43 44 45 46 47 46 47 48
  .byte $49,$4A,$4B,$4C,$4D,$41,$4E,$4F,$50; $D148: 49 4A 4B 4C 4D 41 4E 4F 50
Loc_D151:
; --- Code Region ---
  EOR ($52),Y                           ; $D151: 51 52
  SRE ($54),Y                           ; $D153: 53 54
  EOR $56,X                             ; $D155: 55 56
  SRE $41,X                             ; $D157: 57 41
  EOR ($41,X)                           ; $D159: 41 41
  EOR ($41,X)                           ; $D15B: 41 41
  CLI                                   ; $D15D: 58
  EOR $415A,Y                           ; $D15E: 59 5A 41
  SRE $4141,Y                           ; $D161: 5B 41 41
  EOR $5F5E,X                           ; $D164: 5D 5E 5F
  RTS                                   ; $D167: 60
; --- Data Region ---
  .byte $61,$62,$63,$64,$65,$66,$67,$68,$41,$69,$6A,$41,$41,$6B,$41,$41; $D168: 61 62 63 64 65 66 67 68 41 69 6A 41 41 6B 41 41
  .byte $6C,$6D,$6E                       ; $D178: 6C 6D 6E
Loc_D17B:
; --- Code Region ---
  ROR $7170                             ; $D17B: 6E 70 71
  JAM                                   ; $D17E: 72
  RRA ($74),Y                           ; $D17F: 73 74
  ADC $76,X                             ; $D181: 75 76
  EOR ($41,X)                           ; $D183: 41 41
  RRA $41,X                             ; $D185: 77 41
  EOR ($78,X)                           ; $D187: 41 78
  ADC $7B7A,Y                           ; $D189: 79 7A 7B
  NOP $417D,X                           ; $D18C: 7C 7D 41
  ROR $CE7F,X                           ; $D18F: 7E 7F CE
  BRK                                   ; $D192: 00
  BPL $D1AD                             ; $D193: 10 18
  ROL $10                               ; $D195: 26 10
  CLC                                   ; $D197: 18
  ROL $41                               ; $D198: 26 41
  JAM                                   ; $D19A: 42
  SRE ($44,X)                           ; $D19B: 43 44
  EOR $46                               ; $D19D: 45 46
  SRE $48                               ; $D19F: 47 48
  EOR #$4A                              ; $D1A1: 49 4A
  ALR #$4C                              ; $D1A3: 4B 4C
  SRE ($4D,X)                           ; $D1A5: 43 4D
  LSR $7D40                             ; $D1A7: 4E 40 7D
  SRE $5150                             ; $D1AA: 4F 50 51
Loc_D1AD:
  EOR ($42,X)                           ; $D1AD: 41 42
  SRE ($44,X)                           ; $D1AF: 43 44
  RTI                                   ; $D1B1: 40
; --- Data Region ---
  .byte $40,$40,$4F,$52,$53,$41,$4C,$43,$4D,$40,$40,$40,$54,$55,$56,$41; $D1B2: 40 40 4F 52 53 41 4C 43 4D 40 40 40 54 55 56 41
  .byte $42,$58,$59,$40,$40,$40,$5A,$5B,$4A,$5C,$5D,$5E,$40,$40,$40,$40; $D1C2: 42 58 59 40 40 40 5A 5B 4A 5C 5D 5E 40 40 40 40
  .byte $5F,$60,$56,$61,$62,$63,$64,$40,$40,$65,$66,$67,$4A,$40,$40,$40; $D1D2: 5F 60 56 61 62 63 64 40 40 65 66 67 4A 40 40 40
  .byte $40,$40,$68,$69,$6A,$6B,$6C,$6D,$6E,$6F,$70,$40,$71; $D1E2: 40 40 68 69 6A 6B 6C 6D 6E 6F 70 40 71
Loc_D1EF:
; --- Code Region ---
  JAM                                   ; $D1EF: 72
  RRA ($74),Y                           ; $D1F0: 73 74
  ADC $76,X                             ; $D1F2: 75 76
  RRA $78,X                             ; $D1F4: 77 78
  ADC $4040,Y                           ; $D1F6: 79 40 40
  RTI                                   ; $D1F9: 40
; --- Data Region ---
  .byte $7A,$7B,$7C,$CD,$00,$30,$17,$36,$30,$17,$36,$40,$41,$03,$03,$03; $D1FA: 7A 7B 7C CD 00 30 17 36 30 17 36 40 41 03 03 03
  .byte $03,$03,$03,$03,$03,$00,$42,$03,$03,$03,$00,$00,$00,$03; $D20A: 03 03 03 03 03 00 42 03 03 03 00 00 00 03
Loc_D218:
; --- Code Region ---
  SLO ($43,X)                           ; $D218: 03 43
  NOP $03                               ; $D21A: 44 03
  SLO ($03,X)                           ; $D21C: 03 03
  BRK                                   ; $D21E: 00
  BRK                                   ; $D21F: 00
  BRK                                   ; $D220: 00
  SLO ($03,X)                           ; $D221: 03 03
  EOR $46                               ; $D223: 45 46
  SLO ($03,X)                           ; $D225: 03 03
  BRK                                   ; $D227: 00
  BRK                                   ; $D228: 00
  BRK                                   ; $D229: 00
  BRK                                   ; $D22A: 00
  BRK                                   ; $D22B: 00
  SLO ($47,X)                           ; $D22C: 03 47
Loc_D22E:
  PHA                                   ; $D22E: 48
  EOR #$03                              ; $D22F: 49 03
  BRK                                   ; $D231: 00
  BRK                                   ; $D232: 00
  BRK                                   ; $D233: 00
  BRK                                   ; $D234: 00
  BRK                                   ; $D235: 00
  ALR #$00                              ; $D236: 4B 00
  BRK                                   ; $D238: 00
  JMP $4E4D                             ; $D239: 4C 4D 4E
; --- Data Region ---
  .byte $4A,$00,$02,$02,$4F,$00,$00,$4C,$50,$51,$52,$53,$02,$54,$55,$00; $D23C: 4A 00 02 02 4F 00 00 4C 50 51 52 53 02 54 55 00
  .byte $00,$4C,$56,$57,$58,$59,$02,$54,$55,$00,$00,$4C,$00,$00,$00,$5B; $D24C: 00 4C 56 57 58 59 02 54 55 00 00 4C 00 00 00 5B
  .byte $5C,$5D,$5E,$00,$00,$4C,$00,$00,$00,$00,$00,$5F,$02,$D9,$00,$30; $D25C: 5C 5D 5E 00 00 4C 00 00 00 00 00 5F 02 D9 00 30
  .byte $36,$17,$30,$36,$17,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41; $D26C: 36 17 30 36 17 41 41 41 41 41 41 41 41 41 41 41
  .byte $41,$41,$41,$41,$40,$40,$40,$41,$41,$42,$43,$44,$41,$41,$40,$40; $D27C: 41 41 41 41 40 40 40 41 41 42 43 44 41 41 40 40
  .byte $40,$41,$41,$45,$46,$47,$41,$41,$40,$40,$40,$48,$41,$49,$4A,$4B; $D28C: 40 41 41 45 46 47 41 41 40 40 40 48 41 49 4A 4B
  .byte $41,$41,$40,$40,$40,$4C,$4D       ; $D29C: 41 41 40 40 40 4C 4D
Loc_D2A3:
; --- Code Region ---
  LSR $4040                             ; $D2A3: 4E 40 40
  SRE $5041                             ; $D2A6: 4F 41 50
  EOR ($52),Y                           ; $D2A9: 51 52
  SRE ($54),Y                           ; $D2AB: 53 54
  EOR $56,X                             ; $D2AD: 55 56
  SRE $58,X                             ; $D2AF: 57 58
  EOR $5B5A,Y                           ; $D2B1: 59 5A 5B
  NOP $5E5D,X                           ; $D2B4: 5C 5D 5E
  SRE $6160,X                           ; $D2B7: 5F 60 61
  JAM                                   ; $D2BA: 62
  RRA ($64,X)                           ; $D2BB: 63 64
  ADC $66                               ; $D2BD: 65 66
  RRA $68                               ; $D2BF: 67 68
  ADC #$6A                              ; $D2C1: 69 6A
  ARR #$6C                              ; $D2C3: 6B 6C
  ADC $6F6E                             ; $D2C5: 6D 6E 6F
  BVS $D33B                             ; $D2C8: 70 71
  JAM                                   ; $D2CA: 72
  RRA ($74),Y                           ; $D2CB: 73 74
  ADC $76,X                             ; $D2CD: 75 76
  RRA $78,X                             ; $D2CF: 77 78
  ADC $7B7A,Y                           ; $D2D1: 79 7A 7B
  NOP $00DC,X                           ; $D2D4: 7C DC 00
  AND ($21),Y                           ; $D2D7: 31 21
  ORA ($30),Y                           ; $D2D9: 11 30
  ROL $18,X                             ; $D2DB: 36 18
  LSR $57,X                             ; $D2DD: 56 57
  CLI                                   ; $D2DF: 58
  EOR $5957,Y                           ; $D2E0: 59 57 59
  LSR $57,X                             ; $D2E3: 56 57
  CLI                                   ; $D2E5: 58
  EOR $5B5A,Y                           ; $D2E6: 59 5A 5B
  NOP $5B5D,X                           ; $D2E9: 5C 5D 5B
  EOR $5B5A,X                           ; $D2EC: 5D 5A 5B
  NOP $5E5D,X                           ; $D2EF: 5C 5D 5E
  SRE $6160,X                           ; $D2F2: 5F 60 61
  SRE $5E61,X                           ; $D2F5: 5F 61 5E
  SRE $6160,X                           ; $D2F8: 5F 60 61
  JAM                                   ; $D2FB: 62
  JAM                                   ; $D2FC: 62
  JAM                                   ; $D2FD: 62
  JAM                                   ; $D2FE: 62
  JAM                                   ; $D2FF: 62
  JAM                                   ; $D300: 62
  JAM                                   ; $D301: 62
  JAM                                   ; $D302: 62
  JAM                                   ; $D303: 62
  JAM                                   ; $D304: 62
  RRA ($63,X)                           ; $D305: 63 63
  RRA ($63,X)                           ; $D307: 63 63
  RRA ($63,X)                           ; $D309: 63 63
  RRA ($63,X)                           ; $D30B: 63 63
  RRA ($63,X)                           ; $D30D: 63 63
  NOP $64                               ; $D30F: 64 64
  NOP $64                               ; $D311: 64 64
  NOP $64                               ; $D313: 64 64
  NOP $64                               ; $D315: 64 64
  NOP $64                               ; $D317: 64 64
  ADC $65                               ; $D319: 65 65
  ADC $65                               ; $D31B: 65 65
  ADC $65                               ; $D31D: 65 65
  ADC $65                               ; $D31F: 65 65
  ADC $65                               ; $D321: 65 65
  ROR $66                               ; $D323: 66 66
  ROR $66                               ; $D325: 66 66
  ROR $66                               ; $D327: 66 66
  ROR $66                               ; $D329: 66 66
  ROR $66                               ; $D32B: 66 66
  RRA $68                               ; $D32D: 67 68
  RRA $68                               ; $D32F: 67 68
  RRA $68                               ; $D331: 67 68
  RRA $68                               ; $D333: 67 68
  RRA $68                               ; $D335: 67 68
  ADC #$6A                              ; $D337: 69 6A
  ADC #$6A                              ; $D339: 69 6A
Loc_D33B:
  ADC #$6A                              ; $D33B: 69 6A
  ADC #$6A                              ; $D33D: 69 6A
  ADC #$6A                              ; $D33F: 69 6A
  NOP $D5,X                             ; $D341: D4 D5
  AND ($36),Y                           ; $D343: 31 36
  SLO $31,X                             ; $D345: 17 31
  ROL $17,X                             ; $D347: 36 17
  JAM                                   ; $D349: 42
  RTI                                   ; $D34A: 40
; --- Data Region ---
  .byte $43,$44,$41,$41,$45,$46,$47,$48,$40,$40,$40,$49,$4A,$41,$4B,$4C; $D34B: 43 44 41 41 45 46 47 48 40 40 40 49 4A 41 4B 4C
  .byte $4C,$4C,$40,$4D,$4E,$4F,$50,$41,$41,$41,$41,$41,$51,$40,$40,$40; $D35B: 4C 4C 40 4D 4E 4F 50 41 41 41 41 41 51 40 40 40
  .byte $52,$53,$41,$00,$00,$00,$54,$55,$40,$56,$57,$58,$00,$00,$00,$00; $D36B: 52 53 41 00 00 00 54 55 40 56 57 58 00 00 00 00
  .byte $40,$59,$40,$40,$5A,$5B,$00,$00,$00,$00,$5C,$5D,$5E,$5F,$60,$61; $D37B: 40 59 40 40 5A 5B 00 00 00 00 5C 5D 5E 5F 60 61
  .byte $00,$00,$00,$00,$62,$63,$41,$41,$64,$65,$66,$00,$00,$67,$68,$69; $D38B: 00 00 00 00 62 63 41 41 64 65 66 00 00 67 68 69
  .byte $6A,$6B,$00,$00,$6C,$6D,$6E,$6F,$70; $D39B: 6A 6B 00 00 6C 6D 6E 6F 70
Loc_D3A4:
; --- Code Region ---
  ADC ($72),Y                           ; $D3A4: 71 72
  RRA ($00),Y                           ; $D3A6: 73 00
  BRK                                   ; $D3A8: 00
  BRK                                   ; $D3A9: 00
  NOP $75,X                             ; $D3AA: 74 75
  ROR $CF,X                             ; $D3AC: 76 CF
  BRK                                   ; $D3AE: 00
  BMI $D3C7                             ; $D3AF: 30 16
  RLA $30                               ; $D3B1: 27 30
  ASL $27,X                             ; $D3B3: 16 27
  EOR ($42,X)                           ; $D3B5: 41 42
  SRE ($44,X)                           ; $D3B7: 43 44
  EOR $46                               ; $D3B9: 45 46
  SRE $40                               ; $D3BB: 47 40
  RTI                                   ; $D3BD: 40
; --- Data Region ---
  .byte $40,$48,$49,$4A,$4B,$4C,$4D,$4E,$40; $D3BE: 40 48 49 4A 4B 4C 4D 4E 40
Loc_D3C7:
; --- Code Region ---
  RTI                                   ; $D3C7: 40
; --- Data Region ---
  .byte $40,$4F,$50,$51,$52,$53,$54,$55,$40,$56,$57,$58,$59,$5A,$40,$40; $D3C8: 40 4F 50 51 52 53 54 55 40 56 57 58 59 5A 40 40
  .byte $40,$40,$40,$5B,$5C,$58,$59,$5A,$5D,$5E,$5F,$60,$40,$40,$40,$58; $D3D8: 40 40 40 5B 5C 58 59 5A 5D 5E 5F 60 40 40 40 58
  .byte $59,$5A,$61,$62,$63,$64,$40,$40,$40,$58,$59,$5A,$40,$40,$65,$66; $D3E8: 59 5A 61 62 63 64 40 40 40 58 59 5A 40 40 65 66
  .byte $40,$40,$40,$58,$59,$67,$40,$40,$40,$68,$69,$6A,$6B,$74,$75,$40; $D3F8: 40 40 40 58 59 67 40 40 40 68 69 6A 6B 74 75 40
  .byte $40,$40,$40,$6C,$6D,$6E,$6F,$74,$75,$40,$40,$40,$40,$70,$71,$72; $D408: 40 40 40 6C 6D 6E 6F 74 75 40 40 40 40 70 71 72
  .byte $73,$D0,$00,$16,$26,$17,$35,$07,$06,$41,$41,$41,$41,$41,$41,$41; $D418: 73 D0 00 16 26 17 35 07 06 41 41 41 41 41 41 41
  .byte $41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$42,$42,$42; $D428: 41 41 41 41 41 41 41 41 41 41 41 41 41 42 42 42
  .byte $42,$42,$42,$42,$42,$42,$42,$43,$43,$43,$43,$43,$43,$43,$43,$43; $D438: 42 42 42 42 42 42 42 43 43 43 43 43 43 43 43 43
  .byte $44,$45,$46,$47,$48,$49,$4A,$4B,$4C,$4D,$4E,$55,$56,$57,$58,$59; $D448: 44 45 46 47 48 49 4A 4B 4C 4D 4E 55 56 57 58 59
  .byte $5A,$5B,$5C,$5D,$5E,$50,$54,$54,$54,$54,$54,$54,$54,$54,$54,$54; $D458: 5A 5B 5C 5D 5E 50 54 54 54 54 54 54 54 54 54 54
  .byte $54,$51,$52,$53,$54,$54,$54,$54,$54,$54,$54,$54,$54,$54,$54,$54; $D468: 54 51 52 53 54 54 54 54 54 54 54 54 54 54 54 54
  .byte $54,$54,$54,$4F,$5F,$60,$54,$54,$54,$54,$54,$54,$54,$D6,$00,$10; $D478: 54 54 54 4F 5F 60 54 54 54 54 54 54 54 D6 00 10
Loc_D488:
; --- Code Region ---
  SLO $07,X                             ; $D488: 17 07
  ROL $17,X                             ; $D48A: 36 17
  SLO $41                               ; $D48C: 07 41
  JAM                                   ; $D48E: 42
  SRE ($44,X)                           ; $D48F: 43 44
  EOR $46                               ; $D491: 45 46
  SRE $48                               ; $D493: 47 48
  EOR #$4A                              ; $D495: 49 4A
  EOR ($52),Y                           ; $D497: 51 52
  SRE ($54),Y                           ; $D499: 53 54
  EOR $56,X                             ; $D49B: 55 56
  SRE $58,X                             ; $D49D: 57 58
  EOR $615A,Y                           ; $D49F: 59 5A 61
  JAM                                   ; $D4A2: 62
  RRA ($64,X)                           ; $D4A3: 63 64
  ADC $66                               ; $D4A5: 65 66
  RRA $68                               ; $D4A7: 67 68
  ADC #$6A                              ; $D4A9: 69 6A
  SEI                                   ; $D4AB: 78
  ADC $7940,Y                           ; $D4AC: 79 40 79
  ADC $7A78,Y                           ; $D4AF: 79 78 7A
  ALR #$4C                              ; $D4B2: 4B 4C
  EOR $4040                             ; $D4B4: 4D 40 40
; --- Data Region ---
  .byte $40,$40,$40,$40,$78,$5B,$5C,$5D,$40,$40,$40,$40,$40,$40,$60,$6B; $D4B7: 40 40 40 40 78 5B 5C 5D 40 40 40 40 40 40 60 6B
  .byte $6C,$6D,$75                       ; $D4C7: 6C 6D 75
Loc_D4CA:
; --- Code Region ---
  ROR $77,X                             ; $D4CA: 76 77
  RTI                                   ; $D4CC: 40
; --- Data Region ---
  .byte $40,$40,$40,$7B,$7C,$7D,$40,$40,$40,$40,$40,$40,$40,$4E,$4F,$6E; $D4CD: 40 40 40 7B 7C 7D 40 40 40 40 40 40 40 4E 4F 6E
  .byte $70,$71,$40,$40,$40,$40,$40,$5E,$5F,$7E,$72,$73,$74,$40,$40,$40; $D4DD: 70 71 40 40 40 40 40 5E 5F 7E 72 73 74 40 40 40
  .byte $7B,$6F,$7F,$50,$D8,$00,$30,$36,$26,$30,$36,$26,$00,$00,$00,$00; $D4ED: 7B 6F 7F 50 D8 00 30 36 26 30 36 26 00 00 00 00
  .byte $02,$02,$02,$02,$02,$02,$00,$00,$00,$00,$02,$02,$02,$02,$02,$02; $D4FD: 02 02 02 02 02 02 00 00 00 00 02 02 02 02 02 02
  .byte $00,$00,$00,$02,$02,$02,$42,$43,$44,$02,$00,$00,$00,$02,$02,$02; $D50D: 00 00 00 02 02 02 42 43 44 02 00 00 00 02 02 02
  .byte $45,$46,$47,$02,$00,$00,$00,$01,$02,$02,$49,$4A,$4B,$02; $D51D: 45 46 47 02 00 00 00 01 02 02 49 4A 4B 02
Loc_D52B:
; --- Code Region ---
  JMP $4D4C                             ; $D52B: 4C 4C 4D
; --- Data Region ---
  .byte $01,$02,$4E,$4F,$00,$00,$50,$4C,$4C,$53,$01,$02,$54,$55,$00,$00; $D52E: 01 02 4E 4F 00 00 50 4C 4C 53 01 02 54 55 00 00
  .byte $56,$4C,$4C,$59,$01,$5A,$5B,$5C,$5D,$5E,$02,$4C,$4C,$62,$63,$64; $D53E: 56 4C 4C 59 01 5A 5B 5C 5D 5E 02 4C 4C 62 63 64
  .byte $65,$66                           ; $D54E: 65 66
Loc_D550:
; --- Code Region ---
  RRA $68                               ; $D550: 67 68
  ADC #$4C                              ; $D552: 69 4C
  JMP $7372                             ; $D554: 4C 72 73
; --- Data Region ---
  .byte $74,$75,$76,$77,$78,$79,$E6,$E7,$36,$16,$10,$36,$16,$10,$80,$40; $D557: 74 75 76 77 78 79 E6 E7 36 16 10 36 16 10 80 40
  .byte $41,$80,$80,$42,$80,$80,$43,$44,$80,$45,$46,$80,$80,$47,$80,$80; $D567: 41 80 80 42 80 80 43 44 80 45 46 80 80 47 80 80
  .byte $48,$49,$4A,$4B,$4C,$80,$80,$80,$80,$80,$4D; $D577: 48 49 4A 4B 4C 80 80 80 80 80 4D
Loc_D582:
; --- Code Region ---
  LSR $504F                             ; $D582: 4E 4F 50
  EOR ($52),Y                           ; $D585: 51 52
  SRE ($80),Y                           ; $D587: 53 80
  NOP #$54                              ; $D589: 80 54
  EOR $56,X                             ; $D58B: 55 56
  SRE $58,X                             ; $D58D: 57 58
  EOR $5B5A,Y                           ; $D58F: 59 5A 5B
  NOP $5E5D,X                           ; $D592: 5C 5D 5E
  SRE $6160,X                           ; $D595: 5F 60 61
  JAM                                   ; $D598: 62
Loc_D599:
  RRA ($64,X)                           ; $D599: 63 64
  ADC $66                               ; $D59B: 65 66
  RRA $68                               ; $D59D: 67 68
  ADC #$6A                              ; $D59F: 69 6A
  ARR #$6C                              ; $D5A1: 6B 6C
  ADC $6F6E                             ; $D5A3: 6D 6E 6F
  BVS $D619                             ; $D5A6: 70 71
  JAM                                   ; $D5A8: 72
  RRA ($74),Y                           ; $D5A9: 73 74
  ADC $76,X                             ; $D5AB: 75 76
  RRA $78,X                             ; $D5AD: 77 78
  ADC $7B7A,Y                           ; $D5AF: 79 7A 7B
  NOP $7E7D,X                           ; $D5B2: 7C 7D 7E
  RRA $0100,X                           ; $D5B5: 7F 00 01
  JAM                                   ; $D5B8: 02
  SLO ($04,X)                           ; $D5B9: 03 04
  ORA $06                               ; $D5BB: 05 06
  SLO $08                               ; $D5BD: 07 08
  ORA #$09                              ; $D5BF: 09 09
  ORA #$0A                              ; $D5C1: 09 0A
  ANC #$0C                              ; $D5C3: 0B 0C
  ORA $0F0E                             ; $D5C5: 0D 0E 0F
  BPL $D5A7                             ; $D5C8: 10 DD
  BRK                                   ; $D5CA: 00
  BMI $D603                             ; $D5CB: 30 36
  CLC                                   ; $D5CD: 18
  BMI $D606                             ; $D5CE: 30 36
  CLC                                   ; $D5D0: 18
  BRK                                   ; $D5D1: 00
  BRK                                   ; $D5D2: 00
  BRK                                   ; $D5D3: 00
  BRK                                   ; $D5D4: 00
  BRK                                   ; $D5D5: 00
  BRK                                   ; $D5D6: 00
  BRK                                   ; $D5D7: 00
  BRK                                   ; $D5D8: 00
  BRK                                   ; $D5D9: 00
  BRK                                   ; $D5DA: 00
  BRK                                   ; $D5DB: 00
  BRK                                   ; $D5DC: 00
  EOR ($42,X)                           ; $D5DD: 41 42
  SRE ($44,X)                           ; $D5DF: 43 44
  BRK                                   ; $D5E1: 00
  BRK                                   ; $D5E2: 00
  BRK                                   ; $D5E3: 00
  BRK                                   ; $D5E4: 00
  BRK                                   ; $D5E5: 00
  EOR $46                               ; $D5E6: 45 46
  SRE $48                               ; $D5E8: 47 48
  EOR #$4A                              ; $D5EA: 49 4A
  BRK                                   ; $D5EC: 00
  BRK                                   ; $D5ED: 00
  BRK                                   ; $D5EE: 00
  ALR #$4C                              ; $D5EF: 4B 4C
  EOR $4F4E                             ; $D5F1: 4D 4E 4F
  BVC $D647                             ; $D5F4: 50 51
  BRK                                   ; $D5F6: 00
  BRK                                   ; $D5F7: 00
  BRK                                   ; $D5F8: 00
  JAM                                   ; $D5F9: 52
  SRE ($54),Y                           ; $D5FA: 53 54
  EOR $56,X                             ; $D5FC: 55 56
  SRE $58,X                             ; $D5FE: 57 58
  BRK                                   ; $D600: 00
  BRK                                   ; $D601: 00
  BRK                                   ; $D602: 00
Loc_D603:
  BRK                                   ; $D603: 00
  EOR $5B5A,Y                           ; $D604: 59 5A 5B
  NOP $5E5D,X                           ; $D607: 5C 5D 5E
  SRE $6000,X                           ; $D60A: 5F 00 60
; --- Data Region ---
  .byte $40,$61,$62,$63,$64,$65,$66,$67,$68,$69,$75,$6A; $D60D: 40 61 62 63 64 65 66 67 68 69 75 6A
Loc_D619:
; --- Code Region ---
  ARR #$6C                              ; $D619: 6B 6C
  ADC $6F6E                             ; $D61B: 6D 6E 6F
  BVS $D691                             ; $D61E: 70 71
  JAM                                   ; $D620: 72
  BRK                                   ; $D621: 00
  RRA ($74),Y                           ; $D622: 73 74
  JMP ($7776)                           ; $D624: 6C 76 77
; --- Data Region ---
  .byte $78,$79,$7A,$7B,$00,$73,$74,$6C,$76,$77,$7C,$7D,$7E,$7F,$E1,$E3; $D627: 78 79 7A 7B 00 73 74 6C 76 77 7C 7D 7E 7F E1 E3
  .byte $36,$16,$31,$17,$07,$0F,$42,$43,$44,$44,$45,$42,$42,$42,$43,$44; $D637: 36 16 31 17 07 0F 42 43 44 44 45 42 42 42 43 44
Loc_D647:
; --- Code Region ---
  LSR $47                               ; $D647: 46 47
  PHA                                   ; $D649: 48
  PHA                                   ; $D64A: 48
  EOR #$4A                              ; $D64B: 49 4A
  ALR #$46                              ; $D64D: 4B 46
  SRE $48                               ; $D64F: 47 48
  JMP $4E4D                             ; $D651: 4C 4D 4E
; --- Data Region ---
  .byte $4F,$50,$51,$52,$4C,$4D,$4E,$53,$54,$55,$55,$56,$57,$58,$59,$5A; $D654: 4F 50 51 52 4C 4D 4E 53 54 55 55 56 57 58 59 5A
  .byte $55,$5B,$5C,$41,$5D,$5E,$5F,$60,$61,$62,$63,$64,$65,$41,$41,$66; $D664: 55 5B 5C 41 5D 5E 5F 60 61 62 63 64 65 41 41 66
  .byte $67,$68,$41,$69,$6A,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41; $D674: 67 68 41 69 6A 41 41 41 41 41 41 41 41 41 41 41
  .byte $41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41; $D684: 41 41 41 41 41 41 41 41 41 41 41 41 41
Loc_D691:
; --- Code Region ---
  EOR ($41,X)                           ; $D691: 41 41
  EOR ($41,X)                           ; $D693: 41 41
  EOR ($41,X)                           ; $D695: 41 41
  EOR ($6B,X)                           ; $D697: 41 6B
  SLO ($14),Y                           ; $D699: 13 14
  EOR ($41,X)                           ; $D69B: 41 41
  ORA $16,X                             ; $D69D: 15 16
  SLO $18,X                             ; $D69F: 17 18
  DEC $10DC,X                           ; $D6A1: DE DC 10
  ROL $17,X                             ; $D6A4: 36 17
  BPL $D6DE                             ; $D6A6: 10 36
  SLO $40,X                             ; $D6A8: 17 40
  RTI                                   ; $D6AA: 40
; --- Data Region ---
  .byte $41,$41,$41,$41,$42,$43,$44,$41,$40,$40,$40,$40,$41,$41,$45,$46; $D6AB: 41 41 41 41 42 43 44 41 40 40 40 40 41 41 45 46
  .byte $47,$48,$40,$40,$40,$40,$41,$41,$49,$40,$4A,$4B,$40,$40,$40,$40; $D6BB: 47 48 40 40 40 40 41 41 49 40 4A 4B 40 40 40 40
  .byte $41,$4C,$4D,$4E,$4F,$50,$40,$40,$40,$51,$52,$53,$54,$55,$56,$57; $D6CB: 41 4C 4D 4E 4F 50 40 40 40 51 52 53 54 55 56 57
  .byte $58,$59,$5A                       ; $D6DB: 58 59 5A
Loc_D6DE:
; --- Code Region ---
  SRE $5D5C,Y                           ; $D6DE: 5B 5C 5D
  LSR $605F,X                           ; $D6E1: 5E 5F 60
  ADC ($62,X)                           ; $D6E4: 61 62
  RRA ($64,X)                           ; $D6E6: 63 64
  ADC $66                               ; $D6E8: 65 66
  RRA $68                               ; $D6EA: 67 68
  ADC #$6A                              ; $D6EC: 69 6A
  ARR #$6C                              ; $D6EE: 6B 6C
  ADC $6F6E                             ; $D6F0: 6D 6E 6F
  BVS $D766                             ; $D6F3: 70 71
  JAM                                   ; $D6F5: 72
  RRA ($00),Y                           ; $D6F6: 73 00
  ORA ($02,X)                           ; $D6F8: 01 02
  SLO ($04,X)                           ; $D6FA: 03 04
  ORA $06                               ; $D6FC: 05 06
  SLO $08                               ; $D6FE: 07 08
  ORA #$0A                              ; $D700: 09 0A
  ANC #$0C                              ; $D702: 0B 0C
  ORA $0F0E                             ; $D704: 0D 0E 0F
  BPL $D71A                             ; $D707: 10 11
  JAM                                   ; $D709: 12
  SLO ($14),Y                           ; $D70A: 13 14
  ORA $DF,X                             ; $D70C: 15 DF
  BRK                                   ; $D70E: 00
  BMI $D747                             ; $D70F: 30 36
  SLO $30,X                             ; $D711: 17 30
  ROL $17,X                             ; $D713: 36 17
  JAM                                   ; $D715: 02
  JAM                                   ; $D716: 02
  JAM                                   ; $D717: 02
  JAM                                   ; $D718: 02
  JAM                                   ; $D719: 02
Loc_D71A:
  JAM                                   ; $D71A: 02
  JAM                                   ; $D71B: 02
  JAM                                   ; $D71C: 42
  SRE ($43,X)                           ; $D71D: 43 43
  JAM                                   ; $D71F: 02
  JAM                                   ; $D720: 02
  JAM                                   ; $D721: 42
  SRE ($43,X)                           ; $D722: 43 43
  SRE ($44,X)                           ; $D724: 43 44
  EOR $46                               ; $D726: 45 46
  LSR $02                               ; $D728: 46 02
  SRE $45                               ; $D72A: 47 45
  LSR $46                               ; $D72C: 46 46
  LSR $48                               ; $D72E: 46 48
  EOR #$4A                              ; $D730: 49 4A
  ALR #$4C                              ; $D732: 4B 4C
  EOR $4A49                             ; $D734: 4D 49 4A
  LSR $4F4A                             ; $D737: 4E 4A 4F
  BVC $D78D                             ; $D73A: 50 51
  BRK                                   ; $D73C: 00
  JAM                                   ; $D73D: 52
  SRE ($50),Y                           ; $D73E: 53 50
  EOR ($00),Y                           ; $D740: 51 00
  EOR ($54),Y                           ; $D742: 51 54
  BRK                                   ; $D744: 00
  BRK                                   ; $D745: 00
  BRK                                   ; $D746: 00
Loc_D747:
  BRK                                   ; $D747: 00
  EOR $00,X                             ; $D748: 55 00
  LSR $57,X                             ; $D74A: 56 57
  BRK                                   ; $D74C: 00
  CLI                                   ; $D74D: 58
  BRK                                   ; $D74E: 00
  BRK                                   ; $D74F: 00
  BRK                                   ; $D750: 00
  EOR $5B5A,Y                           ; $D751: 59 5A 5B
  BRK                                   ; $D754: 00
  BRK                                   ; $D755: 00
  BRK                                   ; $D756: 00
  NOP $5D00,X                           ; $D757: 5C 00 5D
  LSR $005F,X                           ; $D75A: 5E 5F 00
  RTS                                   ; $D75D: 60
; --- Data Region ---
  .byte $61,$62,$00,$00,$63,$00,$64,$65   ; $D75E: 61 62 00 00 63 00 64 65
Loc_D766:
; --- Code Region ---
  ROR $67                               ; $D766: 66 67
  PLA                                   ; $D768: 68
  BRK                                   ; $D769: 00
  BRK                                   ; $D76A: 00
  BRK                                   ; $D76B: 00
  BRK                                   ; $D76C: 00
  BRK                                   ; $D76D: 00
  ADC #$6A                              ; $D76E: 69 6A
  ARR #$6C                              ; $D770: 6B 6C
  BRK                                   ; $D772: 00
  BRK                                   ; $D773: 00
  BRK                                   ; $D774: 00
  BRK                                   ; $D775: 00
  BRK                                   ; $D776: 00
  ADC $B56E                             ; $D777: 6D 6E B5
  BRK                                   ; $D77A: 00
  BMI $D7B3                             ; $D77B: 30 36
  SLO $30,X                             ; $D77D: 17 30
  ROL $17,X                             ; $D77F: 36 17
  BRK                                   ; $D781: 00
  BRK                                   ; $D782: 00
  BRK                                   ; $D783: 00
  BRK                                   ; $D784: 00
  BRK                                   ; $D785: 00
  BRK                                   ; $D786: 00
  BRK                                   ; $D787: 00
  SRE ($54),Y                           ; $D788: 53 54
  EOR $40,X                             ; $D78A: 55 40
  EOR ($00,X)                           ; $D78C: 41 00
  BRK                                   ; $D78E: 00
  BRK                                   ; $D78F: 00
  BRK                                   ; $D790: 00
  BRK                                   ; $D791: 00
  RRA ($64,X)                           ; $D792: 63 64
  ADC $50                               ; $D794: 65 50
  EOR ($52),Y                           ; $D796: 51 52
  BRK                                   ; $D798: 00
  BRK                                   ; $D799: 00
  BRK                                   ; $D79A: 00
  BRK                                   ; $D79B: 00
  RRA ($74),Y                           ; $D79C: 73 74
  ADC $60,X                             ; $D79E: 75 60
  ADC ($62,X)                           ; $D7A0: 61 62
  BRK                                   ; $D7A2: 00
  BRK                                   ; $D7A3: 00
  BRK                                   ; $D7A4: 00
  BRK                                   ; $D7A5: 00
  EOR $00                               ; $D7A6: 45 00
  LSR $70                               ; $D7A8: 46 70
  BRK                                   ; $D7AA: 00
  JAM                                   ; $D7AB: 72
  BRK                                   ; $D7AC: 00
  BRK                                   ; $D7AD: 00
  BRK                                   ; $D7AE: 00
  BRK                                   ; $D7AF: 00
  LSR $66,X                             ; $D7B0: 56 66
  ROR $42,X                             ; $D7B2: 76 42
  ADC ($43),Y                           ; $D7B4: 71 43
  NOP $00                               ; $D7B6: 44 00
  BRK                                   ; $D7B8: 00
  PHA                                   ; $D7B9: 48
  EOR #$4A                              ; $D7BA: 49 4A
  ALR #$00                              ; $D7BC: 4B 00
  BRK                                   ; $D7BE: 00
  BRK                                   ; $D7BF: 00
  BRK                                   ; $D7C0: 00
  BRK                                   ; $D7C1: 00
  SRE $58,X                             ; $D7C2: 57 58
  EOR $5B5A,Y                           ; $D7C4: 59 5A 5B
  BRK                                   ; $D7C7: 00
  BRK                                   ; $D7C8: 00
  BRK                                   ; $D7C9: 00
  BRK                                   ; $D7CA: 00
  BRK                                   ; $D7CB: 00
  RRA $68                               ; $D7CC: 67 68
  ADC #$6A                              ; $D7CE: 69 6A
  ARR #$00                              ; $D7D0: 6B 00
  BRK                                   ; $D7D2: 00
  BRK                                   ; $D7D3: 00
  BRK                                   ; $D7D4: 00
  BRK                                   ; $D7D5: 00
  RRA $78,X                             ; $D7D6: 77 78
  ADC $7B7A,Y                           ; $D7D8: 79 7A 7B
  BRK                                   ; $D7DB: 00
  BRK                                   ; $D7DC: 00
  BRK                                   ; $D7DD: 00
  BRK                                   ; $D7DE: 00
  BRK                                   ; $D7DF: 00
  JMP $4E4D                             ; $D7E0: 4C 4D 4E
; --- Data Region ---
  .byte $4F,$47,$D5,$00,$10,$36,$17,$10,$36,$17,$41,$40,$40,$41,$42,$43; $D7E3: 4F 47 D5 00 10 36 17 10 36 17 41 40 40 41 42 43
  .byte $41,$41,$41,$41,$44,$40,$40,$40,$45,$46,$47,$48,$41,$41,$49,$41; $D7F3: 41 41 41 41 44 40 40 40 45 46 47 48 41 41 49 41
  .byte $40,$40,$4A,$4B,$4C,$4D,$4E,$41,$4F,$50,$40,$40,$40,$40,$40,$51; $D803: 40 40 4A 4B 4C 4D 4E 41 4F 50 40 40 40 40 40 51
  .byte $52,$53,$54,$55,$40,$40,$40,$40,$40,$56,$57,$58; $D813: 52 53 54 55 40 40 40 40 40 56 57 58
Loc_D81F:
; --- Code Region ---
  EOR $405A,Y                           ; $D81F: 59 5A 40
  RTI                                   ; $D822: 40
; --- Data Region ---
  .byte $40,$40,$40,$5B,$5C,$5D,$5E,$5F,$60,$40,$40,$40,$61,$62,$63,$64; $D823: 40 40 40 5B 5C 5D 5E 5F 60 40 40 40 61 62 63 64
  .byte $65,$66,$40,$67,$68,$69,$6A,$6B,$6C,$6D,$6E,$6F,$70,$71,$72,$73; $D833: 65 66 40 67 68 69 6A 6B 6C 6D 6E 6F 70 71 72 73
  .byte $40,$74,$75,$76,$77,$78,$79,$7A,$7B,$7C,$40,$7D,$7E,$7F,$DC,$00; $D843: 40 74 75 76 77 78 79 7A 7B 7C 40 7D 7E 7F DC 00
  .byte $30,$31,$21,$0F,$10,$15,$56,$57,$58,$59,$57,$59,$56,$57,$58,$59; $D853: 30 31 21 0F 10 15 56 57 58 59 57 59 56 57 58 59
  .byte $5A,$5B,$5C,$5D,$5B,$5D,$5A,$5B,$5C,$5D,$5E; $D863: 5A 5B 5C 5D 5B 5D 5A 5B 5C 5D 5E
Loc_D86E:
; --- Code Region ---
  SRE $6160,X                           ; $D86E: 5F 60 61
  SRE $5E61,X                           ; $D871: 5F 61 5E
  SRE $6160,X                           ; $D874: 5F 60 61
  JAM                                   ; $D877: 62
  JAM                                   ; $D878: 62
  JAM                                   ; $D879: 62
  JAM                                   ; $D87A: 62
  JAM                                   ; $D87B: 62
  JAM                                   ; $D87C: 62
  JAM                                   ; $D87D: 62
  JAM                                   ; $D87E: 62
  JAM                                   ; $D87F: 62
  JAM                                   ; $D880: 62
  ROR $6E6E                             ; $D881: 6E 6E 6E
  ROR $6E6E                             ; $D884: 6E 6E 6E
  ROR $6E6E                             ; $D887: 6E 6E 6E
  ROR $6E6E                             ; $D88A: 6E 6E 6E
  ROR $6E6E                             ; $D88D: 6E 6E 6E
  ROR $6E6E                             ; $D890: 6E 6E 6E
  ROR $6E6E                             ; $D893: 6E 6E 6E
  ROR $6E6E                             ; $D896: 6E 6E 6E
  ROR $6E6E                             ; $D899: 6E 6E 6E
  ROR $6E6E                             ; $D89C: 6E 6E 6E
  RRA $7170                             ; $D89F: 6F 70 71
  RRA $7170                             ; $D8A2: 6F 70 71
  RRA $7170                             ; $D8A5: 6F 70 71
  RRA $6C6B                             ; $D8A8: 6F 6B 6C
  ADC $6C6B                             ; $D8AB: 6D 6B 6C
  ADC $6C6B                             ; $D8AE: 6D 6B 6C
  ADC $016B                             ; $D8B1: 6D 6B 01
  ORA ($01,X)                           ; $D8B4: 01 01
  ORA ($01,X)                           ; $D8B6: 01 01
  ORA ($01,X)                           ; $D8B8: 01 01
  ORA ($01,X)                           ; $D8BA: 01 01
  ORA ($E3,X)                           ; $D8BC: 01 E3
  BRK                                   ; $D8BE: 00
  ROL $27,X                             ; $D8BF: 36 27
  SLO $36,X                             ; $D8C1: 17 36
  RLA $17                               ; $D8C3: 27 17
  ORA ($01,X)                           ; $D8C5: 01 01
  ORA ($01,X)                           ; $D8C7: 01 01
  ORA ($01,X)                           ; $D8C9: 01 01
  ORA ($01,X)                           ; $D8CB: 01 01
  ORA ($01,X)                           ; $D8CD: 01 01
  ORA ($01,X)                           ; $D8CF: 01 01
  ORA ($01,X)                           ; $D8D1: 01 01
  ORA ($01,X)                           ; $D8D3: 01 01
  ORA ($01,X)                           ; $D8D5: 01 01
  ORA ($01,X)                           ; $D8D7: 01 01
  ORA ($01,X)                           ; $D8D9: 01 01
  ORA ($01,X)                           ; $D8DB: 01 01
  ORA ($01,X)                           ; $D8DD: 01 01
  ORA ($01,X)                           ; $D8DF: 01 01
  ORA ($01,X)                           ; $D8E1: 01 01
  ORA ($01,X)                           ; $D8E3: 01 01
  ORA ($01,X)                           ; $D8E5: 01 01
  ORA ($01,X)                           ; $D8E7: 01 01
  ORA ($01,X)                           ; $D8E9: 01 01
  ORA ($01,X)                           ; $D8EB: 01 01
  JAM                                   ; $D8ED: 42
  JAM                                   ; $D8EE: 42
  JAM                                   ; $D8EF: 42
  JAM                                   ; $D8F0: 42
  JAM                                   ; $D8F1: 42
  JAM                                   ; $D8F2: 42
  JAM                                   ; $D8F3: 42
  JAM                                   ; $D8F4: 42
  JAM                                   ; $D8F5: 42
  JAM                                   ; $D8F6: 42
  EOR ($61,X)                           ; $D8F7: 41 61
  JAM                                   ; $D8F9: 62
  RRA ($41,X)                           ; $D8FA: 63 41
  EOR ($41,X)                           ; $D8FC: 41 41
  EOR ($41,X)                           ; $D8FE: 41 41
  EOR ($43,X)                           ; $D900: 41 43
  ADC ($72),Y                           ; $D902: 71 72
  RRA ($74),Y                           ; $D904: 73 74
  SRE ($43,X)                           ; $D906: 43 43
  SRE ($43,X)                           ; $D908: 43 43
  SRE ($44,X)                           ; $D90A: 43 44
  BRK                                   ; $D90C: 00
  BRK                                   ; $D90D: 00
  BRK                                   ; $D90E: 00
  ROR $67                               ; $D90F: 66 67
  PLA                                   ; $D911: 68
  EOR $46                               ; $D912: 45 46
  SRE $6A                               ; $D914: 47 6A
  BVS $D918                             ; $D916: 70 00
Loc_D918:
  ADC $76,X                             ; $D918: 75 76
  RRA $48,X                             ; $D91A: 77 48
  EOR #$4A                              ; $D91C: 49 4A
  ALR #$79                              ; $D91E: 4B 79
  NOP                                   ; $D920: 7A
  RRA $7D7C,Y                           ; $D921: 7B 7C 7D
  ROR $4D4C,X                           ; $D924: 7E 4C 4D
  EOR ($52),Y                           ; $D927: 51 52
  LDA $20BE,X                           ; $D929: BD BE 20
  SLO $36,X                             ; $D92C: 17 36
  JSR $3617                             ; $D92E: 20 17 36
  BVS $D9A4                             ; $D931: 70 71
  JAM                                   ; $D933: 72
  RRA ($74),Y                           ; $D934: 73 74
  ADC $76,X                             ; $D936: 75 76
  RRA $78,X                             ; $D938: 77 78
  BVS $D9AC                             ; $D93A: 70 70
  ADC ($72),Y                           ; $D93C: 71 72
  RRA ($74),Y                           ; $D93E: 73 74
  ADC $76,X                             ; $D940: 75 76
  RRA $78,X                             ; $D942: 77 78
  ADC $7A70,Y                           ; $D944: 79 70 7A
  RRA $7D7C,Y                           ; $D947: 7B 7C 7D
  ROR $007F,X                           ; $D94A: 7E 7F 00
  ORA ($02,X)                           ; $D94D: 01 02
  SLO ($03,X)                           ; $D94F: 03 03
  NOP $05                               ; $D951: 04 05
  ASL $07                               ; $D953: 06 07
  PHP                                   ; $D955: 08
  NOP #$80                              ; $D956: 80 80
  ORA #$39                              ; $D958: 09 39
  AND $0B0A,Y                           ; $D95A: 39 0A 0B
  NOP $0E0D                             ; $D95D: 0C 0D 0E
  NOP #$80                              ; $D960: 80 80
  SLO $1110                             ; $D962: 0F 10 11
  JAM                                   ; $D965: 12
  SLO ($14),Y                           ; $D966: 13 14
  ORA $16,X                             ; $D968: 15 16
  NOP #$80                              ; $D96A: 80 80
  SLO $18,X                             ; $D96C: 17 18
  ORA $1B1A,Y                           ; $D96E: 19 1A 1B
  NOP $1E1D,X                           ; $D971: 1C 1D 1E
  SLO $2120,X                           ; $D974: 1F 20 21
  JAM                                   ; $D977: 22
  RLA ($24,X)                           ; $D978: 23 24
  AND $26                               ; $D97A: 25 26
  RLA $28                               ; $D97C: 27 28
  AND #$2A                              ; $D97E: 29 2A
  ANC #$39                              ; $D980: 2B 39
  BIT $2E2D                             ; $D982: 2C 2D 2E
  RLA $3130                             ; $D985: 2F 30 31
  JAM                                   ; $D988: 32
  AND $3939,Y                           ; $D989: 39 39 39
  RLA ($34),Y                           ; $D98C: 33 34
  AND $36,X                             ; $D98E: 35 36
  RLA $38,X                             ; $D990: 37 38
  AND $3939,Y                           ; $D992: 39 39 39
  DCP ($00),Y                           ; $D995: D3 00
  BPL $D9B0                             ; $D997: 10 17
  ORA ($10),Y                           ; $D999: 11 10
  SLO $11,X                             ; $D99B: 17 11
  JAM                                   ; $D99D: 42
  SRE ($41,X)                           ; $D99E: 43 41
  NOP $45                               ; $D9A0: 44 45
  LSR $47                               ; $D9A2: 46 47
Loc_D9A4:
  EOR ($41,X)                           ; $D9A4: 41 41
  PHA                                   ; $D9A6: 48
  EOR #$4A                              ; $D9A7: 49 4A
  EOR ($4B,X)                           ; $D9A9: 41 4B
  JMP $4E4D                             ; $D9AB: 4C 4D 4E
  SRE $5150                             ; $D9AE: 4F 50 51
  JAM                                   ; $D9B1: 52
  SRE ($54),Y                           ; $D9B2: 53 54
  EOR $56,X                             ; $D9B4: 55 56
  SRE $40,X                             ; $D9B6: 57 40
  RTI                                   ; $D9B8: 40
; --- Data Region ---
  .byte $58,$59,$5A,$5B,$40,$5C,$5D,$40,$40,$40,$5E,$5F,$60,$61,$62,$63; $D9B9: 58 59 5A 5B 40 5C 5D 40 40 40 5E 5F 60 61 62 63
  .byte $64,$40,$65,$66,$67,$68,$69,$6A,$6B,$6C,$40,$6E,$40,$40,$6F,$70; $D9C9: 64 40 65 66 67 68 69 6A 6B 6C 40 6E 40 40 6F 70
  .byte $40,$6E,$40,$6E,$71,$72,$73,$40,$40,$40,$6E,$40,$6E,$40,$74,$75; $D9D9: 40 6E 40 6E 71 72 73 40 40 40 6E 40 6E 40 74 75
  .byte $75,$76,$77,$78,$40,$6E,$40,$6E,$40,$75,$75,$79,$7A,$7B,$6E,$40; $D9E9: 75 76 77 78 40 6E 40 6E 40 75 75 79 7A 7B 6E 40
  .byte $6E,$6E,$40,$6D,$7C,$7D,$7E,$7F,$CA,$CB,$16,$36,$17,$16,$36,$17; $D9F9: 6E 6E 40 6D 7C 7D 7E 7F CA CB 16 36 17 16 36 17
  .byte $71,$72,$73,$74,$74,$74,$74,$75,$76,$74,$77,$78,$79,$74,$74,$74; $DA09: 71 72 73 74 74 74 74 75 76 74 77 78 79 74 74 74
  .byte $74,$7A,$7B,$7C,$7D,$7E,$74,$7F,$00,$01,$02,$03,$04,$05,$06,$07; $DA19: 74 7A 7B 7C 7D 7E 74 7F 00 01 02 03 04 05 06 07
  .byte $08,$09,$0A,$0B,$0C,$0D,$74,$0E,$0F,$10,$11,$12,$3D,$3D,$13,$14; $DA29: 08 09 0A 0B 0C 0D 74 0E 0F 10 11 12 3D 3D 13 14
  .byte $15,$74,$16,$17,$18,$19,$3D,$3D,$1A,$1B,$1C,$1D,$1E,$1F,$20,$21; $DA39: 15 74 16 17 18 19 3D 3D 1A 1B 1C 1D 1E 1F 20 21
  .byte $22,$23,$24,$25,$26,$27,$28,$29,$2A,$2B,$2C,$2D,$2E,$2F,$3D,$3D; $DA49: 22 23 24 25 26 27 28 29 2A 2B 2C 2D 2E 2F 3D 3D
  .byte $30,$3D,$3D,$31,$32,$33,$34,$35,$3D,$3D,$3D,$3D,$3D,$36,$37,$38; $DA59: 30 3D 3D 31 32 33 34 35 3D 3D 3D 3D 3D 36 37 38
  .byte $39,$3A,$3B,$3C,$BC,$00,$36,$27,$17,$36,$27,$17,$44,$44,$44,$44; $DA69: 39 3A 3B 3C BC 00 36 27 17 36 27 17 44 44 44 44
  .byte $44,$44,$44,$44,$44,$44,$00,$00,$01,$00,$00,$00,$45,$01,$46,$47; $DA79: 44 44 44 44 44 44 00 00 01 00 00 00 45 01 46 47
  .byte $00,$00,$01,$00,$00,$00,$48,$49,$4A,$4B,$00,$00,$00,$00,$00,$00; $DA89: 00 00 01 00 00 00 48 49 4A 4B 00 00 00 00 00 00
  .byte $4C,$4D,$4E,$4F,$50,$00,$00,$00,$00,$51,$52,$53,$54,$55,$56,$57; $DA99: 4C 4D 4E 4F 50 00 00 00 00 51 52 53 54 55 56 57
  .byte $58,$59,$5A,$5B,$5C,$5D,$5E,$5F,$60,$61,$62,$63,$64,$65,$66,$67; $DAA9: 58 59 5A 5B 5C 5D 5E 5F 60 61 62 63 64 65 66 67
  .byte $68,$69,$6A,$6B,$6C,$6D,$01,$6E,$6F,$70,$01,$71,$72,$73,$74,$75; $DAB9: 68 69 6A 6B 6C 6D 01 6E 6F 70 01 71 72 73 74 75
  .byte $76,$77,$78,$79,$7A,$7B,$7C,$7D,$7C,$7D,$7E,$7F,$40,$41,$42,$43; $DAC9: 76 77 78 79 7A 7B 7C 7D 7C 7D 7E 7F 40 41 42 43
  .byte $B6,$B7,$30,$36,$17,$30,$36,$17,$41,$42,$43,$44,$41,$41,$41,$41; $DAD9: B6 B7 30 36 17 30 36 17 41 42 43 44 41 41 41 41
  .byte $41,$41,$41,$49,$4A,$4B,$41,$41,$41,$41,$41,$41,$41,$50,$51,$52; $DAE9: 41 41 41 49 4A 4B 41 41 41 41 41 41 41 50 51 52
  .byte $41,$41,$41,$41,$41,$41,$57,$58,$59,$5A,$5B,$5C,$41,$41,$41,$41; $DAF9: 41 41 41 41 41 41 57 58 59 5A 5B 5C 41 41 41 41
  .byte $61,$62,$63,$64,$65,$40,$40,$40,$41,$41,$68,$69,$6A; $DB09: 61 62 63 64 65 40 40 40 41 41 68 69 6A
Loc_DB16:
; --- Code Region ---
  ARR #$6C                              ; $DB16: 6B 6C
  RTI                                   ; $DB18: 40
; --- Data Region ---
  .byte $40,$40,$41,$41,$6F,$70,$71,$72,$40,$40,$40,$40,$41,$73,$74,$75; $DB19: 40 40 41 41 6F 70 71 72 40 40 40 40 41 73 74 75
  .byte $76,$40,$40,$40,$40,$40,$77,$78,$79,$7A,$7B,$40,$40,$7C,$7D,$7E; $DB29: 76 40 40 40 40 40 77 78 79 7A 7B 40 40 7C 7D 7E
  .byte $41,$40,$7F,$00,$01,$40,$40,$02,$41,$41,$41,$40,$AA,$00,$36,$10; $DB39: 41 40 7F 00 01 40 40 02 41 41 41 40 AA 00 36 10
Loc_DB49:
; --- Code Region ---
  ASL $10,X                             ; $DB49: 16 10
  ASL $17                               ; $DB4B: 06 17
  RTI                                   ; $DB4D: 40
; --- Data Region ---
  .byte $41,$42,$43,$44,$45,$46,$47,$48,$49,$4A,$4B,$4C,$4D,$4E,$4F,$50; $DB4E: 41 42 43 44 45 46 47 48 49 4A 4B 4C 4D 4E 4F 50
  .byte $51,$52,$53,$00,$54,$55,$56,$72,$72,$57,$58,$59,$5A,$5B,$5C,$5D; $DB5E: 51 52 53 00 54 55 56 72 72 57 58 59 5A 5B 5C 5D
  .byte $5E,$72,$72,$5F,$60,$61,$62,$63,$64,$65,$72,$00,$00,$72,$66,$67; $DB6E: 5E 72 72 5F 60 61 62 63 64 65 72 00 00 72 66 67
  .byte $68,$69,$6A,$72,$72,$00,$00,$72,$6B,$6C,$6D,$6E,$6F,$72,$00,$00; $DB7E: 68 69 6A 72 72 00 00 72 6B 6C 6D 6E 6F 72 00 00
  .byte $00,$72,$72,$72,$72,$70,$71,$72,$00,$00,$00,$00,$72,$72,$72,$72; $DB8E: 00 72 72 72 72 70 71 72 00 00 00 00 72 72 72 72
  .byte $72,$72,$00,$00,$00,$00,$72,$72,$72,$72,$72,$00,$00,$00,$00,$00; $DB9E: 72 72 00 00 00 00 72 72 72 72 72 00 00 00 00 00
  .byte $00,$72                           ; $DBAE: 00 72
Loc_DBB0:
; --- Code Region ---
  JAM                                   ; $DBB0: 72
Loc_DBB1:
  LDA $0000                             ; $DBB1: AD 00 00
  ASL                                   ; $DBB4: 0A
  TAY                                   ; $DBB5: A8
  LDA $DBCF,Y                           ; $DBB6: B9 CF DB
  STA $000A                             ; $DBB9: 8D 0A 00
  LDA $DBD0,Y                           ; $DBBC: B9 D0 DB
  STA $000B                             ; $DBBF: 8D 0B 00
  LDY #$00                              ; $DBC2: A0 00
Loc_DBC4:
  LDA ($0A),Y                           ; $DBC4: B1 0A
  STA $0100,Y                           ; $DBC6: 99 00 01
  INY                                   ; $DBC9: C8
  CPY #$20                              ; $DBCA: C0 20
  BCC $DBC4                             ; $DBCC: 90 F6
  RTS                                   ; $DBCE: 60
; --- Data Region ---
  .byte $EB,$DB,$0B,$DC,$2B,$DC,$4B,$DC,$6B,$DC,$8B,$DC,$AB,$DC,$CB,$DC; $DBCF: EB DB 0B DC 2B DC 4B DC 6B DC 8B DC AB DC CB DC
  .byte $EB,$DC,$EB,$DC,$0B,$DD,$2B,$DD,$4B,$DD,$6B,$DD,$0F,$12,$1A,$2A; $DBDF: EB DC EB DC 0B DD 2B DD 4B DD 6B DD 0F 12 1A 2A
  .byte $0F,$27,$16,$2A,$0F,$36,$30,$16,$0F,$36,$30,$16,$0F,$0F,$20,$16; $DBEF: 0F 27 16 2A 0F 36 30 16 0F 36 30 16 0F 0F 20 16
  .byte $0F,$0F,$2B,$28,$0F,$36,$30       ; $DBFF: 0F 0F 2B 28 0F 36 30
Loc_DC06:
; --- Code Region ---
  ASL $0F,X                             ; $DC06: 16 0F
  JSR $1727                             ; $DC08: 20 27 17
  SLO $1927                             ; $DC0B: 0F 27 19
  ASL                                   ; $DC0E: 0A
  SLO $1219                             ; $DC0F: 0F 19 12
  JAM                                   ; $DC12: 02
  SLO $2036                             ; $DC13: 0F 36 20
  ASL $0F,X                             ; $DC16: 16 0F
  JSR $2020                             ; $DC18: 20 20 20
  SLO $200F                             ; $DC1B: 0F 0F 20
  ASL $0F,X                             ; $DC1E: 16 0F
  SLO $1727                             ; $DC20: 0F 27 17
  SLO $2720                             ; $DC23: 0F 20 27
  SLO $0F,X                             ; $DC26: 17 0F
  JSR $1727                             ; $DC28: 20 27 17
  SLO $1A29                             ; $DC2B: 0F 29 1A
  ORA #$0F                              ; $DC2E: 09 0F
  AND #$36                              ; $DC30: 29 36
  ASL $0F                               ; $DC32: 06 0F
  ROL $20,X                             ; $DC34: 36 20
  ASL $0F,X                             ; $DC36: 16 0F
  AND #$36                              ; $DC38: 29 36
  NOP $0F,X                             ; $DC3A: 14 0F
  SLO $0636                             ; $DC3C: 0F 36 06
  SLO $360F                             ; $DC3F: 0F 0F 36
  NOP $0F,X                             ; $DC42: 14 0F
  SLO $1620                             ; $DC44: 0F 20 16
  SLO $2720                             ; $DC47: 0F 20 27
  SLO $0F,X                             ; $DC4A: 17 0F
  RLA $17                               ; $DC4C: 27 17
  CLC                                   ; $DC4E: 18
  SLO $3627                             ; $DC4F: 0F 27 36
  ASL $0F                               ; $DC52: 06 0F
  ROL $20,X                             ; $DC54: 36 20
  ASL $0F,X                             ; $DC56: 16 0F
  RLA $36                               ; $DC58: 27 36
  NOP $0F,X                             ; $DC5A: 14 0F
  SLO $0636                             ; $DC5C: 0F 36 06
  SLO $360F                             ; $DC5F: 0F 0F 36
  NOP $0F,X                             ; $DC62: 14 0F
  SLO $1620                             ; $DC64: 0F 20 16
  SLO $2720                             ; $DC67: 0F 20 27
  SLO $0F,X                             ; $DC6A: 17 0F
  RLA $29,X                             ; $DC6C: 37 29
  ORA $370F,Y                           ; $DC6E: 19 0F 37
  ROL $06,X                             ; $DC71: 36 06
  SLO $2036                             ; $DC73: 0F 36 20
  ASL $0F,X                             ; $DC76: 16 0F
  RLA $36,X                             ; $DC78: 37 36
  NOP $0F,X                             ; $DC7A: 14 0F
  SLO $0636                             ; $DC7C: 0F 36 06
  SLO $360F                             ; $DC7F: 0F 0F 36
  NOP $0F,X                             ; $DC82: 14 0F
  SLO $1620                             ; $DC84: 0F 20 16
  SLO $2720                             ; $DC87: 0F 20 27
  SLO $0F,X                             ; $DC8A: 17 0F
  AND ($20,X)                           ; $DC8C: 21 20
  JAM                                   ; $DC8E: 12
  SLO $3621                             ; $DC8F: 0F 21 36
  ASL $0F                               ; $DC92: 06 0F
  ROL $20,X                             ; $DC94: 36 20
  ASL $0F,X                             ; $DC96: 16 0F
  AND ($36,X)                           ; $DC98: 21 36
  NOP $0F,X                             ; $DC9A: 14 0F
  SLO $0636                             ; $DC9C: 0F 36 06
  SLO $360F                             ; $DC9F: 0F 0F 36
  NOP $0F,X                             ; $DCA2: 14 0F
  SLO $1620                             ; $DCA4: 0F 20 16
  SLO $2720                             ; $DCA7: 0F 20 27
  SLO $0F,X                             ; $DCAA: 17 0F
  AND $1929,Y                           ; $DCAC: 39 29 19
  SLO $3639                             ; $DCAF: 0F 39 36
  ASL $0F                               ; $DCB2: 06 0F
  ROL $20,X                             ; $DCB4: 36 20
  ASL $0F,X                             ; $DCB6: 16 0F
  AND $1436,Y                           ; $DCB8: 39 36 14
  SLO $360F                             ; $DCBB: 0F 0F 36
  ASL $0F                               ; $DCBE: 06 0F
  SLO $1436                             ; $DCC0: 0F 36 14
  SLO $200F                             ; $DCC3: 0F 0F 20
  ASL $0F,X                             ; $DCC6: 16 0F
  JSR $1727                             ; $DCC8: 20 27 17
  SLO $0010                             ; $DCCB: 0F 10 00
  JSR $100F                             ; $DCCE: 20 0F 10
  ROL $06,X                             ; $DCD1: 36 06
  SLO $2036                             ; $DCD3: 0F 36 20
  ASL $0F,X                             ; $DCD6: 16 0F
  BPL $DD10                             ; $DCD8: 10 36
  NOP $0F,X                             ; $DCDA: 14 0F
  SLO $0636                             ; $DCDC: 0F 36 06
  SLO $360F                             ; $DCDF: 0F 0F 36
  NOP $0F,X                             ; $DCE2: 14 0F
  SLO $1620                             ; $DCE4: 0F 20 16
  SLO $2720                             ; $DCE7: 0F 20 27
  SLO $0F,X                             ; $DCEA: 17 0F
  AND #$1A                              ; $DCEC: 29 1A
  ORA #$0F                              ; $DCEE: 09 0F
  AND #$36                              ; $DCF0: 29 36
  ASL $0F                               ; $DCF2: 06 0F
  ROL $20,X                             ; $DCF4: 36 20
  ASL $0F,X                             ; $DCF6: 16 0F
  AND #$36                              ; $DCF8: 29 36
  NOP $0F,X                             ; $DCFA: 14 0F
  SLO $0636                             ; $DCFC: 0F 36 06
  SLO $360F                             ; $DCFF: 0F 0F 36
  NOP $0F,X                             ; $DD02: 14 0F
  SLO $1620                             ; $DD04: 0F 20 16
  SLO $2720                             ; $DD07: 0F 20 27
  SLO $0F,X                             ; $DD0A: 17 0F
  SLO $18,X                             ; $DD0C: 17 18
  ROL $0F,X                             ; $DD0E: 36 0F
Loc_DD10:
  SLO $20,X                             ; $DD10: 17 20
  ROL $0F,X                             ; $DD12: 36 0F
  ROL $20,X                             ; $DD14: 36 20
  ASL $0F,X                             ; $DD16: 16 0F
  SLO $16,X                             ; $DD18: 17 16
  ROL $0F,X                             ; $DD1A: 36 0F
  SLO $18,X                             ; $DD1C: 17 18
  ROL $0F,X                             ; $DD1E: 36 0F
  SLO $20,X                             ; $DD20: 17 20
  ROL $0F,X                             ; $DD22: 36 0F
  SLO $16,X                             ; $DD24: 17 16
  ROL $0F,X                             ; $DD26: 36 0F
  JSR $1727                             ; $DD28: 20 27 17
  SLO $0F10                             ; $DD2B: 0F 10 0F
  BRK                                   ; $DD2E: 00
  SLO $0F16                             ; $DD2F: 0F 16 0F
  BMI $DD43                             ; $DD32: 30 0F
  SLO $07,X                             ; $DD34: 17 07
  AND ($0F,X)                           ; $DD36: 21 0F
  SLO $10,X                             ; $DD38: 17 10
  AND ($0F,X)                           ; $DD3A: 21 0F
  SLO $0A30                             ; $DD3C: 0F 30 0A
  SLO $2816                             ; $DD3F: 0F 16 28
  SLO $300F                             ; $DD42: 0F 0F 30
  BMI $DD77                             ; $DD45: 30 30
  SLO $0706                             ; $DD47: 0F 06 07
  AND ($0F,X)                           ; $DD4A: 21 0F
  ROL $30,X                             ; $DD4C: 36 30
  ASL $0F,X                             ; $DD4E: 16 0F
  RLA $16                               ; $DD50: 27 16
  ROL                                   ; $DD52: 2A
  SLO $3036                             ; $DD53: 0F 36 30
  ASL $0F,X                             ; $DD56: 16 0F
  ROL $30,X                             ; $DD58: 36 30
  ASL $0F,X                             ; $DD5A: 16 0F
  SLO $1620                             ; $DD5C: 0F 20 16
  SLO $2B0F                             ; $DD5F: 0F 0F 2B
  PLP                                   ; $DD62: 28
  SLO $3036                             ; $DD63: 0F 36 30
  ASL $0F,X                             ; $DD66: 16 0F
  JSR $1727                             ; $DD68: 20 27 17
  SLO $0F0F                             ; $DD6B: 0F 0F 0F
  SLO $0F0F                             ; $DD6E: 0F 0F 0F
  SLO $0F0F                             ; $DD71: 0F 0F 0F
  SLO $0F0F                             ; $DD74: 0F 0F 0F
Loc_DD77:
  SLO $0F0F                             ; $DD77: 0F 0F 0F
  SLO $0F0F                             ; $DD7A: 0F 0F 0F
  SLO $0F0F                             ; $DD7D: 0F 0F 0F
  SLO $0F0F                             ; $DD80: 0F 0F 0F
  SLO $0F0F                             ; $DD83: 0F 0F 0F
  SLO $0F0F                             ; $DD86: 0F 0F 0F
  SLO $AD0F                             ; $DD89: 0F 0F AD
  SRE ($6F,X)                           ; $DD8C: 43 6F
  PHA                                   ; $DD8E: 48
  LDA #$60                              ; $DD8F: A9 60
  STA $0001                             ; $DD91: 8D 01 00
  LDA #$00                              ; $DD94: A9 00
  STA $0000                             ; $DD96: 8D 00 00
  TAY                                   ; $DD99: A8
Loc_DD9A:
  STA ($00),Y                           ; $DD9A: 91 00
  INY                                   ; $DD9C: C8
  BNE $DD9A                             ; $DD9D: D0 FB
  INC $0001                             ; $DD9F: EE 01 00
  LDX $0001                             ; $DDA2: AE 01 00
  CPX #$70                              ; $DDA5: E0 70
  BCC $DD9A                             ; $DDA7: 90 F1
  PLA                                   ; $DDA9: 68
  STA $6F43                             ; $DDAA: 8D 43 6F
Loc_DDAD:
  JSR $E87A                             ; $DDAD: 20 7A E8
  AND #$07                              ; $DDB0: 29 07
  CMP #$05                              ; $DDB2: C9 05
  BCS $DDAD                             ; $DDB4: B0 F7
  STA $6F45                             ; $DDB6: 8D 45 6F
  LDA #$FF                              ; $DDB9: A9 FF
  STA $6F04                             ; $DDBB: 8D 04 6F
  LDA #$FF                              ; $DDBE: A9 FF
  STA $6FE2                             ; $DDC0: 8D E2 6F
  LDA #$0B                              ; $DDC3: A9 0B
  STA $0400                             ; $DDC5: 8D 00 04
  LDA #$00                              ; $DDC8: A9 00
  STA $0401                             ; $DDCA: 8D 01 04
  LDY #$30                              ; $DDCD: A0 30
  JSR $F25F                             ; $DDCF: 20 5F F2
  LDA #$00                              ; $DDD2: A9 00
  STA $0000                             ; $DDD4: 8D 00 00
  LDA #$8C                              ; $DDD7: A9 8C
  STA $0001                             ; $DDD9: 8D 01 00
  LDA #$00                              ; $DDDC: A9 00
  STA $0002                             ; $DDDE: 8D 02 00
  LDA #$60                              ; $DDE1: A9 60
  STA $0003                             ; $DDE3: 8D 03 00
  LDY #$00                              ; $DDE6: A0 00
  LDX #$00                              ; $DDE8: A2 00
  STX $0004                             ; $DDEA: 8E 04 00
Loc_DDED:
  LDA ($00),Y                           ; $DDED: B1 00
  STA ($02),Y                           ; $DDEF: 91 02
  INC $0000                             ; $DDF1: EE 00 00
  BNE $DDF9                             ; $DDF4: D0 03
  INC $0001                             ; $DDF6: EE 01 00
Loc_DDF9:
  INC $0002                             ; $DDF9: EE 02 00
  BNE $DE01                             ; $DDFC: D0 03
  INC $0003                             ; $DDFE: EE 03 00
Loc_DE01:
  INX                                   ; $DE01: E8
  BNE $DE07                             ; $DE02: D0 03
  INC $0004                             ; $DE04: EE 04 00
Loc_DE07:
  LDA $0004                             ; $DE07: AD 04 00
  CMP #$03                              ; $DE0A: C9 03
  BCC $DDED                             ; $DE0C: 90 DF
  CPX #$C0                              ; $DE0E: E0 C0
  BCC $DDED                             ; $DE10: 90 DB
  LDY #$31                              ; $DE12: A0 31
  JSR $F25F                             ; $DE14: 20 5F F2
  LDA #$00                              ; $DE17: A9 00
  STA $0000                             ; $DE19: 8D 00 00
  LDA #$80                              ; $DE1C: A9 80
  STA $0001                             ; $DE1E: 8D 01 00
  LDA #$C0                              ; $DE21: A9 C0
  STA $0002                             ; $DE23: 8D 02 00
  LDA #$63                              ; $DE26: A9 63
  STA $0003                             ; $DE28: 8D 03 00
  LDY #$00                              ; $DE2B: A0 00
  LDX #$00                              ; $DE2D: A2 00
  STX $0004                             ; $DE2F: 8E 04 00
Loc_DE32:
  LDA ($00),Y                           ; $DE32: B1 00
  STA ($02),Y                           ; $DE34: 91 02
  INC $0000                             ; $DE36: EE 00 00
  BNE $DE3E                             ; $DE39: D0 03
  INC $0001                             ; $DE3B: EE 01 00
Loc_DE3E:
  INC $0002                             ; $DE3E: EE 02 00
  BNE $DE46                             ; $DE41: D0 03
  INC $0003                             ; $DE43: EE 03 00
Loc_DE46:
  INX                                   ; $DE46: E8
  BNE $DE4C                             ; $DE47: D0 03
  INC $0004                             ; $DE49: EE 04 00
Loc_DE4C:
  LDA $0004                             ; $DE4C: AD 04 00
  CMP #$0B                              ; $DE4F: C9 0B
  BCC $DE32                             ; $DE51: 90 DF
  CPX #$40                              ; $DE53: E0 40
  BCC $DE32                             ; $DE55: 90 DB
  LDA #$59                              ; $DE57: A9 59
  STA $6F00                             ; $DE59: 8D 00 6F
  LDA #$00                              ; $DE5C: A9 00
  STA $6F01                             ; $DE5E: 8D 01 6F
  LDA #$FF                              ; $DE61: A9 FF
  STA $6F83                             ; $DE63: 8D 83 6F
  STA $6F84                             ; $DE66: 8D 84 6F
  STA $6F85                             ; $DE69: 8D 85 6F
  STA $6F86                             ; $DE6C: 8D 86 6F
  STA $6F87                             ; $DE6F: 8D 87 6F
  STA $6F88                             ; $DE72: 8D 88 6F
  STA $6F89                             ; $DE75: 8D 89 6F
  LDA #$00                              ; $DE78: A9 00
  STA $6F8A                             ; $DE7A: 8D 8A 6F
  RTS                                   ; $DE7D: 60
Loc_DE7E:
  LDY #$21                              ; $DE7E: A0 21
  JSR $F25F                             ; $DE80: 20 5F F2
  LDY #$00                              ; $DE83: A0 00
  STY $0001                             ; $DE85: 8C 01 00
  STA $0000                             ; $DE88: 8D 00 00
  ASL                                   ; $DE8B: 0A
  CLC                                   ; $DE8C: 18
  ADC $0000                             ; $DE8D: 6D 00 00
  ASL                                   ; $DE90: 0A
  ROL $0001                             ; $DE91: 2E 01 00
  ASL                                   ; $DE94: 0A
  ROL $0001                             ; $DE95: 2E 01 00
  ASL                                   ; $DE98: 0A
  ROL $0001                             ; $DE99: 2E 01 00
  ASL                                   ; $DE9C: 0A
  ROL $0001                             ; $DE9D: 2E 01 00
  CLC                                   ; $DEA0: 18
  ADC #$6C                              ; $DEA1: 69 6C
  STA $0002                             ; $DEA3: 8D 02 00
  LDA #$94                              ; $DEA6: A9 94
  ADC $0001                             ; $DEA8: 6D 01 00
  STA $0003                             ; $DEAB: 8D 03 00
Loc_DEAE:
  LDA ($02),Y                           ; $DEAE: B1 02
  STA $00AE,Y                           ; $DEB0: 99 AE 00
  INY                                   ; $DEB3: C8
  CPY #$30                              ; $DEB4: C0 30
  BCC $DEAE                             ; $DEB6: 90 F6
  RTS                                   ; $DEB8: 60
Loc_DEB9:
  STA $0000                             ; $DEB9: 8D 00 00
  TAX                                   ; $DEBC: AA
  ASL                                   ; $DEBD: 0A
  ASL                                   ; $DEBE: 0A
  CLC                                   ; $DEBF: 18
  ADC $0000                             ; $DEC0: 6D 00 00
  ASL                                   ; $DEC3: 0A
  TAY                                   ; $DEC4: A8
  LDA $DF1A,Y                           ; $DEC5: B9 1A DF
  STA $0068                             ; $DEC8: 8D 68 00
  LDA $DF1B,Y                           ; $DECB: B9 1B DF
  STA $0069                             ; $DECE: 8D 69 00
  LDA $DF1C,Y                           ; $DED1: B9 1C DF
  STA $006A                             ; $DED4: 8D 6A 00
  LDA $DF1D,Y                           ; $DED7: B9 1D DF
  STA $006B                             ; $DEDA: 8D 6B 00
  LDA $DF1E,Y                           ; $DEDD: B9 1E DF
  STA $006C                             ; $DEE0: 8D 6C 00
  LDA $DF1F,Y                           ; $DEE3: B9 1F DF
  STA $006D                             ; $DEE6: 8D 6D 00
  LDA $DF20,Y                           ; $DEE9: B9 20 DF
  STA $006E                             ; $DEEC: 8D 6E 00
  LDA $DF21,Y                           ; $DEEF: B9 21 DF
  STA $006F                             ; $DEF2: 8D 6F 00
  LDA $DF22,Y                           ; $DEF5: B9 22 DF
  STA $0070                             ; $DEF8: 8D 70 00
  LDA $DF23,Y                           ; $DEFB: B9 23 DF
  STA $0071                             ; $DEFE: 8D 71 00
  LDA $DF56,X                           ; $DF01: BD 56 DF
  STA $0072                             ; $DF04: 8D 72 00
  LDA $DF5C,X                           ; $DF07: BD 5C DF
  STA $0073                             ; $DF0A: 8D 73 00
  LDA $DF62,X                           ; $DF0D: BD 62 DF
  STA $0074                             ; $DF10: 8D 74 00
  LDA $DF68,X                           ; $DF13: BD 68 DF
  STA $0061                             ; $DF16: 8D 61 00
Loc_DF19:
  RTS                                   ; $DF19: 60
; --- Data Region ---
  .byte $40,$E9,$14,$F2,$1E               ; $DF1A: 40 E9 14 F2 1E
Loc_DF1F:
; --- Code Region ---
  JAM                                   ; $DF1F: F2
  JSR $FAF2                             ; $DF20: 20 F2 FA
  SBC ($6C),Y                           ; $DF23: F1 6C
  BCS $DF47                             ; $DF25: B0 20
  JAM                                   ; $DF27: F2
  JSR $20F2                             ; $DF28: 20 F2 20
  JAM                                   ; $DF2B: F2
  BNE $DF1F                             ; $DF2C: D0 F1
  BVC $DF19                             ; $DF2E: 50 E9
  RTI                                   ; $DF30: 40
; --- Data Region ---
  .byte $F2,$BA,$D5,$20,$F2,$80,$F1       ; $DF31: F2 BA D5 20 F2 80 F1
Loc_DF38:
; --- Code Region ---
  RTI                                   ; $DF38: 40
; --- Data Region ---
  .byte $E9,$30,$F2,$A0,$F2,$F0,$F8       ; $DF39: E9 30 F2 A0 F2 F0 F8
Loc_DF40:
; --- Code Region ---
  JSR $A0EA                             ; $DF40: 20 EA A0
  SBC #$1E                              ; $DF43: E9 1E
  JAM                                   ; $DF45: F2
  NOP $F2,X                             ; $DF46: 14 F2
  JSR $8BF2                             ; $DF48: 20 F2 8B
  SBC ($F0),Y                           ; $DF4B: F1 F0
  ISB $F270                             ; $DF4D: EF 70 F2
  JSR $10F2                             ; $DF50: 20 F2 10
  JAM                                   ; $DF53: F2
  BNE $DF40                             ; $DF54: D0 EA
  RLA $0F0F                             ; $DF56: 2F 0F 0F
  SLO $0F29                             ; $DF59: 0F 29 0F
  ASL $1414                             ; $DF5C: 0E 14 14
  NOP $0E,X                             ; $DF5F: 14 0E
  NOP $0F,X                             ; $DF61: 14 0F
  NOP $14,X                             ; $DF63: 14 14
  NOP $0F,X                             ; $DF65: 14 0F
  NOP $03,X                             ; $DF67: 14 03
  ASL                                   ; $DF69: 0A
  ANC #$08                              ; $DF6A: 0B 08
  SLO ($03,X)                           ; $DF6C: 03 03
  ISB $FFFF,X                           ; $DF6E: FF FF FF
  ISB $FFFF,X                           ; $DF71: FF FF FF
  ISB $FFFF,X                           ; $DF74: FF FF FF
  ISB $FFFF,X                           ; $DF77: FF FF FF
  ISB $FFFF,X                           ; $DF7A: FF FF FF
  ISB $FFFF,X                           ; $DF7D: FF FF FF
  ISB $FFFF,X                           ; $DF80: FF FF FF
  ISB $FFFF,X                           ; $DF83: FF FF FF
  ISB $FFFF,X                           ; $DF86: FF FF FF
  ISB $FFFF,X                           ; $DF89: FF FF FF
  ISB $FFFF,X                           ; $DF8C: FF FF FF
  ISB $FFFF,X                           ; $DF8F: FF FF FF
  ISB $FFFF,X                           ; $DF92: FF FF FF
  ISB $FFFF,X                           ; $DF95: FF FF FF
  ISB $FFFF,X                           ; $DF98: FF FF FF
  ISB $FFFF,X                           ; $DF9B: FF FF FF
  ISB $FFFF,X                           ; $DF9E: FF FF FF
  ISB $FFFF,X                           ; $DFA1: FF FF FF
  ISB $FFFF,X                           ; $DFA4: FF FF FF
  ISB $FFFF,X                           ; $DFA7: FF FF FF
  ISB $FFFF,X                           ; $DFAA: FF FF FF
  ISB $FFFF,X                           ; $DFAD: FF FF FF
  ISB $FFFF,X                           ; $DFB0: FF FF FF
  ISB $FFFF,X                           ; $DFB3: FF FF FF
  ISB $FFFF,X                           ; $DFB6: FF FF FF
  ISB $FFFF,X                           ; $DFB9: FF FF FF
  ISB $FFFF,X                           ; $DFBC: FF FF FF
  ISB $FFFF,X                           ; $DFBF: FF FF FF
  ISB $FFFF,X                           ; $DFC2: FF FF FF
  ISB $FFFF,X                           ; $DFC5: FF FF FF
  ISB $FFFF,X                           ; $DFC8: FF FF FF
  ISB $FFFF,X                           ; $DFCB: FF FF FF
  ISB $FFFF,X                           ; $DFCE: FF FF FF
  ISB $FFFF,X                           ; $DFD1: FF FF FF
  ISB $FFFF,X                           ; $DFD4: FF FF FF
  ISB $FFFF,X                           ; $DFD7: FF FF FF
  ISB $FFFF,X                           ; $DFDA: FF FF FF
  ISB $FFFF,X                           ; $DFDD: FF FF FF
  ISB $FFFF,X                           ; $DFE0: FF FF FF
  ISB $FFFF,X                           ; $DFE3: FF FF FF
  ISB $FFFF,X                           ; $DFE6: FF FF FF
  ISB $FFFF,X                           ; $DFE9: FF FF FF
  ISB $FFFF,X                           ; $DFEC: FF FF FF
  ISB $FFFF,X                           ; $DFEF: FF FF FF
  ISB $FFFF,X                           ; $DFF2: FF FF FF
  ISB $FFFF,X                           ; $DFF5: FF FF FF
  ISB $FFFF,X                           ; $DFF8: FF FF FF
  ISB $FFFF,X                           ; $DFFB: FF FF FF
  .byte $FF                              ; $DFFE: FF
; --- Data Region ---
  .byte $FF                               ; $DFFF: FF
