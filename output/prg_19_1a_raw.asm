Loc_A000:
  JMP $CE1F                             ; $A000: 4C 1F CE
Loc_A003:  ; (dispatch callback target)
  JMP $A033                             ; $A003: 4C 33 A0
Loc_A006:  ; (dispatch callback target)
  JMP $C773                             ; $A006: 4C 73 C7
Loc_A009:  ; (dispatch callback target)
  JMP $A296                             ; $A009: 4C 96 A2
Loc_A00C:
  JMP $AD81                             ; $A00C: 4C 81 AD
Loc_A00F:
  JMP $CFD6                             ; $A00F: 4C D6 CF
Loc_A012:
  JMP $B2D7                             ; $A012: 4C D7 B2
Loc_A015:  ; (dispatch callback target)
  JMP $B7D9                             ; $A015: 4C D9 B7
Loc_A018:
  JMP $B8D7                             ; $A018: 4C D7 B8
Loc_A01B:
  JMP $B964                             ; $A01B: 4C 64 B9
Loc_A01E:  ; (dispatch callback target)
  JMP $C435                             ; $A01E: 4C 35 C4
Loc_A021:  ; (dispatch callback target)
  JMP $AFE5                             ; $A021: 4C E5 AF
Loc_A024:
  JMP $BA70                             ; $A024: 4C 70 BA
Loc_A027:
  JMP $BB03                             ; $A027: 4C 03 BB
Loc_A02A:  ; (dispatch callback target)
  JMP $BBDE                             ; $A02A: 4C DE BB
Loc_A02D:
  JMP $BC02                             ; $A02D: 4C 02 BC
Loc_A030:
  JMP $BB73                             ; $A030: 4C 73 BB
Loc_A033:
  LDA $0401                             ; $A033: AD 01 04
  JSR $EADE                             ; $A036: 20 DE EA
; --- Data Region ---
  .byte $41,$A0,$2C,$A1,$5E,$A1,$86,$A1   ; $A039: 41 A0 2C A1 5E A1 86 A1
Loc_A041:  ; (dispatch callback target)
; --- Code Region ---
  LDA #$F0                              ; $A041: A9 F0
  STA $6F41                             ; $A043: 8D 41 6F
  INC $6F04                             ; $A046: EE 04 6F
  LDA $6F04                             ; $A049: AD 04 6F
  CMP #$07                              ; $A04C: C9 07
  BCC $A06B                             ; $A04E: 90 1B
  LDA #$00                              ; $A050: A9 00
  STA $6F04                             ; $A052: 8D 04 6F
  STA $6F06                             ; $A055: 8D 06 6F
  LDY $6F01                             ; $A058: AC 01 6F
  INY                                   ; $A05B: C8
  CPY #$0C                              ; $A05C: C0 0C
  BCC $A065                             ; $A05E: 90 05
  LDY #$00                              ; $A060: A0 00
  INC $6F00                             ; $A062: EE 00 6F
Loc_A065:
  STY $6F01                             ; $A065: 8C 01 6F
  JSR $A209                             ; $A068: 20 09 A2
Loc_A06B:
  LDA $6F45                             ; $A06B: AD 45 6F
  ASL                                   ; $A06E: 0A
  ASL                                   ; $A06F: 0A
  ASL                                   ; $A070: 0A
  ORA $6F04                             ; $A071: 0D 04 6F
  TAY                                   ; $A074: A8
  LDA $A104,Y                           ; $A075: B9 04 A1
  STA $6F03                             ; $A078: 8D 03 6F
  ASL                                   ; $A07B: 0A
  TAY                                   ; $A07C: A8
  LDA $A0D6,Y                           ; $A07D: B9 D6 A0
  STA $00EE                             ; $A080: 8D EE 00
  LDA $A0D7,Y                           ; $A083: B9 D7 A0
  STA $00EF                             ; $A086: 8D EF 00
  LDY #$00                              ; $A089: A0 00
  LDA ($EE),Y                           ; $A08B: B1 EE
  CMP #$FF                              ; $A08D: C9 FF
  BEQ $A041                             ; $A08F: F0 B0
  JSR $A240                             ; $A091: 20 40 A2
  LDA $0011                             ; $A094: AD 11 00
  CMP #$1E                              ; $A097: C9 1E
  BCS $A0A5                             ; $A099: B0 0A
  LDA #$03                              ; $A09B: A9 03
  STA $0401                             ; $A09D: 8D 01 04
  LDA #$D5                              ; $A0A0: A9 D5
  JMP $F28B                             ; $A0A2: 4C 8B F2
Loc_A0A5:
  LDA $6F03                             ; $A0A5: AD 03 6F
  AND #$07                              ; $A0A8: 29 07
  JSR $A19F                             ; $A0AA: 20 9F A1
Loc_A0AD:  ; (dispatch callback target)
  LDY $0003                             ; $A0AD: AC 03 00
  LDA $A0E4,Y                           ; $A0B0: B9 E4 A0
  STA $6F05                             ; $A0B3: 8D 05 6F
  LDY #$3D                              ; $A0B6: A0 3D
  JSR $EE07                             ; $A0B8: 20 07 EE
; --- Data Region ---
  .byte $1E,$A0,$A0,$00,$B1,$EE,$8D,$0A,$00,$20,$EB,$A1,$A0,$01,$91,$EE; $A0BB: 1E A0 A0 00 B1 EE 8D 0A 00 20 EB A1 A0 01 91 EE
  .byte $A9,$0A,$8D,$00,$04,$A9,$00,$8D,$01,$04,$60,$07,$6F,$0F,$6F,$17; $A0CB: A9 0A 8D 00 04 A9 00 8D 01 04 60 07 6F 0F 6F 17
  .byte $6F,$1F,$6F,$27,$6F,$2F,$6F,$37,$6F,$00,$03,$03,$03,$04,$05,$07; $A0DB: 6F 1F 6F 27 6F 2F 6F 37 6F 00 03 03 03 04 05 07
  .byte $07,$07,$08,$08,$08,$08,$09,$09,$09,$09,$0A,$0A,$0A,$0B,$0B,$0B; $A0EB: 07 07 08 08 08 08 09 09 09 09 0A 0A 0A 0B 0B 0B
  .byte $0B,$0C,$0C,$0C,$0C,$0D,$0D,$0D,$0D,$00,$01,$02,$03,$06,$05,$04; $A0FB: 0B 0C 0C 0C 0C 0D 0D 0D 0D 00 01 02 03 06 05 04
  .byte $00,$01,$04,$06,$00,$02,$03,$05,$00,$03,$02,$04,$06,$05,$00,$01; $A10B: 00 01 04 06 00 02 03 05 00 03 02 04 06 05 00 01
  .byte $00,$05,$06,$04,$03,$00,$01,$02,$00,$04,$02,$03,$00,$01,$05,$06; $A11B: 00 05 06 04 03 00 01 02 00 04 02 03 00 01 05 06
  .byte $00                               ; $A12B: 00
Loc_A12C:  ; (dispatch callback target)
; --- Code Region ---
  INC $0401                             ; $A12C: EE 01 04
  LDA #$20                              ; $A12F: A9 20
  JSR $F28B                             ; $A131: 20 8B F2
  LDY #$00                              ; $A134: A0 00
  LDA ($EE),Y                           ; $A136: B1 EE
  STA $042C                             ; $A138: 8D 2C 04
  LDA $6F05                             ; $A13B: AD 05 6F
  STA $042F                             ; $A13E: 8D 2F 04
  LDA #$00                              ; $A141: A9 00
  STA $0430                             ; $A143: 8D 30 04
  STA $0431                             ; $A146: 8D 31 04
  LDY #$01                              ; $A149: A0 01
  LDA ($EE),Y                           ; $A14B: B1 EE
  TAY                                   ; $A14D: A8
  LDA $C737,Y                           ; $A14E: B9 37 C7
  STA $6F3F                             ; $A151: 8D 3F 6F
  LDA $C755,Y                           ; $A154: B9 55 C7
  CLC                                   ; $A157: 18
  ADC #$01                              ; $A158: 69 01
  STA $6F41                             ; $A15A: 8D 41 6F
  RTS                                   ; $A15D: 60
Loc_A15E:  ; (dispatch callback target)
  LDY #$3D                              ; $A15E: A0 3D
  JSR $EE07                             ; $A160: 20 07 EE
; --- Data Region ---
  .byte $21,$A0,$AD,$00,$03,$C9,$FF,$D0,$19,$AD,$04,$03,$C9,$FF,$D0,$12; $A163: 21 A0 AD 00 03 C9 FF D0 19 AD 04 03 C9 FF D0 12
  .byte $20,$C2,$A1,$AD,$81,$00,$29,$01,$F0,$08,$A9,$00,$8D,$00,$04,$8D; $A173: 20 C2 A1 AD 81 00 29 01 F0 08 A9 00 8D 00 04 8D
  .byte $01,$04                           ; $A183: 01 04
Loc_A185:
; --- Code Region ---
  RTS                                   ; $A185: 60
Loc_A186:  ; (dispatch callback target)
  LDA $0300                             ; $A186: AD 00 03
  CMP #$FF                              ; $A189: C9 FF
  BNE $A19E                             ; $A18B: D0 11
  LDA $0304                             ; $A18D: AD 04 03
  CMP #$FF                              ; $A190: C9 FF
  BNE $A19E                             ; $A192: D0 0A
  LDA $0081                             ; $A194: AD 81 00
  AND #$01                              ; $A197: 29 01
  BEQ $A19E                             ; $A199: F0 03
  JMP $E000                             ; $A19B: 4C 00 E0
Loc_A19E:
  RTS                                   ; $A19E: 60
Loc_A19F:
  STA $0002                             ; $A19F: 8D 02 00
  LDA #$00                              ; $A1A2: A9 00
  STA $0003                             ; $A1A4: 8D 03 00
  LDA #$1D                              ; $A1A7: A9 1D
Loc_A1A9:
  PHA                                   ; $A1A9: 48
  JSR $F2AF                             ; $A1AA: 20 AF F2
  LDY #$00                              ; $A1AD: A0 00
  LDA ($00),Y                           ; $A1AF: B1 00
  AND #$0F                              ; $A1B1: 29 0F
  CMP $0002                             ; $A1B3: CD 02 00
  BNE $A1BB                             ; $A1B6: D0 03
  INC $0003                             ; $A1B8: EE 03 00
Loc_A1BB:
  PLA                                   ; $A1BB: 68
  SEC                                   ; $A1BC: 38
  SBC #$01                              ; $A1BD: E9 01
  BPL $A1A9                             ; $A1BF: 10 E8
  RTS                                   ; $A1C1: 60
Loc_A1C2:
  LDA $005E                             ; $A1C2: AD 5E 00
  AND #$10                              ; $A1C5: 29 10
  BNE $A1E5                             ; $A1C7: D0 1C
  LDA #$D8                              ; $A1C9: A9 D8
  STA $000A                             ; $A1CB: 8D 0A 00
  LDA #$A0                              ; $A1CE: A9 A0
  STA $000C                             ; $A1D0: 8D 0C 00
  LDA #$E6                              ; $A1D3: A9 E6
  STA $0000                             ; $A1D5: 8D 00 00
  LDA #$A1                              ; $A1D8: A9 A1
  STA $0001                             ; $A1DA: 8D 01 00
  LDA #$00                              ; $A1DD: A9 00
  STA $0002                             ; $A1DF: 8D 02 00
  JMP $F1AD                             ; $A1E2: 4C AD F1
Loc_A1E5:
  RTS                                   ; $A1E5: 60
; --- Data Region ---
  .byte $00,$04,$00,$00,$80               ; $A1E6: 00 04 00 00 80
Loc_A1EB:
; --- Code Region ---
  LDX #$00                              ; $A1EB: A2 00
Loc_A1ED:
  TXA                                   ; $A1ED: 8A
  JSR $F2AF                             ; $A1EE: 20 AF F2
  LDY #$11                              ; $A1F1: A0 11
Loc_A1F3:
  LDA ($00),Y                           ; $A1F3: B1 00
  CMP $000A                             ; $A1F5: CD 0A 00
  BNE $A1FC                             ; $A1F8: D0 02
  TXA                                   ; $A1FA: 8A
  RTS                                   ; $A1FB: 60
Loc_A1FC:
  INY                                   ; $A1FC: C8
  CPY #$1B                              ; $A1FD: C0 1B
  BCC $A1F3                             ; $A1FF: 90 F2
  INX                                   ; $A201: E8
  CPX #$1E                              ; $A202: E0 1E
  BCC $A1ED                             ; $A204: 90 E7
  LDA #$00                              ; $A206: A9 00
  RTS                                   ; $A208: 60
Loc_A209:
  LDA #$00                              ; $A209: A9 00
  STA $0002                             ; $A20B: 8D 02 00
Loc_A20E:
  LDA $0002                             ; $A20E: AD 02 00
  JSR $F368                             ; $A211: 20 68 F3
  LDY #$04                              ; $A214: A0 04
Loc_A216:
  LDA ($00),Y                           ; $A216: B1 00
  AND #$0F                              ; $A218: 29 0F
  BEQ $A223                             ; $A21A: F0 07
  LDA ($00),Y                           ; $A21C: B1 00
  SEC                                   ; $A21E: 38
  SBC #$01                              ; $A21F: E9 01
  STA ($00),Y                           ; $A221: 91 00
Loc_A223:
  LDA ($00),Y                           ; $A223: B1 00
  AND #$F0                              ; $A225: 29 F0
  BEQ $A230                             ; $A227: F0 07
  LDA ($00),Y                           ; $A229: B1 00
  SEC                                   ; $A22B: 38
  SBC #$10                              ; $A22C: E9 10
  STA ($00),Y                           ; $A22E: 91 00
Loc_A230:
  INY                                   ; $A230: C8
  CPY #$08                              ; $A231: C0 08
  BCC $A216                             ; $A233: 90 E1
  INC $0002                             ; $A235: EE 02 00
  LDA $0002                             ; $A238: AD 02 00
  CMP #$07                              ; $A23B: C9 07
  BCC $A20E                             ; $A23D: 90 CF
  RTS                                   ; $A23F: 60
Loc_A240:
  LDY #$31                              ; $A240: A0 31
  JSR $F25F                             ; $A242: 20 5F F2
  LDY #$00                              ; $A245: A0 00
  LDX #$00                              ; $A247: A2 00
Loc_A249:
  LDA $6F07,Y                           ; $A249: B9 07 6F
  STA $042C,X                           ; $A24C: 9D 2C 04
  INX                                   ; $A24F: E8
  TXA                                   ; $A250: 8A
  ASL                                   ; $A251: 0A
  ASL                                   ; $A252: 0A
  ASL                                   ; $A253: 0A
  TAY                                   ; $A254: A8
  CPX #$07                              ; $A255: E0 07
  BCC $A249                             ; $A257: 90 F0
  LDX $6F03                             ; $A259: AE 03 6F
  LDA #$FF                              ; $A25C: A9 FF
  STA $042C,X                           ; $A25E: 9D 2C 04
  LDA #$00                              ; $A261: A9 00
  STA $0010                             ; $A263: 8D 10 00
  STA $0011                             ; $A266: 8D 11 00
Loc_A269:
  LDX #$00                              ; $A269: A2 00
Loc_A26B:
  LDA $042C,X                           ; $A26B: BD 2C 04
  CMP $0010                             ; $A26E: CD 10 00
  BEQ $A28B                             ; $A271: F0 18
  INX                                   ; $A273: E8
  CPX #$07                              ; $A274: E0 07
  BCC $A26B                             ; $A276: 90 F3
  LDA $0010                             ; $A278: AD 10 00
  JSR $F2D7                             ; $A27B: 20 D7 F2
  LDY #$0B                              ; $A27E: A0 0B
  LDA ($00),Y                           ; $A280: B1 00
  AND #$03                              ; $A282: 29 03
  CMP #$03                              ; $A284: C9 03
  BEQ $A28B                             ; $A286: F0 03
  INC $0011                             ; $A288: EE 11 00
Loc_A28B:
  INC $0010                             ; $A28B: EE 10 00
  LDA $0010                             ; $A28E: AD 10 00
  CMP #$ED                              ; $A291: C9 ED
  BCC $A269                             ; $A293: 90 D4
  RTS                                   ; $A295: 60
Loc_A296:
  LDA $0401                             ; $A296: AD 01 04
  JSR $EADE                             ; $A299: 20 DE EA
; --- Data Region ---
  .byte $BC,$A2,$0C,$A3,$3C,$A3,$89,$A3,$9B,$A3,$63,$A3,$E5,$A3,$AA,$A5; $A29C: BC A2 0C A3 3C A3 89 A3 9B A3 63 A3 E5 A3 AA A5
  .byte $EF,$A6,$A0,$A9,$C0,$AE,$80,$BC,$01,$BE,$32,$C1,$7A,$C3,$15,$AB; $A2AC: EF A6 A0 A9 C0 AE 80 BC 01 BE 32 C1 7A C3 15 AB
Loc_A2BC:  ; (dispatch callback target)
; --- Code Region ---
  LDA $0300                             ; $A2BC: AD 00 03
  CMP #$FF                              ; $A2BF: C9 FF
  BNE $A2D9                             ; $A2C1: D0 16
  LDA $0304                             ; $A2C3: AD 04 03
  CMP #$FF                              ; $A2C6: C9 FF
  BNE $A2D9                             ; $A2C8: D0 0F
  LDA $007E                             ; $A2CA: AD 7E 00
  BNE $A2D9                             ; $A2CD: D0 0A
  LDA $6F06                             ; $A2CF: AD 06 6F
  BEQ $A2DA                             ; $A2D2: F0 06
  LDA #$02                              ; $A2D4: A9 02
  STA $0401                             ; $A2D6: 8D 01 04
Loc_A2D9:
  RTS                                   ; $A2D9: 60
Loc_A2DA:
  INC $6F06                             ; $A2DA: EE 06 6F
  LDA $6F01                             ; $A2DD: AD 01 6F
  CMP #$03                              ; $A2E0: C9 03
  BNE $A2EF                             ; $A2E2: D0 0B
  LDA #$06                              ; $A2E4: A9 06
  STA $0401                             ; $A2E6: 8D 01 04
  LDA #$00                              ; $A2E9: A9 00
  STA $0402                             ; $A2EB: 8D 02 04
  RTS                                   ; $A2EE: 60
Loc_A2EF:
  LDA $6F01                             ; $A2EF: AD 01 6F
  CMP #$09                              ; $A2F2: C9 09
  BNE $A301                             ; $A2F4: D0 0B
  LDA #$07                              ; $A2F6: A9 07
  STA $0401                             ; $A2F8: 8D 01 04
  LDA #$00                              ; $A2FB: A9 00
  STA $0402                             ; $A2FD: 8D 02 04
  RTS                                   ; $A300: 60
Loc_A301:
  LDA #$0F                              ; $A301: A9 0F
  STA $0401                             ; $A303: 8D 01 04
  LDA #$00                              ; $A306: A9 00
  STA $0402                             ; $A308: 8D 02 04
  RTS                                   ; $A30B: 60
Loc_A30C:  ; (dispatch callback target)
  LDA $6F01                             ; $A30C: AD 01 6F
  CMP #$07                              ; $A30F: C9 07
  BEQ $A317                             ; $A311: F0 04
  CMP #$08                              ; $A313: C9 08
  BNE $A322                             ; $A315: D0 0B
Loc_A317:
  LDA #$08                              ; $A317: A9 08
  STA $0401                             ; $A319: 8D 01 04
  LDA #$00                              ; $A31C: A9 00
  STA $0402                             ; $A31E: 8D 02 04
  RTS                                   ; $A321: 60
Loc_A322:
  LDA $6F01                             ; $A322: AD 01 6F
  CMP #$04                              ; $A325: C9 04
  BEQ $A32D                             ; $A327: F0 04
  CMP #$05                              ; $A329: C9 05
  BNE $A338                             ; $A32B: D0 0B
Loc_A32D:
  LDA #$09                              ; $A32D: A9 09
  STA $0401                             ; $A32F: 8D 01 04
  LDA #$00                              ; $A332: A9 00
  STA $0402                             ; $A334: 8D 02 04
  RTS                                   ; $A337: 60
Loc_A338:
  INC $0401                             ; $A338: EE 01 04
  RTS                                   ; $A33B: 60
Loc_A33C:  ; (dispatch callback target)
  LDA $6F03                             ; $A33C: AD 03 6F
  CMP #$02                              ; $A33F: C9 02
  BCC $A35F                             ; $A341: 90 1C
  CMP #$05                              ; $A343: C9 05
  BEQ $A35F                             ; $A345: F0 18
  CMP #$06                              ; $A347: C9 06
  BNE $A34D                             ; $A349: D0 02
  LDA #$05                              ; $A34B: A9 05
Loc_A34D:
  SEC                                   ; $A34D: 38
  SBC #$02                              ; $A34E: E9 02
  ASL                                   ; $A350: 0A
  STA $0470                             ; $A351: 8D 70 04
  LDA #$0A                              ; $A354: A9 0A
  STA $0401                             ; $A356: 8D 01 04
  LDA #$00                              ; $A359: A9 00
  STA $0402                             ; $A35B: 8D 02 04
  RTS                                   ; $A35E: 60
Loc_A35F:
  INC $0401                             ; $A35F: EE 01 04
  RTS                                   ; $A362: 60
Loc_A363:  ; (dispatch callback target)
  LDA #$00                              ; $A363: A9 00
  STA $0470                             ; $A365: 8D 70 04
  LDY #$03                              ; $A368: A0 03
  LDA ($EE),Y                           ; $A36A: B1 EE
  CMP #$03                              ; $A36C: C9 03
  BNE $A37B                             ; $A36E: D0 0B
  LDA #$09                              ; $A370: A9 09
  STA $0400                             ; $A372: 8D 00 04
  LDA #$00                              ; $A375: A9 00
  STA $0401                             ; $A377: 8D 01 04
  RTS                                   ; $A37A: 60
Loc_A37B:
  STA $6F44                             ; $A37B: 8D 44 6F
  LDA #$0B                              ; $A37E: A9 0B
  STA $0400                             ; $A380: 8D 00 04
  LDA #$01                              ; $A383: A9 01
  STA $0401                             ; $A385: 8D 01 04
  RTS                                   ; $A388: 60
Loc_A389:  ; (dispatch callback target)
  LDY #$00                              ; $A389: A0 00
  LDA ($EE),Y                           ; $A38B: B1 EE
  STA $040B                             ; $A38D: 8D 0B 04
  LDA #$0B                              ; $A390: A9 0B
  STA $0401                             ; $A392: 8D 01 04
  LDA #$00                              ; $A395: A9 00
  STA $0402                             ; $A397: 8D 02 04
  RTS                                   ; $A39A: 60
Loc_A39B:  ; (dispatch callback target)
  LDY #$00                              ; $A39B: A0 00
  LDA ($EE),Y                           ; $A39D: B1 EE
  STA $040B                             ; $A39F: 8D 0B 04
  JSR $F2D7                             ; $A3A2: 20 D7 F2
  LDY #$0B                              ; $A3A5: A0 0B
  LDA ($00),Y                           ; $A3A7: B1 00
  AND #$03                              ; $A3A9: 29 03
  CMP #$03                              ; $A3AB: C9 03
  BNE $A3E1                             ; $A3AD: D0 32
  LDA #$05                              ; $A3AF: A9 05
  STA $0470                             ; $A3B1: 8D 70 04
  LDA #$0E                              ; $A3B4: A9 0E
  STA $0471                             ; $A3B6: 8D 71 04
  LDA #$0B                              ; $A3B9: A9 0B
  STA $0472                             ; $A3BB: 8D 72 04
  LDA #$00                              ; $A3BE: A9 00
  STA $0473                             ; $A3C0: 8D 73 04
  LDA $6F03                             ; $A3C3: AD 03 6F
  STA $040A                             ; $A3C6: 8D 0A 04
  LDA #$FF                              ; $A3C9: A9 FF
  STA $040C                             ; $A3CB: 8D 0C 04
  LDA #$0C                              ; $A3CE: A9 0C
  STA $0401                             ; $A3D0: 8D 01 04
  LDA #$00                              ; $A3D3: A9 00
  STA $0402                             ; $A3D5: 8D 02 04
  LDY #$03                              ; $A3D8: A0 03
  LDA ($EE),Y                           ; $A3DA: B1 EE
  CMP #$03                              ; $A3DC: C9 03
  BEQ $A3E1                             ; $A3DE: F0 01
  RTS                                   ; $A3E0: 60
Loc_A3E1:
  INC $0401                             ; $A3E1: EE 01 04
  RTS                                   ; $A3E4: 60
Loc_A3E5:  ; (dispatch callback target)
  LDA $0402                             ; $A3E5: AD 02 04
  JSR $EADE                             ; $A3E8: 20 DE EA
; --- Data Region ---
  .byte $F1,$A3,$04,$A4,$20,$A4,$A9,$BC,$20,$8B,$F2,$EE,$02,$04,$A9,$A6; $A3EB: F1 A3 04 A4 20 A4 A9 BC 20 8B F2 EE 02 04 A9 A6
  .byte $8D,$D6,$04,$A9,$20,$8D,$A0,$04,$60; $A3FB: 8D D6 04 A9 20 8D A0 04 60
Loc_A404:  ; (dispatch callback target)
; --- Code Region ---
  LDA $04A0                             ; $A404: AD A0 04
  BNE $A41F                             ; $A407: D0 16
  LDA $0140                             ; $A409: AD 40 01
  BNE $A41F                             ; $A40C: D0 11
  LDA $0300                             ; $A40E: AD 00 03
  CMP #$FF                              ; $A411: C9 FF
  BNE $A41F                             ; $A413: D0 0A
  LDA $0304                             ; $A415: AD 04 03
  CMP #$FF                              ; $A418: C9 FF
  BNE $A41F                             ; $A41A: D0 03
  INC $0402                             ; $A41C: EE 02 04
Loc_A41F:
  RTS                                   ; $A41F: 60
Loc_A420:  ; (dispatch callback target)
  LDA #$01                              ; $A420: A9 01
  STA $0401                             ; $A422: 8D 01 04
  JSR $A429                             ; $A425: 20 29 A4
  RTS                                   ; $A428: 60
Loc_A429:
  LDA #$1D                              ; $A429: A9 1D
Loc_A42B:
  PHA                                   ; $A42B: 48
  JSR $F2AF                             ; $A42C: 20 AF F2
  LDA $0000                             ; $A42F: AD 00 00
  STA $0010                             ; $A432: 8D 10 00
  LDA $0001                             ; $A435: AD 01 00
  STA $0011                             ; $A438: 8D 11 00
  LDY #$06                              ; $A43B: A0 06
  LDA ($10),Y                           ; $A43D: B1 10
  PHA                                   ; $A43F: 48
  INY                                   ; $A440: C8
  LDA ($10),Y                           ; $A441: B1 10
  AND #$7F                              ; $A443: 29 7F
  PHA                                   ; $A445: 48
  LDY #$0E                              ; $A446: A0 0E
  LDA ($10),Y                           ; $A448: B1 10
  STA $0000                             ; $A44A: 8D 00 00
  INY                                   ; $A44D: C8
  LDA ($10),Y                           ; $A44E: B1 10
  AND #$03                              ; $A450: 29 03
  STA $0001                             ; $A452: 8D 01 00
  LDA #$00                              ; $A455: A9 00
  STA $0002                             ; $A457: 8D 02 00
  STA $0004                             ; $A45A: 8D 04 00
  LDY $6F02                             ; $A45D: AC 02 6F
  LDA $A527,Y                           ; $A460: B9 27 A5
  STA $0003                             ; $A463: 8D 03 00
  JSR $EAA5                             ; $A466: 20 A5 EA
  LDY $6F02                             ; $A469: AC 02 6F
  LDA $0000                             ; $A46C: AD 00 00
  CLC                                   ; $A46F: 18
  ADC $A524,Y                           ; $A470: 79 24 A5
  STA $0003                             ; $A473: 8D 03 00
  LDA $0001                             ; $A476: AD 01 00
  ADC #$00                              ; $A479: 69 00
  STA $0004                             ; $A47B: 8D 04 00
  PLA                                   ; $A47E: 68
  STA $0001                             ; $A47F: 8D 01 00
  PLA                                   ; $A482: 68
  STA $0000                             ; $A483: 8D 00 00
  LDA #$00                              ; $A486: A9 00
  STA $0002                             ; $A488: 8D 02 00
  JSR $EC22                             ; $A48B: 20 22 EC
  LDA $0006                             ; $A48E: AD 06 00
  STA $0000                             ; $A491: 8D 00 00
  LDA $0007                             ; $A494: AD 07 00
  STA $0001                             ; $A497: 8D 01 00
  LDA $0008                             ; $A49A: AD 08 00
  STA $0002                             ; $A49D: 8D 02 00
  LDA #$50                              ; $A4A0: A9 50
  STA $0003                             ; $A4A2: 8D 03 00
  LDA #$00                              ; $A4A5: A9 00
  STA $0004                             ; $A4A7: 8D 04 00
  JSR $EAA5                             ; $A4AA: 20 A5 EA
  LDY #$0B                              ; $A4AD: A0 0B
  LDA ($10),Y                           ; $A4AF: B1 10
  AND #$7F                              ; $A4B1: 29 7F
  LDY #$32                              ; $A4B3: A0 32
  CMP #$33                              ; $A4B5: C9 33
  BCC $A4D3                             ; $A4B7: 90 1A
  LDY #$3C                              ; $A4B9: A0 3C
  CMP #$47                              ; $A4BB: C9 47
  BCC $A4D3                             ; $A4BD: 90 14
  LDY #$46                              ; $A4BF: A0 46
  CMP #$51                              ; $A4C1: C9 51
  BCC $A4D3                             ; $A4C3: 90 0E
  LDY #$50                              ; $A4C5: A0 50
  CMP #$5B                              ; $A4C7: C9 5B
  BCC $A4D3                             ; $A4C9: 90 08
  LDY #$5A                              ; $A4CB: A0 5A
  CMP #$64                              ; $A4CD: C9 64
  BCC $A4D3                             ; $A4CF: 90 02
  LDY #$64                              ; $A4D1: A0 64
Loc_A4D3:
  STY $0003                             ; $A4D3: 8C 03 00
  LDA #$00                              ; $A4D6: A9 00
  STA $0004                             ; $A4D8: 8D 04 00
  JSR $EC22                             ; $A4DB: 20 22 EC
  LDA $0006                             ; $A4DE: AD 06 00
  STA $0000                             ; $A4E1: 8D 00 00
  LDA $0007                             ; $A4E4: AD 07 00
  STA $0001                             ; $A4E7: 8D 01 00
  LDA $0008                             ; $A4EA: AD 08 00
  STA $0002                             ; $A4ED: 8D 02 00
  LDA #$64                              ; $A4F0: A9 64
  STA $0003                             ; $A4F2: 8D 03 00
  LDA #$00                              ; $A4F5: A9 00
  STA $0004                             ; $A4F7: 8D 04 00
  JSR $EAA5                             ; $A4FA: 20 A5 EA
  LDY #$02                              ; $A4FD: A0 02
  LDA ($10),Y                           ; $A4FF: B1 10
  CLC                                   ; $A501: 18
  ADC $0000                             ; $A502: 6D 00 00
  STA ($10),Y                           ; $A505: 91 10
  INY                                   ; $A507: C8
  LDA ($10),Y                           ; $A508: B1 10
  ADC $0001                             ; $A50A: 6D 01 00
  STA ($10),Y                           ; $A50D: 91 10
  LDY #$02                              ; $A50F: A0 02
  JSR $A52A                             ; $A511: 20 2A A5
  JSR $A540                             ; $A514: 20 40 A5
  JSR $A582                             ; $A517: 20 82 A5
  PLA                                   ; $A51A: 68
  SEC                                   ; $A51B: 38
  SBC #$01                              ; $A51C: E9 01
  BMI $A523                             ; $A51E: 30 03
  JMP $A42B                             ; $A520: 4C 2B A4
Loc_A523:
  RTS                                   ; $A523: 60
; --- Data Region ---
  .byte $64,$3C,$3C,$03,$03,$04           ; $A524: 64 3C 3C 03 03 04
Loc_A52A:
; --- Code Region ---
  LDA ($10),Y                           ; $A52A: B1 10
  SEC                                   ; $A52C: 38
  SBC #$10                              ; $A52D: E9 10
  INY                                   ; $A52F: C8
  LDA ($10),Y                           ; $A530: B1 10
  SBC #$27                              ; $A532: E9 27
  BCC $A53F                             ; $A534: 90 09
  LDA #$27                              ; $A536: A9 27
  STA ($10),Y                           ; $A538: 91 10
  DEY                                   ; $A53A: 88
  LDA #$0F                              ; $A53B: A9 0F
  STA ($10),Y                           ; $A53D: 91 10
Loc_A53F:
  RTS                                   ; $A53F: 60
Loc_A540:
  RTS                                   ; $A540: 60
; --- Data Region ---
  .byte $A0,$02,$B1,$10,$38,$E9,$10,$C8,$B1,$10,$E9,$27,$90,$01,$00; $A541: A0 02 B1 10 38 E9 10 C8 B1 10 E9 27 90 01 00
Loc_A550:
; --- Code Region ---
  LDY #$04                              ; $A550: A0 04
  LDA ($10),Y                           ; $A552: B1 10
  SEC                                   ; $A554: 38
  SBC #$10                              ; $A555: E9 10
  INY                                   ; $A557: C8
  LDA ($10),Y                           ; $A558: B1 10
  SBC #$27                              ; $A55A: E9 27
  BCC $A55F                             ; $A55C: 90 01
  BRK                                   ; $A55E: 00
Loc_A55F:
  LDY #$0C                              ; $A55F: A0 0C
  LDA ($10),Y                           ; $A561: B1 10
  SEC                                   ; $A563: 38
  SBC #$10                              ; $A564: E9 10
  INY                                   ; $A566: C8
  LDA ($10),Y                           ; $A567: B1 10
  SBC #$27                              ; $A569: E9 27
  BCC $A56E                             ; $A56B: 90 01
  BRK                                   ; $A56D: 00
Loc_A56E:
  LDY #$00                              ; $A56E: A0 00
  LDA ($10),Y                           ; $A570: B1 10
  AND #$0F                              ; $A572: 29 0F
  CMP #$07                              ; $A574: C9 07
  BNE $A581                             ; $A576: D0 09
  LDY #$11                              ; $A578: A0 11
  LDA ($10),Y                           ; $A57A: B1 10
  CMP #$FF                              ; $A57C: C9 FF
  BEQ $A581                             ; $A57E: F0 01
  BRK                                   ; $A580: 00
Loc_A581:
  RTS                                   ; $A581: 60
Loc_A582:
  RTS                                   ; $A582: 60
; --- Data Region ---
  .byte $A9,$11                           ; $A583: A9 11
Loc_A585:
; --- Code Region ---
  PHA                                   ; $A585: 48
  TAY                                   ; $A586: A8
  CPY #$1B                              ; $A587: C0 1B
  BCS $A5A8                             ; $A589: B0 1D
  LDA ($10),Y                           ; $A58B: B1 10
  CMP #$FF                              ; $A58D: C9 FF
  BEQ $A5A8                             ; $A58F: F0 17
  JSR $F2D7                             ; $A591: 20 D7 F2
  LDY #$0B                              ; $A594: A0 0B
  LDA ($00),Y                           ; $A596: B1 00
  AND #$03                              ; $A598: 29 03
  CMP #$02                              ; $A59A: C9 02
  BEQ $A5A1                             ; $A59C: F0 03
  PLA                                   ; $A59E: 68
  BRK                                   ; $A59F: 00
  RTS                                   ; $A5A0: 60
Loc_A5A1:
  PLA                                   ; $A5A1: 68
  CLC                                   ; $A5A2: 18
  ADC #$01                              ; $A5A3: 69 01
  JMP $A585                             ; $A5A5: 4C 85 A5
Loc_A5A8:
  PLA                                   ; $A5A8: 68
  RTS                                   ; $A5A9: 60
Loc_A5AA:  ; (dispatch callback target)
  LDA $0402                             ; $A5AA: AD 02 04
  JSR $EADE                             ; $A5AD: 20 DE EA
; --- Data Region ---
  .byte $B6,$A5,$C9,$A5,$E5,$A5,$A9,$BD,$20,$8B,$F2,$EE,$02,$04,$A9,$A6; $A5B0: B6 A5 C9 A5 E5 A5 A9 BD 20 8B F2 EE 02 04 A9 A6
  .byte $8D,$D6,$04,$A9,$1D,$8D,$A0,$04,$60; $A5C0: 8D D6 04 A9 1D 8D A0 04 60
Loc_A5C9:  ; (dispatch callback target)
; --- Code Region ---
  LDA $04A0                             ; $A5C9: AD A0 04
  BNE $A5E4                             ; $A5CC: D0 16
  LDA $0140                             ; $A5CE: AD 40 01
  BNE $A5E4                             ; $A5D1: D0 11
  LDA $0300                             ; $A5D3: AD 00 03
  CMP #$FF                              ; $A5D6: C9 FF
  BNE $A5E4                             ; $A5D8: D0 0A
  LDA $0304                             ; $A5DA: AD 04 03
  CMP #$FF                              ; $A5DD: C9 FF
  BNE $A5E4                             ; $A5DF: D0 03
  INC $0402                             ; $A5E1: EE 02 04
Loc_A5E4:
  RTS                                   ; $A5E4: 60
Loc_A5E5:  ; (dispatch callback target)
  LDA #$01                              ; $A5E5: A9 01
  STA $0401                             ; $A5E7: 8D 01 04
  JSR $A5EE                             ; $A5EA: 20 EE A5
  RTS                                   ; $A5ED: 60
Loc_A5EE:
  LDA #$1D                              ; $A5EE: A9 1D
Loc_A5F0:
  PHA                                   ; $A5F0: 48
  JSR $F2AF                             ; $A5F1: 20 AF F2
  LDA $0000                             ; $A5F4: AD 00 00
  STA $0010                             ; $A5F7: 8D 10 00
  LDA $0001                             ; $A5FA: AD 01 00
  STA $0011                             ; $A5FD: 8D 11 00
  LDY #$06                              ; $A600: A0 06
  LDA ($10),Y                           ; $A602: B1 10
  PHA                                   ; $A604: 48
  INY                                   ; $A605: C8
  LDA ($10),Y                           ; $A606: B1 10
  AND #$7F                              ; $A608: 29 7F
  PHA                                   ; $A60A: 48
  LDY #$08                              ; $A60B: A0 08
  LDA ($10),Y                           ; $A60D: B1 10
  STA $0000                             ; $A60F: 8D 00 00
  INY                                   ; $A612: C8
  LDA ($10),Y                           ; $A613: B1 10
  AND #$03                              ; $A615: 29 03
  STA $0001                             ; $A617: 8D 01 00
  LDA #$00                              ; $A61A: A9 00
  STA $0002                             ; $A61C: 8D 02 00
  STA $0004                             ; $A61F: 8D 04 00
  LDY $6F02                             ; $A622: AC 02 6F
  LDA $A6EC,Y                           ; $A625: B9 EC A6
  STA $0003                             ; $A628: 8D 03 00
  JSR $EAA5                             ; $A62B: 20 A5 EA
  LDY $6F02                             ; $A62E: AC 02 6F
  LDA $0000                             ; $A631: AD 00 00
  CLC                                   ; $A634: 18
  ADC $A6E9,Y                           ; $A635: 79 E9 A6
  STA $0003                             ; $A638: 8D 03 00
  LDA $0001                             ; $A63B: AD 01 00
  ADC #$00                              ; $A63E: 69 00
  STA $0004                             ; $A640: 8D 04 00
  PLA                                   ; $A643: 68
  STA $0001                             ; $A644: 8D 01 00
  PLA                                   ; $A647: 68
  STA $0000                             ; $A648: 8D 00 00
  LDA #$00                              ; $A64B: A9 00
  STA $0002                             ; $A64D: 8D 02 00
  JSR $EC22                             ; $A650: 20 22 EC
  LDA $0006                             ; $A653: AD 06 00
  STA $0000                             ; $A656: 8D 00 00
  LDA $0007                             ; $A659: AD 07 00
  STA $0001                             ; $A65C: 8D 01 00
  LDA $0008                             ; $A65F: AD 08 00
  STA $0002                             ; $A662: 8D 02 00
  LDA #$3C                              ; $A665: A9 3C
  STA $0003                             ; $A667: 8D 03 00
  LDA #$00                              ; $A66A: A9 00
  STA $0004                             ; $A66C: 8D 04 00
  JSR $EAA5                             ; $A66F: 20 A5 EA
  LDY #$0B                              ; $A672: A0 0B
  LDA ($10),Y                           ; $A674: B1 10
  AND #$7F                              ; $A676: 29 7F
  LDY #$32                              ; $A678: A0 32
  CMP #$33                              ; $A67A: C9 33
  BCC $A698                             ; $A67C: 90 1A
  LDY #$3C                              ; $A67E: A0 3C
  CMP #$47                              ; $A680: C9 47
  BCC $A698                             ; $A682: 90 14
  LDY #$46                              ; $A684: A0 46
  CMP #$51                              ; $A686: C9 51
  BCC $A698                             ; $A688: 90 0E
  LDY #$50                              ; $A68A: A0 50
  CMP #$5B                              ; $A68C: C9 5B
  BCC $A698                             ; $A68E: 90 08
  LDY #$5A                              ; $A690: A0 5A
  CMP #$64                              ; $A692: C9 64
  BCC $A698                             ; $A694: 90 02
  LDY #$64                              ; $A696: A0 64
Loc_A698:
  STY $0003                             ; $A698: 8C 03 00
  LDA #$00                              ; $A69B: A9 00
  STA $0004                             ; $A69D: 8D 04 00
  JSR $EC22                             ; $A6A0: 20 22 EC
  LDA $0006                             ; $A6A3: AD 06 00
  STA $0000                             ; $A6A6: 8D 00 00
  LDA $0007                             ; $A6A9: AD 07 00
  STA $0001                             ; $A6AC: 8D 01 00
  LDA $0008                             ; $A6AF: AD 08 00
  STA $0002                             ; $A6B2: 8D 02 00
  LDA #$64                              ; $A6B5: A9 64
  STA $0003                             ; $A6B7: 8D 03 00
  LDA #$00                              ; $A6BA: A9 00
  STA $0004                             ; $A6BC: 8D 04 00
  JSR $EAA5                             ; $A6BF: 20 A5 EA
  LDY #$04                              ; $A6C2: A0 04
  LDA ($10),Y                           ; $A6C4: B1 10
  CLC                                   ; $A6C6: 18
  ADC $0000                             ; $A6C7: 6D 00 00
  STA ($10),Y                           ; $A6CA: 91 10
  INY                                   ; $A6CC: C8
  LDA ($10),Y                           ; $A6CD: B1 10
  ADC $0001                             ; $A6CF: 6D 01 00
  STA ($10),Y                           ; $A6D2: 91 10
  LDY #$04                              ; $A6D4: A0 04
  JSR $A52A                             ; $A6D6: 20 2A A5
  JSR $A540                             ; $A6D9: 20 40 A5
  JSR $A582                             ; $A6DC: 20 82 A5
  PLA                                   ; $A6DF: 68
  SEC                                   ; $A6E0: 38
  SBC #$01                              ; $A6E1: E9 01
  BMI $A6E8                             ; $A6E3: 30 03
  JMP $A5F0                             ; $A6E5: 4C F0 A5
Loc_A6E8:
  RTS                                   ; $A6E8: 60
; --- Data Region ---
  .byte $64,$3C,$3C,$03,$03,$04           ; $A6E9: 64 3C 3C 03 03 04
Loc_A6EF:  ; (dispatch callback target)
; --- Code Region ---
  LDA $0402                             ; $A6EF: AD 02 04
  JSR $EADE                             ; $A6F2: 20 DE EA
; --- Data Region ---
  .byte $FD,$A6,$20,$A7,$41,$A7,$5F,$A8,$A0,$00,$20,$96,$A8,$AD,$00,$00; $A6F5: FD A6 20 A7 41 A7 5F A8 A0 00 20 96 A8 AD 00 00
  .byte $D0,$06,$A9,$02,$8D,$01,$04,$60   ; $A705: D0 06 A9 02 8D 01 04 60
Loc_A70D:
; --- Code Region ---
  LDA #$BE                              ; $A70D: A9 BE
  JSR $F28B                             ; $A70F: 20 8B F2
  LDA #$9F                              ; $A712: A9 9F
  STA $04D6                             ; $A714: 8D D6 04
  LDA #$1C                              ; $A717: A9 1C
  STA $04A0                             ; $A719: 8D A0 04
  INC $0402                             ; $A71C: EE 02 04
  RTS                                   ; $A71F: 60
; --- Data Region ---
  .byte $AD,$A0,$04,$D0,$1B,$AD,$40,$01,$D0,$16,$AD,$00,$03,$C9,$FF,$D0; $A720: AD A0 04 D0 1B AD 40 01 D0 16 AD 00 03 C9 FF D0
  .byte $0F,$AD,$04,$03,$C9,$FF,$D0,$08,$A9,$00,$8D,$03,$04,$EE,$02,$04; $A730: 0F AD 04 03 C9 FF D0 08 A9 00 8D 03 04 EE 02 04
Loc_A740:
; --- Code Region ---
  RTS                                   ; $A740: 60
; --- Data Region ---
  .byte $AC,$03,$04,$B9,$2D,$04,$C9,$FF,$D0,$18; $A741: AC 03 04 B9 2D 04 C9 FF D0 18
Loc_A74B:
; --- Code Region ---
  INC $0403                             ; $A74B: EE 03 04
  LDA $0403                             ; $A74E: AD 03 04
  CMP #$10                              ; $A751: C9 10
  BCC $A762                             ; $A753: 90 0D
  LDA #$02                              ; $A755: A9 02
  STA $0401                             ; $A757: 8D 01 04
  LDA #$00                              ; $A75A: A9 00
  STA $00A4                             ; $A75C: 8D A4 00
  JSR $F28B                             ; $A75F: 20 8B F2
Loc_A762:
  RTS                                   ; $A762: 60
Loc_A763:
  JSR $F2AF                             ; $A763: 20 AF F2
  LDY #$00                              ; $A766: A0 00
  LDA ($00),Y                           ; $A768: B1 00
  AND #$07                              ; $A76A: 29 07
  CMP #$07                              ; $A76C: C9 07
  BEQ $A74B                             ; $A76E: F0 DB
  JSR $A8E0                             ; $A770: 20 E0 A8
  LDA $0010                             ; $A773: AD 10 00
  CMP #$0A                              ; $A776: C9 0A
  BNE $A789                             ; $A778: D0 0F
  LDA $0000                             ; $A77A: AD 00 00
  STA $000C                             ; $A77D: 8D 0C 00
  LDA $0001                             ; $A780: AD 01 00
  STA $000D                             ; $A783: 8D 0D 00
  JMP $A81B                             ; $A786: 4C 1B A8
Loc_A789:
  LDA $0000                             ; $A789: AD 00 00
  STA $000A                             ; $A78C: 8D 0A 00
  LDA $0001                             ; $A78F: AD 01 00
  STA $000B                             ; $A792: 8D 0B 00
  LDY #$06                              ; $A795: A0 06
  LDA ($0A),Y                           ; $A797: B1 0A
  STA $0000                             ; $A799: 8D 00 00
  INY                                   ; $A79C: C8
  LDA ($0A),Y                           ; $A79D: B1 0A
  STA $0001                             ; $A79F: 8D 01 00
  LSR $0001                             ; $A7A2: 4E 01 00
  ROR $0000                             ; $A7A5: 6E 00 00
  LSR $0001                             ; $A7A8: 4E 01 00
  ROR $0000                             ; $A7AB: 6E 00 00
  LDY #$06                              ; $A7AE: A0 06
  JSR $A93E                             ; $A7B0: 20 3E A9
  LDY #$08                              ; $A7B3: A0 08
  LDA ($0A),Y                           ; $A7B5: B1 0A
  STA $0000                             ; $A7B7: 8D 00 00
  INY                                   ; $A7BA: C8
  LDA ($0A),Y                           ; $A7BB: B1 0A
  STA $0001                             ; $A7BD: 8D 01 00
  LSR $0001                             ; $A7C0: 4E 01 00
  ROR $0000                             ; $A7C3: 6E 00 00
  LSR $0001                             ; $A7C6: 4E 01 00
  ROR $0000                             ; $A7C9: 6E 00 00
  LDY #$08                              ; $A7CC: A0 08
  JSR $A93E                             ; $A7CE: 20 3E A9
  LDA $000A                             ; $A7D1: AD 0A 00
  STA $000C                             ; $A7D4: 8D 0C 00
  LDA $000B                             ; $A7D7: AD 0B 00
  STA $000D                             ; $A7DA: 8D 0D 00
  LDY #$11                              ; $A7DD: A0 11
Loc_A7DF:
  TYA                                   ; $A7DF: 98
  PHA                                   ; $A7E0: 48
  LDA ($0C),Y                           ; $A7E1: B1 0C
  CMP #$FF                              ; $A7E3: C9 FF
  BEQ $A814                             ; $A7E5: F0 2D
  JSR $F2D7                             ; $A7E7: 20 D7 F2
  LDA $0000                             ; $A7EA: AD 00 00
  STA $000A                             ; $A7ED: 8D 0A 00
  LDA $0001                             ; $A7F0: AD 01 00
  STA $000B                             ; $A7F3: 8D 0B 00
  LDY #$08                              ; $A7F6: A0 08
  LDA ($0A),Y                           ; $A7F8: B1 0A
  STA $0000                             ; $A7FA: 8D 00 00
  INY                                   ; $A7FD: C8
  LDA ($0A),Y                           ; $A7FE: B1 0A
  STA $0001                             ; $A800: 8D 01 00
  LSR $0001                             ; $A803: 4E 01 00
  ROR $0000                             ; $A806: 6E 00 00
  LSR $0001                             ; $A809: 4E 01 00
  ROR $0000                             ; $A80C: 6E 00 00
  LDY #$08                              ; $A80F: A0 08
  JSR $A93E                             ; $A811: 20 3E A9
Loc_A814:
  PLA                                   ; $A814: 68
  TAY                                   ; $A815: A8
  INY                                   ; $A816: C8
  CPY #$1B                              ; $A817: C0 1B
  BCC $A7DF                             ; $A819: 90 C4
Loc_A81B:
  LDY #$00                              ; $A81B: A0 00
  LDA ($0C),Y                           ; $A81D: B1 0C
  JSR $F368                             ; $A81F: 20 68 F3
  LDY #$03                              ; $A822: A0 03
  LDA ($00),Y                           ; $A824: B1 00
  CMP #$03                              ; $A826: C9 03
  BNE $A82D                             ; $A828: D0 03
  JMP $A74B                             ; $A82A: 4C 4B A7
Loc_A82D:
  STA $6F44                             ; $A82D: 8D 44 6F
  INC $0402                             ; $A830: EE 02 04
  LDY $0403                             ; $A833: AC 03 04
  LDA $042D,Y                           ; $A836: B9 2D 04
  STA $042C                             ; $A839: 8D 2C 04
  STA $0472                             ; $A83C: 8D 72 04
  LDA $0010                             ; $A83F: AD 10 00
  STA $0470                             ; $A842: 8D 70 04
  LDA $0011                             ; $A845: AD 11 00
  STA $0471                             ; $A848: 8D 71 04
  STA $0000                             ; $A84B: 8D 00 00
  LDA #$04                              ; $A84E: A9 04
  STA $00A4                             ; $A850: 8D A4 00
  LDY #$3D                              ; $A853: A0 3D
  JSR $EE07                             ; $A855: 20 07 EE
; --- Data Region ---
  .byte $2A,$A0,$A9,$3F,$4C,$6D,$F2,$20,$85,$A9,$AD,$00,$03,$C9,$FF,$D0; $A858: 2A A0 A9 3F 4C 6D F2 20 85 A9 AD 00 03 C9 FF D0
  .byte $2C,$AD,$04,$03,$C9,$FF,$D0,$25,$20,$C2,$A1,$AD,$81,$00,$4A,$90; $A868: 2C AD 04 03 C9 FF D0 25 20 C2 A1 AD 81 00 4A 90
  .byte $1C,$AD,$70,$04,$C9,$0A,$F0,$06,$CE,$02,$04,$4C,$4B,$A7; $A878: 1C AD 70 04 C9 0A F0 06 CE 02 04 4C 4B A7
Loc_A886:
; --- Code Region ---
  LDA #$00                              ; $A886: A9 00
  STA $0470                             ; $A888: 8D 70 04
  LDA #$03                              ; $A88B: A9 03
  STA $00A4                             ; $A88D: 8D A4 00
  LDA #$4D                              ; $A890: A9 4D
  JSR $F26D                             ; $A892: 20 6D F2
Loc_A895:
  RTS                                   ; $A895: 60
Loc_A896:
  LDX #$10                              ; $A896: A2 10
  LDA #$FF                              ; $A898: A9 FF
Loc_A89A:
  STA $042C,X                           ; $A89A: 9D 2C 04
  DEX                                   ; $A89D: CA
  BPL $A89A                             ; $A89E: 10 FA
  LDX #$00                              ; $A8A0: A2 00
  STX $0000                             ; $A8A2: 8E 00 00
Loc_A8A5:
  JSR $E856                             ; $A8A5: 20 56 E8
  CMP #$06                              ; $A8A8: C9 06
  BCS $A8A5                             ; $A8AA: B0 F9
  CMP #$00                              ; $A8AC: C9 00
  BNE $A8B9                             ; $A8AE: D0 09
  LDA $A8C0,Y                           ; $A8B0: B9 C0 A8
  STA $042D,X                           ; $A8B3: 9D 2D 04
  INC $0000                             ; $A8B6: EE 00 00
Loc_A8B9:
  INY                                   ; $A8B9: C8
  INX                                   ; $A8BA: E8
  CPX #$10                              ; $A8BB: E0 10
  BCC $A8A5                             ; $A8BD: 90 E6
  RTS                                   ; $A8BF: 60
; --- Data Region ---
  .byte $01,$02,$05,$06,$07,$08,$09,$0D,$11,$15,$18,$19,$1A,$1C,$1D,$FF; $A8C0: 01 02 05 06 07 08 09 0D 11 15 18 19 1A 1C 1D FF
  .byte $00,$03,$04,$0A,$0B,$0C,$0E,$0F,$10,$12,$13,$14,$16,$17,$1B,$FF; $A8D0: 00 03 04 0A 0B 0C 0E 0F 10 12 13 14 16 17 1B FF
Loc_A8E0:
; --- Code Region ---
  LDY #$0A                              ; $A8E0: A0 0A
  LDA ($00),Y                           ; $A8E2: B1 00
  LDX #$0A                              ; $A8E4: A2 0A
  LDY #$0A                              ; $A8E6: A0 0A
  CMP #$63                              ; $A8E8: C9 63
  BEQ $A910                             ; $A8EA: F0 24
  LDX #$08                              ; $A8EC: A2 08
  LDY #$07                              ; $A8EE: A0 07
  CMP #$50                              ; $A8F0: C9 50
  BCS $A910                             ; $A8F2: B0 1C
  LDX #$06                              ; $A8F4: A2 06
  LDY #$05                              ; $A8F6: A0 05
  CMP #$32                              ; $A8F8: C9 32
  BCS $A910                             ; $A8FA: B0 14
  LDX #$04                              ; $A8FC: A2 04
  LDY #$01                              ; $A8FE: A0 01
  CMP #$14                              ; $A900: C9 14
  BCS $A910                             ; $A902: B0 0C
  LDX #$02                              ; $A904: A2 02
  LDY #$00                              ; $A906: A0 00
  CMP #$01                              ; $A908: C9 01
  BCS $A910                             ; $A90A: B0 04
  LDX #$00                              ; $A90C: A2 00
  LDY #$00                              ; $A90E: A0 00
Loc_A910:
  STX $0010                             ; $A910: 8E 10 00
  STY $0011                             ; $A913: 8C 11 00
  CPY #$00                              ; $A916: C0 00
  BEQ $A936                             ; $A918: F0 1C
Loc_A91A:
  JSR $E856                             ; $A91A: 20 56 E8
  CMP #$06                              ; $A91D: C9 06
  BCS $A91A                             ; $A91F: B0 F9
  CLC                                   ; $A921: 18
  ADC $0011                             ; $A922: 6D 11 00
  BNE $A929                             ; $A925: D0 02
  LDA #$01                              ; $A927: A9 01
Loc_A929:
  STA $0011                             ; $A929: 8D 11 00
  LDY #$0A                              ; $A92C: A0 0A
  LDA ($00),Y                           ; $A92E: B1 00
  SEC                                   ; $A930: 38
  SBC $0011                             ; $A931: ED 11 00
  STA ($00),Y                           ; $A934: 91 00
Loc_A936:
  LDY #$11                              ; $A936: A0 11
  LDA ($00),Y                           ; $A938: B1 00
  STA $0011                             ; $A93A: 8D 11 00
  RTS                                   ; $A93D: 60
Loc_A93E:
  LDA $0010                             ; $A93E: AD 10 00
  BEQ $A974                             ; $A941: F0 31
  TYA                                   ; $A943: 98
  PHA                                   ; $A944: 48
  LDA $0010                             ; $A945: AD 10 00
  STA $0003                             ; $A948: 8D 03 00
  LDA #$00                              ; $A94B: A9 00
  STA $0002                             ; $A94D: 8D 02 00
  JSR $EBE9                             ; $A950: 20 E9 EB
  LDA $0006                             ; $A953: AD 06 00
  STA $0000                             ; $A956: 8D 00 00
  LDA $0007                             ; $A959: AD 07 00
  STA $0001                             ; $A95C: 8D 01 00
  LDA $0008                             ; $A95F: AD 08 00
  STA $0002                             ; $A962: 8D 02 00
  LDA #$0A                              ; $A965: A9 0A
  STA $0003                             ; $A967: 8D 03 00
  LDA #$00                              ; $A96A: A9 00
  STA $0004                             ; $A96C: 8D 04 00
  JSR $EAA5                             ; $A96F: 20 A5 EA
  PLA                                   ; $A972: 68
  TAY                                   ; $A973: A8
Loc_A974:
  LDA ($0A),Y                           ; $A974: B1 0A
  SEC                                   ; $A976: 38
  SBC $0000                             ; $A977: ED 00 00
  STA ($0A),Y                           ; $A97A: 91 0A
  INY                                   ; $A97C: C8
  LDA ($0A),Y                           ; $A97D: B1 0A
  SBC $0001                             ; $A97F: ED 01 00
  STA ($0A),Y                           ; $A982: 91 0A
  RTS                                   ; $A984: 60
Loc_A985:
  LDA $0472                             ; $A985: AD 72 04
  JSR $BBE7                             ; $A988: 20 E7 BB
  LDA $0471                             ; $A98B: AD 71 04
  CMP #$FF                              ; $A98E: C9 FF
  BEQ $A99F                             ; $A990: F0 0D
  STA $0000                             ; $A992: 8D 00 00
  LDA #$A7                              ; $A995: A9 A7
  STA $000A                             ; $A997: 8D 0A 00
  LDX #$00                              ; $A99A: A2 00
  JSR $CE1F                             ; $A99C: 20 1F CE
Loc_A99F:
  RTS                                   ; $A99F: 60
Loc_A9A0:  ; (dispatch callback target)
  LDA $0402                             ; $A9A0: AD 02 04
  JSR $EADE                             ; $A9A3: 20 DE EA
  LDX $D1A9                             ; $A9A6: AE A9 D1
; --- Data Region ---
  .byte $A9,$F2,$A9,$DE,$AA               ; $A9A9: A9 F2 A9 DE AA
Loc_A9AE:  ; (dispatch callback target)
; --- Code Region ---
  LDY #$10                              ; $A9AE: A0 10
  JSR $A896                             ; $A9B0: 20 96 A8
  LDA $0000                             ; $A9B3: AD 00 00
  BNE $A9BE                             ; $A9B6: D0 06
  LDA #$02                              ; $A9B8: A9 02
  STA $0401                             ; $A9BA: 8D 01 04
  RTS                                   ; $A9BD: 60
Loc_A9BE:
  LDA #$BF                              ; $A9BE: A9 BF
  JSR $F28B                             ; $A9C0: 20 8B F2
  LDA #$9F                              ; $A9C3: A9 9F
  STA $04D6                             ; $A9C5: 8D D6 04
  LDA #$1E                              ; $A9C8: A9 1E
  STA $04A0                             ; $A9CA: 8D A0 04
  INC $0402                             ; $A9CD: EE 02 04
  RTS                                   ; $A9D0: 60
Loc_A9D1:  ; (dispatch callback target)
  LDA $04A0                             ; $A9D1: AD A0 04
  BNE $A9F1                             ; $A9D4: D0 1B
  LDA $0140                             ; $A9D6: AD 40 01
  BNE $A9F1                             ; $A9D9: D0 16
  LDA $0300                             ; $A9DB: AD 00 03
  CMP #$FF                              ; $A9DE: C9 FF
  BNE $A9F1                             ; $A9E0: D0 0F
  LDA $0304                             ; $A9E2: AD 04 03
  CMP #$FF                              ; $A9E5: C9 FF
  BNE $A9F1                             ; $A9E7: D0 08
  LDA #$00                              ; $A9E9: A9 00
  STA $0403                             ; $A9EB: 8D 03 04
  INC $0402                             ; $A9EE: EE 02 04
Loc_A9F1:
  RTS                                   ; $A9F1: 60
Loc_A9F2:  ; (dispatch callback target)
  LDY $0403                             ; $A9F2: AC 03 04
  LDA $042D,Y                           ; $A9F5: B9 2D 04
  CMP #$FF                              ; $A9F8: C9 FF
  BNE $AA14                             ; $A9FA: D0 18
Loc_A9FC:
  INC $0403                             ; $A9FC: EE 03 04
  LDA $0403                             ; $A9FF: AD 03 04
  CMP #$10                              ; $AA02: C9 10
  BCC $AA13                             ; $AA04: 90 0D
  LDA #$02                              ; $AA06: A9 02
  STA $0401                             ; $AA08: 8D 01 04
  LDA #$00                              ; $AA0B: A9 00
  STA $00A4                             ; $AA0D: 8D A4 00
  JSR $F28B                             ; $AA10: 20 8B F2
Loc_AA13:
  RTS                                   ; $AA13: 60
Loc_AA14:
  JSR $F2AF                             ; $AA14: 20 AF F2
  LDY #$00                              ; $AA17: A0 00
  LDA ($00),Y                           ; $AA19: B1 00
  AND #$07                              ; $AA1B: 29 07
  CMP #$07                              ; $AA1D: C9 07
  BEQ $A9FC                             ; $AA1F: F0 DB
  JSR $A8E0                             ; $AA21: 20 E0 A8
  LDA $0010                             ; $AA24: AD 10 00
  CMP #$0A                              ; $AA27: C9 0A
  BNE $AA3A                             ; $AA29: D0 0F
  LDA $0000                             ; $AA2B: AD 00 00
  STA $000A                             ; $AA2E: 8D 0A 00
  LDA $0001                             ; $AA31: AD 01 00
  STA $000B                             ; $AA34: 8D 0B 00
  JMP $AA9A                             ; $AA37: 4C 9A AA
Loc_AA3A:
  LDA $0000                             ; $AA3A: AD 00 00
  STA $000A                             ; $AA3D: 8D 0A 00
  LDA $0001                             ; $AA40: AD 01 00
  STA $000B                             ; $AA43: 8D 0B 00
  LDY #$06                              ; $AA46: A0 06
  LDA ($0A),Y                           ; $AA48: B1 0A
  STA $0000                             ; $AA4A: 8D 00 00
  INY                                   ; $AA4D: C8
  LDA ($0A),Y                           ; $AA4E: B1 0A
  STA $0001                             ; $AA50: 8D 01 00
  LSR $0001                             ; $AA53: 4E 01 00
  ROR $0000                             ; $AA56: 6E 00 00
  LSR $0001                             ; $AA59: 4E 01 00
  ROR $0000                             ; $AA5C: 6E 00 00
  LDY #$06                              ; $AA5F: A0 06
  JSR $A93E                             ; $AA61: 20 3E A9
  LDY #$0E                              ; $AA64: A0 0E
  LDA ($0A),Y                           ; $AA66: B1 0A
  STA $0000                             ; $AA68: 8D 00 00
  INY                                   ; $AA6B: C8
  LDA ($0A),Y                           ; $AA6C: B1 0A
  STA $0001                             ; $AA6E: 8D 01 00
  LSR $0001                             ; $AA71: 4E 01 00
  ROR $0000                             ; $AA74: 6E 00 00
  LSR $0001                             ; $AA77: 4E 01 00
  ROR $0000                             ; $AA7A: 6E 00 00
  LDY #$0E                              ; $AA7D: A0 0E
  JSR $A93E                             ; $AA7F: 20 3E A9
  LDY #$04                              ; $AA82: A0 04
  LDA ($0A),Y                           ; $AA84: B1 0A
  STA $0000                             ; $AA86: 8D 00 00
  INY                                   ; $AA89: C8
  LDA ($0A),Y                           ; $AA8A: B1 0A
  STA $0001                             ; $AA8C: 8D 01 00
  LSR $0001                             ; $AA8F: 4E 01 00
  ROR $0000                             ; $AA92: 6E 00 00
  LDY #$04                              ; $AA95: A0 04
  JSR $A93E                             ; $AA97: 20 3E A9
Loc_AA9A:
  LDY #$00                              ; $AA9A: A0 00
  LDA ($0A),Y                           ; $AA9C: B1 0A
  JSR $F368                             ; $AA9E: 20 68 F3
  LDY #$03                              ; $AAA1: A0 03
  LDA ($00),Y                           ; $AAA3: B1 00
  CMP #$03                              ; $AAA5: C9 03
  BNE $AAAC                             ; $AAA7: D0 03
  JMP $A9FC                             ; $AAA9: 4C FC A9
Loc_AAAC:
  STA $6F44                             ; $AAAC: 8D 44 6F
  INC $0402                             ; $AAAF: EE 02 04
  LDY $0403                             ; $AAB2: AC 03 04
  LDA $042D,Y                           ; $AAB5: B9 2D 04
  STA $042C                             ; $AAB8: 8D 2C 04
  STA $0472                             ; $AABB: 8D 72 04
  LDA $0010                             ; $AABE: AD 10 00
  STA $0470                             ; $AAC1: 8D 70 04
  LDA $0011                             ; $AAC4: AD 11 00
  STA $0471                             ; $AAC7: 8D 71 04
  STA $0000                             ; $AACA: 8D 00 00
  LDY #$3D                              ; $AACD: A0 3D
  JSR $EE07                             ; $AACF: 20 07 EE
; --- Data Region ---
  .byte $2A,$A0,$A9,$04,$8D,$A4,$00,$A9,$45,$4C,$6D,$F2; $AAD2: 2A A0 A9 04 8D A4 00 A9 45 4C 6D F2
Loc_AADE:  ; (dispatch callback target)
; --- Code Region ---
  JSR $A985                             ; $AADE: 20 85 A9
  LDA $0300                             ; $AAE1: AD 00 03
  CMP #$FF                              ; $AAE4: C9 FF
  BNE $AB14                             ; $AAE6: D0 2C
  LDA $0304                             ; $AAE8: AD 04 03
  CMP #$FF                              ; $AAEB: C9 FF
  BNE $AB14                             ; $AAED: D0 25
  JSR $A1C2                             ; $AAEF: 20 C2 A1
  LDA $0081                             ; $AAF2: AD 81 00
  LSR                                   ; $AAF5: 4A
  BCC $AB14                             ; $AAF6: 90 1C
  LDA $0470                             ; $AAF8: AD 70 04
  CMP #$0A                              ; $AAFB: C9 0A
  BEQ $AB05                             ; $AAFD: F0 06
  DEC $0402                             ; $AAFF: CE 02 04
  JMP $A9FC                             ; $AB02: 4C FC A9
Loc_AB05:
  LDA #$00                              ; $AB05: A9 00
  STA $0470                             ; $AB07: 8D 70 04
  LDA #$03                              ; $AB0A: A9 03
  STA $00A4                             ; $AB0C: 8D A4 00
  LDA #$4D                              ; $AB0F: A9 4D
  JSR $F26D                             ; $AB11: 20 6D F2
Loc_AB14:
  RTS                                   ; $AB14: 60
Loc_AB15:  ; (dispatch callback target)
  LDA $0402                             ; $AB15: AD 02 04
  JSR $EADE                             ; $AB18: 20 DE EA
; --- Data Region ---
  .byte $25,$AB,$A9,$AB,$4D,$AC,$9A,$AC,$BD,$AC; $AB1B: 25 AB A9 AB 4D AC 9A AC BD AC
Loc_AB25:  ; (dispatch callback target)
; --- Code Region ---
  LDA $6F00                             ; $AB25: AD 00 6F
  CMP #$59                              ; $AB28: C9 59
  BNE $AB39                             ; $AB2A: D0 0D
  LDA $6F01                             ; $AB2C: AD 01 6F
  CMP #$04                              ; $AB2F: C9 04
  BCS $AB39                             ; $AB31: B0 06
  LDA #$01                              ; $AB33: A9 01
  STA $0401                             ; $AB35: 8D 01 04
  RTS                                   ; $AB38: 60
Loc_AB39:
  LDX #$00                              ; $AB39: A2 00
  LDA #$00                              ; $AB3B: A9 00
Loc_AB3D:
  STA $042C,X                           ; $AB3D: 9D 2C 04
  INX                                   ; $AB40: E8
  CPX #$1E                              ; $AB41: E0 1E
  BCC $AB3D                             ; $AB43: 90 F8
  LDX #$00                              ; $AB45: A2 00
Loc_AB47:
  TXA                                   ; $AB47: 8A
  JSR $F2AF                             ; $AB48: 20 AF F2
  LDY #$00                              ; $AB4B: A0 00
  LDA ($00),Y                           ; $AB4D: B1 00
  AND #$0F                              ; $AB4F: 29 0F
  CMP #$07                              ; $AB51: C9 07
  BEQ $AB60                             ; $AB53: F0 0B
  LDY #$1B                              ; $AB55: A0 1B
  LDA ($00),Y                           ; $AB57: B1 00
  BEQ $AB6E                             ; $AB59: F0 13
  SEC                                   ; $AB5B: 38
  SBC #$01                              ; $AB5C: E9 01
  STA ($00),Y                           ; $AB5E: 91 00
Loc_AB60:
  INX                                   ; $AB60: E8
  CPX #$1E                              ; $AB61: E0 1E
  BCC $AB47                             ; $AB63: 90 E2
  INC $0402                             ; $AB65: EE 02 04
  LDA #$00                              ; $AB68: A9 00
  STA $0403                             ; $AB6A: 8D 03 04
  RTS                                   ; $AB6D: 60
Loc_AB6E:
  LDY #$0B                              ; $AB6E: A0 0B
  LDA ($00),Y                           ; $AB70: B1 00
  CMP #$32                              ; $AB72: C9 32
  BCS $AB60                             ; $AB74: B0 EA
  LDY #$05                              ; $AB76: A0 05
  CMP #$28                              ; $AB78: C9 28
  BCS $AB8A                             ; $AB7A: B0 0E
  LDY #$0A                              ; $AB7C: A0 0A
  CMP #$1E                              ; $AB7E: C9 1E
  BCS $AB8A                             ; $AB80: B0 08
  LDY #$1E                              ; $AB82: A0 1E
  CMP #$14                              ; $AB84: C9 14
  BCS $AB8A                             ; $AB86: B0 02
  LDY #$32                              ; $AB88: A0 32
Loc_AB8A:
  STY $0011                             ; $AB8A: 8C 11 00
  LDA #$64                              ; $AB8D: A9 64
  JSR $E862                             ; $AB8F: 20 62 E8
  CMP $0011                             ; $AB92: CD 11 00
  BCC $AB9A                             ; $AB95: 90 03
  JMP $AB60                             ; $AB97: 4C 60 AB
Loc_AB9A:
  LDA $0011                             ; $AB9A: AD 11 00
  STA $042C,X                           ; $AB9D: 9D 2C 04
  LDY #$1B                              ; $ABA0: A0 1B
  LDA #$06                              ; $ABA2: A9 06
  STA ($00),Y                           ; $ABA4: 91 00
  JMP $AB60                             ; $ABA6: 4C 60 AB
Loc_ABA9:  ; (dispatch callback target)
  LDY $0403                             ; $ABA9: AC 03 04
  LDA $042C,Y                           ; $ABAC: B9 2C 04
  BNE $ABC9                             ; $ABAF: D0 18
Loc_ABB1:
  INC $0403                             ; $ABB1: EE 03 04
  LDA $0403                             ; $ABB4: AD 03 04
  CMP #$1E                              ; $ABB7: C9 1E
  BCC $ABC8                             ; $ABB9: 90 0D
  LDA #$01                              ; $ABBB: A9 01
  STA $0401                             ; $ABBD: 8D 01 04
  LDA #$00                              ; $ABC0: A9 00
  STA $00A4                             ; $ABC2: 8D A4 00
  JSR $F28B                             ; $ABC5: 20 8B F2
Loc_ABC8:
  RTS                                   ; $ABC8: 60
Loc_ABC9:
  STA $0470                             ; $ABC9: 8D 70 04
  TYA                                   ; $ABCC: 98
  JSR $F2AF                             ; $ABCD: 20 AF F2
  LDA $0000                             ; $ABD0: AD 00 00
  STA $000A                             ; $ABD3: 8D 0A 00
  LDA $0001                             ; $ABD6: AD 01 00
  STA $000B                             ; $ABD9: 8D 0B 00
Loc_ABDC:
  JSR $E850                             ; $ABDC: 20 50 E8
  BEQ $ABDC                             ; $ABDF: F0 FB
  STA $0010                             ; $ABE1: 8D 10 00
  CMP #$01                              ; $ABE4: C9 01
  BNE $ABEE                             ; $ABE6: D0 06
  JSR $ACCD                             ; $ABE8: 20 CD AC
  JMP $ABFB                             ; $ABEB: 4C FB AB
Loc_ABEE:
  CMP #$02                              ; $ABEE: C9 02
  BNE $ABF8                             ; $ABF0: D0 06
  JSR $ACE9                             ; $ABF2: 20 E9 AC
  JMP $ABFB                             ; $ABF5: 4C FB AB
Loc_ABF8:
  JSR $AD14                             ; $ABF8: 20 14 AD
Loc_ABFB:
  LDY #$00                              ; $ABFB: A0 00
  LDA ($0A),Y                           ; $ABFD: B1 0A
  JSR $F368                             ; $ABFF: 20 68 F3
  LDY #$03                              ; $AC02: A0 03
  LDA ($00),Y                           ; $AC04: B1 00
  CMP #$03                              ; $AC06: C9 03
  BNE $AC0D                             ; $AC08: D0 03
  JMP $ABB1                             ; $AC0A: 4C B1 AB
Loc_AC0D:
  STA $6F44                             ; $AC0D: 8D 44 6F
  INC $0402                             ; $AC10: EE 02 04
  LDA $0403                             ; $AC13: AD 03 04
  STA $044C                             ; $AC16: 8D 4C 04
  STA $0472                             ; $AC19: 8D 72 04
  LDA $0010                             ; $AC1C: AD 10 00
  STA $0470                             ; $AC1F: 8D 70 04
  LDA #$FF                              ; $AC22: A9 FF
  STA $0471                             ; $AC24: 8D 71 04
  LDA $0472                             ; $AC27: AD 72 04
  STA $000A                             ; $AC2A: 8D 0A 00
  LDY #$3B                              ; $AC2D: A0 3B
  JSR $EE07                             ; $AC2F: 20 07 EE
; --- Data Region ---
  .byte $09,$A0,$AD,$0B,$00,$29,$80,$49,$80,$8D,$50,$01,$A9,$9F,$8D,$D6; $AC32: 09 A0 AD 0B 00 29 80 49 80 8D 50 01 A9 9F 8D D6
  .byte $04,$A9,$1F,$8D,$A0,$04,$A9,$E8,$4C,$8B,$F2; $AC42: 04 A9 1F 8D A0 04 A9 E8 4C 8B F2
Loc_AC4D:  ; (dispatch callback target)
; --- Code Region ---
  JSR $A985                             ; $AC4D: 20 85 A9
  LDA $04A0                             ; $AC50: AD A0 04
  BNE $AC71                             ; $AC53: D0 1C
  LDA $0140                             ; $AC55: AD 40 01
  BNE $AC71                             ; $AC58: D0 17
  LDA $0300                             ; $AC5A: AD 00 03
  CMP #$FF                              ; $AC5D: C9 FF
  BNE $AC71                             ; $AC5F: D0 10
  LDA $0304                             ; $AC61: AD 04 03
  CMP #$FF                              ; $AC64: C9 FF
  BNE $AC71                             ; $AC66: D0 09
  JSR $A1C2                             ; $AC68: 20 C2 A1
  LDA $0081                             ; $AC6B: AD 81 00
  LSR                                   ; $AC6E: 4A
  BCS $AC72                             ; $AC6F: B0 01
Loc_AC71:
  RTS                                   ; $AC71: 60
Loc_AC72:
  INC $0402                             ; $AC72: EE 02 04
  LDA #$04                              ; $AC75: A9 04
  STA $00A4                             ; $AC77: 8D A4 00
  LDA $0472                             ; $AC7A: AD 72 04
  JSR $F2AF                             ; $AC7D: 20 AF F2
  LDY #$11                              ; $AC80: A0 11
  LDA ($00),Y                           ; $AC82: B1 00
  STA $0471                             ; $AC84: 8D 71 04
  STA $0000                             ; $AC87: 8D 00 00
  LDY #$3D                              ; $AC8A: A0 3D
  JSR $EE07                             ; $AC8C: 20 07 EE
; --- Data Region ---
  .byte $2A,$A0,$A9,$E8,$18,$6D,$70,$04,$4C,$6D,$F2; $AC8F: 2A A0 A9 E8 18 6D 70 04 4C 6D F2
Loc_AC9A:  ; (dispatch callback target)
; --- Code Region ---
  JSR $A985                             ; $AC9A: 20 85 A9
  LDA $0300                             ; $AC9D: AD 00 03
  CMP #$FF                              ; $ACA0: C9 FF
  BNE $ACBC                             ; $ACA2: D0 18
  LDA $0304                             ; $ACA4: AD 04 03
  CMP #$FF                              ; $ACA7: C9 FF
  BNE $ACBC                             ; $ACA9: D0 11
  JSR $A1C2                             ; $ACAB: 20 C2 A1
  LDA $0081                             ; $ACAE: AD 81 00
  LSR                                   ; $ACB1: 4A
  BCC $ACBC                             ; $ACB2: 90 08
  INC $0402                             ; $ACB4: EE 02 04
  LDA #$00                              ; $ACB7: A9 00
  JMP $F28B                             ; $ACB9: 4C 8B F2
Loc_ACBC:
  RTS                                   ; $ACBC: 60
Loc_ACBD:  ; (dispatch callback target)
  LDA $0304                             ; $ACBD: AD 04 03
  CMP #$FF                              ; $ACC0: C9 FF
  BNE $ACCC                             ; $ACC2: D0 08
  LDA #$01                              ; $ACC4: A9 01
  STA $0402                             ; $ACC6: 8D 02 04
  JMP $ABB1                             ; $ACC9: 4C B1 AB
Loc_ACCC:
  RTS                                   ; $ACCC: 60
Loc_ACCD:
  LDX #$01                              ; $ACCD: A2 01
  LDA $0470                             ; $ACCF: AD 70 04
  CMP #$05                              ; $ACD2: C9 05
  BEQ $ACE1                             ; $ACD4: F0 0B
  INX                                   ; $ACD6: E8
  CMP #$0A                              ; $ACD7: C9 0A
  BEQ $ACE1                             ; $ACD9: F0 06
  INX                                   ; $ACDB: E8
  CMP #$1E                              ; $ACDC: C9 1E
  BEQ $ACE1                             ; $ACDE: F0 01
  INX                                   ; $ACE0: E8
Loc_ACE1:
  STX $0003                             ; $ACE1: 8E 03 00
  LDY #$06                              ; $ACE4: A0 06
  JMP $AD3F                             ; $ACE6: 4C 3F AD
Loc_ACE9:
  LDX #$04                              ; $ACE9: A2 04
  LDA $0470                             ; $ACEB: AD 70 04
  CMP #$05                              ; $ACEE: C9 05
  BEQ $ACFE                             ; $ACF0: F0 0C
  INX                                   ; $ACF2: E8
  INX                                   ; $ACF3: E8
  CMP #$0A                              ; $ACF4: C9 0A
  BEQ $ACFE                             ; $ACF6: F0 06
  INX                                   ; $ACF8: E8
  CMP #$1E                              ; $ACF9: C9 1E
  BEQ $ACFE                             ; $ACFB: F0 01
  INX                                   ; $ACFD: E8
Loc_ACFE:
  STX $0003                             ; $ACFE: 8E 03 00
  STX $000C                             ; $AD01: 8E 0C 00
  LDY #$02                              ; $AD04: A0 02
  JSR $AD3F                             ; $AD06: 20 3F AD
  LDA $000C                             ; $AD09: AD 0C 00
  STA $0003                             ; $AD0C: 8D 03 00
  LDY #$04                              ; $AD0F: A0 04
  JMP $AD3F                             ; $AD11: 4C 3F AD
Loc_AD14:
  LDX #$04                              ; $AD14: A2 04
  LDA $0470                             ; $AD16: AD 70 04
  CMP #$05                              ; $AD19: C9 05
  BEQ $AD29                             ; $AD1B: F0 0C
  INX                                   ; $AD1D: E8
  INX                                   ; $AD1E: E8
  CMP #$0A                              ; $AD1F: C9 0A
  BEQ $AD29                             ; $AD21: F0 06
  INX                                   ; $AD23: E8
  CMP #$1E                              ; $AD24: C9 1E
  BEQ $AD29                             ; $AD26: F0 01
  INX                                   ; $AD28: E8
Loc_AD29:
  STX $0003                             ; $AD29: 8E 03 00
  STX $000C                             ; $AD2C: 8E 0C 00
  LDY #$08                              ; $AD2F: A0 08
  JSR $AD3F                             ; $AD31: 20 3F AD
  LDA $000C                             ; $AD34: AD 0C 00
  STA $0003                             ; $AD37: 8D 03 00
  LDY #$0E                              ; $AD3A: A0 0E
  JMP $AD3F                             ; $AD3C: 4C 3F AD
Loc_AD3F:
  STY $000D                             ; $AD3F: 8C 0D 00
  LDA ($0A),Y                           ; $AD42: B1 0A
  STA $0000                             ; $AD44: 8D 00 00
  INY                                   ; $AD47: C8
  LDA ($0A),Y                           ; $AD48: B1 0A
  STA $0001                             ; $AD4A: 8D 01 00
  LSR $0001                             ; $AD4D: 4E 01 00
  ROR $0000                             ; $AD50: 6E 00 00
  LSR $0001                             ; $AD53: 4E 01 00
  ROR $0000                             ; $AD56: 6E 00 00
  LSR $0001                             ; $AD59: 4E 01 00
  ROR $0000                             ; $AD5C: 6E 00 00
  LSR $0001                             ; $AD5F: 4E 01 00
  ROR $0000                             ; $AD62: 6E 00 00
  LDA #$00                              ; $AD65: A9 00
  STA $0002                             ; $AD67: 8D 02 00
  JSR $EBE9                             ; $AD6A: 20 E9 EB
  LDY $000D                             ; $AD6D: AC 0D 00
  LDA ($0A),Y                           ; $AD70: B1 0A
  SEC                                   ; $AD72: 38
  SBC $0006                             ; $AD73: ED 06 00
  STA ($0A),Y                           ; $AD76: 91 0A
  INY                                   ; $AD78: C8
  LDA ($0A),Y                           ; $AD79: B1 0A
  SBC $0007                             ; $AD7B: ED 07 00
  STA ($0A),Y                           ; $AD7E: 91 0A
  RTS                                   ; $AD80: 60
Loc_AD81:
  LDA $0401                             ; $AD81: AD 01 04
  JSR $EADE                             ; $AD84: 20 DE EA
; --- Data Region ---
  .byte $95,$AD,$AA,$AD,$0D,$AE,$51,$AE,$01,$BE,$32,$C1,$7A,$C3; $AD87: 95 AD AA AD 0D AE 51 AE 01 BE 32 C1 7A C3
Loc_AD95:  ; (dispatch callback target)
; --- Code Region ---
  LDA #$00                              ; $AD95: A9 00
  STA $04E4                             ; $AD97: 8D E4 04
  LDA #$F0                              ; $AD9A: A9 F0
  STA $6F41                             ; $AD9C: 8D 41 6F
  LDY #$3D                              ; $AD9F: A0 3D
  JSR $EE07                             ; $ADA1: 20 07 EE
; --- Data Region ---
  .byte $1E,$A0,$EE,$01,$04,$60           ; $ADA4: 1E A0 EE 01 04 60
Loc_ADAA:  ; (dispatch callback target)
; --- Code Region ---
  LDA $007E                             ; $ADAA: AD 7E 00
  BEQ $ADB0                             ; $ADAD: F0 01
  RTS                                   ; $ADAF: 60
Loc_ADB0:
  LDA $0507                             ; $ADB0: AD 07 05
  LSR                                   ; $ADB3: 4A
  LSR                                   ; $ADB4: 4A
  LSR                                   ; $ADB5: 4A
  LSR                                   ; $ADB6: 4A
  STA $040C                             ; $ADB7: 8D 0C 04
  LDA $0507                             ; $ADBA: AD 07 05
  AND #$0F                              ; $ADBD: 29 0F
  STA $040A                             ; $ADBF: 8D 0A 04
  JSR $F368                             ; $ADC2: 20 68 F3
  LDY #$00                              ; $ADC5: A0 00
  LDA ($00),Y                           ; $ADC7: B1 00
  STA $040B                             ; $ADC9: 8D 0B 04
  JSR $F2D7                             ; $ADCC: 20 D7 F2
  LDY #$0B                              ; $ADCF: A0 0B
  LDA ($00),Y                           ; $ADD1: B1 00
  AND #$03                              ; $ADD3: 29 03
  CMP #$03                              ; $ADD5: C9 03
  BEQ $ADDD                             ; $ADD7: F0 04
Loc_ADD9:
  INC $0401                             ; $ADD9: EE 01 04
  RTS                                   ; $ADDC: 60
Loc_ADDD:
  LDA #$02                              ; $ADDD: A9 02
  STA $0470                             ; $ADDF: 8D 70 04
  LDA #$06                              ; $ADE2: A9 06
  STA $0471                             ; $ADE4: 8D 71 04
  LDA #$0D                              ; $ADE7: A9 0D
  STA $0472                             ; $ADE9: 8D 72 04
  LDA #$03                              ; $ADEC: A9 03
  STA $0473                             ; $ADEE: 8D 73 04
Loc_ADF1:
  LDA #$04                              ; $ADF1: A9 04
  STA $0401                             ; $ADF3: 8D 01 04
  LDA #$00                              ; $ADF6: A9 00
  STA $0402                             ; $ADF8: 8D 02 04
  LDA $040A                             ; $ADFB: AD 0A 04
  JSR $F368                             ; $ADFE: 20 68 F3
  LDY #$03                              ; $AE01: A0 03
  LDA ($00),Y                           ; $AE03: B1 00
  CMP #$03                              ; $AE05: C9 03
  BEQ $ADD9                             ; $AE07: F0 D0
  STA $6F44                             ; $AE09: 8D 44 6F
  RTS                                   ; $AE0C: 60
Loc_AE0D:  ; (dispatch callback target)
  LDA $0507                             ; $AE0D: AD 07 05
  AND #$0F                              ; $AE10: 29 0F
  STA $040C                             ; $AE12: 8D 0C 04
  LDA $0507                             ; $AE15: AD 07 05
  LSR                                   ; $AE18: 4A
  LSR                                   ; $AE19: 4A
  LSR                                   ; $AE1A: 4A
  LSR                                   ; $AE1B: 4A
  STA $040A                             ; $AE1C: 8D 0A 04
  JSR $F368                             ; $AE1F: 20 68 F3
  LDY #$00                              ; $AE22: A0 00
  LDA ($00),Y                           ; $AE24: B1 00
  STA $040B                             ; $AE26: 8D 0B 04
  JSR $F2D7                             ; $AE29: 20 D7 F2
  LDY #$0B                              ; $AE2C: A0 0B
  LDA ($00),Y                           ; $AE2E: B1 00
  AND #$03                              ; $AE30: 29 03
  CMP #$03                              ; $AE32: C9 03
  BNE $AE4D                             ; $AE34: D0 17
  LDA #$03                              ; $AE36: A9 03
  STA $0470                             ; $AE38: 8D 70 04
  LDA #$06                              ; $AE3B: A9 06
  STA $0471                             ; $AE3D: 8D 71 04
  LDA #$0B                              ; $AE40: A9 0B
  STA $0472                             ; $AE42: 8D 72 04
  LDA #$00                              ; $AE45: A9 00
  STA $0473                             ; $AE47: 8D 73 04
  JMP $ADF1                             ; $AE4A: 4C F1 AD
Loc_AE4D:
  INC $0401                             ; $AE4D: EE 01 04
  RTS                                   ; $AE50: 60
Loc_AE51:  ; (dispatch callback target)
  LDA #$00                              ; $AE51: A9 00
  STA $0470                             ; $AE53: 8D 70 04
  STA $0471                             ; $AE56: 8D 71 04
  LDY #$03                              ; $AE59: A0 03
  LDA ($EE),Y                           ; $AE5B: B1 EE
  CMP #$03                              ; $AE5D: C9 03
  BNE $AE8B                             ; $AE5F: D0 2A
  LDA #$BB                              ; $AE61: A9 BB
  JSR $F28B                             ; $AE63: 20 8B F2
  LDY #$00                              ; $AE66: A0 00
  LDA ($EE),Y                           ; $AE68: B1 EE
  STA $042C                             ; $AE6A: 8D 2C 04
  LDA #$09                              ; $AE6D: A9 09
  STA $0400                             ; $AE6F: 8D 00 04
  LDA #$01                              ; $AE72: A9 01
  STA $0401                             ; $AE74: 8D 01 04
  LDA #$00                              ; $AE77: A9 00
  STA $040C                             ; $AE79: 8D 0C 04
  LDA #$00                              ; $AE7C: A9 00
  STA $6F8B                             ; $AE7E: 8D 8B 6F
  STA $6F5B                             ; $AE81: 8D 5B 6F
  STA $6F5C                             ; $AE84: 8D 5C 6F
  STA $6F62                             ; $AE87: 8D 62 6F
  RTS                                   ; $AE8A: 60
Loc_AE8B:
  STA $6F44                             ; $AE8B: 8D 44 6F
  LDY #$00                              ; $AE8E: A0 00
  LDA ($EE),Y                           ; $AE90: B1 EE
  STA $000A                             ; $AE92: 8D 0A 00
  JSR $A1EB                             ; $AE95: 20 EB A1
  LDY #$01                              ; $AE98: A0 01
  STA ($EE),Y                           ; $AE9A: 91 EE
  LDY #$01                              ; $AE9C: A0 01
  LDA ($EE),Y                           ; $AE9E: B1 EE
  TAY                                   ; $AEA0: A8
  LDA $C737,Y                           ; $AEA1: B9 37 C7
  STA $6F3F                             ; $AEA4: 8D 3F 6F
  LDA $C755,Y                           ; $AEA7: B9 55 C7
  CLC                                   ; $AEAA: 18
  ADC #$01                              ; $AEAB: 69 01
  STA $6F41                             ; $AEAD: 8D 41 6F
  LDY #$3D                              ; $AEB0: A0 3D
  JSR $EE07                             ; $AEB2: 20 07 EE
; --- Data Region ---
  .byte $1E,$A0,$A9,$00,$8D,$00,$04,$8D,$01,$04,$60; $AEB5: 1E A0 A9 00 8D 00 04 8D 01 04 60
Loc_AEC0:  ; (dispatch callback target)
; --- Code Region ---
  LDA $0402                             ; $AEC0: AD 02 04
  JSR $EADE                             ; $AEC3: 20 DE EA
; --- Data Region ---
  .byte $CE,$AE,$74,$AF,$8B,$AF,$B8,$AF   ; $AEC6: CE AE 74 AF 8B AF B8 AF
Loc_AECE:  ; (dispatch callback target)
; --- Code Region ---
  LDY #$31                              ; $AECE: A0 31
  JSR $F25F                             ; $AED0: 20 5F F2
  LDA #$74                              ; $AED3: A9 74
  STA $0000                             ; $AED5: 8D 00 00
  LDA #$8D                              ; $AED8: A9 8D
  STA $0001                             ; $AEDA: 8D 01 00
  LDY $0470                             ; $AEDD: AC 70 04
  LDA ($00),Y                           ; $AEE0: B1 00
  STA $0010                             ; $AEE2: 8D 10 00
  INY                                   ; $AEE5: C8
  LDA ($00),Y                           ; $AEE6: B1 00
  CLC                                   ; $AEE8: 18
  ADC #$60                              ; $AEE9: 69 60
  STA $0011                             ; $AEEB: 8D 11 00
  LDX #$00                              ; $AEEE: A2 00
Loc_AEF0:
  TXA                                   ; $AEF0: 8A
  TAY                                   ; $AEF1: A8
  LDA ($10),Y                           ; $AEF2: B1 10
  CMP #$FF                              ; $AEF4: C9 FF
  BEQ $AF19                             ; $AEF6: F0 21
  STA $0012                             ; $AEF8: 8D 12 00
  JSR $F2D7                             ; $AEFB: 20 D7 F2
  LDY #$0B                              ; $AEFE: A0 0B
  LDA ($00),Y                           ; $AF00: B1 00
  AND #$03                              ; $AF02: 29 03
  CMP #$01                              ; $AF04: C9 01
  BEQ $AF0D                             ; $AF06: F0 05
  INX                                   ; $AF08: E8
  INX                                   ; $AF09: E8
  JMP $AEF0                             ; $AF0A: 4C F0 AE
Loc_AF0D:
  INX                                   ; $AF0D: E8
  TXA                                   ; $AF0E: 8A
  TAY                                   ; $AF0F: A8
  LDA ($10),Y                           ; $AF10: B1 10
  CMP $6F00                             ; $AF12: CD 00 6F
  BEQ $AF1F                             ; $AF15: F0 08
  BCC $AF1F                             ; $AF17: 90 06
Loc_AF19:
  LDA #$03                              ; $AF19: A9 03
  STA $0401                             ; $AF1B: 8D 01 04
  RTS                                   ; $AF1E: 60
Loc_AF1F:
  LDY #$01                              ; $AF1F: A0 01
  LDA ($EE),Y                           ; $AF21: B1 EE
  JSR $F2AF                             ; $AF23: 20 AF F2
  LDY #$11                              ; $AF26: A0 11
  LDX #$00                              ; $AF28: A2 00
Loc_AF2A:
  LDA ($00),Y                           ; $AF2A: B1 00
  CMP #$FF                              ; $AF2C: C9 FF
  BEQ $AF31                             ; $AF2E: F0 01
  INX                                   ; $AF30: E8
Loc_AF31:
  INY                                   ; $AF31: C8
  CPY #$1B                              ; $AF32: C0 1B
  BCC $AF2A                             ; $AF34: 90 F4
  CPX #$0A                              ; $AF36: E0 0A
  BEQ $AF19                             ; $AF38: F0 DF
  TXA                                   ; $AF3A: 8A
  CLC                                   ; $AF3B: 18
  ADC #$11                              ; $AF3C: 69 11
  TAY                                   ; $AF3E: A8
  LDA $0012                             ; $AF3F: AD 12 00
  STA ($00),Y                           ; $AF42: 91 00
  LDA $0012                             ; $AF44: AD 12 00
  JSR $F2D7                             ; $AF47: 20 D7 F2
  LDY #$0B                              ; $AF4A: A0 0B
  LDA ($00),Y                           ; $AF4C: B1 00
  AND #$FC                              ; $AF4E: 29 FC
  ORA #$02                              ; $AF50: 09 02
  STA ($00),Y                           ; $AF52: 91 00
  LDY #$03                              ; $AF54: A0 03
  LDA ($EE),Y                           ; $AF56: B1 EE
  CMP #$03                              ; $AF58: C9 03
  BEQ $AF19                             ; $AF5A: F0 BD
  STA $6F44                             ; $AF5C: 8D 44 6F
  LDA $0012                             ; $AF5F: AD 12 00
  STA $042C                             ; $AF62: 8D 2C 04
  LDY #$00                              ; $AF65: A0 00
  LDA ($EE),Y                           ; $AF67: B1 EE
  STA $042D                             ; $AF69: 8D 2D 04
  INC $0402                             ; $AF6C: EE 02 04
  LDA #$00                              ; $AF6F: A9 00
  JMP $F28B                             ; $AF71: 4C 8B F2
Loc_AF74:  ; (dispatch callback target)
  LDA $0300                             ; $AF74: AD 00 03
  CMP #$FF                              ; $AF77: C9 FF
  BNE $AF8A                             ; $AF79: D0 0F
  LDA $0304                             ; $AF7B: AD 04 03
  CMP #$FF                              ; $AF7E: C9 FF
  BNE $AF8A                             ; $AF80: D0 08
  INC $0402                             ; $AF82: EE 02 04
  LDA #$30                              ; $AF85: A9 30
  JMP $F26D                             ; $AF87: 4C 6D F2
Loc_AF8A:
  RTS                                   ; $AF8A: 60
Loc_AF8B:  ; (dispatch callback target)
  LDA $0300                             ; $AF8B: AD 00 03
  CMP #$FF                              ; $AF8E: C9 FF
  BNE $AFA2                             ; $AF90: D0 10
  LDA $0304                             ; $AF92: AD 04 03
  CMP #$FF                              ; $AF95: C9 FF
  BNE $AFA2                             ; $AF97: D0 09
  JSR $A1C2                             ; $AF99: 20 C2 A1
  LDA $0081                             ; $AF9C: AD 81 00
  LSR                                   ; $AF9F: 4A
  BCS $AFA3                             ; $AFA0: B0 01
Loc_AFA2:
  RTS                                   ; $AFA2: 60
Loc_AFA3:
  LDA $042C                             ; $AFA3: AD 2C 04
  STA $0000                             ; $AFA6: 8D 00 00
  LDY #$3D                              ; $AFA9: A0 3D
  JSR $EE07                             ; $AFAB: 20 07 EE
; --- Data Region ---
  .byte $2A,$A0,$EE,$02,$04,$A9,$39,$4C,$6D,$F2; $AFAE: 2A A0 EE 02 04 A9 39 4C 6D F2
Loc_AFB8:  ; (dispatch callback target)
; --- Code Region ---
  LDA $042C                             ; $AFB8: AD 2C 04
  STA $0000                             ; $AFBB: 8D 00 00
  LDA #$A7                              ; $AFBE: A9 A7
  STA $000A                             ; $AFC0: 8D 0A 00
  LDX #$00                              ; $AFC3: A2 00
  JSR $CE1F                             ; $AFC5: 20 1F CE
  LDA $0300                             ; $AFC8: AD 00 03
  CMP #$FF                              ; $AFCB: C9 FF
  BNE $AFE4                             ; $AFCD: D0 15
  LDA $0304                             ; $AFCF: AD 04 03
  CMP #$FF                              ; $AFD2: C9 FF
  BNE $AFE4                             ; $AFD4: D0 0E
  JSR $A1C2                             ; $AFD6: 20 C2 A1
  LDA $0081                             ; $AFD9: AD 81 00
  LSR                                   ; $AFDC: 4A
  BCC $AFE4                             ; $AFDD: 90 05
  LDA #$03                              ; $AFDF: A9 03
  STA $0401                             ; $AFE1: 8D 01 04
Loc_AFE4:
  RTS                                   ; $AFE4: 60
Loc_AFE5:
  LDA $0401                             ; $AFE5: AD 01 04
  JSR $EADE                             ; $AFE8: 20 DE EA
; --- Data Region ---
  .byte $F5,$AF,$41,$B0,$86,$B0,$36,$B1,$55,$B1; $AFEB: F5 AF 41 B0 86 B0 36 B1 55 B1
Loc_AFF5:  ; (dispatch callback target)
; --- Code Region ---
  LDA #$00                              ; $AFF5: A9 00
  STA $0000                             ; $AFF7: 8D 00 00
  LDY #$3D                              ; $AFFA: A0 3D
  JSR $EE07                             ; $AFFC: 20 07 EE
; --- Data Region ---
  .byte $15,$A0,$A9,$FF,$8D,$E4,$04,$A9,$00,$8D,$0C,$04,$8D,$0D,$04,$EE; $AFFF: 15 A0 A9 FF 8D E4 04 A9 00 8D 0C 04 8D 0D 04 EE
  .byte $01,$04,$A9,$08,$8D,$BA,$00,$A9,$06,$8D,$BB,$00,$A0,$00,$A9,$FF; $B00F: 01 04 A9 08 8D BA 00 A9 06 8D BB 00 A0 00 A9 FF
Loc_B01F:
; --- Code Region ---
  STA $0410,Y                           ; $B01F: 99 10 04
  INY                                   ; $B022: C8
  CPY #$0A                              ; $B023: C0 0A
  BCC $B01F                             ; $B025: 90 F8
  LDA $0402                             ; $B027: AD 02 04
  JSR $F2AF                             ; $B02A: 20 AF F2
  LDX #$00                              ; $B02D: A2 00
  LDY #$11                              ; $B02F: A0 11
Loc_B031:
  LDA ($00),Y                           ; $B031: B1 00
  CMP #$FF                              ; $B033: C9 FF
  BEQ $B03B                             ; $B035: F0 04
  STA $0410,X                           ; $B037: 9D 10 04
  INX                                   ; $B03A: E8
Loc_B03B:
  INY                                   ; $B03B: C8
  CPY #$1B                              ; $B03C: C0 1B
  BCC $B031                             ; $B03E: 90 F1
  RTS                                   ; $B040: 60
Loc_B041:  ; (dispatch callback target)
  JSR $B2D7                             ; $B041: 20 D7 B2
  LDA $040D                             ; $B044: AD 0D 04
  CMP #$FF                              ; $B047: C9 FF
  BNE $B085                             ; $B049: D0 3A
  LDA #$00                              ; $B04B: A9 00
  STA $0096                             ; $B04D: 8D 96 00
  LDA #$01                              ; $B050: A9 01
  STA $0097                             ; $B052: 8D 97 00
  LDA #$00                              ; $B055: A9 00
  STA $0098                             ; $B057: 8D 98 00
  LDA #$01                              ; $B05A: A9 01
  STA $0061                             ; $B05C: 8D 61 00
  LDA #$40                              ; $B05F: A9 40
  STA $0068                             ; $B061: 8D 68 00
  LDA #$18                              ; $B064: A9 18
  STA $006A                             ; $B066: 8D 6A 00
  LDA #$20                              ; $B069: A9 20
  STA $006C                             ; $B06B: 8D 6C 00
  LDA #$1A                              ; $B06E: A9 1A
  STA $006E                             ; $B070: 8D 6E 00
  LDA #$F0                              ; $B073: A9 F0
  STA $0070                             ; $B075: 8D 70 00
  LDA #$F1                              ; $B078: A9 F1
  STA $0071                             ; $B07A: 8D 71 00
  INC $0401                             ; $B07D: EE 01 04
  LDA #$00                              ; $B080: A9 00
  STA $0408                             ; $B082: 8D 08 04
Loc_B085:
  RTS                                   ; $B085: 60
Loc_B086:  ; (dispatch callback target)
  LDA #$AE                              ; $B086: A9 AE
  STA $000A                             ; $B088: 8D 0A 00
  LDX $0408                             ; $B08B: AE 08 04
  LDA $0410,X                           ; $B08E: BD 10 04
  STA $0000                             ; $B091: 8D 00 00
  JSR $CE1F                             ; $B094: 20 1F CE
  LDA $0472                             ; $B097: AD 72 04
  BNE $B0AA                             ; $B09A: D0 0E
  JSR $B209                             ; $B09C: 20 09 B2
Loc_B09F:
  LDA $0081                             ; $B09F: AD 81 00
  LSR                                   ; $B0A2: 4A
  BCC $B0E7                             ; $B0A3: 90 42
  LDA $0470                             ; $B0A5: AD 70 04
  BEQ $B0EA                             ; $B0A8: F0 40
Loc_B0AA:
  LDA $0140                             ; $B0AA: AD 40 01
  BEQ $B0B0                             ; $B0AD: F0 01
  RTS                                   ; $B0AF: 60
Loc_B0B0:
  LDA $0472                             ; $B0B0: AD 72 04
  BMI $B0BF                             ; $B0B3: 30 0A
  BEQ $B0C5                             ; $B0B5: F0 0E
  CMP #$0A                              ; $B0B7: C9 0A
  BEQ $B0CE                             ; $B0B9: F0 13
  INC $0472                             ; $B0BB: EE 72 04
  RTS                                   ; $B0BE: 60
Loc_B0BF:
  LDA #$00                              ; $B0BF: A9 00
  STA $0472                             ; $B0C1: 8D 72 04
  RTS                                   ; $B0C4: 60
Loc_B0C5:
  LDA #$80                              ; $B0C5: A9 80
  STA $0140                             ; $B0C7: 8D 40 01
  INC $0472                             ; $B0CA: EE 72 04
  RTS                                   ; $B0CD: 60
Loc_B0CE:
  LDA #$80                              ; $B0CE: A9 80
  STA $0140                             ; $B0D0: 8D 40 01
  LDA $0473                             ; $B0D3: AD 73 04
  EOR #$03                              ; $B0D6: 49 03
  STA $0473                             ; $B0D8: 8D 73 04
  ORA $0150                             ; $B0DB: 0D 50 01
  STA $0150                             ; $B0DE: 8D 50 01
  LDA #$80                              ; $B0E1: A9 80
  STA $0472                             ; $B0E3: 8D 72 04
  RTS                                   ; $B0E6: 60
Loc_B0E7:
  LSR                                   ; $B0E7: 4A
  BCC $B135                             ; $B0E8: 90 4B
Loc_B0EA:
  LDA $0470                             ; $B0EA: AD 70 04
  STA $0400                             ; $B0ED: 8D 00 04
  LDA $0471                             ; $B0F0: AD 71 04
  STA $0401                             ; $B0F3: 8D 01 04
  LDA #$40                              ; $B0F6: A9 40
  STA $0068                             ; $B0F8: 8D 68 00
  LDA #$14                              ; $B0FB: A9 14
  STA $006A                             ; $B0FD: 8D 6A 00
  LDA #$1E                              ; $B100: A9 1E
  STA $006C                             ; $B102: 8D 6C 00
  LDA #$20                              ; $B105: A9 20
  STA $006E                             ; $B107: 8D 6E 00
  LDA #$0D                              ; $B10A: A9 0D
  STA $0070                             ; $B10C: 8D 70 00
  LDA #$F2                              ; $B10F: A9 F2
  STA $0071                             ; $B111: 8D 71 00
  LDA #$03                              ; $B114: A9 03
  STA $0061                             ; $B116: 8D 61 00
  LDA #$00                              ; $B119: A9 00
  STA $0096                             ; $B11B: 8D 96 00
  STA $0097                             ; $B11E: 8D 97 00
  LDA #$A0                              ; $B121: A9 A0
  STA $0098                             ; $B123: 8D 98 00
  LDA #$00                              ; $B126: A9 00
  STA $04E4                             ; $B128: 8D E4 04
  LDA #$09                              ; $B12B: A9 09
  STA $00BB                             ; $B12D: 8D BB 00
  LDA #$0D                              ; $B130: A9 0D
  STA $00BC                             ; $B132: 8D BC 00
Loc_B135:
  RTS                                   ; $B135: 60
Loc_B136:  ; (dispatch callback target)
  JSR $B2D7                             ; $B136: 20 D7 B2
  LDA #$AE                              ; $B139: A9 AE
  STA $000A                             ; $B13B: 8D 0A 00
  LDX $0408                             ; $B13E: AE 08 04
  LDA $0410,X                           ; $B141: BD 10 04
  STA $0000                             ; $B144: 8D 00 00
  JSR $CE1F                             ; $B147: 20 1F CE
  LDA $040D                             ; $B14A: AD 0D 04
  CMP #$FF                              ; $B14D: C9 FF
  BNE $B154                             ; $B14F: D0 03
  INC $0401                             ; $B151: EE 01 04
Loc_B154:
  RTS                                   ; $B154: 60
Loc_B155:  ; (dispatch callback target)
  JSR $B285                             ; $B155: 20 85 B2
  LDA $040A                             ; $B158: AD 0A 04
  BNE $B1AE                             ; $B15B: D0 51
  LDA $0409                             ; $B15D: AD 09 04
  CMP #$29                              ; $B160: C9 29
  BCS $B189                             ; $B162: B0 25
  LDA #$AC                              ; $B164: A9 AC
  SEC                                   ; $B166: 38
  SBC $0409                             ; $B167: ED 09 04
  STA $000A                             ; $B16A: 8D 0A 00
  LDX $0408                             ; $B16D: AE 08 04
  JSR $B1FF                             ; $B170: 20 FF B1
  LDA #$FC                              ; $B173: A9 FC
  SEC                                   ; $B175: 38
  SBC $0409                             ; $B176: ED 09 04
  STA $000A                             ; $B179: 8D 0A 00
  LDX $0408                             ; $B17C: AE 08 04
  INX                                   ; $B17F: E8
  JSR $B1FF                             ; $B180: 20 FF B1
  JSR $B260                             ; $B183: 20 60 B2
  JMP $B09F                             ; $B186: 4C 9F B0
Loc_B189:
  LDA #$FC                              ; $B189: A9 FC
  SEC                                   ; $B18B: 38
  SBC $0409                             ; $B18C: ED 09 04
  STA $000A                             ; $B18F: 8D 0A 00
  LDX $0408                             ; $B192: AE 08 04
  INX                                   ; $B195: E8
  JSR $B1FF                             ; $B196: 20 FF B1
  LDA #$AC                              ; $B199: A9 AC
  SEC                                   ; $B19B: 38
  SBC $0409                             ; $B19C: ED 09 04
  STA $000A                             ; $B19F: 8D 0A 00
  LDX $0408                             ; $B1A2: AE 08 04
  JSR $B1FF                             ; $B1A5: 20 FF B1
  JSR $B260                             ; $B1A8: 20 60 B2
  JMP $B09F                             ; $B1AB: 4C 9F B0
Loc_B1AE:
  LDA $0409                             ; $B1AE: AD 09 04
  CMP #$29                              ; $B1B1: C9 29
  BCC $B1DA                             ; $B1B3: 90 25
  LDA #$60                              ; $B1B5: A9 60
  CLC                                   ; $B1B7: 18
  ADC $0409                             ; $B1B8: 6D 09 04
  STA $000A                             ; $B1BB: 8D 0A 00
  LDX $0408                             ; $B1BE: AE 08 04
  DEX                                   ; $B1C1: CA
  JSR $B1FF                             ; $B1C2: 20 FF B1
  LDA #$B0                              ; $B1C5: A9 B0
  CLC                                   ; $B1C7: 18
  ADC $0409                             ; $B1C8: 6D 09 04
  STA $000A                             ; $B1CB: 8D 0A 00
  LDX $0408                             ; $B1CE: AE 08 04
  JSR $B1FF                             ; $B1D1: 20 FF B1
  JSR $B260                             ; $B1D4: 20 60 B2
  JMP $B09F                             ; $B1D7: 4C 9F B0
Loc_B1DA:
  LDA #$B0                              ; $B1DA: A9 B0
  CLC                                   ; $B1DC: 18
  ADC $0409                             ; $B1DD: 6D 09 04
  STA $000A                             ; $B1E0: 8D 0A 00
  LDX $0408                             ; $B1E3: AE 08 04
  JSR $B1FF                             ; $B1E6: 20 FF B1
  LDA #$60                              ; $B1E9: A9 60
  CLC                                   ; $B1EB: 18
  ADC $0409                             ; $B1EC: 6D 09 04
  STA $000A                             ; $B1EF: 8D 0A 00
  LDX $0408                             ; $B1F2: AE 08 04
  DEX                                   ; $B1F5: CA
  JSR $B1FF                             ; $B1F6: 20 FF B1
  JSR $B260                             ; $B1F9: 20 60 B2
  JMP $B09F                             ; $B1FC: 4C 9F B0
Loc_B1FF:
  LDA $0410,X                           ; $B1FF: BD 10 04
  STA $0000                             ; $B202: 8D 00 00
  JSR $CE1F                             ; $B205: 20 1F CE
  RTS                                   ; $B208: 60
Loc_B209:
  LDA $0083                             ; $B209: AD 83 00
  AND #$10                              ; $B20C: 29 10
  BEQ $B230                             ; $B20E: F0 20
  LDA $0408                             ; $B210: AD 08 04
  BEQ $B230                             ; $B213: F0 1B
  LDA #$00                              ; $B215: A9 00
  STA $0409                             ; $B217: 8D 09 04
  LDA #$01                              ; $B21A: A9 01
  STA $040A                             ; $B21C: 8D 0A 04
  INC $0401                             ; $B21F: EE 01 04
  LDA #$00                              ; $B222: A9 00
  STA $040D                             ; $B224: 8D 0D 04
  LDA $0408                             ; $B227: AD 08 04
  SEC                                   ; $B22A: 38
  SBC #$01                              ; $B22B: E9 01
  STA $040C                             ; $B22D: 8D 0C 04
Loc_B230:
  LDA $0083                             ; $B230: AD 83 00
  AND #$20                              ; $B233: 29 20
  BEQ $B25F                             ; $B235: F0 28
  LDY $0408                             ; $B237: AC 08 04
  CPY #$09                              ; $B23A: C0 09
  BCS $B25F                             ; $B23C: B0 21
  INY                                   ; $B23E: C8
  LDA $0410,Y                           ; $B23F: B9 10 04
  CMP #$FF                              ; $B242: C9 FF
  BEQ $B25F                             ; $B244: F0 19
  LDA #$00                              ; $B246: A9 00
  STA $0409                             ; $B248: 8D 09 04
  STA $040A                             ; $B24B: 8D 0A 04
  INC $0401                             ; $B24E: EE 01 04
  LDA #$00                              ; $B251: A9 00
  STA $040D                             ; $B253: 8D 0D 04
  LDA $0408                             ; $B256: AD 08 04
  CLC                                   ; $B259: 18
  ADC #$01                              ; $B25A: 69 01
  STA $040C                             ; $B25C: 8D 0C 04
Loc_B25F:
  RTS                                   ; $B25F: 60
Loc_B260:
  LDA #$00                              ; $B260: A9 00
  STA $0081                             ; $B262: 8D 81 00
  INC $0409                             ; $B265: EE 09 04
  INC $0409                             ; $B268: EE 09 04
  LDA $0409                             ; $B26B: AD 09 04
  CMP #$50                              ; $B26E: C9 50
  BCC $B284                             ; $B270: 90 12
  DEC $0401                             ; $B272: CE 01 04
  DEC $0401                             ; $B275: CE 01 04
  LDA $040A                             ; $B278: AD 0A 04
  BNE $B281                             ; $B27B: D0 04
  INC $0408                             ; $B27D: EE 08 04
  RTS                                   ; $B280: 60
Loc_B281:
  DEC $0408                             ; $B281: CE 08 04
Loc_B284:
  RTS                                   ; $B284: 60
Loc_B285:
  LDA $040A                             ; $B285: AD 0A 04
  BNE $B2B0                             ; $B288: D0 26
  LDA $0409                             ; $B28A: AD 09 04
  CMP #$40                              ; $B28D: C9 40
  BNE $B29D                             ; $B28F: D0 0C
  LDA $040E                             ; $B291: AD 0E 04
  STA $00BC                             ; $B294: 8D BC 00
  LDA $040F                             ; $B297: AD 0F 04
  STA $00BD                             ; $B29A: 8D BD 00
Loc_B29D:
  INC $0098                             ; $B29D: EE 98 00
  INC $0098                             ; $B2A0: EE 98 00
  LDA $0098                             ; $B2A3: AD 98 00
  CMP #$F0                              ; $B2A6: C9 F0
  BCC $B2D6                             ; $B2A8: 90 2C
  LDA #$00                              ; $B2AA: A9 00
  STA $0098                             ; $B2AC: 8D 98 00
  RTS                                   ; $B2AF: 60
Loc_B2B0:
  LDA $0409                             ; $B2B0: AD 09 04
  CMP #$10                              ; $B2B3: C9 10
  BNE $B2C3                             ; $B2B5: D0 0C
  LDA $040E                             ; $B2B7: AD 0E 04
  STA $00BC                             ; $B2BA: 8D BC 00
  LDA $040F                             ; $B2BD: AD 0F 04
  STA $00BD                             ; $B2C0: 8D BD 00
Loc_B2C3:
  DEC $0098                             ; $B2C3: CE 98 00
  DEC $0098                             ; $B2C6: CE 98 00
  LDA $0098                             ; $B2C9: AD 98 00
  CMP #$F0                              ; $B2CC: C9 F0
  BCC $B2D6                             ; $B2CE: 90 06
  SEC                                   ; $B2D0: 38
  SBC #$10                              ; $B2D1: E9 10
  STA $0098                             ; $B2D3: 8D 98 00
Loc_B2D6:
  RTS                                   ; $B2D6: 60
Loc_B2D7:
  LDA $007E                             ; $B2D7: AD 7E 00
  AND #$04                              ; $B2DA: 29 04
  BNE $B2E8                             ; $B2DC: D0 0A
  LDA #$00                              ; $B2DE: A9 00
  STA $0001                             ; $B2E0: 8D 01 00
  LDA $040D                             ; $B2E3: AD 0D 04
  BPL $B2E9                             ; $B2E6: 10 01
Loc_B2E8:
  RTS                                   ; $B2E8: 60
Loc_B2E9:
  PHA                                   ; $B2E9: 48
  ASL                                   ; $B2EA: 0A
  ROL $0001                             ; $B2EB: 2E 01 00
  ASL                                   ; $B2EE: 0A
  ROL $0001                             ; $B2EF: 2E 01 00
  ASL                                   ; $B2F2: 0A
  ROL $0001                             ; $B2F3: 2E 01 00
  ASL                                   ; $B2F6: 0A
  ROL $0001                             ; $B2F7: 2E 01 00
  ASL                                   ; $B2FA: 0A
  ROL $0001                             ; $B2FB: 2E 01 00
  STA $0382                             ; $B2FE: 8D 82 03
  LDA $0001                             ; $B301: AD 01 00
  STA $0381                             ; $B304: 8D 81 03
  LDA #$20                              ; $B307: A9 20
  STA $0380                             ; $B309: 8D 80 03
  LDA $040C                             ; $B30C: AD 0C 04
  STA $0001                             ; $B30F: 8D 01 00
  LDA #$00                              ; $B312: A9 00
  STA $0002                             ; $B314: 8D 02 00
  STA $0004                             ; $B317: 8D 04 00
  LDA #$03                              ; $B31A: A9 03
  STA $0003                             ; $B31C: 8D 03 00
  JSR $EA7C                             ; $B31F: 20 7C EA
  LDA $0005                             ; $B322: AD 05 00
  ASL                                   ; $B325: 0A
  TAY                                   ; $B326: A8
  LDA $B4B9,Y                           ; $B327: B9 B9 B4
  CLC                                   ; $B32A: 18
  ADC $0382                             ; $B32B: 6D 82 03
  STA $0382                             ; $B32E: 8D 82 03
  LDA $B4BA,Y                           ; $B331: B9 BA B4
  ADC $0381                             ; $B334: 6D 81 03
  STA $0381                             ; $B337: 8D 81 03
  LDY $040C                             ; $B33A: AC 0C 04
  LDA $0410,Y                           ; $B33D: B9 10 04
  CMP #$FE                              ; $B340: C9 FE
  BNE $B34A                             ; $B342: D0 06
  PLA                                   ; $B344: 68
  LDY #$10                              ; $B345: A0 10
  JMP $B34D                             ; $B347: 4C 4D B3
Loc_B34A:
  PLA                                   ; $B34A: 68
  ASL                                   ; $B34B: 0A
  TAY                                   ; $B34C: A8
Loc_B34D:
  LDA $B385,Y                           ; $B34D: B9 85 B3
  STA $0000                             ; $B350: 8D 00 00
  LDA $B386,Y                           ; $B353: B9 86 B3
  STA $0001                             ; $B356: 8D 01 00
  LDY #$00                              ; $B359: A0 00
Loc_B35B:
  LDA ($00),Y                           ; $B35B: B1 00
  STA $0383,Y                           ; $B35D: 99 83 03
  INY                                   ; $B360: C8
  CPY #$20                              ; $B361: C0 20
  BCC $B35B                             ; $B363: 90 F6
  JSR $B4BF                             ; $B365: 20 BF B4
  LDA #$FF                              ; $B368: A9 FF
  STA $03A3                             ; $B36A: 8D A3 03
  LDA $007E                             ; $B36D: AD 7E 00
  ORA #$04                              ; $B370: 09 04
  STA $007E                             ; $B372: 8D 7E 00
  INC $040D                             ; $B375: EE 0D 04
  LDA $040D                             ; $B378: AD 0D 04
  CMP #$0A                              ; $B37B: C9 0A
  BCC $B384                             ; $B37D: 90 05
  LDA #$FF                              ; $B37F: A9 FF
  STA $040D                             ; $B381: 8D 0D 04
Loc_B384:
  RTS                                   ; $B384: 60
; --- Data Region ---
  .byte $99,$B3,$B9,$B3,$D9,$B3,$F9,$B3,$19,$B4,$39,$B4,$59,$B4,$79,$B4; $B385: 99 B3 B9 B3 D9 B3 F9 B3 19 B4 39 B4 59 B4 79 B4
  .byte $99,$B4,$99,$B4,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01; $B395: 99 B4 99 B4 01 01 01 01 01 01 01 01 01 01 01 01
  .byte $01,$01,$01,$01,$01,$01,$40,$41,$01,$01,$01,$01,$46,$47,$01,$01; $B3A5: 01 01 01 01 01 01 40 41 01 01 01 01 46 47 01 01
  .byte $01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01; $B3B5: 01 01 01 01 01 01 00 00 00 00 01 01 01 01 01 01
  .byte $01,$01,$01,$01,$01,$01,$50,$51,$01,$01,$01,$01,$56,$57,$01,$01; $B3C5: 01 01 01 01 01 01 50 51 01 01 01 01 56 57 01 01
  .byte $01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$01,$01,$01,$01,$01,$39; $B3D5: 01 01 01 01 01 01 00 00 00 00 01 01 01 01 01 39
  .byte $01,$01,$01,$01,$01,$01,$42,$43,$01,$01,$01,$01,$48,$49,$01,$01; $B3E5: 01 01 01 01 01 01 42 43 01 01 01 01 48 49 01 01
  .byte $01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$01,$01,$32,$01,$2D,$20; $B3F5: 01 01 01 01 01 01 00 00 00 00 01 01 32 01 2D 20
  .byte $2C,$01,$01,$01,$32,$01,$52,$53,$01,$01,$01,$01,$58,$59,$01,$01; $B405: 2C 01 01 01 32 01 52 53 01 01 01 01 58 59 01 01
  .byte $01,$01,$01,$01,$01,$01,$00,$00,$00; $B415: 01 01 01 01 01 01 00 00 00
Loc_B41E:
; --- Code Region ---
  BRK                                   ; $B41E: 00
  ORA ($01,X)                           ; $B41F: 01 01
  ORA ($01,X)                           ; $B421: 01 01
  LSR $014F                             ; $B423: 4E 4F 01
  ORA ($01,X)                           ; $B426: 01 01
  ORA ($01,X)                           ; $B428: 01 01
  ORA ($44,X)                           ; $B42A: 01 44
  EOR $01                               ; $B42C: 45 01
  ORA ($01,X)                           ; $B42E: 01 01
  ORA ($4A,X)                           ; $B430: 01 4A
  ALR #$01                              ; $B432: 4B 01
  ORA ($01,X)                           ; $B434: 01 01
  ORA ($01,X)                           ; $B436: 01 01
  ORA ($01,X)                           ; $B438: 01 01
  ORA ($00,X)                           ; $B43A: 01 00
  BRK                                   ; $B43C: 00
  BRK                                   ; $B43D: 00
  BRK                                   ; $B43E: 00
  ORA ($01,X)                           ; $B43F: 01 01
  ORA ($01,X)                           ; $B441: 01 01
  LSR $015F,X                           ; $B443: 5E 5F 01
  ORA ($01,X)                           ; $B446: 01 01
  ORA ($01,X)                           ; $B448: 01 01
  ORA ($54,X)                           ; $B44A: 01 54
  EOR $01,X                             ; $B44C: 55 01
  ORA ($01,X)                           ; $B44E: 01 01
  ORA ($5A,X)                           ; $B450: 01 5A
  SRE $0101,Y                           ; $B452: 5B 01 01
  ORA ($01,X)                           ; $B455: 01 01
  ORA ($01,X)                           ; $B457: 01 01
  ORA ($01,X)                           ; $B459: 01 01
  ORA ($01,X)                           ; $B45B: 01 01
  ORA ($01,X)                           ; $B45D: 01 01
  ORA ($01,X)                           ; $B45F: 01 01
  JMP ($016D)                           ; $B461: 6C 6D 01
; --- Data Region ---
  .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$4C,$4D,$01,$01,$01,$01,$01; $B464: 01 01 01 01 01 01 01 01 01 4C 4D 01 01 01 01 01
  .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$6E,$6F,$6A; $B474: 01 01 01 01 01 01 01 01 01 01 01 01 01 6E 6F 6A
  .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$5C,$5D,$6A,$01,$01,$01,$01; $B484: 01 01 01 01 01 01 01 01 01 5C 5D 6A 01 01 01 01
  .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01; $B494: 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
  .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01; $B4A4: 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01
  .byte $01,$01,$01,$01,$01,$00,$24,$40,$25,$80,$26; $B4B4: 01 01 01 01 01 00 24 40 25 80 26
Loc_B4BF:
; --- Code Region ---
  LDY $040C                             ; $B4BF: AC 0C 04
  LDA $0410,Y                           ; $B4C2: B9 10 04
  CMP #$ED                              ; $B4C5: C9 ED
  BCC $B4CA                             ; $B4C7: 90 01
Loc_B4C9:
  RTS                                   ; $B4C9: 60
Loc_B4CA:
  JSR $F2D7                             ; $B4CA: 20 D7 F2
  LDA $0000                             ; $B4CD: AD 00 00
  STA $0010                             ; $B4D0: 8D 10 00
  LDA $0001                             ; $B4D3: AD 01 00
  STA $0011                             ; $B4D6: 8D 11 00
  LDA $040D                             ; $B4D9: AD 0D 04
  JSR $EADE                             ; $B4DC: 20 DE EA
; --- Data Region ---
  .byte $08,$B5,$2D,$B5,$07,$B5,$A6,$B5,$30,$B6,$4D,$B6,$30,$B7,$70,$B7; $B4DF: 08 B5 2D B5 07 B5 A6 B5 30 B6 4D B6 30 B7 70 B7
  .byte $F3,$B4,$07,$B5                   ; $B4EF: F3 B4 07 B5
Loc_B4F3:  ; (dispatch callback target)
; --- Code Region ---
  LDA $0401                             ; $B4F3: AD 01 04
  CMP #$03                              ; $B4F6: C9 03
  BEQ $B506                             ; $B4F8: F0 0C
  LDA $040E                             ; $B4FA: AD 0E 04
  STA $00BC                             ; $B4FD: 8D BC 00
  LDA $040F                             ; $B500: AD 0F 04
  STA $00BD                             ; $B503: 8D BD 00
Loc_B506:
  RTS                                   ; $B506: 60
Loc_B507:  ; (dispatch callback target)
  RTS                                   ; $B507: 60
Loc_B508:  ; (dispatch callback target)
  LDY $040C                             ; $B508: AC 0C 04
  LDA $0410,Y                           ; $B50B: B9 10 04
  JSR $F308                             ; $B50E: 20 08 F3
  TAX                                   ; $B511: AA
  LDY #$00                              ; $B512: A0 00
Loc_B514:
  LDA ($00),Y                           ; $B514: B1 00
  BEQ $B52C                             ; $B516: F0 14
  CMP #$39                              ; $B518: C9 39
  BEQ $B525                             ; $B51A: F0 09
  CMP #$3A                              ; $B51C: C9 3A
  BEQ $B525                             ; $B51E: F0 05
  INY                                   ; $B520: C8
  INX                                   ; $B521: E8
  JMP $B514                             ; $B522: 4C 14 B5
Loc_B525:
  STA $038A,X                           ; $B525: 9D 8A 03
  INY                                   ; $B528: C8
  JMP $B514                             ; $B529: 4C 14 B5
Loc_B52C:
  RTS                                   ; $B52C: 60
Loc_B52D:  ; (dispatch callback target)
  LDY $040C                             ; $B52D: AC 0C 04
  LDA $0410,Y                           ; $B530: B9 10 04
  JSR $F308                             ; $B533: 20 08 F3
  TAX                                   ; $B536: AA
  LDY #$00                              ; $B537: A0 00
Loc_B539:
  LDA ($00),Y                           ; $B539: B1 00
  BEQ $B54D                             ; $B53B: F0 10
  CMP #$39                              ; $B53D: C9 39
  BEQ $B549                             ; $B53F: F0 08
  CMP #$3A                              ; $B541: C9 3A
  BEQ $B549                             ; $B543: F0 04
  STA $038B,X                           ; $B545: 9D 8B 03
  INX                                   ; $B548: E8
Loc_B549:
  INY                                   ; $B549: C8
  JMP $B539                             ; $B54A: 4C 39 B5
Loc_B54D:
  LDY #$00                              ; $B54D: A0 00
  LDA ($10),Y                           ; $B54F: B1 10
  STA $0001                             ; $B551: 8D 01 00
  LDA #$00                              ; $B554: A9 00
  STA $0002                             ; $B556: 8D 02 00
  STA $0003                             ; $B559: 8D 03 00
  JSR $E9BA                             ; $B55C: 20 BA E9
  LDA $0007                             ; $B55F: AD 07 00
  LSR                                   ; $B562: 4A
  LSR                                   ; $B563: 4A
  LSR                                   ; $B564: 4A
  LSR                                   ; $B565: 4A
  BEQ $B56E                             ; $B566: F0 06
  CLC                                   ; $B568: 18
  ADC #$76                              ; $B569: 69 76
  STA $0398                             ; $B56B: 8D 98 03
Loc_B56E:
  LDA $0007                             ; $B56E: AD 07 00
  AND #$0F                              ; $B571: 29 0F
  CLC                                   ; $B573: 18
  ADC #$76                              ; $B574: 69 76
  STA $0399                             ; $B576: 8D 99 03
  LDY #$04                              ; $B579: A0 04
  LDA ($10),Y                           ; $B57B: B1 10
  STA $0001                             ; $B57D: 8D 01 00
  LDA #$00                              ; $B580: A9 00
  STA $0002                             ; $B582: 8D 02 00
  STA $0003                             ; $B585: 8D 03 00
  JSR $E9BA                             ; $B588: 20 BA E9
  LDA $0007                             ; $B58B: AD 07 00
  LSR                                   ; $B58E: 4A
  LSR                                   ; $B58F: 4A
  LSR                                   ; $B590: 4A
  LSR                                   ; $B591: 4A
  BEQ $B59A                             ; $B592: F0 06
  CLC                                   ; $B594: 18
  ADC #$76                              ; $B595: 69 76
  STA $039E                             ; $B597: 8D 9E 03
Loc_B59A:
  LDA $0007                             ; $B59A: AD 07 00
  AND #$0F                              ; $B59D: 29 0F
  CLC                                   ; $B59F: 18
  ADC #$76                              ; $B5A0: 69 76
  STA $039F                             ; $B5A2: 8D 9F 03
  RTS                                   ; $B5A5: 60
Loc_B5A6:  ; (dispatch callback target)
  LDY #$0B                              ; $B5A6: A0 0B
  LDA ($10),Y                           ; $B5A8: B1 10
  LSR                                   ; $B5AA: 4A
  LSR                                   ; $B5AB: 4A
  LSR                                   ; $B5AC: 4A
  LSR                                   ; $B5AD: 4A
  CLC                                   ; $B5AE: 18
  ADC #$01                              ; $B5AF: 69 01
  STA $0001                             ; $B5B1: 8D 01 00
  LDA #$00                              ; $B5B4: A9 00
  STA $0002                             ; $B5B6: 8D 02 00
  STA $0003                             ; $B5B9: 8D 03 00
  JSR $E9BA                             ; $B5BC: 20 BA E9
  LDA $0007                             ; $B5BF: AD 07 00
  AND #$0F                              ; $B5C2: 29 0F
  CLC                                   ; $B5C4: 18
  ADC #$76                              ; $B5C5: 69 76
  STA $0391                             ; $B5C7: 8D 91 03
  LDY #$02                              ; $B5CA: A0 02
  LDA ($10),Y                           ; $B5CC: B1 10
  STA $0001                             ; $B5CE: 8D 01 00
  LDA #$00                              ; $B5D1: A9 00
  STA $0002                             ; $B5D3: 8D 02 00
  STA $0003                             ; $B5D6: 8D 03 00
  JSR $E9BA                             ; $B5D9: 20 BA E9
  LDA $0007                             ; $B5DC: AD 07 00
  LSR                                   ; $B5DF: 4A
  LSR                                   ; $B5E0: 4A
  LSR                                   ; $B5E1: 4A
  LSR                                   ; $B5E2: 4A
  BEQ $B5EB                             ; $B5E3: F0 06
  CLC                                   ; $B5E5: 18
  ADC #$76                              ; $B5E6: 69 76
  STA $0398                             ; $B5E8: 8D 98 03
Loc_B5EB:
  LDA $0007                             ; $B5EB: AD 07 00
  AND #$0F                              ; $B5EE: 29 0F
  CLC                                   ; $B5F0: 18
  ADC #$76                              ; $B5F1: 69 76
  STA $0399                             ; $B5F3: 8D 99 03
  LDY #$03                              ; $B5F6: A0 03
  LDA ($10),Y                           ; $B5F8: B1 10
  STA $0001                             ; $B5FA: 8D 01 00
  CMP #$64                              ; $B5FD: C9 64
  BEQ $B627                             ; $B5FF: F0 26
  LDA #$00                              ; $B601: A9 00
  STA $0002                             ; $B603: 8D 02 00
  STA $0003                             ; $B606: 8D 03 00
  JSR $E9BA                             ; $B609: 20 BA E9
  LDA $0007                             ; $B60C: AD 07 00
  LSR                                   ; $B60F: 4A
  LSR                                   ; $B610: 4A
  LSR                                   ; $B611: 4A
  LSR                                   ; $B612: 4A
  BEQ $B61B                             ; $B613: F0 06
  CLC                                   ; $B615: 18
  ADC #$76                              ; $B616: 69 76
  STA $039E                             ; $B618: 8D 9E 03
Loc_B61B:
  LDA $0007                             ; $B61B: AD 07 00
  AND #$0F                              ; $B61E: 29 0F
  CLC                                   ; $B620: 18
  ADC #$76                              ; $B621: 69 76
  STA $039F                             ; $B623: 8D 9F 03
  RTS                                   ; $B626: 60
Loc_B627:
  LDA #$32                              ; $B627: A9 32
  STA $039E                             ; $B629: 8D 9E 03
  STA $039F                             ; $B62C: 8D 9F 03
  RTS                                   ; $B62F: 60
Loc_B630:  ; (dispatch callback target)
  LDY #$0B                              ; $B630: A0 0B
  LDA ($10),Y                           ; $B632: B1 10
  LSR                                   ; $B634: 4A
  LSR                                   ; $B635: 4A
  AND #$03                              ; $B636: 29 03
  ASL                                   ; $B638: 0A
  TAY                                   ; $B639: A8
  LDA $B647,Y                           ; $B63A: B9 47 B6
  STA $038B                             ; $B63D: 8D 8B 03
  LDA $B648,Y                           ; $B640: B9 48 B6
  STA $038C                             ; $B643: 8D 8C 03
  RTS                                   ; $B646: 60
; --- Data Region ---
  .byte $62,$63,$64,$65,$60,$61           ; $B647: 62 63 64 65 60 61
Loc_B64D:  ; (dispatch callback target)
; --- Code Region ---
  LDY #$0B                              ; $B64D: A0 0B
  LDA ($10),Y                           ; $B64F: B1 10
  LSR                                   ; $B651: 4A
  LSR                                   ; $B652: 4A
  AND #$03                              ; $B653: 29 03
  ASL                                   ; $B655: 0A
  TAY                                   ; $B656: A8
  LDA $B713,Y                           ; $B657: B9 13 B7
  STA $038B                             ; $B65A: 8D 8B 03
  LDA $B714,Y                           ; $B65D: B9 14 B7
  STA $038C                             ; $B660: 8D 8C 03
  LDY #$08                              ; $B663: A0 08
  LDA ($10),Y                           ; $B665: B1 10
  STA $0001                             ; $B667: 8D 01 00
  LDY #$09                              ; $B66A: A0 09
  LDA ($10),Y                           ; $B66C: B1 10
  AND #$03                              ; $B66E: 29 03
  STA $0002                             ; $B670: 8D 02 00
  LDA #$00                              ; $B673: A9 00
  STA $0003                             ; $B675: 8D 03 00
  JSR $E9BA                             ; $B678: 20 BA E9
  LDX #$00                              ; $B67B: A2 00
  LDY #$00                              ; $B67D: A0 00
  LDA $0008                             ; $B67F: AD 08 00
  JSR $B719                             ; $B682: 20 19 B7
  LDA $0008                             ; $B685: AD 08 00
  JSR $B71D                             ; $B688: 20 1D B7
  LDA $0007                             ; $B68B: AD 07 00
  JSR $B719                             ; $B68E: 20 19 B7
  LDA $0007                             ; $B691: AD 07 00
  AND #$0F                              ; $B694: 29 0F
  JSR $B727                             ; $B696: 20 27 B7
  LDY #$01                              ; $B699: A0 01
  LDA ($10),Y                           ; $B69B: B1 10
  STA $0001                             ; $B69D: 8D 01 00
  LDA #$00                              ; $B6A0: A9 00
  STA $0002                             ; $B6A2: 8D 02 00
  STA $0003                             ; $B6A5: 8D 03 00
  JSR $E9BA                             ; $B6A8: 20 BA E9
  LDA $0007                             ; $B6AB: AD 07 00
  LSR                                   ; $B6AE: 4A
  LSR                                   ; $B6AF: 4A
  LSR                                   ; $B6B0: 4A
  LSR                                   ; $B6B1: 4A
  BEQ $B6BA                             ; $B6B2: F0 06
  CLC                                   ; $B6B4: 18
  ADC #$76                              ; $B6B5: 69 76
  STA $0398                             ; $B6B7: 8D 98 03
Loc_B6BA:
  LDA $0007                             ; $B6BA: AD 07 00
  AND #$0F                              ; $B6BD: 29 0F
  CLC                                   ; $B6BF: 18
  ADC #$76                              ; $B6C0: 69 76
  STA $0399                             ; $B6C2: 8D 99 03
  LDY #$06                              ; $B6C5: A0 06
  LDA ($10),Y                           ; $B6C7: B1 10
  STA $0001                             ; $B6C9: 8D 01 00
  LDY #$07                              ; $B6CC: A0 07
  LDA ($10),Y                           ; $B6CE: B1 10
  STA $0002                             ; $B6D0: 8D 02 00
  LDA #$00                              ; $B6D3: A9 00
  STA $0003                             ; $B6D5: 8D 03 00
  ASL $0001                             ; $B6D8: 0E 01 00
  ROL $0002                             ; $B6DB: 2E 02 00
  ROL $0003                             ; $B6DE: 2E 03 00
  JSR $E9BA                             ; $B6E1: 20 BA E9
  LDX #$00                              ; $B6E4: A2 00
  LDA $0009                             ; $B6E6: AD 09 00
  AND #$0F                              ; $B6E9: 29 0F
  BEQ $B6F4                             ; $B6EB: F0 07
  CLC                                   ; $B6ED: 18
  ADC #$76                              ; $B6EE: 69 76
  STA $039D                             ; $B6F0: 8D 9D 03
  INX                                   ; $B6F3: E8
Loc_B6F4:
  LDA $0008                             ; $B6F4: AD 08 00
  LSR                                   ; $B6F7: 4A
  LSR                                   ; $B6F8: 4A
  LSR                                   ; $B6F9: 4A
  LSR                                   ; $B6FA: 4A
  BNE $B701                             ; $B6FB: D0 04
  CPX #$00                              ; $B6FD: E0 00
  BEQ $B707                             ; $B6FF: F0 06
Loc_B701:
  CLC                                   ; $B701: 18
  ADC #$76                              ; $B702: 69 76
  STA $039E                             ; $B704: 8D 9E 03
Loc_B707:
  LDA $0008                             ; $B707: AD 08 00
  AND #$0F                              ; $B70A: 29 0F
  CLC                                   ; $B70C: 18
  ADC #$76                              ; $B70D: 69 76
  STA $039F                             ; $B70F: 8D 9F 03
  RTS                                   ; $B712: 60
; --- Data Region ---
  .byte $72,$73,$74,$75,$70,$71           ; $B713: 72 73 74 75 70 71
Loc_B719:
; --- Code Region ---
  LSR                                   ; $B719: 4A
  LSR                                   ; $B71A: 4A
  LSR                                   ; $B71B: 4A
  LSR                                   ; $B71C: 4A
Loc_B71D:
  AND #$0F                              ; $B71D: 29 0F
  CPX #$00                              ; $B71F: E0 00
  BNE $B727                             ; $B721: D0 04
  CMP #$00                              ; $B723: C9 00
  BEQ $B72E                             ; $B725: F0 07
Loc_B727:
  CLC                                   ; $B727: 18
  ADC #$76                              ; $B728: 69 76
  STA $0390,Y                           ; $B72A: 99 90 03
  INX                                   ; $B72D: E8
Loc_B72E:
  INY                                   ; $B72E: C8
  RTS                                   ; $B72F: 60
Loc_B730:  ; (dispatch callback target)
  LDY #$0A                              ; $B730: A0 0A
  LDA ($10),Y                           ; $B732: B1 10
  STA $0015                             ; $B734: 8D 15 00
  AND #$1F                              ; $B737: 29 1F
  JSR $B7C1                             ; $B739: 20 C1 B7
  LDA #$00                              ; $B73C: A9 00
  LDX #$0E                              ; $B73E: A2 0E
  LDY #$01                              ; $B740: A0 01
  JSR $B7A2                             ; $B742: 20 A2 B7
  LDY #$00                              ; $B745: A0 00
  LDA ($12),Y                           ; $B747: B1 12
  STA $040E                             ; $B749: 8D 0E 04
  LDA $0015                             ; $B74C: AD 15 00
  ROL                                   ; $B74F: 2A
  ROL                                   ; $B750: 2A
  ROL                                   ; $B751: 2A
  ROL                                   ; $B752: 2A
  AND #$07                              ; $B753: 29 07
  CLC                                   ; $B755: 18
  ADC #$18                              ; $B756: 69 18
  JSR $B7C1                             ; $B758: 20 C1 B7
  LDA #$40                              ; $B75B: A9 40
  LDX #$1A                              ; $B75D: A2 1A
  LDY #$01                              ; $B75F: A0 01
  JSR $B7A2                             ; $B761: 20 A2 B7
  LDY #$00                              ; $B764: A0 00
  LDA ($12),Y                           ; $B766: B1 12
  STA $040F                             ; $B768: 8D 0F 04
  LDY #$31                              ; $B76B: A0 31
  JMP $F25F                             ; $B76D: 4C 5F F2
Loc_B770:  ; (dispatch callback target)
  LDY #$0A                              ; $B770: A0 0A
  LDA ($10),Y                           ; $B772: B1 10
  STA $0015                             ; $B774: 8D 15 00
  AND #$1F                              ; $B777: 29 1F
  JSR $B7C1                             ; $B779: 20 C1 B7
  LDA #$00                              ; $B77C: A9 00
  LDX #$0E                              ; $B77E: A2 0E
  LDY #$09                              ; $B780: A0 09
  JSR $B7A2                             ; $B782: 20 A2 B7
  LDA $0015                             ; $B785: AD 15 00
  ROL                                   ; $B788: 2A
  ROL                                   ; $B789: 2A
  ROL                                   ; $B78A: 2A
  ROL                                   ; $B78B: 2A
  AND #$07                              ; $B78C: 29 07
  CLC                                   ; $B78E: 18
  ADC #$18                              ; $B78F: 69 18
  JSR $B7C1                             ; $B791: 20 C1 B7
  LDA #$40                              ; $B794: A9 40
  LDX #$1A                              ; $B796: A2 1A
  LDY #$09                              ; $B798: A0 09
  JSR $B7A2                             ; $B79A: 20 A2 B7
  LDY #$31                              ; $B79D: A0 31
  JMP $F25F                             ; $B79F: 4C 5F F2
Loc_B7A2:
  STA $0014                             ; $B7A2: 8D 14 00
  TYA                                   ; $B7A5: 98
  CLC                                   ; $B7A6: 18
  ADC #$08                              ; $B7A7: 69 08
  STA $0002                             ; $B7A9: 8D 02 00
Loc_B7AC:
  LDA ($12),Y                           ; $B7AC: B1 12
  CMP #$01                              ; $B7AE: C9 01
  BEQ $B7B6                             ; $B7B0: F0 04
  CLC                                   ; $B7B2: 18
  ADC $0014                             ; $B7B3: 6D 14 00
Loc_B7B6:
  STA $0380,X                           ; $B7B6: 9D 80 03
  INX                                   ; $B7B9: E8
  INY                                   ; $B7BA: C8
  CPY $0002                             ; $B7BB: CC 02 00
  BCC $B7AC                             ; $B7BE: 90 EC
  RTS                                   ; $B7C0: 60
Loc_B7C1:
  ASL                                   ; $B7C1: 0A
  TAX                                   ; $B7C2: AA
  LDY #$30                              ; $B7C3: A0 30
  JSR $F25F                             ; $B7C5: 20 5F F2
  LDA $9B12,X                           ; $B7C8: BD 12 9B
  STA $0012                             ; $B7CB: 8D 12 00
  INX                                   ; $B7CE: E8
  LDA $9B12,X                           ; $B7CF: BD 12 9B
  CLC                                   ; $B7D2: 18
  ADC #$80                              ; $B7D3: 69 80
  STA $0013                             ; $B7D5: 8D 13 00
  RTS                                   ; $B7D8: 60
Loc_B7D9:
  LDA $0471                             ; $B7D9: AD 71 04
  JSR $F2AF                             ; $B7DC: 20 AF F2
  LDY #$02                              ; $B7DF: A0 02
  LDX #$26                              ; $B7E1: A2 26
Loc_B7E3:
  LDA ($00),Y                           ; $B7E3: B1 00
  STA $0500,X                           ; $B7E5: 9D 00 05
  LDA #$00                              ; $B7E8: A9 00
  STA ($00),Y                           ; $B7EA: 91 00
  INY                                   ; $B7EC: C8
  INX                                   ; $B7ED: E8
  CPX #$28                              ; $B7EE: E0 28
  BNE $B7F4                             ; $B7F0: D0 02
  LDX #$22                              ; $B7F2: A2 22
Loc_B7F4:
  CPY #$06                              ; $B7F4: C0 06
  BCC $B7E3                             ; $B7F6: 90 EB
  LDY #$00                              ; $B7F8: A0 00
  LDA ($00),Y                           ; $B7FA: B1 00
  STA $0507                             ; $B7FC: 8D 07 05
  LDA $0000                             ; $B7FF: AD 00 00
  CLC                                   ; $B802: 18
  ADC #$11                              ; $B803: 69 11
  STA $0000                             ; $B805: 8D 00 00
  LDA $0001                             ; $B808: AD 01 00
  ADC #$00                              ; $B80B: 69 00
  STA $0001                             ; $B80D: 8D 01 00
  LDY #$09                              ; $B810: A0 09
Loc_B812:
  LDA ($00),Y                           ; $B812: B1 00
  STA $0664,Y                           ; $B814: 99 64 06
  LDA #$FF                              ; $B817: A9 FF
  STA ($00),Y                           ; $B819: 91 00
  DEY                                   ; $B81B: 88
  BPL $B812                             ; $B81C: 10 F4
  LDY #$0A                              ; $B81E: A0 0A
  LDA $0481                             ; $B820: AD 81 04
  STA $0664,Y                           ; $B823: 99 64 06
  INY                                   ; $B826: C8
  LDX #$00                              ; $B827: A2 00
Loc_B829:
  CPX #$0A                              ; $B829: E0 0A
  BCC $B832                             ; $B82B: 90 05
  LDA #$FF                              ; $B82D: A9 FF
  JMP $B83A                             ; $B82F: 4C 3A B8
Loc_B832:
  LDA $0151,X                           ; $B832: BD 51 01
  CMP $0481                             ; $B835: CD 81 04
  BEQ $B83E                             ; $B838: F0 04
Loc_B83A:
  STA $0664,Y                           ; $B83A: 99 64 06
  INY                                   ; $B83D: C8
Loc_B83E:
  INX                                   ; $B83E: E8
  CPY #$14                              ; $B83F: C0 14
  BCC $B829                             ; $B841: 90 E6
  LDA $0402                             ; $B843: AD 02 04
  JSR $F2AF                             ; $B846: 20 AF F2
  LDY #$00                              ; $B849: A0 00
  LDA ($00),Y                           ; $B84B: B1 00
  ASL                                   ; $B84D: 0A
  ASL                                   ; $B84E: 0A
  ASL                                   ; $B84F: 0A
  ASL                                   ; $B850: 0A
  ORA $0507                             ; $B851: 0D 07 05
  STA $0507                             ; $B854: 8D 07 05
  LDX #$00                              ; $B857: A2 00
Loc_B859:
  LDA $0151,X                           ; $B859: BD 51 01
  CMP #$FF                              ; $B85C: C9 FF
  BEQ $B879                             ; $B85E: F0 19
  STA $0002                             ; $B860: 8D 02 00
  LDY #$11                              ; $B863: A0 11
Loc_B865:
  LDA ($00),Y                           ; $B865: B1 00
  CMP $0002                             ; $B867: CD 02 00
  BEQ $B870                             ; $B86A: F0 04
  INY                                   ; $B86C: C8
  JMP $B865                             ; $B86D: 4C 65 B8
Loc_B870:
  LDA #$FF                              ; $B870: A9 FF
  STA ($00),Y                           ; $B872: 91 00
  INX                                   ; $B874: E8
  CPX #$0A                              ; $B875: E0 0A
  BCC $B859                             ; $B877: 90 E0
Loc_B879:
  LDY #$11                              ; $B879: A0 11
  LDA #$10                              ; $B87B: A9 10
  STA $0003                             ; $B87D: 8D 03 00
Loc_B880:
  LDA ($00),Y                           ; $B880: B1 00
  STA $0002                             ; $B882: 8D 02 00
  LDA #$FF                              ; $B885: A9 FF
  STA ($00),Y                           ; $B887: 91 00
  LDA $0002                             ; $B889: AD 02 00
  CMP #$FF                              ; $B88C: C9 FF
  BEQ $B89F                             ; $B88E: F0 0F
  TYA                                   ; $B890: 98
  TAX                                   ; $B891: AA
  INC $0003                             ; $B892: EE 03 00
  LDY $0003                             ; $B895: AC 03 00
  LDA $0002                             ; $B898: AD 02 00
  STA ($00),Y                           ; $B89B: 91 00
  TXA                                   ; $B89D: 8A
  TAY                                   ; $B89E: A8
Loc_B89F:
  INY                                   ; $B89F: C8
  CPY #$1B                              ; $B8A0: C0 1B
  BCC $B880                             ; $B8A2: 90 DC
  LDY #$11                              ; $B8A4: A0 11
  LDA ($00),Y                           ; $B8A6: B1 00
  CMP #$FF                              ; $B8A8: C9 FF
  BNE $B8B2                             ; $B8AA: D0 06
  LDA #$07                              ; $B8AC: A9 07
  LDY #$00                              ; $B8AE: A0 00
  STA ($00),Y                           ; $B8B0: 91 00
Loc_B8B2:
  LDY #$02                              ; $B8B2: A0 02
  LDA ($00),Y                           ; $B8B4: B1 00
  SEC                                   ; $B8B6: 38
  SBC $042F                             ; $B8B7: ED 2F 04
  STA ($00),Y                           ; $B8BA: 91 00
  INY                                   ; $B8BC: C8
  LDA ($00),Y                           ; $B8BD: B1 00
  SBC $0430                             ; $B8BF: ED 30 04
  STA ($00),Y                           ; $B8C2: 91 00
  LDY #$04                              ; $B8C4: A0 04
  LDA ($00),Y                           ; $B8C6: B1 00
  SEC                                   ; $B8C8: 38
  SBC $0432                             ; $B8C9: ED 32 04
  STA ($00),Y                           ; $B8CC: 91 00
  INY                                   ; $B8CE: C8
  LDA ($00),Y                           ; $B8CF: B1 00
  SBC $0433                             ; $B8D1: ED 33 04
  STA ($00),Y                           ; $B8D4: 91 00
  RTS                                   ; $B8D6: 60
Loc_B8D7:
  LDA $0470                             ; $B8D7: AD 70 04
  JSR $F2AF                             ; $B8DA: 20 AF F2
  LDY #$02                              ; $B8DD: A0 02
  LDA ($00),Y                           ; $B8DF: B1 00
  STA $0498                             ; $B8E1: 8D 98 04
  INY                                   ; $B8E4: C8
  LDA ($00),Y                           ; $B8E5: B1 00
  STA $0499                             ; $B8E7: 8D 99 04
  LDY #$04                              ; $B8EA: A0 04
  LDA ($00),Y                           ; $B8EC: B1 00
  STA $049A                             ; $B8EE: 8D 9A 04
  INY                                   ; $B8F1: C8
  LDA ($00),Y                           ; $B8F2: B1 00
  STA $049B                             ; $B8F4: 8D 9B 04
  LDY #$10                              ; $B8F7: A0 10
  LDA ($00),Y                           ; $B8F9: B1 00
  STA $049C                             ; $B8FB: 8D 9C 04
  LDA #$00                              ; $B8FE: A9 00
  STA $049D                             ; $B900: 8D 9D 04
  LDA $0471                             ; $B903: AD 71 04
  JSR $F2AF                             ; $B906: 20 AF F2
  LDY #$02                              ; $B909: A0 02
  LDA #$0F                              ; $B90B: A9 0F
  SEC                                   ; $B90D: 38
  SBC ($00),Y                           ; $B90E: F1 00
  STA $0010                             ; $B910: 8D 10 00
  INY                                   ; $B913: C8
  LDA #$27                              ; $B914: A9 27
  SBC ($00),Y                           ; $B916: F1 00
  STA $0011                             ; $B918: 8D 11 00
  LDY #$00                              ; $B91B: A0 00
  JSR $B948                             ; $B91D: 20 48 B9
  LDY #$04                              ; $B920: A0 04
  LDA #$0F                              ; $B922: A9 0F
  SEC                                   ; $B924: 38
  SBC ($00),Y                           ; $B925: F1 00
  STA $0010                             ; $B927: 8D 10 00
  INY                                   ; $B92A: C8
  LDA #$27                              ; $B92B: A9 27
  SBC ($00),Y                           ; $B92D: F1 00
  STA $0011                             ; $B92F: 8D 11 00
  LDY #$02                              ; $B932: A0 02
  JSR $B948                             ; $B934: 20 48 B9
  LDY #$10                              ; $B937: A0 10
  LDA #$63                              ; $B939: A9 63
  SEC                                   ; $B93B: 38
  SBC ($00),Y                           ; $B93C: F1 00
  STA $0010                             ; $B93E: 8D 10 00
  LDA #$00                              ; $B941: A9 00
  STA $0011                             ; $B943: 8D 11 00
  LDY #$04                              ; $B946: A0 04
Loc_B948:
  LDA $0010                             ; $B948: AD 10 00
  SEC                                   ; $B94B: 38
  SBC $0498,Y                           ; $B94C: F9 98 04
  LDA $0011                             ; $B94F: AD 11 00
  SBC $0499,Y                           ; $B952: F9 99 04
  BCS $B963                             ; $B955: B0 0C
  LDA $0010                             ; $B957: AD 10 00
  STA $0498,Y                           ; $B95A: 99 98 04
  LDA $0011                             ; $B95D: AD 11 00
  STA $0499,Y                           ; $B960: 99 99 04
Loc_B963:
  RTS                                   ; $B963: 60
Loc_B964:
  LDY #$31                              ; $B964: A0 31
  JSR $F25F                             ; $B966: 20 5F F2
  LDA $0402                             ; $B969: AD 02 04
  STA $0000                             ; $B96C: 8D 00 00
  LDA #$00                              ; $B96F: A9 00
  STA $0001                             ; $B971: 8D 01 00
  STA $0002                             ; $B974: 8D 02 00
  LDA #$14                              ; $B977: A9 14
  STA $0003                             ; $B979: 8D 03 00
  JSR $EBE9                             ; $B97C: 20 E9 EB
  LDA $0006                             ; $B97F: AD 06 00
  CLC                                   ; $B982: 18
  ADC #$1C                              ; $B983: 69 1C
  STA $0002                             ; $B985: 8D 02 00
  LDA $0007                             ; $B988: AD 07 00
  ADC #$8B                              ; $B98B: 69 8B
  STA $0003                             ; $B98D: 8D 03 00
  LDA #$00                              ; $B990: A9 00
  STA $0004                             ; $B992: 8D 04 00
Loc_B995:
  LDY $0004                             ; $B995: AC 04 00
  LDA ($02),Y                           ; $B998: B1 02
  STA $0472                             ; $B99A: 8D 72 04
  CMP #$FF                              ; $B99D: C9 FF
  BNE $B9A4                             ; $B99F: D0 03
  JMP $B9EA                             ; $B9A1: 4C EA B9
Loc_B9A4:
  JSR $F2D7                             ; $B9A4: 20 D7 F2
  LDY #$0B                              ; $B9A7: A0 0B
  LDA ($00),Y                           ; $B9A9: B1 00
  AND #$03                              ; $B9AB: 29 03
  CMP #$01                              ; $B9AD: C9 01
  BEQ $B9BA                             ; $B9AF: F0 09
  INC $0004                             ; $B9B1: EE 04 00
  INC $0004                             ; $B9B4: EE 04 00
  JMP $B995                             ; $B9B7: 4C 95 B9
Loc_B9BA:
  INC $0004                             ; $B9BA: EE 04 00
  LDY $0004                             ; $B9BD: AC 04 00
  LDA ($02),Y                           ; $B9C0: B1 02
  SEC                                   ; $B9C2: 38
  SBC #$64                              ; $B9C3: E9 64
  CMP $6F00                             ; $B9C5: CD 00 6F
  BEQ $B9CC                             ; $B9C8: F0 02
  BCS $B9EA                             ; $B9CA: B0 1E
Loc_B9CC:
  LDY #$00                              ; $B9CC: A0 00
Loc_B9CE:
  LDA $BA50,Y                           ; $B9CE: B9 50 BA
  CMP $0472                             ; $B9D1: CD 72 04
  BEQ $B9DD                             ; $B9D4: F0 07
  INY                                   ; $B9D6: C8
  INY                                   ; $B9D7: C8
  CPY #$24                              ; $B9D8: C0 24
  BCC $B9CE                             ; $B9DA: 90 F2
  RTS                                   ; $B9DC: 60
Loc_B9DD:
  INY                                   ; $B9DD: C8
  LDA $BA50,Y                           ; $B9DE: B9 50 BA
  STA $0473                             ; $B9E1: 8D 73 04
  LDA #$07                              ; $B9E4: A9 07
  STA $0470                             ; $B9E6: 8D 70 04
  RTS                                   ; $B9E9: 60
Loc_B9EA:
  LDY #$30                              ; $B9EA: A0 30
  JSR $F25F                             ; $B9EC: 20 5F F2
  LDA $0402                             ; $B9EF: AD 02 04
  ASL                                   ; $B9F2: 0A
  ASL                                   ; $B9F3: 0A
  ASL                                   ; $B9F4: 0A
  TAY                                   ; $B9F5: A8
  LDX #$00                              ; $B9F6: A2 00
Loc_B9F8:
  LDA $9D72,Y                           ; $B9F8: B9 72 9D
  STA $0160,X                           ; $B9FB: 9D 60 01
  INY                                   ; $B9FE: C8
  INX                                   ; $B9FF: E8
  CPX #$08                              ; $BA00: E0 08
  BCC $B9F8                             ; $BA02: 90 F4
  LDY #$31                              ; $BA04: A0 31
  JSR $F25F                             ; $BA06: 20 5F F2
  LDA #$00                              ; $BA09: A9 00
  STA $0004                             ; $BA0B: 8D 04 00
Loc_BA0E:
  LDA $0004                             ; $BA0E: AD 04 00
  JSR $F2D7                             ; $BA11: 20 D7 F2
  LDY #$0B                              ; $BA14: A0 0B
  LDA ($00),Y                           ; $BA16: B1 00
  AND #$03                              ; $BA18: 29 03
  BEQ $BA2C                             ; $BA1A: F0 10
Loc_BA1C:
  INC $0004                             ; $BA1C: EE 04 00
  LDA $0004                             ; $BA1F: AD 04 00
  CMP #$ED                              ; $BA22: C9 ED
  BCC $BA0E                             ; $BA24: 90 E8
  LDA #$80                              ; $BA26: A9 80
  STA $0011                             ; $BA28: 8D 11 00
Loc_BA2B:
  RTS                                   ; $BA2B: 60
Loc_BA2C:
  LDA $0004                             ; $BA2C: AD 04 00
  STA $0472                             ; $BA2F: 8D 72 04
  LDY #$05                              ; $BA32: A0 05
  LDA ($00),Y                           ; $BA34: B1 00
  CMP $0402                             ; $BA36: CD 02 04
  BEQ $BA2B                             ; $BA39: F0 F0
  STA $0005                             ; $BA3B: 8D 05 00
  LDX #$00                              ; $BA3E: A2 00
Loc_BA40:
  LDA $0160,X                           ; $BA40: BD 60 01
  CMP $0005                             ; $BA43: CD 05 00
  BEQ $BA2B                             ; $BA46: F0 E3
  INX                                   ; $BA48: E8
  CPX #$08                              ; $BA49: E0 08
  BCC $BA40                             ; $BA4B: 90 F3
  JMP $BA1C                             ; $BA4D: 4C 1C BA
; --- Data Region ---
  .byte $6D,$04,$70,$04,$56,$02,$37,$04,$B7,$04,$63,$02,$6B,$03,$2F,$03; $BA50: 6D 04 70 04 56 02 37 04 B7 04 63 02 6B 03 2F 03
  .byte $A1,$02,$EA,$03,$EB,$03,$D5,$03,$90,$04,$39,$02,$A5,$02,$9C,$02; $BA60: A1 02 EA 03 EB 03 D5 03 90 04 39 02 A5 02 9C 02
Loc_BA70:
; --- Code Region ---
  LDX #$7F                              ; $BA70: A2 7F
  LDA $0470                             ; $BA72: AD 70 04
  BEQ $BA7F                             ; $BA75: F0 08
  LDX #$88                              ; $BA77: A2 88
  CMP #$01                              ; $BA79: C9 01
  BEQ $BA7F                             ; $BA7B: F0 02
  LDX #$91                              ; $BA7D: A2 91
Loc_BA7F:
  STX $0471                             ; $BA7F: 8E 71 04
Loc_BA82:
  JSR $E856                             ; $BA82: 20 56 E8
  CMP #$05                              ; $BA85: C9 05
  BCS $BA82                             ; $BA87: B0 F9
  STA $0010                             ; $BA89: 8D 10 00
  LDA $0481                             ; $BA8C: AD 81 04
  JSR $F2D7                             ; $BA8F: 20 D7 F2
  LDY #$02                              ; $BA92: A0 02
  LDA ($00),Y                           ; $BA94: B1 00
  CMP #$51                              ; $BA96: C9 51
  BCS $BAAD                             ; $BA98: B0 13
  CMP #$33                              ; $BA9A: C9 33
  BCS $BAA1                             ; $BA9C: B0 03
  JMP $BAB6                             ; $BA9E: 4C B6 BA
Loc_BAA1:
  LDA $0010                             ; $BAA1: AD 10 00
  CLC                                   ; $BAA4: 18
  ADC #$02                              ; $BAA5: 69 02
  STA $0010                             ; $BAA7: 8D 10 00
  JMP $BAB6                             ; $BAAA: 4C B6 BA
Loc_BAAD:
  LDA $0010                             ; $BAAD: AD 10 00
  CLC                                   ; $BAB0: 18
  ADC #$04                              ; $BAB1: 69 04
  STA $0010                             ; $BAB3: 8D 10 00
Loc_BAB6:
  LDA $0010                             ; $BAB6: AD 10 00
  CLC                                   ; $BAB9: 18
  ADC $0471                             ; $BABA: 6D 71 04
  STA $0471                             ; $BABD: 8D 71 04
  LDY $0010                             ; $BAC0: AC 10 00
  LDA $BADF,Y                           ; $BAC3: B9 DF BA
  STA $0472                             ; $BAC6: 8D 72 04
  LDA $0470                             ; $BAC9: AD 70 04
  ASL                                   ; $BACC: 0A
  ASL                                   ; $BACD: 0A
  ASL                                   ; $BACE: 0A
  CLC                                   ; $BACF: 18
  ADC $0470                             ; $BAD0: 6D 70 04
  CLC                                   ; $BAD3: 18
  ADC $0010                             ; $BAD4: 6D 10 00
  TAY                                   ; $BAD7: A8
  LDA $BAE8,Y                           ; $BAD8: B9 E8 BA
  STA $04A2                             ; $BADB: 8D A2 04
  RTS                                   ; $BADE: 60
; --- Data Region ---
  .byte $0A,$0C,$0E,$10,$12,$14,$16,$18,$1A,$0A,$0B,$07,$07,$07,$0E,$0E; $BADF: 0A 0C 0E 10 12 14 16 18 1A 0A 0B 07 07 07 0E 0E
  .byte $15,$0E,$10,$14,$18,$16,$12,$12,$14,$15,$14,$16,$18,$16,$18,$10; $BAEF: 15 0E 10 14 18 16 12 12 14 15 14 16 18 16 18 10
  .byte $10,$18,$0F,$10                   ; $BAFF: 10 18 0F 10
Loc_BB03:
; --- Code Region ---
  LDA $0402                             ; $BB03: AD 02 04
  JSR $F2AF                             ; $BB06: 20 AF F2
  LDY #$02                              ; $BB09: A0 02
Loc_BB0B:
  LDA ($00),Y                           ; $BB0B: B1 00
  STA $0000,Y                           ; $BB0D: 99 00 00
Loc_BB10:
  INY                                   ; $BB10: C8
  CPY #$05                              ; $BB11: C0 05
  BCC $BB0B                             ; $BB13: 90 F6
  LDA $0002                             ; $BB15: AD 02 00
  SEC                                   ; $BB18: 38
  SBC $0004                             ; $BB19: ED 04 00
  STA $0006                             ; $BB1C: 8D 06 00
  LDA $0003                             ; $BB1F: AD 03 00
  SBC $0005                             ; $BB22: ED 05 00
  BCC $BB33                             ; $BB25: 90 0C
  BNE $BB2E                             ; $BB27: D0 05
  LDA $0006                             ; $BB29: AD 06 00
  BEQ $BB35                             ; $BB2C: F0 07
Loc_BB2E:
  LDY #$03                              ; $BB2E: A0 03
  JMP $BB35                             ; $BB30: 4C 35 BB
Loc_BB33:
  LDY #$07                              ; $BB33: A0 07
Loc_BB35:
  STY $042D                             ; $BB35: 8C 2D 04
  LDY #$F0                              ; $BB38: A0 F0
  LDA #$0A                              ; $BB3A: A9 0A
  JSR $E862                             ; $BB3C: 20 62 E8
  CMP $042D                             ; $BB3F: CD 2D 04
  BCC $BB45                             ; $BB42: 90 01
  INY                                   ; $BB44: C8
Loc_BB45:
  STY $042D                             ; $BB45: 8C 2D 04
  LDA #$64                              ; $BB48: A9 64
  SEC                                   ; $BB4A: 38
  SBC $042F                             ; $BB4B: ED 2F 04
  STA $0000                             ; $BB4E: 8D 00 00
  LDA #$00                              ; $BB51: A9 00
  STA $0001                             ; $BB53: 8D 01 00
  STA $0002                             ; $BB56: 8D 02 00
  LDA #$04                              ; $BB59: A9 04
  STA $0003                             ; $BB5B: 8D 03 00
  JSR $EBE9                             ; $BB5E: 20 E9 EB
  LDA $0006                             ; $BB61: AD 06 00
  STA $042F                             ; $BB64: 8D 2F 04
  LDA $0007                             ; $BB67: AD 07 00
  STA $0430                             ; $BB6A: 8D 30 04
  LDA #$00                              ; $BB6D: A9 00
  STA $0431                             ; $BB6F: 8D 31 04
  RTS                                   ; $BB72: 60
Loc_BB73:
  LDA $0402                             ; $BB73: AD 02 04
  JSR $F2AF                             ; $BB76: 20 AF F2
  LDY #$02                              ; $BB79: A0 02
  LDA $042D                             ; $BB7B: AD 2D 04
  CMP #$F0                              ; $BB7E: C9 F0
  BEQ $BB84                             ; $BB80: F0 02
  LDY #$04                              ; $BB82: A0 04
Loc_BB84:
  LDA ($00),Y                           ; $BB84: B1 00
  SEC                                   ; $BB86: 38
  SBC $042F                             ; $BB87: ED 2F 04
  STA $0002                             ; $BB8A: 8D 02 00
  INY                                   ; $BB8D: C8
  LDA ($00),Y                           ; $BB8E: B1 00
  SBC $0430                             ; $BB90: ED 30 04
  BCS $BBA1                             ; $BB93: B0 0C
  LDA $042D                             ; $BB95: AD 2D 04
  STA $042E                             ; $BB98: 8D 2E 04
  LDA #$00                              ; $BB9B: A9 00
  STA $042D                             ; $BB9D: 8D 2D 04
  RTS                                   ; $BBA0: 60
Loc_BBA1:
  STA ($00),Y                           ; $BBA1: 91 00
  DEY                                   ; $BBA3: 88
  LDA $0002                             ; $BBA4: AD 02 00
  STA ($00),Y                           ; $BBA7: 91 00
Loc_BBA9:  ; (dispatch callback target)
  LDA $042C                             ; $BBA9: AD 2C 04
  STA $000A                             ; $BBAC: 8D 0A 00
  JSR $A1EB                             ; $BBAF: 20 EB A1
  LDY #$02                              ; $BBB2: A0 02
  LDA $042D                             ; $BBB4: AD 2D 04
  CMP #$F0                              ; $BBB7: C9 F0
  BEQ $BBBD                             ; $BBB9: F0 02
  LDY #$04                              ; $BBBB: A0 04
Loc_BBBD:
  LDA ($00),Y                           ; $BBBD: B1 00
  CLC                                   ; $BBBF: 18
  ADC $042F                             ; $BBC0: 6D 2F 04
  STA ($00),Y                           ; $BBC3: 91 00
  INY                                   ; $BBC5: C8
  LDA ($00),Y                           ; $BBC6: B1 00
  ADC $0430                             ; $BBC8: 6D 30 04
  STA ($00),Y                           ; $BBCB: 91 00
  LDA $0000                             ; $BBCD: AD 00 00
  STA $0010                             ; $BBD0: 8D 10 00
  LDA $0001                             ; $BBD3: AD 01 00
  STA $0011                             ; $BBD6: 8D 11 00
  DEY                                   ; $BBD9: 88
  JSR $A52A                             ; $BBDA: 20 2A A5
  RTS                                   ; $BBDD: 60
Loc_BBDE:
  LDA $04E4                             ; $BBDE: AD E4 04
  BNE $BBE4                             ; $BBE1: D0 01
  RTS                                   ; $BBE3: 60
Loc_BBE4:
  LDA $0402                             ; $BBE4: AD 02 04
Loc_BBE7:
  PHA                                   ; $BBE7: 48
  AND #$07                              ; $BBE8: 29 07
  TAX                                   ; $BBEA: AA
  PLA                                   ; $BBEB: 68
  LSR                                   ; $BBEC: 4A
  LSR                                   ; $BBED: 4A
  LSR                                   ; $BBEE: 4A
  TAY                                   ; $BBEF: A8
  LDA $04E0,Y                           ; $BBF0: B9 E0 04
  ORA $BBFA,X                           ; $BBF3: 1D FA BB
  STA $04E0,Y                           ; $BBF6: 99 E0 04
  RTS                                   ; $BBF9: 60
; --- Data Region ---
  .byte $01,$02,$04,$08,$10,$20,$40,$80   ; $BBFA: 01 02 04 08 10 20 40 80
Loc_BC02:
; --- Code Region ---
  LDA #$40                              ; $BC02: A9 40
  STA $00A5                             ; $BC04: 8D A5 00
  STA $F800                             ; $BC07: 8D 00 F8
  LDA #$49                              ; $BC0A: A9 49
  STA $6FFC                             ; $BC0C: 8D FC 6F
  LDA #$44                              ; $BC0F: A9 44
  STA $6FFD                             ; $BC11: 8D FD 6F
  LDA #$00                              ; $BC14: A9 00
  STA $0000                             ; $BC16: 8D 00 00
  STA $0002                             ; $BC19: 8D 02 00
  STA $0004                             ; $BC1C: 8D 04 00
  STA $0005                             ; $BC1F: 8D 05 00
  LDA #$60                              ; $BC22: A9 60
  STA $0001                             ; $BC24: 8D 01 00
  LDA #$70                              ; $BC27: A9 70
  STA $0003                             ; $BC29: 8D 03 00
Loc_BC2C:
  LDY #$00                              ; $BC2C: A0 00
Loc_BC2E:
  LDA ($00),Y                           ; $BC2E: B1 00
  STA ($02),Y                           ; $BC30: 91 02
  CLC                                   ; $BC32: 18
  ADC $0004                             ; $BC33: 6D 04 00
  STA $0004                             ; $BC36: 8D 04 00
  LDA $0005                             ; $BC39: AD 05 00
  ADC #$00                              ; $BC3C: 69 00
  STA $0005                             ; $BC3E: 8D 05 00
  INY                                   ; $BC41: C8
  BNE $BC2E                             ; $BC42: D0 EA
  INC $0001                             ; $BC44: EE 01 00
  INC $0003                             ; $BC47: EE 03 00
  LDA $0001                             ; $BC4A: AD 01 00
  CMP #$6F                              ; $BC4D: C9 6F
  BCC $BC2C                             ; $BC4F: 90 DB
  LDY #$00                              ; $BC51: A0 00
Loc_BC53:
  LDA ($00),Y                           ; $BC53: B1 00
  STA ($02),Y                           ; $BC55: 91 02
  CLC                                   ; $BC57: 18
  ADC $0004                             ; $BC58: 6D 04 00
  STA $0004                             ; $BC5B: 8D 04 00
  LDA $0005                             ; $BC5E: AD 05 00
  ADC #$00                              ; $BC61: 69 00
  STA $0005                             ; $BC63: 8D 05 00
  INY                                   ; $BC66: C8
  CPY #$FE                              ; $BC67: C0 FE
  BNE $BC53                             ; $BC69: D0 E8
  LDA $0004                             ; $BC6B: AD 04 00
  STA $7FFE                             ; $BC6E: 8D FE 7F
  LDA $0005                             ; $BC71: AD 05 00
  STA $7FFF                             ; $BC74: 8D FF 7F
  LDA #$4C                              ; $BC77: A9 4C
  STA $00A5                             ; $BC79: 8D A5 00
  STA $F800                             ; $BC7C: 8D 00 F8
  RTS                                   ; $BC7F: 60
Loc_BC80:  ; (dispatch callback target)
  LDA $0402                             ; $BC80: AD 02 04
  JSR $EADE                             ; $BC83: 20 DE EA
; --- Data Region ---
  .byte $8C,$BC,$95,$BC,$67,$BD           ; $BC86: 8C BC 95 BC 67 BD
Loc_BC8C:  ; (dispatch callback target)
; --- Code Region ---
  LDA #$00                              ; $BC8C: A9 00
  STA $0408                             ; $BC8E: 8D 08 04
  INC $0402                             ; $BC91: EE 02 04
  RTS                                   ; $BC94: 60
Loc_BC95:  ; (dispatch callback target)
  LDA $0408                             ; $BC95: AD 08 04
  JSR $F2AF                             ; $BC98: 20 AF F2
  LDA $0000                             ; $BC9B: AD 00 00
  STA $001C                             ; $BC9E: 8D 1C 00
  LDA $0001                             ; $BCA1: AD 01 00
  STA $001D                             ; $BCA4: 8D 1D 00
  LDY #$00                              ; $BCA7: A0 00
Loc_BCA9:  ; (dispatch callback target)
  LDA ($1C),Y                           ; $BCA9: B1 1C
  AND #$07                              ; $BCAB: 29 07
  CMP $6F03                             ; $BCAD: CD 03 6F
  BNE $BCFE                             ; $BCB0: D0 4C
  LDY #$11                              ; $BCB2: A0 11
  STY $0409                             ; $BCB4: 8C 09 04
Loc_BCB7:
  LDY $0409                             ; $BCB7: AC 09 04
  LDA ($1C),Y                           ; $BCBA: B1 1C
  CMP #$FF                              ; $BCBC: C9 FF
  BEQ $BCF4                             ; $BCBE: F0 34
  CMP $040B                             ; $BCC0: CD 0B 04
  BNE $BCD4                             ; $BCC3: D0 0F
  LDA $0408                             ; $BCC5: AD 08 04
  STA $001E                             ; $BCC8: 8D 1E 00
  LDA $0409                             ; $BCCB: AD 09 04
  STA $001F                             ; $BCCE: 8D 1F 00
  JMP $BCF4                             ; $BCD1: 4C F4 BC
Loc_BCD4:
  STA $040A                             ; $BCD4: 8D 0A 04
  JSR $BD28                             ; $BCD7: 20 28 BD
  BCC $BCF4                             ; $BCDA: 90 18
  LDY #$03                              ; $BCDC: A0 03
  LDA ($EE),Y                           ; $BCDE: B1 EE
  AND #$03                              ; $BCE0: 29 03
  CMP #$03                              ; $BCE2: C9 03
  BEQ $BCF4                             ; $BCE4: F0 0E
  INC $0402                             ; $BCE6: EE 02 04
  LDA $040A                             ; $BCE9: AD 0A 04
  STA $042C                             ; $BCEC: 8D 2C 04
  LDA #$C1                              ; $BCEF: A9 C1
  JMP $F28B                             ; $BCF1: 4C 8B F2
Loc_BCF4:
  INC $0409                             ; $BCF4: EE 09 04
  LDA $0409                             ; $BCF7: AD 09 04
  CMP #$1B                              ; $BCFA: C9 1B
  BCC $BCB7                             ; $BCFC: 90 B9
Loc_BCFE:
  INC $0408                             ; $BCFE: EE 08 04
  LDA $0408                             ; $BD01: AD 08 04
  CMP #$1E                              ; $BD04: C9 1E
Loc_BD06:
  BCC $BC95                             ; $BD06: 90 8D
  LDA $040B                             ; $BD08: AD 0B 04
  STA $040A                             ; $BD0B: 8D 0A 04
  LDA $001E                             ; $BD0E: AD 1E 00
  STA $0408                             ; $BD11: 8D 08 04
  LDA $001F                             ; $BD14: AD 1F 00
  STA $0409                             ; $BD17: 8D 09 04
  JSR $BD28                             ; $BD1A: 20 28 BD
  LDA #$04                              ; $BD1D: A9 04
  STA $0401                             ; $BD1F: 8D 01 04
  LDA #$00                              ; $BD22: A9 00
  STA $0402                             ; $BD24: 8D 02 04
  RTS                                   ; $BD27: 60
Loc_BD28:
  LDY #$31                              ; $BD28: A0 31
  JSR $F25F                             ; $BD2A: 20 5F F2
  LDA #$58                              ; $BD2D: A9 58
  STA $0002                             ; $BD2F: 8D 02 00
  LDA #$9C                              ; $BD32: A9 9C
  STA $0003                             ; $BD34: 8D 03 00
  LDY $040A                             ; $BD37: AC 0A 04
  LDA $6F00                             ; $BD3A: AD 00 6F
  SEC                                   ; $BD3D: 38
  SBC ($02),Y                           ; $BD3E: F1 02
  BCC $BD59                             ; $BD40: 90 17
  CMP #$06                              ; $BD42: C9 06
  BCC $BD48                             ; $BD44: 90 02
  LDA #$06                              ; $BD46: A9 06
Loc_BD48:
  TAY                                   ; $BD48: A8
  LDA $BD60,Y                           ; $BD49: B9 60 BD
  STA $000C                             ; $BD4C: 8D 0C 00
  LDA #$C8                              ; $BD4F: A9 C8
  JSR $E862                             ; $BD51: 20 62 E8
  CMP $000C                             ; $BD54: CD 0C 00
  BCC $BD5B                             ; $BD57: 90 02
Loc_BD59:
  CLC                                   ; $BD59: 18
  RTS                                   ; $BD5A: 60
Loc_BD5B:
  JSR $BDBB                             ; $BD5B: 20 BB BD
  SEC                                   ; $BD5E: 38
  RTS                                   ; $BD5F: 60
; --- Data Region ---
  .byte $05,$0A,$14,$25,$50,$A0,$C9       ; $BD60: 05 0A 14 25 50 A0 C9
Loc_BD67:  ; (dispatch callback target)
; --- Code Region ---
  LDA $0300                             ; $BD67: AD 00 03
  CMP #$FF                              ; $BD6A: C9 FF
  BNE $BD85                             ; $BD6C: D0 17
  LDA $0304                             ; $BD6E: AD 04 03
  CMP #$FF                              ; $BD71: C9 FF
  BNE $BD85                             ; $BD73: D0 10
  JSR $A1C2                             ; $BD75: 20 C2 A1
  LDA $0081                             ; $BD78: AD 81 00
  AND #$03                              ; $BD7B: 29 03
  BEQ $BD85                             ; $BD7D: F0 06
  DEC $0402                             ; $BD7F: CE 02 04
  JMP $BCF4                             ; $BD82: 4C F4 BC
Loc_BD85:
  RTS                                   ; $BD85: 60
Loc_BD86:
  LDX #$00                              ; $BD86: A2 00
  LDA #$FF                              ; $BD88: A9 FF
Loc_BD8A:
  STA $0580,X                           ; $BD8A: 9D 80 05
  INX                                   ; $BD8D: E8
  CPX #$10                              ; $BD8E: E0 10
  BCC $BD8A                             ; $BD90: 90 F8
  LDA $0408                             ; $BD92: AD 08 04
  JSR $F2AF                             ; $BD95: 20 AF F2
  LDY #$11                              ; $BD98: A0 11
  LDX #$00                              ; $BD9A: A2 00
Loc_BD9C:
  LDA ($00),Y                           ; $BD9C: B1 00
  CMP #$FF                              ; $BD9E: C9 FF
  BEQ $BDA6                             ; $BDA0: F0 04
  STA $0580,X                           ; $BDA2: 9D 80 05
  INX                                   ; $BDA5: E8
Loc_BDA6:
  INY                                   ; $BDA6: C8
  CPY #$1B                              ; $BDA7: C0 1B
Loc_BDA9:  ; (dispatch callback target)
  BCC $BD9C                             ; $BDA9: 90 F1
  LDY #$11                              ; $BDAB: A0 11
  LDX #$00                              ; $BDAD: A2 00
Loc_BDAF:
  LDA $0580,X                           ; $BDAF: BD 80 05
  STA ($00),Y                           ; $BDB2: 91 00
  INY                                   ; $BDB4: C8
  INX                                   ; $BDB5: E8
  CPY #$1B                              ; $BDB6: C0 1B
  BCC $BDAF                             ; $BDB8: 90 F5
  RTS                                   ; $BDBA: 60
Loc_BDBB:
  LDY #$31                              ; $BDBB: A0 31
  JSR $F25F                             ; $BDBD: 20 5F F2
  LDA $040A                             ; $BDC0: AD 0A 04
  JSR $F2D7                             ; $BDC3: 20 D7 F2
  LDY #$0B                              ; $BDC6: A0 0B
  LDA ($00),Y                           ; $BDC8: B1 00
  ORA #$03                              ; $BDCA: 09 03
  STA ($00),Y                           ; $BDCC: 91 00
  LDY #$30                              ; $BDCE: A0 30
  JSR $F25F                             ; $BDD0: 20 5F F2
  LDA $0408                             ; $BDD3: AD 08 04
  JSR $F2AF                             ; $BDD6: 20 AF F2
  LDY $0409                             ; $BDD9: AC 09 04
  LDA #$FF                              ; $BDDC: A9 FF
  STA ($00),Y                           ; $BDDE: 91 00
  JSR $BD86                             ; $BDE0: 20 86 BD
  LDY #$11                              ; $BDE3: A0 11
  LDX #$00                              ; $BDE5: A2 00
Loc_BDE7:
  LDA ($00),Y                           ; $BDE7: B1 00
  CMP #$FF                              ; $BDE9: C9 FF
  BEQ $BDEE                             ; $BDEB: F0 01
  INX                                   ; $BDED: E8
Loc_BDEE:
  INY                                   ; $BDEE: C8
  CPY #$1B                              ; $BDEF: C0 1B
  BCC $BDE7                             ; $BDF1: 90 F4
  TXA                                   ; $BDF3: 8A
  BNE $BE00                             ; $BDF4: D0 0A
  LDY #$00                              ; $BDF6: A0 00
  LDA ($00),Y                           ; $BDF8: B1 00
  AND #$F8                              ; $BDFA: 29 F8
  ORA #$07                              ; $BDFC: 09 07
  STA ($00),Y                           ; $BDFE: 91 00
Loc_BE00:
  RTS                                   ; $BE00: 60
Loc_BE01:  ; (dispatch callback target)
  LDA $0402                             ; $BE01: AD 02 04
  JSR $EADE                             ; $BE04: 20 DE EA
; --- Data Region ---
  .byte $17,$BE,$2E,$BE,$83,$BE,$D1,$BE,$2F,$BF,$B9,$BF,$1E,$C0,$E5,$C0; $BE07: 17 BE 2E BE 83 BE D1 BE 2F BF B9 BF 1E C0 E5 C0
Loc_BE17:  ; (dispatch callback target)
; --- Code Region ---
  LDA $040B                             ; $BE17: AD 0B 04
  STA $042C                             ; $BE1A: 8D 2C 04
  INC $0402                             ; $BE1D: EE 02 04
  LDA #$C1                              ; $BE20: A9 C1
  JSR $F28B                             ; $BE22: 20 8B F2
  JSR $E57F                             ; $BE25: 20 7F E5
  LDA #$08                              ; $BE28: A9 08
  JSR $E683                             ; $BE2A: 20 83 E6
  RTS                                   ; $BE2D: 60
Loc_BE2E:  ; (dispatch callback target)
  LDA $0300                             ; $BE2E: AD 00 03
  CMP #$FF                              ; $BE31: C9 FF
  BNE $BE82                             ; $BE33: D0 4D
  LDA $0304                             ; $BE35: AD 04 03
  CMP #$FF                              ; $BE38: C9 FF
  BNE $BE82                             ; $BE3A: D0 46
  JSR $A1C2                             ; $BE3C: 20 C2 A1
  LDA $0081                             ; $BE3F: AD 81 00
  AND #$03                              ; $BE42: 29 03
  BEQ $BE82                             ; $BE44: F0 3C
  LDX #$00                              ; $BE46: A2 00
Loc_BE48:
  TXA                                   ; $BE48: 8A
  JSR $F2AF                             ; $BE49: 20 AF F2
  LDY #$00                              ; $BE4C: A0 00
  LDA ($00),Y                           ; $BE4E: B1 00
  AND #$07                              ; $BE50: 29 07
  CMP $040A                             ; $BE52: CD 0A 04
  BNE $BE5F                             ; $BE55: D0 08
  LDY #$11                              ; $BE57: A0 11
  LDA ($00),Y                           ; $BE59: B1 00
  CMP #$FF                              ; $BE5B: C9 FF
  BNE $BE70                             ; $BE5D: D0 11
Loc_BE5F:
  INX                                   ; $BE5F: E8
  CPX #$1E                              ; $BE60: E0 1E
  BCC $BE48                             ; $BE62: 90 E4
  LDA $0471                             ; $BE64: AD 71 04
  STA $0401                             ; $BE67: 8D 01 04
  LDA #$00                              ; $BE6A: A9 00
  STA $0402                             ; $BE6C: 8D 02 04
  RTS                                   ; $BE6F: 60
Loc_BE70:
  INC $0402                             ; $BE70: EE 02 04
  LDA #$80                              ; $BE73: A9 80
  STA $6F3F                             ; $BE75: 8D 3F 6F
  LDA #$41                              ; $BE78: A9 41
  STA $6F41                             ; $BE7A: 8D 41 6F
  LDA #$D0                              ; $BE7D: A9 D0
  JMP $F28B                             ; $BE7F: 4C 8B F2
Loc_BE82:
  RTS                                   ; $BE82: 60
Loc_BE83:  ; (dispatch callback target)
  JSR $C67C                             ; $BE83: 20 7C C6
  LDA $0300                             ; $BE86: AD 00 03
  CMP #$FF                              ; $BE89: C9 FF
  BNE $BEC6                             ; $BE8B: D0 39
  LDA $0304                             ; $BE8D: AD 04 03
  CMP #$FF                              ; $BE90: C9 FF
  BNE $BEC6                             ; $BE92: D0 32
  LDA $0081                             ; $BE94: AD 81 00
  AND #$01                              ; $BE97: 29 01
  BEQ $BEC6                             ; $BE99: F0 2B
  JSR $C708                             ; $BE9B: 20 08 C7
  CPY #$FF                              ; $BE9E: C0 FF
  BEQ $BEC7                             ; $BEA0: F0 25
  STY $040C                             ; $BEA2: 8C 0C 04
  TYA                                   ; $BEA5: 98
  JSR $F2AF                             ; $BEA6: 20 AF F2
  LDY #$00                              ; $BEA9: A0 00
  LDA ($00),Y                           ; $BEAB: B1 00
  AND #$07                              ; $BEAD: 29 07
  CMP $040A                             ; $BEAF: CD 0A 04
  BNE $BECC                             ; $BEB2: D0 18
  INC $0402                             ; $BEB4: EE 02 04
  LDA #$82                              ; $BEB7: A9 82
  STA $0478                             ; $BEB9: 8D 78 04
  LDA #$0F                              ; $BEBC: A9 0F
  STA $047C                             ; $BEBE: 8D 7C 04
  LDA #$D1                              ; $BEC1: A9 D1
  JMP $F26D                             ; $BEC3: 4C 6D F2
Loc_BEC6:
  RTS                                   ; $BEC6: 60
Loc_BEC7:
  LDA #$21                              ; $BEC7: A9 21
  JMP $F26D                             ; $BEC9: 4C 6D F2
Loc_BECC:
  LDA #$22                              ; $BECC: A9 22
  JMP $F26D                             ; $BECE: 4C 6D F2
Loc_BED1:  ; (dispatch callback target)
  LDA $0478                             ; $BED1: AD 78 04
  BNE $BEFC                             ; $BED4: D0 26
  LDA $0402                             ; $BED6: AD 02 04
  PHA                                   ; $BED9: 48
  LDA $040C                             ; $BEDA: AD 0C 04
  STA $0402                             ; $BEDD: 8D 02 04
  LDY #$3B                              ; $BEE0: A0 3B
  JSR $EE07                             ; $BEE2: 20 07 EE
; --- Data Region ---
  .byte $06,$A0,$68,$8D,$02,$04,$AD,$7C,$04,$10,$0C,$C9,$90,$D0,$09,$CE; $BEE5: 06 A0 68 8D 02 04 AD 7C 04 10 0C C9 90 D0 09 CE
  .byte $02,$04,$A9,$D0,$4C,$6D,$F2       ; $BEF5: 02 04 A9 D0 4C 6D F2
Loc_BEFC:
; --- Code Region ---
  RTS                                   ; $BEFC: 60
Loc_BEFD:
  LDA #$00                              ; $BEFD: A9 00
  STA $008F                             ; $BEFF: 8D 8F 00
  LDA #$03                              ; $BF02: A9 03
  STA $0061                             ; $BF04: 8D 61 00
  LDA #$00                              ; $BF07: A9 00
  STA $00B2                             ; $BF09: 8D B2 00
  LDA #$05                              ; $BF0C: A9 05
  STA $00B3                             ; $BF0E: 8D B3 00
  LDA #$09                              ; $BF11: A9 09
  STA $00B4                             ; $BF13: 8D B4 00
  INC $0402                             ; $BF16: EE 02 04
  LDA $0481                             ; $BF19: AD 81 04
  STA $042C                             ; $BF1C: 8D 2C 04
  STA $040D                             ; $BF1F: 8D 0D 04
  LDA #$00                              ; $BF22: A9 00
  STA $0424                             ; $BF24: 8D 24 04
  STA $0425                             ; $BF27: 8D 25 04
  LDA #$D2                              ; $BF2A: A9 D2
  JMP $F28B                             ; $BF2C: 4C 8B F2
Loc_BF2F:  ; (dispatch callback target)
  LDA $0300                             ; $BF2F: AD 00 03
  CMP #$FF                              ; $BF32: C9 FF
  BNE $BF84                             ; $BF34: D0 4E
  LDA $0304                             ; $BF36: AD 04 03
  CMP #$FF                              ; $BF39: C9 FF
  BNE $BF84                             ; $BF3B: D0 47
  LDA #$AC                              ; $BF3D: A9 AC
  STA $0010                             ; $BF3F: 8D 10 00
  LDA #$BF                              ; $BF42: A9 BF
  STA $0011                             ; $BF44: 8D 11 00
  LDA #$00                              ; $BF47: A9 00
  STA $0012                             ; $BF49: 8D 12 00
  JSR $ED1E                             ; $BF4C: 20 1E ED
  LDA #$B0                              ; $BF4F: A9 B0
  STA $0010                             ; $BF51: 8D 10 00
  LDA #$BF                              ; $BF54: A9 BF
  STA $0011                             ; $BF56: 8D 11 00
  LDA #$B4                              ; $BF59: A9 B4
  STA $0000                             ; $BF5B: 8D 00 00
  LDA #$BF                              ; $BF5E: A9 BF
  STA $0001                             ; $BF60: 8D 01 00
  LDA $0012                             ; $BF63: AD 12 00
  JSR $EDF5                             ; $BF66: 20 F5 ED
  LDA $0081                             ; $BF69: AD 81 00
  LSR                                   ; $BF6C: 4A
  BCS $BF85                             ; $BF6D: B0 16
  LSR                                   ; $BF6F: 4A
  BCC $BF84                             ; $BF70: 90 12
Loc_BF72:
  LDA #$82                              ; $BF72: A9 82
  STA $0478                             ; $BF74: 8D 78 04
  LDA #$0F                              ; $BF77: A9 0F
  STA $047C                             ; $BF79: 8D 7C 04
  DEC $0402                             ; $BF7C: CE 02 04
  LDA #$D1                              ; $BF7F: A9 D1
  JSR $F26D                             ; $BF81: 20 6D F2
Loc_BF84:
  RTS                                   ; $BF84: 60
Loc_BF85:
  LDA $0012                             ; $BF85: AD 12 00
  BNE $BF72                             ; $BF88: D0 E8
  LDA $040A                             ; $BF8A: AD 0A 04
  JSR $F368                             ; $BF8D: 20 68 F3
  LDA $040D                             ; $BF90: AD 0D 04
  STA $042C                             ; $BF93: 8D 2C 04
  LDY #$00                              ; $BF96: A0 00
  STA ($00),Y                           ; $BF98: 91 00
  LDA $040C                             ; $BF9A: AD 0C 04
  LDY #$01                              ; $BF9D: A0 01
  STA ($EE),Y                           ; $BF9F: 91 EE
  JSR $C101                             ; $BFA1: 20 01 C1
  INC $0402                             ; $BFA4: EE 02 04
  LDA #$D3                              ; $BFA7: A9 D3
  JMP $F28B                             ; $BFA9: 4C 8B F2
; --- Data Region ---
  .byte $00,$01,$FF,$FF,$C8,$58,$C8,$98,$00,$07,$00,$00,$80; $BFAC: 00 01 FF FF C8 58 C8 98 00 07 00 00 80
Loc_BFB9:  ; (dispatch callback target)
; --- Code Region ---
  LDA $0300                             ; $BFB9: AD 00 03
  CMP #$FF                              ; $BFBC: C9 FF
  BNE $C01D                             ; $BFBE: D0 5D
  LDA $0304                             ; $BFC0: AD 04 03
  CMP #$FF                              ; $BFC3: C9 FF
  BNE $C01D                             ; $BFC5: D0 56
  JSR $A1C2                             ; $BFC7: 20 C2 A1
  LDA $0081                             ; $BFCA: AD 81 00
  AND #$03                              ; $BFCD: 29 03
  BEQ $C01D                             ; $BFCF: F0 4C
  LDA $040A                             ; $BFD1: AD 0A 04
  ASL                                   ; $BFD4: 0A
  ASL                                   ; $BFD5: 0A
  ASL                                   ; $BFD6: 0A
  TAY                                   ; $BFD7: A8
  CLC                                   ; $BFD8: 18
  ADC #$08                              ; $BFD9: 69 08
  STA $0010                             ; $BFDB: 8D 10 00
Loc_BFDE:
  LDA $C342,Y                           ; $BFDE: B9 42 C3
  CMP #$FF                              ; $BFE1: C9 FF
  BNE $BFF3                             ; $BFE3: D0 0E
  LDA #$00                              ; $BFE5: A9 00
  STA $040E                             ; $BFE7: 8D 0E 04
  LDA #$11                              ; $BFEA: A9 11
  STA $040F                             ; $BFEC: 8D 0F 04
  INC $0402                             ; $BFEF: EE 02 04
  RTS                                   ; $BFF2: 60
Loc_BFF3:
  CMP $040D                             ; $BFF3: CD 0D 04
  BEQ $BFFE                             ; $BFF6: F0 06
  INY                                   ; $BFF8: C8
  CPY $0010                             ; $BFF9: CC 10 00
  BCC $BFDE                             ; $BFFC: 90 E0
Loc_BFFE:
  LDA $040D                             ; $BFFE: AD 0D 04
  JSR $F2D7                             ; $C001: 20 D7 F2
  LDY #$03                              ; $C004: A0 03
  LDA #$64                              ; $C006: A9 64
  STA ($00),Y                           ; $C008: 91 00
  LDA $0470                             ; $C00A: AD 70 04
  STA $0401                             ; $C00D: 8D 01 04
  LDA #$00                              ; $C010: A9 00
  STA $0402                             ; $C012: 8D 02 04
  JSR $E57F                             ; $C015: 20 7F E5
  LDA #$81                              ; $C018: A9 81
  JSR $E673                             ; $C01A: 20 73 E6
Loc_C01D:
  RTS                                   ; $C01D: 60
Loc_C01E:  ; (dispatch callback target)
  LDA $040E                             ; $C01E: AD 0E 04
  JSR $F2AF                             ; $C021: 20 AF F2
  LDY #$00                              ; $C024: A0 00
  LDA ($00),Y                           ; $C026: B1 00
  AND #$07                              ; $C028: 29 07
  CMP $040A                             ; $C02A: CD 0A 04
  BNE $C07F                             ; $C02D: D0 50
  LDA $0000                             ; $C02F: AD 00 00
  STA $0010                             ; $C032: 8D 10 00
  LDA $0001                             ; $C035: AD 01 00
  STA $0011                             ; $C038: 8D 11 00
  LDY $040F                             ; $C03B: AC 0F 04
Loc_C03E:
  LDA ($10),Y                           ; $C03E: B1 10
  CMP #$FF                              ; $C040: C9 FF
  BEQ $C07F                             ; $C042: F0 3B
  STA $0031                             ; $C044: 8D 31 00
  LDA $040D                             ; $C047: AD 0D 04
  STA $0030                             ; $C04A: 8D 30 00
  LDA $040A                             ; $C04D: AD 0A 04
  STA $0032                             ; $C050: 8D 32 00
  LDA $040B                             ; $C053: AD 0B 04
  STA $0033                             ; $C056: 8D 33 00
  LDY #$2A                              ; $C059: A0 2A
  JSR $EE07                             ; $C05B: 20 07 EE
; --- Data Region ---
  .byte $09,$A0,$AD,$31,$00,$20,$D7,$F2,$A0,$03,$B1,$00,$C9,$1F,$B0,$07; $C05E: 09 A0 AD 31 00 20 D7 F2 A0 03 B1 00 C9 1F B0 07
  .byte $20,$43,$E8,$C9,$14,$90,$1C       ; $C06E: 20 43 E8 C9 14 90 1C
Loc_C075:
; --- Code Region ---
  INC $040F                             ; $C075: EE 0F 04
  LDY $040F                             ; $C078: AC 0F 04
  CPY #$1B                              ; $C07B: C0 1B
  BCC $C03E                             ; $C07D: 90 BF
Loc_C07F:
  INC $040E                             ; $C07F: EE 0E 04
  LDA #$11                              ; $C082: A9 11
  STA $040F                             ; $C084: 8D 0F 04
  LDA $040E                             ; $C087: AD 0E 04
  CMP #$1E                              ; $C08A: C9 1E
  BCC $C01E                             ; $C08C: 90 90
  JMP $BFFE                             ; $C08E: 4C FE BF
Loc_C091:
  LDA $0031                             ; $C091: AD 31 00
  CMP $040D                             ; $C094: CD 0D 04
  BEQ $C075                             ; $C097: F0 DC
  LDY #$0B                              ; $C099: A0 0B
  LDA ($00),Y                           ; $C09B: B1 00
  AND #$FC                              ; $C09D: 29 FC
  STA ($00),Y                           ; $C09F: 91 00
  LDY #$05                              ; $C0A1: A0 05
  LDA $040E                             ; $C0A3: AD 0E 04
  STA ($00),Y                           ; $C0A6: 91 00
  LDY $040F                             ; $C0A8: AC 0F 04
Loc_C0AB:
  CPY #$1A                              ; $C0AB: C0 1A
  BEQ $C0B9                             ; $C0AD: F0 0A
  INY                                   ; $C0AF: C8
  LDA ($10),Y                           ; $C0B0: B1 10
  DEY                                   ; $C0B2: 88
  STA ($10),Y                           ; $C0B3: 91 10
  INY                                   ; $C0B5: C8
  JMP $C0AB                             ; $C0B6: 4C AB C0
Loc_C0B9:
  LDA #$FF                              ; $C0B9: A9 FF
  STA ($10),Y                           ; $C0BB: 91 10
  LDX #$00                              ; $C0BD: A2 00
  LDY #$11                              ; $C0BF: A0 11
Loc_C0C1:
  LDA ($10),Y                           ; $C0C1: B1 10
  CMP #$FF                              ; $C0C3: C9 FF
  BEQ $C0C8                             ; $C0C5: F0 01
  INX                                   ; $C0C7: E8
Loc_C0C8:
  INY                                   ; $C0C8: C8
  CPY #$1B                              ; $C0C9: C0 1B
  BCC $C0C1                             ; $C0CB: 90 F4
  CPX #$00                              ; $C0CD: E0 00
  BNE $C0D7                             ; $C0CF: D0 06
  LDY #$00                              ; $C0D1: A0 00
  LDA #$07                              ; $C0D3: A9 07
  STA ($10),Y                           ; $C0D5: 91 10
Loc_C0D7:
  INC $0402                             ; $C0D7: EE 02 04
  LDA $0031                             ; $C0DA: AD 31 00
  STA $042C                             ; $C0DD: 8D 2C 04
  LDA #$D4                              ; $C0E0: A9 D4
  JMP $F28B                             ; $C0E2: 4C 8B F2
Loc_C0E5:  ; (dispatch callback target)
  LDA $0300                             ; $C0E5: AD 00 03
  CMP #$FF                              ; $C0E8: C9 FF
  BNE $C100                             ; $C0EA: D0 14
  LDA $0304                             ; $C0EC: AD 04 03
  CMP #$FF                              ; $C0EF: C9 FF
  BNE $C100                             ; $C0F1: D0 0D
  JSR $A1C2                             ; $C0F3: 20 C2 A1
  LDA $0081                             ; $C0F6: AD 81 00
  AND #$03                              ; $C0F9: 29 03
  BEQ $C100                             ; $C0FB: F0 03
  DEC $0402                             ; $C0FD: CE 02 04
Loc_C100:
  RTS                                   ; $C100: 60
Loc_C101:
  LDA $040C                             ; $C101: AD 0C 04
  JSR $F2AF                             ; $C104: 20 AF F2
  LDA $040D                             ; $C107: AD 0D 04
  STA $0002                             ; $C10A: 8D 02 00
  LDY #$11                              ; $C10D: A0 11
Loc_C10F:
  LDA ($00),Y                           ; $C10F: B1 00
  CMP $0002                             ; $C111: CD 02 00
  BEQ $C11C                             ; $C114: F0 06
  INY                                   ; $C116: C8
  CPY #$1B                              ; $C117: C0 1B
  BCC $C10F                             ; $C119: 90 F4
  RTS                                   ; $C11B: 60
Loc_C11C:
  TYA                                   ; $C11C: 98
  PHA                                   ; $C11D: 48
  LDY #$11                              ; $C11E: A0 11
  LDA ($00),Y                           ; $C120: B1 00
  STA $0003                             ; $C122: 8D 03 00
  LDA $0002                             ; $C125: AD 02 00
  STA ($00),Y                           ; $C128: 91 00
  PLA                                   ; $C12A: 68
  TAY                                   ; $C12B: A8
  LDA $0003                             ; $C12C: AD 03 00
  STA ($00),Y                           ; $C12F: 91 00
  RTS                                   ; $C131: 60
Loc_C132:  ; (dispatch callback target)
  LDA $0402                             ; $C132: AD 02 04
  JSR $EADE                             ; $C135: 20 DE EA
; --- Data Region ---
  .byte $44,$C1,$58,$C1,$DB,$C1,$5D,$C2,$80,$C2,$89,$C2; $C138: 44 C1 58 C1 DB C1 5D C2 80 C2 89 C2
Loc_C144:  ; (dispatch callback target)
; --- Code Region ---
  INC $0402                             ; $C144: EE 02 04
  LDA #$00                              ; $C147: A9 00
  STA $04D0                             ; $C149: 8D D0 04
  LDA $040B                             ; $C14C: AD 0B 04
  STA $042C                             ; $C14F: 8D 2C 04
  LDA #$C1                              ; $C152: A9 C1
  JSR $F28B                             ; $C154: 20 8B F2
Loc_C157:
  RTS                                   ; $C157: 60
Loc_C158:  ; (dispatch callback target)
  INC $04D0                             ; $C158: EE D0 04
  BNE $C157                             ; $C15B: D0 FA
  LDA $040A                             ; $C15D: AD 0A 04
  ASL                                   ; $C160: 0A
  ASL                                   ; $C161: 0A
  ASL                                   ; $C162: 0A
  STA $0010                             ; $C163: 8D 10 00
  LDA #$42                              ; $C166: A9 42
  CLC                                   ; $C168: 18
  ADC $0010                             ; $C169: 6D 10 00
  STA $0010                             ; $C16C: 8D 10 00
  LDA #$C3                              ; $C16F: A9 C3
  ADC #$00                              ; $C171: 69 00
  STA $0011                             ; $C173: 8D 11 00
  LDY #$00                              ; $C176: A0 00
  STY $0012                             ; $C178: 8C 12 00
Loc_C17B:
  LDY $0012                             ; $C17B: AC 12 00
  LDA ($10),Y                           ; $C17E: B1 10
  CMP #$FF                              ; $C180: C9 FF
  BEQ $C19D                             ; $C182: F0 19
  STA $040D                             ; $C184: 8D 0D 04
  JSR $C1A1                             ; $C187: 20 A1 C1
  BCS $C192                             ; $C18A: B0 06
  INC $0012                             ; $C18C: EE 12 00
  JMP $C17B                             ; $C18F: 4C 7B C1
Loc_C192:
  LDA #$00                              ; $C192: A9 00
  STA $0409                             ; $C194: 8D 09 04
  LDA #$03                              ; $C197: A9 03
  STA $0402                             ; $C199: 8D 02 04
  RTS                                   ; $C19C: 60
Loc_C19D:
  INC $0402                             ; $C19D: EE 02 04
  RTS                                   ; $C1A0: 60
Loc_C1A1:
  LDX #$00                              ; $C1A1: A2 00
Loc_C1A3:
  TXA                                   ; $C1A3: 8A
  JSR $F2AF                             ; $C1A4: 20 AF F2
  LDY #$00                              ; $C1A7: A0 00
  LDA ($00),Y                           ; $C1A9: B1 00
  AND #$07                              ; $C1AB: 29 07
  CMP $040A                             ; $C1AD: CD 0A 04
  BNE $C1D4                             ; $C1B0: D0 22
  LDY #$11                              ; $C1B2: A0 11
  STY $0004                             ; $C1B4: 8C 04 00
Loc_C1B7:
  LDY $0004                             ; $C1B7: AC 04 00
  LDA ($00),Y                           ; $C1BA: B1 00
  CMP $040D                             ; $C1BC: CD 0D 04
  BNE $C1C6                             ; $C1BF: D0 05
  STX $040C                             ; $C1C1: 8E 0C 04
  SEC                                   ; $C1C4: 38
  RTS                                   ; $C1C5: 60
Loc_C1C6:
  CMP #$FF                              ; $C1C6: C9 FF
  BEQ $C1D4                             ; $C1C8: F0 0A
  INC $0004                             ; $C1CA: EE 04 00
  LDA $0004                             ; $C1CD: AD 04 00
  CMP #$1B                              ; $C1D0: C9 1B
  BCC $C1B7                             ; $C1D2: 90 E3
Loc_C1D4:
  INX                                   ; $C1D4: E8
  CPX #$1E                              ; $C1D5: E0 1E
  BCC $C1A3                             ; $C1D7: 90 CA
  CLC                                   ; $C1D9: 18
  RTS                                   ; $C1DA: 60
Loc_C1DB:  ; (dispatch callback target)
  LDA #$FF                              ; $C1DB: A9 FF
  STA $0010                             ; $C1DD: 8D 10 00
  LDX #$00                              ; $C1E0: A2 00
  STX $0011                             ; $C1E2: 8E 11 00
Loc_C1E5:
  TXA                                   ; $C1E5: 8A
  JSR $F2AF                             ; $C1E6: 20 AF F2
  LDY #$00                              ; $C1E9: A0 00
  LDA ($00),Y                           ; $C1EB: B1 00
  AND #$07                              ; $C1ED: 29 07
  CMP $040A                             ; $C1EF: CD 0A 04
  BNE $C1F7                             ; $C1F2: D0 03
  JSR $C21D                             ; $C1F4: 20 1D C2
Loc_C1F7:
  INX                                   ; $C1F7: E8
  CPX #$1E                              ; $C1F8: E0 1E
  BCC $C1E5                             ; $C1FA: 90 E9
  LDA $0010                             ; $C1FC: AD 10 00
  CMP #$FF                              ; $C1FF: C9 FF
  BEQ $C211                             ; $C201: F0 0E
  STA $040D                             ; $C203: 8D 0D 04
  LDA #$80                              ; $C206: A9 80
  STA $0409                             ; $C208: 8D 09 04
  LDA #$03                              ; $C20B: A9 03
  STA $0402                             ; $C20D: 8D 02 04
  RTS                                   ; $C210: 60
Loc_C211:
  LDA $0471                             ; $C211: AD 71 04
  STA $0401                             ; $C214: 8D 01 04
  LDA #$00                              ; $C217: A9 00
  STA $0402                             ; $C219: 8D 02 04
  RTS                                   ; $C21C: 60
Loc_C21D:
  LDA $0000                             ; $C21D: AD 00 00
  STA $0002                             ; $C220: 8D 02 00
  LDA $0001                             ; $C223: AD 01 00
  STA $0003                             ; $C226: 8D 03 00
  LDY #$11                              ; $C229: A0 11
  STY $0004                             ; $C22B: 8C 04 00
Loc_C22E:
  LDY $0004                             ; $C22E: AC 04 00
  LDA ($02),Y                           ; $C231: B1 02
  CMP #$FF                              ; $C233: C9 FF
  BEQ $C25C                             ; $C235: F0 25
  STA $0012                             ; $C237: 8D 12 00
  JSR $F2D7                             ; $C23A: 20 D7 F2
  LDY #$04                              ; $C23D: A0 04
  LDA ($00),Y                           ; $C23F: B1 00
  CMP $0011                             ; $C241: CD 11 00
  BCC $C252                             ; $C244: 90 0C
  STA $0011                             ; $C246: 8D 11 00
  LDA $0012                             ; $C249: AD 12 00
  STA $0010                             ; $C24C: 8D 10 00
  STX $040C                             ; $C24F: 8E 0C 04
Loc_C252:
  INC $0004                             ; $C252: EE 04 00
  LDA $0004                             ; $C255: AD 04 00
  CMP #$1B                              ; $C258: C9 1B
  BCC $C22E                             ; $C25A: 90 D2
Loc_C25C:
  RTS                                   ; $C25C: 60
Loc_C25D:  ; (dispatch callback target)
  LDA $040A                             ; $C25D: AD 0A 04
  JSR $F368                             ; $C260: 20 68 F3
  LDY #$00                              ; $C263: A0 00
  LDA $040D                             ; $C265: AD 0D 04
  STA ($00),Y                           ; $C268: 91 00
  JSR $C101                             ; $C26A: 20 01 C1
  INC $0402                             ; $C26D: EE 02 04
  LDA $040D                             ; $C270: AD 0D 04
  STA $042C                             ; $C273: 8D 2C 04
  LDA #$00                              ; $C276: A9 00
  STA $04D0                             ; $C278: 8D D0 04
  LDA #$C2                              ; $C27B: A9 C2
  JMP $F28B                             ; $C27D: 4C 8B F2
Loc_C280:  ; (dispatch callback target)
  INC $04D0                             ; $C280: EE D0 04
  BNE $C288                             ; $C283: D0 03
  INC $0402                             ; $C285: EE 02 04
Loc_C288:
  RTS                                   ; $C288: 60
Loc_C289:  ; (dispatch callback target)
  LDA $0409                             ; $C289: AD 09 04
  BMI $C2A6                             ; $C28C: 30 18
Loc_C28E:
  LDA $040D                             ; $C28E: AD 0D 04
  JSR $F2D7                             ; $C291: 20 D7 F2
  LDY #$03                              ; $C294: A0 03
  LDA #$64                              ; $C296: A9 64
  STA ($00),Y                           ; $C298: 91 00
  LDA $0470                             ; $C29A: AD 70 04
  STA $0401                             ; $C29D: 8D 01 04
  LDA #$00                              ; $C2A0: A9 00
  STA $0402                             ; $C2A2: 8D 02 04
  RTS                                   ; $C2A5: 60
Loc_C2A6:
  LDA #$00                              ; $C2A6: A9 00
  STA $0012                             ; $C2A8: 8D 12 00
Loc_C2AB:
  LDA $0012                             ; $C2AB: AD 12 00
  JSR $F2AF                             ; $C2AE: 20 AF F2
  LDY #$00                              ; $C2B1: A0 00
  LDA ($00),Y                           ; $C2B3: B1 00
  AND #$07                              ; $C2B5: 29 07
  CMP $040A                             ; $C2B7: CD 0A 04
  BNE $C30B                             ; $C2BA: D0 4F
  LDA $0000                             ; $C2BC: AD 00 00
  STA $0010                             ; $C2BF: 8D 10 00
  LDA $0001                             ; $C2C2: AD 01 00
  STA $0011                             ; $C2C5: 8D 11 00
  LDY #$11                              ; $C2C8: A0 11
  STY $0013                             ; $C2CA: 8C 13 00
Loc_C2CD:
  LDA ($10),Y                           ; $C2CD: B1 10
  CMP #$FF                              ; $C2CF: C9 FF
  BEQ $C30B                             ; $C2D1: F0 38
  STA $0031                             ; $C2D3: 8D 31 00
  LDA $040D                             ; $C2D6: AD 0D 04
  STA $0030                             ; $C2D9: 8D 30 00
  LDA $040A                             ; $C2DC: AD 0A 04
  STA $0032                             ; $C2DF: 8D 32 00
  LDA $040B                             ; $C2E2: AD 0B 04
  STA $0033                             ; $C2E5: 8D 33 00
  LDY #$2A                              ; $C2E8: A0 2A
  JSR $EE07                             ; $C2EA: 20 07 EE
; --- Data Region ---
  .byte $09,$A0,$A0,$03,$B1,$22,$C9,$1F,$B0,$0A,$20,$43,$E8,$C9,$14,$B0; $C2ED: 09 A0 A0 03 B1 22 C9 1F B0 0A 20 43 E8 C9 14 B0
  .byte $03,$20,$18,$C3                   ; $C2FD: 03 20 18 C3
Loc_C301:
; --- Code Region ---
  INC $0013                             ; $C301: EE 13 00
  LDY $0013                             ; $C304: AC 13 00
  CPY #$1B                              ; $C307: C0 1B
  BCC $C2CD                             ; $C309: 90 C2
Loc_C30B:
  INC $0012                             ; $C30B: EE 12 00
  LDA $0012                             ; $C30E: AD 12 00
  CMP #$1E                              ; $C311: C9 1E
  BCC $C2AB                             ; $C313: 90 96
  JMP $C28E                             ; $C315: 4C 8E C2
Loc_C318:
  LDA $0031                             ; $C318: AD 31 00
  CMP $040D                             ; $C31B: CD 0D 04
  BNE $C321                             ; $C31E: D0 01
  RTS                                   ; $C320: 60
Loc_C321:
  LDY #$0B                              ; $C321: A0 0B
  LDA ($22),Y                           ; $C323: B1 22
  AND #$FC                              ; $C325: 29 FC
  STA ($22),Y                           ; $C327: 91 22
  LDY $0013                             ; $C329: AC 13 00
Loc_C32C:
  CPY #$1A                              ; $C32C: C0 1A
  BEQ $C33A                             ; $C32E: F0 0A
  INY                                   ; $C330: C8
  LDA ($10),Y                           ; $C331: B1 10
  DEY                                   ; $C333: 88
  STA ($10),Y                           ; $C334: 91 10
  INY                                   ; $C336: C8
  JMP $C32C                             ; $C337: 4C 2C C3
Loc_C33A:
  LDA #$FF                              ; $C33A: A9 FF
  STA ($10),Y                           ; $C33C: 91 10
  DEC $0013                             ; $C33E: CE 13 00
  RTS                                   ; $C341: 60
; --- Data Region ---
  .byte $DA,$DB,$D3,$FF,$FF,$FF,$FF,$FF,$09,$07,$FF,$FF,$FF,$FF,$FF,$FF; $C342: DA DB D3 FF FF FF FF FF 09 07 FF FF FF FF FF FF
  .byte $84,$7B,$7F,$80,$85,$82,$FF,$FF,$89,$8B,$5D,$FF,$FF,$FF,$FF,$FF; $C352: 84 7B 7F 80 85 82 FF FF 89 8B 5D FF FF FF FF FF
  .byte $E0,$6D,$26,$99,$FF,$FF,$FF,$FF,$42,$97,$FF,$FF,$FF,$FF,$FF,$FF; $C362: E0 6D 26 99 FF FF FF FF 42 97 FF FF FF FF FF FF
  .byte $B4,$B0,$B5,$B3,$FF,$FF,$FF,$FF   ; $C372: B4 B0 B5 B3 FF FF FF FF
Loc_C37A:  ; (dispatch callback target)
; --- Code Region ---
  LDA $0402                             ; $C37A: AD 02 04
  JSR $EADE                             ; $C37D: 20 DE EA
; --- Data Region ---
  .byte $86,$C3,$C2,$C3,$1E,$C4,$AC,$0A,$04,$B9,$BB,$C3,$8D,$2D,$04,$A9; $C380: 86 C3 C2 C3 1E C4 AC 0A 04 B9 BB C3 8D 2D 04 A9
  .byte $C3,$20,$8B,$F2,$AD,$0A,$04,$20,$68,$F3,$A0,$00,$B1,$00,$8D,$2C; $C390: C3 20 8B F2 AD 0A 04 20 68 F3 A0 00 B1 00 8D 2C
  .byte $04,$A9,$FF,$91,$00,$A0,$03,$B1,$00,$29,$03,$C9,$03,$D0,$08,$EE; $C3A0: 04 A9 FF 91 00 A0 03 B1 00 29 03 C9 03 D0 08 EE
  .byte $02,$04,$A9,$00,$8D,$D0,$04       ; $C3B0: 02 04 A9 00 8D D0 04
Loc_C3B7:
; --- Code Region ---
  INC $0402                             ; $C3B7: EE 02 04
  RTS                                   ; $C3BA: 60
; --- Data Region ---
  .byte $AD,$08,$83,$8A,$DE,$DC,$B6,$AD,$00,$03,$C9,$FF,$D0,$11,$AD,$04; $C3BB: AD 08 83 8A DE DC B6 AD 00 03 C9 FF D0 11 AD 04
  .byte $03,$C9,$FF,$D0,$0A,$20,$C2,$A1,$AD,$81,$00,$29,$03,$D0,$01; $C3CB: 03 C9 FF D0 0A 20 C2 A1 AD 81 00 29 03 D0 01
Loc_C3DA:
; --- Code Region ---
  RTS                                   ; $C3DA: 60
Loc_C3DB:
  LDA $040C                             ; $C3DB: AD 0C 04
  CMP #$FF                              ; $C3DE: C9 FF
  BEQ $C3E9                             ; $C3E0: F0 07
  JSR $F368                             ; $C3E2: 20 68 F3
  LDY #$00                              ; $C3E5: A0 00
  LDA ($00),Y                           ; $C3E7: B1 00
Loc_C3E9:
  STA $042E                             ; $C3E9: 8D 2E 04
  LDA $6F00                             ; $C3EC: AD 00 6F
  CLC                                   ; $C3EF: 18
  ADC #$64                              ; $C3F0: 69 64
  STA $042F                             ; $C3F2: 8D 2F 04
  LDA #$00                              ; $C3F5: A9 00
  ADC #$00                              ; $C3F7: 69 00
  STA $0430                             ; $C3F9: 8D 30 04
  LDA $6F01                             ; $C3FC: AD 01 6F
  CLC                                   ; $C3FF: 18
  ADC #$01                              ; $C400: 69 01
  STA $0432                             ; $C402: 8D 32 04
  LDA #$00                              ; $C405: A9 00
  STA $0431                             ; $C407: 8D 31 04
  STA $0433                             ; $C40A: 8D 33 04
  STA $0434                             ; $C40D: 8D 34 04
  LDA #$0D                              ; $C410: A9 0D
  STA $007A                             ; $C412: 8D 7A 00
  LDA #$00                              ; $C415: A9 00
  STA $0541                             ; $C417: 8D 41 05
  STA $04CA                             ; $C41A: 8D CA 04
  RTS                                   ; $C41D: 60
; --- Data Region ---
  .byte $EE,$D0,$04,$D0,$11,$AD,$72,$04,$8D,$00,$04,$AD,$73,$04,$8D,$01; $C41E: EE D0 04 D0 11 AD 72 04 8D 00 04 AD 73 04 8D 01
  .byte $04,$A9,$00,$8D,$02,$04           ; $C42E: 04 A9 00 8D 02 04
Loc_C434:
; --- Code Region ---
  RTS                                   ; $C434: 60
Loc_C435:
  LDA $0401                             ; $C435: AD 01 04
  JSR $EADE                             ; $C438: 20 DE EA
; --- Data Region ---
  .byte $41,$C4,$B9,$C5,$DF,$C5           ; $C43B: 41 C4 B9 C5 DF C5
Loc_C441:  ; (dispatch callback target)
; --- Code Region ---
  LDY #$00                              ; $C441: A0 00
  LDA ($EE),Y                           ; $C443: B1 EE
  STA $042C                             ; $C445: 8D 2C 04
  LDX #$00                              ; $C448: A2 00
  STX $0010                             ; $C44A: 8E 10 00
  STX $0011                             ; $C44D: 8E 11 00
  STX $0012                             ; $C450: 8E 12 00
  STX $0013                             ; $C453: 8E 13 00
  STX $0014                             ; $C456: 8E 14 00
Loc_C459:
  TXA                                   ; $C459: 8A
  JSR $F2AF                             ; $C45A: 20 AF F2
  LDA $0000                             ; $C45D: AD 00 00
  STA $000A                             ; $C460: 8D 0A 00
  LDA $0001                             ; $C463: AD 01 00
  STA $000B                             ; $C466: 8D 0B 00
  LDY #$0B                              ; $C469: A0 0B
  LDA ($0A),Y                           ; $C46B: B1 0A
  CLC                                   ; $C46D: 18
  ADC $0012                             ; $C46E: 6D 12 00
  STA $0012                             ; $C471: 8D 12 00
  LDA #$00                              ; $C474: A9 00
  ADC $0013                             ; $C476: 6D 13 00
  STA $0013                             ; $C479: 8D 13 00
  LDY #$11                              ; $C47C: A0 11
Loc_C47E:
  TYA                                   ; $C47E: 98
  PHA                                   ; $C47F: 48
  LDA ($0A),Y                           ; $C480: B1 0A
  CMP #$FF                              ; $C482: C9 FF
  BEQ $C4A4                             ; $C484: F0 1E
  CMP $042C                             ; $C486: CD 2C 04
  BEQ $C4A4                             ; $C489: F0 19
  JSR $F2D7                             ; $C48B: 20 D7 F2
  LDY #$03                              ; $C48E: A0 03
  LDA ($00),Y                           ; $C490: B1 00
  CLC                                   ; $C492: 18
  ADC $0010                             ; $C493: 6D 10 00
  STA $0010                             ; $C496: 8D 10 00
  LDA #$00                              ; $C499: A9 00
  ADC $0011                             ; $C49B: 6D 11 00
  STA $0011                             ; $C49E: 8D 11 00
  INC $0014                             ; $C4A1: EE 14 00
Loc_C4A4:
  PLA                                   ; $C4A4: 68
  TAY                                   ; $C4A5: A8
  INY                                   ; $C4A6: C8
  CPY #$1B                              ; $C4A7: C0 1B
  BCC $C47E                             ; $C4A9: 90 D3
  INX                                   ; $C4AB: E8
  CPX #$1E                              ; $C4AC: E0 1E
  BCC $C459                             ; $C4AE: 90 A9
  LDA #$00                              ; $C4B0: A9 00
  STA $0435                             ; $C4B2: 8D 35 04
  STA $0436                             ; $C4B5: 8D 36 04
  STA $0437                             ; $C4B8: 8D 37 04
  LDA $0010                             ; $C4BB: AD 10 00
  STA $0001                             ; $C4BE: 8D 01 00
  LDA $0011                             ; $C4C1: AD 11 00
  STA $0002                             ; $C4C4: 8D 02 00
  LDA $0014                             ; $C4C7: AD 14 00
  STA $0003                             ; $C4CA: 8D 03 00
  LDA #$00                              ; $C4CD: A9 00
  STA $0004                             ; $C4CF: 8D 04 00
  JSR $C59A                             ; $C4D2: 20 9A C5
  LDA $0014                             ; $C4D5: AD 14 00
  STA $0000                             ; $C4D8: 8D 00 00
  LDA #$00                              ; $C4DB: A9 00
  STA $0001                             ; $C4DD: 8D 01 00
  STA $0002                             ; $C4E0: 8D 02 00
  LDA #$64                              ; $C4E3: A9 64
  STA $0003                             ; $C4E5: 8D 03 00
  JSR $EBE9                             ; $C4E8: 20 E9 EB
  LDA $0006                             ; $C4EB: AD 06 00
  STA $0001                             ; $C4EE: 8D 01 00
  LDA $0007                             ; $C4F1: AD 07 00
  STA $0002                             ; $C4F4: 8D 02 00
  LDA #$82                              ; $C4F7: A9 82
  STA $0003                             ; $C4F9: 8D 03 00
  LDA #$00                              ; $C4FC: A9 00
  STA $0004                             ; $C4FE: 8D 04 00
  JSR $C59A                             ; $C501: 20 9A C5
  LDA $0012                             ; $C504: AD 12 00
  STA $0001                             ; $C507: 8D 01 00
  LDA $0013                             ; $C50A: AD 13 00
  STA $0002                             ; $C50D: 8D 02 00
  LDA #$1E                              ; $C510: A9 1E
  STA $0003                             ; $C512: 8D 03 00
  LDA #$00                              ; $C515: A9 00
  STA $0004                             ; $C517: 8D 04 00
  JSR $C59A                             ; $C51A: 20 9A C5
  LDA $0435                             ; $C51D: AD 35 04
  STA $0000                             ; $C520: 8D 00 00
  LDA $0436                             ; $C523: AD 36 04
  STA $0001                             ; $C526: 8D 01 00
  LDA $0437                             ; $C529: AD 37 04
  STA $0002                             ; $C52C: 8D 02 00
  LDA #$03                              ; $C52F: A9 03
  STA $0003                             ; $C531: 8D 03 00
  LDA #$00                              ; $C534: A9 00
  STA $0004                             ; $C536: 8D 04 00
  JSR $EAA5                             ; $C539: 20 A5 EA
  LDA $0000                             ; $C53C: AD 00 00
  STA $0435                             ; $C53F: 8D 35 04
  LDA $0001                             ; $C542: AD 01 00
  STA $0436                             ; $C545: 8D 36 04
  LDA $0002                             ; $C548: AD 02 00
  STA $0437                             ; $C54B: 8D 37 04
  LDA $6F00                             ; $C54E: AD 00 6F
  SEC                                   ; $C551: 38
  SBC #$59                              ; $C552: E9 59
  STA $044C                             ; $C554: 8D 4C 04
  LDA #$00                              ; $C557: A9 00
  STA $044D                             ; $C559: 8D 4D 04
  STA $044E                             ; $C55C: 8D 4E 04
  LDA $6F00                             ; $C55F: AD 00 6F
  CLC                                   ; $C562: 18
  ADC #$64                              ; $C563: 69 64
  STA $042F                             ; $C565: 8D 2F 04
  LDA #$00                              ; $C568: A9 00
  ADC #$00                              ; $C56A: 69 00
  STA $0430                             ; $C56C: 8D 30 04
  LDA #$00                              ; $C56F: A9 00
  STA $0431                             ; $C571: 8D 31 04
  LDA $6F01                             ; $C574: AD 01 6F
  CLC                                   ; $C577: 18
  ADC #$01                              ; $C578: 69 01
  STA $0432                             ; $C57A: 8D 32 04
  LDA #$00                              ; $C57D: A9 00
  STA $0433                             ; $C57F: 8D 33 04
  STA $0434                             ; $C582: 8D 34 04
  LDA $6F02                             ; $C585: AD 02 6F
  CLC                                   ; $C588: 18
  ADC #$01                              ; $C589: 69 01
  STA $044F                             ; $C58B: 8D 4F 04
  LDA #$00                              ; $C58E: A9 00
  STA $0450                             ; $C590: 8D 50 04
  STA $0451                             ; $C593: 8D 51 04
  INC $0401                             ; $C596: EE 01 04
  RTS                                   ; $C599: 60
Loc_C59A:
  JSR $EA7C                             ; $C59A: 20 7C EA
  LDA $0001                             ; $C59D: AD 01 00
  CLC                                   ; $C5A0: 18
  ADC $0435                             ; $C5A1: 6D 35 04
  STA $0435                             ; $C5A4: 8D 35 04
  LDA $0002                             ; $C5A7: AD 02 00
  ADC $0436                             ; $C5AA: 6D 36 04
  STA $0436                             ; $C5AD: 8D 36 04
  LDA #$00                              ; $C5B0: A9 00
  ADC $0437                             ; $C5B2: 6D 37 04
  STA $0437                             ; $C5B5: 8D 37 04
  RTS                                   ; $C5B8: 60
Loc_C5B9:  ; (dispatch callback target)
  LDA $007E                             ; $C5B9: AD 7E 00
  BEQ $C5BF                             ; $C5BC: F0 01
  RTS                                   ; $C5BE: 60
Loc_C5BF:
  JSR $C626                             ; $C5BF: 20 26 C6
  LDA $0010                             ; $C5C2: AD 10 00
  STA $042D                             ; $C5C5: 8D 2D 04
  STA $0000                             ; $C5C8: 8D 00 00
  LDY #$3D                              ; $C5CB: A0 3D
  JSR $EE07                             ; $C5CD: 20 07 EE
; --- Data Region ---
  .byte $2A,$A0,$A9,$03,$8D,$A4,$00,$EE,$01,$04,$A9,$DF,$4C,$6D,$F2; $C5D0: 2A A0 A9 03 8D A4 00 EE 01 04 A9 DF 4C 6D F2
Loc_C5DF:  ; (dispatch callback target)
; --- Code Region ---
  LDA $042D                             ; $C5DF: AD 2D 04
  STA $0000                             ; $C5E2: 8D 00 00
  LDA #$A7                              ; $C5E5: A9 A7
  STA $000A                             ; $C5E7: 8D 0A 00
  LDX #$00                              ; $C5EA: A2 00
  JSR $CE1F                             ; $C5EC: 20 1F CE
  LDA $0300                             ; $C5EF: AD 00 03
  CMP #$FF                              ; $C5F2: C9 FF
  BNE $C625                             ; $C5F4: D0 2F
  LDA $0304                             ; $C5F6: AD 04 03
  CMP #$FF                              ; $C5F9: C9 FF
  BNE $C625                             ; $C5FB: D0 28
  JSR $A1C2                             ; $C5FD: 20 C2 A1
  LDA $0081                             ; $C600: AD 81 00
  LSR                                   ; $C603: 4A
  BCC $C625                             ; $C604: 90 1F
  LDA #$0D                              ; $C606: A9 0D
  STA $007A                             ; $C608: 8D 7A 00
  LDX #$01                              ; $C60B: A2 01
  LDA $0435                             ; $C60D: AD 35 04
  CMP #$46                              ; $C610: C9 46
  BCS $C61A                             ; $C612: B0 06
  INX                                   ; $C614: E8
  CMP #$28                              ; $C615: C9 28
  BCS $C61A                             ; $C617: B0 01
  INX                                   ; $C619: E8
Loc_C61A:
  STX $0541                             ; $C61A: 8E 41 05
  LDA #$00                              ; $C61D: A9 00
  STA $04C9                             ; $C61F: 8D C9 04
  STA $04CA                             ; $C622: 8D CA 04
Loc_C625:
  RTS                                   ; $C625: 60
Loc_C626:
  LDX #$00                              ; $C626: A2 00
  STX $0010                             ; $C628: 8E 10 00
  STX $0011                             ; $C62B: 8E 11 00
Loc_C62E:
  TXA                                   ; $C62E: 8A
  JSR $F2AF                             ; $C62F: 20 AF F2
  LDY #$00                              ; $C632: A0 00
  LDA ($00),Y                           ; $C634: B1 00
  AND #$07                              ; $C636: 29 07
  CMP $6F03                             ; $C638: CD 03 6F
  BNE $C640                             ; $C63B: D0 03
  JSR $C646                             ; $C63D: 20 46 C6
Loc_C640:
  INX                                   ; $C640: E8
  CPX #$1E                              ; $C641: E0 1E
  BCC $C62E                             ; $C643: 90 E9
  RTS                                   ; $C645: 60
Loc_C646:
  LDA $0000                             ; $C646: AD 00 00
  STA $000A                             ; $C649: 8D 0A 00
  LDA $0001                             ; $C64C: AD 01 00
  STA $000B                             ; $C64F: 8D 0B 00
  LDY #$11                              ; $C652: A0 11
Loc_C654:
  TYA                                   ; $C654: 98
  PHA                                   ; $C655: 48
  LDA ($0A),Y                           ; $C656: B1 0A
  CMP #$FF                              ; $C658: C9 FF
  BEQ $C674                             ; $C65A: F0 18
  STA $0002                             ; $C65C: 8D 02 00
  JSR $F2D7                             ; $C65F: 20 D7 F2
  LDY #$02                              ; $C662: A0 02
  LDA ($00),Y                           ; $C664: B1 00
  CMP $0011                             ; $C666: CD 11 00
  BCC $C674                             ; $C669: 90 09
  STA $0011                             ; $C66B: 8D 11 00
  LDA $0002                             ; $C66E: AD 02 00
  STA $0010                             ; $C671: 8D 10 00
Loc_C674:
  PLA                                   ; $C674: 68
  TAY                                   ; $C675: A8
  INY                                   ; $C676: C8
  CPY #$1B                              ; $C677: C0 1B
  BCC $C654                             ; $C679: 90 D9
  RTS                                   ; $C67B: 60
Loc_C67C:
  LDA $0318                             ; $C67C: AD 18 03
  STA $0000                             ; $C67F: 8D 00 00
  LDA $0083                             ; $C682: AD 83 00
  AND #$F0                              ; $C685: 29 F0
  STA $0318                             ; $C687: 8D 18 03
  BEQ $C6A8                             ; $C68A: F0 1C
  CMP $0000                             ; $C68C: CD 00 00
  BNE $C6AE                             ; $C68F: D0 1D
  INC $0319                             ; $C691: EE 19 03
  LDA $0319                             ; $C694: AD 19 03
  CMP #$0F                              ; $C697: C9 0F
  BCC $C6A7                             ; $C699: 90 0C
  LDA #$0F                              ; $C69B: A9 0F
  STA $0319                             ; $C69D: 8D 19 03
  LDA $005E                             ; $C6A0: AD 5E 00
  AND #$03                              ; $C6A3: 29 03
  BEQ $C6B3                             ; $C6A5: F0 0C
Loc_C6A7:
  RTS                                   ; $C6A7: 60
Loc_C6A8:
  LDA #$00                              ; $C6A8: A9 00
  STA $0319                             ; $C6AA: 8D 19 03
  RTS                                   ; $C6AD: 60
Loc_C6AE:
  LDA #$00                              ; $C6AE: A9 00
  STA $0319                             ; $C6B0: 8D 19 03
Loc_C6B3:
  LDA $0083                             ; $C6B3: AD 83 00
  BPL $C6CA                             ; $C6B6: 10 12
  LDX $6F3F                             ; $C6B8: AE 3F 6F
  CPX #$F8                              ; $C6BB: E0 F8
  BCS $C6CA                             ; $C6BD: B0 0B
  PHA                                   ; $C6BF: 48
  LDA $6F3F                             ; $C6C0: AD 3F 6F
  CLC                                   ; $C6C3: 18
  ADC #$08                              ; $C6C4: 69 08
  STA $6F3F                             ; $C6C6: 8D 3F 6F
  PLA                                   ; $C6C9: 68
Loc_C6CA:
  ASL                                   ; $C6CA: 0A
  BPL $C6DF                             ; $C6CB: 10 12
  LDX $6F3F                             ; $C6CD: AE 3F 6F
  CPX #$10                              ; $C6D0: E0 10
  BCC $C6DF                             ; $C6D2: 90 0B
  PHA                                   ; $C6D4: 48
  LDA $6F3F                             ; $C6D5: AD 3F 6F
  SEC                                   ; $C6D8: 38
  SBC #$08                              ; $C6D9: E9 08
  STA $6F3F                             ; $C6DB: 8D 3F 6F
  PLA                                   ; $C6DE: 68
Loc_C6DF:
  ASL                                   ; $C6DF: 0A
  BPL $C6F4                             ; $C6E0: 10 12
  LDX $6F41                             ; $C6E2: AE 41 6F
  CPX #$94                              ; $C6E5: E0 94
Loc_C6E7:
  BCS $C6F4                             ; $C6E7: B0 0B
  PHA                                   ; $C6E9: 48
  LDA $6F41                             ; $C6EA: AD 41 6F
  CLC                                   ; $C6ED: 18
  ADC #$08                              ; $C6EE: 69 08
Loc_C6F0:
  STA $6F41                             ; $C6F0: 8D 41 6F
Loc_C6F3:
  PLA                                   ; $C6F3: 68
Loc_C6F4:
  ASL                                   ; $C6F4: 0A
  BPL $C707                             ; $C6F5: 10 10
  LDX $6F41                             ; $C6F7: AE 41 6F
  CPX #$10                              ; $C6FA: E0 10
  BCC $C707                             ; $C6FC: 90 09
  LDA $6F41                             ; $C6FE: AD 41 6F
  SEC                                   ; $C701: 38
  SBC #$08                              ; $C702: E9 08
  STA $6F41                             ; $C704: 8D 41 6F
Loc_C707:
  RTS                                   ; $C707: 60
Loc_C708:
  LDA $6F3F                             ; $C708: AD 3F 6F
  CMP #$20                              ; $C70B: C9 20
  BCS $C719                             ; $C70D: B0 0A
  LDA $6F41                             ; $C70F: AD 41 6F
  CMP #$20                              ; $C712: C9 20
  BCS $C719                             ; $C714: B0 03
  LDY #$FF                              ; $C716: A0 FF
  RTS                                   ; $C718: 60
Loc_C719:
  LDY #$1E                              ; $C719: A0 1E
Loc_C71B:
  LDA $6F3F                             ; $C71B: AD 3F 6F
  SEC                                   ; $C71E: 38
  SBC $C737,Y                           ; $C71F: F9 37 C7
  CMP #$10                              ; $C722: C9 10
  BCS $C731                             ; $C724: B0 0B
  LDA $6F41                             ; $C726: AD 41 6F
  SEC                                   ; $C729: 38
  SBC $C755,Y                           ; $C72A: F9 55 C7
  CMP #$10                              ; $C72D: C9 10
  BCC $C736                             ; $C72F: 90 05
Loc_C731:
  DEY                                   ; $C731: 88
  BPL $C71B                             ; $C732: 10 E7
  LDY #$FF                              ; $C734: A0 FF
Loc_C736:
  RTS                                   ; $C736: 60
; --- Data Region ---
  .byte $E8,$B0,$90,$D0,$A8,$68,$38,$58,$70,$38,$D0,$B0,$90,$80,$A8,$D8; $C737: E8 B0 90 D0 A8 68 38 58 70 38 D0 B0 90 80 A8 D8
  .byte $C0,$D0,$B8,$68,$A8,$88,$70,$98,$80,$50,$38,$58,$40,$10,$10,$17; $C747: C0 D0 B8 68 A8 88 70 98 80 50 38 58 40 10 10 17
  .byte $1F,$28,$38,$17,$28,$38,$40,$40,$40,$48,$48,$50,$58,$60,$60; $C757: 1F 28 38 17 28 38 40 40 40 48 48 50 58 60 60
Loc_C766:
; --- Code Region ---
  BVS $C6F0                             ; $C766: 70 88
  DEY                                   ; $C768: 88
  PLA                                   ; $C769: 68
  PLA                                   ; $C76A: 68
  BVS $C7E5                             ; $C76B: 70 78
  NOP #$50                              ; $C76D: 80 50
  RTS                                   ; $C76F: 60
; --- Data Region ---
  .byte $68,$78,$78                       ; $C770: 68 78 78
Loc_C773:
; --- Code Region ---
  LDA $0401                             ; $C773: AD 01 04
  JSR $EADE                             ; $C776: 20 DE EA
; --- Data Region ---
  .byte $9B,$C7,$E0,$C7,$E0,$C7,$E0,$C7,$D2,$C9,$42,$CA,$42,$CA,$42,$CA; $C779: 9B C7 E0 C7 E0 C7 E0 C7 D2 C9 42 CA 42 CA 42 CA
  .byte $84,$CA,$D4,$CA,$2F,$CB,$7F,$CB,$9D,$CB,$7F,$CB,$C3,$CB,$26,$CC; $C789: 84 CA D4 CA 2F CB 7F CB 9D CB 7F CB C3 CB 26 CC
  .byte $89,$CC,$A9,$BB,$20,$8B,$F2,$A0,$00,$B1,$EE,$8D,$2C,$04,$A9,$F0; $C799: 89 CC A9 BB 20 8B F2 A0 00 B1 EE 8D 2C 04 A9 F0
  .byte $8D,$41,$6F,$EE,$01,$04,$A9,$00,$8D,$0C,$04,$AC,$05,$6F,$B9,$CC; $C7A9: 8D 41 6F EE 01 04 A9 00 8D 0C 04 AC 05 6F B9 CC
  .byte $C7,$8D,$5D                       ; $C7B9: C7 8D 5D
Loc_C7BC:
; --- Code Region ---
  RRA $00A9                             ; $C7BC: 6F A9 00
  STA $6F8B                             ; $C7BF: 8D 8B 6F
  STA $6F5B                             ; $C7C2: 8D 5B 6F
  STA $6F5C                             ; $C7C5: 8D 5C 6F
  STA $6F62                             ; $C7C8: 8D 62 6F
  RTS                                   ; $C7CB: 60
; --- Data Region ---
  .byte $00,$0A,$14,$1E,$28,$32,$3C,$46,$50,$5A,$64,$6E,$78,$82,$8C,$96; $C7CC: 00 0A 14 1E 28 32 3C 46 50 5A 64 6E 78 82 8C 96
  .byte $A0,$AA,$B4,$BE                   ; $C7DC: A0 AA B4 BE
Loc_C7E0:  ; (dispatch callback target)
; --- Code Region ---
  JSR $CD8C                             ; $C7E0: 20 8C CD
  LDA $040C                             ; $C7E3: AD 0C 04
  BNE $C81B                             ; $C7E6: D0 33
  LDA $0304                             ; $C7E8: AD 04 03
  CMP #$FF                              ; $C7EB: C9 FF
  BNE $C818                             ; $C7ED: D0 29
  LDA $0300                             ; $C7EF: AD 00 03
  CMP #$FF                              ; $C7F2: C9 FF
  BNE $C818                             ; $C7F4: D0 22
  LDA $6F03                             ; $C7F6: AD 03 6F
  JSR $F368                             ; $C7F9: 20 68 F3
  LDY #$00                              ; $C7FC: A0 00
  LDA ($00),Y                           ; $C7FE: B1 00
  STA $000B                             ; $C800: 8D 0B 00
  LDA #$00                              ; $C803: A9 00
  STA $000A                             ; $C805: 8D 0A 00
  LDA $040C                             ; $C808: AD 0C 04
  STA $000C                             ; $C80B: 8D 0C 00
  LDY #$3D                              ; $C80E: A0 3D
  JSR $EE07                             ; $C810: 20 07 EE
; --- Data Region ---
  .byte $42,$A0,$EE,$0C,$04               ; $C813: 42 A0 EE 0C 04
Loc_C818:
; --- Code Region ---
  JMP $C898                             ; $C818: 4C 98 C8
Loc_C81B:
  LDA $6F03                             ; $C81B: AD 03 6F
  JSR $F368                             ; $C81E: 20 68 F3
  LDY #$00                              ; $C821: A0 00
  LDA ($00),Y                           ; $C823: B1 00
  STA $000B                             ; $C825: 8D 0B 00
  LDA #$00                              ; $C828: A9 00
  STA $000A                             ; $C82A: 8D 0A 00
  LDA $040C                             ; $C82D: AD 0C 04
  STA $000C                             ; $C830: 8D 0C 00
  LDY #$3D                              ; $C833: A0 3D
  JSR $EE07                             ; $C835: 20 07 EE
; --- Data Region ---
  .byte $42,$A0,$AD,$8B,$6F,$C9,$FE,$F0,$58,$C9,$FD,$D0,$03,$4C,$CF,$C8; $C838: 42 A0 AD 8B 6F C9 FE F0 58 C9 FD D0 03 4C CF C8
Loc_C848:
; --- Code Region ---
  CMP #$FC                              ; $C848: C9 FC
  BNE $C84F                             ; $C84A: D0 03
  JMP $C905                             ; $C84C: 4C 05 C9
Loc_C84F:
  CMP #$FB                              ; $C84F: C9 FB
  BNE $C856                             ; $C851: D0 03
  JMP $C91B                             ; $C853: 4C 1B C9
Loc_C856:
  CMP #$FA                              ; $C856: C9 FA
  BNE $C85D                             ; $C858: D0 03
  JMP $C942                             ; $C85A: 4C 42 C9
Loc_C85D:
  CMP #$F9                              ; $C85D: C9 F9
  BNE $C864                             ; $C85F: D0 03
  JMP $C97D                             ; $C861: 4C 7D C9
Loc_C864:
  CMP #$F8                              ; $C864: C9 F8
  BNE $C86B                             ; $C866: D0 03
  JMP $C9AB                             ; $C868: 4C AB C9
Loc_C86B:
  CMP #$FF                              ; $C86B: C9 FF
  BNE $C898                             ; $C86D: D0 29
  INC $040C                             ; $C86F: EE 0C 04
  LDA $040C                             ; $C872: AD 0C 04
  CMP #$20                              ; $C875: C9 20
  BCC $C898                             ; $C877: 90 1F
  LDA #$00                              ; $C879: A9 00
  STA $0400                             ; $C87B: 8D 00 04
  STA $0401                             ; $C87E: 8D 01 04
  STA $6F05                             ; $C881: 8D 05 6F
  LDA #$FF                              ; $C884: A9 FF
  STA $000B                             ; $C886: 8D 0B 00
  STA $000A                             ; $C889: 8D 0A 00
  LDA #$00                              ; $C88C: A9 00
  STA $000C                             ; $C88E: 8D 0C 00
  LDY #$3D                              ; $C891: A0 3D
  JSR $EE07                             ; $C893: 20 07 EE
; --- Data Region ---
  .byte $42,$A0                           ; $C896: 42 A0
Loc_C898:
; --- Code Region ---
  RTS                                   ; $C898: 60
Loc_C899:
  JSR $CA2A                             ; $C899: 20 2A CA
  LDA $6F03                             ; $C89C: AD 03 6F
  JSR $F368                             ; $C89F: 20 68 F3
  LDY #$00                              ; $C8A2: A0 00
  LDA ($00),Y                           ; $C8A4: B1 00
  STA $000B                             ; $C8A6: 8D 0B 00
  LDA #$01                              ; $C8A9: A9 01
  STA $000A                             ; $C8AB: 8D 0A 00
  LDA #$00                              ; $C8AE: A9 00
  STA $000C                             ; $C8B0: 8D 0C 00
  LDY #$3D                              ; $C8B3: A0 3D
  JSR $EE07                             ; $C8B5: 20 07 EE
; --- Data Region ---
  .byte $42,$A0,$A9,$09,$8D,$A0,$04,$A9,$47,$8D,$D6,$04,$A9,$04,$8D,$01; $C8B8: 42 A0 A9 09 8D A0 04 A9 47 8D D6 04 A9 04 8D 01
  .byte $04,$A9,$00,$8D,$0C,$04,$60       ; $C8C8: 04 A9 00 8D 0C 04 60
Loc_C8CF:
; --- Code Region ---
  JSR $CA2A                             ; $C8CF: 20 2A CA
  LDA $6F03                             ; $C8D2: AD 03 6F
  JSR $F368                             ; $C8D5: 20 68 F3
  LDY #$00                              ; $C8D8: A0 00
  LDA ($00),Y                           ; $C8DA: B1 00
  STA $000B                             ; $C8DC: 8D 0B 00
  LDA #$01                              ; $C8DF: A9 01
  STA $000A                             ; $C8E1: 8D 0A 00
  LDA #$00                              ; $C8E4: A9 00
  STA $000C                             ; $C8E6: 8D 0C 00
  LDY #$3D                              ; $C8E9: A0 3D
  JSR $EE07                             ; $C8EB: 20 07 EE
; --- Data Region ---
  .byte $42,$A0,$A9,$09,$8D,$A0,$04,$A9,$A2,$8D,$D6,$04,$A9,$08,$8D,$01; $C8EE: 42 A0 A9 09 8D A0 04 A9 A2 8D D6 04 A9 08 8D 01
  .byte $04,$A9,$00,$8D,$0C,$04,$60       ; $C8FE: 04 A9 00 8D 0C 04 60
Loc_C905:
; --- Code Region ---
  LDA $0038                             ; $C905: AD 38 00
  STA $042C                             ; $C908: 8D 2C 04
  LDA #$C1                              ; $C90B: A9 C1
  JSR $F28B                             ; $C90D: 20 8B F2
  LDA #$0B                              ; $C910: A9 0B
  STA $0401                             ; $C912: 8D 01 04
  LDA #$00                              ; $C915: A9 00
  STA $040C                             ; $C917: 8D 0C 04
  RTS                                   ; $C91A: 60
Loc_C91B:
  LDA $0038                             ; $C91B: AD 38 00
  STA $042C                             ; $C91E: 8D 2C 04
  LDY $0040                             ; $C921: AC 40 00
  LDA $C93A,Y                           ; $C924: B9 3A C9
  STA $042D                             ; $C927: 8D 2D 04
  LDA #$C3                              ; $C92A: A9 C3
  JSR $F28B                             ; $C92C: 20 8B F2
  LDA #$0C                              ; $C92F: A9 0C
  STA $0401                             ; $C931: 8D 01 04
  LDA #$00                              ; $C934: A9 00
  STA $040C                             ; $C936: 8D 0C 04
  RTS                                   ; $C939: 60
; --- Data Region ---
  .byte $AD,$08,$83,$8A,$DE,$DC,$B6,$00   ; $C93A: AD 08 83 8A DE DC B6 00
Loc_C942:
; --- Code Region ---
  LDA $0041                             ; $C942: AD 41 00
  STA $042C                             ; $C945: 8D 2C 04
  LDA $0040                             ; $C948: AD 40 00
  STA $042D                             ; $C94B: 8D 2D 04
  LDA #$E6                              ; $C94E: A9 E6
  JSR $F26D                             ; $C950: 20 6D F2
  LDA $003D                             ; $C953: AD 3D 00
  STA $0000                             ; $C956: 8D 00 00
  LDY #$3D                              ; $C959: A0 3D
  JSR $EE07                             ; $C95B: 20 07 EE
; --- Data Region ---
  .byte $2A,$A0,$A9,$0E,$8D,$01,$04,$A9,$00,$8D,$02,$04,$A9,$00,$8D,$0C; $C95E: 2A A0 A9 0E 8D 01 04 A9 00 8D 02 04 A9 00 8D 0C
  .byte $04,$AD,$42,$00,$20,$68,$F3,$A0,$03,$B1,$00,$8D,$44,$6F,$60; $C96E: 04 AD 42 00 20 68 F3 A0 03 B1 00 8D 44 6F 60
Loc_C97D:
; --- Code Region ---
  LDA $003A                             ; $C97D: AD 3A 00
  STA $042C                             ; $C980: 8D 2C 04
  LDA $0039                             ; $C983: AD 39 00
  STA $042D                             ; $C986: 8D 2D 04
  LDA #$E6                              ; $C989: A9 E6
  JSR $F26D                             ; $C98B: 20 6D F2
  LDA $003D                             ; $C98E: AD 3D 00
  STA $0000                             ; $C991: 8D 00 00
  LDY #$3D                              ; $C994: A0 3D
  JSR $EE07                             ; $C996: 20 07 EE
; --- Data Region ---
  .byte $2A,$A0,$A9,$0F,$8D,$01,$04,$A9,$00,$8D,$02,$04,$A9,$00,$8D,$0C; $C999: 2A A0 A9 0F 8D 01 04 A9 00 8D 02 04 A9 00 8D 0C
  .byte $04,$60                           ; $C9A9: 04 60
Loc_C9AB:
; --- Code Region ---
  LDA $0041                             ; $C9AB: AD 41 00
  STA $042C                             ; $C9AE: 8D 2C 04
  LDA $0040                             ; $C9B1: AD 40 00
  STA $042D                             ; $C9B4: 8D 2D 04
  LDA $0042                             ; $C9B7: AD 42 00
  STA $042E                             ; $C9BA: 8D 2E 04
  LDA #$E2                              ; $C9BD: A9 E2
  JSR $F28B                             ; $C9BF: 20 8B F2
  LDA #$10                              ; $C9C2: A9 10
  STA $0401                             ; $C9C4: 8D 01 04
  LDA #$00                              ; $C9C7: A9 00
  STA $0402                             ; $C9C9: 8D 02 04
  LDA #$00                              ; $C9CC: A9 00
  STA $040C                             ; $C9CE: 8D 0C 04
  RTS                                   ; $C9D1: 60
Loc_C9D2:  ; (dispatch callback target)
  JSR $CA02                             ; $C9D2: 20 02 CA
  LDA $6F03                             ; $C9D5: AD 03 6F
  JSR $F368                             ; $C9D8: 20 68 F3
  LDY #$00                              ; $C9DB: A0 00
  LDA ($00),Y                           ; $C9DD: B1 00
  STA $000B                             ; $C9DF: 8D 0B 00
  LDA #$01                              ; $C9E2: A9 01
  STA $000A                             ; $C9E4: 8D 0A 00
  LDA #$01                              ; $C9E7: A9 01
  STA $000C                             ; $C9E9: 8D 0C 00
  LDY #$3D                              ; $C9EC: A0 3D
  JSR $EE07                             ; $C9EE: 20 07 EE
; --- Data Region ---
  .byte $42,$A0,$AD,$A0,$04,$0D,$40,$01,$D0,$06,$20,$EE,$EC,$EE,$01,$04; $C9F1: 42 A0 AD A0 04 0D 40 01 D0 06 20 EE EC EE 01 04
Loc_CA01:
; --- Code Region ---
  RTS                                   ; $CA01: 60
Loc_CA02:
  LDA $050E                             ; $CA02: AD 0E 05
  JSR $CA0F                             ; $CA05: 20 0F CA
  LDA $003A                             ; $CA08: AD 3A 00
  JSR $CA0F                             ; $CA0B: 20 0F CA
  RTS                                   ; $CA0E: 60
Loc_CA0F:
  PHA                                   ; $CA0F: 48
  AND #$07                              ; $CA10: 29 07
  TAX                                   ; $CA12: AA
  PLA                                   ; $CA13: 68
  LSR                                   ; $CA14: 4A
  LSR                                   ; $CA15: 4A
  LSR                                   ; $CA16: 4A
  TAY                                   ; $CA17: A8
  LDA $04E0,Y                           ; $CA18: B9 E0 04
  ORA $CA22,X                           ; $CA1B: 1D 22 CA
  STA $04E0,Y                           ; $CA1E: 99 E0 04
  RTS                                   ; $CA21: 60
; --- Data Region ---
  .byte $01,$02,$04,$08,$10,$20,$40,$80   ; $CA22: 01 02 04 08 10 20 40 80
Loc_CA2A:
; --- Code Region ---
  LDA $003A                             ; $CA2A: AD 3A 00
  STA $000A                             ; $CA2D: 8D 0A 00
  LDY #$3B                              ; $CA30: A0 3B
  JSR $EE07                             ; $CA32: 20 07 EE
; --- Data Region ---
  .byte $09,$A0,$AD,$0B,$00,$29,$80,$49,$80,$8D,$50,$01,$60; $CA35: 09 A0 AD 0B 00 29 80 49 80 8D 50 01 60
Loc_CA42:  ; (dispatch callback target)
; --- Code Region ---
  JSR $CA02                             ; $CA42: 20 02 CA
  LDA $0087                             ; $CA45: AD 87 00
Loc_CA48:
  BPL $CA83                             ; $CA48: 10 39
  LDA #$03                              ; $CA4A: A9 03
  STA $007A                             ; $CA4C: 8D 7A 00
  LDA #$00                              ; $CA4F: A9 00
  STA $0510                             ; $CA51: 8D 10 05
  STA $0511                             ; $CA54: 8D 11 05
  STA $0512                             ; $CA57: 8D 12 05
  STA $0513                             ; $CA5A: 8D 13 05
  LDA #$0A                              ; $CA5D: A9 0A
  STA $0500                             ; $CA5F: 8D 00 05
  LDA #$00                              ; $CA62: A9 00
  STA $0501                             ; $CA64: 8D 01 05
  STA $0502                             ; $CA67: 8D 02 05
  STA $0503                             ; $CA6A: 8D 03 05
  LDA #$80                              ; $CA6D: A9 80
  STA $0504                             ; $CA6F: 8D 04 05
  LDA #$00                              ; $CA72: A9 00
  STA $0505                             ; $CA74: 8D 05 05
  LDA #$00                              ; $CA77: A9 00
  STA $0506                             ; $CA79: 8D 06 05
  LDY #$2C                              ; $CA7C: A0 2C
  JSR $EE07                             ; $CA7E: 20 07 EE
; --- Data Region ---
  .byte $03,$A0                           ; $CA81: 03 A0
Loc_CA83:
; --- Code Region ---
  RTS                                   ; $CA83: 60
Loc_CA84:  ; (dispatch callback target)
  JSR $CA02                             ; $CA84: 20 02 CA
  LDA $6F03                             ; $CA87: AD 03 6F
  JSR $F368                             ; $CA8A: 20 68 F3
  LDY #$00                              ; $CA8D: A0 00
  LDA ($00),Y                           ; $CA8F: B1 00
  STA $000B                             ; $CA91: 8D 0B 00
  LDA #$01                              ; $CA94: A9 01
  STA $000A                             ; $CA96: 8D 0A 00
  LDA #$01                              ; $CA99: A9 01
  STA $000C                             ; $CA9B: 8D 0C 00
  LDY #$3D                              ; $CA9E: A0 3D
  JSR $EE07                             ; $CAA0: 20 07 EE
; --- Data Region ---
  .byte $42,$A0,$AD,$A0,$04,$0D,$40,$01,$D0,$26; $CAA3: 42 A0 AD A0 04 0D 40 01 D0 26
Loc_CAAD:  ; (dispatch callback target)
; --- Code Region ---
  LDA $6F03                             ; $CAAD: AD 03 6F
  JSR $F368                             ; $CAB0: 20 68 F3
  LDY #$00                              ; $CAB3: A0 00
  LDA ($00),Y                           ; $CAB5: B1 00
  STA $000B                             ; $CAB7: 8D 0B 00
  LDA #$02                              ; $CABA: A9 02
  STA $000A                             ; $CABC: 8D 0A 00
  LDA #$00                              ; $CABF: A9 00
  STA $000C                             ; $CAC1: 8D 0C 00
  LDY #$3D                              ; $CAC4: A0 3D
  JSR $EE07                             ; $CAC6: 20 07 EE
; --- Data Region ---
  .byte $42,$A0,$A9,$05,$8D,$A0,$04,$EE,$01,$04; $CAC9: 42 A0 A9 05 8D A0 04 EE 01 04
Loc_CAD3:
; --- Code Region ---
  RTS                                   ; $CAD3: 60
Loc_CAD4:  ; (dispatch callback target)
  JSR $CA02                             ; $CAD4: 20 02 CA
  LDA $6F03                             ; $CAD7: AD 03 6F
  JSR $F368                             ; $CADA: 20 68 F3
  LDY #$00                              ; $CADD: A0 00
  LDA ($00),Y                           ; $CADF: B1 00
  STA $000B                             ; $CAE1: 8D 0B 00
  LDA #$01                              ; $CAE4: A9 01
  STA $000A                             ; $CAE6: 8D 0A 00
  LDA #$01                              ; $CAE9: A9 01
  STA $000C                             ; $CAEB: 8D 0C 00
  LDY #$3D                              ; $CAEE: A0 3D
  JSR $EE07                             ; $CAF0: 20 07 EE
; --- Data Region ---
  .byte $42,$A0,$AD,$A0,$04,$0D,$40,$01,$D0,$31,$AD,$07,$05,$AC,$8C,$6F; $CAF3: 42 A0 AD A0 04 0D 40 01 D0 31 AD 07 05 AC 8C 6F
  .byte $D0,$04,$4A,$4A,$4A,$4A           ; $CB03: D0 04 4A 4A 4A 4A
Loc_CB09:
; --- Code Region ---
  AND #$07                              ; $CB09: 29 07
  JSR $F368                             ; $CB0B: 20 68 F3
  LDY #$00                              ; $CB0E: A0 00
  LDA ($00),Y                           ; $CB10: B1 00
  STA $000B                             ; $CB12: 8D 0B 00
  LDA #$03                              ; $CB15: A9 03
  STA $000A                             ; $CB17: 8D 0A 00
  LDA #$00                              ; $CB1A: A9 00
  STA $000C                             ; $CB1C: 8D 0C 00
  LDY #$3D                              ; $CB1F: A0 3D
  JSR $EE07                             ; $CB21: 20 07 EE
; --- Data Region ---
  .byte $42,$A0,$A9,$06,$8D,$A0,$04,$EE,$01,$04; $CB24: 42 A0 A9 06 8D A0 04 EE 01 04
Loc_CB2E:
; --- Code Region ---
  RTS                                   ; $CB2E: 60
Loc_CB2F:  ; (dispatch callback target)
  JSR $CA02                             ; $CB2F: 20 02 CA
  LDA $0507                             ; $CB32: AD 07 05
  LDY $6F8C                             ; $CB35: AC 8C 6F
  BNE $CB3E                             ; $CB38: D0 04
  LSR                                   ; $CB3A: 4A
  LSR                                   ; $CB3B: 4A
  LSR                                   ; $CB3C: 4A
  LSR                                   ; $CB3D: 4A
Loc_CB3E:
  AND #$07                              ; $CB3E: 29 07
  JSR $F368                             ; $CB40: 20 68 F3
  LDY #$00                              ; $CB43: A0 00
  LDA ($00),Y                           ; $CB45: B1 00
  STA $000B                             ; $CB47: 8D 0B 00
  LDA #$01                              ; $CB4A: A9 01
  STA $000A                             ; $CB4C: 8D 0A 00
  LDA #$01                              ; $CB4F: A9 01
  STA $000C                             ; $CB51: 8D 0C 00
  LDY #$3D                              ; $CB54: A0 3D
  JSR $EE07                             ; $CB56: 20 07 EE
; --- Data Region ---
  .byte $42,$A0,$AD,$A0,$04,$0D,$40,$01,$D0,$CB,$A9,$BB,$20,$8B,$F2,$A0; $CB59: 42 A0 AD A0 04 0D 40 01 D0 CB A9 BB 20 8B F2 A0
  .byte $00,$B1,$EE,$8D,$2C,$04,$A9,$01,$8D,$01,$04,$A9,$00,$8D,$0C,$04; $CB69: 00 B1 EE 8D 2C 04 A9 01 8D 01 04 A9 00 8D 0C 04
  .byte $A9,$01,$8D,$8B,$6F,$60           ; $CB79: A9 01 8D 8B 6F 60
Loc_CB7F:  ; (dispatch callback target)
; --- Code Region ---
  INC $040C                             ; $CB7F: EE 0C 04
  LDA $040C                             ; $CB82: AD 0C 04
  CMP #$F0                              ; $CB85: C9 F0
  BCC $CB9C                             ; $CB87: 90 13
  LDA $0027                             ; $CB89: AD 27 00
  STA $042C                             ; $CB8C: 8D 2C 04
  LDA #$C2                              ; $CB8F: A9 C2
  JSR $F28B                             ; $CB91: 20 8B F2
  INC $0401                             ; $CB94: EE 01 04
  LDA #$00                              ; $CB97: A9 00
  STA $040C                             ; $CB99: 8D 0C 04
Loc_CB9C:
  RTS                                   ; $CB9C: 60
Loc_CB9D:  ; (dispatch callback target)
  INC $040C                             ; $CB9D: EE 0C 04
  LDA $040C                             ; $CBA0: AD 0C 04
  CMP #$F0                              ; $CBA3: C9 F0
  BCC $CBC2                             ; $CBA5: 90 1B
  LDA #$BB                              ; $CBA7: A9 BB
  JSR $F28B                             ; $CBA9: 20 8B F2
  LDY #$00                              ; $CBAC: A0 00
  LDA ($EE),Y                           ; $CBAE: B1 EE
  STA $042C                             ; $CBB0: 8D 2C 04
  LDA #$01                              ; $CBB3: A9 01
  STA $0401                             ; $CBB5: 8D 01 04
  LDA #$00                              ; $CBB8: A9 00
  STA $040C                             ; $CBBA: 8D 0C 04
  LDA #$01                              ; $CBBD: A9 01
  STA $6F8B                             ; $CBBF: 8D 8B 6F
Loc_CBC2:
  RTS                                   ; $CBC2: 60
Loc_CBC3:  ; (dispatch callback target)
  LDA $003D                             ; $CBC3: AD 3D 00
  STA $0000                             ; $CBC6: 8D 00 00
  LDA #$A7                              ; $CBC9: A9 A7
  STA $000A                             ; $CBCB: 8D 0A 00
  LDX #$00                              ; $CBCE: A2 00
  JSR $CE1F                             ; $CBD0: 20 1F CE
  LDA $0402                             ; $CBD3: AD 02 04
  JSR $EADE                             ; $CBD6: 20 DE EA
; --- Data Region ---
  .byte $DD,$CB,$0A,$CC                   ; $CBD9: DD CB 0A CC
Loc_CBDD:  ; (dispatch callback target)
; --- Code Region ---
  LDA $0300                             ; $CBDD: AD 00 03
  CMP #$FF                              ; $CBE0: C9 FF
  BNE $CC09                             ; $CBE2: D0 25
  LDA $0304                             ; $CBE4: AD 04 03
  CMP #$FF                              ; $CBE7: C9 FF
  BNE $CC09                             ; $CBE9: D0 1E
  JSR $A1C2                             ; $CBEB: 20 C2 A1
  LDA $0081                             ; $CBEE: AD 81 00
  AND #$03                              ; $CBF1: 29 03
  BEQ $CC09                             ; $CBF3: F0 14
  LDA $0043                             ; $CBF5: AD 43 00
  STA $042C                             ; $CBF8: 8D 2C 04
  LDA $0040                             ; $CBFB: AD 40 00
  STA $042D                             ; $CBFE: 8D 2D 04
  LDA #$E0                              ; $CC01: A9 E0
  JSR $F26D                             ; $CC03: 20 6D F2
  INC $0402                             ; $CC06: EE 02 04
Loc_CC09:
  RTS                                   ; $CC09: 60
Loc_CC0A:  ; (dispatch callback target)
  LDA $0300                             ; $CC0A: AD 00 03
  CMP #$FF                              ; $CC0D: C9 FF
  BNE $CC25                             ; $CC0F: D0 14
  LDA $0304                             ; $CC11: AD 04 03
  CMP #$FF                              ; $CC14: C9 FF
  BNE $CC25                             ; $CC16: D0 0D
  JSR $A1C2                             ; $CC18: 20 C2 A1
  LDA $0081                             ; $CC1B: AD 81 00
  AND #$03                              ; $CC1E: 29 03
  BEQ $CC25                             ; $CC20: F0 03
  JSR $CD6F                             ; $CC22: 20 6F CD
Loc_CC25:
  RTS                                   ; $CC25: 60
Loc_CC26:  ; (dispatch callback target)
  LDA $003D                             ; $CC26: AD 3D 00
  STA $0000                             ; $CC29: 8D 00 00
  LDA #$A7                              ; $CC2C: A9 A7
  STA $000A                             ; $CC2E: 8D 0A 00
  LDX #$00                              ; $CC31: A2 00
  JSR $CE1F                             ; $CC33: 20 1F CE
  LDA $0402                             ; $CC36: AD 02 04
  JSR $EADE                             ; $CC39: 20 DE EA
; --- Data Region ---
  .byte $40,$CC,$6D,$CC                   ; $CC3C: 40 CC 6D CC
Loc_CC40:  ; (dispatch callback target)
; --- Code Region ---
  LDA $0300                             ; $CC40: AD 00 03
  CMP #$FF                              ; $CC43: C9 FF
  BNE $CC6C                             ; $CC45: D0 25
  LDA $0304                             ; $CC47: AD 04 03
  CMP #$FF                              ; $CC4A: C9 FF
  BNE $CC6C                             ; $CC4C: D0 1E
  JSR $A1C2                             ; $CC4E: 20 C2 A1
  LDA $0081                             ; $CC51: AD 81 00
  AND #$03                              ; $CC54: 29 03
  BEQ $CC6C                             ; $CC56: F0 14
  LDA $0037                             ; $CC58: AD 37 00
  STA $042C                             ; $CC5B: 8D 2C 04
  LDA $0039                             ; $CC5E: AD 39 00
  STA $042D                             ; $CC61: 8D 2D 04
  LDA #$E1                              ; $CC64: A9 E1
  JSR $F26D                             ; $CC66: 20 6D F2
  INC $0402                             ; $CC69: EE 02 04
Loc_CC6C:
  RTS                                   ; $CC6C: 60
Loc_CC6D:  ; (dispatch callback target)
  LDA $0300                             ; $CC6D: AD 00 03
  CMP #$FF                              ; $CC70: C9 FF
  BNE $CC88                             ; $CC72: D0 14
  LDA $0304                             ; $CC74: AD 04 03
  CMP #$FF                              ; $CC77: C9 FF
  BNE $CC88                             ; $CC79: D0 0D
  JSR $A1C2                             ; $CC7B: 20 C2 A1
  LDA $0081                             ; $CC7E: AD 81 00
  AND #$03                              ; $CC81: 29 03
  BEQ $CC88                             ; $CC83: F0 03
  JSR $CD6F                             ; $CC85: 20 6F CD
Loc_CC88:
  RTS                                   ; $CC88: 60
Loc_CC89:  ; (dispatch callback target)
  LDA $0402                             ; $CC89: AD 02 04
  JSR $EADE                             ; $CC8C: 20 DE EA
; --- Data Region ---
  .byte $95,$CC,$D8,$CC,$53,$CD           ; $CC8F: 95 CC D8 CC 53 CD
Loc_CC95:  ; (dispatch callback target)
; --- Code Region ---
  LDA $0300                             ; $CC95: AD 00 03
  CMP #$FF                              ; $CC98: C9 FF
  BNE $CCD7                             ; $CC9A: D0 3B
  LDA $0304                             ; $CC9C: AD 04 03
  CMP #$FF                              ; $CC9F: C9 FF
  BNE $CCD7                             ; $CCA1: D0 34
  JSR $A1C2                             ; $CCA3: 20 C2 A1
  LDA $0081                             ; $CCA6: AD 81 00
  AND #$03                              ; $CCA9: 29 03
  BEQ $CCD7                             ; $CCAB: F0 2A
  LDA $0041                             ; $CCAD: AD 41 00
  STA $042C                             ; $CCB0: 8D 2C 04
  LDA #$E3                              ; $CCB3: A9 E3
  LDY $0039                             ; $CCB5: AC 39 00
  BEQ $CCBC                             ; $CCB8: F0 02
  LDA #$EE                              ; $CCBA: A9 EE
Loc_CCBC:
  JSR $F26D                             ; $CCBC: 20 6D F2
  INC $0402                             ; $CCBF: EE 02 04
  LDA #$00                              ; $CCC2: A9 00
  STA $0424                             ; $CCC4: 8D 24 04
  STA $0425                             ; $CCC7: 8D 25 04
  LDA $0042                             ; $CCCA: AD 42 00
  STA $0000                             ; $CCCD: 8D 00 00
  LDY #$3D                              ; $CCD0: A0 3D
  JSR $EE07                             ; $CCD2: 20 07 EE
; --- Data Region ---
  .byte $2A,$A0,$60,$AD,$42,$00,$8D,$00,$00,$A9,$A7,$8D,$0A,$00,$A2,$00; $CCD5: 2A A0 60 AD 42 00 8D 00 00 A9 A7 8D 0A 00 A2 00
  .byte $20,$1F,$CE,$A9,$46,$8D,$10,$00,$A9,$CD,$8D,$11,$00,$A9,$00,$8D; $CCE5: 20 1F CE A9 46 8D 10 00 A9 CD 8D 11 00 A9 00 8D
  .byte $12,$00,$20,$1E,$ED,$A9,$4A,$8D,$10,$00,$A9,$CD,$8D,$11,$00,$A9; $CCF5: 12 00 20 1E ED A9 4A 8D 10 00 A9 CD 8D 11 00 A9
  .byte $4E,$8D,$00,$00,$A9,$CD,$8D,$01,$00,$AD,$12,$00,$20,$F5,$ED,$AD; $CD05: 4E 8D 00 00 A9 CD 8D 01 00 AD 12 00 20 F5 ED AD
  .byte $00,$03,$C9,$FF,$D0,$2A,$AD,$04,$03,$C9,$FF,$D0,$23,$AD,$81,$00; $CD15: 00 03 C9 FF D0 2A AD 04 03 C9 FF D0 23 AD 81 00
  .byte $29,$03,$F0,$AE,$AD,$40,$00,$8D,$2C,$04,$EE,$02,$04,$AD,$12,$00; $CD25: 29 03 F0 AE AD 40 00 8D 2C 04 EE 02 04 AD 12 00
  .byte $8D,$0C,$04,$D0,$06,$A9,$E4,$20,$8B,$F2,$60; $CD35: 8D 0C 04 D0 06 A9 E4 20 8B F2 60
Loc_CD40:
; --- Code Region ---
  LDA #$E5                              ; $CD40: A9 E5
  JSR $F28B                             ; $CD42: 20 8B F2
Loc_CD45:
  RTS                                   ; $CD45: 60
; --- Data Region ---
  .byte $00,$01,$FF,$FF,$D6,$58,$D6,$98,$00,$07,$00,$00,$80; $CD46: 00 01 FF FF D6 58 D6 98 00 07 00 00 80
Loc_CD53:  ; (dispatch callback target)
; --- Code Region ---
  LDA $0300                             ; $CD53: AD 00 03
  CMP #$FF                              ; $CD56: C9 FF
  BNE $CD6E                             ; $CD58: D0 14
  LDA $0304                             ; $CD5A: AD 04 03
  CMP #$FF                              ; $CD5D: C9 FF
  BNE $CD6E                             ; $CD5F: D0 0D
  JSR $A1C2                             ; $CD61: 20 C2 A1
  LDA $0081                             ; $CD64: AD 81 00
  AND #$03                              ; $CD67: 29 03
  BEQ $CD6E                             ; $CD69: F0 03
  JSR $CD6F                             ; $CD6B: 20 6F CD
Loc_CD6E:
  RTS                                   ; $CD6E: 60
Loc_CD6F:
  LDA #$BB                              ; $CD6F: A9 BB
  JSR $F28B                             ; $CD71: 20 8B F2
  LDY #$00                              ; $CD74: A0 00
  LDA ($EE),Y                           ; $CD76: B1 EE
  STA $042C                             ; $CD78: 8D 2C 04
  LDA $040C                             ; $CD7B: AD 0C 04
  STA $6F8B                             ; $CD7E: 8D 8B 6F
  LDA #$01                              ; $CD81: A9 01
  STA $0401                             ; $CD83: 8D 01 04
  LDA #$00                              ; $CD86: A9 00
  STA $040C                             ; $CD88: 8D 0C 04
  RTS                                   ; $CD8B: 60
Loc_CD8C:
  LDA $FFF9                             ; $CD8C: AD F9 FF
  CMP #$FF                              ; $CD8F: C9 FF
  BNE $CDDC                             ; $CD91: D0 49
  LDA $0083                             ; $CD93: AD 83 00
  AND #$08                              ; $CD96: 29 08
  BEQ $CDDC                             ; $CD98: F0 42
  LDA $0081                             ; $CD9A: AD 81 00
  AND #$01                              ; $CD9D: 29 01
  BEQ $CDDC                             ; $CD9F: F0 3B
  LDA #$62                              ; $CDA1: A9 62
  JSR $E693                             ; $CDA3: 20 93 E6
  LDA $6FE2                             ; $CDA6: AD E2 6F
  CMP #$FF                              ; $CDA9: C9 FF
  BEQ $CDDD                             ; $CDAB: F0 30
  LDA $6FE2                             ; $CDAD: AD E2 6F
  STA $6F0A                             ; $CDB0: 8D 0A 6F
  LDA $6FE3                             ; $CDB3: AD E3 6F
  STA $6F12                             ; $CDB6: 8D 12 6F
  LDA $6FE4                             ; $CDB9: AD E4 6F
  STA $6F1A                             ; $CDBC: 8D 1A 6F
  LDA $6FE5                             ; $CDBF: AD E5 6F
  STA $6F22                             ; $CDC2: 8D 22 6F
  LDA $6FE6                             ; $CDC5: AD E6 6F
  STA $6F2A                             ; $CDC8: 8D 2A 6F
  LDA $6FE7                             ; $CDCB: AD E7 6F
  STA $6F32                             ; $CDCE: 8D 32 6F
  LDA $6FE8                             ; $CDD1: AD E8 6F
  STA $6F3A                             ; $CDD4: 8D 3A 6F
  LDA #$FF                              ; $CDD7: A9 FF
  STA $6FE2                             ; $CDD9: 8D E2 6F
Loc_CDDC:
  RTS                                   ; $CDDC: 60
Loc_CDDD:
  LDA $6F0A                             ; $CDDD: AD 0A 6F
  STA $6FE2                             ; $CDE0: 8D E2 6F
  LDA $6F12                             ; $CDE3: AD 12 6F
  STA $6FE3                             ; $CDE6: 8D E3 6F
  LDA $6F1A                             ; $CDE9: AD 1A 6F
  STA $6FE4                             ; $CDEC: 8D E4 6F
  LDA $6F22                             ; $CDEF: AD 22 6F
  STA $6FE5                             ; $CDF2: 8D E5 6F
  LDA $6F2A                             ; $CDF5: AD 2A 6F
  STA $6FE6                             ; $CDF8: 8D E6 6F
  LDA $6F32                             ; $CDFB: AD 32 6F
  STA $6FE7                             ; $CDFE: 8D E7 6F
  LDA $6F3A                             ; $CE01: AD 3A 6F
  STA $6FE8                             ; $CE04: 8D E8 6F
  LDA #$03                              ; $CE07: A9 03
  STA $6F0A                             ; $CE09: 8D 0A 6F
  STA $6F12                             ; $CE0C: 8D 12 6F
  STA $6F1A                             ; $CE0F: 8D 1A 6F
  STA $6F22                             ; $CE12: 8D 22 6F
  STA $6F2A                             ; $CE15: 8D 2A 6F
  STA $6F32                             ; $CE18: 8D 32 6F
  STA $6F3A                             ; $CE1B: 8D 3A 6F
  RTS                                   ; $CE1E: 60
Loc_CE1F:
  LDA $6FEA                             ; $CE1F: AD EA 6F
  AND #$04                              ; $CE22: 29 04
  BEQ $CE2B                             ; $CE24: F0 05
  LDA #$03                              ; $CE26: A9 03
  STA $00A4                             ; $CE28: 8D A4 00
Loc_CE2B:
  LDA $6FEA                             ; $CE2B: AD EA 6F
  AND #$08                              ; $CE2E: 29 08
  BEQ $CE37                             ; $CE30: F0 05
  LDA #$04                              ; $CE32: A9 04
  STA $00A4                             ; $CE34: 8D A4 00
Loc_CE37:
  LDY #$21                              ; $CE37: A0 21
  JSR $F25F                             ; $CE39: 20 5F F2
  LDA $0000                             ; $CE3C: AD 00 00
  TAY                                   ; $CE3F: A8
  TXA                                   ; $CE40: 8A
  AND #$01                              ; $CE41: 29 01
  BEQ $CE53                             ; $CE43: F0 0E
  LDA #$40                              ; $CE45: A9 40
  STA $0003                             ; $CE47: 8D 03 00
  LDA $CED6,Y                           ; $CE4A: B9 D6 CE
  STA $00B9                             ; $CE4D: 8D B9 00
  JMP $CE5E                             ; $CE50: 4C 5E CE
Loc_CE53:
  LDA #$00                              ; $CE53: A9 00
  STA $0003                             ; $CE55: 8D 03 00
  LDA $CED6,Y                           ; $CE58: B9 D6 CE
  STA $00B8                             ; $CE5B: 8D B8 00
Loc_CE5E:
  LDA #$00                              ; $CE5E: A9 00
  STA $0005                             ; $CE60: 8D 05 00
  LDA $00A4                             ; $CE63: AD A4 00
  AND #$07                              ; $CE66: 29 07
  CLC                                   ; $CE68: 18
  ADC $99A0,Y                           ; $CE69: 79 A0 99
  ASL                                   ; $CE6C: 0A
  PHA                                   ; $CE6D: 48
  TAY                                   ; $CE6E: A8
  LDA $9AA0,Y                           ; $CE6F: B9 A0 9A
  STA $0000                             ; $CE72: 8D 00 00
  LDA $9AA1,Y                           ; $CE75: B9 A1 9A
  STA $0001                             ; $CE78: 8D 01 00
  LDA $04BC                             ; $CE7B: AD BC 04
  BNE $CE82                             ; $CE7E: D0 02
  LDA #$10                              ; $CE80: A9 10
Loc_CE82:
  STA $000C                             ; $CE82: 8D 0C 00
  LDA #$00                              ; $CE85: A9 00
  STA $0002                             ; $CE87: 8D 02 00
  LDA #$A0                              ; $CE8A: A9 A0
  STA $0004                             ; $CE8C: 8D 04 00
  JSR $F1B7                             ; $CE8F: 20 B7 F1
  LDA #$00                              ; $CE92: A9 00
  STA $04BC                             ; $CE94: 8D BC 04
  PLA                                   ; $CE97: 68
  TAY                                   ; $CE98: A8
  LDA $00A4                             ; $CE99: AD A4 00
  BMI $CEB8                             ; $CE9C: 30 1A
  LDA $007E                             ; $CE9E: AD 7E 00
  AND #$01                              ; $CEA1: 29 01
  BEQ $CEB8                             ; $CEA3: F0 13
  LDA $0304                             ; $CEA5: AD 04 03
  CMP #$FF                              ; $CEA8: C9 FF
  BEQ $CEB8                             ; $CEAA: F0 0C
  LDA $0303                             ; $CEAC: AD 03 03
  BNE $CEB8                             ; $CEAF: D0 07
  LDA $005E                             ; $CEB1: AD 5E 00
  AND #$08                              ; $CEB4: 29 08
  BNE $CEC7                             ; $CEB6: D0 0F
Loc_CEB8:
  LDA $9BAC,Y                           ; $CEB8: B9 AC 9B
  STA $0000                             ; $CEBB: 8D 00 00
  LDA $9BAD,Y                           ; $CEBE: B9 AD 9B
  STA $0001                             ; $CEC1: 8D 01 00
  JMP $F1B7                             ; $CEC4: 4C B7 F1
Loc_CEC7:
  LDA $9D64,Y                           ; $CEC7: B9 64 9D
  STA $0000                             ; $CECA: 8D 00 00
  LDA $9D65,Y                           ; $CECD: B9 65 9D
  STA $0001                             ; $CED0: 8D 01 00
  JMP $F1B7                             ; $CED3: 4C B7 F1
; --- Data Region ---
  .byte $40,$37,$4E,$20,$52,$41,$4F,$4F,$18,$1B,$33,$46,$4C,$9F,$46,$2C; $CED6: 40 37 4E 20 52 41 4F 4F 18 1B 33 46 4C 9F 46 2C
  .byte $3D,$46,$39,$DB                   ; $CEE6: 3D 46 39 DB
Loc_CEEA:
; --- Code Region ---
  RLA $394A,X                           ; $CEEA: 3F 4A 39
  NOP                                   ; $CEED: 3A
  RLA $503F,Y                           ; $CEEE: 3B 3F 50
  NOP $3F                               ; $CEF1: 44 3F
  NOP                                   ; $CEF3: 3A
  SRE ($26),Y                           ; $CEF4: 53 26
  AND $5135,X                           ; $CEF6: 3D 35 51
  AND ($20),Y                           ; $CEF9: 31 20
  NOP $4219,X                           ; $CEFB: 1C 19 42
  AND ($1C),Y                           ; $CEFE: 31 1C
  AND ($36,X)                           ; $CF00: 21 36
  RLA $5134                             ; $CF02: 2F 34 51
  ORA $3022,X                           ; $CF05: 1D 22 30
  LSR                                   ; $CF08: 4A
  ANC #$36                              ; $CF09: 2B 36
  ROL $50                               ; $CF0B: 26 50
  RLA $23                               ; $CF0D: 27 23
  SRE ($50),Y                           ; $CF0F: 53 50
  EOR ($1B),Y                           ; $CF11: 51 1B
  ASL $1D24,X                           ; $CF13: 1E 24 1D
  AND $214A                             ; $CF16: 2D 4A 21
  ROL $3828                             ; $CF19: 2E 28 38
  RLA $383A,Y                           ; $CF1C: 3B 3A 38
  SEC                                   ; $CF1F: 38
  AND $1C,X                             ; $CF20: 35 1C
  AND ($2B),Y                           ; $CF22: 31 2B
  EOR #$37                              ; $CF24: 49 37
  AND $2D41,X                           ; $CF26: 3D 41 2D
  JSR $264F                             ; $CF29: 20 4F 26
  BMI $CF60                             ; $CF2C: 30 32
  SEC                                   ; $CF2E: 38
  JAM                                   ; $CF2F: 42
  EOR $24                               ; $CF30: 45 24
  JSR $4821                             ; $CF32: 20 21 48
  ASL $3A22,X                           ; $CF35: 1E 22 3A
  SRE ($1A,X)                           ; $CF38: 43 1A
  EOR $3C                               ; $CF3A: 45 3C
  SLO $483F,X                           ; $CF3C: 1F 3F 48
  PHA                                   ; $CF3F: 48
  EOR $47                               ; $CF40: 45 47
  BIT $49                               ; $CF42: 24 49
  ALR #$3C                              ; $CF44: 4B 3C
  LSR $3B31                             ; $CF46: 4E 31 3B
  BMI $CEEA                             ; $CF49: 30 9F
  AND #$32                              ; $CF4B: 29 32
  EOR #$26                              ; $CF4D: 49 26
  AND $4A                               ; $CF4F: 25 4A
  SRE $3821                             ; $CF51: 4F 21 38
  PHA                                   ; $CF54: 48
  NOP $3A1D,X                           ; $CF55: 1C 1D 3A
  AND $18,X                             ; $CF58: 35 18
  LSR $2523                             ; $CF5A: 4E 23 25
  NOP $1B43,X                           ; $CF5D: 3C 43 1B
Loc_CF60:
  ALR #$2A                              ; $CF60: 4B 2A
  ROL $424D                             ; $CF62: 2E 4D 42
  BMI $CF81                             ; $CF65: 30 1A
  JAM                                   ; $CF67: 42
  JAM                                   ; $CF68: 32
  NOP $3E                               ; $CF69: 44 3E
  EOR $2D                               ; $CF6B: 45 2D
  PLP                                   ; $CF6D: 28
  SRE $4D1A                             ; $CF6E: 4F 1A 4D
  AND $33,X                             ; $CF71: 35 33
  ROL $2A,X                             ; $CF73: 36 2A
  ASL $4322,X                           ; $CF75: 1E 22 43
  NOP $34,X                             ; $CF78: 34 34
  AND $4D                               ; $CF7A: 25 4D
  RLA $29,X                             ; $CF7C: 37 29
  SLO $4C52,X                           ; $CF7E: 1F 52 4C
Loc_CF81:
  JSR $4740                             ; $CF81: 20 40 47
  EOR ($53),Y                           ; $CF84: 51 53
  RLA $4A46                             ; $CF86: 2F 46 4A
  ROL $222A                             ; $CF89: 2E 2A 22
  ORA $3728,Y                           ; $CF8C: 19 28 37
  RLA $3337                             ; $CF8F: 2F 37 33
  AND $343B                             ; $CF92: 2D 3B 34
  ANC #$40                              ; $CF95: 2B 40
  JAM                                   ; $CF97: 52
  AND $24                               ; $CF98: 25 24
  BIT $2C29                             ; $CF9A: 2C 29 2C
  SEC                                   ; $CF9D: 38
  ROL                                   ; $CF9E: 2A
  RLA $1E                               ; $CF9F: 27 1E
  JAM                                   ; $CFA1: 42
  AND $20                               ; $CFA2: 25 20
  JMP $3E3D                             ; $CFA4: 4C 3D 3E
; --- Data Region ---
  .byte $39,$42,$26,$43,$2F,$41,$3E,$27,$52,$4B,$3E,$19,$1F,$18,$2F,$23; $CFA7: 39 42 26 43 2F 41 3E 27 52 4B 3E 19 1F 18 2F 23
  .byte $44,$3D,$2E,$DB,$3C,$35,$31,$3E,$4C,$1E,$1F,$30,$00,$00,$00,$41; $CFB7: 44 3D 2E DB 3C 35 31 3E 4C 1E 1F 30 00 00 00 41
  .byte $41,$41,$41,$42,$42,$42,$42,$43,$43,$43,$43,$44,$44,$44,$44; $CFC7: 41 41 41 42 42 42 42 43 43 43 43 44 44 44 44
Loc_CFD6:
; --- Code Region ---
  LDA $04C8                             ; $CFD6: AD C8 04
  BNE $CFDC                             ; $CFD9: D0 01
Loc_CFDB:
  RTS                                   ; $CFDB: 60
Loc_CFDC:
  LDA $0300                             ; $CFDC: AD 00 03
  CMP #$FF                              ; $CFDF: C9 FF
  BNE $CFDB                             ; $CFE1: D0 F8
  LDA $0304                             ; $CFE3: AD 04 03
  CMP #$FF                              ; $CFE6: C9 FF
  BNE $CFDB                             ; $CFE8: D0 F1
  LDA $04C8                             ; $CFEA: AD C8 04
  BMI $D007                             ; $CFED: 30 18
  STA $04C9                             ; $CFEF: 8D C9 04
  DEC $04C9                             ; $CFF2: CE C9 04
  LDA #$00                              ; $CFF5: A9 00
  STA $04CA                             ; $CFF7: 8D CA 04
  LDA #$80                              ; $CFFA: A9 80
  STA $04C8                             ; $CFFC: 8D C8 04
Loc_CFFF:
  LDA #$07                              ; $CFFF: A9 07
  STA $04D1                             ; $D001: 8D D1 04
Loc_D004:  ; (dispatch callback target)
  JMP $D41F                             ; $D004: 4C 1F D4
Loc_D007:
  AND #$0F                              ; $D007: 29 0F
  JSR $EADE                             ; $D009: 20 DE EA
; --- Data Region ---
  .byte $1F,$D4,$10,$D0,$EE,$D0,$04,$20,$EA,$D2,$AD; $D00C: 1F D4 10 D0 EE D0 04 20 EA D2 AD
Loc_D017:
; --- Code Region ---
  CMP #$04                              ; $D017: C9 04
  ASL                                   ; $D019: 0A
  TAY                                   ; $D01A: A8
  LDA $D85F,Y                           ; $D01B: B9 5F D8
  STA $0010                             ; $D01E: 8D 10 00
  INY                                   ; $D021: C8
  LDA $D85F,Y                           ; $D022: B9 5F D8
  STA $0011                             ; $D025: 8D 11 00
  INC $04CD                             ; $D028: EE CD 04
  INC $04CE                             ; $D02B: EE CE 04
  LDA $04C9                             ; $D02E: AD C9 04
  JSR $EADE                             ; $D031: 20 DE EA
  LSR                                   ; $D034: 4A
; --- Data Region ---
  .byte $D0,$7C,$D0,$B8,$D0,$F5,$D0,$32,$D1,$8C,$D1,$C3,$D1,$06,$D2,$32; $D035: D0 7C D0 B8 D0 F5 D0 32 D1 8C D1 C3 D1 06 D2 32
  .byte $D2,$63,$D2,$94,$D2,$AD,$CA,$04,$D0,$0F,$A9,$FB,$8D,$BE,$00,$8D; $D045: D2 63 D2 94 D2 AD CA 04 D0 0F A9 FB 8D BE 00 8D
  .byte $C6,$00,$8D,$CE,$00,$EE,$CA,$04,$60; $D055: C6 00 8D CE 00 EE CA 04 60
Loc_D05E:
; --- Code Region ---
  LDY $04CA                             ; $D05E: AC CA 04
  JSR $D2C9                             ; $D061: 20 C9 D2
  LDA $04CD                             ; $D064: AD CD 04
  LSR                                   ; $D067: 4A
  LSR                                   ; $D068: 4A
  LSR                                   ; $D069: 4A
  LSR                                   ; $D06A: 4A
  AND #$03                              ; $D06B: 29 03
  CMP #$03                              ; $D06D: C9 03
Loc_D06F:
  BNE $D073                             ; $D06F: D0 02
  LDA #$01                              ; $D071: A9 01
Loc_D073:
  STA $04CA                             ; $D073: 8D CA 04
  INC $04CA                             ; $D076: EE CA 04
  JMP $D3A3                             ; $D079: 4C A3 D3
Loc_D07C:  ; (dispatch callback target)
  LDA $04CA                             ; $D07C: AD CA 04
  CMP $04CB                             ; $D07F: CD CB 04
  BNE $D092                             ; $D082: D0 0E
  LDA $04CD                             ; $D084: AD CD 04
  LSR                                   ; $D087: 4A
  LSR                                   ; $D088: 4A
  LSR                                   ; $D089: 4A
  AND #$03                              ; $D08A: 29 03
  STA $04CA                             ; $D08C: 8D CA 04
  JMP $D0A9                             ; $D08F: 4C A9 D0
Loc_D092:
  STA $04CB                             ; $D092: 8D CB 04
  ASL                                   ; $D095: 0A
  CLC                                   ; $D096: 18
  ADC $04CA                             ; $D097: 6D CA 04
  TAY                                   ; $D09A: A8
  LDX #$0D                              ; $D09B: A2 0D
Loc_D09D:
  LDA $D0AC,Y                           ; $D09D: B9 AC D0
  STA $0100,X                           ; $D0A0: 9D 00 01
  INY                                   ; $D0A3: C8
  INX                                   ; $D0A4: E8
  CPX #$10                              ; $D0A5: E0 10
  BCC $D09D                             ; $D0A7: 90 F4
Loc_D0A9:
  JMP $D3A3                             ; $D0A9: 4C A3 D3
; --- Data Region ---
  .byte $16,$26,$27,$26,$27,$26,$27       ; $D0AC: 16 26 27 26 27 26 27
Loc_D0B3:
; --- Code Region ---
  ROL $16                               ; $D0B3: 26 16
  ROL $16                               ; $D0B5: 26 16
  ROL $AD                               ; $D0B7: 26 AD
  DEX                                   ; $D0B9: CA
  NOP $D0                               ; $D0BA: 04 D0
  NOP                                   ; $D0BC: 1A
  LDA #$FC                              ; $D0BD: A9 FC
  STA $00BE                             ; $D0BF: 8D BE 00
  STA $00C6                             ; $D0C2: 8D C6 00
  STA $00CE                             ; $D0C5: 8D CE 00
  LDA #$FE                              ; $D0C8: A9 FE
  STA $00BF                             ; $D0CA: 8D BF 00
  STA $00C7                             ; $D0CD: 8D C7 00
  STA $00CF                             ; $D0D0: 8D CF 00
  INC $04CA                             ; $D0D3: EE CA 04
  RTS                                   ; $D0D6: 60
Loc_D0D7:
  LDY $04CA                             ; $D0D7: AC CA 04
  JSR $D2C9                             ; $D0DA: 20 C9 D2
  LDA $04CD                             ; $D0DD: AD CD 04
  LSR                                   ; $D0E0: 4A
  LSR                                   ; $D0E1: 4A
  LSR                                   ; $D0E2: 4A
  LSR                                   ; $D0E3: 4A
  AND #$03                              ; $D0E4: 29 03
  CMP #$03                              ; $D0E6: C9 03
  BNE $D0EC                             ; $D0E8: D0 02
  LDA #$01                              ; $D0EA: A9 01
Loc_D0EC:
  STA $04CA                             ; $D0EC: 8D CA 04
  INC $04CA                             ; $D0EF: EE CA 04
  JMP $D3A3                             ; $D0F2: 4C A3 D3
Loc_D0F5:  ; (dispatch callback target)
  LDA $04CA                             ; $D0F5: AD CA 04
  BNE $D114                             ; $D0F8: D0 1A
  LDA #$F0                              ; $D0FA: A9 F0
  STA $00BE                             ; $D0FC: 8D BE 00
  STA $00C6                             ; $D0FF: 8D C6 00
  STA $00CE                             ; $D102: 8D CE 00
  LDA #$F2                              ; $D105: A9 F2
  STA $00BF                             ; $D107: 8D BF 00
  STA $00C7                             ; $D10A: 8D C7 00
  STA $00CF                             ; $D10D: 8D CF 00
  INC $04CA                             ; $D110: EE CA 04
  RTS                                   ; $D113: 60
Loc_D114:
  LDY $04CA                             ; $D114: AC CA 04
  JSR $D2C9                             ; $D117: 20 C9 D2
  LDA $04CD                             ; $D11A: AD CD 04
  LSR                                   ; $D11D: 4A
  LSR                                   ; $D11E: 4A
  LSR                                   ; $D11F: 4A
  LSR                                   ; $D120: 4A
  AND #$03                              ; $D121: 29 03
  CMP #$03                              ; $D123: C9 03
  BNE $D129                             ; $D125: D0 02
  LDA #$01                              ; $D127: A9 01
Loc_D129:
  STA $04CA                             ; $D129: 8D CA 04
  INC $04CA                             ; $D12C: EE CA 04
  JMP $D3A3                             ; $D12F: 4C A3 D3
Loc_D132:  ; (dispatch callback target)
  LDA $04CA                             ; $D132: AD CA 04
  BNE $D165                             ; $D135: D0 2E
  LDA #$EC                              ; $D137: A9 EC
  STA $00BE                             ; $D139: 8D BE 00
  STA $00C6                             ; $D13C: 8D C6 00
  STA $00CE                             ; $D13F: 8D CE 00
  LDA #$ED                              ; $D142: A9 ED
  STA $00BF                             ; $D144: 8D BF 00
  STA $00C7                             ; $D147: 8D C7 00
  STA $00CF                             ; $D14A: 8D CF 00
  LDA #$27                              ; $D14D: A9 27
  STA $0101                             ; $D14F: 8D 01 01
  LDA #$19                              ; $D152: A9 19
  STA $0102                             ; $D154: 8D 02 01
  LDA #$0A                              ; $D157: A9 0A
  STA $0103                             ; $D159: 8D 03 01
  INC $04CA                             ; $D15C: EE CA 04
  LDA #$03                              ; $D15F: A9 03
  STA $04CB                             ; $D161: 8D CB 04
  RTS                                   ; $D164: 60
Loc_D165:
  LDY $04CA                             ; $D165: AC CA 04
  JSR $D2C9                             ; $D168: 20 C9 D2
  LDY $04CB                             ; $D16B: AC CB 04
  JSR $D2C9                             ; $D16E: 20 C9 D2
  LDA $04CD                             ; $D171: AD CD 04
  CMP #$40                              ; $D174: C9 40
  BNE $D180                             ; $D176: D0 08
  LDA #$02                              ; $D178: A9 02
  STA $04CA                             ; $D17A: 8D CA 04
  JMP $D189                             ; $D17D: 4C 89 D1
Loc_D180:
  CMP #$60                              ; $D180: C9 60
  BNE $D189                             ; $D182: D0 05
  LDA #$04                              ; $D184: A9 04
  STA $04CB                             ; $D186: 8D CB 04
Loc_D189:
  JMP $D3A3                             ; $D189: 4C A3 D3
Loc_D18C:  ; (dispatch callback target)
  LDA $04CA                             ; $D18C: AD CA 04
  BNE $D1AB                             ; $D18F: D0 1A
  LDA #$E5                              ; $D191: A9 E5
  STA $00BE                             ; $D193: 8D BE 00
  STA $00C6                             ; $D196: 8D C6 00
  STA $00CE                             ; $D199: 8D CE 00
  LDA #$E5                              ; $D19C: A9 E5
  STA $00BF                             ; $D19E: 8D BF 00
  STA $00C7                             ; $D1A1: 8D C7 00
  STA $00CF                             ; $D1A4: 8D CF 00
  INC $04CA                             ; $D1A7: EE CA 04
  RTS                                   ; $D1AA: 60
Loc_D1AB:
  LDY $04CA                             ; $D1AB: AC CA 04
  JSR $D2C9                             ; $D1AE: 20 C9 D2
  LDA $04CD                             ; $D1B1: AD CD 04
  LSR                                   ; $D1B4: 4A
  LSR                                   ; $D1B5: 4A
  LSR                                   ; $D1B6: 4A
  LSR                                   ; $D1B7: 4A
  AND #$01                              ; $D1B8: 29 01
  CLC                                   ; $D1BA: 18
  ADC #$01                              ; $D1BB: 69 01
  STA $04CA                             ; $D1BD: 8D CA 04
  JMP $D3A3                             ; $D1C0: 4C A3 D3
Loc_D1C3:  ; (dispatch callback target)
  LDA $04CA                             ; $D1C3: AD CA 04
  BNE $D1DC                             ; $D1C6: D0 14
  LDA #$EF                              ; $D1C8: A9 EF
  STA $00BE                             ; $D1CA: 8D BE 00
  STA $00C6                             ; $D1CD: 8D C6 00
  STA $00CE                             ; $D1D0: 8D CE 00
  INC $04CA                             ; $D1D3: EE CA 04
  LDA #$03                              ; $D1D6: A9 03
  STA $04CB                             ; $D1D8: 8D CB 04
  RTS                                   ; $D1DB: 60
Loc_D1DC:
  LDY $04CA                             ; $D1DC: AC CA 04
  JSR $D2C9                             ; $D1DF: 20 C9 D2
  LDY $04CB                             ; $D1E2: AC CB 04
  JSR $D2C9                             ; $D1E5: 20 C9 D2
  LDA $04CD                             ; $D1E8: AD CD 04
  CMP #$60                              ; $D1EB: C9 60
  BNE $D1F4                             ; $D1ED: D0 05
  LDA #$02                              ; $D1EF: A9 02
  STA $04CA                             ; $D1F1: 8D CA 04
Loc_D1F4:
  LDA $04CD                             ; $D1F4: AD CD 04
  LSR                                   ; $D1F7: 4A
  LSR                                   ; $D1F8: 4A
  LSR                                   ; $D1F9: 4A
  LSR                                   ; $D1FA: 4A
  AND #$01                              ; $D1FB: 29 01
  CLC                                   ; $D1FD: 18
  ADC #$03                              ; $D1FE: 69 03
  STA $04CB                             ; $D200: 8D CB 04
  JMP $D3A3                             ; $D203: 4C A3 D3
Loc_D206:  ; (dispatch callback target)
  LDA $04CA                             ; $D206: AD CA 04
  BNE $D21A                             ; $D209: D0 0F
  LDA #$BB                              ; $D20B: A9 BB
  STA $00BF                             ; $D20D: 8D BF 00
  STA $00C7                             ; $D210: 8D C7 00
  STA $00CF                             ; $D213: 8D CF 00
  INC $04CA                             ; $D216: EE CA 04
  RTS                                   ; $D219: 60
Loc_D21A:
  LDY $04CA                             ; $D21A: AC CA 04
  JSR $D2C9                             ; $D21D: 20 C9 D2
  LDA $04CD                             ; $D220: AD CD 04
  LSR                                   ; $D223: 4A
  LSR                                   ; $D224: 4A
  LSR                                   ; $D225: 4A
  LSR                                   ; $D226: 4A
  AND #$01                              ; $D227: 29 01
  CLC                                   ; $D229: 18
  ADC #$01                              ; $D22A: 69 01
  STA $04CA                             ; $D22C: 8D CA 04
  JMP $D3A3                             ; $D22F: 4C A3 D3
Loc_D232:  ; (dispatch callback target)
  LDA $04CA                             ; $D232: AD CA 04
  BNE $D246                             ; $D235: D0 0F
  LDA #$B9                              ; $D237: A9 B9
  STA $00BF                             ; $D239: 8D BF 00
  STA $00C7                             ; $D23C: 8D C7 00
  STA $00CF                             ; $D23F: 8D CF 00
  INC $04CA                             ; $D242: EE CA 04
  RTS                                   ; $D245: 60
Loc_D246:
  LDY $04CA                             ; $D246: AC CA 04
  JSR $D2C9                             ; $D249: 20 C9 D2
  LDA $04CD                             ; $D24C: AD CD 04
  LSR                                   ; $D24F: 4A
  LSR                                   ; $D250: 4A
  LSR                                   ; $D251: 4A
  AND #$03                              ; $D252: 29 03
  CMP #$03                              ; $D254: C9 03
  BNE $D25A                             ; $D256: D0 02
  LDA #$01                              ; $D258: A9 01
Loc_D25A:
  STA $04CA                             ; $D25A: 8D CA 04
  INC $04CA                             ; $D25D: EE CA 04
  JMP $D3A3                             ; $D260: 4C A3 D3
Loc_D263:  ; (dispatch callback target)
  LDA $04CA                             ; $D263: AD CA 04
  BNE $D277                             ; $D266: D0 0F
  LDA #$D8                              ; $D268: A9 D8
  STA $00BF                             ; $D26A: 8D BF 00
  STA $00C7                             ; $D26D: 8D C7 00
  STA $00CF                             ; $D270: 8D CF 00
  INC $04CA                             ; $D273: EE CA 04
  RTS                                   ; $D276: 60
Loc_D277:
  LDY $04CA                             ; $D277: AC CA 04
  JSR $D2C9                             ; $D27A: 20 C9 D2
  LDA $04CD                             ; $D27D: AD CD 04
  LSR                                   ; $D280: 4A
  LSR                                   ; $D281: 4A
  LSR                                   ; $D282: 4A
  AND #$03                              ; $D283: 29 03
  CMP #$03                              ; $D285: C9 03
  BNE $D28B                             ; $D287: D0 02
  LDA #$01                              ; $D289: A9 01
Loc_D28B:
  STA $04CA                             ; $D28B: 8D CA 04
  INC $04CA                             ; $D28E: EE CA 04
  JMP $D3A3                             ; $D291: 4C A3 D3
Loc_D294:  ; (dispatch callback target)
  LDA $04CA                             ; $D294: AD CA 04
  BNE $D2AF                             ; $D297: D0 16
  LDA #$E3                              ; $D299: A9 E3
  STA $00BF                             ; $D29B: 8D BF 00
  STA $00C7                             ; $D29E: 8D C7 00
  STA $00CF                             ; $D2A1: 8D CF 00
  LDA #$10                              ; $D2A4: A9 10
  STA $04CA                             ; $D2A6: 8D CA 04
  LDA #$10                              ; $D2A9: A9 10
  STA $04CB                             ; $D2AB: 8D CB 04
  RTS                                   ; $D2AE: 60
Loc_D2AF:
  LDY #$01                              ; $D2AF: A0 01
  LDX $04CB                             ; $D2B1: AE CB 04
  JSR $D2CB                             ; $D2B4: 20 CB D2
  LDA $04CD                             ; $D2B7: AD CD 04
  LSR                                   ; $D2BA: 4A
  LSR                                   ; $D2BB: 4A
  LSR                                   ; $D2BC: 4A
  AND #$01                              ; $D2BD: 29 01
  CLC                                   ; $D2BF: 18
  ADC $04CA                             ; $D2C0: 6D CA 04
  STA $04CB                             ; $D2C3: 8D CB 04
  JMP $D3A3                             ; $D2C6: 4C A3 D3
Loc_D2C9:
  LDX #$10                              ; $D2C9: A2 10
Loc_D2CB:
  STX $000C                             ; $D2CB: 8E 0C 00
  DEY                                   ; $D2CE: 88
  TYA                                   ; $D2CF: 98
  ASL                                   ; $D2D0: 0A
  TAY                                   ; $D2D1: A8
  LDA ($10),Y                           ; $D2D2: B1 10
  STA $0000                             ; $D2D4: 8D 00 00
  INY                                   ; $D2D7: C8
  LDA ($10),Y                           ; $D2D8: B1 10
  STA $0001                             ; $D2DA: 8D 01 00
  LDA #$40                              ; $D2DD: A9 40
  STA $000A                             ; $D2DF: 8D 0A 00
  LDA #$03                              ; $D2E2: A9 03
  STA $0002                             ; $D2E4: 8D 02 00
  JMP $F1AD                             ; $D2E7: 4C AD F1
Loc_D2EA:
  LDY #$31                              ; $D2EA: A0 31
  JSR $F25F                             ; $D2EC: 20 5F F2
  LDA #$00                              ; $D2EF: A9 00
  STA $0001                             ; $D2F1: 8D 01 00
  LDY $0509                             ; $D2F4: AC 09 05
  LDA $0664,Y                           ; $D2F7: B9 64 06
  ASL                                   ; $D2FA: 0A
  ROL $0001                             ; $D2FB: 2E 01 00
  ASL                                   ; $D2FE: 0A
  ROL $0001                             ; $D2FF: 2E 01 00
  STA $0000                             ; $D302: 8D 00 00
  LDA $0001                             ; $D305: AD 01 00
  STA $0002                             ; $D308: 8D 02 00
  LDA $0000                             ; $D30B: AD 00 00
  ASL                                   ; $D30E: 0A
  ROL $0001                             ; $D30F: 2E 01 00
  CLC                                   ; $D312: 18
  ADC $0000                             ; $D313: 6D 00 00
  STA $0000                             ; $D316: 8D 00 00
  LDA $0001                             ; $D319: AD 01 00
  ADC $0002                             ; $D31C: 6D 02 00
  STA $0001                             ; $D31F: 8D 01 00
  LDA $0000                             ; $D322: AD 00 00
  CLC                                   ; $D325: 18
  ADC $0664,Y                           ; $D326: 79 64 06
  STA $0000                             ; $D329: 8D 00 00
  LDA $0001                             ; $D32C: AD 01 00
  ADC #$00                              ; $D32F: 69 00
  STA $0001                             ; $D331: 8D 01 00
  LDA #$B4                              ; $D334: A9 B4
  CLC                                   ; $D336: 18
  ADC $0000                             ; $D337: 6D 00 00
  STA $0000                             ; $D33A: 8D 00 00
  LDA #$8D                              ; $D33D: A9 8D
  ADC $0001                             ; $D33F: 6D 01 00
  STA $0001                             ; $D342: 8D 01 00
  LDY #$00                              ; $D345: A0 00
  STY $0004                             ; $D347: 8C 04 00
  LDA ($00),Y                           ; $D34A: B1 00
  STA $00C1                             ; $D34C: 8D C1 00
  LDX $007C                             ; $D34F: AE 7C 00
Loc_D352:
  INY                                   ; $D352: C8
  LDA ($00),Y                           ; $D353: B1 00
  CMP #$FF                              ; $D355: C9 FF
  BEQ $D387                             ; $D357: F0 2E
  CLC                                   ; $D359: 18
  ADC #$C0                              ; $D35A: 69 C0
  STA $0201,X                           ; $D35C: 9D 01 02
  LDA #$00                              ; $D35F: A9 00
  STA $0202,X                           ; $D361: 9D 02 02
  TYA                                   ; $D364: 98
  PHA                                   ; $D365: 48
  LDY $0004                             ; $D366: AC 04 00
  LDA $D38B,Y                           ; $D369: B9 8B D3
  STA $0203,X                           ; $D36C: 9D 03 02
  INY                                   ; $D36F: C8
  LDA $D38B,Y                           ; $D370: B9 8B D3
  CLC                                   ; $D373: 18
  ADC #$08                              ; $D374: 69 08
  STA $0200,X                           ; $D376: 9D 00 02
  INY                                   ; $D379: C8
  STY $0004                             ; $D37A: 8C 04 00
  INX                                   ; $D37D: E8
  INX                                   ; $D37E: E8
  INX                                   ; $D37F: E8
  INX                                   ; $D380: E8
  PLA                                   ; $D381: 68
  TAY                                   ; $D382: A8
  CPY #$0C                              ; $D383: C0 0C
  BCC $D352                             ; $D385: 90 CB
Loc_D387:
  STX $007C                             ; $D387: 8E 7C 00
  RTS                                   ; $D38A: 60
; --- Data Region ---
  .byte $A0,$30,$A8,$30,$A0,$38,$A8,$38,$B0,$30,$B8,$30,$B0,$38,$B8,$38; $D38B: A0 30 A8 30 A0 38 A8 38 B0 30 B8 30 B0 38 B8 38
  .byte $C0,$30,$C8,$30,$C0,$38,$C8,$38   ; $D39B: C0 30 C8 30 C0 38 C8 38
Loc_D3A3:
; --- Code Region ---
  LDA $04D0                             ; $D3A3: AD D0 04
  CMP #$B0                              ; $D3A6: C9 B0
  BEQ $D3AB                             ; $D3A8: F0 01
  RTS                                   ; $D3AA: 60
Loc_D3AB:
  LDA #$20                              ; $D3AB: A9 20
  STA $0380                             ; $D3AD: 8D 80 03
  LDA #$27                              ; $D3B0: A9 27
  STA $0381                             ; $D3B2: 8D 81 03
  LDA #$D8                              ; $D3B5: A9 D8
  STA $0382                             ; $D3B7: 8D 82 03
  LDY #$00                              ; $D3BA: A0 00
  LDA #$AA                              ; $D3BC: A9 AA
Loc_D3BE:
  STA $0383,Y                           ; $D3BE: 99 83 03
  INY                                   ; $D3C1: C8
  CPY #$20                              ; $D3C2: C0 20
  BCC $D3BE                             ; $D3C4: 90 F8
  LDA #$FF                              ; $D3C6: A9 FF
  STA $0383,Y                           ; $D3C8: 99 83 03
  LDA $007E                             ; $D3CB: AD 7E 00
  ORA #$04                              ; $D3CE: 09 04
  STA $007E                             ; $D3D0: 8D 7E 00
  LDA #$00                              ; $D3D3: A9 00
  STA $04C8                             ; $D3D5: 8D C8 04
  LDA #$01                              ; $D3D8: A9 01
  STA $0518                             ; $D3DA: 8D 18 05
  LDA #$01                              ; $D3DD: A9 01
  STA $007D                             ; $D3DF: 8D 7D 00
  STA $0000                             ; $D3E2: 8D 00 00
  LDY #$3D                              ; $D3E5: A0 3D
  JSR $EE07                             ; $D3E7: 20 07 EE
; --- Data Region ---
  .byte $15,$A0,$A9,$88,$8D,$C2,$00,$8D,$CA,$00,$8D,$D2,$00,$8D,$C5,$00; $D3EA: 15 A0 A9 88 8D C2 00 8D CA 00 8D D2 00 8D C5 00
  .byte $8D,$CD,$00,$8D,$D5,$00,$A9,$89,$8D,$C3,$00,$8D,$CB,$00,$8D,$D3; $D3FA: 8D CD 00 8D D5 00 A9 89 8D C3 00 8D CB 00 8D D3
  .byte $00,$A9,$8A,$8D,$C4,$00,$8D,$CC,$00,$8D,$D4,$00,$20,$7F,$E5,$A9; $D40A: 00 A9 8A 8D C4 00 8D CC 00 8D D4 00 20 7F E5 A9
  .byte $1D,$20,$73,$E6,$60               ; $D41A: 1D 20 73 E6 60
Loc_D41F:  ; (dispatch callback target)
; --- Code Region ---
  LDA $04CA                             ; $D41F: AD CA 04
  JSR $EADE                             ; $D422: 20 DE EA
; --- Data Region ---
  .byte $2F,$D4,$76,$D4,$59,$D5,$F2,$D5,$EA,$D6; $D425: 2F D4 76 D4 59 D5 F2 D5 EA D6
Loc_D42F:  ; (dispatch callback target)
; --- Code Region ---
  LDA #$50                              ; $D42F: A9 50
  STA $04D4                             ; $D431: 8D D4 04
  LDA #$8C                              ; $D434: A9 8C
  STA $04D5                             ; $D436: 8D D5 04
  LDA #$C0                              ; $D439: A9 C0
  STA $04D2                             ; $D43B: 8D D2 04
  LDA #$25                              ; $D43E: A9 25
  STA $04D3                             ; $D440: 8D D3 04
  LDY $0509                             ; $D443: AC 09 05
  LDA $0664,Y                           ; $D446: B9 64 06
  JSR $F2D7                             ; $D449: 20 D7 F2
  LDY #$00                              ; $D44C: A0 00
  LDA ($00),Y                           ; $D44E: B1 00
  STA $0430                             ; $D450: 8D 30 04
  LDY #$02                              ; $D453: A0 02
  LDA ($00),Y                           ; $D455: B1 00
  STA $042F                             ; $D457: 8D 2F 04
  INY                                   ; $D45A: C8
  LDA ($00),Y                           ; $D45B: B1 00
  STA $042E                             ; $D45D: 8D 2E 04
  LDY #$08                              ; $D460: A0 08
  LDA ($00),Y                           ; $D462: B1 00
  STA $042D                             ; $D464: 8D 2D 04
  INY                                   ; $D467: C8
  LDA ($00),Y                           ; $D468: B1 00
  STA $042C                             ; $D46A: 8D 2C 04
  LDA #$06                              ; $D46D: A9 06
  STA $04D1                             ; $D46F: 8D D1 04
  INC $04CA                             ; $D472: EE CA 04
  RTS                                   ; $D475: 60
Loc_D476:  ; (dispatch callback target)
  LDY #$21                              ; $D476: A0 21
  JSR $F25F                             ; $D478: 20 5F F2
  LDA $04D4                             ; $D47B: AD D4 04
  STA $0000                             ; $D47E: 8D 00 00
  LDA $04D5                             ; $D481: AD D5 04
  STA $0001                             ; $D484: 8D 01 00
  LDX #$00                              ; $D487: A2 00
  LDA #$40                              ; $D489: A9 40
  STA $0380,X                           ; $D48B: 9D 80 03
  LDA $04D3                             ; $D48E: AD D3 04
  STA $0381,X                           ; $D491: 9D 81 03
  LDA $04D2                             ; $D494: AD D2 04
  STA $0382,X                           ; $D497: 9D 82 03
  LDX #$03                              ; $D49A: A2 03
  LDY #$00                              ; $D49C: A0 00
Loc_D49E:
  LDA ($00),Y                           ; $D49E: B1 00
  STA $0380,X                           ; $D4A0: 9D 80 03
  INX                                   ; $D4A3: E8
  INY                                   ; $D4A4: C8
  CPY #$40                              ; $D4A5: C0 40
  BCC $D49E                             ; $D4A7: 90 F5
  LDA #$FF                              ; $D4A9: A9 FF
  STA $0380,X                           ; $D4AB: 9D 80 03
  LDA $0000                             ; $D4AE: AD 00 00
  CLC                                   ; $D4B1: 18
  ADC #$40                              ; $D4B2: 69 40
  STA $04D4                             ; $D4B4: 8D D4 04
  LDA $0001                             ; $D4B7: AD 01 00
  ADC #$00                              ; $D4BA: 69 00
  STA $04D5                             ; $D4BC: 8D D5 04
  LDA $04D2                             ; $D4BF: AD D2 04
  CLC                                   ; $D4C2: 18
  ADC #$40                              ; $D4C3: 69 40
  STA $04D2                             ; $D4C5: 8D D2 04
  LDA $04D3                             ; $D4C8: AD D3 04
  ADC #$00                              ; $D4CB: 69 00
  STA $04D3                             ; $D4CD: 8D D3 04
  LDA $04D1                             ; $D4D0: AD D1 04
  BEQ $D4DC                             ; $D4D3: F0 07
  CMP #$05                              ; $D4D5: C9 05
  BCS $D4DC                             ; $D4D7: B0 03
  JSR $D75C                             ; $D4D9: 20 5C D7
Loc_D4DC:
  DEC $04D1                             ; $D4DC: CE D1 04
  LDA $04D1                             ; $D4DF: AD D1 04
  BMI $D4ED                             ; $D4E2: 30 09
Loc_D4E4:
  LDA $007E                             ; $D4E4: AD 7E 00
  ORA #$04                              ; $D4E7: 09 04
  STA $007E                             ; $D4E9: 8D 7E 00
  RTS                                   ; $D4EC: 60
Loc_D4ED:
  LDA #$02                              ; $D4ED: A9 02
  STA $04D2                             ; $D4EF: 8D D2 04
  LDA #$26                              ; $D4F2: A9 26
  STA $04D3                             ; $D4F4: 8D D3 04
  LDY $04C9                             ; $D4F7: AC C9 04
  LDA $D549,Y                           ; $D4FA: B9 49 D5
  TAY                                   ; $D4FD: A8
  LSR                                   ; $D4FE: 4A
  STA $04C9                             ; $D4FF: 8D C9 04
  LDA $8E10,Y                           ; $D502: B9 10 8E
  STA $0000                             ; $D505: 8D 00 00
  INY                                   ; $D508: C8
  LDA $8E10,Y                           ; $D509: B9 10 8E
  CLC                                   ; $D50C: 18
  ADC #$60                              ; $D50D: 69 60
  STA $0001                             ; $D50F: 8D 01 00
  LDY #$00                              ; $D512: A0 00
  LDX #$15                              ; $D514: A2 15
Loc_D516:
  LDA ($00),Y                           ; $D516: B1 00
  STA $00AE,X                           ; $D518: 9D AE 00
  INX                                   ; $D51B: E8
  TXA                                   ; $D51C: 8A
  AND #$07                              ; $D51D: 29 07
  CMP #$07                              ; $D51F: C9 07
  BNE $D528                             ; $D521: D0 05
  TXA                                   ; $D523: 8A
  CLC                                   ; $D524: 18
  ADC #$06                              ; $D525: 69 06
  TAX                                   ; $D527: AA
Loc_D528:
  INY                                   ; $D528: C8
  CPY #$06                              ; $D529: C0 06
  BCC $D516                             ; $D52B: 90 E9
  LDA $0000                             ; $D52D: AD 00 00
  CLC                                   ; $D530: 18
  ADC #$06                              ; $D531: 69 06
  STA $04D4                             ; $D533: 8D D4 04
  LDA $0001                             ; $D536: AD 01 00
  ADC #$00                              ; $D539: 69 00
  STA $04D5                             ; $D53B: 8D D5 04
  LDA #$04                              ; $D53E: A9 04
  STA $04D1                             ; $D540: 8D D1 04
  INC $04CA                             ; $D543: EE CA 04
  JMP $D4E4                             ; $D546: 4C E4 D4
; --- Data Region ---
  .byte $02,$10,$06,$08,$04,$02,$0E,$08,$0C; $D549: 02 10 06 08 04 02 0E 08 0C
Loc_D552:
; --- Code Region ---
  NOP $0A,X                             ; $D552: 14 0A
  PHP                                   ; $D554: 08
  NOP $12                               ; $D555: 04 12
  JAM                                   ; $D557: 02
  BRK                                   ; $D558: 00
Loc_D559:  ; (dispatch callback target)
  LDY #$21                              ; $D559: A0 21
  JSR $F25F                             ; $D55B: 20 5F F2
  LDA $04D2                             ; $D55E: AD D2 04
  STA $0002                             ; $D561: 8D 02 00
  LDA $04D3                             ; $D564: AD D3 04
  STA $0003                             ; $D567: 8D 03 00
  LDA $04D4                             ; $D56A: AD D4 04
  STA $0000                             ; $D56D: 8D 00 00
  LDA $04D5                             ; $D570: AD D5 04
  STA $0001                             ; $D573: 8D 01 00
  LDX #$00                              ; $D576: A2 00
  LDY #$00                              ; $D578: A0 00
Loc_D57A:
  LDA #$0E                              ; $D57A: A9 0E
  STA $0380,X                           ; $D57C: 9D 80 03
  INX                                   ; $D57F: E8
  LDA $0003                             ; $D580: AD 03 00
  STA $0380,X                           ; $D583: 9D 80 03
  INX                                   ; $D586: E8
  LDA $0002                             ; $D587: AD 02 00
  STA $0380,X                           ; $D58A: 9D 80 03
  INX                                   ; $D58D: E8
  LDY #$00                              ; $D58E: A0 00
Loc_D590:
  LDA ($00),Y                           ; $D590: B1 00
  STA $0380,X                           ; $D592: 9D 80 03
  INX                                   ; $D595: E8
  INY                                   ; $D596: C8
  CPY #$0E                              ; $D597: C0 0E
  BCC $D590                             ; $D599: 90 F5
  LDA $0000                             ; $D59B: AD 00 00
  CLC                                   ; $D59E: 18
  ADC #$0E                              ; $D59F: 69 0E
  STA $0000                             ; $D5A1: 8D 00 00
  LDA $0001                             ; $D5A4: AD 01 00
  ADC #$00                              ; $D5A7: 69 00
  STA $0001                             ; $D5A9: 8D 01 00
  LDA $0002                             ; $D5AC: AD 02 00
  CLC                                   ; $D5AF: 18
  ADC #$20                              ; $D5B0: 69 20
  STA $0002                             ; $D5B2: 8D 02 00
  LDA $0003                             ; $D5B5: AD 03 00
  ADC #$00                              ; $D5B8: 69 00
  STA $0003                             ; $D5BA: 8D 03 00
  CPX #$22                              ; $D5BD: E0 22
  BCC $D57A                             ; $D5BF: 90 B9
  LDA #$FF                              ; $D5C1: A9 FF
  STA $0380,X                           ; $D5C3: 9D 80 03
  LDA $0002                             ; $D5C6: AD 02 00
  STA $04D2                             ; $D5C9: 8D D2 04
  LDA $0003                             ; $D5CC: AD 03 00
  STA $04D3                             ; $D5CF: 8D D3 04
  LDA $0000                             ; $D5D2: AD 00 00
  STA $04D4                             ; $D5D5: 8D D4 04
  LDA $0001                             ; $D5D8: AD 01 00
  STA $04D5                             ; $D5DB: 8D D5 04
  DEC $04D1                             ; $D5DE: CE D1 04
  LDA $04D1                             ; $D5E1: AD D1 04
  BPL $D5E9                             ; $D5E4: 10 03
  INC $04CA                             ; $D5E6: EE CA 04
Loc_D5E9:
  LDA $007E                             ; $D5E9: AD 7E 00
  ORA #$04                              ; $D5EC: 09 04
  STA $007E                             ; $D5EE: 8D 7E 00
  RTS                                   ; $D5F1: 60
Loc_D5F2:  ; (dispatch callback target)
  LDA $04C9                             ; $D5F2: AD C9 04
  ASL                                   ; $D5F5: 0A
  ASL                                   ; $D5F6: 0A
  ASL                                   ; $D5F7: 0A
  TAY                                   ; $D5F8: A8
  CLC                                   ; $D5F9: 18
  ADC #$08                              ; $D5FA: 69 08
  STA $0002                             ; $D5FC: 8D 02 00
  LDX #$0C                              ; $D5FF: A2 0C
Loc_D601:
  LDA $D692,Y                           ; $D601: B9 92 D6
  STA $0100,X                           ; $D604: 9D 00 01
  INX                                   ; $D607: E8
  CPX #$10                              ; $D608: E0 10
  BNE $D60E                             ; $D60A: D0 02
  LDX #$1C                              ; $D60C: A2 1C
Loc_D60E:
  INY                                   ; $D60E: C8
  CPY $0002                             ; $D60F: CC 02 00
  BCC $D601                             ; $D612: 90 ED
  LDA #$00                              ; $D614: A9 00
  STA $0000                             ; $D616: 8D 00 00
  LDA $04C9                             ; $D619: AD C9 04
  CMP #$01                              ; $D61C: C9 01
  BNE $D628                             ; $D61E: D0 08
  LDA #$20                              ; $D620: A9 20
  STA $0000                             ; $D622: 8D 00 00
  JMP $D631                             ; $D625: 4C 31 D6
Loc_D628:
  CMP #$04                              ; $D628: C9 04
  BNE $D631                             ; $D62A: D0 05
  LDA #$40                              ; $D62C: A9 40
  STA $0000                             ; $D62E: 8D 00 00
Loc_D631:
  LDA #$FF                              ; $D631: A9 FF
  CLC                                   ; $D633: 18
  ADC $0000                             ; $D634: 6D 00 00
  STA $0000                             ; $D637: 8D 00 00
  LDA #$D7                              ; $D63A: A9 D7
  ADC #$00                              ; $D63C: 69 00
  STA $0001                             ; $D63E: 8D 01 00
  LDA #$20                              ; $D641: A9 20
  STA $0380                             ; $D643: 8D 80 03
  LDA #$27                              ; $D646: A9 27
  STA $0381                             ; $D648: 8D 81 03
  LDA #$D8                              ; $D64B: A9 D8
  STA $0382                             ; $D64D: 8D 82 03
  LDY #$00                              ; $D650: A0 00
Loc_D652:
  LDA ($00),Y                           ; $D652: B1 00
  STA $0383,Y                           ; $D654: 99 83 03
  INY                                   ; $D657: C8
  CPY #$20                              ; $D658: C0 20
  BCC $D652                             ; $D65A: 90 F6
  LDA #$FF                              ; $D65C: A9 FF
  STA $0383,Y                           ; $D65E: 99 83 03
  LDA $007E                             ; $D661: AD 7E 00
  ORA #$04                              ; $D664: 09 04
  STA $007E                             ; $D666: 8D 7E 00
  LDA #$0F                              ; $D669: A9 0F
  STA $0111                             ; $D66B: 8D 11 01
  LDA #$1B                              ; $D66E: A9 1B
  STA $0112                             ; $D670: 8D 12 01
  LDA #$28                              ; $D673: A9 28
  STA $0113                             ; $D675: 8D 13 01
  LDA #$02                              ; $D678: A9 02
  STA $00C2                             ; $D67A: 8D C2 00
  STA $00CA                             ; $D67D: 8D CA 00
  STA $00D2                             ; $D680: 8D D2 00
  LDA #$06                              ; $D683: A9 06
  STA $00C5                             ; $D685: 8D C5 00
  STA $00CD                             ; $D688: 8D CD 00
  STA $00D5                             ; $D68B: 8D D5 00
  INC $04CA                             ; $D68E: EE CA 04
  RTS                                   ; $D691: 60
; --- Data Region ---
  .byte $0F,$36,$20,$17,$0F,$36,$20,$17,$0F,$06,$16,$17,$0F,$06,$16,$17; $D692: 0F 36 20 17 0F 36 20 17 0F 06 16 17 0F 06 16 17
  .byte $0F,$36,$26,$12,$0F,$36,$26,$12,$0F,$36,$00,$17,$0F,$0F,$0F,$20; $D6A2: 0F 36 26 12 0F 36 26 12 0F 36 00 17 0F 0F 0F 20
  .byte $0F,$36,$27,$17,$0F,$36,$27,$17,$0F,$36,$17,$21,$0F,$36,$17,$21; $D6B2: 0F 36 27 17 0F 36 27 17 0F 36 17 21 0F 36 17 21
  .byte $0F,$30,$36,$17,$0F,$30,$36,$17,$0F,$36,$17,$10,$0F,$36,$17,$10; $D6C2: 0F 30 36 17 0F 30 36 17 0F 36 17 10 0F 36 17 10
  .byte $0F,$2A,$36,$17,$0F,$2A,$36,$17,$0F,$36,$17,$10; $D6D2: 0F 2A 36 17 0F 2A 36 17 0F 36 17 10
Loc_D6DE:
; --- Code Region ---
  SLO $0707                             ; $D6DE: 0F 07 07
  CLC                                   ; $D6E1: 18
Loc_D6E2:
  SLO $1736                             ; $D6E2: 0F 36 17
  ASL $0F,X                             ; $D6E5: 16 0F
  JSR $0F10                             ; $D6E7: 20 10 0F
Loc_D6EA:  ; (dispatch callback target)
  LDY #$03                              ; $D6EA: A0 03
  LDA #$01                              ; $D6EC: A9 01
Loc_D6EE:
  STA $0380,Y                           ; $D6EE: 99 80 03
  INY                                   ; $D6F1: C8
  CPY #$46                              ; $D6F2: C0 46
  BCC $D6EE                             ; $D6F4: 90 F8
  LDA #$FF                              ; $D6F6: A9 FF
  STA $0380,Y                           ; $D6F8: 99 80 03
Loc_D6FB:
  LDA #$20                              ; $D6FB: A9 20
  STA $0380                             ; $D6FD: 8D 80 03
  STA $03A3                             ; $D700: 8D A3 03
  LDA #$25                              ; $D703: A9 25
  STA $0381                             ; $D705: 8D 81 03
  LDA #$A0                              ; $D708: A9 A0
  STA $0382                             ; $D70A: 8D 82 03
  LDA #$27                              ; $D70D: A9 27
  STA $03A4                             ; $D70F: 8D A4 03
  LDA #$80                              ; $D712: A9 80
  STA $03A5                             ; $D714: 8D A5 03
  LDA $007E                             ; $D717: AD 7E 00
  ORA #$04                              ; $D71A: 09 04
  STA $007E                             ; $D71C: 8D 7E 00
  LDA #$81                              ; $D71F: A9 81
  STA $04C8                             ; $D721: 8D C8 04
  LDA #$00                              ; $D724: A9 00
  STA $04CA                             ; $D726: 8D CA 04
  STA $04CD                             ; $D729: 8D CD 04
  STA $04CE                             ; $D72C: 8D CE 04
  STA $04D0                             ; $D72F: 8D D0 04
  LDA #$00                              ; $D732: A9 00
  STA $0518                             ; $D734: 8D 18 05
  JSR $E57F                             ; $D737: 20 7F E5
  LDY $04C9                             ; $D73A: AC C9 04
  LDA $D751,Y                           ; $D73D: B9 51 D7
  CMP #$88                              ; $D740: C9 88
  BEQ $D74E                             ; $D742: F0 0A
  CMP #$95                              ; $D744: C9 95
  BEQ $D74B                             ; $D746: F0 03
  JMP $E68B                             ; $D748: 4C 8B E6
Loc_D74B:
  JMP $E693                             ; $D74B: 4C 93 E6
Loc_D74E:
  JMP $E683                             ; $D74E: 4C 83 E6
; --- Data Region ---
  .byte $95,$88,$88,$8D,$8D,$8D,$91,$88,$95,$88,$95; $D751: 95 88 88 8D 8D 8D 91 88 95 88 95
Loc_D75C:
; --- Code Region ---
  LDY $04D1                             ; $D75C: AC D1 04
  CPY #$01                              ; $D75F: C0 01
  BEQ $D788                             ; $D761: F0 25
  LDA $042C,Y                           ; $D763: B9 2C 04
  CMP #$64                              ; $D766: C9 64
  BNE $D76D                             ; $D768: D0 03
  JMP $D7F6                             ; $D76A: 4C F6 D7
Loc_D76D:
  STA $0001                             ; $D76D: 8D 01 00
  LDA #$00                              ; $D770: A9 00
  STA $0002                             ; $D772: 8D 02 00
  STA $0003                             ; $D775: 8D 03 00
  JSR $E9BA                             ; $D778: 20 BA E9
  LDX #$00                              ; $D77B: A2 00
  LDA $0007                             ; $D77D: AD 07 00
  STA $0000                             ; $D780: 8D 00 00
  LDY #$00                              ; $D783: A0 00
  JMP $D7BD                             ; $D785: 4C BD D7
Loc_D788:
  LDY $04D1                             ; $D788: AC D1 04
  LDA $042C                             ; $D78B: AD 2C 04
  STA $0002                             ; $D78E: 8D 02 00
  LDA $042D                             ; $D791: AD 2D 04
  STA $0001                             ; $D794: 8D 01 00
  LDA #$00                              ; $D797: A9 00
  STA $0003                             ; $D799: 8D 03 00
  JSR $E9BA                             ; $D79C: 20 BA E9
  LDX #$00                              ; $D79F: A2 00
  LDA $0008                             ; $D7A1: AD 08 00
  STA $0000                             ; $D7A4: 8D 00 00
  LDY #$01                              ; $D7A7: A0 01
  JSR $D7BD                             ; $D7A9: 20 BD D7
  LDX #$02                              ; $D7AC: A2 02
  LDA $0007                             ; $D7AE: AD 07 00
  STA $0000                             ; $D7B1: 8D 00 00
  CPY #$FF                              ; $D7B4: C0 FF
  BEQ $D7BA                             ; $D7B6: F0 02
  LDY #$00                              ; $D7B8: A0 00
Loc_D7BA:
  JMP $D7BD                             ; $D7BA: 4C BD D7
Loc_D7BD:
  LDA $0000                             ; $D7BD: AD 00 00
  LSR                                   ; $D7C0: 4A
  LSR                                   ; $D7C1: 4A
  LSR                                   ; $D7C2: 4A
  LSR                                   ; $D7C3: 4A
  BNE $D7CF                             ; $D7C4: D0 09
  CPY #$FF                              ; $D7C6: C0 FF
  BEQ $D7CF                             ; $D7C8: F0 05
  LDA #$01                              ; $D7CA: A9 01
  JMP $D7D4                             ; $D7CC: 4C D4 D7
Loc_D7CF:
  CLC                                   ; $D7CF: 18
  ADC #$F6                              ; $D7D0: 69 F6
  LDY #$FF                              ; $D7D2: A0 FF
Loc_D7D4:
  STA $03BA,X                           ; $D7D4: 9D BA 03
  CPY #$01                              ; $D7D7: C0 01
  BEQ $D7DD                             ; $D7D9: F0 02
  LDY #$FF                              ; $D7DB: A0 FF
Loc_D7DD:
  LDA $0000                             ; $D7DD: AD 00 00
  AND #$0F                              ; $D7E0: 29 0F
  BNE $D7ED                             ; $D7E2: D0 09
  CPY #$FF                              ; $D7E4: C0 FF
  BEQ $D7ED                             ; $D7E6: F0 05
  LDA #$01                              ; $D7E8: A9 01
  JMP $D7F2                             ; $D7EA: 4C F2 D7
Loc_D7ED:
  CLC                                   ; $D7ED: 18
  ADC #$F6                              ; $D7EE: 69 F6
  LDY #$FF                              ; $D7F0: A0 FF
Loc_D7F2:
  STA $03BB,X                           ; $D7F2: 9D BB 03
  RTS                                   ; $D7F5: 60
Loc_D7F6:
  LDA #$EB                              ; $D7F6: A9 EB
  STA $03BA                             ; $D7F8: 8D BA 03
  STA $03BB                             ; $D7FB: 8D BB 03
  RTS                                   ; $D7FE: 60
; --- Data Region ---
  .byte $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$EE,$FF,$FF,$FF,$AA,$AA,$AA,$AA; $D7FF: AA AA AA AA AA AA AA AA EE FF FF FF AA AA AA AA
  .byte $EE,$FF,$FF,$FF,$AA,$AA,$AA,$AA,$AE,$AF,$AF,$AF,$AA,$AA,$AA,$AA; $D80F: EE FF FF FF AA AA AA AA AE AF AF AF AA AA AA AA
  .byte $AA                               ; $D81F: AA
Loc_D820:
; --- Code Region ---
  TAX                                   ; $D820: AA
  TAX                                   ; $D821: AA
  TAX                                   ; $D822: AA
  TAX                                   ; $D823: AA
  TAX                                   ; $D824: AA
  TAX                                   ; $D825: AA
  TAX                                   ; $D826: AA
  INC $FFFF                             ; $D827: EE FF FF
  ISB $AAAA,X                           ; $D82A: FF AA AA
  TAX                                   ; $D82D: AA
  TAX                                   ; $D82E: AA
  ROR $5F5F                             ; $D82F: 6E 5F 5F
  SRE $AAAA,X                           ; $D832: 5F AA AA
  TAX                                   ; $D835: AA
  TAX                                   ; $D836: AA
  LDX $A5                               ; $D837: A6 A5
  LDA $A5                               ; $D839: A5 A5
  TAX                                   ; $D83B: AA
  TAX                                   ; $D83C: AA
  TAX                                   ; $D83D: AA
  TAX                                   ; $D83E: AA
  TAX                                   ; $D83F: AA
  TAX                                   ; $D840: AA
  TAX                                   ; $D841: AA
  TAX                                   ; $D842: AA
  TAX                                   ; $D843: AA
  TAX                                   ; $D844: AA
Loc_D845:
  TAX                                   ; $D845: AA
  TAX                                   ; $D846: AA
  JAM                                   ; $D847: 22
  CPY #$00                              ; $D848: C0 00
  BEQ $D7F6                             ; $D84A: F0 AA
  TAX                                   ; $D84C: AA
  TAX                                   ; $D84D: AA
  TAX                                   ; $D84E: AA
  INC $FFFF                             ; $D84F: EE FF FF
  ISB $AAAA,X                           ; $D852: FF AA AA
  TAX                                   ; $D855: AA
  TAX                                   ; $D856: AA
  LDX $AFAF                             ; $D857: AE AF AF
  LAX $AAAA                             ; $D85A: AF AA AA
  TAX                                   ; $D85D: AA
  TAX                                   ; $D85E: AA
  ADC $D8,X                             ; $D85F: 75 D8
  NOP                                   ; $D861: EA
  CLD                                   ; $D862: D8
  NOP                                   ; $D863: EA
  CLD                                   ; $D864: D8
  RLA $B0DA                             ; $D865: 2F DA B0
  NOP                                   ; $D868: DA
  STY $DB,X                             ; $D869: 94 DB
  ASL                                   ; $D86B: 0A
  NOP $DC5E,X                           ; $D86C: DC 5E DC
  NOP $69DC,X                           ; $D86F: DC DC 69
  CMP $DDFA,X                           ; $D872: DD FA DD
  RRA $A0D8,Y                           ; $D875: 7B D8 A0
  CLD                                   ; $D878: D8
  CMP $D8                               ; $D879: C5 D8
  CLC                                   ; $D87B: 18
  ANC #$00                              ; $D87C: 0B 00
  BVC $D898                             ; $D87E: 50 18
  BPL $D882                             ; $D880: 10 00
Loc_D882:
  CLI                                   ; $D882: 58
  JSR $0011                             ; $D883: 20 11 00
  PHA                                   ; $D886: 48
  JSR $0016                             ; $D887: 20 16 00
  BVC $D8AC                             ; $D88A: 50 20
  SLO $00,X                             ; $D88C: 17 00
  CLI                                   ; $D88E: 58
  PLP                                   ; $D88F: 28
  CLC                                   ; $D890: 18
  BRK                                   ; $D891: 00
  PHA                                   ; $D892: 48
  PLP                                   ; $D893: 28
  ORA $5000,Y                           ; $D894: 19 00 50
  PLP                                   ; $D897: 28
Loc_D898:
  NOP                                   ; $D898: 1A
  BRK                                   ; $D899: 00
  CLI                                   ; $D89A: 58
  BMI $D8B8                             ; $D89B: 30 1B
  BRK                                   ; $D89D: 00
  BVC $D820                             ; $D89E: 50 80
  CLC                                   ; $D8A0: 18
  JSR $5000                             ; $D8A1: 20 00 50
  CLC                                   ; $D8A4: 18
  AND ($00,X)                           ; $D8A5: 21 00
  CLI                                   ; $D8A7: 58
  JSR $0022                             ; $D8A8: 20 22 00
  PHA                                   ; $D8AB: 48
Loc_D8AC:
  JSR $0023                             ; $D8AC: 20 23 00
  BVC $D8D1                             ; $D8AF: 50 20
  SLO $00,X                             ; $D8B1: 17 00
  CLI                                   ; $D8B3: 58
  PLP                                   ; $D8B4: 28
  BIT $00                               ; $D8B5: 24 00
  PHA                                   ; $D8B7: 48
Loc_D8B8:
  PLP                                   ; $D8B8: 28
  AND $00                               ; $D8B9: 25 00
  BVC $D8E5                             ; $D8BB: 50 28
  NOP                                   ; $D8BD: 1A
  BRK                                   ; $D8BE: 00
  CLI                                   ; $D8BF: 58
  BMI $D8DD                             ; $D8C0: 30 1B
  BRK                                   ; $D8C2: 00
  BVC $D845                             ; $D8C3: 50 80
  CLC                                   ; $D8C5: 18
  ANC #$00                              ; $D8C6: 0B 00
  BVC $D8E2                             ; $D8C8: 50 18
  BPL $D8CC                             ; $D8CA: 10 00
Loc_D8CC:
  CLI                                   ; $D8CC: 58
  JSR $0026                             ; $D8CD: 20 26 00
  PHA                                   ; $D8D0: 48
Loc_D8D1:
  JSR $0027                             ; $D8D1: 20 27 00
  BVC $D8F6                             ; $D8D4: 50 20
  SLO $00,X                             ; $D8D6: 17 00
  CLI                                   ; $D8D8: 58
  PLP                                   ; $D8D9: 28
  PLP                                   ; $D8DA: 28
  BRK                                   ; $D8DB: 00
  PHA                                   ; $D8DC: 48
Loc_D8DD:
  PLP                                   ; $D8DD: 28
  AND #$00                              ; $D8DE: 29 00
  BVC $D90A                             ; $D8E0: 50 28
Loc_D8E2:
  NOP                                   ; $D8E2: 1A
  BRK                                   ; $D8E3: 00
  CLI                                   ; $D8E4: 58
Loc_D8E5:
  BMI $D902                             ; $D8E5: 30 1B
  BRK                                   ; $D8E7: 00
  BVC $D86A                             ; $D8E8: 50 80
  BEQ $D8C4                             ; $D8EA: F0 D8
  EOR $C2D9,Y                           ; $D8EC: 59 D9 C2
  CMP $1C10,Y                           ; $D8EF: D9 10 1C
  BRK                                   ; $D8F2: 00
  BRK                                   ; $D8F3: 00
  BPL $D913                             ; $D8F4: 10 1D
Loc_D8F6:
  BRK                                   ; $D8F6: 00
  PHP                                   ; $D8F7: 08
  CLC                                   ; $D8F8: 18
  SLO $0800,X                           ; $D8F9: 1F 00 08
  CLC                                   ; $D8FC: 18
  RLA ($00,X)                           ; $D8FD: 23 00
  BPL $D919                             ; $D8FF: 10 18
  BIT $00                               ; $D901: 24 00
  CLC                                   ; $D903: 18
  CLC                                   ; $D904: 18
  AND $00                               ; $D905: 25 00
  JSR $2A20                             ; $D907: 20 20 2A
Loc_D90A:
  BRK                                   ; $D90A: 00
  JSR $2B20                             ; $D90B: 20 20 2B
  BRK                                   ; $D90E: 00
  PLP                                   ; $D90F: 28
  JSR $002C                             ; $D910: 20 2C 00
Loc_D913:
  BMI $D93D                             ; $D913: 30 28
  RLA $2800                             ; $D915: 2F 00 28
  PLP                                   ; $D918: 28
Loc_D919:
  BMI $D91B                             ; $D919: 30 00
Loc_D91B:
  BMI $D945                             ; $D91B: 30 28
  AND ($00),Y                           ; $D91D: 31 00
  SEC                                   ; $D91F: 38
  PLP                                   ; $D920: 28
  JAM                                   ; $D921: 32
  BRK                                   ; $D922: 00
  RTI                                   ; $D923: 40
; --- Data Region ---
  .byte $28,$33,$00,$48,$30,$36,$00,$48,$18,$26,$00,$50,$20,$2D,$00,$50; $D924: 28 33 00 48 30 36 00 48 18 26 00 50 20 2D 00 50
  .byte $28,$34,$00,$50,$30,$37,$00,$50,$18; $D934: 28 34 00 50 30 37 00 50 18
Loc_D93D:
; --- Code Region ---
  RLA $00                               ; $D93D: 27 00
  CLI                                   ; $D93F: 58
  JSR $002E                             ; $D940: 20 2E 00
  CLI                                   ; $D943: 58
  PLP                                   ; $D944: 28
Loc_D945:
  AND $00,X                             ; $D945: 35 00
  CLI                                   ; $D947: 58
  BMI $D982                             ; $D948: 30 38
  BRK                                   ; $D94A: 00
  CLI                                   ; $D94B: 58
  CLC                                   ; $D94C: 18
  PLP                                   ; $D94D: 28
  BRK                                   ; $D94E: 00
  RTS                                   ; $D94F: 60
; --- Data Region ---
  .byte $10                               ; $D950: 10
Loc_D951:
; --- Code Region ---
  ASL $6800,X                           ; $D951: 1E 00 68
  CLC                                   ; $D954: 18
Loc_D955:
  AND #$00                              ; $D955: 29 00
  PLA                                   ; $D957: 68
  NOP #$10                              ; $D958: 80 10
  AND $0000,Y                           ; $D95A: 39 00 00
  BPL $D999                             ; $D95D: 10 3A
  BRK                                   ; $D95F: 00
Loc_D960:
  PHP                                   ; $D960: 08
  CLC                                   ; $D961: 18
  NOP $0800,X                           ; $D962: 3C 00 08
  CLC                                   ; $D965: 18
  AND $1000,X                           ; $D966: 3D 00 10
Loc_D969:
  CLC                                   ; $D969: 18
  ROL $1800,X                           ; $D96A: 3E 00 18
  CLC                                   ; $D96D: 18
  RLA $2000,X                           ; $D96E: 3F 00 20
  JSR $0044                             ; $D971: 20 44 00
  JSR $4520                             ; $D974: 20 20 45
  BRK                                   ; $D977: 00
  PLP                                   ; $D978: 28
  JSR $0046                             ; $D979: 20 46 00
  BMI $D9A6                             ; $D97C: 30 28
  PHA                                   ; $D97E: 48
  BRK                                   ; $D97F: 00
  PLP                                   ; $D980: 28
  PLP                                   ; $D981: 28
Loc_D982:
  EOR #$00                              ; $D982: 49 00
  BMI $D9AE                             ; $D984: 30 28
  LSR                                   ; $D986: 4A
  BRK                                   ; $D987: 00
  SEC                                   ; $D988: 38
  PLP                                   ; $D989: 28
  ALR #$00                              ; $D98A: 4B 00
  RTI                                   ; $D98C: 40
; --- Data Region ---
  .byte $28,$4C,$00,$48,$30,$4E,$00,$48,$18,$40,$00,$50; $D98D: 28 4C 00 48 30 4E 00 48 18 40 00 50
Loc_D999:
; --- Code Region ---
  JSR $0047                             ; $D999: 20 47 00
  BVC $D9C6                             ; $D99C: 50 28
  EOR $5000                             ; $D99E: 4D 00 50
  BMI $D9EB                             ; $D9A1: 30 48
  BRK                                   ; $D9A3: 00
  BVC $D9BE                             ; $D9A4: 50 18
Loc_D9A6:
  EOR ($00,X)                           ; $D9A6: 41 00
  CLI                                   ; $D9A8: 58
  JSR $002E                             ; $D9A9: 20 2E 00
  CLI                                   ; $D9AC: 58
  PLP                                   ; $D9AD: 28
Loc_D9AE:
  AND $00,X                             ; $D9AE: 35 00
  CLI                                   ; $D9B0: 58
  BMI $D9FB                             ; $D9B1: 30 48
  BRK                                   ; $D9B3: 00
  CLI                                   ; $D9B4: 58
  CLC                                   ; $D9B5: 18
  JAM                                   ; $D9B6: 42
  BRK                                   ; $D9B7: 00
  RTS                                   ; $D9B8: 60
; --- Data Region ---
  .byte $10                               ; $D9B9: 10
Loc_D9BA:
; --- Code Region ---
  RLA $6800,Y                           ; $D9BA: 3B 00 68
  CLC                                   ; $D9BD: 18
Loc_D9BE:
  SRE ($00,X)                           ; $D9BE: 43 00
  PLA                                   ; $D9C0: 68
  NOP #$08                              ; $D9C1: 80 08
  SRE $0000                             ; $D9C3: 4F 00 00
Loc_D9C6:
  BPL $DA10                             ; $D9C6: 10 48
  BRK                                   ; $D9C8: 00
  BRK                                   ; $D9C9: 00
  BPL $DA1C                             ; $D9CA: 10 50
  BRK                                   ; $D9CC: 00
  PHP                                   ; $D9CD: 08
  CLC                                   ; $D9CE: 18
  PHA                                   ; $D9CF: 48
  BRK                                   ; $D9D0: 00
  PHP                                   ; $D9D1: 08
  CLC                                   ; $D9D2: 18
  EOR ($00),Y                           ; $D9D3: 51 00
  BPL $D9EF                             ; $D9D5: 10 18
  JAM                                   ; $D9D7: 52
  BRK                                   ; $D9D8: 00
  CLC                                   ; $D9D9: 18
  CLC                                   ; $D9DA: 18
  SRE ($00),Y                           ; $D9DB: 53 00
  JSR $4820                             ; $D9DD: 20 20 48
  BRK                                   ; $D9E0: 00
Loc_D9E1:
  JSR $5720                             ; $D9E1: 20 20 57
  BRK                                   ; $D9E4: 00
  PLP                                   ; $D9E5: 28
  PLP                                   ; $D9E6: 28
  PHA                                   ; $D9E7: 48
  BRK                                   ; $D9E8: 00
  PLP                                   ; $D9E9: 28
  JSR $0058                             ; $D9EA: 20 58 00
  BMI $DA17                             ; $D9ED: 30 28
Loc_D9EF:
  PHA                                   ; $D9EF: 48
  BRK                                   ; $D9F0: 00
  BMI $DA1B                             ; $D9F1: 30 28
  SRE $3800,Y                           ; $D9F3: 5B 00 38
Loc_D9F6:
  PLP                                   ; $D9F6: 28
  NOP $4000,X                           ; $D9F7: 5C 00 40
  PLP                                   ; $D9FA: 28
Loc_D9FB:
  EOR $4800,X                           ; $D9FB: 5D 00 48
  BMI $DA48                             ; $D9FE: 30 48
  BRK                                   ; $DA00: 00
  PHA                                   ; $DA01: 48
  CLC                                   ; $DA02: 18
  RTI                                   ; $DA03: 40
; --- Data Region ---
  .byte $00,$50,$20,$59,$00,$50,$28,$5E,$00,$50,$30,$48; $DA04: 00 50 20 59 00 50 28 5E 00 50 30 48
Loc_DA10:
; --- Code Region ---
  BRK                                   ; $DA10: 00
  BVC $DA2B                             ; $DA11: 50 18
  NOP $00,X                             ; $DA13: 54 00
  CLI                                   ; $DA15: 58
  JSR $005A                             ; $DA16: 20 5A 00
  CLI                                   ; $DA19: 58
  PLP                                   ; $DA1A: 28
Loc_DA1B:
  AND ($00,X)                           ; $DA1B: 21 00
  CLI                                   ; $DA1D: 58
  BMI $DA68                             ; $DA1E: 30 48
  BRK                                   ; $DA20: 00
  CLI                                   ; $DA21: 58
  CLC                                   ; $DA22: 18
  EOR $00,X                             ; $DA23: 55 00
  RTS                                   ; $DA25: 60
; --- Data Region ---
  .byte $10                               ; $DA26: 10
Loc_DA27:
; --- Code Region ---
  RLA $6800,Y                           ; $DA27: 3B 00 68
  CLC                                   ; $DA2A: 18
Loc_DA2B:
  LSR $00,X                             ; $DA2B: 56 00
  PLA                                   ; $DA2D: 68
  NOP #$35                              ; $DA2E: 80 35
  NOP                                   ; $DA30: DA
  LSR $87DA,X                           ; $DA31: 5E DA 87
  NOP                                   ; $DA34: DA
  BRK                                   ; $DA35: 00
  RLA $3000,X                           ; $DA36: 3F 00 30
  PHP                                   ; $DA39: 08
  NOP $00,X                             ; $DA3A: 74 00
  BMI $DA4E                             ; $DA3C: 30 10
  ADC $00,X                             ; $DA3E: 75 00
  BMI $DA5A                             ; $DA40: 30 18
  ROR $00,X                             ; $DA42: 76 00
  BMI $DA66                             ; $DA44: 30 20
  AND $3000,X                           ; $DA46: 3D 00 30
  BRK                                   ; $DA49: 00
  RRA $4800,Y                           ; $DA4A: 7B 00 48
  PHP                                   ; $DA4D: 08
Loc_DA4E:
  NOP $4800,X                           ; $DA4E: 7C 00 48
  BPL $DAD0                             ; $DA51: 10 7D
  BRK                                   ; $DA53: 00
  PHA                                   ; $DA54: 48
  CLC                                   ; $DA55: 18
  ROR $4800,X                           ; $DA56: 7E 00 48
  JSR $003E                             ; $DA59: 20 3E 00
  PHA                                   ; $DA5C: 48
  NOP #$00                              ; $DA5D: 80 00
  RRA $00,X                             ; $DA5F: 77 00
  BMI $DA6B                             ; $DA61: 30 08
Loc_DA63:
  SEI                                   ; $DA63: 78
  BRK                                   ; $DA64: 00
  BMI $DA77                             ; $DA65: 30 10
  ADC $3000,Y                           ; $DA67: 79 00 30
  CLC                                   ; $DA6A: 18
Loc_DA6B:
  NOP                                   ; $DA6B: 7A
  BRK                                   ; $DA6C: 00
  BMI $DA8F                             ; $DA6D: 30 20
  AND $3000,X                           ; $DA6F: 3D 00 30
  BRK                                   ; $DA72: 00
  RLA $4800,X                           ; $DA73: 3F 00 48
  PHP                                   ; $DA76: 08
Loc_DA77:
  NOP $00,X                             ; $DA77: 74 00
  PHA                                   ; $DA79: 48
  BPL $DAF1                             ; $DA7A: 10 75
  BRK                                   ; $DA7C: 00
  PHA                                   ; $DA7D: 48
  CLC                                   ; $DA7E: 18
  ROR $00,X                             ; $DA7F: 76 00
  PHA                                   ; $DA81: 48
  JSR $003E                             ; $DA82: 20 3E 00
  PHA                                   ; $DA85: 48
  NOP #$00                              ; $DA86: 80 00
  RRA $3000,Y                           ; $DA88: 7B 00 30
  PHP                                   ; $DA8B: 08
  NOP $3000,X                           ; $DA8C: 7C 00 30
Loc_DA8F:
  BPL $DB0E                             ; $DA8F: 10 7D
  BRK                                   ; $DA91: 00
  BMI $DAAC                             ; $DA92: 30 18
  ROR $3000,X                           ; $DA94: 7E 00 30
  JSR $003D                             ; $DA97: 20 3D 00
  BMI $DA9C                             ; $DA9A: 30 00
Loc_DA9C:
  RRA $00,X                             ; $DA9C: 77 00
  PHA                                   ; $DA9E: 48
  PHP                                   ; $DA9F: 08
  SEI                                   ; $DAA0: 78
  BRK                                   ; $DAA1: 00
  PHA                                   ; $DAA2: 48
  BPL $DB1E                             ; $DAA3: 10 79
  BRK                                   ; $DAA5: 00
  PHA                                   ; $DAA6: 48
  CLC                                   ; $DAA7: 18
  NOP                                   ; $DAA8: 7A
  BRK                                   ; $DAA9: 00
  PHA                                   ; $DAAA: 48
  JSR $003E                             ; $DAAB: 20 3E 00
  PHA                                   ; $DAAE: 48
  NOP #$B8                              ; $DAAF: 80 B8
  NOP                                   ; $DAB1: DA
  ORA $DB                               ; $DAB2: 05 DB
  JAM                                   ; $DAB4: 52
  DCP $DB73,Y                           ; $DAB5: DB 73 DB
  JSR $003D                             ; $DAB8: 20 3D 00
  PHA                                   ; $DABB: 48
  PLP                                   ; $DABC: 28
  EOR ($00,X)                           ; $DABD: 41 00
  PHA                                   ; $DABF: 48
  BMI $DB07                             ; $DAC0: 30 45
  BRK                                   ; $DAC2: 00
  PHA                                   ; $DAC3: 48
  CLC                                   ; $DAC4: 18
  NOP                                   ; $DAC5: 3A
  BRK                                   ; $DAC6: 00
  BVC $DAE9                             ; $DAC7: 50 20
  ROL $5000,X                           ; $DAC9: 3E 00 50
  PLP                                   ; $DACC: 28
  JAM                                   ; $DACD: 42
  BRK                                   ; $DACE: 00
  BVC $DB01                             ; $DACF: 50 30
  LSR $00                               ; $DAD1: 46 00
  BVC $DAED                             ; $DAD3: 50 18
  RLA $5800,Y                           ; $DAD5: 3B 00 58
  JSR $003F                             ; $DAD8: 20 3F 00
  CLI                                   ; $DADB: 58
  PLP                                   ; $DADC: 28
  SRE ($00,X)                           ; $DADD: 43 00
  CLI                                   ; $DADF: 58
  BMI $DB29                             ; $DAE0: 30 47
  BRK                                   ; $DAE2: 00
  CLI                                   ; $DAE3: 58
  SEC                                   ; $DAE4: 38
  LSR                                   ; $DAE5: 4A
  BRK                                   ; $DAE6: 00
  CLI                                   ; $DAE7: 58
  CLC                                   ; $DAE8: 18
Loc_DAE9:
  NOP $6000,X                           ; $DAE9: 3C 00 60
  JSR $0040                             ; $DAEC: 20 40 00
  RTS                                   ; $DAEF: 60
; --- Data Region ---
  .byte $28                               ; $DAF0: 28
Loc_DAF1:
; --- Code Region ---
  NOP $00                               ; $DAF1: 44 00
Loc_DAF3:
  RTS                                   ; $DAF3: 60
; --- Data Region ---
  .byte $30,$48,$00,$60,$38,$4B,$00,$60,$30,$49,$00,$68,$38; $DAF4: 30 48 00 60 38 4B 00 60 30 49 00 68 38
Loc_DB01:
; --- Code Region ---
  JMP $6800                             ; $DB01: 4C 00 68
; --- Data Region ---
  .byte $80,$20,$50                       ; $DB04: 80 20 50
Loc_DB07:
; --- Code Region ---
  BRK                                   ; $DB07: 00
Loc_DB08:
  PHA                                   ; $DB08: 48
  PLP                                   ; $DB09: 28
  NOP $00,X                             ; $DB0A: 54 00
  PHA                                   ; $DB0C: 48
  BMI $DB67                             ; $DB0D: 30 58
  BRK                                   ; $DB0F: 00
  PHA                                   ; $DB10: 48
  CLC                                   ; $DB11: 18
  EOR $5000                             ; $DB12: 4D 00 50
  JSR $0051                             ; $DB15: 20 51 00
  BVC $DB42                             ; $DB18: 50 28
  EOR $00,X                             ; $DB1A: 55 00
  BVC $DB4E                             ; $DB1C: 50 30
Loc_DB1E:
  EOR $5000,Y                           ; $DB1E: 59 00 50
  CLC                                   ; $DB21: 18
  LSR $5800                             ; $DB22: 4E 00 58
  JSR $0052                             ; $DB25: 20 52 00
  CLI                                   ; $DB28: 58
Loc_DB29:
  PLP                                   ; $DB29: 28
  LSR $00,X                             ; $DB2A: 56 00
  CLI                                   ; $DB2C: 58
  BMI $DB89                             ; $DB2D: 30 5A
  BRK                                   ; $DB2F: 00
  CLI                                   ; $DB30: 58
  SEC                                   ; $DB31: 38
  EOR $5800,X                           ; $DB32: 5D 00 58
  CLC                                   ; $DB35: 18
  SRE $6000                             ; $DB36: 4F 00 60
  JSR $0053                             ; $DB39: 20 53 00
  RTS                                   ; $DB3C: 60
; --- Data Region ---
  .byte $28                               ; $DB3D: 28
Loc_DB3E:
; --- Code Region ---
  SRE $00,X                             ; $DB3E: 57 00
  RTS                                   ; $DB40: 60
; --- Data Region ---
  .byte $30                               ; $DB41: 30
Loc_DB42:
; --- Code Region ---
  SRE $6000,Y                           ; $DB42: 5B 00 60
  SEC                                   ; $DB45: 38
  LSR $6000,X                           ; $DB46: 5E 00 60
  BMI $DBA7                             ; $DB49: 30 5C
  BRK                                   ; $DB4B: 00
  PLA                                   ; $DB4C: 68
  SEC                                   ; $DB4D: 38
Loc_DB4E:
  SRE $6800,X                           ; $DB4E: 5F 00 68
  NOP #$40                              ; $DB51: 80 40
  RRA ($00,X)                           ; $DB53: 63 00
  CLC                                   ; $DB55: 18
  PHA                                   ; $DB56: 48
  ROR $00                               ; $DB57: 66 00
  CLC                                   ; $DB59: 18
  SEC                                   ; $DB5A: 38
  RTS                                   ; $DB5B: 60
; --- Data Region ---
  .byte $00,$20,$40,$64,$00,$20,$48,$67,$00,$20,$38; $DB5C: 00 20 40 64 00 20 48 67 00 20 38
Loc_DB67:
; --- Code Region ---
  ADC ($00,X)                           ; $DB67: 61 00
  PLP                                   ; $DB69: 28
  RTI                                   ; $DB6A: 40
; --- Data Region ---
  .byte $65,$00,$28,$38,$62,$00,$30,$80,$40,$6B,$00,$18,$48,$6E,$00,$18; $DB6B: 65 00 28 38 62 00 30 80 40 6B 00 18 48 6E 00 18
  .byte $38,$68,$00,$20,$40,$6C,$00,$20,$48,$6F,$00,$20,$38,$69; $DB7B: 38 68 00 20 40 6C 00 20 48 6F 00 20 38 69
Loc_DB89:
; --- Code Region ---
  BRK                                   ; $DB89: 00
  PLP                                   ; $DB8A: 28
  RTI                                   ; $DB8B: 40
; --- Data Region ---
  .byte $6D,$00,$28,$38,$6A,$00,$30,$80,$98,$DB,$D1; $DB8C: 6D 00 28 38 6A 00 30 80 98 DB D1
Loc_DB97:
; --- Code Region ---
  DCP $1F48,Y                           ; $DB97: DB 48 1F
  BRK                                   ; $DB9A: 00
  BRK                                   ; $DB9B: 00
Loc_DB9C:
  RTI                                   ; $DB9C: 40
; --- Data Region ---
  .byte $20                               ; $DB9D: 20
Loc_DB9E:
; --- Code Region ---
  BRK                                   ; $DB9E: 00
  BPL $DBE9                             ; $DB9F: 10 48
  JAM                                   ; $DBA1: 22
  BRK                                   ; $DBA2: 00
  BPL $DBE5                             ; $DBA3: 10 40
  AND ($00,X)                           ; $DBA5: 21 00
Loc_DBA7:
  CLC                                   ; $DBA7: 18
  PHA                                   ; $DBA8: 48
  RLA ($00,X)                           ; $DBA9: 23 00
  CLC                                   ; $DBAB: 18
  RTI                                   ; $DBAC: 40
; --- Data Region ---
  .byte $24,$00,$28,$40,$25,$00,$30,$40,$26,$00,$40,$48,$28,$00,$40,$40; $DBAD: 24 00 28 40 25 00 30 40 26 00 40 48 28 00 40 40
Loc_DBBD:
; --- Code Region ---
  RLA $00                               ; $DBBD: 27 00
  PHA                                   ; $DBBF: 48
  PHA                                   ; $DBC0: 48
  AND #$00                              ; $DBC1: 29 00
  PHA                                   ; $DBC3: 48
  PHA                                   ; $DBC4: 48
  ROL                                   ; $DBC5: 2A
  BRK                                   ; $DBC6: 00
  CLI                                   ; $DBC7: 58
  PHA                                   ; $DBC8: 48
  ANC #$00                              ; $DBC9: 2B 00
  RTS                                   ; $DBCB: 60
; --- Data Region ---
  .byte $48,$2C,$00,$68,$80,$48,$2D,$00,$00,$40,$2E,$00,$10,$48,$30,$00; $DBCC: 48 2C 00 68 80 48 2D 00 00 40 2E 00 10 48 30 00
Loc_DBDC:
; --- Code Region ---
  BPL $DC1E                             ; $DBDC: 10 40
Loc_DBDE:
  RLA $1800                             ; $DBDE: 2F 00 18
  PHA                                   ; $DBE1: 48
  AND ($00),Y                           ; $DBE2: 31 00
  CLC                                   ; $DBE4: 18
Loc_DBE5:
  RTI                                   ; $DBE5: 40
; --- Data Region ---
  .byte $32,$00,$28,$40,$33,$00,$30,$40,$34,$00,$40,$48,$36,$00,$40; $DBE6: 32 00 28 40 33 00 30 40 34 00 40 48 36 00 40
Loc_DBF5:
; --- Code Region ---
  RTI                                   ; $DBF5: 40
; --- Data Region ---
  .byte $35,$00,$48,$48,$37,$00,$48,$48,$38,$00,$58,$48,$39,$00,$60,$48; $DBF6: 35 00 48 48 37 00 48 48 38 00 58 48 39 00 60 48
  .byte $3A,$00,$68,$80,$12,$DC,$17,$DC,$1C,$DC,$3D,$DC,$18,$19,$00,$50; $DC06: 3A 00 68 80 12 DC 17 DC 1C DC 3D DC 18 19 00 50
  .byte $80,$18,$18,$00,$50,$80,$20,$16   ; $DC16: 80 18 18 00 50 80 20 16
Loc_DC1E:
; --- Code Region ---
  BRK                                   ; $DC1E: 00
  JSR $2628                             ; $DC1F: 20 28 26
  BRK                                   ; $DC22: 00
  JSR $1340                             ; $DC23: 20 40 13
  BRK                                   ; $DC26: 00
  JSR $2348                             ; $DC27: 20 48 23
  BRK                                   ; $DC2A: 00
  JSR $1440                             ; $DC2B: 20 40 14
Loc_DC2E:
  BRK                                   ; $DC2E: 00
  PLP                                   ; $DC2F: 28
  PHA                                   ; $DC30: 48
  BIT $00                               ; $DC31: 24 00
  PLP                                   ; $DC33: 28
  RTI                                   ; $DC34: 40
; --- Data Region ---
  .byte $15,$00,$30,$48,$25,$00,$30,$80,$20,$17,$00,$20,$28,$27,$00,$20; $DC35: 15 00 30 48 25 00 30 80 20 17 00 20 28 27 00 20
  .byte $40,$10,$00,$20,$48,$20,$00,$20,$40,$11,$00,$28,$48,$21,$00,$28; $DC45: 40 10 00 20 48 20 00 20 40 11 00 28 48 21 00 28
  .byte $40,$12,$00,$30,$48,$22,$00,$30,$80,$62,$DC,$9F,$DC,$08,$40,$00; $DC55: 40 12 00 30 48 22 00 30 80 62 DC 9F DC 08 40 00
  .byte $20,$08,$41,$00,$28,$10,$50,$00,$20,$10,$51,$00,$28,$18,$60,$00; $DC65: 20 08 41 00 28 10 50 00 20 10 51 00 28 18 60 00
  .byte $20,$18,$61,$00,$28,$20,$70,$00,$20,$20,$71,$00; $DC75: 20 18 61 00 28 20 70 00 20 20 71 00
Loc_DC81:
; --- Code Region ---
  PLP                                   ; $DC81: 28
  PLP                                   ; $DC82: 28
  JAM                                   ; $DC83: 42
  BRK                                   ; $DC84: 00
  JSR $4328                             ; $DC85: 20 28 43
  BRK                                   ; $DC88: 00
  PLP                                   ; $DC89: 28
  BMI $DCDF                             ; $DC8A: 30 53
  BRK                                   ; $DC8C: 00
  PLP                                   ; $DC8D: 28
  BMI $DCE6                             ; $DC8E: 30 56
  BRK                                   ; $DC90: 00
  RTI                                   ; $DC91: 40
; --- Data Region ---
  .byte $38,$66,$00,$40,$38,$67,$00,$48,$30,$46,$00,$60,$80,$08,$44,$00; $DC92: 38 66 00 40 38 67 00 48 30 46 00 60 80 08 44 00
Loc_DCA2:
; --- Code Region ---
  JSR $4508                             ; $DCA2: 20 08 45
  BRK                                   ; $DCA5: 00
  PLP                                   ; $DCA6: 28
  BPL $DCFD                             ; $DCA7: 10 54
  BRK                                   ; $DCA9: 00
  JSR $5510                             ; $DCAA: 20 10 55
  BRK                                   ; $DCAD: 00
  PLP                                   ; $DCAE: 28
  CLC                                   ; $DCAF: 18
  NOP $00                               ; $DCB0: 64 00
  JSR $6518                             ; $DCB2: 20 18 65
  BRK                                   ; $DCB5: 00
  PLP                                   ; $DCB6: 28
  JSR $0074                             ; $DCB7: 20 74 00
  JSR $7520                             ; $DCBA: 20 20 75
  BRK                                   ; $DCBD: 00
  PLP                                   ; $DCBE: 28
  PLP                                   ; $DCBF: 28
  JAM                                   ; $DCC0: 62
  BRK                                   ; $DCC1: 00
  JSR $6328                             ; $DCC2: 20 28 63
  BRK                                   ; $DCC5: 00
  PLP                                   ; $DCC6: 28
  BMI $DD3C                             ; $DCC7: 30 73
  BRK                                   ; $DCC9: 00
  PLP                                   ; $DCCA: 28
  BMI $DD44                             ; $DCCB: 30 77
  BRK                                   ; $DCCD: 00
  RTI                                   ; $DCCE: 40
; --- Data Region ---
  .byte $38,$76,$00,$40,$38,$57,$00,$48,$30,$47,$00,$60,$80,$E2,$DC,$0F; $DCCF: 38 76 00 40 38 57 00 48 30 47 00 60 80 E2 DC 0F
Loc_DCDF:
; --- Code Region ---
  CMP $DD3C,X                           ; $DCDF: DD 3C DD
Loc_DCE2:
  CLC                                   ; $DCE2: 18
  RTI                                   ; $DCE3: 40
; --- Data Region ---
  .byte $00,$18                           ; $DCE4: 00 18
Loc_DCE6:
; --- Code Region ---
  CLC                                   ; $DCE6: 18
  EOR ($00,X)                           ; $DCE7: 41 00
  JSR $4218                             ; $DCE9: 20 18 42
  BRK                                   ; $DCEC: 00
  PLP                                   ; $DCED: 28
  CLC                                   ; $DCEE: 18
  SRE ($00,X)                           ; $DCEF: 43 00
  BMI $DD13                             ; $DCF1: 30 20
  NOP $00                               ; $DCF3: 44 00
  CLC                                   ; $DCF5: 18
  JSR $0045                             ; $DCF6: 20 45 00
  JSR $4620                             ; $DCF9: 20 20 46
  BRK                                   ; $DCFC: 00
Loc_DCFD:
  PLP                                   ; $DCFD: 28
  JSR $0047                             ; $DCFE: 20 47 00
  BMI $DD2B                             ; $DD01: 30 28
  PHA                                   ; $DD03: 48
  BRK                                   ; $DD04: 00
  JSR $4928                             ; $DD05: 20 28 49
  BRK                                   ; $DD08: 00
  PLP                                   ; $DD09: 28
  PLP                                   ; $DD0A: 28
  LSR                                   ; $DD0B: 4A
  BRK                                   ; $DD0C: 00
  BMI $DC8F                             ; $DD0D: 30 80
  CLC                                   ; $DD0F: 18
  ALR #$00                              ; $DD10: 4B 00
  CLC                                   ; $DD12: 18
Loc_DD13:
  CLC                                   ; $DD13: 18
  JMP $2000                             ; $DD14: 4C 00 20
; --- Data Region ---
  .byte $18,$4D,$00,$28,$18,$4E,$00,$30,$20; $DD17: 18 4D 00 28 18 4E 00 30 20
Loc_DD20:
; --- Code Region ---
  SRE $1800                             ; $DD20: 4F 00 18
  JSR $0050                             ; $DD23: 20 50 00
  JSR $5120                             ; $DD26: 20 20 51
  BRK                                   ; $DD29: 00
  PLP                                   ; $DD2A: 28
Loc_DD2B:
  JSR $0052                             ; $DD2B: 20 52 00
  BMI $DD58                             ; $DD2E: 30 28
  SRE ($00),Y                           ; $DD30: 53 00
  JSR $5428                             ; $DD32: 20 28 54
  BRK                                   ; $DD35: 00
  PLP                                   ; $DD36: 28
  PLP                                   ; $DD37: 28
  EOR $00,X                             ; $DD38: 55 00
  BMI $DCBC                             ; $DD3A: 30 80
Loc_DD3C:
  CLC                                   ; $DD3C: 18
  ALR #$00                              ; $DD3D: 4B 00
  CLC                                   ; $DD3F: 18
  CLC                                   ; $DD40: 18
  LSR $00,X                             ; $DD41: 56 00
  JSR $5718                             ; $DD43: 20 18 57
  BRK                                   ; $DD46: 00
  PLP                                   ; $DD47: 28
  CLC                                   ; $DD48: 18
  CLI                                   ; $DD49: 58
  BRK                                   ; $DD4A: 00
  BMI $DD6D                             ; $DD4B: 30 20
  SRE $1800                             ; $DD4D: 4F 00 18
  JSR $0059                             ; $DD50: 20 59 00
  JSR $5A20                             ; $DD53: 20 20 5A
  BRK                                   ; $DD56: 00
  PLP                                   ; $DD57: 28
Loc_DD58:
  JSR $005B                             ; $DD58: 20 5B 00
  BMI $DD85                             ; $DD5B: 30 28
  NOP $2000,X                           ; $DD5D: 5C 00 20
  PLP                                   ; $DD60: 28
  EOR $2800,X                           ; $DD61: 5D 00 28
  PLP                                   ; $DD64: 28
  LSR $3000,X                           ; $DD65: 5E 00 30
  NOP #$6F                              ; $DD68: 80 6F
  CMP $DDA0,X                           ; $DD6A: DD A0 DD
Loc_DD6D:
  CMP ($DD),Y                           ; $DD6D: D1 DD
  PHP                                   ; $DD6F: 08
  BVS $DD72                             ; $DD70: 70 00
Loc_DD72:
  BMI $DD7C                             ; $DD72: 30 08
  BVS $DD76                             ; $DD74: 70 00
Loc_DD76:
  CLI                                   ; $DD76: 58
  BPL $DDF4                             ; $DD77: 10 7B
  BRK                                   ; $DD79: 00
  PHP                                   ; $DD7A: 08
  BPL $DDEB                             ; $DD7B: 10 6E
  BRK                                   ; $DD7D: 00
  PHA                                   ; $DD7E: 48
  CLC                                   ; $DD7F: 18
  BVS $DD82                             ; $DD80: 70 00
Loc_DD82:
  CLC                                   ; $DD82: 18
  CLC                                   ; $DD83: 18
  RRA $3000,Y                           ; $DD84: 7B 00 30
  JSR $006E                             ; $DD87: 20 6E 00
  BRK                                   ; $DD8A: 00
  JSR $0071                             ; $DD8B: 20 71 00
  BPL $DDB0                             ; $DD8E: 10 20
  ROR $2800                             ; $DD90: 6E 00 28
  JSR $007B                             ; $DD93: 20 7B 00
  RTI                                   ; $DD96: 40
; --- Data Region ---
  .byte $20,$6E,$00,$58,$20,$7D,$00,$68,$80,$08,$7B,$00,$10,$08,$6E,$00; $DD97: 20 6E 00 58 20 7D 00 68 80 08 7B 00 10 08 6E 00
  .byte $40,$10,$6E,$00,$20,$10,$70,$00,$38; $DDA7: 40 10 6E 00 20 10 70 00 38
Loc_DDB0:
; --- Code Region ---
  BPL $DE22                             ; $DDB0: 10 70
  BRK                                   ; $DDB2: 00
  BVC $DDCD                             ; $DDB3: 50 18
  ROR $0800                             ; $DDB5: 6E 00 08
  CLC                                   ; $DDB8: 18
  ROR $3800                             ; $DDB9: 6E 00 38
  CLC                                   ; $DDBC: 18
  ADC $4800,X                           ; $DDBD: 7D 00 48
  CLC                                   ; $DDC0: 18
  RRA $6000,Y                           ; $DDC1: 7B 00 60
  JSR $007B                             ; $DDC4: 20 7B 00
  CLC                                   ; $DDC7: 18
  PLP                                   ; $DDC8: 28
  ADC ($00),Y                           ; $DDC9: 71 00
  BMI $DDF5                             ; $DDCB: 30 28
Loc_DDCD:
  NOP                                   ; $DDCD: 7A
  BRK                                   ; $DDCE: 00
  PHA                                   ; $DDCF: 48
  NOP #$00                              ; $DDD0: 80 00
  BVS $DDD4                             ; $DDD2: 70 00
Loc_DDD4:
  RTI                                   ; $DDD4: 40
; --- Data Region ---
  .byte $08,$6E,$00,$20,$10,$7B,$00,$10,$10,$70,$00; $DDD5: 08 6E 00 20 10 7B 00 10 10 70 00
Loc_DDE0:
; --- Code Region ---
  RTI                                   ; $DDE0: 40
; --- Data Region ---
  .byte $10,$7C,$00,$60,$18,$6E,$00,$58,$20,$6E; $DDE1: 10 7C 00 60 18 6E 00 58 20 6E
Loc_DDEB:
; --- Code Region ---
  BRK                                   ; $DDEB: 00
  PHP                                   ; $DDEC: 08
  PLP                                   ; $DDED: 28
Loc_DDEE:
  NOP                                   ; $DDEE: 7A
  BRK                                   ; $DDEF: 00
  JSR $7128                             ; $DDF0: 20 28 71
  BRK                                   ; $DDF3: 00
Loc_DDF4:
  SEC                                   ; $DDF4: 38
Loc_DDF5:
  PLP                                   ; $DDF5: 28
  NOP                                   ; $DDF6: 7A
  BRK                                   ; $DDF7: 00
  CLI                                   ; $DDF8: 58
  NOP #$FC                              ; $DDF9: 80 FC
  CMP $6400,X                           ; $DDFB: DD 00 64
  BRK                                   ; $DDFE: 00
  PLP                                   ; $DDFF: 28
  PHP                                   ; $DE00: 08
  ARR #$00                              ; $DE01: 6B 00
  PHA                                   ; $DE03: 48
  PHP                                   ; $DE04: 08
  JMP ($5000)                           ; $DE05: 6C 00 50
; --- Data Region ---
  .byte $10,$64,$00,$38,$10,$6D,$00,$48,$10,$6E,$00,$50,$18,$6B,$00,$20; $DE08: 10 64 00 38 10 6D 00 48 10 6E 00 50 18 6B 00 20
Loc_DE18:
; --- Code Region ---
  CLC                                   ; $DE18: 18
  JMP ($2800)                           ; $DE19: 6C 00 28
; --- Data Region ---
  .byte $18,$65,$00,$58,$20,$6D           ; $DE1C: 18 65 00 58 20 6D
Loc_DE22:
; --- Code Region ---
  BRK                                   ; $DE22: 00
  JSR $6E20                             ; $DE23: 20 20 6E
  BRK                                   ; $DE26: 00
  PLP                                   ; $DE27: 28
  PLP                                   ; $DE28: 28
  ADC $00                               ; $DE29: 65 00
  PHP                                   ; $DE2B: 08
  NOP #$FF                              ; $DE2C: 80 FF
  ISB $FFFF,X                           ; $DE2E: FF FF FF
  ISB $FFFF,X                           ; $DE31: FF FF FF
  ISB $FFFF,X                           ; $DE34: FF FF FF
  ISB $FFFF,X                           ; $DE37: FF FF FF
  ISB $FFFF,X                           ; $DE3A: FF FF FF
  ISB $FFFF,X                           ; $DE3D: FF FF FF
  ISB $FFFF,X                           ; $DE40: FF FF FF
  ISB $FFFF,X                           ; $DE43: FF FF FF
  ISB $FFFF,X                           ; $DE46: FF FF FF
  ISB $FFFF,X                           ; $DE49: FF FF FF
  ISB $FFFF,X                           ; $DE4C: FF FF FF
  ISB $FFFF,X                           ; $DE4F: FF FF FF
  ISB $FFFF,X                           ; $DE52: FF FF FF
  ISB $FFFF,X                           ; $DE55: FF FF FF
  ISB $FFFF,X                           ; $DE58: FF FF FF
  ISB $FFFF,X                           ; $DE5B: FF FF FF
  ISB $FFFF,X                           ; $DE5E: FF FF FF
  ISB $FFFF,X                           ; $DE61: FF FF FF
  ISB $FFFF,X                           ; $DE64: FF FF FF
  ISB $FFFF,X                           ; $DE67: FF FF FF
  ISB $FFFF,X                           ; $DE6A: FF FF FF
  ISB $FFFF,X                           ; $DE6D: FF FF FF
  ISB $FFFF,X                           ; $DE70: FF FF FF
  ISB $FFFF,X                           ; $DE73: FF FF FF
  ISB $FFFF,X                           ; $DE76: FF FF FF
  ISB $FFFF,X                           ; $DE79: FF FF FF
  ISB $FFFF,X                           ; $DE7C: FF FF FF
  ISB $FFFF,X                           ; $DE7F: FF FF FF
  ISB $FFFF,X                           ; $DE82: FF FF FF
  ISB $FFFF,X                           ; $DE85: FF FF FF
  ISB $FFFF,X                           ; $DE88: FF FF FF
  ISB $FFFF,X                           ; $DE8B: FF FF FF
  ISB $FFFF,X                           ; $DE8E: FF FF FF
  ISB $FFFF,X                           ; $DE91: FF FF FF
  ISB $FFFF,X                           ; $DE94: FF FF FF
  ISB $FFFF,X                           ; $DE97: FF FF FF
  ISB $FFFF,X                           ; $DE9A: FF FF FF
  ISB $FFFF,X                           ; $DE9D: FF FF FF
  ISB $FFFF,X                           ; $DEA0: FF FF FF
  ISB $FFFF,X                           ; $DEA3: FF FF FF
  ISB $FFFF,X                           ; $DEA6: FF FF FF
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
