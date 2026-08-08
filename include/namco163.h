;===============================================================================
; Namco-163 Mapper Definitions
; Sangokushi 2 - Haou no Tairiku uses Namco-163 (Mapper 19)
;===============================================================================

.ifndef GUARD_NAMCO163_H
GUARD_NAMCO163_H = 1

; Namco-163 PRG ROM Configuration
; Total PRG ROM: 32 banks x 8KB = 256KB
; Banks are 8KB each, mapped to $8000-$FFFF

; Namco-163 CHR Bank Registers (1KB CHR windows for nametable tile banks)
NAMCO_CHR_BANK_0  = $C000  ; CHR bank 0 - NT slot 0
NAMCO_CHR_BANK_1  = $C800  ; CHR bank 1 - NT slot 1
NAMCO_CHR_BANK_2  = $D000  ; CHR bank 2 - NT slot 2
NAMCO_CHR_BANK_3  = $D800  ; CHR bank 3 - NT slot 3

; Namco-163 CHR Bank Registers - Primary Set (8 x 1KB pattern table slots)
NAMCO163_CHR_0    = $8000  ; CHR slot 0 -> PPU $0000-$03FF
NAMCO163_CHR_1    = $8800  ; CHR slot 1 -> PPU $0400-$07FF
NAMCO163_CHR_2    = $9000  ; CHR slot 2 -> PPU $0800-$0BFF
NAMCO163_CHR_3    = $9800  ; CHR slot 3 -> PPU $0C00-$0FFF
NAMCO163_CHR_4    = $A000  ; CHR slot 4 -> PPU $1000-$13FF
NAMCO163_CHR_5    = $A800  ; CHR slot 5 -> PPU $1400-$17FF
NAMCO163_CHR_6    = $B000  ; CHR slot 6 -> PPU $1800-$1BFF
NAMCO163_CHR_7    = $B800  ; CHR slot 7 -> PPU $1C00-$1FFF

; Namco-163 PRG Bank Switching Registers (8KB PRG windows)
NAMCO_PRG_8000    = $E000  ; Switch PRG bank at $8000-$9FFF
NAMCO_PRG_A000    = $E800  ; Switch PRG bank at $A000-$BFFF (ORA #$C0 to disable CHR-RAM)
NAMCO_PRG_C000    = $F000  ; Switch PRG bank at $C000-$DFFF
NAMCO_PRG_8000_ALT = $F800 ; Alternate/mirror for PRG $8000; also Namco control register

; Namco-163 Control Register
NAMCO_CTRL        = $F800  ; Sound/IRQ control (same address as PRG_8000_ALT)

; Namco-163 Address/Control Port ($4800)
; Shared by sound and IRQ subsystems: write register index here first
NAMCO163_ADDR     = $4800  ; Namco-163 register address port
NAMCO_IRQ_COUNTER = $4800  ; IRQ counter (alias)
NAMCO_SOUND_ADDR  = $4800  ; Sound register address (alias)

; Namco-163 Data Ports ($5000/$5800)
; After writing address to $4800, read/write data through these
NAMCO163_DATA_LO  = $5000  ; Data port low byte
NAMCO163_DATA_HI  = $5800  ; Data port high byte
; Sound aliases
NAMCO_SOUND_DATA_LO = $5000  ; Sound data low byte
NAMCO_SOUND_DATA_HI = $5800  ; Sound data high byte
; IRQ aliases
NAMCO_IRQ_LO      = $5000  ; IRQ counter low byte
NAMCO_IRQ_HI      = $5800  ; IRQ counter high byte

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

.endif ; GUARD_NAMCO163_H

