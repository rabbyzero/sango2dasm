;===============================================================================
; 6502 CPU Registers and Zero Page Definitions
;===============================================================================

; PPU Registers
PPU_CTRL        = $2000
PPU_MASK        = $2001
PPU_STATUS      = $2002
PPU_OAM_ADDR    = $2003
PPU_OAM_DATA    = $2004
PPU_SCROLL      = $2005
PPU_ADDR        = $2006
PPU_DATA        = $2007

; APU and I/O Registers
APU_PULSE1_VOL  = $4000
APU_PULSE1_SWEEP = $4001
APU_PULSE1_LO   = $4002
APU_PULSE1_HI   = $4003
APU_PULSE2_VOL  = $4004
APU_PULSE2_SWEEP = $4005
APU_PULSE2_LO   = $4006
APU_PULSE2_HI   = $4007
APU_TRI_LINEAR  = $4008
APU_TRI_LO      = $400A
APU_TRI_HI      = $400B
APU_NOISE_VOL   = $400C
APU_NOISE_LO    = $400E
APU_NOISE_HI    = $400F
APU_DMC_FREQ    = $4010
APU_DMC_RAW     = $4011
APU_DMC_START   = $4012
APU_DMC_LEN     = $4013
APU_OAM_DMA     = $4014
APU_SND_CHN     = $4015
APU_JOY1        = $4016
APU_JOY2        = $4017
APU_FRAME       = $4017

; Namco-163 Registers
NAMCO_IRQ       = $4800
NAMCO_SOUND     = $4800
NAMCO_CTRL      = $F800

; Namco-163 PRG Bank Switching
; Writing to these addresses switches 8KB PRG banks
PRG_BANK_8000   = $F800
PRG_BANK_A000   = $FA00
PRG_BANK_C000   = $FC00
PRG_BANK_E000   = $FE00

;===============================================================================
; PPU Control Bits
;===============================================================================
PPU_CTRL_NMI        = %10000000  ; Enable NMI
PPU_CTRL_PPM        = %01000000  ; PPU master/slave
PPU_CTRL_SPR_8      = %00000000  ; 8x8 sprites
PPU_CTRL_SPR_16     = %00100000  ; 8x16 sprites
PPU_CTRL_BG_0       = %00000000  ; BG pattern table $0000
PPU_CTRL_BG_1       = %00001000  ; BG pattern table $1000
PPU_CTRL_SPR_0      = %00000000  ; SPR pattern table $0000
PPU_CTRL_SPR_1      = %00000100  ; SPR pattern table $1000
PPU_CTRL_INC_1      = %00000000  ; VRAM address +1
PPU_CTRL_INC_32     = %00000010  ; VRAM address +32
PPU_CTRL_NT_0       = %00000000  ; Nametable $2000
PPU_CTRL_NT_1       = %00000001  ; Nametable $2400
PPU_CTRL_NT_2       = %00000010  ; Nametable $2800
PPU_CTRL_NT_3       = %00000011  ; Nametable $2C00

;===============================================================================
; PPU Mask Bits
;===============================================================================
PPU_MASK_EMPHASIS_BLUE  = %00100000
PPU_MASK_EMPHASIS_GREEN = %00010000
PPU_MASK_EMPHASIS_RED   = %00001000
PPU_MASK_SPRITES_VISIBLE = %00000100
PPU_MASK_BG_VISIBLE     = %00000010
PPU_MASK_SPRITE_CLIP    = %00000001
PPU_MASK_BG_CLIP        = %00000010

;===============================================================================
; PPU Status Bits
;===============================================================================
PPU_STATUS_VBLANK     = %10000000
PPU_STATUS_SPRITE0    = %01000000
PPU_STATUS_OVERFLOW   = %00100000
PPU_STATUS_VRAM_WRITE = %00010000
