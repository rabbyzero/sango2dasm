; Bytes:
; - instruction: 7306
; - data       : 886
; Labels:
; - named    : 470
; - anonymous: 124
; Bytes in CDL file:
; - instruction  : 0
; - data         : 164
; - unaccessed   : 8028

; --- Macros ------------------------------------------------------------------

; force 16-bit addressing (absolute/absolute,x/absolute,y) with
; operands <= $ff
macro ora_abs _zp
                db $0d, _zp, $00
endm
macro asl_abs _zp
                db $0e, _zp, $00
endm
macro bit_abs _zp
                db $2c, _zp, $00
endm
macro and_abs _zp
                db $2d, _zp, $00
endm
macro rol_abs _zp
                db $2e, _zp, $00
endm
macro eor_abs _zp
                db $4d, _zp, $00
endm
macro adc_abs _zp
                db $6d, _zp, $00
endm
macro ror_abs _zp
                db $6e, _zp, $00
endm
macro sty_abs _zp
                db $8c, _zp, $00
endm
macro sta_abs _zp
                db $8d, _zp, $00
endm
macro stx_abs _zp
                db $8e, _zp, $00
endm
macro ldy_abs _zp
                db $ac, _zp, $00
endm
macro lda_abs _zp
                db $ad, _zp, $00
endm
macro ldx_abs _zp
                db $ae, _zp, $00
endm
macro lda_absx _zp
                db $bd, _zp, $00
endm
macro cpy_abs _zp
                db $cc, _zp, $00
endm
macro cmp_abs _zp
                db $cd, _zp, $00
endm
macro dec_abs _zp
                db $ce, _zp, $00
endm
macro cmp_absx _zp
                db $dd, _zp, $00
endm
macro sbc_abs _zp
                db $ed, _zp, $00
endm
macro inc_abs _zp
                db $ee, _zp, $00
endm

; --- Address constants at $0000-$7fff ----------------------------------------

; 'arr' = RAM array, 'ram' = RAM non-array, 'misc' = $2000-$7fff
; note: unused hardware registers commented out

arr1            equ $00
ram1            equ $01
ram2            equ $02
ram3            equ $03
ram4            equ $04
ram5            equ $05
ram6            equ $06
arr2            equ $07
ram7            equ $08
arr3            equ $09
arr4            equ $0a
ram8            equ $0b
ram9            equ $0c
ram10           equ $0d
ram11           equ $0e
ram12           equ $0f
arr5            equ $10
ram13           equ $12
arr6            equ $17
arr7            equ $18
arr8            equ $1a
ram14           equ $1b
ram15           equ $1e
arr9            equ $20
ram16           equ $21
ram17           equ $22
arr10           equ $24
ram18           equ $25
ram19           equ $26
ram20           equ $27
ram21           equ $30
arr11           equ $31
arr12           equ $32
arr13           equ $33
ram22           equ $34
arr14           equ $36
arr15           equ $37
ram23           equ $3a
ram24           equ $42
arr16           equ $43
ram25           equ $44
ram26           equ $46
ram27           equ $47
ram28           equ $4e
ram29           equ $4f
ram30           equ $50
ram31           equ $51
ram32           equ $52
ram33           equ $53
arr17           equ $54
ram34           equ $55
ram35           equ $58
ram36           equ $59
ram37           equ $5a
ram38           equ $5b
ram39           equ $5c
ram40           equ $5d
ram41           equ $5e
ram42           equ $5f
ram43           equ $60
ram44           equ $61
ram45           equ $62
ram46           equ $63
ram47           equ $64
ram48           equ $65
arr18           equ $66
ram49           equ $68
ram50           equ $69
arr19           equ $6a
arr20           equ $6b
ram51           equ $6c
ram52           equ $6d
ram53           equ $70
ram54           equ $72
ram55           equ $73
ram56           equ $74
arr21           equ $75
ram57           equ $77
ram58           equ $78
ram59           equ $7a
ram60           equ $7b
ram61           equ $7c
arr22           equ $7d
ram62           equ $7e
ram63           equ $81
ram64           equ $82
ram65           equ $83
ram66           equ $84
ram67           equ $85
ram68           equ $86
ram69           equ $87
ram70           equ $88
ram71           equ $89
ram72           equ $8a
ram73           equ $8b
arr23           equ $8c
arr24           equ $8d
ram74           equ $8e
ram75           equ $8f
ram76           equ $90
ram77           equ $91
ram78           equ $94
ram79           equ $95
ram80           equ $96
arr25           equ $97
ram81           equ $98
ram82           equ $99
ram83           equ $9a
ram84           equ $9b
ram85           equ $9c
ram86           equ $9d
ram87           equ $a0
ram88           equ $a4
ram89           equ $a5
ram90           equ $a6
ram91           equ $a9
ram92           equ $ab
ram93           equ $ae
ram94           equ $af
ram95           equ $b0
ram96           equ $b2
ram97           equ $b4
arr26           equ $b6
ram98           equ $b7
ram99           equ $b8
ram100          equ $ba
ram101          equ $bb
ram102          equ $bc
ram103          equ $bd
ram104          equ $be
ram105          equ $bf
ram106          equ $c0
ram107          equ $c2
ram108          equ $c3
ram109          equ $c4
ram110          equ $c6
ram111          equ $c7
ram112          equ $c8
ram113          equ $ca
ram114          equ $cb
ram115          equ $cc
ram116          equ $ce
ram117          equ $cf
ram118          equ $d0
ram119          equ $d1
ram120          equ $d2
ram121          equ $d3
ram122          equ $d4
ram123          equ $d6
ram124          equ $d7
ram125          equ $d8
ram126          equ $d9
ram127          equ $da
ram128          equ $db
ram129          equ $dc
PRGSelect1A     equ $de
PRGSelect2A     equ $df
PRGSelect3A     equ $e0
PRGSelect1B     equ $e1
PRGSelect2B     equ $e2
PRGSelect3B     equ $e3
ram136          equ $e6
ram137          equ $e7
ram138          equ $e8
ram139          equ $e9
ram140          equ $ea
ram141          equ $eb
ram142          equ $ec
ram143          equ $ed
ram144          equ $f0
ram145          equ $f1
arr27           equ $f6
arr28           equ $f8
ram146          equ $f9
arr29           equ $0100
arr30           equ $0101
ram147          equ $0106
ram148          equ $0107
ram149          equ $010e
ram150          equ $010f
ram151          equ $0113
ram152          equ $0116
ram153          equ $0117
ram154          equ $011a
ram155          equ $0140
ram156          equ $0141
arr31           equ $0142
ram157          equ $0164
ram158          equ $0165
arr32           equ $0166
ram159          equ $0188
ram160          equ $0189
arr33           equ $018a
ram161          equ $019c
ram162          equ $019d
arr34           equ $019e
arr35           equ $0200
arr36           equ $0201
arr37           equ $0202
arr38           equ $0203
ram163          equ $0300
ram164          equ $0304
UIsubid         equ $0310
UIid            equ $0311
UIidnext        equ $0312
UIidFF          equ $0313
ram169          equ $03aa
ram170          equ $0400
ram171          equ $0420
ram172          equ $0424
ram173          equ $0425
ram174          equ $04ab
ram175          equ $04ac
ram176          equ $04e0
ram177          equ $04e1
ram178          equ $04e2
ram179          equ $04e3
ram180          equ $0500
ram181          equ $0508
ram182          equ $0510
ram183          equ $0511
ram184          equ $0512
ram185          equ $0513
ram186          equ $0518
ram187          equ $0541
ram188          equ $0544
ram189          equ $0561
ram190          equ $0562
ram191          equ $0563
arr39           equ $0700
arr40           equ $0701
arr41           equ $0702
arr42           equ $0703
arr43           equ $0706
ram192          equ $07f2
ram193          equ $07f6
arr44           equ $0a31
ram194          equ $0b0d
arr45           equ $0c33
arr46           equ $1225
ram195          equ $148f
ram196          equ $19ae
ram197          equ $1d1c
ram198          equ $1d7a
ram199          equ $1e0f
ppu_ctrl        equ $2000
ppu_mask        equ $2001
ppu_status      equ $2002
oam_addr        equ $2003
;oam_data       equ $2004
ppu_scroll      equ $2005
ppu_addr        equ $2006
ppu_data        equ $2007
misc1           equ $203f
misc2           equ $2233
misc3           equ $226f
misc4           equ $2323
misc5           equ $2333
misc6           equ $2b4d
misc7           equ $2e76
misc8           equ $2f2e
misc9           equ $3332
misc10          equ $350b
misc11          equ $365e
misc12          equ $3937
misc13          equ $3c2d
misc14          equ $3d7b
sq1_vol         equ $4000
sq1_sweep       equ $4001
;sq1_lo         equ $4002
;sq1_hi         equ $4003
sq2_vol         equ $4004
sq2_sweep       equ $4005
;sq2_lo         equ $4006
;sq2_hi         equ $4007
tri_linear      equ $4008
;tri_lo         equ $400a
;tri_hi         equ $400b
noise_vol       equ $400c
;noise_lo       equ $400e
;noise_hi       equ $400f
dmc_freq        equ $4010
;dmc_raw        equ $4011
;dmc_start      equ $4012
;dmc_len        equ $4013
oam_dma         equ $4014
snd_chn         equ $4015
joypad1         equ $4016
joypad2         equ $4017
misc15          equ $4800
misc16          equ $4f4b
misc17          equ $4f4e
misc18          equ $5000
misc19          equ $570f
misc20          equ $5800
misc21          equ $5c23
misc22          equ $5d3b
misc23          equ $5d4e
misc24          equ $5e3b
misc25          equ $605e
misc26          equ $60bf
misc27          equ $6162
misc28          equ $672d
misc29          equ $6af8
misc30          equ $6ba3
misc31          equ $6f33
misc32          equ $6f3f
misc33          equ $6f41
misc34          equ $6f44
misc35          equ $6f8b
misc36          equ $7370
misc37          equ $7372
misc38          equ $7e23
misc39          equ $7fc9

; --- PRG ROM (CPU $e000-$ffff) -----------------------------------------------

; labels: 'sub' = subroutine, 'cod' = code, 'dat' = data

                org $e000

RSTFUNC         sei                          ; e000: 78       (unaccessed)
                cld                          ; e001: d8       (unaccessed)
                lda #0                       ; e002: a9 00    (unaccessed)
                sta ppu_ctrl                 ; e004: 8d 00 20 (unaccessed)
                sta ppu_mask                 ; e007: 8d 01 20 (unaccessed)
                ldy #2                       ; e00a: a0 02    (unaccessed)
cod1            lda ppu_status               ; e00c: ad 02 20 (unaccessed)
                bpl cod1                     ; e00f: 10 fb    (unaccessed)
-               lda ppu_status               ; e011: ad 02 20 (unaccessed)
                bmi -                        ; e014: 30 fb    (unaccessed)
                dey                          ; e016: 88       (unaccessed)
                bpl cod1                     ; e017: 10 f3    (unaccessed)
                lda #0                       ; e019: a9 00    (unaccessed)
                sta dmc_freq                 ; e01b: 8d 10 40 (unaccessed)
                lda #$0f                     ; e01e: a9 0f    (unaccessed)
                sta snd_chn                  ; e020: 8d 15 40 (unaccessed)
                lda #$c0                     ; e023: a9 c0    (unaccessed)
                sta joypad2                  ; e025: 8d 17 40 (unaccessed)
                lda #0                       ; e028: a9 00    (unaccessed)
                sta ppu_ctrl                 ; e02a: 8d 00 20 (unaccessed)
                sta ppu_mask                 ; e02d: 8d 01 20 (unaccessed)
                ldy #4                       ; e030: a0 04    (unaccessed)
cod2            lda ppu_status               ; e032: ad 02 20 (unaccessed)
                bpl cod2                     ; e035: 10 fb    (unaccessed)
cod3            lda ppu_status               ; e037: ad 02 20 (unaccessed)
                bmi cod3                     ; e03a: 30 fb    (unaccessed)
                dey                          ; e03c: 88       (unaccessed)
                bpl cod2                     ; e03d: 10 f3    (unaccessed)
                ldx #$ff                     ; e03f: a2 ff    (unaccessed)
                txs                          ; e041: 9a       (unaccessed)
                lda #4                       ; e042: a9 04    (unaccessed)
                sta_abs ram1                 ; e044: 8d 01 00 (unaccessed)
                ldy #0                       ; e047: a0 00    (unaccessed)
                sty_abs ram2                 ; e049: 8c 02 00 (unaccessed)
-               tya                          ; e04c: 98       (unaccessed)
                sta (ram1),y                 ; e04d: 91 01    (unaccessed)
                inc_abs ram1                 ; e04f: ee 01 00 (unaccessed)
                bne -                        ; e052: d0 f8    (unaccessed)
                inc_abs ram2                 ; e054: ee 02 00 (unaccessed)
                lda_abs ram2                 ; e057: ad 02 00 (unaccessed)
                cmp #8                       ; e05a: c9 08    (unaccessed)
                bcc -                        ; e05c: 90 ee    (unaccessed)
                jsr sub41                    ; e05e: 20 bd f3 (unaccessed)
                lda #0                       ; e061: a9 00    (unaccessed)
                sta_abs ram59                ; e063: 8d 7a 00 (unaccessed)
MAINLOOP        lda_abs ram59                ; e066: ad 7a 00 (unaccessed)
                and #%00011111               ; e069: 29 1f    (unaccessed)
                asl a                        ; e06b: 0a       (unaccessed)
                tay                          ; e06c: a8       (unaccessed)
                lda MainLoopBaseL,y          ; e06d: b9 7c e0 (unaccessed)
                sta_abs ram28                ; e070: 8d 4e 00 (unaccessed)
                lda MainLoopBaseH,y          ; e073: b9 7d e0 (unaccessed)
                sta_abs ram29                ; e076: 8d 4f 00 (unaccessed)
                jmp (ram28)                  ; e079: 6c 4e 00 (unaccessed)
MainLoopBaseL   hex 9a                       ; e07c //main loop sequence?  0 -> 9 -> a -> wait NMI
MainLoopBaseH   hex E0                       ; e07d
                hex DA E0 7D E1 8B E1 21 E2  ; e07e
                hex 2F E2 E2 E2 E8 E2 6A E3  ; e085
                hex 7C E3 EB E3 EE E3 EB E3  ; e08d
                hex 6A E4 EB E3              ; e095

MAINLOOP0       jsr sub16                    ; e09a: 20 68 e7 (unaccessed)
                jsr sub14                    ; e09d: 20 4d e7 (unaccessed)
                sta ppu_mask                 ; e0a0: 8d 01 20 (unaccessed)
                jsr subE57F                  ; e0a3: 20 7f e5 (unaccessed)
                ldx #$1f                     ; e0a6: a2 1f    (unaccessed)
                lda #$0f                     ; e0a8: a9 0f    (unaccessed)
-               sta arr29,x                  ; e0aa: 9d 00 01 (unaccessed)
                dex                          ; e0ad: ca       (unaccessed)
                bpl -                        ; e0ae: 10 fa    (unaccessed)
-               lda ppu_status               ; e0b0: ad 02 20 (unaccessed)
                bpl -                        ; e0b3: 10 fb    (unaccessed)
                lda #$4c                     ; e0b5: a9 4c    (unaccessed)
                sta_abs ram89                ; e0b7: 8d a5 00 (unaccessed)
                sta_abs $f800                ; e0ba: 8d 00 f8 (unaccessed)
                lda #0                       ; e0bd: a9 00    (unaccessed)
                jsr sub3                     ; e0bf: 20 1f e5 (unaccessed)
                lda #$10                     ; e0c2: a9 10    (unaccessed)
                sta_abs ram73                ; e0c4: 8d 8b 00 (unaccessed)
                sta ppu_ctrl                 ; e0c7: 8d 00 20 (unaccessed)
                lda #0                       ; e0ca: a9 00    (unaccessed)
                sta_abs arr23                ; e0cc: 8d 8c 00 (unaccessed)
                sta ppu_mask                 ; e0cf: 8d 01 20 (unaccessed)
                lda #9                       ; e0d2: a9 09    (unaccessed)
                sta_abs ram59                ; e0d4: 8d 7a 00 (unaccessed)
                jmp MAINLOOP                 ; e0d7: 4c 66 e0 (unaccessed)

MAINLOOP1       jsr sub2                     ; e0da: 20 da e4 (unaccessed)
                lda #2                       ; e0dd: a9 02    (unaccessed)
                sta_abs ram58                ; e0df: 8d 78 00 (unaccessed)
                lda #0                       ; e0e2: a9 00    (unaccessed)
                jsr sub1                     ; e0e4: 20 70 e3 (unaccessed)
                ldy #$30                     ; e0e7: a0 30    (unaccessed)
                jsr SelectPRG1B              ; e0e9: 20 5f f2 (unaccessed)
                lda #0                       ; e0ec: a9 00    (unaccessed)
                sta_abs arr4                 ; e0ee: 8d 0a 00 (unaccessed)
                lda #$80                     ; e0f1: a9 80    (unaccessed)
                sta_abs ram8                 ; e0f3: 8d 0b 00 (unaccessed)
                lda #$20                     ; e0f6: a9 20    (unaccessed)
                sta_abs ram1                 ; e0f8: 8d 01 00 (unaccessed)
                lda #0                       ; e0fb: a9 00    (unaccessed)
                sta_abs arr1                 ; e0fd: 8d 00 00 (unaccessed)
                sta_abs ram4                 ; e100: 8d 04 00 (unaccessed)
                sta_abs ram5                 ; e103: 8d 05 00 (unaccessed)
                sta_abs ram6                 ; e106: 8d 06 00 (unaccessed)
                lda #4                       ; e109: a9 04    (unaccessed)
                sta_abs arr2                 ; e10b: 8d 07 00 (unaccessed)
                ldy #$37                     ; e10e: a0 37    (unaccessed)
                jsr SelectPRG23B             ; e110: 20 37 f2 (unaccessed)
                jsr $a003                    ; e113: 20 03 a0 (unaccessed)
                ldy #$3d                     ; e116: a0 3d    (unaccessed)
                jsr SelectPRG23B             ; e118: 20 37 f2 (unaccessed)
                lda #0                       ; e11b: a9 00    (unaccessed)
                sta_abs arr1                 ; e11d: 8d 00 00 (unaccessed)
                jsr $a015                    ; e120: 20 15 a0 (unaccessed)
                jsr sub22                    ; e123: 20 f7 ea (unaccessed)
                lda ram170                   ; e126: ad 00 04 (unaccessed)
                cmp #$0d                     ; e129: c9 0d    (unaccessed)
                beq +                        ; e12b: f0 05    (unaccessed)
                lda #$ff                     ; e12d: a9 ff    (unaccessed)
                sta misc35                   ; e12f: 8d 8b 6f (unaccessed)
+               ldy #$3d                     ; e132: a0 3d    (unaccessed)
                jsr SelectPRG23B             ; e134: 20 37 f2 (unaccessed)
                jsr $a036                    ; e137: 20 36 a0 (unaccessed)
                jsr MOV_0100_0120            ; e13a: 20 bf ec (unaccessed)
                ldy #$3d                     ; e13d: a0 3d    (unaccessed)
                jsr SelectPRG23B             ; e13f: 20 37 f2 (unaccessed)
                lda #0                       ; e142: a9 00    (unaccessed)
                jsr $a045                    ; e144: 20 45 a0 (unaccessed)
                lda #$a0                     ; e147: a9 a0    (unaccessed)
                sta_abs ram81                ; e149: 8d 98 00 (unaccessed)
                lda #0                       ; e14c: a9 00    (unaccessed)
                sta ram171                   ; e14e: 8d 20 04 (unaccessed)
                sta ram176                   ; e151: 8d e0 04 (unaccessed)
                sta ram177                   ; e154: 8d e1 04 (unaccessed)
                sta ram178                   ; e157: 8d e2 04 (unaccessed)
                sta ram179                   ; e15a: 8d e3 04 (unaccessed)
                lda #$f0                     ; e15d: a9 f0    (unaccessed)
                sta misc33                   ; e15f: 8d 41 6f (unaccessed)
                lda #$80                     ; e162: a9 80    (unaccessed)
                sta misc32                   ; e164: 8d 3f 6f (unaccessed)
                lda #0                       ; e167: a9 00    (unaccessed)
                jsr sub3                     ; e169: 20 1f e5 (unaccessed)
                inc_abs ram59                ; e16c: ee 7a 00 (unaccessed)
                lda #$81                     ; e16f: a9 81    (unaccessed)
                jsr subE673                  ; e171: 20 73 e6 (unaccessed)
                jsr sub13                    ; e174: 20 49 e7 (unaccessed)
                jsr sub15                    ; e177: 20 53 e7 (unaccessed)
                jmp MAINLOOP                 ; e17a: 4c 66 e0 (unaccessed)
                
MAINLOOP2       jsr RNDRAW                   ; e17d: 20 7a e8 (unaccessed)
                ldy #$2a                     ; e180: a0 2a    (unaccessed)
                jsr SelectPRG23A             ; e182: 20 4b f2 (unaccessed)
                jsr $a000                    ; e185: 20 00 a0 (unaccessed)
                jmp MAINLOOP                 ; e188: 4c 66 e0 (unaccessed)

MAINLOOP3       jsr sub2                     ; e18b: 20 da e4 (unaccessed)
                lda #3                       ; e18e: a9 03    (unaccessed)
                sta_abs ram58                ; e190: 8d 78 00 (unaccessed)
                lda #1                       ; e193: a9 01    (unaccessed)
                jsr sub1                     ; e195: 20 70 e3 (unaccessed)
                ldy #$37                     ; e198: a0 37    (unaccessed)
                jsr SelectPRG23B             ; e19a: 20 37 f2 (unaccessed)
                jsr $a027                    ; e19d: 20 27 a0 (unaccessed)
                lda ram180                   ; e1a0: ad 00 05 (unaccessed)
                cmp #$0b                     ; e1a3: c9 0b    (unaccessed)
                bne +                        ; e1a5: d0 0b    (unaccessed)
                ldy #$2c                     ; e1a7: a0 2c    (unaccessed)
                jsr SelectPRG23B             ; e1a9: 20 37 f2 (unaccessed)
                jsr $a006                    ; e1ac: 20 06 a0 (unaccessed)
                jmp cod5                     ; e1af: 4c ba e1 (unaccessed)
+               ldy #$28                     ; e1b2: a0 28    (unaccessed)
                jsr SelectPRG23B             ; e1b4: 20 37 f2 (unaccessed)
                jsr $a003                    ; e1b7: 20 03 a0 (unaccessed)
cod5            lda ram182                   ; e1ba: ad 10 05 (unaccessed)
                sta_abs ram76                ; e1bd: 8d 90 00 (unaccessed)
                lda ram183                   ; e1c0: ad 11 05 (unaccessed)
                sta_abs ram77                ; e1c3: 8d 91 00 (unaccessed)
                lda ram184                   ; e1c6: ad 12 05 (unaccessed)
                sta_abs ram74                ; e1c9: 8d 8e 00 (unaccessed)
                lda ram185                   ; e1cc: ad 13 05 (unaccessed)
                sta_abs ram75                ; e1cf: 8d 8f 00 (unaccessed)
                lda #$ff                     ; e1d2: a9 ff    (unaccessed)
                sta ram186                   ; e1d4: 8d 18 05 (unaccessed)
                ldy #$37                     ; e1d7: a0 37    (unaccessed)
                jsr SelectPRG23B             ; e1d9: 20 37 f2 (unaccessed)
                jsr $a009                    ; e1dc: 20 09 a0 (unaccessed)
                ldy #$3d                     ; e1df: a0 3d    (unaccessed)
                jsr SelectPRG23B             ; e1e1: 20 37 f2 (unaccessed)
                lda #1                       ; e1e4: a9 01    (unaccessed)
                sta_abs arr1                 ; e1e6: 8d 00 00 (unaccessed)
                jsr $a015                    ; e1e9: 20 15 a0 (unaccessed)
                jsr sub22                    ; e1ec: 20 f7 ea (unaccessed)
                lda #0                       ; e1ef: a9 00    (unaccessed)
                sta ram181                   ; e1f1: 8d 08 05 (unaccessed)
                lda #$70                     ; e1f4: a9 70    (unaccessed)
                sta_abs ram49                ; e1f6: 8d 68 00 (unaccessed)
                lda #$af                     ; e1f9: a9 af    (unaccessed)
                sta_abs ram50                ; e1fb: 8d 69 00 (unaccessed)
                lda #1                       ; e1fe: a9 01    (unaccessed)
                jsr sub3                     ; e200: 20 1f e5 (unaccessed)
                lda #1                       ; e203: a9 01    (unaccessed)
                sta_abs arr25                ; e205: 8d 97 00 (unaccessed)
                jsr MOV_0100_0120            ; e208: 20 bf ec (unaccessed)
                lda #5                       ; e20b: a9 05    (unaccessed)
                sta_abs ram44                ; e20d: 8d 61 00 (unaccessed)
                inc_abs ram59                ; e210: ee 7a 00 (unaccessed)
                lda #$1d                     ; e213: a9 1d    (unaccessed)
                jsr subE673                  ; e215: 20 73 e6 (unaccessed)
                jsr sub13                    ; e218: 20 49 e7 (unaccessed)
                jsr sub15                    ; e21b: 20 53 e7 (unaccessed)
                jmp MAINLOOP                 ; e21e: 4c 66 e0 (unaccessed)

MAINLOOP4       jsr RNDRAW                   ; e221: 20 7a e8 (unaccessed)
                ldy #$28                     ; e224: a0 28    (unaccessed)
                jsr SelectPRG23A             ; e226: 20 4b f2 (unaccessed)
                jsr $a000                    ; e229: 20 00 a0 (unaccessed)
                jmp MAINLOOP                 ; e22c: 4c 66 e0 (unaccessed)

MAINLOOP5       jsr sub2                     ; e22f: 20 da e4 (unaccessed)
                lda #4                       ; e232: a9 04    (unaccessed)
                sta_abs ram58                ; e234: 8d 78 00 (unaccessed)
                lda ram188                   ; e237: ad 44 05 (unaccessed)
                clc                          ; e23a: 18       (unaccessed)
                adc #2                       ; e23b: 69 02    (unaccessed)
                jsr sub1                     ; e23d: 20 70 e3 (unaccessed)
                lda #2                       ; e240: a9 02    (unaccessed)
                jsr sub3                     ; e242: 20 1f e5 (unaccessed)
                ldy #$37                     ; e245: a0 37    (unaccessed)
                jsr SelectPRG23B             ; e247: 20 37 f2 (unaccessed)
                jsr $a024                    ; e24a: 20 24 a0 (unaccessed)
                ldy #$3d                     ; e24d: a0 3d    (unaccessed)
                jsr SelectPRG23B             ; e24f: 20 37 f2 (unaccessed)
                lda ram188                   ; e252: ad 44 05 (unaccessed)
                clc                          ; e255: 18       (unaccessed)
                adc #2                       ; e256: 69 02    (unaccessed)
                sta_abs arr1                 ; e258: 8d 00 00 (unaccessed)
                jsr $a015                    ; e25b: 20 15 a0 (unaccessed)
                ldy ram191                   ; e25e: ac 63 05 (unaccessed)
                lda dat7,y                   ; e261: b9 de e2 (unaccessed)
                sta ram148                   ; e264: 8d 07 01 (unaccessed)
                sta ram151                   ; e267: 8d 13 01 (unaccessed)
                ldy ram190                   ; e26a: ac 62 05 (unaccessed)
                lda dat7,y                   ; e26d: b9 de e2 (unaccessed)
                sta ram150                   ; e270: 8d 0f 01 (unaccessed)
                sta ram153                   ; e273: 8d 17 01 (unaccessed)
                jsr sub22                    ; e276: 20 f7 ea (unaccessed)
                ldy #$3d                     ; e279: a0 3d    (unaccessed)
                jsr SelectPRG23B             ; e27b: 20 37 f2 (unaccessed)
                lda #1                       ; e27e: a9 01    (unaccessed)
                jsr $a045                    ; e280: 20 45 a0 (unaccessed)
                lda #$a0                     ; e283: a9 a0    (unaccessed)
                sta_abs ram81                ; e285: 8d 98 00 (unaccessed)
                jsr MOV_0100_0120            ; e288: 20 bf ec (unaccessed)
                inc_abs ram59                ; e28b: ee 7a 00 (unaccessed)
                lda #$0d                     ; e28e: a9 0d    (unaccessed)
                jsr subE683                  ; e290: 20 83 e6 (unaccessed)
                jsr sub13                    ; e293: 20 49 e7 (unaccessed)
                jsr sub15                    ; e296: 20 53 e7 (unaccessed)
                jmp MAINLOOP                 ; e299: 4c 66 e0 (unaccessed)

                lda ram188                   ; e29c: ad 44 05 (unaccessed)
                asl a                        ; e29f: 0a       (unaccessed)
                tay                          ; e2a0: a8       (unaccessed)
                lda dat3,y                   ; e2a1: b9 c2 e2 (unaccessed)
                sta_abs arr4                 ; e2a4: 8d 0a 00 (unaccessed)
                lda dat4,y                   ; e2a7: b9 c3 e2 (unaccessed)
                sta_abs ram8                 ; e2aa: 8d 0b 00 (unaccessed)
                lda dat5,y                   ; e2ad: b9 d0 e2 (unaccessed)
                sta_abs ram9                 ; e2b0: 8d 0c 00 (unaccessed)
                lda dat6,y                   ; e2b3: b9 d1 e2 (unaccessed)
                sta_abs ram10                ; e2b6: 8d 0d 00 (unaccessed)
                ldy #$37                     ; e2b9: a0 37    (unaccessed)
                jsr SelectPRG23B             ; e2bb: 20 37 f2 (unaccessed)
                jsr $a006                    ; e2be: 20 06 a0 (unaccessed)
                rts                          ; e2c1: 60       (unaccessed)

dat3            hex 40                       ; e2c2           (unaccessed)
dat4            hex 84 70 85 A0 86 D0 87 00  ; e2c3
                hex 89 30 8A 60 8B           ; e2cb
dat5            hex 00                       ; e2d0
dat6            hex 80                       ; e2d1
                hex 00 80 00 80 00 80 00 80  ; e2d3
                hex 00 80 00 80              ; e2db
dat7            hex 10 0F 00 16              ; e2de

MAINLOOP6       jsr RNDRAW                   ; e2e2: 20 7a e8 (unaccessed)
                jmp MAINLOOP                 ; e2e5: 4c 66 e0 (unaccessed)

MAINLOOP7       jsr sub2                     ; e2e8: 20 da e4 (unaccessed)
                lda #5                       ; e2eb: a9 05    (unaccessed)
                sta_abs ram58                ; e2ed: 8d 78 00 (unaccessed)
                lda #$0a                     ; e2f0: a9 0a    (unaccessed)
                jsr sub1                     ; e2f2: 20 70 e3 (unaccessed)
                lda #$a0                     ; e2f5: a9 a0    (unaccessed)
                sta_abs ram81                ; e2f7: 8d 98 00 (unaccessed)
                ldy #$30                     ; e2fa: a0 30    (unaccessed)
                jsr SelectPRG1B              ; e2fc: 20 5f f2 (unaccessed)
                lda #0                       ; e2ff: a9 00    (unaccessed)
                sta_abs arr4                 ; e301: 8d 0a 00 (unaccessed)
                lda #$84                     ; e304: a9 84    (unaccessed)
                sta_abs ram8                 ; e306: 8d 0b 00 (unaccessed)
                lda #0                       ; e309: a9 00    (unaccessed)
                sta_abs arr1                 ; e30b: 8d 00 00 (unaccessed)
                lda #$20                     ; e30e: a9 20    (unaccessed)
                sta_abs ram1                 ; e310: 8d 01 00 (unaccessed)
                ldy #$37                     ; e313: a0 37    (unaccessed)
                jsr SelectPRG23B             ; e315: 20 37 f2 (unaccessed)
                jsr $a003                    ; e318: 20 03 a0 (unaccessed)
                ldy #$3d                     ; e31b: a0 3d    (unaccessed)
                jsr SelectPRG23B             ; e31d: 20 37 f2 (unaccessed)
                lda #$0a                     ; e320: a9 0a    (unaccessed)
                sta_abs arr1                 ; e322: 8d 00 00 (unaccessed)
                jsr $a015                    ; e325: 20 15 a0 (unaccessed)
                jsr sub22                    ; e328: 20 f7 ea (unaccessed)
                ldx #0                       ; e32b: a2 00    (unaccessed)
                lda ram174                   ; e32d: ad ab 04 (unaccessed)
                cmp #1                       ; e330: c9 01    (unaccessed)
                bne +                        ; e332: d0 06    (unaccessed)
                stx ram147                   ; e334: 8e 06 01 (unaccessed)
                stx ram152                   ; e337: 8e 16 01 (unaccessed)
+               lda ram175                   ; e33a: ad ac 04 (unaccessed)
                cmp #1                       ; e33d: c9 01    (unaccessed)
                bne +                        ; e33f: d0 06    (unaccessed)
                stx ram149                   ; e341: 8e 0e 01 (unaccessed)
                stx ram154                   ; e344: 8e 1a 01 (unaccessed)
+               jsr MOV_0100_0120            ; e347: 20 bf ec (unaccessed)
                ldy #$3d                     ; e34a: a0 3d    (unaccessed)
                jsr SelectPRG23B             ; e34c: 20 37 f2 (unaccessed)
                lda #2                       ; e34f: a9 02    (unaccessed)
                jsr $a045                    ; e351: 20 45 a0 (unaccessed)
                lda #0                       ; e354: a9 00    (unaccessed)
                jsr sub3                     ; e356: 20 1f e5 (unaccessed)
                inc_abs ram59                ; e359: ee 7a 00 (unaccessed)
                lda #$12                     ; e35c: a9 12    (unaccessed)
                jsr sub10                    ; e35e: 20 7b e6 (unaccessed)
                jsr sub13                    ; e361: 20 49 e7 (unaccessed)
                jsr sub15                    ; e364: 20 53 e7 (unaccessed)
                jmp MAINLOOP                 ; e367: 4c 66 e0 (unaccessed)

MAINLOOP8       jsr RNDRAW                   ; e36a: 20 7a e8 (unaccessed)
                jmp MAINLOOP                 ; e36d: 4c 66 e0 (unaccessed)

sub1            ldy #$3d                     ; e370: a0 3d    (unaccessed)
                jsr SelectPRG23B             ; e372: 20 37 f2 (unaccessed)
                jsr $a01b                    ; e375: 20 1b a0 (unaccessed)
                jsr sub37                    ; e378: 20 06 f2 (unaccessed)
                rts                          ; e37b: 60       (unaccessed)

MAINLOOP9       jsr sub2                     ; e37c: 20 da e4 (unaccessed)
                lda #6                       ; e37f: a9 06    (unaccessed)
                sta_abs ram58                ; e381: 8d 78 00 (unaccessed)
                lda #$0b                     ; e384: a9 0b    (unaccessed)
                jsr sub1                     ; e386: 20 70 e3 (unaccessed)
                ldy #$35                     ; e389: a0 35    (unaccessed)
                jsr SelectPRG1B              ; e38b: 20 5f f2 (unaccessed)
                lda #$90                     ; e38e: a9 90    (unaccessed)
                sta_abs arr4                 ; e390: 8d 0a 00 (unaccessed)
                lda #$9a                     ; e393: a9 9a    (unaccessed)
                sta_abs ram8                 ; e395: 8d 0b 00 (unaccessed)
                lda #$20                     ; e398: a9 20    (unaccessed)
                sta_abs ram1                 ; e39a: 8d 01 00 (unaccessed)
                lda #0                       ; e39d: a9 00    (unaccessed)
                sta_abs arr1                 ; e39f: 8d 00 00 (unaccessed)
                sta_abs ram4                 ; e3a2: 8d 04 00 (unaccessed)
                sta_abs ram5                 ; e3a5: 8d 05 00 (unaccessed)
                sta_abs ram6                 ; e3a8: 8d 06 00 (unaccessed)
                lda #4                       ; e3ab: a9 04    (unaccessed)
                sta_abs arr2                 ; e3ad: 8d 07 00 (unaccessed)
                ldy #$37                     ; e3b0: a0 37    (unaccessed)
                jsr SelectPRG23B             ; e3b2: 20 37 f2 (unaccessed)
                jsr $a003                    ; e3b5: 20 03 a0 (unaccessed)
                ldy #$3d                     ; e3b8: a0 3d    (unaccessed)
                jsr SelectPRG23B             ; e3ba: 20 37 f2 (unaccessed)
                lda #$0b                     ; e3bd: a9 0b    (unaccessed)
                sta_abs arr1                 ; e3bf: 8d 00 00 (unaccessed)
                jsr $a015                    ; e3c2: 20 15 a0 (unaccessed)
                jsr sub22                    ; e3c5: 20 f7 ea (unaccessed)
                jsr MOV_0100_0120            ; e3c8: 20 bf ec (unaccessed)
                ldy #$3d                     ; e3cb: a0 3d    (unaccessed)
                jsr SelectPRG23B             ; e3cd: 20 37 f2 (unaccessed)
                lda #3                       ; e3d0: a9 03    (unaccessed)
                jsr $a045                    ; e3d2: 20 45 a0 (unaccessed)
                lda #$a0                     ; e3d5: a9 a0    (unaccessed)
                sta_abs ram81                ; e3d7: 8d 98 00 (unaccessed)
                lda #2                       ; e3da: a9 02    (unaccessed)
                jsr sub3                     ; e3dc: 20 1f e5 (unaccessed)
                inc_abs ram59                ; e3df: ee 7a 00 (unaccessed)
                jsr sub13                    ; e3e2: 20 49 e7 (unaccessed)
                jsr sub15                    ; e3e5: 20 53 e7 (unaccessed)
                jmp MAINLOOP                 ; e3e8: 4c 66 e0 (unaccessed)

MAINLOOPA       jmp MAINLOOP                 ; e3eb: 4c 66 e0 (unaccessed) // waiting for interrupt (NMI?) also MAINLOOPC, MAINLOOPE

MAINLOOPB       jsr sub2                     ; e3ee: 20 da e4 (unaccessed)
                lda #7                       ; e3f1: a9 07    (unaccessed)
                sta_abs ram58                ; e3f3: 8d 78 00 (unaccessed)
                lda #$0c                     ; e3f6: a9 0c    (unaccessed)
                jsr sub1                     ; e3f8: 20 70 e3 (unaccessed)
                ldy #$32                     ; e3fb: a0 32    (unaccessed)
                jsr SelectPRG1B              ; e3fd: 20 5f f2 (unaccessed)
                lda #$e3                     ; e400: a9 e3    (unaccessed)
                sta_abs arr4                 ; e402: 8d 0a 00 (unaccessed)
                lda #$9a                     ; e405: a9 9a    (unaccessed)
                sta_abs ram8                 ; e407: 8d 0b 00 (unaccessed)
                lda #$20                     ; e40a: a9 20    (unaccessed)
                sta_abs ram1                 ; e40c: 8d 01 00 (unaccessed)
                lda #0                       ; e40f: a9 00    (unaccessed)
                sta_abs arr1                 ; e411: 8d 00 00 (unaccessed)
                sta_abs ram4                 ; e414: 8d 04 00 (unaccessed)
                sta_abs ram5                 ; e417: 8d 05 00 (unaccessed)
                sta_abs ram6                 ; e41a: 8d 06 00 (unaccessed)
                lda #4                       ; e41d: a9 04    (unaccessed)
                sta_abs arr2                 ; e41f: 8d 07 00 (unaccessed)
                ldy #$37                     ; e422: a0 37    (unaccessed)
                jsr SelectPRG23B             ; e424: 20 37 f2 (unaccessed)
                jsr $a003                    ; e427: 20 03 a0 (unaccessed)
                ldy #$3d                     ; e42a: a0 3d    (unaccessed)
                jsr SelectPRG23B             ; e42c: 20 37 f2 (unaccessed)
                jsr $a018                    ; e42f: 20 18 a0 (unaccessed)
                ldy #$3d                     ; e432: a0 3d    (unaccessed)
                jsr SelectPRG23B             ; e434: 20 37 f2 (unaccessed)
                lda #$0c                     ; e437: a9 0c    (unaccessed)
                sta_abs arr1                 ; e439: 8d 00 00 (unaccessed)
                jsr $a015                    ; e43c: 20 15 a0 (unaccessed)
                jsr sub22                    ; e43f: 20 f7 ea (unaccessed)
                jsr MOV_0100_0120            ; e442: 20 bf ec (unaccessed)
                ldy #$3d                     ; e445: a0 3d    (unaccessed)
                jsr SelectPRG23B             ; e447: 20 37 f2 (unaccessed)
                lda #4                       ; e44a: a9 04    (unaccessed)
                jsr $a045                    ; e44c: 20 45 a0 (unaccessed)
                lda #$a0                     ; e44f: a9 a0    (unaccessed)
                sta_abs ram81                ; e451: 8d 98 00 (unaccessed)
                lda #2                       ; e454: a9 02    (unaccessed)
                jsr sub3                     ; e456: 20 1f e5 (unaccessed)
                inc_abs ram59                ; e459: ee 7a 00 (unaccessed)
                lda #8                       ; e45c: a9 08    (unaccessed)
                jsr subE683                  ; e45e: 20 83 e6 (unaccessed)
                jsr sub13                    ; e461: 20 49 e7 (unaccessed)
                jsr sub15                    ; e464: 20 53 e7 (unaccessed)
                jmp MAINLOOP                 ; e467: 4c 66 e0 (unaccessed)

MAINLOOPD       jsr sub2                     ; e46a: 20 da e4 (unaccessed)
                lda #8                       ; e46d: a9 08    (unaccessed)
                sta_abs ram58                ; e46f: 8d 78 00 (unaccessed)
                lda #$0d                     ; e472: a9 0d    (unaccessed)
                jsr sub1                     ; e474: 20 70 e3 (unaccessed)
                ldy #$36                     ; e477: a0 36    (unaccessed)
                jsr SelectPRG1B              ; e479: 20 5f f2 (unaccessed)
                lda #$92                     ; e47c: a9 92    (unaccessed)
                sta_abs arr4                 ; e47e: 8d 0a 00 (unaccessed)
                lda #$9b                     ; e481: a9 9b    (unaccessed)
                sta_abs ram8                 ; e483: 8d 0b 00 (unaccessed)
                lda #0                       ; e486: a9 00    (unaccessed)
                sta_abs arr1                 ; e488: 8d 00 00 (unaccessed)
                lda #$20                     ; e48b: a9 20    (unaccessed)
                sta_abs ram1                 ; e48d: 8d 01 00 (unaccessed)
                ldy #$37                     ; e490: a0 37    (unaccessed)
                jsr SelectPRG23B             ; e492: 20 37 f2 (unaccessed)
                jsr $a003                    ; e495: 20 03 a0 (unaccessed)
                ldy #$3d                     ; e498: a0 3d    (unaccessed)
                jsr SelectPRG23B             ; e49a: 20 37 f2 (unaccessed)
                lda #$0d                     ; e49d: a9 0d    (unaccessed)
                sta_abs arr1                 ; e49f: 8d 00 00 (unaccessed)
                jsr $a015                    ; e4a2: 20 15 a0 (unaccessed)
                jsr sub22                    ; e4a5: 20 f7 ea (unaccessed)
                ldy #$3d                     ; e4a8: a0 3d    (unaccessed)
                jsr SelectPRG23B             ; e4aa: 20 37 f2 (unaccessed)
                lda #5                       ; e4ad: a9 05    (unaccessed)
                jsr $a045                    ; e4af: 20 45 a0 (unaccessed)
                lda #$a0                     ; e4b2: a9 a0    (unaccessed)
                sta_abs ram81                ; e4b4: 8d 98 00 (unaccessed)
                lda #2                       ; e4b7: a9 02    (unaccessed)
                jsr sub3                     ; e4b9: 20 1f e5 (unaccessed)
                inc_abs ram59                ; e4bc: ee 7a 00 (unaccessed)
                ldy ram187                   ; e4bf: ac 41 05 (unaccessed)
                bne +                        ; e4c2: d0 08    (unaccessed)
                lda #$98                     ; e4c4: a9 98    (unaccessed)
                jsr subE673                  ; e4c6: 20 73 e6 (unaccessed)
                jmp cod7                     ; e4c9: 4c d1 e4 (unaccessed)
+               lda #$aa                     ; e4cc: a9 aa    (unaccessed)
                jsr sub10                    ; e4ce: 20 7b e6 (unaccessed)
cod7            jsr sub13                    ; e4d1: 20 49 e7 (unaccessed)
                jsr sub15                    ; e4d4: 20 53 e7 (unaccessed)
                jmp MAINLOOP                 ; e4d7: 4c 66 e0 (unaccessed)

sub2            jsr sub16                    ; e4da: 20 68 e7 (unaccessed)
                jsr sub14                    ; e4dd: 20 4d e7 (unaccessed)
                sta ppu_mask                 ; e4e0: 8d 01 20 (unaccessed)
                jsr subE57F                  ; e4e3: 20 7f e5 (unaccessed)
                jsr sub18                    ; e4e6: 20 df e7 (unaccessed)
                lda #0                       ; e4e9: a9 00    (unaccessed)
                sta_abs ram76                ; e4eb: 8d 90 00 (unaccessed)
                sta_abs ram77                ; e4ee: 8d 91 00 (unaccessed)
                sta_abs ram74                ; e4f1: 8d 8e 00 (unaccessed)
                sta_abs ram75                ; e4f4: 8d 8f 00 (unaccessed)
                sta_abs ram81                ; e4f7: 8d 98 00 (unaccessed)
                sta_abs ram82                ; e4fa: 8d 99 00 (unaccessed)
                sta_abs ram80                ; e4fd: 8d 96 00 (unaccessed)
                sta_abs arr25                ; e500: 8d 97 00 (unaccessed)
                lda #0                       ; e503: a9 00    (unaccessed)
                sta_abs ram62                ; e505: 8d 7e 00 (unaccessed)
                sta_abs ram41                ; e508: 8d 5e 00 (unaccessed)
                sta_abs ram42                ; e50b: 8d 5f 00 (unaccessed)
                sta_abs arr24                ; e50e: 8d 8d 00 (unaccessed)
                sta_abs ram88                ; e511: 8d a4 00 (unaccessed)
                lda #$ff                     ; e514: a9 ff    (unaccessed)
                sta ram163                   ; e516: 8d 00 03 (unaccessed)
                sta ram164                   ; e519: 8d 04 03 (unaccessed)
                jmp cod12                    ; e51c: 4c 23 e8 (unaccessed)

sub3            asl a                        ; e51f: 0a       (unaccessed)
                asl a                        ; e520: 0a       (unaccessed)
                asl a                        ; e521: 0a       (unaccessed)
                tay                          ; e522: a8       (unaccessed)
                lda dat8,y                   ; e523: b9 67 e5 (unaccessed)
                sta_abs ram136               ; e526: 8d e6 00 (unaccessed)
                sta_abs $c000                ; e529: 8d 00 c0 (unaccessed)
                iny                          ; e52c: c8       (unaccessed)
                lda dat8,y                   ; e52d: b9 67 e5 (unaccessed)
                sta_abs ram137               ; e530: 8d e7 00 (unaccessed)
                sta_abs $c800                ; e533: 8d 00 c8 (unaccessed)
                iny                          ; e536: c8       (unaccessed)
                lda dat8,y                   ; e537: b9 67 e5 (unaccessed)
                sta_abs ram138               ; e53a: 8d e8 00 (unaccessed)
                sta_abs $d000                ; e53d: 8d 00 d0 (unaccessed)
                iny                          ; e540: c8       (unaccessed)
                lda dat8,y                   ; e541: b9 67 e5 (unaccessed)
                sta_abs ram139               ; e544: 8d e9 00 (unaccessed)
                sta_abs $d800                ; e547: 8d 00 d8 (unaccessed)
                iny                          ; e54a: c8       (unaccessed)
                lda dat8,y                   ; e54b: b9 67 e5 (unaccessed)
                sta_abs ram140               ; e54e: 8d ea 00 (unaccessed)
                iny                          ; e551: c8       (unaccessed)
                lda dat8,y                   ; e552: b9 67 e5 (unaccessed)
                sta_abs ram141               ; e555: 8d eb 00 (unaccessed)
                iny                          ; e558: c8       (unaccessed)
                lda dat8,y                   ; e559: b9 67 e5 (unaccessed)
                sta_abs ram142               ; e55c: 8d ec 00 (unaccessed)
                iny                          ; e55f: c8       (unaccessed)
                lda dat8,y                   ; e560: b9 67 e5 (unaccessed)
                sta_abs ram143               ; e563: 8d ed 00 (unaccessed)
                rts                          ; e566: 60       (unaccessed)
dat8            hex E0 E1 E1 E1 E0 E1 E0 E1  ; e567
                hex E0 E0 E0 E0 E1 E1 E1 E1  ; e56f
                hex E0 E1 E0 E1 E0 E1 E0 E1  ; e577              

subE57F         lda #0                       ; e57f: a9 00    (unaccessed)
                jsr subE673                  ; e581: 20 73 e6 (unaccessed)
                jsr sub5                     ; e584: 20 90 e5 (unaccessed)
                lda #$4c                     ; e587: a9 4c    (unaccessed)
                sta_abs ram89                ; e589: 8d a5 00 (unaccessed)
                sta_abs $f800                ; e58c: 8d 00 f8 (unaccessed)
                rts                          ; e58f: 60       (unaccessed)
                
sub5            lda #0                       ; e590: a9 00    (unaccessed)
                sta snd_chn                  ; e592: 8d 15 40 (unaccessed)
                sta ram193                   ; e595: 8d f6 07 (unaccessed)
                lda #$10                     ; e598: a9 10    (unaccessed)
                sta sq1_vol                  ; e59a: 8d 00 40 (unaccessed)
                sta sq2_vol                  ; e59d: 8d 04 40 (unaccessed)
                sta noise_vol                ; e5a0: 8d 0c 40 (unaccessed)
                lda #8                       ; e5a3: a9 08    (unaccessed)
                sta sq1_sweep                ; e5a5: 8d 01 40 (unaccessed)
                sta sq2_sweep                ; e5a8: 8d 05 40 (unaccessed)
                lda #0                       ; e5ab: a9 00    (unaccessed)
                sta tri_linear               ; e5ad: 8d 08 40 (unaccessed)
                sta ram192                   ; e5b0: 8d f2 07 (unaccessed)
                tax                          ; e5b3: aa       (unaccessed)
-               lda #$ff                     ; e5b4: a9 ff    (unaccessed)
                sta arr39,x                  ; e5b6: 9d 00 07 (unaccessed)
                lda #0                       ; e5b9: a9 00    (unaccessed)
                sta arr43,x                  ; e5bb: 9d 06 07 (unaccessed)
                txa                          ; e5be: 8a       (unaccessed)
                clc                          ; e5bf: 18       (unaccessed)
                adc #$16                     ; e5c0: 69 16    (unaccessed)
                tax                          ; e5c2: aa       (unaccessed)
                cmp #$f2                     ; e5c3: c9 f2    (unaccessed)
                bne -                        ; e5c5: d0 ed    (unaccessed)
                lda #$c0                     ; e5c7: a9 c0    (unaccessed)
                sta $f800                    ; e5c9: 8d 00 f8 (unaccessed)
                ldx #$3f                     ; e5cc: a2 3f    (unaccessed)
                lda #0                       ; e5ce: a9 00    (unaccessed)
-               sta misc15                   ; e5d0: 8d 00 48 (unaccessed)
                dex                          ; e5d3: ca       (unaccessed)
                bpl -                        ; e5d4: 10 fa    (unaccessed)
                ldx #$80                     ; e5d6: a2 80    (unaccessed)
                stx $f800                    ; e5d8: 8e 00 f8 (unaccessed)
                ldx #0                       ; e5db: a2 00    (unaccessed)
-               lda dat10,x                  ; e5dd: bd a6 e6 (unaccessed)
                sta misc15                   ; e5e0: 8d 00 48 (unaccessed)
                inx                          ; e5e3: e8       (unaccessed)
                cpx #$20                     ; e5e4: e0 20    (unaccessed)
                bcc -                        ; e5e6: 90 f5    (unaccessed)
                ldx #$64                     ; e5e8: a2 64    (unaccessed)
                lda #$f0                     ; e5ea: a9 f0    (unaccessed)
                jsr sub7                     ; e5ec: 20 fa e5 (unaccessed)
                ldx #$7f                     ; e5ef: a2 7f    (unaccessed)
                lda #$30                     ; e5f1: a9 30    (unaccessed)
sub6            stx_abs $f800                ; e5f3: 8e 00 f8 (unaccessed)
                sta misc15                   ; e5f6: 8d 00 48 (unaccessed)
                rts                          ; e5f9: 60       (unaccessed)
sub7            pha                          ; e5fa: 48       (unaccessed)
-               pla                          ; e5fb: 68       (unaccessed)
                jsr sub6                     ; e5fc: 20 f3 e5 (unaccessed)
                pha                          ; e5ff: 48       (unaccessed)
                txa                          ; e600: 8a       (unaccessed)
                clc                          ; e601: 18       (unaccessed)
                adc #8                       ; e602: 69 08    (unaccessed)
                tax                          ; e604: aa       (unaccessed)
                bpl -                        ; e605: 10 f4    (unaccessed)
                pla                          ; e607: 68       (unaccessed)
                rts                          ; e608: 60       (unaccessed)

sub8            ldy #$22                     ; e609: a0 22    (unaccessed)
                jsr SelectPRG1B              ; e60b: 20 5f f2 (unaccessed)
                ldy #0                       ; e60e: a0 00    (unaccessed)
                sty_abs ram145               ; e610: 8c f1 00 (unaccessed)
                asl a                        ; e613: 0a       (unaccessed)
                rol_abs ram145               ; e614: 2e f1 00 (unaccessed)
                asl a                        ; e617: 0a       (unaccessed)
                rol_abs ram145               ; e618: 2e f1 00 (unaccessed)
                clc                          ; e61b: 18       (unaccessed)
                adc #0                       ; e61c: 69 00    (unaccessed)
                sta_abs ram144               ; e61e: 8d f0 00 (unaccessed)
                lda #$80                     ; e621: a9 80    (unaccessed)
                adc_abs ram145               ; e623: 6d f1 00 (unaccessed)
                sta_abs ram145               ; e626: 8d f1 00 (unaccessed)
                txa                          ; e629: 8a       (unaccessed)
                pha                          ; e62a: 48       (unaccessed)
                lda (ram144),y               ; e62b: b1 f0    (unaccessed)
                tax                          ; e62d: aa       (unaccessed)
                lda arr39,x                  ; e62e: bd 00 07 (unaccessed)
                cmp #$ff                     ; e631: c9 ff    (unaccessed)
                beq +                        ; e633: f0 14    (unaccessed)
                lda arr40,x                  ; e635: bd 01 07 (unaccessed)
                cmp #4                       ; e638: c9 04    (unaccessed)
                bcs +                        ; e63a: b0 0d    (unaccessed)
                tay                          ; e63c: a8       (unaccessed)
                lda dat9,y                   ; e63d: b9 67 e6 (unaccessed)
                and ram193                   ; e640: 2d f6 07 (unaccessed)
                sta ram193                   ; e643: 8d f6 07 (unaccessed)
                sta snd_chn                  ; e646: 8d 15 40 (unaccessed)
+               ldy #1                       ; e649: a0 01    (unaccessed)
                lda (ram144),y               ; e64b: b1 f0    (unaccessed)
                sta arr40,x                  ; e64d: 9d 01 07 (unaccessed)
                iny                          ; e650: c8       (unaccessed)
                lda (ram144),y               ; e651: b1 f0    (unaccessed)
                sta arr41,x                  ; e653: 9d 02 07 (unaccessed)
                iny                          ; e656: c8       (unaccessed)
                lda (ram144),y               ; e657: b1 f0    (unaccessed)
                clc                          ; e659: 18       (unaccessed)
                adc #$40                     ; e65a: 69 40    (unaccessed)
                sta arr42,x                  ; e65c: 9d 03 07 (unaccessed)
                lda #0                       ; e65f: a9 00    (unaccessed)
                sta arr39,x                  ; e661: 9d 00 07 (unaccessed)
                pla                          ; e664: 68       (unaccessed)
                tax                          ; e665: aa       (unaccessed)
                rts                          ; e666: 60       (unaccessed)
dat9            hex 0E 0D 0B 07 48 20 09 E6  ; e667
                hex 68 18 69 01              ; e66f 

subE673         pha                          ; e673: 48       (unaccessed)
                jsr sub8                     ; e674: 20 09 e6 (unaccessed)
                pla                          ; e677: 68       (unaccessed)
                clc                          ; e678: 18       (unaccessed)
                adc #1                       ; e679: 69 01    (unaccessed)
sub10           pha                          ; e67b: 48       (unaccessed)
                jsr sub8                     ; e67c: 20 09 e6 (unaccessed)
                pla                          ; e67f: 68       (unaccessed)
                clc                          ; e680: 18       (unaccessed)
                adc #1                       ; e681: 69 01    (unaccessed)
subE683         pha                          ; e683: 48       (unaccessed)
                jsr sub8                     ; e684: 20 09 e6 (unaccessed)
                pla                          ; e687: 68       (unaccessed)
                clc                          ; e688: 18       (unaccessed)
                adc #1                       ; e689: 69 01    (unaccessed)
subE68B         pha                          ; e68b: 48       (unaccessed)
                jsr sub8                     ; e68c: 20 09 e6 (unaccessed)
                pla                          ; e68f: 68       (unaccessed)
                clc                          ; e690: 18       (unaccessed)
                adc #1                       ; e691: 69 01    (unaccessed)
                pha                          ; e693: 48       (unaccessed)
                jsr sub8                     ; e694: 20 09 e6 (unaccessed)
                pla                          ; e697: 68       (unaccessed)
                clc                          ; e698: 18       (unaccessed)
                adc #1                       ; e699: 69 01    (unaccessed)
subE69B         pha                          ; e69b: 48       (unaccessed)
                jsr sub8                     ; e69c: 20 09 e6 (unaccessed)
                pla                          ; e69f: 68       (unaccessed)
                clc                          ; e6a0: 18       (unaccessed)
                adc #1                       ; e6a1: 69 01    (unaccessed)
                jmp sub8                     ; e6a3: 4c 09 e6 (unaccessed)

dat10           hex FF 00 00 00 00 00 00 00  ; e6a6
                hex FF FF 00 00 00 00 00 00  ; e6ae
                hex FF FF FF FF FF FF FF FF  ; e6b6
                hex FF 00 FF 00 FF 00 FF 00  ; e6be

PADINPUT        lda_abs ram65                ; e6c6: ad 83 00 (unaccessed)
                sta_abs ram66                ; e6c9: 8d 84 00 (unaccessed)
                lda_abs ram67                ; e6cc: ad 85 00 (unaccessed)
                sta_abs ram68                ; e6cf: 8d 86 00 (unaccessed)
                lda #1                       ; e6d2: a9 01    (unaccessed)
                sta joypad1                  ; e6d4: 8d 16 40 (unaccessed)
                lda #0                       ; e6d7: a9 00    (unaccessed)
                sta joypad1                  ; e6d9: 8d 16 40 (unaccessed)
                ldx #7                       ; e6dc: a2 07    (unaccessed)
-               lda joypad1                  ; e6de: ad 16 40 (unaccessed)
                and #%00000011               ; e6e1: 29 03    (unaccessed)
                cmp #1                       ; e6e3: c9 01    (unaccessed)
                ror_abs ram65                ; e6e5: 6e 83 00 (unaccessed) //pad1 -> $83 [r l d u start sel b a]
                lda joypad2                  ; e6e8: ad 17 40 (unaccessed)
                and #%00000011               ; e6eb: 29 03    (unaccessed)
                cmp #1                       ; e6ed: c9 01    (unaccessed)
                ror_abs ram67                ; e6ef: 6e 85 00 (unaccessed) //pad2 -> $85
                dex                          ; e6f2: ca       (unaccessed)
                bpl -                        ; e6f3: 10 e9    (unaccessed)
                lda_abs ram65                ; e6f5: ad 83 00 (unaccessed)
                eor_abs ram66                ; e6f8: 4d 84 00 (unaccessed) //pad1 change -> $84
                and_abs ram65                ; e6fb: 2d 83 00 (unaccessed)
                sta_abs ram63                ; e6fe: 8d 81 00 (unaccessed) //pad1 press -> $81
                lda_abs ram67                ; e701: ad 85 00 (unaccessed)
                eor_abs ram68                ; e704: 4d 86 00 (unaccessed) //pad2 change -> $86
                and_abs ram67                ; e707: 2d 85 00 (unaccessed)
                sta_abs ram64                ; e70a: 8d 82 00 (unaccessed) //pad2 press -> $82
                rts                          ; e70d: 60       (unaccessed)

cod8            lda_abs ram73                ; e70e: ad 8b 00 (unaccessed)
                and #%11111011               ; e711: 29 fb    (unaccessed)
                sta ppu_ctrl                 ; e713: 8d 00 20 (unaccessed)
                lda ppu_status               ; e716: ad 02 20 (unaccessed)
                ldy #0                       ; e719: a0 00    (unaccessed)
                sty_abs arr22                ; e71b: 8c 7d 00 (unaccessed)
                lda #$3f                     ; e71e: a9 3f    (unaccessed)
                sta ppu_addr                 ; e720: 8d 06 20 (unaccessed)
                sty ppu_addr                 ; e723: 8c 06 20 (unaccessed)
-               lda arr29,y                  ; e726: b9 00 01 (unaccessed)
                sta ppu_data                 ; e729: 8d 07 20 (unaccessed)
                lda arr30,y                  ; e72c: b9 01 01 (unaccessed)
                sta ppu_data                 ; e72f: 8d 07 20 (unaccessed)
                iny                          ; e732: c8       (unaccessed)
                iny                          ; e733: c8       (unaccessed)
                cpy #$20                     ; e734: c0 20    (unaccessed)
                bcc -                        ; e736: 90 ee    (unaccessed)
                lda #$3f                     ; e738: a9 3f    (unaccessed)
                sta ppu_addr                 ; e73a: 8d 06 20 (unaccessed)
                lda #0                       ; e73d: a9 00    (unaccessed)
                sta ppu_addr                 ; e73f: 8d 06 20 (unaccessed)
                sta ppu_addr                 ; e742: 8d 06 20 (unaccessed)
                sta ppu_addr                 ; e745: 8d 06 20 (unaccessed)
                rts                          ; e748: 60       (unaccessed)
sub13           lda #$1e                     ; e749: a9 1e    (unaccessed)
                bne cod9                     ; e74b: d0 02    (unaccessed)
sub14           lda #0                       ; e74d: a9 00    (unaccessed)
cod9            sta_abs arr23                ; e74f: 8d 8c 00 (unaccessed)
                rts                          ; e752: 60       (unaccessed)

sub15           lda ppu_status               ; e753: ad 02 20 (unaccessed)
                ldy #0                       ; e756: a0 00    (unaccessed)
                sty_abs ram60                ; e758: 8c 7b 00 (unaccessed)
                sty_abs ram62                ; e75b: 8c 7e 00 (unaccessed)
                lda_abs ram73                ; e75e: ad 8b 00 (unaccessed)
                ora #%10000000               ; e761: 09 80    (unaccessed)
                sta_abs ram73                ; e763: 8d 8b 00 (unaccessed)
                bne cod10                    ; e766: d0 08    (unaccessed)
sub16           lda_abs ram73                ; e768: ad 8b 00 (unaccessed)
                and #%01111111               ; e76b: 29 7f    (unaccessed)
                sta_abs ram73                ; e76d: 8d 8b 00 (unaccessed)
cod10           sta ppu_ctrl                 ; e770: 8d 00 20 (unaccessed)
                rts                          ; e773: 60       (unaccessed)

                lda #$e0                     ; e774: a9 e0    (unaccessed)
                sta_abs $c000                ; e776: 8d 00 c0 (unaccessed)
                lda #$e1                     ; e779: a9 e1    (unaccessed)
                sta_abs $c800                ; e77c: 8d 00 c8 (unaccessed)
                lda #$e0                     ; e77f: a9 e0    (unaccessed)
                sta_abs $d000                ; e782: 8d 00 d0 (unaccessed)
                lda #$e1                     ; e785: a9 e1    (unaccessed)
                sta_abs $d800                ; e788: 8d 00 d8 (unaccessed)
                lda ppu_status               ; e788: ad 02 20 (unaccessed)
                lda #1                       ; e78b: a9 01    (unaccessed)
                sta ram2                     ; e78d: 85 02    (unaccessed)
                lda #0                       ; e78f: a9 00    (unaccessed)
                sta ram3                     ; e791: 85 03    (unaccessed)
                lda #$20                     ; e793: a9 20    (unaccessed)
                jsr sub17                    ; e795: 20 b5 e7 (unaccessed)
cod11           lda ppu_status               ; e798: ad 02 20 (unaccessed)
                lda #1                       ; e79b: a9 01    (unaccessed)
                sta ram2                     ; e79d: 85 02    (unaccessed)
                lda #0                       ; e79f: a9 00    (unaccessed)
                sta ram3                     ; e7a1: 85 03    (unaccessed)
                lda #$24                     ; e7a3: a9 24    (unaccessed)
                jsr sub17                    ; e7a5: 20 b5 e7 (unaccessed)
                lda ppu_status               ; e7a8: ad 02 20 (unaccessed)
                lda #1                       ; e7ab: a9 01    (unaccessed)
                sta ram2                     ; e7ad: 85 02    (unaccessed)
                lda #0                       ; e7af: a9 00    (unaccessed)
                sta ram3                     ; e7b1: 85 03    (unaccessed)
                lda #$28                     ; e7b3: a9 28    (unaccessed)
sub17           sta ppu_addr                 ; e7b5: 8d 06 20 (unaccessed)
                lda #0                       ; e7b8: a9 00    (unaccessed)
                sta ppu_addr                 ; e7ba: 8d 06 20 (unaccessed)
                tay                          ; e7bd: a8       (unaccessed)
                lda #3                       ; e7be: a9 03    (unaccessed)
                sta ram1                     ; e7c0: 85 01    (unaccessed)
                lda ram2                     ; e7c2: a5 02    (unaccessed)
-               sta ppu_data                 ; e7c4: 8d 07 20 (unaccessed)
                dey                          ; e7c7: 88       (unaccessed)
                bne -                        ; e7c8: d0 fa    (unaccessed)
                dec ram1                     ; e7ca: c6 01    (unaccessed)
                bne -                        ; e7cc: d0 f6    (unaccessed)
-               sta ppu_data                 ; e7ce: 8d 07 20 (unaccessed)
                iny                          ; e7d1: c8       (unaccessed)
                cpy #$c0                     ; e7d2: c0 c0    (unaccessed)
                bcc -                        ; e7d4: 90 f8    (unaccessed)
                lda ram3                     ; e7d6: a5 03    (unaccessed)
-               sta ppu_data                 ; e7d8: 8d 07 20 (unaccessed)
                iny                          ; e7db: c8       (unaccessed)
                bne -                        ; e7dc: d0 fa    (unaccessed)
                rts                          ; e7de: 60       (unaccessed)

sub18           lda #$e0                     ; e7df: a9 e0    (unaccessed)
                sta_abs $c000                ; e7e1: 8d 00 c0 (unaccessed)
                lda #$e1                     ; e7e4: a9 e1    (unaccessed)
                sta_abs $c800                ; e7e6: 8d 00 c8 (unaccessed)
                lda #$e0                     ; e7e9: a9 e0    (unaccessed)
                sta_abs $d000                ; e7eb: 8d 00 d0 (unaccessed)
                lda #$e1                     ; e7ee: a9 e1    (unaccessed)
                sta_abs $d800                ; e7f1: 8d 00 d8 (unaccessed)
                lda ppu_status               ; e7f3: ad 02 20 (unaccessed)
                lda #1                       ; e7f6: a9 01    (unaccessed)
                sta ram2                     ; e7f8: 85 02    (unaccessed)
                lda #$aa                     ; e7fa: a9 aa    (unaccessed)
                sta ram3                     ; e7fc: 85 03    (unaccessed)
                lda #$20                     ; e7fe: a9 20    (unaccessed)
                jsr sub17                    ; e800: 20 b5 e7 (unaccessed)
                lda ppu_status               ; e803: ad 02 20 (unaccessed)
                lda #1                       ; e806: a9 01    (unaccessed)
                sta ram2                     ; e808: 85 02    (unaccessed)
                lda #$aa                     ; e80a: a9 aa    (unaccessed)
                sta ram3                     ; e80c: 85 03    (unaccessed)
                lda #$24                     ; e80e: a9 24    (unaccessed)
                jsr sub17                    ; e810: 20 b5 e7 (unaccessed)
                lda ppu_status               ; e813: ad 02 20 (unaccessed)
                lda #1                       ; e816: a9 01    (unaccessed)
                sta ram2                     ; e818: 85 02    (unaccessed)
                lda #$aa                     ; e81a: a9 aa    (unaccessed)
                sta ram3                     ; e81c: 85 03    (unaccessed)
                lda #$28                     ; e81e: a9 28    (unaccessed)
                jmp sub17                    ; e820: 4c b5 e7 (unaccessed)
                
cod12           ldy #4                       ; e823: a0 04    (unaccessed)
                ldy #0                       ; e825: a0 00    (unaccessed)
                lda #$f0                     ; e827: a9 f0    (unaccessed)
-               sta arr35,y                  ; e829: 99 00 02 (unaccessed)
                iny                          ; e82c: c8       (unaccessed)
                bne -                        ; e82d: d0 fa    (unaccessed)
                rts                          ; e82f: 60       (unaccessed)

sub19           ldx_abs ram61                ; e830: ae 7c 00 (unaccessed)
                cpx #$ff                     ; e833: e0 ff    (unaccessed)
                beq +                        ; e835: f0 0b    (unaccessed)
-               lda #$f0                     ; e837: a9 f0    (unaccessed)
                sta arr35,x                  ; e839: 9d 00 02 (unaccessed)
                inx                          ; e83c: e8       (unaccessed)
                inx                          ; e83d: e8       (unaccessed)
                inx                          ; e83e: e8       (unaccessed)
                inx                          ; e83f: e8       (unaccessed)
                bne -                        ; e840: d0 f5    (unaccessed)
+               rts                          ; e842: 60       (unaccessed)

RND100          jsr RNDRAW                   ; e843: 20 7a e8 (unaccessed) //RND100
                cmp #$64                     ; e846: c9 64    (unaccessed)
                bcs RND100                   ; e848: b0 f9    (unaccessed)
                rts                          ; e84a: 60       (unaccessed)

RND2            jsr RNDRAW                   ; e84b: 20 7a e8 (unaccessed)
                lsr a                        ; e84e: 4a       (unaccessed)
                rts                          ; e84f: 60       (unaccessed)

RND4            jsr RNDRAW                   ; e850: 20 7a e8 (unaccessed)
                and #%00000011               ; e853: 29 03    (unaccessed)
                rts                          ; e855: 60       (unaccessed)

RND8            jsr RNDRAW                   ; e856: 20 7a e8 (unaccessed)
                and #%00000111               ; e859: 29 07    (unaccessed)
                rts                          ; e85b: 60       (unaccessed)

RND16           jsr RNDRAW                   ; e85c: 20 7a e8 (unaccessed)
                and #%00001111               ; e85f: 29 0f    (unaccessed)
                rts                          ; e861: 60       (unaccessed)

RND_n           sta arr5                     ; e862: 85 10    (unaccessed)
                cmp #$0f                     ; e864: c9 0f    (unaccessed)
                bcs cod13                    ; e866: b0 0a    (unaccessed)
-               jsr RNDRAW                   ; e868: 20 7a e8 (unaccessed)
                and #%00001111               ; e86b: 29 0f    (unaccessed)
                cmp arr5                     ; e86d: c5 10    (unaccessed)
                bcs -                        ; e86f: b0 f7    (unaccessed)
                rts                          ; e871: 60       (unaccessed)
cod13           jsr RNDRAW                   ; e872: 20 7a e8 (unaccessed)
                cmp arr5                     ; e875: c5 10    (unaccessed)
                bcs cod13                    ; e877: b0 f9    (unaccessed)
                rts                          ; e879: 60       (unaccessed)

RNDRAW          stx_abs ram31                ; e87a: 8e 51 00 (unaccessed)
                ldx_abs ram30                ; e87d: ae 50 00 (unaccessed)
                lda RNDTABLE,x               ; e880: bd ba e8 (unaccessed)
                inc_abs ram30                ; e883: ee 50 00 (unaccessed)
                ldx_abs ram31                ; e886: ae 51 00 (unaccessed)
                rts                          ; e889: 60       (unaccessed)

RNDRAW2         stx_abs ram33                ; e88a: 8e 53 00 (unaccessed)
                ldx_abs ram32                ; e88d: ae 52 00 (unaccessed)
                lda RNDTABLE,x               ; e890: bd ba e8 (unaccessed)
                inc_abs ram32                ; e893: ee 52 00 (unaccessed)
                ldx_abs ram33                ; e896: ae 53 00 (unaccessed)
                rts                          ; e899: 60       (unaccessed)

RNDRAW3         stx_abs ram33                ; e89a: 8e 53 00 (unaccessed)
                ldx_abs arr17                ; e89d: ae 54 00 (unaccessed)
                lda RNDTABLE,x               ; e8a0: bd ba e8 (unaccessed)
                inc_abs arr17                ; e8a3: ee 54 00 (unaccessed)
                ldx_abs ram33                ; e8a6: ae 53 00 (unaccessed)
                rts                          ; e8a9: 60       (unaccessed)

RNDRAW4         stx_abs ram33                ; e8aa: 8e 53 00 (unaccessed)
                ldx_abs ram34                ; e8ad: ae 55 00 (unaccessed)
                lda RNDTABLE,x               ; e8b0: bd ba e8 (unaccessed)
                inc_abs ram34                ; e8b3: ee 55 00 (unaccessed)
                ldx_abs ram33                ; e8b6: ae 53 00 (unaccessed)
                rts                          ; e8b9: 60       (unaccessed)

RNDTABLE        hex 3E 4E 4F 83 0E C9 7F 5D  ; e8ba
                hex FC E6 BA 01 F8 00 F4 0A  ; e8c2
                hex E5 A9 8D D1 E8 DB DE 81  ; e8ca
                hex 95 72 08 9A C7 49 C8 23  ; e8d2
                hex 39 37 E0 91 C3 33 9B 5F  ; e8da
                hex BE 41 EE 74 E2 0B 47 7E  ; e8e2
                hex BF 60 BB 20 61 05 B2 94  ; e8ea
                hex B6 E4 3A 21 1E B4 8C CE  ; e8f2
                hex 7B FE 22 DC 18 C4 6D FB  ; e8fa
                hex CD 27 A0 09 6E 38 8A 04  ; e902
                hex 7C 56 97 5A A8 4D 78 B5  ; e90a
                hex 6C AA 03 1A 4A 0D 26 82  ; e912
                hex AD 02 A1 B9 A3 6B D8 0C  ; e91a
                hex 4C AE 19 45 5B 9C 16 07  ; e922
                hex 89 51 90 29 F5 62 F7 CB  ; e92a
                hex F1 53 FF 14 65 D0 87 35  ; e932
                hex 10 73 7A 9F EB D9 3C EF  ; e93a
                hex 9E D7 3D 6F D6 84 AB 11  ; e942
                hex CA D2 88 17 E1 A6 52 8E  ; e94a
                hex 5E 36 24 44 28 A4 55 A7  ; e952
                hex C2 FD 76 2E B7 D5 F6 64  ; e95a
                hex 15 31 99 93 C0 8F B3 FA  ; e962
                hex E9 E3 67 4B 85 32 C6 69  ; e96a
                hex 48 DF A2 EC 98 6A E7 D4  ; e972
                hex 1C F3 58 50 ED 2B 1D 86  ; e97a
                hex F0 71 BD 34 1B AF 30 2D  ; e982
                hex 68 CC 0F 57 EA 92 8B 3F  ; e98a
                hex 3B AC B8 C1 2F F2 46 75  ; e992
                hex 96 7D 2A 79 40 DA 9D 25  ; e99a
                hex 12 42 54 D3 1F 80 5C 59  ; e9a2
                hex 43 F9 B0 DD 63 A5 77 CF  ; e9aa
                hex 13 2C 66 BC 70 B1 C5 06  ; e9b2

HEXTODEC        lda #0                       ; e9ba: a9 00    (unaccessed)
                sta arr2                     ; e9bc: 85 07    (unaccessed)
                sta ram7                     ; e9be: 85 08    (unaccessed)
                sta arr3                     ; e9c0: 85 09    (unaccessed)
-               lda ram1                     ; e9c2: a5 01    (unaccessed)
                sec                          ; e9c4: 38       (unaccessed)
                sbc #$40                     ; e9c5: e9 40    (unaccessed)
                sta ram4                     ; e9c7: 85 04    (unaccessed)
                lda ram2                     ; e9c9: a5 02    (unaccessed)
                sbc #$42                     ; e9cb: e9 42    (unaccessed)
                sta ram5                     ; e9cd: 85 05    (unaccessed)
                lda ram3                     ; e9cf: a5 03    (unaccessed)
                sbc #$0f                     ; e9d1: e9 0f    (unaccessed)
                bcc cod15                    ; e9d3: 90 0d    (unaccessed)
                sta ram3                     ; e9d5: 85 03    (unaccessed)
                lda ram4                     ; e9d7: a5 04    (unaccessed)
                sta ram1                     ; e9d9: 85 01    (unaccessed)
                lda ram5                     ; e9db: a5 05    (unaccessed)
                sta ram2                     ; e9dd: 85 02    (unaccessed)
                jmp -                        ; e9df: 4c c2 e9 (unaccessed)
cod15           lda ram1                     ; e9e2: a5 01    (unaccessed)
                sec                          ; e9e4: 38       (unaccessed)
                sbc #$a0                     ; e9e5: e9 a0    (unaccessed)
                sta ram4                     ; e9e7: 85 04    (unaccessed)
                lda ram2                     ; e9e9: a5 02    (unaccessed)
                sbc #$86                     ; e9eb: e9 86    (unaccessed)
                sta ram5                     ; e9ed: 85 05    (unaccessed)
                lda ram3                     ; e9ef: a5 03    (unaccessed)
                sbc #1                       ; e9f1: e9 01    (unaccessed)
                bcc cod16                    ; e9f3: 90 12    (unaccessed)
                sta ram3                     ; e9f5: 85 03    (unaccessed)
                lda ram4                     ; e9f7: a5 04    (unaccessed)
                sta ram1                     ; e9f9: 85 01    (unaccessed)
                lda ram5                     ; e9fb: a5 05    (unaccessed)
                sta ram2                     ; e9fd: 85 02    (unaccessed)
                lda arr3                     ; e9ff: a5 09    (unaccessed)
                adc #$0f                     ; ea01: 69 0f    (unaccessed)
                sta arr3                     ; ea03: 85 09    (unaccessed)
                bne cod15                    ; ea05: d0 db    (unaccessed)
cod16           lda ram1                     ; ea07: a5 01    (unaccessed)
                sec                          ; ea09: 38       (unaccessed)
                sbc #$10                     ; ea0a: e9 10    (unaccessed)
                sta ram4                     ; ea0c: 85 04    (unaccessed)
                lda ram2                     ; ea0e: a5 02    (unaccessed)
                sbc #$27                     ; ea10: e9 27    (unaccessed)
                sta ram5                     ; ea12: 85 05    (unaccessed)
                lda ram3                     ; ea14: a5 03    (unaccessed)
                sbc #0                       ; ea16: e9 00    (unaccessed)
                bcc cod17                    ; ea18: 90 0e    (unaccessed)
                sta ram3                     ; ea1a: 85 03    (unaccessed)
                lda ram4                     ; ea1c: a5 04    (unaccessed)
                sta ram1                     ; ea1e: 85 01    (unaccessed)
                lda ram5                     ; ea20: a5 05    (unaccessed)
                sta ram2                     ; ea22: 85 02    (unaccessed)
                inc arr3                     ; ea24: e6 09    (unaccessed)
                bne cod16                    ; ea26: d0 df    (unaccessed)
cod17           lda ram1                     ; ea28: a5 01    (unaccessed)
                sec                          ; ea2a: 38       (unaccessed)
                sbc #$e8                     ; ea2b: e9 e8    (unaccessed)
                sta ram4                     ; ea2d: 85 04    (unaccessed)
                lda ram2                     ; ea2f: a5 02    (unaccessed)
                sbc #3                       ; ea31: e9 03    (unaccessed)
                bcc cod18                    ; ea33: 90 0e    (unaccessed)
                sta ram2                     ; ea35: 85 02    (unaccessed)
                lda ram4                     ; ea37: a5 04    (unaccessed)
                sta ram1                     ; ea39: 85 01    (unaccessed)
                lda ram7                     ; ea3b: a5 08    (unaccessed)
                adc #$0f                     ; ea3d: 69 0f    (unaccessed)
                sta ram7                     ; ea3f: 85 08    (unaccessed)
                bne cod17                    ; ea41: d0 e5    (unaccessed)
cod18           lda ram1                     ; ea43: a5 01    (unaccessed)
                sec                          ; ea45: 38       (unaccessed)
                sbc #$64                     ; ea46: e9 64    (unaccessed)
                sta ram4                     ; ea48: 85 04    (unaccessed)
                lda ram2                     ; ea4a: a5 02    (unaccessed)
                sbc #0                       ; ea4c: e9 00    (unaccessed)
                bcc cod19                    ; ea4e: 90 0a    (unaccessed)
                sta ram2                     ; ea50: 85 02    (unaccessed)
                lda ram4                     ; ea52: a5 04    (unaccessed)
                sta ram1                     ; ea54: 85 01    (unaccessed)
                inc ram7                     ; ea56: e6 08    (unaccessed)
                bne cod18                    ; ea58: d0 e9    (unaccessed)
cod19           lda ram1                     ; ea5a: a5 01    (unaccessed)
                sec                          ; ea5c: 38       (unaccessed)
                sbc #$0a                     ; ea5d: e9 0a    (unaccessed)
                sta ram4                     ; ea5f: 85 04    (unaccessed)
                lda ram2                     ; ea61: a5 02    (unaccessed)
                sbc #0                       ; ea63: e9 00    (unaccessed)
                bcc +                        ; ea65: 90 0e    (unaccessed)
                sta ram2                     ; ea67: 85 02    (unaccessed)
                lda ram4                     ; ea69: a5 04    (unaccessed)
                sta ram1                     ; ea6b: 85 01    (unaccessed)
                lda arr2                     ; ea6d: a5 07    (unaccessed)
                adc #$0f                     ; ea6f: 69 0f    (unaccessed)
                sta arr2                     ; ea71: 85 07    (unaccessed)
                bne cod19                    ; ea73: d0 e5    (unaccessed)
+               lda ram1                     ; ea75: a5 01    (unaccessed)
                ora arr2                     ; ea77: 05 07    (unaccessed)
                sta arr2                     ; ea79: 85 07    (unaccessed)
                rts                          ; ea7b: 60       (unaccessed)

DIVIDE          lda #0                       ; ea7c: a9 00    (unaccessed)
                sta ram5                     ; ea7e: 85 05    (unaccessed)
                sta ram6                     ; ea80: 85 06    (unaccessed)
                ldy #$0f                     ; ea82: a0 0f    (unaccessed)
-               asl ram1                     ; ea84: 06 01    (unaccessed)
                rol ram2                     ; ea86: 26 02    (unaccessed)
                rol ram5                     ; ea88: 26 05    (unaccessed)
                rol ram6                     ; ea8a: 26 06    (unaccessed)
                lda ram5                     ; ea8c: a5 05    (unaccessed)
                sec                          ; ea8e: 38       (unaccessed)
                sbc ram3                     ; ea8f: e5 03    (unaccessed)
                sta arr2                     ; ea91: 85 07    (unaccessed)
                lda ram6                     ; ea93: a5 06    (unaccessed)
                sbc ram4                     ; ea95: e5 04    (unaccessed)
                bcc +                        ; ea97: 90 08    (unaccessed)
                sta ram6                     ; ea99: 85 06    (unaccessed)
                lda arr2                     ; ea9b: a5 07    (unaccessed)
                sta ram5                     ; ea9d: 85 05    (unaccessed)
                inc ram1                     ; ea9f: e6 01    (unaccessed)
+               dey                          ; eaa1: 88       (unaccessed)
                bpl -                        ; eaa2: 10 e0    (unaccessed)
                rts                          ; eaa4: 60       (unaccessed)

DIVIDE_B        lda #0                       ; eaa5: a9 00    (unaccessed)
                sta ram5                     ; eaa7: 85 05    (unaccessed)
                sta ram6                     ; eaa9: 85 06    (unaccessed)
                sta arr2                     ; eaab: 85 07    (unaccessed)
                ldy #$17                     ; eaad: a0 17    (unaccessed)
-               asl arr1                     ; eaaf: 06 00    (unaccessed)
                rol ram1                     ; eab1: 26 01    (unaccessed)
                rol ram2                     ; eab3: 26 02    (unaccessed)
                rol ram5                     ; eab5: 26 05    (unaccessed)
                rol ram6                     ; eab7: 26 06    (unaccessed)
                rol arr2                     ; eab9: 26 07    (unaccessed)
                lda ram5                     ; eabb: a5 05    (unaccessed)
                sec                          ; eabd: 38       (unaccessed)
                sbc ram3                     ; eabe: e5 03    (unaccessed)
                sta ram7                     ; eac0: 85 08    (unaccessed)
                lda ram6                     ; eac2: a5 06    (unaccessed)
                sbc ram4                     ; eac4: e5 04    (unaccessed)
                sta arr3                     ; eac6: 85 09    (unaccessed)
                lda arr2                     ; eac8: a5 07    (unaccessed)
                sbc #0                       ; eaca: e9 00    (unaccessed)
                bcc +                        ; eacc: 90 0c    (unaccessed)
                sta arr2                     ; eace: 85 07    (unaccessed)
                lda ram7                     ; ead0: a5 08    (unaccessed)
                sta ram5                     ; ead2: 85 05    (unaccessed)
                lda arr3                     ; ead4: a5 09    (unaccessed)
                sta ram6                     ; ead6: 85 06    (unaccessed)
                inc arr1                     ; ead8: e6 00    (unaccessed)
+               dey                          ; eada: 88       (unaccessed)
                bpl -                        ; eadb: 10 d2    (unaccessed)
                rts                          ; eadd: 60       (unaccessed)

JMPTOINDIRECT   sty arr1                     ; eade: 84 00    (unaccessed)
                asl a                        ; eae0: 0a       (unaccessed)
                tay                          ; eae1: a8       (unaccessed)
                iny                          ; eae2: c8       (unaccessed)
                pla                          ; eae3: 68       (unaccessed)
                sta ram1                     ; eae4: 85 01    (unaccessed)
                pla                          ; eae6: 68       (unaccessed)
                sta ram2                     ; eae7: 85 02    (unaccessed)
                lda (ram1),y                 ; eae9: b1 01    (unaccessed)
                sta ram3                     ; eaeb: 85 03    (unaccessed)
                iny                          ; eaed: c8       (unaccessed)
                lda (ram1),y                 ; eaee: b1 01    (unaccessed)
                sta ram4                     ; eaf0: 85 04    (unaccessed)
                ldy arr1                     ; eaf2: a4 00    (unaccessed)
                jmp (ram3)                   ; eaf4: 6c 03 00 (unaccessed)
                
sub22           lda_abs ram74                ; eaf7: ad 8e 00 (unaccessed)
                sta ppu_scroll               ; eafa: 8d 05 20 (unaccessed)
                lda_abs ram76                ; eafd: ad 90 00 (unaccessed)
                sta ppu_scroll               ; eb00: 8d 05 20 (unaccessed)
                lda_abs ram73                ; eb03: ad 8b 00 (unaccessed)
                and #%11111110               ; eb06: 29 fe    (unaccessed)
                sta_abs ram73                ; eb08: 8d 8b 00 (unaccessed)
                lda_abs ram75                ; eb0b: ad 8f 00 (unaccessed)
                and #%00000001               ; eb0e: 29 01    (unaccessed)
                ora_abs ram73                ; eb10: 0d 8b 00 (unaccessed)
                sta_abs ram73                ; eb13: 8d 8b 00 (unaccessed)
                sta ppu_ctrl                 ; eb16: 8d 00 20 (unaccessed)
                rts                          ; eb19: 60       (unaccessed)

                lda #2                       ; eb1a: a9 02    (unaccessed)
                sta ppu_addr                 ; eb1c: 8d 06 20 (unaccessed)
                lda #$50                     ; eb1f: a9 50    (unaccessed)
                sta ppu_addr                 ; eb21: 8d 06 20 (unaccessed)
                lda #0                       ; eb24: a9 00    (unaccessed)
                sta ppu_scroll               ; eb26: 8d 05 20 (unaccessed)
                sta ppu_scroll               ; eb29: 8d 05 20 (unaccessed)
                rts                          ; eb2c: 60       (unaccessed)

MULTIPLE        lda #0                       ; eb2d: a9 00    (unaccessed)
                sta ram11                    ; eb2f: 85 0e    (unaccessed)
                sta ram12                    ; eb31: 85 0f    (unaccessed)
                lda arr4                     ; eb33: a5 0a    (unaccessed)
                pha                          ; eb35: 48       (unaccessed)
                and #%00001111               ; eb36: 29 0f    (unaccessed)
                sta ram10                    ; eb38: 85 0d    (unaccessed)
                pla                          ; eb3a: 68       (unaccessed)
                jsr AHIGH2LOW                ; eb3b: 20 b1 eb (unaccessed)
                sta ram3                     ; eb3e: 85 03    (unaccessed)
                lda #$0a                     ; eb40: a9 0a    (unaccessed)
                sta arr1                     ; eb42: 85 00    (unaccessed)
                lda #0                       ; eb44: a9 00    (unaccessed)
                sta ram1                     ; eb46: 85 01    (unaccessed)
                sta ram2                     ; eb48: 85 02    (unaccessed)
                jsr MULTI_3_1                ; eb4a: 20 e9 eb (unaccessed)
                jsr sub24                    ; eb4d: 20 b6 eb (unaccessed)
                lda ram8                     ; eb50: a5 0b    (unaccessed)
                pha                          ; eb52: 48       (unaccessed)
                and #%00001111               ; eb53: 29 0f    (unaccessed)
                sta ram3                     ; eb55: 85 03    (unaccessed)
                lda #$64                     ; eb57: a9 64    (unaccessed)
                sta arr1                     ; eb59: 85 00    (unaccessed)
                lda #0                       ; eb5b: a9 00    (unaccessed)
                sta ram1                     ; eb5d: 85 01    (unaccessed)
                sta ram2                     ; eb5f: 85 02    (unaccessed)
                jsr MULTI_3_1                ; eb61: 20 e9 eb (unaccessed)
                jsr sub24                    ; eb64: 20 b6 eb (unaccessed)
                pla                          ; eb67: 68       (unaccessed)
                jsr AHIGH2LOW                ; eb68: 20 b1 eb (unaccessed)
                sta ram3                     ; eb6b: 85 03    (unaccessed)
                lda #$e8                     ; eb6d: a9 e8    (unaccessed)
                sta arr1                     ; eb6f: 85 00    (unaccessed)
                lda #3                       ; eb71: a9 03    (unaccessed)
                sta ram1                     ; eb73: 85 01    (unaccessed)
                lda #0                       ; eb75: a9 00    (unaccessed)
                sta ram2                     ; eb77: 85 02    (unaccessed)
                jsr MULTI_3_1                ; eb79: 20 e9 eb (unaccessed)
                jsr sub24                    ; eb7c: 20 b6 eb (unaccessed)
                lda ram9                     ; eb7f: a5 0c    (unaccessed)
                pha                          ; eb81: 48       (unaccessed)
                and #%00001111               ; eb82: 29 0f    (unaccessed)
                sta ram3                     ; eb84: 85 03    (unaccessed)
                lda #$10                     ; eb86: a9 10    (unaccessed)
                sta arr1                     ; eb88: 85 00    (unaccessed)
                lda #$27                     ; eb8a: a9 27    (unaccessed)
                sta ram1                     ; eb8c: 85 01    (unaccessed)
                lda #0                       ; eb8e: a9 00    (unaccessed)
                sta ram2                     ; eb90: 85 02    (unaccessed)
                jsr MULTI_3_1                ; eb92: 20 e9 eb (unaccessed)
                jsr sub24                    ; eb95: 20 b6 eb (unaccessed)
                pla                          ; eb98: 68       (unaccessed)
                jsr AHIGH2LOW                ; eb99: 20 b1 eb (unaccessed)
                sta ram3                     ; eb9c: 85 03    (unaccessed)
                lda #$a0                     ; eb9e: a9 a0    (unaccessed)
                sta arr1                     ; eba0: 85 00    (unaccessed)
                lda #$86                     ; eba2: a9 86    (unaccessed)
                sta ram1                     ; eba4: 85 01    (unaccessed)
                lda #1                       ; eba6: a9 01    (unaccessed)
                sta ram2                     ; eba8: 85 02    (unaccessed)
                jsr MULTI_3_1                ; ebaa: 20 e9 eb (unaccessed)
                jsr sub24                    ; ebad: 20 b6 eb (unaccessed)
                rts                          ; ebb0: 60       (unaccessed)
AHIGH2LOW       lsr a                        ; ebb1: 4a       (unaccessed)
                lsr a                        ; ebb2: 4a       (unaccessed)
                lsr a                        ; ebb3: 4a       (unaccessed)
                lsr a                        ; ebb4: 4a       (unaccessed)
                rts                          ; ebb5: 60       (unaccessed)
sub24           lda ram6                     ; ebb6: a5 06    (unaccessed)
                clc                          ; ebb8: 18       (unaccessed)
                adc ram10                    ; ebb9: 65 0d    (unaccessed)
                sta ram10                    ; ebbb: 85 0d    (unaccessed)
                lda arr2                     ; ebbd: a5 07    (unaccessed)
                adc ram11                    ; ebbf: 65 0e    (unaccessed)
                sta ram11                    ; ebc1: 85 0e    (unaccessed)
                lda ram7                     ; ebc3: a5 08    (unaccessed)
                adc ram12                    ; ebc5: 65 0f    (unaccessed)
                sta ram12                    ; ebc7: 85 0f    (unaccessed)
                rts                          ; ebc9: 60       (unaccessed)

MULTI_PERCENT   lda #0                       ; ebca: a9 00    (unaccessed)
                sta ram2                     ; ebcc: 85 02    (unaccessed)
                jsr MULTI_3_1                ; ebce: 20 e9 eb (unaccessed)
                lda ram6                     ; ebd1: a5 06    (unaccessed)
                sta arr1                     ; ebd3: 85 00    (unaccessed)
                lda arr2                     ; ebd5: a5 07    (unaccessed)
                sta ram1                     ; ebd7: 85 01    (unaccessed)
                lda ram7                     ; ebd9: a5 08    (unaccessed)
                sta ram2                     ; ebdb: 85 02    (unaccessed)
                lda #$64                     ; ebdd: a9 64    (unaccessed)
                sta ram3                     ; ebdf: 85 03    (unaccessed)
                lda #0                       ; ebe1: a9 00    (unaccessed)
                sta ram4                     ; ebe3: 85 04    (unaccessed)
                jsr DIVIDE_B                 ; ebe5: 20 a5 ea (unaccessed)
                rts                          ; ebe8: 60       (unaccessed)
                
MULTI_3_1       ldy #7                       ; ebe9: a0 07    (unaccessed)
                lda #0                       ; ebeb: a9 00    (unaccessed)
                sta ram4                     ; ebed: 85 04    (unaccessed)
                sta ram5                     ; ebef: 85 05    (unaccessed)
                sta ram6                     ; ebf1: 85 06    (unaccessed)
                sta arr2                     ; ebf3: 85 07    (unaccessed)
                sta ram7                     ; ebf5: 85 08    (unaccessed)
                sta arr3                     ; ebf7: 85 09    (unaccessed)
-               lsr ram3                     ; ebf9: 46 03    (unaccessed)
                bcc +                        ; ebfb: 90 19    (unaccessed)
                lda arr1                     ; ebfd: a5 00    (unaccessed)
                clc                          ; ebff: 18       (unaccessed)
                adc ram6                     ; ec00: 65 06    (unaccessed)
                sta ram6                     ; ec02: 85 06    (unaccessed)
                lda ram1                     ; ec04: a5 01    (unaccessed)
                adc arr2                     ; ec06: 65 07    (unaccessed)
                sta arr2                     ; ec08: 85 07    (unaccessed)
                lda ram2                     ; ec0a: a5 02    (unaccessed)
                adc ram7                     ; ec0c: 65 08    (unaccessed)
                sta ram7                     ; ec0e: 85 08    (unaccessed)
                lda ram4                     ; ec10: a5 04    (unaccessed)
                adc arr3                     ; ec12: 65 09    (unaccessed)
                sta arr3                     ; ec14: 85 09    (unaccessed)
+               asl arr1                     ; ec16: 06 00    (unaccessed)
                rol ram1                     ; ec18: 26 01    (unaccessed)
                rol ram2                     ; ec1a: 26 02    (unaccessed)
                rol ram4                     ; ec1c: 26 04    (unaccessed)
                dey                          ; ec1e: 88       (unaccessed)
                bpl -                        ; ec1f: 10 d8    (unaccessed)
                rts                          ; ec21: 60       (unaccessed)

MULTI?          ldy #$0f                     ; ec22: a0 0f    (unaccessed)
                lda #0                       ; ec24: a9 00    (unaccessed)
                sta ram6                     ; ec26: 85 06    (unaccessed)
                sta arr2                     ; ec28: 85 07    (unaccessed)
                sta ram7                     ; ec2a: 85 08    (unaccessed)
                sta arr3                     ; ec2c: 85 09    (unaccessed)
                sta arr4                     ; ec2e: 85 0a    (unaccessed)
                sta ram8                     ; ec30: 85 0b    (unaccessed)
                sta ram9                     ; ec32: 85 0c    (unaccessed)
-               lsr ram4                     ; ec34: 46 04    (unaccessed)
                ror ram3                     ; ec36: 66 03    (unaccessed)
                bcc +                        ; ec38: 90 1f    (unaccessed)
                lda arr1                     ; ec3a: a5 00    (unaccessed)
                clc                          ; ec3c: 18       (unaccessed)
                adc ram6                     ; ec3d: 65 06    (unaccessed)
                sta ram6                     ; ec3f: 85 06    (unaccessed)
                lda ram1                     ; ec41: a5 01    (unaccessed)
                adc arr2                     ; ec43: 65 07    (unaccessed)
                sta arr2                     ; ec45: 85 07    (unaccessed)
                lda ram2                     ; ec47: a5 02    (unaccessed)
                adc ram7                     ; ec49: 65 08    (unaccessed)
                sta ram7                     ; ec4b: 85 08    (unaccessed)
                lda ram8                     ; ec4d: a5 0b    (unaccessed)
                adc arr3                     ; ec4f: 65 09    (unaccessed)
                sta arr3                     ; ec51: 85 09    (unaccessed)
                lda ram9                     ; ec53: a5 0c    (unaccessed)
                adc arr4                     ; ec55: 65 0a    (unaccessed)
                sta arr4                     ; ec57: 85 0a    (unaccessed)
+               asl arr1                     ; ec59: 06 00    (unaccessed)
                rol ram1                     ; ec5b: 26 01    (unaccessed)
                rol ram2                     ; ec5d: 26 02    (unaccessed)
                rol ram8                     ; ec5f: 26 0b    (unaccessed)
                rol ram9                     ; ec61: 26 0c    (unaccessed)
                dey                          ; ec63: 88       (unaccessed)
                bpl -                        ; ec64: 10 ce    (unaccessed)
                rts                          ; ec66: 60       (unaccessed)

sub26           lda_abs ram69                ; ec67: ad 87 00 (unaccessed)
                bmi cod23                    ; ec6a: 30 52    (unaccessed)
                dec_abs ram72                ; ec6c: ce 8a 00 (unaccessed)
                bpl cod23                    ; ec6f: 10 4d    (unaccessed)
                lda_abs ram71                ; ec71: ad 89 00 (unaccessed)
                sta_abs ram72                ; ec74: 8d 8a 00 (unaccessed)
                lda #1                       ; ec77: a9 01    (unaccessed)
                sta_abs arr22                ; ec79: 8d 7d 00 (unaccessed)
                lda_abs ram69                ; ec7c: ad 87 00 (unaccessed)
                beq +                        ; ec7f: f0 0d    (unaccessed)
                inc_abs ram70                ; ec81: ee 88 00 (unaccessed)
                lda_abs ram70                ; ec84: ad 88 00 (unaccessed)
                cmp #4                       ; ec87: c9 04    (unaccessed)
                bcc cod21                    ; ec89: 90 0d    (unaccessed)
                jmp cod20                    ; ec8b: 4c 93 ec (unaccessed)
+               dec_abs ram70                ; ec8e: ce 88 00 (unaccessed)
                bne cod21                    ; ec91: d0 05    (unaccessed)
cod20           lda #$ff                     ; ec93: a9 ff    (unaccessed)
                sta_abs ram69                ; ec95: 8d 87 00 (unaccessed)
cod21           lda #0                       ; ec98: a9 00    (unaccessed)
                sta arr1                     ; ec9a: 85 00    (unaccessed)
                lda #1                       ; ec9c: a9 01    (unaccessed)
                sta ram1                     ; ec9e: 85 01    (unaccessed)
                lda #$20                     ; eca0: a9 20    (unaccessed)
                sta ram2                     ; eca2: 85 02    (unaccessed)
                lda #1                       ; eca4: a9 01    (unaccessed)
                sta ram3                     ; eca6: 85 03    (unaccessed)
                ldy #$1f                     ; eca8: a0 1f    (unaccessed)
cod22           ldx_abs ram70                ; ecaa: ae 88 00 (unaccessed)
                lda (ram2),y                 ; ecad: b1 02    (unaccessed)
-               dex                          ; ecaf: ca       (unaccessed)
                bmi +                        ; ecb0: 30 07    (unaccessed)
                sec                          ; ecb2: 38       (unaccessed)
                sbc #$10                     ; ecb3: e9 10    (unaccessed)
                bpl -                        ; ecb5: 10 f8    (unaccessed)
                lda #$0f                     ; ecb7: a9 0f    (unaccessed)
+               sta (arr1),y                 ; ecb9: 91 00    (unaccessed)
                dey                          ; ecbb: 88       (unaccessed)
                bpl cod22                    ; ecbc: 10 ec    (unaccessed)
cod23           rts                          ; ecbe: 60       (unaccessed)

MOV_0100_0120   lda #0                       ; ecbf: a9 00    (unaccessed)
                sta_abs ram69                ; ecc1: 8d 87 00 (unaccessed)
                lda #4                       ; ecc4: a9 04    (unaccessed)
                sta_abs ram70                ; ecc6: 8d 88 00 (unaccessed)
                lda #4                       ; ecc9: a9 04    (unaccessed)
                sta_abs ram71                ; eccb: 8d 89 00 (unaccessed)
                lda #0                       ; ecce: a9 00    (unaccessed)
                sta arr1                     ; ecd0: 85 00    (unaccessed)
                lda #1                       ; ecd2: a9 01    (unaccessed)
                sta ram1                     ; ecd4: 85 01    (unaccessed)
                lda #$20                     ; ecd6: a9 20    (unaccessed)
                sta ram2                     ; ecd8: 85 02    (unaccessed)
                lda #1                       ; ecda: a9 01    (unaccessed)
                sta ram3                     ; ecdc: 85 03    (unaccessed)
                ldy #0                       ; ecde: a0 00    (unaccessed)
-               lda (arr1),y                 ; ece0: b1 00    (unaccessed)
                sta (ram2),y                 ; ece2: 91 02    (unaccessed)
                lda #$0f                     ; ece4: a9 0f    (unaccessed)
                sta (arr1),y                 ; ece6: 91 00    (unaccessed)
                iny                          ; ece8: c8       (unaccessed)
                cpy #$20                     ; ece9: c0 20    (unaccessed)
                bcc -                        ; eceb: 90 f3    (unaccessed)
                rts                          ; eced: 60       (unaccessed)

COPY_0100_0120  lda #1                       ; ecee: a9 01    (unaccessed)
                sta_abs ram69                ; ecf0: 8d 87 00 (unaccessed)
                lda #0                       ; ecf3: a9 00    (unaccessed)
                sta_abs ram70                ; ecf5: 8d 88 00 (unaccessed)
                lda #4                       ; ecf8: a9 04    (unaccessed)
                sta_abs ram71                ; ecfa: 8d 89 00 (unaccessed)
                lda #0                       ; ecfd: a9 00    (unaccessed)
                sta arr1                     ; ecff: 85 00    (unaccessed)
                lda #1                       ; ed01: a9 01    (unaccessed)
                sta ram1                     ; ed03: 85 01    (unaccessed)
                lda #$20                     ; ed05: a9 20    (unaccessed)
                sta ram2                     ; ed07: 85 02    (unaccessed)
                lda #1                       ; ed09: a9 01    (unaccessed)
                sta ram3                     ; ed0b: 85 03    (unaccessed)
                ldy #0                       ; ed0d: a0 00    (unaccessed)
-               lda (arr1),y                 ; ed0f: b1 00    (unaccessed)
                sta (ram2),y                 ; ed11: 91 02    (unaccessed)
                iny                          ; ed13: c8       (unaccessed)
                cpy #$20                     ; ed14: c0 20    (unaccessed)
                bcc -                        ; ed16: 90 f7    (unaccessed)
                rts                          ; ed18: 60       (unaccessed)

                lda #1                       ; ed19: a9 01    (unaccessed)
                jmp +                        ; ed1b: 4c 41 ed (unaccessed)
                lda #2                       ; ed1e: a9 02    (unaccessed)
                jmp +                        ; ed20: 4c 41 ed (unaccessed)
subED23         lda #3                       ; ed23: a9 03    (unaccessed)
                jmp +                        ; ed25: 4c 41 ed (unaccessed)
                lda #4                       ; ed28: a9 04    (unaccessed)
                jmp +                        ; ed2a: 4c 41 ed (unaccessed)
                lda #5                       ; ed2d: a9 05    (unaccessed)
                jmp +                        ; ed2f: 4c 41 ed (unaccessed)
                lda #6                       ; ed32: a9 06    (unaccessed)
                jmp +                        ; ed34: 4c 41 ed (unaccessed)
                lda #7                       ; ed37: a9 07    (unaccessed)
                jmp +                        ; ed39: 4c 41 ed (unaccessed)
                lda #8                       ; ed3c: a9 08    (unaccessed)
                jmp +                        ; ed3e: 4c 41 ed (unaccessed)
+               sta arr1                     ; ed41: 85 00    (unaccessed)
                lda_abs ram63                ; ed43: ad 81 00 (unaccessed)
                and #%10000000               ; ed46: 29 80    (unaccessed)
                beq +                        ; ed48: f0 03    (unaccessed)
                jsr sub28                    ; ed4a: 20 71 ed (unaccessed)
+               lda_abs ram63                ; ed4d: ad 81 00 (unaccessed)
                and #%01000000               ; ed50: 29 40    (unaccessed)
                beq +                        ; ed52: f0 03    (unaccessed)
                jsr sub29                    ; ed54: 20 8d ed (unaccessed)
+               lda_abs ram63                ; ed57: ad 81 00 (unaccessed)
                and #%00100000               ; ed5a: 29 20    (unaccessed)
                beq +                        ; ed5c: f0 03    (unaccessed)
                jsr sub30                    ; ed5e: 20 a9 ed (unaccessed)
+               lda_abs ram63                ; ed61: ad 81 00 (unaccessed)
                and #%00010000               ; ed64: 29 10    (unaccessed)
                beq +                        ; ed66: f0 03    (unaccessed)
                jsr sub31                    ; ed68: 20 be ed (unaccessed)
+               jsr sub32                    ; ed6b: 20 dd ed (unaccessed)
                sta ram13                    ; ed6e: 85 12    (unaccessed)
                rts                          ; ed70: 60       (unaccessed)

sub28           inc ram172                   ; ed71: ee 24 04 (unaccessed)
                jsr sub32                    ; ed74: 20 dd ed (unaccessed)
                bmi +                        ; ed77: 30 07    (unaccessed)
                lda ram172                   ; ed79: ad 24 04 (unaccessed)
                cmp arr1                     ; ed7c: c5 00    (unaccessed)
                bcc cod24                    ; ed7e: 90 0c    (unaccessed)
+               dec ram172                   ; ed80: ce 24 04 (unaccessed)
                lda ram13                    ; ed83: a5 12    (unaccessed)
                bne cod24                    ; ed85: d0 05    (unaccessed)
                lda #0                       ; ed87: a9 00    (unaccessed)
                sta ram172                   ; ed89: 8d 24 04 (unaccessed)
cod24           rts                          ; ed8c: 60       (unaccessed)

sub29           dec ram172                   ; ed8d: ce 24 04 (unaccessed)
                bpl +                        ; ed90: 10 16    (unaccessed)
                inc ram172                   ; ed92: ee 24 04 (unaccessed)
                lda ram13                    ; ed95: a5 12    (unaccessed)
                bne +                        ; ed97: d0 0f    (unaccessed)
                lda arr1                     ; ed99: a5 00    (unaccessed)
                sta ram172                   ; ed9b: 8d 24 04 (unaccessed)
-               dec ram172                   ; ed9e: ce 24 04 (unaccessed)
                jsr sub32                    ; eda1: 20 dd ed (unaccessed)
                cmp #$ff                     ; eda4: c9 ff    (unaccessed)
                beq -                        ; eda6: f0 f6    (unaccessed)
+               rts                          ; eda8: 60       (unaccessed)

sub30           inc ram173                   ; eda9: ee 25 04 (unaccessed)
                jsr sub32                    ; edac: 20 dd ed (unaccessed)
                bpl +                        ; edaf: 10 0c    (unaccessed)
                dec ram173                   ; edb1: ce 25 04 (unaccessed)
                lda ram13                    ; edb4: a5 12    (unaccessed)
                bne +                        ; edb6: d0 05    (unaccessed)
                lda #0                       ; edb8: a9 00    (unaccessed)
                sta ram173                   ; edba: 8d 25 04 (unaccessed)
+               rts                          ; edbd: 60       (unaccessed)

sub31           dec ram173                   ; edbe: ce 25 04 (unaccessed)
                bpl +                        ; edc1: 10 19    (unaccessed)
                inc ram173                   ; edc3: ee 25 04 (unaccessed)
                lda ram13                    ; edc6: a5 12    (unaccessed)
                bne +                        ; edc8: d0 12    (unaccessed)
                ldx #$ff                     ; edca: a2 ff    (unaccessed)
                ldy ram172                   ; edcc: ac 24 04 (unaccessed)
-               inx                          ; edcf: e8       (unaccessed)
                tya                          ; edd0: 98       (unaccessed)
                clc                          ; edd1: 18       (unaccessed)
                adc arr1                     ; edd2: 65 00    (unaccessed)
                tay                          ; edd4: a8       (unaccessed)
                lda (arr5),y                 ; edd5: b1 10    (unaccessed)
                bpl -                        ; edd7: 10 f6    (unaccessed)
                stx ram173                   ; edd9: 8e 25 04 (unaccessed)
+               rts                          ; eddc: 60       (unaccessed)

sub32           lda #0                       ; eddd: a9 00    (unaccessed)
                ldy ram173                   ; eddf: ac 25 04 (unaccessed)
-               cpy #0                       ; ede2: c0 00    (unaccessed)
                beq +                        ; ede4: f0 07    (unaccessed)
                clc                          ; ede6: 18       (unaccessed)
                adc arr1                     ; ede7: 65 00    (unaccessed)
                dey                          ; ede9: 88       (unaccessed)
                jmp -                        ; edea: 4c e2 ed (unaccessed)
+               clc                          ; eded: 18       (unaccessed)
                adc ram172                   ; edee: 6d 24 04 (unaccessed)
                tay                          ; edf1: a8       (unaccessed)
                lda (arr5),y                 ; edf2: b1 10    (unaccessed)
                rts                          ; edf4: 60       (unaccessed)

subEDF5         asl a                        ; edf5: 0a       (unaccessed)
                tay                          ; edf6: a8       (unaccessed)
                lda (arr5),y                 ; edf7: b1 10    (unaccessed)
                sta arr4                     ; edf9: 85 0a    (unaccessed)
                iny                          ; edfb: c8       (unaccessed)
                lda (arr5),y                 ; edfc: b1 10    (unaccessed)
                sta ram9                     ; edfe: 85 0c    (unaccessed)
                lda #0                       ; ee00: a9 00    (unaccessed)
                sta ram2                     ; ee02: 85 02    (unaccessed)
                jmp cod47                    ; ee04: 4c ad f1 (unaccessed)

SWITCHPRG23CALL lda_abs PRGSelect2B          ; ee07: ad e2 00 (unaccessed)
                sta_abs ram35                ; ee0a: 8d 58 00 (unaccessed)
                sty_abs ram40                ; ee0d: 8c 5d 00 (unaccessed)
                pla                          ; ee10: 68       (unaccessed)
                clc                          ; ee11: 18       (unaccessed)
                adc #1                       ; ee12: 69 01    (unaccessed)
                sta_abs ram36                ; ee14: 8d 59 00 (unaccessed)
                pla                          ; ee17: 68       (unaccessed)
                adc #0                       ; ee18: 69 00    (unaccessed)
                sta_abs ram37                ; ee1a: 8d 5a 00 (unaccessed)
                ldy #0                       ; ee1d: a0 00    (unaccessed)
                lda (ram36),y                ; ee1f: b1 59    (unaccessed)
                sta_abs ram38                ; ee21: 8d 5b 00 (unaccessed)
                iny                          ; ee24: c8       (unaccessed)
                lda (ram36),y                ; ee25: b1 59    (unaccessed)
                sta_abs ram39                ; ee27: 8d 5c 00 (unaccessed)
                ldy_abs ram40                ; ee2a: ac 5d 00 (unaccessed)
                jsr SelectPRG23B             ; ee2d: 20 37 f2 (unaccessed)
                inc_abs ram36                ; ee30: ee 59 00 (unaccessed)
                bne +                        ; ee33: d0 03    (unaccessed)
                inc_abs ram37                ; ee35: ee 5a 00 (unaccessed)
+               lda_abs ram37                ; ee38: ad 5a 00 (unaccessed)
                pha                          ; ee3b: 48       (unaccessed)
                lda_abs ram36                ; ee3c: ad 59 00 (unaccessed)
                pha                          ; ee3f: 48       (unaccessed)
                lda_abs ram35                ; ee40: ad 58 00 (unaccessed)
                pha                          ; ee43: 48       (unaccessed)
                lda #$ee                     ; ee44: a9 ee    (unaccessed)
                pha                          ; ee46: 48       (unaccessed)
                lda #$4c                     ; ee47: a9 4c    (unaccessed)
                pha                          ; ee49: 48       (unaccessed)
                jmp (ram38)                  ; ee4a: 6c 5b 00 (unaccessed)
                pla                          ; ee4d: 68       (unaccessed)
                tay                          ; ee4e: a8       (unaccessed)
                jsr SelectPRG23B             ; ee4f: 20 37 f2 (unaccessed)
                rts                          ; ee52: 60       (unaccessed)

sub33           lda_abs arr22                ; ee53: ad 7d 00 (unaccessed)
                bne cod26                    ; ee56: d0 1a    (unaccessed)
                lda_abs ram62                ; ee58: ad 7e 00 (unaccessed)
                bmi cod27                    ; ee5b: 30 18    (unaccessed)
                asl a                        ; ee5d: 0a       (unaccessed)
                bmi cod28                    ; ee5e: 30 27    (unaccessed)
cod25           asl a                        ; ee60: 0a       (unaccessed)
                bmi cod29                    ; ee61: 30 35    (unaccessed)
                asl a                        ; ee63: 0a       (unaccessed)
                bmi cod30                    ; ee64: 30 3d    (unaccessed)
                asl a                        ; ee66: 0a       (unaccessed)
                bmi cod31                    ; ee67: 30 45    (unaccessed)
                asl a                        ; ee69: 0a       (unaccessed)
                bmi cod32                    ; ee6a: 30 52    (unaccessed)
                asl a                        ; ee6c: 0a       (unaccessed)
                bmi cod33                    ; ee6d: 30 5f    (unaccessed)
                asl a                        ; ee6f: 0a       (unaccessed)
                bmi cod34                    ; ee70: 30 6c    (unaccessed)
cod26           jmp cod8                     ; ee72: 4c 0e e7 (unaccessed)
cod27           pha                          ; ee75: 48       (unaccessed)
                lda_abs ram62                ; ee76: ad 7e 00 (unaccessed)
                and #%01111111               ; ee79: 29 7f    (unaccessed)
                sta_abs ram62                ; ee7b: 8d 7e 00 (unaccessed)
                jsr sub34                    ; ee7e: 20 0b ef (unaccessed)
                pla                          ; ee81: 68       (unaccessed)
                rts                          ; ee82: 60       (unaccessed)
                asl a                        ; ee83: 0a       (unaccessed)
                jmp cod25                    ; ee84: 4c 60 ee (unaccessed)
cod28           pha                          ; ee87: 48       (unaccessed)
                lda_abs ram62                ; ee88: ad 7e 00 (unaccessed)
                and #%10111111               ; ee8b: 29 bf    (unaccessed)
                sta_abs ram62                ; ee8d: 8d 7e 00 (unaccessed)
                jsr sub35                    ; ee90: 20 71 ef (unaccessed)
                pla                          ; ee93: 68       (unaccessed)
                rts                          ; ee94: 60       (unaccessed)
                jmp cod25                    ; ee95: 4c 60 ee (unaccessed)
cod29           lda_abs ram62                ; ee98: ad 7e 00 (unaccessed)
                and #%11011111               ; ee9b: 29 df    (unaccessed)
                sta_abs ram62                ; ee9d: 8d 7e 00 (unaccessed)
                jmp cod36                    ; eea0: 4c c0 ef (unaccessed)
cod30           lda_abs ram62                ; eea3: ad 7e 00 (unaccessed)
                and #%11101111               ; eea6: 29 ef    (unaccessed)
                sta_abs ram62                ; eea8: 8d 7e 00 (unaccessed)
                jmp cod37                    ; eeab: 4c 28 f0 (unaccessed)
cod31           ldy #$3d                     ; eeae: a0 3d    (unaccessed)
                jsr SelectPRG23B             ; eeb0: 20 37 f2 (unaccessed)
                lda_abs ram62                ; eeb3: ad 7e 00 (unaccessed)
                and #%11110111               ; eeb6: 29 f7    (unaccessed)
                sta_abs ram62                ; eeb8: 8d 7e 00 (unaccessed)
                jmp $a00c                    ; eebb: 4c 0c a0 (unaccessed)
cod32           lda_abs ram62                ; eebe: ad 7e 00 (unaccessed)
                and #%11111011               ; eec1: 29 fb    (unaccessed)
                sta_abs ram62                ; eec3: 8d 7e 00 (unaccessed)
                ldy #$3d                     ; eec6: a0 3d    (unaccessed)
                jsr SelectPRG23B             ; eec8: 20 37 f2 (unaccessed)
                jmp $a006                    ; eecb: 4c 06 a0 (unaccessed)
cod33           lda_abs ram62                ; eece: ad 7e 00 (unaccessed)
                and #%11111101               ; eed1: 29 fd    (unaccessed)
                sta_abs ram62                ; eed3: 8d 7e 00 (unaccessed)
                ldy #$3d                     ; eed6: a0 3d    (unaccessed)
                jsr SelectPRG23B             ; eed8: 20 37 f2 (unaccessed)
                jmp $a012                    ; eedb: 4c 12 a0 (unaccessed)
cod34           ldy #$3d                     ; eede: a0 3d    (unaccessed)
                jsr SelectPRG23B             ; eee0: 20 37 f2 (unaccessed)
                jmp $a000                    ; eee3: 4c 00 a0 (unaccessed)
                lda_abs ram62                ; eee6: ad 7e 00 (unaccessed)
                bmi +                        ; eee9: 30 0a    (unaccessed)
                asl a                        ; eeeb: 0a       (unaccessed)
                bmi cod35                    ; eeec: 30 12    (unaccessed)
                asl a                        ; eeee: 0a       (unaccessed)
                bmi cod29                    ; eeef: 30 a7    (unaccessed)
                asl a                        ; eef1: 0a       (unaccessed)
                bmi cod30                    ; eef2: 30 af    (unaccessed)
                rts                          ; eef4: 60       (unaccessed)
+               lda_abs ram62                ; eef5: ad 7e 00 (unaccessed)
                and #%01111111               ; eef8: 29 7f    (unaccessed)
                sta_abs ram62                ; eefa: 8d 7e 00 (unaccessed)
                jmp sub34                    ; eefd: 4c 0b ef (unaccessed)
cod35           lda_abs ram62                ; ef00: ad 7e 00 (unaccessed)
                and #%10111111               ; ef03: 29 bf    (unaccessed)
                sta_abs ram62                ; ef05: 8d 7e 00 (unaccessed)
                jmp sub35                    ; ef08: 4c 71 ef (unaccessed)

sub34           lda ram156                   ; ef0b: ad 41 01 (unaccessed)
                sta_abs ram1                 ; ef0e: 8d 01 00 (unaccessed)
                lda ram155                   ; ef11: ad 40 01 (unaccessed)
                and #%00000011               ; ef14: 29 03    (unaccessed)
                asl_abs ram1                 ; ef16: 0e 01 00 (unaccessed)
                rol a                        ; ef19: 2a       (unaccessed)
                asl_abs ram1                 ; ef1a: 0e 01 00 (unaccessed)
                rol a                        ; ef1d: 2a       (unaccessed)
                asl_abs ram1                 ; ef1e: 0e 01 00 (unaccessed)
                rol a                        ; ef21: 2a       (unaccessed)
                sta_abs ram1                 ; ef22: 8d 01 00 (unaccessed)
                lda #$1e                     ; ef25: a9 1e    (unaccessed)
                sec                          ; ef27: 38       (unaccessed)
                sbc_abs ram1                 ; ef28: ed 01 00 (unaccessed)
                sta_abs arr1                 ; ef2b: 8d 00 00 (unaccessed)
                lda_abs ram73                ; ef2e: ad 8b 00 (unaccessed)
                ora #%00000100               ; ef31: 09 04    (unaccessed)
                sta ppu_ctrl                 ; ef33: 8d 00 20 (unaccessed)
                lda ppu_status               ; ef36: ad 02 20 (unaccessed)
                lda ram155                   ; ef39: ad 40 01 (unaccessed)
                sta ppu_addr                 ; ef3c: 8d 06 20 (unaccessed)
                lda ram156                   ; ef3f: ad 41 01 (unaccessed)
                sta ppu_addr                 ; ef42: 8d 06 20 (unaccessed)
                ldy #0                       ; ef45: a0 00    (unaccessed)
-               lda arr31,y                  ; ef47: b9 42 01 (unaccessed)
                sta ppu_data                 ; ef4a: 8d 07 20 (unaccessed)
                iny                          ; ef4d: c8       (unaccessed)
                cpy_abs arr1                 ; ef4e: cc 00 00 (unaccessed)
                bcc -                        ; ef51: 90 f4    (unaccessed)
                lda ram155                   ; ef53: ad 40 01 (unaccessed)
                and #%11111100               ; ef56: 29 fc    (unaccessed)
                sta ppu_addr                 ; ef58: 8d 06 20 (unaccessed)
                lda ram156                   ; ef5b: ad 41 01 (unaccessed)
                and #%00011111               ; ef5e: 29 1f    (unaccessed)
                sta ppu_addr                 ; ef60: 8d 06 20 (unaccessed)
-               cpy #$1e                     ; ef63: c0 1e    (unaccessed)
                bcs +                        ; ef65: b0 09    (unaccessed)
                lda arr31,y                  ; ef67: b9 42 01 (unaccessed)
                sta ppu_data                 ; ef6a: 8d 07 20 (unaccessed)
                iny                          ; ef6d: c8       (unaccessed)
                bne -                        ; ef6e: d0 f3    (unaccessed)
+               rts                          ; ef70: 60       (unaccessed)

sub35           lda_abs ram73                ; ef71: ad 8b 00 (unaccessed)
                and #%11111011               ; ef74: 29 fb    (unaccessed)
                sta ppu_ctrl                 ; ef76: 8d 00 20 (unaccessed)
                lda ppu_status               ; ef79: ad 02 20 (unaccessed)
                lda ram157                   ; ef7c: ad 64 01 (unaccessed)
                sta ppu_addr                 ; ef7f: 8d 06 20 (unaccessed)
                lda ram158                   ; ef82: ad 65 01 (unaccessed)
                sta ppu_addr                 ; ef85: 8d 06 20 (unaccessed)
                and #%00011111               ; ef88: 29 1f    (unaccessed)
                sta_abs arr1                 ; ef8a: 8d 00 00 (unaccessed)
                lda #$20                     ; ef8d: a9 20    (unaccessed)
                sec                          ; ef8f: 38       (unaccessed)
                sbc_abs arr1                 ; ef90: ed 00 00 (unaccessed)
                sta_abs arr1                 ; ef93: 8d 00 00 (unaccessed)
                ldy #0                       ; ef96: a0 00    (unaccessed)
-               lda arr32,y                  ; ef98: b9 66 01 (unaccessed)
                sta ppu_data                 ; ef9b: 8d 07 20 (unaccessed)
                iny                          ; ef9e: c8       (unaccessed)
                cpy_abs arr1                 ; ef9f: cc 00 00 (unaccessed)
                bcc -                        ; efa2: 90 f4    (unaccessed)
                lda ram157                   ; efa4: ad 64 01 (unaccessed)
                sta ppu_addr                 ; efa7: 8d 06 20 (unaccessed)
                lda ram158                   ; efaa: ad 65 01 (unaccessed)
                and #%11100000               ; efad: 29 e0    (unaccessed)
                sta ppu_addr                 ; efaf: 8d 06 20 (unaccessed)
-               cpy #$20                     ; efb2: c0 20    (unaccessed)
                bcs +                        ; efb4: b0 09    (unaccessed)
                lda arr32,y                  ; efb6: b9 66 01 (unaccessed)
                sta ppu_data                 ; efb9: 8d 07 20 (unaccessed)
                iny                          ; efbc: c8       (unaccessed)
                bne -                        ; efbd: d0 f3    (unaccessed)
+               rts                          ; efbf: 60       (unaccessed)

cod36           lda ram160                   ; efc0: ad 89 01 (unaccessed)
                sta_abs ram1                 ; efc3: 8d 01 00 (unaccessed)
                and #%00111000               ; efc6: 29 38    (unaccessed)
                lsr a                        ; efc8: 4a       (unaccessed)
                lsr a                        ; efc9: 4a       (unaccessed)
                lsr a                        ; efca: 4a       (unaccessed)
                sta_abs arr1                 ; efcb: 8d 00 00 (unaccessed)
                lda #8                       ; efce: a9 08    (unaccessed)
                sec                          ; efd0: 38       (unaccessed)
                sbc_abs arr1                 ; efd1: ed 00 00 (unaccessed)
                sta_abs arr1                 ; efd4: 8d 00 00 (unaccessed)
                ldy #0                       ; efd7: a0 00    (unaccessed)
                lda ppu_status               ; efd9: ad 02 20 (unaccessed)
-               lda ram159                   ; efdc: ad 88 01 (unaccessed)
                sta ppu_addr                 ; efdf: 8d 06 20 (unaccessed)
                lda_abs ram1                 ; efe2: ad 01 00 (unaccessed)
                sta ppu_addr                 ; efe5: 8d 06 20 (unaccessed)
                lda arr33,y                  ; efe8: b9 8a 01 (unaccessed)
                sta ppu_data                 ; efeb: 8d 07 20 (unaccessed)
                lda_abs ram1                 ; efee: ad 01 00 (unaccessed)
                clc                          ; eff1: 18       (unaccessed)
                adc #8                       ; eff2: 69 08    (unaccessed)
                sta_abs ram1                 ; eff4: 8d 01 00 (unaccessed)
                iny                          ; eff7: c8       (unaccessed)
                cpy_abs arr1                 ; eff8: cc 00 00 (unaccessed)
                bcc -                        ; effb: 90 df    (unaccessed)
                lda ram160                   ; effd: ad 89 01 (unaccessed)
                and #%11000111               ; f000: 29 c7    (unaccessed)
                sta_abs ram1                 ; f002: 8d 01 00 (unaccessed)
-               cpy #8                       ; f005: c0 08    (unaccessed)
                bcs +                        ; f007: b0 1e    (unaccessed)
                lda ram159                   ; f009: ad 88 01 (unaccessed)
                sta ppu_addr                 ; f00c: 8d 06 20 (unaccessed)
                lda_abs ram1                 ; f00f: ad 01 00 (unaccessed)
                sta ppu_addr                 ; f012: 8d 06 20 (unaccessed)
                lda arr33,y                  ; f015: b9 8a 01 (unaccessed)
                sta ppu_data                 ; f018: 8d 07 20 (unaccessed)
                lda_abs ram1                 ; f01b: ad 01 00 (unaccessed)
                clc                          ; f01e: 18       (unaccessed)
                adc #8                       ; f01f: 69 08    (unaccessed)
                sta_abs ram1                 ; f021: 8d 01 00 (unaccessed)
                iny                          ; f024: c8       (unaccessed)
                bne -                        ; f025: d0 de    (unaccessed)
+               rts                          ; f027: 60       (unaccessed)
cod37           lda_abs ram73                ; f028: ad 8b 00 (unaccessed)
                and #%11111011               ; f02b: 29 fb    (unaccessed)
                sta ppu_ctrl                 ; f02d: 8d 00 20 (unaccessed)
                lda ppu_status               ; f030: ad 02 20 (unaccessed)
                lda ram161                   ; f033: ad 9c 01 (unaccessed)
                sta ppu_addr                 ; f036: 8d 06 20 (unaccessed)
                lda ram162                   ; f039: ad 9d 01 (unaccessed)
                sta ppu_addr                 ; f03c: 8d 06 20 (unaccessed)
                and #%00000111               ; f03f: 29 07    (unaccessed)
                sta_abs arr1                 ; f041: 8d 00 00 (unaccessed)
                lda #8                       ; f044: a9 08    (unaccessed)
                sec                          ; f046: 38       (unaccessed)
                sbc_abs arr1                 ; f047: ed 00 00 (unaccessed)
                sta_abs arr1                 ; f04a: 8d 00 00 (unaccessed)
                ldy #0                       ; f04d: a0 00    (unaccessed)
-               lda arr34,y                  ; f04f: b9 9e 01 (unaccessed)
                sta ppu_data                 ; f052: 8d 07 20 (unaccessed)
                iny                          ; f055: c8       (unaccessed)
                cpy_abs arr1                 ; f056: cc 00 00 (unaccessed)
                bcc -                        ; f059: 90 f4    (unaccessed)
                lda ram161                   ; f05b: ad 9c 01 (unaccessed)
                sta ppu_addr                 ; f05e: 8d 06 20 (unaccessed)
                lda ram162                   ; f061: ad 9d 01 (unaccessed)
                and #%11111000               ; f064: 29 f8    (unaccessed)
                sta ppu_addr                 ; f066: 8d 06 20 (unaccessed)
-               cpy #8                       ; f069: c0 08    (unaccessed)
                bcs +                        ; f06b: b0 09    (unaccessed)
                lda arr34,y                  ; f06d: b9 9e 01 (unaccessed)
                sta ppu_data                 ; f070: 8d 07 20 (unaccessed)
                iny                          ; f073: c8       (unaccessed)
                bne -                        ; f074: d0 f3    (unaccessed)
+               rts                          ; f076: 60       (unaccessed)

sub36           lda_abs ram85                ; f077: ad 9c 00 (unaccessed)
                eor_abs ram86                ; f07a: 4d 9d 00 (unaccessed)
                pha                          ; f07d: 48       (unaccessed)
                and #%11000000               ; f07e: 29 c0    (unaccessed)
                beq +                        ; f080: f0 05    (unaccessed)
                ldy #$ff                     ; f082: a0 ff    (unaccessed)
                sty_abs ram79                ; f084: 8c 95 00 (unaccessed)
+               pla                          ; f087: 68       (unaccessed)
                and #%00110000               ; f088: 29 30    (unaccessed)
                beq +                        ; f08a: f0 05    (unaccessed)
                ldy #$ff                     ; f08c: a0 ff    (unaccessed)
                sty_abs ram78                ; f08e: 8c 94 00 (unaccessed)
+               rts                          ; f091: 60       (unaccessed)

PRGf092         lda #0                       ; f092: a9 00    (unaccessed) // 5 jmp 1 jsr from bank1415 and bank1213(once ?)
                sta_abs ram3                 ; f094: 8d 03 00 (unaccessed)
                lda #$f0                     ; f097: a9 f0    (unaccessed)
                sta_abs ram4                 ; f099: 8d 04 00 (unaccessed)
                bit_abs ram2                 ; f09c: 2c 02 00 (unaccessed)
                bpl cod38                    ; f09f: 10 12    (unaccessed)
                lda_abs arr4                 ; f0a1: ad 0a 00 (unaccessed)
                sec                          ; f0a4: 38       (unaccessed)
                sbc #8                       ; f0a5: e9 08    (unaccessed)
                cmp #$f0                     ; f0a7: c9 f0    (unaccessed)
                bcc +                        ; f0a9: 90 05    (unaccessed)
                sbc #$10                     ; f0ab: e9 10    (unaccessed)
                dec_abs ram8                 ; f0ad: ce 0b 00 (unaccessed)
+               sta_abs arr4                 ; f0b0: 8d 0a 00 (unaccessed)
cod38           bit_abs ram2                 ; f0b3: 2c 02 00 (unaccessed)
                bvc +                        ; f0b6: 50 0e    (unaccessed)
                lda_abs ram9                 ; f0b8: ad 0c 00 (unaccessed)
                sec                          ; f0bb: 38       (unaccessed)
                sbc #$10                     ; f0bc: e9 10    (unaccessed)
                sta_abs ram9                 ; f0be: 8d 0c 00 (unaccessed)
                bcs +                        ; f0c1: b0 03    (unaccessed)
                dec_abs ram10                ; f0c3: ce 0d 00 (unaccessed)
+               lda_abs arr4                 ; f0c6: ad 0a 00 (unaccessed)
                sec                          ; f0c9: 38       (unaccessed)
                sbc_abs ram76                ; f0ca: ed 90 00 (unaccessed)
                bcs +                        ; f0cd: b0 04    (unaccessed)
                sec                          ; f0cf: 38       (unaccessed)
                sbc #$10                     ; f0d0: e9 10    (unaccessed)
                clc                          ; f0d2: 18       (unaccessed)
+               sta_abs arr4                 ; f0d3: 8d 0a 00 (unaccessed)
                lda_abs ram8                 ; f0d6: ad 0b 00 (unaccessed)
                sbc_abs ram77                ; f0d9: ed 91 00 (unaccessed)
                sta_abs ram8                 ; f0dc: 8d 0b 00 (unaccessed)
                lda_abs ram9                 ; f0df: ad 0c 00 (unaccessed)
                sec                          ; f0e2: 38       (unaccessed)
                sbc_abs ram74                ; f0e3: ed 8e 00 (unaccessed)
                sta_abs ram9                 ; f0e6: 8d 0c 00 (unaccessed)
                lda_abs ram10                ; f0e9: ad 0d 00 (unaccessed)
                sbc_abs ram75                ; f0ec: ed 8f 00 (unaccessed)
                sta_abs ram10                ; f0ef: 8d 0d 00 (unaccessed)
                ldy #0                       ; f0f2: a0 00    (unaccessed)
                ldx_abs ram61                ; f0f4: ae 7c 00 (unaccessed)
cod39           cpx #$ff                     ; f0f7: e0 ff    (unaccessed)
                bne cod41                    ; f0f9: d0 04    (unaccessed)
cod40           stx_abs ram61                ; f0fb: 8e 7c 00 (unaccessed)
                rts                          ; f0fe: 60       (unaccessed)
cod41           lda_abs ram8                 ; f0ff: ad 0b 00 (unaccessed)
                sta_abs ram12                ; f102: 8d 0f 00 (unaccessed)
                lda (arr1),y                 ; f105: b1 00    (unaccessed)
                cmp #$80                     ; f107: c9 80    (unaccessed)
                beq cod40                    ; f109: f0 f0    (unaccessed)
                bit_abs ram2                 ; f10b: 2c 02 00 (unaccessed)
                bpl +                        ; f10e: 10 05    (unaccessed)
                lda #8                       ; f110: a9 08    (unaccessed)
                sec                          ; f112: 38       (unaccessed)
                sbc (arr1),y                 ; f113: f1 00    (unaccessed)
+               cmp #$80                     ; f115: c9 80    (unaccessed)
                bcs +                        ; f117: b0 0f    (unaccessed)
                adc_abs arr4                 ; f119: 6d 0a 00 (unaccessed)
                sta_abs ram11                ; f11c: 8d 0e 00 (unaccessed)
                lda_abs ram8                 ; f11f: ad 0b 00 (unaccessed)
                adc #0                       ; f122: 69 00    (unaccessed)
                beq cod42                    ; f124: f0 1a    (unaccessed)
                bne cod46                    ; f126: d0 7e    (unaccessed)
+               eor #%11111111               ; f128: 49 ff    (unaccessed)
                adc #0                       ; f12a: 69 00    (unaccessed)
                sta_abs ram11                ; f12c: 8d 0e 00 (unaccessed)
                lda_abs arr4                 ; f12f: ad 0a 00 (unaccessed)
                sec                          ; f132: 38       (unaccessed)
                sbc_abs ram11                ; f133: ed 0e 00 (unaccessed)
                sta_abs ram11                ; f136: 8d 0e 00 (unaccessed)
                lda_abs ram8                 ; f139: ad 0b 00 (unaccessed)
                sbc #0                       ; f13c: e9 00    (unaccessed)
                bne cod46                    ; f13e: d0 66    (unaccessed)
cod42           lda_abs ram11                ; f140: ad 0e 00 (unaccessed)
                sec                          ; f143: 38       (unaccessed)
                sbc #1                       ; f144: e9 01    (unaccessed)
                cmp_abs ram4                 ; f146: cd 04 00 (unaccessed)
                bcs cod46                    ; f149: b0 5b    (unaccessed)
                sta arr35,x                  ; f14b: 9d 00 02 (unaccessed)
                iny                          ; f14e: c8       (unaccessed)
                lda (arr1),y                 ; f14f: b1 00    (unaccessed)
                clc                          ; f151: 18       (unaccessed)
                adc_abs ram3                 ; f152: 6d 03 00 (unaccessed)
                sta arr36,x                  ; f155: 9d 01 02 (unaccessed)
                iny                          ; f158: c8       (unaccessed)
                lda (arr1),y                 ; f159: b1 00    (unaccessed)
                eor_abs ram2                 ; f15b: 4d 02 00 (unaccessed)
                sta arr37,x                  ; f15e: 9d 02 02 (unaccessed)
                iny                          ; f161: c8       (unaccessed)
                bit_abs ram2                 ; f162: 2c 02 00 (unaccessed)
                lda (arr1),y                 ; f165: b1 00    (unaccessed)
                bvc +                        ; f167: 50 05    (unaccessed)
                lda #8                       ; f169: a9 08    (unaccessed)
                sec                          ; f16b: 38       (unaccessed)
                sbc (arr1),y                 ; f16c: f1 00    (unaccessed)
+               bpl cod45                    ; f16e: 10 26    (unaccessed)
                eor #%11111111               ; f170: 49 ff    (unaccessed)
                sta_abs ram11                ; f172: 8d 0e 00 (unaccessed)
                lda_abs ram9                 ; f175: ad 0c 00 (unaccessed)
                sec                          ; f178: 38       (unaccessed)
                sbc_abs ram11                ; f179: ed 0e 00 (unaccessed)
                sta arr38,x                  ; f17c: 9d 03 02 (unaccessed)
                lda_abs ram10                ; f17f: ad 0d 00 (unaccessed)
                sbc #0                       ; f182: e9 00    (unaccessed)
                bne cod44                    ; f184: d0 0c    (unaccessed)
cod43           iny                          ; f186: c8       (unaccessed)
                inx                          ; f187: e8       (unaccessed)
                inx                          ; f188: e8       (unaccessed)
                inx                          ; f189: e8       (unaccessed)
                inx                          ; f18a: e8       (unaccessed)
                bne +                        ; f18b: d0 02    (unaccessed)
                ldx #$ff                     ; f18d: a2 ff    (unaccessed)
+               jmp cod39                    ; f18f: 4c f7 f0 (unaccessed)
cod44           iny                          ; f192: c8       (unaccessed)
                jmp cod39                    ; f193: 4c f7 f0 (unaccessed)
cod45           clc                          ; f196: 18       (unaccessed)
                adc_abs ram9                 ; f197: 6d 0c 00 (unaccessed)
                sta arr38,x                  ; f19a: 9d 03 02 (unaccessed)
                lda_abs ram10                ; f19d: ad 0d 00 (unaccessed)
                adc #0                       ; f1a0: 69 00    (unaccessed)
                beq cod43                    ; f1a2: f0 e2    (unaccessed)
                bne cod44                    ; f1a4: d0 ec    (unaccessed)
cod46           iny                          ; f1a6: c8       (unaccessed)
                iny                          ; f1a7: c8       (unaccessed)
                iny                          ; f1a8: c8       (unaccessed)
                iny                          ; f1a9: c8       (unaccessed)
                jmp cod39                    ; f1aa: 4c f7 f0 (unaccessed)

PRGf1ad         lda #0                       ; f1ad: a9 00    (unaccessed)
                sta_abs ram3                 ; f1af: 8d 03 00 (unaccessed)
                lda #0                       ; f1b2: a9 00    (unaccessed)
                sta_abs ram4                 ; f1b4: 8d 04 00 (unaccessed)
                ldy #0                       ; f1b7: a0 00    (unaccessed)
                ldx_abs ram61                ; f1b9: ae 7c 00 (unaccessed)
cod48           cpx #$ff                     ; f1bc: e0 ff    (unaccessed)
                bne cod50                    ; f1be: d0 04    (unaccessed)
cod49           stx_abs ram61                ; f1c0: 8e 7c 00 (unaccessed)
                rts                          ; f1c3: 60       (unaccessed)            
cod50           lda (arr1),y                 ; f1c4: b1 00    (unaccessed)
cod51           cmp #$80                     ; f1c6: c9 80    (unaccessed)
                beq cod49                    ; f1c8: f0 f6    (unaccessed)
cod52           clc                          ; f1ca: 18       (unaccessed)
                adc_abs arr4                 ; f1cb: 6d 0a 00 (unaccessed)
                cmp_abs ram4                 ; f1ce: cd 04 00 (unaccessed)
                bcs +                        ; f1d1: b0 07    (unaccessed)
                iny                          ; f1d3: c8       (unaccessed)
                iny                          ; f1d4: c8       (unaccessed)
                iny                          ; f1d5: c8       (unaccessed)
                iny                          ; f1d6: c8       (unaccessed)
                jmp cod50                    ; f1d7: 4c c4 f1 (unaccessed)
+               sta arr35,x                  ; f1da: 9d 00 02 (unaccessed)
                iny                          ; f1dd: c8       (unaccessed)
                lda (arr1),y                 ; f1de: b1 00    (unaccessed)
                clc                          ; f1e0: 18       (unaccessed)
                adc_abs ram3                 ; f1e1: 6d 03 00 (unaccessed)
                sta arr36,x                  ; f1e4: 9d 01 02 (unaccessed)
                iny                          ; f1e7: c8       (unaccessed)
                lda (arr1),y                 ; f1e8: b1 00    (unaccessed)
                eor_abs ram2                 ; f1ea: 4d 02 00 (unaccessed)
                sta arr37,x                  ; f1ed: 9d 02 02 (unaccessed)
                iny                          ; f1f0: c8       (unaccessed)
                lda (arr1),y                 ; f1f1: b1 00    (unaccessed)
                clc                          ; f1f3: 18       (unaccessed)
                adc_abs ram9                 ; f1f4: 6d 0c 00 (unaccessed)
                sta arr38,x                  ; f1f7: 9d 03 02 (unaccessed)
                iny                          ; f1fa: c8       (unaccessed)
                inx                          ; f1fb: e8       (unaccessed)
                inx                          ; f1fc: e8       (unaccessed)
                inx                          ; f1fd: e8       (unaccessed)
                inx                          ; f1fe: e8       (unaccessed)
                bne cod48                    ; f1ff: d0 bb    (unaccessed)
                ldx #$ff                     ; f201: a2 ff    (unaccessed)
                jmp cod49                    ; f203: 4c c0 f1 (unaccessed)

sub37           lda_abs ram93                ; f206: ad ae 00 (unaccessed)
                sta_abs $8000                ; f209: 8d 00 80 (unaccessed)
                lda_abs ram94                ; f20c: ad af 00 (unaccessed)
                sta_abs $8800                ; f20f: 8d 00 88 (unaccessed)
                lda_abs ram95                ; f212: ad b0 00 (unaccessed)
                sta_abs $9000                ; f215: 8d 00 90 (unaccessed)
                lda_abs $00b1                ; f218: ad b1 00 (unaccessed)
                sta_abs $9800                ; f21b: 8d 00 98 (unaccessed)
                lda_abs ram96                ; f21e: ad b2 00 (unaccessed)
                sta_abs $a000                ; f221: 8d 00 a0 (unaccessed)
                lda_abs $00b3                ; f224: ad b3 00 (unaccessed)
                sta_abs $a800                ; f227: 8d 00 a8 (unaccessed)
                lda_abs ram97                ; f22a: ad b4 00 (unaccessed)
                sta_abs $b000                ; f22d: 8d 00 b0 (unaccessed)
                lda_abs $00b5                ; f230: ad b5 00 (unaccessed)
                sta_abs $b800                ; f233: 8d 00 b8 (unaccessed)
                rts                          ; f236: 60       (unaccessed)

SelectPRG23B    sty_abs PRGSelect2B          ; f237: 8c e2 00 (unaccessed)
                iny                          ; f23a: c8       (unaccessed)
                sty_abs PRGSelect3B          ; f23b: 8c e3 00 (unaccessed)
                sta_abs $f000                ; f23e: 8c 00 f0 (unaccessed)
                dey                          ; f241: 88       (unaccessed)
                pha                          ; f242: 48       (unaccessed)
                tya                          ; f243: 98       (unaccessed)
                ora #%11000000               ; f244: 09 c0    (unaccessed)
                sta_abs $e800                ; f246: 8d 00 e8 (unaccessed)
                pla                          ; f249: 68       (unaccessed)
                rts                          ; f24a: 60       (unaccessed)

SelectPRG23A    sty_abs PRGSelect2A          ; f24b: 8c df 00 (unaccessed)
                iny                          ; f24e: c8       (unaccessed)
                sty_abs PRGSelect3A          ; f24f: 8c e0 00 (unaccessed)
                sty_abs $f000                ; f252: 8c 00 f0 (unaccessed)
                dey                          ; f255: 88       (unaccessed)
                pha                          ; f256: 48       (unaccessed)
                tya                          ; f257: 98       (unaccessed)
                ora #%11000000               ; f258: 09 c0    (unaccessed)
                sta_abs $e800                ; f25a: 8d 00 e8 (unaccessed)
                pla                          ; f25d: 68       (unaccessed)
                rts                          ; f25e: 60       (unaccessed)

SelectPRG1B     sty_abs PRGSelect1B          ; f25f: 8c e1 00 (unaccessed)
                sty_abs $e000                ; f262: 8c 00 e0 (unaccessed)
                rts                          ; f265: 60       (unaccessed)

SelectPRG1A     sty_abs PRGSelect1A          ; f266: 8c de 00 (unaccessed)
                sty_abs $e000                ; f269: 8c 00 e0 (unaccessed)
                rts                          ; f26c: 60       (unaccessed)

SetUI0          sta UIid                     ; f26d: 8d 11 03 (unaccessed)
                lda #0                       ; f270: a9 00    (unaccessed)
-               sta UIsubid                  ; f272: 8d 10 03 (unaccessed)
                lda #$ff                     ; f275: a9 ff    (unaccessed)
                sta UIidnext                 ; f277: 8d 12 03 (unaccessed)
                sta UIidFF                   ; f27a: 8d 13 03 (unaccessed)
                lda #0                       ; f27d: a9 00    (unaccessed)
                sta ram163                   ; f27f: 8d 00 03 (unaccessed)
                rts                          ; f282: 60       (unaccessed)                
SetUI2          sta UIid                     ; f283: 8d 11 03 (unaccessed)
                lda #2                       ; f286: a9 02    (unaccessed)
                jmp -                        ; f288: 4c 72 f2 (unaccessed)
SetUI4          sta UIid                     ; f28b: 8d 11 03 (unaccessed)
                lda #4                       ; f28e: a9 04    (unaccessed)
                jmp -                        ; f290: 4c 72 f2 (unaccessed)
SetUI5          sta UIid                     ; f293: 8d 11 03 (unaccessed)
                lda #5                       ; f296: a9 05    (unaccessed)
                jmp -                        ; f298: 4c 72 f2 (unaccessed)

ClearUI         sta UIsubid                  ; f29b: 8d 10 03 (unaccessed)
                lda #$ff                     ; f29e: a9 ff    (unaccessed)
                sta UIid                     ; f2a0: 8d 11 03 (unaccessed)
                sta UIidnext                 ; f2a3: 8d 12 03 (unaccessed)
                sta UIidFF                   ; f2a6: 8d 13 03 (unaccessed)
                lda #0                       ; f2a9: a9 00    (unaccessed)
                sta ram163                   ; f2ab: 8d 00 03 (unaccessed)
                rts                          ; f2ae: 60       (unaccessed)

GETCITY         ldy #0                       ; f2af: a0 00    (unaccessed)
                sty_abs ram1                 ; f2b1: 8c 01 00 (unaccessed)
                asl a                        ; f2b4: 0a       (unaccessed)
                rol_abs ram1                 ; f2b5: 2e 01 00 (unaccessed)
                asl a                        ; f2b8: 0a       (unaccessed)
                rol_abs ram1                 ; f2b9: 2e 01 00 (unaccessed)
                asl a                        ; f2bc: 0a       (unaccessed)
                rol_abs ram1                 ; f2bd: 2e 01 00 (unaccessed)
                asl a                        ; f2c0: 0a       (unaccessed)
                rol_abs ram1                 ; f2c1: 2e 01 00 (unaccessed)
                asl a                        ; f2c4: 0a       (unaccessed)
                rol_abs ram1                 ; f2c5: 2e 01 00 (unaccessed)
                clc                          ; f2c8: 18       (unaccessed)
                adc #0                       ; f2c9: 69 00    (unaccessed)
                sta_abs arr1                 ; f2cb: 8d 00 00 (unaccessed)
                lda_abs ram1                 ; f2ce: ad 01 00 (unaccessed)
                adc #$60                     ; f2d1: 69 60    (unaccessed)
                sta_abs ram1                 ; f2d3: 8d 01 00 (unaccessed)
                rts                          ; f2d6: 60       (unaccessed)

GETHERO         ldy #0                       ; f2d7: a0 00    (unaccessed)
                sty_abs ram1                 ; f2d9: 8c 01 00 (unaccessed)
                sta_abs arr1                 ; f2dc: 8d 00 00 (unaccessed)
                asl a                        ; f2df: 0a       (unaccessed)
                rol_abs ram1                 ; f2e0: 2e 01 00 (unaccessed)
                clc                          ; f2e3: 18       (unaccessed)
                adc_abs arr1                 ; f2e4: 6d 00 00 (unaccessed)
                pha                          ; f2e7: 48       (unaccessed)
                lda_abs ram1                 ; f2e8: ad 01 00 (unaccessed)
                adc #0                       ; f2eb: 69 00    (unaccessed)
                sta_abs ram1                 ; f2ed: 8d 01 00 (unaccessed)
                pla                          ; f2f0: 68       (unaccessed)
                asl a                        ; f2f1: 0a       (unaccessed)
                rol_abs ram1                 ; f2f2: 2e 01 00 (unaccessed)
                asl a                        ; f2f5: 0a       (unaccessed)
                rol_abs ram1                 ; f2f6: 2e 01 00 (unaccessed)
                clc                          ; f2f9: 18       (unaccessed)
                adc #$c0                     ; f2fa: 69 c0    (unaccessed)
                sta_abs arr1                 ; f2fc: 8d 00 00 (unaccessed)
                lda_abs ram1                 ; f2ff: ad 01 00 (unaccessed)
                adc #$63                     ; f302: 69 63    (unaccessed)
                sta_abs ram1                 ; f304: 8d 01 00 (unaccessed)
                rts                          ; f307: 60       (unaccessed)

GETHEROKATA     sta_abs ram2                 ; f308: 8d 02 00 (unaccessed) katakana addr in $00, leading space number in A
                ldy #$30                     ; f30b: a0 30    (unaccessed)
                jsr SelectPRG1B              ; f30d: 20 5f f2 (unaccessed)
                lda #0                       ; f310: a9 00    (unaccessed)
                sta_abs ram1                 ; f312: 8d 01 00 (unaccessed)
                lda_abs ram2                 ; f315: ad 02 00 (unaccessed)
                asl a                        ; f318: 0a       (unaccessed)
                rol_abs ram1                 ; f319: 2e 01 00 (unaccessed)
                asl a                        ; f31c: 0a       (unaccessed)
                rol_abs ram1                 ; f31d: 2e 01 00 (unaccessed)
                clc                          ; f320: 18       (unaccessed)
                adc_abs ram2                 ; f321: 6d 02 00 (unaccessed)
                sta_abs arr1                 ; f324: 8d 00 00 (unaccessed)
                lda_abs ram1                 ; f327: ad 01 00 (unaccessed)
                adc #0                       ; f32a: 69 00    (unaccessed)
                sta_abs ram1                 ; f32c: 8d 01 00 (unaccessed)
                asl_abs arr1                 ; f32f: 0e 00 00 (unaccessed)
                rol_abs ram1                 ; f332: 2e 01 00 (unaccessed)
                lda_abs arr1                 ; f335: ad 00 00 (unaccessed)
                clc                          ; f338: 18       (unaccessed)
                adc #$1a                     ; f339: 69 1a    (unaccessed)
                sta_abs arr1                 ; f33b: 8d 00 00 (unaccessed)
                lda_abs ram1                 ; f33e: ad 01 00 (unaccessed)
                adc #$90                     ; f341: 69 90    (unaccessed)
                sta_abs ram1                 ; f343: 8d 01 00 (unaccessed)
                ldy #0                       ; f346: a0 00    (unaccessed)
                ldx #0                       ; f348: a2 00    (unaccessed)
-               lda (arr1),y                 ; f34a: b1 00    (unaccessed)
                beq +                        ; f34c: f0 0d    (unaccessed)
                iny                          ; f34e: c8       (unaccessed)
                cmp #$39                     ; f34f: c9 39    (unaccessed)
                beq -                        ; f351: f0 f7    (unaccessed)
                cmp #$3a                     ; f353: c9 3a    (unaccessed)
                beq -                        ; f355: f0 f3    (unaccessed)
                inx                          ; f357: e8       (unaccessed)
                jmp -                        ; f358: 4c 4a f3 (unaccessed)
+               lda KataSpaceArr,x           ; f35b: bd 5f f3 (unaccessed)
                rts                          ; f35e: 60       (unaccessed)
KataSpaceArr    hex 03 03 03 02 02 01 01 00  ; f35f           (unaccessed) //leading spaces before name
                hex 00                       ; f367           (unaccessed)

GETKINGDOM      and #%00001111               ; f368: 29 0f    (unaccessed)
                asl a                        ; f36a: 0a       (unaccessed)
                tay                          ; f36b: a8       (unaccessed)
                lda KingdomBaseL,y           ; f36c: b9 79 f3 (unaccessed)
                sta_abs arr1                 ; f36f: 8d 00 00 (unaccessed)
                lda KingdomBaseH,y           ; f372: b9 7a f3 (unaccessed)
                sta_abs ram1                 ; f375: 8d 01 00 (unaccessed)
                rts                          ; f378: 60       (unaccessed)
KingdomBaseL    hex 07                       ; f379           (unaccessed)
KingdomBaseH    hex 6f 0f 6f 17 6f 1f 6f 27  ; f37a           (unaccessed)
                hex 6f 2f 6f 37 6f           ; f382           (unaccessed)

GETHEROINIT     ldy #$31                     ; f387: a0 31    (unaccessed)
                jsr SelectPRG1B              ; f389: 20 5f f2 (unaccessed)
                ldy #0                       ; f38c: a0 00    (unaccessed)
                sty_abs ram1                 ; f38e: 8c 01 00 (unaccessed)
                sta_abs arr1                 ; f391: 8d 00 00 (unaccessed)
                asl a                        ; f394: 0a       (unaccessed)
                rol_abs ram1                 ; f395: 2e 01 00 (unaccessed)
                clc                          ; f398: 18       (unaccessed)
                adc_abs arr1                 ; f399: 6d 00 00 (unaccessed)
                pha                          ; f39c: 48       (unaccessed)
                lda_abs ram1                 ; f39d: ad 01 00 (unaccessed)
                adc #0                       ; f3a0: 69 00    (unaccessed)
                sta_abs ram1                 ; f3a2: 8d 01 00 (unaccessed)
                pla                          ; f3a5: 68       (unaccessed)
                asl a                        ; f3a6: 0a       (unaccessed)
                rol_abs ram1                 ; f3a7: 2e 01 00 (unaccessed)
                asl a                        ; f3aa: 0a       (unaccessed)
                rol_abs ram1                 ; f3ab: 2e 01 00 (unaccessed)
                clc                          ; f3ae: 18       (unaccessed)
                adc #0                       ; f3af: 69 00    (unaccessed)
                sta_abs arr1                 ; f3b1: 8d 00 00 (unaccessed)
                lda_abs ram1                 ; f3b4: ad 01 00 (unaccessed)
                adc #$80                     ; f3b7: 69 80    (unaccessed)
                sta_abs ram1                 ; f3b9: 8d 01 00 (unaccessed)
                rts                          ; f3bc: 60       (unaccessed)

sub41           lda #0                       ; f3bd: a9 00    (unaccessed)
                sta misc18                   ; f3bf: 8d 00 50 (unaccessed)
                sta misc20                   ; f3c2: 8d 00 58 (unaccessed)
                lda #$e0                     ; f3c5: a9 e0    (unaccessed)
                sta_abs $c000                ; f3c7: 8d 00 c0 (unaccessed)
                sta_abs $d000                ; f3ca: 8d 00 d0 (unaccessed)
                lda #$e1                     ; f3cd: a9 e1    (unaccessed)
                sta_abs $c800                ; f3cf: 8d 00 c8 (unaccessed)
                sta_abs $d800                ; f3d2: 8d 00 d8 (unaccessed)
                ldx #0                       ; f3d5: a2 00    (unaccessed)
-               lda sub41,x                  ; f3d7: bd bd f3 (unaccessed)
                and #%00000001               ; f3da: 29 01    (unaccessed)
                sta_abs ram1                 ; f3dc: 8d 01 00 (unaccessed)
                sta joypad1                  ; f3df: 8d 16 40 (unaccessed)
                lda joypad2                  ; f3e2: ad 17 40 (unaccessed)
                lsr a                        ; f3e5: 4a       (unaccessed)
                eor #%11111111               ; f3e6: 49 ff    (unaccessed)
                and #%00000001               ; f3e8: 29 01    (unaccessed)
                cmp_abs ram1                 ; f3ea: cd 01 00 (unaccessed)
                bne cod54                    ; f3ed: d0 32    (unaccessed)
                inx                          ; f3ef: e8       (unaccessed)
                cpx #$46                     ; f3f0: e0 46    (unaccessed)
                bne -                        ; f3f2: d0 e3    (unaccessed)
                lda #$40                     ; f3f4: a9 40    (unaccessed)
                sta_abs $f800                ; f3f6: 8d 00 f8 (unaccessed)
                ldx #1                       ; f3f9: a2 01    (unaccessed)
                jsr sub42                    ; f3fb: 20 22 f4 (unaccessed)
                beq +                        ; f3fe: f0 0c    (unaccessed)
                ldx #$37                     ; f400: a2 37    (unaccessed)
                jsr sub43                    ; f402: 20 3f f4 (unaccessed)
                jsr sub42                    ; f405: 20 22 f4 (unaccessed)
                beq +                        ; f408: f0 02    (unaccessed)
                ldx #$16                     ; f40a: a2 16    (unaccessed)
+               lda #$3f                     ; f40c: a9 3f    (unaccessed)
                sta ppu_addr                 ; f40e: 8d 06 20 (unaccessed)
                ldy #0                       ; f411: a0 00    (unaccessed)
                sty ppu_addr                 ; f413: 8c 06 20 (unaccessed)
-               stx ppu_data                 ; f416: 8e 07 20 (unaccessed)
                iny                          ; f419: c8       (unaccessed)
                cpy #$20                     ; f41a: c0 20    (unaccessed)
                bne -                        ; f41c: d0 f8    (unaccessed)
-               jmp -                        ; f41e: 4c 1e f4 (unaccessed)
cod54           rts                          ; f421: 60       (unaccessed)

sub42           jsr sub44                    ; f422: 20 58 f4 (unaccessed)
-               lda (ram2),y                 ; f425: b1 02    (unaccessed)
                cmp_abs arr1                 ; f427: cd 00 00 (unaccessed)
                bne +                        ; f42a: d0 12    (unaccessed)
                jsr MULTI5                   ; f42c: 20 68 f4 (unaccessed)
                iny                          ; f42f: c8       (unaccessed)
                bne -                        ; f430: d0 f3    (unaccessed)
                inc_abs ram3                 ; f432: ee 03 00 (unaccessed)
                lda_abs ram3                 ; f435: ad 03 00 (unaccessed)
                cmp #$80                     ; f438: c9 80    (unaccessed)
                bne -                        ; f43a: d0 e9    (unaccessed)
                lda #0                       ; f43c: a9 00    (unaccessed)
+               rts                          ; f43e: 60       (unaccessed)

sub43           jsr sub44                    ; f43f: 20 58 f4 (unaccessed)
-               lda_abs arr1                 ; f442: ad 00 00 (unaccessed)
                sta (ram2),y                 ; f445: 91 02    (unaccessed)
                jsr MULTI5                   ; f447: 20 68 f4 (unaccessed)
                iny                          ; f44a: c8       (unaccessed)
                bne -                        ; f44b: d0 f5    (unaccessed)
                inc_abs ram3                 ; f44d: ee 03 00 (unaccessed)
                lda_abs ram3                 ; f450: ad 03 00 (unaccessed)
                cmp #$80                     ; f453: c9 80    (unaccessed)
                bne -                        ; f455: d0 eb    (unaccessed)
                rts                          ; f457: 60       (unaccessed)

sub44           ldy #0                       ; f458: a0 00    (unaccessed)
                sty_abs ram2                 ; f45a: 8c 02 00 (unaccessed)
                lda #$60                     ; f45d: a9 60    (unaccessed)
                sta_abs ram3                 ; f45f: 8d 03 00 (unaccessed)
                lda #$aa                     ; f462: a9 aa    (unaccessed)
                sta_abs arr1                 ; f464: 8d 00 00 (unaccessed)
                rts                          ; f467: 60       (unaccessed)

MULTI5          lda_abs arr1                 ; f468: ad 00 00 (unaccessed)
                asl a                        ; f46b: 0a       (unaccessed)
                asl a                        ; f46c: 0a       (unaccessed)
                sec                          ; f46d: 38       (unaccessed)
                adc_abs arr1                 ; f46e: 6d 00 00 (unaccessed)
                sta_abs arr1                 ; f471: 8d 00 00 (unaccessed)
                beq MULTI5                   ; f474: f0 f2    (unaccessed)
                rts                          ; f476: 60       (unaccessed)

                hex 00 00 00 00 01 01 01 01  ; f477
                hex 14                       ; f47f           (unaccessed)
                hex 15 24 25 07 08 17 18 07  ; f480
                hex 27 1A 25 26 08 24 1B 12  ; f488
                hex 15 17 37 14 13 36 18 07  ; f490
                hex 0A 1A 25 0A 08 24 1B 12  ; f498
                hex 15 17 0A 14 13 0A 18 26  ; f4a0
                hex 0A 0A 0A 0A 27 0A 0A 0A  ; f4a8
                hex 0A 0A 37 0A 0A 36 0A 26  ; f4b0
                hex 27 0A 0A 0A 0A 36 37 0A  ; f4b8
                hex 27 0A 37 26 0A 36 0A 26  ; f4c0
                hex 27 24 25 14 15 36 37 07  ; f4c8
                hex 27 17 37 26 08 36 18 0A  ; f4d0
                hex 0A 24 25 14 15 0A 0A 07  ; f4d8
                hex 0A 17 0A 0A 08 0A 18 22  ; f4e0
                hex 23 04 05 34 35 32 33 22  ; f4e8
                hex 06 32 16 09 23 19 33 0C  ; f4f0
                hex 0D 1C 1D 0E 0F 1E 1F 22  ; f4f8
                hex 40 32 50 41 42 51 52 43  ; f500
                hex 44 53 54 22 23 55 33 46  ;
                hex 42 56 54 22 23 55 33 2C  ;
                hex 2D 3C 3D 2E 2F 3E 3F 20  ;
                hex 21 30 31 22 23 45 33 2A  ;
                hex 2B 3A 3B 60 63 70 73 22  ;
                hex 23 48 49 58 59 32 33 22  ;
                hex 57 32 33 5A 23 32 33 22  ;
                hex 23 32 47 22 23 4A 33 22  ;
                hex 4B 32 5B 4C 23 5C 33 60  ;
                hex 61 5D 3B 62 63 3A 5E 4D  ;
                hex 2B 70 71 22 23 32 33 60  ;
                hex 4E 70 73 60 63 5D 5E 60  ;
                hex 61 70 71 62 63 72 73 4D  ;
                hex 4E 5D 5E 62 61 72 71 0A  ;
                hex 27 24 25 0A 08 36 18 26  ; 
                hex 08 0A 18 14 15 36 0A 14  ; f580
                hex 15 0A 37 07 27 17 0A 07  ;
                hex 0A 17 37 26 0A 24 25 4C  ;
                hex 4B 4F 5F 2A 4E 72 73 2A  ;
                hex 2B 72 71 62 61 3A 3B 22  ;
                hex 23 32 33 64 23 64 33 22  ;
                hex 74 32 74 65 65 32 33 22  ;
                hex 23 75 75 66 66 65 33 22  ;
                hex 75 66 66 66 23 66 64 22  ;
                hex 66 74 66 22 23 55 33 2C  ;
                hex 2D 67 3D 0B 35 19 33 22  ;
                hex 06 04 76 43 68 53 78 09  ;
                hex 23 77 05 6A 0D 7A 1D 6B  ;
                hex 2D 7B 3D 69 21 79 31 0A  ;
                hex 0A 0A 0A 4D 3B 5D 3B 22  ;
                hex 23 32 33 22 23 32 33 8C  ;
                hex 8D 86 87 88 89 8C 8D 8A  ; f600
                hex 8B 8E 8F 14 13 24 1B 3B  ;
                hex 4E 3B 5E 12 13 17 18 D2  ;
                hex 15 1A 25 17 18 1A 1B 6C  ;
                hex 01 01 01 01 01 7C 01 01  ;
                hex 6D 01 01 01 01 01 7D 6E  ;
                hex 23 7E 33 23 6F 33 7F 01  ;
                hex 6D 01 7D 6E 23 23 23 6E  ;
                hex 33 23 33 33 6F 33 33 01  ;
                hex 01 7C 7D 33 6F 33 33 6E  ;
                hex 6F 22 22 26 0A 0A 37 0A  ;
                hex 27 36 0A 22 23 32 33 22  ;
                hex 23 32 33 22 23 32 33 00  ; f660
                hex 00 00 00 00 00 00 00 00  ;
                hex 00 00 00 00 00 00 00 00  ;
                hex 00 00 00 00 00 00 00 FF  ;
                hex FF FF FF FF FF FF FF FF  ; f680
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;
                hex FF FF FF FF FF FF FF FF  ;

NMIFUNC         pha                          ; f800: 48       (unaccessed)
                txa                          ; f801: 8a       (unaccessed)
                pha                          ; f802: 48       (unaccessed)
                tya                          ; f803: 98       (unaccessed)
                pha                          ; f804: 48       (unaccessed)
                lda ppu_status               ; f805: ad 02 20 (unaccessed)
                lda #0                       ; f808: a9 00    (unaccessed)
                sta misc20                   ; f80a: 8d 00 58 (unaccessed)
                lda_abs ram49                ; f80d: ad 68 00 (unaccessed)
                sta misc18                   ; f810: 8d 00 50 (unaccessed)
                lda_abs ram50                ; f813: ad 69 00 (unaccessed)
                sta misc20                   ; f816: 8d 00 58 (unaccessed)
                sta_abs ram45                ; f819: 8d 62 00 (unaccessed)
                lda_abs ram44                ; f81c: ad 61 00 (unaccessed)
                sta_abs ram43                ; f81f: 8d 60 00 (unaccessed)
                cli                          ; f822: 58       (unaccessed)
                lda #$e0                     ; f823: a9 e0    (unaccessed)
                sta_abs $c000                ; f825: 8d 00 c0 (unaccessed)
                lda #$e1                     ; f828: a9 e1    (unaccessed)
                sta_abs $c800                ; f82a: 8d 00 c8 (unaccessed)
                lda #$e0                     ; f82d: a9 e0    (unaccessed)
                sta_abs $d000                ; f82f: 8d 00 d0 (unaccessed)
                lda #$e1                     ; f832: a9 e1    (unaccessed)
                sta_abs $d800                ; f834: 8d 00 d8 (unaccessed)
                lda ram60                    ; f837: a5 7b    (unaccessed)
                beq +                        ; f839: f0 03    (unaccessed)
                jmp cod61                    ; f83b: 4c d5 fa (unaccessed)
+               lda PRGSelect1B              ; f83e: a5 e1    (unaccessed)
                sta_abs $e000                ; f840: 8d 00 e0 (unaccessed)
                lda PRGSelect2B              ; f843: a5 e2    (unaccessed)
                ora #%11000000               ; f845: 09 c0    (unaccessed)
                sta_abs $e800                ; f847: 8d 00 e8 (unaccessed)
                lda PRGSelect3B              ; f84a: a5 e3    (unaccessed)
                sta_abs $f000                ; f84c: 8d 00 f0 (unaccessed)
                ldy #$00                     ; f84f: a0 00    (unaccessed)
                sty oam_addr                 ; f851: 8c 03 20 (unaccessed)
                iny                          ; f854: c8       (unaccessed)
                sty ram60                    ; f855: 84 7b    (unaccessed)
                lda #2                       ; f857: a9 02    (unaccessed)
                sta oam_dma                  ; f859: 8d 14 40 (unaccessed)
                lda_abs arr23                ; f85c: ad 8c 00 (unaccessed)
                sta ppu_mask                 ; f85f: 8d 01 20 (unaccessed)
                lda #0                       ; f862: a9 00    (unaccessed)
                sta ram61                    ; f864: 85 7c    (unaccessed)
                lda ram58                    ; f866: a5 78    (unaccessed)
                and #%00001111               ; f868: 29 0f    (unaccessed)
                asl a                        ; f86a: 0a       (unaccessed)
                tay                          ; f86b: a8       (unaccessed)
                lda dat16,y                  ; f86c: b9 7b f8 (unaccessed)
                sta_abs arr1                 ; f86f: 8d 00 00 (unaccessed)
                lda dat17,y                  ; f872: b9 7c f8 (unaccessed)
                sta_abs ram1                 ; f875: 8d 01 00 (unaccessed)
                jmp (arr1)                   ; f878: 6c 00 00 (unaccessed)
dat16           hex 97                       ; f87b           (unaccessed) //addresses to jmp for NMI
dat17           hex fa                       ; f87c           (unaccessed)
                hex 97 fa                    ; f87d           (unaccessed)
                hex B5 F8 FE F8 6A F9 A0 F9  ; f87f
                hex E4 F9 13 FA 53 FA        ; f887

cod59           dec_abs ram60                ; f88d: ce 7b 00 (unaccessed)
                lda PRGSelect1A              ; f890: a5 de    (unaccessed)
                sta_abs $e000                ; f892: 8d 00 e0 (unaccessed)
                lda PRGSelect2A              ; f895: a5 df    (unaccessed)
                ora #%11000000               ; f897: 09 c0    (unaccessed)
                sta_abs $e800                ; f899: 8d 00 e8 (unaccessed)
                lda PRGSelect3A              ; f89c: a5 e0    (unaccessed)
                sta_abs $f000                ; f89f: 8d 00 f0 (unaccessed)
                inc ram30                    ; f8a2: e6 50    (unaccessed)
                inc ram31                    ; f8a4: e6 52    (unaccessed)
                inc ram32                    ; f8a6: e6 54    (unaccessed)
                inc ram34                    ; f8a7: e6 55    (unaccessed)
                inc ram41                    ; f8a9: e6 5e    (unaccessed)
                bne cod60                    ; f8ab: d0 02    (unaccessed)
                inc ram42                    ; f8ad: e6 5f    (unaccessed)
cod60           pla                          ; f8af: 68       (unaccessed)
                tay                          ; f8b0: a8       (unaccessed)
                pla                          ; f8b1: 68       (unaccessed)
                tax                          ; f8b2: aa       (unaccessed)
                pla                          ; f8b3: 68       (unaccessed)
                rti                          ; f8b4: 40       (unaccessed)

                jsr sub33                    ; f8b5: 20 53 ee (unaccessed)
                jsr sub37                    ; f8b8: 20 06 f2 (unaccessed)
                jsr sub48                    ; f8bb: 20 0b fb (unaccessed)
                jsr sub26                    ; f8be: 20 67 ec (unaccessed)
                jsr PADINPUT                 ; f8c1: 20 c6 e6 (unaccessed)
                ldy #$2e                     ; f8c4: a0 2e    (unaccessed)
                jsr SelectPRG23B             ; f8c6: 20 37 f2 (unaccessed)
                jsr $a003                    ; f8c9: 20 03 a0 (unaccessed)
                lda #$4c                     ; f8cc: a9 4c    (unaccessed)
                sta ram89                    ; f8ce: 85 a5    (unaccessed)
                sta_abs $f800                ; f8d0: 8d 00 f8 (unaccessed)
                jsr sub51                    ; f8d3: 20 9b ff (unaccessed)
                jsr sub46                    ; f8d6: 20 a9 fa (unaccessed)
                ldy #$3d                     ; f8d9: a0 3d    (unaccessed)
                jsr SelectPRG23B             ; f8db: 20 37 f2 (unaccessed)
                jsr $a003                    ; f8de: 20 03 a0 (unaccessed)
                jsr $a009                    ; f8e1: 20 09 a0 (unaccessed)
                jsr $a00f                    ; f8e4: 20 0f a0 (unaccessed)
                jsr $a03f                    ; f8e7: 20 3f a0 (unaccessed)
                ldy #$3b                     ; f8ea: a0 3b    (unaccessed)
                jsr SelectPRG23B             ; f8ec: 20 37 f2 (unaccessed)
                jsr $a000                    ; f8ef: 20 00 a0 (unaccessed)
                jsr sub47                    ; f8f2: 20 bf fa (unaccessed)
                jsr sub19                    ; f8f5: 20 30 e8 (unaccessed)
                jsr sub49                    ; f8f8: 20 28 fb (unaccessed)
                jmp cod59                    ; f8fb: 4c 8d f8 (unaccessed)

                jsr sub33                    ; f8fe: 20 53 ee (unaccessed)
                jsr sub37                    ; f901: 20 06 f2 (unaccessed)
                jsr sub48                    ; f904: 20 0b fb (unaccessed)
                lda #0                       ; f907: a9 00    (unaccessed)
                sta ram61                    ; f909: 85 7c    (unaccessed)
                jsr sub26                    ; f90b: 20 67 ec (unaccessed)
                jsr PADINPUT                 ; f90e: 20 c6 e6 (unaccessed)
                ldy #$2e                     ; f911: a0 2e    (unaccessed)
                jsr SelectPRG23B             ; f913: 20 37 f2 (unaccessed)
                jsr $a003                    ; f916: 20 03 a0 (unaccessed)
                lda #$4c                     ; f919: a9 4c    (unaccessed)
                sta ram89                    ; f91b: 85 a5    (unaccessed)
                sta_abs $f800                ; f91d: 8d 00 f8 (unaccessed)
                jsr sub50                    ; f920: 20 62 ff (unaccessed)
                lda ram180                   ; f923: ad 00 05 (unaccessed)
                cmp #$0c                     ; f926: c9 0c    (unaccessed)
                bcs +                        ; f928: b0 13    (unaccessed)
                lda_abs ram75                ; f92a: ad 8f 00 (unaccessed)
                bne +                        ; f92d: d0 0e    (unaccessed)
                jsr sub36                    ; f92f: 20 77 f0 (unaccessed)
                ldy #$37                     ; f932: a0 37    (unaccessed)
                jsr SelectPRG23B             ; f934: 20 37 f2 (unaccessed)
                jsr $a00c                    ; f937: 20 0c a0 (unaccessed)
                jsr $a00f                    ; f93a: 20 0f a0 (unaccessed)
+               jsr sub46                    ; f93d: 20 a9 fa (unaccessed)
                ldy #$39                     ; f940: a0 39    (unaccessed)
                jsr SelectPRG23B             ; f942: 20 37 f2 (unaccessed)
                jsr $a00f                    ; f945: 20 0f a0 (unaccessed)
                ldy #$2c                     ; f948: a0 2c    (unaccessed)
                jsr SelectPRG23B             ; f94a: 20 37 f2 (unaccessed)
                jsr $a000                    ; f94d: 20 00 a0 (unaccessed)
                ldy #$3d                     ; f950: a0 3d    (unaccessed)
                jsr SelectPRG23B             ; f952: 20 37 f2 (unaccessed)
                jsr $a003                    ; f955: 20 03 a0 (unaccessed)
                jsr sub47                    ; f958: 20 bf fa (unaccessed)
                jsr sub19                    ; f95b: 20 30 e8 (unaccessed)
                lda_abs ram85                ; f95e: ad 9c 00 (unaccessed)
                sta_abs ram86                ; f961: 8d 9d 00 (unaccessed)
                jsr sub49                    ; f964: 20 28 fb (unaccessed)
                jmp cod59                    ; f967: 4c 8d f8 (unaccessed)

                jsr sub33                    ; f96a: 20 53 ee (unaccessed)
                jsr sub37                    ; f96d: 20 06 f2 (unaccessed)
                jsr sub48                    ; f970: 20 0b fb (unaccessed)
                lda #0                       ; f973: a9 00    (unaccessed)
                sta ram61                    ; f975: 85 7c    (unaccessed)
                jsr sub26                    ; f977: 20 67 ec (unaccessed)
                jsr PADINPUT                 ; f97a: 20 c6 e6 (unaccessed)
                ldy #$2e                     ; f97d: a0 2e    (unaccessed)
                jsr SelectPRG23B             ; f97f: 20 37 f2 (unaccessed)
                jsr $a003                    ; f982: 20 03 a0 (unaccessed)
                lda #$4c                     ; f985: a9 4c    (unaccessed)
                sta ram89                    ; f987: 85 a5    (unaccessed)
                sta_abs $f800                ; f989: 8d 00 f8 (unaccessed)
                jsr sub50                    ; f98c: 20 62 ff (unaccessed)
                ldy #$2e                     ; f98f: a0 2e    (unaccessed)
                jsr SelectPRG23B             ; f991: 20 37 f2 (unaccessed)
                jsr $a000                    ; f994: 20 00 a0 (unaccessed)
                jsr sub19                    ; f997: 20 30 e8 (unaccessed)
                jsr sub49                    ; f99a: 20 28 fb (unaccessed)
                jmp cod59                    ; f99d: 4c 8d f8 (unaccessed)

                jsr sub33                    ; f9a0: 20 53 ee (unaccessed)
                jsr sub37                    ; f9a3: 20 06 f2 (unaccessed)
                jsr sub48                    ; f9a6: 20 0b fb (unaccessed)
                lda #0                       ; f9a9: a9 00    (unaccessed)
                sta ram61                    ; f9ab: 85 7c    (unaccessed)
                jsr sub26                    ; f9ad: 20 67 ec (unaccessed)
                jsr PADINPUT                 ; f9b0: 20 c6 e6 (unaccessed)
                ldy #$2e                     ; f9b3: a0 2e    (unaccessed)
                jsr SelectPRG23B             ; f9b5: 20 37 f2 (unaccessed)
                jsr $a003                    ; f9b8: 20 03 a0 (unaccessed)
                lda #$4c                     ; f9bb: a9 4c    (unaccessed)
                sta ram89                    ; f9bd: 85 a5    (unaccessed)
                sta_abs $f800                ; f9bf: 8d 00 f8 (unaccessed)
                jsr sub50                    ; f9c2: 20 62 ff (unaccessed)
                jsr sub46                    ; f9c5: 20 a9 fa (unaccessed)
                ldy #$37                     ; f9c8: a0 37    (unaccessed)
                jsr SelectPRG23B             ; f9ca: 20 37 f2 (unaccessed)
                jsr $a01b                    ; f9cd: 20 1b a0 (unaccessed)
                ldy #$3d                     ; f9d0: a0 3d    (unaccessed)
                jsr SelectPRG23B             ; f9d2: 20 37 f2 (unaccessed)
                jsr $a003                    ; f9d5: 20 03 a0 (unaccessed)
                jsr sub47                    ; f9d8: 20 bf fa (unaccessed)
                jsr sub19                    ; f9db: 20 30 e8 (unaccessed)
                jsr sub49                    ; f9de: 20 28 fb (unaccessed)
                jmp cod59                    ; f9e1: 4c 8d f8 (unaccessed)

                jsr sub33                    ; f9e4: 20 53 ee (unaccessed)
                jsr sub37                    ; f9e7: 20 06 f2 (unaccessed)
                jsr sub48                    ; f9ea: 20 0b fb (unaccessed)
                jsr PADINPUT                 ; f9ed: 20 c6 e6 (unaccessed)
                ldy #$2e                     ; f9f0: a0 2e    (unaccessed)
                jsr SelectPRG23B             ; f9f2: 20 37 f2 (unaccessed)
                jsr $a003                    ; f9f5: 20 03 a0 (unaccessed)
                lda #$4c                     ; f9f8: a9 4c    (unaccessed)
                sta ram89                    ; f9fa: 85 a5    (unaccessed)
                sta_abs $f800                ; f9fc: 8d 00 f8 (unaccessed)
                ldy #$2a                     ; f9ff: a0 2a    (unaccessed)
                jsr SelectPRG23B             ; fa01: 20 37 f2 (unaccessed)
                jsr $a003                    ; fa04: 20 03 a0 (unaccessed)
                jsr sub50                    ; fa07: 20 62 ff (unaccessed)
                jsr sub19                    ; fa0a: 20 30 e8 (unaccessed)
                jsr sub49                    ; fa0d: 20 28 fb (unaccessed)
                jmp cod59                    ; fa10: 4c 8d f8 (unaccessed)

                jsr sub33                    ; fa13: 20 53 ee (unaccessed)
                jsr sub37                    ; fa16: 20 06 f2 (unaccessed)
                jsr sub48                    ; fa19: 20 0b fb (unaccessed)
                jsr sub26                    ; fa1c: 20 67 ec (unaccessed)
                jsr PADINPUT                 ; fa1f: 20 c6 e6 (unaccessed)
                ldy #$2e                     ; fa22: a0 2e    (unaccessed)
                jsr SelectPRG23B             ; fa24: 20 37 f2 (unaccessed)
                jsr $a003                    ; fa27: 20 03 a0 (unaccessed)
                jsr sub51                    ; fa2a: 20 9b ff (unaccessed)
                lda #$4c                     ; fa2d: a9 4c    (unaccessed)
                sta ram89                    ; fa2f: 85 a5    (unaccessed)
                sta_abs $f800                ; fa31: 8d 00 f8 (unaccessed)
                jsr sub46                    ; fa34: 20 a9 fa (unaccessed)
                ldy #$3d                     ; fa37: a0 3d    (unaccessed)
                jsr SelectPRG23B             ; fa39: 20 37 f2 (unaccessed)
                jsr $a003                    ; fa3c: 20 03 a0 (unaccessed)
                ldy #$28                     ; fa3f: a0 28    (unaccessed)
                jsr SelectPRG23B             ; fa41: 20 37 f2 (unaccessed)
                jsr $a024                    ; fa44: 20 24 a0 (unaccessed)
                jsr sub47                    ; fa47: 20 bf fa (unaccessed)
                jsr sub19                    ; fa4a: 20 30 e8 (unaccessed)
                jsr sub49                    ; fa4d: 20 28 fb (unaccessed)
                jmp cod59                    ; fa50: 4c 8d f8 (unaccessed)

                jsr sub33                    ; fa53: 20 53 ee (unaccessed)
                jsr sub37                    ; fa56: 20 06 f2 (unaccessed)
                jsr sub48                    ; fa59: 20 0b fb (unaccessed)
                jsr sub26                    ; fa5c: 20 67 ec (unaccessed)
                ldy #$2e                     ; fa5f: a0 2e    (unaccessed)
                jsr SelectPRG23B             ; fa61: 20 37 f2 (unaccessed)
                jsr $a003                    ; fa64: 20 03 a0 (unaccessed)
                lda #0                       ; fa67: a9 00    (unaccessed)
                sta ram63                    ; fa69: 85 81    (unaccessed)
                ldy #$3d                     ; fa6b: a0 3d    (unaccessed)
                jsr SelectPRG23B             ; fa6d: 20 37 f2 (unaccessed)
                jsr $a003                    ; fa70: 20 03 a0 (unaccessed)
                lda #$4c                     ; fa73: a9 4c    (unaccessed)
                sta ram89                    ; fa75: 85 a5    (unaccessed)
                sta_abs $f800                ; fa77: 8d 00 f8 (unaccessed)
                jsr PADINPUT                 ; fa7a: 20 c6 e6 (unaccessed)
                jsr sub46                    ; fa7d: 20 a9 fa (unaccessed)
                ldy #$37                     ; fa80: a0 37    (unaccessed)
                jsr SelectPRG23B             ; fa82: 20 37 f2 (unaccessed)
                jsr $a01e                    ; fa85: 20 1e a0 (unaccessed)
                jsr sub47                    ; fa88: 20 bf fa (unaccessed)
                jsr sub50                    ; fa8b: 20 62 ff (unaccessed)
                jsr sub19                    ; fa8e: 20 30 e8 (unaccessed)
                jsr sub49                    ; fa91: 20 28 fb (unaccessed)
                jmp cod59                    ; fa94: 4c 8d f8 (unaccessed)

                jsr sub48                    ; fa97: 20 0b fb (unaccessed)
                jsr sub37                    ; fa9a: 20 06 f2 (unaccessed)
                jsr PADINPUT                 ; fa9d: 20 c6 e6 (unaccessed)
                jsr sub50                    ; faa0: 20 62 ff (unaccessed)
                jsr sub49                    ; faa3: 20 28 fb (unaccessed)
                jmp cod59                    ; faa6: 4c 8d f8 (unaccessed)

sub46           lda misc34                   ; faa9: ad 44 6f (unaccessed)
                beq +                        ; faac: f0 10    (unaccessed)
                ldy ram63                    ; faae: a4 81    (unaccessed)
                lda ram64                    ; fab0: a5 82    (unaccessed)
                sta ram63                    ; fab2: 85 81    (unaccessed)
                sty ram64                    ; fab4: 84 82    (unaccessed)
                ldy ram65                    ; fab6: a4 83    (unaccessed)
                lda ram67                    ; fab8: a5 85    (unaccessed)
                sta ram65                    ; faba: 85 83    (unaccessed)
                sty ram67                    ; fabc: 84 85    (unaccessed)
+               rts                          ; fabe: 60       (unaccessed)
sub47           lda misc34                   ; fabf: ad 44 6f (unaccessed)
                beq +                        ; fac2: f0 10    (unaccessed)
                ldy ram64                    ; fac4: a4 82    (unaccessed)
                lda ram63                    ; fac6: a5 81    (unaccessed)
                sta ram64                    ; fac8: 85 82    (unaccessed)
                sty ram63                    ; faca: 84 81    (unaccessed)
                ldy ram67                    ; facc: a4 85    (unaccessed)
                lda ram65                    ; face: a5 83    (unaccessed)
                sta ram67                    ; fad0: 85 85    (unaccessed)
                sty ram65                    ; fad2: 84 83    (unaccessed)
+               rts                          ; fad4: 60       (unaccessed)
cod61           jsr sub37                    ; fad5: 20 06 f2 (unaccessed)
                jsr sub48                    ; fad8: 20 0b fb (unaccessed)
                lda PRGSelect3B              ; fadb: a5 e3    (unaccessed)
                pha                          ; fadd: 48       (unaccessed)
                lda PRGSelect2B              ; fade: a5 e2    (unaccessed)
                pha                          ; fae0: 48       (unaccessed)
                lda PRGSelect1B              ; fae1: a5 e1    (unaccessed)
                pha                          ; fae3: 48       (unaccessed)
                ldy #$2e                     ; fae4: a0 2e    (unaccessed)
                jsr SelectPRG23B             ; fae6: 20 37 f2 (unaccessed)
                jsr $a003                    ; fae9: 20 03 a0 (unaccessed)
                lda ram89                    ; faec: a5 a5    (unaccessed)
                sta_abs $f800                ; faee: 8d 00 f8 (unaccessed)
                pla                          ; faf1: 68       (unaccessed)
                sta PRGSelect1B              ; faf2: 85 e1    (unaccessed)
                sta_abs $e000                ; faf4: 8d 00 e0 (unaccessed)
                pla                          ; faf7: 68       (unaccessed)
                sta PRGSelect2B              ; faf8: 85 e2    (unaccessed)
                ora #%11000000               ; fafa: 09 c0    (unaccessed)
                sta_abs $e800                ; fafc: 8d 00 e8 (unaccessed)
                pla                          ; faff: 68       (unaccessed)
                sta PRGSelect3B              ; fb00: 85 e3    (unaccessed)
                sta_abs $f000                ; fb02: 8d 00 f0 (unaccessed)
                jsr sub49                    ; fb05: 20 28 fb (unaccessed)
                jmp cod60                    ; fb08: 4c af f8 (unaccessed)

sub48           jsr sub22                    ; fb0b: 20 f7 ea (unaccessed)
                lda ram136                   ; fb0e: a5 e6    (unaccessed)
                sta_abs $c000                ; fb10: 8d 00 c0 (unaccessed)
                lda ram137                   ; fb13: a5 e7    (unaccessed) 
                sta_abs $c800                ; fb15: 8d 00 c8 (unaccessed)
                lda ram138                   ; fb18: a5 e8    (unaccessed)
                sta_abs $d000                ; fb1a: 8d 00 d0 (unaccessed)
                lda ram139                   ; fb1d: a5 e9    (unaccessed)
                sta_abs $d800                ; fb1f: 8d 00 d8 (unaccessed)
-               bit ppu_status               ; fb22: 2c 02 20 (unaccessed)
                bvs -                        ; fb25: 70 fb    (unaccessed)
                rts                          ; fb27: 60       (unaccessed)

sub49           lda ram45                    ; fb28: a5 62    (unaccessed)
                bne sub49                    ; fb2a: d0 fc    (unaccessed)
                rts                          ; fb2c: 60       (unaccessed)

BRKFUNC         pha                          ; fb2d: 48       (unaccessed)
                txa                          ; fb2e: 8a       (unaccessed)
                pha                          ; fb2f: 48       (unaccessed)
                tya                          ; fb30: 98       (unaccessed)
                pha                          ; fb31: 48       (unaccessed)
                lda misc20                   ; fb32: ad 00 58 (unaccessed)
                and #%01111111               ; fb35: 29 7f    (unaccessed)
                cmp #$7f                     ; fb37: c9 7f    (unaccessed)
                beq +                        ; fb39: f0 04    (unaccessed)
                nop                          ; fb3b: ea       (unaccessed)
-               jmp -                        ; fb3c: 4c 3c fb (unaccessed)
+               ldy_abs ram43                ; fb3f: ac 60 00 (unaccessed)
                beq cod64                    ; fb42: f0 4e    (unaccessed)
                dey                          ; fb44: 88       (unaccessed)
                bne +                        ; fb45: d0 09    (unaccessed)
                nop                          ; fb47: ea       (unaccessed)
                nop                          ; fb48: ea       (unaccessed)
                nop                          ; fb49: ea       (unaccessed)
                nop                          ; fb4a: ea       (unaccessed)
                nop                          ; fb4b: ea       (unaccessed)
                nop                          ; fb4c: ea       (unaccessed)
                jmp cod66                    ; fb4d: 4c a4 fb (unaccessed)
+               dey                          ; fb50: 88       (unaccessed)
                bne +                        ; fb51: d0 03    (unaccessed)
                jmp cod75                    ; fb53: 4c 8b fc (unaccessed)
+               dey                          ; fb56: 88       (unaccessed)
                bne +                        ; fb57: d0 03    (unaccessed)
                jmp cod66                    ; fb59: 4c a4 fb (unaccessed)
+               dey                          ; fb5c: 88       (unaccessed)
                bne +                        ; fb5d: d0 03    (unaccessed)
                jmp cod80                    ; fb5f: 4c 2a fd (unaccessed)
+               dey                          ; fb62: 88       (unaccessed)
                bne +                        ; fb63: d0 03    (unaccessed)
                jmp cod86                    ; fb65: 4c 95 fd (unaccessed)
+               dey                          ; fb68: 88       (unaccessed)
                bne +                        ; fb69: d0 03    (unaccessed)
                jmp cod89                    ; fb6b: 4c f4 fd (unaccessed)
+               dey                          ; fb6e: 88       (unaccessed)
                bne +                        ; fb6f: d0 03    (unaccessed)
                jmp cod90                    ; fb71: 4c 03 fe (unaccessed)
+               dey                          ; fb74: 88       (unaccessed)
                bne +                        ; fb75: d0 03    (unaccessed)
                jmp cod94                    ; fb77: 4c 69 fe (unaccessed)
+               dey                          ; fb7a: 88       (unaccessed)
                bne +                        ; fb7b: d0 03    (unaccessed)
                jmp cod95                    ; fb7d: 4c 96 fe (unaccessed)
+               dey                          ; fb80: 88       (unaccessed)
                bne cod63                    ; fb81: d0 03    (unaccessed)
cod62           jmp cod96                    ; fb83: 4c cd fe (unaccessed)
cod63           dey                          ; fb86: 88       (unaccessed)
                bne +                        ; fb87: d0 03    (unaccessed)
                jmp cod97                    ; fb89: 4c 31 ff (unaccessed)
+               dey                          ; fb8c: 88       (unaccessed)
                bne cod64                    ; fb8d: d0 03    (unaccessed)
                jmp cod98                    ; fb8f: 4c 48 ff (unaccessed)
cod64           sei                          ; fb92: 78       (unaccessed)
                lda #0                       ; fb93: a9 00    (unaccessed)
                sta_abs ram45                ; fb95: 8d 62 00 (unaccessed)
                sta misc18                   ; fb98: 8d 00 50 (unaccessed)
                sta misc20                   ; fb9b: 8d 00 58 (unaccessed)
cod65           pla                          ; fb9e: 68       (unaccessed)
                tay                          ; fb9f: a8       (unaccessed)
                pla                          ; fba0: 68       (unaccessed)
                tax                          ; fba1: aa       (unaccessed)
                pla                          ; fba2: 68       (unaccessed)
                rti                          ; fba3: 40       (unaccessed)

cod66           lda_abs ram46                ; fba4: ad 63 00 (unaccessed)
                asl a                        ; fba7: 0a       (unaccessed)
                tax                          ; fba8: aa       (unaccessed)
                lda #0                       ; fba9: a9 00    (unaccessed)
                sta misc18                   ; fbab: 8d 00 50 (unaccessed)
                lda_absx arr19               ; fbae: bd 6a 00 (unaccessed)
cod67           sta misc18                   ; fbb1: 8d 00 50 (unaccessed)
                lda_absx arr20               ; fbb4: bd 6b 00 (unaccessed)
                sta misc20                   ; fbb7: 8d 00 58 (unaccessed)
                ldy_abs ram46                ; fbba: ac 63 00 (unaccessed)
                beq cod68                    ; fbbd: f0 0f    (unaccessed)
                dey                          ; fbbf: 88       (unaccessed)
                bne +                        ; fbc0: d0 03    (unaccessed)
                jmp cod70                    ; fbc2: 4c fc fb (unaccessed)
+               dey                          ; fbc5: 88       (unaccessed)
                bne +                        ; fbc6: d0 03    (unaccessed)
                jmp cod72                    ; fbc8: 4c 2a fc (unaccessed)
+               jmp cod74                    ; fbcb: 4c 58 fc (unaccessed)
cod68           lda ram107                   ; fbce: a5 c2    (unaccessed)
                ldy ram108                   ; fbd0: a4 c3    (unaccessed)
                ldx ram109                   ; fbd2: a6 c4    (unaccessed)
                sta_abs $a000                ; fbd4: 8d 00 a0 (unaccessed)
                sty_abs $a800                ; fbd7: 8c 00 a8 (unaccessed)
                stx_abs $b000                ; fbda: 8e 00 b0 (unaccessed)
                lda $c5                      ; fbdd: a5 c5    (unaccessed)
                sta_abs $b800                ; fbdf: 8d 00 b8 (unaccessed)
                lda ram104                   ; fbe2: a5 be    (unaccessed)
                ldy ram105                   ; fbe4: a4 bf    (unaccessed)
                ldx ram106                   ; fbe6: a6 c0    (unaccessed)
                sta_abs $8000                ; fbe8: 8d 00 80 (unaccessed)
                sty_abs $8800                ; fbeb: 8c 00 88 (unaccessed)
                stx_abs $9000                ; fbee: 8e 00 90 (unaccessed)
                lda $c1                      ; fbf1: a5 c1    (unaccessed)
                sta_abs $9800                ; fbf3: 8d 00 98 (unaccessed)
                inc_abs ram46                ; fbf6: ee 63 00 (unaccessed)
                jmp cod65                    ; fbf9: 4c 9e fb (unaccessed)
cod70           lda ram113                   ; fbfc: a5 ca    (unaccessed)
                ldy ram114                   ; fbfe: a4 cb    (unaccessed)
                ldx ram115                   ; fc00: a6 cc    (unaccessed)
                sta_abs $a000                ; fc02: 8d 00 a0 (unaccessed)
                sty_abs $a800                ; fc05: 8c 00 a8 (unaccessed)
                stx_abs $b000                ; fc08: 8e 00 b0 (unaccessed)
                lda $cd                      ; fc0b: a5 cd    (unaccessed)
                sta_abs $b800                ; fc0d: 8d 00 b8 (unaccessed)
                ldy ram110                   ; fc10: a4 c6    (unaccessed)
                ldx ram111                   ; fc12: a6 c7    (unaccessed)
                lda ram112                   ; fc14: a5 c8    (unaccessed)
                sty_abs $8000                ; fc16: 8c 00 80 (unaccessed)
                stx_abs $8800                ; fc19: 8e 00 88 (unaccessed)
                sta_abs $9000                ; fc1c: 8d 00 90 (unaccessed)
                ldy $c9                      ; fc1f: a4 c9    (unaccessed)
                sty_abs $9800                ; fc21: 8c 00 98 (unaccessed)
                inc_abs ram46                ; fc24: ee 63 00 (unaccessed)
                jmp cod65                    ; fc27: 4c 9e fb (unaccessed)
cod72           lda ram120                   ; fc2a: a5 d2    (unaccessed)
                ldy ram121                   ; fc2c: a4 d3    (unaccessed)
                ldx ram122                   ; fc2e: a6 d4    (unaccessed)
                sta_abs $a000                ; fc30: 8d 00 a0 (unaccessed)
                sty_abs $a800                ; fc33: 8c 00 a8 (unaccessed)
                stx_abs $b000                ; fc36: 8e 00 b0 (unaccessed)
                lda $d5                      ; fc39: a5 d5    (unaccessed)
                sta_abs $b800                ; fc3b: 8d 00 b8 (unaccessed)
                ldy ram116                   ; fc3e: a4 ce    (unaccessed)
                ldx ram117                   ; fc40: a6 cf    (unaccessed)
                sty_abs $8000                ; fc42: 8c 00 80 (unaccessed)
                stx_abs $8800                ; fc45: 8e 00 88 (unaccessed)
cod73           lda ram118                   ; fc48: a5 d0    (unaccessed)
                ldy ram119                   ; fc4a: a4 d1    (unaccessed)
                sta_abs $9000                ; fc4c: 8d 00 90 (unaccessed)
                sty_abs $9800                ; fc4f: 8c 00 98 (unaccessed)
                inc_abs ram46                ; fc52: ee 63 00 (unaccessed)
                jmp cod65                    ; fc55: 4c 9e fb (unaccessed)
cod74           lda ram127                   ; fc58: a5 da    (unaccessed)
                ldy ram128                   ; fc5a: a4 db    (unaccessed)
                ldx ram129                   ; fc5c: a6 dc    (unaccessed)
                sta_abs $a000                ; fc5e: 8d 00 a0 (unaccessed)
                sty_abs $a800                ; fc61: 8c 00 a8 (unaccessed)
                stx_abs $b000                ; fc64: 8e 00 b0 (unaccessed)
                lda $dd                      ; fc67: a5 dd    (unaccessed)
                sta_abs $b800                ; fc69: 8d 00 b8 (unaccessed)
                ldy ram123                   ; fc6c: a4 d6    (unaccessed)
                ldx ram124                   ; fc6e: a6 d7    (unaccessed)
                sty_abs $8000                ; fc70: 8c 00 80 (unaccessed)
                stx_abs $8800                ; fc73: 8e 00 88 (unaccessed)
                lda ram125                   ; fc76: a5 d8    (unaccessed)
                ldy ram126                   ; fc78: a4 d9    (unaccessed)
                sta_abs $9000                ; fc7a: 8d 00 90 (unaccessed)
                sty_abs $9800                ; fc7d: 8c 00 98 (unaccessed)
                lda #0                       ; fc80: a9 00    (unaccessed)
                sta_abs ram46                ; fc82: 8d 63 00 (unaccessed)
                inc_abs ram43                ; fc85: ee 60 00 (unaccessed)
                jmp cod65                    ; fc88: 4c 9e fb (unaccessed)
cod75           sei                          ; fc8b: 78       (unaccessed)
                lda #0                       ; fc8c: a9 00    (unaccessed)
                sta_abs ram45                ; fc8e: 8d 62 00 (unaccessed)
                sta misc18                   ; fc91: 8d 00 50 (unaccessed)
                sta misc20                   ; fc94: 8d 00 58 (unaccessed)
                ldy #8                       ; fc97: a0 08    (unaccessed)
-               dey                          ; fc99: 88       (unaccessed)
                bpl -                        ; fc9a: 10 fd    (unaccessed)
                lda_abs ram82                ; fc9c: ad 99 00 (unaccessed)
cod76           and #%00000111               ; fc9f: 29 07    (unaccessed)
                asl a                        ; fca1: 0a       (unaccessed)
                tay                          ; fca2: a8       (unaccessed)
                lda dat19L,y                 ; fca3: b9 1a fd (unaccessed)
                sta_abs ram26                ; fca6: 8d 46 00 (unaccessed)
                lda dat19H,y                 ; fca9: b9 1b fd (unaccessed)
                sta_abs ram27                ; fcac: 8d 47 00 (unaccessed)
                lda #$0f                     ; fcaf: a9 0f    (unaccessed)
                sta_abs $8000                ; fcb1: 8d 00 80 (unaccessed)
                sta_abs $8800                ; fcb4: 8c 00 88 (unaccessed)
                sta_abs $9000                ; fcb7: 8e 00 90 (unaccessed)
                sta_abs $9800                ; fcba: 8d 00 98 (unaccessed)
                sta_abs $a000                ; fcbd: 8d 00 a0 (unaccessed)
                sta_abs $a800                ; fcc0: 8c 00 a8 (unaccessed)
                sta_abs $b000                ; fcc3: 8e 00 b0 (unaccessed)
                sta_abs $b800                ; fcc6: 8d 00 b8 (unaccessed)
-               dec_abs ram26                ; fcc9: ce 46 00 (unaccessed)
                bne -                        ; fccc: d0 fb    (unaccessed)
                lda ram140                   ; fcce: a5 ea    (unaccessed)
                ldy ram84                    ; fcd0: a4 9b    (unaccessed)
                ldx ram83                    ; fcd2: a6 9a    (unaccessed)
                sta_abs $c700                ; fcd4: 8d 00 c7 (unaccessed)
                sty ppu_addr                 ; fcd7: 8c 06 20 (unaccessed)
                stx ppu_addr                 ; fcda: 8e 06 20 (unaccessed)
                ldx ram80                    ; fcdd: a6 96    (unaccessed)
                stx ppu_scroll               ; fcdf: 8e 05 20 (unaccessed)
                stx ppu_scroll               ; fce2: 8e 05 20 (unaccessed)
-               dec_abs ram27                ; fce5: ce 47 00 (unaccessed)
                bne -                        ; fce8: d0 fb    (unaccessed)
                lda ram100                   ; fcea: a5 ba    (unaccessed)
                ldy ram101                   ; fcec: a4 bb    (unaccessed)
                ldx ram102                   ; fcee: a6 bc    (unaccessed)
                sta_abs $a000                ; fcf0: 8d 00 a0 (unaccessed)
                sty_abs $a800                ; fcf3: 8c 00 a8 (unaccessed)
                stx_abs $b000                ; fcf6: 8e 00 b0 (unaccessed)
                lda ram103                   ; fcf9: a5 bd    (unaccessed)
                sta_abs $b800                ; fcfb: 8d 00 b8 (unaccessed)
                ldy #$1b                     ; fcfe: a0 1b    (unaccessed)
-               dey                          ; fd00: 88       (unaccessed)
                bne -                        ; fd01: d0 fd    (unaccessed)
                lda arr26                    ; fd03: a5 b6    (unaccessed)
                ldy ram98                    ; fd05: a4 b7    (unaccessed)
                ldx ram99                    ; fd07: a6 b8    (unaccessed)
                sta_abs $8000                ; fd09: 8d 00 80 (unaccessed)
                sty_abs $8800                ; fd0c: 8c 00 88 (unaccessed)
                stx_abs $9000                ; fd0f: 8e 00 90 (unaccessed)
                lda $b9                      ; fd12: a5 b9    (unaccessed)
                sta_abs $9800                ; fd14: 8d 00 98 (unaccessed)
                jmp cod65                    ; fd17: 4c 9e fb (unaccessed)
dat19L          hex 68                       ; fd1a: 68       (unaccessed)
dat19H          hex 0b                       ; fd1b           (unaccessed)
                hex 5c 18 50 23 44 2e 37 39  ; fb1c
                hex 2a 45 1e 50 12 5b

cod80           sei                          ; fd2a: 78       (unaccessed)
                lda #0                       ; fd2b: a9 00    (unaccessed)
                sta_abs ram45                ; fd2d: 8d 62 00 (unaccessed)
                sta misc18                   ; fd30: 8d 00 50 (unaccessed)
cod81           sta misc20                   ; fd33: 8d 00 58 (unaccessed)
                ldy #$0f                     ; fd36: a0 0f    (unaccessed)

                hex 8c                       ; fd38           (unaccessed)

                brk                          ; fd39: 00       (unaccessed)
                ldy #$8c                     ; fd3a: a0 8c    (unaccessed)
                brk                          ; fd3c: 00       (unaccessed)
                tay                          ; fd3d: a8       (unaccessed)

cod82           hex 8c                       ; fd3e           (unaccessed)

                brk                          ; fd3f: 00       (unaccessed)
                bcs cod78                    ; fd40: b0 8c    (unaccessed)
                brk                          ; fd42: 00       (unaccessed)
cod83           clv                          ; fd43: b8       (unaccessed)
                ldy ram54                    ; fd44: a4 72    (unaccessed)
-               dey                          ; fd46: 88       (unaccessed)
                bpl -                        ; fd47: 10 fd    (unaccessed)
                lda ram140                   ; fd49: a5 ea    (unaccessed)
                ldx ram84                    ; fd4b: a6 9b    (unaccessed)
                ldy ram83                    ; fd4d: a4 9a    (unaccessed)
                stx ppu_addr                 ; fd4f: 8e 06 20 (unaccessed)
                sty ppu_addr                 ; fd52: 8c 06 20 (unaccessed)
                ldx ram80                    ; fd55: a6 96    (unaccessed)
                stx ppu_scroll               ; fd57: 8e 05 20 (unaccessed)
                stx ppu_scroll               ; fd5a: 8e 05 20 (unaccessed)

                hex 8d                       ; fd5d           (unaccessed)

                brk                          ; fd5e: 00       (unaccessed)

                hex c7                       ; fd5f           (unaccessed)

                ldy ram55                    ; fd60: a4 73    (unaccessed)
-               dey                          ; fd62: 88       (unaccessed)
                bpl -                        ; fd63: 10 fd    (unaccessed)
                lda ram100                   ; fd65: a5 ba    (unaccessed)
                ldy ram101                   ; fd67: a4 bb    (unaccessed)
                ldx ram102                   ; fd69: a6 bc    (unaccessed)

                hex 8d                       ; fd6b           (unaccessed)

                brk                          ; fd6c: 00       (unaccessed)
                ldy #$8c                     ; fd6d: a0 8c    (unaccessed)
                brk                          ; fd6f: 00       (unaccessed)
                tay                          ; fd70: a8       (unaccessed)

cod84           hex 8e                       ; fd71           (unaccessed)

                brk                          ; fd72: 00       (unaccessed)
                bcs cod79                    ; fd73: b0 a5    (unaccessed)
                lda_absx arr24               ; fd75: bd 8d 00 (unaccessed)
                clv                          ; fd78: b8       (unaccessed)
                ldy ram56                    ; fd79: a4 74    (unaccessed)
-               dey                          ; fd7b: 88       (unaccessed)
                bpl -                        ; fd7c: 10 fd    (unaccessed)
                lda arr26                    ; fd7e: a5 b6    (unaccessed)
                ldy ram98                    ; fd80: a4 b7    (unaccessed)
                ldx ram99                    ; fd82: a6 b8    (unaccessed)

                hex 8d                       ; fd84           (unaccessed)

                brk                          ; fd85: 00       (unaccessed)

                hex 80 8c                    ; fd86           (unaccessed)

                brk                          ; fd88: 00       (unaccessed)
                dey                          ; fd89: 88       (unaccessed)

                hex 8e                       ; fd8a           (unaccessed)

                brk                          ; fd8b: 00       (unaccessed)
                bcc cod81                    ; fd8c: 90 a5    (unaccessed)
                lda arr24,y                  ; fd8e: b9 8d 00 (unaccessed)
                tya                          ; fd91: 98       (unaccessed)
cod85           jmp cod65                    ; fd92: 4c 9e fb (unaccessed)
cod86           sei                          ; fd95: 78       (unaccessed)
                lda #0                       ; fd96: a9 00    (unaccessed)
                sta_abs ram45                ; fd98: 8d 62 00 (unaccessed)
                sta misc18                   ; fd9b: 8d 00 50 (unaccessed)
                sta misc20                   ; fd9e: 8d 00 58 (unaccessed)
                lda ppu_status               ; fda1: ad 02 20 (unaccessed)
                lda #$e1                     ; fda4: a9 e1    (unaccessed)
                ldx ram84                    ; fda6: a6 9b    (unaccessed)
                ldy ram83                    ; fda8: a4 9a    (unaccessed)

                hex 8d                       ; fdaa           (unaccessed)

                brk                          ; fdab: 00       (unaccessed)

                hex c7 8d                    ; fdac           (unaccessed)

                brk                          ; fdae: 00       (unaccessed)
                bne cod82                    ; fdaf: d0 8d    (unaccessed)
                brk                          ; fdb1: 00       (unaccessed)
                iny                          ; fdb2: c8       (unaccessed)

                hex 8d                       ; fdb3           (unaccessed)

                brk                          ; fdb4: 00       (unaccessed)
                cld                          ; fdb5: d8       (unaccessed)
                stx ppu_addr                 ; fdb6: 8e 06 20 (unaccessed)
                sty ppu_addr                 ; fdb9: 8c 06 20 (unaccessed)
                ldy ram101                   ; fdbc: a4 bb    (unaccessed)
                ldx ram102                   ; fdbe: a6 bc    (unaccessed)
                lda ram100                   ; fdc0: a5 ba    (unaccessed)

                hex 8d                       ; fdc2           (unaccessed)

                brk                          ; fdc3: 00       (unaccessed)
cod87           ldy #$8c                     ; fdc4: a0 8c    (unaccessed)
                brk                          ; fdc6: 00       (unaccessed)
                tay                          ; fdc7: a8       (unaccessed)

                hex 8e                       ; fdc8           (unaccessed)

                brk                          ; fdc9: 00       (unaccessed)
                bcs cod84                    ; fdca: b0 a5    (unaccessed)
                lda_absx arr24               ; fdcc: bd 8d 00 (unaccessed)
                clv                          ; fdcf: b8       (unaccessed)
                ldx ram80                    ; fdd0: a6 96    (unaccessed)
                stx ppu_scroll               ; fdd2: 8e 05 20 (unaccessed)
                stx ppu_scroll               ; fdd5: 8e 05 20 (unaccessed)
                ldy #$30                     ; fdd8: a0 30    (unaccessed)
-               dey                          ; fdda: 88       (unaccessed)
cod88           bpl -                        ; fddb: 10 fd    (unaccessed)
                lda arr26                    ; fddd: a5 b6    (unaccessed)
                ldy ram98                    ; fddf: a4 b7    (unaccessed)
                ldx ram99                    ; fde1: a6 b8    (unaccessed)

                hex 8d                       ; fde3           (unaccessed)

                brk                          ; fde4: 00       (unaccessed)

                hex 80 8c                    ; fde5           (unaccessed)

                brk                          ; fde7: 00       (unaccessed)
                dey                          ; fde8: 88       (unaccessed)

                hex 8e                       ; fde9           (unaccessed)

                brk                          ; fdea: 00       (unaccessed)
                bcc cod85                    ; fdeb: 90 a5    (unaccessed)
                lda arr24,y                  ; fded: b9 8d 00 (unaccessed)
                tya                          ; fdf0: 98       (unaccessed)
                jmp cod65                    ; fdf1: 4c 9e fb (unaccessed)
cod89           sei                          ; fdf4: 78       (unaccessed)
                lda #0                       ; fdf5: a9 00    (unaccessed)
                sta_abs ram45                ; fdf7: 8d 62 00 (unaccessed)
                sta misc18                   ; fdfa: 8d 00 50 (unaccessed)
                sta misc20                   ; fdfd: 8d 00 58 (unaccessed)
                jmp cod65                    ; fe00: 4c 9e fb (unaccessed)
cod90           lda_abs ram46                ; fe03: ad 63 00 (unaccessed)
                asl a                        ; fe06: 0a       (unaccessed)
                tax                          ; fe07: aa       (unaccessed)
                lda #0                       ; fe08: a9 00    (unaccessed)
                sta misc18                   ; fe0a: 8d 00 50 (unaccessed)
                lda_absx arr19               ; fe0d: bd 6a 00 (unaccessed)
                sta misc18                   ; fe10: 8d 00 50 (unaccessed)
                lda_absx arr20               ; fe13: bd 6b 00 (unaccessed)
                sta misc20                   ; fe16: 8d 00 58 (unaccessed)
                ldy_abs ram46                ; fe19: ac 63 00 (unaccessed)
                beq +                        ; fe1c: f0 09    (unaccessed)
                dey                          ; fe1e: 88       (unaccessed)
                beq cod91                    ; fe1f: f0 3a    (unaccessed)
                dey                          ; fe21: 88       (unaccessed)
                beq cod92                    ; fe22: f0 3a    (unaccessed)
                jmp cod93                    ; fe24: 4c 61 fe (unaccessed)
+               lda ppu_status               ; fe27: ad 02 20 (unaccessed)
                lda #$e1                     ; fe2a: a9 e1    (unaccessed)
                ldx #$25                     ; fe2c: a2 25    (unaccessed)
                ldy #$b8                     ; fe2e: a0 b8    (unaccessed)

                hex 8d                       ; fe30           (unaccessed)

                brk                          ; fe31: 00       (unaccessed)

                hex c7 8d                    ; fe32           (unaccessed)

                brk                          ; fe34: 00       (unaccessed)
                bne cod87                    ; fe35: d0 8d    (unaccessed)
                brk                          ; fe37: 00       (unaccessed)
                iny                          ; fe38: c8       (unaccessed)

                hex 8d                       ; fe39           (unaccessed)

                brk                          ; fe3a: 00       (unaccessed)
                cld                          ; fe3b: d8       (unaccessed)
                stx ppu_addr                 ; fe3c: 8e 06 20 (unaccessed)
                sty ppu_addr                 ; fe3f: 8c 06 20 (unaccessed)
                lda #$0f                     ; fe42: a9 0f    (unaccessed)

                hex 8d                       ; fe44           (unaccessed)

                brk                          ; fe45: 00       (unaccessed)
                ldy #$8d                     ; fe46: a0 8d    (unaccessed)
                brk                          ; fe48: 00       (unaccessed)
                tay                          ; fe49: a8       (unaccessed)

                hex 8d                       ; fe4a           (unaccessed)

                brk                          ; fe4b: 00       (unaccessed)
                bcs cod88                    ; fe4c: b0 8d    (unaccessed)
                brk                          ; fe4e: 00       (unaccessed)
                clv                          ; fe4f: b8       (unaccessed)
                ldx #0                       ; fe50: a2 00    (unaccessed)
                stx ppu_scroll               ; fe52: 8e 05 20 (unaccessed)
                stx ppu_scroll               ; fe55: 8e 05 20 (unaccessed)
                jmp cod68                    ; fe58: 4c ce fb (unaccessed)
cod91           jmp cod70                    ; fe5b: 4c fc fb (unaccessed)
cod92           jmp cod72                    ; fe5e: 4c 2a fc (unaccessed)
cod93           lda #0                       ; fe61: a9 00    (unaccessed)
                sta_abs ram46                ; fe63: 8d 63 00 (unaccessed)
                jmp cod86                    ; fe66: 4c 95 fd (unaccessed)
cod94           lda_abs ram46                ; fe69: ad 63 00 (unaccessed)
                asl a                        ; fe6c: 0a       (unaccessed)
                tax                          ; fe6d: aa       (unaccessed)
                lda #0                       ; fe6e: a9 00    (unaccessed)
                sta misc18                   ; fe70: 8d 00 50 (unaccessed)
                lda_absx arr19               ; fe73: bd 6a 00 (unaccessed)
                sta misc18                   ; fe76: 8d 00 50 (unaccessed)
                lda_absx arr20               ; fe79: bd 6b 00 (unaccessed)
                sta misc20                   ; fe7c: 8d 00 58 (unaccessed)
                ldy_abs ram46                ; fe7f: ac 63 00 (unaccessed)
                bne +                        ; fe82: d0 03    (unaccessed)
                jmp cod68                    ; fe84: 4c ce fb (unaccessed)
+               dey                          ; fe87: 88       (unaccessed)
                bne +                        ; fe88: d0 03    (unaccessed)
                jmp cod70                    ; fe8a: 4c fc fb (unaccessed)
+               dey                          ; fe8d: 88       (unaccessed)
                bne +                        ; fe8e: d0 03    (unaccessed)
                jmp cod72                    ; fe90: 4c 2a fc (unaccessed)
+               jmp cod74                    ; fe93: 4c 58 fc (unaccessed)
cod95           sei                          ; fe96: 78       (unaccessed)
                lda #0                       ; fe97: a9 00    (unaccessed)
                sta_abs ram45                ; fe99: 8d 62 00 (unaccessed)
                sta misc18                   ; fe9c: 8d 00 50 (unaccessed)
                sta misc20                   ; fe9f: 8d 00 58 (unaccessed)
                lda ram100                   ; fea2: a5 ba    (unaccessed)
                ldy ram101                   ; fea4: a4 bb    (unaccessed)
                ldx ram102                   ; fea6: a6 bc    (unaccessed)

                hex 8d                       ; fea8           (unaccessed)

                brk                          ; fea9: 00       (unaccessed)
                ldy #$8c                     ; feaa: a0 8c    (unaccessed)
                brk                          ; feac: 00       (unaccessed)
                tay                          ; fead: a8       (unaccessed)

                hex 8e                       ; feae           (unaccessed)

                brk                          ; feaf: 00       (unaccessed)
                bcs $fe57                    ; feb0: b0 a5    (unaccessed)
                lda_absx arr24               ; feb2: bd 8d 00 (unaccessed)
                clv                          ; feb5: b8       (unaccessed)
                lda arr26                    ; feb6: a5 b6    (unaccessed)
                ldy ram98                    ; feb8: a4 b7    (unaccessed)
                ldx ram99                    ; feba: a6 b8    (unaccessed)

                hex 8d                       ; febc           (unaccessed)

                brk                          ; febd: 00       (unaccessed)

                hex 80 8c                    ; febe           (unaccessed)

                brk                          ; fec0: 00       (unaccessed)
                dey                          ; fec1: 88       (unaccessed)

                hex 8e                       ; fec2           (unaccessed)

                brk                          ; fec3: 00       (unaccessed)
                bcc $fe6b                    ; fec4: 90 a5    (unaccessed)
                lda arr24,y                  ; fec6: b9 8d 00 (unaccessed)
                tya                          ; fec9: 98       (unaccessed)
                jmp cod65                    ; feca: 4c 9e fb (unaccessed)
cod96           sei                          ; fecd: 78       (unaccessed)
                lda #0                       ; fece: a9 00    (unaccessed)
                sta_abs ram45                ; fed0: 8d 62 00 (unaccessed)
                sta misc18                   ; fed3: 8d 00 50 (unaccessed)
                sta misc20                   ; fed6: 8d 00 58 (unaccessed)
                lda ppu_status               ; fed9: ad 02 20 (unaccessed)
                lda ram140                   ; fedc: a5 ea    (unaccessed)

                hex 8d                       ; fede           (unaccessed)

                brk                          ; fedf: 00       (unaccessed)
                cpy #$a9                     ; fee0: c0 a9    (unaccessed)

                hex 0f                       ; fee2           (unaccessed)

                ldy ram84                    ; fee3: a4 9b    (unaccessed)
                ldx ram83                    ; fee5: a6 9a    (unaccessed)

                hex 8d                       ; fee7           (unaccessed)

                brk                          ; fee8: 00       (unaccessed)
                ldy #$8d                     ; fee9: a0 8d    (unaccessed)
                brk                          ; feeb: 00       (unaccessed)
                tay                          ; feec: a8       (unaccessed)

                hex 8d                       ; feed           (unaccessed)

                brk                          ; feee: 00       (unaccessed)
                bcs $fe7e                    ; feef: b0 8d    (unaccessed)
                brk                          ; fef1: 00       (unaccessed)
                clv                          ; fef2: b8       (unaccessed)
                sty ppu_addr                 ; fef3: 8c 06 20 (unaccessed)
                stx ppu_addr                 ; fef6: 8e 06 20 (unaccessed)
                lda #0                       ; fef9: a9 00    (unaccessed)
                sta ppu_scroll               ; fefb: 8d 05 20 (unaccessed)
                sta ppu_scroll               ; fefe: 8d 05 20 (unaccessed)
                ldy #$10                     ; ff01: a0 10    (unaccessed)
-               dey                          ; ff03: 88       (unaccessed)
                bpl -                        ; ff04: 10 fd    (unaccessed)
                lda ram100                   ; ff06: a5 ba    (unaccessed)
                ldy ram101                   ; ff08: a4 bb    (unaccessed)
                ldx ram102                   ; ff0a: a6 bc    (unaccessed)

                hex 8d                       ; ff0c           (unaccessed)

                brk                          ; ff0d: 00       (unaccessed)
                ldy #$8c                     ; ff0e: a0 8c    (unaccessed)
                brk                          ; ff10: 00       (unaccessed)
                tay                          ; ff11: a8       (unaccessed)

                hex 8e                       ; ff12           (unaccessed)

                brk                          ; ff13: 00       (unaccessed)
                bcs $febb                    ; ff14: b0 a5    (unaccessed)
                lda_absx arr24               ; ff16: bd 8d 00 (unaccessed)
                clv                          ; ff19: b8       (unaccessed)
                lda arr26                    ; ff1a: a5 b6    (unaccessed)
                ldy ram98                    ; ff1c: a4 b7    (unaccessed)
                ldx ram99                    ; ff1e: a6 b8    (unaccessed)

                hex 8d                       ; ff20           (unaccessed)

                brk                          ; ff21: 00       (unaccessed)

                hex 80 8c                    ; ff22           (unaccessed)

                brk                          ; ff24: 00       (unaccessed)
                dey                          ; ff25: 88       (unaccessed)

                hex 8e                       ; ff26           (unaccessed)

                brk                          ; ff27: 00       (unaccessed)
                bcc $fecf                    ; ff28: 90 a5    (unaccessed)
                lda arr24,y                  ; ff2a: b9 8d 00 (unaccessed)
                tya                          ; ff2d: 98       (unaccessed)
                jmp cod65                    ; ff2e: 4c 9e fb (unaccessed)
cod97           lda #0                       ; ff31: a9 00    (unaccessed)
                sta misc18                   ; ff33: 8d 00 50 (unaccessed)
                lda_abs arr19                ; ff36: ad 6a 00 (unaccessed)
                sta misc18                   ; ff39: 8d 00 50 (unaccessed)
                lda_abs arr20                ; ff3c: ad 6b 00 (unaccessed)
                sta misc20                   ; ff3f: 8d 00 58 (unaccessed)
                inc_abs ram43                ; ff42: ee 60 00 (unaccessed)
                jmp cod68                    ; ff45: 4c ce fb (unaccessed)
cod98           lda #0                       ; ff48: a9 00    (unaccessed)
                sta misc18                   ; ff4a: 8d 00 50 (unaccessed)
                lda_abs ram51                ; ff4d: ad 6c 00 (unaccessed)
                sta misc18                   ; ff50: 8d 00 50 (unaccessed)
                lda_abs ram52                ; ff53: ad 6d 00 (unaccessed)
                sta misc20                   ; ff56: 8d 00 58 (unaccessed)
                dec_abs ram43                ; ff59: ce 60 00 (unaccessed)
                dec_abs ram43                ; ff5c: ce 60 00 (unaccessed)
                jmp cod70                    ; ff5f: 4c fc fb (unaccessed)
sub50           lda #0                       ; ff62: a9 00    (unaccessed)
                sta_abs ram27                ; ff64: 8d 47 00 (unaccessed)
                lda_abs ram81                ; ff67: ad 98 00 (unaccessed)
                sta_abs ram82                ; ff6a: 8d 99 00 (unaccessed)
                and #%11111000               ; ff6d: 29 f8    (unaccessed)
                asl a                        ; ff6f: 0a       (unaccessed)
                rol_abs ram27                ; ff70: 2e 47 00 (unaccessed)
                asl a                        ; ff73: 0a       (unaccessed)
                rol_abs ram27                ; ff74: 2e 47 00 (unaccessed)
                sta_abs ram83                ; ff77: 8d 9a 00 (unaccessed)
                lda_abs ram27                ; ff7a: ad 47 00 (unaccessed)
                clc                          ; ff7d: 18       (unaccessed)
                adc #$20                     ; ff7e: 69 20    (unaccessed)
                sta_abs ram84                ; ff80: 8d 9b 00 (unaccessed)
                lda #$e0                     ; ff83: a9 e0    (unaccessed)
                sta_abs ram140               ; ff85: 8d ea 00 (unaccessed)
                sta_abs ram142               ; ff88: 8d ec 00 (unaccessed)
                lda_abs arr25                ; ff8b: ad 97 00 (unaccessed)
                and #%00000001               ; ff8e: 29 01    (unaccessed)
                beq +                        ; ff90: f0 08    (unaccessed)
                lda #$e1                     ; ff92: a9 e1    (unaccessed)
                sta_abs ram140               ; ff94: 8d ea 00 (unaccessed)
                sta_abs ram142               ; ff97: 8d ec 00 (unaccessed)
+               rts                          ; ff9a: 60       (unaccessed)
sub51           lda #0                       ; ff9b: a9 00    (unaccessed)
                sta_abs ram27                ; ff9d: 8d 47 00 (unaccessed)
                lda_abs ram81                ; ffa0: ad 98 00 (unaccessed)
                sta_abs ram82                ; ffa3: 8d 99 00 (unaccessed)
                and #%11111000               ; ffa6: 29 f8    (unaccessed)
                asl a                        ; ffa8: 0a       (unaccessed)
                rol_abs ram27                ; ffa9: 2e 47 00 (unaccessed)
                asl a                        ; ffac: 0a       (unaccessed)
                rol_abs ram27                ; ffad: 2e 47 00 (unaccessed)
                sta_abs ram83                ; ffb0: 8d 9a 00 (unaccessed)
                lda_abs ram27                ; ffb3: ad 47 00 (unaccessed)
                clc                          ; ffb6: 18       (unaccessed)
                adc #$20                     ; ffb7: 69 20    (unaccessed)
                sta_abs ram84                ; ffb9: 8d 9b 00 (unaccessed)
                lda #$e0                     ; ffbc: a9 e0    (unaccessed)
                sta_abs ram140               ; ffbe: 8d ea 00 (unaccessed)
                lda_abs arr25                ; ffc1: ad 97 00 (unaccessed)
                and #%00000001               ; ffc4: 29 01    (unaccessed)
                beq +                        ; ffc6: f0 0e    (unaccessed)
                lda_abs ram84                ; ffc8: ad 9b 00 (unaccessed)
                clc                          ; ffcb: 18       (unaccessed)
                adc #4                       ; ffcc: 69 04    (unaccessed)
                sta_abs ram84                ; ffce: 8d 9b 00 (unaccessed)
                lda #$e1                     ; ffd1: a9 e1    (unaccessed)
                sta_abs ram140               ; ffd3: 8d ea 00 (unaccessed)
+               rts                          ; ffd6: 60       (unaccessed)

                hex ff ff ff ff ff ff ff ff  ; ffd7           (unaccessed)
                hex ff ff ff ff ff ff ff ff  ; ffdf           (unaccessed)
                hex ff ff ff ff ff ff ff ff  ; ffe7           (unaccessed)
                hex ff ff ff ff ff ff ff ff  ; ffef           (unaccessed)
                hex ff ff 00                 ; fff7           (unaccessed)
NMIADDR         hex 00 f8                    ; fffa
RSTADDR         hex 00 e0                    ; fffc
BRKADDR         hex 2d fb                    ; fffe           (unaccessed)

