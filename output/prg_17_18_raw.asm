Loc_A000:  ; (dispatch callback target)
  JMP $A087                             ; $A000: 4C 87 A0
Loc_A003:
  JMP $A212                             ; $A003: 4C 12 A2
Loc_A006:
  JMP $A24E                             ; $A006: 4C 4E A2
Loc_A009:
  JMP $A2FF                             ; $A009: 4C FF A2
Loc_A00C:
  JMP $A387                             ; $A00C: 4C 87 A3
Loc_A00F:
  JMP $AB53                             ; $A00F: 4C 53 AB
Loc_A012:  ; (dispatch callback target)
  JMP $A61C                             ; $A012: 4C 1C A6
Loc_A015:
  JMP $AEF0                             ; $A015: 4C F0 AE
Loc_A018:
  JMP $A983                             ; $A018: 4C 83 A9
Loc_A01B:
  JMP $B100                             ; $A01B: 4C 00 B1
Loc_A01E:
  JMP $D693                             ; $A01E: 4C 93 D6
Loc_A021:
  JMP $DE25                             ; $A021: 4C 25 DE
Loc_A024:
  JMP $A02A                             ; $A024: 4C 2A A0
Loc_A027:
  JMP $DF15                             ; $A027: 4C 15 DF
Loc_A02A:
  LDY #$21                              ; $A02A: A0 21
  JSR $F25F                             ; $A02C: 20 5F F2
  LDA #$00                              ; $A02F: A9 00
  STA $0000                             ; $A031: 8D 00 00
  LDA #$20                              ; $A034: A9 20
  STA $0001                             ; $A036: 8D 01 00
  JSR $A04A                             ; $A039: 20 4A A0
  LDA #$00                              ; $A03C: A9 00
  STA $0000                             ; $A03E: 8D 00 00
  LDA #$24                              ; $A041: A9 24
  STA $0001                             ; $A043: 8D 01 00
  JSR $A04A                             ; $A046: 20 4A A0
  RTS                                   ; $A049: 60
Loc_A04A:
  LDA $0544                             ; $A04A: AD 44 05
  ASL                                   ; $A04D: 0A
  TAY                                   ; $A04E: A8
  LDA $A06B,Y                           ; $A04F: B9 6B A0
  STA $000A                             ; $A052: 8D 0A 00
  LDA $A06C,Y                           ; $A055: B9 6C A0
  STA $000B                             ; $A058: 8D 0B 00
  LDA $A079,Y                           ; $A05B: B9 79 A0
  STA $000C                             ; $A05E: 8D 0C 00
  LDA $A07A,Y                           ; $A061: B9 7A A0
  STA $000D                             ; $A064: 8D 0D 00
  JSR $A24E                             ; $A067: 20 4E A2
  RTS                                   ; $A06A: 60
; --- Data Region ---
  .byte $40,$84,$70,$85,$A0,$86,$D0,$87,$00,$89,$30,$8A,$60,$8B,$00,$80; $A06B: 40 84 70 85 A0 86 D0 87 00 89 30 8A 60 8B 00 80
  .byte $00,$80,$00,$80,$00,$80,$00,$80,$00,$80,$00,$80; $A07B: 00 80 00 80 00 80 00 80 00 80 00 80
Loc_A087:
; --- Code Region ---
  LDA $008B                             ; $A087: AD 8B 00
  AND #$FB                              ; $A08A: 29 FB
  STA $2000                             ; $A08C: 8D 00 20
  LDA $2002                             ; $A08F: AD 02 20
  LDA $0001                             ; $A092: AD 01 00
  STA $2006                             ; $A095: 8D 06 20
  LDA $0000                             ; $A098: AD 00 00
  STA $2006                             ; $A09B: 8D 06 20
  LDY #$00                              ; $A09E: A0 00
  LDA ($0A),Y                           ; $A0A0: B1 0A
  STA $0002                             ; $A0A2: 8D 02 00
  JSR $A0D2                             ; $A0A5: 20 D2 A0
Loc_A0A8:
  LDA ($0A),Y                           ; $A0A8: B1 0A
  CMP $0002                             ; $A0AA: CD 02 00
  BEQ $A0B8                             ; $A0AD: F0 09
  STA $2007                             ; $A0AF: 8D 07 20
  JSR $A0D2                             ; $A0B2: 20 D2 A0
  JMP $A0A8                             ; $A0B5: 4C A8 A0
Loc_A0B8:
  JSR $A0D2                             ; $A0B8: 20 D2 A0
  LDA ($0A),Y                           ; $A0BB: B1 0A
  TAX                                   ; $A0BD: AA
  BEQ $A0D1                             ; $A0BE: F0 11
  JSR $A0D2                             ; $A0C0: 20 D2 A0
  LDA ($0A),Y                           ; $A0C3: B1 0A
Loc_A0C5:
  STA $2007                             ; $A0C5: 8D 07 20
  DEX                                   ; $A0C8: CA
  BNE $A0C5                             ; $A0C9: D0 FA
  JSR $A0D2                             ; $A0CB: 20 D2 A0
  JMP $A0A8                             ; $A0CE: 4C A8 A0
Loc_A0D1:
  RTS                                   ; $A0D1: 60
Loc_A0D2:
  LDA $000A                             ; $A0D2: AD 0A 00
  CLC                                   ; $A0D5: 18
  ADC #$01                              ; $A0D6: 69 01
  STA $000A                             ; $A0D8: 8D 0A 00
  LDA $000B                             ; $A0DB: AD 0B 00
  ADC #$00                              ; $A0DE: 69 00
  STA $000B                             ; $A0E0: 8D 0B 00
  RTS                                   ; $A0E3: 60
; --- Data Region ---
  .byte $A9,$00,$8D,$1A,$00,$8D,$1B,$00,$8D,$1C,$00,$8D,$1D,$00,$8D,$1E; $A0E4: A9 00 8D 1A 00 8D 1B 00 8D 1C 00 8D 1D 00 8D 1E
  .byte $00,$8D,$1F,$00,$8D,$04,$00,$8D,$05,$00,$AD,$8B,$00,$29,$FB,$8D; $A0F4: 00 8D 1F 00 8D 04 00 8D 05 00 AD 8B 00 29 FB 8D
  .byte $00,$20,$AD,$02,$20,$AD,$01,$00,$8D,$06,$20,$AD,$00,$00,$8D,$06; $A104: 00 20 AD 02 20 AD 01 00 8D 06 20 AD 00 00 8D 06
  .byte $20,$A0,$00,$B1,$0A,$8D,$1A,$00,$20,$09,$A2,$20,$A5,$A1,$8D,$02; $A114: 20 A0 00 B1 0A 8D 1A 00 20 09 A2 20 A5 A1 8D 02
  .byte $00,$AD,$06,$00,$D0,$3F           ; $A124: 00 AD 06 00 D0 3F
Loc_A12A:
; --- Code Region ---
  JSR $A1A5                             ; $A12A: 20 A5 A1
  CMP $0002                             ; $A12D: CD 02 00
  BEQ $A146                             ; $A130: F0 14
  STA $2007                             ; $A132: 8D 07 20
  INC $0004                             ; $A135: EE 04 00
  BNE $A12A                             ; $A138: D0 F0
  INC $0005                             ; $A13A: EE 05 00
  LDY $0005                             ; $A13D: AC 05 00
  CPY $0007                             ; $A140: CC 07 00
  BCC $A12A                             ; $A143: 90 E5
  RTS                                   ; $A145: 60
Loc_A146:
  JSR $A1A5                             ; $A146: 20 A5 A1
  TAX                                   ; $A149: AA
  BEQ $A168                             ; $A14A: F0 1C
  JSR $A1A5                             ; $A14C: 20 A5 A1
Loc_A14F:
  STA $2007                             ; $A14F: 8D 07 20
  INC $0004                             ; $A152: EE 04 00
  BNE $A162                             ; $A155: D0 0B
  INC $0005                             ; $A157: EE 05 00
  LDY $0005                             ; $A15A: AC 05 00
  CPY $0007                             ; $A15D: CC 07 00
  BCS $A168                             ; $A160: B0 06
Loc_A162:
  DEX                                   ; $A162: CA
  BNE $A14F                             ; $A163: D0 EA
  JMP $A12A                             ; $A165: 4C 2A A1
Loc_A168:
  RTS                                   ; $A168: 60
Loc_A169:
  JSR $A1A5                             ; $A169: 20 A5 A1
  CMP $0002                             ; $A16C: CD 02 00
  BEQ $A184                             ; $A16F: F0 13
  INC $0004                             ; $A171: EE 04 00
  BNE $A169                             ; $A174: D0 F3
  INC $0005                             ; $A176: EE 05 00
  LDY $0005                             ; $A179: AC 05 00
  CPY $0006                             ; $A17C: CC 06 00
  BCC $A169                             ; $A17F: 90 E8
  JMP $A12A                             ; $A181: 4C 2A A1
Loc_A184:
  JSR $A1A5                             ; $A184: 20 A5 A1
  TAX                                   ; $A187: AA
  JSR $A1A5                             ; $A188: 20 A5 A1
Loc_A18B:
  INC $0004                             ; $A18B: EE 04 00
  BNE $A19E                             ; $A18E: D0 0E
  INC $0005                             ; $A190: EE 05 00
  LDY $0005                             ; $A193: AC 05 00
  CPY $0006                             ; $A196: CC 06 00
  BCC $A19E                             ; $A199: 90 03
  JMP $A162                             ; $A19B: 4C 62 A1
Loc_A19E:
  DEX                                   ; $A19E: CA
  BNE $A18B                             ; $A19F: D0 EA
  JMP $A169                             ; $A1A1: 4C 69 A1
; --- Data Region ---
  .byte $60                               ; $A1A4: 60
Loc_A1A5:
; --- Code Region ---
  LDY #$00                              ; $A1A5: A0 00
  LDA $001B                             ; $A1A7: AD 1B 00
  BNE $A1F5                             ; $A1AA: D0 49
  LDA ($0A),Y                           ; $A1AC: B1 0A
  CMP $001A                             ; $A1AE: CD 1A 00
  BNE $A203                             ; $A1B1: D0 50
  LDA $000A                             ; $A1B3: AD 0A 00
  STA $001C                             ; $A1B6: 8D 1C 00
  LDA $000B                             ; $A1B9: AD 0B 00
  STA $001D                             ; $A1BC: 8D 1D 00
  JSR $A209                             ; $A1BF: 20 09 A2
  LDA ($0A),Y                           ; $A1C2: B1 0A
  BEQ $A203                             ; $A1C4: F0 3D
  PHA                                   ; $A1C6: 48
  AND #$0F                              ; $A1C7: 29 0F
  STA $001F                             ; $A1C9: 8D 1F 00
  PLA                                   ; $A1CC: 68
  LSR                                   ; $A1CD: 4A
  LSR                                   ; $A1CE: 4A
  LSR                                   ; $A1CF: 4A
  LSR                                   ; $A1D0: 4A
  CLC                                   ; $A1D1: 18
  ADC #$03                              ; $A1D2: 69 03
  STA $001B                             ; $A1D4: 8D 1B 00
  JSR $A209                             ; $A1D7: 20 09 A2
  LDA ($0A),Y                           ; $A1DA: B1 0A
  STA $001E                             ; $A1DC: 8D 1E 00
  JSR $A209                             ; $A1DF: 20 09 A2
  LDA $001C                             ; $A1E2: AD 1C 00
  SEC                                   ; $A1E5: 38
  SBC $001E                             ; $A1E6: ED 1E 00
  STA $001C                             ; $A1E9: 8D 1C 00
  LDA $001D                             ; $A1EC: AD 1D 00
  SBC $001F                             ; $A1EF: ED 1F 00
  STA $001D                             ; $A1F2: 8D 1D 00
Loc_A1F5:
  LDA ($1C),Y                           ; $A1F5: B1 1C
  INC $001C                             ; $A1F7: EE 1C 00
  BNE $A1FF                             ; $A1FA: D0 03
  INC $001D                             ; $A1FC: EE 1D 00
Loc_A1FF:
  DEC $001B                             ; $A1FF: CE 1B 00
  RTS                                   ; $A202: 60
Loc_A203:
  PHA                                   ; $A203: 48
  JSR $A209                             ; $A204: 20 09 A2
  PLA                                   ; $A207: 68
  RTS                                   ; $A208: 60
Loc_A209:
  INC $000A                             ; $A209: EE 0A 00
  BNE $A211                             ; $A20C: D0 03
  INC $000B                             ; $A20E: EE 0B 00
Loc_A211:
  RTS                                   ; $A211: 60
Loc_A212:
  LDA $008B                             ; $A212: AD 8B 00
  AND #$FB                              ; $A215: 29 FB
  STA $2000                             ; $A217: 8D 00 20
  LDA $2002                             ; $A21A: AD 02 20
  LDA $0001                             ; $A21D: AD 01 00
  STA $2006                             ; $A220: 8D 06 20
  LDA $0000                             ; $A223: AD 00 00
  STA $2006                             ; $A226: 8D 06 20
  LDY #$00                              ; $A229: A0 00
  STY $000C                             ; $A22B: 8C 0C 00
  STY $000D                             ; $A22E: 8C 0D 00
Loc_A231:
  LDA ($0A),Y                           ; $A231: B1 0A
  STA $2007                             ; $A233: 8D 07 20
  INC $000A                             ; $A236: EE 0A 00
  BNE $A23E                             ; $A239: D0 03
  INC $000B                             ; $A23B: EE 0B 00
Loc_A23E:
  INC $000C                             ; $A23E: EE 0C 00
  BNE $A246                             ; $A241: D0 03
  INC $000D                             ; $A243: EE 0D 00
Loc_A246:
  LDA $000D                             ; $A246: AD 0D 00
  CMP #$04                              ; $A249: C9 04
  BCC $A231                             ; $A24B: 90 E4
  RTS                                   ; $A24D: 60
Loc_A24E:
  LDA $008B                             ; $A24E: AD 8B 00
  AND #$FB                              ; $A251: 29 FB
  STA $2000                             ; $A253: 8D 00 20
  LDA $2002                             ; $A256: AD 02 20
  LDA $0001                             ; $A259: AD 01 00
  STA $2006                             ; $A25C: 8D 06 20
  LDA $0000                             ; $A25F: AD 00 00
  STA $2006                             ; $A262: 8D 06 20
  LDA $000A                             ; $A265: AD 0A 00
  SEC                                   ; $A268: 38
  SBC #$40                              ; $A269: E9 40
  PHA                                   ; $A26B: 48
  LDA $000B                             ; $A26C: AD 0B 00
  SBC #$00                              ; $A26F: E9 00
  PHA                                   ; $A271: 48
  LDY #$00                              ; $A272: A0 00
  STY $0002                             ; $A274: 8C 02 00
  STY $0003                             ; $A277: 8C 03 00
Loc_A27A:
  LDY #$00                              ; $A27A: A0 00
  STY $0001                             ; $A27C: 8C 01 00
  LDA ($0A),Y                           ; $A27F: B1 0A
  ASL                                   ; $A281: 0A
  ROL $0001                             ; $A282: 2E 01 00
  ASL                                   ; $A285: 0A
  ROL $0001                             ; $A286: 2E 01 00
  CLC                                   ; $A289: 18
  ADC $000C                             ; $A28A: 6D 0C 00
  STA $0000                             ; $A28D: 8D 00 00
  LDA $0001                             ; $A290: AD 01 00
  ADC $000D                             ; $A293: 6D 0D 00
  STA $0001                             ; $A296: 8D 01 00
  LDA $0002                             ; $A299: AD 02 00
  AND #$10                              ; $A29C: 29 10
  BEQ $A2A2                             ; $A29E: F0 02
  LDY #$02                              ; $A2A0: A0 02
Loc_A2A2:
  LDA ($00),Y                           ; $A2A2: B1 00
  STA $2007                             ; $A2A4: 8D 07 20
  INY                                   ; $A2A7: C8
  LDA ($00),Y                           ; $A2A8: B1 00
  STA $2007                             ; $A2AA: 8D 07 20
  JSR $A2E4                             ; $A2AD: 20 E4 A2
  INC $0002                             ; $A2B0: EE 02 00
  LDA $0002                             ; $A2B3: AD 02 00
  AND #$0F                              ; $A2B6: 29 0F
  BNE $A2C7                             ; $A2B8: D0 0D
  INC $0003                             ; $A2BA: EE 03 00
  LDA $0003                             ; $A2BD: AD 03 00
  AND #$01                              ; $A2C0: 29 01
  BEQ $A2C7                             ; $A2C2: F0 03
  JSR $A2ED                             ; $A2C4: 20 ED A2
Loc_A2C7:
  LDA $0003                             ; $A2C7: AD 03 00
  CMP #$1E                              ; $A2CA: C9 1E
  BCC $A27A                             ; $A2CC: 90 AC
  PLA                                   ; $A2CE: 68
  STA $000B                             ; $A2CF: 8D 0B 00
  PLA                                   ; $A2D2: 68
  STA $000A                             ; $A2D3: 8D 0A 00
  LDX #$40                              ; $A2D6: A2 40
  LDY #$00                              ; $A2D8: A0 00
Loc_A2DA:
  LDA ($0A),Y                           ; $A2DA: B1 0A
  STA $2007                             ; $A2DC: 8D 07 20
  INY                                   ; $A2DF: C8
  DEX                                   ; $A2E0: CA
  BNE $A2DA                             ; $A2E1: D0 F7
  RTS                                   ; $A2E3: 60
Loc_A2E4:
  INC $000A                             ; $A2E4: EE 0A 00
  BNE $A2EC                             ; $A2E7: D0 03
  INC $000B                             ; $A2E9: EE 0B 00
Loc_A2EC:
  RTS                                   ; $A2EC: 60
Loc_A2ED:
  LDA $000A                             ; $A2ED: AD 0A 00
  SEC                                   ; $A2F0: 38
  SBC #$10                              ; $A2F1: E9 10
  STA $000A                             ; $A2F3: 8D 0A 00
  LDA $000B                             ; $A2F6: AD 0B 00
  SBC #$00                              ; $A2F9: E9 00
  STA $000B                             ; $A2FB: 8D 0B 00
  RTS                                   ; $A2FE: 60
Loc_A2FF:
  LDA $008E                             ; $A2FF: AD 8E 00
  PHA                                   ; $A302: 48
  LDA $008F                             ; $A303: AD 8F 00
  PHA                                   ; $A306: 48
  LDA $0090                             ; $A307: AD 90 00
  STA $001E                             ; $A30A: 8D 1E 00
  PHA                                   ; $A30D: 48
  LDA $0091                             ; $A30E: AD 91 00
  STA $001F                             ; $A311: 8D 1F 00
  PHA                                   ; $A314: 48
  INC $0091                             ; $A315: EE 91 00
  LDA #$1E                              ; $A318: A9 1E
Loc_A31A:
  PHA                                   ; $A31A: 48
  JSR $A485                             ; $A31B: 20 85 A4
  JSR $AD9F                             ; $A31E: 20 9F AD
Loc_A321:
  JSR $EEE6                             ; $A321: 20 E6 EE
  LDA $007E                             ; $A324: AD 7E 00
  BNE $A321                             ; $A327: D0 F8
  LDA $0090                             ; $A329: AD 90 00
  SEC                                   ; $A32C: 38
  SBC #$08                              ; $A32D: E9 08
  STA $0090                             ; $A32F: 8D 90 00
  BCS $A33D                             ; $A332: B0 09
  SEC                                   ; $A334: 38
  SBC #$10                              ; $A335: E9 10
  STA $0090                             ; $A337: 8D 90 00
  DEC $0091                             ; $A33A: CE 91 00
Loc_A33D:
  PLA                                   ; $A33D: 68
  SEC                                   ; $A33E: 38
  SBC #$01                              ; $A33F: E9 01
  BPL $A31A                             ; $A341: 10 D7
  PLA                                   ; $A343: 68
  STA $0091                             ; $A344: 8D 91 00
  PLA                                   ; $A347: 68
  STA $0090                             ; $A348: 8D 90 00
  PLA                                   ; $A34B: 68
  STA $008F                             ; $A34C: 8D 8F 00
  PLA                                   ; $A34F: 68
  STA $008E                             ; $A350: 8D 8E 00
  LDA $0090                             ; $A353: AD 90 00
  LSR                                   ; $A356: 4A
  LSR                                   ; $A357: 4A
  LSR                                   ; $A358: 4A
  STA $0092                             ; $A359: 8D 92 00
  LDA $0090                             ; $A35C: AD 90 00
  CLC                                   ; $A35F: 18
  ADC #$08                              ; $A360: 69 08
  LSR                                   ; $A362: 4A
  LSR                                   ; $A363: 4A
  LSR                                   ; $A364: 4A
  LSR                                   ; $A365: 4A
  STA $0094                             ; $A366: 8D 94 00
  LDA $008E                             ; $A369: AD 8E 00
  SEC                                   ; $A36C: 38
  SBC #$06                              ; $A36D: E9 06
  LSR                                   ; $A36F: 4A
  LSR                                   ; $A370: 4A
  LSR                                   ; $A371: 4A
  STA $0095                             ; $A372: 8D 95 00
  LDA $008E                             ; $A375: AD 8E 00
  LSR                                   ; $A378: 4A
  LSR                                   ; $A379: 4A
  LSR                                   ; $A37A: 4A
  STA $0093                             ; $A37B: 8D 93 00
  LDA #$90                              ; $A37E: A9 90
  STA $009C                             ; $A380: 8D 9C 00
  STA $009D                             ; $A383: 8D 9D 00
  RTS                                   ; $A386: 60
Loc_A387:
  LDA $008E                             ; $A387: AD 8E 00
  CMP #$FE                              ; $A38A: C9 FE
  BCC $A391                             ; $A38C: 90 03
  CLC                                   ; $A38E: 18
  ADC #$02                              ; $A38F: 69 02
Loc_A391:
  LSR                                   ; $A391: 4A
  LSR                                   ; $A392: 4A
  LSR                                   ; $A393: 4A
  CMP $0093                             ; $A394: CD 93 00
  BEQ $A39F                             ; $A397: F0 06
  STA $0093                             ; $A399: 8D 93 00
  JSR $A3B1                             ; $A39C: 20 B1 A3
Loc_A39F:
  LDA $0090                             ; $A39F: AD 90 00
  LSR                                   ; $A3A2: 4A
  LSR                                   ; $A3A3: 4A
  LSR                                   ; $A3A4: 4A
  CMP $0092                             ; $A3A5: CD 92 00
  BEQ $A3B0                             ; $A3A8: F0 06
  STA $0092                             ; $A3AA: 8D 92 00
  JSR $A3BC                             ; $A3AD: 20 BC A3
Loc_A3B0:
  RTS                                   ; $A3B0: 60
Loc_A3B1:
  LDA $009C                             ; $A3B1: AD 9C 00
  BPL $A3B9                             ; $A3B4: 10 03
  JMP $A465                             ; $A3B6: 4C 65 A4
Loc_A3B9:
  JMP $A3C9                             ; $A3B9: 4C C9 A3
Loc_A3BC:
  LDA $009C                             ; $A3BC: AD 9C 00
  AND #$20                              ; $A3BF: 29 20
  BNE $A3C6                             ; $A3C1: D0 03
  JMP $A485                             ; $A3C3: 4C 85 A4
Loc_A3C6:
  JMP $A51C                             ; $A3C6: 4C 1C A5
Loc_A3C9:
  LDA $008E                             ; $A3C9: AD 8E 00
  STA $000C                             ; $A3CC: 8D 0C 00
  LDA $008F                             ; $A3CF: AD 8F 00
  STA $000D                             ; $A3D2: 8D 0D 00
  LDA $0090                             ; $A3D5: AD 90 00
  STA $000E                             ; $A3D8: 8D 0E 00
  LDA $0091                             ; $A3DB: AD 91 00
  STA $000F                             ; $A3DE: 8D 0F 00
Loc_A3E1:
  LDA $007E                             ; $A3E1: AD 7E 00
  BPL $A3E7                             ; $A3E4: 10 01
  RTS                                   ; $A3E6: 60
Loc_A3E7:
  JSR $A604                             ; $A3E7: 20 04 A6
  STY $001A                             ; $A3EA: 8C 1A 00
  JSR $A61F                             ; $A3ED: 20 1F A6
  LDA $001A                             ; $A3F0: AD 1A 00
  CLC                                   ; $A3F3: 18
  ADC #$02                              ; $A3F4: 69 02
  TAY                                   ; $A3F6: A8
  LDA ($A8),Y                           ; $A3F7: B1 A8
  STA $0010                             ; $A3F9: 8D 10 00
  JSR $A93F                             ; $A3FC: 20 3F A9
  LDX #$00                              ; $A3FF: A2 00
  STX $0006                             ; $A401: 8E 06 00
  STX $0007                             ; $A404: 8E 07 00
  LDA $000C                             ; $A407: AD 0C 00
  LSR                                   ; $A40A: 4A
  LSR                                   ; $A40B: 4A
  LSR                                   ; $A40C: 4A
  LSR                                   ; $A40D: 4A
  STA $0008                             ; $A40E: 8D 08 00
  LDA $000E                             ; $A411: AD 0E 00
  AND #$F0                              ; $A414: 29 F0
  CLC                                   ; $A416: 18
  ADC $0008                             ; $A417: 6D 08 00
  STA $0005                             ; $A41A: 8D 05 00
Loc_A41D:
  LDY $0005                             ; $A41D: AC 05 00
  LDA ($00),Y                           ; $A420: B1 00
  JSR $A545                             ; $A422: 20 45 A5
  INC $0019                             ; $A425: EE 19 00
  LDA $0005                             ; $A428: AD 05 00
  CLC                                   ; $A42B: 18
  ADC #$10                              ; $A42C: 69 10
  CMP #$F0                              ; $A42E: C9 F0
  BCC $A442                             ; $A430: 90 10
  AND #$0F                              ; $A432: 29 0F
  PHA                                   ; $A434: 48
  LDA $0010                             ; $A435: AD 10 00
  JSR $A61F                             ; $A438: 20 1F A6
  INC $0007                             ; $A43B: EE 07 00
  INC $0019                             ; $A43E: EE 19 00
  PLA                                   ; $A441: 68
Loc_A442:
  STA $0005                             ; $A442: 8D 05 00
  INC $0006                             ; $A445: EE 06 00
  LDA $0006                             ; $A448: AD 06 00
  CMP #$10                              ; $A44B: C9 10
  BCC $A41D                             ; $A44D: 90 CE
  LDA #$40                              ; $A44F: A9 40
  STA $0000                             ; $A451: 8D 00 00
  LDA #$01                              ; $A454: A9 01
  STA $0001                             ; $A456: 8D 01 00
  JSR $A89A                             ; $A459: 20 9A A8
  LDA $007E                             ; $A45C: AD 7E 00
  ORA #$80                              ; $A45F: 09 80
  STA $007E                             ; $A461: 8D 7E 00
  RTS                                   ; $A464: 60
Loc_A465:
  LDA $008E                             ; $A465: AD 8E 00
  CLC                                   ; $A468: 18
  ADC #$F8                              ; $A469: 69 F8
  STA $000C                             ; $A46B: 8D 0C 00
  LDA $008F                             ; $A46E: AD 8F 00
  ADC #$00                              ; $A471: 69 00
  STA $000D                             ; $A473: 8D 0D 00
  LDA $0090                             ; $A476: AD 90 00
  STA $000E                             ; $A479: 8D 0E 00
  LDA $0091                             ; $A47C: AD 91 00
  STA $000F                             ; $A47F: 8D 0F 00
  JMP $A3E1                             ; $A482: 4C E1 A3
Loc_A485:
  LDA $008E                             ; $A485: AD 8E 00
  STA $000C                             ; $A488: 8D 0C 00
  LDA $008F                             ; $A48B: AD 8F 00
  STA $000D                             ; $A48E: 8D 0D 00
  LDA $0091                             ; $A491: AD 91 00
  STA $000F                             ; $A494: 8D 0F 00
  LDA $0090                             ; $A497: AD 90 00
Loc_A49A:
  STA $000E                             ; $A49A: 8D 0E 00
  LDA $007E                             ; $A49D: AD 7E 00
  ASL                                   ; $A4A0: 0A
  BPL $A4A4                             ; $A4A1: 10 01
  RTS                                   ; $A4A3: 60
Loc_A4A4:
  JSR $A604                             ; $A4A4: 20 04 A6
  STY $001A                             ; $A4A7: 8C 1A 00
  JSR $A61F                             ; $A4AA: 20 1F A6
  LDY $001A                             ; $A4AD: AC 1A 00
  INY                                   ; $A4B0: C8
  LDA ($A8),Y                           ; $A4B1: B1 A8
  STA $0010                             ; $A4B3: 8D 10 00
  JSR $A961                             ; $A4B6: 20 61 A9
  LDA $000C                             ; $A4B9: AD 0C 00
  LSR                                   ; $A4BC: 4A
  LSR                                   ; $A4BD: 4A
  LSR                                   ; $A4BE: 4A
  LSR                                   ; $A4BF: 4A
  STA $0008                             ; $A4C0: 8D 08 00
  LDA $000E                             ; $A4C3: AD 0E 00
  AND #$F0                              ; $A4C6: 29 F0
  CLC                                   ; $A4C8: 18
  ADC $0008                             ; $A4C9: 6D 08 00
  STA $0005                             ; $A4CC: 8D 05 00
  LDX #$00                              ; $A4CF: A2 00
  STX $0006                             ; $A4D1: 8E 06 00
Loc_A4D4:
  LDY $0005                             ; $A4D4: AC 05 00
  LDA ($00),Y                           ; $A4D7: B1 00
  JSR $A5A5                             ; $A4D9: 20 A5 A5
  INC $0018                             ; $A4DC: EE 18 00
  LDA $0005                             ; $A4DF: AD 05 00
  INC $0005                             ; $A4E2: EE 05 00
  AND #$0F                              ; $A4E5: 29 0F
  CMP #$0F                              ; $A4E7: C9 0F
  BNE $A4FC                             ; $A4E9: D0 11
  LDA $0010                             ; $A4EB: AD 10 00
  JSR $A61F                             ; $A4EE: 20 1F A6
  DEC $0005                             ; $A4F1: CE 05 00
  LDA $0005                             ; $A4F4: AD 05 00
  AND #$F0                              ; $A4F7: 29 F0
  STA $0005                             ; $A4F9: 8D 05 00
Loc_A4FC:
  INC $0006                             ; $A4FC: EE 06 00
  LDA $0006                             ; $A4FF: AD 06 00
  CMP #$11                              ; $A502: C9 11
  BCC $A4D4                             ; $A504: 90 CE
  LDA #$64                              ; $A506: A9 64
  STA $0000                             ; $A508: 8D 00 00
  LDA #$01                              ; $A50B: A9 01
  STA $0001                             ; $A50D: 8D 01 00
  JSR $A89A                             ; $A510: 20 9A A8
  LDA $007E                             ; $A513: AD 7E 00
  ORA #$40                              ; $A516: 09 40
  STA $007E                             ; $A518: 8D 7E 00
  RTS                                   ; $A51B: 60
Loc_A51C:
  LDA $008E                             ; $A51C: AD 8E 00
  STA $000C                             ; $A51F: 8D 0C 00
  LDA $008F                             ; $A522: AD 8F 00
  STA $000D                             ; $A525: 8D 0D 00
  LDA $0091                             ; $A528: AD 91 00
  STA $000F                             ; $A52B: 8D 0F 00
  INC $000F                             ; $A52E: EE 0F 00
  LDA $0090                             ; $A531: AD 90 00
  CLC                                   ; $A534: 18
  ADC #$F0                              ; $A535: 69 F0
  BCS $A53F                             ; $A537: B0 06
  SEC                                   ; $A539: 38
  SBC #$10                              ; $A53A: E9 10
  DEC $000F                             ; $A53C: CE 0F 00
Loc_A53F:
  STA $000E                             ; $A53F: 8D 0E 00
  JMP $A49A                             ; $A542: 4C 9A A4
Loc_A545:
  JSR $A8FD                             ; $A545: 20 FD A8
  LDY #$00                              ; $A548: A0 00
  STY $0009                             ; $A54A: 8C 09 00
  ASL                                   ; $A54D: 0A
  ROL $0009                             ; $A54E: 2E 09 00
  ASL                                   ; $A551: 0A
  ROL $0009                             ; $A552: 2E 09 00
  CLC                                   ; $A555: 18
  ADC $0002                             ; $A556: 6D 02 00
  STA $0008                             ; $A559: 8D 08 00
  LDA $0009                             ; $A55C: AD 09 00
  ADC $0003                             ; $A55F: 6D 03 00
  STA $0009                             ; $A562: 8D 09 00
Loc_A565:
  LDY #$00                              ; $A565: A0 00
  LDA $000C                             ; $A567: AD 0C 00
  AND #$08                              ; $A56A: 29 08
  BNE $A589                             ; $A56C: D0 1B
  LDA $0006                             ; $A56E: AD 06 00
  BNE $A57A                             ; $A571: D0 07
  LDA $000E                             ; $A573: AD 0E 00
  AND #$08                              ; $A576: 29 08
  BNE $A580                             ; $A578: D0 06
Loc_A57A:
  LDA ($08),Y                           ; $A57A: B1 08
  STA $0142,X                           ; $A57C: 9D 42 01
  INX                                   ; $A57F: E8
Loc_A580:
  INY                                   ; $A580: C8
  INY                                   ; $A581: C8
  LDA ($08),Y                           ; $A582: B1 08
  STA $0142,X                           ; $A584: 9D 42 01
  INX                                   ; $A587: E8
  RTS                                   ; $A588: 60
Loc_A589:
  INY                                   ; $A589: C8
  LDA $0006                             ; $A58A: AD 06 00
  BNE $A596                             ; $A58D: D0 07
  LDA $000E                             ; $A58F: AD 0E 00
  AND #$08                              ; $A592: 29 08
  BNE $A59C                             ; $A594: D0 06
Loc_A596:
  LDA ($08),Y                           ; $A596: B1 08
  STA $0142,X                           ; $A598: 9D 42 01
  INX                                   ; $A59B: E8
Loc_A59C:
  INY                                   ; $A59C: C8
  INY                                   ; $A59D: C8
  LDA ($08),Y                           ; $A59E: B1 08
  STA $0142,X                           ; $A5A0: 9D 42 01
  INX                                   ; $A5A3: E8
  RTS                                   ; $A5A4: 60
Loc_A5A5:
  JSR $A91E                             ; $A5A5: 20 1E A9
  LDY #$00                              ; $A5A8: A0 00
  STY $0009                             ; $A5AA: 8C 09 00
  ASL                                   ; $A5AD: 0A
  ROL $0009                             ; $A5AE: 2E 09 00
  ASL                                   ; $A5B1: 0A
  ROL $0009                             ; $A5B2: 2E 09 00
  CLC                                   ; $A5B5: 18
  ADC $0002                             ; $A5B6: 6D 02 00
  STA $0008                             ; $A5B9: 8D 08 00
  LDA $0009                             ; $A5BC: AD 09 00
  ADC $0003                             ; $A5BF: 6D 03 00
  STA $0009                             ; $A5C2: 8D 09 00
Loc_A5C5:
  LDY #$00                              ; $A5C5: A0 00
  LDA $000E                             ; $A5C7: AD 0E 00
  AND #$08                              ; $A5CA: 29 08
  BNE $A5E8                             ; $A5CC: D0 1A
  LDA $0006                             ; $A5CE: AD 06 00
  BNE $A5DA                             ; $A5D1: D0 07
  LDA $000C                             ; $A5D3: AD 0C 00
  AND #$08                              ; $A5D6: 29 08
  BNE $A5E0                             ; $A5D8: D0 06
Loc_A5DA:
  LDA ($08),Y                           ; $A5DA: B1 08
  STA $0166,X                           ; $A5DC: 9D 66 01
  INX                                   ; $A5DF: E8
Loc_A5E0:
  INY                                   ; $A5E0: C8
  LDA ($08),Y                           ; $A5E1: B1 08
  STA $0166,X                           ; $A5E3: 9D 66 01
  INX                                   ; $A5E6: E8
  RTS                                   ; $A5E7: 60
Loc_A5E8:
  INY                                   ; $A5E8: C8
Loc_A5E9:
  INY                                   ; $A5E9: C8
  LDA $0006                             ; $A5EA: AD 06 00
  BNE $A5F6                             ; $A5ED: D0 07
Loc_A5EF:
  LDA $000C                             ; $A5EF: AD 0C 00
  AND #$08                              ; $A5F2: 29 08
  BNE $A5FC                             ; $A5F4: D0 06
Loc_A5F6:
  LDA ($08),Y                           ; $A5F6: B1 08
  STA $0166,X                           ; $A5F8: 9D 66 01
  INX                                   ; $A5FB: E8
Loc_A5FC:
  INY                                   ; $A5FC: C8
  LDA ($08),Y                           ; $A5FD: B1 08
  STA $0166,X                           ; $A5FF: 9D 66 01
  INX                                   ; $A602: E8
  RTS                                   ; $A603: 60
Loc_A604:
  LDA $000F                             ; $A604: AD 0F 00
  ASL                                   ; $A607: 0A
  CLC                                   ; $A608: 18
  ADC $000D                             ; $A609: 6D 0D 00
  TAY                                   ; $A60C: A8
  LDA ($A8),Y                           ; $A60D: B1 A8
  RTS                                   ; $A60F: 60
Loc_A610:
  LDA $001F                             ; $A610: AD 1F 00
  ASL                                   ; $A613: 0A
  CLC                                   ; $A614: 18
  ADC $001D                             ; $A615: 6D 1D 00
  TAY                                   ; $A618: A8
  LDA ($A8),Y                           ; $A619: B1 A8
  RTS                                   ; $A61B: 60
Loc_A61C:
  LDA $0000                             ; $A61C: AD 00 00
Loc_A61F:
  PHA                                   ; $A61F: 48
  ASL                                   ; $A620: 0A
  TAY                                   ; $A621: A8
  LDA $A642,Y                           ; $A622: B9 42 A6
  STA $0000                             ; $A625: 8D 00 00
  LDA $A643,Y                           ; $A628: B9 43 A6
  STA $0001                             ; $A62B: 8D 01 00
  LDA #$77                              ; $A62E: A9 77
  STA $0002                             ; $A630: 8D 02 00
  LDA #$F4                              ; $A633: A9 F4
  STA $0003                             ; $A635: 8D 03 00
  PLA                                   ; $A638: 68
  TAY                                   ; $A639: A8
  LDA $A822,Y                           ; $A63A: B9 22 A8
  TAY                                   ; $A63D: A8
  JSR $F25F                             ; $A63E: 20 5F F2
  RTS                                   ; $A641: 60
; --- Data Region ---
  .byte $40,$80,$70,$81,$00,$82,$30,$83,$C0,$83,$F0,$84,$80,$85,$B0,$86; $A642: 40 80 70 81 00 82 30 83 C0 83 F0 84 80 85 B0 86
  .byte $40,$87,$70,$88,$00               ; $A652: 40 87 70 88 00
Loc_A657:
; --- Code Region ---
  NOP #$30                              ; $A657: 89 30
  TXA                                   ; $A659: 8A
  CPY #$8A                              ; $A65A: C0 8A
  BEQ $A5E9                             ; $A65C: F0 8B
  NOP #$8C                              ; $A65E: 80 8C
  BCS $A5EF                             ; $A660: B0 8D
  RTI                                   ; $A662: 40
; --- Data Region ---
  .byte $8E,$70,$8F,$00,$90,$30           ; $A663: 8E 70 8F 00 90 30
Loc_A669:
; --- Code Region ---
  STA ($C0),Y                           ; $A669: 91 C0
  STA ($F0),Y                           ; $A66B: 91 F0
  JAM                                   ; $A66D: 92
  NOP #$93                              ; $A66E: 80 93
  BCS $A606                             ; $A670: B0 94
  RTI                                   ; $A672: 40
  STA $70,X                             ; $A673: 95 70
  STX $00,Y                             ; $A675: 96 00
  SAX $30,Y                             ; $A677: 97 30
  TYA                                   ; $A679: 98
  CPY #$98                              ; $A67A: C0 98
  BEQ $A617                             ; $A67C: F0 99
  NOP #$9A                              ; $A67E: 80 9A
  BCS $A61D                             ; $A680: B0 9B
  LDX $89                               ; $A682: A6 89
  DEC $8A,X                             ; $A684: D6 8A
Loc_A686:
  ROR $8B                               ; $A686: 66 8B
  STX $8C,Y                             ; $A688: 96 8C
  ROL $8D                               ; $A68A: 26 8D
  LSR $8E,X                             ; $A68C: 56 8E
  INC $8E                               ; $A68E: E6 8E
  ASL $90,X                             ; $A690: 16 90
  LDX $90                               ; $A692: A6 90
  DEC $91,X                             ; $A694: D6 91
  ROR $92                               ; $A696: 66 92
  STX $93,Y                             ; $A698: 96 93
  ROL $94                               ; $A69A: 26 94
  LSR $95,X                             ; $A69C: 56 95
  INC $95                               ; $A69E: E6 95
  ASL $97,X                             ; $A6A0: 16 97
  LDX $97                               ; $A6A2: A6 97
  DEC $98,X                             ; $A6A4: D6 98
  ROR $99                               ; $A6A6: 66 99
  STX $9A,Y                             ; $A6A8: 96 9A
  ROL $9B                               ; $A6AA: 26 9B
  LSR $9C,X                             ; $A6AC: 56 9C
  INC $9C                               ; $A6AE: E6 9C
  ASL $9E,X                             ; $A6B0: 16 9E
  RTI                                   ; $A6B2: 40
; --- Data Region ---
  .byte $95,$70,$96,$00,$97,$30,$98,$C0,$98,$F0,$99,$80,$9A,$B0,$9B,$40; $A6B3: 95 70 96 00 97 30 98 C0 98 F0 99 80 9A B0 9B 40
  .byte $80,$70,$81                       ; $A6C3: 80 70 81
Loc_A6C6:
; --- Code Region ---
  BRK                                   ; $A6C6: 00
  NOP #$30                              ; $A6C7: 82 30
  SAX ($C0,X)                           ; $A6C9: 83 C0
  SAX ($F0,X)                           ; $A6CB: 83 F0
  STY $80                               ; $A6CD: 84 80
  STA $B0                               ; $A6CF: 85 B0
  STX $40                               ; $A6D1: 86 40
Loc_A6D3:
  SAX $70                               ; $A6D3: 87 70
  DEY                                   ; $A6D5: 88
  BRK                                   ; $A6D6: 00
  NOP #$30                              ; $A6D7: 89 30
Loc_A6D9:
  TXA                                   ; $A6D9: 8A
  CPY #$8A                              ; $A6DA: C0 8A
  BEQ $A669                             ; $A6DC: F0 8B
  NOP #$8C                              ; $A6DE: 80 8C
  BCS $A66F                             ; $A6E0: B0 8D
  RTI                                   ; $A6E2: 40
; --- Data Region ---
  .byte $8E,$70,$8F,$00,$90,$30,$91       ; $A6E3: 8E 70 8F 00 90 30 91
Loc_A6EA:
; --- Code Region ---
  CPY #$91                              ; $A6EA: C0 91
  BEQ $A680                             ; $A6EC: F0 92
  NOP #$93                              ; $A6EE: 80 93
Loc_A6F0:
  BCS $A686                             ; $A6F0: B0 94
  RTI                                   ; $A6F2: 40
; --- Data Region ---
  .byte $95,$70,$96,$00,$97,$30,$98,$C0,$98,$F0,$99,$80,$9A,$B0,$9B,$40; $A6F3: 95 70 96 00 97 30 98 C0 98 F0 99 80 9A B0 9B 40
  .byte $80,$70,$81,$00                   ; $A703: 80 70 81 00
Loc_A707:
; --- Code Region ---
  NOP #$30                              ; $A707: 82 30
  SAX ($C0,X)                           ; $A709: 83 C0
  SAX ($F0,X)                           ; $A70B: 83 F0
Loc_A70D:
  STY $80                               ; $A70D: 84 80
  STA $B0                               ; $A70F: 85 B0
  STX $40                               ; $A711: 86 40
  SAX $70                               ; $A713: 87 70
  DEY                                   ; $A715: 88
  BRK                                   ; $A716: 00
  NOP #$30                              ; $A717: 89 30
Loc_A719:
  TXA                                   ; $A719: 8A
  CPY #$8A                              ; $A71A: C0 8A
  BEQ $A6A9                             ; $A71C: F0 8B
  NOP #$8C                              ; $A71E: 80 8C
  BCS $A6AF                             ; $A720: B0 8D
  RTI                                   ; $A722: 40
; --- Data Region ---
  .byte $8E,$70,$8F,$00,$90,$30,$91,$C0,$91,$F0,$92,$80,$93,$B0,$94,$00; $A723: 8E 70 8F 00 90 30 91 C0 91 F0 92 80 93 B0 94 00
  .byte $80,$30,$81,$C0,$81,$F0,$82,$80,$83,$B0,$84,$40,$85,$70,$86,$00; $A733: 80 30 81 C0 81 F0 82 80 83 B0 84 40 85 70 86 00
  .byte $87,$30,$88,$C0                   ; $A743: 87 30 88 C0
Loc_A747:
; --- Code Region ---
  DEY                                   ; $A747: 88
  BEQ $A6D3                             ; $A748: F0 89
  NOP #$8A                              ; $A74A: 80 8A
  BCS $A6D9                             ; $A74C: B0 8B
  RTI                                   ; $A74E: 40
  STY $8D70                             ; $A74F: 8C 70 8D
  BRK                                   ; $A752: 00
Loc_A753:
  STX $8F30                             ; $A753: 8E 30 8F
  CPY #$8F                              ; $A756: C0 8F
  BEQ $A6EA                             ; $A758: F0 90
  NOP #$91                              ; $A75A: 80 91
  BCS $A6F0                             ; $A75C: B0 92
  RTI                                   ; $A75E: 40
; --- Data Region ---
  .byte $93,$70,$94,$00,$95,$30,$96,$C0,$96,$F0,$97; $A75F: 93 70 94 00 95 30 96 C0 96 F0 97
Loc_A76A:
; --- Code Region ---
  NOP #$98                              ; $A76A: 80 98
  BCS $A707                             ; $A76C: B0 99
  RTI                                   ; $A76E: 40
; --- Data Region ---
  .byte $9A                               ; $A76F: 9A
Loc_A770:
; --- Code Region ---
  BVS $A70D                             ; $A770: 70 9B
  ROR $89                               ; $A772: 66 89
  STX $8A,Y                             ; $A774: 96 8A
  ROL $8B                               ; $A776: 26 8B
  LSR $8C,X                             ; $A778: 56 8C
  INC $8C                               ; $A77A: E6 8C
  ASL $8E,X                             ; $A77C: 16 8E
  LDX $8E                               ; $A77E: A6 8E
  DEC $8F,X                             ; $A780: D6 8F
  ROR $90                               ; $A782: 66 90
  STX $91,Y                             ; $A784: 96 91
  ROL $92                               ; $A786: 26 92
  LSR $93,X                             ; $A788: 56 93
  INC $93                               ; $A78A: E6 93
  ASL $95,X                             ; $A78C: 16 95
  LDX $95                               ; $A78E: A6 95
  DEC $96,X                             ; $A790: D6 96
  ROR $97                               ; $A792: 66 97
  STX $98,Y                             ; $A794: 96 98
  ROL $99                               ; $A796: 26 99
  LSR $9A,X                             ; $A798: 56 9A
  INC $9A                               ; $A79A: E6 9A
  ASL $9C,X                             ; $A79C: 16 9C
  LDX $9C                               ; $A79E: A6 9C
  DEC $9D,X                             ; $A7A0: D6 9D
  BRK                                   ; $A7A2: 00
  STA $30,X                             ; $A7A3: 95 30
  STX $C0,Y                             ; $A7A5: 96 C0
  STX $F0,Y                             ; $A7A7: 96 F0
  SAX $80,Y                             ; $A7A9: 97 80
  TYA                                   ; $A7AB: 98
  BCS $A747                             ; $A7AC: B0 99
  RTI                                   ; $A7AE: 40
; --- Data Region ---
  .byte $9A                               ; $A7AF: 9A
Loc_A7B0:
; --- Code Region ---
  BVS $A74D                             ; $A7B0: 70 9B
  BRK                                   ; $A7B2: 00
  NOP #$30                              ; $A7B3: 80 30
  STA ($C0,X)                           ; $A7B5: 81 C0
  STA ($F0,X)                           ; $A7B7: 81 F0
  NOP #$80                              ; $A7B9: 82 80
  SAX ($B0,X)                           ; $A7BB: 83 B0
  STY $40                               ; $A7BD: 84 40
  STA $70                               ; $A7BF: 85 70
  STX $00                               ; $A7C1: 86 00
  SAX $30                               ; $A7C3: 87 30
  DEY                                   ; $A7C5: 88
  CPY #$88                              ; $A7C6: C0 88
  BEQ $A753                             ; $A7C8: F0 89
  NOP #$8A                              ; $A7CA: 80 8A
  BCS $A759                             ; $A7CC: B0 8B
  RTI                                   ; $A7CE: 40
; --- Data Region ---
  .byte $8C,$70,$8D,$00,$8E,$30,$8F,$C0,$8F,$F0,$90,$80,$91,$B0,$92,$40; $A7CF: 8C 70 8D 00 8E 30 8F C0 8F F0 90 80 91 B0 92 40
  .byte $93,$70,$94,$00,$95,$30,$96,$C0,$96,$F0,$97,$80,$98,$B0,$99,$40; $A7DF: 93 70 94 00 95 30 96 C0 96 F0 97 80 98 B0 99 40
  .byte $9A,$70,$9B,$00,$80,$30,$81,$C0,$81,$F0,$82,$80,$83,$B0,$84,$40; $A7EF: 9A 70 9B 00 80 30 81 C0 81 F0 82 80 83 B0 84 40
  .byte $85,$70,$86,$00,$87,$30,$88,$C0,$88,$F0,$89,$80,$8A,$B0,$8B,$40; $A7FF: 85 70 86 00 87 30 88 C0 88 F0 89 80 8A B0 8B 40
  .byte $8C,$70,$8D,$00,$8E,$30,$8F,$C0,$8F,$F0,$90,$80,$91,$B0,$92,$40; $A80F: 8C 70 8D 00 8E 30 8F C0 8F F0 90 80 91 B0 92 40
  .byte $93,$70,$94,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20; $A81F: 93 70 94 20 20 20 20 20 20 20 20 20 20 20 20 20
  .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20; $A82F: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20
  .byte $20,$20,$20,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23; $A83F: 20 20 20 23 23 23 23 23 23 23 23 23 23 23 23 23
  .byte $23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$25,$25,$25,$25,$25; $A84F: 23 23 23 23 23 23 23 23 23 23 23 25 25 25 25 25
  .byte $25,$25,$25,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24; $A85F: 25 25 25 24 24 24 24 24 24 24 24 24 24 24 24 24
  .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24; $A86F: 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24
  .byte $24,$24,$24,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25; $A87F: 24 24 24 25 25 25 25 25 25 25 25 25 25 25 25 25
  .byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25; $A88F: 25 25 25 25 25 25 25 25 25 25 25
Loc_A89A:
; --- Code Region ---
  LDY #$00                              ; $A89A: A0 00
  LDA $000D                             ; $A89C: AD 0D 00
  LDX #$20                              ; $A89F: A2 20
  LSR                                   ; $A8A1: 4A
  BCS $A8A6                             ; $A8A2: B0 02
  LDX #$20                              ; $A8A4: A2 20
Loc_A8A6:
  TXA                                   ; $A8A6: 8A
  STA ($00),Y                           ; $A8A7: 91 00
  INY                                   ; $A8A9: C8
  LDA $000C                             ; $A8AA: AD 0C 00
  LSR                                   ; $A8AD: 4A
  LSR                                   ; $A8AE: 4A
  LSR                                   ; $A8AF: 4A
  STA ($00),Y                           ; $A8B0: 91 00
  LDA #$00                              ; $A8B2: A9 00
  STA $000F                             ; $A8B4: 8D 0F 00
  LDA $000E                             ; $A8B7: AD 0E 00
  AND #$F8                              ; $A8BA: 29 F8
  ASL                                   ; $A8BC: 0A
  ROL $000F                             ; $A8BD: 2E 0F 00
  ASL                                   ; $A8C0: 0A
  ROL $000F                             ; $A8C1: 2E 0F 00
  CLC                                   ; $A8C4: 18
  ADC ($00),Y                           ; $A8C5: 71 00
  STA ($00),Y                           ; $A8C7: 91 00
  DEY                                   ; $A8C9: 88
  LDA ($00),Y                           ; $A8CA: B1 00
  CLC                                   ; $A8CC: 18
  ADC $000F                             ; $A8CD: 6D 0F 00
  STA ($00),Y                           ; $A8D0: 91 00
  RTS                                   ; $A8D2: 60
Loc_A8D3:
  LDY #$00                              ; $A8D3: A0 00
  LDA $000D                             ; $A8D5: AD 0D 00
  LDX #$23                              ; $A8D8: A2 23
  LSR                                   ; $A8DA: 4A
  BCS $A8DF                             ; $A8DB: B0 02
  LDX #$23                              ; $A8DD: A2 23
Loc_A8DF:
  TXA                                   ; $A8DF: 8A
  STA ($00),Y                           ; $A8E0: 91 00
  INY                                   ; $A8E2: C8
  LDA $000C                             ; $A8E3: AD 0C 00
  LSR                                   ; $A8E6: 4A
  LSR                                   ; $A8E7: 4A
  LSR                                   ; $A8E8: 4A
  LSR                                   ; $A8E9: 4A
  LSR                                   ; $A8EA: 4A
  CLC                                   ; $A8EB: 18
  ADC #$C0                              ; $A8EC: 69 C0
  STA ($00),Y                           ; $A8EE: 91 00
  LDA $000E                             ; $A8F0: AD 0E 00
  AND #$E0                              ; $A8F3: 29 E0
  LSR                                   ; $A8F5: 4A
  LSR                                   ; $A8F6: 4A
  CLC                                   ; $A8F7: 18
  ADC ($00),Y                           ; $A8F8: 71 00
  STA ($00),Y                           ; $A8FA: 91 00
  RTS                                   ; $A8FC: 60
Loc_A8FD:
  PHA                                   ; $A8FD: 48
  LDY $0019                             ; $A8FE: AC 19 00
  LDA $0680,Y                           ; $A901: B9 80 06
Loc_A904:  ; (dispatch callback target)
  CMP #$FF                              ; $A904: C9 FF
  BEQ $A91C                             ; $A906: F0 14
  TAY                                   ; $A908: A8
  PLA                                   ; $A909: 68
  PLA                                   ; $A90A: 68
  PLA                                   ; $A90B: 68
  JSR $A986                             ; $A90C: 20 86 A9
  LDA #$B0                              ; $A90F: A9 B0
  STA $0008                             ; $A911: 8D 08 00
  LDA #$01                              ; $A914: A9 01
  STA $0009                             ; $A916: 8D 09 00
  JMP $A565                             ; $A919: 4C 65 A5
Loc_A91C:
  PLA                                   ; $A91C: 68
  RTS                                   ; $A91D: 60
Loc_A91E:
  PHA                                   ; $A91E: 48
  LDY $0018                             ; $A91F: AC 18 00
  LDA $0680,Y                           ; $A922: B9 80 06
Loc_A925:  ; (dispatch callback target)
  CMP #$FF                              ; $A925: C9 FF
  BEQ $A93D                             ; $A927: F0 14
  TAY                                   ; $A929: A8
  PLA                                   ; $A92A: 68
  PLA                                   ; $A92B: 68
  PLA                                   ; $A92C: 68
  JSR $A986                             ; $A92D: 20 86 A9
  LDA #$B0                              ; $A930: A9 B0
  STA $0008                             ; $A932: 8D 08 00
  LDA #$01                              ; $A935: A9 01
  STA $0009                             ; $A937: 8D 09 00
  JMP $A5C5                             ; $A93A: 4C C5 A5
Loc_A93D:
  PLA                                   ; $A93D: 68
  RTS                                   ; $A93E: 60
Loc_A93F:
  JSR $AB26                             ; $A93F: 20 26 AB
  LDY #$3F                              ; $A942: A0 3F
  LDA #$FF                              ; $A944: A9 FF
Loc_A946:
  STA $0680,Y                           ; $A946: 99 80 06
  DEY                                   ; $A949: 88
  BPL $A946                             ; $A94A: 10 FA
  LDY #$13                              ; $A94C: A0 13
Loc_A94E:
  LDA $0600,Y                           ; $A94E: B9 00 06
  CMP $0018                             ; $A951: CD 18 00
  BNE $A95D                             ; $A954: D0 07
  LDX $0614,Y                           ; $A956: BE 14 06
  TYA                                   ; $A959: 98
  STA $0680,X                           ; $A95A: 9D 80 06
Loc_A95D:
  DEY                                   ; $A95D: 88
  BPL $A94E                             ; $A95E: 10 EE
  RTS                                   ; $A960: 60
Loc_A961:
  JSR $AB26                             ; $A961: 20 26 AB
  LDY #$3F                              ; $A964: A0 3F
  LDA #$FF                              ; $A966: A9 FF
Loc_A968:
  STA $0680,Y                           ; $A968: 99 80 06
  DEY                                   ; $A96B: 88
  BPL $A968                             ; $A96C: 10 FA
  LDY #$13                              ; $A96E: A0 13
Loc_A970:
  LDA $0614,Y                           ; $A970: B9 14 06
  CMP $0019                             ; $A973: CD 19 00
  BNE $A97F                             ; $A976: D0 07
  LDX $0600,Y                           ; $A978: BE 00 06
  TYA                                   ; $A97B: 98
  STA $0680,X                           ; $A97C: 9D 80 06
Loc_A97F:
  DEY                                   ; $A97F: 88
  BPL $A970                             ; $A980: 10 EE
  RTS                                   ; $A982: 60
Loc_A983:
  LDY $0000                             ; $A983: AC 00 00
Loc_A986:
  TYA                                   ; $A986: 98
  PHA                                   ; $A987: 48
  LDA $0507                             ; $A988: AD 07 05
  PHA                                   ; $A98B: 48
  LDA $0628,Y                           ; $A98C: B9 28 06
  BPL $A997                             ; $A98F: 10 06
  PLA                                   ; $A991: 68
  LSR                                   ; $A992: 4A
  LSR                                   ; $A993: 4A
  LSR                                   ; $A994: 4A
  LSR                                   ; $A995: 4A
  PHA                                   ; $A996: 48
Loc_A997:
  PLA                                   ; $A997: 68
  AND #$0F                              ; $A998: 29 0F
  JSR $A9A8                             ; $A99A: 20 A8 A9
  CMP #$00                              ; $A99D: C9 00
  BEQ $A9C4                             ; $A99F: F0 23
  CMP #$01                              ; $A9A1: C9 01
  BEQ $AA24                             ; $A9A3: F0 7F
  JMP $AA84                             ; $A9A5: 4C 84 AA
Loc_A9A8:
  TAY                                   ; $A9A8: A8
  LDA $0000                             ; $A9A9: AD 00 00
  PHA                                   ; $A9AC: 48
Loc_A9AD:  ; (dispatch callback target)
  LDA $0001                             ; $A9AD: AD 01 00
  PHA                                   ; $A9B0: 48
  TYA                                   ; $A9B1: 98
  JSR $F368                             ; $A9B2: 20 68 F3
  LDY #$03                              ; $A9B5: A0 03
  LDA ($00),Y                           ; $A9B7: B1 00
  TAY                                   ; $A9B9: A8
  PLA                                   ; $A9BA: 68
  STA $0001                             ; $A9BB: 8D 01 00
  PLA                                   ; $A9BE: 68
  STA $0000                             ; $A9BF: 8D 00 00
  TYA                                   ; $A9C2: 98
  RTS                                   ; $A9C3: 60
Loc_A9C4:
  PLA                                   ; $A9C4: 68
  TAY                                   ; $A9C5: A8
  PHA                                   ; $A9C6: 48
  LDA $063C,Y                           ; $A9C7: B9 3C 06
  TAY                                   ; $A9CA: A8
  LDA $AAE4,Y                           ; $A9CB: B9 E4 AA
  STA $01B0                             ; $A9CE: 8D B0 01
  LDA $AAEF,Y                           ; $A9D1: B9 EF AA
  STA $01B1                             ; $A9D4: 8D B1 01
  PLA                                   ; $A9D7: 68
  TAY                                   ; $A9D8: A8
  BEQ $A9DF                             ; $A9D9: F0 04
  CMP #$0A                              ; $A9DB: C9 0A
  BNE $A9F5                             ; $A9DD: D0 16
Loc_A9DF:
  LDA #$BB                              ; $A9DF: A9 BB
  STA $01B0                             ; $A9E1: 8D B0 01
  LDA $063C,Y                           ; $A9E4: B9 3C 06
  CMP #$0A                              ; $A9E7: C9 0A
  BNE $A9F5                             ; $A9E9: D0 0A
  LDA #$BA                              ; $A9EB: A9 BA
  STA $01B0                             ; $A9ED: 8D B0 01
  LDA #$AB                              ; $A9F0: A9 AB
  STA $01B1                             ; $A9F2: 8D B1 01
Loc_A9F5:
  LDA #$AE                              ; $A9F5: A9 AE
  STA $01B2                             ; $A9F7: 8D B2 01
  LDA #$AF                              ; $A9FA: A9 AF
  STA $01B3                             ; $A9FC: 8D B3 01
  LDA $0628,Y                           ; $A9FF: B9 28 06
  AND #$03                              ; $AA02: 29 03
  BNE $AA10                             ; $AA04: D0 0A
  LDA #$BD                              ; $AA06: A9 BD
  STA $01B2                             ; $AA08: 8D B2 01
  LDA #$BE                              ; $AA0B: A9 BE
  STA $01B3                             ; $AA0D: 8D B3 01
Loc_AA10:
  LDA $0628,Y                           ; $AA10: B9 28 06
  AND #$03                              ; $AA13: 29 03
  CMP #$01                              ; $AA15: C9 01
  BNE $AA23                             ; $AA17: D0 0A
  LDA #$AC                              ; $AA19: A9 AC
  STA $01B2                             ; $AA1B: 8D B2 01
  LDA #$AD                              ; $AA1E: A9 AD
  STA $01B3                             ; $AA20: 8D B3 01
Loc_AA23:
  RTS                                   ; $AA23: 60
Loc_AA24:
  PLA                                   ; $AA24: 68
  TAY                                   ; $AA25: A8
  PHA                                   ; $AA26: 48
  LDA $063C,Y                           ; $AA27: B9 3C 06
  TAY                                   ; $AA2A: A8
  LDA $AAFA,Y                           ; $AA2B: B9 FA AA
  STA $01B0                             ; $AA2E: 8D B0 01
  LDA $AB05,Y                           ; $AA31: B9 05 AB
  STA $01B1                             ; $AA34: 8D B1 01
  PLA                                   ; $AA37: 68
  TAY                                   ; $AA38: A8
  BEQ $AA3F                             ; $AA39: F0 04
  CPY #$0A                              ; $AA3B: C0 0A
  BNE $AA55                             ; $AA3D: D0 16
Loc_AA3F:
  LDA #$B1                              ; $AA3F: A9 B1
  STA $01B0                             ; $AA41: 8D B0 01
  LDA $063C,Y                           ; $AA44: B9 3C 06
  CMP #$0A                              ; $AA47: C9 0A
  BNE $AA55                             ; $AA49: D0 0A
  LDA #$B0                              ; $AA4B: A9 B0
  STA $01B0                             ; $AA4D: 8D B0 01
  LDA #$8B                              ; $AA50: A9 8B
  STA $01B1                             ; $AA52: 8D B1 01
Loc_AA55:
  LDA #$8C                              ; $AA55: A9 8C
  STA $01B2                             ; $AA57: 8D B2 01
  LDA #$8D                              ; $AA5A: A9 8D
  STA $01B3                             ; $AA5C: 8D B3 01
  LDA $0628,Y                           ; $AA5F: B9 28 06
  AND #$03                              ; $AA62: 29 03
  BNE $AA70                             ; $AA64: D0 0A
  LDA #$B3                              ; $AA66: A9 B3
  STA $01B2                             ; $AA68: 8D B2 01
  LDA #$B4                              ; $AA6B: A9 B4
  STA $01B3                             ; $AA6D: 8D B3 01
Loc_AA70:
  LDA $0628,Y                           ; $AA70: B9 28 06
  AND #$03                              ; $AA73: 29 03
  CMP #$02                              ; $AA75: C9 02
  BNE $AA83                             ; $AA77: D0 0A
  LDA #$8E                              ; $AA79: A9 8E
  STA $01B2                             ; $AA7B: 8D B2 01
  LDA #$8F                              ; $AA7E: A9 8F
  STA $01B3                             ; $AA80: 8D B3 01
Loc_AA83:
  RTS                                   ; $AA83: 60
Loc_AA84:
  PLA                                   ; $AA84: 68
  TAY                                   ; $AA85: A8
  PHA                                   ; $AA86: 48
  LDA $063C,Y                           ; $AA87: B9 3C 06
  TAY                                   ; $AA8A: A8
  LDA $AB10,Y                           ; $AA8B: B9 10 AB
  STA $01B0                             ; $AA8E: 8D B0 01
  LDA $AB1B,Y                           ; $AA91: B9 1B AB
  STA $01B1                             ; $AA94: 8D B1 01
  PLA                                   ; $AA97: 68
  TAY                                   ; $AA98: A8
  BEQ $AA9F                             ; $AA99: F0 04
  CPY #$0A                              ; $AA9B: C0 0A
  BNE $AAB5                             ; $AA9D: D0 16
Loc_AA9F:
  LDA #$B6                              ; $AA9F: A9 B6
  STA $01B0                             ; $AAA1: 8D B0 01
  LDA $063C,Y                           ; $AAA4: B9 3C 06
  CMP #$0A                              ; $AAA7: C9 0A
  BNE $AAB5                             ; $AAA9: D0 0A
  LDA #$B5                              ; $AAAB: A9 B5
Loc_AAAD:  ; (dispatch callback target)
  STA $01B0                             ; $AAAD: 8D B0 01
  LDA #$9B                              ; $AAB0: A9 9B
  STA $01B1                             ; $AAB2: 8D B1 01
Loc_AAB5:
  LDA #$9C                              ; $AAB5: A9 9C
  STA $01B2                             ; $AAB7: 8D B2 01
  LDA #$9D                              ; $AABA: A9 9D
  STA $01B3                             ; $AABC: 8D B3 01
  LDA $0628,Y                           ; $AABF: B9 28 06
  AND #$03                              ; $AAC2: 29 03
  BNE $AAD0                             ; $AAC4: D0 0A
  LDA #$B8                              ; $AAC6: A9 B8
  STA $01B2                             ; $AAC8: 8D B2 01
  LDA #$B9                              ; $AACB: A9 B9
  STA $01B3                             ; $AACD: 8D B3 01
Loc_AAD0:
  LDA $0628,Y                           ; $AAD0: B9 28 06
  AND #$03                              ; $AAD3: 29 03
  CMP #$02                              ; $AAD5: C9 02
  BNE $AAE3                             ; $AAD7: D0 0A
  LDA #$9E                              ; $AAD9: A9 9E
  STA $01B2                             ; $AADB: 8D B2 01
  LDA #$9F                              ; $AADE: A9 9F
  STA $01B3                             ; $AAE0: 8D B3 01
Loc_AAE3:
  RTS                                   ; $AAE3: 60
; --- Data Region ---
  .byte $BC,$BC,$BC,$BC,$BC,$BC,$BC,$BC,$BC,$BC,$AA,$A0,$A1,$A2,$A3,$A4; $AAE4: BC BC BC BC BC BC BC BC BC BC AA A0 A1 A2 A3 A4
  .byte $A5,$A6,$A7,$A8,$A9,$AB,$B2,$B2,$B2,$B2,$B2,$B2,$B2,$B2,$B2,$B2; $AAF4: A5 A6 A7 A8 A9 AB B2 B2 B2 B2 B2 B2 B2 B2 B2 B2
  .byte $8A,$80,$81,$82,$83,$84,$85,$86,$87,$88,$89,$8B,$B7,$B7,$B7,$B7; $AB04: 8A 80 81 82 83 84 85 86 87 88 89 8B B7 B7 B7 B7
  .byte $B7,$B7,$B7,$B7,$B7,$B7,$9A,$90,$91,$92,$93,$94,$95,$96,$97,$98; $AB14: B7 B7 B7 B7 B7 B7 9A 90 91 92 93 94 95 96 97 98
  .byte $99,$9B                           ; $AB24: 99 9B
Loc_AB26:
; --- Code Region ---
  LDA $000C                             ; $AB26: AD 0C 00
  STA $0018                             ; $AB29: 8D 18 00
  LDA $000D                             ; $AB2C: AD 0D 00
  LSR                                   ; $AB2F: 4A
  ROR $0018                             ; $AB30: 6E 18 00
  LSR $0018                             ; $AB33: 4E 18 00
  LSR $0018                             ; $AB36: 4E 18 00
  LSR $0018                             ; $AB39: 4E 18 00
  LDA $000E                             ; $AB3C: AD 0E 00
  STA $0019                             ; $AB3F: 8D 19 00
  LDA $000F                             ; $AB42: AD 0F 00
  LSR                                   ; $AB45: 4A
  ROR $0019                             ; $AB46: 6E 19 00
  LSR $0019                             ; $AB49: 4E 19 00
  LSR $0019                             ; $AB4C: 4E 19 00
  LSR $0019                             ; $AB4F: 4E 19 00
  RTS                                   ; $AB52: 60
Loc_AB53:
  LDA $008E                             ; $AB53: AD 8E 00
  SEC                                   ; $AB56: 38
  SBC #$06                              ; $AB57: E9 06
  LSR                                   ; $AB59: 4A
  LSR                                   ; $AB5A: 4A
  LSR                                   ; $AB5B: 4A
  CMP $0095                             ; $AB5C: CD 95 00
  BEQ $AB68                             ; $AB5F: F0 07
  STA $0095                             ; $AB61: 8D 95 00
  JSR $AB7B                             ; $AB64: 20 7B AB
  RTS                                   ; $AB67: 60
Loc_AB68:
  LDA $0090                             ; $AB68: AD 90 00
  LSR                                   ; $AB6B: 4A
  LSR                                   ; $AB6C: 4A
  LSR                                   ; $AB6D: 4A
  LSR                                   ; $AB6E: 4A
  CMP $0094                             ; $AB6F: CD 94 00
  BEQ $AB7A                             ; $AB72: F0 06
  STA $0094                             ; $AB74: 8D 94 00
  JSR $AB87                             ; $AB77: 20 87 AB
Loc_AB7A:
  RTS                                   ; $AB7A: 60
Loc_AB7B:
  LDA $009C                             ; $AB7B: AD 9C 00
  ASL                                   ; $AB7E: 0A
  BMI $AB84                             ; $AB7F: 30 03
  JMP $AD69                             ; $AB81: 4C 69 AD
Loc_AB84:
  JMP $AB94                             ; $AB84: 4C 94 AB
Loc_AB87:
  LDA $009C                             ; $AB87: AD 9C 00
  AND #$10                              ; $AB8A: 29 10
  BEQ $AB91                             ; $AB8C: F0 03
  JMP $AD9F                             ; $AB8E: 4C 9F AD
Loc_AB91:
  JMP $AEB5                             ; $AB91: 4C B5 AE
Loc_AB94:
  LDA $008E                             ; $AB94: AD 8E 00
  STA $000C                             ; $AB97: 8D 0C 00
  LDA $008F                             ; $AB9A: AD 8F 00
  STA $000D                             ; $AB9D: 8D 0D 00
  LDA $0090                             ; $ABA0: AD 90 00
  STA $000E                             ; $ABA3: 8D 0E 00
  LDA $0091                             ; $ABA6: AD 91 00
  STA $000F                             ; $ABA9: 8D 0F 00
  LDA $008E                             ; $ABAC: AD 8E 00
  STA $001C                             ; $ABAF: 8D 1C 00
  LDA $008F                             ; $ABB2: AD 8F 00
  STA $001D                             ; $ABB5: 8D 1D 00
  INC $001D                             ; $ABB8: EE 1D 00
  LDA $0090                             ; $ABBB: AD 90 00
  STA $001E                             ; $ABBE: 8D 1E 00
  LDA $0091                             ; $ABC1: AD 91 00
  STA $001F                             ; $ABC4: 8D 1F 00
Loc_ABC7:
  JSR $A604                             ; $ABC7: 20 04 A6
  STY $000A                             ; $ABCA: 8C 0A 00
  JSR $AEF3                             ; $ABCD: 20 F3 AE
  LDA $000A                             ; $ABD0: AD 0A 00
  CLC                                   ; $ABD3: 18
  ADC #$02                              ; $ABD4: 69 02
  TAY                                   ; $ABD6: A8
  LDA ($A8),Y                           ; $ABD7: B1 A8
  STA $000A                             ; $ABD9: 8D 0A 00
  JSR $A610                             ; $ABDC: 20 10 A6
  STY $001A                             ; $ABDF: 8C 1A 00
  JSR $AF0C                             ; $ABE2: 20 0C AF
  LDA $001A                             ; $ABE5: AD 1A 00
  CLC                                   ; $ABE8: 18
  ADC #$02                              ; $ABE9: 69 02
  TAY                                   ; $ABEB: A8
  LDA ($A8),Y                           ; $ABEC: B1 A8
  STA $001A                             ; $ABEE: 8D 1A 00
  LDX #$00                              ; $ABF1: A2 00
  STX $0006                             ; $ABF3: 8E 06 00
  LDA $000C                             ; $ABF6: AD 0C 00
  LSR                                   ; $ABF9: 4A
  LSR                                   ; $ABFA: 4A
  LSR                                   ; $ABFB: 4A
  LSR                                   ; $ABFC: 4A
  LSR                                   ; $ABFD: 4A
  STA $0008                             ; $ABFE: 8D 08 00
  LDA $000E                             ; $AC01: AD 0E 00
  AND #$E0                              ; $AC04: 29 E0
  LSR                                   ; $AC06: 4A
  LSR                                   ; $AC07: 4A
  CLC                                   ; $AC08: 18
  ADC $0008                             ; $AC09: 6D 08 00
  STA $0005                             ; $AC0C: 8D 05 00
  JSR $AFF9                             ; $AC0F: 20 F9 AF
  LDX #$00                              ; $AC12: A2 00
  LDA #$08                              ; $AC14: A9 08
  STA $0007                             ; $AC16: 8D 07 00
  LDA $000E                             ; $AC19: AD 0E 00
  AND #$10                              ; $AC1C: 29 10
  BEQ $AC23                             ; $AC1E: F0 03
  INC $0007                             ; $AC20: EE 07 00
Loc_AC23:
  LDY $0005                             ; $AC23: AC 05 00
  LDA ($00),Y                           ; $AC26: B1 00
  STA $0002                             ; $AC28: 8D 02 00
  LDA ($10),Y                           ; $AC2B: B1 10
  STA $0003                             ; $AC2D: 8D 03 00
  JSR $AF1B                             ; $AC30: 20 1B AF
  INC $0017                             ; $AC33: EE 17 00
  INC $0017                             ; $AC36: EE 17 00
  INC $0019                             ; $AC39: EE 19 00
  INC $0019                             ; $AC3C: EE 19 00
  JSR $AC80                             ; $AC3F: 20 80 AC
  LDA $0005                             ; $AC42: AD 05 00
  CLC                                   ; $AC45: 18
  ADC #$08                              ; $AC46: 69 08
  CMP #$40                              ; $AC48: C9 40
  BCC $AC5C                             ; $AC4A: 90 10
  AND #$07                              ; $AC4C: 29 07
  PHA                                   ; $AC4E: 48
  LDA $000A                             ; $AC4F: AD 0A 00
  JSR $AEF3                             ; $AC52: 20 F3 AE
  LDA $001A                             ; $AC55: AD 1A 00
  JSR $AF0C                             ; $AC58: 20 0C AF
  PLA                                   ; $AC5B: 68
Loc_AC5C:
  STA $0005                             ; $AC5C: 8D 05 00
  INC $0006                             ; $AC5F: EE 06 00
  LDA $0006                             ; $AC62: AD 06 00
  CMP $0007                             ; $AC65: CD 07 00
  BCC $AC23                             ; $AC68: 90 B9
  LDA #$88                              ; $AC6A: A9 88
  STA $0000                             ; $AC6C: 8D 00 00
  LDA #$01                              ; $AC6F: A9 01
  STA $0001                             ; $AC71: 8D 01 00
  JSR $A8D3                             ; $AC74: 20 D3 A8
  LDA $007E                             ; $AC77: AD 7E 00
  ORA #$20                              ; $AC7A: 09 20
  STA $007E                             ; $AC7C: 8D 7E 00
  RTS                                   ; $AC7F: 60
Loc_AC80:
  LDA $009C                             ; $AC80: AD 9C 00
  ASL                                   ; $AC83: 0A
  BPL $ACF4                             ; $AC84: 10 6E
  LDA $000C                             ; $AC86: AD 0C 00
  AND #$10                              ; $AC89: 29 10
  BNE $ACB8                             ; $AC8B: D0 2B
  LDA $0006                             ; $AC8D: AD 06 00
  CMP #$08                              ; $AC90: C9 08
  BNE $ACB0                             ; $AC92: D0 1C
  LDA $000E                             ; $AC94: AD 0E 00
  AND #$10                              ; $AC97: 29 10
  BEQ $ACB0                             ; $AC99: F0 15
  LDA $018A                             ; $AC9B: AD 8A 01
  AND #$F0                              ; $AC9E: 29 F0
  STA $018A                             ; $ACA0: 8D 8A 01
  LDA $0002                             ; $ACA3: AD 02 00
  AND #$0F                              ; $ACA6: 29 0F
  ORA $018A                             ; $ACA8: 0D 8A 01
  STA $018A                             ; $ACAB: 8D 8A 01
  INX                                   ; $ACAE: E8
  RTS                                   ; $ACAF: 60
Loc_ACB0:
  LDA $0002                             ; $ACB0: AD 02 00
  STA $018A,X                           ; $ACB3: 9D 8A 01
  INX                                   ; $ACB6: E8
  RTS                                   ; $ACB7: 60
Loc_ACB8:
  LDA $0006                             ; $ACB8: AD 06 00
  CMP #$08                              ; $ACBB: C9 08
  BNE $ACDF                             ; $ACBD: D0 20
  LDA $018A                             ; $ACBF: AD 8A 01
  AND #$F0                              ; $ACC2: 29 F0
  STA $018A                             ; $ACC4: 8D 8A 01
  LDA $0002                             ; $ACC7: AD 02 00
  AND #$0C                              ; $ACCA: 29 0C
  STA $0002                             ; $ACCC: 8D 02 00
  LDA $0003                             ; $ACCF: AD 03 00
  AND #$03                              ; $ACD2: 29 03
  ORA $0002                             ; $ACD4: 0D 02 00
  ORA $018A                             ; $ACD7: 0D 8A 01
  STA $018A                             ; $ACDA: 8D 8A 01
  INX                                   ; $ACDD: E8
  RTS                                   ; $ACDE: 60
Loc_ACDF:
  LDA $0002                             ; $ACDF: AD 02 00
  AND #$CC                              ; $ACE2: 29 CC
  STA $0002                             ; $ACE4: 8D 02 00
  LDA $0003                             ; $ACE7: AD 03 00
  AND #$33                              ; $ACEA: 29 33
  ORA $0002                             ; $ACEC: 0D 02 00
  STA $018A,X                           ; $ACEF: 9D 8A 01
  INX                                   ; $ACF2: E8
  RTS                                   ; $ACF3: 60
Loc_ACF4:
  LDA $000C                             ; $ACF4: AD 0C 00
  AND #$10                              ; $ACF7: 29 10
  BEQ $AD26                             ; $ACF9: F0 2B
  LDA $0006                             ; $ACFB: AD 06 00
  CMP #$08                              ; $ACFE: C9 08
  BNE $AD1E                             ; $AD00: D0 1C
  LDA $000E                             ; $AD02: AD 0E 00
  AND #$10                              ; $AD05: 29 10
  BEQ $AD1E                             ; $AD07: F0 15
  LDA $018A                             ; $AD09: AD 8A 01
  AND #$F0                              ; $AD0C: 29 F0
  STA $018A                             ; $AD0E: 8D 8A 01
  LDA $0002                             ; $AD11: AD 02 00
  AND #$0F                              ; $AD14: 29 0F
  ORA $018A                             ; $AD16: 0D 8A 01
  STA $018A                             ; $AD19: 8D 8A 01
  INX                                   ; $AD1C: E8
  RTS                                   ; $AD1D: 60
Loc_AD1E:
  LDA $0002                             ; $AD1E: AD 02 00
  STA $018A,X                           ; $AD21: 9D 8A 01
  INX                                   ; $AD24: E8
  RTS                                   ; $AD25: 60
Loc_AD26:
  LDA $0006                             ; $AD26: AD 06 00
  CMP #$08                              ; $AD29: C9 08
  BNE $AD54                             ; $AD2B: D0 27
  LDA $000E                             ; $AD2D: AD 0E 00
  AND #$10                              ; $AD30: 29 10
  BEQ $AD54                             ; $AD32: F0 20
  LDA $018A                             ; $AD34: AD 8A 01
  AND #$F0                              ; $AD37: 29 F0
  STA $018A                             ; $AD39: 8D 8A 01
  LDA $0002                             ; $AD3C: AD 02 00
  AND #$03                              ; $AD3F: 29 03
  STA $0002                             ; $AD41: 8D 02 00
  LDA $0003                             ; $AD44: AD 03 00
  AND #$0C                              ; $AD47: 29 0C
  ORA $0002                             ; $AD49: 0D 02 00
  ORA $018A                             ; $AD4C: 0D 8A 01
  STA $018A                             ; $AD4F: 8D 8A 01
  INX                                   ; $AD52: E8
  RTS                                   ; $AD53: 60
Loc_AD54:
  LDA $0002                             ; $AD54: AD 02 00
  AND #$33                              ; $AD57: 29 33
  STA $0002                             ; $AD59: 8D 02 00
  LDA $0003                             ; $AD5C: AD 03 00
  AND #$CC                              ; $AD5F: 29 CC
  ORA $0002                             ; $AD61: 0D 02 00
  STA $018A,X                           ; $AD64: 9D 8A 01
  INX                                   ; $AD67: E8
  RTS                                   ; $AD68: 60
Loc_AD69:
  LDA $008E                             ; $AD69: AD 8E 00
  STA $000C                             ; $AD6C: 8D 0C 00
  LDA $008F                             ; $AD6F: AD 8F 00
  STA $000D                             ; $AD72: 8D 0D 00
  INC $000D                             ; $AD75: EE 0D 00
  LDA $0090                             ; $AD78: AD 90 00
  STA $000E                             ; $AD7B: 8D 0E 00
  LDA $0091                             ; $AD7E: AD 91 00
  STA $000F                             ; $AD81: 8D 0F 00
  LDA $008E                             ; $AD84: AD 8E 00
  STA $001C                             ; $AD87: 8D 1C 00
  LDA $008F                             ; $AD8A: AD 8F 00
  STA $001D                             ; $AD8D: 8D 1D 00
  LDA $0090                             ; $AD90: AD 90 00
  STA $001E                             ; $AD93: 8D 1E 00
  LDA $0091                             ; $AD96: AD 91 00
  STA $001F                             ; $AD99: 8D 1F 00
  JMP $ABC7                             ; $AD9C: 4C C7 AB
Loc_AD9F:
  LDA $008E                             ; $AD9F: AD 8E 00
  CLC                                   ; $ADA2: 18
  ADC #$04                              ; $ADA3: 69 04
  STA $000C                             ; $ADA5: 8D 0C 00
  LDA $008F                             ; $ADA8: AD 8F 00
  ADC #$00                              ; $ADAB: 69 00
Loc_ADAD:  ; (dispatch callback target)
  STA $000D                             ; $ADAD: 8D 0D 00
  LDA $0090                             ; $ADB0: AD 90 00
  STA $000E                             ; $ADB3: 8D 0E 00
  LDA $0091                             ; $ADB6: AD 91 00
  STA $000F                             ; $ADB9: 8D 0F 00
Loc_ADBC:
  JSR $A604                             ; $ADBC: 20 04 A6
  STY $000A                             ; $ADBF: 8C 0A 00
  JSR $AEF3                             ; $ADC2: 20 F3 AE
  LDY $000A                             ; $ADC5: AC 0A 00
  INY                                   ; $ADC8: C8
  LDA ($A8),Y                           ; $ADC9: B1 A8
  STA $000A                             ; $ADCB: 8D 0A 00
  LDA #$00                              ; $ADCE: A9 00
  STA $0006                             ; $ADD0: 8D 06 00
  LDA $000C                             ; $ADD3: AD 0C 00
  LSR                                   ; $ADD6: 4A
  LSR                                   ; $ADD7: 4A
  LSR                                   ; $ADD8: 4A
  LSR                                   ; $ADD9: 4A
  LSR                                   ; $ADDA: 4A
  STA $0008                             ; $ADDB: 8D 08 00
  LDA $000E                             ; $ADDE: AD 0E 00
  AND #$E0                              ; $ADE1: 29 E0
  LSR                                   ; $ADE3: 4A
  LSR                                   ; $ADE4: 4A
  CLC                                   ; $ADE5: 18
  ADC $0008                             ; $ADE6: 6D 08 00
  STA $0005                             ; $ADE9: 8D 05 00
  JSR $B055                             ; $ADEC: 20 55 B0
  LDX #$00                              ; $ADEF: A2 00
  LDA #$08                              ; $ADF1: A9 08
  STA $0007                             ; $ADF3: 8D 07 00
  LDA $000C                             ; $ADF6: AD 0C 00
  AND #$10                              ; $ADF9: 29 10
  BEQ $AE00                             ; $ADFB: F0 03
  INC $0007                             ; $ADFD: EE 07 00
Loc_AE00:
  LDY $0005                             ; $AE00: AC 05 00
  LDA ($00),Y                           ; $AE03: B1 00
  STA $0002                             ; $AE05: 8D 02 00
  JSR $AFB5                             ; $AE08: 20 B5 AF
  INC $0016                             ; $AE0B: EE 16 00
  INC $0016                             ; $AE0E: EE 16 00
  INC $0018                             ; $AE11: EE 18 00
  INC $0018                             ; $AE14: EE 18 00
  JSR $AE58                             ; $AE17: 20 58 AE
  LDA $0005                             ; $AE1A: AD 05 00
  INC $0005                             ; $AE1D: EE 05 00
  AND #$07                              ; $AE20: 29 07
  CMP #$07                              ; $AE22: C9 07
  BNE $AE37                             ; $AE24: D0 11
  LDA $000A                             ; $AE26: AD 0A 00
  JSR $AEF3                             ; $AE29: 20 F3 AE
  DEC $0005                             ; $AE2C: CE 05 00
  LDA $0005                             ; $AE2F: AD 05 00
  AND #$F8                              ; $AE32: 29 F8
  STA $0005                             ; $AE34: 8D 05 00
Loc_AE37:
  INC $0006                             ; $AE37: EE 06 00
  LDA $0006                             ; $AE3A: AD 06 00
  CMP $0007                             ; $AE3D: CD 07 00
  BCC $AE00                             ; $AE40: 90 BE
  LDA #$9C                              ; $AE42: A9 9C
  STA $0000                             ; $AE44: 8D 00 00
  LDA #$01                              ; $AE47: A9 01
  STA $0001                             ; $AE49: 8D 01 00
  JSR $A8D3                             ; $AE4C: 20 D3 A8
  LDA $007E                             ; $AE4F: AD 7E 00
  ORA #$10                              ; $AE52: 09 10
  STA $007E                             ; $AE54: 8D 7E 00
  RTS                                   ; $AE57: 60
Loc_AE58:
  LDA $009C                             ; $AE58: AD 9C 00
  AND #$10                              ; $AE5B: 29 10
  BEQ $AE8A                             ; $AE5D: F0 2B
  LDA $0006                             ; $AE5F: AD 06 00
  CMP #$08                              ; $AE62: C9 08
  BNE $AE82                             ; $AE64: D0 1C
  LDA $000C                             ; $AE66: AD 0C 00
  AND #$10                              ; $AE69: 29 10
  BEQ $AE82                             ; $AE6B: F0 15
  LDA $019E                             ; $AE6D: AD 9E 01
  AND #$CC                              ; $AE70: 29 CC
  STA $019E                             ; $AE72: 8D 9E 01
  LDA $0002                             ; $AE75: AD 02 00
  AND #$33                              ; $AE78: 29 33
  ORA $019E                             ; $AE7A: 0D 9E 01
  STA $019E                             ; $AE7D: 8D 9E 01
  INX                                   ; $AE80: E8
  RTS                                   ; $AE81: 60
Loc_AE82:
  LDA $0002                             ; $AE82: AD 02 00
  STA $019E,X                           ; $AE85: 9D 9E 01
  INX                                   ; $AE88: E8
  RTS                                   ; $AE89: 60
Loc_AE8A:
  LDA $0006                             ; $AE8A: AD 06 00
  CMP #$08                              ; $AE8D: C9 08
  BNE $AEAD                             ; $AE8F: D0 1C
  LDA $000C                             ; $AE91: AD 0C 00
  AND #$10                              ; $AE94: 29 10
  BEQ $AEAD                             ; $AE96: F0 15
  LDA $019E                             ; $AE98: AD 9E 01
  AND #$CC                              ; $AE9B: 29 CC
  STA $019E                             ; $AE9D: 8D 9E 01
  LDA $0002                             ; $AEA0: AD 02 00
  AND #$33                              ; $AEA3: 29 33
  ORA $019E                             ; $AEA5: 0D 9E 01
  STA $019E                             ; $AEA8: 8D 9E 01
  INX                                   ; $AEAB: E8
  RTS                                   ; $AEAC: 60
Loc_AEAD:
  LDA $0002                             ; $AEAD: AD 02 00
  STA $019E,X                           ; $AEB0: 9D 9E 01
  INX                                   ; $AEB3: E8
  RTS                                   ; $AEB4: 60
Loc_AEB5:
  LDA $008E                             ; $AEB5: AD 8E 00
  CLC                                   ; $AEB8: 18
  ADC #$04                              ; $AEB9: 69 04
  STA $000C                             ; $AEBB: 8D 0C 00
  LDA $008F                             ; $AEBE: AD 8F 00
  ADC #$00                              ; $AEC1: 69 00
  STA $000D                             ; $AEC3: 8D 0D 00
  LDA $0090                             ; $AEC6: AD 90 00
  CLC                                   ; $AEC9: 18
  ADC #$A0                              ; $AECA: 69 A0
  STA $000E                             ; $AECC: 8D 0E 00
  BCS $AED5                             ; $AECF: B0 04
  CMP #$F0                              ; $AED1: C9 F0
  BCC $AEE7                             ; $AED3: 90 12
Loc_AED5:
  CLC                                   ; $AED5: 18
  ADC #$10                              ; $AED6: 69 10
  STA $000E                             ; $AED8: 8D 0E 00
  LDA $0091                             ; $AEDB: AD 91 00
  STA $000F                             ; $AEDE: 8D 0F 00
  INC $000F                             ; $AEE1: EE 0F 00
  JMP $ADBC                             ; $AEE4: 4C BC AD
Loc_AEE7:
  LDA $0091                             ; $AEE7: AD 91 00
  STA $000F                             ; $AEEA: 8D 0F 00
  JMP $ADBC                             ; $AEED: 4C BC AD
Loc_AEF0:
  LDA $0000                             ; $AEF0: AD 00 00
Loc_AEF3:
  PHA                                   ; $AEF3: 48
  ASL                                   ; $AEF4: 0A
  TAY                                   ; $AEF5: A8
  LDA $A732,Y                           ; $AEF6: B9 32 A7
  STA $0000                             ; $AEF9: 8D 00 00
  LDA $A733,Y                           ; $AEFC: B9 33 A7
  STA $0001                             ; $AEFF: 8D 01 00
  PLA                                   ; $AF02: 68
  TAY                                   ; $AF03: A8
  LDA $A822,Y                           ; $AF04: B9 22 A8
  TAY                                   ; $AF07: A8
  JSR $F25F                             ; $AF08: 20 5F F2
  RTS                                   ; $AF0B: 60
Loc_AF0C:
  ASL                                   ; $AF0C: 0A
  TAY                                   ; $AF0D: A8
  LDA $A732,Y                           ; $AF0E: B9 32 A7
  STA $0010                             ; $AF11: 8D 10 00
  LDA $A733,Y                           ; $AF14: B9 33 A7
  STA $0011                             ; $AF17: 8D 11 00
  RTS                                   ; $AF1A: 60
Loc_AF1B:
  LDA $000C                             ; $AF1B: AD 0C 00
  CLC                                   ; $AF1E: 18
  ADC #$08                              ; $AF1F: 69 08
  AND #$10                              ; $AF21: 29 10
  BEQ $AF2C                             ; $AF23: F0 07
  JSR $AF30                             ; $AF25: 20 30 AF
  JSR $AF71                             ; $AF28: 20 71 AF
  RTS                                   ; $AF2B: 60
Loc_AF2C:
  JSR $AF30                             ; $AF2C: 20 30 AF
  RTS                                   ; $AF2F: 60
Loc_AF30:
  LDY $0019                             ; $AF30: AC 19 00
  LDA $0680,Y                           ; $AF33: B9 80 06
  BMI $AF42                             ; $AF36: 30 0A
  LDA $0002                             ; $AF38: AD 02 00
  AND #$FC                              ; $AF3B: 29 FC
  ORA #$02                              ; $AF3D: 09 02
  STA $0002                             ; $AF3F: 8D 02 00
Loc_AF42:
  LDA $06A0,Y                           ; $AF42: B9 A0 06
  BMI $AF51                             ; $AF45: 30 0A
  LDA $0002                             ; $AF47: AD 02 00
  AND #$F3                              ; $AF4A: 29 F3
  ORA #$08                              ; $AF4C: 09 08
  STA $0002                             ; $AF4E: 8D 02 00
Loc_AF51:
  INY                                   ; $AF51: C8
  LDA $0680,Y                           ; $AF52: B9 80 06
  BMI $AF61                             ; $AF55: 30 0A
  LDA $0002                             ; $AF57: AD 02 00
  AND #$CF                              ; $AF5A: 29 CF
  ORA #$20                              ; $AF5C: 09 20
  STA $0002                             ; $AF5E: 8D 02 00
Loc_AF61:
  LDA $06A0,Y                           ; $AF61: B9 A0 06
  BMI $AF70                             ; $AF64: 30 0A
  LDA $0002                             ; $AF66: AD 02 00
  AND #$3F                              ; $AF69: 29 3F
  ORA #$80                              ; $AF6B: 09 80
  STA $0002                             ; $AF6D: 8D 02 00
Loc_AF70:
  RTS                                   ; $AF70: 60
Loc_AF71:
  LDY $0019                             ; $AF71: AC 19 00
  LDA $06C0,Y                           ; $AF74: B9 C0 06
  BMI $AF83                             ; $AF77: 30 0A
  LDA $0003                             ; $AF79: AD 03 00
  AND #$FC                              ; $AF7C: 29 FC
  ORA #$02                              ; $AF7E: 09 02
  STA $0003                             ; $AF80: 8D 03 00
Loc_AF83:
  LDA $06E0,Y                           ; $AF83: B9 E0 06
  BMI $AF92                             ; $AF86: 30 0A
  LDA $0003                             ; $AF88: AD 03 00
  AND #$F3                              ; $AF8B: 29 F3
  ORA #$08                              ; $AF8D: 09 08
  STA $0003                             ; $AF8F: 8D 03 00
Loc_AF92:
  INY                                   ; $AF92: C8
  LDA $06C0,Y                           ; $AF93: B9 C0 06
  BMI $AFA2                             ; $AF96: 30 0A
  LDA $0003                             ; $AF98: AD 03 00
  AND #$CF                              ; $AF9B: 29 CF
  ORA #$20                              ; $AF9D: 09 20
  STA $0003                             ; $AF9F: 8D 03 00
Loc_AFA2:
  LDA $06E0,Y                           ; $AFA2: B9 E0 06
  BMI $AFB1                             ; $AFA5: 30 0A
  LDA $0003                             ; $AFA7: AD 03 00
  AND #$3F                              ; $AFAA: 29 3F
  ORA #$80                              ; $AFAC: 09 80
  STA $0003                             ; $AFAE: 8D 03 00
Loc_AFB1:
  DEC $0017                             ; $AFB1: CE 17 00
  RTS                                   ; $AFB4: 60
Loc_AFB5:
  LDY $0018                             ; $AFB5: AC 18 00
  LDA $0680,Y                           ; $AFB8: B9 80 06
  BMI $AFC7                             ; $AFBB: 30 0A
  LDA $0002                             ; $AFBD: AD 02 00
  AND #$FC                              ; $AFC0: 29 FC
  ORA #$02                              ; $AFC2: 09 02
  STA $0002                             ; $AFC4: 8D 02 00
Loc_AFC7:
  LDA $06A0,Y                           ; $AFC7: B9 A0 06
  BMI $AFD6                             ; $AFCA: 30 0A
  LDA $0002                             ; $AFCC: AD 02 00
  AND #$CF                              ; $AFCF: 29 CF
  ORA #$20                              ; $AFD1: 09 20
  STA $0002                             ; $AFD3: 8D 02 00
Loc_AFD6:
  INY                                   ; $AFD6: C8
  LDA $0680,Y                           ; $AFD7: B9 80 06
  BMI $AFE6                             ; $AFDA: 30 0A
  LDA $0002                             ; $AFDC: AD 02 00
  AND #$F3                              ; $AFDF: 29 F3
  ORA #$08                              ; $AFE1: 09 08
  STA $0002                             ; $AFE3: 8D 02 00
Loc_AFE6:
  LDA $06A0,Y                           ; $AFE6: B9 A0 06
  BMI $AFF5                             ; $AFE9: 30 0A
  LDA $0002                             ; $AFEB: AD 02 00
  AND #$3F                              ; $AFEE: 29 3F
  ORA #$80                              ; $AFF0: 09 80
  STA $0002                             ; $AFF2: 8D 02 00
Loc_AFF5:
  DEC $0017                             ; $AFF5: CE 17 00
  RTS                                   ; $AFF8: 60
Loc_AFF9:
  JSR $B08F                             ; $AFF9: 20 8F B0
  LDY #$7F                              ; $AFFC: A0 7F
  LDA #$FF                              ; $AFFE: A9 FF
Loc_B000:
  STA $0680,Y                           ; $B000: 99 80 06
  DEY                                   ; $B003: 88
  BPL $B000                             ; $B004: 10 FA
  LDY #$13                              ; $B006: A0 13
Loc_B008:
  JSR $B00F                             ; $B008: 20 0F B0
  DEY                                   ; $B00B: 88
  BPL $B008                             ; $B00C: 10 FA
  RTS                                   ; $B00E: 60
Loc_B00F:
  LDA $0600,Y                           ; $B00F: B9 00 06
  CMP $0018                             ; $B012: CD 18 00
  BNE $B020                             ; $B015: D0 09
  PHA                                   ; $B017: 48
  LDX $0614,Y                           ; $B018: BE 14 06
  TYA                                   ; $B01B: 98
  STA $0680,X                           ; $B01C: 9D 80 06
  PLA                                   ; $B01F: 68
Loc_B020:
  INC $0018                             ; $B020: EE 18 00
  CMP $0018                             ; $B023: CD 18 00
  BNE $B031                             ; $B026: D0 09
  PHA                                   ; $B028: 48
  LDX $0614,Y                           ; $B029: BE 14 06
  TYA                                   ; $B02C: 98
  STA $06A0,X                           ; $B02D: 9D A0 06
  PLA                                   ; $B030: 68
Loc_B031:
  CMP $0016                             ; $B031: CD 16 00
  BNE $B03F                             ; $B034: D0 09
  PHA                                   ; $B036: 48
  LDX $0614,Y                           ; $B037: BE 14 06
  TYA                                   ; $B03A: 98
  STA $06C0,X                           ; $B03B: 9D C0 06
  PLA                                   ; $B03E: 68
Loc_B03F:
  INC $0016                             ; $B03F: EE 16 00
  CMP $0016                             ; $B042: CD 16 00
  BNE $B04E                             ; $B045: D0 07
  LDX $0614,Y                           ; $B047: BE 14 06
  TYA                                   ; $B04A: 98
  STA $06E0,X                           ; $B04B: 9D E0 06
Loc_B04E:
  DEC $0016                             ; $B04E: CE 16 00
  DEC $0018                             ; $B051: CE 18 00
  RTS                                   ; $B054: 60
Loc_B055:
  JSR $B08F                             ; $B055: 20 8F B0
  LDY #$3F                              ; $B058: A0 3F
  LDA #$FF                              ; $B05A: A9 FF
Loc_B05C:
  STA $0680,Y                           ; $B05C: 99 80 06
  DEY                                   ; $B05F: 88
  BPL $B05C                             ; $B060: 10 FA
  LDY #$13                              ; $B062: A0 13
Loc_B064:
  JSR $B06B                             ; $B064: 20 6B B0
  DEY                                   ; $B067: 88
  BPL $B064                             ; $B068: 10 FA
  RTS                                   ; $B06A: 60
Loc_B06B:
  LDA $0614,Y                           ; $B06B: B9 14 06
  CMP $0019                             ; $B06E: CD 19 00
  BNE $B07C                             ; $B071: D0 09
  PHA                                   ; $B073: 48
  LDX $0600,Y                           ; $B074: BE 00 06
  TYA                                   ; $B077: 98
  STA $0680,X                           ; $B078: 9D 80 06
  PLA                                   ; $B07B: 68
Loc_B07C:
  INC $0019                             ; $B07C: EE 19 00
  CMP $0019                             ; $B07F: CD 19 00
  BNE $B08B                             ; $B082: D0 07
  LDX $0600,Y                           ; $B084: BE 00 06
  TYA                                   ; $B087: 98
  STA $06A0,X                           ; $B088: 9D A0 06
Loc_B08B:
  DEC $0019                             ; $B08B: CE 19 00
  RTS                                   ; $B08E: 60
Loc_B08F:
  LDA $000C                             ; $B08F: AD 0C 00
  STA $0018                             ; $B092: 8D 18 00
  LDA $000D                             ; $B095: AD 0D 00
  LSR                                   ; $B098: 4A
  ROR $0018                             ; $B099: 6E 18 00
  LSR $0018                             ; $B09C: 4E 18 00
  LSR $0018                             ; $B09F: 4E 18 00
  LSR $0018                             ; $B0A2: 4E 18 00
  LSR $0018                             ; $B0A5: 4E 18 00
  ASL $0018                             ; $B0A8: 0E 18 00
  LDA $000E                             ; $B0AB: AD 0E 00
  STA $0019                             ; $B0AE: 8D 19 00
  LDA $000F                             ; $B0B1: AD 0F 00
  LSR                                   ; $B0B4: 4A
  ROR $0019                             ; $B0B5: 6E 19 00
  LSR $0019                             ; $B0B8: 4E 19 00
  LSR $0019                             ; $B0BB: 4E 19 00
  LSR $0019                             ; $B0BE: 4E 19 00
  LSR $0019                             ; $B0C1: 4E 19 00
  ASL $0019                             ; $B0C4: 0E 19 00
  LDA $001C                             ; $B0C7: AD 1C 00
  STA $0016                             ; $B0CA: 8D 16 00
  LDA $001D                             ; $B0CD: AD 1D 00
  LSR                                   ; $B0D0: 4A
  ROR $0016                             ; $B0D1: 6E 16 00
  LSR $0016                             ; $B0D4: 4E 16 00
  LSR $0016                             ; $B0D7: 4E 16 00
  LSR $0016                             ; $B0DA: 4E 16 00
  LSR $0016                             ; $B0DD: 4E 16 00
  ASL $0016                             ; $B0E0: 0E 16 00
  LDA $000E                             ; $B0E3: AD 0E 00
  STA $0017                             ; $B0E6: 8D 17 00
  LDA $000F                             ; $B0E9: AD 0F 00
  LSR                                   ; $B0EC: 4A
  ROR $0017                             ; $B0ED: 6E 17 00
  LSR $0017                             ; $B0F0: 4E 17 00
  LSR $0017                             ; $B0F3: 4E 17 00
  LSR $0017                             ; $B0F6: 4E 17 00
  LSR $0017                             ; $B0F9: 4E 17 00
  ASL $0017                             ; $B0FC: 0E 17 00
  RTS                                   ; $B0FF: 60
Loc_B100:
  LDY $04AA                             ; $B100: AC AA 04
  LDA $04AB,Y                           ; $B103: B9 AB 04
  BPL $B10F                             ; $B106: 10 07
  TYA                                   ; $B108: 98
  EOR #$01                              ; $B109: 49 01
  TAY                                   ; $B10B: A8
  LDA $04AB,Y                           ; $B10C: B9 AB 04
Loc_B10F:
  STA $6F44                             ; $B10F: 8D 44 6F
  LDA $04A8                             ; $B112: AD A8 04
  JSR $EADE                             ; $B115: 20 DE EA
; --- Data Region ---
  .byte $44,$B1,$4F,$B3,$C8,$B5,$C7,$B8,$6D,$BA,$3B,$BC,$E9,$BC,$78,$BE; $B118: 44 B1 4F B3 C8 B5 C7 B8 6D BA 3B BC E9 BC 78 BE
  .byte $8A,$C0,$16,$C1,$44,$B1,$44,$B1,$44,$B1,$1C,$C2,$F6,$C2,$64,$C4; $B128: 8A C0 16 C1 44 B1 44 B1 44 B1 1C C2 F6 C2 64 C4
  .byte $98,$C4,$89,$C6,$49,$C9,$9E,$CB,$87,$CC,$3C,$CD,$AD,$A9,$04,$20; $B138: 98 C4 89 C6 49 C9 9E CB 87 CC 3C CD AD A9 04 20
  .byte $DE,$EA,$5A,$B1,$A6,$B1,$BB,$B1,$D4,$B1,$EE,$B1,$1C,$B2,$30,$B2; $B148: DE EA 5A B1 A6 B1 BB B1 D4 B1 EE B1 1C B2 30 B2
  .byte $E0,$B2                           ; $B158: E0 B2
Loc_B15A:  ; (dispatch callback target)
; --- Code Region ---
  LDA $0087                             ; $B15A: AD 87 00
  BMI $B160                             ; $B15D: 30 01
  RTS                                   ; $B15F: 60
Loc_B160:
  INC $04A9                             ; $B160: EE A9 04
  LDX #$00                              ; $B163: A2 00
Loc_B165:
  LDA $04AD,X                           ; $B165: BD AD 04
  JSR $F2D7                             ; $B168: 20 D7 F2
  LDY #$00                              ; $B16B: A0 00
  LDA ($00),Y                           ; $B16D: B1 00
  STA $04B1,X                           ; $B16F: 9D B1 04
  JSR $B188                             ; $B172: 20 88 B1
  INX                                   ; $B175: E8
  CPX #$02                              ; $B176: E0 02
  BCC $B165                             ; $B178: 90 EB
  LDA #$43                              ; $B17A: A9 43
  STA $0000                             ; $B17C: 8D 00 00
  LDA $04AF                             ; $B17F: AD AF 04
  CLC                                   ; $B182: 18
  ADC #$01                              ; $B183: 69 01
  JMP $CDFD                             ; $B185: 4C FD CD
Loc_B188:
  LDY #$0A                              ; $B188: A0 0A
  LDA ($00),Y                           ; $B18A: B1 00
  AND #$1F                              ; $B18C: 29 1F
  CMP #$10                              ; $B18E: C9 10
  BCC $B197                             ; $B190: 90 05
  LDA #$01                              ; $B192: A9 01
  JMP $B1A2                             ; $B194: 4C A2 B1
Loc_B197:
  CMP #$08                              ; $B197: C9 08
  BCC $B1A0                             ; $B199: 90 05
  LDA #$00                              ; $B19B: A9 00
  JMP $B1A2                             ; $B19D: 4C A2 B1
Loc_B1A0:
  LDA #$02                              ; $B1A0: A9 02
Loc_B1A2:
  STA $04AF,X                           ; $B1A2: 9D AF 04
  RTS                                   ; $B1A5: 60
Loc_B1A6:  ; (dispatch callback target)
  LDA $007E                             ; $B1A6: AD 7E 00
  AND #$04                              ; $B1A9: 29 04
  BNE $B1BA                             ; $B1AB: D0 0D
  LDA #$E3                              ; $B1AD: A9 E3
  STA $0000                             ; $B1AF: 8D 00 00
  LDA #$04                              ; $B1B2: A9 04
  JSR $CDFD                             ; $B1B4: 20 FD CD
  INC $04A9                             ; $B1B7: EE A9 04
Loc_B1BA:
  RTS                                   ; $B1BA: 60
Loc_B1BB:  ; (dispatch callback target)
  LDA $007E                             ; $B1BB: AD 7E 00
  AND #$04                              ; $B1BE: 29 04
  BNE $B1D3                             ; $B1C0: D0 11
  LDA #$55                              ; $B1C2: A9 55
  STA $0000                             ; $B1C4: 8D 00 00
  LDA $04B0                             ; $B1C7: AD B0 04
  CLC                                   ; $B1CA: 18
  ADC #$05                              ; $B1CB: 69 05
  JSR $CDFD                             ; $B1CD: 20 FD CD
  INC $04A9                             ; $B1D0: EE A9 04
Loc_B1D3:
  RTS                                   ; $B1D3: 60
Loc_B1D4:  ; (dispatch callback target)
  LDA $007E                             ; $B1D4: AD 7E 00
  AND #$04                              ; $B1D7: 29 04
  BNE $B1ED                             ; $B1D9: D0 12
  LDA #$F5                              ; $B1DB: A9 F5
  STA $0000                             ; $B1DD: 8D 00 00
  LDA #$08                              ; $B1E0: A9 08
  JSR $CDFD                             ; $B1E2: 20 FD CD
  INC $04A9                             ; $B1E5: EE A9 04
  LDA #$01                              ; $B1E8: A9 01
  STA $04AA                             ; $B1EA: 8D AA 04
Loc_B1ED:
  RTS                                   ; $B1ED: 60
Loc_B1EE:  ; (dispatch callback target)
  LDY #$31                              ; $B1EE: A0 31
  JSR $F25F                             ; $B1F0: 20 5F F2
  LDX #$00                              ; $B1F3: A2 00
  LDA #$44                              ; $B1F5: A9 44
  STA $0003                             ; $B1F7: 8D 03 00
  LDA $04AD                             ; $B1FA: AD AD 04
  JSR $CFA3                             ; $B1FD: 20 A3 CF
  LDA #$52                              ; $B200: A9 52
  STA $0003                             ; $B202: 8D 03 00
  LDA $04AE                             ; $B205: AD AE 04
  JSR $CFA3                             ; $B208: 20 A3 CF
  LDA #$FF                              ; $B20B: A9 FF
  STA $0380,X                           ; $B20D: 9D 80 03
  INC $04A9                             ; $B210: EE A9 04
  LDA $007E                             ; $B213: AD 7E 00
  ORA #$04                              ; $B216: 09 04
  STA $007E                             ; $B218: 8D 7E 00
  RTS                                   ; $B21B: 60
Loc_B21C:  ; (dispatch callback target)
  JSR $D060                             ; $B21C: 20 60 D0
  LDA #$FF                              ; $B21F: A9 FF
  STA $0380,X                           ; $B221: 9D 80 03
  INC $04A9                             ; $B224: EE A9 04
  LDA $007E                             ; $B227: AD 7E 00
  ORA #$04                              ; $B22A: 09 04
  STA $007E                             ; $B22C: 8D 7E 00
  RTS                                   ; $B22F: 60
Loc_B230:  ; (dispatch callback target)
  LDX #$00                              ; $B230: A2 00
Loc_B232:
  LDA $04AD,X                           ; $B232: BD AD 04
  JSR $F2D7                             ; $B235: 20 D7 F2
  LDY #$0A                              ; $B238: A0 0A
  LDA ($00),Y                           ; $B23A: B1 00
  STA $0010                             ; $B23C: 8D 10 00
  LSR                                   ; $B23F: 4A
  LSR                                   ; $B240: 4A
  LSR                                   ; $B241: 4A
  LSR                                   ; $B242: 4A
  LSR                                   ; $B243: 4A
  CLC                                   ; $B244: 18
  ADC #$18                              ; $B245: 69 18
  STA $0011                             ; $B247: 8D 11 00
  LDA $0010                             ; $B24A: AD 10 00
  AND #$1F                              ; $B24D: 29 1F
  STA $0010                             ; $B24F: 8D 10 00
  TAY                                   ; $B252: A8
  LDA $B2C0,Y                           ; $B253: B9 C0 B2
  STA $0010                             ; $B256: 8D 10 00
  LDY $0011                             ; $B259: AC 11 00
  LDA $B2C0,Y                           ; $B25C: B9 C0 B2
  CLC                                   ; $B25F: 18
  ADC $0010                             ; $B260: 6D 10 00
  STA $0010                             ; $B263: 8D 10 00
  LDY #$00                              ; $B266: A0 00
  LDA ($00),Y                           ; $B268: B1 00
  STA $0002                             ; $B26A: 8D 02 00
  LDY #$01                              ; $B26D: A0 01
  LDA ($00),Y                           ; $B26F: B1 00
  CLC                                   ; $B271: 18
  ADC $0002                             ; $B272: 6D 02 00
  STA $0001                             ; $B275: 8D 01 00
  LDA #$00                              ; $B278: A9 00
  STA $0002                             ; $B27A: 8D 02 00
  STA $0004                             ; $B27D: 8D 04 00
  LDA #$0A                              ; $B280: A9 0A
  STA $0003                             ; $B282: 8D 03 00
  JSR $EA7C                             ; $B285: 20 7C EA
  LDA $0001                             ; $B288: AD 01 00
  CLC                                   ; $B28B: 18
  ADC #$14                              ; $B28C: 69 14
  SEC                                   ; $B28E: 38
  SBC $0010                             ; $B28F: ED 10 00
  STA $04B3,X                           ; $B292: 9D B3 04
Loc_B295:
  JSR $E87A                             ; $B295: 20 7A E8
  AND #$0F                              ; $B298: 29 0F
  CMP #$0B                              ; $B29A: C9 0B
  BCS $B295                             ; $B29C: B0 F7
  ADC $04B3,X                           ; $B29E: 7D B3 04
  STA $04BD,X                           ; $B2A1: 9D BD 04
  INX                                   ; $B2A4: E8
  CPX #$02                              ; $B2A5: E0 02
  BNE $B232                             ; $B2A7: D0 89
  LDX #$00                              ; $B2A9: A2 00
  LDA $04BD                             ; $B2AB: AD BD 04
  CMP $04BE                             ; $B2AE: CD BE 04
  BCS $B2B4                             ; $B2B1: B0 01
  INX                                   ; $B2B3: E8
Loc_B2B4:
  STX $04AA                             ; $B2B4: 8E AA 04
  LDA #$00                              ; $B2B7: A9 00
  STA $04C0                             ; $B2B9: 8D C0 04
  INC $04A9                             ; $B2BC: EE A9 04
  RTS                                   ; $B2BF: 60
; --- Data Region ---
  .byte $04,$03,$05,$08,$09,$06,$07,$04,$04,$06,$07,$08,$07,$06,$08,$0A; $B2C0: 04 03 05 08 09 06 07 04 04 06 07 08 07 06 08 0A
  .byte $04,$05,$06,$08,$07,$08,$06,$0A,$01,$02,$04,$06,$05,$0A,$03,$07; $B2D0: 04 05 06 08 07 08 06 0A 01 02 04 06 05 0A 03 07
Loc_B2E0:  ; (dispatch callback target)
; --- Code Region ---
  LDY $04AF                             ; $B2E0: AC AF 04
  LDA $B34C,Y                           ; $B2E3: B9 4C B3
  STA $0000                             ; $B2E6: 8D 00 00
  LDY $04B0                             ; $B2E9: AC B0 04
  LDA $B34C,Y                           ; $B2EC: B9 4C B3
  STA $0001                             ; $B2EF: 8D 01 00
  LDA $0000                             ; $B2F2: AD 00 00
  ASL                                   ; $B2F5: 0A
  CLC                                   ; $B2F6: 18
  ADC $0000                             ; $B2F7: 6D 00 00
  CLC                                   ; $B2FA: 18
  ADC $0001                             ; $B2FB: 6D 01 00
  TAY                                   ; $B2FE: A8
  LDA $B343,Y                           ; $B2FF: B9 43 B3
  STA $04C5                             ; $B302: 8D C5 04
  LDA $0001                             ; $B305: AD 01 00
  ASL                                   ; $B308: 0A
  CLC                                   ; $B309: 18
  ADC $0001                             ; $B30A: 6D 01 00
  CLC                                   ; $B30D: 18
  ADC $0000                             ; $B30E: 6D 00 00
  TAY                                   ; $B311: A8
  LDA $B343,Y                           ; $B312: B9 43 B3
  STA $04C6                             ; $B315: 8D C6 04
  LDA #$02                              ; $B318: A9 02
  STA $04C3                             ; $B31A: 8D C3 04
  STA $04C4                             ; $B31D: 8D C4 04
  LDY $04AA                             ; $B320: AC AA 04
  LDA $04AD,Y                           ; $B323: B9 AD 04
  STA $042C                             ; $B326: 8D 2C 04
  LDA #$3A                              ; $B329: A9 3A
  STA $04BD                             ; $B32B: 8D BD 04
  LDA #$3B                              ; $B32E: A9 3B
  STA $04BE                             ; $B330: 8D BE 04
  LDA #$00                              ; $B333: A9 00
  STA $04BF                             ; $B335: 8D BF 04
  LDA #$09                              ; $B338: A9 09
  STA $04A8                             ; $B33A: 8D A8 04
  LDA #$00                              ; $B33D: A9 00
  STA $04A9                             ; $B33F: 8D A9 04
  RTS                                   ; $B342: 60
; --- Data Region ---
  .byte $46,$4B,$3C,$37,$3C,$46,$50,$32,$3C,$01,$02,$00; $B343: 46 4B 3C 37 3C 46 50 32 3C 01 02 00
Loc_B34F:  ; (dispatch callback target)
; --- Code Region ---
  LDA $04A9                             ; $B34F: AD A9 04
  JSR $EADE                             ; $B352: 20 DE EA
; --- Data Region ---
  .byte $61,$B3,$F0,$B3,$07,$B4,$7E,$B4,$52,$B5,$69,$B5,$AD,$C0,$04,$D0; $B355: 61 B3 F0 B3 07 B4 7E B4 52 B5 69 B5 AD C0 04 D0
  .byte $08,$AD,$AA,$04,$49,$01,$8D,$AA,$04; $B365: 08 AD AA 04 49 01 8D AA 04
Loc_B36E:
; --- Code Region ---
  INC $04C0                             ; $B36E: EE C0 04
  LDA $04C0                             ; $B371: AD C0 04
  CMP #$03                              ; $B374: C9 03
  BCC $B37B                             ; $B376: 90 03
  JSR $B3C6                             ; $B378: 20 C6 B3
Loc_B37B:
  LDA $04AA                             ; $B37B: AD AA 04
  EOR #$01                              ; $B37E: 49 01
  STA $04AA                             ; $B380: 8D AA 04
  TAY                                   ; $B383: A8
  LDA $04B5,Y                           ; $B384: B9 B5 04
  AND #$7F                              ; $B387: 29 7F
  BEQ $B391                             ; $B389: F0 06
  SEC                                   ; $B38B: 38
  SBC #$01                              ; $B38C: E9 01
  STA $04B5,Y                           ; $B38E: 99 B5 04
Loc_B391:
  LDY $04AA                             ; $B391: AC AA 04
  LDA $04AB,Y                           ; $B394: B9 AB 04
  BPL $B39F                             ; $B397: 10 06
  LDA #$02                              ; $B399: A9 02
  STA $04A8                             ; $B39B: 8D A8 04
  RTS                                   ; $B39E: 60
Loc_B39F:
  LDY $04AA                             ; $B39F: AC AA 04
  LDA $04AD,Y                           ; $B3A2: B9 AD 04
  STA $0000                             ; $B3A5: 8D 00 00
  LDY #$3D                              ; $B3A8: A0 3D
  JSR $EE07                             ; $B3AA: 20 07 EE
; --- Data Region ---
  .byte $30,$A0,$AC,$AA,$04,$B9,$B5,$04,$29,$7F,$F0,$02,$A9,$02; $B3AD: 30 A0 AC AA 04 B9 B5 04 29 7F F0 02 A9 02
Loc_B3BB:
; --- Code Region ---
  STA $00A4                             ; $B3BB: 8D A4 00
  INC $04A9                             ; $B3BE: EE A9 04
  LDA #$2B                              ; $B3C1: A9 2B
  JMP $F26D                             ; $B3C3: 4C 6D F2
Loc_B3C6:
  LDX #$00                              ; $B3C6: A2 00
Loc_B3C8:
  JSR $E87A                             ; $B3C8: 20 7A E8
  AND #$0F                              ; $B3CB: 29 0F
  CMP #$0B                              ; $B3CD: C9 0B
  BCS $B3C8                             ; $B3CF: B0 F7
  ADC $04B3,X                           ; $B3D1: 7D B3 04
  STA $04BD,X                           ; $B3D4: 9D BD 04
  INX                                   ; $B3D7: E8
  CPX #$02                              ; $B3D8: E0 02
  BCC $B3C8                             ; $B3DA: 90 EC
  LDX #$00                              ; $B3DC: A2 00
  LDA $04BD                             ; $B3DE: AD BD 04
  CMP $04BE                             ; $B3E1: CD BE 04
  BCC $B3E7                             ; $B3E4: 90 01
  INX                                   ; $B3E6: E8
Loc_B3E7:
  STX $04AA                             ; $B3E7: 8E AA 04
  LDA #$01                              ; $B3EA: A9 01
  STA $04C0                             ; $B3EC: 8D C0 04
  RTS                                   ; $B3EF: 60
Loc_B3F0:  ; (dispatch callback target)
  JSR $D166                             ; $B3F0: 20 66 D1
  JSR $D299                             ; $B3F3: 20 99 D2
  BCC $B406                             ; $B3F6: 90 0E
  LDA #$00                              ; $B3F8: A9 00
  STA $0424                             ; $B3FA: 8D 24 04
  STA $0425                             ; $B3FD: 8D 25 04
  INC $04A9                             ; $B400: EE A9 04
  JMP $D17C                             ; $B403: 4C 7C D1
Loc_B406:
  RTS                                   ; $B406: 60
Loc_B407:  ; (dispatch callback target)
  JSR $D166                             ; $B407: 20 66 D1
  LDA #$61                              ; $B40A: A9 61
  STA $0010                             ; $B40C: 8D 10 00
  LDA #$B4                              ; $B40F: A9 B4
  STA $0011                             ; $B411: 8D 11 00
  LDA #$00                              ; $B414: A9 00
  STA $0012                             ; $B416: 8D 12 00
  JSR $ED1E                             ; $B419: 20 1E ED
  LDA #$6B                              ; $B41C: A9 6B
  STA $0010                             ; $B41E: 8D 10 00
  LDA #$B4                              ; $B421: A9 B4
  STA $0011                             ; $B423: 8D 11 00
  LDA #$79                              ; $B426: A9 79
  STA $0000                             ; $B428: 8D 00 00
  LDA #$B4                              ; $B42B: A9 B4
  STA $0001                             ; $B42D: 8D 01 00
  LDA $0012                             ; $B430: AD 12 00
  JSR $EDF5                             ; $B433: 20 F5 ED
  LDA $0081                             ; $B436: AD 81 00
  LSR                                   ; $B439: 4A
  BCC $B460                             ; $B43A: 90 24
  INC $04A9                             ; $B43C: EE A9 04
  LDA $0012                             ; $B43F: AD 12 00
  STA $04BF                             ; $B442: 8D BF 04
  CMP #$04                              ; $B445: C9 04
  BNE $B460                             ; $B447: D0 17
  LDY $04AA                             ; $B449: AC AA 04
  LDA $04B5,Y                           ; $B44C: B9 B5 04
  AND #$7F                              ; $B44F: 29 7F
  BNE $B45B                             ; $B451: D0 08
  INC $04A9                             ; $B453: EE A9 04
  LDA #$2C                              ; $B456: A9 2C
  JMP $F26D                             ; $B458: 4C 6D F2
Loc_B45B:
  LDA #$02                              ; $B45B: A9 02
  STA $04A9                             ; $B45D: 8D A9 04
Loc_B460:
  RTS                                   ; $B460: 60
; --- Data Region ---
  .byte $00,$01,$02,$03,$04,$05,$06,$FF,$FF,$FF,$A6,$88,$A6,$C0,$B6,$88; $B461: 00 01 02 03 04 05 06 FF FF FF A6 88 A6 C0 B6 88
  .byte $B6,$C0,$C6,$88,$C6,$C0,$D6,$88,$00,$07,$00,$00,$80; $B471: B6 C0 C6 88 C6 C0 D6 88 00 07 00 00 80
Loc_B47E:  ; (dispatch callback target)
; --- Code Region ---
  LDA $04BF                             ; $B47E: AD BF 04
  BNE $B4A5                             ; $B481: D0 22
  LDA #$03                              ; $B483: A9 03
  STA $04BD                             ; $B485: 8D BD 04
  LDA #$00                              ; $B488: A9 00
  STA $04BE                             ; $B48A: 8D BE 04
  LDA #$10                              ; $B48D: A9 10
  STA $04A8                             ; $B48F: 8D A8 04
  LDA #$00                              ; $B492: A9 00
  STA $04A9                             ; $B494: 8D A9 04
  LDY $04AA                             ; $B497: AC AA 04
  LDA $04AD,Y                           ; $B49A: B9 AD 04
  STA $042C                             ; $B49D: 8D 2C 04
  LDA #$23                              ; $B4A0: A9 23
  JMP $F28B                             ; $B4A2: 4C 8B F2
; --- Data Region ---
  .byte $C9,$01,$D0,$0F,$A9,$04,$8D,$A8,$04,$A9,$00,$8D,$A9,$04,$A9,$00; $B4A5: C9 01 D0 0F A9 04 8D A8 04 A9 00 8D A9 04 A9 00
  .byte $4C,$8B,$F2                       ; $B4B5: 4C 8B F2
Loc_B4B8:
; --- Code Region ---
  CMP #$02                              ; $B4B8: C9 02
  BNE $B4DE                             ; $B4BA: D0 22
  LDA #$03                              ; $B4BC: A9 03
  STA $04BD                             ; $B4BE: 8D BD 04
  LDA #$00                              ; $B4C1: A9 00
  STA $04BE                             ; $B4C3: 8D BE 04
  LDA #$11                              ; $B4C6: A9 11
  STA $04A8                             ; $B4C8: 8D A8 04
  LDA #$00                              ; $B4CB: A9 00
  STA $04A9                             ; $B4CD: 8D A9 04
  LDY $04AA                             ; $B4D0: AC AA 04
  LDA $04AD,Y                           ; $B4D3: B9 AD 04
  STA $042C                             ; $B4D6: 8D 2C 04
  LDA #$21                              ; $B4D9: A9 21
  JMP $F28B                             ; $B4DB: 4C 8B F2
Loc_B4DE:
  CMP #$03                              ; $B4DE: C9 03
  BNE $B4FA                             ; $B4E0: D0 18
  JSR $D262                             ; $B4E2: 20 62 D2
  BCC $B4EB                             ; $B4E5: 90 04
  DEC $04A9                             ; $B4E7: CE A9 04
  RTS                                   ; $B4EA: 60
Loc_B4EB:
  LDA #$06                              ; $B4EB: A9 06
  STA $04A8                             ; $B4ED: 8D A8 04
  LDA #$00                              ; $B4F0: A9 00
  STA $04A9                             ; $B4F2: 8D A9 04
  LDA #$00                              ; $B4F5: A9 00
  JMP $F28B                             ; $B4F7: 4C 8B F2
Loc_B4FA:
  CMP #$05                              ; $B4FA: C9 05
  BNE $B512                             ; $B4FC: D0 14
  LDA #$05                              ; $B4FE: A9 05
  STA $04A8                             ; $B500: 8D A8 04
  LDA #$00                              ; $B503: A9 00
  STA $04A9                             ; $B505: 8D A9 04
  LDA $04AA                             ; $B508: AD AA 04
  STA $04BE                             ; $B50B: 8D BE 04
  STA $04BF                             ; $B50E: 8D BF 04
  RTS                                   ; $B511: 60
Loc_B512:
  CMP #$06                              ; $B512: C9 06
  BNE $B538                             ; $B514: D0 22
  LDA #$03                              ; $B516: A9 03
  STA $04BD                             ; $B518: 8D BD 04
  LDA #$00                              ; $B51B: A9 00
  STA $04BE                             ; $B51D: 8D BE 04
  LDA #$12                              ; $B520: A9 12
  STA $04A8                             ; $B522: 8D A8 04
  LDA #$00                              ; $B525: A9 00
  STA $04A9                             ; $B527: 8D A9 04
  LDY $04AA                             ; $B52A: AC AA 04
  LDA $04AD,Y                           ; $B52D: B9 AD 04
  STA $042C                             ; $B530: 8D 2C 04
  LDA #$24                              ; $B533: A9 24
  JMP $F28B                             ; $B535: 4C 8B F2
Loc_B538:
  CMP #$07                              ; $B538: C9 07
  BNE $B547                             ; $B53A: D0 0B
  LDA #$07                              ; $B53C: A9 07
  STA $04A8                             ; $B53E: 8D A8 04
  LDA #$00                              ; $B541: A9 00
  STA $04A9                             ; $B543: 8D A9 04
  RTS                                   ; $B546: 60
Loc_B547:
  LDA #$08                              ; $B547: A9 08
  STA $04A8                             ; $B549: 8D A8 04
  LDA #$00                              ; $B54C: A9 00
  STA $04A9                             ; $B54E: 8D A9 04
  RTS                                   ; $B551: 60
Loc_B552:  ; (dispatch callback target)
  JSR $D166                             ; $B552: 20 66 D1
  JSR $D299                             ; $B555: 20 99 D2
  BCC $B568                             ; $B558: 90 0E
  INC $04A9                             ; $B55A: EE A9 04
  LDA #$00                              ; $B55D: A9 00
  STA $0424                             ; $B55F: 8D 24 04
  STA $0425                             ; $B562: 8D 25 04
  JMP $D17C                             ; $B565: 4C 7C D1
Loc_B568:
  RTS                                   ; $B568: 60
Loc_B569:  ; (dispatch callback target)
  JSR $D166                             ; $B569: 20 66 D1
  LDA #$BB                              ; $B56C: A9 BB
  STA $0010                             ; $B56E: 8D 10 00
  LDA #$B5                              ; $B571: A9 B5
  STA $0011                             ; $B573: 8D 11 00
  LDA #$00                              ; $B576: A9 00
  STA $0012                             ; $B578: 8D 12 00
  JSR $ED1E                             ; $B57B: 20 1E ED
  LDA #$BF                              ; $B57E: A9 BF
  STA $0010                             ; $B580: 8D 10 00
  LDA #$B5                              ; $B583: A9 B5
  STA $0011                             ; $B585: 8D 11 00
  LDA #$C3                              ; $B588: A9 C3
  STA $0000                             ; $B58A: 8D 00 00
  LDA #$B5                              ; $B58D: A9 B5
  STA $0001                             ; $B58F: 8D 01 00
  LDA $0012                             ; $B592: AD 12 00
  JSR $EDF5                             ; $B595: 20 F5 ED
  LDA $0081                             ; $B598: AD 81 00
  LSR                                   ; $B59B: 4A
  BCC $B5AD                             ; $B59C: 90 0F
  LDA $0012                             ; $B59E: AD 12 00
  CLC                                   ; $B5A1: 18
  ADC #$07                              ; $B5A2: 69 07
  STA $04BF                             ; $B5A4: 8D BF 04
  LDA #$03                              ; $B5A7: A9 03
  STA $04A9                             ; $B5A9: 8D A9 04
  RTS                                   ; $B5AC: 60
Loc_B5AD:
  LSR                                   ; $B5AD: 4A
  BCC $B5BA                             ; $B5AE: 90 0A
  LDA #$01                              ; $B5B0: A9 01
  STA $04A9                             ; $B5B2: 8D A9 04
  LDA #$2B                              ; $B5B5: A9 2B
  JMP $F26D                             ; $B5B7: 4C 6D F2
Loc_B5BA:
  RTS                                   ; $B5BA: 60
; --- Data Region ---
  .byte $00,$01,$FF,$FF,$B6,$88,$B6,$C0,$00,$07,$00,$00,$80; $B5BB: 00 01 FF FF B6 88 B6 C0 00 07 00 00 80
Loc_B5C8:  ; (dispatch callback target)
; --- Code Region ---
  LDA $04A9                             ; $B5C8: AD A9 04
  JSR $EADE                             ; $B5CB: 20 DE EA
; --- Data Region ---
  .byte $D8,$B5,$26,$B6,$59,$B6,$89,$B6,$19,$B7,$AD,$AA,$04,$49,$01,$A8; $B5CE: D8 B5 26 B6 59 B6 89 B6 19 B7 AD AA 04 49 01 A8
  .byte $B9,$B1,$04,$8D,$10,$00,$AC,$AA,$04,$B9,$AD,$04,$20,$87,$F3,$A0; $B5DE: B9 B1 04 8D 10 00 AC AA 04 B9 AD 04 20 87 F3 A0
  .byte $00,$B1,$00,$4A,$8D,$11,$00,$AC,$AA,$04,$B9,$B1,$04,$CD,$11,$00; $B5EE: 00 B1 00 4A 8D 11 00 AC AA 04 B9 B1 04 CD 11 00
  .byte $B0,$1F,$CD,$10,$00,$B0,$1D,$20,$62,$D2,$B0,$18,$20,$B3,$B7,$CD; $B5FE: B0 1F CD 10 00 B0 1D 20 62 D2 B0 18 20 B3 B7 CD
  .byte $10,$00,$B0,$10,$AD,$10,$00,$F0,$0B,$A9,$03,$8D,$BF,$04,$4C,$A8; $B60E: 10 00 B0 10 AD 10 00 F0 0B A9 03 8D BF 04 4C A8
  .byte $B7                               ; $B61E: B7
Loc_B61F:
; --- Code Region ---
  INC $04A9                             ; $B61F: EE A9 04
Loc_B622:
  INC $04A9                             ; $B622: EE A9 04
  RTS                                   ; $B625: 60
Loc_B626:  ; (dispatch callback target)
  LDA $04AA                             ; $B626: AD AA 04
  EOR #$01                              ; $B629: 49 01
  TAY                                   ; $B62B: A8
  LDA $04B1,Y                           ; $B62C: B9 B1 04
  STA $0010                             ; $B62F: 8D 10 00
  LDY $04AA                             ; $B632: AC AA 04
  LDA $04B1,Y                           ; $B635: B9 B1 04
  CLC                                   ; $B638: 18
  ADC #$1E                              ; $B639: 69 1E
  CMP $0010                             ; $B63B: CD 10 00
  BCS $B655                             ; $B63E: B0 15
  JSR $B7DD                             ; $B640: 20 DD B7
  CMP $0010                             ; $B643: CD 10 00
  BCS $B655                             ; $B646: B0 0D
  LDA $0010                             ; $B648: AD 10 00
  BEQ $B655                             ; $B64B: F0 08
  LDA #$06                              ; $B64D: A9 06
  STA $04BF                             ; $B64F: 8D BF 04
  JMP $B7A8                             ; $B652: 4C A8 B7
Loc_B655:
  INC $04A9                             ; $B655: EE A9 04
  RTS                                   ; $B658: 60
Loc_B659:  ; (dispatch callback target)
  LDY $04AA                             ; $B659: AC AA 04
  LDA $04B1,Y                           ; $B65C: B9 B1 04
  CMP #$1E                              ; $B65F: C9 1E
  BCS $B685                             ; $B661: B0 22
  LDY $04AA                             ; $B663: AC AA 04
  EOR #$01                              ; $B666: 49 01
  TAY                                   ; $B668: A8
  LDA $04B1,Y                           ; $B669: B9 B1 04
  CMP #$32                              ; $B66C: C9 32
  BCC $B685                             ; $B66E: 90 15
  JSR $B816                             ; $B670: 20 16 B8
  CMP $0010                             ; $B673: CD 10 00
  BCS $B685                             ; $B676: B0 0D
  LDA $0010                             ; $B678: AD 10 00
  BEQ $B685                             ; $B67B: F0 08
  LDA #$02                              ; $B67D: A9 02
  STA $04BF                             ; $B67F: 8D BF 04
  JMP $B7A8                             ; $B682: 4C A8 B7
Loc_B685:
  INC $04A9                             ; $B685: EE A9 04
  RTS                                   ; $B688: 60
Loc_B689:  ; (dispatch callback target)
  LDY $04AA                             ; $B689: AC AA 04
  LDA $04B5,Y                           ; $B68C: B9 B5 04
  AND #$7F                              ; $B68F: 29 7F
  BEQ $B696                             ; $B691: F0 03
  JMP $B715                             ; $B693: 4C 15 B7
Loc_B696:
  LDA $04AD,Y                           ; $B696: B9 AD 04
  JSR $F2D7                             ; $B699: 20 D7 F2
  LDY #$02                              ; $B69C: A0 02
  LDA ($00),Y                           ; $B69E: B1 00
  STA $0010                             ; $B6A0: 8D 10 00
  LDA $04AA                             ; $B6A3: AD AA 04
  EOR #$01                              ; $B6A6: 49 01
  TAY                                   ; $B6A8: A8
  LDA $04AD,Y                           ; $B6A9: B9 AD 04
  JSR $F2D7                             ; $B6AC: 20 D7 F2
  LDY #$02                              ; $B6AF: A0 02
  LDA ($00),Y                           ; $B6B1: B1 00
  CMP $0010                             ; $B6B3: CD 10 00
  BCS $B6CD                             ; $B6B6: B0 15
  JSR $B851                             ; $B6B8: 20 51 B8
  CMP $0010                             ; $B6BB: CD 10 00
  BCS $B6CD                             ; $B6BE: B0 0D
  LDA $0010                             ; $B6C0: AD 10 00
  BEQ $B6CD                             ; $B6C3: F0 08
  LDA #$07                              ; $B6C5: A9 07
  STA $04BF                             ; $B6C7: 8D BF 04
  JMP $B7A8                             ; $B6CA: 4C A8 B7
Loc_B6CD:
  LDY $04AA                             ; $B6CD: AC AA 04
  LDA $04AD,Y                           ; $B6D0: B9 AD 04
  JSR $F2D7                             ; $B6D3: 20 D7 F2
  LDY #$01                              ; $B6D6: A0 01
  LDA ($00),Y                           ; $B6D8: B1 00
  STA $0010                             ; $B6DA: 8D 10 00
  LDA $04AA                             ; $B6DD: AD AA 04
  EOR #$01                              ; $B6E0: 49 01
  TAY                                   ; $B6E2: A8
  LDA $04AD,Y                           ; $B6E3: B9 AD 04
  JSR $F2D7                             ; $B6E6: 20 D7 F2
  LDY #$01                              ; $B6E9: A0 01
  LDA ($00),Y                           ; $B6EB: B1 00
  CMP $0010                             ; $B6ED: CD 10 00
  BCC $B715                             ; $B6F0: 90 23
  JSR $B89B                             ; $B6F2: 20 9B B8
  CMP $0010                             ; $B6F5: CD 10 00
  BCS $B715                             ; $B6F8: B0 1B
  LDY $04AA                             ; $B6FA: AC AA 04
  LDA $04B5,Y                           ; $B6FD: B9 B5 04
  BMI $B715                             ; $B700: 30 13
  TYA                                   ; $B702: 98
  EOR #$01                              ; $B703: 49 01
  TAY                                   ; $B705: A8
  LDA $04B5,Y                           ; $B706: B9 B5 04
  AND #$7F                              ; $B709: 29 7F
  BNE $B715                             ; $B70B: D0 08
  LDA #$08                              ; $B70D: A9 08
  STA $04BF                             ; $B70F: 8D BF 04
  JMP $B7A8                             ; $B712: 4C A8 B7
Loc_B715:
  INC $04A9                             ; $B715: EE A9 04
  RTS                                   ; $B718: 60
Loc_B719:  ; (dispatch callback target)
  LDX #$00                              ; $B719: A2 00
  LDA $04AA                             ; $B71B: AD AA 04
  EOR #$01                              ; $B71E: 49 01
  TAY                                   ; $B720: A8
  LDA $04B1,Y                           ; $B721: B9 B1 04
  CMP #$1F                              ; $B724: C9 1F
  BCC $B730                             ; $B726: 90 08
  LDX #$18                              ; $B728: A2 18
  CMP #$3D                              ; $B72A: C9 3D
  BCC $B730                             ; $B72C: 90 02
  LDX #$30                              ; $B72E: A2 30
Loc_B730:
  LDY $04AA                             ; $B730: AC AA 04
  LDA $04B1,Y                           ; $B733: B9 B1 04
  CMP #$1F                              ; $B736: C9 1F
  BCC $B74B                             ; $B738: 90 11
  TXA                                   ; $B73A: 8A
  CLC                                   ; $B73B: 18
  ADC #$08                              ; $B73C: 69 08
  TAX                                   ; $B73E: AA
  LDA $04B1,Y                           ; $B73F: B9 B1 04
  CMP #$3D                              ; $B742: C9 3D
  BCC $B74B                             ; $B744: 90 05
  TXA                                   ; $B746: 8A
  CLC                                   ; $B747: 18
  ADC #$08                              ; $B748: 69 08
  TAX                                   ; $B74A: AA
Loc_B74B:
  JSR $E856                             ; $B74B: 20 56 E8
  STA $0000                             ; $B74E: 8D 00 00
  TXA                                   ; $B751: 8A
  CLC                                   ; $B752: 18
  ADC $0000                             ; $B753: 6D 00 00
  TAX                                   ; $B756: AA
  LDA $B760,X                           ; $B757: BD 60 B7
  STA $04BF                             ; $B75A: 8D BF 04
  JMP $B7A8                             ; $B75D: 4C A8 B7
; --- Data Region ---
  .byte $00,$00,$00,$02,$02,$02,$02,$02,$00,$00,$00,$00,$00,$02,$02,$02; $B760: 00 00 00 02 02 02 02 02 00 00 00 00 00 02 02 02
  .byte $00,$00,$00,$00,$00,$00,$02,$02,$00,$00,$02,$02,$02,$02,$02,$02; $B770: 00 00 00 00 00 00 02 02 00 00 02 02 02 02 02 02
  .byte $00,$00,$00,$00,$02,$02,$02,$02,$00,$00,$00,$00,$00,$02,$02,$02; $B780: 00 00 00 00 02 02 02 02 00 00 00 00 00 02 02 02
  .byte $00,$02,$02,$02,$02,$02,$02,$02,$00,$00,$00,$02,$02,$02,$02,$02; $B790: 00 02 02 02 02 02 02 02 00 00 00 02 02 02 02 02
  .byte $00,$00,$00,$00,$02,$02,$02,$02   ; $B7A0: 00 00 00 00 02 02 02 02
Loc_B7A8:
; --- Code Region ---
  LDA #$01                              ; $B7A8: A9 01
  STA $04A8                             ; $B7AA: 8D A8 04
  LDA #$03                              ; $B7AD: A9 03
  STA $04A9                             ; $B7AF: 8D A9 04
  RTS                                   ; $B7B2: 60
Loc_B7B3:
  LDY $04AA                             ; $B7B3: AC AA 04
  LDA $04B1,Y                           ; $B7B6: B9 B1 04
  STA $0010                             ; $B7B9: 8D 10 00
  LDA $04AD,Y                           ; $B7BC: B9 AD 04
  JMP $F2D7                             ; $B7BF: 4C D7 F2
; --- Data Region ---
  .byte $A0,$03,$B1,$00,$18,$6D,$10,$00,$8D,$10,$00,$A9,$8C,$38,$ED,$10; $B7C2: A0 03 B1 00 18 6D 10 00 8D 10 00 A9 8C 38 ED 10
  .byte $00,$10,$02,$A9,$00               ; $B7D2: 00 10 02 A9 00
Loc_B7D7:
; --- Code Region ---
  STA $0010                             ; $B7D7: 8D 10 00
  JMP $E843                             ; $B7DA: 4C 43 E8
Loc_B7DD:
  LDY $04AA                             ; $B7DD: AC AA 04
  LDA $04AD,Y                           ; $B7E0: B9 AD 04
  JSR $F2D7                             ; $B7E3: 20 D7 F2
  LDY #$01                              ; $B7E6: A0 01
  LDA ($00),Y                           ; $B7E8: B1 00
  STA $0010                             ; $B7EA: 8D 10 00
  LDY #$02                              ; $B7ED: A0 02
  LDA ($00),Y                           ; $B7EF: B1 00
  CMP $0010                             ; $B7F1: CD 10 00
  BCC $B7F9                             ; $B7F4: 90 03
  STA $0010                             ; $B7F6: 8D 10 00
Loc_B7F9:
  LDY $04AA                             ; $B7F9: AC AA 04
  LDA $04B1,Y                           ; $B7FC: B9 B1 04
  CLC                                   ; $B7FF: 18
  ADC $0010                             ; $B800: 6D 10 00
  STA $0010                             ; $B803: 8D 10 00
  LDA #$7C                              ; $B806: A9 7C
  SEC                                   ; $B808: 38
  SBC $0010                             ; $B809: ED 10 00
  BPL $B810                             ; $B80C: 10 02
  LDA #$00                              ; $B80E: A9 00
Loc_B810:
  STA $0010                             ; $B810: 8D 10 00
  JMP $E843                             ; $B813: 4C 43 E8
Loc_B816:
  LDA $04AA                             ; $B816: AD AA 04
  EOR #$01                              ; $B819: 49 01
  TAY                                   ; $B81B: A8
  LDA $04AD,Y                           ; $B81C: B9 AD 04
  JSR $F2D7                             ; $B81F: 20 D7 F2
  LDY #$01                              ; $B822: A0 01
  LDA ($00),Y                           ; $B824: B1 00
  STA $0010                             ; $B826: 8D 10 00
  LDY $04AA                             ; $B829: AC AA 04
  LDA $04AD,Y                           ; $B82C: B9 AD 04
  JSR $F2D7                             ; $B82F: 20 D7 F2
  LDY #$01                              ; $B832: A0 01
  LDA ($00),Y                           ; $B834: B1 00
  SEC                                   ; $B836: 38
  SBC $0010                             ; $B837: ED 10 00
  BPL $B83E                             ; $B83A: 10 02
  LDA #$00                              ; $B83C: A9 00
Loc_B83E:
  STA $0010                             ; $B83E: 8D 10 00
  LDA #$32                              ; $B841: A9 32
  SEC                                   ; $B843: 38
  SBC $0010                             ; $B844: ED 10 00
  BPL $B84B                             ; $B847: 10 02
  LDA #$00                              ; $B849: A9 00
Loc_B84B:
  STA $0010                             ; $B84B: 8D 10 00
  JMP $E843                             ; $B84E: 4C 43 E8
Loc_B851:
  LDY $04AA                             ; $B851: AC AA 04
  LDA $04AD,Y                           ; $B854: B9 AD 04
  JSR $F2D7                             ; $B857: 20 D7 F2
  LDY #$02                              ; $B85A: A0 02
  LDA ($00),Y                           ; $B85C: B1 00
  STA $0010                             ; $B85E: 8D 10 00
  LDY #$04                              ; $B861: A0 04
  LDA ($00),Y                           ; $B863: B1 00
  CLC                                   ; $B865: 18
  ADC $0010                             ; $B866: 6D 10 00
  STA $0010                             ; $B869: 8D 10 00
  LDY #$01                              ; $B86C: A0 01
  LDA ($00),Y                           ; $B86E: B1 00
  STA $0011                             ; $B870: 8D 11 00
  LDA $04AA                             ; $B873: AD AA 04
  EOR #$01                              ; $B876: 49 01
  TAY                                   ; $B878: A8
  LDA $04AD,Y                           ; $B879: B9 AD 04
  JSR $F2D7                             ; $B87C: 20 D7 F2
  LDY #$03                              ; $B87F: A0 03
  LDA ($00),Y                           ; $B881: B1 00
  CLC                                   ; $B883: 18
  ADC $0011                             ; $B884: 6D 11 00
  STA $0011                             ; $B887: 8D 11 00
  LDA $0010                             ; $B88A: AD 10 00
  SEC                                   ; $B88D: 38
  SBC $0011                             ; $B88E: ED 11 00
  BPL $B895                             ; $B891: 10 02
  LDA #$00                              ; $B893: A9 00
Loc_B895:
  STA $0010                             ; $B895: 8D 10 00
  JMP $E843                             ; $B898: 4C 43 E8
Loc_B89B:
  LDA $04AA                             ; $B89B: AD AA 04
  EOR #$01                              ; $B89E: 49 01
  TAY                                   ; $B8A0: A8
  LDA $04AD,Y                           ; $B8A1: B9 AD 04
  JSR $F2D7                             ; $B8A4: 20 D7 F2
  LDY #$02                              ; $B8A7: A0 02
  LDA ($00),Y                           ; $B8A9: B1 00
  STA $0010                             ; $B8AB: 8D 10 00
  LDY #$01                              ; $B8AE: A0 01
  LDA ($00),Y                           ; $B8B0: B1 00
  SEC                                   ; $B8B2: 38
  SBC $0010                             ; $B8B3: ED 10 00
  BCS $B8BA                             ; $B8B6: B0 02
  LDA #$00                              ; $B8B8: A9 00
Loc_B8BA:
  CLC                                   ; $B8BA: 18
  ADC #$0A                              ; $B8BB: 69 0A
  BPL $B8C1                             ; $B8BD: 10 02
  LDA #$00                              ; $B8BF: A9 00
Loc_B8C1:
  STA $0010                             ; $B8C1: 8D 10 00
  JMP $E843                             ; $B8C4: 4C 43 E8
Loc_B8C7:  ; (dispatch callback target)
  LDA $04A9                             ; $B8C7: AD A9 04
  JSR $EADE                             ; $B8CA: 20 DE EA
; --- Data Region ---
  .byte $D3,$B8,$A5,$B9,$C8,$B9,$EE,$A9,$04,$20,$15,$BA,$AC,$AA,$04,$B9; $B8CD: D3 B8 A5 B9 C8 B9 EE A9 04 20 15 BA AC AA 04 B9
  .byte $B5,$04,$29,$7F,$F0,$26,$AD,$10,$00,$18,$69,$14,$8D,$10,$00,$AD; $B8DD: B5 04 29 7F F0 26 AD 10 00 18 69 14 8D 10 00 AD
  .byte $01,$00,$0A,$18,$6D,$01,$00,$8D,$02,$00; $B8ED: 01 00 0A 18 6D 01 00 8D 02 00
Loc_B8F7:
; --- Code Region ---
  LDA $0002                             ; $B8F7: AD 02 00
  CMP #$0A                              ; $B8FA: C9 0A
  BCC $B909                             ; $B8FC: 90 0B
  SBC #$0A                              ; $B8FE: E9 0A
  STA $0002                             ; $B900: 8D 02 00
  INC $0001                             ; $B903: EE 01 00
  JMP $B8F7                             ; $B906: 4C F7 B8
Loc_B909:
  LDA $04BF                             ; $B909: AD BF 04
  BNE $B92B                             ; $B90C: D0 1D
  LDA $0010                             ; $B90E: AD 10 00
  CMP #$64                              ; $B911: C9 64
  BCC $B918                             ; $B913: 90 03
  JMP $B9A0                             ; $B915: 4C A0 B9
Loc_B918:
  LDA #$03                              ; $B918: A9 03
  STA $0003                             ; $B91A: 8D 03 00
  LDA #$00                              ; $B91D: A9 00
  STA $0002                             ; $B91F: 8D 02 00
  STA $0004                             ; $B922: 8D 04 00
  JSR $EA7C                             ; $B925: 20 7C EA
  JMP $B96D                             ; $B928: 4C 6D B9
Loc_B92B:
  CMP #$06                              ; $B92B: C9 06
  BNE $B962                             ; $B92D: D0 33
  LDA $0010                             ; $B92F: AD 10 00
  CMP #$1E                              ; $B932: C9 1E
  BCS $B940                             ; $B934: B0 0A
  LDA $0001                             ; $B936: AD 01 00
  ASL                                   ; $B939: 0A
  STA $0001                             ; $B93A: 8D 01 00
  JMP $B96D                             ; $B93D: 4C 6D B9
Loc_B940:  ; (dispatch callback target)
  JSR $E87A                             ; $B940: 20 7A E8
  AND #$1F                              ; $B943: 29 1F
  CMP #$15                              ; $B945: C9 15
  BCS $B909                             ; $B947: B0 C0
  ADC #$0A                              ; $B949: 69 0A
  STA $0000                             ; $B94B: 8D 00 00
  LDY $04AA                             ; $B94E: AC AA 04
  LDA $04B1,Y                           ; $B951: B9 B1 04
  SEC                                   ; $B954: 38
  SBC $0000                             ; $B955: ED 00 00
  BPL $B95C                             ; $B958: 10 02
  LDA #$00                              ; $B95A: A9 00
Loc_B95C:
  STA $04B1,Y                           ; $B95C: 99 B1 04
  JMP $B9A0                             ; $B95F: 4C A0 B9
Loc_B962:
  LDY $04AA                             ; $B962: AC AA 04
  LDA $0010                             ; $B965: AD 10 00
  CMP $04C5,Y                           ; $B968: D9 C5 04
  BCS $B9A0                             ; $B96B: B0 33
Loc_B96D:
  LDA $0001                             ; $B96D: AD 01 00
  BEQ $B99B                             ; $B970: F0 29
  BMI $B99B                             ; $B972: 30 27
  LDA $04AA                             ; $B974: AD AA 04
  EOR #$01                              ; $B977: 49 01
  TAY                                   ; $B979: A8
  LDA $04B1,Y                           ; $B97A: B9 B1 04
  SEC                                   ; $B97D: 38
  SBC $0001                             ; $B97E: ED 01 00
  BCS $B985                             ; $B981: B0 02
  LDA #$00                              ; $B983: A9 00
Loc_B985:
  STA $04B1,Y                           ; $B985: 99 B1 04
  LDA $0001                             ; $B988: AD 01 00
  STA $042C                             ; $B98B: 8D 2C 04
  LDA #$00                              ; $B98E: A9 00
  STA $042D                             ; $B990: 8D 2D 04
  STA $042E                             ; $B993: 8D 2E 04
  LDA #$22                              ; $B996: A9 22
  JMP $F28B                             ; $B998: 4C 8B F2
Loc_B99B:
  LDA #$39                              ; $B99B: A9 39
  JMP $F28B                             ; $B99D: 4C 8B F2
Loc_B9A0:
  LDA #$25                              ; $B9A0: A9 25
  JMP $F26D                             ; $B9A2: 4C 6D F2
Loc_B9A5:  ; (dispatch callback target)
  JSR $D299                             ; $B9A5: 20 99 D2
  BCC $B9C7                             ; $B9A8: 90 1D
  JSR $D13D                             ; $B9AA: 20 3D D1
  LDA $0081                             ; $B9AD: AD 81 00
  AND #$03                              ; $B9B0: 29 03
  BEQ $B9C7                             ; $B9B2: F0 13
  JSR $D060                             ; $B9B4: 20 60 D0
  LDA #$FF                              ; $B9B7: A9 FF
  STA $0380,X                           ; $B9B9: 9D 80 03
  INC $04A9                             ; $B9BC: EE A9 04
  LDA $007E                             ; $B9BF: AD 7E 00
  ORA #$04                              ; $B9C2: 09 04
  STA $007E                             ; $B9C4: 8D 7E 00
Loc_B9C7:
  RTS                                   ; $B9C7: 60
Loc_B9C8:  ; (dispatch callback target)
  LDA $007E                             ; $B9C8: AD 7E 00
  AND #$04                              ; $B9CB: 29 04
  BNE $B9EC                             ; $B9CD: D0 1D
  LDY $04AA                             ; $B9CF: AC AA 04
  LDA $04B1,Y                           ; $B9D2: B9 B1 04
  BEQ $B9ED                             ; $B9D5: F0 16
  LDA $04AA                             ; $B9D7: AD AA 04
  EOR #$01                              ; $B9DA: 49 01
  TAY                                   ; $B9DC: A8
  LDA $04B1,Y                           ; $B9DD: B9 B1 04
  BEQ $B9ED                             ; $B9E0: F0 0B
  LDA #$01                              ; $B9E2: A9 01
  STA $04A8                             ; $B9E4: 8D A8 04
  LDA #$00                              ; $B9E7: A9 00
  STA $04A9                             ; $B9E9: 8D A9 04
Loc_B9EC:
  RTS                                   ; $B9EC: 60
Loc_B9ED:
  STY $04AA                             ; $B9ED: 8C AA 04
  LDA $04AD,Y                           ; $B9F0: B9 AD 04
  STA $042C                             ; $B9F3: 8D 2C 04
  CPY #$01                              ; $B9F6: C0 01
  BNE $B9FC                             ; $B9F8: D0 02
  LDY #$02                              ; $B9FA: A0 02
Loc_B9FC:
  LDA #$02                              ; $B9FC: A9 02
  STA $0515,Y                           ; $B9FE: 99 15 05
  TYA                                   ; $BA01: 98
  EOR #$02                              ; $BA02: 49 02
  TAY                                   ; $BA04: A8
  LDA #$00                              ; $BA05: A9 00
  STA $0515,Y                           ; $BA07: 99 15 05
  LDA #$0D                              ; $BA0A: A9 0D
  STA $04A8                             ; $BA0C: 8D A8 04
  LDA #$00                              ; $BA0F: A9 00
  STA $04A9                             ; $BA11: 8D A9 04
  RTS                                   ; $BA14: 60
; --- Data Region ---
  .byte $20,$43,$E8,$8D,$10,$00,$A0,$00,$AE,$AA,$04,$BD,$AD,$04,$CD,$60; $BA15: 20 43 E8 8D 10 00 A0 00 AE AA 04 BD AD 04 CD 60
  .byte $05,$F0,$02,$A0,$01               ; $BA25: 05 F0 02 A0 01
Loc_BA2A:
; --- Code Region ---
  LDA $04C1,Y                           ; $BA2A: B9 C1 04
  STA $0001                             ; $BA2D: 8D 01 00
  LDA $0570,Y                           ; $BA30: B9 70 05
  CLC                                   ; $BA33: 18
  ADC $0001                             ; $BA34: 6D 01 00
  LSR                                   ; $BA37: 4A
  STA $0001                             ; $BA38: 8D 01 00
  TYA                                   ; $BA3B: 98
  EOR #$01                              ; $BA3C: 49 01
  TAY                                   ; $BA3E: A8
Loc_BA3F:
  LDA $056E,Y                           ; $BA3F: B9 6E 05
  STA $0002                             ; $BA42: 8D 02 00
  LDA $0001                             ; $BA45: AD 01 00
  SEC                                   ; $BA48: 38
  SBC $0002                             ; $BA49: ED 02 00
  STA $0001                             ; $BA4C: 8D 01 00
Loc_BA4F:
  JSR $E87A                             ; $BA4F: 20 7A E8
  AND #$0F                              ; $BA52: 29 0F
  CMP #$0B                              ; $BA54: C9 0B
  BCS $BA4F                             ; $BA56: B0 F7
  SEC                                   ; $BA58: 38
  SBC #$05                              ; $BA59: E9 05
  STA $0002                             ; $BA5B: 8D 02 00
  LDA $0001                             ; $BA5E: AD 01 00
  CLC                                   ; $BA61: 18
  ADC $0002                             ; $BA62: 6D 02 00
  BPL $BA69                             ; $BA65: 10 02
  LDA #$00                              ; $BA67: A9 00
Loc_BA69:
  STA $0001                             ; $BA69: 8D 01 00
  RTS                                   ; $BA6C: 60
Loc_BA6D:  ; (dispatch callback target)
  LDA $04A9                             ; $BA6D: AD A9 04
  JSR $EADE                             ; $BA70: 20 DE EA
; --- Data Region ---
  .byte $87,$BA,$A5,$BA,$C0,$BA,$DA,$BA,$03,$BB,$41,$BB,$5B,$BB,$93,$BB; $BA73: 87 BA A5 BA C0 BA DA BA 03 BB 41 BB 5B BB 93 BB
  .byte $C0,$BB,$00,$BC                   ; $BA83: C0 BB 00 BC
Loc_BA87:  ; (dispatch callback target)
; --- Code Region ---
  JSR $D299                             ; $BA87: 20 99 D2
  BCC $BAA4                             ; $BA8A: 90 18
  INC $04A9                             ; $BA8C: EE A9 04
  LDY $04AA                             ; $BA8F: AC AA 04
  LDA $04AD,Y                           ; $BA92: B9 AD 04
Loc_BA95:
  STA $0000                             ; $BA95: 8D 00 00
  LDY #$3D                              ; $BA98: A0 3D
  JSR $EE07                             ; $BA9A: 20 07 EE
; --- Data Region ---
  .byte $30,$A0,$A9,$29,$4C,$6D,$F2       ; $BA9D: 30 A0 A9 29 4C 6D F2
Loc_BAA4:
; --- Code Region ---
  RTS                                   ; $BAA4: 60
Loc_BAA5:  ; (dispatch callback target)
  JSR $D166                             ; $BAA5: 20 66 D1
  JSR $D299                             ; $BAA8: 20 99 D2
  BCC $BABF                             ; $BAAB: 90 12
  JSR $D13D                             ; $BAAD: 20 3D D1
  LDA $0081                             ; $BAB0: AD 81 00
  AND #$03                              ; $BAB3: 29 03
  BEQ $BABF                             ; $BAB5: F0 08
  INC $04A9                             ; $BAB7: EE A9 04
  LDA #$00                              ; $BABA: A9 00
  JMP $F28B                             ; $BABC: 4C 8B F2
Loc_BABF:
  RTS                                   ; $BABF: 60
Loc_BAC0:  ; (dispatch callback target)
  JSR $D299                             ; $BAC0: 20 99 D2
  BCC $BAD9                             ; $BAC3: 90 14
  LDA #$04                              ; $BAC5: A9 04
  STA $04BD                             ; $BAC7: 8D BD 04
  LDA #$03                              ; $BACA: A9 03
  STA $04BE                             ; $BACC: 8D BE 04
  LDA #$14                              ; $BACF: A9 14
  STA $04A8                             ; $BAD1: 8D A8 04
  LDA #$00                              ; $BAD4: A9 00
  STA $04A9                             ; $BAD6: 8D A9 04
Loc_BAD9:
  RTS                                   ; $BAD9: 60
Loc_BADA:  ; (dispatch callback target)
  JSR $D299                             ; $BADA: 20 99 D2
  BCC $BB02                             ; $BADD: 90 23
  LDA $04AA                             ; $BADF: AD AA 04
  EOR #$01                              ; $BAE2: 49 01
  STA $04AA                             ; $BAE4: 8D AA 04
  TAY                                   ; $BAE7: A8
  LDA $04AD,Y                           ; $BAE8: B9 AD 04
  STA $0000                             ; $BAEB: 8D 00 00
  LDY #$3D                              ; $BAEE: A0 3D
  JSR $EE07                             ; $BAF0: 20 07 EE
; --- Data Region ---
  .byte $30,$A0,$A9,$02,$8D,$A4,$00,$EE,$A9,$04,$A9,$2A,$4C,$6D,$F2; $BAF3: 30 A0 A9 02 8D A4 00 EE A9 04 A9 2A 4C 6D F2
Loc_BB02:
; --- Code Region ---
  RTS                                   ; $BB02: 60
Loc_BB03:  ; (dispatch callback target)
  LDA $04AA                             ; $BB03: AD AA 04
  JSR $D166                             ; $BB06: 20 66 D1
  JSR $D299                             ; $BB09: 20 99 D2
  BCC $BB40                             ; $BB0C: 90 32
  JSR $D13D                             ; $BB0E: 20 3D D1
  LDA $0081                             ; $BB11: AD 81 00
  AND #$03                              ; $BB14: 29 03
  BEQ $BB40                             ; $BB16: F0 28
  LDA $04AA                             ; $BB18: AD AA 04
  EOR #$01                              ; $BB1B: 49 01
  TAY                                   ; $BB1D: A8
  LDA $04B3,Y                           ; $BB1E: B9 B3 04
  ASL                                   ; $BB21: 0A
  CLC                                   ; $BB22: 18
  STA $0011                             ; $BB23: 8D 11 00
  JSR $E843                             ; $BB26: 20 43 E8
  CMP $0011                             ; $BB29: CD 11 00
  BCS $BB38                             ; $BB2C: B0 0A
  LDA #$09                              ; $BB2E: A9 09
  STA $04A9                             ; $BB30: 8D A9 04
  LDA #$3C                              ; $BB33: A9 3C
  JMP $F26D                             ; $BB35: 4C 6D F2
Loc_BB38:
  INC $04A9                             ; $BB38: EE A9 04
  LDA #$00                              ; $BB3B: A9 00
  JMP $F28B                             ; $BB3D: 4C 8B F2
Loc_BB40:
  RTS                                   ; $BB40: 60
Loc_BB41:  ; (dispatch callback target)
  JSR $D299                             ; $BB41: 20 99 D2
  BCC $BB5A                             ; $BB44: 90 14
  LDA #$04                              ; $BB46: A9 04
  STA $04BD                             ; $BB48: 8D BD 04
  LDA #$06                              ; $BB4B: A9 06
  STA $04BE                             ; $BB4D: 8D BE 04
  LDA #$15                              ; $BB50: A9 15
  STA $04A8                             ; $BB52: 8D A8 04
  LDA #$00                              ; $BB55: A9 00
  STA $04A9                             ; $BB57: 8D A9 04
Loc_BB5A:
  RTS                                   ; $BB5A: 60
Loc_BB5B:  ; (dispatch callback target)
  LDA #$0A                              ; $BB5B: A9 0A
  JSR $E862                             ; $BB5D: 20 62 E8
  CLC                                   ; $BB60: 18
  ADC #$05                              ; $BB61: 69 05
  STA $042F                             ; $BB63: 8D 2F 04
  LDA #$00                              ; $BB66: A9 00
  STA $0430                             ; $BB68: 8D 30 04
  STA $0431                             ; $BB6B: 8D 31 04
  LDA $04AA                             ; $BB6E: AD AA 04
  EOR #$01                              ; $BB71: 49 01
  TAY                                   ; $BB73: A8
  LDA $04AD,Y                           ; $BB74: B9 AD 04
  STA $042C                             ; $BB77: 8D 2C 04
  JSR $F2D7                             ; $BB7A: 20 D7 F2
  LDY #$00                              ; $BB7D: A0 00
  LDA ($00),Y                           ; $BB7F: B1 00
  SEC                                   ; $BB81: 38
  SBC $042F                             ; $BB82: ED 2F 04
  BPL $BB89                             ; $BB85: 10 02
  LDA #$00                              ; $BB87: A9 00
Loc_BB89:
  STA ($00),Y                           ; $BB89: 91 00
  INC $04A9                             ; $BB8B: EE A9 04
  LDA #$3D                              ; $BB8E: A9 3D
  JMP $F28B                             ; $BB90: 4C 8B F2
Loc_BB93:  ; (dispatch callback target)
  JSR $D299                             ; $BB93: 20 99 D2
  BCC $BBBF                             ; $BB96: 90 27
  JSR $D13D                             ; $BB98: 20 3D D1
  LDA $0081                             ; $BB9B: AD 81 00
  AND #$03                              ; $BB9E: 29 03
  BEQ $BBBF                             ; $BBA0: F0 1D
  LDA $04AA                             ; $BBA2: AD AA 04
  EOR #$01                              ; $BBA5: 49 01
  TAY                                   ; $BBA7: A8
  LDA $04AD,Y                           ; $BBA8: B9 AD 04
  JSR $F2D7                             ; $BBAB: 20 D7 F2
  LDY #$00                              ; $BBAE: A0 00
  LDA ($00),Y                           ; $BBB0: B1 00
  BEQ $BBB7                             ; $BBB2: F0 03
  JMP $BC16                             ; $BBB4: 4C 16 BC
Loc_BBB7:
  INC $04A9                             ; $BBB7: EE A9 04
  LDA #$26                              ; $BBBA: A9 26
  JMP $F28B                             ; $BBBC: 4C 8B F2
Loc_BBBF:
  RTS                                   ; $BBBF: 60
Loc_BBC0:  ; (dispatch callback target)
  JSR $D299                             ; $BBC0: 20 99 D2
  BCC $BBCF                             ; $BBC3: 90 0A
  JSR $D13D                             ; $BBC5: 20 3D D1
  LDA $0081                             ; $BBC8: AD 81 00
  AND #$03                              ; $BBCB: 29 03
  BNE $BBD0                             ; $BBCD: D0 01
Loc_BBCF:
  RTS                                   ; $BBCF: 60
Loc_BBD0:
  LDA $04AA                             ; $BBD0: AD AA 04
  EOR #$01                              ; $BBD3: 49 01
  TAY                                   ; $BBD5: A8
  LDA $04AD,Y                           ; $BBD6: B9 AD 04
  STA $042C                             ; $BBD9: 8D 2C 04
  CPY #$01                              ; $BBDC: C0 01
  BNE $BBE2                             ; $BBDE: D0 02
  LDY #$02                              ; $BBE0: A0 02
Loc_BBE2:
  LDA #$02                              ; $BBE2: A9 02
  STA $0515,Y                           ; $BBE4: 99 15 05
  TYA                                   ; $BBE7: 98
  EOR #$02                              ; $BBE8: 49 02
  TAY                                   ; $BBEA: A8
  LDA #$00                              ; $BBEB: A9 00
  STA $0515,Y                           ; $BBED: 99 15 05
  LDA #$0E                              ; $BBF0: A9 0E
  STA $04A8                             ; $BBF2: 8D A8 04
  LDA #$00                              ; $BBF5: A9 00
  STA $04A9                             ; $BBF7: 8D A9 04
  LDA #$FF                              ; $BBFA: A9 FF
  STA $04C0                             ; $BBFC: 8D C0 04
  RTS                                   ; $BBFF: 60
Loc_BC00:  ; (dispatch callback target)
  LDA $04AA                             ; $BC00: AD AA 04
  JSR $D166                             ; $BC03: 20 66 D1
  JSR $D299                             ; $BC06: 20 99 D2
  BCC $BC15                             ; $BC09: 90 0A
  JSR $D13D                             ; $BC0B: 20 3D D1
  LDA $0081                             ; $BC0E: AD 81 00
  AND #$03                              ; $BC11: 29 03
  BNE $BC16                             ; $BC13: D0 01
Loc_BC15:
  RTS                                   ; $BC15: 60
Loc_BC16:
  LDA $04AA                             ; $BC16: AD AA 04
  EOR #$01                              ; $BC19: 49 01
  STA $04AA                             ; $BC1B: 8D AA 04
  BEQ $BC22                             ; $BC1E: F0 02
  LDY #$02                              ; $BC20: A0 02
Loc_BC22:
  LDA #$01                              ; $BC22: A9 01
  STA $0515,Y                           ; $BC24: 99 15 05
  TYA                                   ; $BC27: 98
  EOR #$02                              ; $BC28: 49 02
  TAY                                   ; $BC2A: A8
  LDA #$00                              ; $BC2B: A9 00
  STA $0515,Y                           ; $BC2D: 99 15 05
  LDA #$0F                              ; $BC30: A9 0F
  STA $04A8                             ; $BC32: 8D A8 04
  LDA #$00                              ; $BC35: A9 00
  STA $04A9                             ; $BC37: 8D A9 04
  RTS                                   ; $BC3A: 60
Loc_BC3B:  ; (dispatch callback target)
  LDA $04A9                             ; $BC3B: AD A9 04
  JSR $EADE                             ; $BC3E: 20 DE EA
; --- Data Region ---
  .byte $47,$BC,$5C,$BC,$8C,$BC,$EE,$A9,$04,$A9,$00,$8D,$0C,$04,$8D,$0D; $BC41: 47 BC 5C BC 8C BC EE A9 04 A9 00 8D 0C 04 8D 0D
  .byte $04,$AC,$BE,$04,$B9,$AD,$04,$8D,$10,$04,$60; $BC51: 04 AC BE 04 B9 AD 04 8D 10 04 60
Loc_BC5C:  ; (dispatch callback target)
; --- Code Region ---
  LDA $04BE                             ; $BC5C: AD BE 04
  STA $04AA                             ; $BC5F: 8D AA 04
  JSR $D166                             ; $BC62: 20 66 D1
  LDA $04BF                             ; $BC65: AD BF 04
  STA $04AA                             ; $BC68: 8D AA 04
  LDY #$39                              ; $BC6B: A0 39
  JSR $EE07                             ; $BC6D: 20 07 EE
; --- Data Region ---
  .byte $12,$A0,$AD,$0D,$04,$C9,$FF,$D0,$12,$A9,$06,$8D,$BB,$00,$EE,$A9; $BC70: 12 A0 AD 0D 04 C9 FF D0 12 A9 06 8D BB 00 EE A9
  .byte $04,$A9,$00,$8D,$98,$00,$A9,$01,$8D,$97,$00,$60; $BC80: 04 A9 00 8D 98 00 A9 01 8D 97 00 60
Loc_BC8C:  ; (dispatch callback target)
; --- Code Region ---
  LDA $04BE                             ; $BC8C: AD BE 04
  STA $04AA                             ; $BC8F: 8D AA 04
  JSR $D166                             ; $BC92: 20 66 D1
  LDA $04BF                             ; $BC95: AD BF 04
  STA $04AA                             ; $BC98: 8D AA 04
  LDA $040D                             ; $BC9B: AD 0D 04
  BPL $BCBE                             ; $BC9E: 10 1E
  LDA $0081                             ; $BCA0: AD 81 00
  STA $0010                             ; $BCA3: 8D 10 00
  AND #$02                              ; $BCA6: 29 02
  BNE $BCBF                             ; $BCA8: D0 15
  LDA $0010                             ; $BCAA: AD 10 00
  AND #$30                              ; $BCAD: 29 30
  BEQ $BCBE                             ; $BCAF: F0 0D
  LDA $04BE                             ; $BCB1: AD BE 04
  EOR #$01                              ; $BCB4: 49 01
  STA $04BE                             ; $BCB6: 8D BE 04
  LDA #$00                              ; $BCB9: A9 00
  STA $04A9                             ; $BCBB: 8D A9 04
Loc_BCBE:
  RTS                                   ; $BCBE: 60
Loc_BCBF:
  LDA #$01                              ; $BCBF: A9 01
  STA $04A8                             ; $BCC1: 8D A8 04
  LDA #$02                              ; $BCC4: A9 02
  STA $04A9                             ; $BCC6: 8D A9 04
  LDA $04BF                             ; $BCC9: AD BF 04
  STA $04AA                             ; $BCCC: 8D AA 04
  LDA #$09                              ; $BCCF: A9 09
  STA $00BB                             ; $BCD1: 8D BB 00
  LDA #$06                              ; $BCD4: A9 06
  STA $00BC                             ; $BCD6: 8D BC 00
  LDA #$0C                              ; $BCD9: A9 0C
  STA $00BD                             ; $BCDB: 8D BD 00
  LDA #$00                              ; $BCDE: A9 00
  STA $0097                             ; $BCE0: 8D 97 00
  LDA #$A0                              ; $BCE3: A9 A0
  STA $0098                             ; $BCE5: 8D 98 00
  RTS                                   ; $BCE8: 60
Loc_BCE9:  ; (dispatch callback target)
  LDA $04A9                             ; $BCE9: AD A9 04
  JSR $EADE                             ; $BCEC: 20 DE EA
; --- Data Region ---
  .byte $FB,$BC,$1E,$BD,$40,$BD,$5D,$BD,$A9,$BD,$3F,$BE; $BCEF: FB BC 1E BD 40 BD 5D BD A9 BD 3F BE
Loc_BCFB:  ; (dispatch callback target)
; --- Code Region ---
  JSR $D299                             ; $BCFB: 20 99 D2
  BCC $BD1D                             ; $BCFE: 90 1D
  INC $04A9                             ; $BD00: EE A9 04
  LDY $04AA                             ; $BD03: AC AA 04
  LDA $04AD,Y                           ; $BD06: B9 AD 04
  STA $0000                             ; $BD09: 8D 00 00
  LDY #$3D                              ; $BD0C: A0 3D
  JSR $EE07                             ; $BD0E: 20 07 EE
; --- Data Region ---
  .byte $30,$A0,$A9,$04,$8D,$A4,$00,$A9,$27,$4C,$6D,$F2; $BD11: 30 A0 A9 04 8D A4 00 A9 27 4C 6D F2
Loc_BD1D:
; --- Code Region ---
  RTS                                   ; $BD1D: 60
Loc_BD1E:  ; (dispatch callback target)
  JSR $D166                             ; $BD1E: 20 66 D1
  JSR $D299                             ; $BD21: 20 99 D2
  BCC $BD5C                             ; $BD24: 90 36
  JSR $D13D                             ; $BD26: 20 3D D1
  LDA $0081                             ; $BD29: AD 81 00
  AND #$03                              ; $BD2C: 29 03
  BEQ $BD5C                             ; $BD2E: F0 2C
  INC $04A9                             ; $BD30: EE A9 04
  JSR $E57F                             ; $BD33: 20 7F E5
  LDA #$6C                              ; $BD36: A9 6C
  JSR $E683                             ; $BD38: 20 83 E6
  LDA #$00                              ; $BD3B: A9 00
  JMP $F28B                             ; $BD3D: 4C 8B F2
Loc_BD40:  ; (dispatch callback target)
  JSR $D299                             ; $BD40: 20 99 D2
  BCC $BD5C                             ; $BD43: 90 17
  INC $04A9                             ; $BD45: EE A9 04
  LDA #$43                              ; $BD48: A9 43
  STA $0000                             ; $BD4A: 8D 00 00
  LDY $04AA                             ; $BD4D: AC AA 04
  BEQ $BD57                             ; $BD50: F0 05
  LDA #$55                              ; $BD52: A9 55
  STA $0000                             ; $BD54: 8D 00 00
Loc_BD57:
  LDA #$00                              ; $BD57: A9 00
  JMP $CDFD                             ; $BD59: 4C FD CD
Loc_BD5C:
  RTS                                   ; $BD5C: 60
Loc_BD5D:  ; (dispatch callback target)
  LDA #$98                              ; $BD5D: A9 98
  STA $00C6                             ; $BD5F: 8D C6 00
  STA $00CE                             ; $BD62: 8D CE 00
  STA $00D6                             ; $BD65: 8D D6 00
  LDA #$99                              ; $BD68: A9 99
  STA $00C7                             ; $BD6A: 8D C7 00
  STA $00CF                             ; $BD6D: 8D CF 00
  STA $00D7                             ; $BD70: 8D D7 00
  LDA #$02                              ; $BD73: A9 02
  STA $00C8                             ; $BD75: 8D C8 00
  STA $00D0                             ; $BD78: 8D D0 00
  STA $00D8                             ; $BD7B: 8D D8 00
  LDA #$00                              ; $BD7E: A9 00
  STA $04B8                             ; $BD80: 8D B8 04
  LDA #$5F                              ; $BD83: A9 5F
  STA $04BA                             ; $BD85: 8D BA 04
  INC $04A9                             ; $BD88: EE A9 04
  LDA #$18                              ; $BD8B: A9 18
  STA $04BB                             ; $BD8D: 8D BB 04
  LDA #$E3                              ; $BD90: A9 E3
  STA $0000                             ; $BD92: 8D 00 00
  LDY $04AA                             ; $BD95: AC AA 04
  BEQ $BDA4                             ; $BD98: F0 0A
  LDA #$A8                              ; $BD9A: A9 A8
  STA $04BB                             ; $BD9C: 8D BB 04
  LDA #$F5                              ; $BD9F: A9 F5
  STA $0000                             ; $BDA1: 8D 00 00
Loc_BDA4:
  LDA #$00                              ; $BDA4: A9 00
  JMP $CDFD                             ; $BDA6: 4C FD CD
Loc_BDA9:  ; (dispatch callback target)
  INC $04B8                             ; $BDA9: EE B8 04
  LDA $04B8                             ; $BDAC: AD B8 04
  LSR                                   ; $BDAF: 4A
  LSR                                   ; $BDB0: 4A
  LSR                                   ; $BDB1: 4A
  LSR                                   ; $BDB2: 4A
  LSR                                   ; $BDB3: 4A
  AND #$07                              ; $BDB4: 29 07
  CMP #$05                              ; $BDB6: C9 05
  BNE $BDCB                             ; $BDB8: D0 11
  INC $04A9                             ; $BDBA: EE A9 04
  LDY $04AA                             ; $BDBD: AC AA 04
  LDA $04AD,Y                           ; $BDC0: B9 AD 04
  STA $042C                             ; $BDC3: 8D 2C 04
  LDA #$28                              ; $BDC6: A9 28
  JMP $F28B                             ; $BDC8: 4C 8B F2
Loc_BDCB:
  STA $0010                             ; $BDCB: 8D 10 00
  STA $0011                             ; $BDCE: 8D 11 00
  LDA $04AA                             ; $BDD1: AD AA 04
  BNE $BDDF                             ; $BDD4: D0 09
  LDA $0010                             ; $BDD6: AD 10 00
  CLC                                   ; $BDD9: 18
  ADC #$1A                              ; $BDDA: 69 1A
  STA $0010                             ; $BDDC: 8D 10 00
Loc_BDDF:
  LDA #$00                              ; $BDDF: A9 00
  STA $0002                             ; $BDE1: 8D 02 00
  LDA $0010                             ; $BDE4: AD 10 00
  CLC                                   ; $BDE7: 18
  ADC #$A8                              ; $BDE8: 69 A8
  JSR $CEA5                             ; $BDEA: 20 A5 CE
  LDA $04AA                             ; $BDED: AD AA 04
  CLC                                   ; $BDF0: 18
  ADC #$01                              ; $BDF1: 69 01
  STA $0002                             ; $BDF3: 8D 02 00
  LDY $04AA                             ; $BDF6: AC AA 04
  LDA $04AF,Y                           ; $BDF9: B9 AF 04
  STA $0000                             ; $BDFC: 8D 00 00
  ASL                                   ; $BDFF: 0A
  ASL                                   ; $BE00: 0A
  CLC                                   ; $BE01: 18
  ADC $0000                             ; $BE02: 6D 00 00
  ADC $0010                             ; $BE05: 6D 10 00
  ADC #$AD                              ; $BE08: 69 AD
  JSR $CEA5                             ; $BE0A: 20 A5 CE
  LDA $0010                             ; $BE0D: AD 10 00
  SEC                                   ; $BE10: 38
  SBC $0011                             ; $BE11: ED 11 00
  STA $0010                             ; $BE14: 8D 10 00
  LDA #$00                              ; $BE17: A9 00
  STA $0002                             ; $BE19: 8D 02 00
  LDA $0011                             ; $BE1C: AD 11 00
  CMP #$02                              ; $BE1F: C9 02
  BCC $BE3E                             ; $BE21: 90 1B
  LDY #$BC                              ; $BE23: A0 BC
  CMP #$02                              ; $BE25: C9 02
  BEQ $BE2B                             ; $BE27: F0 02
  LDY #$BF                              ; $BE29: A0 BF
Loc_BE2B:
  STY $0000                             ; $BE2B: 8C 00 00
  LDY $04AA                             ; $BE2E: AC AA 04
  LDA $04AF,Y                           ; $BE31: B9 AF 04
  CLC                                   ; $BE34: 18
  ADC $0010                             ; $BE35: 6D 10 00
  ADC $0000                             ; $BE38: 6D 00 00
  JMP $CEA5                             ; $BE3B: 4C A5 CE
Loc_BE3E:
  RTS                                   ; $BE3E: 60
Loc_BE3F:  ; (dispatch callback target)
  LDA #$04                              ; $BE3F: A9 04
  JSR $BDCB                             ; $BE41: 20 CB BD
  JSR $D299                             ; $BE44: 20 99 D2
  BCC $BE77                             ; $BE47: 90 2E
  JSR $D13D                             ; $BE49: 20 3D D1
  LDA $0081                             ; $BE4C: AD 81 00
  AND #$03                              ; $BE4F: 29 03
  BEQ $BE77                             ; $BE51: F0 24
  LDY $04AA                             ; $BE53: AC AA 04
  BEQ $BE5A                             ; $BE56: F0 02
  LDY #$02                              ; $BE58: A0 02
Loc_BE5A:
  LDA #$03                              ; $BE5A: A9 03
  STA $0515,Y                           ; $BE5C: 99 15 05
  TYA                                   ; $BE5F: 98
  EOR #$02                              ; $BE60: 49 02
  TAY                                   ; $BE62: A8
  LDA #$00                              ; $BE63: A9 00
  STA $0515,Y                           ; $BE65: 99 15 05
  LDA #$80                              ; $BE68: A9 80
  STA $04C0                             ; $BE6A: 8D C0 04
  LDA #$0E                              ; $BE6D: A9 0E
  STA $04A8                             ; $BE6F: 8D A8 04
  LDA #$00                              ; $BE72: A9 00
  STA $04A9                             ; $BE74: 8D A9 04
Loc_BE77:
  RTS                                   ; $BE77: 60
Loc_BE78:  ; (dispatch callback target)
  LDA $04A9                             ; $BE78: AD A9 04
  JSR $EADE                             ; $BE7B: 20 DE EA
; --- Data Region ---
  .byte $86,$BE,$43,$BF,$66,$BF,$7E,$BF,$AD,$AA,$04,$49,$01,$A8,$B9,$AD; $BE7E: 86 BE 43 BF 66 BF 7E BF AD AA 04 49 01 A8 B9 AD
  .byte $04,$20,$D7,$F2,$A0,$03,$B1,$00,$8D,$10,$00,$A0,$00,$B1,$00,$8D; $BE8E: 04 20 D7 F2 A0 03 B1 00 8D 10 00 A0 00 B1 00 8D
  .byte $11,$00,$AC,$AA,$04,$B9,$AD,$04,$20,$D7,$F2,$A0,$02,$B1,$00,$8D; $BE9E: 11 00 AC AA 04 B9 AD 04 20 D7 F2 A0 02 B1 00 8D
  .byte $12,$00,$A0,$04,$B1,$00,$18,$6D,$12,$00,$8D,$12,$00,$A2,$00,$AD; $BEAE: 12 00 A0 04 B1 00 18 6D 12 00 8D 12 00 A2 00 AD
  .byte $10,$00,$C9,$50,$B0,$11,$8A,$18,$69,$18,$AA,$AD,$10,$00,$C9,$32; $BEBE: 10 00 C9 50 B0 11 8A 18 69 18 AA AD 10 00 C9 32
  .byte $B0,$05,$8A,$18,$69,$18,$AA       ; $BECE: B0 05 8A 18 69 18 AA
Loc_BED5:
; --- Code Region ---
  LDA $0011                             ; $BED5: AD 11 00
  CMP #$50                              ; $BED8: C9 50
  BCS $BEED                             ; $BEDA: B0 11
  TXA                                   ; $BEDC: 8A
  CLC                                   ; $BEDD: 18
  ADC #$08                              ; $BEDE: 69 08
  TAX                                   ; $BEE0: AA
  LDA $0011                             ; $BEE1: AD 11 00
  CMP #$32                              ; $BEE4: C9 32
  BCS $BEED                             ; $BEE6: B0 05
  TXA                                   ; $BEE8: 8A
  CLC                                   ; $BEE9: 18
  ADC #$08                              ; $BEEA: 69 08
  TAX                                   ; $BEEC: AA
Loc_BEED:
  LDA $0012                             ; $BEED: AD 12 00
  CMP #$B4                              ; $BEF0: C9 B4
  BCS $BF05                             ; $BEF2: B0 11
  TXA                                   ; $BEF4: 8A
  CLC                                   ; $BEF5: 18
  ADC #$48                              ; $BEF6: 69 48
  TAX                                   ; $BEF8: AA
  LDA $0012                             ; $BEF9: AD 12 00
  CMP #$82                              ; $BEFC: C9 82
  BCS $BF05                             ; $BEFE: B0 05
  TXA                                   ; $BF00: 8A
  CLC                                   ; $BF01: 18
  ADC #$48                              ; $BF02: 69 48
  TAX                                   ; $BF04: AA
Loc_BF05:
  JSR $E856                             ; $BF05: 20 56 E8
  STA $0010                             ; $BF08: 8D 10 00
  TXA                                   ; $BF0B: 8A
  CLC                                   ; $BF0C: 18
  ADC $0010                             ; $BF0D: 6D 10 00
  TAX                                   ; $BF10: AA
  LDA $BFB2,X                           ; $BF11: BD B2 BF
  STA $04BF                             ; $BF14: 8D BF 04
  CLC                                   ; $BF17: 18
  ADC #$33                              ; $BF18: 69 33
  STA $04BE                             ; $BF1A: 8D BE 04
  LDA $04BF                             ; $BF1D: AD BF 04
  CLC                                   ; $BF20: 18
  ADC #$2F                              ; $BF21: 69 2F
  STA $04BD                             ; $BF23: 8D BD 04
  LDA $04BF                             ; $BF26: AD BF 04
  CMP #$03                              ; $BF29: C9 03
  BCS $BF38                             ; $BF2B: B0 0B
  LDA $04AA                             ; $BF2D: AD AA 04
  EOR #$01                              ; $BF30: 49 01
  TAY                                   ; $BF32: A8
  LDA #$02                              ; $BF33: A9 02
  STA $04C3,Y                           ; $BF35: 99 C3 04
Loc_BF38:
  LDA #$09                              ; $BF38: A9 09
  STA $04A8                             ; $BF3A: 8D A8 04
  LDA #$00                              ; $BF3D: A9 00
  STA $04A9                             ; $BF3F: 8D A9 04
  RTS                                   ; $BF42: 60
Loc_BF43:  ; (dispatch callback target)
  LDA $04AA                             ; $BF43: AD AA 04
  EOR #$01                              ; $BF46: 49 01
  TAY                                   ; $BF48: A8
  BEQ $BF4D                             ; $BF49: F0 02
  LDY #$02                              ; $BF4B: A0 02
Loc_BF4D:
  LDA #$01                              ; $BF4D: A9 01
  STA $0515,Y                           ; $BF4F: 99 15 05
  TYA                                   ; $BF52: 98
  EOR #$02                              ; $BF53: 49 02
  TAY                                   ; $BF55: A8
  LDA #$00                              ; $BF56: A9 00
  STA $0515,Y                           ; $BF58: 99 15 05
  LDA #$0F                              ; $BF5B: A9 0F
  STA $04A8                             ; $BF5D: 8D A8 04
  LDA #$00                              ; $BF60: A9 00
  STA $04A9                             ; $BF62: 8D A9 04
  RTS                                   ; $BF65: 60
Loc_BF66:  ; (dispatch callback target)
  LDA #$00                              ; $BF66: A9 00
  STA $0515                             ; $BF68: 8D 15 05
  STA $0517                             ; $BF6B: 8D 17 05
  LDA #$0E                              ; $BF6E: A9 0E
  STA $04A8                             ; $BF70: 8D A8 04
  LDA #$00                              ; $BF73: A9 00
  STA $04A9                             ; $BF75: 8D A9 04
  LDA #$FF                              ; $BF78: A9 FF
  STA $04C0                             ; $BF7A: 8D C0 04
  RTS                                   ; $BF7D: 60
Loc_BF7E:  ; (dispatch callback target)
  JSR $D299                             ; $BF7E: 20 99 D2
  BCC $BFB1                             ; $BF81: 90 2E
  JSR $D13D                             ; $BF83: 20 3D D1
  LDA $0081                             ; $BF86: AD 81 00
  AND #$03                              ; $BF89: 29 03
  BEQ $BFB1                             ; $BF8B: F0 24
  LDY $04AA                             ; $BF8D: AC AA 04
  BEQ $BF94                             ; $BF90: F0 02
  LDY #$02                              ; $BF92: A0 02
Loc_BF94:
  LDA #$00                              ; $BF94: A9 00
  STA $0515,Y                           ; $BF96: 99 15 05
  TYA                                   ; $BF99: 98
  EOR #$02                              ; $BF9A: 49 02
  TAY                                   ; $BF9C: A8
  LDA #$04                              ; $BF9D: A9 04
  STA $0515,Y                           ; $BF9F: 99 15 05
  LDA #$0E                              ; $BFA2: A9 0E
  STA $04A8                             ; $BFA4: 8D A8 04
  LDA #$00                              ; $BFA7: A9 00
  STA $04A9                             ; $BFA9: 8D A9 04
  LDA #$FF                              ; $BFAC: A9 FF
  STA $04C0                             ; $BFAE: 8D C0 04
Loc_BFB1:
  RTS                                   ; $BFB1: 60
; --- Data Region ---
  .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01; $BFB2: 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
  .byte $01,$01,$01,$01,$02,$02,$02,$02,$01,$01,$01,$01,$01,$01,$01,$02; $BFC2: 01 01 01 01 02 02 02 02 01 01 01 01 01 01 01 02
  .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$02,$02,$03,$03; $BFD2: 01 01 01 01 01 01 01 01 01 01 01 01 02 02 03 03
  .byte $01,$01,$01,$01,$01,$01,$04,$04,$01,$01,$03,$03,$04,$04,$04,$04; $BFE2: 01 01 01 01 01 01 04 04 01 01 03 03 04 04 04 04
  .byte $02,$02,$02,$02,$04,$04,$04,$04,$01,$01,$01,$01,$01,$01,$01,$01; $BFF2: 02 02 02 02 04 04 04 04 01 01 01 01 01 01 01 01
  .byte $01,$01,$01,$01,$01,$01,$02,$02,$01,$01,$01,$01,$01,$01,$02,$02; $C002: 01 01 01 01 01 01 02 02 01 01 01 01 01 01 02 02
  .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$02,$02,$03,$03; $C012: 01 01 01 01 01 01 01 01 01 01 01 01 02 02 03 03
  .byte $01,$01,$01,$01,$02,$02,$02,$02,$01,$01,$01,$01,$03,$03,$04,$04; $C022: 01 01 01 01 02 02 02 02 01 01 01 01 03 03 04 04
  .byte $01,$01,$03,$03,$03,$03,$04,$04,$01,$01,$03,$03,$04,$04,$04,$04; $C032: 01 01 03 03 03 03 04 04 01 01 03 03 04 04 04 04
  .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01; $C042: 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
  .byte $01,$01,$01,$01,$02,$02,$02,$02,$01,$01,$01,$01,$04,$04,$04,$04; $C052: 01 01 01 01 02 02 02 02 01 01 01 01 04 04 04 04
  .byte $01,$01,$03,$03,$03,$03,$04,$04,$01,$01,$02,$02,$04,$04,$04,$04; $C062: 01 01 03 03 03 03 04 04 01 01 02 02 04 04 04 04
  .byte $01,$01,$01,$01,$04,$04,$04,$04,$01,$01,$02,$02,$04,$04,$04,$04; $C072: 01 01 01 01 04 04 04 04 01 01 02 02 04 04 04 04
  .byte $01,$01,$04,$04,$04,$04,$04,$04   ; $C082: 01 01 04 04 04 04 04 04
Loc_C08A:  ; (dispatch callback target)
; --- Code Region ---
  LDY $04AA                             ; $C08A: AC AA 04
  LDA #$80                              ; $C08D: A9 80
  STA $04B5,Y                           ; $C08F: 99 B5 04
  TYA                                   ; $C092: 98
  EOR #$01                              ; $C093: 49 01
  TAY                                   ; $C095: A8
  LDA $04AD,Y                           ; $C096: B9 AD 04
  JSR $F2D7                             ; $C099: 20 D7 F2
  LDY #$02                              ; $C09C: A0 02
  LDA ($00),Y                           ; $C09E: B1 00
  STA $0011                             ; $C0A0: 8D 11 00
  LDY $04AA                             ; $C0A3: AC AA 04
  LDA $04AD,Y                           ; $C0A6: B9 AD 04
  JSR $F2D7                             ; $C0A9: 20 D7 F2
  LDY #$02                              ; $C0AC: A0 02
  LDA ($00),Y                           ; $C0AE: B1 00
  STA $0010                             ; $C0B0: 8D 10 00
  LDY #$04                              ; $C0B3: A0 04
  LDA ($00),Y                           ; $C0B5: B1 00
  CLC                                   ; $C0B7: 18
  ADC $0010                             ; $C0B8: 6D 10 00
  SEC                                   ; $C0BB: 38
  SBC $0011                             ; $C0BC: ED 11 00
  BCS $C0C3                             ; $C0BF: B0 02
  LDA #$00                              ; $C0C1: A9 00
Loc_C0C3:
  STA $0010                             ; $C0C3: 8D 10 00
  INC $0010                             ; $C0C6: EE 10 00
Loc_C0C9:
  JSR $E85C                             ; $C0C9: 20 5C E8
  CMP #$0A                              ; $C0CC: C9 0A
  BCS $C0C9                             ; $C0CE: B0 F9
  ADC $0010                             ; $C0D0: 6D 10 00
  CMP #$6E                              ; $C0D3: C9 6E
  BCS $C0DF                             ; $C0D5: B0 08
  LDA #$2F                              ; $C0D7: A9 2F
Loc_C0D9:
  STA $04BE                             ; $C0D9: 8D BE 04
  JMP $C103                             ; $C0DC: 4C 03 C1
Loc_C0DF:
  JSR $E850                             ; $C0DF: 20 50 E8
  STA $0010                             ; $C0E2: 8D 10 00
  BEQ $C0DF                             ; $C0E5: F0 F8
  INC $0010                             ; $C0E7: EE 10 00
  INC $0010                             ; $C0EA: EE 10 00
  LDA $04AA                             ; $C0ED: AD AA 04
  EOR #$01                              ; $C0F0: 49 01
  TAY                                   ; $C0F2: A8
  LDA $0010                             ; $C0F3: AD 10 00
  STA $04B5,Y                           ; $C0F6: 99 B5 04
  LDA #$02                              ; $C0F9: A9 02
  STA $04C3,Y                           ; $C0FB: 99 C3 04
  LDA #$2E                              ; $C0FE: A9 2E
  STA $04BE                             ; $C100: 8D BE 04
Loc_C103:
  LDA #$2D                              ; $C103: A9 2D
  STA $04BD                             ; $C105: 8D BD 04
  LDA #$09                              ; $C108: A9 09
  STA $04A8                             ; $C10A: 8D A8 04
  LDA #$00                              ; $C10D: A9 00
  STA $04A9                             ; $C10F: 8D A9 04
  STA $04BF                             ; $C112: 8D BF 04
  RTS                                   ; $C115: 60
Loc_C116:  ; (dispatch callback target)
  LDA $04A9                             ; $C116: AD A9 04
  JSR $EADE                             ; $C119: 20 DE EA
  BIT $C1                               ; $C11C: 24 C1
; --- Data Region ---
  .byte $3A,$C1,$4A,$C1,$87,$C1           ; $C11E: 3A C1 4A C1 87 C1
Loc_C124:  ; (dispatch callback target)
; --- Code Region ---
  JSR $D299                             ; $C124: 20 99 D2
  BCC $C139                             ; $C127: 90 10
  INC $04A9                             ; $C129: EE A9 04
  LDA $04AD                             ; $C12C: AD AD 04
  STA $0000                             ; $C12F: 8D 00 00
  LDY #$3D                              ; $C132: A0 3D
  JSR $EE07                             ; $C134: 20 07 EE
; --- Data Region ---
  .byte $30,$A0,$60                       ; $C137: 30 A0 60
Loc_C13A:  ; (dispatch callback target)
; --- Code Region ---
  INC $04A9                             ; $C13A: EE A9 04
  LDY #$3D                              ; $C13D: A0 3D
  JSR $EE07                             ; $C13F: 20 07 EE
; --- Data Region ---
  .byte $33,$A0,$AD,$BD,$04,$4C,$83,$D2   ; $C142: 33 A0 AD BD 04 4C 83 D2
Loc_C14A:  ; (dispatch callback target)
; --- Code Region ---
  LDY $04AA                             ; $C14A: AC AA 04
  LDA $04C3,Y                           ; $C14D: B9 C3 04
  STA $0010,Y                           ; $C150: 99 10 00
  TYA                                   ; $C153: 98
  EOR #$01                              ; $C154: 49 01
  TAY                                   ; $C156: A8
  LDA #$80                              ; $C157: A9 80
  STA $0010,Y                           ; $C159: 99 10 00
  JSR $C1E2                             ; $C15C: 20 E2 C1
  JSR $D299                             ; $C15F: 20 99 D2
  BCC $C186                             ; $C162: 90 22
  JSR $D13D                             ; $C164: 20 3D D1
  LDA $0081                             ; $C167: AD 81 00
  AND #$03                              ; $C16A: 29 03
  BEQ $C186                             ; $C16C: F0 18
  INC $04A9                             ; $C16E: EE A9 04
  LDA $04AA                             ; $C171: AD AA 04
  EOR #$01                              ; $C174: 49 01
  STA $04AA                             ; $C176: 8D AA 04
  TAY                                   ; $C179: A8
  LDA $04AD,Y                           ; $C17A: B9 AD 04
  STA $042C                             ; $C17D: 8D 2C 04
  LDA $04BE                             ; $C180: AD BE 04
  JMP $D283                             ; $C183: 4C 83 D2
Loc_C186:
  RTS                                   ; $C186: 60
Loc_C187:  ; (dispatch callback target)
  LDY $04AA                             ; $C187: AC AA 04
  LDA $04C3,Y                           ; $C18A: B9 C3 04
  STA $0010,Y                           ; $C18D: 99 10 00
  TYA                                   ; $C190: 98
  EOR #$01                              ; $C191: 49 01
  TAY                                   ; $C193: A8
  LDA #$80                              ; $C194: A9 80
  STA $0010,Y                           ; $C196: 99 10 00
  JSR $C1E2                             ; $C199: 20 E2 C1
  JSR $D299                             ; $C19C: 20 99 D2
  BCC $C1E1                             ; $C19F: 90 40
  JSR $D13D                             ; $C1A1: 20 3D D1
  LDA $0081                             ; $C1A4: AD 81 00
  AND #$03                              ; $C1A7: 29 03
  BEQ $C1E1                             ; $C1A9: F0 36
  LDA $04AA                             ; $C1AB: AD AA 04
  EOR #$01                              ; $C1AE: 49 01
  STA $04AA                             ; $C1B0: 8D AA 04
  LDA $04BF                             ; $C1B3: AD BF 04
  CMP #$02                              ; $C1B6: C9 02
  BCC $C1D1                             ; $C1B8: 90 17
  STA $04A9                             ; $C1BA: 8D A9 04
  DEC $04A9                             ; $C1BD: CE A9 04
  LDA #$07                              ; $C1C0: A9 07
  STA $04A8                             ; $C1C2: 8D A8 04
  LDA $04BF                             ; $C1C5: AD BF 04
  CMP #$04                              ; $C1C8: C9 04
  BNE $C1E1                             ; $C1CA: D0 15
  LDA #$38                              ; $C1CC: A9 38
  JMP $F28B                             ; $C1CE: 4C 8B F2
Loc_C1D1:
  LDA #$01                              ; $C1D1: A9 01
  STA $04A8                             ; $C1D3: 8D A8 04
  LDA #$00                              ; $C1D6: A9 00
  STA $04A9                             ; $C1D8: 8D A9 04
  STA $04C3                             ; $C1DB: 8D C3 04
  STA $04C4                             ; $C1DE: 8D C4 04
Loc_C1E1:
  RTS                                   ; $C1E1: 60
Loc_C1E2:
  LDA #$A5                              ; $C1E2: A9 A5
  STA $000A                             ; $C1E4: 8D 0A 00
  LDX #$00                              ; $C1E7: A2 00
  LDA $04AD                             ; $C1E9: AD AD 04
  STA $0000                             ; $C1EC: 8D 00 00
  LDA $0010                             ; $C1EF: AD 10 00
  STA $00A4                             ; $C1F2: 8D A4 00
  LDY #$39                              ; $C1F5: A0 39
  JSR $EE07                             ; $C1F7: 20 07 EE
; --- Data Region ---
  .byte $00,$A0,$A2,$01,$A9,$C8,$8D,$BC,$04,$AD,$AE,$04,$8D,$00,$00,$AD; $C1FA: 00 A0 A2 01 A9 C8 8D BC 04 AD AE 04 8D 00 00 AD
  .byte $11,$00,$8D,$A4,$00,$A0,$39,$20,$07,$EE,$00,$A0,$A9,$00,$8D,$BC; $C20A: 11 00 8D A4 00 A0 39 20 07 EE 00 A0 A9 00 8D BC
  .byte $04,$60                           ; $C21A: 04 60
Loc_C21C:  ; (dispatch callback target)
; --- Code Region ---
  LDA $04A9                             ; $C21C: AD A9 04
  JSR $EADE                             ; $C21F: 20 DE EA
; --- Data Region ---
  .byte $2A,$C2,$56,$C2,$8E,$C2,$AA,$C2   ; $C222: 2A C2 56 C2 8E C2 AA C2
Loc_C22A:  ; (dispatch callback target)
; --- Code Region ---
  JSR $E57F                             ; $C22A: 20 7F E5
  LDA #$71                              ; $C22D: A9 71
  JSR $E683                             ; $C22F: 20 83 E6
  LDA #$91                              ; $C232: A9 91
  STA $00CC                             ; $C234: 8D CC 00
  STA $00D4                             ; $C237: 8D D4 00
  STA $00DC                             ; $C23A: 8D DC 00
  INC $04A9                             ; $C23D: EE A9 04
  LDA #$43                              ; $C240: A9 43
  STA $0000                             ; $C242: 8D 00 00
  LDA #$13                              ; $C245: A9 13
  LDY $04AA                             ; $C247: AC AA 04
  BEQ $C253                             ; $C24A: F0 07
  LDA #$55                              ; $C24C: A9 55
  STA $0000                             ; $C24E: 8D 00 00
  LDA #$15                              ; $C251: A9 15
Loc_C253:
  JMP $CDFD                             ; $C253: 4C FD CD
Loc_C256:  ; (dispatch callback target)
  LDA #$90                              ; $C256: A9 90
  STA $00C6                             ; $C258: 8D C6 00
  STA $00CE                             ; $C25B: 8D CE 00
  STA $00D6                             ; $C25E: 8D D6 00
  LDA #$00                              ; $C261: A9 00
  STA $04B8                             ; $C263: 8D B8 04
  LDA #$4F                              ; $C266: A9 4F
  STA $04BA                             ; $C268: 8D BA 04
  INC $04A9                             ; $C26B: EE A9 04
  LDA #$18                              ; $C26E: A9 18
  STA $04BB                             ; $C270: 8D BB 04
  LDA #$E3                              ; $C273: A9 E3
  STA $0000                             ; $C275: 8D 00 00
  LDA #$14                              ; $C278: A9 14
  LDY $04AA                             ; $C27A: AC AA 04
  BEQ $C28B                             ; $C27D: F0 0C
  LDA #$A8                              ; $C27F: A9 A8
  STA $04BB                             ; $C281: 8D BB 04
  LDA #$F5                              ; $C284: A9 F5
  STA $0000                             ; $C286: 8D 00 00
  LDA #$16                              ; $C289: A9 16
Loc_C28B:
  JMP $CDFD                             ; $C28B: 4C FD CD
Loc_C28E:  ; (dispatch callback target)
  INC $04B8                             ; $C28E: EE B8 04
  LDA $04B8                             ; $C291: AD B8 04
  ROL                                   ; $C294: 2A
  ROL                                   ; $C295: 2A
  ROL                                   ; $C296: 2A
  AND #$03                              ; $C297: 29 03
  CMP #$02                              ; $C299: C9 02
  BNE $C2CC                             ; $C29B: D0 2F
  LDA #$01                              ; $C29D: A9 01
  JSR $C2CC                             ; $C29F: 20 CC C2
  INC $04A9                             ; $C2A2: EE A9 04
  LDA #$26                              ; $C2A5: A9 26
  JMP $F28B                             ; $C2A7: 4C 8B F2
Loc_C2AA:  ; (dispatch callback target)
  LDA #$01                              ; $C2AA: A9 01
  JSR $C2CC                             ; $C2AC: 20 CC C2
  JSR $D299                             ; $C2AF: 20 99 D2
  BCC $C2CB                             ; $C2B2: 90 17
  JSR $D13D                             ; $C2B4: 20 3D D1
  LDA $0081                             ; $C2B7: AD 81 00
  AND #$03                              ; $C2BA: 29 03
  BEQ $C2CB                             ; $C2BC: F0 0D
  LDA #$0E                              ; $C2BE: A9 0E
  STA $04A8                             ; $C2C0: 8D A8 04
  LDA #$00                              ; $C2C3: A9 00
  STA $04A9                             ; $C2C5: 8D A9 04
  STA $04C0                             ; $C2C8: 8D C0 04
Loc_C2CB:
  RTS                                   ; $C2CB: 60
Loc_C2CC:
  STA $0010                             ; $C2CC: 8D 10 00
  LDA $04AA                             ; $C2CF: AD AA 04
  BEQ $C2DD                             ; $C2D2: F0 09
  LDA $0010                             ; $C2D4: AD 10 00
  CLC                                   ; $C2D7: 18
  ADC #$06                              ; $C2D8: 69 06
  STA $0010                             ; $C2DA: 8D 10 00
Loc_C2DD:
  LDA $04AA                             ; $C2DD: AD AA 04
  CLC                                   ; $C2E0: 18
  ADC #$01                              ; $C2E1: 69 01
  STA $0002                             ; $C2E3: 8D 02 00
  LDY $04AA                             ; $C2E6: AC AA 04
  LDA $04AF,Y                           ; $C2E9: B9 AF 04
  ASL                                   ; $C2EC: 0A
  CLC                                   ; $C2ED: 18
  ADC $0010                             ; $C2EE: 6D 10 00
  ADC #$6A                              ; $C2F1: 69 6A
  JMP $CEA5                             ; $C2F3: 4C A5 CE
Loc_C2F6:  ; (dispatch callback target)
  LDA $04C0                             ; $C2F6: AD C0 04
  BMI $C300                             ; $C2F9: 30 05
  LDA #$01                              ; $C2FB: A9 01
  JSR $C2CC                             ; $C2FD: 20 CC C2
Loc_C300:
  LDA $04A9                             ; $C300: AD A9 04
  JSR $EADE                             ; $C303: 20 DE EA
; --- Data Region ---
  .byte $0E,$C3,$3B,$C3,$5D,$C3,$4F,$C4,$AD,$AD,$04,$8D,$14,$05,$AD,$AE; $C306: 0E C3 3B C3 5D C3 4F C4 AD AD 04 8D 14 05 AD AE
  .byte $04,$8D,$16,$05,$A0,$00,$AD,$15,$05,$C9,$02,$F0,$0F,$A0,$02,$AD; $C316: 04 8D 16 05 A0 00 AD 15 05 C9 02 F0 0F A0 02 AD
  .byte $17,$05,$C9,$02,$F0,$06,$EE,$A9,$04,$4C,$EE,$EC; $C326: 17 05 C9 02 F0 06 EE A9 04 4C EE EC
Loc_C332:
; --- Code Region ---
  STY $04BD                             ; $C332: 8C BD 04
  LDA #$02                              ; $C335: A9 02
  STA $04A9                             ; $C337: 8D A9 04
  RTS                                   ; $C33A: 60
Loc_C33B:  ; (dispatch callback target)
  LDA $0087                             ; $C33B: AD 87 00
  BPL $C35C                             ; $C33E: 10 1C
  LDA #$0B                              ; $C340: A9 0B
  STA $0500                             ; $C342: 8D 00 05
  LDA #$00                              ; $C345: A9 00
  STA $0501                             ; $C347: 8D 01 05
  LDA $050F                             ; $C34A: AD 0F 05
  CMP #$03                              ; $C34D: C9 03
  BEQ $C354                             ; $C34F: F0 03
  STA $6F44                             ; $C351: 8D 44 6F
Loc_C354:
  LDA #$03                              ; $C354: A9 03
  STA $007A                             ; $C356: 8D 7A 00
  JMP $ECBF                             ; $C359: 4C BF EC
Loc_C35C:
  RTS                                   ; $C35C: 60
Loc_C35D:  ; (dispatch callback target)
  LDX $04BD                             ; $C35D: AE BD 04
  LDA $0514,X                           ; $C360: BD 14 05
  CMP #$83                              ; $C363: C9 83
  BNE $C36A                             ; $C365: D0 03
  JMP $C3AA                             ; $C367: 4C AA C3
Loc_C36A:
  CMP #$AD                              ; $C36A: C9 AD
  BNE $C371                             ; $C36C: D0 03
  JMP $C3C0                             ; $C36E: 4C C0 C3
Loc_C371:
  CMP #$B6                              ; $C371: C9 B6
  BNE $C378                             ; $C373: D0 03
  JMP $C401                             ; $C375: 4C 01 C4
Loc_C378:
  CMP #$DE                              ; $C378: C9 DE
  BNE $C37F                             ; $C37A: D0 03
  JMP $C42E                             ; $C37C: 4C 2E C4
Loc_C37F:
  LDA $6FE1                             ; $C37F: AD E1 6F
  AND #$01                              ; $C382: 29 01
  BNE $C3A4                             ; $C384: D0 1E
  LDA #$00                              ; $C386: A9 00
  STA $0010                             ; $C388: 8D 10 00
Loc_C38B:
  JSR $F368                             ; $C38B: 20 68 F3
  LDY #$00                              ; $C38E: A0 00
  LDA ($00),Y                           ; $C390: B1 00
  CMP $0514,X                           ; $C392: DD 14 05
  BNE $C39A                             ; $C395: D0 03
  JMP $C3E3                             ; $C397: 4C E3 C3
Loc_C39A:
  INC $0010                             ; $C39A: EE 10 00
  LDA $0010                             ; $C39D: AD 10 00
  CMP #$07                              ; $C3A0: C9 07
  BCC $C38B                             ; $C3A2: 90 E7
Loc_C3A4:
  LDA #$01                              ; $C3A4: A9 01
  STA $04A9                             ; $C3A6: 8D A9 04
  RTS                                   ; $C3A9: 60
Loc_C3AA:
  LDA #$64                              ; $C3AA: A9 64
  JSR $E862                             ; $C3AC: 20 62 E8
  CMP #$1E                              ; $C3AF: C9 1E
  BCS $C3A4                             ; $C3B1: B0 F1
  LDA #$06                              ; $C3B3: A9 06
  STA $0010                             ; $C3B5: 8D 10 00
  LDA #$3F                              ; $C3B8: A9 3F
  STA $0011                             ; $C3BA: 8D 11 00
  JMP $C40B                             ; $C3BD: 4C 0B C4
Loc_C3C0:
  LDA $04BD                             ; $C3C0: AD BD 04
  EOR #$02                              ; $C3C3: 49 02
  TAX                                   ; $C3C5: AA
  LDA $0514,X                           ; $C3C6: BD 14 05
  JSR $F2D7                             ; $C3C9: 20 D7 F2
  LDY #$0B                              ; $C3CC: A0 0B
  LDA ($00),Y                           ; $C3CE: B1 00
  AND #$F0                              ; $C3D0: 29 F0
  CMP #$20                              ; $C3D2: C9 20
  BCS $C3A4                             ; $C3D4: B0 CE
  LDA #$07                              ; $C3D6: A9 07
  STA $0010                             ; $C3D8: 8D 10 00
  LDA #$40                              ; $C3DB: A9 40
  STA $0011                             ; $C3DD: 8D 11 00
  JMP $C40B                             ; $C3E0: 4C 0B C4
Loc_C3E3:
  LDA #$64                              ; $C3E3: A9 64
  JSR $E862                             ; $C3E5: 20 62 E8
  CMP #$32                              ; $C3E8: C9 32
  BCS $C3A4                             ; $C3EA: B0 B8
  LDA $6FE1                             ; $C3EC: AD E1 6F
  ORA #$01                              ; $C3EF: 09 01
  STA $6FE1                             ; $C3F1: 8D E1 6F
  LDA #$0E                              ; $C3F4: A9 0E
  STA $0010                             ; $C3F6: 8D 10 00
  LDA #$41                              ; $C3F9: A9 41
  STA $0011                             ; $C3FB: 8D 11 00
  JMP $C40B                             ; $C3FE: 4C 0B C4
Loc_C401:
  LDA #$05                              ; $C401: A9 05
  STA $0010                             ; $C403: 8D 10 00
  LDA #$3E                              ; $C406: A9 3E
  STA $0011                             ; $C408: 8D 11 00
Loc_C40B:
  LDA $04BD                             ; $C40B: AD BD 04
  EOR #$02                              ; $C40E: 49 02
  TAX                                   ; $C410: AA
  LDA $0514,X                           ; $C411: BD 14 05
  STA $042C                             ; $C414: 8D 2C 04
  JSR $F2D7                             ; $C417: 20 D7 F2
  LDY #$0A                              ; $C41A: A0 0A
  LDA ($00),Y                           ; $C41C: B1 00
  AND #$E0                              ; $C41E: 29 E0
  ORA $0010                             ; $C420: 0D 10 00
  STA ($00),Y                           ; $C423: 91 00
  INC $04A9                             ; $C425: EE A9 04
  LDA $0011                             ; $C428: AD 11 00
  JMP $F28B                             ; $C42B: 4C 8B F2
Loc_C42E:
  LDA $04BD                             ; $C42E: AD BD 04
  EOR #$02                              ; $C431: 49 02
  TAX                                   ; $C433: AA
  LDA $0514,X                           ; $C434: BD 14 05
  STA $042C                             ; $C437: 8D 2C 04
  JSR $F2D7                             ; $C43A: 20 D7 F2
  LDY #$0A                              ; $C43D: A0 0A
  LDA ($00),Y                           ; $C43F: B1 00
  AND #$1F                              ; $C441: 29 1F
  ORA #$E0                              ; $C443: 09 E0
  STA ($00),Y                           ; $C445: 91 00
  INC $04A9                             ; $C447: EE A9 04
  LDA #$42                              ; $C44A: A9 42
  JMP $F28B                             ; $C44C: 4C 8B F2
Loc_C44F:  ; (dispatch callback target)
  JSR $D299                             ; $C44F: 20 99 D2
  BCC $C463                             ; $C452: 90 0F
  JSR $D13D                             ; $C454: 20 3D D1
  LDA $0081                             ; $C457: AD 81 00
  AND #$03                              ; $C45A: 29 03
  BEQ $C463                             ; $C45C: F0 05
  LDA #$01                              ; $C45E: A9 01
  STA $04A9                             ; $C460: 8D A9 04
Loc_C463:
  RTS                                   ; $C463: 60
Loc_C464:  ; (dispatch callback target)
  LDA $04A9                             ; $C464: AD A9 04
  JSR $EADE                             ; $C467: 20 DE EA
; --- Data Region ---
  .byte $6E,$C4,$80,$C4,$AD,$AD,$04,$8D,$14,$05,$AD,$AE,$04,$8D,$16,$05; $C46A: 6E C4 80 C4 AD AD 04 8D 14 05 AD AE 04 8D 16 05
  .byte $EE,$A9,$04,$4C,$EE,$EC           ; $C47A: EE A9 04 4C EE EC
Loc_C480:  ; (dispatch callback target)
; --- Code Region ---
  LDA $0087                             ; $C480: AD 87 00
  BPL $C497                             ; $C483: 10 12
  LDA $050F                             ; $C485: AD 0F 05
  CMP #$03                              ; $C488: C9 03
  BEQ $C48F                             ; $C48A: F0 03
  STA $6F44                             ; $C48C: 8D 44 6F
Loc_C48F:
  LDA #$05                              ; $C48F: A9 05
  STA $007A                             ; $C491: 8D 7A 00
  JMP $ECBF                             ; $C494: 4C BF EC
Loc_C497:
  RTS                                   ; $C497: 60
Loc_C498:  ; (dispatch callback target)
  LDA $04A9                             ; $C498: AD A9 04
  JSR $EADE                             ; $C49B: 20 DE EA
; --- Data Region ---
  .byte $AC,$C4,$C3,$C4,$E9,$C4,$5A,$C5,$98,$C5,$D2,$C5,$6B,$C6,$EE,$A9; $C49E: AC C4 C3 C4 E9 C4 5A C5 98 C5 D2 C5 6B C6 EE A9
  .byte $04,$A9,$43,$8D,$00,$00,$AD,$AA,$04,$F0,$05,$A9,$55,$8D,$00,$00; $C4AE: 04 A9 43 8D 00 00 AD AA 04 F0 05 A9 55 8D 00 00
Loc_C4BE:
; --- Code Region ---
  LDA #$00                              ; $C4BE: A9 00
  JMP $CDFD                             ; $C4C0: 4C FD CD
Loc_C4C3:  ; (dispatch callback target)
  LDA #$00                              ; $C4C3: A9 00
  STA $04B8                             ; $C4C5: 8D B8 04
  INC $04A9                             ; $C4C8: EE A9 04
  LDA #$18                              ; $C4CB: A9 18
  STA $04BB                             ; $C4CD: 8D BB 04
  LDA #$E3                              ; $C4D0: A9 E3
  STA $0000                             ; $C4D2: 8D 00 00
  LDA $04AA                             ; $C4D5: AD AA 04
  BEQ $C4E4                             ; $C4D8: F0 0A
  LDA #$A8                              ; $C4DA: A9 A8
  STA $04BB                             ; $C4DC: 8D BB 04
  LDA #$F5                              ; $C4DF: A9 F5
  STA $0000                             ; $C4E1: 8D 00 00
Loc_C4E4:
  LDA #$00                              ; $C4E4: A9 00
  JMP $CDFD                             ; $C4E6: 4C FD CD
Loc_C4E9:  ; (dispatch callback target)
  LDA $04AA                             ; $C4E9: AD AA 04
  BEQ $C4F8                             ; $C4EC: F0 0A
  LDA $04BB                             ; $C4EE: AD BB 04
  CMP #$58                              ; $C4F1: C9 58
  BEQ $C513                             ; $C4F3: F0 1E
  JMP $C4FF                             ; $C4F5: 4C FF C4
Loc_C4F8:
  LDA $04BB                             ; $C4F8: AD BB 04
  CMP #$68                              ; $C4FB: C9 68
  BEQ $C513                             ; $C4FD: F0 14
Loc_C4FF:
  LDA $04AA                             ; $C4FF: AD AA 04
  STA $0011                             ; $C502: 8D 11 00
  BEQ $C50D                             ; $C505: F0 06
  DEC $04BB                             ; $C507: CE BB 04
  JMP $CEE1                             ; $C50A: 4C E1 CE
Loc_C50D:
  INC $04BB                             ; $C50D: EE BB 04
  JMP $CEE1                             ; $C510: 4C E1 CE
Loc_C513:
  INC $04A9                             ; $C513: EE A9 04
  LDA $04AA                             ; $C516: AD AA 04
  BEQ $C525                             ; $C519: F0 0A
  LDA #$4B                              ; $C51B: A9 4B
  STA $0000                             ; $C51D: 8D 00 00
  LDA #$18                              ; $C520: A9 18
  JMP $C52C                             ; $C522: 4C 2C C5
Loc_C525:
  LDA #$4D                              ; $C525: A9 4D
  STA $0000                             ; $C527: 8D 00 00
  LDA #$17                              ; $C52A: A9 17
Loc_C52C:
  JSR $CDFD                             ; $C52C: 20 FD CD
  LDA #$02                              ; $C52F: A9 02
  STA $03B7                             ; $C531: 8D B7 03
  LDA #$23                              ; $C534: A9 23
  STA $03B8                             ; $C536: 8D B8 03
  LDA #$DB                              ; $C539: A9 DB
  STA $03B9                             ; $C53B: 8D B9 03
  LDA $04AA                             ; $C53E: AD AA 04
  ASL                                   ; $C541: 0A
  TAY                                   ; $C542: A8
  LDA $C556,Y                           ; $C543: B9 56 C5
  STA $03BA                             ; $C546: 8D BA 03
  INY                                   ; $C549: C8
  LDA $C556,Y                           ; $C54A: B9 56 C5
  STA $03BB                             ; $C54D: 8D BB 03
  LDA #$FF                              ; $C550: A9 FF
  STA $03BC                             ; $C552: 8D BC 03
  RTS                                   ; $C555: 60
; --- Data Region ---
  .byte $44,$11,$CC,$33                   ; $C556: 44 11 CC 33
Loc_C55A:  ; (dispatch callback target)
; --- Code Region ---
  LDA #$92                              ; $C55A: A9 92
  STA $00C7                             ; $C55C: 8D C7 00
  STA $00CF                             ; $C55F: 8D CF 00
  STA $00D7                             ; $C562: 8D D7 00
  LDA #$84                              ; $C565: A9 84
  STA $00C8                             ; $C567: 8D C8 00
  STA $00D0                             ; $C56A: 8D D0 00
  STA $00D8                             ; $C56D: 8D D8 00
  LDA #$FF                              ; $C570: A9 FF
  STA $04B8                             ; $C572: 8D B8 04
  LDA #$00                              ; $C575: A9 00
  STA $04B9                             ; $C577: 8D B9 04
  LDA #$4F                              ; $C57A: A9 4F
  STA $04BA                             ; $C57C: 8D BA 04
  INC $04A9                             ; $C57F: EE A9 04
  LDA #$ED                              ; $C582: A9 ED
  STA $0000                             ; $C584: 8D 00 00
  LDA #$04                              ; $C587: A9 04
  LDY $04AA                             ; $C589: AC AA 04
  BEQ $C595                             ; $C58C: F0 07
  LDA #$EB                              ; $C58E: A9 EB
  STA $0000                             ; $C590: 8D 00 00
  LDA #$08                              ; $C593: A9 08
Loc_C595:
  JMP $CDFD                             ; $C595: 4C FD CD
Loc_C598:  ; (dispatch callback target)
  LDA #$90                              ; $C598: A9 90
  STA $00CC                             ; $C59A: 8D CC 00
  STA $00D4                             ; $C59D: 8D D4 00
  STA $00DC                             ; $C5A0: 8D DC 00
  INC $04A9                             ; $C5A3: EE A9 04
  LDA $04AA                             ; $C5A6: AD AA 04
  EOR #$01                              ; $C5A9: 49 01
  TAY                                   ; $C5AB: A8
  LDA $04AF,Y                           ; $C5AC: B9 AF 04
  STA $0001                             ; $C5AF: 8D 01 00
  CPY #$01                              ; $C5B2: C0 01
  BEQ $C5C4                             ; $C5B4: F0 0E
  LDA #$43                              ; $C5B6: A9 43
  STA $0000                             ; $C5B8: 8D 00 00
  LDA #$0D                              ; $C5BB: A9 0D
  CLC                                   ; $C5BD: 18
  ADC $0001                             ; $C5BE: 6D 01 00
  JMP $CDFD                             ; $C5C1: 4C FD CD
Loc_C5C4:
  LDA #$55                              ; $C5C4: A9 55
  STA $0000                             ; $C5C6: 8D 00 00
  LDA #$10                              ; $C5C9: A9 10
  CLC                                   ; $C5CB: 18
  ADC $0001                             ; $C5CC: 6D 01 00
  JMP $CDFD                             ; $C5CF: 4C FD CD
Loc_C5D2:  ; (dispatch callback target)
  LDA $04B8                             ; $C5D2: AD B8 04
  LSR                                   ; $C5D5: 4A
  LSR                                   ; $C5D6: 4A
  LSR                                   ; $C5D7: 4A
  LSR                                   ; $C5D8: 4A
  AND #$01                              ; $C5D9: 29 01
  STA $0012                             ; $C5DB: 8D 12 00
  INC $04B8                             ; $C5DE: EE B8 04
  LDA $04B8                             ; $C5E1: AD B8 04
  LSR                                   ; $C5E4: 4A
  LSR                                   ; $C5E5: 4A
  LSR                                   ; $C5E6: 4A
  LSR                                   ; $C5E7: 4A
  AND #$07                              ; $C5E8: 29 07
  CMP #$05                              ; $C5EA: C9 05
  BNE $C622                             ; $C5EC: D0 34
  INC $04A9                             ; $C5EE: EE A9 04
  LDA #$4B                              ; $C5F1: A9 4B
  STA $0000                             ; $C5F3: 8D 00 00
  LDA $04AA                             ; $C5F6: AD AA 04
  BNE $C600                             ; $C5F9: D0 05
  LDA #$4D                              ; $C5FB: A9 4D
  STA $0000                             ; $C5FD: 8D 00 00
Loc_C600:
  LDA #$00                              ; $C600: A9 00
  JSR $CDFD                             ; $C602: 20 FD CD
  LDA #$02                              ; $C605: A9 02
  STA $03B7                             ; $C607: 8D B7 03
  LDA #$23                              ; $C60A: A9 23
  STA $03B8                             ; $C60C: 8D B8 03
  LDA #$DB                              ; $C60F: A9 DB
  STA $03B9                             ; $C611: 8D B9 03
  LDA #$00                              ; $C614: A9 00
  STA $03BA                             ; $C616: 8D BA 03
  STA $03BB                             ; $C619: 8D BB 03
  LDA #$FF                              ; $C61C: A9 FF
  STA $03BC                             ; $C61E: 8D BC 03
  RTS                                   ; $C621: 60
Loc_C622:
  AND #$01                              ; $C622: 29 01
  STA $0010                             ; $C624: 8D 10 00
  STA $0011                             ; $C627: 8D 11 00
  BNE $C636                             ; $C62A: D0 0A
  CMP $0012                             ; $C62C: CD 12 00
  BEQ $C636                             ; $C62F: F0 05
  LDA #$62                              ; $C631: A9 62
  JSR $E693                             ; $C633: 20 93 E6
Loc_C636:
  LDA $04AA                             ; $C636: AD AA 04
  BEQ $C644                             ; $C639: F0 09
  LDA $0010                             ; $C63B: AD 10 00
  CLC                                   ; $C63E: 18
  ADC #$06                              ; $C63F: 69 06
  STA $0010                             ; $C641: 8D 10 00
Loc_C644:
  LDA $04AA                             ; $C644: AD AA 04
  CLC                                   ; $C647: 18
  ADC #$01                              ; $C648: 69 01
  STA $0002                             ; $C64A: 8D 02 00
  LDY $04AA                             ; $C64D: AC AA 04
  LDA $04AF,Y                           ; $C650: B9 AF 04
  ASL                                   ; $C653: 0A
  CLC                                   ; $C654: 18
  ADC $0010                             ; $C655: 6D 10 00
  ADC #$5E                              ; $C658: 69 5E
  JSR $CEA5                             ; $C65A: 20 A5 CE
  LDA $0011                             ; $C65D: AD 11 00
  BNE $C66A                             ; $C660: D0 08
  LDA #$76                              ; $C662: A9 76
  STA $0010                             ; $C664: 8D 10 00
  JMP $D235                             ; $C667: 4C 35 D2
Loc_C66A:
  RTS                                   ; $C66A: 60
Loc_C66B:  ; (dispatch callback target)
  LDA #$13                              ; $C66B: A9 13
  STA $04A8                             ; $C66D: 8D A8 04
  LDA #$00                              ; $C670: A9 00
  STA $04A9                             ; $C672: 8D A9 04
  LDA #$ED                              ; $C675: A9 ED
  STA $0000                             ; $C677: 8D 00 00
  LDY $04AA                             ; $C67A: AC AA 04
  BEQ $C684                             ; $C67D: F0 05
  LDA #$EB                              ; $C67F: A9 EB
  STA $0000                             ; $C681: 8D 00 00
Loc_C684:
  LDA #$00                              ; $C684: A9 00
  JMP $CDFD                             ; $C686: 4C FD CD
Loc_C689:  ; (dispatch callback target)
  LDA $04A9                             ; $C689: AD A9 04
  JSR $EADE                             ; $C68C: 20 DE EA
; --- Data Region ---
  .byte $9F,$C6,$B6,$C6,$DC,$C6,$2D,$C7,$73,$C7,$09,$C8,$4A,$C8,$84,$C8; $C68F: 9F C6 B6 C6 DC C6 2D C7 73 C7 09 C8 4A C8 84 C8
  .byte $EE,$A9,$04,$A9,$43,$8D,$00,$00,$AD,$AA,$04,$F0,$05,$A9,$55,$8D; $C69F: EE A9 04 A9 43 8D 00 00 AD AA 04 F0 05 A9 55 8D
  .byte $00,$00                           ; $C6AF: 00 00
Loc_C6B1:
; --- Code Region ---
  LDA #$00                              ; $C6B1: A9 00
  JMP $CDFD                             ; $C6B3: 4C FD CD
Loc_C6B6:  ; (dispatch callback target)
  LDA #$00                              ; $C6B6: A9 00
  STA $04B8                             ; $C6B8: 8D B8 04
  INC $04A9                             ; $C6BB: EE A9 04
  LDA #$18                              ; $C6BE: A9 18
  STA $04BB                             ; $C6C0: 8D BB 04
  LDA #$E3                              ; $C6C3: A9 E3
  STA $0000                             ; $C6C5: 8D 00 00
  LDA $04AA                             ; $C6C8: AD AA 04
  BEQ $C6D7                             ; $C6CB: F0 0A
  LDA #$A8                              ; $C6CD: A9 A8
  STA $04BB                             ; $C6CF: 8D BB 04
  LDA #$F5                              ; $C6D2: A9 F5
  STA $0000                             ; $C6D4: 8D 00 00
Loc_C6D7:
  LDA #$00                              ; $C6D7: A9 00
  JMP $CDFD                             ; $C6D9: 4C FD CD
Loc_C6DC:  ; (dispatch callback target)
  LDA $04AA                             ; $C6DC: AD AA 04
  BEQ $C6EB                             ; $C6DF: F0 0A
  LDA $04BB                             ; $C6E1: AD BB 04
  CMP #$58                              ; $C6E4: C9 58
  BNE $C719                             ; $C6E6: D0 31
  JMP $C6F2                             ; $C6E8: 4C F2 C6
Loc_C6EB:
  LDA $04BB                             ; $C6EB: AD BB 04
  CMP #$68                              ; $C6EE: C9 68
  BNE $C719                             ; $C6F0: D0 27
Loc_C6F2:
  LDA #$8F                              ; $C6F2: A9 8F
  STA $00CC                             ; $C6F4: 8D CC 00
  STA $00D4                             ; $C6F7: 8D D4 00
  STA $00DC                             ; $C6FA: 8D DC 00
  INC $04A9                             ; $C6FD: EE A9 04
  LDA $04AA                             ; $C700: AD AA 04
  BEQ $C70F                             ; $C703: F0 0A
  LDA #$4B                              ; $C705: A9 4B
  STA $0000                             ; $C707: 8D 00 00
  LDA #$0B                              ; $C70A: A9 0B
  JMP $CDFD                             ; $C70C: 4C FD CD
Loc_C70F:
  LDA #$4D                              ; $C70F: A9 4D
  STA $0000                             ; $C711: 8D 00 00
  LDA #$09                              ; $C714: A9 09
  JMP $CDFD                             ; $C716: 4C FD CD
Loc_C719:
  LDA $04AA                             ; $C719: AD AA 04
  STA $0011                             ; $C71C: 8D 11 00
  BEQ $C727                             ; $C71F: F0 06
  DEC $04BB                             ; $C721: CE BB 04
  JMP $CEE1                             ; $C724: 4C E1 CE
Loc_C727:
  INC $04BB                             ; $C727: EE BB 04
  JMP $CEE1                             ; $C72A: 4C E1 CE
Loc_C72D:  ; (dispatch callback target)
  LDA #$83                              ; $C72D: A9 83
  STA $00C9                             ; $C72F: 8D C9 00
  STA $00D1                             ; $C732: 8D D1 00
  STA $00D9                             ; $C735: 8D D9 00
  LDY $04AA                             ; $C738: AC AA 04
  LDA $04AF,Y                           ; $C73B: B9 AF 04
  BEQ $C74B                             ; $C73E: F0 0B
  LDA #$84                              ; $C740: A9 84
  STA $00C6                             ; $C742: 8D C6 00
  STA $00CE                             ; $C745: 8D CE 00
  STA $00D6                             ; $C748: 8D D6 00
Loc_C74B:
  LDA #$FF                              ; $C74B: A9 FF
  STA $04B8                             ; $C74D: 8D B8 04
  LDA #$00                              ; $C750: A9 00
  STA $04B9                             ; $C752: 8D B9 04
  LDA #$4F                              ; $C755: A9 4F
  STA $04BA                             ; $C757: 8D BA 04
  INC $04A9                             ; $C75A: EE A9 04
  LDA #$ED                              ; $C75D: A9 ED
  STA $0000                             ; $C75F: 8D 00 00
  LDA #$0A                              ; $C762: A9 0A
  LDY $04AA                             ; $C764: AC AA 04
  BEQ $C770                             ; $C767: F0 07
  LDA #$EB                              ; $C769: A9 EB
  STA $0000                             ; $C76B: 8D 00 00
  LDA #$0C                              ; $C76E: A9 0C
Loc_C770:
  JMP $CDFD                             ; $C770: 4C FD CD
Loc_C773:  ; (dispatch callback target)
  LDA $04B8                             ; $C773: AD B8 04
  LSR                                   ; $C776: 4A
  LSR                                   ; $C777: 4A
  LSR                                   ; $C778: 4A
  AND #$03                              ; $C779: 29 03
  STA $0012                             ; $C77B: 8D 12 00
  INC $04B8                             ; $C77E: EE B8 04
  LDA $04B8                             ; $C781: AD B8 04
  LSR                                   ; $C784: 4A
  LSR                                   ; $C785: 4A
  LSR                                   ; $C786: 4A
  AND #$03                              ; $C787: 29 03
  CMP #$03                              ; $C789: C9 03
  BNE $C7B3                             ; $C78B: D0 26
  LDA #$00                              ; $C78D: A9 00
  STA $04B8                             ; $C78F: 8D B8 04
  INC $04B9                             ; $C792: EE B9 04
  LDY $04B9                             ; $C795: AC B9 04
  CPY #$03                              ; $C798: C0 03
  BNE $C7B3                             ; $C79A: D0 17
  INC $04A9                             ; $C79C: EE A9 04
  LDA #$4B                              ; $C79F: A9 4B
  STA $0000                             ; $C7A1: 8D 00 00
  LDA $04AA                             ; $C7A4: AD AA 04
  BNE $C7AE                             ; $C7A7: D0 05
  LDA #$4D                              ; $C7A9: A9 4D
  STA $0000                             ; $C7AB: 8D 00 00
Loc_C7AE:
  LDA #$00                              ; $C7AE: A9 00
  JMP $CDFD                             ; $C7B0: 4C FD CD
Loc_C7B3:
  STA $0010                             ; $C7B3: 8D 10 00
  CMP #$01                              ; $C7B6: C9 01
  BNE $C7C4                             ; $C7B8: D0 0A
  CMP $0012                             ; $C7BA: CD 12 00
  BEQ $C7C4                             ; $C7BD: F0 05
  LDA #$61                              ; $C7BF: A9 61
  JSR $E609                             ; $C7C1: 20 09 E6
Loc_C7C4:
  LDA $04AA                             ; $C7C4: AD AA 04
  BNE $C7D2                             ; $C7C7: D0 09
  LDA $0010                             ; $C7C9: AD 10 00
  CLC                                   ; $C7CC: 18
  ADC #$0F                              ; $C7CD: 69 0F
  STA $0010                             ; $C7CF: 8D 10 00
Loc_C7D2:
  LDA #$00                              ; $C7D2: A9 00
  STA $0002                             ; $C7D4: 8D 02 00
  LDA $0010                             ; $C7D7: AD 10 00
  CLC                                   ; $C7DA: 18
  ADC #$22                              ; $C7DB: 69 22
  JSR $CEA5                             ; $C7DD: 20 A5 CE
  LDA $04AA                             ; $C7E0: AD AA 04
  CLC                                   ; $C7E3: 18
  ADC #$01                              ; $C7E4: 69 01
  STA $0002                             ; $C7E6: 8D 02 00
  LDA $0010                             ; $C7E9: AD 10 00
  CLC                                   ; $C7EC: 18
  ADC #$25                              ; $C7ED: 69 25
  JSR $CEA5                             ; $C7EF: 20 A5 CE
  LDY $04AA                             ; $C7F2: AC AA 04
  LDA $04AF,Y                           ; $C7F5: B9 AF 04
  STA $0011                             ; $C7F8: 8D 11 00
  ASL                                   ; $C7FB: 0A
  CLC                                   ; $C7FC: 18
  ADC $0011                             ; $C7FD: 6D 11 00
  CLC                                   ; $C800: 18
  ADC $0010                             ; $C801: 6D 10 00
  ADC #$28                              ; $C804: 69 28
  JMP $CEA5                             ; $C806: 4C A5 CE
Loc_C809:  ; (dispatch callback target)
  LDA #$00                              ; $C809: A9 00
  STA $04B8                             ; $C80B: 8D B8 04
  LDA #$57                              ; $C80E: A9 57
  STA $04BA                             ; $C810: 8D BA 04
  LDA #$80                              ; $C813: A9 80
  STA $00C6                             ; $C815: 8D C6 00
  STA $00CE                             ; $C818: 8D CE 00
  STA $00D6                             ; $C81B: 8D D6 00
  LDY $04AA                             ; $C81E: AC AA 04
  LDA $04AF,Y                           ; $C821: B9 AF 04
  CMP #$01                              ; $C824: C9 01
  BNE $C833                             ; $C826: D0 0B
  LDA #$96                              ; $C828: A9 96
  STA $00C9                             ; $C82A: 8D C9 00
  STA $00D1                             ; $C82D: 8D D1 00
  STA $00D9                             ; $C830: 8D D9 00
Loc_C833:
  INC $04A9                             ; $C833: EE A9 04
  LDA #$EB                              ; $C836: A9 EB
  STA $0000                             ; $C838: 8D 00 00
  LDA $04AA                             ; $C83B: AD AA 04
  BNE $C845                             ; $C83E: D0 05
  LDA #$ED                              ; $C840: A9 ED
  STA $0000                             ; $C842: 8D 00 00
Loc_C845:
  LDA #$00                              ; $C845: A9 00
  JMP $CDFD                             ; $C847: 4C FD CD
Loc_C84A:  ; (dispatch callback target)
  LDA #$90                              ; $C84A: A9 90
  STA $00CC                             ; $C84C: 8D CC 00
  STA $00D4                             ; $C84F: 8D D4 00
  STA $00DC                             ; $C852: 8D DC 00
  INC $04A9                             ; $C855: EE A9 04
  LDA $04AA                             ; $C858: AD AA 04
  EOR #$01                              ; $C85B: 49 01
  TAY                                   ; $C85D: A8
  LDA $04AF,Y                           ; $C85E: B9 AF 04
  STA $0001                             ; $C861: 8D 01 00
  CPY #$01                              ; $C864: C0 01
  BEQ $C876                             ; $C866: F0 0E
  LDA #$43                              ; $C868: A9 43
  STA $0000                             ; $C86A: 8D 00 00
  LDA #$0D                              ; $C86D: A9 0D
  CLC                                   ; $C86F: 18
  ADC $0001                             ; $C870: 6D 01 00
  JMP $CDFD                             ; $C873: 4C FD CD
Loc_C876:
  LDA #$55                              ; $C876: A9 55
  STA $0000                             ; $C878: 8D 00 00
  LDA #$10                              ; $C87B: A9 10
  CLC                                   ; $C87D: 18
  ADC $0001                             ; $C87E: 6D 01 00
  JMP $CDFD                             ; $C881: 4C FD CD
Loc_C884:  ; (dispatch callback target)
  LDA $04B8                             ; $C884: AD B8 04
  LSR                                   ; $C887: 4A
  LSR                                   ; $C888: 4A
  LSR                                   ; $C889: 4A
  AND #$07                              ; $C88A: 29 07
  STA $0012                             ; $C88C: 8D 12 00
  INC $04B8                             ; $C88F: EE B8 04
  LDA $04B8                             ; $C892: AD B8 04
  LSR                                   ; $C895: 4A
  LSR                                   ; $C896: 4A
  LSR                                   ; $C897: 4A
  AND #$07                              ; $C898: 29 07
  CMP #$03                              ; $C89A: C9 03
  BCC $C8AF                             ; $C89C: 90 11
  CMP #$05                              ; $C89E: C9 05
  BCC $C8AD                             ; $C8A0: 90 0B
  LDA #$13                              ; $C8A2: A9 13
  STA $04A8                             ; $C8A4: 8D A8 04
  LDA #$00                              ; $C8A7: A9 00
  STA $04A9                             ; $C8A9: 8D A9 04
  RTS                                   ; $C8AC: 60
Loc_C8AD:
  LDA #$02                              ; $C8AD: A9 02
Loc_C8AF:
  STA $0010                             ; $C8AF: 8D 10 00
  STA $0011                             ; $C8B2: 8D 11 00
  CMP #$01                              ; $C8B5: C9 01
  BNE $C8C3                             ; $C8B7: D0 0A
  CMP $0012                             ; $C8B9: CD 12 00
  BEQ $C8C3                             ; $C8BC: F0 05
  LDA #$69                              ; $C8BE: A9 69
  JSR $E609                             ; $C8C0: 20 09 E6
Loc_C8C3:
  LDA $04AA                             ; $C8C3: AD AA 04
  BNE $C8D1                             ; $C8C6: D0 09
  LDA $0010                             ; $C8C8: AD 10 00
  CLC                                   ; $C8CB: 18
  ADC #$0F                              ; $C8CC: 69 0F
  STA $0010                             ; $C8CE: 8D 10 00
Loc_C8D1:
  LDA #$00                              ; $C8D1: A9 00
  STA $0002                             ; $C8D3: 8D 02 00
  LDA #$40                              ; $C8D6: A9 40
  STA $0001                             ; $C8D8: 8D 01 00
  LDY $04AA                             ; $C8DB: AC AA 04
  LDA $04AF,Y                           ; $C8DE: B9 AF 04
  CMP #$01                              ; $C8E1: C9 01
  BNE $C8EA                             ; $C8E3: D0 05
  LDA #$4C                              ; $C8E5: A9 4C
  STA $0001                             ; $C8E7: 8D 01 00
Loc_C8EA:
  LDA $0010                             ; $C8EA: AD 10 00
  CLC                                   ; $C8ED: 18
  ADC $0001                             ; $C8EE: 6D 01 00
  JSR $CEA5                             ; $C8F1: 20 A5 CE
  LDA $04AA                             ; $C8F4: AD AA 04
  CLC                                   ; $C8F7: 18
  ADC #$01                              ; $C8F8: 69 01
  STA $0002                             ; $C8FA: 8D 02 00
  LDY $04AA                             ; $C8FD: AC AA 04
  LDA $04AF,Y                           ; $C900: B9 AF 04
  STA $0001                             ; $C903: 8D 01 00
  ASL                                   ; $C906: 0A
  CLC                                   ; $C907: 18
  ADC $0001                             ; $C908: 6D 01 00
  CLC                                   ; $C90B: 18
  ADC $0010                             ; $C90C: 6D 10 00
  ADC #$43                              ; $C90F: 69 43
  JSR $CEA5                             ; $C911: 20 A5 CE
  LDY $04AA                             ; $C914: AC AA 04
  LDA $04AF,Y                           ; $C917: B9 AF 04
  CMP #$01                              ; $C91A: C9 01
  BEQ $C930                             ; $C91C: F0 12
  LDA $04B8                             ; $C91E: AD B8 04
  CMP #$11                              ; $C921: C9 11
  BNE $C930                             ; $C923: D0 0B
  LDA #$84                              ; $C925: A9 84
  STA $00C9                             ; $C927: 8D C9 00
  STA $00D1                             ; $C92A: 8D D1 00
  STA $00D9                             ; $C92D: 8D D9 00
Loc_C930:
  LDA $0011                             ; $C930: AD 11 00
  CMP #$02                              ; $C933: C9 02
  BNE $C948                             ; $C935: D0 11
  LDY $04AA                             ; $C937: AC AA 04
  LDA $04AF,Y                           ; $C93A: B9 AF 04
  AND #$01                              ; $C93D: 29 01
  CLC                                   ; $C93F: 18
  ADC #$77                              ; $C940: 69 77
  STA $0010                             ; $C942: 8D 10 00
  JMP $D235                             ; $C945: 4C 35 D2
Loc_C948:
  RTS                                   ; $C948: 60
Loc_C949:  ; (dispatch callback target)
  LDA $04A9                             ; $C949: AD A9 04
  JSR $EADE                             ; $C94C: 20 DE EA
; --- Data Region ---
  .byte $5F,$C9,$76,$C9,$9C,$C9,$ED,$C9,$50,$CA,$B8,$CA,$D4,$CA,$0E,$CB; $C94F: 5F C9 76 C9 9C C9 ED C9 50 CA B8 CA D4 CA 0E CB
  .byte $EE,$A9,$04,$A9,$55,$8D,$00,$00,$AD,$AA,$04,$D0,$05,$A9,$43,$8D; $C95F: EE A9 04 A9 55 8D 00 00 AD AA 04 D0 05 A9 43 8D
  .byte $00,$00                           ; $C96F: 00 00
Loc_C971:
; --- Code Region ---
  LDA #$00                              ; $C971: A9 00
  JMP $CDFD                             ; $C973: 4C FD CD
Loc_C976:  ; (dispatch callback target)
  LDA #$00                              ; $C976: A9 00
  STA $04B8                             ; $C978: 8D B8 04
  INC $04A9                             ; $C97B: EE A9 04
  LDA #$A8                              ; $C97E: A9 A8
  STA $04BB                             ; $C980: 8D BB 04
  LDA #$F5                              ; $C983: A9 F5
  STA $0000                             ; $C985: 8D 00 00
  LDA $04AA                             ; $C988: AD AA 04
  BNE $C997                             ; $C98B: D0 0A
  LDA #$18                              ; $C98D: A9 18
  STA $04BB                             ; $C98F: 8D BB 04
  LDA #$E3                              ; $C992: A9 E3
  STA $0000                             ; $C994: 8D 00 00
Loc_C997:
  LDA #$00                              ; $C997: A9 00
  JMP $CDFD                             ; $C999: 4C FD CD
Loc_C99C:  ; (dispatch callback target)
  LDA $04AA                             ; $C99C: AD AA 04
  BEQ $C9AB                             ; $C99F: F0 0A
  LDA $04BB                             ; $C9A1: AD BB 04
  CMP #$58                              ; $C9A4: C9 58
  BNE $C9D9                             ; $C9A6: D0 31
  JMP $C9B2                             ; $C9A8: 4C B2 C9
Loc_C9AB:
  LDA $04BB                             ; $C9AB: AD BB 04
  CMP #$68                              ; $C9AE: C9 68
  BNE $C9D9                             ; $C9B0: D0 27
Loc_C9B2:
  LDA #$8F                              ; $C9B2: A9 8F
  STA $00CC                             ; $C9B4: 8D CC 00
  STA $00D4                             ; $C9B7: 8D D4 00
  STA $00DC                             ; $C9BA: 8D DC 00
  INC $04A9                             ; $C9BD: EE A9 04
  LDA $04AA                             ; $C9C0: AD AA 04
  BEQ $C9CF                             ; $C9C3: F0 0A
  LDA #$4B                              ; $C9C5: A9 4B
  STA $0000                             ; $C9C7: 8D 00 00
  LDA #$0B                              ; $C9CA: A9 0B
  JMP $CDFD                             ; $C9CC: 4C FD CD
Loc_C9CF:
  LDA #$4D                              ; $C9CF: A9 4D
  STA $0000                             ; $C9D1: 8D 00 00
  LDA #$09                              ; $C9D4: A9 09
  JMP $CDFD                             ; $C9D6: 4C FD CD
Loc_C9D9:
  LDA $04AA                             ; $C9D9: AD AA 04
  STA $0011                             ; $C9DC: 8D 11 00
  BEQ $C9E7                             ; $C9DF: F0 06
  DEC $04BB                             ; $C9E1: CE BB 04
  JMP $CEE1                             ; $C9E4: 4C E1 CE
Loc_C9E7:
  INC $04BB                             ; $C9E7: EE BB 04
  JMP $CEE1                             ; $C9EA: 4C E1 CE
Loc_C9ED:  ; (dispatch callback target)
  LDA #$3F                              ; $C9ED: A9 3F
  STA $04BA                             ; $C9EF: 8D BA 04
  LDA #$86                              ; $C9F2: A9 86
  STA $00BE                             ; $C9F4: 8D BE 00
  STA $00C6                             ; $C9F7: 8D C6 00
  STA $00CE                             ; $C9FA: 8D CE 00
  STA $00D6                             ; $C9FD: 8D D6 00
  LDA #$87                              ; $CA00: A9 87
  STA $00BF                             ; $CA02: 8D BF 00
  STA $00C7                             ; $CA05: 8D C7 00
  STA $00CF                             ; $CA08: 8D CF 00
  STA $00D7                             ; $CA0B: 8D D7 00
  LDA #$93                              ; $CA0E: A9 93
  STA $00C0                             ; $CA10: 8D C0 00
  STA $00C8                             ; $CA13: 8D C8 00
  STA $00D0                             ; $CA16: 8D D0 00
  STA $00D8                             ; $CA19: 8D D8 00
  LDA #$94                              ; $CA1C: A9 94
  STA $00C1                             ; $CA1E: 8D C1 00
  STA $00C9                             ; $CA21: 8D C9 00
  STA $00D1                             ; $CA24: 8D D1 00
  STA $00D9                             ; $CA27: 8D D9 00
  LDA #$00                              ; $CA2A: A9 00
  STA $04B8                             ; $CA2C: 8D B8 04
  STA $04B9                             ; $CA2F: 8D B9 04
  INC $04A9                             ; $CA32: EE A9 04
  LDA #$61                              ; $CA35: A9 61
  JSR $E609                             ; $CA37: 20 09 E6
  LDA #$ED                              ; $CA3A: A9 ED
  STA $0000                             ; $CA3C: 8D 00 00
  LDA #$0A                              ; $CA3F: A9 0A
  LDY $04AA                             ; $CA41: AC AA 04
  BEQ $CA4D                             ; $CA44: F0 07
  LDA #$EB                              ; $CA46: A9 EB
  STA $0000                             ; $CA48: 8D 00 00
  LDA #$0C                              ; $CA4B: A9 0C
Loc_CA4D:
  JMP $CDFD                             ; $CA4D: 4C FD CD
Loc_CA50:  ; (dispatch callback target)
  INC $04B8                             ; $CA50: EE B8 04
  LDA $04B8                             ; $CA53: AD B8 04
  LSR                                   ; $CA56: 4A
  LSR                                   ; $CA57: 4A
  LSR                                   ; $CA58: 4A
  LSR                                   ; $CA59: 4A
  AND #$01                              ; $CA5A: 29 01
  BEQ $CA7A                             ; $CA5C: F0 1C
  LDA #$00                              ; $CA5E: A9 00
  STA $04B8                             ; $CA60: 8D B8 04
  INC $04A9                             ; $CA63: EE A9 04
  LDA #$4B                              ; $CA66: A9 4B
  STA $0000                             ; $CA68: 8D 00 00
  LDA $04AA                             ; $CA6B: AD AA 04
  BNE $CA75                             ; $CA6E: D0 05
  LDA #$4D                              ; $CA70: A9 4D
  STA $0000                             ; $CA72: 8D 00 00
Loc_CA75:
  LDA #$00                              ; $CA75: A9 00
  JMP $CDFD                             ; $CA77: 4C FD CD
Loc_CA7A:
  STA $0010                             ; $CA7A: 8D 10 00
  LDA $04AA                             ; $CA7D: AD AA 04
  BNE $CA8B                             ; $CA80: D0 09
  LDA $0010                             ; $CA82: AD 10 00
  CLC                                   ; $CA85: 18
  ADC #$14                              ; $CA86: 69 14
  STA $0010                             ; $CA88: 8D 10 00
Loc_CA8B:
  LDA #$00                              ; $CA8B: A9 00
  STA $0002                             ; $CA8D: 8D 02 00
  LDA $0010                             ; $CA90: AD 10 00
  CLC                                   ; $CA93: 18
  ADC #$80                              ; $CA94: 69 80
  JSR $CEA5                             ; $CA96: 20 A5 CE
  LDY $04AA                             ; $CA99: AC AA 04
  TYA                                   ; $CA9C: 98
  CLC                                   ; $CA9D: 18
  ADC #$01                              ; $CA9E: 69 01
  STA $0002                             ; $CAA0: 8D 02 00
  LDA $04AF,Y                           ; $CAA3: B9 AF 04
  STA $0001                             ; $CAA6: 8D 01 00
  ASL                                   ; $CAA9: 0A
  ASL                                   ; $CAAA: 0A
  CLC                                   ; $CAAB: 18
  ADC $0001                             ; $CAAC: 6D 01 00
  CLC                                   ; $CAAF: 18
  ADC $0010                             ; $CAB0: 6D 10 00
  ADC #$85                              ; $CAB3: 69 85
  JMP $CEA5                             ; $CAB5: 4C A5 CE
Loc_CAB8:  ; (dispatch callback target)
  LDA #$00                              ; $CAB8: A9 00
  STA $04B8                             ; $CABA: 8D B8 04
  INC $04A9                             ; $CABD: EE A9 04
  LDA #$EB                              ; $CAC0: A9 EB
  STA $0000                             ; $CAC2: 8D 00 00
  LDA $04AA                             ; $CAC5: AD AA 04
  BNE $CACF                             ; $CAC8: D0 05
  LDA #$ED                              ; $CACA: A9 ED
  STA $0000                             ; $CACC: 8D 00 00
Loc_CACF:
  LDA #$00                              ; $CACF: A9 00
  JMP $CDFD                             ; $CAD1: 4C FD CD
Loc_CAD4:  ; (dispatch callback target)
  LDA #$90                              ; $CAD4: A9 90
  STA $00CC                             ; $CAD6: 8D CC 00
  STA $00D4                             ; $CAD9: 8D D4 00
  STA $00DC                             ; $CADC: 8D DC 00
  INC $04A9                             ; $CADF: EE A9 04
  LDA $04AA                             ; $CAE2: AD AA 04
  EOR #$01                              ; $CAE5: 49 01
  TAY                                   ; $CAE7: A8
  LDA $04AF,Y                           ; $CAE8: B9 AF 04
  STA $0001                             ; $CAEB: 8D 01 00
  CPY #$01                              ; $CAEE: C0 01
  BEQ $CB00                             ; $CAF0: F0 0E
  LDA #$43                              ; $CAF2: A9 43
  STA $0000                             ; $CAF4: 8D 00 00
  LDA #$0D                              ; $CAF7: A9 0D
  CLC                                   ; $CAF9: 18
  ADC $0001                             ; $CAFA: 6D 01 00
  JMP $CDFD                             ; $CAFD: 4C FD CD
Loc_CB00:
  LDA #$55                              ; $CB00: A9 55
  STA $0000                             ; $CB02: 8D 00 00
  LDA #$10                              ; $CB05: A9 10
  CLC                                   ; $CB07: 18
  ADC $0001                             ; $CB08: 6D 01 00
  JMP $CDFD                             ; $CB0B: 4C FD CD
Loc_CB0E:  ; (dispatch callback target)
  LDA $04B8                             ; $CB0E: AD B8 04
  LSR                                   ; $CB11: 4A
  LSR                                   ; $CB12: 4A
  LSR                                   ; $CB13: 4A
  LSR                                   ; $CB14: 4A
  AND #$07                              ; $CB15: 29 07
  STA $0012                             ; $CB17: 8D 12 00
  INC $04B8                             ; $CB1A: EE B8 04
  LDA $04B8                             ; $CB1D: AD B8 04
  LSR                                   ; $CB20: 4A
  LSR                                   ; $CB21: 4A
  LSR                                   ; $CB22: 4A
  LSR                                   ; $CB23: 4A
  AND #$07                              ; $CB24: 29 07
  CMP #$06                              ; $CB26: C9 06
  BNE $CB35                             ; $CB28: D0 0B
  LDA #$13                              ; $CB2A: A9 13
  STA $04A8                             ; $CB2C: 8D A8 04
  LDA #$00                              ; $CB2F: A9 00
  STA $04A9                             ; $CB31: 8D A9 04
  RTS                                   ; $CB34: 60
Loc_CB35:
  CMP #$03                              ; $CB35: C9 03
  BNE $CB45                             ; $CB37: D0 0C
  CMP $0012                             ; $CB39: CD 12 00
  BEQ $CB45                             ; $CB3C: F0 07
  LDA #$68                              ; $CB3E: A9 68
  JSR $E609                             ; $CB40: 20 09 E6
  LDA #$03                              ; $CB43: A9 03
Loc_CB45:
  CMP #$04                              ; $CB45: C9 04
  BCC $CB4B                             ; $CB47: 90 02
  LDA #$03                              ; $CB49: A9 03
Loc_CB4B:
  STA $0010                             ; $CB4B: 8D 10 00
  STA $0011                             ; $CB4E: 8D 11 00
  LDA $04AA                             ; $CB51: AD AA 04
  BNE $CB5F                             ; $CB54: D0 09
  LDA $0010                             ; $CB56: AD 10 00
  CLC                                   ; $CB59: 18
  ADC #$14                              ; $CB5A: 69 14
  STA $0010                             ; $CB5C: 8D 10 00
Loc_CB5F:
  LDA $04AA                             ; $CB5F: AD AA 04
  CLC                                   ; $CB62: 18
  ADC #$01                              ; $CB63: 69 01
  STA $0002                             ; $CB65: 8D 02 00
  LDY $04AA                             ; $CB68: AC AA 04
  LDA $04AF,Y                           ; $CB6B: B9 AF 04
  STA $0001                             ; $CB6E: 8D 01 00
  ASL                                   ; $CB71: 0A
  ASL                                   ; $CB72: 0A
  CLC                                   ; $CB73: 18
  ADC $0001                             ; $CB74: 6D 01 00
  CLC                                   ; $CB77: 18
  ADC $0010                             ; $CB78: 6D 10 00
  ADC #$86                              ; $CB7B: 69 86
  JSR $CEA5                             ; $CB7D: 20 A5 CE
  LDA #$00                              ; $CB80: A9 00
  STA $0002                             ; $CB82: 8D 02 00
  LDA $0010                             ; $CB85: AD 10 00
  CLC                                   ; $CB88: 18
  ADC #$81                              ; $CB89: 69 81
  JSR $CEA5                             ; $CB8B: 20 A5 CE
  LDA $0011                             ; $CB8E: AD 11 00
  CMP #$03                              ; $CB91: C9 03
  BNE $CB9D                             ; $CB93: D0 08
  LDA #$79                              ; $CB95: A9 79
  STA $0010                             ; $CB97: 8D 10 00
  JMP $D235                             ; $CB9A: 4C 35 D2
Loc_CB9D:
  RTS                                   ; $CB9D: 60
Loc_CB9E:  ; (dispatch callback target)
  LDA $04A9                             ; $CB9E: AD A9 04
  JSR $EADE                             ; $CBA1: 20 DE EA
; --- Data Region ---
  .byte $AA,$CB,$0A,$CC,$62,$CC           ; $CBA4: AA CB 0A CC 62 CC
Loc_CBAA:  ; (dispatch callback target)
; --- Code Region ---
  LDA #$80                              ; $CBAA: A9 80
  STA $00C6                             ; $CBAC: 8D C6 00
  STA $00CE                             ; $CBAF: 8D CE 00
  STA $00D6                             ; $CBB2: 8D D6 00
  LDA #$81                              ; $CBB5: A9 81
  STA $00C7                             ; $CBB7: 8D C7 00
  STA $00CF                             ; $CBBA: 8D CF 00
  STA $00D7                             ; $CBBD: 8D D7 00
  LDA #$82                              ; $CBC0: A9 82
  STA $00C8                             ; $CBC2: 8D C8 00
  STA $00D0                             ; $CBC5: 8D D0 00
  STA $00D8                             ; $CBC8: 8D D8 00
  LDA #$85                              ; $CBCB: A9 85
  STA $00C9                             ; $CBCD: 8D C9 00
  STA $00D1                             ; $CBD0: 8D D1 00
  STA $00D9                             ; $CBD3: 8D D9 00
  LDA #$00                              ; $CBD6: A9 00
  STA $04B8                             ; $CBD8: 8D B8 04
  INC $04A9                             ; $CBDB: EE A9 04
  LDA $04AA                             ; $CBDE: AD AA 04
  EOR #$01                              ; $CBE1: 49 01
  TAY                                   ; $CBE3: A8
  LDA $04AF,Y                           ; $CBE4: B9 AF 04
  STA $0001                             ; $CBE7: 8D 01 00
  CPY #$01                              ; $CBEA: C0 01
  BEQ $CBFC                             ; $CBEC: F0 0E
  LDA #$43                              ; $CBEE: A9 43
  STA $0000                             ; $CBF0: 8D 00 00
  LDA #$01                              ; $CBF3: A9 01
  CLC                                   ; $CBF5: 18
  ADC $0001                             ; $CBF6: 6D 01 00
  JMP $CDFD                             ; $CBF9: 4C FD CD
Loc_CBFC:
  LDA #$55                              ; $CBFC: A9 55
  STA $0000                             ; $CBFE: 8D 00 00
  LDA #$05                              ; $CC01: A9 05
  CLC                                   ; $CC03: 18
  ADC $0001                             ; $CC04: 6D 01 00
  JMP $CDFD                             ; $CC07: 4C FD CD
Loc_CC0A:  ; (dispatch callback target)
  LDA $04AA                             ; $CC0A: AD AA 04
  BEQ $CC19                             ; $CC0D: F0 0A
  LDA $04BB                             ; $CC0F: AD BB 04
  CMP #$A8                              ; $CC12: C9 A8
  BNE $CC49                             ; $CC14: D0 33
  JMP $CC20                             ; $CC16: 4C 20 CC
Loc_CC19:
  LDA $04BB                             ; $CC19: AD BB 04
  CMP #$18                              ; $CC1C: C9 18
  BNE $CC49                             ; $CC1E: D0 29
Loc_CC20:
  INC $04A9                             ; $CC20: EE A9 04
  LDA #$43                              ; $CC23: A9 43
  STA $0000                             ; $CC25: 8D 00 00
  LDA #$01                              ; $CC28: A9 01
  STA $0001                             ; $CC2A: 8D 01 00
  LDA $04AA                             ; $CC2D: AD AA 04
  BEQ $CC3C                             ; $CC30: F0 0A
  LDA #$55                              ; $CC32: A9 55
  STA $0000                             ; $CC34: 8D 00 00
  LDA #$05                              ; $CC37: A9 05
  STA $0001                             ; $CC39: 8D 01 00
Loc_CC3C:
  LDY $04AA                             ; $CC3C: AC AA 04
  LDA $04AF,Y                           ; $CC3F: B9 AF 04
  CLC                                   ; $CC42: 18
  ADC $0001                             ; $CC43: 6D 01 00
  JMP $CDFD                             ; $CC46: 4C FD CD
Loc_CC49:
  LDA $04AA                             ; $CC49: AD AA 04
  EOR #$01                              ; $CC4C: 49 01
  STA $0011                             ; $CC4E: 8D 11 00
  LDA $04AA                             ; $CC51: AD AA 04
  BEQ $CC5C                             ; $CC54: F0 06
  INC $04BB                             ; $CC56: EE BB 04
  JMP $CEE1                             ; $CC59: 4C E1 CE
Loc_CC5C:
  DEC $04BB                             ; $CC5C: CE BB 04
  JMP $CEE1                             ; $CC5F: 4C E1 CE
Loc_CC62:  ; (dispatch callback target)
  LDA $04BD                             ; $CC62: AD BD 04
  STA $04A8                             ; $CC65: 8D A8 04
  LDA $04BE                             ; $CC68: AD BE 04
  STA $04A9                             ; $CC6B: 8D A9 04
  LDA $04AA                             ; $CC6E: AD AA 04
  BEQ $CC7D                             ; $CC71: F0 0A
  LDA #$F5                              ; $CC73: A9 F5
  STA $0000                             ; $CC75: 8D 00 00
  LDA #$08                              ; $CC78: A9 08
  JMP $CDFD                             ; $CC7A: 4C FD CD
Loc_CC7D:
  LDA #$E3                              ; $CC7D: A9 E3
  STA $0000                             ; $CC7F: 8D 00 00
  LDA #$04                              ; $CC82: A9 04
  JMP $CDFD                             ; $CC84: 4C FD CD
Loc_CC87:  ; (dispatch callback target)
  LDA $04A9                             ; $CC87: AD A9 04
  JSR $EADE                             ; $CC8A: 20 DE EA
; --- Data Region ---
  .byte $93,$CC,$AA,$CC,$D0,$CC,$EE,$A9,$04,$A9,$55,$8D,$00,$00,$AD,$AA; $CC8D: 93 CC AA CC D0 CC EE A9 04 A9 55 8D 00 00 AD AA
  .byte $04,$D0,$05,$A9,$43,$8D,$00,$00   ; $CC9D: 04 D0 05 A9 43 8D 00 00
Loc_CCA5:
; --- Code Region ---
  LDA #$00                              ; $CCA5: A9 00
  JMP $CDFD                             ; $CCA7: 4C FD CD
Loc_CCAA:  ; (dispatch callback target)
  LDA #$00                              ; $CCAA: A9 00
  STA $04B8                             ; $CCAC: 8D B8 04
  INC $04A9                             ; $CCAF: EE A9 04
  LDA #$A8                              ; $CCB2: A9 A8
  STA $04BB                             ; $CCB4: 8D BB 04
  LDA #$F5                              ; $CCB7: A9 F5
  STA $0000                             ; $CCB9: 8D 00 00
  LDA $04AA                             ; $CCBC: AD AA 04
  BNE $CCCB                             ; $CCBF: D0 0A
  LDA #$18                              ; $CCC1: A9 18
  STA $04BB                             ; $CCC3: 8D BB 04
  LDA #$E3                              ; $CCC6: A9 E3
  STA $0000                             ; $CCC8: 8D 00 00
Loc_CCCB:
  LDA #$00                              ; $CCCB: A9 00
  JMP $CDFD                             ; $CCCD: 4C FD CD
Loc_CCD0:  ; (dispatch callback target)
  LDA $04AA                             ; $CCD0: AD AA 04
  BEQ $CCDF                             ; $CCD3: F0 0A
  LDA $04BB                             ; $CCD5: AD BB 04
  CMP #$08                              ; $CCD8: C9 08
  BNE $CCF3                             ; $CCDA: D0 17
  JMP $CCE6                             ; $CCDC: 4C E6 CC
Loc_CCDF:
  LDA $04BB                             ; $CCDF: AD BB 04
  CMP #$B8                              ; $CCE2: C9 B8
  BNE $CCF3                             ; $CCE4: D0 0D
Loc_CCE6:
  LDA $04BD                             ; $CCE6: AD BD 04
  STA $04A8                             ; $CCE9: 8D A8 04
  LDA $04BE                             ; $CCEC: AD BE 04
  STA $04A9                             ; $CCEF: 8D A9 04
  RTS                                   ; $CCF2: 60
Loc_CCF3:
  LDA $04AA                             ; $CCF3: AD AA 04
  EOR #$01                              ; $CCF6: 49 01
  STA $0011                             ; $CCF8: 8D 11 00
  LDA $04AA                             ; $CCFB: AD AA 04
  BEQ $CD06                             ; $CCFE: F0 06
  INC $04BB                             ; $CD00: EE BB 04
  JMP $CD09                             ; $CD03: 4C 09 CD
Loc_CD06:
  DEC $04BB                             ; $CD06: CE BB 04
Loc_CD09:
  JSR $CEE1                             ; $CD09: 20 E1 CE
  LDY #$00                              ; $CD0C: A0 00
  LDX #$00                              ; $CD0E: A2 00
Loc_CD10:
  CPY $007C                             ; $CD10: CC 7C 00
  BEQ $CD3B                             ; $CD13: F0 26
  INX                                   ; $CD15: E8
  INX                                   ; $CD16: E8
  INX                                   ; $CD17: E8
  LDA $04AA                             ; $CD18: AD AA 04
  BEQ $CD25                             ; $CD1B: F0 08
  LDA $0200,X                           ; $CD1D: BD 00 02
  BMI $CD33                             ; $CD20: 30 11
  JMP $CD2E                             ; $CD22: 4C 2E CD
Loc_CD25:
  LDA $0200,X                           ; $CD25: BD 00 02
  CMP #$FF                              ; $CD28: C9 FF
  BCS $CD33                             ; $CD2A: B0 07
  BPL $CD33                             ; $CD2C: 10 05
Loc_CD2E:
  LDA #$F0                              ; $CD2E: A9 F0
  STA $0200,Y                           ; $CD30: 99 00 02
Loc_CD33:
  INX                                   ; $CD33: E8
  INY                                   ; $CD34: C8
  INY                                   ; $CD35: C8
  INY                                   ; $CD36: C8
  INY                                   ; $CD37: C8
  JMP $CD10                             ; $CD38: 4C 10 CD
Loc_CD3B:
  RTS                                   ; $CD3B: 60
Loc_CD3C:  ; (dispatch callback target)
  LDA $04A9                             ; $CD3C: AD A9 04
  JSR $EADE                             ; $CD3F: 20 DE EA
; --- Data Region ---
  .byte $48,$CD,$5F,$CD,$85,$CD,$EE,$A9,$04,$A9,$55,$8D,$00,$00,$AD,$AA; $CD42: 48 CD 5F CD 85 CD EE A9 04 A9 55 8D 00 00 AD AA
  .byte $04,$D0,$05,$A9,$43,$8D,$00,$00   ; $CD52: 04 D0 05 A9 43 8D 00 00
Loc_CD5A:
; --- Code Region ---
  LDA #$00                              ; $CD5A: A9 00
  JMP $CDFD                             ; $CD5C: 4C FD CD
Loc_CD5F:  ; (dispatch callback target)
  LDA #$00                              ; $CD5F: A9 00
  STA $04B8                             ; $CD61: 8D B8 04
  INC $04A9                             ; $CD64: EE A9 04
  LDA #$A8                              ; $CD67: A9 A8
  STA $04BB                             ; $CD69: 8D BB 04
  LDA #$F5                              ; $CD6C: A9 F5
  STA $0000                             ; $CD6E: 8D 00 00
  LDA $04AA                             ; $CD71: AD AA 04
  BNE $CD80                             ; $CD74: D0 0A
  LDA #$18                              ; $CD76: A9 18
  STA $04BB                             ; $CD78: 8D BB 04
  LDA #$E3                              ; $CD7B: A9 E3
  STA $0000                             ; $CD7D: 8D 00 00
Loc_CD80:
  LDA #$00                              ; $CD80: A9 00
  JMP $CDFD                             ; $CD82: 4C FD CD
Loc_CD85:  ; (dispatch callback target)
  LDA $04AA                             ; $CD85: AD AA 04
  BEQ $CD94                             ; $CD88: F0 0A
  LDA $04BB                             ; $CD8A: AD BB 04
  CMP #$B8                              ; $CD8D: C9 B8
  BNE $CDA8                             ; $CD8F: D0 17
  JMP $CD9B                             ; $CD91: 4C 9B CD
Loc_CD94:
  LDA $04BB                             ; $CD94: AD BB 04
  CMP #$08                              ; $CD97: C9 08
  BNE $CDA8                             ; $CD99: D0 0D
Loc_CD9B:
  LDA $04BD                             ; $CD9B: AD BD 04
  STA $04A8                             ; $CD9E: 8D A8 04
  LDA $04BE                             ; $CDA1: AD BE 04
  STA $04A9                             ; $CDA4: 8D A9 04
  RTS                                   ; $CDA7: 60
Loc_CDA8:
  LDA $04AA                             ; $CDA8: AD AA 04
  STA $0011                             ; $CDAB: 8D 11 00
  LDA $04AA                             ; $CDAE: AD AA 04
  BNE $CDB9                             ; $CDB1: D0 06
  INC $04BB                             ; $CDB3: EE BB 04
  JMP $CDBC                             ; $CDB6: 4C BC CD
Loc_CDB9:
  DEC $04BB                             ; $CDB9: CE BB 04
Loc_CDBC:
  JSR $CEE1                             ; $CDBC: 20 E1 CE
  LDY #$00                              ; $CDBF: A0 00
  LDX #$00                              ; $CDC1: A2 00
Loc_CDC3:
  CPY $007C                             ; $CDC3: CC 7C 00
  BEQ $CDFC                             ; $CDC6: F0 34
  INX                                   ; $CDC8: E8
  INX                                   ; $CDC9: E8
  INX                                   ; $CDCA: E8
  LDA $04AA                             ; $CDCB: AD AA 04
  BEQ $CDDF                             ; $CDCE: F0 0F
  LDA $04BB                             ; $CDD0: AD BB 04
  CMP #$B8                              ; $CDD3: C9 B8
  BCC $CDF4                             ; $CDD5: 90 1D
  LDA $0200,X                           ; $CDD7: BD 00 02
  BMI $CDEF                             ; $CDDA: 30 13
  JMP $CDF4                             ; $CDDC: 4C F4 CD
Loc_CDDF:
  LDA $04BB                             ; $CDDF: AD BB 04
  CMP #$18                              ; $CDE2: C9 18
  BCC $CDEA                             ; $CDE4: 90 04
  CMP #$C8                              ; $CDE6: C9 C8
  BCC $CDF4                             ; $CDE8: 90 0A
Loc_CDEA:
  LDA $0200,X                           ; $CDEA: BD 00 02
  BMI $CDF4                             ; $CDED: 30 05
Loc_CDEF:
  LDA #$F0                              ; $CDEF: A9 F0
  STA $0200,Y                           ; $CDF1: 99 00 02
Loc_CDF4:
  INX                                   ; $CDF4: E8
  INY                                   ; $CDF5: C8
  INY                                   ; $CDF6: C8
  INY                                   ; $CDF7: C8
  INY                                   ; $CDF8: C8
  JMP $CDC3                             ; $CDF9: 4C C3 CD
Loc_CDFC:
  RTS                                   ; $CDFC: 60
Loc_CDFD:
  STA $0002                             ; $CDFD: 8D 02 00
  LDA #$00                              ; $CE00: A9 00
  STA $0003                             ; $CE02: 8D 03 00
  LDA $0002                             ; $CE05: AD 02 00
  ASL                                   ; $CE08: 0A
  ROL $0003                             ; $CE09: 2E 03 00
  ASL                                   ; $CE0C: 0A
  ROL $0003                             ; $CE0D: 2E 03 00
  ASL                                   ; $CE10: 0A
  ROL $0003                             ; $CE11: 2E 03 00
  STA $0004                             ; $CE14: 8D 04 00
  LDA $0003                             ; $CE17: AD 03 00
  STA $0005                             ; $CE1A: 8D 05 00
  LDA $0004                             ; $CE1D: AD 04 00
  ASL                                   ; $CE20: 0A
  ROL $0003                             ; $CE21: 2E 03 00
  ASL                                   ; $CE24: 0A
  ROL $0003                             ; $CE25: 2E 03 00
  CLC                                   ; $CE28: 18
  ADC $0004                             ; $CE29: 6D 04 00
  STA $0002                             ; $CE2C: 8D 02 00
  LDA $0003                             ; $CE2F: AD 03 00
  ADC $0005                             ; $CE32: 6D 05 00
  STA $0003                             ; $CE35: 8D 03 00
  LDA $0002                             ; $CE38: AD 02 00
  CLC                                   ; $CE3B: 18
  ADC #$AB                              ; $CE3C: 69 AB
  STA $0002                             ; $CE3E: 8D 02 00
  LDA $0003                             ; $CE41: AD 03 00
  ADC #$D2                              ; $CE44: 69 D2
  STA $0003                             ; $CE46: 8D 03 00
  LDA #$21                              ; $CE49: A9 21
  STA $0001                             ; $CE4B: 8D 01 00
  LDX #$00                              ; $CE4E: A2 00
Loc_CE50:
  LDA #$08                              ; $CE50: A9 08
  STA $0380,X                           ; $CE52: 9D 80 03
  INX                                   ; $CE55: E8
  LDA $0001                             ; $CE56: AD 01 00
  STA $0380,X                           ; $CE59: 9D 80 03
  INX                                   ; $CE5C: E8
  LDA $0000                             ; $CE5D: AD 00 00
  STA $0380,X                           ; $CE60: 9D 80 03
  INX                                   ; $CE63: E8
  LDY #$00                              ; $CE64: A0 00
Loc_CE66:
  LDA ($02),Y                           ; $CE66: B1 02
  STA $0380,X                           ; $CE68: 9D 80 03
  INX                                   ; $CE6B: E8
  INY                                   ; $CE6C: C8
  CPY #$08                              ; $CE6D: C0 08
  BCC $CE66                             ; $CE6F: 90 F5
  LDA $0000                             ; $CE71: AD 00 00
  CLC                                   ; $CE74: 18
  ADC #$20                              ; $CE75: 69 20
  STA $0000                             ; $CE77: 8D 00 00
  LDA $0001                             ; $CE7A: AD 01 00
  ADC #$00                              ; $CE7D: 69 00
  STA $0001                             ; $CE7F: 8D 01 00
  LDA $0002                             ; $CE82: AD 02 00
  CLC                                   ; $CE85: 18
  ADC #$08                              ; $CE86: 69 08
  STA $0002                             ; $CE88: 8D 02 00
  LDA $0003                             ; $CE8B: AD 03 00
  ADC #$00                              ; $CE8E: 69 00
  STA $0003                             ; $CE90: 8D 03 00
  CPX #$37                              ; $CE93: E0 37
  BCC $CE50                             ; $CE95: 90 B9
  LDA #$FF                              ; $CE97: A9 FF
  STA $0380,X                           ; $CE99: 9D 80 03
  LDA $007E                             ; $CE9C: AD 7E 00
  ORA #$04                              ; $CE9F: 09 04
  STA $007E                             ; $CEA1: 8D 7E 00
  RTS                                   ; $CEA4: 60
Loc_CEA5:
  ASL                                   ; $CEA5: 0A
  BCS $CEB6                             ; $CEA6: B0 0E
  LDY #$34                              ; $CEA8: A0 34
  JSR $F25F                             ; $CEAA: 20 5F F2
  TAY                                   ; $CEAD: A8
  LDA #$00                              ; $CEAE: A9 00
  STA $0001                             ; $CEB0: 8D 01 00
  JMP $CEC1                             ; $CEB3: 4C C1 CE
Loc_CEB6:
  LDY #$35                              ; $CEB6: A0 35
  JSR $F25F                             ; $CEB8: 20 5F F2
  TAY                                   ; $CEBB: A8
  LDA #$20                              ; $CEBC: A9 20
  STA $0001                             ; $CEBE: 8D 01 00
Loc_CEC1:
  LDA $8000,Y                           ; $CEC1: B9 00 80
  STA $0000                             ; $CEC4: 8D 00 00
  INY                                   ; $CEC7: C8
  LDA $8000,Y                           ; $CEC8: B9 00 80
  SEC                                   ; $CECB: 38
  SBC $0001                             ; $CECC: ED 01 00
  STA $0001                             ; $CECF: 8D 01 00
  LDA $04BA                             ; $CED2: AD BA 04
  STA $000A                             ; $CED5: 8D 0A 00
  LDA $04BB                             ; $CED8: AD BB 04
  STA $000C                             ; $CEDB: 8D 0C 00
  JMP $F1AD                             ; $CEDE: 4C AD F1
Loc_CEE1:
  INC $04B8                             ; $CEE1: EE B8 04
  LDA $04B8                             ; $CEE4: AD B8 04
  CMP #$20                              ; $CEE7: C9 20
  BCC $CEF5                             ; $CEE9: 90 0A
  LDA #$00                              ; $CEEB: A9 00
  STA $04B8                             ; $CEED: 8D B8 04
  LDA #$60                              ; $CEF0: A9 60
  JSR $E609                             ; $CEF2: 20 09 E6
Loc_CEF5:
  LSR                                   ; $CEF5: 4A
  LSR                                   ; $CEF6: 4A
  AND #$0F                              ; $CEF7: 29 0F
  STA $0010                             ; $CEF9: 8D 10 00
  LDA #$5D                              ; $CEFC: A9 5D
  STA $04BA                             ; $CEFE: 8D BA 04
  LDA $0010                             ; $CF01: AD 10 00
  CMP #$01                              ; $CF04: C9 01
  BEQ $CF1D                             ; $CF06: F0 15
  CMP #$02                              ; $CF08: C9 02
  BEQ $CF1D                             ; $CF0A: F0 11
  CMP #$04                              ; $CF0C: C9 04
  BEQ $CF14                             ; $CF0E: F0 04
  CMP #$05                              ; $CF10: C9 05
  BNE $CF23                             ; $CF12: D0 0F
Loc_CF14:
  INC $04BA                             ; $CF14: EE BA 04
  INC $04BA                             ; $CF17: EE BA 04
  JMP $CF23                             ; $CF1A: 4C 23 CF
Loc_CF1D:
  DEC $04BA                             ; $CF1D: CE BA 04
  DEC $04BA                             ; $CF20: CE BA 04
Loc_CF23:
  LDY $04AA                             ; $CF23: AC AA 04
  LDA $04AF,Y                           ; $CF26: B9 AF 04
  CMP #$02                              ; $CF29: C9 02
  BEQ $CF2F                             ; $CF2B: F0 02
  LDA #$00                              ; $CF2D: A9 00
Loc_CF2F:
  STA $0012                             ; $CF2F: 8D 12 00
  LDA $0011                             ; $CF32: AD 11 00
  BEQ $CF61                             ; $CF35: F0 2A
  LDA #$00                              ; $CF37: A9 00
  STA $0002                             ; $CF39: 8D 02 00
  LDA $0010                             ; $CF3C: AD 10 00
  JSR $CEA5                             ; $CF3F: 20 A5 CE
  LDA $04AA                             ; $CF42: AD AA 04
  CLC                                   ; $CF45: 18
  ADC #$01                              ; $CF46: 69 01
  STA $0002                             ; $CF48: 8D 02 00
  LDY $0010                             ; $CF4B: AC 10 00
  LDA $CF9B,Y                           ; $CF4E: B9 9B CF
  CLC                                   ; $CF51: 18
  ADC $0012                             ; $CF52: 6D 12 00
  JSR $CEA5                             ; $CF55: 20 A5 CE
  LDY $0010                             ; $CF58: AC 10 00
  LDA $CF93,Y                           ; $CF5B: B9 93 CF
  JMP $CEA5                             ; $CF5E: 4C A5 CE
Loc_CF61:
  LDA #$40                              ; $CF61: A9 40
  STA $0002                             ; $CF63: 8D 02 00
  LDA $0010                             ; $CF66: AD 10 00
  CLC                                   ; $CF69: 18
  ADC #$11                              ; $CF6A: 69 11
  JSR $CEA5                             ; $CF6C: 20 A5 CE
  LDA $04AA                             ; $CF6F: AD AA 04
  CLC                                   ; $CF72: 18
  ADC #$41                              ; $CF73: 69 41
  STA $0002                             ; $CF75: 8D 02 00
  LDY $0010                             ; $CF78: AC 10 00
  LDA $CF9B,Y                           ; $CF7B: B9 9B CF
  CLC                                   ; $CF7E: 18
  ADC #$11                              ; $CF7F: 69 11
  ADC $0012                             ; $CF81: 6D 12 00
  JSR $CEA5                             ; $CF84: 20 A5 CE
  LDY $0010                             ; $CF87: AC 10 00
  LDA $CF93,Y                           ; $CF8A: B9 93 CF
  CLC                                   ; $CF8D: 18
  ADC #$11                              ; $CF8E: 69 11
  JMP $CEA5                             ; $CF90: 4C A5 CE
; --- Data Region ---
  .byte $08,$09,$0A,$0A,$0B,$0C,$0B,$0B,$0D,$0E,$0E,$0E,$0D,$0D,$0D,$0D; $CF93: 08 09 0A 0A 0B 0C 0B 0B 0D 0E 0E 0E 0D 0D 0D 0D
Loc_CFA3:
; --- Code Region ---
  STA $0002                             ; $CFA3: 8D 02 00
  LDA #$00                              ; $CFA6: A9 00
  STA $0001                             ; $CFA8: 8D 01 00
  LDA $0002                             ; $CFAB: AD 02 00
  ASL                                   ; $CFAE: 0A
  ROL $0001                             ; $CFAF: 2E 01 00
  CLC                                   ; $CFB2: 18
  ADC $0002                             ; $CFB3: 6D 02 00
  STA $0000                             ; $CFB6: 8D 00 00
  LDA $0001                             ; $CFB9: AD 01 00
  ADC #$00                              ; $CFBC: 69 00
  STA $0001                             ; $CFBE: 8D 01 00
  LDA $0000                             ; $CFC1: AD 00 00
  ASL                                   ; $CFC4: 0A
  ROL $0001                             ; $CFC5: 2E 01 00
  ASL                                   ; $CFC8: 0A
  ROL $0001                             ; $CFC9: 2E 01 00
  CLC                                   ; $CFCC: 18
  ADC $0002                             ; $CFCD: 6D 02 00
  STA $0000                             ; $CFD0: 8D 00 00
  LDA $0001                             ; $CFD3: AD 01 00
  ADC #$00                              ; $CFD6: 69 00
  STA $0001                             ; $CFD8: 8D 01 00
  LDA #$B4                              ; $CFDB: A9 B4
  CLC                                   ; $CFDD: 18
  ADC $0000                             ; $CFDE: 6D 00 00
  STA $0000                             ; $CFE1: 8D 00 00
  LDA #$8D                              ; $CFE4: A9 8D
  ADC $0001                             ; $CFE6: 6D 01 00
  STA $0001                             ; $CFE9: 8D 01 00
  LDY #$00                              ; $CFEC: A0 00
  LDA ($00),Y                           ; $CFEE: B1 00
  STA $0002                             ; $CFF0: 8D 02 00
  LDY #$05                              ; $CFF3: A0 05
  LDA #$40                              ; $CFF5: A9 40
  STA $0005                             ; $CFF7: 8D 05 00
  LDA $0003                             ; $CFFA: AD 03 00
  CMP #$52                              ; $CFFD: C9 52
  BNE $D007                             ; $CFFF: D0 06
  LDA #$80                              ; $D001: A9 80
  STA $0005                             ; $D003: 8D 05 00
  INY                                   ; $D006: C8
Loc_D007:
  LDA $0002                             ; $D007: AD 02 00
  STA $00AE,Y                           ; $D00A: 99 AE 00
Loc_D00D:
  LDA #$06                              ; $D00D: A9 06
  STA $0380,X                           ; $D00F: 9D 80 03
  INX                                   ; $D012: E8
  LDA #$20                              ; $D013: A9 20
  STA $0380,X                           ; $D015: 9D 80 03
  INX                                   ; $D018: E8
  LDA $0003                             ; $D019: AD 03 00
  STA $0380,X                           ; $D01C: 9D 80 03
  INX                                   ; $D01F: E8
  LDY #$01                              ; $D020: A0 01
Loc_D022:
  LDA ($00),Y                           ; $D022: B1 00
  CMP #$FF                              ; $D024: C9 FF
  BNE $D02D                             ; $D026: D0 05
  LDA #$01                              ; $D028: A9 01
  JMP $D031                             ; $D02A: 4C 31 D0
Loc_D02D:
  CLC                                   ; $D02D: 18
  ADC $0005                             ; $D02E: 6D 05 00
Loc_D031:
  STA $0380,X                           ; $D031: 9D 80 03
  INX                                   ; $D034: E8
  INY                                   ; $D035: C8
  TYA                                   ; $D036: 98
  AND #$01                              ; $D037: 29 01
  BEQ $D022                             ; $D039: F0 E7
  INY                                   ; $D03B: C8
  INY                                   ; $D03C: C8
  CPY #$0D                              ; $D03D: C0 0D
  BCC $D022                             ; $D03F: 90 E1
  LDA $0000                             ; $D041: AD 00 00
  CLC                                   ; $D044: 18
  ADC #$02                              ; $D045: 69 02
  STA $0000                             ; $D047: 8D 00 00
  LDA $0001                             ; $D04A: AD 01 00
  ADC #$00                              ; $D04D: 69 00
  STA $0001                             ; $D04F: 8D 01 00
  LDA $0003                             ; $D052: AD 03 00
  CLC                                   ; $D055: 18
  ADC #$20                              ; $D056: 69 20
  STA $0003                             ; $D058: 8D 03 00
  CMP #$80                              ; $D05B: C9 80
  BCC $D00D                             ; $D05D: 90 AE
  RTS                                   ; $D05F: 60
Loc_D060:
  LDX #$00                              ; $D060: A2 00
Loc_D062:
  LDA $04AD,X                           ; $D062: BD AD 04
  JSR $F2D7                             ; $D065: 20 D7 F2
  LDA $04B1,X                           ; $D068: BD B1 04
  LDY #$00                              ; $D06B: A0 00
  STA ($00),Y                           ; $D06D: 91 00
  INX                                   ; $D06F: E8
  CPX #$02                              ; $D070: E0 02
  BCC $D062                             ; $D072: 90 EE
  LDX #$00                              ; $D074: A2 00
  LDA #$A4                              ; $D076: A9 A4
  STA $0010                             ; $D078: 8D 10 00
  LDA $04B1                             ; $D07B: AD B1 04
  JSR $D089                             ; $D07E: 20 89 D0
  LDA #$B2                              ; $D081: A9 B2
  STA $0010                             ; $D083: 8D 10 00
  LDA $04B2                             ; $D086: AD B2 04
Loc_D089:
  STA $0001                             ; $D089: 8D 01 00
  LDA #$0A                              ; $D08C: A9 0A
  STA $0380,X                           ; $D08E: 9D 80 03
  INX                                   ; $D091: E8
  LDA #$20                              ; $D092: A9 20
  STA $0380,X                           ; $D094: 9D 80 03
  INX                                   ; $D097: E8
  LDA $0010                             ; $D098: AD 10 00
  STA $0380,X                           ; $D09B: 9D 80 03
  INX                                   ; $D09E: E8
  LDA #$00                              ; $D09F: A9 00
  STA $0000                             ; $D0A1: 8D 00 00
Loc_D0A4:
  LDA $0001                             ; $D0A4: AD 01 00
  CMP #$0A                              ; $D0A7: C9 0A
  BCC $D0B7                             ; $D0A9: 90 0C
  SEC                                   ; $D0AB: 38
  SBC #$0A                              ; $D0AC: E9 0A
  STA $0001                             ; $D0AE: 8D 01 00
  INC $0000                             ; $D0B1: EE 00 00
  JMP $D0A4                             ; $D0B4: 4C A4 D0
Loc_D0B7:
  LDA $0010                             ; $D0B7: AD 10 00
  CMP #$A4                              ; $D0BA: C9 A4
  BEQ $D0C1                             ; $D0BC: F0 03
  JMP $D0FA                             ; $D0BE: 4C FA D0
Loc_D0C1:
  LDY #$00                              ; $D0C1: A0 00
  LDA #$04                              ; $D0C3: A9 04
Loc_D0C5:
  CPY $0000                             ; $D0C5: CC 00 00
  BEQ $D0D2                             ; $D0C8: F0 08
  STA $0380,X                           ; $D0CA: 9D 80 03
  INX                                   ; $D0CD: E8
  INY                                   ; $D0CE: C8
  JMP $D0C5                             ; $D0CF: 4C C5 D0
Loc_D0D2:
  CPY #$0A                              ; $D0D2: C0 0A
  BCS $D137                             ; $D0D4: B0 61
  LDA $0001                             ; $D0D6: AD 01 00
  BEQ $D0EB                             ; $D0D9: F0 10
  CMP #$06                              ; $D0DB: C9 06
  BCS $D0E4                             ; $D0DD: B0 05
  LDA #$05                              ; $D0DF: A9 05
  JMP $D0E6                             ; $D0E1: 4C E6 D0
Loc_D0E4:
  LDA #$04                              ; $D0E4: A9 04
Loc_D0E6:
  STA $0380,X                           ; $D0E6: 9D 80 03
  INX                                   ; $D0E9: E8
  INY                                   ; $D0EA: C8
Loc_D0EB:
  CPY #$0A                              ; $D0EB: C0 0A
  BEQ $D0F9                             ; $D0ED: F0 0A
  LDA #$06                              ; $D0EF: A9 06
  STA $0380,X                           ; $D0F1: 9D 80 03
  INX                                   ; $D0F4: E8
  INY                                   ; $D0F5: C8
  JMP $D0EB                             ; $D0F6: 4C EB D0
Loc_D0F9:
  RTS                                   ; $D0F9: 60
Loc_D0FA:
  TXA                                   ; $D0FA: 8A
  CLC                                   ; $D0FB: 18
  ADC #$09                              ; $D0FC: 69 09
  TAX                                   ; $D0FE: AA
  LDY #$00                              ; $D0FF: A0 00
  LDA #$04                              ; $D101: A9 04
Loc_D103:
  CPY $0000                             ; $D103: CC 00 00
  BEQ $D110                             ; $D106: F0 08
  STA $0380,X                           ; $D108: 9D 80 03
  DEX                                   ; $D10B: CA
  INY                                   ; $D10C: C8
  JMP $D103                             ; $D10D: 4C 03 D1
Loc_D110:
  CPY #$0A                              ; $D110: C0 0A
  BCS $D137                             ; $D112: B0 23
  LDA $0001                             ; $D114: AD 01 00
  BEQ $D129                             ; $D117: F0 10
  CMP #$06                              ; $D119: C9 06
  BCS $D122                             ; $D11B: B0 05
  LDA #$07                              ; $D11D: A9 07
  JMP $D124                             ; $D11F: 4C 24 D1
Loc_D122:
  LDA #$04                              ; $D122: A9 04
Loc_D124:
  STA $0380,X                           ; $D124: 9D 80 03
  DEX                                   ; $D127: CA
  INY                                   ; $D128: C8
Loc_D129:
  CPY #$0A                              ; $D129: C0 0A
  BEQ $D137                             ; $D12B: F0 0A
  LDA #$06                              ; $D12D: A9 06
  STA $0380,X                           ; $D12F: 9D 80 03
  DEX                                   ; $D132: CA
  INY                                   ; $D133: C8
  JMP $D129                             ; $D134: 4C 29 D1
Loc_D137:
  TXA                                   ; $D137: 8A
  CLC                                   ; $D138: 18
  ADC #$0B                              ; $D139: 69 0B
  TAX                                   ; $D13B: AA
  RTS                                   ; $D13C: 60
Loc_D13D:
  INC $046C                             ; $D13D: EE 6C 04
  LDA $046C                             ; $D140: AD 6C 04
  AND #$10                              ; $D143: 29 10
  BEQ $D149                             ; $D145: F0 02
  LDA #$20                              ; $D147: A9 20
Loc_D149:
  STA $000A                             ; $D149: 8D 0A 00
  LDA #$00                              ; $D14C: A9 00
  STA $0002                             ; $D14E: 8D 02 00
  STA $000C                             ; $D151: 8D 0C 00
  LDA #$61                              ; $D154: A9 61
  STA $0000                             ; $D156: 8D 00 00
  LDA #$D1                              ; $D159: A9 D1
  STA $0001                             ; $D15B: 8D 01 00
  JMP $F1AD                             ; $D15E: 4C AD F1
; --- Data Region ---
  .byte $D9,$04,$00,$7C,$80               ; $D161: D9 04 00 7C 80
Loc_D166:
; --- Code Region ---
  LDA #$A5                              ; $D166: A9 A5
  STA $000A                             ; $D168: 8D 0A 00
  LDY $04AA                             ; $D16B: AC AA 04
  LDA $04AD,Y                           ; $D16E: B9 AD 04
  STA $0000                             ; $D171: 8D 00 00
  LDY #$39                              ; $D174: A0 39
  JSR $EE07                             ; $D176: 20 07 EE
; --- Data Region ---
  .byte $00,$A0,$60,$A0,$40,$B9,$F4,$D1,$99,$80,$03,$88,$10,$F7,$AC,$AA; $D179: 00 A0 60 A0 40 B9 F4 D1 99 80 03 88 10 F7 AC AA
  .byte $04,$B9,$AD,$04,$20,$D7,$F2,$AD,$00,$00,$8D,$10,$00,$AD,$01,$00; $D189: 04 B9 AD 04 20 D7 F2 AD 00 00 8D 10 00 AD 01 00
  .byte $8D,$11,$00,$A0,$00,$A2,$0E       ; $D199: 8D 11 00 A0 00 A2 0E
Loc_D1A0:
; --- Code Region ---
  LDA #$00                              ; $D1A0: A9 00
  STA $0002                             ; $D1A2: 8D 02 00
  STA $0003                             ; $D1A5: 8D 03 00
  LDA ($10),Y                           ; $D1A8: B1 10
  CMP #$64                              ; $D1AA: C9 64
  BEQ $D1D3                             ; $D1AC: F0 25
  STA $0001                             ; $D1AE: 8D 01 00
  JSR $E9BA                             ; $D1B1: 20 BA E9
  LDA $0007                             ; $D1B4: AD 07 00
  AND #$0F                              ; $D1B7: 29 0F
  CLC                                   ; $D1B9: 18
  ADC #$76                              ; $D1BA: 69 76
  STA $0000                             ; $D1BC: 8D 00 00
  LDA $0007                             ; $D1BF: AD 07 00
  LSR                                   ; $D1C2: 4A
  LSR                                   ; $D1C3: 4A
  LSR                                   ; $D1C4: 4A
  LSR                                   ; $D1C5: 4A
  BNE $D1CD                             ; $D1C6: D0 05
  LDA #$01                              ; $D1C8: A9 01
  JMP $D1D8                             ; $D1CA: 4C D8 D1
Loc_D1CD:
  CLC                                   ; $D1CD: 18
  ADC #$76                              ; $D1CE: 69 76
  JMP $D1D8                             ; $D1D0: 4C D8 D1
Loc_D1D3:
  LDA #$32                              ; $D1D3: A9 32
  STA $0000                             ; $D1D5: 8D 00 00
Loc_D1D8:
  STA $0380,X                           ; $D1D8: 9D 80 03
  LDA $0000                             ; $D1DB: AD 00 00
  STA $0381,X                           ; $D1DE: 9D 81 03
  TXA                                   ; $D1E1: 8A
  CLC                                   ; $D1E2: 18
  ADC #$10                              ; $D1E3: 69 10
  TAX                                   ; $D1E5: AA
  INY                                   ; $D1E6: C8
  CPY #$04                              ; $D1E7: C0 04
  BCC $D1A0                             ; $D1E9: 90 B5
  LDA $007E                             ; $D1EB: AD 7E 00
  ORA #$04                              ; $D1EE: 09 04
  STA $007E                             ; $D1F0: 8D 7E 00
  RTS                                   ; $D1F3: 60
Loc_D1F4:  ; (dispatch callback target)
  ORA $22                               ; $D1F4: 05 22
  NOP #$80                              ; $D1F6: 89 80
  STA ($01,X)                           ; $D1F8: 81 01
  ORA ($01,X)                           ; $D1FA: 01 01
  ORA $22                               ; $D1FC: 05 22
  LDA #$90                              ; $D1FE: A9 90
  STA ($01),Y                           ; $D200: 91 01
  ORA ($01,X)                           ; $D202: 01 01
  ORA $22                               ; $D204: 05 22
  CMP #$84                              ; $D206: C9 84
  STA $01                               ; $D208: 85 01
  ORA ($01,X)                           ; $D20A: 01 01
  ORA $22                               ; $D20C: 05 22
  SBC #$94                              ; $D20E: E9 94
  STA $01,X                             ; $D210: 95 01
  ORA ($01,X)                           ; $D212: 01 01
  ORA $23                               ; $D214: 05 23
  ORA #$82                              ; $D216: 09 82
  SAX ($01,X)                           ; $D218: 83 01
  ORA ($01,X)                           ; $D21A: 01 01
  ORA $23                               ; $D21C: 05 23
  AND #$92                              ; $D21E: 29 92
  AHX ($01),Y                           ; $D220: 93 01
  ORA ($01,X)                           ; $D222: 01 01
  ORA $23                               ; $D224: 05 23
  EOR #$88                              ; $D226: 49 88
  NOP #$01                              ; $D228: 89 01
  ORA ($01,X)                           ; $D22A: 01 01
  ORA $23                               ; $D22C: 05 23
  ADC #$98                              ; $D22E: 69 98
  STA $0101,Y                           ; $D230: 99 01 01
  ORA ($FF,X)                           ; $D233: 01 FF
Loc_D235:
  LDA $04BA                             ; $D235: AD BA 04
  PHA                                   ; $D238: 48
  LDA $04BB                             ; $D239: AD BB 04
  PHA                                   ; $D23C: 48
  LDA #$57                              ; $D23D: A9 57
  STA $04BA                             ; $D23F: 8D BA 04
  LDX #$38                              ; $D242: A2 38
  LDA $04AA                             ; $D244: AD AA 04
  BNE $D24B                             ; $D247: D0 02
  LDX #$B8                              ; $D249: A2 B8
Loc_D24B:
  STX $04BB                             ; $D24B: 8E BB 04
  LDA #$03                              ; $D24E: A9 03
  STA $0002                             ; $D250: 8D 02 00
  LDA $0010                             ; $D253: AD 10 00
  JSR $CEA5                             ; $D256: 20 A5 CE
  PLA                                   ; $D259: 68
  STA $04BB                             ; $D25A: 8D BB 04
  PLA                                   ; $D25D: 68
  STA $04BA                             ; $D25E: 8D BA 04
  RTS                                   ; $D261: 60
Loc_D262:
  LDY $04AA                             ; $D262: AC AA 04
  LDA $04AD,Y                           ; $D265: B9 AD 04
  STA $0010                             ; $D268: 8D 10 00
  LDX #$00                              ; $D26B: A2 00
Loc_D26D:
  TXA                                   ; $D26D: 8A
  JSR $F368                             ; $D26E: 20 68 F3
  LDY #$00                              ; $D271: A0 00
  LDA ($00),Y                           ; $D273: B1 00
  CMP $0010                             ; $D275: CD 10 00
  BEQ $D281                             ; $D278: F0 07
  INX                                   ; $D27A: E8
  CPX #$07                              ; $D27B: E0 07
  BCC $D26D                             ; $D27D: 90 EE
  CLC                                   ; $D27F: 18
  RTS                                   ; $D280: 60
Loc_D281:
  SEC                                   ; $D281: 38
  RTS                                   ; $D282: 60
Loc_D283:
  STA $0311                             ; $D283: 8D 11 03
  LDA #$20                              ; $D286: A9 20
  STA $0310                             ; $D288: 8D 10 03
  LDA #$FF                              ; $D28B: A9 FF
  STA $0312                             ; $D28D: 8D 12 03
  STA $0313                             ; $D290: 8D 13 03
  LDA #$00                              ; $D293: A9 00
  STA $0300                             ; $D295: 8D 00 03
  RTS                                   ; $D298: 60
Loc_D299:
  LDA $0304                             ; $D299: AD 04 03
  CMP #$FF                              ; $D29C: C9 FF
  BNE $D2A9                             ; $D29E: D0 09
  LDA $0300                             ; $D2A0: AD 00 03
  CMP #$FF                              ; $D2A3: C9 FF
  BNE $D2A9                             ; $D2A5: D0 02
  SEC                                   ; $D2A7: 38
  RTS                                   ; $D2A8: 60
Loc_D2A9:
  CLC                                   ; $D2A9: 18
  RTS                                   ; $D2AA: 60
; --- Data Region ---
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; $D2AB: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; $D2BB: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; $D2CB: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$05,$06,$00,$00,$00,$07,$08,$09,$0A,$04; $D2DB: 00 00 00 00 00 00 05 06 00 00 00 07 08 09 0A 04
  .byte $00,$00,$0B,$0C,$0D,$0E,$0F,$00,$00,$10,$11,$12,$13,$14,$15,$16; $D2EB: 00 00 0B 0C 0D 0E 0F 00 00 10 11 12 13 14 15 16
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; $D2FB: 00 00 00 00 00 00 00 00 00 00 00 00
Loc_D307:
; --- Code Region ---
  BRK                                   ; $D307: 00
  BRK                                   ; $D308: 00
  NOP $35,X                             ; $D309: 34 35
  BRK                                   ; $D30B: 00
  BRK                                   ; $D30C: 00
  BRK                                   ; $D30D: 00
  SLO $08                               ; $D30E: 07 08
  ROL $37,X                             ; $D310: 36 37
  SEC                                   ; $D312: 38
  BRK                                   ; $D313: 00
  BRK                                   ; $D314: 00
  ANC #$0C                              ; $D315: 0B 0C
  ORA $0F0E                             ; $D317: 0D 0E 0F
  BRK                                   ; $D31A: 00
  BRK                                   ; $D31B: 00
  BPL $D32F                             ; $D31C: 10 11
  JAM                                   ; $D31E: 12
  SLO ($14),Y                           ; $D31F: 13 14
  ORA $16,X                             ; $D321: 15 16
  BRK                                   ; $D323: 00
  BRK                                   ; $D324: 00
  BRK                                   ; $D325: 00
  BRK                                   ; $D326: 00
  BRK                                   ; $D327: 00
  BRK                                   ; $D328: 00
  BRK                                   ; $D329: 00
  BRK                                   ; $D32A: 00
  BRK                                   ; $D32B: 00
  BRK                                   ; $D32C: 00
  BRK                                   ; $D32D: 00
  BRK                                   ; $D32E: 00
Loc_D32F:
  BRK                                   ; $D32F: 00
  BRK                                   ; $D330: 00
  BRK                                   ; $D331: 00
  BRK                                   ; $D332: 00
  BRK                                   ; $D333: 00
  BRK                                   ; $D334: 00
  BRK                                   ; $D335: 00
  SLO $39                               ; $D336: 07 39
  NOP                                   ; $D338: 3A
  RLA $0000,Y                           ; $D339: 3B 00 00
  BRK                                   ; $D33C: 00
  ANC #$0C                              ; $D33D: 0B 0C
  NOP $0F3D,X                           ; $D33F: 3C 3D 0F
  BRK                                   ; $D342: 00
  BRK                                   ; $D343: 00
  BRK                                   ; $D344: 00
  ROL $1312,X                           ; $D345: 3E 12 13
  NOP $15,X                             ; $D348: 14 15
  ASL $17,X                             ; $D34A: 16 17
  CLC                                   ; $D34C: 18
Loc_D34D:
  ORA $1B1A,Y                           ; $D34D: 19 1A 1B
  NOP $1E1D,X                           ; $D350: 1C 1D 1E
  SLO $2120,X                           ; $D353: 1F 20 21
  JAM                                   ; $D356: 22
  RLA ($24,X)                           ; $D357: 23 24
  AND $00                               ; $D359: 25 00
  ROL $27                               ; $D35B: 26 27
  PLP                                   ; $D35D: 28
  AND #$2A                              ; $D35E: 29 2A
  ANC #$00                              ; $D360: 2B 00
  BRK                                   ; $D362: 00
  BIT $002D                             ; $D363: 2C 2D 00
  BRK                                   ; $D366: 00
  ROL $002F                             ; $D367: 2E 2F 00
  BRK                                   ; $D36A: 00
  BMI $D39E                             ; $D36B: 30 31
  BRK                                   ; $D36D: 00
  BRK                                   ; $D36E: 00
  JAM                                   ; $D36F: 32
  RLA ($00),Y                           ; $D370: 33 00
  BRK                                   ; $D372: 00
  BRK                                   ; $D373: 00
  BRK                                   ; $D374: 00
  BRK                                   ; $D375: 00
  BRK                                   ; $D376: 00
  BRK                                   ; $D377: 00
  BRK                                   ; $D378: 00
  BRK                                   ; $D379: 00
  BRK                                   ; $D37A: 00
  ADC ($72),Y                           ; $D37B: 71 72
  BRK                                   ; $D37D: 00
  BRK                                   ; $D37E: 00
  BRK                                   ; $D37F: 00
  BRK                                   ; $D380: 00
  BRK                                   ; $D381: 00
  BRK                                   ; $D382: 00
  BVS $D3F8                             ; $D383: 70 73
  NOP $45,X                             ; $D385: 74 45
  LSR $00                               ; $D387: 46 00
  BRK                                   ; $D389: 00
  BRK                                   ; $D38A: 00
  BRK                                   ; $D38B: 00
  SRE $48                               ; $D38C: 47 48
  EOR #$4A                              ; $D38E: 49 4A
  ALR #$00                              ; $D390: 4B 00
  BRK                                   ; $D392: 00
  JMP $4E4D                             ; $D393: 4C 4D 4E
; --- Data Region ---
  .byte $4F,$50,$51,$52,$00,$00,$00,$00   ; $D396: 4F 50 51 52 00 00 00 00
Loc_D39E:
; --- Code Region ---
  BRK                                   ; $D39E: 00
  BRK                                   ; $D39F: 00
  BRK                                   ; $D3A0: 00
  BRK                                   ; $D3A1: 00
  BRK                                   ; $D3A2: 00
  RTI                                   ; $D3A3: 40
; --- Data Region ---
  .byte $41,$00,$00,$00,$00,$00,$00,$42,$43,$44,$45,$46,$00,$00,$00,$00; $D3A4: 41 00 00 00 00 00 00 42 43 44 45 46 00 00 00 00
  .byte $47,$48,$49,$4A,$4B,$00,$00,$4C,$4D,$4E,$4F,$50,$51,$52,$00,$00; $D3B4: 47 48 49 4A 4B 00 00 4C 4D 4E 4F 50 51 52 00 00
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; $D3C4: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  .byte $75,$76,$77,$46,$00,$00,$00,$00,$47,$78,$79,$4A,$4B,$00,$00,$4C; $D3D4: 75 76 77 46 00 00 00 00 47 78 79 4A 4B 00 00 4C
  .byte $4D,$4E,$4F,$50,$7A,$00,$00,$53,$54,$55,$56,$57,$58,$59,$5A,$00; $D3E4: 4D 4E 4F 50 7A 00 00 53 54 55 56 57 58 59 5A 00
  .byte $5B,$5C,$5D,$5E                   ; $D3F4: 5B 5C 5D 5E
Loc_D3F8:
; --- Code Region ---
  SRE $6160,X                           ; $D3F8: 5F 60 61
  BRK                                   ; $D3FB: 00
  BRK                                   ; $D3FC: 00
  JAM                                   ; $D3FD: 62
  RRA ($64,X)                           ; $D3FE: 63 64
  ADC $66                               ; $D400: 65 66
  RRA $00                               ; $D402: 67 00
  BRK                                   ; $D404: 00
  PLA                                   ; $D405: 68
  ADC #$00                              ; $D406: 69 00
  BRK                                   ; $D408: 00
  ROR                                   ; $D409: 6A
  ARR #$00                              ; $D40A: 6B 00
  BRK                                   ; $D40C: 00
  JMP ($006D)                           ; $D40D: 6C 6D 00
; --- Data Region ---
  .byte $00,$6E,$6F,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; $D410: 00 6E 6F 00 00 00 00 00 00 00 00 00 00 00 00 00
  .byte $00,$98,$00,$00,$00,$00,$00,$99,$9A,$9B,$00,$00,$00,$00,$00,$9C; $D420: 00 98 00 00 00 00 00 99 9A 9B 00 00 00 00 00 9C
  .byte $9D,$9E,$9F,$00,$00,$00,$00,$A0,$A1,$00,$00,$A2,$A3,$A4,$00,$00; $D430: 9D 9E 9F 00 00 00 00 A0 A1 00 00 A2 A3 A4 00 00
  .byte $A5,$00,$00,$A6,$A7,$A8,$A9,$AA,$00,$00,$00,$AB,$AC,$AD,$AE,$00; $D440: A5 00 00 A6 A7 A8 A9 AA 00 00 00 AB AC AD AE 00
  .byte $00,$00,$00,$AF,$B0,$B1,$00,$00,$00,$00,$00,$B2,$00,$B3,$B4,$00; $D450: 00 00 00 AF B0 B1 00 00 00 00 00 B2 00 B3 B4 00
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7B,$00,$00,$00; $D460: 00 00 00 00 00 00 00 00 00 00 00 00 7B 00 00 00
  .byte $00,$00,$00,$00,$7C,$7D,$7E,$00,$00,$00,$00,$7F,$80,$81,$82,$00; $D470: 00 00 00 00 7C 7D 7E 00 00 00 00 7F 80 81 82 00
  .byte $00,$00,$00,$00,$00,$83,$84,$00,$00,$00,$00,$00,$00,$85,$00,$00; $D480: 00 00 00 00 00 83 84 00 00 00 00 00 00 85 00 00
  .byte $86,$87,$88,$00,$00,$00,$89,$8A,$8B,$8C,$8D,$00,$00,$00,$00,$8E; $D490: 86 87 88 00 00 00 89 8A 8B 8C 8D 00 00 00 00 8E
  .byte $8F,$90,$91,$00,$00,$00,$00,$00,$92,$93,$94,$00,$00,$00,$00,$95; $D4A0: 8F 90 91 00 00 00 00 00 92 93 94 00 00 00 00 95
  .byte $96,$00,$97,$A6,$A7,$00,$00,$00,$00,$00,$00,$00,$A8,$A9,$00,$00; $D4B0: 96 00 97 A6 A7 00 00 00 00 00 00 00 A8 A9 00 00
  .byte $00,$00,$00,$00,$00,$AA,$AB,$00,$00,$00,$00,$00,$00,$AC,$AD,$AE; $D4C0: 00 00 00 00 00 AA AB 00 00 00 00 00 00 AC AD AE
  .byte $85,$0F,$00,$00,$00,$AF,$B0,$B1,$B2,$15,$16,$B3,$B4,$B5,$00,$00; $D4D0: 85 0F 00 00 00 AF B0 B1 B2 15 16 B3 B4 B5 00 00
  .byte $00,$00,$00,$00,$B6,$B7,$00,$00,$00,$00,$00,$00,$00,$AA,$AB,$00; $D4E0: 00 00 00 00 B6 B7 00 00 00 00 00 00 00 AA AB 00
  .byte $00,$00,$00,$00,$00,$AC,$AD,$AE,$85,$0F,$00,$00,$00,$AF,$B0,$B1; $D4F0: 00 00 00 00 00 AC AD AE 85 0F 00 00 00 AF B0 B1
  .byte $B2,$15,$16,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$B8,$00; $D500: B2 15 16 00 00 00 00 00 00 00 00 00 00 00 B8 00
  .byte $00,$00,$00,$00,$00,$BA,$C0,$C1,$C2; $D510: 00 00 00 00 00 BA C0 C1 C2
Loc_D519:
; --- Code Region ---
  DCP ($C4,X)                           ; $D519: C3 C4
  BRK                                   ; $D51B: 00
  BRK                                   ; $D51C: 00
  CMP $AD                               ; $D51D: C5 AD
  DEC $85                               ; $D51F: C6 85
  SLO $0000                             ; $D521: 0F 00 00
  BRK                                   ; $D524: 00
  DCP $B0                               ; $D525: C7 B0
  INY                                   ; $D527: C8
  LDA $1615,Y                           ; $D528: B9 15 16
  BRK                                   ; $D52B: 00
  BRK                                   ; $D52C: 00
  BRK                                   ; $D52D: 00
  BRK                                   ; $D52E: 00
  BRK                                   ; $D52F: 00
  BRK                                   ; $D530: 00
  CMP #$CA                              ; $D531: C9 CA
  BRK                                   ; $D533: 00
  BRK                                   ; $D534: 00
  BRK                                   ; $D535: 00
  BRK                                   ; $D536: 00
  BRK                                   ; $D537: 00
  AXS #$CC                              ; $D538: CB CC
  BRK                                   ; $D53A: 00
  BRK                                   ; $D53B: 00
  BRK                                   ; $D53C: 00
  BRK                                   ; $D53D: 00
  BRK                                   ; $D53E: 00
  CMP $00CE                             ; $D53F: CD CE 00
  BRK                                   ; $D542: 00
  BRK                                   ; $D543: 00
  SRE $CF                               ; $D544: 47 CF
  BNE $D519                             ; $D546: D0 D1
  JAM                                   ; $D548: D2
  BRK                                   ; $D549: 00
  BRK                                   ; $D54A: 00
  JMP $D34D                             ; $D54B: 4C 4D D3
; --- Data Region ---
  .byte $D4,$D5,$D6,$00,$00,$00,$00,$00,$00,$00,$D7,$D8,$00,$00,$00,$00; $D54E: D4 D5 D6 00 00 00 00 00 00 00 D7 D8 00 00 00 00
  .byte $00,$00,$D9,$DA,$00,$00,$00,$00,$00,$CD,$CE,$00,$00,$00,$47,$CF; $D55E: 00 00 D9 DA 00 00 00 00 00 CD CE 00 00 00 47 CF
  .byte $D0,$D1,$D2,$00,$00,$4C,$4D,$D3,$D4,$D5,$D6,$00,$00,$00,$00,$00; $D56E: D0 D1 D2 00 00 4C 4D D3 D4 D5 D6 00 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$DC,$00,$00,$00,$DD,$DE,$DF; $D57E: 00 00 00 00 00 00 00 00 00 DC 00 00 00 DD DE DF
  .byte $E0,$E1,$E2,$00,$00,$00,$47,$CF,$E3,$D1,$E4,$00,$00,$4C,$4D,$DB; $D58E: E0 E1 E2 00 00 00 47 CF E3 D1 E4 00 00 4C 4D DB
  .byte $E5,$D5,$E6,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; $D59E: E5 D5 E6 00 00 00 00 00 00 00 00 00 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; $D5AE: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  .byte $00,$00,$A7,$0F,$00,$00,$00,$00,$00,$00,$14,$15,$16,$17,$18,$19; $D5BE: 00 00 A7 0F 00 00 00 00 00 00 14 15 16 17 18 19
  .byte $00,$00,$1C,$1D,$1E,$1F,$20,$21,$22,$23,$24,$25,$00,$26,$27,$28; $D5CE: 00 00 1C 1D 1E 1F 20 21 22 23 24 25 00 26 27 28
  .byte $29,$2A,$2B,$00,$00,$2C,$2D,$00,$00,$2E,$2F,$00,$00,$30,$31,$00; $D5DE: 29 2A 2B 00 00 2C 2D 00 00 2E 2F 00 00 30 31 00
  .byte $00,$32,$33,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; $D5EE: 00 32 33 00 00 00 00 00 00 00 00 00 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$47,$A8; $D5FE: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 47 A8
  .byte $00,$00,$00,$00,$00,$4C,$4D,$4E,$00,$00,$00,$00,$00,$53,$54,$55; $D60E: 00 00 00 00 00 4C 4D 4E 00 00 00 00 00 53 54 55
Loc_D61E:
; --- Code Region ---
  BRK                                   ; $D61E: 00
  BRK                                   ; $D61F: 00
  CLI                                   ; $D620: 58
  EOR $005A,Y                           ; $D621: 59 5A 00
  SRE $5D5C,Y                           ; $D624: 5B 5C 5D
  LSR $605F,X                           ; $D627: 5E 5F 60
  ADC ($00,X)                           ; $D62A: 61 00
  BRK                                   ; $D62C: 00
  JAM                                   ; $D62D: 62
  RRA ($64,X)                           ; $D62E: 63 64
  ADC $66                               ; $D630: 65 66
  RRA $00                               ; $D632: 67 00
  BRK                                   ; $D634: 00
  PLA                                   ; $D635: 68
  ADC #$00                              ; $D636: 69 00
  BRK                                   ; $D638: 00
  ROR                                   ; $D639: 6A
  ARR #$00                              ; $D63A: 6B 00
  BRK                                   ; $D63C: 00
  JMP ($006D)                           ; $D63D: 6C 6D 00
; --- Data Region ---
  .byte $00,$6E,$6F,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; $D640: 00 6E 6F 00 00 00 00 00 00 00 00 00 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; $D650: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  .byte $3F,$0F,$00,$00,$00,$00,$00,$00,$14,$15,$16,$00,$00,$00,$00,$00; $D660: 3F 0F 00 00 00 00 00 00 14 15 16 00 00 00 00 00
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00; $D670: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  .byte $00,$00,$00,$00,$47,$48,$00,$00,$00,$00,$00,$4C,$4D,$4E,$00,$00; $D680: 00 00 00 00 47 48 00 00 00 00 00 4C 4D 4E 00 00
  .byte $00,$00,$00                       ; $D690: 00 00 00
Loc_D693:
; --- Code Region ---
  LDY #$26                              ; $D693: A0 26
  JSR $F25F                             ; $D695: 20 5F F2
  LDA $0541                             ; $D698: AD 41 05
  JSR $EADE                             ; $D69B: 20 DE EA
; --- Data Region ---
  .byte $AA,$D6,$9B,$D7,$3A,$D8,$C9,$D8,$CA,$D9,$20,$D9,$AD,$CA,$04,$D0; $D69E: AA D6 9B D7 3A D8 C9 D8 CA D9 20 D9 AD CA 04 D0
  .byte $25,$A9,$00,$8D,$CD,$04,$8D,$CE,$04,$EE,$CA,$04,$A9,$FF,$8D,$CB; $D6AE: 25 A9 00 8D CD 04 8D CE 04 EE CA 04 A9 FF 8D CB
  .byte $04,$20,$6D,$D7,$A9,$D9,$AE,$2E,$04,$E0,$FF,$F0,$02,$A9,$D8; $D6BE: 04 20 6D D7 A9 D9 AE 2E 04 E0 FF F0 02 A9 D8
Loc_D6CD:
; --- Code Region ---
  JSR $F28B                             ; $D6CD: 20 8B F2
  JSR $ECBF                             ; $D6D0: 20 BF EC
  RTS                                   ; $D6D3: 60
Loc_D6D4:
  INC $04CD                             ; $D6D4: EE CD 04
  LDA #$7E                              ; $D6D7: A9 7E
  STA $10                               ; $D6D9: 85 10
  LDA #$9A                              ; $D6DB: A9 9A
  STA $11                               ; $D6DD: 85 11
  LDY $04CB                             ; $D6DF: AC CB 04
  BMI $D6E7                             ; $D6E2: 30 03
  JSR $DBF3                             ; $D6E4: 20 F3 DB
Loc_D6E7:
  LDY $04CA                             ; $D6E7: AC CA 04
  JSR $DBF3                             ; $D6EA: 20 F3 DB
  LDA $04CA                             ; $D6ED: AD CA 04
  CLC                                   ; $D6F0: 18
  ADC #$04                              ; $D6F1: 69 04
  TAY                                   ; $D6F3: A8
  JSR $DBF3                             ; $D6F4: 20 F3 DB
  LDA $04CD                             ; $D6F7: AD CD 04
  LSR                                   ; $D6FA: 4A
  LSR                                   ; $D6FB: 4A
  LSR                                   ; $D6FC: 4A
  AND #$03                              ; $D6FD: 29 03
  CLC                                   ; $D6FF: 18
  ADC #$01                              ; $D700: 69 01
  STA $04CA                             ; $D702: 8D CA 04
  LDA $04CB                             ; $D705: AD CB 04
  CMP #$FE                              ; $D708: C9 FE
  BEQ $D72A                             ; $D70A: F0 1E
  LDA $0300                             ; $D70C: AD 00 03
  CMP #$FF                              ; $D70F: C9 FF
  BNE $D729                             ; $D711: D0 16
  LDA $0304                             ; $D713: AD 04 03
  CMP #$FF                              ; $D716: C9 FF
  BNE $D729                             ; $D718: D0 0F
  INC $04CE                             ; $D71A: EE CE 04
  LDA $04CE                             ; $D71D: AD CE 04
  LSR                                   ; $D720: 4A
  LSR                                   ; $D721: 4A
  TAY                                   ; $D722: A8
  LDA $D755,Y                           ; $D723: B9 55 D7
  STA $04CB                             ; $D726: 8D CB 04
Loc_D729:
  RTS                                   ; $D729: 60
Loc_D72A:
  LDA $0081                             ; $D72A: AD 81 00
  AND #$01                              ; $D72D: 29 01
  BEQ $D751                             ; $D72F: F0 20
  LDA $6F43                             ; $D731: AD 43 6F
  BEQ $D752                             ; $D734: F0 1C
  LDA #$00                              ; $D736: A9 00
  STA $6F43                             ; $D738: 8D 43 6F
  LDA $0472                             ; $D73B: AD 72 04
  STA $0400                             ; $D73E: 8D 00 04
  LDA $0473                             ; $D741: AD 73 04
  STA $0401                             ; $D744: 8D 01 04
  LDA #$00                              ; $D747: A9 00
  STA $0402                             ; $D749: 8D 02 04
  LDA #$01                              ; $D74C: A9 01
  STA $007A                             ; $D74E: 8D 7A 00
Loc_D751:
  RTS                                   ; $D751: 60
Loc_D752:
  JMP $E000                             ; $D752: 4C 00 E0
; --- Data Region ---
  .byte $09,$0A,$0B,$0C,$F0,$F0,$F0,$0D,$0E,$0F,$10,$11,$12,$13,$13,$14; $D755: 09 0A 0B 0C F0 F0 F0 0D 0E 0F 10 11 12 13 13 14
  .byte $14,$15,$15,$14,$14               ; $D765: 14 15 15 14 14
Loc_D76A:
; --- Code Region ---
  SLO ($13),Y                           ; $D76A: 13 13
  INC $00A0,X                           ; $D76C: FE A0 00
Loc_D76F:
  LDA $D77B,Y                           ; $D76F: B9 7B D7
  STA $0100,Y                           ; $D772: 99 00 01
  INY                                   ; $D775: C8
  CPY #$20                              ; $D776: C0 20
  BCC $D76F                             ; $D778: 90 F5
  RTS                                   ; $D77A: 60
; --- Data Region ---
  .byte $0F,$30,$10,$00,$0F,$27,$16,$2A,$0F,$36,$30,$16,$0F,$30,$10,$00; $D77B: 0F 30 10 00 0F 27 16 2A 0F 36 30 16 0F 30 10 00
  .byte $0F,$30,$10,$00,$0F,$0F,$1B,$28,$0F,$36,$30,$16,$0F,$20,$27; $D78B: 0F 30 10 00 0F 0F 1B 28 0F 36 30 16 0F 20 27
Loc_D79A:
; --- Code Region ---
  SLO $AD,X                             ; $D79A: 17 AD
  DEX                                   ; $D79C: CA
  NOP $D0                               ; $D79D: 04 D0
  RLA $AD,X                             ; $D79F: 37 AD
  CMP #$04                              ; $D7A1: C9 04
  BNE $D7B7                             ; $D7A3: D0 12
  LDA #$A0                              ; $D7A5: A9 A0
  STA $006A                             ; $D7A7: 8D 6A 00
  LDA #$F8                              ; $D7AA: A9 F8
  STA $006C                             ; $D7AC: 8D 6C 00
  LDA #$F1                              ; $D7AF: A9 F1
  STA $006D                             ; $D7B1: 8D 6D 00
  JSR $DCE1                             ; $D7B4: 20 E1 DC
Loc_D7B7:
  JSR $DC13                             ; $D7B7: 20 13 DC
  LDA $04C9                             ; $D7BA: AD C9 04
  CMP #$10                              ; $D7BD: C9 10
  BCC $D7D6                             ; $D7BF: 90 15
  LDA #$00                              ; $D7C1: A9 00
  STA $04CD                             ; $D7C3: 8D CD 04
  STA $04CE                             ; $D7C6: 8D CE 04
  LDA #$02                              ; $D7C9: A9 02
  STA $04CA                             ; $D7CB: 8D CA 04
  LDA #$DC                              ; $D7CE: A9 DC
  JSR $F28B                             ; $D7D0: 20 8B F2
  JSR $ECBF                             ; $D7D3: 20 BF EC
Loc_D7D6:
  RTS                                   ; $D7D6: 60
Loc_D7D7:
  LDA $04C9                             ; $D7D7: AD C9 04
  BPL $D7DF                             ; $D7DA: 10 03
  JMP $D815                             ; $D7DC: 4C 15 D8
Loc_D7DF:
  INC $04CD                             ; $D7DF: EE CD 04
  BNE $D7E7                             ; $D7E2: D0 03
  INC $04CE                             ; $D7E4: EE CE 04
Loc_D7E7:
  LDA #$D9                              ; $D7E7: A9 D9
  STA $10                               ; $D7E9: 85 10
  LDA #$9C                              ; $D7EB: A9 9C
  STA $11                               ; $D7ED: 85 11
  LDY $04CA                             ; $D7EF: AC CA 04
  JSR $DBF3                             ; $D7F2: 20 F3 DB
  LDA $04CD                             ; $D7F5: AD CD 04
  LSR                                   ; $D7F8: 4A
  LSR                                   ; $D7F9: 4A
  LSR                                   ; $D7FA: 4A
  AND #$03                              ; $D7FB: 29 03
  STA $00                               ; $D7FD: 85 00
  CLC                                   ; $D7FF: 18
  ADC #$01                              ; $D800: 69 01
  STA $04CA                             ; $D802: 8D CA 04
  LDA $04CE                             ; $D805: AD CE 04
  CMP #$03                              ; $D808: C9 03
  BCC $D814                             ; $D80A: 90 08
  LDA #$80                              ; $D80C: A9 80
  STA $04C9                             ; $D80E: 8D C9 04
  JSR $ECEE                             ; $D811: 20 EE EC
Loc_D814:
  RTS                                   ; $D814: 60
Loc_D815:
  LDA $0087                             ; $D815: AD 87 00
  BPL $D839                             ; $D818: 10 1F
  LDA #$70                              ; $D81A: A9 70
  STA $006A                             ; $D81C: 8D 6A 00
  LDA #$20                              ; $D81F: A9 20
  STA $006C                             ; $D821: 8D 6C 00
  LDA #$F2                              ; $D824: A9 F2
  STA $006D                             ; $D826: 8D 6D 00
  LDA #$00                              ; $D829: A9 00
  STA $04C9                             ; $D82B: 8D C9 04
  STA $04CA                             ; $D82E: 8D CA 04
  INC $0541                             ; $D831: EE 41 05
  LDA #$00                              ; $D834: A9 00
  JSR $F28B                             ; $D836: 20 8B F2
Loc_D839:
  RTS                                   ; $D839: 60
Loc_D83A:  ; (dispatch callback target)
  LDA $04CA                             ; $D83A: AD CA 04
  BNE $D867                             ; $D83D: D0 28
  LDA $04C9                             ; $D83F: AD C9 04
  BNE $D847                             ; $D842: D0 03
  JSR $DCE1                             ; $D844: 20 E1 DC
Loc_D847:
  JSR $DC13                             ; $D847: 20 13 DC
  LDA $04C9                             ; $D84A: AD C9 04
  CMP #$10                              ; $D84D: C9 10
  BCC $D866                             ; $D84F: 90 15
  LDA #$00                              ; $D851: A9 00
  STA $04CD                             ; $D853: 8D CD 04
  STA $04CE                             ; $D856: 8D CE 04
  LDA #$01                              ; $D859: A9 01
  STA $04CA                             ; $D85B: 8D CA 04
  LDA #$DD                              ; $D85E: A9 DD
  JSR $F28B                             ; $D860: 20 8B F2
  JSR $ECBF                             ; $D863: 20 BF EC
Loc_D866:
  RTS                                   ; $D866: 60
Loc_D867:
  LDA $04C9                             ; $D867: AD C9 04
  BPL $D86F                             ; $D86A: 10 03
  JMP $D8B3                             ; $D86C: 4C B3 D8
Loc_D86F:
  INC $04CD                             ; $D86F: EE CD 04
  BNE $D877                             ; $D872: D0 03
  INC $04CE                             ; $D874: EE CE 04
Loc_D877:
  LDA #$75                              ; $D877: A9 75
  STA $10                               ; $D879: 85 10
  LDA #$9E                              ; $D87B: A9 9E
  STA $11                               ; $D87D: 85 11
  LDY $04CA                             ; $D87F: AC CA 04
  JSR $DBF3                             ; $D882: 20 F3 DB
  LDA $04CA                             ; $D885: AD CA 04
  CLC                                   ; $D888: 18
  ADC #$03                              ; $D889: 69 03
  TAY                                   ; $D88B: A8
  JSR $DBF3                             ; $D88C: 20 F3 DB
  LDA $04CD                             ; $D88F: AD CD 04
  LSR                                   ; $D892: 4A
  LSR                                   ; $D893: 4A
  LSR                                   ; $D894: 4A
  AND #$03                              ; $D895: 29 03
  CMP #$03                              ; $D897: C9 03
  BNE $D89D                             ; $D899: D0 02
  LDA #$02                              ; $D89B: A9 02
Loc_D89D:
  CLC                                   ; $D89D: 18
  ADC #$01                              ; $D89E: 69 01
  STA $04CA                             ; $D8A0: 8D CA 04
  LDA $04CE                             ; $D8A3: AD CE 04
  CMP #$03                              ; $D8A6: C9 03
  BCC $D8B2                             ; $D8A8: 90 08
  LDA #$80                              ; $D8AA: A9 80
  STA $04C9                             ; $D8AC: 8D C9 04
  JSR $ECEE                             ; $D8AF: 20 EE EC
Loc_D8B2:
  RTS                                   ; $D8B2: 60
Loc_D8B3:
  LDA $0087                             ; $D8B3: AD 87 00
  BPL $D8C8                             ; $D8B6: 10 10
  INC $0541                             ; $D8B8: EE 41 05
  LDA #$00                              ; $D8BB: A9 00
  STA $04C9                             ; $D8BD: 8D C9 04
  STA $04CA                             ; $D8C0: 8D CA 04
  LDA #$00                              ; $D8C3: A9 00
  JSR $F28B                             ; $D8C5: 20 8B F2
Loc_D8C8:
  RTS                                   ; $D8C8: 60
Loc_D8C9:  ; (dispatch callback target)
  LDA $04CA                             ; $D8C9: AD CA 04
  BNE $D8F6                             ; $D8CC: D0 28
  LDA $04C9                             ; $D8CE: AD C9 04
  BNE $D8D6                             ; $D8D1: D0 03
  JSR $DCE1                             ; $D8D3: 20 E1 DC
Loc_D8D6:
  JSR $DC13                             ; $D8D6: 20 13 DC
  LDA $04C9                             ; $D8D9: AD C9 04
  CMP #$10                              ; $D8DC: C9 10
  BCC $D8F5                             ; $D8DE: 90 15
  LDA #$00                              ; $D8E0: A9 00
  STA $04CD                             ; $D8E2: 8D CD 04
  STA $04CE                             ; $D8E5: 8D CE 04
  LDA #$01                              ; $D8E8: A9 01
  STA $04CA                             ; $D8EA: 8D CA 04
  LDA #$DE                              ; $D8ED: A9 DE
  JSR $F28B                             ; $D8EF: 20 8B F2
  JSR $ECBF                             ; $D8F2: 20 BF EC
Loc_D8F5:
  RTS                                   ; $D8F5: 60
Loc_D8F6:
  INC $04CD                             ; $D8F6: EE CD 04
  BNE $D8FE                             ; $D8F9: D0 03
  INC $04CE                             ; $D8FB: EE CE 04
Loc_D8FE:
  LDA $04CE                             ; $D8FE: AD CE 04
  CMP #$03                              ; $D901: C9 03
  BCC $D914                             ; $D903: 90 0F
  LDA $0435                             ; $D905: AD 35 04
  CMP #$46                              ; $D908: C9 46
  BCC $D915                             ; $D90A: 90 09
  INC $0541                             ; $D90C: EE 41 05
  LDA #$00                              ; $D90F: A9 00
  STA $0542                             ; $D911: 8D 42 05
Loc_D914:
  RTS                                   ; $D914: 60
Loc_D915:
  LDA #$05                              ; $D915: A9 05
  STA $0541                             ; $D917: 8D 41 05
  LDA #$04                              ; $D91A: A9 04
  STA $0542                             ; $D91C: 8D 42 05
  RTS                                   ; $D91F: 60
Loc_D920:  ; (dispatch callback target)
  LDA $0542                             ; $D920: AD 42 05
  JSR $EADE                             ; $D923: 20 DE EA
; --- Data Region ---
  .byte $32,$D9,$50,$D9,$5A,$D9,$76,$D9,$B4,$D9,$C2,$D9; $D926: 32 D9 50 D9 5A D9 76 D9 B4 D9 C2 D9
Loc_D932:  ; (dispatch callback target)
; --- Code Region ---
  LDA #$00                              ; $D932: A9 00
  STA $98                               ; $D934: 85 98
  LDA #$08                              ; $D936: A9 08
  STA $BA                               ; $D938: 85 BA
  LDA #$09                              ; $D93A: A9 09
  STA $BB                               ; $D93C: 85 BB
  LDA #$A7                              ; $D93E: A9 A7
  STA $BD                               ; $D940: 85 BD
  LDA #$F2                              ; $D942: A9 F2
  STA $0543                             ; $D944: 8D 43 05
  INC $0542                             ; $D947: EE 42 05
  LDA #$01                              ; $D94A: A9 01
  STA $0544                             ; $D94C: 8D 44 05
  RTS                                   ; $D94F: 60
Loc_D950:  ; (dispatch callback target)
  LDA $0543                             ; $D950: AD 43 05
  JSR $F28B                             ; $D953: 20 8B F2
  INC $0542                             ; $D956: EE 42 05
  RTS                                   ; $D959: 60
Loc_D95A:  ; (dispatch callback target)
  LDA $0300                             ; $D95A: AD 00 03
  CMP #$FF                              ; $D95D: C9 FF
  BNE $D975                             ; $D95F: D0 14
  LDA $0304                             ; $D961: AD 04 03
  CMP #$FF                              ; $D964: C9 FF
  BNE $D975                             ; $D966: D0 0D
  DEC $0544                             ; $D968: CE 44 05
  BNE $D975                             ; $D96B: D0 08
  LDA #$00                              ; $D96D: A9 00
  STA $0409                             ; $D96F: 8D 09 04
  INC $0542                             ; $D972: EE 42 05
Loc_D975:
  RTS                                   ; $D975: 60
Loc_D976:  ; (dispatch callback target)
  INC $0098                             ; $D976: EE 98 00
  LDA $0098                             ; $D979: AD 98 00
  CMP #$F0                              ; $D97C: C9 F0
  BCC $D985                             ; $D97E: 90 05
  LDA #$00                              ; $D980: A9 00
  STA $0098                             ; $D982: 8D 98 00
Loc_D985:
  INC $0409                             ; $D985: EE 09 04
  LDA $0409                             ; $D988: AD 09 04
  CMP #$50                              ; $D98B: C9 50
  BCC $D9B3                             ; $D98D: 90 24
  DEC $0542                             ; $D98F: CE 42 05
  DEC $0542                             ; $D992: CE 42 05
  LDA #$60                              ; $D995: A9 60
  STA $0544                             ; $D997: 8D 44 05
  INC $0543                             ; $D99A: EE 43 05
  LDA $0543                             ; $D99D: AD 43 05
  CMP #$F9                              ; $D9A0: C9 F9
  BNE $D9AA                             ; $D9A2: D0 06
  LDA #$01                              ; $D9A4: A9 01
  STA $0544                             ; $D9A6: 8D 44 05
  RTS                                   ; $D9A9: 60
Loc_D9AA:
  CMP #$FA                              ; $D9AA: C9 FA
  BNE $D9B3                             ; $D9AC: D0 05
  LDA #$04                              ; $D9AE: A9 04
  STA $0542                             ; $D9B0: 8D 42 05
Loc_D9B3:
  RTS                                   ; $D9B3: 60
Loc_D9B4:  ; (dispatch callback target)
  LDA $0081                             ; $D9B4: AD 81 00
Loc_D9B7:
  AND #$08                              ; $D9B7: 29 08
  BEQ $D9C1                             ; $D9B9: F0 06
  JSR $ECEE                             ; $D9BB: 20 EE EC
  INC $0542                             ; $D9BE: EE 42 05
Loc_D9C1:
  RTS                                   ; $D9C1: 60
Loc_D9C2:  ; (dispatch callback target)
  LDA $0087                             ; $D9C2: AD 87 00
  BPL $D9C1                             ; $D9C5: 10 FA
  JMP $E000                             ; $D9C7: 4C 00 E0
Loc_D9CA:  ; (dispatch callback target)
  LDA $0542                             ; $D9CA: AD 42 05
  JSR $EADE                             ; $D9CD: 20 DE EA
; --- Data Region ---
  .byte $DE,$D9,$41,$DA,$87,$DA,$B6,$DA,$E0,$DA,$90,$DB,$DA,$DB; $D9D0: DE D9 41 DA 87 DA B6 DA E0 DA 90 DB DA DB
Loc_D9DE:  ; (dispatch callback target)
; --- Code Region ---
  LDY #$30                              ; $D9DE: A0 30
  JSR $F25F                             ; $D9E0: 20 5F F2
  LDA #$FE                              ; $D9E3: A9 FE
  STA $0410                             ; $D9E5: 8D 10 04
  LDA $042C                             ; $D9E8: AD 2C 04
  STA $0411                             ; $D9EB: 8D 11 04
  LDX #$00                              ; $D9EE: A2 00
  LDA #$02                              ; $D9F0: A9 02
  STA $02                               ; $D9F2: 85 02
Loc_D9F4:
  TXA                                   ; $D9F4: 8A
  PHA                                   ; $D9F5: 48
  JSR $F2AF                             ; $D9F6: 20 AF F2
  LDY #$11                              ; $D9F9: A0 11
Loc_D9FB:
  LDA ($00),Y                           ; $D9FB: B1 00
  CMP #$FF                              ; $D9FD: C9 FF
  BEQ $DA0D                             ; $D9FF: F0 0C
  CMP $0411                             ; $DA01: CD 11 04
  BEQ $DA0D                             ; $DA04: F0 07
  LDX $02                               ; $DA06: A6 02
  STA $0410,X                           ; $DA08: 9D 10 04
  INC $02                               ; $DA0B: E6 02
Loc_DA0D:
  INY                                   ; $DA0D: C8
  CPY #$1B                              ; $DA0E: C0 1B
  BCC $D9FB                             ; $DA10: 90 E9
  PLA                                   ; $DA12: 68
  TAX                                   ; $DA13: AA
  INX                                   ; $DA14: E8
  CPX #$1E                              ; $DA15: E0 1E
  BCC $D9F4                             ; $DA17: 90 DB
  LDA #$FE                              ; $DA19: A9 FE
  LDX $02                               ; $DA1B: A6 02
  STA $0410,X                           ; $DA1D: 9D 10 04
  INX                                   ; $DA20: E8
  LDA #$FF                              ; $DA21: A9 FF
  STA $0410,X                           ; $DA23: 9D 10 04
  LDA #$00                              ; $DA26: A9 00
  STA $040C                             ; $DA28: 8D 0C 04
  STA $040D                             ; $DA2B: 8D 0D 04
  STA $0401                             ; $DA2E: 8D 01 04
  LDA #$C0                              ; $DA31: A9 C0
  STA $0543                             ; $DA33: 8D 43 05
  LDA #$06                              ; $DA36: A9 06
  STA $0542                             ; $DA38: 8D 42 05
  LDA #$F1                              ; $DA3B: A9 F1
  JSR $F28B                             ; $DA3D: 20 8B F2
  RTS                                   ; $DA40: 60
Loc_DA41:  ; (dispatch callback target)
  LDY #$39                              ; $DA41: A0 39
  JSR $EE07                             ; $DA43: 20 07 EE
; --- Data Region ---
  .byte $12,$A0,$AD,$0D,$04,$C9,$FF,$F0,$01,$60,$A9,$08,$85,$BA,$A9,$06; $DA46: 12 A0 AD 0D 04 C9 FF F0 01 60 A9 08 85 BA A9 06
  .byte $85,$BB,$A9,$00,$85,$96,$A9,$01,$85,$97,$A9,$00,$85,$98,$A9,$01; $DA56: 85 BB A9 00 85 96 A9 01 85 97 A9 00 85 98 A9 01
  .byte $85,$61,$A9,$20,$85,$6E,$A9,$C0,$85,$70,$A9,$E1,$85,$E8,$EE,$42; $DA66: 85 61 A9 20 85 6E A9 C0 85 70 A9 E1 85 E8 EE 42
  .byte $05,$A9,$03,$8D,$01,$04,$A9,$20,$8D,$43,$05,$A9,$00,$8D,$08,$04; $DA76: 05 A9 03 8D 01 04 A9 20 8D 43 05 A9 00 8D 08 04
  .byte $60                               ; $DA86: 60
Loc_DA87:  ; (dispatch callback target)
; --- Code Region ---
  LDA #$AE                              ; $DA87: A9 AE
  STA $0A                               ; $DA89: 85 0A
  LDX $0408                             ; $DA8B: AE 08 04
  LDA $0410,X                           ; $DA8E: BD 10 04
  STA $00                               ; $DA91: 85 00
  LDY #$39                              ; $DA93: A0 39
  JSR $EE07                             ; $DA95: 20 07 EE
; --- Data Region ---
  .byte $00,$A0,$EE,$42,$05,$A9,$00,$8D,$09,$04,$8D,$0A,$04,$A9,$00,$8D; $DA98: 00 A0 EE 42 05 A9 00 8D 09 04 8D 0A 04 A9 00 8D
  .byte $0D,$04,$AC,$08,$04,$C8,$B9,$10,$04,$98,$8D,$0C,$04,$60; $DAA8: 0D 04 AC 08 04 C8 B9 10 04 98 8D 0C 04 60
Loc_DAB6:  ; (dispatch callback target)
; --- Code Region ---
  LDY #$39                              ; $DAB6: A0 39
  JSR $EE07                             ; $DAB8: 20 07 EE
; --- Data Region ---
  .byte $12,$A0,$A9,$AE,$85,$0A,$AE,$08,$04,$BD,$10,$04,$85,$00,$A0,$39; $DABB: 12 A0 A9 AE 85 0A AE 08 04 BD 10 04 85 00 A0 39
  .byte $20,$07,$EE,$00,$A0,$AD,$0D,$04,$C9,$FF,$D0,$08,$CE,$43,$05,$D0; $DACB: 20 07 EE 00 A0 AD 0D 04 C9 FF D0 08 CE 43 05 D0
  .byte $03,$EE,$42,$05                   ; $DADB: 03 EE 42 05
Loc_DADF:
; --- Code Region ---
  RTS                                   ; $DADF: 60
Loc_DAE0:  ; (dispatch callback target)
  LDA $0409                             ; $DAE0: AD 09 04
  CMP #$40                              ; $DAE3: C9 40
  BNE $DAF1                             ; $DAE5: D0 0A
  LDA $040E                             ; $DAE7: AD 0E 04
  STA $BC                               ; $DAEA: 85 BC
  LDA $040F                             ; $DAEC: AD 0F 04
  STA $BD                               ; $DAEF: 85 BD
Loc_DAF1:
  INC $98                               ; $DAF1: E6 98
  LDA $98                               ; $DAF3: A5 98
  CMP #$F0                              ; $DAF5: C9 F0
  BCC $DAFD                             ; $DAF7: 90 04
  LDA #$00                              ; $DAF9: A9 00
  STA $98                               ; $DAFB: 85 98
Loc_DAFD:
  LDA $0409                             ; $DAFD: AD 09 04
  CMP #$29                              ; $DB00: C9 29
  BCS $DB2A                             ; $DB02: B0 26
  LDA #$AC                              ; $DB04: A9 AC
  SEC                                   ; $DB06: 38
  SBC $0409                             ; $DB07: ED 09 04
  STA $0A                               ; $DB0A: 85 0A
  LDX $0408                             ; $DB0C: AE 08 04
  JSR $DB50                             ; $DB0F: 20 50 DB
  LDA #$FC                              ; $DB12: A9 FC
  SEC                                   ; $DB14: 38
  SBC $0409                             ; $DB15: ED 09 04
  CMP #$AE                              ; $DB18: C9 AE
  BCS $DB1E                             ; $DB1A: B0 02
  LDA #$AE                              ; $DB1C: A9 AE
Loc_DB1E:
  STA $0A                               ; $DB1E: 85 0A
  LDX $0408                             ; $DB20: AE 08 04
  INX                                   ; $DB23: E8
  JSR $DB50                             ; $DB24: 20 50 DB
  JMP $DB5D                             ; $DB27: 4C 5D DB
Loc_DB2A:
  LDA #$FC                              ; $DB2A: A9 FC
  SEC                                   ; $DB2C: 38
  SBC $0409                             ; $DB2D: ED 09 04
  CMP #$AE                              ; $DB30: C9 AE
  BCS $DB36                             ; $DB32: B0 02
  LDA #$AE                              ; $DB34: A9 AE
Loc_DB36:
  STA $0A                               ; $DB36: 85 0A
  LDX $0408                             ; $DB38: AE 08 04
  INX                                   ; $DB3B: E8
  JSR $DB50                             ; $DB3C: 20 50 DB
  LDA #$AC                              ; $DB3F: A9 AC
  SEC                                   ; $DB41: 38
  SBC $0409                             ; $DB42: ED 09 04
  STA $0A                               ; $DB45: 85 0A
  LDX $0408                             ; $DB47: AE 08 04
  JSR $DB50                             ; $DB4A: 20 50 DB
Loc_DB4D:
  JMP $DB5D                             ; $DB4D: 4C 5D DB
Loc_DB50:
  LDA $0410,X                           ; $DB50: BD 10 04
  STA $00                               ; $DB53: 85 00
  LDY #$39                              ; $DB55: A0 39
  JSR $EE07                             ; $DB57: 20 07 EE
; --- Data Region ---
  .byte $00,$A0,$60                       ; $DB5A: 00 A0 60
Loc_DB5D:
; --- Code Region ---
  INC $0409                             ; $DB5D: EE 09 04
  LDA $0409                             ; $DB60: AD 09 04
  CMP #$50                              ; $DB63: C9 50
  BCC $DB8F                             ; $DB65: 90 28
  DEC $0542                             ; $DB67: CE 42 05
  DEC $0542                             ; $DB6A: CE 42 05
  INC $0408                             ; $DB6D: EE 08 04
  LDA #$20                              ; $DB70: A9 20
  STA $0543                             ; $DB72: 8D 43 05
  LDY $0408                             ; $DB75: AC 08 04
  INY                                   ; $DB78: C8
  LDA $0410,Y                           ; $DB79: B9 10 04
  CMP #$FF                              ; $DB7C: C9 FF
  BNE $DB8F                             ; $DB7E: D0 0F
  LDA #$05                              ; $DB80: A9 05
  STA $0542                             ; $DB82: 8D 42 05
  LDA #$80                              ; $DB85: A9 80
  STA $0543                             ; $DB87: 8D 43 05
  LDA #$27                              ; $DB8A: A9 27
  STA $0544                             ; $DB8C: 8D 44 05
Loc_DB8F:
  RTS                                   ; $DB8F: 60
Loc_DB90:  ; (dispatch callback target)
  LDA #$40                              ; $DB90: A9 40
  STA $0380                             ; $DB92: 8D 80 03
  LDA $0544                             ; $DB95: AD 44 05
  STA $0381                             ; $DB98: 8D 81 03
  LDA $0543                             ; $DB9B: AD 43 05
  STA $0382                             ; $DB9E: 8D 82 03
  LDY #$00                              ; $DBA1: A0 00
  LDA #$01                              ; $DBA3: A9 01
Loc_DBA5:
  STA $0383,Y                           ; $DBA5: 99 83 03
  INY                                   ; $DBA8: C8
  CPY #$40                              ; $DBA9: C0 40
  BCC $DBA5                             ; $DBAB: 90 F8
  LDA #$FF                              ; $DBAD: A9 FF
  STA $0383,Y                           ; $DBAF: 99 83 03
  LDA $0543                             ; $DBB2: AD 43 05
  SEC                                   ; $DBB5: 38
  SBC #$40                              ; $DBB6: E9 40
  STA $0543                             ; $DBB8: 8D 43 05
  LDA $0544                             ; $DBBB: AD 44 05
  SBC #$00                              ; $DBBE: E9 00
  STA $0544                             ; $DBC0: 8D 44 05
  CMP #$23                              ; $DBC3: C9 23
  BNE $DBD1                             ; $DBC5: D0 0A
  LDA #$05                              ; $DBC7: A9 05
  STA $0541                             ; $DBC9: 8D 41 05
  LDA #$00                              ; $DBCC: A9 00
  STA $0542                             ; $DBCE: 8D 42 05
Loc_DBD1:
  LDA $007E                             ; $DBD1: AD 7E 00
  ORA #$04                              ; $DBD4: 09 04
  STA $007E                             ; $DBD6: 8D 7E 00
  RTS                                   ; $DBD9: 60
Loc_DBDA:  ; (dispatch callback target)
  LDA $0300                             ; $DBDA: AD 00 03
  CMP #$FF                              ; $DBDD: C9 FF
  BNE $DBF2                             ; $DBDF: D0 11
  LDA $0304                             ; $DBE1: AD 04 03
  CMP #$FF                              ; $DBE4: C9 FF
  BNE $DBF2                             ; $DBE6: D0 0A
  DEC $0543                             ; $DBE8: CE 43 05
  BNE $DBF2                             ; $DBEB: D0 05
  LDA #$01                              ; $DBED: A9 01
  STA $0542                             ; $DBEF: 8D 42 05
Loc_DBF2:
  RTS                                   ; $DBF2: 60
Loc_DBF3:
  LDX #$10                              ; $DBF3: A2 10
  STX $0C                               ; $DBF5: 86 0C
  DEY                                   ; $DBF7: 88
  TYA                                   ; $DBF8: 98
  ASL                                   ; $DBF9: 0A
  TAY                                   ; $DBFA: A8
  LDA ($10),Y                           ; $DBFB: B1 10
  STA $0000                             ; $DBFD: 8D 00 00
  INY                                   ; $DC00: C8
  LDA ($10),Y                           ; $DC01: B1 10
  STA $0001                             ; $DC03: 8D 01 00
  LDA #$1F                              ; $DC06: A9 1F
  STA $000A                             ; $DC08: 8D 0A 00
  LDA #$00                              ; $DC0B: A9 00
  STA $0002                             ; $DC0D: 8D 02 00
  JMP $F1AD                             ; $DC10: 4C AD F1
Loc_DC13:
  LDY #$26                              ; $DC13: A0 26
  JSR $F25F                             ; $DC15: 20 5F F2
  LDA $04C9                             ; $DC18: AD C9 04
  CMP #$02                              ; $DC1B: C9 02
  BCS $DC22                             ; $DC1D: B0 03
  JMP $DC7E                             ; $DC1F: 4C 7E DC
Loc_DC22:
  LDA #$1C                              ; $DC22: A9 1C
  STA $0380                             ; $DC24: 8D 80 03
  LDA $04D5                             ; $DC27: AD D5 04
  STA $0381                             ; $DC2A: 8D 81 03
  LDA $04D4                             ; $DC2D: AD D4 04
  STA $0382                             ; $DC30: 8D 82 03
  LDA $04D2                             ; $DC33: AD D2 04
  STA $0010                             ; $DC36: 8D 10 00
  LDA $04D3                             ; $DC39: AD D3 04
  STA $0011                             ; $DC3C: 8D 11 00
  LDY #$00                              ; $DC3F: A0 00
Loc_DC41:
  LDA ($10),Y                           ; $DC41: B1 10
  STA $0383,Y                           ; $DC43: 99 83 03
  INY                                   ; $DC46: C8
  CPY #$1C                              ; $DC47: C0 1C
  BCC $DC41                             ; $DC49: 90 F6
  LDA #$FF                              ; $DC4B: A9 FF
  STA $0383,Y                           ; $DC4D: 99 83 03
  LDA $0010                             ; $DC50: AD 10 00
  CLC                                   ; $DC53: 18
  ADC #$1C                              ; $DC54: 69 1C
  STA $04D2                             ; $DC56: 8D D2 04
  LDA $0011                             ; $DC59: AD 11 00
  ADC #$00                              ; $DC5C: 69 00
  STA $04D3                             ; $DC5E: 8D D3 04
  LDA $04D4                             ; $DC61: AD D4 04
  CLC                                   ; $DC64: 18
  ADC #$20                              ; $DC65: 69 20
  STA $04D4                             ; $DC67: 8D D4 04
  LDA $04D5                             ; $DC6A: AD D5 04
  ADC #$00                              ; $DC6D: 69 00
  STA $04D5                             ; $DC6F: 8D D5 04
Loc_DC72:
  INC $04C9                             ; $DC72: EE C9 04
  LDA $007E                             ; $DC75: AD 7E 00
  ORA #$04                              ; $DC78: 09 04
  STA $007E                             ; $DC7A: 8D 7E 00
  RTS                                   ; $DC7D: 60
Loc_DC7E:
  LDA #$20                              ; $DC7E: A9 20
  STA $0380                             ; $DC80: 8D 80 03
  LDA #$23                              ; $DC83: A9 23
  STA $0381                             ; $DC85: 8D 81 03
  LDA #$C8                              ; $DC88: A9 C8
  STA $0382                             ; $DC8A: 8D 82 03
  LDA $0541                             ; $DC8D: AD 41 05
  SEC                                   ; $DC90: 38
  SBC #$01                              ; $DC91: E9 01
  ASL                                   ; $DC93: 0A
  TAY                                   ; $DC94: A8
  LDA $DCDB,Y                           ; $DC95: B9 DB DC
  STA $0010                             ; $DC98: 8D 10 00
  INY                                   ; $DC9B: C8
  LDA $DCDB,Y                           ; $DC9C: B9 DB DC
  STA $0011                             ; $DC9F: 8D 11 00
  LDY #$00                              ; $DCA2: A0 00
Loc_DCA4:
  LDA ($10),Y                           ; $DCA4: B1 10
  STA $0383,Y                           ; $DCA6: 99 83 03
  INY                                   ; $DCA9: C8
  CPY #$20                              ; $DCAA: C0 20
  BCC $DCA4                             ; $DCAC: 90 F6
  LDA #$FF                              ; $DCAE: A9 FF
  STA $0383,Y                           ; $DCB0: 99 83 03
  LDA $0541                             ; $DCB3: AD 41 05
  SEC                                   ; $DCB6: 38
  SBC #$01                              ; $DCB7: E9 01
  ASL                                   ; $DCB9: 0A
  TAY                                   ; $DCBA: A8
  LDA $DCD5,Y                           ; $DCBB: B9 D5 DC
  STA $04D2                             ; $DCBE: 8D D2 04
  INY                                   ; $DCC1: C8
  LDA $DCD5,Y                           ; $DCC2: B9 D5 DC
  STA $04D3                             ; $DCC5: 8D D3 04
  LDA #$82                              ; $DCC8: A9 82
  STA $04D4                             ; $DCCA: 8D D4 04
  LDA #$20                              ; $DCCD: A9 20
  STA $04D5                             ; $DCCF: 8D D5 04
  JMP $DC72                             ; $DCD2: 4C 72 DC
; --- Data Region ---
  .byte $E6,$95,$6E,$97,$F6,$98,$C5,$DD,$E5,$DD,$05,$DE; $DCD5: E6 95 6E 97 F6 98 C5 DD E5 DD 05 DE
Loc_DCE1:
; --- Code Region ---
  LDA $0541                             ; $DCE1: AD 41 05
  SEC                                   ; $DCE4: 38
  SBC #$01                              ; $DCE5: E9 01
  ASL                                   ; $DCE7: 0A
  ASL                                   ; $DCE8: 0A
  ASL                                   ; $DCE9: 0A
  ASL                                   ; $DCEA: 0A
  ASL                                   ; $DCEB: 0A
  TAY                                   ; $DCEC: A8
  LDX #$00                              ; $DCED: A2 00
Loc_DCEF:
  LDA $DD05,Y                           ; $DCEF: B9 05 DD
  STA $00BE,X                           ; $DCF2: 9D BE 00
  LDA $DD65,Y                           ; $DCF5: B9 65 DD
  STA $0100,X                           ; $DCF8: 9D 00 01
  INY                                   ; $DCFB: C8
  INX                                   ; $DCFC: E8
  CPX #$20                              ; $DCFD: E0 20
  BCC $DCEF                             ; $DCFF: 90 EE
  INC $04C9                             ; $DD01: EE C9 04
  RTS                                   ; $DD04: 60
; --- Data Region ---
  .byte $DA,$C9,$00,$00,$02,$F9,$00,$00,$C5,$C2,$C0,$00,$02,$F9,$FA,$F5; $DD05: DA C9 00 00 02 F9 00 00 C5 C2 C0 00 02 F9 FA F5
  .byte $FB,$00,$00,$00,$02,$F6,$B5,$D7,$9F,$00,$00,$00,$02,$AB,$BF,$00; $DD15: FB 00 00 00 02 F6 B5 D7 9F 00 00 00 02 AB BF 00
  .byte $BB,$A9,$00,$00,$02,$AC,$AD,$AE,$BB,$A9,$00,$00,$02,$AC,$AD,$AE; $DD25: BB A9 00 00 02 AC AD AE BB A9 00 00 02 AC AD AE
  .byte $BB,$A9,$00,$00,$02,$AC,$AD,$AE,$BB,$A9,$00,$00,$02,$AC,$AD,$AE; $DD35: BB A9 00 00 02 AC AD AE BB A9 00 00 02 AC AD AE
  .byte $BB,$A9,$00,$00,$02,$9A,$00,$00,$BB,$A9,$00,$00,$02,$9B,$9A,$9C; $DD45: BB A9 00 00 02 9A 00 00 BB A9 00 00 02 9B 9A 9C
  .byte $BB,$A9,$00,$00,$02,$9C,$9D,$9E,$BB,$A9,$00,$00,$02,$9E,$9D,$9F; $DD55: BB A9 00 00 02 9C 9D 9E BB A9 00 00 02 9E 9D 9F
  .byte $0F,$36,$17,$16,$0F,$27,$26,$17,$0F,$36,$20; $DD65: 0F 36 17 16 0F 27 26 17 0F 36 20
Loc_DD70:
; --- Code Region ---
  ASL $0F,X                             ; $DD70: 16 0F
  RLA $26                               ; $DD72: 27 26
  ROL $0F,X                             ; $DD74: 36 0F
  SLO $0620                             ; $DD76: 0F 20 06
  SLO $0F36                             ; $DD79: 0F 36 0F
  SLO $300F                             ; $DD7C: 0F 0F 30
  JSR $0F16                             ; $DD7F: 20 16 0F
  ORA ($02,X)                           ; $DD82: 01 02
  JAM                                   ; $DD84: 12
  SLO $1617                             ; $DD85: 0F 17 16
  ROL $0F,X                             ; $DD88: 36 0F
  RLA $36                               ; $DD8A: 27 36
  JSR $360F                             ; $DD8C: 20 0F 36
  JSR $0F16                             ; $DD8F: 20 16 0F
  SLO $26,X                             ; $DD92: 17 26
  RLA $0F                               ; $DD94: 27 0F
  SLO $16,X                             ; $DD96: 17 16
  ROL $0F,X                             ; $DD98: 36 0F
  RLA $36                               ; $DD9A: 27 36
  JSR $360F                             ; $DD9C: 20 0F 36
  JSR $0F16                             ; $DD9F: 20 16 0F
  SLO $26,X                             ; $DDA2: 17 26
  RLA $0F                               ; $DDA4: 27 0F
  ASL $17,X                             ; $DDA6: 16 17
  ROL $0F,X                             ; $DDA8: 36 0F
  SLO $16,X                             ; $DDAA: 17 16
  BMI $DDBD                             ; $DDAC: 30 0F
  ROL $20,X                             ; $DDAE: 36 20
  ASL $0F,X                             ; $DDB0: 16 0F
  SLO $26,X                             ; $DDB2: 17 26
  RLA $0F                               ; $DDB4: 27 0F
  SLO $1620                             ; $DDB6: 0F 20 16
  SLO $2816                             ; $DDB9: 0F 16 28
  SLO $360F                             ; $DDBC: 0F 0F 36
  BMI $DDD7                             ; $DDBF: 30 16
  SLO $2720                             ; $DDC1: 0F 20 27
  SLO $AA,X                             ; $DDC4: 17 AA
  TAX                                   ; $DDC6: AA
  BRK                                   ; $DDC7: 00
  TAX                                   ; $DDC8: AA
  TAX                                   ; $DDC9: AA
  JAM                                   ; $DDCA: 22
  TAX                                   ; $DDCB: AA
  TAX                                   ; $DDCC: AA
  ROR $005F                             ; $DDCD: 6E 5F 00
  SRE $005F,X                           ; $DDD0: 5F 5F 00
  BVC $DD70                             ; $DDD3: 50 9B
  ROR $D5                               ; $DDD5: 66 D5
Loc_DDD7:
  BRK                                   ; $DDD7: 00
  NOP $07                               ; $DDD8: 04 07
  CMP $41                               ; $DDDA: C5 41
  STA $AFAE,Y                           ; $DDDC: 99 AE AF
  LDY #$A0                              ; $DDDF: A0 A0
  LDY #$AC                              ; $DDE1: A0 AC
  LAX ($A8,X)                           ; $DDE3: A3 A8
  INC $77FF                             ; $DDE5: EE FF 77
  EOR $55,X                             ; $DDE8: 55 55
  CMP $BBFF,X                           ; $DDEA: DD FF BB
  INC $37FF                             ; $DDED: EE FF 37
  BRK                                   ; $DDF0: 00
  ORA $CD                               ; $DDF1: 05 CD
  ISB $22BB,X                           ; $DDF3: FF BB 22
  BRK                                   ; $DDF6: 00
  BRK                                   ; $DDF7: 00
  BRK                                   ; $DDF8: 00
  BRK                                   ; $DDF9: 00
  BRK                                   ; $DDFA: 00
  BRK                                   ; $DDFB: 00
  DEY                                   ; $DDFC: 88
  LDX #$A0                              ; $DDFD: A2 A0
  LDY #$A0                              ; $DDFF: A0 A0
  LDY #$A0                              ; $DE01: A0 A0
  LDY #$A8                              ; $DE03: A0 A8
  JAM                                   ; $DE05: 22
  BRK                                   ; $DE06: 00
  NOP $15                               ; $DE07: 44 15
  EOR $11                               ; $DE09: 45 11
  BRK                                   ; $DE0B: 00
  DEY                                   ; $DE0C: 88
  JAM                                   ; $DE0D: 22
  BRK                                   ; $DE0E: 00
  BRK                                   ; $DE0F: 00
  BRK                                   ; $DE10: 00
  BRK                                   ; $DE11: 00
  BRK                                   ; $DE12: 00
  BRK                                   ; $DE13: 00
  DEY                                   ; $DE14: 88
  JAM                                   ; $DE15: 22
  BRK                                   ; $DE16: 00
  BRK                                   ; $DE17: 00
  BRK                                   ; $DE18: 00
  BRK                                   ; $DE19: 00
  BRK                                   ; $DE1A: 00
  BRK                                   ; $DE1B: 00
  DEY                                   ; $DE1C: 88
  LDX #$A0                              ; $DE1D: A2 A0
  LDY #$A0                              ; $DE1F: A0 A0
  LDY #$A0                              ; $DE21: A0 A0
  LDY #$A8                              ; $DE23: A0 A8
Loc_DE25:
  LDA $0081                             ; $DE25: AD 81 00
  AND #$08                              ; $DE28: 29 08
  BEQ $DE34                             ; $DE2A: F0 08
  LDA #$03                              ; $DE2C: A9 03
  STA $0541                             ; $DE2E: 8D 41 05
  JMP $DEC7                             ; $DE31: 4C C7 DE
Loc_DE34:
  LDA $0541                             ; $DE34: AD 41 05
  JSR $EADE                             ; $DE37: 20 DE EA
; --- Data Region ---
  .byte $44,$DE,$66,$DE,$B9,$DE,$C7,$DE,$D6,$DE; $DE3A: 44 DE 66 DE B9 DE C7 DE D6 DE
Loc_DE44:  ; (dispatch callback target)
; --- Code Region ---
  INC $0544                             ; $DE44: EE 44 05
  LDA $0544                             ; $DE47: AD 44 05
  CMP #$20                              ; $DE4A: C9 20
  BCC $DE65                             ; $DE4C: 90 17
  LDA #$16                              ; $DE4E: A9 16
  STA $0115                             ; $DE50: 8D 15 01
  LDA #$30                              ; $DE53: A9 30
  STA $0116                             ; $DE55: 8D 16 01
  LDA #$00                              ; $DE58: A9 00
  STA $0543                             ; $DE5A: 8D 43 05
  LDA #$02                              ; $DE5D: A9 02
  STA $0544                             ; $DE5F: 8D 44 05
  INC $0541                             ; $DE62: EE 41 05
Loc_DE65:
  RTS                                   ; $DE65: 60
Loc_DE66:  ; (dispatch callback target)
  LDY $0543                             ; $DE66: AC 43 05
  CPY #$14                              ; $DE69: C0 14
  BNE $DE72                             ; $DE6B: D0 05
  LDA #$62                              ; $DE6D: A9 62
  JSR $E693                             ; $DE6F: 20 93 E6
Loc_DE72:
  LDY #$21                              ; $DE72: A0 21
  JSR $F25F                             ; $DE74: 20 5F F2
  LDY $0543                             ; $DE77: AC 43 05
  LDA $DEA0,Y                           ; $DE7A: B9 A0 DE
  JSR $DEFA                             ; $DE7D: 20 FA DE
  DEC $0544                             ; $DE80: CE 44 05
  BNE $DE9F                             ; $DE83: D0 1A
  LDA #$02                              ; $DE85: A9 02
  STA $0544                             ; $DE87: 8D 44 05
  INC $0543                             ; $DE8A: EE 43 05
  LDY $0543                             ; $DE8D: AC 43 05
  LDA $DEA0,Y                           ; $DE90: B9 A0 DE
  CMP #$FF                              ; $DE93: C9 FF
  BNE $DE9F                             ; $DE95: D0 08
  INC $0541                             ; $DE97: EE 41 05
  LDA #$40                              ; $DE9A: A9 40
  STA $0544                             ; $DE9C: 8D 44 05
Loc_DE9F:
  RTS                                   ; $DE9F: 60
; --- Data Region ---
  .byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$08,$08,$08,$08,$08,$08,$08; $DEA0: 00 01 02 03 04 05 06 07 08 08 08 08 08 08 08 08
  .byte $09,$0A,$0B,$0C,$0D,$0E,$0D,$08,$FF; $DEB0: 09 0A 0B 0C 0D 0E 0D 08 FF
Loc_DEB9:  ; (dispatch callback target)
; --- Code Region ---
  DEC $0544                             ; $DEB9: CE 44 05
  BEQ $DEC3                             ; $DEBC: F0 05
  LDA #$08                              ; $DEBE: A9 08
  JMP $DEFA                             ; $DEC0: 4C FA DE
; --- Data Region ---
  .byte $EE,$41,$05,$60                   ; $DEC3: EE 41 05 60
Loc_DEC7:  ; (dispatch callback target)
; --- Code Region ---
  INC $0541                             ; $DEC7: EE 41 05
  LDA #$0F                              ; $DECA: A9 0F
  STA $0115                             ; $DECC: 8D 15 01
  STA $0116                             ; $DECF: 8D 16 01
  STA $0117                             ; $DED2: 8D 17 01
  RTS                                   ; $DED5: 60
Loc_DED6:  ; (dispatch callback target)
  INC $0540                             ; $DED6: EE 40 05
  LDA #$00                              ; $DED9: A9 00
  STA $0541                             ; $DEDB: 8D 41 05
  LDA #$B0                              ; $DEDE: A9 B0
  STA $CE                               ; $DEE0: 85 CE
  LDA #$04                              ; $DEE2: A9 04
  STA $D6                               ; $DEE4: 85 D6
  LDA #$00                              ; $DEE6: A9 00
  STA $0544                             ; $DEE8: 8D 44 05
  STA $0470                             ; $DEEB: 8D 70 04
  STA $0471                             ; $DEEE: 8D 71 04
  JSR $E57F                             ; $DEF1: 20 7F E5
  LDA #$B0                              ; $DEF4: A9 B0
  JSR $E673                             ; $DEF6: 20 73 E6
  RTS                                   ; $DEF9: 60
Loc_DEFA:
  ASL                                   ; $DEFA: 0A
  TAY                                   ; $DEFB: A8
  LDA $97EF,Y                           ; $DEFC: B9 EF 97
  STA $00                               ; $DEFF: 85 00
  LDA $97F0,Y                           ; $DF01: B9 F0 97
  STA $01                               ; $DF04: 85 01
  LDA #$58                              ; $DF06: A9 58
  STA $0A                               ; $DF08: 85 0A
  LDA #$68                              ; $DF0A: A9 68
  STA $0C                               ; $DF0C: 85 0C
  LDA #$01                              ; $DF0E: A9 01
  STA $02                               ; $DF10: 85 02
  JMP $F1AD                             ; $DF12: 4C AD F1
Loc_DF15:
  LDA $050E                             ; $DF15: AD 0E 05
  ASL                                   ; $DF18: 0A
  TAY                                   ; $DF19: A8
  LDA $DF4A,Y                           ; $DF1A: B9 4A DF
  STA $0000                             ; $DF1D: 8D 00 00
  LDA $DF4B,Y                           ; $DF20: B9 4B DF
  STA $0001                             ; $DF23: 8D 01 00
  LDY #$00                              ; $DF26: A0 00
  LDA ($00),Y                           ; $DF28: B1 00
  STA $00AA                             ; $DF2A: 8D AA 00
  INY                                   ; $DF2D: C8
  LDA ($00),Y                           ; $DF2E: B1 00
  STA $00AB                             ; $DF30: 8D AB 00
  INY                                   ; $DF33: C8
  LDA ($00),Y                           ; $DF34: B1 00
  STA $00AC                             ; $DF36: 8D AC 00
  INY                                   ; $DF39: C8
  LDA ($00),Y                           ; $DF3A: B1 00
  STA $00AD                             ; $DF3C: 8D AD 00
  LDA #$AA                              ; $DF3F: A9 AA
  STA $00A8                             ; $DF41: 8D A8 00
  LDA #$00                              ; $DF44: A9 00
  STA $00A9                             ; $DF46: 8D A9 00
  RTS                                   ; $DF49: 60
; --- Data Region ---
  .byte $86,$DF,$8A,$DF,$8E,$DF,$92,$DF,$96,$DF,$9A,$DF,$9E,$DF,$A2,$DF; $DF4A: 86 DF 8A DF 8E DF 92 DF 96 DF 9A DF 9E DF A2 DF
  .byte $A6,$DF,$AA,$DF,$AE,$DF,$B2,$DF,$B6,$DF,$BA,$DF,$BE,$DF,$C2,$DF; $DF5A: A6 DF AA DF AE DF B2 DF B6 DF BA DF BE DF C2 DF
  .byte $C6,$DF,$CA,$DF,$CE,$DF,$D2,$DF,$D6,$DF,$DA,$DF,$DE,$DF,$E2,$DF; $DF6A: C6 DF CA DF CE DF D2 DF D6 DF DA DF DE DF E2 DF
  .byte $E6,$DF,$EA,$DF,$EE,$DF,$F2,$DF,$F6,$DF,$FA,$DF,$00,$02,$01,$03; $DF7A: E6 DF EA DF EE DF F2 DF F6 DF FA DF 00 02 01 03
  .byte $04,$06,$05,$07,$08,$0A,$09,$0B,$0C,$0E,$0D,$0F,$10,$12,$11,$13; $DF8A: 04 06 05 07 08 0A 09 0B 0C 0E 0D 0F 10 12 11 13
  .byte $14,$16,$15,$17,$18,$1A,$19,$1B,$1C,$1E,$1D,$1F,$20,$22,$21,$23; $DF9A: 14 16 15 17 18 1A 19 1B 1C 1E 1D 1F 20 22 21 23
  .byte $24,$26,$25,$27,$28,$2A,$29,$2B,$2C,$2E,$2D,$2F,$30,$32,$31,$33; $DFAA: 24 26 25 27 28 2A 29 2B 2C 2E 2D 2F 30 32 31 33
  .byte $34,$36,$35,$37,$38,$3A,$39,$3B,$3C,$3E,$3D,$3F,$40,$42,$41,$43; $DFBA: 34 36 35 37 38 3A 39 3B 3C 3E 3D 3F 40 42 41 43
  .byte $44,$46,$45,$47,$48,$4A,$49,$4B,$4C,$4E,$4D,$4F,$50,$52,$51,$53; $DFCA: 44 46 45 47 48 4A 49 4B 4C 4E 4D 4F 50 52 51 53
  .byte $54,$56,$55,$57,$58,$5A,$59,$5B,$5C,$5E,$5D,$5F,$60,$62,$61,$63; $DFDA: 54 56 55 57 58 5A 59 5B 5C 5E 5D 5F 60 62 61 63
  .byte $64,$66,$65,$67,$68,$6A,$69,$6B,$6C,$6E,$6D,$6F,$70,$72,$71,$73; $DFEA: 64 66 65 67 68 6A 69 6B 6C 6E 6D 6F 70 72 71 73
  .byte $74,$76,$75,$77,$FF,$FF           ; $DFFA: 74 76 75 77 FF FF
