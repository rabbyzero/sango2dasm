;===============================================================================
; macros.h - Common 6502 Macros
;===============================================================================

;-------------------------------------------------------------------------------
; Wait for VBlank
;-------------------------------------------------------------------------------
.macro wait_vblank
    :
    BIT PPU_STATUS
    BPL :-
.endmacro

;-------------------------------------------------------------------------------
; Set PPU Address
;-------------------------------------------------------------------------------
.macro set_ppu_addr, addr
    LDA #>addr
    STA PPU_ADDR
    LDA #<addr
    STA PPU_ADDR
.endmacro

;-------------------------------------------------------------------------------
; Write to PPU
;-------------------------------------------------------------------------------
.macro ppu_write, value
    LDA #value
    STA PPU_DATA
.endmacro

;-------------------------------------------------------------------------------
; Copy block of data to PPU
; Expects: X = low byte of source, Y = high byte of source
;          A = length
;-------------------------------------------------------------------------------
.macro ppu_copy, dest_addr
    set_ppu_addr dest_addr
    :
    LDA (zp_ptr),Y
    STA PPU_DATA
    INY
    BNE :-
    INC zp_ptr+1
    DEC A
    BNE :--
.endmacro

;-------------------------------------------------------------------------------
; DMA Sprite Data
;-------------------------------------------------------------------------------
.macro dma_sprites, addr
    LDA #>addr
    STA APU_OAM_DMA
.endmacro

;-------------------------------------------------------------------------------
; Switch PRG Bank (Namco-163)
;-------------------------------------------------------------------------------
.macro switch_prg_bank, slot, bank
    LDA #bank
    .if slot == $8000
        STA NAMCO_PRG_8000
    .elseif slot == $A000
        STA NAMCO_PRG_A000
    .elseif slot == $C000
        STA NAMCO_PRG_C000
    .elseif slot == $E000
        STA NAMCO_PRG_E000
    .endif
.endmacro
