;===============================================================================
; Namco-163 Mapper Definitions
; Sangokushi 2 - Haou no Tairiku uses Namco-163 (Mapper 19)
;===============================================================================

; Namco-163 PRG ROM Configuration
; Total PRG ROM: 32 banks x 8KB = 256KB
; Banks are 8KB each, mapped to $8000-$FFFF

; Bank switching registers (write-only)
NAMCO_PRG_8000    = $F800  ; Switch PRG bank at $8000-$9FFF
NAMCO_PRG_A000    = $FA00  ; Switch PRG bank at $A000-$BFFF
NAMCO_PRG_C000    = $FC00  ; Switch PRG bank at $C000-$DFFF
NAMCO_PRG_E000    = $FE00  ; Switch PRG bank at $E000-$FFFF (usually fixed)

; Namco-163 Control Register (same as PRG_8000)
; NAMCO_CTRL = $F800  ; Defined above as NAMCO_PRG_8000

; Namco-163 IRQ Register
NAMCO_IRQ_COUNTER = $4800  ; IRQ counter
NAMCO_IRQ_LATCH   = $5000  ; IRQ latch value

; Namco-163 Sound Registers (if used)
NAMCO_SOUND_ADDR  = $4800  ; Sound register address
NAMCO_SOUND_DATA  = $4800  ; Sound register data

; Number of PRG banks
NUM_PRG_BANKS     = 32

; Bank indices
BANK_00           = $00
BANK_01           = $01
BANK_02           = $02
BANK_03           = $03
BANK_04           = $04
BANK_05           = $05
BANK_06           = $06
BANK_07           = $07
BANK_08           = $08
BANK_09           = $09
BANK_0A           = $0A
BANK_0B           = $0B
BANK_0C           = $0C
BANK_0D           = $0D
BANK_0E           = $0E
BANK_0F           = $0F
BANK_10           = $10
BANK_11           = $11
BANK_12           = $12
BANK_13           = $13
BANK_14           = $14
BANK_15           = $15
BANK_16           = $16
BANK_17           = $17
BANK_18           = $18
BANK_19           = $19
BANK_1A           = $1A
BANK_1B           = $1B
BANK_1C           = $1C
BANK_1D           = $1D
BANK_1E           = $1E
BANK_1F           = $1F

;===============================================================================
; Bank Switching Macros
;===============================================================================

.macro switch_bank_8000 bank
    LDA #bank
    STA NAMCO_PRG_8000
.endmacro

.macro switch_bank_A000 bank
    LDA #bank
    STA NAMCO_PRG_A000
.endmacro

.macro switch_bank_C000 bank
    LDA #bank
    STA NAMCO_PRG_C000
.endmacro

.macro switch_bank_E000 bank
    LDA #bank
    STA NAMCO_PRG_E000
.endmacro
