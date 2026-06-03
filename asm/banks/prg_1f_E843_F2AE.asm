;===============================================================================
; Sangokushi 2 - Haou no Tairiku (J) - Bank $1F Disassembly
; Address Range: $E843-$F2AE
; Generated from: rom/prg/prg_1f.bin (offset $0843-$12AE)
; Base address: $E000 (Bank $1F fixed at $E000-$FFFF)
;===============================================================================

.include "include/6502_registers.h"
.include "include/namco163.h"

.segment "CODE_BANK1F"

;===============================================================================
; RAM Address Definitions (used in this range)
;===============================================================================
addr_rng_index       = $0050
addr_rng_saved_x     = $0051
addr_rng2_index      = $0052
addr_rng_temp_x      = $0053
addr_rng3_index      = $0054
addr_rng4_index      = $0055
addr_trampoline_saved_bank = $0058
addr_trampoline_ret_lo     = $0059
addr_trampoline_ret_hi     = $005A
addr_trampoline_target_lo  = $005B
addr_trampoline_target_hi  = $005C
addr_trampoline_bank_param = $005D
addr_sprite_count    = $007C
addr_nmi_flag        = $007D
addr_nmi_ctrl        = $007E
addr_pad1_edge       = $0081
addr_anim_direction  = $0087
addr_anim_frame      = $0088
addr_anim_speed      = $0089
addr_anim_counter    = $008A
addr_ppu_ctrl_ram    = $008B
addr_scroll_x        = $008E
addr_scroll_x_hi     = $008F
addr_scroll_y        = $0090
addr_scroll_y_hi     = $0091
addr_input_prev_x    = $0094
addr_input_prev_y    = $0095
addr_ctrl_state_x    = $009C
addr_ctrl_state_y    = $009D
addr_chr_bank_0      = $00AE
addr_chr_bank_1      = $00AF
addr_chr_bank_2      = $00B0
addr_chr_bank_3      = $00B1
addr_chr_bank_4      = $00B2
addr_chr_bank_5      = $00B3
addr_chr_bank_6      = $00B4
addr_chr_bank_7      = $00B5
addr_prg_select_1a   = $00DE
addr_prg_select_2a   = $00DF
addr_prg_select_3a   = $00E0
addr_prg_select_1b   = $00E1
addr_prg_select_2b   = $00E2
addr_prg_select_3b   = $00E3
addr_menu_column     = $0424
addr_menu_page       = $0425

;===============================================================================
; $E843: Random Below 100
; Returns: A = random value in range [0, 99]
;===============================================================================
.proc RandomBelow100
@loop:
  JSR RandomByte                                ; $E843: 20 7A E8
  CMP #$64                                      ; $E846: C9 64
  BCS @loop                                     ; $E848: B0 F9
  RTS                                           ; $E84A: 60
.endproc

;===============================================================================
; $E84B: Random Div 2
; Returns: A = random byte / 2 (range [0, 127])
;===============================================================================
.proc RandomDiv2
  JSR RandomByte                                ; $E84B: 20 7A E8
  LSR                                           ; $E84E: 4A
  RTS                                           ; $E84F: 60
.endproc

;===============================================================================
; $E850: Random Mod Power of 2
; Multiple entry points: RandomMod4, RandomMod8, RandomMod16
;===============================================================================
.proc RandomModPow2
RandomMod4:
  JSR RandomByte                                ; $E850: 20 7A E8
  AND #$03                                      ; $E853: 29 03
  RTS                                           ; $E855: 60

RandomMod8:
  JSR RandomByte                                ; $E856: 20 7A E8
  AND #$07                                      ; $E859: 29 07
  RTS                                           ; $E85B: 60

RandomMod16:
  JSR RandomByte                                ; $E85C: 20 7A E8
  AND #$0F                                      ; $E85F: 29 0F
  RTS                                           ; $E861: 60
.endproc

;===============================================================================
; $E862: Random Below Threshold
; Input: A = threshold (max value exclusive)
; Returns: A = random value in [0, threshold-1]
; If threshold < 15, uses AND #$0F mask optimization
;===============================================================================
.proc RandomBelowThreshold
threshold = $10

  STA threshold                                 ; $E862: 85 10
  CMP #$0F                                      ; $E864: C9 0F
  BCS @full_range                               ; $E866: B0 0A
@loop_masked:
  JSR RandomByte                                ; $E868: 20 7A E8
  AND #$0F                                      ; $E86B: 29 0F
  CMP threshold                                 ; $E86D: C5 10
  BCS @loop_masked                              ; $E86F: B0 F7
  RTS                                           ; $E871: 60
@full_range:
  JSR RandomByte                                ; $E872: 20 7A E8
  CMP threshold                                 ; $E875: C5 10
  BCS @full_range                               ; $E877: B0 F9
  RTS                                           ; $E879: 60
.endproc

;===============================================================================
; $E87A: Random Byte (RNG Core)
; Table lookup using index at $0050, table at $E8BA
; Returns: A = pseudo-random byte
; Preserves: X (saved/restored via $0051)
;===============================================================================
.proc RandomByte
  STX addr_rng_saved_x                          ; $E87A: 8E 51 00
  LDX addr_rng_index                            ; $E87D: AE 50 00
  LDA RandomTable,X                             ; $E880: BD BA E8
  INC addr_rng_index                            ; $E883: EE 50 00
  LDX addr_rng_saved_x                          ; $E886: AE 51 00
  RTS                                           ; $E889: 60
.endproc

;===============================================================================
; $E88A: Random Variants (3 additional RNG instances)
; RandomByte2 uses index at $0052
; RandomByte3 uses index at $0054
; RandomByte4 uses index at $0055
;===============================================================================
.proc RandomVariants
RandomByte2:
  STX addr_rng_temp_x                           ; $E88A: 8E 53 00
  LDX addr_rng2_index                           ; $E88D: AE 52 00
  LDA RandomTable,X                             ; $E890: BD BA E8
  INC addr_rng2_index                           ; $E893: EE 52 00
  LDX addr_rng_temp_x                           ; $E896: AE 53 00
  RTS                                           ; $E899: 60

RandomByte3:
  STX addr_rng_temp_x                           ; $E89A: 8E 53 00
  LDX addr_rng3_index                           ; $E89D: AE 54 00
  LDA RandomTable,X                             ; $E8A0: BD BA E8
  INC addr_rng3_index                           ; $E8A3: EE 54 00
  LDX addr_rng_temp_x                           ; $E8A6: AE 53 00
  RTS                                           ; $E8A9: 60

RandomByte4:
  STX addr_rng_temp_x                           ; $E8AA: 8E 53 00
  LDX addr_rng4_index                           ; $E8AD: AE 55 00
  LDA RandomTable,X                             ; $E8B0: BD BA E8
  INC addr_rng4_index                           ; $E8B3: EE 55 00
  LDX addr_rng_temp_x                           ; $E8B6: AE 53 00
  RTS                                           ; $E8B9: 60
.endproc

;===============================================================================
; $E8BA-$E9B9: Random Number Table (256 bytes)
; Pre-computed permutation table for RNG
;===============================================================================
RandomTable:
  .byte $3E,$4E,$4F,$83,$0E,$C9,$7F,$5D         ; $E8BA: 3E 4E 4F 83 0E C9 7F 5D
  .byte $FC,$E6,$BA,$01,$F8,$00,$F4,$0A         ; $E8C2: FC E6 BA 01 F8 00 F4 0A
  .byte $E5,$A9,$8D,$D1,$E8,$DB,$DE,$81         ; $E8CA: E5 A9 8D D1 E8 DB DE 81
  .byte $95,$72,$08,$9A,$C7,$49,$C8,$23         ; $E8D2: 95 72 08 9A C7 49 C8 23
  .byte $39,$37,$E0,$91,$C3,$33,$9B,$5F         ; $E8DA: 39 37 E0 91 C3 33 9B 5F
  .byte $BE,$41,$EE,$74,$E2,$0B,$47,$7E         ; $E8E2: BE 41 EE 74 E2 0B 47 7E
  .byte $BF,$60,$BB,$20,$61,$05,$B2,$94         ; $E8EA: BF 60 BB 20 61 05 B2 94
  .byte $B6,$E4,$3A,$21,$1E,$B4,$8C,$CE         ; $E8F2: B6 E4 3A 21 1E B4 8C CE
  .byte $7B,$FE,$22,$DC,$18,$C4,$6D,$FB         ; $E8FA: 7B FE 22 DC 18 C4 6D FB
  .byte $CD,$27,$A0,$09,$6E,$38,$8A,$04         ; $E902: CD 27 A0 09 6E 38 8A 04
  .byte $7C,$56,$97,$5A,$A8,$4D,$78,$B5         ; $E90A: 7C 56 97 5A A8 4D 78 B5
  .byte $6C,$AA,$03,$1A,$4A,$0D,$26,$82         ; $E912: 6C AA 03 1A 4A 0D 26 82
  .byte $AD,$02,$A1,$B9,$A3,$6B,$D8,$0C         ; $E91A: AD 02 A1 B9 A3 6B D8 0C
  .byte $4C,$AE,$19,$45,$5B,$9C,$16,$07         ; $E922: 4C AE 19 45 5B 9C 16 07
  .byte $89,$51,$90,$29,$F5,$62,$F7,$CB         ; $E92A: 89 51 90 29 F5 62 F7 CB
  .byte $F1,$53,$FF,$14,$65,$D0,$87,$35         ; $E932: F1 53 FF 14 65 D0 87 35
  .byte $10,$73,$7A,$9F,$EB,$D9,$3C,$EF         ; $E93A: 10 73 7A 9F EB D9 3C EF
  .byte $9E,$D7,$3D,$6F,$D6,$84,$AB,$11         ; $E942: 9E D7 3D 6F D6 84 AB 11
  .byte $CA,$D2,$88,$17,$E1,$A6,$52,$8E         ; $E94A: CA D2 88 17 E1 A6 52 8E
  .byte $5E,$36,$24,$44,$28,$A4,$55,$A7         ; $E952: 5E 36 24 44 28 A4 55 A7
  .byte $C2,$FD,$76,$2E,$B7,$D5,$F6,$64         ; $E95A: C2 FD 76 2E B7 D5 F6 64
  .byte $15,$31,$99,$93,$C0,$8F,$B3,$FA         ; $E962: 15 31 99 93 C0 8F B3 FA
  .byte $E9,$E3,$67,$4B,$85,$32,$C6,$69         ; $E96A: E9 E3 67 4B 85 32 C6 69
  .byte $48,$DF,$A2,$EC,$98,$6A,$E7,$D4         ; $E972: 48 DF A2 EC 98 6A E7 D4
  .byte $1C,$F3,$58,$50,$ED,$2B,$1D,$86         ; $E97A: 1C F3 58 50 ED 2B 1D 86
  .byte $F0,$71,$BD,$34,$1B,$AF,$30,$2D         ; $E982: F0 71 BD 34 1B AF 30 2D
  .byte $68,$CC,$0F,$57,$EA,$92,$8B,$3F         ; $E98A: 68 CC 0F 57 EA 92 8B 3F
  .byte $3B,$AC,$B8,$C1,$2F,$F2,$46,$75         ; $E992: 3B AC B8 C1 2F F2 46 75
  .byte $96,$7D,$2A,$79,$40,$DA,$9D,$25         ; $E99A: 96 7D 2A 79 40 DA 9D 25
  .byte $12,$42,$54,$D3,$1F,$80,$5C,$59         ; $E9A2: 12 42 54 D3 1F 80 5C 59
  .byte $43,$F9,$B0,$DD,$63,$A5,$77,$CF         ; $E9AA: 43 F9 B0 DD 63 A5 77 CF
  .byte $13,$2C,$66,$BC,$70,$B1,$C5,$06         ; $E9B2: 13 2C 66 BC 70 B1 C5 06

;===============================================================================
; $E9BA: Math - Binary to BCD (24-bit)
; Input: $01/$02/$03 = 24-bit binary value (LE, mod 1,000,000)
; Output: $07 = tens|ones, $08 = thousands|hundreds, $09 = hthou|tthou
; Clobbers: $01-$05
;===============================================================================
.proc MathBinToBcd
dividend_lo   = $01
dividend_mid  = $02
dividend_hi   = $03
temp_lo       = $04
temp_mid      = $05
bcd_tens_ones = $07
bcd_thou_hund = $08
bcd_htth_tth  = $09

  LDA #$00                                      ; $E9BA: A9 00
  STA bcd_tens_ones                             ; $E9BC: 85 07
  STA bcd_thou_hund                             ; $E9BE: 85 08
  STA bcd_htth_tth                              ; $E9C0: 85 09

  ; Subtract 1,000,000 ($0F4240) repeatedly - clamping
@clamp_million:
  LDA dividend_lo                               ; $E9C2: A5 01
  SEC                                           ; $E9C4: 38
  SBC #$40                                      ; $E9C5: E9 40
  STA temp_lo                                   ; $E9C7: 85 04
  LDA dividend_mid                              ; $E9C9: A5 02
  SBC #$42                                      ; $E9CB: E9 42
  STA temp_mid                                  ; $E9CD: 85 05
  LDA dividend_hi                               ; $E9CF: A5 03
  SBC #$0F                                      ; $E9D1: E9 0F
  BCC @sub_100k                                 ; $E9D3: 90 0D
  STA dividend_hi                               ; $E9D5: 85 03
  LDA temp_lo                                   ; $E9D7: A5 04
  STA dividend_lo                               ; $E9D9: 85 01
  LDA temp_mid                                  ; $E9DB: A5 05
  STA dividend_mid                              ; $E9DD: 85 02
  JMP @clamp_million                            ; $E9DF: 4C C2 E9

  ; Subtract 100,000 ($0186A0) -> hundred-thousands digit
@sub_100k:
  LDA dividend_lo                               ; $E9E2: A5 01
  SEC                                           ; $E9E4: 38
  SBC #$A0                                      ; $E9E5: E9 A0
  STA temp_lo                                   ; $E9E7: 85 04
  LDA dividend_mid                              ; $E9E9: A5 02
  SBC #$86                                      ; $E9EB: E9 86
  STA temp_mid                                  ; $E9ED: 85 05
  LDA dividend_hi                               ; $E9EF: A5 03
  SBC #$01                                      ; $E9F1: E9 01
  BCC @sub_10k                                  ; $E9F3: 90 12
  STA dividend_hi                               ; $E9F5: 85 03
  LDA temp_lo                                   ; $E9F7: A5 04
  STA dividend_lo                               ; $E9F9: 85 01
  LDA temp_mid                                  ; $E9FB: A5 05
  STA dividend_mid                              ; $E9FD: 85 02
  LDA bcd_htth_tth                              ; $E9FF: A5 09
  ADC #$0F                                      ; $EA01: 69 0F
  STA bcd_htth_tth                              ; $EA03: 85 09
  BNE @sub_100k                                 ; $EA05: D0 DB

  ; Subtract 10,000 ($002710) -> ten-thousands digit
@sub_10k:
  LDA dividend_lo                               ; $EA07: A5 01
  SEC                                           ; $EA09: 38
  SBC #$10                                      ; $EA0A: E9 10
  STA temp_lo                                   ; $EA0C: 85 04
  LDA dividend_mid                              ; $EA0E: A5 02
  SBC #$27                                      ; $EA10: E9 27
  STA temp_mid                                  ; $EA12: 85 05
  LDA dividend_hi                               ; $EA14: A5 03
  SBC #$00                                      ; $EA16: E9 00
  BCC @sub_1k                                   ; $EA18: 90 0E
  STA dividend_hi                               ; $EA1A: 85 03
  LDA temp_lo                                   ; $EA1C: A5 04
  STA dividend_lo                               ; $EA1E: 85 01
  LDA temp_mid                                  ; $EA20: A5 05
  STA dividend_mid                              ; $EA22: 85 02
  INC bcd_htth_tth                              ; $EA24: E6 09
  BNE @sub_10k                                  ; $EA26: D0 DF

  ; Subtract 1,000 ($03E8) -> thousands digit
@sub_1k:
  LDA dividend_lo                               ; $EA28: A5 01
  SEC                                           ; $EA2A: 38
  SBC #$E8                                      ; $EA2B: E9 E8
  STA temp_lo                                   ; $EA2D: 85 04
  LDA dividend_mid                              ; $EA2F: A5 02
  SBC #$03                                      ; $EA31: E9 03
  BCC @sub_100                                  ; $EA33: 90 0E
  STA dividend_mid                              ; $EA35: 85 02
  LDA temp_lo                                   ; $EA37: A5 04
  STA dividend_lo                               ; $EA39: 85 01
  LDA bcd_thou_hund                             ; $EA3B: A5 08
  ADC #$0F                                      ; $EA3D: 69 0F
  STA bcd_thou_hund                             ; $EA3F: 85 08
  BNE @sub_1k                                   ; $EA41: D0 E5

  ; Subtract 100 ($0064) -> hundreds digit
@sub_100:
  LDA dividend_lo                               ; $EA43: A5 01
  SEC                                           ; $EA45: 38
  SBC #$64                                      ; $EA46: E9 64
  STA temp_lo                                   ; $EA48: 85 04
  LDA dividend_mid                              ; $EA4A: A5 02
  SBC #$00                                      ; $EA4C: E9 00
  BCC @sub_10                                   ; $EA4E: 90 0A
  STA dividend_mid                              ; $EA50: 85 02
  LDA temp_lo                                   ; $EA52: A5 04
  STA dividend_lo                               ; $EA54: 85 01
  INC bcd_thou_hund                             ; $EA56: E6 08
  BNE @sub_100                                  ; $EA58: D0 E9

  ; Subtract 10 ($000A) -> tens digit
@sub_10:
  LDA dividend_lo                               ; $EA5A: A5 01
  SEC                                           ; $EA5C: 38
  SBC #$0A                                      ; $EA5D: E9 0A
  STA temp_lo                                   ; $EA5F: 85 04
  LDA dividend_mid                              ; $EA61: A5 02
  SBC #$00                                      ; $EA63: E9 00
  BCC @final                                    ; $EA65: 90 0E
  STA dividend_mid                              ; $EA67: 85 02
  LDA temp_lo                                   ; $EA69: A5 04
  STA dividend_lo                               ; $EA6B: 85 01
  LDA bcd_tens_ones                             ; $EA6D: A5 07
  ADC #$0F                                      ; $EA6F: 69 0F
  STA bcd_tens_ones                             ; $EA71: 85 07
  BNE @sub_10                                   ; $EA73: D0 E5

  ; Remainder = ones digit
@final:
  LDA dividend_lo                               ; $EA75: A5 01
  ORA bcd_tens_ones                             ; $EA77: 05 07
  STA bcd_tens_ones                             ; $EA79: 85 07
  RTS                                           ; $EA7B: 60
.endproc

;===============================================================================
; $EA7C: Math - 16-bit Unsigned Division
; Input: $01/$02 = dividend (16-bit), $03/$04 = divisor (16-bit)
; Output: $01/$02 = quotient, $05/$06 = remainder
;===============================================================================
.proc MathDiv16
dividend_lo   = $01
dividend_hi   = $02
divisor_lo    = $03
divisor_hi    = $04
remainder_lo  = $05
remainder_hi  = $06
temp          = $07

  LDA #$00                                      ; $EA7C: A9 00
  STA remainder_lo                              ; $EA7E: 85 05
  STA remainder_hi                              ; $EA80: 85 06
  LDY #$0F                                      ; $EA82: A0 0F
@loop:
  ASL dividend_lo                               ; $EA84: 06 01
  ROL dividend_hi                               ; $EA86: 26 02
  ROL remainder_lo                              ; $EA88: 26 05
  ROL remainder_hi                              ; $EA8A: 26 06
  LDA remainder_lo                              ; $EA8C: A5 05
  SEC                                           ; $EA8E: 38
  SBC divisor_lo                                ; $EA8F: E5 03
  STA temp                                      ; $EA91: 85 07
  LDA remainder_hi                              ; $EA93: A5 06
  SBC divisor_hi                                ; $EA95: E5 04
  BCC @skip                                     ; $EA97: 90 08
  STA remainder_hi                              ; $EA99: 85 06
  LDA temp                                      ; $EA9B: A5 07
  STA remainder_lo                              ; $EA9D: 85 05
  INC dividend_lo                               ; $EA9F: E6 01
@skip:
  DEY                                           ; $EAA1: 88
  BPL @loop                                     ; $EAA2: 10 E0
  RTS                                           ; $EAA4: 60
.endproc

;===============================================================================
; $EAA5: Math - 24-bit Unsigned Division
; Input: $00/$01/$02 = dividend (24-bit), $03/$04 = divisor (16-bit)
; Output: $00/$01/$02 = quotient, $05/$06/$07 = remainder
;===============================================================================
.proc MathDiv24
dividend_b0   = $00
dividend_b1   = $01
dividend_b2   = $02
divisor_lo    = $03
divisor_hi    = $04
remainder_b0  = $05
remainder_b1  = $06
remainder_b2  = $07
temp_b0       = $08
temp_b1       = $09

  LDA #$00                                      ; $EAA5: A9 00
  STA remainder_b0                              ; $EAA7: 85 05
  STA remainder_b1                              ; $EAA9: 85 06
  STA remainder_b2                              ; $EAAB: 85 07
  LDY #$17                                      ; $EAAD: A0 17
@loop:
  ASL dividend_b0                               ; $EAAF: 06 00
  ROL dividend_b1                               ; $EAB1: 26 01
  ROL dividend_b2                               ; $EAB3: 26 02
  ROL remainder_b0                              ; $EAB5: 26 05
  ROL remainder_b1                              ; $EAB7: 26 06
  ROL remainder_b2                              ; $EAB9: 26 07
  LDA remainder_b0                              ; $EABB: A5 05
  SEC                                           ; $EABD: 38
  SBC divisor_lo                                ; $EABE: E5 03
  STA temp_b0                                   ; $EAC0: 85 08
  LDA remainder_b1                              ; $EAC2: A5 06
  SBC divisor_hi                                ; $EAC4: E5 04
  STA temp_b1                                   ; $EAC6: 85 09
  LDA remainder_b2                              ; $EAC8: A5 07
  SBC #$00                                      ; $EACA: E9 00
  BCC @skip                                     ; $EACC: 90 0C
  STA remainder_b2                              ; $EACE: 85 07
  LDA temp_b0                                   ; $EAD0: A5 08
  STA remainder_b0                              ; $EAD2: 85 05
  LDA temp_b1                                   ; $EAD4: A5 09
  STA remainder_b1                              ; $EAD6: 85 06
  INC dividend_b0                               ; $EAD8: E6 00
@skip:
  DEY                                           ; $EADA: 88
  BPL @loop                                     ; $EADB: 10 D2
  RTS                                           ; $EADD: 60
.endproc

;===============================================================================
; $EADE: Callback Dispatcher (Indirect Jump via Inline Table)
; Input: A = index into table, Y = parameter
; The caller's inline word table follows the JSR instruction
; Usage: JSR CallbackDispatcher; .word handler0, handler1, ...
;===============================================================================
.proc CallbackDispatcher
param         = $00
ret_addr_lo   = $01
ret_addr_hi   = $02
target_lo     = $03
target_hi     = $04

  STY param                                     ; $EADE: 84 00
  ASL                                           ; $EAE0: 0A
  TAY                                           ; $EAE1: A8
  INY                                           ; $EAE2: C8
  PLA                                           ; $EAE3: 68
  STA ret_addr_lo                               ; $EAE4: 85 01
  PLA                                           ; $EAE6: 68
  STA ret_addr_hi                               ; $EAE7: 85 02
  LDA (ret_addr_lo),Y                           ; $EAE9: B1 01
  STA target_lo                                 ; $EAEB: 85 03
  INY                                           ; $EAED: C8
  LDA (ret_addr_lo),Y                           ; $EAEE: B1 01
  STA target_hi                                 ; $EAF0: 85 04
  LDY param                                     ; $EAF2: A4 00
  JMP (target_lo)                               ; $EAF4: 6C 03 00
.endproc

;===============================================================================
; $EAF7: Scroll Set
; Writes scroll_x ($008E) and scroll_y ($0090) to PPU_SCROLL
; Then updates PPU_CTRL nametable select bits from $008F
;===============================================================================
.proc ScrollSet
  LDA addr_scroll_x                             ; $EAF7: AD 8E 00
  STA $2005                                     ; $EAFA: 8D 05 20
  LDA addr_scroll_y                             ; $EAFD: AD 90 00
  STA $2005                                     ; $EB00: 8D 05 20
  LDA addr_ppu_ctrl_ram                         ; $EB03: AD 8B 00
  AND #$FE                                      ; $EB06: 29 FE
  STA addr_ppu_ctrl_ram                         ; $EB08: 8D 8B 00
  LDA addr_scroll_x_hi                          ; $EB0B: AD 8F 00
  AND #$01                                      ; $EB0E: 29 01
  ORA addr_ppu_ctrl_ram                         ; $EB10: 0D 8B 00
  STA addr_ppu_ctrl_ram                         ; $EB13: 8D 8B 00
  STA $2000                                     ; $EB16: 8D 00 20
  RTS                                           ; $EB19: 60
.endproc

;===============================================================================
; $EB1A: Window Reset
; Sets PPU_ADDR to $0250, zeros scroll registers
;===============================================================================
.proc WindowReset
  LDA #$02                                      ; $EB1A: A9 02
  STA $2006                                     ; $EB1C: 8D 06 20
  LDA #$50                                      ; $EB1F: A9 50
  STA $2006                                     ; $EB21: 8D 06 20
  LDA #$00                                      ; $EB24: A9 00
  STA $2005                                     ; $EB26: 8D 05 20
  STA $2005                                     ; $EB29: 8D 05 20
  RTS                                           ; $EB2C: 60
.endproc

;===============================================================================
; $EB2D: Math - BCD to Binary
; Input: $0A = tens|ones, $0B = thou|hund, $0C = hthou|tthou (packed BCD)
; Output: $0D/$0E/$0F = 24-bit binary result
;===============================================================================
.proc MathBcdToBin
bcd_tens_ones = $0A
bcd_thou_hund = $0B
bcd_htth_tth  = $0C
result_b0     = $0D
result_b1     = $0E
result_b2     = $0F
mul_lo        = $00
mul_mid       = $01
mul_hi        = $02
multiplier    = $03

  LDA #$00                                      ; $EB2D: A9 00
  STA result_b1                                 ; $EB2F: 85 0E
  STA result_b2                                 ; $EB31: 85 0F
  ; Ones digit
  LDA bcd_tens_ones                             ; $EB33: A5 0A
  PHA                                           ; $EB35: 48
  AND #$0F                                      ; $EB36: 29 0F
  STA result_b0                                 ; $EB38: 85 0D
  ; Tens digit x 10
  PLA                                           ; $EB3A: 68
  JSR MathExtractUpperNibble                    ; $EB3B: 20 B1 EB
  STA multiplier                                ; $EB3E: 85 03
  LDA #$0A                                      ; $EB40: A9 0A
  STA mul_lo                                    ; $EB42: 85 00
  LDA #$00                                      ; $EB44: A9 00
  STA mul_mid                                   ; $EB46: 85 01
  STA mul_hi                                    ; $EB48: 85 02
  JSR MathMul24x8                               ; $EB4A: 20 E9 EB
  JSR MathAccumulate24                          ; $EB4D: 20 B6 EB
  ; Hundreds digit x 100
  LDA bcd_thou_hund                             ; $EB50: A5 0B
  PHA                                           ; $EB52: 48
  AND #$0F                                      ; $EB53: 29 0F
  STA multiplier                                ; $EB55: 85 03
  LDA #$64                                      ; $EB57: A9 64
  STA mul_lo                                    ; $EB59: 85 00
  LDA #$00                                      ; $EB5B: A9 00
  STA mul_mid                                   ; $EB5D: 85 01
  STA mul_hi                                    ; $EB5F: 85 02
  JSR MathMul24x8                               ; $EB61: 20 E9 EB
  JSR MathAccumulate24                          ; $EB64: 20 B6 EB
  ; Thousands digit x 1000
  PLA                                           ; $EB67: 68
  JSR MathExtractUpperNibble                    ; $EB68: 20 B1 EB
  STA multiplier                                ; $EB6B: 85 03
  LDA #$E8                                      ; $EB6D: A9 E8
  STA mul_lo                                    ; $EB6F: 85 00
  LDA #$03                                      ; $EB71: A9 03
  STA mul_mid                                   ; $EB73: 85 01
  LDA #$00                                      ; $EB75: A9 00
  STA mul_hi                                    ; $EB77: 85 02
  JSR MathMul24x8                               ; $EB79: 20 E9 EB
  JSR MathAccumulate24                          ; $EB7C: 20 B6 EB
  ; Ten-thousands digit x 10000
  LDA bcd_htth_tth                              ; $EB7F: A5 0C
  PHA                                           ; $EB81: 48
  AND #$0F                                      ; $EB82: 29 0F
  STA multiplier                                ; $EB84: 85 03
  LDA #$10                                      ; $EB86: A9 10
  STA mul_lo                                    ; $EB88: 85 00
  LDA #$27                                      ; $EB8A: A9 27
  STA mul_mid                                   ; $EB8C: 85 01
  LDA #$00                                      ; $EB8E: A9 00
  STA mul_hi                                    ; $EB90: 85 02
  JSR MathMul24x8                               ; $EB92: 20 E9 EB
  JSR MathAccumulate24                          ; $EB95: 20 B6 EB
  ; Hundred-thousands digit x 100000
  PLA                                           ; $EB98: 68
  JSR MathExtractUpperNibble                    ; $EB99: 20 B1 EB
  STA multiplier                                ; $EB9C: 85 03
  LDA #$A0                                      ; $EB9E: A9 A0
  STA mul_lo                                    ; $EBA0: 85 00
  LDA #$86                                      ; $EBA2: A9 86
  STA mul_mid                                   ; $EBA4: 85 01
  LDA #$01                                      ; $EBA6: A9 01
  STA mul_hi                                    ; $EBA8: 85 02
  JSR MathMul24x8                               ; $EBAA: 20 E9 EB
  JSR MathAccumulate24                          ; $EBAD: 20 B6 EB
  RTS                                           ; $EBB0: 60
.endproc

;===============================================================================
; $EBB1: Extract Upper Nibble
; Input: A = byte; Output: A = upper nibble >> 4
;===============================================================================
.proc MathExtractUpperNibble
  LSR                                           ; $EBB1: 4A
  LSR                                           ; $EBB2: 4A
  LSR                                           ; $EBB3: 4A
  LSR                                           ; $EBB4: 4A
  RTS                                           ; $EBB5: 60
.endproc

;===============================================================================
; $EBB6: Math - 24-bit Accumulate
; $0D/$0E/$0F += $06/$07/$08
;===============================================================================
.proc MathAccumulate24
  LDA $06                                       ; $EBB6: A5 06
  CLC                                           ; $EBB8: 18
  ADC $0D                                       ; $EBB9: 65 0D
  STA $0D                                       ; $EBBB: 85 0D
  LDA $07                                       ; $EBBD: A5 07
  ADC $0E                                       ; $EBBF: 65 0E
  STA $0E                                       ; $EBC1: 85 0E
  LDA $08                                       ; $EBC3: A5 08
  ADC $0F                                       ; $EBC5: 65 0F
  STA $0F                                       ; $EBC7: 85 0F
  RTS                                           ; $EBC9: 60
.endproc

;===============================================================================
; $EBCA: Math - Multiply then Divide by 100
; Input: $00/$01 = value, $03 = multiplier
; Computes: (value * multiplier) / 100
; Output: $00/$01/$02 = quotient
;===============================================================================
.proc MathMulDiv100
  LDA #$00                                      ; $EBCA: A9 00
  STA $02                                       ; $EBCC: 85 02
  JSR MathMul24x8                               ; $EBCE: 20 E9 EB
  LDA $06                                       ; $EBD1: A5 06
  STA $00                                       ; $EBD3: 85 00
  LDA $07                                       ; $EBD5: A5 07
  STA $01                                       ; $EBD7: 85 01
  LDA $08                                       ; $EBD9: A5 08
  STA $02                                       ; $EBDB: 85 02
  LDA #$64                                      ; $EBDD: A9 64
  STA $03                                       ; $EBDF: 85 03
  LDA #$00                                      ; $EBE1: A9 00
  STA $04                                       ; $EBE3: 85 04
  JSR MathDiv24                                 ; $EBE5: 20 A5 EA
  RTS                                           ; $EBE8: 60
.endproc

;===============================================================================
; $EBE9: Math - 24x8 Multiply
; Input: $00/$01/$02 = multiplicand (24-bit), $03 = multiplier (8-bit)
; Output: $06/$07/$08/$09 = product (32-bit)
;===============================================================================
.proc MathMul24x8
multiplicand_b0 = $00
multiplicand_b1 = $01
multiplicand_b2 = $02
multiplier_val  = $03
extension       = $04
product_b0      = $05
product_b1      = $06
product_b2      = $07
product_b3      = $08
product_b4      = $09

  LDY #$07                                      ; $EBE9: A0 07
  LDA #$00                                      ; $EBEB: A9 00
  STA extension                                 ; $EBED: 85 04
  STA product_b0                                ; $EBEF: 85 05
  STA product_b1                                ; $EBF1: 85 06
  STA product_b2                                ; $EBF3: 85 07
  STA product_b3                                ; $EBF5: 85 08
  STA product_b4                                ; $EBF7: 85 09
@loop:
  LSR multiplier_val                            ; $EBF9: 46 03
  BCC @skip_add                                 ; $EBFB: 90 19
  LDA multiplicand_b0                           ; $EBFD: A5 00
  CLC                                           ; $EBFF: 18
  ADC product_b1                                ; $EC00: 65 06
  STA product_b1                                ; $EC02: 85 06
  LDA multiplicand_b1                           ; $EC04: A5 01
  ADC product_b2                                ; $EC06: 65 07
  STA product_b2                                ; $EC08: 85 07
  LDA multiplicand_b2                           ; $EC0A: A5 02
  ADC product_b3                                ; $EC0C: 65 08
  STA product_b3                                ; $EC0E: 85 08
  LDA extension                                 ; $EC10: A5 04
  ADC product_b4                                ; $EC12: 65 09
  STA product_b4                                ; $EC14: 85 09
@skip_add:
  ASL multiplicand_b0                           ; $EC16: 06 00
  ROL multiplicand_b1                           ; $EC18: 26 01
  ROL multiplicand_b2                           ; $EC1A: 26 02
  ROL extension                                 ; $EC1C: 26 04
  DEY                                           ; $EC1E: 88
  BPL @loop                                     ; $EC1F: 10 D8
  RTS                                           ; $EC21: 60
.endproc

;===============================================================================
; $EC22: Math - 24x16 Multiply
; Input: $00/$01/$02 = multiplicand, $03/$04 = multiplier (16-bit)
; Output: $06/$07/$08/$09/$0A = product (40-bit)
;===============================================================================
.proc MathMul24x16
multiplicand_b0 = $00
multiplicand_b1 = $01
multiplicand_b2 = $02
multiplier_lo   = $03
multiplier_hi   = $04
product_b0      = $06
product_b1      = $07
product_b2      = $08
product_b3      = $09
product_b4      = $0A
ext_b0          = $0B
ext_b1          = $0C

  LDY #$0F                                      ; $EC22: A0 0F
  LDA #$00                                      ; $EC24: A9 00
  STA product_b0                                ; $EC26: 85 06
  STA product_b1                                ; $EC28: 85 07
  STA product_b2                                ; $EC2A: 85 08
  STA product_b3                                ; $EC2C: 85 09
  STA product_b4                                ; $EC2E: 85 0A
  STA ext_b0                                    ; $EC30: 85 0B
  STA ext_b1                                    ; $EC32: 85 0C
@loop:
  LSR multiplier_hi                             ; $EC34: 46 04
  ROR multiplier_lo                             ; $EC36: 66 03
  BCC @skip_add                                 ; $EC38: 90 1F
  LDA multiplicand_b0                           ; $EC3A: A5 00
  CLC                                           ; $EC3C: 18
  ADC product_b0                                ; $EC3D: 65 06
  STA product_b0                                ; $EC3F: 85 06
  LDA multiplicand_b1                           ; $EC41: A5 01
  ADC product_b1                                ; $EC43: 65 07
  STA product_b1                                ; $EC45: 85 07
  LDA multiplicand_b2                           ; $EC47: A5 02
  ADC product_b2                                ; $EC49: 65 08
  STA product_b2                                ; $EC4B: 85 08
  LDA ext_b0                                    ; $EC4D: A5 0B
  ADC product_b3                                ; $EC4F: 65 09
  STA product_b3                                ; $EC51: 85 09
  LDA ext_b1                                    ; $EC53: A5 0C
  ADC product_b4                                ; $EC55: 65 0A
  STA product_b4                                ; $EC57: 85 0A
@skip_add:
  ASL multiplicand_b0                           ; $EC59: 06 00
  ROL multiplicand_b1                           ; $EC5B: 26 01
  ROL multiplicand_b2                           ; $EC5D: 26 02
  ROL ext_b0                                    ; $EC5F: 26 0B
  ROL ext_b1                                    ; $EC61: 26 0C
  DEY                                           ; $EC63: 88
  BPL @loop                                     ; $EC64: 10 CE
  RTS                                           ; $EC66: 60
.endproc


;===============================================================================
; $EC67: Palette Animation
; Controls color cycling animation for palette entries
; Uses frame counter at $0087, animation direction at $0087,
; step counter at $0088, speed at $0089, tick counter at $008A
;===============================================================================
.proc PaletteAnimation
anim_direction  = $0087
anim_step       = $0088
anim_speed      = $0089
anim_counter    = $008A
nmi_flag        = $007D

  LDA anim_direction                            ; $EC67: AD 87 00
  BMI @done                                     ; $EC6A: 30 52
  DEC anim_counter                              ; $EC6C: CE 8A 00
  BPL @done                                     ; $EC6F: 10 4D
  LDA anim_speed                                ; $EC71: AD 89 00
  STA anim_counter                              ; $EC74: 8D 8A 00
  LDA #$01                                      ; $EC77: A9 01
  STA nmi_flag                                  ; $EC79: 8D 7D 00
  LDA anim_direction                            ; $EC7C: AD 87 00
  BEQ @reverse                                  ; $EC7F: F0 0D
  INC anim_step                                 ; $EC81: EE 88 00
  LDA anim_step                                 ; $EC84: AD 88 00
  CMP #$04                                      ; $EC87: C9 04
  BCC @apply_shift                              ; $EC89: 90 0D
  JMP @mark_done                                ; $EC8B: 4C 93 EC
@reverse:
  DEC anim_step                                 ; $EC8E: CE 88 00
  BNE @apply_shift                              ; $EC91: D0 05
@mark_done:
  LDA #$FF                                      ; $EC93: A9 FF
  STA anim_direction                            ; $EC95: 8D 87 00
@apply_shift:
  LDA #$00                                      ; $EC98: A9 00
  STA $00                                       ; $EC9A: 85 00
  LDA #$01                                      ; $EC9C: A9 01
  STA $01                                       ; $EC9E: 85 01
  LDA #$20                                      ; $ECA0: A9 20
  STA $02                                       ; $ECA2: 85 02
  LDA #$01                                      ; $ECA4: A9 01
  STA $03                                       ; $ECA6: 85 03
  LDY #$1F                                      ; $ECA8: A0 1F
@shift_loop:
  LDX anim_step                                 ; $ECAA: AE 88 00
  LDA ($02),Y                                   ; $ECAD: B1 02
@sub_loop:
  DEX                                           ; $ECAF: CA
  BMI @store                                    ; $ECB0: 30 07
  SEC                                           ; $ECB2: 38
  SBC #$10                                      ; $ECB3: E9 10
  BPL @sub_loop                                 ; $ECB5: 10 F8
  LDA #$0F                                      ; $ECB7: A9 0F
@store:
  STA ($00),Y                                   ; $ECB9: 91 00
  DEY                                           ; $ECBB: 88
  BPL @shift_loop                               ; $ECBC: 10 EC
@done:
  RTS                                           ; $ECBE: 60
.endproc

;===============================================================================
; $ECBF: Palette Fade Init (Move $0100 -> $0120)
; Initializes fade: copies palette from $0100 to $0120, fills $0100 with $0F
;===============================================================================
.proc PaletteFadeInit
  LDA #$00                                      ; $ECBF: A9 00
  STA $0087                                     ; $ECC1: 8D 87 00
  LDA #$04                                      ; $ECC4: A9 04
  STA $0088                                     ; $ECC6: 8D 88 00
  LDA #$04                                      ; $ECC9: A9 04
  STA $0089                                     ; $ECCB: 8D 89 00
  LDA #$00                                      ; $ECCE: A9 00
  STA $00                                       ; $ECD0: 85 00
  LDA #$01                                      ; $ECD2: A9 01
  STA $01                                       ; $ECD4: 85 01
  LDA #$20                                      ; $ECD6: A9 20
  STA $02                                       ; $ECD8: 85 02
  LDA #$01                                      ; $ECDA: A9 01
  STA $03                                       ; $ECDC: 85 03
  LDY #$00                                      ; $ECDE: A0 00
@copy_loop:
  LDA ($00),Y                                   ; $ECE0: B1 00
  STA ($02),Y                                   ; $ECE2: 91 02
  LDA #$0F                                      ; $ECE4: A9 0F
  STA ($00),Y                                   ; $ECE6: 91 00
  INY                                           ; $ECE8: C8
  CPY #$20                                      ; $ECE9: C0 20
  BCC @copy_loop                                ; $ECEB: 90 F3
  RTS                                           ; $ECED: 60
.endproc

;===============================================================================
; $ECEE: Palette Copy Buffer ($0100 -> $0120, no fill)
; Similar to PaletteFadeInit but doesn't blank source
;===============================================================================
.proc PaletteCopyBuffer
  LDA #$01                                      ; $ECEE: A9 01
  STA $0087                                     ; $ECF0: 8D 87 00
  LDA #$00                                      ; $ECF3: A9 00
  STA $0088                                     ; $ECF5: 8D 88 00
  LDA #$04                                      ; $ECF8: A9 04
  STA $0089                                     ; $ECFA: 8D 89 00
  LDA #$00                                      ; $ECFD: A9 00
  STA $00                                       ; $ECFF: 85 00
  LDA #$01                                      ; $ED01: A9 01
  STA $01                                       ; $ED03: 85 01
  LDA #$20                                      ; $ED05: A9 20
  STA $02                                       ; $ED07: 85 02
  LDA #$01                                      ; $ED09: A9 01
  STA $03                                       ; $ED0B: 85 03
  LDY #$00                                      ; $ED0D: A0 00
@copy_loop:
  LDA ($00),Y                                   ; $ED0F: B1 00
  STA ($02),Y                                   ; $ED11: 91 02
  INY                                           ; $ED13: C8
  CPY #$20                                      ; $ED14: C0 20
  BCC @copy_loop                                ; $ED16: 90 F7
  RTS                                           ; $ED18: 60
.endproc

;===============================================================================
; $ED19: Menu Cursor System (8 entry points)
; Entry: MenuStep1-MenuStep8 with step_size = 1..8
; Input: ($10) = data table pointer
; Output: $12 = current item value from table lookup
; Checks pad1 edges for directional input
;===============================================================================
.proc MenuCursorSystem
step_size       = $00
data_ptr        = $10
cur_item        = $12

MenuStep1:
  LDA #$01                                      ; $ED19: A9 01
  JMP MenuMain                                  ; $ED1B: 4C 41 ED
MenuStep2:
  LDA #$02                                      ; $ED1E: A9 02
  JMP MenuMain                                  ; $ED20: 4C 41 ED
MenuStep3:
  LDA #$03                                      ; $ED23: A9 03
  JMP MenuMain                                  ; $ED25: 4C 41 ED
MenuStep4:
  LDA #$04                                      ; $ED28: A9 04
  JMP MenuMain                                  ; $ED2A: 4C 41 ED
MenuStep5:
  LDA #$05                                      ; $ED2D: A9 05
  JMP MenuMain                                  ; $ED2F: 4C 41 ED
MenuStep6:
  LDA #$06                                      ; $ED32: A9 06
  JMP MenuMain                                  ; $ED34: 4C 41 ED
MenuStep7:
  LDA #$07                                      ; $ED37: A9 07
  JMP MenuMain                                  ; $ED39: 4C 41 ED
MenuStep8:
  LDA #$08                                      ; $ED3C: A9 08
  JMP MenuMain                                  ; $ED3E: 4C 41 ED
MenuMain:
  STA step_size                                 ; $ED41: 85 00
  LDA addr_pad1_edge                            ; $ED43: AD 81 00
  AND #$80                                      ; $ED46: 29 80
  BEQ @check_left                               ; $ED48: F0 03
  JSR @cursor_right                             ; $ED4A: 20 71 ED
@check_left:
  LDA addr_pad1_edge                            ; $ED4D: AD 81 00
  AND #$40                                      ; $ED50: 29 40
  BEQ @check_down                               ; $ED52: F0 03
  JSR @cursor_left                              ; $ED54: 20 8D ED
@check_down:
  LDA addr_pad1_edge                            ; $ED57: AD 81 00
  AND #$20                                      ; $ED5A: 29 20
  BEQ @check_up                                 ; $ED5C: F0 03
  JSR @cursor_down                              ; $ED5E: 20 A9 ED
@check_up:
  LDA addr_pad1_edge                            ; $ED61: AD 81 00
  AND #$10                                      ; $ED64: 29 10
  BEQ @do_lookup                                ; $ED66: F0 03
  JSR @cursor_up                                ; $ED68: 20 BE ED
@do_lookup:
  JSR MenuItemLookup                            ; $ED6B: 20 DD ED
  STA cur_item                                  ; $ED6E: 85 12
  RTS                                           ; $ED70: 60

; --- cursor_right: increment column ---
@cursor_right:
  INC addr_menu_column                          ; $ED71: EE 24 04
  JSR MenuItemLookup                            ; $ED74: 20 DD ED
  BMI @right_overflow                           ; $ED77: 30 07
  LDA addr_menu_column                          ; $ED79: AD 24 04
  CMP step_size                                 ; $ED7C: C5 00
  BCC @right_done                               ; $ED7E: 90 0C
@right_overflow:
  DEC addr_menu_column                          ; $ED80: CE 24 04
  LDA cur_item                                  ; $ED83: A5 12
  BNE @right_done                               ; $ED85: D0 05
  LDA #$00                                      ; $ED87: A9 00
  STA addr_menu_column                          ; $ED89: 8D 24 04
@right_done:
  RTS                                           ; $ED8C: 60

; --- cursor_left: decrement column ---
@cursor_left:
  DEC addr_menu_column                          ; $ED8D: CE 24 04
  BPL @left_valid                               ; $ED90: 10 16
  INC addr_menu_column                          ; $ED92: EE 24 04
  LDA cur_item                                  ; $ED95: A5 12
  BNE @left_valid                               ; $ED97: D0 0F
  LDA step_size                                 ; $ED99: A5 00
  STA addr_menu_column                          ; $ED9B: 8D 24 04
@left_scan:
  DEC addr_menu_column                          ; $ED9E: CE 24 04
  JSR MenuItemLookup                            ; $EDA1: 20 DD ED
  CMP #$FF                                      ; $EDA4: C9 FF
  BEQ @left_scan                                ; $EDA6: F0 F6
@left_valid:
  RTS                                           ; $EDA8: 60

; --- cursor_down: increment page ---
@cursor_down:
  INC addr_menu_page                            ; $EDA9: EE 25 04
  JSR MenuItemLookup                            ; $EDAC: 20 DD ED
  BPL @down_done                                ; $EDAF: 10 0C
  DEC addr_menu_page                            ; $EDB1: CE 25 04
  LDA cur_item                                  ; $EDB4: A5 12
  BNE @down_done                                ; $EDB6: D0 05
  LDA #$00                                      ; $EDB8: A9 00
  STA addr_menu_page                            ; $EDBA: 8D 25 04
@down_done:
  RTS                                           ; $EDBD: 60

; --- cursor_up: decrement page ---
@cursor_up:
  DEC addr_menu_page                            ; $EDBE: CE 25 04
  BPL @up_done                                  ; $EDC1: 10 19
  INC addr_menu_page                            ; $EDC3: EE 25 04
  LDA cur_item                                  ; $EDC6: A5 12
  BNE @up_done                                  ; $EDC8: D0 12
  LDX #$FF                                      ; $EDCA: A2 FF
  LDY addr_menu_column                          ; $EDCC: AC 24 04
@up_count:
  INX                                           ; $EDCF: E8
  TYA                                           ; $EDD0: 98
  CLC                                           ; $EDD1: 18
  ADC step_size                                 ; $EDD2: 65 00
  TAY                                           ; $EDD4: A8
  LDA (data_ptr),Y                              ; $EDD5: B1 10
  BPL @up_count                                 ; $EDD7: 10 F6
  STX addr_menu_page                            ; $EDD9: 8E 25 04
@up_done:
  RTS                                           ; $EDDC: 60
.endproc

;===============================================================================
; $EDDD: Menu Item Lookup
; Computes: offset = page * step_size + column
; Returns: A = (data_ptr)[offset]
;===============================================================================
.proc MenuItemLookup
step_size  = $00
data_ptr   = $10

  LDA #$00                                      ; $EDDD: A9 00
  LDY addr_menu_page                            ; $EDDF: AC 25 04
@mul_loop:
  CPY #$00                                      ; $EDE2: C0 00
  BEQ @add_column                               ; $EDE4: F0 07
  CLC                                           ; $EDE6: 18
  ADC step_size                                 ; $EDE7: 65 00
  DEY                                           ; $EDE9: 88
  JMP @mul_loop                                 ; $EDEA: 4C E2 ED
@add_column:
  CLC                                           ; $EDED: 18
  ADC addr_menu_column                          ; $EDEE: 6D 24 04
  TAY                                           ; $EDF1: A8
  LDA (data_ptr),Y                              ; $EDF2: B1 10
  RTS                                           ; $EDF4: 60
.endproc

;===============================================================================
; $EDF5: Pointer Table Lookup
; Input: A = entry index, ($10) = pointer table base
; Output: $0A/$0C = fetched pointer, then JMP SpriteOamWriterSimple
;===============================================================================
.proc PointerTableLookup
ptr_lo   = $0A
ptr_hi   = $0C

  ASL                                           ; $EDF5: 0A
  TAY                                           ; $EDF6: A8
  LDA ($10),Y                                   ; $EDF7: B1 10
  STA ptr_lo                                    ; $EDF9: 85 0A
  INY                                           ; $EDFB: C8
  LDA ($10),Y                                   ; $EDFC: B1 10
  STA ptr_hi                                    ; $EDFE: 85 0C
  LDA #$00                                      ; $EE00: A9 00
  STA $02                                       ; $EE02: 85 02
  JMP SpriteOamWriterSimple                     ; $EE04: 4C AD F1
.endproc

;===============================================================================
; $EE07: Banked Callback Trampoline
; Switches PRG banks, calls target, restores bank on return
; Usage: LDY #bank; JSR BankedCallbackTrampoline; .word target_addr
;===============================================================================
.proc BankedCallbackTrampoline
  LDA addr_prg_select_2b                        ; $EE07: AD E2 00
  STA addr_trampoline_saved_bank                ; $EE0A: 8D 58 00
  STY addr_trampoline_bank_param                ; $EE0D: 8C 5D 00
  PLA                                           ; $EE10: 68
  CLC                                           ; $EE11: 18
  ADC #$01                                      ; $EE12: 69 01
  STA addr_trampoline_ret_lo                    ; $EE14: 8D 59 00
  PLA                                           ; $EE17: 68
  ADC #$00                                      ; $EE18: 69 00
  STA addr_trampoline_ret_hi                    ; $EE1A: 8D 5A 00
  LDY #$00                                      ; $EE1D: A0 00
  LDA (addr_trampoline_ret_lo),Y                ; $EE1F: B1 59
  STA addr_trampoline_target_lo                 ; $EE21: 8D 5B 00
  INY                                           ; $EE24: C8
  LDA (addr_trampoline_ret_lo),Y                ; $EE25: B1 59
  STA addr_trampoline_target_hi                 ; $EE27: 8D 5C 00
  LDY addr_trampoline_bank_param                ; $EE2A: AC 5D 00
  JSR SwitchBankAC_B                             ; $EE2D: 20 37 F2
  INC addr_trampoline_ret_lo                    ; $EE30: EE 59 00
  BNE @no_carry                                 ; $EE33: D0 03
  INC addr_trampoline_ret_hi                    ; $EE35: EE 5A 00
@no_carry:
  LDA addr_trampoline_ret_hi                    ; $EE38: AD 5A 00
  PHA                                           ; $EE3B: 48
  LDA addr_trampoline_ret_lo                    ; $EE3C: AD 59 00
  PHA                                           ; $EE3F: 48
  LDA addr_trampoline_saved_bank                ; $EE40: AD 58 00
  PHA                                           ; $EE43: 48
  LDA #$EE                                      ; $EE44: A9 EE
  PHA                                           ; $EE46: 48
  LDA #$4C                                      ; $EE47: A9 4C
  PHA                                           ; $EE49: 48
  JMP (addr_trampoline_target_lo)               ; $EE4A: 6C 5B 00
.endproc

;===============================================================================
; $EE4D: Banked Callback Return
; Restores PRG banks after banked call completes
;===============================================================================
.proc BankedCallbackReturn
  PLA                                           ; $EE4D: 68
  TAY                                           ; $EE4E: A8
  JSR SwitchBankAC_B                             ; $EE4F: 20 37 F2
  RTS                                           ; $EE52: 60
.endproc

;===============================================================================
; $EE53: NMI Sub-Dispatch
; Tests bits of $007E to dispatch PPU update tasks
; bit7 -> PpuBgTileWrite, bit6 -> PpuSpriteTileWrite
; bit5 -> PpuAttrTileWrite, bit4 -> PpuAttrTileWriteAlt
;===============================================================================
.proc NmiSubDispatch
nmi_ctrl = $007E

  LDA nmi_ctrl                                  ; $EE53: AD 7D 00
  BNE @check_bits                               ; $EE56: D0 1A
  LDA nmi_ctrl                                  ; $EE58: AD 7E 00
  BMI @do_bg                                    ; $EE5B: 30 18
  ASL                                           ; $EE5D: 0A
  BMI @do_sprite                                ; $EE5E: 30 27
@test_attr:
  ASL                                           ; $EE60: 0A
  BMI @do_attr                                  ; $EE61: 30 35
  ASL                                           ; $EE63: 0A
  BMI @do_attr_alt                              ; $EE64: 30 3D
  ASL                                           ; $EE66: 0A
  BMI @do_bank_3d_a                             ; $EE67: 30 45
  ASL                                           ; $EE69: 0A
  BMI @do_bank_3d_b                             ; $EE6A: 30 52
  ASL                                           ; $EE6C: 0A
  BMI @do_bank_3d_c                             ; $EE6D: 30 5F
  ASL                                           ; $EE6F: 0A
  BMI @do_bank_3d_d                             ; $EE70: 30 6C
@check_bits:
  JMP sub_E70E                                  ; $EE72: 4C 0E E7

@do_bg:
  PHA                                           ; $EE75: 48
  LDA nmi_ctrl                                  ; $EE76: AD 7E 00
  AND #$7F                                      ; $EE79: 29 7F
  STA nmi_ctrl                                  ; $EE7B: 8D 7E 00
  JSR PpuBgTileWrite                            ; $EE7E: 20 0B EF
  PLA                                           ; $EE81: 68
  RTS                                           ; $EE82: 60
  ASL                                           ; $EE83: 0A
  JMP @test_attr                                ; $EE84: 4C 60 EE

@do_sprite:
  PHA                                           ; $EE87: 48
  LDA nmi_ctrl                                  ; $EE88: AD 7E 00
  AND #$BF                                      ; $EE8B: 29 BF
  STA nmi_ctrl                                  ; $EE8D: 8D 7E 00
  JSR PpuSpriteTileWrite                        ; $EE90: 20 71 EF
  PLA                                           ; $EE93: 68
  RTS                                           ; $EE94: 60
  JMP @test_attr                                ; $EE95: 4C 60 EE

@do_attr:
  LDA nmi_ctrl                                  ; $EE98: AD 7E 00
  AND #$DF                                      ; $EE9B: 29 DF
  STA nmi_ctrl                                  ; $EE9D: 8D 7E 00
  JMP PpuAttrTileWrite                          ; $EEA0: 4C C0 EF

@do_attr_alt:
  LDA nmi_ctrl                                  ; $EEA3: AD 7E 00
  AND #$EF                                      ; $EEA6: 29 EF
  STA nmi_ctrl                                  ; $EEA8: 8D 7E 00
  JMP PpuAttrTileWriteAlt                       ; $EEAB: 4C 28 F0

@do_bank_3d_a:
  LDY #$3D                                      ; $EEAE: A0 3D
  JSR SwitchBankAC_B                             ; $EEB0: 20 37 F2
  LDA nmi_ctrl                                  ; $EEB3: AD 7E 00
  AND #$F7                                      ; $EEB6: 29 F7
  STA nmi_ctrl                                  ; $EEB8: 8D 7E 00
  JMP $A00C                                     ; $EEBB: 4C 0C A0

@do_bank_3d_b:
  LDA nmi_ctrl                                  ; $EEBE: AD 7E 00
  AND #$FB                                      ; $EEC1: 29 FB
  STA nmi_ctrl                                  ; $EEC3: 8D 7E 00
  LDY #$3D                                      ; $EEC6: A0 3D
  JSR SwitchBankAC_B                             ; $EEC8: 20 37 F2
  JMP $A006                                     ; $EECB: 4C 06 A0

@do_bank_3d_c:
  LDA nmi_ctrl                                  ; $EECE: AD 7E 00
  AND #$FD                                      ; $EED1: 29 FD
  STA nmi_ctrl                                  ; $EED3: 8D 7E 00
  LDY #$3D                                      ; $EED6: A0 3D
  JSR SwitchBankAC_B                             ; $EED8: 20 37 F2
  JMP $A012                                     ; $EEDB: 4C 12 A0

@do_bank_3d_d:
  LDY #$3D                                      ; $EEDE: A0 3D
  JSR SwitchBankAC_B                             ; $EEE0: 20 37 F2
  JMP $A000                                     ; $EEE3: 4C 00 A0
.endproc

;===============================================================================
; $EEE6: NMI Sub-Dispatch Alt
; Simplified variant checking fewer bits of $007E
;===============================================================================
.proc NmiSubDispatchAlt
nmi_ctrl = $007E

  LDA nmi_ctrl                                  ; $EEE6: AD 7E 00
  BMI @do_bg                                    ; $EEE9: 30 0A
  ASL                                           ; $EEEB: 0A
  BMI @do_sprite                                ; $EEEC: 30 12
  ASL                                           ; $EEEE: 0A
  BMI @do_attr                                  ; $EEEF: 30 A7
  ASL                                           ; $EEF1: 0A
  BMI @do_attr_alt                              ; $EEF2: 30 AF
  RTS                                           ; $EEF4: 60

@do_bg:
  LDA nmi_ctrl                                  ; $EEF5: AD 7E 00
  AND #$7F                                      ; $EEF8: 29 7F
  STA nmi_ctrl                                  ; $EEFA: 8D 7E 00
  JMP PpuBgTileWrite                            ; $EEFD: 4C 0B EF

@do_sprite:
  LDA nmi_ctrl                                  ; $EF00: AD 7E 00
  AND #$BF                                      ; $EF03: 29 BF
  STA nmi_ctrl                                  ; $EF05: 8D 7E 00
  JMP PpuSpriteTileWrite                        ; $EF08: 4C 71 EF
.endproc

;===============================================================================
; $EF0B: PPU BG Tile Write (Vertical increment mode)
; Writes tile data from $0142 buffer to PPU with vertical increment
; Address from $0140/$0141, length computed from $0141
;===============================================================================
.proc PpuBgTileWrite
  LDA $0141                                     ; $EF0B: AD 41 01
  STA $0001                                     ; $EF0E: 8D 01 00
  LDA $0140                                     ; $EF11: AD 40 01
  AND #$03                                      ; $EF14: 29 03
  ASL $0001                                     ; $EF16: 0E 01 00
  ROL                                           ; $EF19: 2A
  ASL $0001                                     ; $EF1A: 0E 01 00
  ROL                                           ; $EF1D: 2A
  ASL $0001                                     ; $EF1E: 0E 01 00
  ROL                                           ; $EF21: 2A
  STA $0001                                     ; $EF22: 8D 01 00
  LDA #$1E                                      ; $EF25: A9 1E
  SEC                                           ; $EF27: 38
  SBC $0001                                     ; $EF28: ED 01 00
  STA $0000                                     ; $EF2B: 8D 00 00
  LDA addr_ppu_ctrl_ram                         ; $EF2E: AD 8B 00
  ORA #$04                                      ; $EF31: 09 04
  STA $2000                                     ; $EF33: 8D 00 20
  LDA $2002                                     ; $EF36: AD 02 20
  LDA $0140                                     ; $EF39: AD 40 01
  STA $2006                                     ; $EF3C: 8D 06 20
  LDA $0141                                     ; $EF3F: AD 41 01
  STA $2006                                     ; $EF42: 8D 06 20
  LDY #$00                                      ; $EF45: A0 00
@write_loop1:
  LDA $0142,Y                                   ; $EF47: B9 42 01
  STA $2007                                     ; $EF4A: 8D 07 20
  INY                                           ; $EF4D: C8
  CPY $0000                                     ; $EF4E: CC 00 00
  BCC @write_loop1                              ; $EF51: 90 F4
  LDA $0140                                     ; $EF53: AD 40 01
  AND #$FC                                      ; $EF56: 29 FC
  STA $2006                                     ; $EF58: 8D 06 20
  LDA $0141                                     ; $EF5B: AD 41 01
  AND #$1F                                      ; $EF5E: 29 1F
  STA $2006                                     ; $EF60: 8D 06 20
@write_loop2:
  CPY #$1E                                      ; $EF63: C0 1E
  BCS @done                                     ; $EF65: B0 09
  LDA $0142,Y                                   ; $EF67: B9 42 01
  STA $2007                                     ; $EF6A: 8D 07 20
  INY                                           ; $EF6D: C8
  BNE @write_loop2                              ; $EF6E: D0 F3
@done:
  RTS                                           ; $EF70: 60
.endproc

;===============================================================================
; $EF71: PPU Sprite Tile Write (Horizontal mode)
; Writes tile data from $0166 buffer to PPU
; Address from $0164/$0165
;===============================================================================
.proc PpuSpriteTileWrite
  LDA addr_ppu_ctrl_ram                         ; $EF71: AD 8B 00
  AND #$FB                                      ; $EF74: 29 FB
  STA $2000                                     ; $EF76: 8D 00 20
  LDA $2002                                     ; $EF79: AD 02 20
  LDA $0164                                     ; $EF7C: AD 64 01
  STA $2006                                     ; $EF7F: 8D 06 20
  LDA $0165                                     ; $EF82: AD 65 01
  STA $2006                                     ; $EF85: 8D 06 20
  AND #$1F                                      ; $EF88: 29 1F
  STA $0000                                     ; $EF8A: 8D 00 00
  LDA #$20                                      ; $EF8D: A9 20
  SEC                                           ; $EF8F: 38
  SBC $0000                                     ; $EF90: ED 00 00
  STA $0000                                     ; $EF93: 8D 00 00
  LDY #$00                                      ; $EF96: A0 00
@write_loop1:
  LDA $0166,Y                                   ; $EF98: B9 66 01
  STA $2007                                     ; $EF9B: 8D 07 20
  INY                                           ; $EF9E: C8
  CPY $0000                                     ; $EF9F: CC 00 00
  BCC @write_loop1                              ; $EFA2: 90 F4
  LDA $0164                                     ; $EFA4: AD 64 01
  STA $2006                                     ; $EFA7: 8D 06 20
  LDA $0165                                     ; $EFAA: AD 65 01
  AND #$E0                                      ; $EFAD: 29 E0
  STA $2006                                     ; $EFAF: 8D 06 20
@write_loop2:
  CPY #$20                                      ; $EFB2: C0 20
  BCS @done                                     ; $EFB4: B0 09
  LDA $0166,Y                                   ; $EFB6: B9 66 01
  STA $2007                                     ; $EFB9: 8D 07 20
  INY                                           ; $EFBC: C8
  BNE @write_loop2                              ; $EFBD: D0 F3
@done:
  RTS                                           ; $EFBF: 60
.endproc


;===============================================================================
; $EFC0: PPU Attribute Tile Write (Vertical increment mode)
; Writes attribute data from $018A buffer using vertical PPU increment
; Address from $0188/$0189, handles wrap
;===============================================================================
.proc PpuAttrTileWrite
  LDA $0189                                     ; $EFC0: AD 89 01
  STA $0001                                     ; $EFC3: 8D 01 00
  AND #$38                                      ; $EFC6: 29 38
  LSR                                           ; $EFC8: 4A
  LSR                                           ; $EFC9: 4A
  LSR                                           ; $EFCA: 4A
  STA $0000                                     ; $EFCB: 8D 00 00
  LDA #$08                                      ; $EFCE: A9 08
  SEC                                           ; $EFD0: 38
  SBC $0000                                     ; $EFD1: ED 00 00
  STA $0000                                     ; $EFD4: 8D 00 00
  LDY #$00                                      ; $EFD7: A0 00
  LDA $2002                                     ; $EFD9: AD 02 20
@write_loop1:
  LDA $0188                                     ; $EFDC: AD 88 01
  STA $2006                                     ; $EFDF: 8D 06 20
  LDA $0001                                     ; $EFE2: AD 01 00
  STA $2006                                     ; $EFE5: 8D 06 20
  LDA $018A,Y                                   ; $EFE8: B9 8A 01
  STA $2007                                     ; $EFEB: 8D 07 20
  LDA $0001                                     ; $EFEE: AD 01 00
  CLC                                           ; $EFF1: 18
  ADC #$08                                      ; $EFF2: 69 08
  STA $0001                                     ; $EFF4: 8D 01 00
  INY                                           ; $EFF7: C8
  CPY $0000                                     ; $EFF8: CC 00 00
  BCC @write_loop1                              ; $EFFB: 90 DF
  LDA $0189                                     ; $EFFD: AD 89 01
  AND #$C7                                      ; $F000: 29 C7
  STA $0001                                     ; $F002: 8D 01 00
@write_loop2:
  CPY #$08                                      ; $F005: C0 08
  BCS @done                                     ; $F007: B0 1E
  LDA $0188                                     ; $F009: AD 88 01
  STA $2006                                     ; $F00C: 8D 06 20
  LDA $0001                                     ; $F00F: AD 01 00
  STA $2006                                     ; $F012: 8D 06 20
  LDA $018A,Y                                   ; $F015: B9 8A 01
  STA $2007                                     ; $F018: 8D 07 20
  LDA $0001                                     ; $F01B: AD 01 00
  CLC                                           ; $F01E: 18
  ADC #$08                                      ; $F01F: 69 08
  STA $0001                                     ; $F021: 8D 01 00
  INY                                           ; $F024: C8
  BNE @write_loop2                              ; $F025: D0 DE
@done:
  RTS                                           ; $F027: 60
.endproc

;===============================================================================
; $F028: PPU Attribute Tile Write (Alt - Horizontal mode)
; Writes attribute data from $019E buffer
; Address from $019C/$019D, handles wrap at 8 bytes
;===============================================================================
.proc PpuAttrTileWriteAlt
  LDA addr_ppu_ctrl_ram                         ; $F028: AD 8B 00
  AND #$FB                                      ; $F02B: 29 FB
  STA $2000                                     ; $F02D: 8D 00 20
  LDA $2002                                     ; $F030: AD 02 20
  LDA $019C                                     ; $F033: AD 9C 01
  STA $2006                                     ; $F036: 8D 06 20
  LDA $019D                                     ; $F039: AD 9D 01
  STA $2006                                     ; $F03C: 8D 06 20
  AND #$07                                      ; $F03F: 29 07
  STA $0000                                     ; $F041: 8D 00 00
  LDA #$08                                      ; $F044: A9 08
  SEC                                           ; $F046: 38
  SBC $0000                                     ; $F047: ED 00 00
  STA $0000                                     ; $F04A: 8D 00 00
  LDY #$00                                      ; $F04D: A0 00
@write_loop1:
  LDA $019E,Y                                   ; $F04F: B9 9E 01
  STA $2007                                     ; $F052: 8D 07 20
  INY                                           ; $F055: C8
  CPY $0000                                     ; $F056: CC 00 00
  BCC @write_loop1                              ; $F059: 90 F4
  LDA $019C                                     ; $F05B: AD 9C 01
  STA $2006                                     ; $F05E: 8D 06 20
  LDA $019D                                     ; $F061: AD 9D 01
  AND #$F8                                      ; $F064: 29 F8
  STA $2006                                     ; $F066: 8D 06 20
@write_loop2:
  CPY #$08                                      ; $F069: C0 08
  BCS @done                                     ; $F06B: B0 09
  LDA $019E,Y                                   ; $F06D: B9 9E 01
  STA $2007                                     ; $F070: 8D 07 20
  INY                                           ; $F073: C8
  BNE @write_loop2                              ; $F074: D0 F3
@done:
  RTS                                           ; $F076: 60
.endproc

;===============================================================================
; $F077: Namco-163 Sound Register Change Detect
; Compares $009C and $009D, flags changes in $0094/$0095
;===============================================================================
.proc NamcoSoundRegRead
  LDA addr_ctrl_state_x                         ; $F077: AD 9C 00
  EOR addr_ctrl_state_y                         ; $F07A: 4D 9D 00
  PHA                                           ; $F07D: 48
  AND #$C0                                      ; $F07E: 29 C0
  BEQ @check_low                                ; $F080: F0 05
  LDY #$FF                                      ; $F082: A0 FF
  STY addr_input_prev_y                         ; $F084: 8C 95 00
@check_low:
  PLA                                           ; $F087: 68
  AND #$30                                      ; $F088: 29 30
  BEQ @done                                     ; $F08A: F0 05
  LDY #$FF                                      ; $F08C: A0 FF
  STY addr_input_prev_x                         ; $F08E: 8C 94 00
@done:
  RTS                                           ; $F091: 60
.endproc

;===============================================================================
; $F092: Sprite OAM Writer (with scroll offsets)
; Converts sprite data at ($00) with scroll/flip handling
; Input: $00/$01 = sprite data ptr, $02 = flip flags
;        $0A/$0B = X offset, $0C/$0D = Y offset
;        $007C = starting OAM slot index
;===============================================================================
.proc SpriteOamWriterScroll
  LDA #$00                                      ; $F092: A9 00
  STA $0003                                     ; $F094: 8D 03 00
  LDA #$F0                                      ; $F097: A9 F0
  STA $0004                                     ; $F099: 8D 04 00
  BIT $0002                                     ; $F09C: 2C 02 00
  BPL @skip_x_flip                              ; $F09F: 10 12
  LDA $000A                                     ; $F0A1: AD 0A 00
  SEC                                           ; $F0A4: 38
  SBC #$08                                      ; $F0A5: E9 08
  CMP #$F0                                      ; $F0A7: C9 F0
  BCC @store_x                                  ; $F0A9: 90 05
  SBC #$10                                      ; $F0AB: E9 10
  DEC $000B                                     ; $F0AD: CE 0B 00
@store_x:
  STA $000A                                     ; $F0B0: 8D 0A 00
@skip_x_flip:
  BIT $0002                                     ; $F0B3: 2C 02 00
  BVC @apply_scroll                             ; $F0B6: 50 0E
  LDA $000C                                     ; $F0B8: AD 0C 00
  SEC                                           ; $F0BB: 38
  SBC #$10                                      ; $F0BC: E9 10
  STA $000C                                     ; $F0BE: 8D 0C 00
  BCS @apply_scroll                             ; $F0C1: B0 03
  DEC $000D                                     ; $F0C3: CE 0D 00
@apply_scroll:
  LDA $000A                                     ; $F0C6: AD 0A 00
  SEC                                           ; $F0C9: 38
  SBC addr_scroll_y                             ; $F0CA: ED 90 00
  BCS @no_borrow_x                              ; $F0CD: B0 04
  SEC                                           ; $F0CF: 38
  SBC #$10                                      ; $F0D0: E9 10
  CLC                                           ; $F0D2: 18
@no_borrow_x:
  STA $000A                                     ; $F0D3: 8D 0A 00
  LDA $000B                                     ; $F0D6: AD 0B 00
  SBC addr_scroll_y_hi                          ; $F0D9: ED 91 00
  STA $000B                                     ; $F0DC: 8D 0B 00
  LDA $000C                                     ; $F0DF: AD 0C 00
  SEC                                           ; $F0E2: 38
  SBC addr_scroll_x                             ; $F0E3: ED 8E 00
  STA $000C                                     ; $F0E6: 8D 0C 00
  LDA $000D                                     ; $F0E9: AD 0D 00
  SBC addr_scroll_x_hi                          ; $F0EC: ED 8F 00
  STA $000D                                     ; $F0EF: 8D 0D 00
  LDY #$00                                      ; $F0F2: A0 00
  LDX addr_sprite_count                         ; $F0F4: AE 7C 00
@main_loop:
  CPX #$FF                                      ; $F0F7: E0 FF
  BNE @process_sprite                           ; $F0F9: D0 04
@end:
  STX addr_sprite_count                         ; $F0FB: 8E 7C 00
  RTS                                           ; $F0FE: 60
@process_sprite:
  LDA $000B                                     ; $F0FF: AD 0B 00
  STA $000F                                     ; $F102: 8D 0F 00
  LDA ($00),Y                                   ; $F105: B1 00
  CMP #$80                                      ; $F107: C9 80
  BEQ @end                                      ; $F109: F0 F0
  BIT $0002                                     ; $F10B: 2C 02 00
  BPL @no_x_mirror                              ; $F10E: 10 05
  LDA #$08                                      ; $F110: A9 08
  SEC                                           ; $F112: 38
  SBC ($00),Y                                   ; $F113: F1 00
@no_x_mirror:
  CMP #$80                                      ; $F115: C9 80
  BCS @negative_x                               ; $F117: B0 0F
  ADC $000A                                     ; $F119: 6D 0A 00
  STA $000E                                     ; $F11C: 8D 0E 00
  LDA $000B                                     ; $F11F: AD 0B 00
  ADC #$00                                      ; $F122: 69 00
  BEQ @visible                                  ; $F124: F0 1A
  BNE @skip_sprite                              ; $F126: D0 7E
@negative_x:
  EOR #$FF                                      ; $F128: 49 FF
  ADC #$00                                      ; $F12A: 69 00
  STA $000E                                     ; $F12C: 8D 0E 00
  LDA $000A                                     ; $F12F: AD 0A 00
  SEC                                           ; $F132: 38
  SBC $000E                                     ; $F133: ED 0E 00
  STA $000E                                     ; $F136: 8D 0E 00
  LDA $000B                                     ; $F139: AD 0B 00
  SBC #$00                                      ; $F13C: E9 00
  BNE @skip_sprite                              ; $F13E: D0 66
@visible:
  LDA $000E                                     ; $F140: AD 0E 00
  SEC                                           ; $F143: 38
  SBC #$01                                      ; $F144: E9 01
  CMP $0004                                     ; $F146: CD 04 00
  BCS @skip_sprite                              ; $F149: B0 5B
  STA $0200,X                                   ; $F14B: 9D 00 02
  INY                                           ; $F14E: C8
  LDA ($00),Y                                   ; $F14F: B1 00
  CLC                                           ; $F151: 18
  ADC $0003                                     ; $F152: 6D 03 00
  STA $0201,X                                   ; $F155: 9D 01 02
  INY                                           ; $F158: C8
  LDA ($00),Y                                   ; $F159: B1 00
  EOR $0002                                     ; $F15B: 4D 02 00
  STA $0202,X                                   ; $F15E: 9D 02 02
  INY                                           ; $F161: C8
  BIT $0002                                     ; $F162: 2C 02 00
  LDA ($00),Y                                   ; $F165: B1 00
  BVC @no_y_mirror                              ; $F167: 50 05
  LDA #$08                                      ; $F169: A9 08
  SEC                                           ; $F16B: 38
  SBC ($00),Y                                   ; $F16C: F1 00
@no_y_mirror:
  BPL @positive_y                               ; $F16E: 10 26
  EOR #$FF                                      ; $F170: 49 FF
  STA $000E                                     ; $F172: 8D 0E 00
  LDA $000C                                     ; $F175: AD 0C 00
  SEC                                           ; $F178: 38
  SBC $000E                                     ; $F179: ED 0E 00
  STA $0203,X                                   ; $F17C: 9D 03 02
  LDA $000D                                     ; $F17F: AD 0D 00
  SBC #$00                                      ; $F182: E9 00
  BNE @skip_y_offscreen                         ; $F184: D0 0C
@advance_slot:
  INY                                           ; $F186: C8
  INX                                           ; $F187: E8
  INX                                           ; $F188: E8
  INX                                           ; $F189: E8
  INX                                           ; $F18A: E8
  BNE @back_to_loop                             ; $F18B: D0 02
  LDX #$FF                                      ; $F18D: A2 FF
@back_to_loop:
  JMP @main_loop                                ; $F18F: 4C F7 F0
@skip_y_offscreen:
  INY                                           ; $F192: C8
  JMP @main_loop                                ; $F193: 4C F7 F0
@positive_y:
  CLC                                           ; $F196: 18
  ADC $000C                                     ; $F197: 6D 0C 00
  STA $0203,X                                   ; $F19A: 9D 03 02
  LDA $000D                                     ; $F19D: AD 0D 00
  ADC #$00                                      ; $F1A0: 69 00
  BEQ @advance_slot                             ; $F1A2: F0 E2
  BNE @skip_y_offscreen                         ; $F1A4: D0 EC
@skip_sprite:
  INY                                           ; $F1A6: C8
  INY                                           ; $F1A7: C8
  INY                                           ; $F1A8: C8
  INY                                           ; $F1A9: C8
  JMP @main_loop                                ; $F1AA: 4C F7 F0
.endproc

;===============================================================================
; $F1AD: Sprite OAM Writer (Simple - no scroll)
; Converts sprite data at ($00) directly to OAM
; Input: $00/$01 = sprite data ptr, $02 = flip flags
;        $0A = X base, $0C = Y base, $007C = OAM slot
;===============================================================================
.proc SpriteOamWriterSimple
  LDA #$00                                      ; $F1AD: A9 00
  STA $0003                                     ; $F1AF: 8D 03 00
  LDA #$00                                      ; $F1B2: A9 00
  STA $0004                                     ; $F1B4: 8D 04 00
  LDY #$00                                      ; $F1B7: A0 00
  LDX addr_sprite_count                         ; $F1B9: AE 7C 00
@main_loop:
  CPX #$FF                                      ; $F1BC: E0 FF
  BNE @process                                  ; $F1BE: D0 04
@end:
  STX addr_sprite_count                         ; $F1C0: 8E 7C 00
  RTS                                           ; $F1C3: 60
@process:
  LDA ($00),Y                                   ; $F1C4: B1 00
  CMP #$80                                      ; $F1C6: C9 80
  BEQ @end                                      ; $F1C8: F0 F6
  CLC                                           ; $F1CA: 18
  ADC $000A                                     ; $F1CB: 6D 0A 00
  CMP $0004                                     ; $F1CE: CD 04 00
  BCS @write_oam                                ; $F1D1: B0 07
  INY                                           ; $F1D3: C8
  INY                                           ; $F1D4: C8
  INY                                           ; $F1D5: C8
  INY                                           ; $F1D6: C8
  JMP @process                                  ; $F1D7: 4C C4 F1
@write_oam:
  STA $0200,X                                   ; $F1DA: 9D 00 02
  INY                                           ; $F1DD: C8
  LDA ($00),Y                                   ; $F1DE: B1 00
  CLC                                           ; $F1E0: 18
  ADC $0003                                     ; $F1E1: 6D 03 00
  STA $0201,X                                   ; $F1E4: 9D 01 02
  INY                                           ; $F1E7: C8
  LDA ($00),Y                                   ; $F1E8: B1 00
  EOR $0002                                     ; $F1EA: 4D 02 00
  STA $0202,X                                   ; $F1ED: 9D 02 02
  INY                                           ; $F1F0: C8
  LDA ($00),Y                                   ; $F1F1: B1 00
  CLC                                           ; $F1F3: 18
  ADC $000C                                     ; $F1F4: 6D 0C 00
  STA $0203,X                                   ; $F1F7: 9D 03 02
  INY                                           ; $F1FA: C8
  INX                                           ; $F1FB: E8
  INX                                           ; $F1FC: E8
  INX                                           ; $F1FD: E8
  INX                                           ; $F1FE: E8
  BNE @main_loop                                ; $F1FF: D0 BB
  LDX #$FF                                      ; $F201: A2 FF
  JMP @end                                      ; $F203: 4C C0 F1
.endproc

;===============================================================================
; $F206: CHR Bank Switch
; Writes 8 CHR bank values from $00AE-$00B5 to Namco-163
; CHR registers at $8000/$8800/$9000/$9800/$A000/$A800/$B000/$B800
;===============================================================================
.proc ChrBankSwitch
  LDA addr_chr_bank_0                           ; $F206: AD AE 00
  STA $8000                                     ; $F209: 8D 00 80
  LDA addr_chr_bank_1                           ; $F20C: AD AF 00
  STA $8800                                     ; $F20F: 8D 00 88
  LDA addr_chr_bank_2                           ; $F212: AD B0 00
  STA $9000                                     ; $F215: 8D 00 90
  LDA addr_chr_bank_3                           ; $F218: AD B1 00
  STA $9800                                     ; $F21B: 8D 00 98
  LDA addr_chr_bank_4                           ; $F21E: AD B2 00
  STA $A000                                     ; $F221: 8D 00 A0
  LDA addr_chr_bank_5                           ; $F224: AD B3 00
  STA $A800                                     ; $F227: 8D 00 A8
  LDA addr_chr_bank_6                           ; $F22A: AD B4 00
  STA $B000                                     ; $F22D: 8D 00 B0
  LDA addr_chr_bank_7                           ; $F230: AD B5 00
  STA $B800                                     ; $F233: 8D 00 B8
  RTS                                           ; $F236: 60
.endproc

;===============================================================================
; $F237: Switch Bank Pair at $A000+$C000 (Slot B)
; Input: Y = bank number for $A000 window (Y+1 maps to $C000)
; Writes to Namco-163 registers $E800 (A000, with CHR flags $C0) and $F000 (C000)
; Saves bank numbers to RAM slot B ($00E2, $00E3)
;===============================================================================
.proc SwitchBankAC_B
  STY addr_prg_select_2b                        ; $F237: 8C E2 00
  INY                                           ; $F23A: C8
  STY addr_prg_select_3b                        ; $F23B: 8C E3 00
  STY $F000                                     ; $F23E: 8C 00 F0
  DEY                                           ; $F241: 88
  PHA                                           ; $F242: 48
  TYA                                           ; $F243: 98
  ORA #$C0                                      ; $F244: 09 C0
  STA $E800                                     ; $F246: 8D 00 E8
  PLA                                           ; $F249: 68
  RTS                                           ; $F24A: 60
.endproc

;===============================================================================
; $F24B: Switch Bank Pair at $A000+$C000 (Slot A)
; Input: Y = bank number for $A000 window (Y+1 maps to $C000)
; Writes to Namco-163 registers $E800 (A000, with CHR flags $C0) and $F000 (C000)
; Saves bank numbers to RAM slot A ($00DF, $00E0)
;===============================================================================
.proc SwitchBankAC_A
  STY addr_prg_select_2a                        ; $F24B: 8C DF 00
  INY                                           ; $F24E: C8
  STY addr_prg_select_3a                        ; $F24F: 8C E0 00
  STY $F000                                     ; $F252: 8C 00 F0
  DEY                                           ; $F255: 88
  PHA                                           ; $F256: 48
  TYA                                           ; $F257: 98
  ORA #$C0                                      ; $F258: 09 C0
  STA $E800                                     ; $F25A: 8D 00 E8
  PLA                                           ; $F25D: 68
  RTS                                           ; $F25E: 60
.endproc

;===============================================================================
; $F25F: Switch Bank at $8000 (Slot B)
; Input: Y = bank number for $8000-$9FFF window
; Writes to Namco-163 register $E000, saves to RAM slot B ($00E1)
;===============================================================================
.proc SwitchBank8000_B
  STY addr_prg_select_1b                        ; $F25F: 8C E1 00
  STY $E000                                     ; $F262: 8C 00 E0
  RTS                                           ; $F265: 60
.endproc

;===============================================================================
; $F266: Switch Bank at $8000 (Slot A)
; Input: Y = bank number for $8000-$9FFF window
; Writes to Namco-163 register $E000, saves to RAM slot A ($00DE)
;===============================================================================
.proc SwitchBank8000_A
  STY addr_prg_select_1a                        ; $F266: 8C DE 00
  STY $E000                                     ; $F269: 8C 00 E0
  RTS                                           ; $F26C: 60
.endproc

;===============================================================================
; $F26D: Set UI Mode 0
; Input: A = UI ID
; Sets UI sub-ID to 0, clears next/FF markers
;===============================================================================
.proc SetUI0
  STA $0311                                     ; $F26D: 8D 11 03
  LDA #$00                                      ; $F270: A9 00
@common:
  STA $0310                                     ; $F272: 8D 10 03
  LDA #$FF                                      ; $F275: A9 FF
  STA $0312                                     ; $F277: 8D 12 03
  STA $0313                                     ; $F27A: 8D 13 03
  LDA #$00                                      ; $F27D: A9 00
  STA $0300                                     ; $F27F: 8D 00 03
  RTS                                           ; $F282: 60
.endproc

;===============================================================================
; $F283: Set UI Mode 2
; Input: A = UI ID
;===============================================================================
.proc SetUI2
  STA $0311                                     ; $F283: 8D 11 03
  LDA #$02                                      ; $F286: A9 02
  JMP SetUI0::@common                           ; $F288: 4C 72 F2
.endproc

;===============================================================================
; $F28B: Set UI Mode 4
; Input: A = UI ID
;===============================================================================
.proc SetUI4
  STA $0311                                     ; $F28B: 8D 11 03
  LDA #$04                                      ; $F28E: A9 04
  JMP SetUI0::@common                           ; $F290: 4C 72 F2
.endproc

;===============================================================================
; $F293: Set UI Mode 5
; Input: A = UI ID
;===============================================================================
.proc SetUI5
  STA $0311                                     ; $F293: 8D 11 03
  LDA #$05                                      ; $F296: A9 05
  JMP SetUI0::@common                           ; $F298: 4C 72 F2
.endproc

;===============================================================================
; $F29B: Clear UI
; Clears all UI state, sets UI ID to $FF
;===============================================================================
.proc ClearUI
  STA $0310                                     ; $F29B: 8D 10 03
  LDA #$FF                                      ; $F29E: A9 FF
  STA $0311                                     ; $F2A0: 8D 11 03
  STA $0312                                     ; $F2A3: 8D 12 03
  STA $0313                                     ; $F2A6: 8D 13 03
  LDA #$00                                      ; $F2A9: A9 00
  STA $0300                                     ; $F2AB: 8D 00 03
  RTS                                           ; $F2AE: 60
.endproc

; End of range $E843-$F2AE
