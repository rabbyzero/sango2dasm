Loc_A000:  ; (dispatch callback target)
  JMP $A02D                             ; $A000: 4C 2D A0
Loc_A003:  ; (dispatch callback target)
  JMP $B130                             ; $A003: 4C 30 B1
Loc_A006:  ; (dispatch callback target)
  JMP $BAB3                             ; $A006: 4C B3 BA
Loc_A009:
  JMP $C0BB                             ; $A009: 4C BB C0
Loc_A00C:
  JMP $C983                             ; $A00C: 4C 83 C9
Loc_A00F:
  JMP $CD78                             ; $A00F: 4C 78 CD
Loc_A012:  ; (dispatch callback target)
  JMP $CFA2                             ; $A012: 4C A2 CF
Loc_A015:
  JMP $D1ED                             ; $A015: 4C ED D1
Loc_A018:
  JMP $D390                             ; $A018: 4C 90 D3
Loc_A01B:
  JMP $D3EE                             ; $A01B: 4C EE D3
Loc_A01E:
  JMP $C851                             ; $A01E: 4C 51 C8
Loc_A021:
  JMP $D57B                             ; $A021: 4C 7B D5
Loc_A024:
  JMP $D70F                             ; $A024: 4C 0F D7
Loc_A027:
  JMP $D66E                             ; $A027: 4C 6E D6
Loc_A02A:  ; (dispatch callback target)
  JMP $D6CD                             ; $A02A: 4C CD D6
Loc_A02D:
  LDA $6F8B                             ; $A02D: AD 8B 6F
  CMP #$FF                              ; $A030: C9 FF
  BNE $A035                             ; $A032: D0 01
  RTS                                   ; $A034: 60
Loc_A035:
  CMP #$01                              ; $A035: C9 01
  BNE $A03C                             ; $A037: D0 03
  JMP $B933                             ; $A039: 4C 33 B9
Loc_A03C:
  LDY $6F94                             ; $A03C: AC 94 6F
  CPY #$14                              ; $A03F: C0 14
  BCS $A073                             ; $A041: B0 30
  INC $6F94                             ; $A043: EE 94 6F
  LDA $6FA1,Y                           ; $A046: B9 A1 6F
  CMP #$FF                              ; $A049: C9 FF
Loc_A04B:
  BEQ $A06C                             ; $A04B: F0 1F
  JSR $A944                             ; $A04D: 20 44 A9
  BMI $A06C                             ; $A050: 30 1A
  LDA $0664,Y                           ; $A052: B9 64 06
  CMP #$FF                              ; $A055: C9 FF
  BEQ $A06C                             ; $A057: F0 13
  INC $6F96                             ; $A059: EE 96 6F
  STY $6F8C                             ; $A05C: 8C 8C 6F
  JSR $A099                             ; $A05F: 20 99 A0
  LDA $6F8F                             ; $A062: AD 8F 6F
  CMP #$03                              ; $A065: C9 03
  BNE $A093                             ; $A067: D0 2A
  INC $6F95                             ; $A069: EE 95 6F
Loc_A06C:
  LDA $6F94                             ; $A06C: AD 94 6F
  CMP #$14                              ; $A06F: C9 14
  BCC $A03C                             ; $A071: 90 C9
Loc_A073:
  LDA $6F96                             ; $A073: AD 96 6F
  CMP $6F95                             ; $A076: CD 95 6F
  BEQ $A089                             ; $A079: F0 0E
  LDA #$00                              ; $A07B: A9 00
  STA $6F94                             ; $A07D: 8D 94 6F
  STA $6F95                             ; $A080: 8D 95 6F
  STA $6F96                             ; $A083: 8D 96 6F
  JMP $A03C                             ; $A086: 4C 3C A0
Loc_A089:
  LDA #$03                              ; $A089: A9 03
  STA $6F8F                             ; $A08B: 8D 8F 6F
  LDA #$00                              ; $A08E: A9 00
  STA $6F94                             ; $A090: 8D 94 6F
Loc_A093:
  LDA #$FF                              ; $A093: A9 FF
  STA $6F8B                             ; $A095: 8D 8B 6F
  RTS                                   ; $A098: 60
Loc_A099:
  LDA $6FA1,Y                           ; $A099: B9 A1 6F
  AND #$0F                              ; $A09C: 29 0F
  JSR $B517                             ; $A09E: 20 17 B5
  LDA ($A0),Y                           ; $A0A1: B1 A0
  ORA $A1                               ; $A0A3: 05 A1
  ROR $A1                               ; $A0A5: 66 A1
  BPL $A04B                             ; $A0A7: 10 A2
  LDA $29A2                             ; $A0A9: AD A2 29
  LAX ($07,X)                           ; $A0AC: A3 07
  LDA $06                               ; $A0AE: A5 06
  LDX $AD                               ; $A0B0: A6 AD
  NOP $05                               ; $A0B2: 04 05
  BMI $A0B9                             ; $A0B4: 30 03
  JMP $A0F6                             ; $A0B6: 4C F6 A0
Loc_A0B9:
  JSR $AF0D                             ; $A0B9: 20 0D AF
  BCC $A0BF                             ; $A0BC: 90 01
  RTS                                   ; $A0BE: 60
Loc_A0BF:
  JSR $AAF8                             ; $A0BF: 20 F8 AA
  BCC $A0C5                             ; $A0C2: 90 01
  RTS                                   ; $A0C4: 60
Loc_A0C5:
  JSR $A8A8                             ; $A0C5: 20 A8 A8
  BCC $A0CB                             ; $A0C8: 90 01
  RTS                                   ; $A0CA: 60
Loc_A0CB:
  JSR $A95C                             ; $A0CB: 20 5C A9
  BCC $A0D1                             ; $A0CE: 90 01
  RTS                                   ; $A0D0: 60
Loc_A0D1:
  JSR $B5D5                             ; $A0D1: 20 D5 B5
  AND #$03                              ; $A0D4: 29 03
  BNE $A0DE                             ; $A0D6: D0 06
  LDA #$03                              ; $A0D8: A9 03
  STA $6F8F                             ; $A0DA: 8D 8F 6F
  RTS                                   ; $A0DD: 60
Loc_A0DE:
  LDA $0600                             ; $A0DE: AD 00 06
  STA $0020                             ; $A0E1: 8D 20 00
  LDA $0614                             ; $A0E4: AD 14 06
  CMP #$10                              ; $A0E7: C9 10
  BCC $A0ED                             ; $A0E9: 90 02
  SBC #$01                              ; $A0EB: E9 01
Loc_A0ED:
  STA $0021                             ; $A0ED: 8D 21 00
  LDY $6F8C                             ; $A0F0: AC 8C 6F
  JMP $A60C                             ; $A0F3: 4C 0C A6
Loc_A0F6:
  JSR $AF0D                             ; $A0F6: 20 0D AF
  BCC $A0FC                             ; $A0F9: 90 01
  RTS                                   ; $A0FB: 60
Loc_A0FC:
  JSR $AAF8                             ; $A0FC: 20 F8 AA
  BCC $A102                             ; $A0FF: 90 01
  RTS                                   ; $A101: 60
Loc_A102:
  JMP $A95C                             ; $A102: 4C 5C A9
; --- Data Region ---
  .byte $20,$0D,$AF,$90,$01,$60           ; $A105: 20 0D AF 90 01 60
Loc_A10B:
; --- Code Region ---
  JSR $AAF8                             ; $A10B: 20 F8 AA
  BCC $A111                             ; $A10E: 90 01
  RTS                                   ; $A110: 60
Loc_A111:
  LDA $0505                             ; $A111: AD 05 05
  CMP #$02                              ; $A114: C9 02
  BCC $A144                             ; $A116: 90 2C
  LDY $6F8C                             ; $A118: AC 8C 6F
  JSR $A837                             ; $A11B: 20 37 A8
  LDX #$0A                              ; $A11E: A2 0A
  LDA $0504                             ; $A120: AD 04 05
  BPL $A127                             ; $A123: 10 02
  LDX #$00                              ; $A125: A2 00
Loc_A127:
  STX $0020                             ; $A127: 8E 20 00
  LDY #$00                              ; $A12A: A0 00
Loc_A12C:
  LDA $6FDD,Y                           ; $A12C: B9 DD 6F
  AND #$7F                              ; $A12F: 29 7F
  CMP $0020                             ; $A131: CD 20 00
  BNE $A13F                             ; $A134: D0 09
  STA $6F8D                             ; $A136: 8D 8D 6F
  LDA #$01                              ; $A139: A9 01
  STA $6F8F                             ; $A13B: 8D 8F 6F
  RTS                                   ; $A13E: 60
Loc_A13F:
  INY                                   ; $A13F: C8
  CPY #$04                              ; $A140: C0 04
  BCC $A12C                             ; $A142: 90 E8
Loc_A144:
  LDX #$0A                              ; $A144: A2 0A
  LDA $0504                             ; $A146: AD 04 05
  BMI $A160                             ; $A149: 30 15
  LDA $0600,X                           ; $A14B: BD 00 06
  STA $0020                             ; $A14E: 8D 20 00
  LDA $0614,X                           ; $A151: BD 14 06
  CMP #$10                              ; $A154: C9 10
  BCC $A15A                             ; $A156: 90 02
  SBC #$01                              ; $A158: E9 01
Loc_A15A:
  STA $0021                             ; $A15A: 8D 21 00
  JMP $A163                             ; $A15D: 4C 63 A1
Loc_A160:
  JSR $A1E5                             ; $A160: 20 E5 A1
Loc_A163:
  JMP $A60C                             ; $A163: 4C 0C A6
; --- Data Region ---
  .byte $20,$0D,$AF,$90,$01,$60           ; $A166: 20 0D AF 90 01 60
Loc_A16C:
; --- Code Region ---
  JSR $AAF8                             ; $A16C: 20 F8 AA
  BCC $A172                             ; $A16F: 90 01
  RTS                                   ; $A171: 60
Loc_A172:
  LDY $6F8C                             ; $A172: AC 8C 6F
  JSR $A8A8                             ; $A175: 20 A8 A8
  BCC $A17B                             ; $A178: 90 01
  RTS                                   ; $A17A: 60
Loc_A17B:
  LDY $6F8C                             ; $A17B: AC 8C 6F
  LDA #$02                              ; $A17E: A9 02
  JSR $A8D3                             ; $A180: 20 D3 A8
  LDA #$FF                              ; $A183: A9 FF
  STA $0020                             ; $A185: 8D 20 00
  LDY #$00                              ; $A188: A0 00
Loc_A18A:
  LDA $6FC9,Y                           ; $A18A: B9 C9 6F
  BPL $A19C                             ; $A18D: 10 0D
  AND #$7F                              ; $A18F: 29 7F
  CMP $0020                             ; $A191: CD 20 00
  BCS $A19C                             ; $A194: B0 06
  STA $0020                             ; $A196: 8D 20 00
  STY $0021                             ; $A199: 8C 21 00
Loc_A19C:
  INY                                   ; $A19C: C8
  CPY #$14                              ; $A19D: C0 14
  BCC $A18A                             ; $A19F: 90 E9
  LDA $0020                             ; $A1A1: AD 20 00
  CMP #$FF                              ; $A1A4: C9 FF
  BEQ $A1C0                             ; $A1A6: F0 18
  LDY $0021                             ; $A1A8: AC 21 00
  LDA $0600,Y                           ; $A1AB: B9 00 06
  STA $0020                             ; $A1AE: 8D 20 00
  LDA $0614,Y                           ; $A1B1: B9 14 06
  CMP #$10                              ; $A1B4: C9 10
  BCC $A1BA                             ; $A1B6: 90 02
  SBC #$01                              ; $A1B8: E9 01
Loc_A1BA:
  STA $0021                             ; $A1BA: 8D 21 00
  JMP $A1DF                             ; $A1BD: 4C DF A1
Loc_A1C0:
  LDX #$0A                              ; $A1C0: A2 0A
  LDA $0504                             ; $A1C2: AD 04 05
  BMI $A1DC                             ; $A1C5: 30 15
  LDA $0600,X                           ; $A1C7: BD 00 06
  STA $0020                             ; $A1CA: 8D 20 00
  LDA $0614,X                           ; $A1CD: BD 14 06
  CMP #$10                              ; $A1D0: C9 10
  BCC $A1D6                             ; $A1D2: 90 02
  SBC #$01                              ; $A1D4: E9 01
Loc_A1D6:
  STA $0021                             ; $A1D6: 8D 21 00
  JMP $A1DF                             ; $A1D9: 4C DF A1
Loc_A1DC:
  JSR $A1E5                             ; $A1DC: 20 E5 A1
Loc_A1DF:
  LDY $6F8C                             ; $A1DF: AC 8C 6F
  JMP $A60C                             ; $A1E2: 4C 0C A6
Loc_A1E5:
  LDY #$26                              ; $A1E5: A0 26
  JSR $F266                             ; $A1E7: 20 66 F2
  LDA $050E                             ; $A1EA: AD 0E 05
  ASL                                   ; $A1ED: 0A
  TAY                                   ; $A1EE: A8
  LDA $8C52,Y                           ; $A1EF: B9 52 8C
  STA $0022                             ; $A1F2: 8D 22 00
  LDA $8C53,Y                           ; $A1F5: B9 53 8C
  STA $0023                             ; $A1F8: 8D 23 00
  LDY #$00                              ; $A1FB: A0 00
  LDA ($22),Y                           ; $A1FD: B1 22
  CMP #$10                              ; $A1FF: C9 10
  BCC $A206                             ; $A201: 90 03
  SEC                                   ; $A203: 38
  SBC #$01                              ; $A204: E9 01
Loc_A206:
  STA $0021                             ; $A206: 8D 21 00
  INY                                   ; $A209: C8
  LDA ($22),Y                           ; $A20A: B1 22
  STA $0020                             ; $A20C: 8D 20 00
  RTS                                   ; $A20F: 60
; --- Data Region ---
  .byte $20,$0D,$AF,$90,$01,$60           ; $A210: 20 0D AF 90 01 60
Loc_A216:
; --- Code Region ---
  JSR $AAF8                             ; $A216: 20 F8 AA
  BCC $A21C                             ; $A219: 90 01
  RTS                                   ; $A21B: 60
Loc_A21C:
  JSR $A8A8                             ; $A21C: 20 A8 A8
  BCC $A222                             ; $A21F: 90 01
  RTS                                   ; $A221: 60
Loc_A222:
  LDY #$00                              ; $A222: A0 00
  LDA $0504                             ; $A224: AD 04 05
  BPL $A22B                             ; $A227: 10 02
  LDY #$0A                              ; $A229: A0 0A
Loc_A22B:
  LDA #$02                              ; $A22B: A9 02
  JSR $A8D3                             ; $A22D: 20 D3 A8
  LDA #$FF                              ; $A230: A9 FF
  STA $0020                             ; $A232: 8D 20 00
  LDY #$00                              ; $A235: A0 00
Loc_A237:
  LDA $6FC9,Y                           ; $A237: B9 C9 6F
  BPL $A247                             ; $A23A: 10 0B
  CMP $0020                             ; $A23C: CD 20 00
  BCS $A247                             ; $A23F: B0 06
  STA $0020                             ; $A241: 8D 20 00
  STY $0021                             ; $A244: 8C 21 00
Loc_A247:
  INY                                   ; $A247: C8
  CPY #$14                              ; $A248: C0 14
  BCC $A237                             ; $A24A: 90 EB
  LDA $0020                             ; $A24C: AD 20 00
  CMP #$FF                              ; $A24F: C9 FF
  BEQ $A289                             ; $A251: F0 36
  LDY $0021                             ; $A253: AC 21 00
  STY $6F8E                             ; $A256: 8C 8E 6F
  JSR $A837                             ; $A259: 20 37 A8
  LDY #$00                              ; $A25C: A0 00
Loc_A25E:
  LDA $6FDD,Y                           ; $A25E: B9 DD 6F
  BMI $A26C                             ; $A261: 30 09
  BEQ $A26C                             ; $A263: F0 07
  CMP #$0A                              ; $A265: C9 0A
  BEQ $A26C                             ; $A267: F0 03
  JMP $A95C                             ; $A269: 4C 5C A9
Loc_A26C:
  INY                                   ; $A26C: C8
  CPY #$04                              ; $A26D: C0 04
  BCC $A25E                             ; $A26F: 90 ED
  LDY $6F8E                             ; $A271: AC 8E 6F
  LDA $0600,Y                           ; $A274: B9 00 06
  STA $0020                             ; $A277: 8D 20 00
  LDA $0614,Y                           ; $A27A: B9 14 06
  CMP #$10                              ; $A27D: C9 10
  BCC $A283                             ; $A27F: 90 02
  SBC #$01                              ; $A281: E9 01
Loc_A283:
  STA $0021                             ; $A283: 8D 21 00
  JMP $A60C                             ; $A286: 4C 0C A6
Loc_A289:
  JSR $A95C                             ; $A289: 20 5C A9
  BCC $A28F                             ; $A28C: 90 01
  RTS                                   ; $A28E: 60
Loc_A28F:
  LDX #$00                              ; $A28F: A2 00
  LDA $0504                             ; $A291: AD 04 05
  BPL $A298                             ; $A294: 10 02
  LDX #$0A                              ; $A296: A2 0A
Loc_A298:
  LDA $0600,X                           ; $A298: BD 00 06
  STA $0020                             ; $A29B: 8D 20 00
  LDA $0614,X                           ; $A29E: BD 14 06
  CMP #$10                              ; $A2A1: C9 10
  BCC $A2A7                             ; $A2A3: 90 02
  SBC #$01                              ; $A2A5: E9 01
Loc_A2A7:
  STA $0021                             ; $A2A7: 8D 21 00
  JMP $A60C                             ; $A2AA: 4C 0C A6
; --- Data Region ---
  .byte $20,$0D,$AF,$90,$01,$60           ; $A2AD: 20 0D AF 90 01 60
Loc_A2B3:
; --- Code Region ---
  JSR $AAF8                             ; $A2B3: 20 F8 AA
  BCC $A2B9                             ; $A2B6: 90 01
  RTS                                   ; $A2B8: 60
Loc_A2B9:
  JSR $A8A8                             ; $A2B9: 20 A8 A8
  BCC $A2BF                             ; $A2BC: 90 01
  RTS                                   ; $A2BE: 60
Loc_A2BF:
  LDY $6F8C                             ; $A2BF: AC 8C 6F
  LDA #$03                              ; $A2C2: A9 03
  JSR $A8D3                             ; $A2C4: 20 D3 A8
  LDA #$FF                              ; $A2C7: A9 FF
  STA $0020                             ; $A2C9: 8D 20 00
  LDY #$00                              ; $A2CC: A0 00
Loc_A2CE:
  LDA $6FC9,Y                           ; $A2CE: B9 C9 6F
  BPL $A2DE                             ; $A2D1: 10 0B
  CMP $0020                             ; $A2D3: CD 20 00
  BCS $A2DE                             ; $A2D6: B0 06
  STA $0020                             ; $A2D8: 8D 20 00
  STY $0021                             ; $A2DB: 8C 21 00
Loc_A2DE:
  INY                                   ; $A2DE: C8
  CPY #$14                              ; $A2DF: C0 14
  BCC $A2CE                             ; $A2E1: 90 EB
  LDA $0020                             ; $A2E3: AD 20 00
  CMP #$FF                              ; $A2E6: C9 FF
  BEQ $A305                             ; $A2E8: F0 1B
  LDY $0021                             ; $A2EA: AC 21 00
  STY $6F8E                             ; $A2ED: 8C 8E 6F
  LDA $0600,Y                           ; $A2F0: B9 00 06
  STA $0020                             ; $A2F3: 8D 20 00
  LDA $0614,Y                           ; $A2F6: B9 14 06
  CMP #$10                              ; $A2F9: C9 10
  BCC $A2FF                             ; $A2FB: 90 02
  SBC #$01                              ; $A2FD: E9 01
Loc_A2FF:
  STA $0021                             ; $A2FF: 8D 21 00
  JMP $A60C                             ; $A302: 4C 0C A6
Loc_A305:
  JSR $A95C                             ; $A305: 20 5C A9
  BCC $A30B                             ; $A308: 90 01
  RTS                                   ; $A30A: 60
Loc_A30B:
  LDX #$00                              ; $A30B: A2 00
  LDA $0504                             ; $A30D: AD 04 05
  BPL $A314                             ; $A310: 10 02
  LDX #$0A                              ; $A312: A2 0A
Loc_A314:
  LDA $0600,X                           ; $A314: BD 00 06
  STA $0020                             ; $A317: 8D 20 00
  LDA $0614,X                           ; $A31A: BD 14 06
  CMP #$10                              ; $A31D: C9 10
  BCC $A323                             ; $A31F: 90 02
  SBC #$01                              ; $A321: E9 01
Loc_A323:
  STA $0021                             ; $A323: 8D 21 00
  JMP $A60C                             ; $A326: 4C 0C A6
; --- Data Region ---
  .byte $A0,$31,$20,$66,$F2,$AD,$0E,$05,$0A,$8D,$20,$00,$0A,$18,$6D,$20; $A329: A0 31 20 66 F2 AD 0E 05 0A 8D 20 00 0A 18 6D 20
  .byte $00,$A8,$B9,$A4,$9B,$8D,$20,$00,$C8,$B9,$A4,$9B,$C9,$10,$90,$02; $A339: 00 A8 B9 A4 9B 8D 20 00 C8 B9 A4 9B C9 10 90 02
  .byte $E9,$01                           ; $A349: E9 01
Loc_A34B:
; --- Code Region ---
  STA $0021                             ; $A34B: 8D 21 00
  JSR $A60C                             ; $A34E: 20 0C A6
  LDA $6F8F                             ; $A351: AD 8F 6F
  BNE $A3AD                             ; $A354: D0 57
  LDY $6F8C                             ; $A356: AC 8C 6F
  LDA $0600,Y                           ; $A359: B9 00 06
  STA $0020                             ; $A35C: 8D 20 00
  LDA $0614,Y                           ; $A35F: B9 14 06
  STA $0021                             ; $A362: 8D 21 00
  LDY #$00                              ; $A365: A0 00
  LDA $6F8D                             ; $A367: AD 8D 6F
  AND #$02                              ; $A36A: 29 02
  BNE $A36F                             ; $A36C: D0 01
  INY                                   ; $A36E: C8
Loc_A36F:
  LDA $6F8D                             ; $A36F: AD 8D 6F
  AND #$01                              ; $A372: 29 01
  BEQ $A37B                             ; $A374: F0 05
  LDA #$01                              ; $A376: A9 01
  JMP $A37D                             ; $A378: 4C 7D A3
Loc_A37B:
  LDA #$FF                              ; $A37B: A9 FF
Loc_A37D:
  STA $0022                             ; $A37D: 8D 22 00
  LDA $0020,Y                           ; $A380: B9 20 00
  CLC                                   ; $A383: 18
  ADC $0022                             ; $A384: 6D 22 00
  STA $0020,Y                           ; $A387: 99 20 00
  LDY #$31                              ; $A38A: A0 31
  JSR $F266                             ; $A38C: 20 66 F2
  LDA $050E                             ; $A38F: AD 0E 05
  ASL                                   ; $A392: 0A
  STA $0022                             ; $A393: 8D 22 00
  ASL                                   ; $A396: 0A
  CLC                                   ; $A397: 18
  ADC $0022                             ; $A398: 6D 22 00
  TAY                                   ; $A39B: A8
  LDA $9BA4,Y                           ; $A39C: B9 A4 9B
  CMP $0020                             ; $A39F: CD 20 00
  BNE $A3AD                             ; $A3A2: D0 09
  INY                                   ; $A3A4: C8
  LDA $9BA4,Y                           ; $A3A5: B9 A4 9B
  CMP $0021                             ; $A3A8: CD 21 00
  BEQ $A3AE                             ; $A3AB: F0 01
Loc_A3AD:
  RTS                                   ; $A3AD: 60
Loc_A3AE:
  LDY $6F8C                             ; $A3AE: AC 8C 6F
  LDA $6FA1,Y                           ; $A3B1: B9 A1 6F
  AND #$F0                              ; $A3B4: 29 F0
  ORA #$07                              ; $A3B6: 09 07
  STA $6FA1,Y                           ; $A3B8: 99 A1 6F
  LDX #$00                              ; $A3BB: A2 00
  LDA $0504                             ; $A3BD: AD 04 05
  BPL $A3C4                             ; $A3C0: 10 02
  LDX #$02                              ; $A3C2: A2 02
Loc_A3C4:
  LDA $0526,X                           ; $A3C4: BD 26 05
  STA $0020                             ; $A3C7: 8D 20 00
  LDA $0527,X                           ; $A3CA: BD 27 05
  STA $0021                             ; $A3CD: 8D 21 00
  LDA #$00                              ; $A3D0: A9 00
  STA $0022                             ; $A3D2: 8D 22 00
  LDA #$07                              ; $A3D5: A9 07
  STA $0023                             ; $A3D7: 8D 23 00
  JSR $B585                             ; $A3DA: 20 85 B5
  LDA $0026                             ; $A3DD: AD 26 00
  STA $0020                             ; $A3E0: 8D 20 00
  LDA $0027                             ; $A3E3: AD 27 00
  STA $0021                             ; $A3E6: 8D 21 00
  LDA $0028                             ; $A3E9: AD 28 00
  STA $0022                             ; $A3EC: 8D 22 00
  LDA #$0A                              ; $A3EF: A9 0A
  STA $0023                             ; $A3F1: 8D 23 00
  LDA #$00                              ; $A3F4: A9 00
  STA $0024                             ; $A3F6: 8D 24 00
  JSR $B536                             ; $A3F9: 20 36 B5
  LDA $0020                             ; $A3FC: AD 20 00
  STA $0036                             ; $A3FF: 8D 36 00
  LDA $0021                             ; $A402: AD 21 00
  STA $0037                             ; $A405: 8D 37 00
  JSR $B0B8                             ; $A408: 20 B8 B0
  LDX #$00                              ; $A40B: A2 00
  LDA $0504                             ; $A40D: AD 04 05
  BPL $A414                             ; $A410: 10 02
  LDX #$02                              ; $A412: A2 02
Loc_A414:
  LDA $002A                             ; $A414: AD 2A 00
  SEC                                   ; $A417: 38
  SBC $0522,X                           ; $A418: FD 22 05
  STA $0038                             ; $A41B: 8D 38 00
  STA $0020                             ; $A41E: 8D 20 00
  LDA $002B                             ; $A421: AD 2B 00
  SBC $0523,X                           ; $A424: FD 23 05
  STA $0039                             ; $A427: 8D 39 00
  STA $0021                             ; $A42A: 8D 21 00
  LDA #$00                              ; $A42D: A9 00
  STA $0022                             ; $A42F: 8D 22 00
  LDA #$64                              ; $A432: A9 64
  STA $0023                             ; $A434: 8D 23 00
  JSR $B585                             ; $A437: 20 85 B5
  LDA $0026                             ; $A43A: AD 26 00
  STA $0020                             ; $A43D: 8D 20 00
  LDA $0027                             ; $A440: AD 27 00
  STA $0021                             ; $A443: 8D 21 00
  LDA $0028                             ; $A446: AD 28 00
  STA $0022                             ; $A449: 8D 22 00
  LDY #$30                              ; $A44C: A0 30
  JSR $F266                             ; $A44E: 20 66 F2
  LDA $050E                             ; $A451: AD 0E 05
  ASL                                   ; $A454: 0A
  TAY                                   ; $A455: A8
  INY                                   ; $A456: C8
  LDA $8FC0,Y                           ; $A457: B9 C0 8F
  STA $003A                             ; $A45A: 8D 3A 00
  STA $0023                             ; $A45D: 8D 23 00
  LDA #$00                              ; $A460: A9 00
  STA $0024                             ; $A462: 8D 24 00
  JSR $B536                             ; $A465: 20 36 B5
  LDX #$00                              ; $A468: A2 00
  LDA $0504                             ; $A46A: AD 04 05
  BPL $A471                             ; $A46D: 10 02
  LDX #$02                              ; $A46F: A2 02
Loc_A471:
  LDA $0036                             ; $A471: AD 36 00
  SEC                                   ; $A474: 38
  SBC $0020                             ; $A475: ED 20 00
  LDA $0037                             ; $A478: AD 37 00
  SBC $0021                             ; $A47B: ED 21 00
  BCC $A4A7                             ; $A47E: 90 27
  LDA $0526,X                           ; $A480: BD 26 05
  SEC                                   ; $A483: 38
  SBC $0020                             ; $A484: ED 20 00
  STA $0526,X                           ; $A487: 9D 26 05
  LDA $0527,X                           ; $A48A: BD 27 05
  SBC $0021                             ; $A48D: ED 21 00
  STA $0527,X                           ; $A490: 9D 27 05
  LDA $0522,X                           ; $A493: BD 22 05
  CLC                                   ; $A496: 18
  ADC $0038                             ; $A497: 6D 38 00
  STA $0522,X                           ; $A49A: 9D 22 05
  LDA $0523,X                           ; $A49D: BD 23 05
  ADC $0039                             ; $A4A0: 6D 39 00
  STA $0523,X                           ; $A4A3: 9D 23 05
  RTS                                   ; $A4A6: 60
Loc_A4A7:
  LDA $0036                             ; $A4A7: AD 36 00
  STA $0020                             ; $A4AA: 8D 20 00
  LDA $0037                             ; $A4AD: AD 37 00
  STA $0021                             ; $A4B0: 8D 21 00
  LDA #$00                              ; $A4B3: A9 00
  STA $0022                             ; $A4B5: 8D 22 00
  LDA $003A                             ; $A4B8: AD 3A 00
  STA $0023                             ; $A4BB: 8D 23 00
  JSR $B585                             ; $A4BE: 20 85 B5
  LDA $0026                             ; $A4C1: AD 26 00
  STA $0020                             ; $A4C4: 8D 20 00
  LDA $0027                             ; $A4C7: AD 27 00
  STA $0021                             ; $A4CA: 8D 21 00
  LDA $0028                             ; $A4CD: AD 28 00
  STA $0022                             ; $A4D0: 8D 22 00
  LDA #$00                              ; $A4D3: A9 00
  STA $0024                             ; $A4D5: 8D 24 00
  LDA #$64                              ; $A4D8: A9 64
  STA $0023                             ; $A4DA: 8D 23 00
  JSR $B536                             ; $A4DD: 20 36 B5
  LDA $0526,X                           ; $A4E0: BD 26 05
  SEC                                   ; $A4E3: 38
  SBC $0036                             ; $A4E4: ED 36 00
  STA $0526,X                           ; $A4E7: 9D 26 05
  LDA $0527,X                           ; $A4EA: BD 27 05
  SBC $0037                             ; $A4ED: ED 37 00
  STA $0527,X                           ; $A4F0: 9D 27 05
  LDA $0522,X                           ; $A4F3: BD 22 05
  CLC                                   ; $A4F6: 18
  ADC $0020                             ; $A4F7: 6D 20 00
  STA $0522,X                           ; $A4FA: 9D 22 05
  LDA $0523,X                           ; $A4FD: BD 23 05
  ADC $0021                             ; $A500: 6D 21 00
  STA $0523,X                           ; $A503: 9D 23 05
  RTS                                   ; $A506: 60
; --- Data Region ---
  .byte $A0,$31,$20,$66,$F2,$AD,$0E,$05,$0A,$8D,$20,$00,$0A,$18,$6D,$20; $A507: A0 31 20 66 F2 AD 0E 05 0A 8D 20 00 0A 18 6D 20
  .byte $00,$18,$69,$04,$A8,$B9,$A4,$9B,$8D,$20,$00,$C8,$B9,$A4,$9B,$C9; $A517: 00 18 69 04 A8 B9 A4 9B 8D 20 00 C8 B9 A4 9B C9
  .byte $10,$90,$02,$E9,$01               ; $A527: 10 90 02 E9 01
Loc_A52C:
; --- Code Region ---
  STA $0021                             ; $A52C: 8D 21 00
  STA $0021                             ; $A52F: 8D 21 00
  JSR $A60C                             ; $A532: 20 0C A6
  LDA $6F8F                             ; $A535: AD 8F 6F
  BNE $A594                             ; $A538: D0 5A
  LDY $6F8C                             ; $A53A: AC 8C 6F
  LDA $0600,Y                           ; $A53D: B9 00 06
  STA $0020                             ; $A540: 8D 20 00
  LDA $0614,Y                           ; $A543: B9 14 06
  STA $0021                             ; $A546: 8D 21 00
  LDY #$00                              ; $A549: A0 00
  LDA $6F8D                             ; $A54B: AD 8D 6F
  AND #$02                              ; $A54E: 29 02
  BNE $A553                             ; $A550: D0 01
  INY                                   ; $A552: C8
Loc_A553:
  LDA $6F8D                             ; $A553: AD 8D 6F
  AND #$01                              ; $A556: 29 01
  BEQ $A55F                             ; $A558: F0 05
  LDA #$01                              ; $A55A: A9 01
  JMP $A561                             ; $A55C: 4C 61 A5
Loc_A55F:
  LDA #$FF                              ; $A55F: A9 FF
Loc_A561:
  STA $0022                             ; $A561: 8D 22 00
  LDA $0020,Y                           ; $A564: B9 20 00
  CLC                                   ; $A567: 18
  ADC $0022                             ; $A568: 6D 22 00
  STA $0020,Y                           ; $A56B: 99 20 00
  LDY #$31                              ; $A56E: A0 31
  JSR $F266                             ; $A570: 20 66 F2
  LDA $050E                             ; $A573: AD 0E 05
  ASL                                   ; $A576: 0A
  STA $0022                             ; $A577: 8D 22 00
  ASL                                   ; $A57A: 0A
  CLC                                   ; $A57B: 18
  ADC $0022                             ; $A57C: 6D 22 00
  CLC                                   ; $A57F: 18
  ADC #$04                              ; $A580: 69 04
  TAY                                   ; $A582: A8
  LDA $9BA4,Y                           ; $A583: B9 A4 9B
  CMP $0020                             ; $A586: CD 20 00
  BNE $A594                             ; $A589: D0 09
  INY                                   ; $A58B: C8
  LDA $9BA4,Y                           ; $A58C: B9 A4 9B
  CMP $0021                             ; $A58F: CD 21 00
  BEQ $A595                             ; $A592: F0 01
Loc_A594:
  RTS                                   ; $A594: 60
Loc_A595:
  LDY $6F8C                             ; $A595: AC 8C 6F
  LDA $6FA1,Y                           ; $A598: B9 A1 6F
  AND #$F0                              ; $A59B: 29 F0
  ORA #$07                              ; $A59D: 09 07
  STA $6FA1,Y                           ; $A59F: 99 A1 6F
  LDX #$00                              ; $A5A2: A2 00
  LDA $0504                             ; $A5A4: AD 04 05
  BPL $A5AB                             ; $A5A7: 10 02
  LDX #$02                              ; $A5A9: A2 02
Loc_A5AB:
  LDA $0527,X                           ; $A5AB: BD 27 05
  BNE $A5B8                             ; $A5AE: D0 08
  LDA $0526,X                           ; $A5B0: BD 26 05
  CMP #$32                              ; $A5B3: C9 32
  BCS $A5B8                             ; $A5B5: B0 01
  RTS                                   ; $A5B7: 60
Loc_A5B8:
  LDA $0526,X                           ; $A5B8: BD 26 05
  SEC                                   ; $A5BB: 38
  SBC #$32                              ; $A5BC: E9 32
  STA $0526,X                           ; $A5BE: 9D 26 05
  LDA $0527,X                           ; $A5C1: BD 27 05
  SBC #$00                              ; $A5C4: E9 00
  STA $0527,X                           ; $A5C6: 9D 27 05
Loc_A5C9:
  JSR $B5D5                             ; $A5C9: 20 D5 B5
  AND #$0F                              ; $A5CC: 29 0F
  CMP #$0B                              ; $A5CE: C9 0B
  BCS $A5C9                             ; $A5D0: B0 F7
  CLC                                   ; $A5D2: 18
  ADC #$23                              ; $A5D3: 69 23
  STA $002A                             ; $A5D5: 8D 2A 00
  LDY $6F8C                             ; $A5D8: AC 8C 6F
  LDA $0664,Y                           ; $A5DB: B9 64 06
  STA $002C                             ; $A5DE: 8D 2C 00
  JSR $B4E1                             ; $A5E1: 20 E1 B4
  LDY #$00                              ; $A5E4: A0 00
  LDA ($20),Y                           ; $A5E6: B1 20
  STA $002B                             ; $A5E8: 8D 2B 00
  LDA $002C                             ; $A5EB: AD 2C 00
  JSR $B491                             ; $A5EE: 20 91 B4
  LDY #$00                              ; $A5F1: A0 00
  LDA ($20),Y                           ; $A5F3: B1 20
  CLC                                   ; $A5F5: 18
  ADC $002A                             ; $A5F6: 6D 2A 00
  STA ($20),Y                           ; $A5F9: 91 20
  CMP $002B                             ; $A5FB: CD 2B 00
  BCC $A605                             ; $A5FE: 90 05
  LDA $002B                             ; $A600: AD 2B 00
  STA ($20),Y                           ; $A603: 91 20
Loc_A605:
  RTS                                   ; $A605: 60
; --- Data Region ---
  .byte $A9,$03,$8D,$8F,$6F,$60           ; $A606: A9 03 8D 8F 6F 60
Loc_A60C:
; --- Code Region ---
  LDY $6F8C                             ; $A60C: AC 8C 6F
  JSR $A837                             ; $A60F: 20 37 A8
  LDY $6F8C                             ; $A612: AC 8C 6F
  LDA $0020                             ; $A615: AD 20 00
  SEC                                   ; $A618: 38
  SBC $0600,Y                           ; $A619: F9 00 06
  STA $0020                             ; $A61C: 8D 20 00
  BPL $A626                             ; $A61F: 10 05
  EOR #$FF                              ; $A621: 49 FF
  CLC                                   ; $A623: 18
  ADC #$01                              ; $A624: 69 01
Loc_A626:
  STA $0022                             ; $A626: 8D 22 00
  LDA $0614,Y                           ; $A629: B9 14 06
  CMP #$10                              ; $A62C: C9 10
  BCC $A633                             ; $A62E: 90 03
  SEC                                   ; $A630: 38
  SBC #$01                              ; $A631: E9 01
Loc_A633:
  STA $0023                             ; $A633: 8D 23 00
  LDA $0021                             ; $A636: AD 21 00
  SEC                                   ; $A639: 38
  SBC $0023                             ; $A63A: ED 23 00
  STA $0021                             ; $A63D: 8D 21 00
  BPL $A647                             ; $A640: 10 05
  EOR #$FF                              ; $A642: 49 FF
  CLC                                   ; $A644: 18
  ADC #$01                              ; $A645: 69 01
Loc_A647:
  STA $0023                             ; $A647: 8D 23 00
  LDY #$00                              ; $A64A: A0 00
  LDA $0023                             ; $A64C: AD 23 00
  CMP $0022                             ; $A64F: CD 22 00
  BCS $A660                             ; $A652: B0 0C
  JSR $A728                             ; $A654: 20 28 A7
  INY                                   ; $A657: C8
  JSR $A733                             ; $A658: 20 33 A7
  LDY #$01                              ; $A65B: A0 01
  JMP $A669                             ; $A65D: 4C 69 A6
Loc_A660:
  JSR $A733                             ; $A660: 20 33 A7
  INY                                   ; $A663: C8
  JSR $A728                             ; $A664: 20 28 A7
  LDY #$00                              ; $A667: A0 00
Loc_A669:
  LDA $0022,Y                           ; $A669: B9 22 00
  BNE $A67E                             ; $A66C: D0 10
  LDA #$FF                              ; $A66E: A9 FF
  STA $002B                             ; $A670: 8D 2B 00
  TYA                                   ; $A673: 98
  EOR #$01                              ; $A674: 49 01
  TAY                                   ; $A676: A8
  LDA $0022,Y                           ; $A677: B9 22 00
  CMP #$01                              ; $A67A: C9 01
  BNE $A67E                             ; $A67C: D0 00
Loc_A67E:
  LDY #$00                              ; $A67E: A0 00
Loc_A680:
  LDA $002A,Y                           ; $A680: B9 2A 00
  CMP #$FF                              ; $A683: C9 FF
  BEQ $A6A7                             ; $A685: F0 20
  TAX                                   ; $A687: AA
  TYA                                   ; $A688: 98
  PHA                                   ; $A689: 48
  JSR $A740                             ; $A68A: 20 40 A7
  BCS $A691                             ; $A68D: B0 02
  LDY #$0F                              ; $A68F: A0 0F
Loc_A691:
  TYA                                   ; $A691: 98
  ASL                                   ; $A692: 0A
  ASL                                   ; $A693: 0A
  ASL                                   ; $A694: 0A
  ASL                                   ; $A695: 0A
  STA $0022                             ; $A696: 8D 22 00
  PLA                                   ; $A699: 68
  TAY                                   ; $A69A: A8
  LDA $002A,Y                           ; $A69B: B9 2A 00
  ORA $0022                             ; $A69E: 0D 22 00
  STA $002A,Y                           ; $A6A1: 99 2A 00
  LDA $0022                             ; $A6A4: AD 22 00
Loc_A6A7:
  STA $002C,Y                           ; $A6A7: 99 2C 00
  INY                                   ; $A6AA: C8
  CPY #$02                              ; $A6AB: C0 02
  BCC $A680                             ; $A6AD: 90 D1
  LDA $002C                             ; $A6AF: AD 2C 00
  CMP $002D                             ; $A6B2: CD 2D 00
  BEQ $A6C7                             ; $A6B5: F0 10
  BCC $A6C7                             ; $A6B7: 90 0E
  LDA $002B                             ; $A6B9: AD 2B 00
  TAX                                   ; $A6BC: AA
  LDA $002A                             ; $A6BD: AD 2A 00
  STA $002B                             ; $A6C0: 8D 2B 00
  TXA                                   ; $A6C3: 8A
  STA $002A                             ; $A6C4: 8D 2A 00
Loc_A6C7:
  LDY $6F8C                             ; $A6C7: AC 8C 6F
  LDA $6FB5,Y                           ; $A6CA: B9 B5 6F
  STA $002F                             ; $A6CD: 8D 2F 00
  LDY #$00                              ; $A6D0: A0 00
Loc_A6D2:
  LDA $002A,Y                           ; $A6D2: B9 2A 00
  CMP #$F0                              ; $A6D5: C9 F0
  BCS $A6E6                             ; $A6D7: B0 0D
  STA $0020                             ; $A6D9: 8D 20 00
  AND #$0F                              ; $A6DC: 29 0F
  TAX                                   ; $A6DE: AA
  LDA $6FDD,X                           ; $A6DF: BD DD 6F
  CMP #$FF                              ; $A6E2: C9 FF
  BEQ $A702                             ; $A6E4: F0 1C
Loc_A6E6:
  INY                                   ; $A6E6: C8
  CPY #$02                              ; $A6E7: C0 02
  BCC $A6D2                             ; $A6E9: 90 E7
  LDY $6F8C                             ; $A6EB: AC 8C 6F
  LDA $6FA1,Y                           ; $A6EE: B9 A1 6F
  CMP #$01                              ; $A6F1: C9 01
  BEQ $A6FF                             ; $A6F3: F0 0A
  CMP #$05                              ; $A6F5: C9 05
  BEQ $A6FF                             ; $A6F7: F0 06
Loc_A6F9:
  LDA #$03                              ; $A6F9: A9 03
  STA $6F8F                             ; $A6FB: 8D 8F 6F
  RTS                                   ; $A6FE: 60
Loc_A6FF:
  JMP $A805                             ; $A6FF: 4C 05 A8
Loc_A702:
  LDY $6F8C                             ; $A702: AC 8C 6F
  LDA $0650,Y                           ; $A705: B9 50 06
  BNE $A6F9                             ; $A708: D0 EF
  STX $6F8D                             ; $A70A: 8E 8D 6F
  LDA #$00                              ; $A70D: A9 00
  STA $6F8F                             ; $A70F: 8D 8F 6F
  LDA $0020                             ; $A712: AD 20 00
  LSR                                   ; $A715: 4A
  LSR                                   ; $A716: 4A
  LSR                                   ; $A717: 4A
  LSR                                   ; $A718: 4A
  STA $6F97                             ; $A719: 8D 97 6F
  LDY $6F8C                             ; $A71C: AC 8C 6F
  LDA $6F8D                             ; $A71F: AD 8D 6F
  EOR #$01                              ; $A722: 49 01
  STA $6FB5,Y                           ; $A724: 99 B5 6F
  RTS                                   ; $A727: 60
Loc_A728:
  LDX #$02                              ; $A728: A2 02
  LDA $0020                             ; $A72A: AD 20 00
  BMI $A73B                             ; $A72D: 30 0C
  INX                                   ; $A72F: E8
  JMP $A73B                             ; $A730: 4C 3B A7
Loc_A733:
  LDX #$00                              ; $A733: A2 00
  LDA $0021                             ; $A735: AD 21 00
  BMI $A73B                             ; $A738: 30 01
  INX                                   ; $A73A: E8
Loc_A73B:
  TXA                                   ; $A73B: 8A
  STA $002A,Y                           ; $A73C: 99 2A 00
  RTS                                   ; $A73F: 60
Loc_A740:
  LDA #$00                              ; $A740: A9 00
  STA $0020                             ; $A742: 8D 20 00
  STA $0021                             ; $A745: 8D 21 00
  LDA #$01                              ; $A748: A9 01
  STA $0022                             ; $A74A: 8D 22 00
  TXA                                   ; $A74D: 8A
  AND #$01                              ; $A74E: 29 01
  BNE $A757                             ; $A750: D0 05
  LDA #$FF                              ; $A752: A9 FF
  STA $0022                             ; $A754: 8D 22 00
Loc_A757:
  TXA                                   ; $A757: 8A
  LSR                                   ; $A758: 4A
  AND #$01                              ; $A759: 29 01
  EOR #$01                              ; $A75B: 49 01
  TAX                                   ; $A75D: AA
  LDA $0022                             ; $A75E: AD 22 00
  STA $0020,X                           ; $A761: 9D 20 00
  LDX $6F8C                             ; $A764: AE 8C 6F
  LDA $0600,X                           ; $A767: BD 00 06
  CLC                                   ; $A76A: 18
  ADC $0020                             ; $A76B: 6D 20 00
  STA $0020                             ; $A76E: 8D 20 00
  BMI $A777                             ; $A771: 30 04
  CMP #$1F                              ; $A773: C9 1F
  BCC $A779                             ; $A775: 90 02
Loc_A777:
  CLC                                   ; $A777: 18
  RTS                                   ; $A778: 60
Loc_A779:
  LDA $0614,X                           ; $A779: BD 14 06
  CLC                                   ; $A77C: 18
  ADC $0021                             ; $A77D: 6D 21 00
  STA $0021                             ; $A780: 8D 21 00
  BMI $A777                             ; $A783: 30 F2
  CMP #$14                              ; $A785: C9 14
  BCS $A777                             ; $A787: B0 EE
  JSR $B6E5                             ; $A789: 20 E5 B6
  PHA                                   ; $A78C: 48
  LDY $6F8C                             ; $A78D: AC 8C 6F
  LDA $0664,Y                           ; $A790: B9 64 06
  JSR $B491                             ; $A793: 20 91 B4
  LDY #$0B                              ; $A796: A0 0B
  LDA ($20),Y                           ; $A798: B1 20
  LSR                                   ; $A79A: 4A
  LSR                                   ; $A79B: 4A
  AND #$03                              ; $A79C: 29 03
  STA $0022                             ; $A79E: 8D 22 00
  PLA                                   ; $A7A1: 68
  ASL                                   ; $A7A2: 0A
  ASL                                   ; $A7A3: 0A
  ORA $0022                             ; $A7A4: 0D 22 00
  TAX                                   ; $A7A7: AA
  LDY #$08                              ; $A7A8: A0 08
  LDA ($20),Y                           ; $A7AA: B1 20
  SEC                                   ; $A7AC: 38
  SBC #$59                              ; $A7AD: E9 59
  LDA ($20),Y                           ; $A7AF: B1 20
  SBC #$02                              ; $A7B1: E9 02
  BCC $A7C1                             ; $A7B3: 90 0C
  LDA $A7CD,X                           ; $A7B5: BD CD A7
  TAY                                   ; $A7B8: A8
  LDA $0505                             ; $A7B9: AD 05 05
  SEC                                   ; $A7BC: 38
  SBC $A7CD,X                           ; $A7BD: FD CD A7
  RTS                                   ; $A7C0: 60
Loc_A7C1:
  LDA $A7E9,X                           ; $A7C1: BD E9 A7
  TAY                                   ; $A7C4: A8
  LDA $0505                             ; $A7C5: AD 05 05
  SEC                                   ; $A7C8: 38
  SBC $A7E9,X                           ; $A7C9: FD E9 A7
  RTS                                   ; $A7CC: 60
; --- Data Region ---
  .byte $03,$05,$05,$00,$04,$04,$04,$00,$02,$03,$03,$00,$05,$06,$03,$00; $A7CD: 03 05 05 00 04 04 04 00 02 03 03 00 05 06 03 00
  .byte $05,$03,$06,$00,$06,$06,$06,$00,$06,$06,$06,$00,$02,$03,$03,$00; $A7DD: 05 03 06 00 06 06 06 00 06 06 06 00 02 03 03 00
  .byte $03,$03,$03,$00,$01,$02,$02,$00,$03,$05,$02,$00,$03,$02,$04,$00; $A7ED: 03 03 03 00 01 02 02 00 03 05 02 00 03 02 04 00
  .byte $04,$04,$04,$00,$04,$04,$04,$00   ; $A7FD: 04 04 04 00 04 04 04 00
Loc_A805:
; --- Code Region ---
  LDY #$00                              ; $A805: A0 00
Loc_A807:
  LDA $002A,Y                           ; $A807: B9 2A 00
  CMP #$F0                              ; $A80A: C9 F0
  BCS $A82C                             ; $A80C: B0 1E
  AND #$0F                              ; $A80E: 29 0F
  TAX                                   ; $A810: AA
  LDA $6FDD,X                           ; $A811: BD DD 6F
  BPL $A82C                             ; $A814: 10 16
  CMP #$FF                              ; $A816: C9 FF
  BEQ $A82C                             ; $A818: F0 12
  AND #$7F                              ; $A81A: 29 7F
  STA $6F8D                             ; $A81C: 8D 8D 6F
  LDA $0505                             ; $A81F: AD 05 05
  CMP #$02                              ; $A822: C9 02
  BCC $A82C                             ; $A824: 90 06
  LDA #$01                              ; $A826: A9 01
  STA $6F8F                             ; $A828: 8D 8F 6F
  RTS                                   ; $A82B: 60
Loc_A82C:
  INY                                   ; $A82C: C8
  CPY #$02                              ; $A82D: C0 02
  BCC $A807                             ; $A82F: 90 D6
  LDA #$03                              ; $A831: A9 03
  STA $6F8F                             ; $A833: 8D 8F 6F
  RTS                                   ; $A836: 60
Loc_A837:
  LDA $0600,Y                           ; $A837: B9 00 06
  STA $0022                             ; $A83A: 8D 22 00
  LDA $0614,Y                           ; $A83D: B9 14 06
  CMP #$10                              ; $A840: C9 10
  BCC $A847                             ; $A842: 90 03
  SEC                                   ; $A844: 38
  SBC #$01                              ; $A845: E9 01
Loc_A847:
  STA $0023                             ; $A847: 8D 23 00
  DEC $0023                             ; $A84A: CE 23 00
  LDX #$00                              ; $A84D: A2 00
  JSR $A871                             ; $A84F: 20 71 A8
  INC $0023                             ; $A852: EE 23 00
  INC $0023                             ; $A855: EE 23 00
  INX                                   ; $A858: E8
  JSR $A871                             ; $A859: 20 71 A8
  DEC $0023                             ; $A85C: CE 23 00
  DEC $0022                             ; $A85F: CE 22 00
  INX                                   ; $A862: E8
  JSR $A871                             ; $A863: 20 71 A8
  INC $0022                             ; $A866: EE 22 00
  INC $0022                             ; $A869: EE 22 00
  INX                                   ; $A86C: E8
  JSR $A871                             ; $A86D: 20 71 A8
  RTS                                   ; $A870: 60
Loc_A871:
  LDY #$00                              ; $A871: A0 00
Loc_A873:
  LDA $0664,Y                           ; $A873: B9 64 06
  CMP #$FF                              ; $A876: C9 FF
  BEQ $A89D                             ; $A878: F0 23
  LDA $0600,Y                           ; $A87A: B9 00 06
  CMP $0022                             ; $A87D: CD 22 00
  BNE $A89D                             ; $A880: D0 1B
  LDA $0614,Y                           ; $A882: B9 14 06
  CMP #$10                              ; $A885: C9 10
  BCC $A88B                             ; $A887: 90 02
  SBC #$01                              ; $A889: E9 01
Loc_A88B:
  CMP $0023                             ; $A88B: CD 23 00
  BNE $A89D                             ; $A88E: D0 0D
  STY $0024                             ; $A890: 8C 24 00
  JSR $A944                             ; $A893: 20 44 A9
  ORA $0024                             ; $A896: 0D 24 00
  STA $6FDD,X                           ; $A899: 9D DD 6F
  RTS                                   ; $A89C: 60
Loc_A89D:
  INY                                   ; $A89D: C8
  CPY #$14                              ; $A89E: C0 14
  BCC $A873                             ; $A8A0: 90 D1
  LDA #$FF                              ; $A8A2: A9 FF
  STA $6FDD,X                           ; $A8A4: 9D DD 6F
  RTS                                   ; $A8A7: 60
Loc_A8A8:
  LDA $0505                             ; $A8A8: AD 05 05
  CMP #$02                              ; $A8AB: C9 02
  BCC $A8D1                             ; $A8AD: 90 22
  LDY $6F8C                             ; $A8AF: AC 8C 6F
  JSR $A837                             ; $A8B2: 20 37 A8
  LDX #$00                              ; $A8B5: A2 00
Loc_A8B7:
  LDA $6FDD,X                           ; $A8B7: BD DD 6F
  CMP #$FF                              ; $A8BA: C9 FF
  BEQ $A8CC                             ; $A8BC: F0 0E
  BPL $A8CC                             ; $A8BE: 10 0C
  AND #$7F                              ; $A8C0: 29 7F
  STA $6F8D                             ; $A8C2: 8D 8D 6F
  LDA #$01                              ; $A8C5: A9 01
  STA $6F8F                             ; $A8C7: 8D 8F 6F
  SEC                                   ; $A8CA: 38
  RTS                                   ; $A8CB: 60
Loc_A8CC:
  INX                                   ; $A8CC: E8
  CPX #$04                              ; $A8CD: E0 04
  BCC $A8B7                             ; $A8CF: 90 E6
Loc_A8D1:
  CLC                                   ; $A8D1: 18
  RTS                                   ; $A8D2: 60
Loc_A8D3:
  STA $0022                             ; $A8D3: 8D 22 00
  LDA $0600,Y                           ; $A8D6: B9 00 06
  STA $0020                             ; $A8D9: 8D 20 00
  LDA $0614,Y                           ; $A8DC: B9 14 06
  CMP #$10                              ; $A8DF: C9 10
  BCC $A8E5                             ; $A8E1: 90 02
  SBC #$01                              ; $A8E3: E9 01
Loc_A8E5:
  STA $0021                             ; $A8E5: 8D 21 00
Loc_A8E8:
  LDY #$00                              ; $A8E8: A0 00
Loc_A8EA:
  LDA #$00                              ; $A8EA: A9 00
  STA $6FC9,Y                           ; $A8EC: 99 C9 6F
  LDA $0664,Y                           ; $A8EF: B9 64 06
  CMP #$FF                              ; $A8F2: C9 FF
  BEQ $A93E                             ; $A8F4: F0 48
  LDA $0600,Y                           ; $A8F6: B9 00 06
  SEC                                   ; $A8F9: 38
  SBC $0020                             ; $A8FA: ED 20 00
  BPL $A904                             ; $A8FD: 10 05
  EOR #$FF                              ; $A8FF: 49 FF
  CLC                                   ; $A901: 18
  ADC #$01                              ; $A902: 69 01
Loc_A904:
  CMP $0022                             ; $A904: CD 22 00
  BEQ $A90E                             ; $A907: F0 05
  BCC $A90E                             ; $A909: 90 03
  JMP $A93E                             ; $A90B: 4C 3E A9
Loc_A90E:
  STA $0023                             ; $A90E: 8D 23 00
  LDA $0614,Y                           ; $A911: B9 14 06
  CMP #$10                              ; $A914: C9 10
  BCC $A91A                             ; $A916: 90 02
  SBC #$01                              ; $A918: E9 01
Loc_A91A:
  SEC                                   ; $A91A: 38
  SBC $0021                             ; $A91B: ED 21 00
  BPL $A925                             ; $A91E: 10 05
  EOR #$FF                              ; $A920: 49 FF
  CLC                                   ; $A922: 18
  ADC #$01                              ; $A923: 69 01
Loc_A925:
  CMP $0022                             ; $A925: CD 22 00
  BEQ $A92F                             ; $A928: F0 05
  BCC $A92F                             ; $A92A: 90 03
  JMP $A93E                             ; $A92C: 4C 3E A9
Loc_A92F:
  ADC $0023                             ; $A92F: 6D 23 00
  STA $0023                             ; $A932: 8D 23 00
  JSR $A944                             ; $A935: 20 44 A9
  ORA $0023                             ; $A938: 0D 23 00
  STA $6FC9,Y                           ; $A93B: 99 C9 6F
Loc_A93E:
  INY                                   ; $A93E: C8
  CPY #$14                              ; $A93F: C0 14
  BCC $A8EA                             ; $A941: 90 A7
  RTS                                   ; $A943: 60
Loc_A944:
  LDA $0504                             ; $A944: AD 04 05
  BMI $A951                             ; $A947: 30 08
  LDA $0628,Y                           ; $A949: B9 28 06
  BMI $A959                             ; $A94C: 30 0B
  LDA #$00                              ; $A94E: A9 00
  RTS                                   ; $A950: 60
Loc_A951:
  LDA $0628,Y                           ; $A951: B9 28 06
  BPL $A959                             ; $A954: 10 03
  LDA #$00                              ; $A956: A9 00
  RTS                                   ; $A958: 60
Loc_A959:
  LDA #$80                              ; $A959: A9 80
  RTS                                   ; $A95B: 60
Loc_A95C:
  LDY $6F8C                             ; $A95C: AC 8C 6F
  LDA $0664,Y                           ; $A95F: B9 64 06
  JSR $B491                             ; $A962: 20 91 B4
  LDY #$02                              ; $A965: A0 02
  LDX #$01                              ; $A967: A2 01
  LDA ($20),Y                           ; $A969: B1 20
  CMP #$28                              ; $A96B: C9 28
  BCC $A983                             ; $A96D: 90 14
  LDX #$03                              ; $A96F: A2 03
  CMP #$3C                              ; $A971: C9 3C
  BCC $A983                             ; $A973: 90 0E
  LDX #$05                              ; $A975: A2 05
  CMP #$4B                              ; $A977: C9 4B
  BCC $A983                             ; $A979: 90 08
  LDX #$07                              ; $A97B: A2 07
  CMP #$55                              ; $A97D: C9 55
  BCC $A983                             ; $A97F: 90 02
  LDX #$09                              ; $A981: A2 09
Loc_A983:
  STX $002A                             ; $A983: 8E 2A 00
  LDY $6F8C                             ; $A986: AC 8C 6F
  LDA #$05                              ; $A989: A9 05
  JSR $A8D3                             ; $A98B: 20 D3 A8
  JSR $AE93                             ; $A98E: 20 93 AE
  LDY #$00                              ; $A991: A0 00
Loc_A993:
  LDA $6FC9,Y                           ; $A993: B9 C9 6F
  CMP #$FF                              ; $A996: C9 FF
  BEQ $A9C8                             ; $A998: F0 2E
  TAX                                   ; $A99A: AA
  LDA $0664,X                           ; $A99B: BD 64 06
  CMP #$FF                              ; $A99E: C9 FF
  BEQ $A9C3                             ; $A9A0: F0 21
  STX $002B                             ; $A9A2: 8E 2B 00
  STY $002F                             ; $A9A5: 8C 2F 00
  JSR $A9CF                             ; $A9A8: 20 CF A9
  BCC $A9C0                             ; $A9AB: 90 13
  LDA $002C                             ; $A9AD: AD 2C 00
  STA $6F8D                             ; $A9B0: 8D 8D 6F
  LDA $002B                             ; $A9B3: AD 2B 00
  STA $6F8E                             ; $A9B6: 8D 8E 6F
  LDA #$02                              ; $A9B9: A9 02
  STA $6F8F                             ; $A9BB: 8D 8F 6F
  SEC                                   ; $A9BE: 38
  RTS                                   ; $A9BF: 60
Loc_A9C0:
  LDY $002F                             ; $A9C0: AC 2F 00
Loc_A9C3:
  INY                                   ; $A9C3: C8
  CPY #$14                              ; $A9C4: C0 14
  BCC $A993                             ; $A9C6: 90 CB
Loc_A9C8:
  LDA #$03                              ; $A9C8: A9 03
  STA $6F8F                             ; $A9CA: 8D 8F 6F
  CLC                                   ; $A9CD: 18
  RTS                                   ; $A9CE: 60
Loc_A9CF:
  LDY $002B                             ; $A9CF: AC 2B 00
  LDA $0664,Y                           ; $A9D2: B9 64 06
  JSR $B491                             ; $A9D5: 20 91 B4
  LDY #$09                              ; $A9D8: A0 09
  LDA ($20),Y                           ; $A9DA: B1 20
  BNE $A9E5                             ; $A9DC: D0 07
  DEY                                   ; $A9DE: 88
  LDA ($20),Y                           ; $A9DF: B1 20
  BNE $A9E5                             ; $A9E1: D0 02
  LDA #$00                              ; $A9E3: A9 00
Loc_A9E5:
  STA $002D                             ; $A9E5: 8D 2D 00
  LDA $002A                             ; $A9E8: AD 2A 00
  CMP #$06                              ; $A9EB: C9 06
  BCC $AA03                             ; $A9ED: 90 14
  LDA $002D                             ; $A9EF: AD 2D 00
  BEQ $AA03                             ; $A9F2: F0 0F
  LDA $0505                             ; $A9F4: AD 05 05
  CMP #$08                              ; $A9F7: C9 08
  BCC $AA03                             ; $A9F9: 90 08
  LDX #$06                              ; $A9FB: A2 06
  JSR $AC7B                             ; $A9FD: 20 7B AC
  BCC $AA03                             ; $AA00: 90 01
  RTS                                   ; $AA02: 60
Loc_AA03:
  LDA $002A                             ; $AA03: AD 2A 00
  CMP #$05                              ; $AA06: C9 05
  BCC $AA19                             ; $AA08: 90 0F
  LDA $0505                             ; $AA0A: AD 05 05
  CMP #$08                              ; $AA0D: C9 08
  BCC $AA19                             ; $AA0F: 90 08
  LDX #$05                              ; $AA11: A2 05
  JSR $AC7B                             ; $AA13: 20 7B AC
  BCC $AA19                             ; $AA16: 90 01
  RTS                                   ; $AA18: 60
Loc_AA19:
  LDA $002A                             ; $AA19: AD 2A 00
  CMP #$08                              ; $AA1C: C9 08
  BCC $AA2F                             ; $AA1E: 90 0F
  LDA $0505                             ; $AA20: AD 05 05
  CMP #$0A                              ; $AA23: C9 0A
  BCC $AA2F                             ; $AA25: 90 08
  LDX #$08                              ; $AA27: A2 08
  JSR $AC7B                             ; $AA29: 20 7B AC
  BCC $AA2F                             ; $AA2C: 90 01
  RTS                                   ; $AA2E: 60
Loc_AA2F:
  LDA $002A                             ; $AA2F: AD 2A 00
  CMP #$09                              ; $AA32: C9 09
  BCC $AA4A                             ; $AA34: 90 14
  LDA $002D                             ; $AA36: AD 2D 00
  BEQ $AA4A                             ; $AA39: F0 0F
  LDA $0505                             ; $AA3B: AD 05 05
  CMP #$09                              ; $AA3E: C9 09
  BCC $AA4A                             ; $AA40: 90 08
  LDX #$09                              ; $AA42: A2 09
  JSR $AC7B                             ; $AA44: 20 7B AC
  BCC $AA4A                             ; $AA47: 90 01
  RTS                                   ; $AA49: 60
Loc_AA4A:
  LDA $002A                             ; $AA4A: AD 2A 00
  CMP #$07                              ; $AA4D: C9 07
  BCC $AA65                             ; $AA4F: 90 14
  LDA $002D                             ; $AA51: AD 2D 00
  BEQ $AA65                             ; $AA54: F0 0F
  LDA $0505                             ; $AA56: AD 05 05
  CMP #$08                              ; $AA59: C9 08
  BCC $AA65                             ; $AA5B: 90 08
  LDX #$07                              ; $AA5D: A2 07
  JSR $AC7B                             ; $AA5F: 20 7B AC
  BCC $AA65                             ; $AA62: 90 01
  RTS                                   ; $AA64: 60
Loc_AA65:
  LDX #$01                              ; $AA65: A2 01
  JSR $AC7B                             ; $AA67: 20 7B AC
  BCS $AA6F                             ; $AA6A: B0 03
  JMP $AAC2                             ; $AA6C: 4C C2 AA
Loc_AA6F:
  JSR $B5D5                             ; $AA6F: 20 D5 B5
  AND #$03                              ; $AA72: 29 03
  BEQ $AA6F                             ; $AA74: F0 F9
  CMP #$01                              ; $AA76: C9 01
  BEQ $AA97                             ; $AA78: F0 1D
  CMP #$02                              ; $AA7A: C9 02
  BEQ $AAB5                             ; $AA7C: F0 37
  LDA $002D                             ; $AA7E: AD 2D 00
  BEQ $AA6F                             ; $AA81: F0 EC
  LDA $002A                             ; $AA83: AD 2A 00
  CMP #$03                              ; $AA86: C9 03
  BCC $AAC2                             ; $AA88: 90 38
  LDA #$03                              ; $AA8A: A9 03
  STA $002C                             ; $AA8C: 8D 2C 00
  LDA $0505                             ; $AA8F: AD 05 05
  CMP #$06                              ; $AA92: C9 06
  BCC $AAC2                             ; $AA94: 90 2C
  RTS                                   ; $AA96: 60
Loc_AA97:
  LDA $002A                             ; $AA97: AD 2A 00
  CMP #$02                              ; $AA9A: C9 02
  BCC $AAC2                             ; $AA9C: 90 24
  LDY $002B                             ; $AA9E: AC 2B 00
  LDA $0650,Y                           ; $AAA1: B9 50 06
  AND #$0F                              ; $AAA4: 29 0F
  BNE $AAC2                             ; $AAA6: D0 1A
  LDA #$02                              ; $AAA8: A9 02
  STA $002C                             ; $AAAA: 8D 2C 00
  LDA $0505                             ; $AAAD: AD 05 05
  CMP #$04                              ; $AAB0: C9 04
  BCC $AAC2                             ; $AAB2: 90 0E
  RTS                                   ; $AAB4: 60
Loc_AAB5:
  LDA #$01                              ; $AAB5: A9 01
  STA $002C                             ; $AAB7: 8D 2C 00
  LDA $0505                             ; $AABA: AD 05 05
  CMP #$05                              ; $AABD: C9 05
  BCC $AAC2                             ; $AABF: 90 01
  RTS                                   ; $AAC1: 60
Loc_AAC2:
  LDA $002A                             ; $AAC2: AD 2A 00
  CMP #$04                              ; $AAC5: C9 04
  BCC $AADD                             ; $AAC7: 90 14
  LDA $002D                             ; $AAC9: AD 2D 00
  BEQ $AADD                             ; $AACC: F0 0F
  LDA $0505                             ; $AACE: AD 05 05
  CMP #$07                              ; $AAD1: C9 07
  BCC $AADD                             ; $AAD3: 90 08
  LDX #$04                              ; $AAD5: A2 04
  JSR $AC7B                             ; $AAD7: 20 7B AC
  BCC $AADD                             ; $AADA: 90 01
  RTS                                   ; $AADC: 60
Loc_AADD:
  LDA $002D                             ; $AADD: AD 2D 00
  BEQ $AAF1                             ; $AAE0: F0 0F
  LDA $0505                             ; $AAE2: AD 05 05
  CMP #$06                              ; $AAE5: C9 06
  BCC $AAF1                             ; $AAE7: 90 08
  LDX #$00                              ; $AAE9: A2 00
  JSR $AC7B                             ; $AAEB: 20 7B AC
  BCC $AAF1                             ; $AAEE: 90 01
  RTS                                   ; $AAF0: 60
Loc_AAF1:
  LDA #$03                              ; $AAF1: A9 03
  STA $6F8F                             ; $AAF3: 8D 8F 6F
  CLC                                   ; $AAF6: 18
  RTS                                   ; $AAF7: 60
Loc_AAF8:
  LDY $6F8C                             ; $AAF8: AC 8C 6F
  LDA $0664,Y                           ; $AAFB: B9 64 06
  STA $002A                             ; $AAFE: 8D 2A 00
  JSR $B491                             ; $AB01: 20 91 B4
  LDY #$02                              ; $AB04: A0 02
  LDA ($20),Y                           ; $AB06: B1 20
  CMP #$5C                              ; $AB08: C9 5C
  BCS $AB0E                             ; $AB0A: B0 02
  CLC                                   ; $AB0C: 18
  RTS                                   ; $AB0D: 60
Loc_AB0E:
  LDY #$0B                              ; $AB0E: A0 0B
  LDA ($20),Y                           ; $AB10: B1 20
  LSR                                   ; $AB12: 4A
  LSR                                   ; $AB13: 4A
  LSR                                   ; $AB14: 4A
  LSR                                   ; $AB15: 4A
  STA $0036                             ; $AB16: 8D 36 00
  CMP #$03                              ; $AB19: C9 03
  BCS $AB1F                             ; $AB1B: B0 02
  CLC                                   ; $AB1D: 18
  RTS                                   ; $AB1E: 60
Loc_AB1F:
  LDY $6F8C                             ; $AB1F: AC 8C 6F
  LDA #$05                              ; $AB22: A9 05
  JSR $A8D3                             ; $AB24: 20 D3 A8
  JSR $AE93                             ; $AB27: 20 93 AE
  LDY #$00                              ; $AB2A: A0 00
Loc_AB2C:
  LDA $6FC9,Y                           ; $AB2C: B9 C9 6F
  CMP #$FF                              ; $AB2F: C9 FF
  BEQ $AB61                             ; $AB31: F0 2E
  TAX                                   ; $AB33: AA
  LDA $0664,X                           ; $AB34: BD 64 06
  CMP #$FF                              ; $AB37: C9 FF
  BEQ $AB5C                             ; $AB39: F0 21
  STY $002F                             ; $AB3B: 8C 2F 00
  STX $002B                             ; $AB3E: 8E 2B 00
  JSR $AB68                             ; $AB41: 20 68 AB
  BCC $AB59                             ; $AB44: 90 13
  LDA $002C                             ; $AB46: AD 2C 00
  STA $6F8D                             ; $AB49: 8D 8D 6F
  LDA $002B                             ; $AB4C: AD 2B 00
  STA $6F8E                             ; $AB4F: 8D 8E 6F
  LDA #$02                              ; $AB52: A9 02
  STA $6F8F                             ; $AB54: 8D 8F 6F
  SEC                                   ; $AB57: 38
  RTS                                   ; $AB58: 60
Loc_AB59:
  LDY $002F                             ; $AB59: AC 2F 00
Loc_AB5C:
  INY                                   ; $AB5C: C8
  CPY #$14                              ; $AB5D: C0 14
  BCC $AB2C                             ; $AB5F: 90 CB
Loc_AB61:
  LDA #$03                              ; $AB61: A9 03
  STA $6F8F                             ; $AB63: 8D 8F 6F
  CLC                                   ; $AB66: 18
  RTS                                   ; $AB67: 60
Loc_AB68:
  LDY #$00                              ; $AB68: A0 00
  LDA #$03                              ; $AB6A: A9 03
  STA $0022                             ; $AB6C: 8D 22 00
  JSR $AC31                             ; $AB6F: 20 31 AC
  BCC $AB8D                             ; $AB72: 90 19
  LDX $002B                             ; $AB74: AE 2B 00
  LDA $0650,X                           ; $AB77: BD 50 06
  AND #$0F                              ; $AB7A: 29 0F
  BNE $AB8D                             ; $AB7C: D0 0F
  LDA $0505                             ; $AB7E: AD 05 05
  CMP #$09                              ; $AB81: C9 09
  BCC $AB8D                             ; $AB83: 90 08
  LDX #$0A                              ; $AB85: A2 0A
  JSR $AC7B                             ; $AB87: 20 7B AC
  BCC $AB8D                             ; $AB8A: 90 01
  RTS                                   ; $AB8C: 60
Loc_AB8D:
  LDY #$00                              ; $AB8D: A0 00
  LDA #$03                              ; $AB8F: A9 03
  STA $0022                             ; $AB91: 8D 22 00
  JSR $AC31                             ; $AB94: 20 31 AC
  BCC $ABA8                             ; $AB97: 90 0F
  LDA $0505                             ; $AB99: AD 05 05
  CMP #$0A                              ; $AB9C: C9 0A
  BCC $ABA8                             ; $AB9E: 90 08
  LDX #$0B                              ; $ABA0: A2 0B
  JSR $AC7B                             ; $ABA2: 20 7B AC
  BCC $ABA8                             ; $ABA5: 90 01
  RTS                                   ; $ABA7: 60
Loc_ABA8:
  LDY #$0B                              ; $ABA8: A0 0B
  LDA #$04                              ; $ABAA: A9 04
  STA $0022                             ; $ABAC: 8D 22 00
  JSR $AC31                             ; $ABAF: 20 31 AC
  BCC $ABC8                             ; $ABB2: 90 14
  JSR $AC4D                             ; $ABB4: 20 4D AC
  BCC $ABC8                             ; $ABB7: 90 0F
  LDA $0505                             ; $ABB9: AD 05 05
  CMP #$0A                              ; $ABBC: C9 0A
  BCC $ABC8                             ; $ABBE: 90 08
  LDX #$0C                              ; $ABC0: A2 0C
  JSR $AC7B                             ; $ABC2: 20 7B AC
  BCC $ABC8                             ; $ABC5: 90 01
  RTS                                   ; $ABC7: 60
Loc_ABC8:
  LDY #$0B                              ; $ABC8: A0 0B
  LDA #$04                              ; $ABCA: A9 04
  STA $0022                             ; $ABCC: 8D 22 00
  JSR $AC31                             ; $ABCF: 20 31 AC
  BCC $ABE8                             ; $ABD2: 90 14
  JSR $AC4D                             ; $ABD4: 20 4D AC
  BCC $ABE8                             ; $ABD7: 90 0F
  LDA $0505                             ; $ABD9: AD 05 05
  CMP #$08                              ; $ABDC: C9 08
  BCC $ABE8                             ; $ABDE: 90 08
  LDX #$0D                              ; $ABE0: A2 0D
  JSR $AC7B                             ; $ABE2: 20 7B AC
  BCC $ABE8                             ; $ABE5: 90 01
  RTS                                   ; $ABE7: 60
Loc_ABE8:
  LDY #$11                              ; $ABE8: A0 11
  LDA #$05                              ; $ABEA: A9 05
  STA $0022                             ; $ABEC: 8D 22 00
  JSR $AC31                             ; $ABEF: 20 31 AC
  BCC $AC08                             ; $ABF2: 90 14
  JSR $AC4D                             ; $ABF4: 20 4D AC
  BCC $AC08                             ; $ABF7: 90 0F
  LDA $0505                             ; $ABF9: AD 05 05
  CMP #$0C                              ; $ABFC: C9 0C
  BCC $AC08                             ; $ABFE: 90 08
  LDX #$0E                              ; $AC00: A2 0E
  JSR $AC7B                             ; $AC02: 20 7B AC
  BCC $AC08                             ; $AC05: 90 01
  RTS                                   ; $AC07: 60
Loc_AC08:
  LDA $002A                             ; $AC08: AD 2A 00
  CMP #$6D                              ; $AC0B: C9 6D
  BNE $AC2F                             ; $AC0D: D0 20
  LDA $0036                             ; $AC0F: AD 36 00
  CMP #$06                              ; $AC12: C9 06
  BCC $AC2F                             ; $AC14: 90 19
  LDX $002B                             ; $AC16: AE 2B 00
  LDA $0650,X                           ; $AC19: BD 50 06
  AND #$F0                              ; $AC1C: 29 F0
  BNE $AC2F                             ; $AC1E: D0 0F
  LDA $0505                             ; $AC20: AD 05 05
  CMP #$0A                              ; $AC23: C9 0A
  BCC $AC2F                             ; $AC25: 90 08
  LDX #$0F                              ; $AC27: A2 0F
  JSR $AC7B                             ; $AC29: 20 7B AC
  BCC $AC2F                             ; $AC2C: 90 01
  RTS                                   ; $AC2E: 60
Loc_AC2F:
  CLC                                   ; $AC2F: 18
  RTS                                   ; $AC30: 60
Loc_AC31:
  LDA $0036                             ; $AC31: AD 36 00
  CMP $0022                             ; $AC34: CD 22 00
  BCC $AC40                             ; $AC37: 90 07
Loc_AC39:
  LDA $AC65,Y                           ; $AC39: B9 65 AC
  CMP #$FF                              ; $AC3C: C9 FF
  BNE $AC42                             ; $AC3E: D0 02
Loc_AC40:
  CLC                                   ; $AC40: 18
  RTS                                   ; $AC41: 60
Loc_AC42:
  CMP $002A                             ; $AC42: CD 2A 00
  BNE $AC49                             ; $AC45: D0 02
  SEC                                   ; $AC47: 38
  RTS                                   ; $AC48: 60
Loc_AC49:
  INY                                   ; $AC49: C8
  JMP $AC39                             ; $AC4A: 4C 39 AC
Loc_AC4D:
  LDY $002B                             ; $AC4D: AC 2B 00
  LDA $0664,Y                           ; $AC50: B9 64 06
  JSR $B491                             ; $AC53: 20 91 B4
  LDY #$09                              ; $AC56: A0 09
  LDA ($20),Y                           ; $AC58: B1 20
  BNE $AC61                             ; $AC5A: D0 05
  DEY                                   ; $AC5C: 88
  LDA ($20),Y                           ; $AC5D: B1 20
  BEQ $AC63                             ; $AC5F: F0 02
Loc_AC61:
  SEC                                   ; $AC61: 38
  RTS                                   ; $AC62: 60
Loc_AC63:
  CLC                                   ; $AC63: 18
  RTS                                   ; $AC64: 60
; --- Data Region ---
  .byte $A1,$63,$A7,$16,$C4,$DB,$EA,$6B,$CE,$EB,$B7,$18,$37,$70,$D5,$6E; $AC65: A1 63 A7 16 C4 DB EA 6B CE EB B7 18 37 70 D5 6E
  .byte $67,$C5,$56,$5D,$6D,$FF           ; $AC75: 67 C5 56 5D 6D FF
Loc_AC7B:
; --- Code Region ---
  STX $002C                             ; $AC7B: 8E 2C 00
  LDY $002B                             ; $AC7E: AC 2B 00
  LDA $0600,Y                           ; $AC81: B9 00 06
  STA $0020                             ; $AC84: 8D 20 00
  LDA $0614,Y                           ; $AC87: B9 14 06
  STA $0021                             ; $AC8A: 8D 21 00
  JSR $B6E5                             ; $AC8D: 20 E5 B6
  STA $0028                             ; $AC90: 8D 28 00
  LDY $6F8C                             ; $AC93: AC 8C 6F
  LDA $0600,Y                           ; $AC96: B9 00 06
  STA $0020                             ; $AC99: 8D 20 00
  LDA $0614,Y                           ; $AC9C: B9 14 06
  STA $0021                             ; $AC9F: 8D 21 00
  JSR $B6E5                             ; $ACA2: 20 E5 B6
  STA $0029                             ; $ACA5: 8D 29 00
  LDA $002C                             ; $ACA8: AD 2C 00
  JSR $B517                             ; $ACAB: 20 17 B5
  DEC $DBAC                             ; $ACAE: CE AC DB
  LDY $ACDB                             ; $ACB1: AC DB AC
  DCP $E8AC,Y                           ; $ACB4: DB AC E8
  LDY $ACF3                             ; $ACB7: AC F3 AC
  BRK                                   ; $ACBA: 00
  LDA $AD22                             ; $ACBB: AD 22 AD
  EOR $AD                               ; $ACBE: 45 AD
  ADC $AD                               ; $ACC0: 65 AD
  JAM                                   ; $ACC2: 92
  LDA $ADCF                             ; $ACC3: AD CF AD
  JAM                                   ; $ACC6: 92
  LDA $ADFE                             ; $ACC7: AD FE AD
  JSR $5DAE                             ; $ACCA: 20 AE 5D
  LDX $28AD                             ; $ACCD: AE AD 28
  BRK                                   ; $ACD0: 00
  BEQ $ACD9                             ; $ACD1: F0 06
  CMP #$02                              ; $ACD3: C9 02
  BEQ $ACD9                             ; $ACD5: F0 02
  CLC                                   ; $ACD7: 18
  RTS                                   ; $ACD8: 60
Loc_ACD9:
  SEC                                   ; $ACD9: 38
  RTS                                   ; $ACDA: 60
; --- Data Region ---
  .byte $AD,$28,$00,$F0,$06,$C9,$04,$F0,$02,$18,$60; $ACDB: AD 28 00 F0 06 C9 04 F0 02 18 60
Loc_ACE6:
; --- Code Region ---
  SEC                                   ; $ACE6: 38
  RTS                                   ; $ACE7: 60
; --- Data Region ---
  .byte $AD,$28,$00,$C9,$03,$F0,$02,$18,$60; $ACE8: AD 28 00 C9 03 F0 02 18 60
Loc_ACF1:
; --- Code Region ---
  SEC                                   ; $ACF1: 38
  RTS                                   ; $ACF2: 60
; --- Data Region ---
  .byte $AD,$2B,$00,$F0,$06,$C9,$0A,$F0,$02,$18,$60; $ACF3: AD 2B 00 F0 06 C9 0A F0 02 18 60
Loc_ACFE:
; --- Code Region ---
  SEC                                   ; $ACFE: 38
  RTS                                   ; $ACFF: 60
; --- Data Region ---
  .byte $AD,$28,$00,$C9,$05,$D0,$17,$AC,$2B,$00,$20,$37,$A8,$A0,$00; $AD00: AD 28 00 C9 05 D0 17 AC 2B 00 20 37 A8 A0 00
Loc_AD0F:
; --- Code Region ---
  LDA $6FDD,Y                           ; $AD0F: B9 DD 6F
  AND #$7F                              ; $AD12: 29 7F
  CMP $6F8C                             ; $AD14: CD 8C 6F
  BEQ $AD20                             ; $AD17: F0 07
  INY                                   ; $AD19: C8
  CPY #$04                              ; $AD1A: C0 04
  BCC $AD0F                             ; $AD1C: 90 F1
Loc_AD1E:
  CLC                                   ; $AD1E: 18
  RTS                                   ; $AD1F: 60
Loc_AD20:
  SEC                                   ; $AD20: 38
  RTS                                   ; $AD21: 60
; --- Data Region ---
  .byte $AD,$28,$00,$F0,$04,$C9,$04,$D0,$16; $AD22: AD 28 00 F0 04 C9 04 D0 16
Loc_AD2B:
; --- Code Region ---
  LDY $002B                             ; $AD2B: AC 2B 00
  JSR $A837                             ; $AD2E: 20 37 A8
  LDY #$00                              ; $AD31: A0 00
Loc_AD33:
  LDA $6FDD,Y                           ; $AD33: B9 DD 6F
  CMP #$FF                              ; $AD36: C9 FF
  BEQ $AD3C                             ; $AD38: F0 02
  BMI $AD43                             ; $AD3A: 30 07
Loc_AD3C:
  INY                                   ; $AD3C: C8
  CPY #$04                              ; $AD3D: C0 04
  BCC $AD33                             ; $AD3F: 90 F2
Loc_AD41:
  CLC                                   ; $AD41: 18
  RTS                                   ; $AD42: 60
Loc_AD43:
  SEC                                   ; $AD43: 38
  RTS                                   ; $AD44: 60
; --- Data Region ---
  .byte $AD,$28,$00,$C9,$05,$F0,$15,$AC,$2B,$00,$B9,$64,$06,$20,$91,$B4; $AD45: AD 28 00 C9 05 F0 15 AC 2B 00 B9 64 06 20 91 B4
  .byte $A0,$03,$B1,$20,$C9,$64,$F0,$04,$C9,$32,$90,$02; $AD55: A0 03 B1 20 C9 64 F0 04 C9 32 90 02
Loc_AD61:
; --- Code Region ---
  CLC                                   ; $AD61: 18
  RTS                                   ; $AD62: 60
Loc_AD63:
  SEC                                   ; $AD63: 38
  RTS                                   ; $AD64: 60
; --- Data Region ---
  .byte $AD,$29,$00,$C9,$04,$F0,$04,$C9,$05,$D0,$17; $AD65: AD 29 00 C9 04 F0 04 C9 05 D0 17
Loc_AD70:
; --- Code Region ---
  LDY $6F8C                             ; $AD70: AC 8C 6F
  JSR $A837                             ; $AD73: 20 37 A8
  LDY #$00                              ; $AD76: A0 00
Loc_AD78:
  LDA $6FDD,Y                           ; $AD78: B9 DD 6F
  AND #$7F                              ; $AD7B: 29 7F
  CMP $002B                             ; $AD7D: CD 2B 00
Loc_AD80:
  BEQ $AD89                             ; $AD80: F0 07
  INY                                   ; $AD82: C8
  CPY #$04                              ; $AD83: C0 04
  BCC $AD78                             ; $AD85: 90 F1
Loc_AD87:
  CLC                                   ; $AD87: 18
  RTS                                   ; $AD88: 60
Loc_AD89:
  LDA $0028                             ; $AD89: AD 28 00
  CMP #$05                              ; $AD8C: C9 05
  BNE $AD87                             ; $AD8E: D0 F7
  SEC                                   ; $AD90: 38
  RTS                                   ; $AD91: 60
; --- Data Region ---
  .byte $AD,$28,$00,$C9,$03,$D0,$32,$AC,$2B,$00,$20,$37,$A8,$A0,$00; $AD92: AD 28 00 C9 03 D0 32 AC 2B 00 20 37 A8 A0 00
Loc_ADA1:
; --- Code Region ---
  LDA $6FDD,Y                           ; $ADA1: B9 DD 6F
  BPL $ADC6                             ; $ADA4: 10 20
  CMP #$FF                              ; $ADA6: C9 FF
  BEQ $ADC6                             ; $ADA8: F0 1C
  STY $0027                             ; $ADAA: 8C 27 00
  AND #$7F                              ; $ADAD: 29 7F
  TAY                                   ; $ADAF: A8
  LDA $0600,Y                           ; $ADB0: B9 00 06
  STA $0020                             ; $ADB3: 8D 20 00
  LDA $0614,Y                           ; $ADB6: B9 14 06
  STA $0021                             ; $ADB9: 8D 21 00
  JSR $B6E5                             ; $ADBC: 20 E5 B6
  CMP #$03                              ; $ADBF: C9 03
  BEQ $ADCD                             ; $ADC1: F0 0A
  LDY $0027                             ; $ADC3: AC 27 00
Loc_ADC6:
  INY                                   ; $ADC6: C8
  CPY #$04                              ; $ADC7: C0 04
  BCC $ADA1                             ; $ADC9: 90 D6
Loc_ADCB:
  CLC                                   ; $ADCB: 18
  RTS                                   ; $ADCC: 60
Loc_ADCD:
  SEC                                   ; $ADCD: 38
  RTS                                   ; $ADCE: 60
; --- Data Region ---
  .byte $AD,$29,$00,$D0,$26,$AC,$8C,$6F,$B9,$64,$06,$20,$91,$B4,$A0,$09; $ADCF: AD 29 00 D0 26 AC 8C 6F B9 64 06 20 91 B4 A0 09
  .byte $B1,$20,$D0,$07,$88,$B1,$20,$C9,$64,$90,$10; $ADDF: B1 20 D0 07 88 B1 20 C9 64 90 10
Loc_ADEA:
; --- Code Region ---
  LDY #$00                              ; $ADEA: A0 00
  LDA $0504                             ; $ADEC: AD 04 05
  BPL $ADF3                             ; $ADEF: 10 02
  LDY #$04                              ; $ADF1: A0 04
Loc_ADF3:
  LDA $04D8,Y                           ; $ADF3: B9 D8 04
  CMP #$FF                              ; $ADF6: C9 FF
  BEQ $ADFC                             ; $ADF8: F0 02
Loc_ADFA:
  CLC                                   ; $ADFA: 18
  RTS                                   ; $ADFB: 60
Loc_ADFC:
  SEC                                   ; $ADFC: 38
  RTS                                   ; $ADFD: 60
; --- Data Region ---
  .byte $AC,$29,$00,$C0,$05,$D0,$17,$AC,$8C,$6F,$20,$37,$A8,$A0,$00; $ADFE: AC 29 00 C0 05 D0 17 AC 8C 6F 20 37 A8 A0 00
Loc_AE0D:
; --- Code Region ---
  LDA $6FDD,Y                           ; $AE0D: B9 DD 6F
  EOR #$80                              ; $AE10: 49 80
  CMP $002B                             ; $AE12: CD 2B 00
  BEQ $AE1E                             ; $AE15: F0 07
  INY                                   ; $AE17: C8
  CPY #$04                              ; $AE18: C0 04
  BCC $AE0D                             ; $AE1A: 90 F1
Loc_AE1C:
  CLC                                   ; $AE1C: 18
  RTS                                   ; $AE1D: 60
Loc_AE1E:
  SEC                                   ; $AE1E: 38
  RTS                                   ; $AE1F: 60
; --- Data Region ---
  .byte $AC,$28,$00,$C0,$05,$F0,$32,$AC,$2B,$00,$20,$37,$A8,$A0,$00; $AE20: AC 28 00 C0 05 F0 32 AC 2B 00 20 37 A8 A0 00
Loc_AE2F:
; --- Code Region ---
  LDA $6FDD,Y                           ; $AE2F: B9 DD 6F
  BPL $AE54                             ; $AE32: 10 20
  CMP #$FF                              ; $AE34: C9 FF
  BEQ $AE54                             ; $AE36: F0 1C
  STY $0027                             ; $AE38: 8C 27 00
  AND #$7F                              ; $AE3B: 29 7F
  TAY                                   ; $AE3D: A8
  LDA $0600,Y                           ; $AE3E: B9 00 06
  STA $0020                             ; $AE41: 8D 20 00
  LDA $0614,Y                           ; $AE44: B9 14 06
  STA $0021                             ; $AE47: 8D 21 00
  JSR $B6E5                             ; $AE4A: 20 E5 B6
  CMP #$05                              ; $AE4D: C9 05
  BNE $AE5B                             ; $AE4F: D0 0A
  LDY $0027                             ; $AE51: AC 27 00
Loc_AE54:
  INY                                   ; $AE54: C8
  CPY #$04                              ; $AE55: C0 04
  BCC $AE2F                             ; $AE57: 90 D6
Loc_AE59:
  CLC                                   ; $AE59: 18
  RTS                                   ; $AE5A: 60
Loc_AE5B:
  SEC                                   ; $AE5B: 38
  RTS                                   ; $AE5C: 60
; --- Data Region ---
  .byte $AC,$28,$00,$C0,$03,$F0,$04,$C0,$05,$F0,$27; $AE5D: AC 28 00 C0 03 F0 04 C0 05 F0 27
Loc_AE68:
; --- Code Region ---
  LDY $002B                             ; $AE68: AC 2B 00
  LDA $0664,Y                           ; $AE6B: B9 64 06
  JSR $B491                             ; $AE6E: 20 91 B4
  LDY #$01                              ; $AE71: A0 01
  LDA ($20),Y                           ; $AE73: B1 20
  CMP #$55                              ; $AE75: C9 55
  BCS $AE80                             ; $AE77: B0 07
  INY                                   ; $AE79: C8
  LDA ($20),Y                           ; $AE7A: B1 20
  CMP #$55                              ; $AE7C: C9 55
  BCC $AE8F                             ; $AE7E: 90 0F
Loc_AE80:
  LDY #$09                              ; $AE80: A0 09
  LDA ($20),Y                           ; $AE82: B1 20
  CMP #$02                              ; $AE84: C9 02
  BCC $AE8F                             ; $AE86: 90 07
  DEY                                   ; $AE88: 88
  LDA ($20),Y                           ; $AE89: B1 20
  CMP #$BC                              ; $AE8B: C9 BC
  BCS $AE91                             ; $AE8D: B0 02
Loc_AE8F:
  CLC                                   ; $AE8F: 18
  RTS                                   ; $AE90: 60
Loc_AE91:
  SEC                                   ; $AE91: 38
  RTS                                   ; $AE92: 60
Loc_AE93:
  LDX #$00                              ; $AE93: A2 00
  LDY #$00                              ; $AE95: A0 00
Loc_AE97:
  LDA $6FC9,Y                           ; $AE97: B9 C9 6F
  STA $0020                             ; $AE9A: 8D 20 00
  LDA #$FF                              ; $AE9D: A9 FF
  STA $6FC9,Y                           ; $AE9F: 99 C9 6F
  LDA $0020                             ; $AEA2: AD 20 00
  BPL $AEAC                             ; $AEA5: 10 05
  TYA                                   ; $AEA7: 98
  STA $6FC9,X                           ; $AEA8: 9D C9 6F
  INX                                   ; $AEAB: E8
Loc_AEAC:
  INY                                   ; $AEAC: C8
  CPY #$14                              ; $AEAD: C0 14
  BCC $AE97                             ; $AEAF: 90 E6
  CPX #$02                              ; $AEB1: E0 02
  BCS $AEB6                             ; $AEB3: B0 01
  RTS                                   ; $AEB5: 60
Loc_AEB6:
  DEX                                   ; $AEB6: CA
  STX $0024                             ; $AEB7: 8E 24 00
Loc_AEBA:
  LDX #$00                              ; $AEBA: A2 00
Loc_AEBC:
  LDA $6FC9,X                           ; $AEBC: BD C9 6F
  TAY                                   ; $AEBF: A8
  LDA $0664,Y                           ; $AEC0: B9 64 06
  JSR $B491                             ; $AEC3: 20 91 B4
  LDY #$08                              ; $AEC6: A0 08
  LDA ($20),Y                           ; $AEC8: B1 20
  STA $0022                             ; $AECA: 8D 22 00
  INY                                   ; $AECD: C8
  LDA ($20),Y                           ; $AECE: B1 20
  STA $0023                             ; $AED0: 8D 23 00
  LDA $6FCA,X                           ; $AED3: BD CA 6F
  TAY                                   ; $AED6: A8
  LDA $0664,Y                           ; $AED7: B9 64 06
  JSR $B491                             ; $AEDA: 20 91 B4
  LDY #$09                              ; $AEDD: A0 09
  LDA ($20),Y                           ; $AEDF: B1 20
  CMP $0023                             ; $AEE1: CD 23 00
  BCC $AEFE                             ; $AEE4: 90 18
  BNE $AEF0                             ; $AEE6: D0 08
  DEY                                   ; $AEE8: 88
  LDA ($20),Y                           ; $AEE9: B1 20
  CMP $0022                             ; $AEEB: CD 22 00
  BCC $AEFE                             ; $AEEE: 90 0E
Loc_AEF0:
  LDA $6FC9,X                           ; $AEF0: BD C9 6F
  TAY                                   ; $AEF3: A8
  LDA $6FCA,X                           ; $AEF4: BD CA 6F
  STA $6FC9,X                           ; $AEF7: 9D C9 6F
  TYA                                   ; $AEFA: 98
  STA $6FCA,X                           ; $AEFB: 9D CA 6F
Loc_AEFE:
  INX                                   ; $AEFE: E8
  CPX $0024                             ; $AEFF: EC 24 00
  BCC $AEBC                             ; $AF02: 90 B8
  DEC $002F                             ; $AF04: CE 2F 00
  LDA $002F                             ; $AF07: AD 2F 00
  BPL $AEBA                             ; $AF0A: 10 AE
  RTS                                   ; $AF0C: 60
Loc_AF0D:
  LDA $0507                             ; $AF0D: AD 07 05
  LDX $0504                             ; $AF10: AE 04 05
  BPL $AF19                             ; $AF13: 10 04
  LSR                                   ; $AF15: 4A
  LSR                                   ; $AF16: 4A
  LSR                                   ; $AF17: 4A
  LSR                                   ; $AF18: 4A
Loc_AF19:
  AND #$0F                              ; $AF19: 29 0F
  JSR $B4C2                             ; $AF1B: 20 C2 B4
  LDY #$00                              ; $AF1E: A0 00
  LDA ($20),Y                           ; $AF20: B1 20
  STA $0022                             ; $AF22: 8D 22 00
  LDY $6F8C                             ; $AF25: AC 8C 6F
  LDA $0664,Y                           ; $AF28: B9 64 06
  CMP $0022                             ; $AF2B: CD 22 00
  BNE $AF33                             ; $AF2E: D0 03
  JMP $AFAA                             ; $AF30: 4C AA AF
Loc_AF33:
  CPY #$00                              ; $AF33: C0 00
  BEQ $AF3E                             ; $AF35: F0 07
  CPY #$0A                              ; $AF37: C0 0A
  BEQ $AF3E                             ; $AF39: F0 03
  JMP $AF88                             ; $AF3B: 4C 88 AF
Loc_AF3E:
  JSR $B067                             ; $AF3E: 20 67 B0
  LDA $002A                             ; $AF41: AD 2A 00
  SEC                                   ; $AF44: 38
  SBC #$DD                              ; $AF45: E9 DD
  LDA $002B                             ; $AF47: AD 2B 00
  SBC #$06                              ; $AF4A: E9 06
  BCS $AF71                             ; $AF4C: B0 23
  LDA $002A                             ; $AF4E: AD 2A 00
  CLC                                   ; $AF51: 18
  ADC #$AB                              ; $AF52: 69 AB
  STA $002A                             ; $AF54: 8D 2A 00
  LDA $002B                             ; $AF57: AD 2B 00
  ADC #$0D                              ; $AF5A: 69 0D
  STA $002B                             ; $AF5C: 8D 2B 00
  LDA $002A                             ; $AF5F: AD 2A 00
  SEC                                   ; $AF62: 38
  SBC $002C                             ; $AF63: ED 2C 00
  LDA $002B                             ; $AF66: AD 2B 00
  SBC $002D                             ; $AF69: ED 2D 00
  BCS $AF71                             ; $AF6C: B0 03
  JMP $AFBE                             ; $AF6E: 4C BE AF
Loc_AF71:
  LDA #$65                              ; $AF71: A9 65
  STA $0022                             ; $AF73: 8D 22 00
  LDA #$00                              ; $AF76: A9 00
  STA $0023                             ; $AF78: 8D 23 00
  LDA #$29                              ; $AF7B: A9 29
  STA $0024                             ; $AF7D: 8D 24 00
  JSR $AFD4                             ; $AF80: 20 D4 AF
  BCS $AFD2                             ; $AF83: B0 4D
  JMP $AFBE                             ; $AF85: 4C BE AF
Loc_AF88:
  LDA #$C9                              ; $AF88: A9 C9
  STA $0022                             ; $AF8A: 8D 22 00
  LDA #$00                              ; $AF8D: A9 00
  STA $0023                             ; $AF8F: 8D 23 00
  LDA #$64                              ; $AF92: A9 64
  STA $0024                             ; $AF94: 8D 24 00
  JSR $AFD4                             ; $AF97: 20 D4 AF
  BCS $AFD2                             ; $AF9A: B0 36
Loc_AF9C:
  JSR $B5D5                             ; $AF9C: 20 D5 B5
  CMP #$64                              ; $AF9F: C9 64
  BCS $AF9C                             ; $AFA1: B0 F9
  CMP #$46                              ; $AFA3: C9 46
  BCS $AFD2                             ; $AFA5: B0 2B
  JMP $AFBE                             ; $AFA7: 4C BE AF
Loc_AFAA:
  LDA #$2D                              ; $AFAA: A9 2D
  STA $0022                             ; $AFAC: 8D 22 00
  LDA #$01                              ; $AFAF: A9 01
  STA $0023                             ; $AFB1: 8D 23 00
  LDA #$33                              ; $AFB4: A9 33
  STA $0024                             ; $AFB6: 8D 24 00
  JSR $AFD4                             ; $AFB9: 20 D4 AF
  BCS $AFD2                             ; $AFBC: B0 14
Loc_AFBE:
  LDA #$FF                              ; $AFBE: A9 FF
  STA $6F8D                             ; $AFC0: 8D 8D 6F
  JSR $AFF6                             ; $AFC3: 20 F6 AF
  LDA $6F8D                             ; $AFC6: AD 8D 6F
  BMI $AFD2                             ; $AFC9: 30 07
  LDA #$04                              ; $AFCB: A9 04
  STA $6F8F                             ; $AFCD: 8D 8F 6F
  SEC                                   ; $AFD0: 38
  RTS                                   ; $AFD1: 60
Loc_AFD2:
  CLC                                   ; $AFD2: 18
  RTS                                   ; $AFD3: 60
Loc_AFD4:
  LDY $6F8C                             ; $AFD4: AC 8C 6F
  LDA $0664,Y                           ; $AFD7: B9 64 06
  JSR $B491                             ; $AFDA: 20 91 B4
  LDY #$08                              ; $AFDD: A0 08
  LDA ($20),Y                           ; $AFDF: B1 20
  SEC                                   ; $AFE1: 38
  SBC $0022                             ; $AFE2: ED 22 00
  LDY #$09                              ; $AFE5: A0 09
  LDA ($20),Y                           ; $AFE7: B1 20
  SBC $0023                             ; $AFE9: ED 23 00
  BCS $AFF5                             ; $AFEC: B0 07
  LDY #$00                              ; $AFEE: A0 00
  LDA ($20),Y                           ; $AFF0: B1 20
  CMP $0024                             ; $AFF2: CD 24 00
Loc_AFF5:
  RTS                                   ; $AFF5: 60
Loc_AFF6:
  LDA $0504                             ; $AFF6: AD 04 05
  BPL $B002                             ; $AFF9: 10 07
  LDA $052A                             ; $AFFB: AD 2A 05
  STA $6F8D                             ; $AFFE: 8D 8D 6F
  RTS                                   ; $B001: 60
Loc_B002:
  LDA $0507                             ; $B002: AD 07 05
  AND #$0F                              ; $B005: 29 0F
  STA $0022                             ; $B007: 8D 22 00
  LDY #$30                              ; $B00A: A0 30
  JSR $F266                             ; $B00C: 20 66 F2
  LDA $050E                             ; $B00F: AD 0E 05
  ASL                                   ; $B012: 0A
  ASL                                   ; $B013: 0A
  ASL                                   ; $B014: 0A
  TAY                                   ; $B015: A8
  LDX #$00                              ; $B016: A2 00
  LDA #$FF                              ; $B018: A9 FF
  STA $0025                             ; $B01A: 8D 25 00
Loc_B01D:
  LDA $9D72,Y                           ; $B01D: B9 72 9D
  BMI $B053                             ; $B020: 30 31
  STA $0023                             ; $B022: 8D 23 00
  STY $0024                             ; $B025: 8C 24 00
  JSR $B469                             ; $B028: 20 69 B4
  LDY #$00                              ; $B02B: A0 00
  LDA ($20),Y                           ; $B02D: B1 20
  AND #$07                              ; $B02F: 29 07
  CMP #$07                              ; $B031: C9 07
  BNE $B03E                             ; $B033: D0 09
  LDA $0023                             ; $B035: AD 23 00
  STA $0025                             ; $B038: 8D 25 00
  JMP $B050                             ; $B03B: 4C 50 B0
Loc_B03E:
  CMP $0022                             ; $B03E: CD 22 00
  BNE $B050                             ; $B041: D0 0D
  LDY #$11                              ; $B043: A0 11
Loc_B045:
  LDA ($20),Y                           ; $B045: B1 20
  CMP #$FF                              ; $B047: C9 FF
  BEQ $B060                             ; $B049: F0 15
  INY                                   ; $B04B: C8
  CPY #$1B                              ; $B04C: C0 1B
  BCC $B045                             ; $B04E: 90 F5
Loc_B050:
  LDY $0024                             ; $B050: AC 24 00
Loc_B053:
  INY                                   ; $B053: C8
  INX                                   ; $B054: E8
  CPX #$08                              ; $B055: E0 08
  BCC $B01D                             ; $B057: 90 C4
  LDA $0025                             ; $B059: AD 25 00
  STA $6F8D                             ; $B05C: 8D 8D 6F
  RTS                                   ; $B05F: 60
Loc_B060:
  LDA $0023                             ; $B060: AD 23 00
  STA $6F8D                             ; $B063: 8D 8D 6F
  RTS                                   ; $B066: 60
Loc_B067:
  LDY #$00                              ; $B067: A0 00
  STY $002A                             ; $B069: 8C 2A 00
  STY $002B                             ; $B06C: 8C 2B 00
  STY $002C                             ; $B06F: 8C 2C 00
  STY $002D                             ; $B072: 8C 2D 00
Loc_B075:
  LDA $0664,Y                           ; $B075: B9 64 06
  CMP #$FF                              ; $B078: C9 FF
  BEQ $B0B2                             ; $B07A: F0 36
  STA $0022                             ; $B07C: 8D 22 00
  TYA                                   ; $B07F: 98
  PHA                                   ; $B080: 48
  LDA $0022                             ; $B081: AD 22 00
  JSR $B491                             ; $B084: 20 91 B4
  LDY #$08                              ; $B087: A0 08
  LDA ($20),Y                           ; $B089: B1 20
  STA $0022                             ; $B08B: 8D 22 00
  INY                                   ; $B08E: C8
  LDA ($20),Y                           ; $B08F: B1 20
  STA $0023                             ; $B091: 8D 23 00
  PLA                                   ; $B094: 68
  TAY                                   ; $B095: A8
  LDX #$00                              ; $B096: A2 00
  JSR $A944                             ; $B098: 20 44 A9
  BPL $B09F                             ; $B09B: 10 02
  LDX #$02                              ; $B09D: A2 02
Loc_B09F:
  LDA $002A,X                           ; $B09F: BD 2A 00
  CLC                                   ; $B0A2: 18
  ADC $0022                             ; $B0A3: 6D 22 00
  STA $002A,X                           ; $B0A6: 9D 2A 00
  LDA $002B,X                           ; $B0A9: BD 2B 00
  ADC $0023                             ; $B0AC: 6D 23 00
  STA $002B,X                           ; $B0AF: 9D 2B 00
Loc_B0B2:
  INY                                   ; $B0B2: C8
  CPY #$14                              ; $B0B3: C0 14
  BCC $B075                             ; $B0B5: 90 BE
  RTS                                   ; $B0B7: 60
Loc_B0B8:
  LDA #$1E                              ; $B0B8: A9 1E
  SEC                                   ; $B0BA: 38
  SBC $0506                             ; $B0BB: ED 06 05
  STA $002E                             ; $B0BE: 8D 2E 00
  JSR $B067                             ; $B0C1: 20 67 B0
  LDA $002A                             ; $B0C4: AD 2A 00
  STA $0020                             ; $B0C7: 8D 20 00
  LDA $002B                             ; $B0CA: AD 2B 00
  STA $0021                             ; $B0CD: 8D 21 00
  JSR $B0FB                             ; $B0D0: 20 FB B0
  LDA $0026                             ; $B0D3: AD 26 00
  STA $002A                             ; $B0D6: 8D 2A 00
  LDA $0027                             ; $B0D9: AD 27 00
  STA $002B                             ; $B0DC: 8D 2B 00
  LDA $002C                             ; $B0DF: AD 2C 00
  STA $0020                             ; $B0E2: 8D 20 00
  LDA $002D                             ; $B0E5: AD 2D 00
  STA $0021                             ; $B0E8: 8D 21 00
  JSR $B0FB                             ; $B0EB: 20 FB B0
  LDA $0026                             ; $B0EE: AD 26 00
  STA $002C                             ; $B0F1: 8D 2C 00
  LDA $0027                             ; $B0F4: AD 27 00
  STA $002D                             ; $B0F7: 8D 2D 00
  RTS                                   ; $B0FA: 60
Loc_B0FB:
  LDA #$00                              ; $B0FB: A9 00
  STA $0022                             ; $B0FD: 8D 22 00
  LDA #$04                              ; $B100: A9 04
  STA $0023                             ; $B102: 8D 23 00
  JSR $B585                             ; $B105: 20 85 B5
  LDA $0026                             ; $B108: AD 26 00
  STA $0020                             ; $B10B: 8D 20 00
  LDA $0027                             ; $B10E: AD 27 00
  STA $0021                             ; $B111: 8D 21 00
  LDA $0028                             ; $B114: AD 28 00
  STA $0022                             ; $B117: 8D 22 00
  LDA #$E8                              ; $B11A: A9 E8
  STA $0023                             ; $B11C: 8D 23 00
  LDA #$03                              ; $B11F: A9 03
  STA $0024                             ; $B121: 8D 24 00
  JSR $B536                             ; $B124: 20 36 B5
  LDA $002E                             ; $B127: AD 2E 00
  STA $0023                             ; $B12A: 8D 23 00
  JMP $B585                             ; $B12D: 4C 85 B5
Loc_B130:
  LDY #$00                              ; $B130: A0 00
  LDA #$FF                              ; $B132: A9 FF
Loc_B134:
  STA $6FA1,Y                           ; $B134: 99 A1 6F
  INY                                   ; $B137: C8
  CPY #$40                              ; $B138: C0 40
  BCC $B134                             ; $B13A: 90 F8
  LDY #$00                              ; $B13C: A0 00
  LDA #$00                              ; $B13E: A9 00
Loc_B140:
  STA $6FC9,Y                           ; $B140: 99 C9 6F
  INY                                   ; $B143: C8
  CPY #$14                              ; $B144: C0 14
  BCC $B140                             ; $B146: 90 F8
  LDA $0507                             ; $B148: AD 07 05
  AND #$0F                              ; $B14B: 29 0F
  STA $0022                             ; $B14D: 8D 22 00
  JSR $B4C2                             ; $B150: 20 C2 B4
  LDY #$03                              ; $B153: A0 03
  LDA ($20),Y                           ; $B155: B1 20
  CMP #$03                              ; $B157: C9 03
  BNE $B16E                             ; $B159: D0 13
  LDA #$00                              ; $B15B: A9 00
  STA $6F91                             ; $B15D: 8D 91 6F
  STA $6FA1                             ; $B160: 8D A1 6F
  JSR $B371                             ; $B163: 20 71 B3
  LDA #$00                              ; $B166: A9 00
  STA $0020                             ; $B168: 8D 20 00
  JSR $B1B0                             ; $B16B: 20 B0 B1
Loc_B16E:
  LDA $0507                             ; $B16E: AD 07 05
  LSR                                   ; $B171: 4A
  LSR                                   ; $B172: 4A
  LSR                                   ; $B173: 4A
  LSR                                   ; $B174: 4A
  STA $0022                             ; $B175: 8D 22 00
  JSR $B4C2                             ; $B178: 20 C2 B4
  LDY #$03                              ; $B17B: A0 03
  LDA ($20),Y                           ; $B17D: B1 20
  CMP #$03                              ; $B17F: C9 03
  BNE $B198                             ; $B181: D0 15
  LDA #$0A                              ; $B183: A9 0A
  STA $6F91                             ; $B185: 8D 91 6F
  LDA #$00                              ; $B188: A9 00
  STA $6FAB                             ; $B18A: 8D AB 6F
  JSR $B371                             ; $B18D: 20 71 B3
  LDA #$36                              ; $B190: A9 36
  STA $0020                             ; $B192: 8D 20 00
  JSR $B1B0                             ; $B195: 20 B0 B1
Loc_B198:
  LDY #$00                              ; $B198: A0 00
  LDA #$FF                              ; $B19A: A9 FF
Loc_B19C:
  STA $04D8,Y                           ; $B19C: 99 D8 04
  INY                                   ; $B19F: C8
  CPY #$08                              ; $B1A0: C0 08
  BCC $B19C                             ; $B1A2: 90 F8
  LDA #$00                              ; $B1A4: A9 00
  STA $6F94                             ; $B1A6: 8D 94 6F
  STA $6F95                             ; $B1A9: 8D 95 6F
  STA $6F96                             ; $B1AC: 8D 96 6F
  RTS                                   ; $B1AF: 60
Loc_B1B0:
  LDA $0022                             ; $B1B0: AD 22 00
  CMP #$01                              ; $B1B3: C9 01
  BEQ $B1C8                             ; $B1B5: F0 11
  CMP #$05                              ; $B1B7: C9 05
  BEQ $B1C8                             ; $B1B9: F0 0D
  CMP #$02                              ; $B1BB: C9 02
  BEQ $B1CD                             ; $B1BD: F0 0E
  CMP #$04                              ; $B1BF: C9 04
  BEQ $B1CD                             ; $B1C1: F0 0A
  LDA #$00                              ; $B1C3: A9 00
  JMP $B1CF                             ; $B1C5: 4C CF B1
Loc_B1C8:
  LDA #$12                              ; $B1C8: A9 12
  JMP $B1CF                             ; $B1CA: 4C CF B1
Loc_B1CD:
  LDA #$24                              ; $B1CD: A9 24
Loc_B1CF:
  CLC                                   ; $B1CF: 18
  ADC $0020                             ; $B1D0: 6D 20 00
  STA $0020                             ; $B1D3: 8D 20 00
  LDA $6F94                             ; $B1D6: AD 94 6F
  BNE $B1DE                             ; $B1D9: D0 03
  JMP $B258                             ; $B1DB: 4C 58 B2
Loc_B1DE:
  SEC                                   ; $B1DE: 38
  SBC #$01                              ; $B1DF: E9 01
  ASL                                   ; $B1E1: 0A
  CLC                                   ; $B1E2: 18
  ADC $0020                             ; $B1E3: 6D 20 00
  STA $0020                             ; $B1E6: 8D 20 00
  LDA #$FD                              ; $B1E9: A9 FD
  CLC                                   ; $B1EB: 18
  ADC $0020                             ; $B1EC: 6D 20 00
  STA $0020                             ; $B1EF: 8D 20 00
  LDA #$B3                              ; $B1F2: A9 B3
  ADC #$00                              ; $B1F4: 69 00
  STA $0021                             ; $B1F6: 8D 21 00
  LDX #$00                              ; $B1F9: A2 00
  LDA $6F91                             ; $B1FB: AD 91 6F
  BEQ $B202                             ; $B1FE: F0 02
  LDX #$04                              ; $B200: A2 04
Loc_B202:
  LDY #$00                              ; $B202: A0 00
Loc_B204:
  LDA ($20),Y                           ; $B204: B1 20
  STA $0022                             ; $B206: 8D 22 00
  LSR                                   ; $B209: 4A
  LSR                                   ; $B20A: 4A
  LSR                                   ; $B20B: 4A
  LSR                                   ; $B20C: 4A
  STA $6F99,X                           ; $B20D: 9D 99 6F
  LDA $0022                             ; $B210: AD 22 00
  AND #$0F                              ; $B213: 29 0F
  STA $6F9A,X                           ; $B215: 9D 9A 6F
  INX                                   ; $B218: E8
  INX                                   ; $B219: E8
  INY                                   ; $B21A: C8
  CPY #$02                              ; $B21B: C0 02
  BCC $B204                             ; $B21D: 90 E5
  LDX #$00                              ; $B21F: A2 00
  LDA $6F91                             ; $B221: AD 91 6F
  BEQ $B228                             ; $B224: F0 02
  LDX #$04                              ; $B226: A2 04
Loc_B228:
  TXA                                   ; $B228: 8A
  CLC                                   ; $B229: 18
  ADC #$04                              ; $B22A: 69 04
  STA $0022                             ; $B22C: 8D 22 00
  LDA #$01                              ; $B22F: A9 01
  STA $0020                             ; $B231: 8D 20 00
  LDY $6F91                             ; $B234: AC 91 6F
  INY                                   ; $B237: C8
Loc_B238:
  LDA $6F99,X                           ; $B238: BD 99 6F
  BEQ $B24F                             ; $B23B: F0 12
  STA $0021                             ; $B23D: 8D 21 00
Loc_B240:
  LDA $0020                             ; $B240: AD 20 00
  STA $6FA1,Y                           ; $B243: 99 A1 6F
  INY                                   ; $B246: C8
  DEC $0021                             ; $B247: CE 21 00
  LDA $0021                             ; $B24A: AD 21 00
  BNE $B240                             ; $B24D: D0 F1
Loc_B24F:
  INC $0020                             ; $B24F: EE 20 00
  INX                                   ; $B252: E8
  CPX $0022                             ; $B253: EC 22 00
  BCC $B238                             ; $B256: 90 E0
Loc_B258:
  LDA $6F91                             ; $B258: AD 91 6F
  BNE $B263                             ; $B25B: D0 06
  JSR $B2AE                             ; $B25D: 20 AE B2
  JMP $B266                             ; $B260: 4C 66 B2
Loc_B263:
  JSR $B312                             ; $B263: 20 12 B3
Loc_B266:
  LDX $6F91                             ; $B266: AE 91 6F
  TXA                                   ; $B269: 8A
  CLC                                   ; $B26A: 18
  ADC #$0A                              ; $B26B: 69 0A
  STA $002A                             ; $B26D: 8D 2A 00
  LDY #$00                              ; $B270: A0 00
  LDA ($20),Y                           ; $B272: B1 20
  STA $0614,X                           ; $B274: 9D 14 06
  INY                                   ; $B277: C8
  LDA ($20),Y                           ; $B278: B1 20
  STA $0600,X                           ; $B27A: 9D 00 06
  INX                                   ; $B27D: E8
Loc_B27E:
  LDA $6FA1,X                           ; $B27E: BD A1 6F
  CMP #$FF                              ; $B281: C9 FF
  BEQ $B2AD                             ; $B283: F0 28
  SEC                                   ; $B285: 38
  SBC #$01                              ; $B286: E9 01
  STA $002B                             ; $B288: 8D 2B 00
  TAY                                   ; $B28B: A8
  LDA $0022,Y                           ; $B28C: B9 22 00
  TAY                                   ; $B28F: A8
  LDA ($20),Y                           ; $B290: B1 20
  STA $0614,X                           ; $B292: 9D 14 06
  INY                                   ; $B295: C8
  LDA ($20),Y                           ; $B296: B1 20
  STA $0600,X                           ; $B298: 9D 00 06
  LDY $002B                             ; $B29B: AC 2B 00
  LDA $0022,Y                           ; $B29E: B9 22 00
  CLC                                   ; $B2A1: 18
  ADC #$02                              ; $B2A2: 69 02
  STA $0022,Y                           ; $B2A4: 99 22 00
  INX                                   ; $B2A7: E8
  CPX $002A                             ; $B2A8: EC 2A 00
  BCC $B27E                             ; $B2AB: 90 D1
Loc_B2AD:
  RTS                                   ; $B2AD: 60
Loc_B2AE:
  LDY #$30                              ; $B2AE: A0 30
  JSR $F266                             ; $B2B0: 20 66 F2
  LDA $050E                             ; $B2B3: AD 0E 05
  ASL                                   ; $B2B6: 0A
  ASL                                   ; $B2B7: 0A
  ASL                                   ; $B2B8: 0A
  TAY                                   ; $B2B9: A8
Loc_B2BA:
  LDA $9D72,Y                           ; $B2BA: B9 72 9D
  BPL $B2C4                             ; $B2BD: 10 05
  LDA #$00                              ; $B2BF: A9 00
  JMP $B2D9                             ; $B2C1: 4C D9 B2
Loc_B2C4:
  CMP $052A                             ; $B2C4: CD 2A 05
  BEQ $B2CD                             ; $B2C7: F0 04
  INY                                   ; $B2C9: C8
  JMP $B2BA                             ; $B2CA: 4C BA B2
Loc_B2CD:
  TYA                                   ; $B2CD: 98
  PHA                                   ; $B2CE: 48
  LDY #$31                              ; $B2CF: A0 31
  JSR $F266                             ; $B2D1: 20 66 F2
  PLA                                   ; $B2D4: 68
  TAY                                   ; $B2D5: A8
  LDA $9AB4,Y                           ; $B2D6: B9 B4 9A
Loc_B2D9:
  STA $0020                             ; $B2D9: 8D 20 00
  ASL                                   ; $B2DC: 0A
  ASL                                   ; $B2DD: 0A
  ASL                                   ; $B2DE: 0A
  ASL                                   ; $B2DF: 0A
  ASL                                   ; $B2E0: 0A
  STA $0020                             ; $B2E1: 8D 20 00
  LDY #$26                              ; $B2E4: A0 26
  JSR $F266                             ; $B2E6: 20 66 F2
  LDA $050E                             ; $B2E9: AD 0E 05
  ASL                                   ; $B2EC: 0A
  TAY                                   ; $B2ED: A8
  LDA $8C52,Y                           ; $B2EE: B9 52 8C
  CLC                                   ; $B2F1: 18
  ADC $0020                             ; $B2F2: 6D 20 00
  STA $0020                             ; $B2F5: 8D 20 00
  LDA $8C53,Y                           ; $B2F8: B9 53 8C
  ADC #$00                              ; $B2FB: 69 00
  STA $0021                             ; $B2FD: 8D 21 00
  LDY #$00                              ; $B300: A0 00
Loc_B302:
  LDA $B30E,Y                           ; $B302: B9 0E B3
  STA $0022,Y                           ; $B305: 99 22 00
  INY                                   ; $B308: C8
  CPY #$04                              ; $B309: C0 04
  BCC $B302                             ; $B30B: 90 F5
  RTS                                   ; $B30D: 60
; --- Data Region ---
  .byte $02,$08,$0C,$14                   ; $B30E: 02 08 0C 14
Loc_B312:
; --- Code Region ---
  LDY #$30                              ; $B312: A0 30
  JSR $F266                             ; $B314: 20 66 F2
  LDA $050E                             ; $B317: AD 0E 05
  ASL                                   ; $B31A: 0A
  ASL                                   ; $B31B: 0A
  ASL                                   ; $B31C: 0A
  TAY                                   ; $B31D: A8
Loc_B31E:
  LDA $9D72,Y                           ; $B31E: B9 72 9D
  BPL $B328                             ; $B321: 10 05
  LDA #$00                              ; $B323: A9 00
  JMP $B334                             ; $B325: 4C 34 B3
Loc_B328:
  CMP $052A                             ; $B328: CD 2A 05
  BEQ $B331                             ; $B32B: F0 04
  INY                                   ; $B32D: C8
  JMP $B31E                             ; $B32E: 4C 1E B3
Loc_B331:
  LDA $9E62,Y                           ; $B331: B9 62 9E
Loc_B334:
  STA $0020                             ; $B334: 8D 20 00
  ASL                                   ; $B337: 0A
  ASL                                   ; $B338: 0A
  ASL                                   ; $B339: 0A
  ASL                                   ; $B33A: 0A
  CLC                                   ; $B33B: 18
  ADC $0020                             ; $B33C: 6D 20 00
  ASL                                   ; $B33F: 0A
  STA $0020                             ; $B340: 8D 20 00
  LDY #$26                              ; $B343: A0 26
  JSR $F266                             ; $B345: 20 66 F2
  LDA $050E                             ; $B348: AD 0E 05
  ASL                                   ; $B34B: 0A
  TAY                                   ; $B34C: A8
  LDA $8000,Y                           ; $B34D: B9 00 80
  CLC                                   ; $B350: 18
  ADC $0020                             ; $B351: 6D 20 00
  STA $0020                             ; $B354: 8D 20 00
  LDA $8001,Y                           ; $B357: B9 01 80
  ADC #$00                              ; $B35A: 69 00
  STA $0021                             ; $B35C: 8D 21 00
  LDY #$00                              ; $B35F: A0 00
Loc_B361:
  LDA $B36D,Y                           ; $B361: B9 6D B3
  STA $0022,Y                           ; $B364: 99 22 00
  INY                                   ; $B367: C8
  CPY #$04                              ; $B368: C0 04
  BCC $B361                             ; $B36A: 90 F5
  RTS                                   ; $B36C: 60
; --- Data Region ---
  .byte $02,$0C,$16,$1C                   ; $B36D: 02 0C 16 1C
Loc_B371:
; --- Code Region ---
  LDA $6F91                             ; $B371: AD 91 6F
  TAY                                   ; $B374: A8
  CLC                                   ; $B375: 18
  ADC #$0A                              ; $B376: 69 0A
  STA $002A                             ; $B378: 8D 2A 00
  LDX #$00                              ; $B37B: A2 00
Loc_B37D:
  LDA $0664,Y                           ; $B37D: B9 64 06
  CMP #$FF                              ; $B380: C9 FF
  BEQ $B385                             ; $B382: F0 01
  INX                                   ; $B384: E8
Loc_B385:
  INY                                   ; $B385: C8
  CPY $002A                             ; $B386: CC 2A 00
  BCC $B37D                             ; $B389: 90 F2
  DEX                                   ; $B38B: CA
  STX $6F94                             ; $B38C: 8E 94 6F
  CPX #$02                              ; $B38F: E0 02
  BCS $B394                             ; $B391: B0 01
  RTS                                   ; $B393: 60
Loc_B394:
  LDY #$01                              ; $B394: A0 01
Loc_B396:
  TYA                                   ; $B396: 98
  PHA                                   ; $B397: 48
  LDX $6F91                             ; $B398: AE 91 6F
  TXA                                   ; $B39B: 8A
  CLC                                   ; $B39C: 18
  ADC $6F94                             ; $B39D: 6D 94 6F
  STA $002B                             ; $B3A0: 8D 2B 00
  INX                                   ; $B3A3: E8
Loc_B3A4:
  LDA $0664,X                           ; $B3A4: BD 64 06
  JSR $B491                             ; $B3A7: 20 91 B4
  LDY #$01                              ; $B3AA: A0 01
  LDA ($20),Y                           ; $B3AC: B1 20
  STA $002A                             ; $B3AE: 8D 2A 00
  LDA $0665,X                           ; $B3B1: BD 65 06
  JSR $B491                             ; $B3B4: 20 91 B4
  LDY #$01                              ; $B3B7: A0 01
  LDA ($20),Y                           ; $B3B9: B1 20
  CMP $002A                             ; $B3BB: CD 2A 00
  BCC $B3C3                             ; $B3BE: 90 03
  JSR $B3D2                             ; $B3C0: 20 D2 B3
Loc_B3C3:
  INX                                   ; $B3C3: E8
  CPX $002B                             ; $B3C4: EC 2B 00
  BCC $B3A4                             ; $B3C7: 90 DB
  PLA                                   ; $B3C9: 68
  TAY                                   ; $B3CA: A8
  INY                                   ; $B3CB: C8
  CPY $6F94                             ; $B3CC: CC 94 6F
  BCC $B396                             ; $B3CF: 90 C5
  RTS                                   ; $B3D1: 60
Loc_B3D2:
  LDA $0664,X                           ; $B3D2: BD 64 06
  TAY                                   ; $B3D5: A8
  LDA $0665,X                           ; $B3D6: BD 65 06
  STA $0664,X                           ; $B3D9: 9D 64 06
  TYA                                   ; $B3DC: 98
  STA $0665,X                           ; $B3DD: 9D 65 06
  LDA $0628,X                           ; $B3E0: BD 28 06
  TAY                                   ; $B3E3: A8
  LDA $0629,X                           ; $B3E4: BD 29 06
  STA $0628,X                           ; $B3E7: 9D 28 06
  TYA                                   ; $B3EA: 98
  STA $0629,X                           ; $B3EB: 9D 29 06
  LDA $063C,X                           ; $B3EE: BD 3C 06
  TAY                                   ; $B3F1: A8
  LDA $063D,X                           ; $B3F2: BD 3D 06
  STA $063C,X                           ; $B3F5: 9D 3C 06
  TYA                                   ; $B3F8: 98
  STA $063D,X                           ; $B3F9: 9D 3D 06
  RTS                                   ; $B3FC: 60
; --- Data Region ---
  .byte $10,$00                           ; $B3FD: 10 00
Loc_B3FF:
; --- Code Region ---
  ORA ($00),Y                           ; $B3FF: 11 00
  AND ($00,X)                           ; $B401: 21 00
  AND ($10,X)                           ; $B403: 21 10
  AND ($10),Y                           ; $B405: 31 10
  JAM                                   ; $B407: 32
  BPL $B43C                             ; $B408: 10 32
  ORA ($32),Y                           ; $B40A: 11 32
  AND ($32,X)                           ; $B40C: 21 32
  JAM                                   ; $B40E: 22
  BRK                                   ; $B40F: 00
  BPL $B413                             ; $B410: 10 01
  BPL $B415                             ; $B412: 10 01
  JSR $2011                             ; $B414: 20 11 20
  ORA ($21),Y                           ; $B417: 11 21
  AND ($21,X)                           ; $B419: 21 21
  AND ($31,X)                           ; $B41B: 21 31
  AND ($32,X)                           ; $B41D: 21 32
  AND ($33,X)                           ; $B41F: 21 33
  ORA ($00,X)                           ; $B421: 01 00
  ORA ($10,X)                           ; $B423: 01 10
  ORA ($10),Y                           ; $B425: 11 10
  JAM                                   ; $B427: 12
  BPL $B43C                             ; $B428: 10 12
  JSR $2022                             ; $B42A: 20 22 20
  JAM                                   ; $B42D: 22
  AND ($22,X)                           ; $B42E: 21 22
  JAM                                   ; $B430: 22
  JAM                                   ; $B431: 32
  AND ($10),Y                           ; $B432: 31 10
  BRK                                   ; $B434: 00
  JSR $2100                             ; $B435: 20 00 21
  BRK                                   ; $B438: 00
  AND ($01,X)                           ; $B439: 21 01
  AND ($01),Y                           ; $B43B: 31 01
  AND ($11),Y                           ; $B43D: 31 11
  JAM                                   ; $B43F: 32
  ORA ($42),Y                           ; $B440: 11 42
  ORA ($42),Y                           ; $B442: 11 42
  JAM                                   ; $B444: 12
  BPL $B447                             ; $B445: 10 00
Loc_B447:
  ORA ($00),Y                           ; $B447: 11 00
  ORA ($10),Y                           ; $B449: 11 10
  AND ($10,X)                           ; $B44B: 21 10
  AND ($11,X)                           ; $B44D: 21 11
  JAM                                   ; $B44F: 22
  ORA ($22),Y                           ; $B450: 11 22
  AND ($32,X)                           ; $B452: 21 32
  AND ($33,X)                           ; $B454: 21 33
  AND ($10,X)                           ; $B456: 21 10
  BRK                                   ; $B458: 00
  ORA ($00),Y                           ; $B459: 11 00
  AND ($00,X)                           ; $B45B: 21 00
  AND ($10,X)                           ; $B45D: 21 10
  AND ($11,X)                           ; $B45F: 21 11
  JAM                                   ; $B461: 22
  ORA ($32),Y                           ; $B462: 11 32
  ORA ($33),Y                           ; $B464: 11 33
  ORA ($33),Y                           ; $B466: 11 33
  JAM                                   ; $B468: 12
Loc_B469:
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
Loc_B491:
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
Loc_B4C2:
  AND #$0F                              ; $B4C2: 29 0F
  ASL                                   ; $B4C4: 0A
  TAY                                   ; $B4C5: A8
  LDA $B4D3,Y                           ; $B4C6: B9 D3 B4
  STA $0020                             ; $B4C9: 8D 20 00
  LDA $B4D4,Y                           ; $B4CC: B9 D4 B4
  STA $0021                             ; $B4CF: 8D 21 00
  RTS                                   ; $B4D2: 60
; --- Data Region ---
  .byte $07,$6F,$0F,$6F,$17,$6F,$1F,$6F,$27,$6F,$2F,$6F,$37,$6F; $B4D3: 07 6F 0F 6F 17 6F 1F 6F 27 6F 2F 6F 37 6F
Loc_B4E1:
; --- Code Region ---
  LDY #$31                              ; $B4E1: A0 31
  JSR $F266                             ; $B4E3: 20 66 F2
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
Loc_B517:
  STY $0020                             ; $B517: 8C 20 00
  ASL                                   ; $B51A: 0A
  TAY                                   ; $B51B: A8
  INY                                   ; $B51C: C8
  PLA                                   ; $B51D: 68
  STA $0021                             ; $B51E: 8D 21 00
  PLA                                   ; $B521: 68
  STA $0022                             ; $B522: 8D 22 00
  LDA ($21),Y                           ; $B525: B1 21
  STA $0023                             ; $B527: 8D 23 00
  INY                                   ; $B52A: C8
  LDA ($21),Y                           ; $B52B: B1 21
  STA $0024                             ; $B52D: 8D 24 00
  LDY $0020                             ; $B530: AC 20 00
  JMP ($0023)                           ; $B533: 6C 23 00
Loc_B536:
  LDA #$00                              ; $B536: A9 00
  STA $0025                             ; $B538: 8D 25 00
  STA $0026                             ; $B53B: 8D 26 00
  STA $0027                             ; $B53E: 8D 27 00
  LDY #$17                              ; $B541: A0 17
Loc_B543:
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
  BCC $B581                             ; $B56D: 90 12
  STA $0027                             ; $B56F: 8D 27 00
  LDA $0028                             ; $B572: AD 28 00
  STA $0025                             ; $B575: 8D 25 00
  LDA $0029                             ; $B578: AD 29 00
  STA $0026                             ; $B57B: 8D 26 00
  INC $0020                             ; $B57E: EE 20 00
Loc_B581:
  DEY                                   ; $B581: 88
  BPL $B543                             ; $B582: 10 BF
  RTS                                   ; $B584: 60
Loc_B585:
  LDY #$07                              ; $B585: A0 07
  LDA #$00                              ; $B587: A9 00
  STA $0024                             ; $B589: 8D 24 00
  STA $0025                             ; $B58C: 8D 25 00
  STA $0026                             ; $B58F: 8D 26 00
  STA $0027                             ; $B592: 8D 27 00
  STA $0028                             ; $B595: 8D 28 00
  STA $0029                             ; $B598: 8D 29 00
Loc_B59B:
  LSR $0023                             ; $B59B: 4E 23 00
  BCC $B5C5                             ; $B59E: 90 25
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
Loc_B5C5:
  ASL $0020                             ; $B5C5: 0E 20 00
  ROL $0021                             ; $B5C8: 2E 21 00
  ROL $0022                             ; $B5CB: 2E 22 00
  ROL $0024                             ; $B5CE: 2E 24 00
  DEY                                   ; $B5D1: 88
  BPL $B59B                             ; $B5D2: 10 C7
  RTS                                   ; $B5D4: 60
Loc_B5D5:
  STX $6F93                             ; $B5D5: 8E 93 6F
  LDX $6F92                             ; $B5D8: AE 92 6F
  LDA $B5E5,X                           ; $B5DB: BD E5 B5
  INC $6F92                             ; $B5DE: EE 92 6F
  LDX $6F93                             ; $B5E1: AE 93 6F
  RTS                                   ; $B5E4: 60
; --- Data Region ---
  .byte $3E,$4E,$4F,$83,$0E,$C9           ; $B5E5: 3E 4E 4F 83 0E C9
Loc_B5EB:
; --- Code Region ---
  RRA $FC5D,X                           ; $B5EB: 7F 5D FC
  INC $BA                               ; $B5EE: E6 BA
  ORA ($F8,X)                           ; $B5F0: 01 F8
  BRK                                   ; $B5F2: 00
  NOP $0A,X                             ; $B5F3: F4 0A
  SBC $A9                               ; $B5F5: E5 A9
  STA $E8D1                             ; $B5F7: 8D D1 E8
  DCP $81DE,Y                           ; $B5FA: DB DE 81
  STA $72,X                             ; $B5FD: 95 72
  PHP                                   ; $B5FF: 08
  TXS                                   ; $B600: 9A
  DCP $49                               ; $B601: C7 49
  INY                                   ; $B603: C8
  RLA ($39,X)                           ; $B604: 23 39
  RLA $E0,X                             ; $B606: 37 E0
  STA ($C3),Y                           ; $B608: 91 C3
  RLA ($9B),Y                           ; $B60A: 33 9B
  SRE $41BE,X                           ; $B60C: 5F BE 41
  INC $E274                             ; $B60F: EE 74 E2
  ANC #$47                              ; $B612: 0B 47
  ROR $60BF,X                           ; $B614: 7E BF 60
  LAS $6120,Y                           ; $B617: BB 20 61
  ORA $B2                               ; $B61A: 05 B2
  STY $B6,X                             ; $B61C: 94 B6
  CPX $3A                               ; $B61E: E4 3A
  AND ($1E,X)                           ; $B620: 21 1E
  LDY $8C,X                             ; $B622: B4 8C
  DEC $FE7B                             ; $B624: CE 7B FE
  JAM                                   ; $B627: 22
  NOP $C418,X                           ; $B628: DC 18 C4
  ADC $CDFB                             ; $B62B: 6D FB CD
  RLA $A0                               ; $B62E: 27 A0
  ORA #$6E                              ; $B630: 09 6E
  SEC                                   ; $B632: 38
  TXA                                   ; $B633: 8A
  NOP $7C                               ; $B634: 04 7C
  LSR $97,X                             ; $B636: 56 97
  NOP                                   ; $B638: 5A
  TAY                                   ; $B639: A8
  EOR $B578                             ; $B63A: 4D 78 B5
  JMP ($03AA)                           ; $B63D: 6C AA 03
; --- Data Region ---
  .byte $1A,$4A,$0D,$26,$82,$AD,$02,$A1,$B9,$A3,$6B,$D8,$0C,$4C,$AE,$19; $B640: 1A 4A 0D 26 82 AD 02 A1 B9 A3 6B D8 0C 4C AE 19
  .byte $45,$5B,$9C,$16,$07,$89,$51,$90,$29,$F5,$62,$F7,$CB,$F1,$53,$FF; $B650: 45 5B 9C 16 07 89 51 90 29 F5 62 F7 CB F1 53 FF
  .byte $14,$65,$D0,$87,$35,$10,$73,$7A,$9F,$EB,$D9,$3C,$EF,$9E,$D7,$3D; $B660: 14 65 D0 87 35 10 73 7A 9F EB D9 3C EF 9E D7 3D
  .byte $6F,$D6,$84,$AB,$11,$CA,$D2,$88,$17,$E1,$A6,$52,$8E,$5E,$36,$24; $B670: 6F D6 84 AB 11 CA D2 88 17 E1 A6 52 8E 5E 36 24
  .byte $44,$28                           ; $B680: 44 28
Loc_B682:
; --- Code Region ---
  LDY $55                               ; $B682: A4 55
  LAX $C2                               ; $B684: A7 C2
  SBC $2E76,X                           ; $B686: FD 76 2E
  LAX $D5,Y                             ; $B689: B7 D5
  INC $64,X                             ; $B68B: F6 64
  ORA $31,X                             ; $B68D: 15 31
  STA $C093,Y                           ; $B68F: 99 93 C0
  SAX $FAB3                             ; $B692: 8F B3 FA
  SBC #$E3                              ; $B695: E9 E3
Loc_B697:
  RRA $4B                               ; $B697: 67 4B
  STA $32                               ; $B699: 85 32
  DEC $69                               ; $B69B: C6 69
  PHA                                   ; $B69D: 48
  DCP $ECA2,X                           ; $B69E: DF A2 EC
  TYA                                   ; $B6A1: 98
  ROR                                   ; $B6A2: 6A
  ISB $D4                               ; $B6A3: E7 D4
  NOP $58F3,X                           ; $B6A5: 1C F3 58
  BVC $B697                             ; $B6A8: 50 ED
  ANC #$1D                              ; $B6AA: 2B 1D
  STX $F0                               ; $B6AC: 86 F0
  ADC ($BD),Y                           ; $B6AE: 71 BD
  NOP $1B,X                             ; $B6B0: 34 1B
  LAX $2D30                             ; $B6B2: AF 30 2D
  PLA                                   ; $B6B5: 68
Loc_B6B6:
  CPY $570F                             ; $B6B6: CC 0F 57
  NOP                                   ; $B6B9: EA
  JAM                                   ; $B6BA: 92
  XAA #$3F                              ; $B6BB: 8B 3F
  RLA $B8AC,Y                           ; $B6BD: 3B AC B8
  CMP ($2F,X)                           ; $B6C0: C1 2F
  JAM                                   ; $B6C2: F2
  LSR $75                               ; $B6C3: 46 75
  STX $7D,Y                             ; $B6C5: 96 7D
  ROL                                   ; $B6C7: 2A
  ADC $DA40,Y                           ; $B6C8: 79 40 DA
  STA $1225,X                           ; $B6CB: 9D 25 12
  JAM                                   ; $B6CE: 42
  NOP $D3,X                             ; $B6CF: 54 D3
  SLO $5C80,X                           ; $B6D1: 1F 80 5C
  EOR $F943,Y                           ; $B6D4: 59 43 F9
  BCS $B6B6                             ; $B6D7: B0 DD
  RRA ($A5,X)                           ; $B6D9: 63 A5
  RRA $CF,X                             ; $B6DB: 77 CF
  SLO ($2C),Y                           ; $B6DD: 13 2C
  ROR $BC                               ; $B6DF: 66 BC
  BVS $B694                             ; $B6E1: 70 B1
  CMP $06                               ; $B6E3: C5 06
Loc_B6E5:
  JSR $B6EF                             ; $B6E5: 20 EF B6
  CMP #$06                              ; $B6E8: C9 06
  BCC $B6EE                             ; $B6EA: 90 02
  LDA #$02                              ; $B6EC: A9 02
Loc_B6EE:
  RTS                                   ; $B6EE: 60
Loc_B6EF:
  LDY #$00                              ; $B6EF: A0 00
  LDA $0020                             ; $B6F1: AD 20 00
  CMP #$10                              ; $B6F4: C9 10
  BCC $B6FA                             ; $B6F6: 90 02
  LDY #$01                              ; $B6F8: A0 01
Loc_B6FA:
  LDA $0021                             ; $B6FA: AD 21 00
  CMP #$10                              ; $B6FD: C9 10
  BCC $B705                             ; $B6FF: 90 04
  TYA                                   ; $B701: 98
  ORA #$02                              ; $B702: 09 02
  TAY                                   ; $B704: A8
Loc_B705:
  LDA ($A8),Y                           ; $B705: B1 A8
  PHA                                   ; $B707: 48
  ASL                                   ; $B708: 0A
  TAY                                   ; $B709: A8
  LDA $B7CB,Y                           ; $B70A: B9 CB B7
  STA $0022                             ; $B70D: 8D 22 00
  LDA $B7CC,Y                           ; $B710: B9 CC B7
  STA $0023                             ; $B713: 8D 23 00
  PLA                                   ; $B716: 68
  TAY                                   ; $B717: A8
  LDA $B8BB,Y                           ; $B718: B9 BB B8
  TAY                                   ; $B71B: A8
  JSR $F266                             ; $B71C: 20 66 F2
  LDA #$4B                              ; $B71F: A9 4B
  STA $0024                             ; $B721: 8D 24 00
  LDA #$B7                              ; $B724: A9 B7
  STA $0025                             ; $B726: 8D 25 00
  LDA $0020                             ; $B729: AD 20 00
  AND #$0F                              ; $B72C: 29 0F
  STA $0026                             ; $B72E: 8D 26 00
  LDX #$00                              ; $B731: A2 00
  LDA $0021                             ; $B733: AD 21 00
  ASL                                   ; $B736: 0A
  ASL                                   ; $B737: 0A
  ASL                                   ; $B738: 0A
  ASL                                   ; $B739: 0A
  ORA $0026                             ; $B73A: 0D 26 00
  TAY                                   ; $B73D: A8
  LDA ($22),Y                           ; $B73E: B1 22
  TAY                                   ; $B740: A8
  CMP #$80                              ; $B741: C9 80
  BCC $B748                             ; $B743: 90 03
  LDA #$00                              ; $B745: A9 00
  RTS                                   ; $B747: 60
Loc_B748:
  LDA ($24),Y                           ; $B748: B1 24
  RTS                                   ; $B74A: 60
; --- Data Region ---
  .byte $00,$01,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03; $B74B: 00 01 03 03 03 03 03 03 03 03 03 03 03 03 03 03
  .byte $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$02,$02,$02,$02; $B75B: 03 03 03 03 03 03 03 03 03 03 03 03 02 02 02 02
  .byte $04,$04,$02,$04,$04,$02,$04       ; $B76B: 04 04 02 04 04 02 04
Loc_B772:
; --- Code Region ---
  JAM                                   ; $B772: 02
  NOP $04                               ; $B773: 04 04
  NOP $02                               ; $B775: 04 02
  BRK                                   ; $B777: 00
Loc_B778:
  BRK                                   ; $B778: 00
  JAM                                   ; $B779: 02
  JAM                                   ; $B77A: 02
  JAM                                   ; $B77B: 02
  JAM                                   ; $B77C: 02
  JAM                                   ; $B77D: 02
  JAM                                   ; $B77E: 02
  JAM                                   ; $B77F: 02
  JAM                                   ; $B780: 02
  BRK                                   ; $B781: 00
  BRK                                   ; $B782: 00
  BRK                                   ; $B783: 00
  JAM                                   ; $B784: 02
  BRK                                   ; $B785: 00
  BRK                                   ; $B786: 00
  BRK                                   ; $B787: 00
  BRK                                   ; $B788: 00
  BRK                                   ; $B789: 00
  BRK                                   ; $B78A: 00
  SLO ($03,X)                           ; $B78B: 03 03
  SLO ($03,X)                           ; $B78D: 03 03
Loc_B78F:
  SLO ($03,X)                           ; $B78F: 03 03
  SLO ($03,X)                           ; $B791: 03 03
  JAM                                   ; $B793: 02
  BRK                                   ; $B794: 00
  BRK                                   ; $B795: 00
  BRK                                   ; $B796: 00
  JAM                                   ; $B797: 02
  JAM                                   ; $B798: 02
  JAM                                   ; $B799: 02
  JAM                                   ; $B79A: 02
  JAM                                   ; $B79B: 02
  JAM                                   ; $B79C: 02
  JAM                                   ; $B79D: 02
  JAM                                   ; $B79E: 02
  JAM                                   ; $B79F: 02
Loc_B7A0:
  JAM                                   ; $B7A0: 02
  NOP $02                               ; $B7A1: 04 02
  JAM                                   ; $B7A3: 02
  NOP $02                               ; $B7A4: 04 02
Loc_B7A6:
  NOP $04                               ; $B7A6: 04 04
  NOP $03                               ; $B7A8: 04 03
  BRK                                   ; $B7AA: 00
  BRK                                   ; $B7AB: 00
  ORA $05                               ; $B7AC: 05 05
  ORA $05                               ; $B7AE: 05 05
  SLO ($00,X)                           ; $B7B0: 03 00
  SLO ($03,X)                           ; $B7B2: 03 03
  SLO ($01,X)                           ; $B7B4: 03 01
  ORA ($01,X)                           ; $B7B6: 01 01
  ORA ($02,X)                           ; $B7B8: 01 02
  JAM                                   ; $B7BA: 02
  ORA ($02,X)                           ; $B7BB: 01 02
  JAM                                   ; $B7BD: 02
  JAM                                   ; $B7BE: 02
  ORA ($02,X)                           ; $B7BF: 01 02
  JAM                                   ; $B7C1: 02
  SLO ($03,X)                           ; $B7C2: 03 03
  ASL $07                               ; $B7C4: 06 07
  PHP                                   ; $B7C6: 08
  BRK                                   ; $B7C7: 00
  BRK                                   ; $B7C8: 00
  BRK                                   ; $B7C9: 00
  BRK                                   ; $B7CA: 00
  RTI                                   ; $B7CB: 40
; --- Data Region ---
  .byte $80,$70,$81,$00,$82,$30,$83,$C0,$83,$F0,$84,$80,$85,$B0,$86,$40; $B7CC: 80 70 81 00 82 30 83 C0 83 F0 84 80 85 B0 86 40
  .byte $87,$70,$88,$00                   ; $B7DC: 87 70 88 00
Loc_B7E0:
; --- Code Region ---
  NOP #$30                              ; $B7E0: 89 30
  TXA                                   ; $B7E2: 8A
  CPY #$8A                              ; $B7E3: C0 8A
  BEQ $B772                             ; $B7E5: F0 8B
  NOP #$8C                              ; $B7E7: 80 8C
  BCS $B778                             ; $B7E9: B0 8D
  RTI                                   ; $B7EB: 40
; --- Data Region ---
  .byte $8E,$70,$8F,$00,$90,$30           ; $B7EC: 8E 70 8F 00 90 30
Loc_B7F2:
; --- Code Region ---
  STA ($C0),Y                           ; $B7F2: 91 C0
  STA ($F0),Y                           ; $B7F4: 91 F0
  JAM                                   ; $B7F6: 92
  NOP #$93                              ; $B7F7: 80 93
  BCS $B78F                             ; $B7F9: B0 94
  RTI                                   ; $B7FB: 40
  STA $70,X                             ; $B7FC: 95 70
  STX $00,Y                             ; $B7FE: 96 00
  SAX $30,Y                             ; $B800: 97 30
  TYA                                   ; $B802: 98
  CPY #$98                              ; $B803: C0 98
  BEQ $B7A0                             ; $B805: F0 99
  NOP #$9A                              ; $B807: 80 9A
  BCS $B7A6                             ; $B809: B0 9B
  LDX $89                               ; $B80B: A6 89
  DEC $8A,X                             ; $B80D: D6 8A
Loc_B80F:
  ROR $8B                               ; $B80F: 66 8B
  STX $8C,Y                             ; $B811: 96 8C
  ROL $8D                               ; $B813: 26 8D
  LSR $8E,X                             ; $B815: 56 8E
  INC $8E                               ; $B817: E6 8E
  ASL $90,X                             ; $B819: 16 90
  LDX $90                               ; $B81B: A6 90
  DEC $91,X                             ; $B81D: D6 91
  ROR $92                               ; $B81F: 66 92
  STX $93,Y                             ; $B821: 96 93
  ROL $94                               ; $B823: 26 94
  LSR $95,X                             ; $B825: 56 95
  INC $95                               ; $B827: E6 95
  ASL $97,X                             ; $B829: 16 97
  LDX $97                               ; $B82B: A6 97
  DEC $98,X                             ; $B82D: D6 98
  ROR $99                               ; $B82F: 66 99
  STX $9A,Y                             ; $B831: 96 9A
  ROL $9B                               ; $B833: 26 9B
  LSR $9C,X                             ; $B835: 56 9C
  INC $9C                               ; $B837: E6 9C
  ASL $9E,X                             ; $B839: 16 9E
  RTI                                   ; $B83B: 40
; --- Data Region ---
  .byte $95,$70,$96,$00,$97,$30,$98,$C0,$98,$F0,$99,$80,$9A,$B0,$9B,$40; $B83C: 95 70 96 00 97 30 98 C0 98 F0 99 80 9A B0 9B 40
  .byte $80,$70,$81                       ; $B84C: 80 70 81
Loc_B84F:
; --- Code Region ---
  BRK                                   ; $B84F: 00
  NOP #$30                              ; $B850: 82 30
  SAX ($C0,X)                           ; $B852: 83 C0
  SAX ($F0,X)                           ; $B854: 83 F0
  STY $80                               ; $B856: 84 80
  STA $B0                               ; $B858: 85 B0
  STX $40                               ; $B85A: 86 40
  SAX $70                               ; $B85C: 87 70
  DEY                                   ; $B85E: 88
  BRK                                   ; $B85F: 00
  NOP #$30                              ; $B860: 89 30
  TXA                                   ; $B862: 8A
  CPY #$8A                              ; $B863: C0 8A
  BEQ $B7F2                             ; $B865: F0 8B
  NOP #$8C                              ; $B867: 80 8C
  BCS $B7F8                             ; $B869: B0 8D
  RTI                                   ; $B86B: 40
; --- Data Region ---
  .byte $8E,$70,$8F,$00,$90,$30,$91,$C0,$91,$F0,$92,$80,$93,$B0,$94,$40; $B86C: 8E 70 8F 00 90 30 91 C0 91 F0 92 80 93 B0 94 40
  .byte $95,$70,$96,$00,$97,$30,$98,$C0,$98,$F0,$99,$80,$9A,$B0,$9B,$40; $B87C: 95 70 96 00 97 30 98 C0 98 F0 99 80 9A B0 9B 40
  .byte $80,$70,$81,$00,$82,$30,$83,$C0,$83,$F0,$84,$80,$85,$B0,$86,$40; $B88C: 80 70 81 00 82 30 83 C0 83 F0 84 80 85 B0 86 40
  .byte $87,$70,$88,$00,$89,$30           ; $B89C: 87 70 88 00 89 30
Loc_B8A2:
; --- Code Region ---
  TXA                                   ; $B8A2: 8A
  CPY #$8A                              ; $B8A3: C0 8A
  BEQ $B832                             ; $B8A5: F0 8B
  NOP #$8C                              ; $B8A7: 80 8C
  BCS $B838                             ; $B8A9: B0 8D
  RTI                                   ; $B8AB: 40
; --- Data Region ---
  .byte $8E,$70,$8F,$00,$90,$30,$91,$C0,$91,$F0,$92,$80,$93,$B0,$94,$20; $B8AC: 8E 70 8F 00 90 30 91 C0 91 F0 92 80 93 B0 94 20
  .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20; $B8BC: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20
  .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$23; $B8CC: 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 23
  .byte $23,$23,$23,$23,$23,$23           ; $B8DC: 23 23 23 23 23 23
Loc_B8E2:
; --- Code Region ---
  RLA ($23,X)                           ; $B8E2: 23 23
  RLA ($23,X)                           ; $B8E4: 23 23
  RLA ($23,X)                           ; $B8E6: 23 23
  RLA ($23,X)                           ; $B8E8: 23 23
  RLA ($23,X)                           ; $B8EA: 23 23
  RLA ($23,X)                           ; $B8EC: 23 23
  RLA ($23,X)                           ; $B8EE: 23 23
  RLA ($23,X)                           ; $B8F0: 23 23
  RLA ($25,X)                           ; $B8F2: 23 25
  AND $25                               ; $B8F4: 25 25
  AND $25                               ; $B8F6: 25 25
  AND $25                               ; $B8F8: 25 25
  AND $24                               ; $B8FA: 25 24
  BIT $24                               ; $B8FC: 24 24
  BIT $24                               ; $B8FE: 24 24
  BIT $24                               ; $B900: 24 24
  BIT $24                               ; $B902: 24 24
  BIT $24                               ; $B904: 24 24
  BIT $24                               ; $B906: 24 24
  BIT $24                               ; $B908: 24 24
  BIT $24                               ; $B90A: 24 24
  BIT $24                               ; $B90C: 24 24
  BIT $24                               ; $B90E: 24 24
  BIT $24                               ; $B910: 24 24
  BIT $24                               ; $B912: 24 24
  BIT $24                               ; $B914: 24 24
  BIT $24                               ; $B916: 24 24
  BIT $24                               ; $B918: 24 24
  BIT $25                               ; $B91A: 24 25
  AND $25                               ; $B91C: 25 25
  AND $25                               ; $B91E: 25 25
  AND $25                               ; $B920: 25 25
  AND $25                               ; $B922: 25 25
  AND $25                               ; $B924: 25 25
  AND $25                               ; $B926: 25 25
  AND $25                               ; $B928: 25 25
  AND $25                               ; $B92A: 25 25
  AND $25                               ; $B92C: 25 25
  AND $25                               ; $B92E: 25 25
  AND $25                               ; $B930: 25 25
  AND $A9                               ; $B932: 25 A9
  ISB $8F8D,X                           ; $B934: FF 8D 8F
  RRA $04A0                             ; $B937: 6F A0 04
  LDA $0504                             ; $B93A: AD 04 05
  BPL $B941                             ; $B93D: 10 02
  LDY #$00                              ; $B93F: A0 00
Loc_B941:
  STY $002A                             ; $B941: 8C 2A 00
  LDA $04D8,Y                           ; $B944: B9 D8 04
  CMP #$FF                              ; $B947: C9 FF
  BNE $B94E                             ; $B949: D0 03
  JMP $BAAD                             ; $B94B: 4C AD BA
Loc_B94E:
  LDA $04D9,Y                           ; $B94E: B9 D9 04
  STA $0020                             ; $B951: 8D 20 00
  LDA $04DA,Y                           ; $B954: B9 DA 04
  STA $0021                             ; $B957: 8D 21 00
  LDX $6F8C                             ; $B95A: AE 8C 6F
  LDA $0600,X                           ; $B95D: BD 00 06
  CMP $0020                             ; $B960: CD 20 00
  BNE $B96D                             ; $B963: D0 08
  LDA $0614,Y                           ; $B965: B9 14 06
  CMP $0021                             ; $B968: CD 21 00
  BEQ $B98D                             ; $B96B: F0 20
Loc_B96D:
  LDA $0021                             ; $B96D: AD 21 00
  CMP #$10                              ; $B970: C9 10
  BCC $B97A                             ; $B972: 90 06
  SEC                                   ; $B974: 38
  SBC #$01                              ; $B975: E9 01
  STA $0021                             ; $B977: 8D 21 00
Loc_B97A:
  LDA #$02                              ; $B97A: A9 02
  STA $0022                             ; $B97C: 8D 22 00
  JSR $A8E8                             ; $B97F: 20 E8 A8
  LDX $6F8C                             ; $B982: AE 8C 6F
  LDA $6FC9,X                           ; $B985: BD C9 6F
  BNE $B98D                             ; $B988: D0 03
  JMP $BAAD                             ; $B98A: 4C AD BA
Loc_B98D:
  LDX $6F8C                             ; $B98D: AE 8C 6F
  LDA $0600,X                           ; $B990: BD 00 06
  STA $0020                             ; $B993: 8D 20 00
  LDA $0614,X                           ; $B996: BD 14 06
  STA $0021                             ; $B999: 8D 21 00
  JSR $B6E5                             ; $B99C: 20 E5 B6
  CMP #$00                              ; $B99F: C9 00
  BEQ $B9A6                             ; $B9A1: F0 03
  JMP $BAAD                             ; $B9A3: 4C AD BA
Loc_B9A6:
  LDY $002A                             ; $B9A6: AC 2A 00
  LDA $04D8,Y                           ; $B9A9: B9 D8 04
  TAX                                   ; $B9AC: AA
  LDA $0664,X                           ; $B9AD: BD 64 06
  JSR $B491                             ; $B9B0: 20 91 B4
  LDY #$02                              ; $B9B3: A0 02
  LDA ($20),Y                           ; $B9B5: B1 20
  STA $0023                             ; $B9B7: 8D 23 00
  LDY #$0B                              ; $B9BA: A0 0B
  LDA ($20),Y                           ; $B9BC: B1 20
  STA $0024                             ; $B9BE: 8D 24 00
  LDY $6F8C                             ; $B9C1: AC 8C 6F
  LDA $0664,Y                           ; $B9C4: B9 64 06
  JSR $B491                             ; $B9C7: 20 91 B4
  LDY #$02                              ; $B9CA: A0 02
  LDA ($20),Y                           ; $B9CC: B1 20
  STA $0022                             ; $B9CE: 8D 22 00
  LDA $0023                             ; $B9D1: AD 23 00
  SEC                                   ; $B9D4: 38
  SBC $0022                             ; $B9D5: ED 22 00
  BPL $B9DC                             ; $B9D8: 10 02
  LDA #$00                              ; $B9DA: A9 00
Loc_B9DC:
  CLC                                   ; $B9DC: 18
  ADC #$0A                              ; $B9DD: 69 0A
  STA $0020                             ; $B9DF: 8D 20 00
Loc_B9E2:
  JSR $B5D5                             ; $B9E2: 20 D5 B5
  CMP #$65                              ; $B9E5: C9 65
  BCS $B9E2                             ; $B9E7: B0 F9
  LDA $0024                             ; $B9E9: AD 24 00
  ASL                                   ; $B9EC: 0A
  ASL                                   ; $B9ED: 0A
  ASL                                   ; $B9EE: 0A
  CLC                                   ; $B9EF: 18
  ADC $0024                             ; $B9F0: 6D 24 00
  ADC $0024                             ; $B9F3: 6D 24 00
  STA $002A                             ; $B9F6: 8D 2A 00
  LDA $0023                             ; $B9F9: AD 23 00
  STA $0020                             ; $B9FC: 8D 20 00
  LDA #$00                              ; $B9FF: A9 00
  STA $0021                             ; $BA01: 8D 21 00
  STA $0022                             ; $BA04: 8D 22 00
Loc_BA07:
  JSR $B5D5                             ; $BA07: 20 D5 B5
  CMP #$0B                              ; $BA0A: C9 0B
  BCS $BA07                             ; $BA0C: B0 F9
  CLC                                   ; $BA0E: 18
  ADC #$1E                              ; $BA0F: 69 1E
  STA $0023                             ; $BA11: 8D 23 00
  JSR $B585                             ; $BA14: 20 85 B5
  LDA $0026                             ; $BA17: AD 26 00
  STA $0020                             ; $BA1A: 8D 20 00
  LDA $0027                             ; $BA1D: AD 27 00
  STA $0021                             ; $BA20: 8D 21 00
  LDA #$0A                              ; $BA23: A9 0A
  STA $0023                             ; $BA25: 8D 23 00
  LDA #$00                              ; $BA28: A9 00
  STA $0022                             ; $BA2A: 8D 22 00
  STA $0024                             ; $BA2D: 8D 24 00
  JSR $B536                             ; $BA30: 20 36 B5
  LDA $0020                             ; $BA33: AD 20 00
  CLC                                   ; $BA36: 18
  ADC $002A                             ; $BA37: 6D 2A 00
  STA $0022                             ; $BA3A: 8D 22 00
  LDA $0021                             ; $BA3D: AD 21 00
  ADC #$00                              ; $BA40: 69 00
  STA $0023                             ; $BA42: 8D 23 00
  LDY $6F8C                             ; $BA45: AC 8C 6F
  LDA $0664,Y                           ; $BA48: B9 64 06
  JSR $B491                             ; $BA4B: 20 91 B4
  LDY #$08                              ; $BA4E: A0 08
  LDA ($20),Y                           ; $BA50: B1 20
  STA $0024                             ; $BA52: 8D 24 00
  INY                                   ; $BA55: C8
  LDA ($20),Y                           ; $BA56: B1 20
  AND #$03                              ; $BA58: 29 03
  STA $0025                             ; $BA5A: 8D 25 00
  LDA $0024                             ; $BA5D: AD 24 00
  SEC                                   ; $BA60: 38
  SBC $0022                             ; $BA61: ED 22 00
  STA $0026                             ; $BA64: 8D 26 00
  LDA $0025                             ; $BA67: AD 25 00
  SBC $0023                             ; $BA6A: ED 23 00
  STA $0027                             ; $BA6D: 8D 27 00
  BCS $BA86                             ; $BA70: B0 14
  LDA $0024                             ; $BA72: AD 24 00
  STA $0022                             ; $BA75: 8D 22 00
  LDA $0025                             ; $BA78: AD 25 00
  STA $0023                             ; $BA7B: 8D 23 00
  LDA #$00                              ; $BA7E: A9 00
  STA $0026                             ; $BA80: 8D 26 00
  STA $0027                             ; $BA83: 8D 27 00
Loc_BA86:
  LDY #$08                              ; $BA86: A0 08
  LDA $0026                             ; $BA88: AD 26 00
  STA ($20),Y                           ; $BA8B: 91 20
  INY                                   ; $BA8D: C8
  LDA ($20),Y                           ; $BA8E: B1 20
  AND #$FC                              ; $BA90: 29 FC
  ORA $0027                             ; $BA92: 0D 27 00
  STA ($20),Y                           ; $BA95: 91 20
  LDA $0022                             ; $BA97: AD 22 00
  STA $042C                             ; $BA9A: 8D 2C 04
  LDA $0023                             ; $BA9D: AD 23 00
  STA $042D                             ; $BAA0: 8D 2D 04
  LDA #$00                              ; $BAA3: A9 00
  STA $042E                             ; $BAA5: 8D 2E 04
  LDA #$00                              ; $BAA8: A9 00
  STA $6F8F                             ; $BAAA: 8D 8F 6F
Loc_BAAD:
  LDA #$FF                              ; $BAAD: A9 FF
  STA $6F8B                             ; $BAAF: 8D 8B 6F
  RTS                                   ; $BAB2: 60
Loc_BAB3:
  LDA $0501                             ; $BAB3: AD 01 05
  JSR $EADE                             ; $BAB6: 20 DE EA
; --- Data Region ---
  .byte $C1,$BA,$3D,$BB,$93,$BB,$A0,$BB   ; $BAB9: C1 BA 3D BB 93 BB A0 BB
Loc_BAC1:  ; (dispatch callback target)
; --- Code Region ---
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
  LDA $0507                             ; $BAE3: AD 07 05
  LSR                                   ; $BAE6: 4A
  LSR                                   ; $BAE7: 4A
  LSR                                   ; $BAE8: 4A
  LSR                                   ; $BAE9: 4A
  JSR $F368                             ; $BAEA: 20 68 F3
  LDY #$03                              ; $BAED: A0 03
  LDA ($00),Y                           ; $BAEF: B1 00
  CMP #$03                              ; $BAF1: C9 03
  BEQ $BB1F                             ; $BAF3: F0 2A
  STA $6F44                             ; $BAF5: 8D 44 6F
  LDA $0514                             ; $BAF8: AD 14 05
  BEQ $BB0F                             ; $BAFB: F0 12
  LDA #$0A                              ; $BAFD: A9 0A
  LDA #$0D                              ; $BAFF: A9 0D
  STA $0500                             ; $BB01: 8D 00 05
  LDA #$00                              ; $BB04: A9 00
  STA $0501                             ; $BB06: 8D 01 05
  LDA #$11                              ; $BB09: A9 11
  STA $050B                             ; $BB0B: 8D 0B 05
  RTS                                   ; $BB0E: 60
Loc_BB0F:
  LDA #$0E                              ; $BB0F: A9 0E
  STA $0500                             ; $BB11: 8D 00 05
  LDA #$00                              ; $BB14: A9 00
  STA $0501                             ; $BB16: 8D 01 05
  LDA #$11                              ; $BB19: A9 11
  STA $050B                             ; $BB1B: 8D 0B 05
  RTS                                   ; $BB1E: 60
Loc_BB1F:
  LDA #$80                              ; $BB1F: A9 80
  STA $0504                             ; $BB21: 8D 04 05
  LDA $0514                             ; $BB24: AD 14 05
  BEQ $BB31                             ; $BB27: F0 08
  LDA #$02                              ; $BB29: A9 02
  STA $6F91                             ; $BB2B: 8D 91 6F
  JMP $BB36                             ; $BB2E: 4C 36 BB
Loc_BB31:
  LDA #$00                              ; $BB31: A9 00
  STA $6F91                             ; $BB33: 8D 91 6F
Loc_BB36:
  JSR $BC46                             ; $BB36: 20 46 BC
  INC $0501                             ; $BB39: EE 01 05
  RTS                                   ; $BB3C: 60
Loc_BB3D:  ; (dispatch callback target)
  LDA $0507                             ; $BB3D: AD 07 05
  AND #$0F                              ; $BB40: 29 0F
  JSR $F368                             ; $BB42: 20 68 F3
  LDY #$03                              ; $BB45: A0 03
  LDA ($00),Y                           ; $BB47: B1 00
  CMP #$03                              ; $BB49: C9 03
  BEQ $BB75                             ; $BB4B: F0 28
  STA $6F44                             ; $BB4D: 8D 44 6F
  LDA $0514                             ; $BB50: AD 14 05
  BNE $BB65                             ; $BB53: D0 10
  LDA #$0D                              ; $BB55: A9 0D
  STA $0500                             ; $BB57: 8D 00 05
  LDA #$00                              ; $BB5A: A9 00
  STA $0501                             ; $BB5C: 8D 01 05
  LDA #$02                              ; $BB5F: A9 02
  STA $050B                             ; $BB61: 8D 0B 05
  RTS                                   ; $BB64: 60
Loc_BB65:
  LDA #$0E                              ; $BB65: A9 0E
  STA $0500                             ; $BB67: 8D 00 05
  LDA #$00                              ; $BB6A: A9 00
  STA $0501                             ; $BB6C: 8D 01 05
  LDA #$02                              ; $BB6F: A9 02
  STA $050B                             ; $BB71: 8D 0B 05
  RTS                                   ; $BB74: 60
Loc_BB75:
  LDA #$00                              ; $BB75: A9 00
  STA $0504                             ; $BB77: 8D 04 05
  LDA $0514                             ; $BB7A: AD 14 05
  BNE $BB87                             ; $BB7D: D0 08
  LDA #$01                              ; $BB7F: A9 01
  STA $6F91                             ; $BB81: 8D 91 6F
  JMP $BB8C                             ; $BB84: 4C 8C BB
Loc_BB87:
  LDA #$00                              ; $BB87: A9 00
  STA $6F91                             ; $BB89: 8D 91 6F
Loc_BB8C:
  JSR $BC46                             ; $BB8C: 20 46 BC
  INC $0501                             ; $BB8F: EE 01 05
  RTS                                   ; $BB92: 60
Loc_BB93:  ; (dispatch callback target)
  JSR $ECEE                             ; $BB93: 20 EE EC
  JSR $BF0A                             ; $BB96: 20 0A BF
  JSR $C027                             ; $BB99: 20 27 C0
  INC $0501                             ; $BB9C: EE 01 05
  RTS                                   ; $BB9F: 60
Loc_BBA0:  ; (dispatch callback target)
  LDA $0087                             ; $BBA0: AD 87 00
  BPL $BBB7                             ; $BBA3: 10 12
  JSR $BBB8                             ; $BBA5: 20 B8 BB
  LDA #$01                              ; $BBA8: A9 01
  STA $007A                             ; $BBAA: 8D 7A 00
  LDA #$0D                              ; $BBAD: A9 0D
  STA $0400                             ; $BBAF: 8D 00 04
  LDA #$00                              ; $BBB2: A9 00
  STA $0401                             ; $BBB4: 8D 01 04
Loc_BBB7:
  RTS                                   ; $BBB7: 60
Loc_BBB8:
  LDY #$30                              ; $BBB8: A0 30
  JSR $F25F                             ; $BBBA: 20 5F F2
  LDA $050E                             ; $BBBD: AD 0E 05
  JSR $F2AF                             ; $BBC0: 20 AF F2
  LDA $0514                             ; $BBC3: AD 14 05
  BNE $BBDF                             ; $BBC6: D0 17
  LDA $0507                             ; $BBC8: AD 07 05
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
Loc_BBDF:
  JSR $BC00                             ; $BBDF: 20 00 BC
  LDA $050E                             ; $BBE2: AD 0E 05
  ASL                                   ; $BBE5: 0A
  ASL                                   ; $BBE6: 0A
  ASL                                   ; $BBE7: 0A
  TAY                                   ; $BBE8: A8
Loc_BBE9:
  TYA                                   ; $BBE9: 98
  PHA                                   ; $BBEA: 48
  LDA $9D72,Y                           ; $BBEB: B9 72 9D
  CMP #$FF                              ; $BBEE: C9 FF
  BNE $BBF4                             ; $BBF0: D0 02
  PLA                                   ; $BBF2: 68
  RTS                                   ; $BBF3: 60
Loc_BBF4:
  JSR $F2AF                             ; $BBF4: 20 AF F2
  JSR $BC00                             ; $BBF7: 20 00 BC
  PLA                                   ; $BBFA: 68
  TAY                                   ; $BBFB: A8
  INY                                   ; $BBFC: C8
  JMP $BBE9                             ; $BBFD: 4C E9 BB
Loc_BC00:
  LDA $0000                             ; $BC00: AD 00 00
  STA $000A                             ; $BC03: 8D 0A 00
  LDA $0001                             ; $BC06: AD 01 00
  STA $000B                             ; $BC09: 8D 0B 00
  LDY #$00                              ; $BC0C: A0 00
  LDA ($0A),Y                           ; $BC0E: B1 0A
  AND #$0F                              ; $BC10: 29 0F
  CMP #$07                              ; $BC12: C9 07
  BNE $BC17                             ; $BC14: D0 01
  RTS                                   ; $BC16: 60
Loc_BC17:
  JSR $F368                             ; $BC17: 20 68 F3
  LDY #$00                              ; $BC1A: A0 00
  LDA ($00),Y                           ; $BC1C: B1 00
  STA $0002                             ; $BC1E: 8D 02 00
  LDY #$11                              ; $BC21: A0 11
Loc_BC23:
  LDA ($0A),Y                           ; $BC23: B1 0A
  CMP $0002                             ; $BC25: CD 02 00
  BEQ $BC30                             ; $BC28: F0 06
  INY                                   ; $BC2A: C8
  CPY #$1B                              ; $BC2B: C0 1B
  BCC $BC23                             ; $BC2D: 90 F4
  RTS                                   ; $BC2F: 60
Loc_BC30:
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
Loc_BC46:
  LDA $6F91                             ; $BC46: AD 91 6F
  JSR $EADE                             ; $BC49: 20 DE EA
; --- Data Region ---
  .byte $52,$BC,$59,$BD,$67,$BD,$20,$CD,$BD,$AD,$0E,$05,$8D,$02,$00,$A9; $BC4C: 52 BC 59 BD 67 BD 20 CD BD AD 0E 05 8D 02 00 A9
  .byte $11,$8D,$03,$00,$A9,$00,$8D,$04,$00,$20,$96,$BD,$E0,$FF,$D0,$01; $BC5C: 11 8D 03 00 A9 00 8D 04 00 20 96 BD E0 FF D0 01
  .byte $60                               ; $BC6C: 60
Loc_BC6D:
; --- Code Region ---
  JSR $BE90                             ; $BC6D: 20 90 BE
  LDY #$00                              ; $BC70: A0 00
Loc_BC72:
  LDA $042C,Y                           ; $BC72: B9 2C 04
  CMP #$FF                              ; $BC75: C9 FF
  BEQ $BC9E                             ; $BC77: F0 25
  STA $0002                             ; $BC79: 8D 02 00
  LDA $0550,Y                           ; $BC7C: B9 50 05
  BEQ $BC99                             ; $BC7F: F0 18
  CMP #$0A                              ; $BC81: C9 0A
  BEQ $BC99                             ; $BC83: F0 14
  CLC                                   ; $BC85: 18
  ADC #$11                              ; $BC86: 69 11
  STA $0003                             ; $BC88: 8D 03 00
  STY $0005                             ; $BC8B: 8C 05 00
  JSR $BD96                             ; $BC8E: 20 96 BD
  CPX #$FF                              ; $BC91: E0 FF
  BNE $BC96                             ; $BC93: D0 01
  RTS                                   ; $BC95: 60
Loc_BC96:
  LDY $0005                             ; $BC96: AC 05 00
Loc_BC99:
  INY                                   ; $BC99: C8
  CPY #$08                              ; $BC9A: C0 08
  BCC $BC72                             ; $BC9C: 90 D4
Loc_BC9E:
  LDA $0507                             ; $BC9E: AD 07 05
  LDY $0504                             ; $BCA1: AC 04 05
  BPL $BCAA                             ; $BCA4: 10 04
  LSR                                   ; $BCA6: 4A
  LSR                                   ; $BCA7: 4A
  LSR                                   ; $BCA8: 4A
  LSR                                   ; $BCA9: 4A
Loc_BCAA:
  AND #$0F                              ; $BCAA: 29 0F
  STA $000A                             ; $BCAC: 8D 0A 00
  LDY #$00                              ; $BCAF: A0 00
Loc_BCB1:
  LDA $042C,Y                           ; $BCB1: B9 2C 04
  CMP #$FF                              ; $BCB4: C9 FF
  BEQ $BCE8                             ; $BCB6: F0 30
  STA $0002                             ; $BCB8: 8D 02 00
  LDA $0550,Y                           ; $BCBB: B9 50 05
  BNE $BCE3                             ; $BCBE: D0 23
  CLC                                   ; $BCC0: 18
  ADC #$11                              ; $BCC1: 69 11
  STA $0003                             ; $BCC3: 8D 03 00
  STY $0005                             ; $BCC6: 8C 05 00
  JSR $BD96                             ; $BCC9: 20 96 BD
  LDY #$11                              ; $BCCC: A0 11
  LDA ($00),Y                           ; $BCCE: B1 00
  CMP #$FF                              ; $BCD0: C9 FF
  BEQ $BCDB                             ; $BCD2: F0 07
  LDY #$00                              ; $BCD4: A0 00
  LDA $000A                             ; $BCD6: AD 0A 00
  STA ($00),Y                           ; $BCD9: 91 00
Loc_BCDB:
  CPX #$FF                              ; $BCDB: E0 FF
  BNE $BCE0                             ; $BCDD: D0 01
  RTS                                   ; $BCDF: 60
Loc_BCE0:
  LDY $0005                             ; $BCE0: AC 05 00
Loc_BCE3:
  INY                                   ; $BCE3: C8
  CPY #$08                              ; $BCE4: C0 08
  BCC $BCB1                             ; $BCE6: 90 C9
Loc_BCE8:
  LDA $0507                             ; $BCE8: AD 07 05
  LDY $0504                             ; $BCEB: AC 04 05
  BPL $BCF4                             ; $BCEE: 10 04
  LSR                                   ; $BCF0: 4A
  LSR                                   ; $BCF1: 4A
  LSR                                   ; $BCF2: 4A
  LSR                                   ; $BCF3: 4A
Loc_BCF4:
  AND #$0F                              ; $BCF4: 29 0F
  JSR $F368                             ; $BCF6: 20 68 F3
  LDY #$00                              ; $BCF9: A0 00
  LDA ($00),Y                           ; $BCFB: B1 00
  STA $0002                             ; $BCFD: 8D 02 00
  LDX $0004                             ; $BD00: AE 04 00
Loc_BD03:
  LDA $6FA1,X                           ; $BD03: BD A1 6F
  STA $0003                             ; $BD06: 8D 03 00
  CMP #$FF                              ; $BD09: C9 FF
  BNE $BD0E                             ; $BD0B: D0 01
  RTS                                   ; $BD0D: 60
Loc_BD0E:
  LDA $0003                             ; $BD0E: AD 03 00
  CMP $0002                             ; $BD11: CD 02 00
  BNE $BD28                             ; $BD14: D0 12
  LDA $0003                             ; $BD16: AD 03 00
  JSR $F2D7                             ; $BD19: 20 D7 F2
  LDY #$0B                              ; $BD1C: A0 0B
  LDA ($00),Y                           ; $BD1E: B1 00
  ORA #$03                              ; $BD20: 09 03
  STA ($00),Y                           ; $BD22: 91 00
  INX                                   ; $BD24: E8
  JMP $BD03                             ; $BD25: 4C 03 BD
Loc_BD28:
  JSR $F2D7                             ; $BD28: 20 D7 F2
  LDY #$0B                              ; $BD2B: A0 0B
  LDA ($00),Y                           ; $BD2D: B1 00
  AND #$FC                              ; $BD2F: 29 FC
  STA ($00),Y                           ; $BD31: 91 00
  LDY #$30                              ; $BD33: A0 30
  JSR $F266                             ; $BD35: 20 66 F2
  LDA $050E                             ; $BD38: AD 0E 05
  ASL                                   ; $BD3B: 0A
  ASL                                   ; $BD3C: 0A
  ASL                                   ; $BD3D: 0A
  STA $0002                             ; $BD3E: 8D 02 00
  JSR $E856                             ; $BD41: 20 56 E8
  CLC                                   ; $BD44: 18
  ADC $0002                             ; $BD45: 6D 02 00
  TAY                                   ; $BD48: A8
  LDA $9D72,Y                           ; $BD49: B9 72 9D
  BPL $BD51                             ; $BD4C: 10 03
  LDA $050E                             ; $BD4E: AD 0E 05
Loc_BD51:
  LDY #$05                              ; $BD51: A0 05
  STA ($00),Y                           ; $BD53: 91 00
  INX                                   ; $BD55: E8
  JMP $BD03                             ; $BD56: 4C 03 BD
Loc_BD59:  ; (dispatch callback target)
  JSR $BDCD                             ; $BD59: 20 CD BD
  JSR $BE55                             ; $BD5C: 20 55 BE
  LDA #$00                              ; $BD5F: A9 00
  STA $0004                             ; $BD61: 8D 04 00
  JMP $BC6D                             ; $BD64: 4C 6D BC
Loc_BD67:  ; (dispatch callback target)
  JSR $BDCD                             ; $BD67: 20 CD BD
  JSR $BE55                             ; $BD6A: 20 55 BE
  LDA $052A                             ; $BD6D: AD 2A 05
  STA $0002                             ; $BD70: 8D 02 00
  JSR $F2AF                             ; $BD73: 20 AF F2
  LDY #$11                              ; $BD76: A0 11
Loc_BD78:
  LDA ($00),Y                           ; $BD78: B1 00
  CMP #$FF                              ; $BD7A: C9 FF
  BEQ $BD86                             ; $BD7C: F0 08
  INY                                   ; $BD7E: C8
  CPY #$1B                              ; $BD7F: C0 1B
  BCC $BD78                             ; $BD81: 90 F5
Loc_BD83:
  JMP $BC6D                             ; $BD83: 4C 6D BC
Loc_BD86:
  STY $0003                             ; $BD86: 8C 03 00
  LDA #$00                              ; $BD89: A9 00
  STA $0004                             ; $BD8B: 8D 04 00
  JSR $BD96                             ; $BD8E: 20 96 BD
  CPX #$FF                              ; $BD91: E0 FF
  BNE $BD83                             ; $BD93: D0 EE
  RTS                                   ; $BD95: 60
Loc_BD96:
  LDA $0002                             ; $BD96: AD 02 00
  JSR $F2AF                             ; $BD99: 20 AF F2
  LDY $0003                             ; $BD9C: AC 03 00
  LDX $0004                             ; $BD9F: AE 04 00
Loc_BDA2:
  LDA $6FA1,X                           ; $BDA2: BD A1 6F
  CMP #$FF                              ; $BDA5: C9 FF
  BNE $BDAB                             ; $BDA7: D0 02
  TAX                                   ; $BDA9: AA
  RTS                                   ; $BDAA: 60
Loc_BDAB:
  CMP $052B                             ; $BDAB: CD 2B 05
  BNE $BDB8                             ; $BDAE: D0 08
  PHA                                   ; $BDB0: 48
  LDA $0002                             ; $BDB1: AD 02 00
  STA $052C                             ; $BDB4: 8D 2C 05
  PLA                                   ; $BDB7: 68
Loc_BDB8:
  STA ($00),Y                           ; $BDB8: 91 00
  INX                                   ; $BDBA: E8
  INY                                   ; $BDBB: C8
  CPY #$1B                              ; $BDBC: C0 1B
  BCC $BDA2                             ; $BDBE: 90 E2
  LDA $6FA1,X                           ; $BDC0: BD A1 6F
  CMP #$FF                              ; $BDC3: C9 FF
  BNE $BDC9                             ; $BDC5: D0 02
  TAX                                   ; $BDC7: AA
  RTS                                   ; $BDC8: 60
Loc_BDC9:
  STX $0004                             ; $BDC9: 8E 04 00
  RTS                                   ; $BDCC: 60
Loc_BDCD:
  LDY #$00                              ; $BDCD: A0 00
  LDX #$00                              ; $BDCF: A2 00
  LDA $0504                             ; $BDD1: AD 04 05
  BPL $BDDA                             ; $BDD4: 10 04
  LDY #$80                              ; $BDD6: A0 80
  LDX #$0A                              ; $BDD8: A2 0A
Loc_BDDA:
  STY $0010                             ; $BDDA: 8C 10 00
  TXA                                   ; $BDDD: 8A
  CLC                                   ; $BDDE: 18
  ADC #$0A                              ; $BDDF: 69 0A
  STA $0011                             ; $BDE1: 8D 11 00
  LDY #$00                              ; $BDE4: A0 00
Loc_BDE6:
  LDA $0628,X                           ; $BDE6: BD 28 06
  CMP #$FF                              ; $BDE9: C9 FF
  BEQ $BDFB                             ; $BDEB: F0 0E
  AND #$80                              ; $BDED: 29 80
  CMP $0010                             ; $BDEF: CD 10 00
  BNE $BDFB                             ; $BDF2: D0 07
  LDA $0664,X                           ; $BDF4: BD 64 06
  STA $6FA1,Y                           ; $BDF7: 99 A1 6F
  INY                                   ; $BDFA: C8
Loc_BDFB:
  INX                                   ; $BDFB: E8
  CPX $0011                             ; $BDFC: EC 11 00
  BCC $BDE6                             ; $BDFF: 90 E5
  CPX #$0A                              ; $BE01: E0 0A
  BEQ $BE07                             ; $BE03: F0 02
  LDX #$00                              ; $BE05: A2 00
Loc_BE07:
  TXA                                   ; $BE07: 8A
  CLC                                   ; $BE08: 18
  ADC #$0A                              ; $BE09: 69 0A
  STA $0011                             ; $BE0B: 8D 11 00
Loc_BE0E:
  LDA $0628,X                           ; $BE0E: BD 28 06
  CMP #$FF                              ; $BE11: C9 FF
  BEQ $BE23                             ; $BE13: F0 0E
  AND #$80                              ; $BE15: 29 80
  CMP $0010                             ; $BE17: CD 10 00
  BNE $BE23                             ; $BE1A: D0 07
  LDA $0664,X                           ; $BE1C: BD 64 06
  STA $6FA1,Y                           ; $BE1F: 99 A1 6F
  INY                                   ; $BE22: C8
Loc_BE23:
  INX                                   ; $BE23: E8
  CPX $0011                             ; $BE24: EC 11 00
  BCC $BE0E                             ; $BE27: 90 E5
  LDX #$00                              ; $BE29: A2 00
  LDA $0504                             ; $BE2B: AD 04 05
  BPL $BE32                             ; $BE2E: 10 02
  LDX #$14                              ; $BE30: A2 14
Loc_BE32:
  TXA                                   ; $BE32: 8A
  CLC                                   ; $BE33: 18
  ADC #$14                              ; $BE34: 69 14
  STA $0011                             ; $BE36: 8D 11 00
Loc_BE39:
  LDA $6F47,X                           ; $BE39: BD 47 6F
  CMP #$FF                              ; $BE3C: C9 FF
  BEQ $BE44                             ; $BE3E: F0 04
  STA $6FA1,Y                           ; $BE40: 99 A1 6F
  INY                                   ; $BE43: C8
Loc_BE44:
  INX                                   ; $BE44: E8
  CPX $0011                             ; $BE45: EC 11 00
  BCC $BE39                             ; $BE48: 90 EF
Loc_BE4A:
  LDA #$FF                              ; $BE4A: A9 FF
  STA $6FA1,Y                           ; $BE4C: 99 A1 6F
  INY                                   ; $BE4F: C8
  CPY #$15                              ; $BE50: C0 15
  BCC $BE4A                             ; $BE52: 90 F6
  RTS                                   ; $BE54: 60
Loc_BE55:
  LDY #$00                              ; $BE55: A0 00
  LDA $0504                             ; $BE57: AD 04 05
  BPL $BE5E                             ; $BE5A: 10 02
  LDY #$0A                              ; $BE5C: A0 0A
Loc_BE5E:
  LDA $0664,Y                           ; $BE5E: B9 64 06
  CMP #$FF                              ; $BE61: C9 FF
  BNE $BE66                             ; $BE63: D0 01
  RTS                                   ; $BE65: 60
Loc_BE66:
  STA $0002                             ; $BE66: 8D 02 00
  LDY #$00                              ; $BE69: A0 00
Loc_BE6B:
  LDA $6FA1,Y                           ; $BE6B: B9 A1 6F
  CMP #$FF                              ; $BE6E: C9 FF
  BEQ $BE8A                             ; $BE70: F0 18
  CMP $0002                             ; $BE72: CD 02 00
  BNE $BE8A                             ; $BE75: D0 13
  LDA $6FA1                             ; $BE77: AD A1 6F
  STA $0003                             ; $BE7A: 8D 03 00
  LDA $0002                             ; $BE7D: AD 02 00
  STA $6FA1                             ; $BE80: 8D A1 6F
  LDA $0003                             ; $BE83: AD 03 00
  STA $6FA1,Y                           ; $BE86: 99 A1 6F
  RTS                                   ; $BE89: 60
Loc_BE8A:
  INY                                   ; $BE8A: C8
  CPY #$14                              ; $BE8B: C0 14
  BCC $BE6B                             ; $BE8D: 90 DC
  RTS                                   ; $BE8F: 60
Loc_BE90:
  LDY #$0A                              ; $BE90: A0 0A
  LDA #$FF                              ; $BE92: A9 FF
Loc_BE94:
  STA $042C,Y                           ; $BE94: 99 2C 04
  STA $0550,Y                           ; $BE97: 99 50 05
  DEY                                   ; $BE9A: 88
  BPL $BE94                             ; $BE9B: 10 F7
  LDA $0507                             ; $BE9D: AD 07 05
  LDY $0504                             ; $BEA0: AC 04 05
  BPL $BEA9                             ; $BEA3: 10 04
  LSR                                   ; $BEA5: 4A
  LSR                                   ; $BEA6: 4A
  LSR                                   ; $BEA7: 4A
  LSR                                   ; $BEA8: 4A
Loc_BEA9:
  AND #$0F                              ; $BEA9: 29 0F
  STA $0012                             ; $BEAB: 8D 12 00
  LDY #$30                              ; $BEAE: A0 30
  JSR $F25F                             ; $BEB0: 20 5F F2
  LDA $050E                             ; $BEB3: AD 0E 05
  ASL                                   ; $BEB6: 0A
  ASL                                   ; $BEB7: 0A
  ASL                                   ; $BEB8: 0A
  TAX                                   ; $BEB9: AA
  LDA #$00                              ; $BEBA: A9 00
  STA $0015                             ; $BEBC: 8D 15 00
  STA $0016                             ; $BEBF: 8D 16 00
Loc_BEC2:
  LDA $9D72,X                           ; $BEC2: BD 72 9D
  BPL $BEC8                             ; $BEC5: 10 01
  RTS                                   ; $BEC7: 60
Loc_BEC8:
  STA $0013                             ; $BEC8: 8D 13 00
  STX $0014                             ; $BECB: 8E 14 00
  JSR $F2AF                             ; $BECE: 20 AF F2
  LDY #$00                              ; $BED1: A0 00
  LDA ($00),Y                           ; $BED3: B1 00
  AND #$07                              ; $BED5: 29 07
  CMP #$07                              ; $BED7: C9 07
  BEQ $BEE0                             ; $BED9: F0 05
  CMP $0012                             ; $BEDB: CD 12 00
  BNE $BF03                             ; $BEDE: D0 23
Loc_BEE0:
  LDA $0013                             ; $BEE0: AD 13 00
  LDY $0016                             ; $BEE3: AC 16 00
  STA $042C,Y                           ; $BEE6: 99 2C 04
  LDY #$11                              ; $BEE9: A0 11
  LDX #$00                              ; $BEEB: A2 00
Loc_BEED:
  LDA ($00),Y                           ; $BEED: B1 00
  CMP #$FF                              ; $BEEF: C9 FF
  BEQ $BEF9                             ; $BEF1: F0 06
  INX                                   ; $BEF3: E8
  INY                                   ; $BEF4: C8
  CPY #$1B                              ; $BEF5: C0 1B
  BCC $BEED                             ; $BEF7: 90 F4
Loc_BEF9:
  LDY $0016                             ; $BEF9: AC 16 00
  TXA                                   ; $BEFC: 8A
  STA $0550,Y                           ; $BEFD: 99 50 05
  INC $0016                             ; $BF00: EE 16 00
Loc_BF03:
  LDX $0014                             ; $BF03: AE 14 00
  INX                                   ; $BF06: E8
  JMP $BEC2                             ; $BF07: 4C C2 BE
Loc_BF0A:
  LDA $0514                             ; $BF0A: AD 14 05
  BEQ $BF10                             ; $BF0D: F0 01
  RTS                                   ; $BF0F: 60
Loc_BF10:
  LDY #$30                              ; $BF10: A0 30
  JSR $F25F                             ; $BF12: 20 5F F2
  LDA $050E                             ; $BF15: AD 0E 05
  JSR $F2AF                             ; $BF18: 20 AF F2
  LDA $0000                             ; $BF1B: AD 00 00
  STA $001A                             ; $BF1E: 8D 1A 00
  LDA $0001                             ; $BF21: AD 01 00
  STA $001B                             ; $BF24: 8D 1B 00
  JSR $E87A                             ; $BF27: 20 7A E8
  AND #$01                              ; $BF2A: 29 01
  CLC                                   ; $BF2C: 18
  ADC #$01                              ; $BF2D: 69 01
  STA $0003                             ; $BF2F: 8D 03 00
  LDY #$06                              ; $BF32: A0 06
  JSR $BF9E                             ; $BF34: 20 9E BF
  LDX #$00                              ; $BF37: A2 00
  LDA $0506                             ; $BF39: AD 06 05
  CMP #$06                              ; $BF3C: C9 06
  BCC $BF50                             ; $BF3E: 90 10
  INX                                   ; $BF40: E8
  CMP #$0B                              ; $BF41: C9 0B
  BCC $BF50                             ; $BF43: 90 0B
  INX                                   ; $BF45: E8
  CMP #$10                              ; $BF46: C9 10
  BCC $BF50                             ; $BF48: 90 06
  INX                                   ; $BF4A: E8
  CMP #$15                              ; $BF4B: C9 15
  BCC $BF50                             ; $BF4D: 90 01
  INX                                   ; $BF4F: E8
Loc_BF50:
  LDA $C015,X                           ; $BF50: BD 15 C0
  STA $0010                             ; $BF53: 8D 10 00
  LDA $0010                             ; $BF56: AD 10 00
  STA $0003                             ; $BF59: 8D 03 00
  LDY #$08                              ; $BF5C: A0 08
  JSR $BF9E                             ; $BF5E: 20 9E BF
  LDA $0010                             ; $BF61: AD 10 00
  STA $0003                             ; $BF64: 8D 03 00
  LDY #$0E                              ; $BF67: A0 0E
  JSR $BF9E                             ; $BF69: 20 9E BF
  LDA $0010                             ; $BF6C: AD 10 00
  STA $0003                             ; $BF6F: 8D 03 00
  LDY #$0B                              ; $BF72: A0 0B
  LDA ($1A),Y                           ; $BF74: B1 1A
  STA $0000                             ; $BF76: 8D 00 00
  LDA #$00                              ; $BF79: A9 00
  STA $0001                             ; $BF7B: 8D 01 00
  STA $0002                             ; $BF7E: 8D 02 00
  JSR $BFB3                             ; $BF81: 20 B3 BF
  LDY #$02                              ; $BF84: A0 02
  JSR $BFEC                             ; $BF86: 20 EC BF
  STA $0003                             ; $BF89: 8D 03 00
  LDY #$02                              ; $BF8C: A0 02
  JSR $BF9E                             ; $BF8E: 20 9E BF
  LDY #$04                              ; $BF91: A0 04
  JSR $BFEC                             ; $BF93: 20 EC BF
  STA $0003                             ; $BF96: 8D 03 00
  LDY #$04                              ; $BF99: A0 04
  JMP $BF9E                             ; $BF9B: 4C 9E BF
Loc_BF9E:
  TYA                                   ; $BF9E: 98
  PHA                                   ; $BF9F: 48
  LDA ($1A),Y                           ; $BFA0: B1 1A
  STA $0000                             ; $BFA2: 8D 00 00
  INY                                   ; $BFA5: C8
  LDA ($1A),Y                           ; $BFA6: B1 1A
  STA $0001                             ; $BFA8: 8D 01 00
  LDA #$00                              ; $BFAB: A9 00
  STA $0002                             ; $BFAD: 8D 02 00
  JMP $BFB5                             ; $BFB0: 4C B5 BF
Loc_BFB3:
  TYA                                   ; $BFB3: 98
  PHA                                   ; $BFB4: 48
Loc_BFB5:
  LDA #$0A                              ; $BFB5: A9 0A
  SEC                                   ; $BFB7: 38
  SBC $0003                             ; $BFB8: ED 03 00
  STA $0003                             ; $BFBB: 8D 03 00
  JSR $EBE9                             ; $BFBE: 20 E9 EB
  LDA $0006                             ; $BFC1: AD 06 00
  STA $0001                             ; $BFC4: 8D 01 00
  LDA $0007                             ; $BFC7: AD 07 00
  STA $0002                             ; $BFCA: 8D 02 00
  LDA #$0A                              ; $BFCD: A9 0A
  STA $0003                             ; $BFCF: 8D 03 00
  LDA #$00                              ; $BFD2: A9 00
  STA $0004                             ; $BFD4: 8D 04 00
  JSR $EA7C                             ; $BFD7: 20 7C EA
  PLA                                   ; $BFDA: 68
  TAY                                   ; $BFDB: A8
  LDA $0001                             ; $BFDC: AD 01 00
  STA ($1A),Y                           ; $BFDF: 91 1A
  CPY #$0B                              ; $BFE1: C0 0B
  BEQ $BFEB                             ; $BFE3: F0 06
  INY                                   ; $BFE5: C8
  LDA $0002                             ; $BFE6: AD 02 00
  STA ($1A),Y                           ; $BFE9: 91 1A
Loc_BFEB:
  RTS                                   ; $BFEB: 60
Loc_BFEC:
  LDA ($1A),Y                           ; $BFEC: B1 1A
  STA $0000                             ; $BFEE: 8D 00 00
  INY                                   ; $BFF1: C8
  LDA ($1A),Y                           ; $BFF2: B1 1A
  STA $0001                             ; $BFF4: 8D 01 00
  LDX #$00                              ; $BFF7: A2 00
Loc_BFF9:
  LDA $C01A,X                           ; $BFF9: BD 1A C0
  SEC                                   ; $BFFC: 38
  SBC $0000                             ; $BFFD: ED 00 00
  LDA $C01B,X                           ; $C000: BD 1B C0
  SBC $0001                             ; $C003: ED 01 00
  BCC $C00E                             ; $C006: 90 06
  INX                                   ; $C008: E8
  INX                                   ; $C009: E8
  CPX #$08                              ; $C00A: E0 08
  BCC $BFF9                             ; $C00C: 90 EB
Loc_C00E:
  TXA                                   ; $C00E: 8A
  LSR                                   ; $C00F: 4A
  TAX                                   ; $C010: AA
  LDA $C022,X                           ; $C011: BD 22 C0
  RTS                                   ; $C014: 60
; --- Data Region ---
  .byte $01,$02,$03,$04,$06,$F5,$01,$E8,$03,$B8,$0B,$88,$13,$05,$06,$07; $C015: 01 02 03 04 06 F5 01 E8 03 B8 0B 88 13 05 06 07
  .byte $08,$09                           ; $C025: 08 09
Loc_C027:
; --- Code Region ---
  LDY #$30                              ; $C027: A0 30
  JSR $F25F                             ; $C029: 20 5F F2
  LDA $050E                             ; $C02C: AD 0E 05
  JSR $F2AF                             ; $C02F: 20 AF F2
  LDA $0514                             ; $C032: AD 14 05
  ASL                                   ; $C035: 0A
  EOR #$02                              ; $C036: 49 02
  TAX                                   ; $C038: AA
  JSR $C07A                             ; $C039: 20 7A C0
  LDY #$31                              ; $C03C: A0 31
  JSR $F25F                             ; $C03E: 20 5F F2
  LDA $052B                             ; $C041: AD 2B 05
  CMP #$FF                              ; $C044: C9 FF
  BEQ $C057                             ; $C046: F0 0F
  JSR $F2D7                             ; $C048: 20 D7 F2
  LDY #$0B                              ; $C04B: A0 0B
  LDA ($00),Y                           ; $C04D: B1 00
  AND #$03                              ; $C04F: 29 03
  BEQ $C057                             ; $C051: F0 04
  CMP #$03                              ; $C053: C9 03
  BNE $C06A                             ; $C055: D0 13
Loc_C057:
  LDY #$30                              ; $C057: A0 30
  JSR $F25F                             ; $C059: 20 5F F2
  LDA $050E                             ; $C05C: AD 0E 05
  JSR $F2AF                             ; $C05F: 20 AF F2
  LDA $0514                             ; $C062: AD 14 05
  ASL                                   ; $C065: 0A
  TAX                                   ; $C066: AA
  JMP $C07A                             ; $C067: 4C 7A C0
Loc_C06A:
  LDY #$30                              ; $C06A: A0 30
  JSR $F25F                             ; $C06C: 20 5F F2
  LDA $052C                             ; $C06F: AD 2C 05
  JSR $F2AF                             ; $C072: 20 AF F2
  LDA $0514                             ; $C075: AD 14 05
  ASL                                   ; $C078: 0A
  TAX                                   ; $C079: AA
Loc_C07A:
  LDY #$02                              ; $C07A: A0 02
  LDA ($00),Y                           ; $C07C: B1 00
  CLC                                   ; $C07E: 18
  ADC $0526,X                           ; $C07F: 7D 26 05
  STA ($00),Y                           ; $C082: 91 00
  INY                                   ; $C084: C8
  LDA ($00),Y                           ; $C085: B1 00
  ADC $0527,X                           ; $C087: 7D 27 05
  STA ($00),Y                           ; $C08A: 91 00
  LDY #$02                              ; $C08C: A0 02
  JSR $C0A5                             ; $C08E: 20 A5 C0
  LDY #$04                              ; $C091: A0 04
  LDA ($00),Y                           ; $C093: B1 00
  CLC                                   ; $C095: 18
  ADC $0522,X                           ; $C096: 7D 22 05
  STA ($00),Y                           ; $C099: 91 00
  INY                                   ; $C09B: C8
  LDA ($00),Y                           ; $C09C: B1 00
  ADC $0523,X                           ; $C09E: 7D 23 05
  STA ($00),Y                           ; $C0A1: 91 00
  LDY #$04                              ; $C0A3: A0 04
Loc_C0A5:
  LDA ($00),Y                           ; $C0A5: B1 00
  SEC                                   ; $C0A7: 38
  SBC #$10                              ; $C0A8: E9 10
  INY                                   ; $C0AA: C8
  LDA ($00),Y                           ; $C0AB: B1 00
  SBC #$27                              ; $C0AD: E9 27
  BCC $C0BA                             ; $C0AF: 90 09
  LDA #$27                              ; $C0B1: A9 27
  STA ($00),Y                           ; $C0B3: 91 00
  DEY                                   ; $C0B5: 88
  LDA #$0F                              ; $C0B6: A9 0F
  STA ($00),Y                           ; $C0B8: 91 00
Loc_C0BA:
  RTS                                   ; $C0BA: 60
Loc_C0BB:
  LDA $0501                             ; $C0BB: AD 01 05
  JSR $EADE                             ; $C0BE: 20 DE EA
; --- Data Region ---
  .byte $D5,$C0,$EB,$C1,$C0,$C2,$92,$C3,$E9,$C3,$B8,$C4,$43,$C5,$2E,$C6; $C0C1: D5 C0 EB C1 C0 C2 92 C3 E9 C3 B8 C4 43 C5 2E C6
  .byte $B0,$C7,$C8,$C7,$A9,$DE,$8D,$10,$00,$A9,$C1,$8D,$11,$00,$A9,$00; $C0D1: B0 C7 C8 C7 A9 DE 8D 10 00 A9 C1 8D 11 00 A9 00
  .byte $8D,$12,$00,$20,$1E,$ED,$A9,$E2,$8D,$10,$00,$A9,$C1,$8D,$11,$00; $C0E1: 8D 12 00 20 1E ED A9 E2 8D 10 00 A9 C1 8D 11 00
  .byte $A9,$E6,$8D,$00,$00,$A9,$C1,$8D,$01,$00,$AD,$12,$00,$20,$F5,$ED; $C0F1: A9 E6 8D 00 00 A9 C1 8D 01 00 AD 12 00 20 F5 ED
  .byte $20,$48,$C9,$90,$11,$AD,$81,$00,$4A,$B0,$0C,$4A,$90,$08,$A9,$00; $C101: 20 48 C9 90 11 AD 81 00 4A B0 0C 4A 90 08 A9 00
  .byte $8D,$00,$05,$8D,$01,$05           ; $C111: 8D 00 05 8D 01 05
Loc_C117:
; --- Code Region ---
  RTS                                   ; $C117: 60
Loc_C118:
  LDA #$00                              ; $C118: A9 00
  STA $048B                             ; $C11A: 8D 8B 04
  STA $048C                             ; $C11D: 8D 8C 04
  STA $048D                             ; $C120: 8D 8D 04
  STA $048E                             ; $C123: 8D 8E 04
  STA $048F                             ; $C126: 8D 8F 04
  LDY #$30                              ; $C129: A0 30
  JSR $F25F                             ; $C12B: 20 5F F2
  LDA $050E                             ; $C12E: AD 0E 05
  ASL                                   ; $C131: 0A
  CLC                                   ; $C132: 18
  ADC #$C0                              ; $C133: 69 C0
  STA $0002                             ; $C135: 8D 02 00
  LDA #$8F                              ; $C138: A9 8F
  ADC #$00                              ; $C13A: 69 00
  STA $0003                             ; $C13C: 8D 03 00
  JSR $C93E                             ; $C13F: 20 3E C9
  LDA $0012                             ; $C142: AD 12 00
  BEQ $C16F                             ; $C145: F0 28
  LDA $0522,X                           ; $C147: BD 22 05
  STA $0490                             ; $C14A: 8D 90 04
  LDA $0523,X                           ; $C14D: BD 23 05
  STA $0491                             ; $C150: 8D 91 04
  LDY #$00                              ; $C153: A0 00
  LDA ($02),Y                           ; $C155: B1 02
  STA $0492                             ; $C157: 8D 92 04
  STA $042C                             ; $C15A: 8D 2C 04
  LDA #$00                              ; $C15D: A9 00
  STA $042D                             ; $C15F: 8D 2D 04
  STA $042E                             ; $C162: 8D 2E 04
  LDA #$02                              ; $C165: A9 02
  STA $0501                             ; $C167: 8D 01 05
  LDA #$AA                              ; $C16A: A9 AA
  JMP $F283                             ; $C16C: 4C 83 F2
Loc_C16F:
  LDY #$01                              ; $C16F: A0 01
  LDA ($02),Y                           ; $C171: B1 02
  STA $0492                             ; $C173: 8D 92 04
  STA $042C                             ; $C176: 8D 2C 04
  LDA #$00                              ; $C179: A9 00
  STA $042D                             ; $C17B: 8D 2D 04
  STA $042E                             ; $C17E: 8D 2E 04
  LDA $0526,X                           ; $C181: BD 26 05
  STA $0000                             ; $C184: 8D 00 00
  LDA $0527,X                           ; $C187: BD 27 05
  STA $0001                             ; $C18A: 8D 01 00
  LDA #$00                              ; $C18D: A9 00
  STA $0002                             ; $C18F: 8D 02 00
  LDA $0492                             ; $C192: AD 92 04
  STA $0003                             ; $C195: 8D 03 00
  JSR $EBE9                             ; $C198: 20 E9 EB
  LDA $0006                             ; $C19B: AD 06 00
  STA $0000                             ; $C19E: 8D 00 00
  LDA $0007                             ; $C1A1: AD 07 00
  STA $0001                             ; $C1A4: 8D 01 00
  LDA $0008                             ; $C1A7: AD 08 00
  STA $0002                             ; $C1AA: 8D 02 00
  LDA #$64                              ; $C1AD: A9 64
  STA $0003                             ; $C1AF: 8D 03 00
  LDA #$00                              ; $C1B2: A9 00
  STA $0004                             ; $C1B4: 8D 04 00
  JSR $EAA5                             ; $C1B7: 20 A5 EA
  LDA $0005                             ; $C1BA: AD 05 00
  BEQ $C1C4                             ; $C1BD: F0 05
  LDA #$01                              ; $C1BF: A9 01
  STA $0005                             ; $C1C1: 8D 05 00
Loc_C1C4:
  LDA $0000                             ; $C1C4: AD 00 00
  CLC                                   ; $C1C7: 18
  ADC $0005                             ; $C1C8: 6D 05 00
  STA $0490                             ; $C1CB: 8D 90 04
  LDA $0001                             ; $C1CE: AD 01 00
  ADC #$00                              ; $C1D1: 69 00
  STA $0491                             ; $C1D3: 8D 91 04
  INC $0501                             ; $C1D6: EE 01 05
  LDA #$A9                              ; $C1D9: A9 A9
  JMP $F283                             ; $C1DB: 4C 83 F2
; --- Data Region ---
  .byte $00,$01,$FF,$FF,$C6,$47,$C6,$87,$00,$07,$00,$00,$80; $C1DE: 00 01 FF FF C6 47 C6 87 00 07 00 00 80
Loc_C1EB:  ; (dispatch callback target)
; --- Code Region ---
  JSR $C948                             ; $C1EB: 20 48 C9
  BCC $C21A                             ; $C1EE: 90 2A
  LDA #$D0                              ; $C1F0: A9 D0
  STA $031C                             ; $C1F2: 8D 1C 03
  LDA #$24                              ; $C1F5: A9 24
  STA $031D                             ; $C1F7: 8D 1D 03
  LDY #$3B                              ; $C1FA: A0 3B
  JSR $EE07                             ; $C1FC: 20 07 EE
; --- Data Region ---
  .byte $03,$A0,$AD,$81,$00,$4A,$B0,$14,$4A,$90,$10,$CE,$01,$05,$A9,$00; $C1FF: 03 A0 AD 81 00 4A B0 14 4A 90 10 CE 01 05 A9 00
  .byte $8D,$24,$04,$8D,$25,$04,$A9,$A8,$4C,$83,$F2; $C20F: 8D 24 04 8D 25 04 A9 A8 4C 83 F2
Loc_C21A:
; --- Code Region ---
  RTS                                   ; $C21A: 60
Loc_C21B:
  LDA $048E                             ; $C21B: AD 8E 04
  STA $0000                             ; $C21E: 8D 00 00
  LDA $048F                             ; $C221: AD 8F 04
  STA $0001                             ; $C224: 8D 01 00
  LDA $0001                             ; $C227: AD 01 00
  BNE $C231                             ; $C22A: D0 05
  LDA $0000                             ; $C22C: AD 00 00
  BEQ $C21A                             ; $C22F: F0 E9
Loc_C231:
  LDA #$64                              ; $C231: A9 64
  STA $0003                             ; $C233: 8D 03 00
  LDA #$00                              ; $C236: A9 00
  STA $0002                             ; $C238: 8D 02 00
  JSR $EBE9                             ; $C23B: 20 E9 EB
  LDA $0006                             ; $C23E: AD 06 00
  STA $0000                             ; $C241: 8D 00 00
  LDA $0007                             ; $C244: AD 07 00
  STA $0001                             ; $C247: 8D 01 00
  LDA $0008                             ; $C24A: AD 08 00
  STA $0002                             ; $C24D: 8D 02 00
  LDA $0492                             ; $C250: AD 92 04
  STA $0003                             ; $C253: 8D 03 00
  LDA #$00                              ; $C256: A9 00
  STA $0004                             ; $C258: 8D 04 00
  JSR $EAA5                             ; $C25B: 20 A5 EA
  JSR $C93E                             ; $C25E: 20 3E C9
  LDA $0526,X                           ; $C261: BD 26 05
  SEC                                   ; $C264: 38
  SBC $0000                             ; $C265: ED 00 00
  STA $0526,X                           ; $C268: 9D 26 05
  LDA $0527,X                           ; $C26B: BD 27 05
  SBC $0001                             ; $C26E: ED 01 00
  BCS $C278                             ; $C271: B0 05
  LDA #$00                              ; $C273: A9 00
  STA $0526,X                           ; $C275: 9D 26 05
Loc_C278:
  STA $0527,X                           ; $C278: 9D 27 05
  LDA $0522,X                           ; $C27B: BD 22 05
  CLC                                   ; $C27E: 18
  ADC $048E                             ; $C27F: 6D 8E 04
  STA $0522,X                           ; $C282: 9D 22 05
  LDA $0523,X                           ; $C285: BD 23 05
  ADC $048F                             ; $C288: 6D 8F 04
  STA $0523,X                           ; $C28B: 9D 23 05
  LDA $0522,X                           ; $C28E: BD 22 05
  SEC                                   ; $C291: 38
  SBC #$10                              ; $C292: E9 10
  LDA $0523,X                           ; $C294: BD 23 05
  SBC #$27                              ; $C297: E9 27
  BCC $C2A5                             ; $C299: 90 0A
  LDA #$0F                              ; $C29B: A9 0F
  STA $0522,X                           ; $C29D: 9D 22 05
  LDA #$27                              ; $C2A0: A9 27
  STA $0523,X                           ; $C2A2: 9D 23 05
Loc_C2A5:
  LDA $048E                             ; $C2A5: AD 8E 04
  STA $042C                             ; $C2A8: 8D 2C 04
  LDA $048F                             ; $C2AB: AD 8F 04
  STA $042D                             ; $C2AE: 8D 2D 04
  LDA #$00                              ; $C2B1: A9 00
  STA $042E                             ; $C2B3: 8D 2E 04
  LDA #$08                              ; $C2B6: A9 08
  STA $0501                             ; $C2B8: 8D 01 05
  LDA #$AB                              ; $C2BB: A9 AB
  JMP $F283                             ; $C2BD: 4C 83 F2
Loc_C2C0:  ; (dispatch callback target)
  JSR $C948                             ; $C2C0: 20 48 C9
  BCC $C2F1                             ; $C2C3: 90 2C
  LDA #$D0                              ; $C2C5: A9 D0
  STA $031C                             ; $C2C7: 8D 1C 03
  LDA #$24                              ; $C2CA: A9 24
  STA $031D                             ; $C2CC: 8D 1D 03
  LDY #$3B                              ; $C2CF: A0 3B
  JSR $EE07                             ; $C2D1: 20 07 EE
; --- Data Region ---
  .byte $03,$A0,$AD,$81,$00,$4A,$B0,$16,$4A,$90,$12,$A9,$00,$8D,$01,$05; $C2D4: 03 A0 AD 81 00 4A B0 16 4A 90 12 A9 00 8D 01 05
  .byte $A9,$00,$8D,$24,$04,$8D,$25,$04,$A9,$A8,$4C,$83,$F2; $C2E4: A9 00 8D 24 04 8D 25 04 A9 A8 4C 83 F2
Loc_C2F1:
; --- Code Region ---
  RTS                                   ; $C2F1: 60
Loc_C2F2:
  LDA $048E                             ; $C2F2: AD 8E 04
  STA $0000                             ; $C2F5: 8D 00 00
  LDA $048F                             ; $C2F8: AD 8F 04
  STA $0001                             ; $C2FB: 8D 01 00
  LDA $0001                             ; $C2FE: AD 01 00
  BNE $C308                             ; $C301: D0 05
  LDA $0000                             ; $C303: AD 00 00
  BEQ $C2F1                             ; $C306: F0 E9
Loc_C308:
  LDA $0492                             ; $C308: AD 92 04
  STA $0003                             ; $C30B: 8D 03 00
  LDA #$00                              ; $C30E: A9 00
  STA $0002                             ; $C310: 8D 02 00
  JSR $EBE9                             ; $C313: 20 E9 EB
  LDA $0006                             ; $C316: AD 06 00
  STA $0000                             ; $C319: 8D 00 00
  LDA $0007                             ; $C31C: AD 07 00
  STA $0001                             ; $C31F: 8D 01 00
  LDA $0008                             ; $C322: AD 08 00
  STA $0002                             ; $C325: 8D 02 00
  LDA #$64                              ; $C328: A9 64
  STA $0003                             ; $C32A: 8D 03 00
  LDA #$00                              ; $C32D: A9 00
  STA $0004                             ; $C32F: 8D 04 00
  JSR $EAA5                             ; $C332: 20 A5 EA
  LDA $0000                             ; $C335: AD 00 00
  STA $042C                             ; $C338: 8D 2C 04
  LDA $0001                             ; $C33B: AD 01 00
  STA $042D                             ; $C33E: 8D 2D 04
  JSR $C93E                             ; $C341: 20 3E C9
  LDA $0522,X                           ; $C344: BD 22 05
  SEC                                   ; $C347: 38
  SBC $048E                             ; $C348: ED 8E 04
  STA $0522,X                           ; $C34B: 9D 22 05
  LDA $0523,X                           ; $C34E: BD 23 05
  SBC $048F                             ; $C351: ED 8F 04
  BCS $C35B                             ; $C354: B0 05
  LDA #$00                              ; $C356: A9 00
  STA $0522,X                           ; $C358: 9D 22 05
Loc_C35B:
  STA $0523,X                           ; $C35B: 9D 23 05
  LDA $0526,X                           ; $C35E: BD 26 05
  CLC                                   ; $C361: 18
  ADC $042C                             ; $C362: 6D 2C 04
  STA $0526,X                           ; $C365: 9D 26 05
  LDA $0527,X                           ; $C368: BD 27 05
  ADC $042D                             ; $C36B: 6D 2D 04
  STA $0527,X                           ; $C36E: 9D 27 05
  LDA $0526,X                           ; $C371: BD 26 05
  SEC                                   ; $C374: 38
  SBC #$10                              ; $C375: E9 10
  LDA $0527,X                           ; $C377: BD 27 05
  SBC #$27                              ; $C37A: E9 27
  BCC $C388                             ; $C37C: 90 0A
  LDA #$0F                              ; $C37E: A9 0F
  STA $0526,X                           ; $C380: 9D 26 05
  LDA #$27                              ; $C383: A9 27
  STA $0527,X                           ; $C385: 9D 27 05
Loc_C388:
  LDA #$08                              ; $C388: A9 08
  STA $0501                             ; $C38A: 8D 01 05
  LDA #$AC                              ; $C38D: A9 AC
  JMP $F283                             ; $C38F: 4C 83 F2
Loc_C392:  ; (dispatch callback target)
  JSR $C948                             ; $C392: 20 48 C9
  BCC $C3A1                             ; $C395: 90 0A
  JSR $C95A                             ; $C397: 20 5A C9
  LDA $0081                             ; $C39A: AD 81 00
  AND #$03                              ; $C39D: 29 03
  BNE $C3A2                             ; $C39F: D0 01
Loc_C3A1:
  RTS                                   ; $C3A1: 60
Loc_C3A2:
  LDY $0509                             ; $C3A2: AC 09 05
  LDA $0664,Y                           ; $C3A5: B9 64 06
  STA $0010                             ; $C3A8: 8D 10 00
  JSR $F2D7                             ; $C3AB: 20 D7 F2
  LDY #$00                              ; $C3AE: A0 00
  LDA ($00),Y                           ; $C3B0: B1 00
  STA $0011                             ; $C3B2: 8D 11 00
  LDA $0010                             ; $C3B5: AD 10 00
  JSR $F387                             ; $C3B8: 20 87 F3
  LDY #$00                              ; $C3BB: A0 00
  LDA ($00),Y                           ; $C3BD: B1 00
  CMP $0011                             ; $C3BF: CD 11 00
  BNE $C3CE                             ; $C3C2: D0 0A
  LDA #$08                              ; $C3C4: A9 08
  STA $0501                             ; $C3C6: 8D 01 05
  LDA #$B3                              ; $C3C9: A9 B3
  JMP $F283                             ; $C3CB: 4C 83 F2
Loc_C3CE:
  LDA #$32                              ; $C3CE: A9 32
  STA $042C                             ; $C3D0: 8D 2C 04
  LDA #$00                              ; $C3D3: A9 00
  STA $042D                             ; $C3D5: 8D 2D 04
  STA $042E                             ; $C3D8: 8D 2E 04
  STA $0424                             ; $C3DB: 8D 24 04
  STA $0425                             ; $C3DE: 8D 25 04
  INC $0501                             ; $C3E1: EE 01 05
  LDA #$B2                              ; $C3E4: A9 B2
  JMP $F283                             ; $C3E6: 4C 83 F2
Loc_C3E9:  ; (dispatch callback target)
  LDA #$AB                              ; $C3E9: A9 AB
  STA $0010                             ; $C3EB: 8D 10 00
  LDA #$C4                              ; $C3EE: A9 C4
  STA $0011                             ; $C3F0: 8D 11 00
  LDA #$00                              ; $C3F3: A9 00
  STA $0012                             ; $C3F5: 8D 12 00
  JSR $ED1E                             ; $C3F8: 20 1E ED
  LDA #$AF                              ; $C3FB: A9 AF
  STA $0010                             ; $C3FD: 8D 10 00
  LDA #$C4                              ; $C400: A9 C4
  STA $0011                             ; $C402: 8D 11 00
  LDA #$B3                              ; $C405: A9 B3
  STA $0000                             ; $C407: 8D 00 00
  LDA #$C4                              ; $C40A: A9 C4
  STA $0001                             ; $C40C: 8D 01 00
  LDA $0012                             ; $C40F: AD 12 00
  JSR $EDF5                             ; $C412: 20 F5 ED
  JSR $C948                             ; $C415: 20 48 C9
  BCC $C42B                             ; $C418: 90 11
  LDA $0081                             ; $C41A: AD 81 00
  LSR                                   ; $C41D: 4A
  BCS $C42C                             ; $C41E: B0 0C
  LSR                                   ; $C420: 4A
  BCC $C42B                             ; $C421: 90 08
Loc_C423:
  LDA #$00                              ; $C423: A9 00
  STA $0500                             ; $C425: 8D 00 05
  STA $0501                             ; $C428: 8D 01 05
Loc_C42B:
  RTS                                   ; $C42B: 60
Loc_C42C:
  LDA $0012                             ; $C42C: AD 12 00
  BNE $C423                             ; $C42F: D0 F2
  JSR $C93E                             ; $C431: 20 3E C9
  LDA $0527,X                           ; $C434: BD 27 05
  BNE $C44A                             ; $C437: D0 11
  LDA $0526,X                           ; $C439: BD 26 05
  CMP #$32                              ; $C43C: C9 32
  BCS $C44A                             ; $C43E: B0 0A
  LDA #$08                              ; $C440: A9 08
  STA $0501                             ; $C442: 8D 01 05
  LDA #$B0                              ; $C445: A9 B0
  JMP $F283                             ; $C447: 4C 83 F2
Loc_C44A:
  LDA $0526,X                           ; $C44A: BD 26 05
  SEC                                   ; $C44D: 38
  SBC #$32                              ; $C44E: E9 32
  STA $0526,X                           ; $C450: 9D 26 05
  LDA $0527,X                           ; $C453: BD 27 05
  SBC #$00                              ; $C456: E9 00
  STA $0527,X                           ; $C458: 9D 27 05
Loc_C45B:
  JSR $E85C                             ; $C45B: 20 5C E8
  CMP #$0B                              ; $C45E: C9 0B
  BCS $C45B                             ; $C460: B0 F9
  CLC                                   ; $C462: 18
  ADC #$23                              ; $C463: 69 23
  STA $042C                             ; $C465: 8D 2C 04
  LDY $0509                             ; $C468: AC 09 05
  LDA $0664,Y                           ; $C46B: B9 64 06
  STA $0010                             ; $C46E: 8D 10 00
  JSR $F387                             ; $C471: 20 87 F3
  LDY #$00                              ; $C474: A0 00
  LDA ($00),Y                           ; $C476: B1 00
  STA $0002                             ; $C478: 8D 02 00
  LDA $0010                             ; $C47B: AD 10 00
  JSR $F2D7                             ; $C47E: 20 D7 F2
  LDA ($00),Y                           ; $C481: B1 00
  CLC                                   ; $C483: 18
  ADC $042C                             ; $C484: 6D 2C 04
  STA ($00),Y                           ; $C487: 91 00
  SEC                                   ; $C489: 38
  SBC $0002                             ; $C48A: ED 02 00
  BCC $C4A1                             ; $C48D: 90 12
  STA $0003                             ; $C48F: 8D 03 00
  LDA $042C                             ; $C492: AD 2C 04
  SEC                                   ; $C495: 38
  SBC $0003                             ; $C496: ED 03 00
  STA $042C                             ; $C499: 8D 2C 04
  LDA $0002                             ; $C49C: AD 02 00
  STA ($00),Y                           ; $C49F: 91 00
Loc_C4A1:
  LDA #$08                              ; $C4A1: A9 08
  STA $0501                             ; $C4A3: 8D 01 05
  LDA #$B4                              ; $C4A6: A9 B4
  JMP $F283                             ; $C4A8: 4C 83 F2
; --- Data Region ---
  .byte $00,$01,$FF,$FF,$D6,$50,$D6,$98,$00,$07,$00,$00,$80; $C4AB: 00 01 FF FF D6 50 D6 98 00 07 00 00 80
Loc_C4B8:  ; (dispatch callback target)
; --- Code Region ---
  LDA #$12                              ; $C4B8: A9 12
  STA $0010                             ; $C4BA: 8D 10 00
  LDA #$C5                              ; $C4BD: A9 C5
  STA $0011                             ; $C4BF: 8D 11 00
  LDA #$00                              ; $C4C2: A9 00
  STA $0012                             ; $C4C4: 8D 12 00
  JSR $ED1E                             ; $C4C7: 20 1E ED
  LDA #$18                              ; $C4CA: A9 18
  STA $0010                             ; $C4CC: 8D 10 00
  LDA #$C5                              ; $C4CF: A9 C5
  STA $0011                             ; $C4D1: 8D 11 00
  LDA #$20                              ; $C4D4: A9 20
  STA $0000                             ; $C4D6: 8D 00 00
  LDA #$C5                              ; $C4D9: A9 C5
  STA $0001                             ; $C4DB: 8D 01 00
  LDA $0012                             ; $C4DE: AD 12 00
  JSR $EDF5                             ; $C4E1: 20 F5 ED
  LDA $0081                             ; $C4E4: AD 81 00
  LSR                                   ; $C4E7: 4A
  BCS $C4F6                             ; $C4E8: B0 0C
  LSR                                   ; $C4EA: 4A
  BCC $C4F5                             ; $C4EB: 90 08
  LDA #$00                              ; $C4ED: A9 00
  STA $0500                             ; $C4EF: 8D 00 05
  STA $0501                             ; $C4F2: 8D 01 05
Loc_C4F5:
  RTS                                   ; $C4F5: 60
Loc_C4F6:
  LDY $050E                             ; $C4F6: AC 0E 05
  LDA $C525,Y                           ; $C4F9: B9 25 C5
  STA $0000                             ; $C4FC: 8D 00 00
  JSR $C851                             ; $C4FF: 20 51 C8
  INC $0501                             ; $C502: EE 01 05
  LDA #$00                              ; $C505: A9 00
  STA $0424                             ; $C507: 8D 24 04
  STA $0425                             ; $C50A: 8D 25 04
  LDA #$AE                              ; $C50D: A9 AE
  JMP $F293                             ; $C50F: 4C 93 F2
; --- Data Region ---
  .byte $00,$01,$02,$03,$FF,$FF,$C4,$56,$C4,$96,$D4,$56,$D4,$96,$00,$07; $C512: 00 01 02 03 FF FF C4 56 C4 96 D4 56 D4 96 00 07
  .byte $00,$00,$80,$00,$00,$00,$00,$04,$00,$03,$00,$01,$00,$00,$01,$01; $C522: 00 00 80 00 00 00 00 04 00 03 00 01 00 00 01 01
  .byte $01,$00,$01,$00,$00,$01,$00,$01,$01,$00,$00,$00,$01,$01,$01,$00; $C532: 01 00 01 00 00 01 00 01 01 00 00 00 01 01 01 00
  .byte $05                               ; $C542: 05
Loc_C543:  ; (dispatch callback target)
; --- Code Region ---
  LDA $0300                             ; $C543: AD 00 03
  CMP #$FF                              ; $C546: C9 FF
  BEQ $C54B                             ; $C548: F0 01
  RTS                                   ; $C54A: 60
; --- Data Region ---
  .byte $A0,$30,$20,$5F,$F2,$A0,$00,$A2,$00,$8E,$10,$00,$8E,$11,$00,$8E; $C54B: A0 30 20 5F F2 A0 00 A2 00 8E 10 00 8E 11 00 8E
  .byte $12,$00,$AC,$10,$00,$B9,$4C,$04,$0A,$A8,$B9,$12,$9B,$8D,$00,$00; $C55B: 12 00 AC 10 00 B9 4C 04 0A A8 B9 12 9B 8D 00 00
  .byte $C8,$B9,$12,$9B,$18,$69,$80,$8D,$01,$00,$A0,$00,$B1,$00,$8D,$BC; $C56B: C8 B9 12 9B 18 69 80 8D 01 00 A0 00 B1 00 8D BC
  .byte $00,$4C,$97,$C5                   ; $C57B: 00 4C 97 C5
Loc_C57F:
; --- Code Region ---
  LDY $0010                             ; $C57F: AC 10 00
  LDA $044C,Y                           ; $C582: B9 4C 04
  ASL                                   ; $C585: 0A
  TAY                                   ; $C586: A8
  LDA $9B12,Y                           ; $C587: B9 12 9B
  STA $0000                             ; $C58A: 8D 00 00
  INY                                   ; $C58D: C8
  LDA $9B12,Y                           ; $C58E: B9 12 9B
  CLC                                   ; $C591: 18
  ADC #$80                              ; $C592: 69 80
  STA $0001                             ; $C594: 8D 01 00
Loc_C597:
  LDY #$00                              ; $C597: A0 00
  STY $0014                             ; $C599: 8C 14 00
  STY $0015                             ; $C59C: 8C 15 00
  LDA ($00),Y                           ; $C59F: B1 00
  CMP $00BC                             ; $C5A1: CD BC 00
  BEQ $C5AE                             ; $C5A4: F0 08
  STA $00BD                             ; $C5A6: 8D BD 00
  LDA #$40                              ; $C5A9: A9 40
  STA $0015                             ; $C5AB: 8D 15 00
Loc_C5AE:
  LDX $0012                             ; $C5AE: AE 12 00
  LDA $C61E,X                           ; $C5B1: BD 1E C6
  STA $0002                             ; $C5B4: 8D 02 00
  INX                                   ; $C5B7: E8
  LDA $C61E,X                           ; $C5B8: BD 1E C6
  STA $0003                             ; $C5BB: 8D 03 00
  INX                                   ; $C5BE: E8
  STX $0012                             ; $C5BF: 8E 12 00
  LDX $0011                             ; $C5C2: AE 11 00
  LDA #$08                              ; $C5C5: A9 08
  STA $0380,X                           ; $C5C7: 9D 80 03
  INX                                   ; $C5CA: E8
  LDA $0003                             ; $C5CB: AD 03 00
  STA $0380,X                           ; $C5CE: 9D 80 03
  INX                                   ; $C5D1: E8
  LDA $0002                             ; $C5D2: AD 02 00
  STA $0380,X                           ; $C5D5: 9D 80 03
  LDA #$00                              ; $C5D8: A9 00
  STA $0013                             ; $C5DA: 8D 13 00
Loc_C5DD:
  INX                                   ; $C5DD: E8
  INY                                   ; $C5DE: C8
  LDA ($00),Y                           ; $C5DF: B1 00
  CLC                                   ; $C5E1: 18
  ADC $0015                             ; $C5E2: 6D 15 00
  STA $0380,X                           ; $C5E5: 9D 80 03
  INC $0013                             ; $C5E8: EE 13 00
  LDA $0013                             ; $C5EB: AD 13 00
  CMP #$08                              ; $C5EE: C9 08
  BCC $C5DD                             ; $C5F0: 90 EB
  INX                                   ; $C5F2: E8
  STX $0011                             ; $C5F3: 8E 11 00
  INC $0014                             ; $C5F6: EE 14 00
  LDA $0014                             ; $C5F9: AD 14 00
  CMP #$02                              ; $C5FC: C9 02
  BCC $C5AE                             ; $C5FE: 90 AE
  INC $0010                             ; $C600: EE 10 00
  LDA $0010                             ; $C603: AD 10 00
  CMP #$04                              ; $C606: C9 04
  BCS $C60D                             ; $C608: B0 03
  JMP $C57F                             ; $C60A: 4C 7F C5
Loc_C60D:
  LDA #$FF                              ; $C60D: A9 FF
  STA $0380,X                           ; $C60F: 9D 80 03
  LDA $007E                             ; $C612: AD 7E 00
  ORA #$04                              ; $C615: 09 04
  STA $007E                             ; $C617: 8D 7E 00
  INC $0501                             ; $C61A: EE 01 05
  RTS                                   ; $C61D: 60
; --- Data Region ---
  .byte $63,$24,$83,$24,$71,$24,$91,$24,$C3,$24,$E3,$24,$D1,$24,$F1,$24; $C61E: 63 24 83 24 71 24 91 24 C3 24 E3 24 D1 24 F1 24
Loc_C62E:  ; (dispatch callback target)
; --- Code Region ---
  LDA #$28                              ; $C62E: A9 28
  STA $0010                             ; $C630: 8D 10 00
  LDA #$C7                              ; $C633: A9 C7
  STA $0011                             ; $C635: 8D 11 00
  LDA #$00                              ; $C638: A9 00
  STA $0012                             ; $C63A: 8D 12 00
  JSR $ED1E                             ; $C63D: 20 1E ED
  LDA #$2E                              ; $C640: A9 2E
  STA $0010                             ; $C642: 8D 10 00
  LDA #$C7                              ; $C645: A9 C7
  STA $0011                             ; $C647: 8D 11 00
  LDA #$36                              ; $C64A: A9 36
  STA $0000                             ; $C64C: 8D 00 00
  LDA #$C7                              ; $C64F: A9 C7
  STA $0001                             ; $C651: 8D 01 00
  LDA $0012                             ; $C654: AD 12 00
  JSR $EDF5                             ; $C657: 20 F5 ED
  LDA $0081                             ; $C65A: AD 81 00
  LSR                                   ; $C65D: 4A
  BCS $C67B                             ; $C65E: B0 1B
  LSR                                   ; $C660: 4A
  BCC $C67A                             ; $C661: 90 17
  LDA #$8C                              ; $C663: A9 8C
  STA $00BD                             ; $C665: 8D BD 00
  LDA #$05                              ; $C668: A9 05
  STA $0501                             ; $C66A: 8D 01 05
  LDA #$00                              ; $C66D: A9 00
  STA $0424                             ; $C66F: 8D 24 04
  STA $0425                             ; $C672: 8D 25 04
  LDA #$AD                              ; $C675: A9 AD
  JMP $F293                             ; $C677: 4C 93 F2
Loc_C67A:
  RTS                                   ; $C67A: 60
Loc_C67B:
  LDY $0012                             ; $C67B: AC 12 00
  LDA $044C,Y                           ; $C67E: B9 4C 04
  STA $044C                             ; $C681: 8D 4C 04
  LDA $0012                             ; $C684: AD 12 00
  ASL                                   ; $C687: 0A
  CLC                                   ; $C688: 18
  ADC $0012                             ; $C689: 6D 12 00
  TAY                                   ; $C68C: A8
  LDA $042C,Y                           ; $C68D: B9 2C 04
  STA $0010                             ; $C690: 8D 10 00
  INY                                   ; $C693: C8
  LDA $042C,Y                           ; $C694: B9 2C 04
  STA $0011                             ; $C697: 8D 11 00
  JSR $C93E                             ; $C69A: 20 3E C9
  LDA $0526,X                           ; $C69D: BD 26 05
  SEC                                   ; $C6A0: 38
  SBC $0010                             ; $C6A1: ED 10 00
  LDA $0527,X                           ; $C6A4: BD 27 05
  SBC $0011                             ; $C6A7: ED 11 00
  BCS $C6B9                             ; $C6AA: B0 0D
  LDA #$11                              ; $C6AC: A9 11
  STA $0471                             ; $C6AE: 8D 71 04
  INC $0501                             ; $C6B1: EE 01 05
  LDA #$B0                              ; $C6B4: A9 B0
  JMP $F293                             ; $C6B6: 4C 93 F2
Loc_C6B9:
  JSR $C73B                             ; $C6B9: 20 3B C7
  BCS $C6C4                             ; $C6BC: B0 06
  LDA #$08                              ; $C6BE: A9 08
  STA $0501                             ; $C6C0: 8D 01 05
  RTS                                   ; $C6C3: 60
Loc_C6C4:
  LDA #$0C                              ; $C6C4: A9 0C
  STA $00BD                             ; $C6C6: 8D BD 00
  LDA $0010                             ; $C6C9: AD 10 00
  STA $042C                             ; $C6CC: 8D 2C 04
  LDA $0011                             ; $C6CF: AD 11 00
  STA $042D                             ; $C6D2: 8D 2D 04
  LDA #$E0                              ; $C6D5: A9 E0
  STA $0010                             ; $C6D7: 8D 10 00
  LDA $044C                             ; $C6DA: AD 4C 04
  CMP #$18                              ; $C6DD: C9 18
  BCC $C6F3                             ; $C6DF: 90 12
  SEC                                   ; $C6E1: 38
  SBC #$18                              ; $C6E2: E9 18
  CLC                                   ; $C6E4: 18
  ROR                                   ; $C6E5: 6A
  ROR                                   ; $C6E6: 6A
  ROR                                   ; $C6E7: 6A
  ROR                                   ; $C6E8: 6A
  AND #$E0                              ; $C6E9: 29 E0
  STA $044C                             ; $C6EB: 8D 4C 04
  LDA #$1F                              ; $C6EE: A9 1F
  STA $0010                             ; $C6F0: 8D 10 00
Loc_C6F3:
  LDY $0509                             ; $C6F3: AC 09 05
  LDA $0664,Y                           ; $C6F6: B9 64 06
  JSR $F2D7                             ; $C6F9: 20 D7 F2
  LDY #$0A                              ; $C6FC: A0 0A
  LDA ($00),Y                           ; $C6FE: B1 00
  AND $0010                             ; $C700: 2D 10 00
  ORA $044C                             ; $C703: 0D 4C 04
  STA ($00),Y                           ; $C706: 91 00
  JSR $C93E                             ; $C708: 20 3E C9
  LDA $0526,X                           ; $C70B: BD 26 05
  SEC                                   ; $C70E: 38
  SBC $042C                             ; $C70F: ED 2C 04
  STA $0526,X                           ; $C712: 9D 26 05
  LDA $0527,X                           ; $C715: BD 27 05
  SBC $042D                             ; $C718: ED 2D 04
  STA $0527,X                           ; $C71B: 9D 27 05
  LDA #$08                              ; $C71E: A9 08
  STA $0501                             ; $C720: 8D 01 05
  LDA #$AF                              ; $C723: A9 AF
  JMP $F293                             ; $C725: 4C 93 F2
; --- Data Region ---
  .byte $00,$01,$02,$03,$FF,$FF,$BA,$10,$BA,$80,$D2,$10,$D2,$80,$00,$07; $C728: 00 01 02 03 FF FF BA 10 BA 80 D2 10 D2 80 00 07
  .byte $00,$00,$80                       ; $C738: 00 00 80
Loc_C73B:
; --- Code Region ---
  LDY $0509                             ; $C73B: AC 09 05
  LDA $0664,Y                           ; $C73E: B9 64 06
  STA $0002                             ; $C741: 8D 02 00
  JSR $F2D7                             ; $C744: 20 D7 F2
  LDA $044C                             ; $C747: AD 4C 04
  CMP #$0F                              ; $C74A: C9 0F
  BNE $C75A                             ; $C74C: D0 0C
  LDA $0002                             ; $C74E: AD 02 00
  CMP #$26                              ; $C751: C9 26
  BNE $C78C                             ; $C753: D0 37
  LDA #$02                              ; $C755: A9 02
  JMP $C793                             ; $C757: 4C 93 C7
Loc_C75A:
  CMP #$17                              ; $C75A: C9 17
  BNE $C76A                             ; $C75C: D0 0C
  LDA $0002                             ; $C75E: AD 02 00
  CMP #$99                              ; $C761: C9 99
  BNE $C78C                             ; $C763: D0 27
  LDA #$04                              ; $C765: A9 04
  JMP $C793                             ; $C767: 4C 93 C7
Loc_C76A:
  CMP #$16                              ; $C76A: C9 16
  BNE $C77B                             ; $C76C: D0 0D
  LDY #$01                              ; $C76E: A0 01
  LDA ($00),Y                           ; $C770: B1 00
  CMP #$5A                              ; $C772: C9 5A
  BCC $C78C                             ; $C774: 90 16
  LDA #$08                              ; $C776: A9 08
  JMP $C793                             ; $C778: 4C 93 C7
Loc_C77B:
  CMP #$1E                              ; $C77B: C9 1E
  BNE $C7A7                             ; $C77D: D0 28
  LDY #$04                              ; $C77F: A0 04
  LDA ($00),Y                           ; $C781: B1 00
  CMP #$5A                              ; $C783: C9 5A
  BCC $C78C                             ; $C785: 90 05
  LDA #$10                              ; $C787: A9 10
  JMP $C793                             ; $C789: 4C 93 C7
Loc_C78C:
  LDA #$48                              ; $C78C: A9 48
  JSR $F293                             ; $C78E: 20 93 F2
  CLC                                   ; $C791: 18
  RTS                                   ; $C792: 60
Loc_C793:
  STA $0003                             ; $C793: 8D 03 00
  LDA $6FE1                             ; $C796: AD E1 6F
  AND $0003                             ; $C799: 2D 03 00
  BNE $C7A9                             ; $C79C: D0 0B
  LDA $6FE1                             ; $C79E: AD E1 6F
  ORA $0003                             ; $C7A1: 0D 03 00
  STA $6FE1                             ; $C7A4: 8D E1 6F
Loc_C7A7:
  SEC                                   ; $C7A7: 38
  RTS                                   ; $C7A8: 60
Loc_C7A9:
  LDA #$49                              ; $C7A9: A9 49
  JSR $F293                             ; $C7AB: 20 93 F2
  CLC                                   ; $C7AE: 18
  RTS                                   ; $C7AF: 60
Loc_C7B0:  ; (dispatch callback target)
  JSR $C948                             ; $C7B0: 20 48 C9
  BCC $C7C7                             ; $C7B3: 90 12
  JSR $C95A                             ; $C7B5: 20 5A C9
  LDA $0081                             ; $C7B8: AD 81 00
  AND #$03                              ; $C7BB: 29 03
  BEQ $C7C7                             ; $C7BD: F0 08
  LDA #$00                              ; $C7BF: A9 00
  STA $0500                             ; $C7C1: 8D 00 05
  STA $0501                             ; $C7C4: 8D 01 05
Loc_C7C7:
  RTS                                   ; $C7C7: 60
Loc_C7C8:  ; (dispatch callback target)
  LDA #$44                              ; $C7C8: A9 44
  STA $0010                             ; $C7CA: 8D 10 00
  LDA #$C8                              ; $C7CD: A9 C8
  STA $0011                             ; $C7CF: 8D 11 00
  LDA #$00                              ; $C7D2: A9 00
  STA $0012                             ; $C7D4: 8D 12 00
  JSR $ED1E                             ; $C7D7: 20 1E ED
  LDA #$48                              ; $C7DA: A9 48
  STA $0010                             ; $C7DC: 8D 10 00
  LDA #$C8                              ; $C7DF: A9 C8
  STA $0011                             ; $C7E1: 8D 11 00
  LDA #$4C                              ; $C7E4: A9 4C
  STA $0000                             ; $C7E6: 8D 00 00
  LDA #$C8                              ; $C7E9: A9 C8
  STA $0001                             ; $C7EB: 8D 01 00
  LDA $0012                             ; $C7EE: AD 12 00
  JSR $EDF5                             ; $C7F1: 20 F5 ED
  JSR $C948                             ; $C7F4: 20 48 C9
  BCC $C80A                             ; $C7F7: 90 11
  LDA $0081                             ; $C7F9: AD 81 00
  LSR                                   ; $C7FC: 4A
  BCS $C80B                             ; $C7FD: B0 0C
  LSR                                   ; $C7FF: 4A
  BCC $C80A                             ; $C800: 90 08
Loc_C802:
  LDA #$00                              ; $C802: A9 00
  STA $0500                             ; $C804: 8D 00 05
  STA $0501                             ; $C807: 8D 01 05
Loc_C80A:
  RTS                                   ; $C80A: 60
Loc_C80B:
  LDA $0012                             ; $C80B: AD 12 00
  BNE $C802                             ; $C80E: D0 F2
  LDA #$00                              ; $C810: A9 00
  STA $0424                             ; $C812: 8D 24 04
  STA $0425                             ; $C815: 8D 25 04
  LDA $0470                             ; $C818: AD 70 04
  BNE $C827                             ; $C81B: D0 0A
  LDA #$00                              ; $C81D: A9 00
  STA $0501                             ; $C81F: 8D 01 05
  LDA #$A8                              ; $C822: A9 A8
  JMP $F283                             ; $C824: 4C 83 F2
Loc_C827:
  CMP #$01                              ; $C827: C9 01
  BNE $C83A                             ; $C829: D0 0F
  LDA #$05                              ; $C82B: A9 05
  STA $0501                             ; $C82D: 8D 01 05
  LDA #$8C                              ; $C830: A9 8C
  STA $00BD                             ; $C832: 8D BD 00
  LDA #$AD                              ; $C835: A9 AD
  JMP $F283                             ; $C837: 4C 83 F2
Loc_C83A:
  LDA #$03                              ; $C83A: A9 03
  STA $0501                             ; $C83C: 8D 01 05
  LDA #$B1                              ; $C83F: A9 B1
  JMP $F283                             ; $C841: 4C 83 F2
; --- Data Region ---
  .byte $00,$01,$FF,$FF,$C6,$50,$C6,$97,$00,$07,$00,$00,$80; $C844: 00 01 FF FF C6 50 C6 97 00 07 00 00 80
Loc_C851:
; --- Code Region ---
  LDA $0000                             ; $C851: AD 00 00
  ASL                                   ; $C854: 0A
  ASL                                   ; $C855: 0A
  ASL                                   ; $C856: 0A
  ASL                                   ; $C857: 0A
  STA $0000                             ; $C858: 8D 00 00
  LDA $0012                             ; $C85B: AD 12 00
  ASL                                   ; $C85E: 0A
  ASL                                   ; $C85F: 0A
  CLC                                   ; $C860: 18
  ADC $0000                             ; $C861: 6D 00 00
  TAY                                   ; $C864: A8
  LDX #$00                              ; $C865: A2 00
Loc_C867:
  LDA $C8DE,Y                           ; $C867: B9 DE C8
  STA $044C,X                           ; $C86A: 9D 4C 04
  ASL                                   ; $C86D: 0A
  STA $0000                             ; $C86E: 8D 00 00
  TYA                                   ; $C871: 98
  PHA                                   ; $C872: 48
  STX $0001                             ; $C873: 8E 01 00
  TXA                                   ; $C876: 8A
  ASL                                   ; $C877: 0A
  CLC                                   ; $C878: 18
  ADC $0001                             ; $C879: 6D 01 00
  TAX                                   ; $C87C: AA
  LDY $0000                             ; $C87D: AC 00 00
  LDA $C89E,Y                           ; $C880: B9 9E C8
  STA $042C,X                           ; $C883: 9D 2C 04
  INY                                   ; $C886: C8
  LDA $C89E,Y                           ; $C887: B9 9E C8
  STA $042D,X                           ; $C88A: 9D 2D 04
  LDA #$00                              ; $C88D: A9 00
  STA $042E,X                           ; $C88F: 9D 2E 04
  LDX $0001                             ; $C892: AE 01 00
  PLA                                   ; $C895: 68
  TAY                                   ; $C896: A8
  INY                                   ; $C897: C8
  INX                                   ; $C898: E8
  CPX #$04                              ; $C899: E0 04
  BCC $C867                             ; $C89B: 90 CA
  RTS                                   ; $C89D: 60
; --- Data Region ---
  .byte $32,$00,$46,$00,$78,$00,$B4,$00,$FA,$00,$00,$00,$00,$00,$00,$00; $C89E: 32 00 46 00 78 00 B4 00 FA 00 00 00 00 00 00 00
  .byte $3C,$00,$64,$00,$96,$00,$C8,$00,$F0,$00; $C8AE: 3C 00 64 00 96 00 C8 00 F0 00
Loc_C8B8:
; --- Code Region ---
  NOP $01                               ; $C8B8: 04 01
  BRK                                   ; $C8BA: 00
  BRK                                   ; $C8BB: 00
  BCC $C8BF                             ; $C8BC: 90 01
  BVC $C8C0                             ; $C8BE: 50 00
Loc_C8C0:
  NOP $00                               ; $C8C0: 64 00
  SEI                                   ; $C8C2: 78
  BRK                                   ; $C8C3: 00
  INY                                   ; $C8C4: C8
  BRK                                   ; $C8C5: 00
  NOP                                   ; $C8C6: FA
  BRK                                   ; $C8C7: 00
  BIT $5E01                             ; $C8C8: 2C 01 5E
  ORA ($90,X)                           ; $C8CB: 01 90
  ORA ($32,X)                           ; $C8CD: 01 32
  BRK                                   ; $C8CF: 00
  BVC $C8D2                             ; $C8D0: 50 00
Loc_C8D2:
  NOP $00                               ; $C8D2: 64 00
  STX $00,Y                             ; $C8D4: 96 00
  INY                                   ; $C8D6: C8
  BRK                                   ; $C8D7: 00
  NOP                                   ; $C8D8: FA
  BRK                                   ; $C8D9: 00
  LSR $9001,X                           ; $C8DA: 5E 01 90
  ORA ($00,X)                           ; $C8DD: 01 00
  ORA ($02,X)                           ; $C8DF: 01 02
  SLO ($08,X)                           ; $C8E1: 03 08
  ORA #$0A                              ; $C8E3: 09 0A
  ANC #$10                              ; $C8E5: 0B 10
  ORA ($12),Y                           ; $C8E7: 11 12
  SLO ($18),Y                           ; $C8E9: 13 18
  ORA $1B1A,Y                           ; $C8EB: 19 1A 1B
  ORA ($02,X)                           ; $C8EE: 01 02
  SLO ($04,X)                           ; $C8F0: 03 04
  ASL                                   ; $C8F2: 0A
  ANC #$0C                              ; $C8F3: 0B 0C
  ORA $1312                             ; $C8F5: 0D 12 13
  NOP $15,X                             ; $C8F8: 14 15
  NOP                                   ; $C8FA: 1A
  SLO $1D1C,Y                           ; $C8FB: 1B 1C 1D
  BRK                                   ; $C8FE: 00
  ORA ($02,X)                           ; $C8FF: 01 02
  SLO ($08,X)                           ; $C901: 03 08
  ORA #$0A                              ; $C903: 09 0A
  SLO $1211                             ; $C905: 0F 11 12
  SLO ($14),Y                           ; $C908: 13 14
  CLC                                   ; $C90A: 18
  ORA $1B1A,Y                           ; $C90B: 19 1A 1B
  BRK                                   ; $C90E: 00
  ORA ($02,X)                           ; $C90F: 01 02
  SLO ($09,X)                           ; $C911: 03 09
  ASL                                   ; $C913: 0A
  ANC #$0C                              ; $C914: 0B 0C
  ORA ($12),Y                           ; $C916: 11 12
  SLO ($16),Y                           ; $C918: 13 16
  ORA $1B1A,Y                           ; $C91A: 19 1A 1B
  ORA $0201,X                           ; $C91D: 1D 01 02
  SLO ($04,X)                           ; $C920: 03 04
  PHP                                   ; $C922: 08
  ORA #$0A                              ; $C923: 09 0A
  ANC #$11                              ; $C925: 0B 11
  JAM                                   ; $C927: 12
  SLO ($14),Y                           ; $C928: 13 14
  NOP                                   ; $C92A: 1A
  SLO $1D1C,Y                           ; $C92B: 1B 1C 1D
  ORA ($02,X)                           ; $C92E: 01 02
  SLO ($04,X)                           ; $C930: 03 04
  ASL                                   ; $C932: 0A
  ANC #$0C                              ; $C933: 0B 0C
  ORA $1312                             ; $C935: 0D 12 13
  NOP $15,X                             ; $C938: 14 15
  ORA $1B1A,Y                           ; $C93A: 19 1A 1B
  ASL $00A2,X                           ; $C93D: 1E A2 00
  LDA $0504                             ; $C940: AD 04 05
  BPL $C947                             ; $C943: 10 02
  LDX #$02                              ; $C945: A2 02
Loc_C947:
  RTS                                   ; $C947: 60
Loc_C948:
  LDA $0304                             ; $C948: AD 04 03
  CMP #$FF                              ; $C94B: C9 FF
  BNE $C958                             ; $C94D: D0 09
  LDA $0300                             ; $C94F: AD 00 03
  CMP #$FF                              ; $C952: C9 FF
  BNE $C958                             ; $C954: D0 02
  SEC                                   ; $C956: 38
  RTS                                   ; $C957: 60
Loc_C958:
  CLC                                   ; $C958: 18
  RTS                                   ; $C959: 60
Loc_C95A:
  LDA #$D8                              ; $C95A: A9 D8
  STA $000A                             ; $C95C: 8D 0A 00
  LDA #$80                              ; $C95F: A9 80
  STA $000C                             ; $C961: 8D 0C 00
  LDA $005E                             ; $C964: AD 5E 00
  AND #$10                              ; $C967: 29 10
  BNE $C97D                             ; $C969: D0 12
  LDA #$7E                              ; $C96B: A9 7E
  STA $0000                             ; $C96D: 8D 00 00
  LDA #$C9                              ; $C970: A9 C9
  STA $0001                             ; $C972: 8D 01 00
  LDA #$00                              ; $C975: A9 00
  STA $0002                             ; $C977: 8D 02 00
  JMP $F1AD                             ; $C97A: 4C AD F1
Loc_C97D:
  RTS                                   ; $C97D: 60
; --- Data Region ---
  .byte $00,$04,$00,$00,$80               ; $C97E: 00 04 00 00 80
Loc_C983:
; --- Code Region ---
  LDY #$00                              ; $C983: A0 00
  STY $0010                             ; $C985: 8C 10 00
  STY $0011                             ; $C988: 8C 11 00
Loc_C98B:
  JSR $CC92                             ; $C98B: 20 92 CC
  BMI $C9C4                             ; $C98E: 30 34
  LDA $6FA1,Y                           ; $C990: B9 A1 6F
  AND #$0F                              ; $C993: 29 0F
  CMP #$07                              ; $C995: C9 07
  BNE $C9A6                             ; $C997: D0 0D
  LDA $6FA1,Y                           ; $C999: B9 A1 6F
  LSR                                   ; $C99C: 4A
  LSR                                   ; $C99D: 4A
  LSR                                   ; $C99E: 4A
  LSR                                   ; $C99F: 4A
  STA $6FA1,Y                           ; $C9A0: 99 A1 6F
  JMP $C9C4                             ; $C9A3: 4C C4 C9
Loc_C9A6:
  CMP #$05                              ; $C9A6: C9 05
  BCC $C9C4                             ; $C9A8: 90 1A
  CMP #$05                              ; $C9AA: C9 05
  BNE $C9B3                             ; $C9AC: D0 05
  LDA #$64                              ; $C9AE: A9 64
  JMP $C9B5                             ; $C9B0: 4C B5 C9
Loc_C9B3:
  LDA #$32                              ; $C9B3: A9 32
Loc_C9B5:
  CLC                                   ; $C9B5: 18
  ADC $0010                             ; $C9B6: 6D 10 00
  STA $0010                             ; $C9B9: 8D 10 00
  LDA $0011                             ; $C9BC: AD 11 00
  ADC #$00                              ; $C9BF: 69 00
  STA $0011                             ; $C9C1: 8D 11 00
Loc_C9C4:
  INY                                   ; $C9C4: C8
  CPY #$14                              ; $C9C5: C0 14
  BCC $C98B                             ; $C9C7: 90 C2
  JSR $C93E                             ; $C9C9: 20 3E C9
  LDA $0526,X                           ; $C9CC: BD 26 05
  SEC                                   ; $C9CF: 38
  SBC $0010                             ; $C9D0: ED 10 00
  LDA $0527,X                           ; $C9D3: BD 27 05
  SBC $0011                             ; $C9D6: ED 11 00
  BCC $C9DE                             ; $C9D9: 90 03
  JMP $CA10                             ; $C9DB: 4C 10 CA
Loc_C9DE:
  LDA #$06                              ; $C9DE: A9 06
  STA $0010                             ; $C9E0: 8D 10 00
Loc_C9E3:
  LDY #$00                              ; $C9E3: A0 00
Loc_C9E5:
  JSR $CC92                             ; $C9E5: 20 92 CC
  BMI $CA01                             ; $C9E8: 30 17
  LDA $6FA1,Y                           ; $C9EA: B9 A1 6F
  AND #$0F                              ; $C9ED: 29 0F
  CMP $0010                             ; $C9EF: CD 10 00
  BNE $CA01                             ; $C9F2: D0 0D
  LDA $6FA1,Y                           ; $C9F4: B9 A1 6F
  LSR                                   ; $C9F7: 4A
  LSR                                   ; $C9F8: 4A
  LSR                                   ; $C9F9: 4A
  LSR                                   ; $C9FA: 4A
  STA $6FA1,Y                           ; $C9FB: 99 A1 6F
  JMP $C983                             ; $C9FE: 4C 83 C9
Loc_CA01:
  INY                                   ; $CA01: C8
  CPY #$14                              ; $CA02: C0 14
  BCC $C9E5                             ; $CA04: 90 DF
  DEC $0010                             ; $CA06: CE 10 00
  LDA $0010                             ; $CA09: AD 10 00
  CMP #$05                              ; $CA0C: C9 05
  BCS $C9E3                             ; $CA0E: B0 D3
Loc_CA10:
  JSR $CD00                             ; $CA10: 20 00 CD
  JSR $C93E                             ; $CA13: 20 3E C9
  LDA $0522,X                           ; $CA16: BD 22 05
  SEC                                   ; $CA19: 38
  SBC $001A                             ; $CA1A: ED 1A 00
  LDA $0523,X                           ; $CA1D: BD 23 05
  SBC $001B                             ; $CA20: ED 1B 00
  BCS $CA28                             ; $CA23: B0 03
  JMP $CA5F                             ; $CA25: 4C 5F CA
Loc_CA28:
  JSR $C93E                             ; $CA28: 20 3E C9
  TXA                                   ; $CA2B: 8A
  EOR #$02                              ; $CA2C: 49 02
  TAX                                   ; $CA2E: AA
  LDA $0522,X                           ; $CA2F: BD 22 05
  SEC                                   ; $CA32: 38
  SBC $001C                             ; $CA33: ED 1C 00
  LDA $0523,X                           ; $CA36: BD 23 05
  SBC $001D                             ; $CA39: ED 1D 00
  BCS $CA5C                             ; $CA3C: B0 1E
  LDA #$05                              ; $CA3E: A9 05
  JSR $CD06                             ; $CA40: 20 06 CD
  JSR $C93E                             ; $CA43: 20 3E C9
  TXA                                   ; $CA46: 8A
  EOR #$02                              ; $CA47: 49 02
  TAX                                   ; $CA49: AA
  LDA $0522,X                           ; $CA4A: BD 22 05
  SEC                                   ; $CA4D: 38
  SBC $001C                             ; $CA4E: ED 1C 00
  LDA $0523,X                           ; $CA51: BD 23 05
  SBC $001D                             ; $CA54: ED 1D 00
  BCS $CA5C                             ; $CA57: B0 03
  JSR $CB4D                             ; $CA59: 20 4D CB
Loc_CA5C:
  JMP $CAC2                             ; $CA5C: 4C C2 CA
Loc_CA5F:
  LDY #$31                              ; $CA5F: A0 31
  JSR $F25F                             ; $CA61: 20 5F F2
  LDA $050E                             ; $CA64: AD 0E 05
  ASL                                   ; $CA67: 0A
  STA $0000                             ; $CA68: 8D 00 00
  ASL                                   ; $CA6B: 0A
  CLC                                   ; $CA6C: 18
  ADC $0000                             ; $CA6D: 6D 00 00
  TAY                                   ; $CA70: A8
  LDA $9BA4,Y                           ; $CA71: B9 A4 9B
  CMP #$FF                              ; $CA74: C9 FF
  BNE $CA7B                             ; $CA76: D0 03
  JMP $CAA8                             ; $CA78: 4C A8 CA
Loc_CA7B:
  JSR $C93E                             ; $CA7B: 20 3E C9
  LDA $0527,X                           ; $CA7E: BD 27 05
  BNE $CA8D                             ; $CA81: D0 0A
  LDA $0526,X                           ; $CA83: BD 26 05
  CMP #$64                              ; $CA86: C9 64
  BCS $CA8D                             ; $CA88: B0 03
  JMP $CAA8                             ; $CA8A: 4C A8 CA
Loc_CA8D:
  LDY #$00                              ; $CA8D: A0 00
Loc_CA8F:
  JSR $CC92                             ; $CA8F: 20 92 CC
  BMI $CA9D                             ; $CA92: 30 09
  LDA $6FA1,Y                           ; $CA94: B9 A1 6F
  AND #$0F                              ; $CA97: 29 0F
  CMP #$05                              ; $CA99: C9 05
  BEQ $CAA5                             ; $CA9B: F0 08
Loc_CA9D:
  INY                                   ; $CA9D: C8
  CPY #$14                              ; $CA9E: C0 14
  BCC $CA8F                             ; $CAA0: 90 ED
  JSR $CB6A                             ; $CAA2: 20 6A CB
Loc_CAA5:
  JMP $CAC2                             ; $CAA5: 4C C2 CA
Loc_CAA8:
  LDA #$0A                              ; $CAA8: A9 0A
  JSR $CD06                             ; $CAAA: 20 06 CD
  JSR $C93E                             ; $CAAD: 20 3E C9
  LDA $0522,X                           ; $CAB0: BD 22 05
  SEC                                   ; $CAB3: 38
  SBC $001A                             ; $CAB4: ED 1A 00
  LDA $0523,X                           ; $CAB7: BD 23 05
  SBC $001B                             ; $CABA: ED 1B 00
  BCS $CAC2                             ; $CABD: B0 03
  JSR $CBFE                             ; $CABF: 20 FE CB
Loc_CAC2:
  LDY #$31                              ; $CAC2: A0 31
  JSR $F25F                             ; $CAC4: 20 5F F2
  LDA $050E                             ; $CAC7: AD 0E 05
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
  BEQ $CB09                             ; $CADC: F0 2B
  JSR $C93E                             ; $CADE: 20 3E C9
  LDA $0527,X                           ; $CAE1: BD 27 05
  BNE $CAED                             ; $CAE4: D0 07
  LDA $0526,X                           ; $CAE6: BD 26 05
  CMP #$32                              ; $CAE9: C9 32
  BCC $CB09                             ; $CAEB: 90 1C
Loc_CAED:
  LDY #$00                              ; $CAED: A0 00
  LDX #$00                              ; $CAEF: A2 00
Loc_CAF1:
  JSR $CC92                             ; $CAF1: 20 92 CC
  BMI $CB00                             ; $CAF4: 30 0A
  LDA $6FA1,Y                           ; $CAF6: B9 A1 6F
  AND #$0F                              ; $CAF9: 29 0F
  CMP #$06                              ; $CAFB: C9 06
  BNE $CB00                             ; $CAFD: D0 01
  INX                                   ; $CAFF: E8
Loc_CB00:
  INY                                   ; $CB00: C8
  CPY #$14                              ; $CB01: C0 14
  BCC $CAF1                             ; $CB03: 90 EC
  CPX #$02                              ; $CB05: E0 02
  BCC $CB0C                             ; $CB07: 90 03
Loc_CB09:
  JMP $CB27                             ; $CB09: 4C 27 CB
Loc_CB0C:
  STX $0010                             ; $CB0C: 8E 10 00
  LDY #$00                              ; $CB0F: A0 00
Loc_CB11:
  JSR $CC92                             ; $CB11: 20 92 CC
  BMI $CB22                             ; $CB14: 30 0C
  LDA $6FA1,Y                           ; $CB16: B9 A1 6F
  BEQ $CB22                             ; $CB19: F0 07
  CMP #$05                              ; $CB1B: C9 05
  BCS $CB22                             ; $CB1D: B0 03
  JSR $CC19                             ; $CB1F: 20 19 CC
Loc_CB22:
  INY                                   ; $CB22: C8
  CPY #$14                              ; $CB23: C0 14
  BCC $CB11                             ; $CB25: 90 EA
Loc_CB27:
  JSR $CCAA                             ; $CB27: 20 AA CC
  LDA $001C                             ; $CB2A: AD 1C 00
  SEC                                   ; $CB2D: 38
  SBC #$E8                              ; $CB2E: E9 E8
  LDA $001D                             ; $CB30: AD 1D 00
  SBC #$03                              ; $CB33: E9 03
  BCC $CB3A                             ; $CB35: 90 03
  JMP $CB9A                             ; $CB37: 4C 9A CB
Loc_CB3A:
  LDA $001A                             ; $CB3A: AD 1A 00
  SEC                                   ; $CB3D: 38
  SBC #$88                              ; $CB3E: E9 88
  LDA $001B                             ; $CB40: AD 1B 00
  SBC #$13                              ; $CB43: E9 13
  BCS $CB4A                             ; $CB45: B0 03
  JMP $CB9A                             ; $CB47: 4C 9A CB
Loc_CB4A:
  JMP $CBFE                             ; $CB4A: 4C FE CB
Loc_CB4D:
  LDY #$00                              ; $CB4D: A0 00
Loc_CB4F:
  JSR $CC92                             ; $CB4F: 20 92 CC
  BMI $CB64                             ; $CB52: 30 10
  LDA $6FA1,Y                           ; $CB54: B9 A1 6F
  CMP #$01                              ; $CB57: C9 01
  BEQ $CB5F                             ; $CB59: F0 04
  CMP #$02                              ; $CB5B: C9 02
  BNE $CB64                             ; $CB5D: D0 05
Loc_CB5F:
  LDA #$04                              ; $CB5F: A9 04
  STA $6FA1,Y                           ; $CB61: 99 A1 6F
Loc_CB64:
  INY                                   ; $CB64: C8
  CPY #$14                              ; $CB65: C0 14
  BCC $CB4F                             ; $CB67: 90 E6
  RTS                                   ; $CB69: 60
Loc_CB6A:
  LDX #$00                              ; $CB6A: A2 00
Loc_CB6C:
  LDA $CB96,X                           ; $CB6C: BD 96 CB
  STA $001A                             ; $CB6F: 8D 1A 00
  LDY #$00                              ; $CB72: A0 00
Loc_CB74:
  JSR $A944                             ; $CB74: 20 44 A9
  BMI $CB8B                             ; $CB77: 30 12
  LDA $6FA1,Y                           ; $CB79: B9 A1 6F
  CMP $001A                             ; $CB7C: CD 1A 00
  BNE $CB8B                             ; $CB7F: D0 0A
  ASL                                   ; $CB81: 0A
  ASL                                   ; $CB82: 0A
  ASL                                   ; $CB83: 0A
  ASL                                   ; $CB84: 0A
  ORA #$05                              ; $CB85: 09 05
  STA $6FA1,Y                           ; $CB87: 99 A1 6F
  RTS                                   ; $CB8A: 60
Loc_CB8B:
  INY                                   ; $CB8B: C8
  CPY #$14                              ; $CB8C: C0 14
  BCC $CB74                             ; $CB8E: 90 E4
  INX                                   ; $CB90: E8
  CPX #$04                              ; $CB91: E0 04
  BCC $CB6C                             ; $CB93: 90 D7
  RTS                                   ; $CB95: 60
; --- Data Region ---
  .byte $02,$04,$01,$03                   ; $CB96: 02 04 01 03
Loc_CB9A:
; --- Code Region ---
  LDY #$00                              ; $CB9A: A0 00
  STY $0010                             ; $CB9C: 8C 10 00
  STY $0011                             ; $CB9F: 8C 11 00
Loc_CBA2:
  JSR $CC92                             ; $CBA2: 20 92 CC
  LDA $6FA1,Y                           ; $CBA5: B9 A1 6F
  CMP #$01                              ; $CBA8: C9 01
  BNE $CBB2                             ; $CBAA: D0 06
  INC $0010                             ; $CBAC: EE 10 00
  JMP $CBB9                             ; $CBAF: 4C B9 CB
Loc_CBB2:
  CMP #$03                              ; $CBB2: C9 03
  BNE $CBB9                             ; $CBB4: D0 03
  INC $0011                             ; $CBB6: EE 11 00
Loc_CBB9:
  INY                                   ; $CBB9: C8
  CPY #$14                              ; $CBBA: C0 14
  BCC $CBA2                             ; $CBBC: 90 E4
  LDA $0010                             ; $CBBE: AD 10 00
  CMP $6F99                             ; $CBC1: CD 99 6F
  BCS $CBCE                             ; $CBC4: B0 08
  LDA #$02                              ; $CBC6: A9 02
  STA $0000                             ; $CBC8: 8D 00 00
  JSR $CBDF                             ; $CBCB: 20 DF CB
Loc_CBCE:
  LDA $0011                             ; $CBCE: AD 11 00
  CMP $6F9B                             ; $CBD1: CD 9B 6F
  BCS $CBDE                             ; $CBD4: B0 08
  LDA #$04                              ; $CBD6: A9 04
  STA $0000                             ; $CBD8: 8D 00 00
  JSR $CBDF                             ; $CBDB: 20 DF CB
Loc_CBDE:
  RTS                                   ; $CBDE: 60
Loc_CBDF:
  LDY #$00                              ; $CBDF: A0 00
Loc_CBE1:
  JSR $CC92                             ; $CBE1: 20 92 CC
  BMI $CBF8                             ; $CBE4: 30 12
  LDA $6FA1,Y                           ; $CBE6: B9 A1 6F
  CMP $0000                             ; $CBE9: CD 00 00
  BNE $CBF8                             ; $CBEC: D0 0A
  DEC $0000                             ; $CBEE: CE 00 00
  LDA $0000                             ; $CBF1: AD 00 00
  STA $6FA1,Y                           ; $CBF4: 99 A1 6F
  RTS                                   ; $CBF7: 60
Loc_CBF8:
  INY                                   ; $CBF8: C8
  CPY #$14                              ; $CBF9: C0 14
  BCC $CBE1                             ; $CBFB: 90 E4
  RTS                                   ; $CBFD: 60
Loc_CBFE:
  LDY #$00                              ; $CBFE: A0 00
Loc_CC00:
  JSR $CC92                             ; $CC00: 20 92 CC
  BMI $CC13                             ; $CC03: 30 0E
  LDA $6FA1,Y                           ; $CC05: B9 A1 6F
  BEQ $CC13                             ; $CC08: F0 09
  CMP #$05                              ; $CC0A: C9 05
  BCS $CC13                             ; $CC0C: B0 05
  LDA #$01                              ; $CC0E: A9 01
  STA $6FA1,Y                           ; $CC10: 99 A1 6F
Loc_CC13:
  INY                                   ; $CC13: C8
  CPY #$14                              ; $CC14: C0 14
  BCC $CC00                             ; $CC16: 90 E8
  RTS                                   ; $CC18: 60
Loc_CC19:
  LDA $0664,Y                           ; $CC19: B9 64 06
  CMP #$FF                              ; $CC1C: C9 FF
  BNE $CC21                             ; $CC1E: D0 01
  RTS                                   ; $CC20: 60
Loc_CC21:
  STA $0011                             ; $CC21: 8D 11 00
  TYA                                   ; $CC24: 98
  PHA                                   ; $CC25: 48
  LDA $0011                             ; $CC26: AD 11 00
  JSR $F387                             ; $CC29: 20 87 F3
  LDY #$00                              ; $CC2C: A0 00
  LDA ($00),Y                           ; $CC2E: B1 00
  STA $0000                             ; $CC30: 8D 00 00
  LDA #$00                              ; $CC33: A9 00
  STA $0001                             ; $CC35: 8D 01 00
  STA $0002                             ; $CC38: 8D 02 00
  LDA #$06                              ; $CC3B: A9 06
  STA $0003                             ; $CC3D: 8D 03 00
  JSR $EBE9                             ; $CC40: 20 E9 EB
  LDA $0006                             ; $CC43: AD 06 00
  STA $0001                             ; $CC46: 8D 01 00
  LDA $0007                             ; $CC49: AD 07 00
  STA $0002                             ; $CC4C: 8D 02 00
  LDA #$0A                              ; $CC4F: A9 0A
  STA $0003                             ; $CC51: 8D 03 00
  LDA #$00                              ; $CC54: A9 00
  STA $0004                             ; $CC56: 8D 04 00
  JSR $EA7C                             ; $CC59: 20 7C EA
  LDA $0001                             ; $CC5C: AD 01 00
  STA $0012                             ; $CC5F: 8D 12 00
  LDA $0011                             ; $CC62: AD 11 00
  JSR $F2D7                             ; $CC65: 20 D7 F2
  LDY #$00                              ; $CC68: A0 00
  LDA ($00),Y                           ; $CC6A: B1 00
  STA $0011                             ; $CC6C: 8D 11 00
  PLA                                   ; $CC6F: 68
  TAY                                   ; $CC70: A8
  LDA $0011                             ; $CC71: AD 11 00
  CMP $0012                             ; $CC74: CD 12 00
  BCS $CC91                             ; $CC77: B0 18
  LDA $6FA1,Y                           ; $CC79: B9 A1 6F
  ASL                                   ; $CC7C: 0A
  ASL                                   ; $CC7D: 0A
  ASL                                   ; $CC7E: 0A
  ASL                                   ; $CC7F: 0A
  ORA #$06                              ; $CC80: 09 06
  STA $6FA1,Y                           ; $CC82: 99 A1 6F
  INC $0010                             ; $CC85: EE 10 00
  LDA $0010                             ; $CC88: AD 10 00
  CMP #$02                              ; $CC8B: C9 02
  BCC $CC91                             ; $CC8D: 90 02
  LDY #$14                              ; $CC8F: A0 14
Loc_CC91:
  RTS                                   ; $CC91: 60
Loc_CC92:
  LDA $0504                             ; $CC92: AD 04 05
  BMI $CC9F                             ; $CC95: 30 08
  LDA $0628,Y                           ; $CC97: B9 28 06
  BMI $CCA7                             ; $CC9A: 30 0B
  LDA #$00                              ; $CC9C: A9 00
  RTS                                   ; $CC9E: 60
Loc_CC9F:
  LDA $0628,Y                           ; $CC9F: B9 28 06
  BPL $CCA7                             ; $CCA2: 10 03
  LDA #$00                              ; $CCA4: A9 00
  RTS                                   ; $CCA6: 60
Loc_CCA7:
  LDA #$80                              ; $CCA7: A9 80
  RTS                                   ; $CCA9: 60
Loc_CCAA:
  LDY #$31                              ; $CCAA: A0 31
  JSR $F25F                             ; $CCAC: 20 5F F2
  LDY #$00                              ; $CCAF: A0 00
  STY $001A                             ; $CCB1: 8C 1A 00
  STY $001B                             ; $CCB4: 8C 1B 00
  STY $001C                             ; $CCB7: 8C 1C 00
  STY $001D                             ; $CCBA: 8C 1D 00
Loc_CCBD:
  LDA $0664,Y                           ; $CCBD: B9 64 06
  CMP #$FF                              ; $CCC0: C9 FF
  BEQ $CCFA                             ; $CCC2: F0 36
  STA $0002                             ; $CCC4: 8D 02 00
  TYA                                   ; $CCC7: 98
  PHA                                   ; $CCC8: 48
  LDA $0002                             ; $CCC9: AD 02 00
  JSR $F2D7                             ; $CCCC: 20 D7 F2
  LDY #$08                              ; $CCCF: A0 08
  LDA ($00),Y                           ; $CCD1: B1 00
  STA $0002                             ; $CCD3: 8D 02 00
  INY                                   ; $CCD6: C8
  LDA ($00),Y                           ; $CCD7: B1 00
  STA $0003                             ; $CCD9: 8D 03 00
  PLA                                   ; $CCDC: 68
  TAY                                   ; $CCDD: A8
  LDX #$00                              ; $CCDE: A2 00
  JSR $CC92                             ; $CCE0: 20 92 CC
  BPL $CCE7                             ; $CCE3: 10 02
  LDX #$02                              ; $CCE5: A2 02
Loc_CCE7:
  LDA $001A,X                           ; $CCE7: BD 1A 00
  CLC                                   ; $CCEA: 18
  ADC $0002                             ; $CCEB: 6D 02 00
  STA $001A,X                           ; $CCEE: 9D 1A 00
  LDA $001B,X                           ; $CCF1: BD 1B 00
  ADC $0003                             ; $CCF4: 6D 03 00
  STA $001B,X                           ; $CCF7: 9D 1B 00
Loc_CCFA:
  INY                                   ; $CCFA: C8
  CPY #$14                              ; $CCFB: C0 14
  BCC $CCBD                             ; $CCFD: 90 BE
  RTS                                   ; $CCFF: 60
Loc_CD00:
  LDA #$1E                              ; $CD00: A9 1E
  SEC                                   ; $CD02: 38
  SBC $0506                             ; $CD03: ED 06 05
Loc_CD06:
  STA $001E                             ; $CD06: 8D 1E 00
  JSR $CCAA                             ; $CD09: 20 AA CC
  LDA $001A                             ; $CD0C: AD 1A 00
  STA $0000                             ; $CD0F: 8D 00 00
  LDA $001B                             ; $CD12: AD 1B 00
  STA $0001                             ; $CD15: 8D 01 00
  JSR $CD43                             ; $CD18: 20 43 CD
  LDA $0006                             ; $CD1B: AD 06 00
  STA $001A                             ; $CD1E: 8D 1A 00
  LDA $0007                             ; $CD21: AD 07 00
  STA $001B                             ; $CD24: 8D 1B 00
  LDA $001C                             ; $CD27: AD 1C 00
  STA $0000                             ; $CD2A: 8D 00 00
  LDA $001D                             ; $CD2D: AD 1D 00
  STA $0001                             ; $CD30: 8D 01 00
  JSR $CD43                             ; $CD33: 20 43 CD
  LDA $0006                             ; $CD36: AD 06 00
  STA $001C                             ; $CD39: 8D 1C 00
  LDA $0007                             ; $CD3C: AD 07 00
  STA $001D                             ; $CD3F: 8D 1D 00
  RTS                                   ; $CD42: 60
Loc_CD43:
  LDA #$00                              ; $CD43: A9 00
  STA $0002                             ; $CD45: 8D 02 00
  LDA #$04                              ; $CD48: A9 04
  STA $0003                             ; $CD4A: 8D 03 00
  JSR $EBE9                             ; $CD4D: 20 E9 EB
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
  JSR $EAA5                             ; $CD6C: 20 A5 EA
  LDA $001E                             ; $CD6F: AD 1E 00
  STA $0003                             ; $CD72: 8D 03 00
  JMP $EBE9                             ; $CD75: 4C E9 EB
Loc_CD78:
  LDA #$00                              ; $CD78: A9 00
  STA $050A                             ; $CD7A: 8D 0A 05
  LDA $0506                             ; $CD7D: AD 06 05
  CMP #$1F                              ; $CD80: C9 1F
  BCC $CD8C                             ; $CD82: 90 08
  LDA #$00                              ; $CD84: A9 00
  STA $0000                             ; $CD86: 8D 00 00
  JMP $CEAB                             ; $CD89: 4C AB CE
Loc_CD8C:
  LDA #$01                              ; $CD8C: A9 01
  JSR $CD06                             ; $CD8E: 20 06 CD
  LDA $0524                             ; $CD91: AD 24 05
  SEC                                   ; $CD94: 38
  SBC $001A                             ; $CD95: ED 1A 00
  STA $0524                             ; $CD98: 8D 24 05
  LDA $0525                             ; $CD9B: AD 25 05
  SBC $001B                             ; $CD9E: ED 1B 00
  STA $0525                             ; $CDA1: 8D 25 05
  BCC $CDB0                             ; $CDA4: 90 0A
  LDA $0524                             ; $CDA6: AD 24 05
  BNE $CDC0                             ; $CDA9: D0 15
  LDA $0525                             ; $CDAB: AD 25 05
  BNE $CDC0                             ; $CDAE: D0 10
Loc_CDB0:
  LDA #$00                              ; $CDB0: A9 00
  STA $0524                             ; $CDB2: 8D 24 05
  STA $0525                             ; $CDB5: 8D 25 05
  LDA #$80                              ; $CDB8: A9 80
  STA $0000                             ; $CDBA: 8D 00 00
  JMP $CEAB                             ; $CDBD: 4C AB CE
Loc_CDC0:
  LDA $0522                             ; $CDC0: AD 22 05
  SEC                                   ; $CDC3: 38
  SBC $001C                             ; $CDC4: ED 1C 00
  STA $0522                             ; $CDC7: 8D 22 05
  LDA $0523                             ; $CDCA: AD 23 05
  SBC $001D                             ; $CDCD: ED 1D 00
  STA $0523                             ; $CDD0: 8D 23 05
  BCC $CDDF                             ; $CDD3: 90 0A
  LDA $0522                             ; $CDD5: AD 22 05
  BNE $CDEA                             ; $CDD8: D0 10
  LDA $0523                             ; $CDDA: AD 23 05
  BNE $CDEA                             ; $CDDD: D0 0B
Loc_CDDF:
  LDA #$00                              ; $CDDF: A9 00
  STA $0522                             ; $CDE1: 8D 22 05
  STA $0523                             ; $CDE4: 8D 23 05
  JMP $CF06                             ; $CDE7: 4C 06 CF
Loc_CDEA:
  LDA #$0F                              ; $CDEA: A9 0F
  STA $0010                             ; $CDEC: 8D 10 00
  LDA #$01                              ; $CDEF: A9 01
  STA $0011                             ; $CDF1: 8D 11 00
  JSR $CE40                             ; $CDF4: 20 40 CE
  JSR $CF60                             ; $CDF7: 20 60 CF
  LDA $052E                             ; $CDFA: AD 2E 05
  BEQ $CE20                             ; $CDFD: F0 21
  LDA #$F0                              ; $CDFF: A9 F0
  STA $0010                             ; $CE01: 8D 10 00
  LDA #$10                              ; $CE04: A9 10
  STA $0011                             ; $CE06: 8D 11 00
  LDA #$00                              ; $CE09: A9 00
  STA $000B                             ; $CE0B: 8D 0B 00
  STA $000C                             ; $CE0E: 8D 0C 00
  JSR $CE40                             ; $CE11: 20 40 CE
  LDA #$6D                              ; $CE14: A9 6D
  STA $000A                             ; $CE16: 8D 0A 00
  LDY #$2E                              ; $CE19: A0 2E
  JSR $EE07                             ; $CE1B: 20 07 EE
; --- Data Region ---
  .byte $06,$A0                           ; $CE1E: 06 A0
Loc_CE20:
; --- Code Region ---
  LDY #$00                              ; $CE20: A0 00
Loc_CE22:
  LDA $04DB,Y                           ; $CE22: B9 DB 04
  CMP #$FF                              ; $CE25: C9 FF
  BEQ $CE36                             ; $CE27: F0 0D
  SEC                                   ; $CE29: 38
  SBC #$01                              ; $CE2A: E9 01
  STA $04DB,Y                           ; $CE2C: 99 DB 04
  BNE $CE36                             ; $CE2F: D0 05
  LDA #$FF                              ; $CE31: A9 FF
  STA $04D8,Y                           ; $CE33: 99 D8 04
Loc_CE36:
  CPY #$04                              ; $CE36: C0 04
  BEQ $CE3F                             ; $CE38: F0 05
  LDY #$04                              ; $CE3A: A0 04
  JMP $CE22                             ; $CE3C: 4C 22 CE
Loc_CE3F:
  RTS                                   ; $CE3F: 60
Loc_CE40:
  LDY #$00                              ; $CE40: A0 00
Loc_CE42:
  LDA $0650,Y                           ; $CE42: B9 50 06
  BEQ $CE5A                             ; $CE45: F0 13
  AND $0010                             ; $CE47: 2D 10 00
  BEQ $CE5A                             ; $CE4A: F0 0E
  SEC                                   ; $CE4C: 38
  SBC $0011                             ; $CE4D: ED 11 00
  STA $0650,Y                           ; $CE50: 99 50 06
  LDA $0011                             ; $CE53: AD 11 00
  CMP #$10                              ; $CE56: C9 10
  BEQ $CE60                             ; $CE58: F0 06
Loc_CE5A:
  INY                                   ; $CE5A: C8
  CPY #$14                              ; $CE5B: C0 14
  BCC $CE42                             ; $CE5D: 90 E3
  RTS                                   ; $CE5F: 60
Loc_CE60:
  TYA                                   ; $CE60: 98
  PHA                                   ; $CE61: 48
  LDA $0664,Y                           ; $CE62: B9 64 06
  JSR $F2D7                             ; $CE65: 20 D7 F2
Loc_CE68:
  JSR $E87A                             ; $CE68: 20 7A E8
  CMP #$47                              ; $CE6B: C9 47
  BCS $CE68                             ; $CE6D: B0 F9
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
  BPL $CE8C                             ; $CE85: 10 05
  LDA #$00                              ; $CE87: A9 00
  STA $0002                             ; $CE89: 8D 02 00
Loc_CE8C:
  STA ($00),Y                           ; $CE8C: 91 00
  DEY                                   ; $CE8E: 88
  LDA $0002                             ; $CE8F: AD 02 00
  STA ($00),Y                           ; $CE92: 91 00
  LDA $0002                             ; $CE94: AD 02 00
  CLC                                   ; $CE97: 18
  ADC $000B                             ; $CE98: 6D 0B 00
  STA $000B                             ; $CE9B: 8D 0B 00
  LDA #$00                              ; $CE9E: A9 00
  ADC $000C                             ; $CEA0: 6D 0C 00
  STA $000C                             ; $CEA3: 8D 0C 00
  PLA                                   ; $CEA6: 68
  TAY                                   ; $CEA7: A8
  JMP $CE5A                             ; $CEA8: 4C 5A CE
Loc_CEAB:
  LDA $066E                             ; $CEAB: AD 6E 06
  STA $052B                             ; $CEAE: 8D 2B 05
  LDA $050F                             ; $CEB1: AD 0F 05
  CMP #$03                              ; $CEB4: C9 03
  BNE $CED5                             ; $CEB6: D0 1D
  JSR $CF92                             ; $CEB8: 20 92 CF
  LDA #$00                              ; $CEBB: A9 00
  STA $0509                             ; $CEBD: 8D 09 05
  LDA $0507                             ; $CEC0: AD 07 05
  AND #$0F                              ; $CEC3: 29 0F
  STA $042C                             ; $CEC5: 8D 2C 04
  LDA #$03                              ; $CEC8: A9 03
  STA $00A4                             ; $CECA: 8D A4 00
  LDA #$B5                              ; $CECD: A9 B5
  STA $050A                             ; $CECF: 8D 0A 05
  JMP $CF00                             ; $CED2: 4C 00 CF
Loc_CED5:
  STA $6F44                             ; $CED5: 8D 44 6F
  LDA #$0A                              ; $CED8: A9 0A
  STA $0509                             ; $CEDA: 8D 09 05
  LDA $0507                             ; $CEDD: AD 07 05
  LSR                                   ; $CEE0: 4A
  LSR                                   ; $CEE1: 4A
  LSR                                   ; $CEE2: 4A
  LSR                                   ; $CEE3: 4A
  AND #$0F                              ; $CEE4: 29 0F
  STA $042C                             ; $CEE6: 8D 2C 04
  LDA #$04                              ; $CEE9: A9 04
  STA $00A4                             ; $CEEB: 8D A4 00
  LDA $0000                             ; $CEEE: AD 00 00
  BMI $CEFB                             ; $CEF1: 30 08
  LDA #$BE                              ; $CEF3: A9 BE
  STA $050A                             ; $CEF5: 8D 0A 05
  JMP $CF00                             ; $CEF8: 4C 00 CF
Loc_CEFB:
  LDA #$BF                              ; $CEFB: A9 BF
  STA $050A                             ; $CEFD: 8D 0A 05
Loc_CF00:
  LDA #$01                              ; $CF00: A9 01
  STA $0514                             ; $CF02: 8D 14 05
  RTS                                   ; $CF05: 60
Loc_CF06:
  LDA $0664                             ; $CF06: AD 64 06
  STA $052B                             ; $CF09: 8D 2B 05
  LDA $0507                             ; $CF0C: AD 07 05
  AND #$0F                              ; $CF0F: 29 0F
  JSR $F368                             ; $CF11: 20 68 F3
  LDY #$03                              ; $CF14: A0 03
  LDA ($00),Y                           ; $CF16: B1 00
  CMP #$03                              ; $CF18: C9 03
  BNE $CF40                             ; $CF1A: D0 24
  LDA $050F                             ; $CF1C: AD 0F 05
  STA $6F44                             ; $CF1F: 8D 44 6F
  LDA #$0A                              ; $CF22: A9 0A
  STA $0509                             ; $CF24: 8D 09 05
  LDA $0507                             ; $CF27: AD 07 05
  LSR                                   ; $CF2A: 4A
  LSR                                   ; $CF2B: 4A
  LSR                                   ; $CF2C: 4A
  LSR                                   ; $CF2D: 4A
  AND #$0F                              ; $CF2E: 29 0F
  STA $042C                             ; $CF30: 8D 2C 04
  LDA #$03                              ; $CF33: A9 03
  STA $00A4                             ; $CF35: 8D A4 00
  LDA #$B5                              ; $CF38: A9 B5
  STA $050A                             ; $CF3A: 8D 0A 05
  JMP $CF5A                             ; $CF3D: 4C 5A CF
Loc_CF40:
  JSR $CF92                             ; $CF40: 20 92 CF
  LDA #$00                              ; $CF43: A9 00
  STA $0509                             ; $CF45: 8D 09 05
  LDA $0507                             ; $CF48: AD 07 05
  AND #$0F                              ; $CF4B: 29 0F
  STA $042C                             ; $CF4D: 8D 2C 04
  LDA #$04                              ; $CF50: A9 04
  STA $00A4                             ; $CF52: 8D A4 00
  LDA #$BF                              ; $CF55: A9 BF
  STA $050A                             ; $CF57: 8D 0A 05
Loc_CF5A:
  LDA #$00                              ; $CF5A: A9 00
  STA $0514                             ; $CF5C: 8D 14 05
  RTS                                   ; $CF5F: 60
Loc_CF60:
  LDY #$00                              ; $CF60: A0 00
Loc_CF62:
  LDA $0664,Y                           ; $CF62: B9 64 06
  CMP #$6D                              ; $CF65: C9 6D
  BEQ $CF6F                             ; $CF67: F0 06
  INY                                   ; $CF69: C8
  CPY #$14                              ; $CF6A: C0 14
  BCC $CF62                             ; $CF6C: 90 F4
  RTS                                   ; $CF6E: 60
Loc_CF6F:
  STY $052F                             ; $CF6F: 8C 2F 05
  LDA #$6D                              ; $CF72: A9 6D
  JSR $F2D7                             ; $CF74: 20 D7 F2
  LDY #$0B                              ; $CF77: A0 0B
  LDA ($00),Y                           ; $CF79: B1 00
  AND #$03                              ; $CF7B: 29 03
  CMP #$03                              ; $CF7D: C9 03
  BEQ $CF91                             ; $CF7F: F0 10
  LDY #$0B                              ; $CF81: A0 0B
  LDA ($00),Y                           ; $CF83: B1 00
  AND #$F0                              ; $CF85: 29 F0
  STA $052C                             ; $CF87: 8D 2C 05
  LDY #$01                              ; $CF8A: A0 01
  LDA ($00),Y                           ; $CF8C: B1 00
  STA $052E                             ; $CF8E: 8D 2E 05
Loc_CF91:
  RTS                                   ; $CF91: 60
Loc_CF92:
  LDA $0507                             ; $CF92: AD 07 05
  AND #$0F                              ; $CF95: 29 0F
  JSR $F368                             ; $CF97: 20 68 F3
  LDY #$03                              ; $CF9A: A0 03
  LDA ($00),Y                           ; $CF9C: B1 00
  STA $6F44                             ; $CF9E: 8D 44 6F
  RTS                                   ; $CFA1: 60
Loc_CFA2:
  LDA $008F                             ; $CFA2: AD 8F 00
  BNE $CFBA                             ; $CFA5: D0 13
  LDA $04C8                             ; $CFA7: AD C8 04
  BNE $CFBA                             ; $CFAA: D0 0E
  LDA $0500                             ; $CFAC: AD 00 05
  CMP #$0C                              ; $CFAF: C9 0C
  BCS $CFBA                             ; $CFB1: B0 07
  LDA $005E                             ; $CFB3: AD 5E 00
  AND #$20                              ; $CFB6: 29 20
  BNE $CFBB                             ; $CFB8: D0 01
Loc_CFBA:
  RTS                                   ; $CFBA: 60
Loc_CFBB:
  LDA #$20                              ; $CFBB: A9 20
  STA $000A                             ; $CFBD: 8D 0A 00
  LDA #$B0                              ; $CFC0: A9 B0
  STA $000C                             ; $CFC2: 8D 0C 00
  LDA #$3C                              ; $CFC5: A9 3C
  STA $0000                             ; $CFC7: 8D 00 00
  LDA #$D1                              ; $CFCA: A9 D1
  STA $0001                             ; $CFCC: 8D 01 00
  LDA #$00                              ; $CFCF: A9 00
  STA $0002                             ; $CFD1: 8D 02 00
  JSR $F1AD                             ; $CFD4: 20 AD F1
  LDA #$5D                              ; $CFD7: A9 5D
  STA $0000                             ; $CFD9: 8D 00 00
  LDA #$D1                              ; $CFDC: A9 D1
  STA $0001                             ; $CFDE: 8D 01 00
  LDA $005E                             ; $CFE1: AD 5E 00
  AND #$40                              ; $CFE4: 29 40
  BNE $CFF2                             ; $CFE6: D0 0A
  LDA #$6E                              ; $CFE8: A9 6E
  STA $0000                             ; $CFEA: 8D 00 00
  LDA #$D1                              ; $CFED: A9 D1
  STA $0001                             ; $CFEF: 8D 01 00
Loc_CFF2:
  JSR $F1AD                             ; $CFF2: 20 AD F1
  LDA $0505                             ; $CFF5: AD 05 05
  STA $0001                             ; $CFF8: 8D 01 00
  LDA #$00                              ; $CFFB: A9 00
  STA $0002                             ; $CFFD: 8D 02 00
  STA $0003                             ; $D000: 8D 03 00
  JSR $E9BA                             ; $D003: 20 BA E9
  LDA $0007                             ; $D006: AD 07 00
  LSR                                   ; $D009: 4A
  LSR                                   ; $D00A: 4A
  LSR                                   ; $D00B: 4A
  LSR                                   ; $D00C: 4A
  BEQ $D01C                             ; $D00D: F0 0D
  LDY #$20                              ; $D00F: A0 20
  STY $000A                             ; $D011: 8C 0A 00
  LDY #$E0                              ; $D014: A0 E0
  STY $000C                             ; $D016: 8C 0C 00
  JSR $D126                             ; $D019: 20 26 D1
Loc_D01C:
  LDA $0007                             ; $D01C: AD 07 00
  AND #$0F                              ; $D01F: 29 0F
  LDY #$20                              ; $D021: A0 20
  STY $000A                             ; $D023: 8C 0A 00
  LDY #$E8                              ; $D026: A0 E8
  STY $000C                             ; $D028: 8C 0C 00
  JSR $D126                             ; $D02B: 20 26 D1
  LDA $0506                             ; $D02E: AD 06 05
  STA $0001                             ; $D031: 8D 01 00
  LDA #$00                              ; $D034: A9 00
  STA $0002                             ; $D036: 8D 02 00
  STA $0003                             ; $D039: 8D 03 00
  JSR $E9BA                             ; $D03C: 20 BA E9
  LDA $0007                             ; $D03F: AD 07 00
  LSR                                   ; $D042: 4A
  LSR                                   ; $D043: 4A
  LSR                                   ; $D044: 4A
  LSR                                   ; $D045: 4A
  BEQ $D055                             ; $D046: F0 0D
  LDY #$10                              ; $D048: A0 10
  STY $000A                             ; $D04A: 8C 0A 00
  LDY #$D0                              ; $D04D: A0 D0
  STY $000C                             ; $D04F: 8C 0C 00
  JSR $D126                             ; $D052: 20 26 D1
Loc_D055:
  LDA $0007                             ; $D055: AD 07 00
  AND #$0F                              ; $D058: 29 0F
  LDY #$10                              ; $D05A: A0 10
  STY $000A                             ; $D05C: 8C 0A 00
  LDY #$D8                              ; $D05F: A0 D8
  STY $000C                             ; $D061: 8C 0C 00
  JSR $D126                             ; $D064: 20 26 D1
  LDA $005E                             ; $D067: AD 5E 00
  AND #$40                              ; $D06A: 29 40
  BNE $D098                             ; $D06C: D0 2A
  LDX #$00                              ; $D06E: A2 00
  LDA $0504                             ; $D070: AD 04 05
  BPL $D077                             ; $D073: 10 02
  LDX #$02                              ; $D075: A2 02
Loc_D077:
  LDA $0522,X                           ; $D077: BD 22 05
  STA $0001                             ; $D07A: 8D 01 00
  LDA $0523,X                           ; $D07D: BD 23 05
  STA $0002                             ; $D080: 8D 02 00
  LDA #$00                              ; $D083: A9 00
  STA $0003                             ; $D085: 8D 03 00
  JSR $E9BA                             ; $D088: 20 BA E9
  LDA #$40                              ; $D08B: A9 40
  STA $0010                             ; $D08D: 8D 10 00
  LDA #$00                              ; $D090: A9 00
  STA $0011                             ; $D092: 8D 11 00
  JMP $D0BF                             ; $D095: 4C BF D0
Loc_D098:
  LDX #$00                              ; $D098: A2 00
  LDA $0504                             ; $D09A: AD 04 05
  BPL $D0A1                             ; $D09D: 10 02
  LDX #$02                              ; $D09F: A2 02
Loc_D0A1:
  LDA $0526,X                           ; $D0A1: BD 26 05
  STA $0001                             ; $D0A4: 8D 01 00
  LDA $0527,X                           ; $D0A7: BD 27 05
  STA $0002                             ; $D0AA: 8D 02 00
  LDA #$00                              ; $D0AD: A9 00
  STA $0003                             ; $D0AF: 8D 03 00
  JSR $E9BA                             ; $D0B2: 20 BA E9
  LDA #$40                              ; $D0B5: A9 40
  STA $0010                             ; $D0B7: 8D 10 00
  LDA #$00                              ; $D0BA: A9 00
  STA $0011                             ; $D0BC: 8D 11 00
Loc_D0BF:
  LDA $0008                             ; $D0BF: AD 08 00
  LSR                                   ; $D0C2: 4A
  LSR                                   ; $D0C3: 4A
  LSR                                   ; $D0C4: 4A
  LSR                                   ; $D0C5: 4A
  BEQ $D0D9                             ; $D0C6: F0 11
  INC $0011                             ; $D0C8: EE 11 00
  LDY $0010                             ; $D0CB: AC 10 00
  STY $000A                             ; $D0CE: 8C 0A 00
  LDY #$D0                              ; $D0D1: A0 D0
  STY $000C                             ; $D0D3: 8C 0C 00
  JSR $D126                             ; $D0D6: 20 26 D1
Loc_D0D9:
  LDA $0008                             ; $D0D9: AD 08 00
  AND #$0F                              ; $D0DC: 29 0F
  BNE $D0E5                             ; $D0DE: D0 05
  LDY $0011                             ; $D0E0: AC 11 00
  BEQ $D0F6                             ; $D0E3: F0 11
Loc_D0E5:
  INC $0011                             ; $D0E5: EE 11 00
  LDY $0010                             ; $D0E8: AC 10 00
  STY $000A                             ; $D0EB: 8C 0A 00
  LDY #$D8                              ; $D0EE: A0 D8
  STY $000C                             ; $D0F0: 8C 0C 00
  JSR $D126                             ; $D0F3: 20 26 D1
Loc_D0F6:
  LDA $0007                             ; $D0F6: AD 07 00
  LSR                                   ; $D0F9: 4A
  LSR                                   ; $D0FA: 4A
  LSR                                   ; $D0FB: 4A
  LSR                                   ; $D0FC: 4A
  BNE $D104                             ; $D0FD: D0 05
  LDY $0011                             ; $D0FF: AC 11 00
  BEQ $D112                             ; $D102: F0 0E
Loc_D104:
  LDY $0010                             ; $D104: AC 10 00
  STY $000A                             ; $D107: 8C 0A 00
  LDY #$E0                              ; $D10A: A0 E0
  STY $000C                             ; $D10C: 8C 0C 00
  JSR $D126                             ; $D10F: 20 26 D1
Loc_D112:
  LDA $0007                             ; $D112: AD 07 00
  AND #$0F                              ; $D115: 29 0F
  LDY $0010                             ; $D117: AC 10 00
  STY $000A                             ; $D11A: 8C 0A 00
  LDY #$E8                              ; $D11D: A0 E8
  STY $000C                             ; $D11F: 8C 0C 00
  JSR $D126                             ; $D122: 20 26 D1
  RTS                                   ; $D125: 60
Loc_D126:
  ASL                                   ; $D126: 0A
  TAY                                   ; $D127: A8
  LDA $D17F,Y                           ; $D128: B9 7F D1
  STA $0000                             ; $D12B: 8D 00 00
  LDA $D180,Y                           ; $D12E: B9 80 D1
  STA $0001                             ; $D131: 8D 01 00
  LDA #$00                              ; $D134: A9 00
  STA $0002                             ; $D136: 8D 02 00
  JMP $F1AD                             ; $D139: 4C AD F1
; --- Data Region ---
  .byte $00,$40,$00,$20,$00               ; $D13C: 00 40 00 20 00
Loc_D141:
; --- Code Region ---
  EOR ($00,X)                           ; $D141: 41 00
  PLP                                   ; $D143: 28
  PHP                                   ; $D144: 08
  BVC $D147                             ; $D145: 50 00
Loc_D147:
  JSR $5108                             ; $D147: 20 08 51
  BRK                                   ; $D14A: 00
  PLP                                   ; $D14B: 28
  BEQ $D1AE                             ; $D14C: F0 60
  BRK                                   ; $D14E: 00
  BMI $D141                             ; $D14F: 30 F0
Loc_D151:
  ADC ($00,X)                           ; $D151: 61 00
  SEC                                   ; $D153: 38
  SED                                   ; $D154: F8
  BVS $D157                             ; $D155: 70 00
Loc_D157:
  BMI $D151                             ; $D157: 30 F8
  ADC ($00),Y                           ; $D159: 71 00
  SEC                                   ; $D15B: 38
  NOP #$10                              ; $D15C: 80 10
  NOP $00                               ; $D15E: 44 00
  JSR $4510                             ; $D160: 20 10 45
  BRK                                   ; $D163: 00
  PLP                                   ; $D164: 28
  CLC                                   ; $D165: 18
  NOP $00,X                             ; $D166: 54 00
  JSR $5518                             ; $D168: 20 18 55
  BRK                                   ; $D16B: 00
  PLP                                   ; $D16C: 28
  NOP #$10                              ; $D16D: 80 10
  JAM                                   ; $D16F: 42
  BRK                                   ; $D170: 00
  JSR $4310                             ; $D171: 20 10 43
  BRK                                   ; $D174: 00
  PLP                                   ; $D175: 28
  CLC                                   ; $D176: 18
  JAM                                   ; $D177: 52
  BRK                                   ; $D178: 00
  JSR $5318                             ; $D179: 20 18 53
  BRK                                   ; $D17C: 00
  PLP                                   ; $D17D: 28
  NOP #$93                              ; $D17E: 80 93
  CMP ($9C),Y                           ; $D180: D1 9C
  CMP ($A5),Y                           ; $D182: D1 A5
  CMP ($AE),Y                           ; $D184: D1 AE
  CMP ($B7),Y                           ; $D186: D1 B7
  CMP ($C0),Y                           ; $D188: D1 C0
  CMP ($C9),Y                           ; $D18A: D1 C9
  CMP ($D2),Y                           ; $D18C: D1 D2
  CMP ($DB),Y                           ; $D18E: D1 DB
  CMP ($E4),Y                           ; $D190: D1 E4
  CMP ($00),Y                           ; $D192: D1 00
  LSR $00                               ; $D194: 46 00
  BRK                                   ; $D196: 00
  PHP                                   ; $D197: 08
  LSR $00,X                             ; $D198: 56 00
  BRK                                   ; $D19A: 00
  NOP #$00                              ; $D19B: 80 00
  SRE $00                               ; $D19D: 47 00
  BRK                                   ; $D19F: 00
  PHP                                   ; $D1A0: 08
  SRE $00,X                             ; $D1A1: 57 00
  BRK                                   ; $D1A3: 00
  NOP #$00                              ; $D1A4: 80 00
  PHA                                   ; $D1A6: 48
  BRK                                   ; $D1A7: 00
  BRK                                   ; $D1A8: 00
  PHP                                   ; $D1A9: 08
  CLI                                   ; $D1AA: 58
  BRK                                   ; $D1AB: 00
  BRK                                   ; $D1AC: 00
  NOP #$00                              ; $D1AD: 80 00
  EOR #$00                              ; $D1AF: 49 00
  BRK                                   ; $D1B1: 00
  PHP                                   ; $D1B2: 08
  EOR $0000,Y                           ; $D1B3: 59 00 00
  NOP #$00                              ; $D1B6: 80 00
  LSR                                   ; $D1B8: 4A
  BRK                                   ; $D1B9: 00
  BRK                                   ; $D1BA: 00
  PHP                                   ; $D1BB: 08
  NOP                                   ; $D1BC: 5A
  BRK                                   ; $D1BD: 00
  BRK                                   ; $D1BE: 00
  NOP #$00                              ; $D1BF: 80 00
  ALR #$00                              ; $D1C1: 4B 00
  BRK                                   ; $D1C3: 00
  PHP                                   ; $D1C4: 08
  SRE $0000,Y                           ; $D1C5: 5B 00 00
  NOP #$00                              ; $D1C8: 80 00
  JMP $0000                             ; $D1CA: 4C 00 00
; --- Data Region ---
  .byte $08,$5C,$00,$00,$80,$00,$4D,$00,$00,$08,$5D,$00,$00,$80,$00,$4E; $D1CD: 08 5C 00 00 80 00 4D 00 00 08 5D 00 00 80 00 4E
  .byte $00,$00,$08,$5E,$00,$00,$80,$00,$4F,$00,$00,$08,$5F,$00,$00,$80; $D1DD: 00 00 08 5E 00 00 80 00 4F 00 00 08 5F 00 00 80
Loc_D1ED:
; --- Code Region ---
  LDA $008F                             ; $D1ED: AD 8F 00
  BNE $D1F9                             ; $D1F0: D0 07
  LDA $0500                             ; $D1F2: AD 00 05
  CMP #$0C                              ; $D1F5: C9 0C
  BCC $D1FA                             ; $D1F7: 90 01
Loc_D1F9:
  RTS                                   ; $D1F9: 60
; --- Data Region ---
  .byte $20,$F5,$D2,$AD,$61,$00,$C9,$07,$F0,$F5,$A0,$31,$20,$5F,$F2,$AD; $D1FA: 20 F5 D2 AD 61 00 C9 07 F0 F5 A0 31 20 5F F2 AD
  .byte $0E,$05,$0A,$0A,$A8,$B9,$58,$9D,$8D,$0A,$00,$B9,$59,$9D,$8D,$0B; $D20A: 0E 05 0A 0A A8 B9 58 9D 8D 0A 00 B9 59 9D 8D 0B
  .byte $00,$B9,$5A,$9D,$8D,$0C,$00,$B9,$5B,$9D,$8D,$0D,$00,$20,$37,$D3; $D21A: 00 B9 5A 9D 8D 0C 00 B9 5B 9D 8D 0D 00 20 37 D3
  .byte $90,$21,$A9,$00,$8D,$02,$00,$A9,$15,$8D,$00,$00,$A9,$D3,$8D,$01; $D22A: 90 21 A9 00 8D 02 00 A9 15 8D 00 00 A9 D3 8D 01
  .byte $00,$A9,$00,$8D,$02,$00,$A9,$00,$8D,$03,$00,$A9,$9C,$8D,$04,$00; $D23A: 00 A9 00 8D 02 00 A9 00 8D 03 00 A9 9C 8D 04 00
  .byte $20,$9C,$F0                       ; $D24A: 20 9C F0
Loc_D24D:
; --- Code Region ---
  LDY #$31                              ; $D24D: A0 31
  JSR $F25F                             ; $D24F: 20 5F F2
  LDA $050E                             ; $D252: AD 0E 05
  ASL                                   ; $D255: 0A
  CLC                                   ; $D256: 18
  ADC $050E                             ; $D257: 6D 0E 05
  ASL                                   ; $D25A: 0A
  PHA                                   ; $D25B: 48
  TAY                                   ; $D25C: A8
  LDA $9BA4,Y                           ; $D25D: B9 A4 9B
  BMI $D26E                             ; $D260: 30 0C
  STA $000C                             ; $D262: 8D 0C 00
  LDA $9BA5,Y                           ; $D265: B9 A5 9B
  STA $000A                             ; $D268: 8D 0A 00
  JSR $D296                             ; $D26B: 20 96 D2
Loc_D26E:
  PLA                                   ; $D26E: 68
  PHA                                   ; $D26F: 48
  TAY                                   ; $D270: A8
  LDA $9BA6,Y                           ; $D271: B9 A6 9B
  BMI $D282                             ; $D274: 30 0C
  STA $000C                             ; $D276: 8D 0C 00
  LDA $9BA7,Y                           ; $D279: B9 A7 9B
  STA $000A                             ; $D27C: 8D 0A 00
  JSR $D296                             ; $D27F: 20 96 D2
Loc_D282:
  PLA                                   ; $D282: 68
  TAY                                   ; $D283: A8
  LDA $9BA8,Y                           ; $D284: B9 A8 9B
  BMI $D295                             ; $D287: 30 0C
  STA $000C                             ; $D289: 8D 0C 00
  LDA $9BA9,Y                           ; $D28C: B9 A9 9B
  STA $000A                             ; $D28F: 8D 0A 00
  JSR $D296                             ; $D292: 20 96 D2
Loc_D295:
  RTS                                   ; $D295: 60
Loc_D296:
  LDA #$00                              ; $D296: A9 00
  STA $000B                             ; $D298: 8D 0B 00
  STA $000D                             ; $D29B: 8D 0D 00
  ASL $000A                             ; $D29E: 0E 0A 00
  ROL $000B                             ; $D2A1: 2E 0B 00
  ASL $000A                             ; $D2A4: 0E 0A 00
  ROL $000B                             ; $D2A7: 2E 0B 00
  ASL $000A                             ; $D2AA: 0E 0A 00
  ROL $000B                             ; $D2AD: 2E 0B 00
  ASL $000A                             ; $D2B0: 0E 0A 00
  ROL $000B                             ; $D2B3: 2E 0B 00
  ASL $000C                             ; $D2B6: 0E 0C 00
  ROL $000D                             ; $D2B9: 2E 0D 00
  ASL $000C                             ; $D2BC: 0E 0C 00
  ROL $000D                             ; $D2BF: 2E 0D 00
  ASL $000C                             ; $D2C2: 0E 0C 00
  ROL $000D                             ; $D2C5: 2E 0D 00
  ASL $000C                             ; $D2C8: 0E 0C 00
  ROL $000D                             ; $D2CB: 2E 0D 00
  JSR $D337                             ; $D2CE: 20 37 D3
  BCC $D2F4                             ; $D2D1: 90 21
  LDA #$00                              ; $D2D3: A9 00
  STA $0002                             ; $D2D5: 8D 02 00
  LDA #$26                              ; $D2D8: A9 26
  STA $0000                             ; $D2DA: 8D 00 00
  LDA #$D3                              ; $D2DD: A9 D3
  STA $0001                             ; $D2DF: 8D 01 00
  LDA #$00                              ; $D2E2: A9 00
  STA $0002                             ; $D2E4: 8D 02 00
  LDA #$00                              ; $D2E7: A9 00
  STA $0003                             ; $D2E9: 8D 03 00
  LDA #$9C                              ; $D2EC: A9 9C
  STA $0004                             ; $D2EE: 8D 04 00
  JMP $F09C                             ; $D2F1: 4C 9C F0
Loc_D2F4:
  RTS                                   ; $D2F4: 60
Loc_D2F5:
  LDX #$88                              ; $D2F5: A2 88
  LDA $005E                             ; $D2F7: AD 5E 00
  AND #$10                              ; $D2FA: 29 10
  BEQ $D300                             ; $D2FC: F0 02
  LDX #$8B                              ; $D2FE: A2 8B
Loc_D300:
  STX $00B2                             ; $D300: 8E B2 00
  STX $00D6                             ; $D303: 8E D6 00
  LDA $04C8                             ; $D306: AD C8 04
  BNE $D314                             ; $D309: D0 09
  STX $00C2                             ; $D30B: 8E C2 00
  STX $00C6                             ; $D30E: 8E C6 00
  STX $00D2                             ; $D311: 8E D2 00
Loc_D314:
  RTS                                   ; $D314: 60
; --- Data Region ---
  .byte $00,$02,$01,$00,$00,$03,$01,$08,$08,$0E,$01,$00,$08,$0F,$01,$08; $D315: 00 02 01 00 00 03 01 08 08 0E 01 00 08 0F 01 08
  .byte $80,$00,$3C,$01,$00,$00,$3D,$01,$08,$08,$3E,$01,$00,$08,$3F,$01; $D325: 80 00 3C 01 00 00 3D 01 08 08 3E 01 00 08 3F 01
  .byte $08,$80                           ; $D335: 08 80
Loc_D337:
; --- Code Region ---
  LDA $000A                             ; $D337: AD 0A 00
  STA $0000                             ; $D33A: 8D 00 00
  LDA $000B                             ; $D33D: AD 0B 00
  STA $0001                             ; $D340: 8D 01 00
  LDA $000C                             ; $D343: AD 0C 00
  STA $0002                             ; $D346: 8D 02 00
  LDA $000D                             ; $D349: AD 0D 00
  STA $0003                             ; $D34C: 8D 03 00
  LSR $0001                             ; $D34F: 4E 01 00
  ROR $0000                             ; $D352: 6E 00 00
  LSR $0000                             ; $D355: 4E 00 00
  LSR $0000                             ; $D358: 4E 00 00
  LSR $0000                             ; $D35B: 4E 00 00
  LSR $0003                             ; $D35E: 4E 03 00
  ROR $0002                             ; $D361: 6E 02 00
  LSR $0002                             ; $D364: 4E 02 00
  LSR $0002                             ; $D367: 4E 02 00
  LSR $0002                             ; $D36A: 4E 02 00
  LDY #$00                              ; $D36D: A0 00
Loc_D36F:
  LDA $0600,Y                           ; $D36F: B9 00 06
  CMP $0002                             ; $D372: CD 02 00
  BNE $D38A                             ; $D375: D0 13
  LDA $0614,Y                           ; $D377: B9 14 06
  CMP $0000                             ; $D37A: CD 00 00
  BNE $D38A                             ; $D37D: D0 0B
  LDA $005E                             ; $D37F: AD 5E 00
  AND #$40                              ; $D382: 29 40
  BNE $D388                             ; $D384: D0 02
  CLC                                   ; $D386: 18
  RTS                                   ; $D387: 60
Loc_D388:
  SEC                                   ; $D388: 38
  RTS                                   ; $D389: 60
Loc_D38A:
  INY                                   ; $D38A: C8
  CPY #$14                              ; $D38B: C0 14
  BCC $D36F                             ; $D38D: 90 E0
  RTS                                   ; $D38F: 60
Loc_D390:
  LDA $042C                             ; $D390: AD 2C 04
  JSR $F2D7                             ; $D393: 20 D7 F2
  LDY #$0B                              ; $D396: A0 0B
  LDA ($00),Y                           ; $D398: B1 00
  LSR                                   ; $D39A: 4A
  LSR                                   ; $D39B: 4A
  LSR                                   ; $D39C: 4A
  LSR                                   ; $D39D: 4A
  CMP #$03                              ; $D39E: C9 03
  BNE $D3A7                             ; $D3A0: D0 05
  LDY #$00                              ; $D3A2: A0 00
  JMP $D3C8                             ; $D3A4: 4C C8 D3
Loc_D3A7:
  CMP #$04                              ; $D3A7: C9 04
  BNE $D3B0                             ; $D3A9: D0 05
  LDY #$0B                              ; $D3AB: A0 0B
  JMP $D3C8                             ; $D3AD: 4C C8 D3
Loc_D3B0:
  CMP #$05                              ; $D3B0: C9 05
  BNE $D3B9                             ; $D3B2: D0 05
  LDY #$11                              ; $D3B4: A0 11
  JMP $D3C8                             ; $D3B6: 4C C8 D3
Loc_D3B9:
  CMP #$06                              ; $D3B9: C9 06
  BNE $D3C2                             ; $D3BB: D0 05
  LDY #$14                              ; $D3BD: A0 14
  JMP $D3C8                             ; $D3BF: 4C C8 D3
Loc_D3C2:
  LDA #$FF                              ; $D3C2: A9 FF
  STA $042D                             ; $D3C4: 8D 2D 04
Loc_D3C7:
  RTS                                   ; $D3C7: 60
Loc_D3C8:
  LDA $D3D8,Y                           ; $D3C8: B9 D8 D3
  CMP #$FF                              ; $D3CB: C9 FF
  BEQ $D3C2                             ; $D3CD: F0 F3
  CMP $042C                             ; $D3CF: CD 2C 04
  BEQ $D3C7                             ; $D3D2: F0 F3
  INY                                   ; $D3D4: C8
  JMP $D3C8                             ; $D3D5: 4C C8 D3
; --- Data Region ---
  .byte $A1,$63,$A7,$16,$C4,$DB,$EA,$6B,$CE,$EB,$B7,$18,$37,$70,$D5,$6E; $D3D8: A1 63 A7 16 C4 DB EA 6B CE EB B7 18 37 70 D5 6E
  .byte $67,$C5,$56,$5D,$6D,$FF           ; $D3E8: 67 C5 56 5D 6D FF
Loc_D3EE:
; --- Code Region ---
  LDY #$0F                              ; $D3EE: A0 0F
  LDA #$FF                              ; $D3F0: A9 FF
Loc_D3F2:
  STA $0580,Y                           ; $D3F2: 99 80 05
  DEY                                   ; $D3F5: 88
  BPL $D3F2                             ; $D3F6: 10 FA
  LDY $050A                             ; $D3F8: AC 0A 05
  LDA $0664,Y                           ; $D3FB: B9 64 06
  STA $0010                             ; $D3FE: 8D 10 00
  JSR $F2D7                             ; $D401: 20 D7 F2
  LDY #$0B                              ; $D404: A0 0B
  LDA ($00),Y                           ; $D406: B1 00
  LSR                                   ; $D408: 4A
  LSR                                   ; $D409: 4A
  LSR                                   ; $D40A: 4A
  LSR                                   ; $D40B: 4A
  STA $0011                             ; $D40C: 8D 11 00
  LDA $0010                             ; $D40F: AD 10 00
  CMP #$A1                              ; $D412: C9 A1
  BEQ $D43E                             ; $D414: F0 28
  CMP #$63                              ; $D416: C9 63
  BEQ $D43E                             ; $D418: F0 24
  CMP #$A7                              ; $D41A: C9 A7
  BEQ $D43E                             ; $D41C: F0 20
  CMP #$16                              ; $D41E: C9 16
  BEQ $D43E                             ; $D420: F0 1C
  CMP #$C4                              ; $D422: C9 C4
  BEQ $D43E                             ; $D424: F0 18
  CMP #$DB                              ; $D426: C9 DB
  BEQ $D43E                             ; $D428: F0 14
  CMP #$EA                              ; $D42A: C9 EA
  BEQ $D43E                             ; $D42C: F0 10
  CMP #$6B                              ; $D42E: C9 6B
  BEQ $D43E                             ; $D430: F0 0C
  CMP #$CE                              ; $D432: C9 CE
  BEQ $D43E                             ; $D434: F0 08
  CMP #$EB                              ; $D436: C9 EB
  BEQ $D43E                             ; $D438: F0 04
  CMP #$B7                              ; $D43A: C9 B7
  BNE $D44A                             ; $D43C: D0 0C
Loc_D43E:
  LDA $0011                             ; $D43E: AD 11 00
  CMP #$03                              ; $D441: C9 03
  BCC $D44A                             ; $D443: 90 05
  LDY #$05                              ; $D445: A0 05
  JMP $D4E6                             ; $D447: 4C E6 D4
Loc_D44A:
  LDA $0010                             ; $D44A: AD 10 00
  CMP #$18                              ; $D44D: C9 18
  BEQ $D465                             ; $D44F: F0 14
  CMP #$37                              ; $D451: C9 37
  BEQ $D465                             ; $D453: F0 10
  CMP #$70                              ; $D455: C9 70
  BEQ $D465                             ; $D457: F0 0C
  CMP #$D5                              ; $D459: C9 D5
  BEQ $D465                             ; $D45B: F0 08
  CMP #$6E                              ; $D45D: C9 6E
  BEQ $D465                             ; $D45F: F0 04
  CMP #$67                              ; $D461: C9 67
  BNE $D47A                             ; $D463: D0 15
Loc_D465:
  LDA $0011                             ; $D465: AD 11 00
  CMP #$04                              ; $D468: C9 04
  BCC $D471                             ; $D46A: 90 05
  LDY #$06                              ; $D46C: A0 06
  JMP $D4E6                             ; $D46E: 4C E6 D4
Loc_D471:
  CMP #$03                              ; $D471: C9 03
  BCC $D47A                             ; $D473: 90 05
  LDY #$05                              ; $D475: A0 05
  JMP $D4E6                             ; $D477: 4C E6 D4
Loc_D47A:
  LDA $0010                             ; $D47A: AD 10 00
  CMP #$C5                              ; $D47D: C9 C5
  BEQ $D489                             ; $D47F: F0 08
  CMP #$56                              ; $D481: C9 56
  BEQ $D489                             ; $D483: F0 04
  CMP #$5D                              ; $D485: C9 5D
  BNE $D4A7                             ; $D487: D0 1E
Loc_D489:
  LDA $0011                             ; $D489: AD 11 00
  CMP #$05                              ; $D48C: C9 05
  BCC $D495                             ; $D48E: 90 05
  LDY #$07                              ; $D490: A0 07
  JMP $D4E6                             ; $D492: 4C E6 D4
Loc_D495:
  CMP #$04                              ; $D495: C9 04
  BCC $D49E                             ; $D497: 90 05
  LDY #$06                              ; $D499: A0 06
  JMP $D4E6                             ; $D49B: 4C E6 D4
Loc_D49E:
  CMP #$03                              ; $D49E: C9 03
  BCC $D4A7                             ; $D4A0: 90 05
  LDY #$05                              ; $D4A2: A0 05
  JMP $D4E6                             ; $D4A4: 4C E6 D4
Loc_D4A7:
  LDA $0010                             ; $D4A7: AD 10 00
  CMP #$6D                              ; $D4AA: C9 6D
  BNE $D4C6                             ; $D4AC: D0 18
  LDA $0011                             ; $D4AE: AD 11 00
  LDY #$08                              ; $D4B1: A0 08
  CMP #$06                              ; $D4B3: C9 06
  BCS $D4E6                             ; $D4B5: B0 2F
  DEY                                   ; $D4B7: 88
  CMP #$05                              ; $D4B8: C9 05
  BCS $D4E6                             ; $D4BA: B0 2A
  DEY                                   ; $D4BC: 88
  CMP #$04                              ; $D4BD: C9 04
  BCS $D4E6                             ; $D4BF: B0 25
  DEY                                   ; $D4C1: 88
  CMP #$03                              ; $D4C2: C9 03
  BCS $D4E6                             ; $D4C4: B0 20
Loc_D4C6:
  LDA $0010                             ; $D4C6: AD 10 00
  JSR $F2D7                             ; $D4C9: 20 D7 F2
  LDY #$02                              ; $D4CC: A0 02
  LDA ($00),Y                           ; $D4CE: B1 00
  LDY #$00                              ; $D4D0: A0 00
  CMP #$28                              ; $D4D2: C9 28
  BCC $D4E6                             ; $D4D4: 90 10
  INY                                   ; $D4D6: C8
  CMP #$3C                              ; $D4D7: C9 3C
  BCC $D4E6                             ; $D4D9: 90 0B
  INY                                   ; $D4DB: C8
  CMP #$4B                              ; $D4DC: C9 4B
  BCC $D4E6                             ; $D4DE: 90 06
  INY                                   ; $D4E0: C8
  CMP #$55                              ; $D4E1: C9 55
  BCC $D4E6                             ; $D4E3: 90 01
  INY                                   ; $D4E5: C8
Loc_D4E6:
  TYA                                   ; $D4E6: 98
  ASL                                   ; $D4E7: 0A
  TAY                                   ; $D4E8: A8
  LDA $D509,Y                           ; $D4E9: B9 09 D5
  STA $0000                             ; $D4EC: 8D 00 00
  LDA $D50A,Y                           ; $D4EF: B9 0A D5
  STA $0001                             ; $D4F2: 8D 01 00
  LDY #$00                              ; $D4F5: A0 00
Loc_D4F7:
  LDA ($00),Y                           ; $D4F7: B1 00
  CMP #$FF                              ; $D4F9: C9 FF
  BEQ $D504                             ; $D4FB: F0 07
  STA $0580,Y                           ; $D4FD: 99 80 05
  INY                                   ; $D500: C8
  JMP $D4F7                             ; $D501: 4C F7 D4
Loc_D504:
  DEY                                   ; $D504: 88
  STY $0542                             ; $D505: 8C 42 05
  RTS                                   ; $D508: 60
; --- Data Region ---
  .byte $1B,$D5,$1E,$D5,$23,$D5,$2A,$D5,$33,$D5,$3E,$D5,$4B,$D5,$5A,$D5; $D509: 1B D5 1E D5 23 D5 2A D5 33 D5 3E D5 4B D5 5A D5
  .byte $6A,$D5,$00,$01,$FF,$00,$01,$02,$03,$FF,$00,$01,$02,$03,$04,$05; $D519: 6A D5 00 01 FF 00 01 02 03 FF 00 01 02 03 04 05
  .byte $FF,$00,$01,$02,$03,$04,$05,$06,$07,$FF,$00,$01,$02,$03,$04,$05; $D529: FF 00 01 02 03 04 05 06 07 FF 00 01 02 03 04 05
  .byte $06,$07,$08,$09,$FF,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A; $D539: 06 07 08 09 FF 00 01 02 03 04 05 06 07 08 09 0A
  .byte $0B,$FF,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D; $D549: 0B FF 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D
  .byte $FF,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E; $D559: FF 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E
  .byte $FF,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E; $D569: FF 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E
  .byte $0F,$FF                           ; $D579: 0F FF
Loc_D57B:
; --- Code Region ---
  LDA $0500                             ; $D57B: AD 00 05
  CMP #$0C                              ; $D57E: C9 0C
  BCC $D583                             ; $D580: 90 01
  RTS                                   ; $D582: 60
; --- Data Region ---
  .byte $A9,$00,$8D,$00,$00,$AD,$08,$05,$30,$05,$AD,$00,$00,$10,$2C; $D583: A9 00 8D 00 00 AD 08 05 30 05 AD 00 00 10 2C
Loc_D592:
; --- Code Region ---
  LDA $0508                             ; $D592: AD 08 05
  ORA #$80                              ; $D595: 09 80
  STA $0508                             ; $D597: 8D 08 05
  LDA $008E                             ; $D59A: AD 8E 00
  CLC                                   ; $D59D: 18
  ADC #$02                              ; $D59E: 69 02
  BCS $D5B6                             ; $D5A0: B0 14
  STA $008E                             ; $D5A2: 8D 8E 00
  LDA $009C                             ; $D5A5: AD 9C 00
  AND #$BF                              ; $D5A8: 29 BF
  ORA #$80                              ; $D5AA: 09 80
  STA $009C                             ; $D5AC: 8D 9C 00
  LDA $008E                             ; $D5AF: AD 8E 00
  AND #$0E                              ; $D5B2: 29 0E
  BNE $D5BE                             ; $D5B4: D0 08
Loc_D5B6:
  LDA $0508                             ; $D5B6: AD 08 05
  AND #$7F                              ; $D5B9: 29 7F
  STA $0508                             ; $D5BB: 8D 08 05
Loc_D5BE:
  LDA $0508                             ; $D5BE: AD 08 05
  ASL                                   ; $D5C1: 0A
  BMI $D5CA                             ; $D5C2: 30 06
  LDA $0000                             ; $D5C4: AD 00 00
  ASL                                   ; $D5C7: 0A
  BPL $D5F6                             ; $D5C8: 10 2C
Loc_D5CA:
  LDA $0508                             ; $D5CA: AD 08 05
  ORA #$40                              ; $D5CD: 09 40
  STA $0508                             ; $D5CF: 8D 08 05
  LDA $008E                             ; $D5D2: AD 8E 00
  SEC                                   ; $D5D5: 38
  SBC #$02                              ; $D5D6: E9 02
  BCC $D5EE                             ; $D5D8: 90 14
  STA $008E                             ; $D5DA: 8D 8E 00
  LDA $009C                             ; $D5DD: AD 9C 00
  AND #$7F                              ; $D5E0: 29 7F
  ORA #$40                              ; $D5E2: 09 40
  STA $009C                             ; $D5E4: 8D 9C 00
  LDA $008E                             ; $D5E7: AD 8E 00
  AND #$0E                              ; $D5EA: 29 0E
  BNE $D5F6                             ; $D5EC: D0 08
Loc_D5EE:
  LDA $0508                             ; $D5EE: AD 08 05
  AND #$BF                              ; $D5F1: 29 BF
  STA $0508                             ; $D5F3: 8D 08 05
Loc_D5F6:
  LDA $0508                             ; $D5F6: AD 08 05
  ASL                                   ; $D5F9: 0A
  ASL                                   ; $D5FA: 0A
  BMI $D604                             ; $D5FB: 30 07
  LDA $0000                             ; $D5FD: AD 00 00
  AND #$10                              ; $D600: 29 10
  BEQ $D630                             ; $D602: F0 2C
Loc_D604:
  LDA $0508                             ; $D604: AD 08 05
  ORA #$20                              ; $D607: 09 20
  STA $0508                             ; $D609: 8D 08 05
  LDA $0090                             ; $D60C: AD 90 00
  SEC                                   ; $D60F: 38
  SBC #$02                              ; $D610: E9 02
  BCC $D628                             ; $D612: 90 14
  STA $0090                             ; $D614: 8D 90 00
  LDA $009C                             ; $D617: AD 9C 00
  AND #$DF                              ; $D61A: 29 DF
  ORA #$10                              ; $D61C: 09 10
  STA $009C                             ; $D61E: 8D 9C 00
  LDA $0090                             ; $D621: AD 90 00
  AND #$0E                              ; $D624: 29 0E
  BNE $D630                             ; $D626: D0 08
Loc_D628:
  LDA $0508                             ; $D628: AD 08 05
  AND #$DF                              ; $D62B: 29 DF
  STA $0508                             ; $D62D: 8D 08 05
Loc_D630:
  LDA $0508                             ; $D630: AD 08 05
  ASL                                   ; $D633: 0A
  ASL                                   ; $D634: 0A
  ASL                                   ; $D635: 0A
  BMI $D63F                             ; $D636: 30 07
  LDA $0000                             ; $D638: AD 00 00
  AND #$20                              ; $D63B: 29 20
  BEQ $D66D                             ; $D63D: F0 2E
Loc_D63F:
  LDA $0508                             ; $D63F: AD 08 05
  ORA #$10                              ; $D642: 09 10
  STA $0508                             ; $D644: 8D 08 05
  LDA $0090                             ; $D647: AD 90 00
  CLC                                   ; $D64A: 18
  ADC #$02                              ; $D64B: 69 02
  CMP #$90                              ; $D64D: C9 90
  BCS $D665                             ; $D64F: B0 14
  STA $0090                             ; $D651: 8D 90 00
  LDA $009C                             ; $D654: AD 9C 00
  AND #$EF                              ; $D657: 29 EF
  ORA #$20                              ; $D659: 09 20
  STA $009C                             ; $D65B: 8D 9C 00
  LDA $0090                             ; $D65E: AD 90 00
  AND #$0E                              ; $D661: 29 0E
  BNE $D66D                             ; $D663: D0 08
Loc_D665:
  LDA $0508                             ; $D665: AD 08 05
  AND #$EF                              ; $D668: 29 EF
  STA $0508                             ; $D66A: 8D 08 05
Loc_D66D:
  RTS                                   ; $D66D: 60
Loc_D66E:
  LDA #$00                              ; $D66E: A9 00
  STA $0514                             ; $D670: 8D 14 05
  LDA $0664                             ; $D673: AD 64 06
  STA $052B                             ; $D676: 8D 2B 05
  LDA $050F                             ; $D679: AD 0F 05
  CMP #$03                              ; $D67C: C9 03
  BEQ $D69C                             ; $D67E: F0 1C
  STA $6F44                             ; $D680: 8D 44 6F
  LDA $0507                             ; $D683: AD 07 05
  LSR                                   ; $D686: 4A
  LSR                                   ; $D687: 4A
  LSR                                   ; $D688: 4A
  LSR                                   ; $D689: 4A
  AND #$0F                              ; $D68A: 29 0F
  STA $042C                             ; $D68C: 8D 2C 04
  LDA #$03                              ; $D68F: A9 03
  STA $00A4                             ; $D691: 8D A4 00
  LDA #$50                              ; $D694: A9 50
  STA $050A                             ; $D696: 8D 0A 05
  JMP $D6C2                             ; $D699: 4C C2 D6
Loc_D69C:
  LDA $0507                             ; $D69C: AD 07 05
  AND #$0F                              ; $D69F: 29 0F
  JSR $F368                             ; $D6A1: 20 68 F3
  LDY #$03                              ; $D6A4: A0 03
  LDA ($00),Y                           ; $D6A6: B1 00
  STA $6F44                             ; $D6A8: 8D 44 6F
  LDA #$00                              ; $D6AB: A9 00
  STA $0509                             ; $D6AD: 8D 09 05
  LDA $0507                             ; $D6B0: AD 07 05
  AND #$0F                              ; $D6B3: 29 0F
  STA $042C                             ; $D6B5: 8D 2C 04
  LDA #$04                              ; $D6B8: A9 04
  STA $00A4                             ; $D6BA: 8D A4 00
  LDA #$51                              ; $D6BD: A9 51
  STA $050A                             ; $D6BF: 8D 0A 05
Loc_D6C2:
  LDA #$07                              ; $D6C2: A9 07
  STA $0500                             ; $D6C4: 8D 00 05
  LDA #$02                              ; $D6C7: A9 02
  STA $0501                             ; $D6C9: 8D 01 05
  RTS                                   ; $D6CC: 60
Loc_D6CD:
  LDY $0000                             ; $D6CD: AC 00 00
  LDA #$FF                              ; $D6D0: A9 FF
  STA $0600,Y                           ; $D6D2: 99 00 06
  STA $0614,Y                           ; $D6D5: 99 14 06
  STA $0628,Y                           ; $D6D8: 99 28 06
  STA $063C,Y                           ; $D6DB: 99 3C 06
  STA $0650,Y                           ; $D6DE: 99 50 06
  STA $0664,Y                           ; $D6E1: 99 64 06
  STA $6FA1,Y                           ; $D6E4: 99 A1 6F
  LDX #$00                              ; $D6E7: A2 00
  LDA $04D8                             ; $D6E9: AD D8 04
  CMP $0000                             ; $D6EC: CD 00 00
  BEQ $D6FC                             ; $D6EF: F0 0B
  LDX #$04                              ; $D6F1: A2 04
  LDA $04DC                             ; $D6F3: AD DC 04
  CMP $0000                             ; $D6F6: CD 00 00
  BEQ $D6FC                             ; $D6F9: F0 01
  RTS                                   ; $D6FB: 60
Loc_D6FC:
  TXA                                   ; $D6FC: 8A
  CLC                                   ; $D6FD: 18
  ADC #$04                              ; $D6FE: 69 04
  STA $0001                             ; $D700: 8D 01 00
  LDA #$FF                              ; $D703: A9 FF
Loc_D705:
  STA $04D8,X                           ; $D705: 9D D8 04
  INX                                   ; $D708: E8
  CPX $0001                             ; $D709: EC 01 00
  BCC $D705                             ; $D70C: 90 F7
  RTS                                   ; $D70E: 60
Loc_D70F:
  JSR $DB10                             ; $D70F: 20 10 DB
  JSR $DB62                             ; $D712: 20 62 DB
  JSR $DBB4                             ; $D715: 20 B4 DB
  JSR $DBFF                             ; $D718: 20 FF DB
  LDA $0540                             ; $D71B: AD 40 05
  JSR $EADE                             ; $D71E: 20 DE EA
; --- Data Region ---
  .byte $23,$D7                           ; $D721: 23 D7
Loc_D723:  ; (dispatch callback target)
; --- Code Region ---
  JSR $DA48                             ; $D723: 20 48 DA
  LDA $0541                             ; $D726: AD 41 05
  JSR $EADE                             ; $D729: 20 DE EA
; --- Data Region ---
  .byte $3A,$D7,$78,$D7,$B0,$D7,$0C,$D8,$44,$D8,$A0,$D8,$E4,$D8; $D72C: 3A D7 78 D7 B0 D7 0C D8 44 D8 A0 D8 E4 D8
Loc_D73A:  ; (dispatch callback target)
; --- Code Region ---
  JSR $D97A                             ; $D73A: 20 7A D9
  LDA #$00                              ; $D73D: A9 00
  STA $0545                             ; $D73F: 8D 45 05
  STA $0546                             ; $D742: 8D 46 05
  STA $0547                             ; $D745: 8D 47 05
  STA $0548                             ; $D748: 8D 48 05
  STA $0549                             ; $D74B: 8D 49 05
  LDA $0543                             ; $D74E: AD 43 05
  STA $6F43                             ; $D751: 8D 43 6F
  LDA $0544                             ; $D754: AD 44 05
  STA $6F02                             ; $D757: 8D 02 6F
  LDA #$00                              ; $D75A: A9 00
  STA $6F44                             ; $D75C: 8D 44 6F
  STA $00A4                             ; $D75F: 8D A4 00
  INC $0541                             ; $D762: EE 41 05
  LDA #$01                              ; $D765: A9 01
  STA $042C                             ; $D767: 8D 2C 04
  LDA #$00                              ; $D76A: A9 00
  STA $042D                             ; $D76C: 8D 2D 04
  STA $042E                             ; $D76F: 8D 2E 04
  LDA #$DA                              ; $D772: A9 DA
  JMP $F28B                             ; $D774: 4C 8B F2
; --- Data Region ---
  .byte $60                               ; $D777: 60
Loc_D778:  ; (dispatch callback target)
; --- Code Region ---
  JSR $DAFE                             ; $D778: 20 FE DA
  BCC $D7AF                             ; $D77B: 90 32
  JSR $DAD9                             ; $D77D: 20 D9 DA
  LDA $0081                             ; $D780: AD 81 00
  AND #$03                              ; $D783: 29 03
  BEQ $D7AF                             ; $D785: F0 28
  INC $0541                             ; $D787: EE 41 05
  LDA #$00                              ; $D78A: A9 00
  STA $0424                             ; $D78C: 8D 24 04
  STA $0425                             ; $D78F: 8D 25 04
  STA $040C                             ; $D792: 8D 0C 04
  STA $040D                             ; $D795: 8D 0D 04
  STA $046C                             ; $D798: 8D 6C 04
  LDA #$DE                              ; $D79B: A9 DE
  STA $0410                             ; $D79D: 8D 10 04
  LDA #$00                              ; $D7A0: A9 00
  STA $0098                             ; $D7A2: 8D 98 00
  LDA #$01                              ; $D7A5: A9 01
  STA $0097                             ; $D7A7: 8D 97 00
  LDA #$06                              ; $D7AA: A9 06
  STA $00BB                             ; $D7AC: 8D BB 00
Loc_D7AF:
  RTS                                   ; $D7AF: 60
Loc_D7B0:  ; (dispatch callback target)
  JSR $D906                             ; $D7B0: 20 06 D9
  BCC $D7E2                             ; $D7B3: 90 2D
  LDA $0081                             ; $D7B5: AD 81 00
  AND #$01                              ; $D7B8: 29 01
  BEQ $D7E2                             ; $D7BA: F0 26
  LDA $0083                             ; $D7BC: AD 83 00
  AND #$08                              ; $D7BF: 29 08
  BEQ $D7C6                             ; $D7C1: F0 03
  JMP $D8E4                             ; $D7C3: 4C E4 D8
Loc_D7C6:
  LDY $0012                             ; $D7C6: AC 12 00
  LDA $DA07,Y                           ; $D7C9: B9 07 DA
  ASL                                   ; $D7CC: 0A
  ASL                                   ; $D7CD: 0A
  ASL                                   ; $D7CE: 0A
  TAY                                   ; $D7CF: A8
  LDA #$00                              ; $D7D0: A9 00
  STA $6F0A,Y                           ; $D7D2: 99 0A 6F
  LDA $6F43                             ; $D7D5: AD 43 6F
  BNE $D7E3                             ; $D7D8: D0 09
  LDA #$06                              ; $D7DA: A9 06
  STA $0541                             ; $D7DC: 8D 41 05
  JSR $ECEE                             ; $D7DF: 20 EE EC
Loc_D7E2:
  RTS                                   ; $D7E2: 60
Loc_D7E3:
  INC $0541                             ; $D7E3: EE 41 05
  LDA #$01                              ; $D7E6: A9 01
  STA $6F44                             ; $D7E8: 8D 44 6F
  LDA #$A0                              ; $D7EB: A9 A0
  STA $0098                             ; $D7ED: 8D 98 00
  LDA #$00                              ; $D7F0: A9 00
  STA $0097                             ; $D7F2: 8D 97 00
  LDA #$09                              ; $D7F5: A9 09
  STA $00BB                             ; $D7F7: 8D BB 00
  LDA #$02                              ; $D7FA: A9 02
  STA $042C                             ; $D7FC: 8D 2C 04
  LDA #$00                              ; $D7FF: A9 00
  STA $042D                             ; $D801: 8D 2D 04
  STA $042E                             ; $D804: 8D 2E 04
  LDA #$DA                              ; $D807: A9 DA
  JMP $F28B                             ; $D809: 4C 8B F2
Loc_D80C:  ; (dispatch callback target)
  JSR $DAFE                             ; $D80C: 20 FE DA
  BCC $D843                             ; $D80F: 90 32
  JSR $DAD9                             ; $D811: 20 D9 DA
  LDA $0081                             ; $D814: AD 81 00
  AND #$03                              ; $D817: 29 03
  BEQ $D843                             ; $D819: F0 28
  INC $0541                             ; $D81B: EE 41 05
  LDA #$00                              ; $D81E: A9 00
  STA $0424                             ; $D820: 8D 24 04
  STA $0425                             ; $D823: 8D 25 04
  STA $040C                             ; $D826: 8D 0C 04
  STA $040D                             ; $D829: 8D 0D 04
  STA $046C                             ; $D82C: 8D 6C 04
  LDA #$DE                              ; $D82F: A9 DE
  STA $0410                             ; $D831: 8D 10 04
  LDA #$00                              ; $D834: A9 00
  STA $0098                             ; $D836: 8D 98 00
  LDA #$01                              ; $D839: A9 01
  STA $0097                             ; $D83B: 8D 97 00
  LDA #$06                              ; $D83E: A9 06
  STA $00BB                             ; $D840: 8D BB 00
Loc_D843:
  RTS                                   ; $D843: 60
Loc_D844:  ; (dispatch callback target)
  JSR $D906                             ; $D844: 20 06 D9
  BCC $D86C                             ; $D847: 90 23
  LDA $0081                             ; $D849: AD 81 00
  AND #$01                              ; $D84C: 29 01
  BEQ $D86C                             ; $D84E: F0 1C
  LDY $0012                             ; $D850: AC 12 00
  LDA $DA07,Y                           ; $D853: B9 07 DA
  ASL                                   ; $D856: 0A
  ASL                                   ; $D857: 0A
  ASL                                   ; $D858: 0A
  TAY                                   ; $D859: A8
  LDA $6F0A,Y                           ; $D85A: B9 0A 6F
  BEQ $D86D                             ; $D85D: F0 0E
  LDA #$01                              ; $D85F: A9 01
  STA $6F0A,Y                           ; $D861: 99 0A 6F
  LDA #$06                              ; $D864: A9 06
  STA $0541                             ; $D866: 8D 41 05
  JSR $ECEE                             ; $D869: 20 EE EC
Loc_D86C:
  RTS                                   ; $D86C: 60
Loc_D86D:
  LDY $0012                             ; $D86D: AC 12 00
  LDA $DA07,Y                           ; $D870: B9 07 DA
  ASL                                   ; $D873: 0A
  ASL                                   ; $D874: 0A
  TAY                                   ; $D875: A8
  LDA $DA0F,Y                           ; $D876: B9 0F DA
  STA $046D                             ; $D879: 8D 6D 04
  INC $0541                             ; $D87C: EE 41 05
  LDA #$A0                              ; $D87F: A9 A0
  STA $0098                             ; $D881: 8D 98 00
  LDA #$00                              ; $D884: A9 00
  STA $0097                             ; $D886: 8D 97 00
  LDA #$09                              ; $D889: A9 09
  STA $00BB                             ; $D88B: 8D BB 00
  LDA $046D                             ; $D88E: AD 6D 04
  STA $0000                             ; $D891: 8D 00 00
  LDY #$3D                              ; $D894: A0 3D
  JSR $EE07                             ; $D896: 20 07 EE
; --- Data Region ---
  .byte $2A,$A0,$A9,$DB,$4C,$6D,$F2       ; $D899: 2A A0 A9 DB 4C 6D F2
Loc_D8A0:  ; (dispatch callback target)
; --- Code Region ---
  LDA $046D                             ; $D8A0: AD 6D 04
  STA $0000                             ; $D8A3: 8D 00 00
  LDX #$00                              ; $D8A6: A2 00
  LDA #$A7                              ; $D8A8: A9 A7
  STA $000A                             ; $D8AA: 8D 0A 00
  LDY #$39                              ; $D8AD: A0 39
  JSR $EE07                             ; $D8AF: 20 07 EE
; --- Data Region ---
  .byte $00,$A0,$20,$FE,$DA,$90,$2A,$20,$D9,$DA,$AD,$81,$00,$29,$03,$F0; $D8B2: 00 A0 20 FE DA 90 2A 20 D9 DA AD 81 00 29 03 F0
  .byte $20,$CE,$41,$05,$AD,$6D,$04,$8D,$10,$04,$A9,$00,$8D,$0C,$04,$8D; $D8C2: 20 CE 41 05 AD 6D 04 8D 10 04 A9 00 8D 0C 04 8D
  .byte $0D,$04,$A9,$00,$8D,$98,$00,$A9,$01,$8D,$97,$00,$A9,$06,$8D,$BB; $D8D2: 0D 04 A9 00 8D 98 00 A9 01 8D 97 00 A9 06 8D BB
  .byte $00                               ; $D8E2: 00
Loc_D8E3:
; --- Code Region ---
  RTS                                   ; $D8E3: 60
Loc_D8E4:  ; (dispatch callback target)
  LDA #$A7                              ; $D8E4: A9 A7
  STA $000A                             ; $D8E6: 8D 0A 00
  LDA $0410                             ; $D8E9: AD 10 04
  STA $0000                             ; $D8EC: 8D 00 00
  LDX #$00                              ; $D8EF: A2 00
  LDY #$39                              ; $D8F1: A0 39
  JSR $EE07                             ; $D8F3: 20 07 EE
; --- Data Region ---
  .byte $00,$A0,$AD,$87,$00,$10,$08,$A9,$01,$8D,$7A,$00,$4C,$4A,$DC; $D8F6: 00 A0 AD 87 00 10 08 A9 01 8D 7A 00 4C 4A DC
Loc_D905:
; --- Code Region ---
  RTS                                   ; $D905: 60
Loc_D906:
  LDA #$35                              ; $D906: A9 35
  STA $0010                             ; $D908: 8D 10 00
  LDA #$DA                              ; $D90B: A9 DA
  STA $0011                             ; $D90D: 8D 11 00
  LDA #$43                              ; $D910: A9 43
  STA $0000                             ; $D912: 8D 00 00
  LDA #$DA                              ; $D915: A9 DA
  STA $0001                             ; $D917: 8D 01 00
  LDA $046C                             ; $D91A: AD 6C 04
  JSR $EDF5                             ; $D91D: 20 F5 ED
  LDA #$A7                              ; $D920: A9 A7
  STA $000A                             ; $D922: 8D 0A 00
  LDA $0410                             ; $D925: AD 10 04
  STA $0000                             ; $D928: 8D 00 00
  LDX #$00                              ; $D92B: A2 00
  LDY #$39                              ; $D92D: A0 39
  JSR $EE07                             ; $D92F: 20 07 EE
; --- Data Region ---
  .byte $00,$A0,$AD,$0D,$04,$C9,$FF,$F0,$09,$A0,$39,$20,$07,$EE,$12,$A0; $D932: 00 A0 AD 0D 04 C9 FF F0 09 A0 39 20 07 EE 12 A0
  .byte $18,$60,$A9,$2B,$8D,$10,$00,$A9,$DA,$8D,$11,$00,$A9,$00,$8D,$12; $D942: 18 60 A9 2B 8D 10 00 A9 DA 8D 11 00 A9 00 8D 12
  .byte $00,$20,$1E,$ED,$AD,$12,$00,$CD,$6C,$04,$D0,$02,$38,$60; $D952: 00 20 1E ED AD 12 00 CD 6C 04 D0 02 38 60
Loc_D960:
; --- Code Region ---
  STA $046C                             ; $D960: 8D 6C 04
  TAY                                   ; $D963: A8
  LDA $DA07,Y                           ; $D964: B9 07 DA
  ASL                                   ; $D967: 0A
  ASL                                   ; $D968: 0A
  TAY                                   ; $D969: A8
  LDA $DA0F,Y                           ; $D96A: B9 0F DA
  STA $0410                             ; $D96D: 8D 10 04
  LDA #$00                              ; $D970: A9 00
  STA $040C                             ; $D972: 8D 0C 04
  STA $040D                             ; $D975: 8D 0D 04
  CLC                                   ; $D978: 18
  RTS                                   ; $D979: 60
Loc_D97A:
  LDA #$AD                              ; $D97A: A9 AD
  STA $6F07                             ; $D97C: 8D 07 6F
  LDA #$00                              ; $D97F: A9 00
  STA $6F08                             ; $D981: 8D 08 6F
  LDA #$00                              ; $D984: A9 00
  STA $6F09                             ; $D986: 8D 09 6F
  LDA #$03                              ; $D989: A9 03
  STA $6F0A                             ; $D98B: 8D 0A 6F
  LDA #$08                              ; $D98E: A9 08
  STA $6F0F                             ; $D990: 8D 0F 6F
  LDA #$00                              ; $D993: A9 00
  STA $6F10                             ; $D995: 8D 10 6F
  LDA #$00                              ; $D998: A9 00
  STA $6F11                             ; $D99A: 8D 11 6F
  LDA #$03                              ; $D99D: A9 03
  STA $6F12                             ; $D99F: 8D 12 6F
  LDA #$83                              ; $D9A2: A9 83
  STA $6F17                             ; $D9A4: 8D 17 6F
  LDA #$00                              ; $D9A7: A9 00
  STA $6F18                             ; $D9A9: 8D 18 6F
  LDA #$00                              ; $D9AC: A9 00
  STA $6F19                             ; $D9AE: 8D 19 6F
  LDA #$03                              ; $D9B1: A9 03
  STA $6F1A                             ; $D9B3: 8D 1A 6F
  LDA #$8A                              ; $D9B6: A9 8A
  STA $6F1F                             ; $D9B8: 8D 1F 6F
  LDA #$00                              ; $D9BB: A9 00
  STA $6F20                             ; $D9BD: 8D 20 6F
  LDA #$00                              ; $D9C0: A9 00
  STA $6F21                             ; $D9C2: 8D 21 6F
  LDA #$03                              ; $D9C5: A9 03
  STA $6F22                             ; $D9C7: 8D 22 6F
  LDA #$DE                              ; $D9CA: A9 DE
  STA $6F27                             ; $D9CC: 8D 27 6F
  LDA #$00                              ; $D9CF: A9 00
  STA $6F28                             ; $D9D1: 8D 28 6F
  LDA #$00                              ; $D9D4: A9 00
  STA $6F29                             ; $D9D6: 8D 29 6F
  LDA #$03                              ; $D9D9: A9 03
  STA $6F2A                             ; $D9DB: 8D 2A 6F
  LDA #$DC                              ; $D9DE: A9 DC
  STA $6F2F                             ; $D9E0: 8D 2F 6F
  LDA #$00                              ; $D9E3: A9 00
  STA $6F30                             ; $D9E5: 8D 30 6F
  LDA #$00                              ; $D9E8: A9 00
  STA $6F31                             ; $D9EA: 8D 31 6F
  LDA #$03                              ; $D9ED: A9 03
  STA $6F32                             ; $D9EF: 8D 32 6F
  LDA #$B6                              ; $D9F2: A9 B6
  STA $6F37                             ; $D9F4: 8D 37 6F
  LDA #$00                              ; $D9F7: A9 00
  STA $6F38                             ; $D9F9: 8D 38 6F
  LDA #$00                              ; $D9FC: A9 00
  STA $6F39                             ; $D9FE: 8D 39 6F
  LDA #$03                              ; $DA01: A9 03
  STA $6F3A                             ; $DA03: 8D 3A 6F
  RTS                                   ; $DA06: 60
; --- Data Region ---
  .byte $04,$02,$03,$01,$06,$05,$00,$00,$AD,$00,$00,$03,$08,$00,$00,$03; $DA07: 04 02 03 01 06 05 00 00 AD 00 00 03 08 00 00 03
  .byte $83,$00,$00,$03,$8A,$00,$00,$03,$DE,$00,$00,$03,$DC,$00,$00,$03; $DA17: 83 00 00 03 8A 00 00 03 DE 00 00 03 DC 00 00 03
  .byte $B6,$00,$00,$03,$00,$01,$02,$03,$04,$05,$06,$FF,$FF,$FF,$24,$10; $DA27: B6 00 00 03 00 01 02 03 04 05 06 FF FF FF 24 10
  .byte $24,$80,$44,$10,$44,$80,$64,$10,$64,$80,$84,$10,$00,$07,$00,$00; $DA37: 24 80 44 10 44 80 64 10 64 80 84 10 00 07 00 00
  .byte $80                               ; $DA47: 80
Loc_DA48:
; --- Code Region ---
  LDA #$68                              ; $DA48: A9 68
  STA $0000                             ; $DA4A: 8D 00 00
  LDA #$DA                              ; $DA4D: A9 DA
  STA $0001                             ; $DA4F: 8D 01 00
  LDA #$00                              ; $DA52: A9 00
  STA $0002                             ; $DA54: 8D 02 00
  LDA $0003                             ; $DA57: AD 03 00
  LDA #$20                              ; $DA5A: A9 20
  STA $000A                             ; $DA5C: 8D 0A 00
  LDA #$48                              ; $DA5F: A9 48
  STA $000C                             ; $DA61: 8D 0C 00
  JSR $F1AD                             ; $DA64: 20 AD F1
  RTS                                   ; $DA67: 60
; --- Data Region ---
  .byte $60,$62,$00,$00,$60,$63,$00,$08,$68,$72,$00,$00,$68,$73,$00,$08; $DA68: 60 62 00 00 60 63 00 08 68 72 00 00 68 73 00 08
  .byte $20,$64,$00,$70,$20,$65,$00,$78,$28,$74,$00,$70,$28,$75,$00,$78; $DA78: 20 64 00 70 20 65 00 78 28 74 00 70 28 75 00 78
  .byte $00,$66,$01,$70,$00               ; $DA88: 00 66 01 70 00
Loc_DA8D:
; --- Code Region ---
  RRA $01                               ; $DA8D: 67 01
  SEI                                   ; $DA8F: 78
  PHP                                   ; $DA90: 08
  ROR $01,X                             ; $DA91: 76 01
  BVS $DA9D                             ; $DA93: 70 08
  RRA $01,X                             ; $DA95: 77 01
  SEI                                   ; $DA97: 78
  JSR $0168                             ; $DA98: 20 68 01
  BRK                                   ; $DA9B: 00
  JSR $0169                             ; $DA9C: 20 69 01
  PHP                                   ; $DA9F: 08
  PLP                                   ; $DAA0: 28
  SEI                                   ; $DAA1: 78
  ORA ($00,X)                           ; $DAA2: 01 00
  PLP                                   ; $DAA4: 28
  ADC $0801,Y                           ; $DAA5: 79 01 08
  BRK                                   ; $DAA8: 00
  ROR                                   ; $DAA9: 6A
  BRK                                   ; $DAAA: 00
  BRK                                   ; $DAAB: 00
  BRK                                   ; $DAAC: 00
Loc_DAAD:
  ARR #$00                              ; $DAAD: 6B 00
  PHP                                   ; $DAAF: 08
  PHP                                   ; $DAB0: 08
  NOP                                   ; $DAB1: 7A
  BRK                                   ; $DAB2: 00
  BRK                                   ; $DAB3: 00
  PHP                                   ; $DAB4: 08
  RRA $0800,Y                           ; $DAB5: 7B 00 08
  RTI                                   ; $DAB8: 40
; --- Data Region ---
  .byte $6C,$00,$70,$40,$6D,$00,$78,$48,$7C,$00,$70,$48,$7D,$00,$78,$40; $DAB9: 6C 00 70 40 6D 00 78 48 7C 00 70 48 7D 00 78 40
  .byte $6E,$00,$00,$40,$6F,$00           ; $DAC9: 6E 00 00 40 6F 00
Loc_DACF:
; --- Code Region ---
  PHP                                   ; $DACF: 08
  PHA                                   ; $DAD0: 48
  ROR $0000,X                           ; $DAD1: 7E 00 00
  PHA                                   ; $DAD4: 48
  RRA $0800,X                           ; $DAD5: 7F 00 08
  NOP #$AD                              ; $DAD8: 80 AD
  LSR $2900,X                           ; $DADA: 5E 00 29
  BPL $DACF                             ; $DADD: 10 F0
  CLC                                   ; $DADF: 18
  LDA #$00                              ; $DAE0: A9 00
  STA $0002                             ; $DAE2: 8D 02 00
  STA $000C                             ; $DAE5: 8D 0C 00
  STA $000A                             ; $DAE8: 8D 0A 00
  LDA #$F9                              ; $DAEB: A9 F9
  STA $0000                             ; $DAED: 8D 00 00
  LDA #$DA                              ; $DAF0: A9 DA
  STA $0001                             ; $DAF2: 8D 01 00
  JSR $F1AD                             ; $DAF5: 20 AD F1
  RTS                                   ; $DAF8: 60
; --- Data Region ---
  .byte $D9,$04,$00,$7C,$80               ; $DAF9: D9 04 00 7C 80
Loc_DAFE:
; --- Code Region ---
  LDA $0304                             ; $DAFE: AD 04 03
  CMP #$FF                              ; $DB01: C9 FF
  BNE $DB0E                             ; $DB03: D0 09
  LDA $0300                             ; $DB05: AD 00 03
  CMP #$FF                              ; $DB08: C9 FF
  BNE $DB0E                             ; $DB0A: D0 02
  SEC                                   ; $DB0C: 38
  RTS                                   ; $DB0D: 60
Loc_DB0E:
  CLC                                   ; $DB0E: 18
  RTS                                   ; $DB0F: 60
Loc_DB10:
  LDA $0541                             ; $DB10: AD 41 05
  CMP #$01                              ; $DB13: C9 01
  BNE $DB50                             ; $DB15: D0 39
  LDY $0545                             ; $DB17: AC 45 05
  LDA $DB51,Y                           ; $DB1A: B9 51 DB
  BPL $DB34                             ; $DB1D: 10 15
  LDA $6FEA                             ; $DB1F: AD EA 6F
  AND #$01                              ; $DB22: 29 01
  BNE $DB33                             ; $DB24: D0 0D
  LDA $6FEA                             ; $DB26: AD EA 6F
  ORA #$01                              ; $DB29: 09 01
  STA $6FEA                             ; $DB2B: 8D EA 6F
  LDA #$62                              ; $DB2E: A9 62
  JSR $E693                             ; $DB30: 20 93 E6
Loc_DB33:
  RTS                                   ; $DB33: 60
Loc_DB34:
  LDA $0083                             ; $DB34: AD 83 00
  LDY $0545                             ; $DB37: AC 45 05
  AND $DB51,Y                           ; $DB3A: 39 51 DB
  BNE $DB45                             ; $DB3D: D0 06
  LDA #$00                              ; $DB3F: A9 00
  STA $0545                             ; $DB41: 8D 45 05
  RTS                                   ; $DB44: 60
Loc_DB45:
  LDA $0081                             ; $DB45: AD 81 00
  AND $DB5A,Y                           ; $DB48: 39 5A DB
  BEQ $DB50                             ; $DB4B: F0 03
  INC $0545                             ; $DB4D: EE 45 05
Loc_DB50:
  RTS                                   ; $DB50: 60
; --- Data Region ---
  .byte $0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C,$80,$10,$20,$10,$20,$40,$80,$40; $DB51: 0C 0C 0C 0C 0C 0C 0C 0C 80 10 20 10 20 40 80 40
  .byte $80                               ; $DB61: 80
Loc_DB62:
; --- Code Region ---
  LDA $0541                             ; $DB62: AD 41 05
  CMP #$03                              ; $DB65: C9 03
  BNE $DBA2                             ; $DB67: D0 39
  LDY $0546                             ; $DB69: AC 46 05
  LDA $DBA3,Y                           ; $DB6C: B9 A3 DB
  BPL $DB86                             ; $DB6F: 10 15
  LDA $6FEA                             ; $DB71: AD EA 6F
  AND #$02                              ; $DB74: 29 02
  BNE $DB85                             ; $DB76: D0 0D
  LDA $6FEA                             ; $DB78: AD EA 6F
  ORA #$02                              ; $DB7B: 09 02
  STA $6FEA                             ; $DB7D: 8D EA 6F
  LDA #$62                              ; $DB80: A9 62
  JSR $E693                             ; $DB82: 20 93 E6
Loc_DB85:
  RTS                                   ; $DB85: 60
Loc_DB86:
  LDA $0085                             ; $DB86: AD 85 00
  LDY $0546                             ; $DB89: AC 46 05
  AND $DBA3,Y                           ; $DB8C: 39 A3 DB
  BNE $DB97                             ; $DB8F: D0 06
  LDA #$00                              ; $DB91: A9 00
  STA $0546                             ; $DB93: 8D 46 05
  RTS                                   ; $DB96: 60
Loc_DB97:
  LDA $0082                             ; $DB97: AD 82 00
  AND $DBAC,Y                           ; $DB9A: 39 AC DB
  BEQ $DBA2                             ; $DB9D: F0 03
  INC $0546                             ; $DB9F: EE 46 05
Loc_DBA2:
  RTS                                   ; $DBA2: 60
; --- Data Region ---
  .byte $0C,$0C,$0C,$0C,$0C,$0C           ; $DBA3: 0C 0C 0C 0C 0C 0C
Loc_DBA9:  ; (dispatch callback target)
; --- Code Region ---
  NOP $800C                             ; $DBA9: 0C 0C 80
  BPL $DBEE                             ; $DBAC: 10 40
  JSR $4080                             ; $DBAE: 20 80 40
  BPL $DB33                             ; $DBB1: 10 80
  JSR $47AC                             ; $DBB3: 20 AC 47
  ORA $B9                               ; $DBB6: 05 B9
  INC $10DB                             ; $DBB8: EE DB 10
  ORA $AD,X                             ; $DBBB: 15 AD
  NOP                                   ; $DBBD: EA
  RRA $0429                             ; $DBBE: 6F 29 04
  BNE $DBD0                             ; $DBC1: D0 0D
  LDA $6FEA                             ; $DBC3: AD EA 6F
  ORA #$04                              ; $DBC6: 09 04
  STA $6FEA                             ; $DBC8: 8D EA 6F
  LDA #$62                              ; $DBCB: A9 62
  JSR $E693                             ; $DBCD: 20 93 E6
Loc_DBD0:
  RTS                                   ; $DBD0: 60
; --- Data Region ---
  .byte $AD,$83,$00,$AC,$47,$05,$39,$EE,$DB,$D0,$06,$A9,$00,$8D,$47,$05; $DBD1: AD 83 00 AC 47 05 39 EE DB D0 06 A9 00 8D 47 05
  .byte $60                               ; $DBE1: 60
Loc_DBE2:
; --- Code Region ---
  LDA $0081                             ; $DBE2: AD 81 00
  AND $DBF7,Y                           ; $DBE5: 39 F7 DB
  BEQ $DBED                             ; $DBE8: F0 03
  INC $0547                             ; $DBEA: EE 47 05
Loc_DBED:
  RTS                                   ; $DBED: 60
Loc_DBEE:
  NOP $04                               ; $DBEE: 04 04
  NOP $04                               ; $DBF0: 04 04
  NOP $04                               ; $DBF2: 04 04
  NOP $04                               ; $DBF4: 04 04
  NOP #$80                              ; $DBF6: 80 80
  NOP #$20                              ; $DBF8: 80 20
  JSR $2010                             ; $DBFA: 20 10 20
  BPL $DC1F                             ; $DBFD: 10 20
Loc_DBFF:
  LDY $0548                             ; $DBFF: AC 48 05
  LDA $DC39,Y                           ; $DC02: B9 39 DC
  BPL $DC1C                             ; $DC05: 10 15
  LDA $6FEA                             ; $DC07: AD EA 6F
  AND #$08                              ; $DC0A: 29 08
  BNE $DC1B                             ; $DC0C: D0 0D
  LDA $6FEA                             ; $DC0E: AD EA 6F
  ORA #$08                              ; $DC11: 09 08
  STA $6FEA                             ; $DC13: 8D EA 6F
  LDA #$62                              ; $DC16: A9 62
  JSR $E693                             ; $DC18: 20 93 E6
Loc_DC1B:
  RTS                                   ; $DC1B: 60
Loc_DC1C:
  LDA $0083                             ; $DC1C: AD 83 00
Loc_DC1F:
  LDY $0548                             ; $DC1F: AC 48 05
  AND $DC39,Y                           ; $DC22: 39 39 DC
  BNE $DC2D                             ; $DC25: D0 06
  LDA #$00                              ; $DC27: A9 00
  STA $0548                             ; $DC29: 8D 48 05
  RTS                                   ; $DC2C: 60
Loc_DC2D:
  LDA $0081                             ; $DC2D: AD 81 00
  AND $DC42,Y                           ; $DC30: 39 42 DC
  BEQ $DC38                             ; $DC33: F0 03
  INC $0548                             ; $DC35: EE 48 05
Loc_DC38:
  RTS                                   ; $DC38: 60
; --- Data Region ---
  .byte $08,$08,$08,$08,$08,$08,$08,$08,$80,$10,$80,$20,$40,$10,$40,$20; $DC39: 08 08 08 08 08 08 08 08 80 10 80 20 40 10 40 20
  .byte $80                               ; $DC49: 80
Loc_DC4A:
; --- Code Region ---
  LDA $6FEA                             ; $DC4A: AD EA 6F
  AND #$01                              ; $DC4D: 29 01
  BEQ $DC74                             ; $DC4F: F0 23
  LDA #$00                              ; $DC51: A9 00
  STA $0002                             ; $DC53: 8D 02 00
Loc_DC56:
  JSR $F368                             ; $DC56: 20 68 F3
  LDY #$03                              ; $DC59: A0 03
  LDA ($00),Y                           ; $DC5B: B1 00
  CMP #$00                              ; $DC5D: C9 00
  BNE $DC6A                             ; $DC5F: D0 09
  LDA $0002                             ; $DC61: AD 02 00
  JSR $DC9C                             ; $DC64: 20 9C DC
  JMP $DC74                             ; $DC67: 4C 74 DC
Loc_DC6A:
  INC $0002                             ; $DC6A: EE 02 00
  LDA $0002                             ; $DC6D: AD 02 00
  CMP #$07                              ; $DC70: C9 07
  BCC $DC56                             ; $DC72: 90 E2
Loc_DC74:
  LDA $6FEA                             ; $DC74: AD EA 6F
  AND #$02                              ; $DC77: 29 02
  BEQ $DC9B                             ; $DC79: F0 20
  LDA #$00                              ; $DC7B: A9 00
  STA $0002                             ; $DC7D: 8D 02 00
Loc_DC80:
  JSR $F368                             ; $DC80: 20 68 F3
  LDY #$03                              ; $DC83: A0 03
  LDA ($00),Y                           ; $DC85: B1 00
  CMP #$01                              ; $DC87: C9 01
  BNE $DC91                             ; $DC89: D0 06
  LDA $0002                             ; $DC8B: AD 02 00
  JMP $DC9C                             ; $DC8E: 4C 9C DC
Loc_DC91:
  INC $0002                             ; $DC91: EE 02 00
  LDA $0002                             ; $DC94: AD 02 00
  CMP #$07                              ; $DC97: C9 07
  BCC $DC80                             ; $DC99: 90 E5
Loc_DC9B:
  RTS                                   ; $DC9B: 60
Loc_DC9C:
  ASL                                   ; $DC9C: 0A
  TAY                                   ; $DC9D: A8
  LDA $DCB7,Y                           ; $DC9E: B9 B7 DC
  STA $0000                             ; $DCA1: 8D 00 00
  LDA $DCB8,Y                           ; $DCA4: B9 B8 DC
  STA $0001                             ; $DCA7: 8D 01 00
  LDY #$02                              ; $DCAA: A0 02
Loc_DCAC:
  LDA $DCC3,Y                           ; $DCAC: B9 C3 DC
  STA ($00),Y                           ; $DCAF: 91 00
  INY                                   ; $DCB1: C8
  CPY #$11                              ; $DCB2: C0 11
  BCC $DCAC                             ; $DCB4: 90 F6
  RTS                                   ; $DCB6: 60
; --- Data Region ---
  .byte $80,$61,$80,$60,$60,$61,$80,$62,$40,$60,$40,$63,$C0,$60,$0F,$27; $DCB7: 80 61 80 60 60 61 80 62 40 60 40 63 C0 60 0F 27
  .byte $0F,$27,$0F,$27,$0F,$27,$63,$63,$0F,$27,$E7,$03,$63,$FF,$FF,$FF; $DCC7: 0F 27 0F 27 0F 27 63 63 0F 27 E7 03 63 FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DCD7: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DCE7: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DCF7: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DD07: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DD17: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DD27: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DD37: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DD47: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DD57: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DD67: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DD77: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DD87: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DD97: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DDA7: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DDB7: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DDC7: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DDD7: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DDE7: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DDF7: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DE07: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DE17: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DE27: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DE37: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DE47: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DE57: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DE67: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DE77: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DE87: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF; $DE97: FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
  .byte $FF,$FF                           ; $DEA7: FF FF
Loc_DEA9:  ; (dispatch callback target)
; --- Code Region ---
  ISB $FFFF,X                           ; $DEA9: FF FF FF
  ISB $FFFF,X                           ; $DEAC: FF FF FF
  ISB $FFFF,X                           ; $DEAF: FF FF FF
  ISB $FFFF,X                           ; $DEB2: FF FF FF
  ISB $FFFF,X                           ; $DEB5: FF FF FF
  ISB $FFFF,X                           ; $DEB8: FF FF FF
  ISB $FFFF,X                           ; $DEBB: FF FF FF
  ISB $FFFF,X                           ; $DEBE: FF FF FF
  ISB $FFFF,X                           ; $DEC1: FF FF FF
  ISB $FFFF,X                           ; $DEC4: FF FF FF
  ISB $FFFF,X                           ; $DEC7: FF FF FF
  ISB $FFFF,X                           ; $DECA: FF FF FF
  ISB $FFFF,X                           ; $DECD: FF FF FF
  ISB $FFFF,X                           ; $DED0: FF FF FF
  ISB $FFFF,X                           ; $DED3: FF FF FF
  ISB $FFFF,X                           ; $DED6: FF FF FF
  ISB $FFFF,X                           ; $DED9: FF FF FF
  ISB $FFFF,X                           ; $DEDC: FF FF FF
  ISB $FFFF,X                           ; $DEDF: FF FF FF
  ISB $FFFF,X                           ; $DEE2: FF FF FF
  ISB $FFFF,X                           ; $DEE5: FF FF FF
  ISB $FFFF,X                           ; $DEE8: FF FF FF
  ISB $FFFF,X                           ; $DEEB: FF FF FF
  ISB $FFFF,X                           ; $DEEE: FF FF FF
  ISB $FFFF,X                           ; $DEF1: FF FF FF
  ISB $FFFF,X                           ; $DEF4: FF FF FF
  ISB $FFFF,X                           ; $DEF7: FF FF FF
  ISB $FFFF,X                           ; $DEFA: FF FF FF
  ISB $FFFF,X                           ; $DEFD: FF FF FF
  ISB $FFFF,X                           ; $DF00: FF FF FF
  ISB $FFFF,X                           ; $DF03: FF FF FF
  ISB $FFFF,X                           ; $DF06: FF FF FF
  ISB $FFFF,X                           ; $DF09: FF FF FF
  ISB $FFFF,X                           ; $DF0C: FF FF FF
  ISB $FFFF,X                           ; $DF0F: FF FF FF
  ISB $FFFF,X                           ; $DF12: FF FF FF
  ISB $FFFF,X                           ; $DF15: FF FF FF
  ISB $FFFF,X                           ; $DF18: FF FF FF
  ISB $FFFF,X                           ; $DF1B: FF FF FF
  ISB $FFFF,X                           ; $DF1E: FF FF FF
  ISB $FFFF,X                           ; $DF21: FF FF FF
  ISB $FFFF,X                           ; $DF24: FF FF FF
  ISB $FFFF,X                           ; $DF27: FF FF FF
  ISB $FFFF,X                           ; $DF2A: FF FF FF
  ISB $FFFF,X                           ; $DF2D: FF FF FF
  ISB $FFFF,X                           ; $DF30: FF FF FF
  ISB $FFFF,X                           ; $DF33: FF FF FF
  ISB $FFFF,X                           ; $DF36: FF FF FF
  ISB $FFFF,X                           ; $DF39: FF FF FF
  ISB $FFFF,X                           ; $DF3C: FF FF FF
  ISB $FFFF,X                           ; $DF3F: FF FF FF
  ISB $FFFF,X                           ; $DF42: FF FF FF
  ISB $FFFF,X                           ; $DF45: FF FF FF
  ISB $FFFF,X                           ; $DF48: FF FF FF
  ISB $FFFF,X                           ; $DF4B: FF FF FF
  ISB $FFFF,X                           ; $DF4E: FF FF FF
  ISB $FFFF,X                           ; $DF51: FF FF FF
  ISB $FFFF,X                           ; $DF54: FF FF FF
  ISB $FFFF,X                           ; $DF57: FF FF FF
  ISB $FFFF,X                           ; $DF5A: FF FF FF
  ISB $FFFF,X                           ; $DF5D: FF FF FF
  ISB $FFFF,X                           ; $DF60: FF FF FF
  ISB $FFFF,X                           ; $DF63: FF FF FF
  ISB $FFFF,X                           ; $DF66: FF FF FF
  ISB $FFFF,X                           ; $DF69: FF FF FF
  ISB $FFFF,X                           ; $DF6C: FF FF FF
  ISB $FFFF,X                           ; $DF6F: FF FF FF
  ISB $FFFF,X                           ; $DF72: FF FF FF
  ISB $FFFF,X                           ; $DF75: FF FF FF
  ISB $FFFF,X                           ; $DF78: FF FF FF
  ISB $FFFF,X                           ; $DF7B: FF FF FF
  ISB $FFFF,X                           ; $DF7E: FF FF FF
  ISB $FFFF,X                           ; $DF81: FF FF FF
  ISB $FFFF,X                           ; $DF84: FF FF FF
  ISB $FFFF,X                           ; $DF87: FF FF FF
  ISB $FFFF,X                           ; $DF8A: FF FF FF
  ISB $FFFF,X                           ; $DF8D: FF FF FF
  ISB $FFFF,X                           ; $DF90: FF FF FF
  ISB $FFFF,X                           ; $DF93: FF FF FF
  ISB $FFFF,X                           ; $DF96: FF FF FF
  ISB $FFFF,X                           ; $DF99: FF FF FF
  ISB $FFFF,X                           ; $DF9C: FF FF FF
  ISB $FFFF,X                           ; $DF9F: FF FF FF
  ISB $FFFF,X                           ; $DFA2: FF FF FF
  ISB $FFFF,X                           ; $DFA5: FF FF FF
  ISB $FFFF,X                           ; $DFA8: FF FF FF
  ISB $FFFF,X                           ; $DFAB: FF FF FF
  ISB $FFFF,X                           ; $DFAE: FF FF FF
  ISB $FFFF,X                           ; $DFB1: FF FF FF
  ISB $FFFF,X                           ; $DFB4: FF FF FF
  ISB $FFFF,X                           ; $DFB7: FF FF FF
  ISB $FFFF,X                           ; $DFBA: FF FF FF
  ISB $FFFF,X                           ; $DFBD: FF FF FF
  ISB $FFFF,X                           ; $DFC0: FF FF FF
  ISB $FFFF,X                           ; $DFC3: FF FF FF
  ISB $FFFF,X                           ; $DFC6: FF FF FF
  ISB $FFFF,X                           ; $DFC9: FF FF FF
  ISB $FFFF,X                           ; $DFCC: FF FF FF
  ISB $FFFF,X                           ; $DFCF: FF FF FF
  ISB $FFFF,X                           ; $DFD2: FF FF FF
  ISB $FFFF,X                           ; $DFD5: FF FF FF
  ISB $FFFF,X                           ; $DFD8: FF FF FF
  ISB $FFFF,X                           ; $DFDB: FF FF FF
  ISB $FFFF,X                           ; $DFDE: FF FF FF
  ISB $FFFF,X                           ; $DFE1: FF FF FF
  ISB $FFFF,X                           ; $DFE4: FF FF FF
  ISB $FFFF,X                           ; $DFE7: FF FF FF
  ISB $FFFF,X                           ; $DFEA: FF FF FF
  ISB $FFFF,X                           ; $DFED: FF FF FF
  ISB $FFFF,X                           ; $DFF0: FF FF FF
  ISB $FFFF,X                           ; $DFF3: FF FF FF
  ISB $FFFF,X                           ; $DFF6: FF FF FF
  ISB $FFFF,X                           ; $DFF9: FF FF FF
  ISB $FFFF,X                           ; $DFFC: FF FF FF
  .byte $FF                              ; $DFFF: FF
