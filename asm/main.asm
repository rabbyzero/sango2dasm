;===============================================================================
; Main.asm - Main entry point for Sangokushi 2 - Haou no Tairiku disassembly
; Namco-163 (Mapper 19)
;===============================================================================

.include "6502_registers.h"
.include "namco163.h"

;===============================================================================
; Global Variables
;===============================================================================

.segment "ZEROPAGE"
    zp_temp:        .res 2
    zp_ptr:         .res 2
    zp_index:       .res 1

.segment "BSS"
    ram_buffer:     .res 256

;===============================================================================
; Code - Bank 0x1F contains reset handler
;===============================================================================

.segment "CODE"

;-------------------------------------------------------------------------------
; Reset Handler
;-------------------------------------------------------------------------------
Reset:
    SEI
    CLD
    LDX #$FF
    TXS

    ; Wait for PPU warm-up
    LDA #3
@waitframes:
    BIT PPU_STATUS
    BNE @waitframes
    SEC
    SBC #1
    BNE @waitframes

    ; Clear RAM
    LDA #0
    TAY
:   STA $0000,Y
    STA $0100,Y
    STA $0300,Y
    STA $0400,Y
    STA $0500,Y
    STA $0600,Y
    STA $0700,Y
    INY
    BNE :-

    JSR PPU_Init
    JSR Mapper_Init
    JMP Main

;-------------------------------------------------------------------------------
; NMI Handler
;-------------------------------------------------------------------------------
NMI:
    PHA
    TXA
    PHA
    TYA
    PHA

    ; TODO: VBlank processing

    PLA
    TAY
    PLA
    TAX
    PLA
    BIT PPU_STATUS
    RTI

;-------------------------------------------------------------------------------
; IRQ Handler
;-------------------------------------------------------------------------------
IRQ:
    PHA
    TXA
    PHA
    TYA
    PHA

    ; TODO: Handle IRQ

    PLA
    TAY
    PLA
    TAX
    PLA
    RTI

;-------------------------------------------------------------------------------
; PPU Initialization
;-------------------------------------------------------------------------------
PPU_Init:
    LDA #0
    STA PPU_CTRL
    STA PPU_MASK
    STA PPU_SCROLL
    STA PPU_SCROLL
    RTS

;-------------------------------------------------------------------------------
; Namco-163 Mapper Initialization
;-------------------------------------------------------------------------------
Mapper_Init:
    switch_bank_8000 BANK_00
    switch_bank_A000 BANK_01
    switch_bank_C000 BANK_02
    LDA #$00
    STA NAMCO_IRQ_COUNTER
    RTS

;-------------------------------------------------------------------------------
; Main Entry
;-------------------------------------------------------------------------------
Main:
    ; TODO: Implement main game loop
Loop:
    BIT PPU_STATUS
    BPL Loop
    JMP Loop

;===============================================================================
; Interrupt Vectors (at $9FFA in PRG_SLOT0)
;===============================================================================

.segment "VECTORS"
    .addr NMI      ; $9FFA - NMI
    .addr Reset    ; $9FFC - Reset
    .addr IRQ      ; $9FFE - IRQ
