;===============================================================================
; ram_globals.h - Cross-Bank RAM Global Declarations
; Sangokushi 2 - Haou no Tairiku (J) / Namco-163 (Mapper 19)
;
; Every work cell here is read or written by more than one PRG bank, so it is
; declared exactly once, in this header, and referenced by name from the bank
; files. A bank file declares only its own cells, inside its own scope.
; Include from every bank:  .include "ram_globals.h"
;
; The guard makes repeated inclusion within one ca65 unit harmless, which is
; how asm/main.asm includes all 32 banks in a single pass.
;
; Column owner: the bank that initializes or services the cell. Function-local
; aliases of the same cell stay in the bank that uses them.
; Full RAM map: code/cpu_ram_map.md, per-bank equate dump: code/ram_equates_full.txt
;
; Naming convention:
;   addr_*   zero-page cells serviced by the bank $1F engine ($0050-$00FF)
;   map_*    field-map scroll and cache state
;   war_*    war/battle scene handoff state ($0500-$0513)
;   scene_*  scene-callback mailbox between the mode layers
;   sram_*   battery-backed $6000-$6FFF save region
;===============================================================================

.ifndef GUARD_RAM_GLOBALS_H
GUARD_RAM_GLOBALS_H = 1

;-------------------------------------------------------------------------------
; $0050-$0058 Engine scratch (owner: bank $1F)
;-------------------------------------------------------------------------------
addr_rng_index               = $0050  ; RNG table index
addr_trampoline_saved_bank   = $0058  ; PRG bank number saved across a trampoline call

;-------------------------------------------------------------------------------
; $0078-$007E State machine, NMI and palette service (owner: bank $1F)
;-------------------------------------------------------------------------------
addr_sub_state               = $0078  ; Sub-state within each major state
addr_game_state              = $007A  ; State counter (0-14), indexes VectorTable
addr_sprite_count            = $007C  ; Current OAM slot index
addr_pal_upload_arm          = $007D  ; Palette-upload armed latch (NmiSubDispatch $EE53 tests it, PaletteUpload clears it at $E71B)
addr_nmi_ctrl                = $007E  ; NMI sub-dispatch control bits

;-------------------------------------------------------------------------------
; $0081-$0086 Controller polling (owner: bank $1F)
;-------------------------------------------------------------------------------
addr_pad1_edge               = $0081  ; Pad 1 newly-pressed buttons
addr_pad2_edge               = $0082  ; Pad 2 newly-pressed buttons
addr_pad1_raw                = $0083  ; Pad 1 raw button state
addr_pad1_prev               = $0084  ; Pad 1 previous frame state
addr_pad2_raw                = $0085  ; Pad 2 raw button state
addr_pad2_prev               = $0086  ; Pad 2 previous frame state

;-------------------------------------------------------------------------------
; $0087-$008A Palette animation (owner: bank $1F)
;-------------------------------------------------------------------------------
addr_anim_direction          = $0087  ; Palette animation direction
addr_anim_step               = $0088  ; Palette animation step
addr_anim_speed              = $0089  ; Palette animation speed
addr_anim_counter            = $008A  ; Palette animation tick counter

;-------------------------------------------------------------------------------
; $008B-$009D PPU mirrors, scroll and field-map cursor state (owner: bank $1F)
;-------------------------------------------------------------------------------
addr_ppu_ctrl_ram            = $008B  ; RAM copy of PPU control ($2000)
addr_ppu_mask_ram            = $008C  ; RAM copy of PPU mask ($2001)
addr_scroll_x                = $008E  ; Scroll X position
addr_scroll_x_hi             = $008F  ; Scroll X high (nametable bit)
addr_scroll_y                = $0090  ; Scroll Y position
addr_scroll_y_hi             = $0091  ; Scroll Y high
map_row_cache                = $0094  ; Palette-row cache; $FF forces a palette reload
map_col_cache                = $0095  ; Scene-column cache; $FF forces an overlay reload
addr_display_mode            = $0098  ; Display mode parameter
addr_display_mode_h          = $0099  ; Display mode parameter (high)
map_dir_flags                = $009C  ; Last field-map scroll step (7=E, 6=W, 4=N, 5=S)
map_dir_prev                 = $009D  ; Previous-frame copy, snapshotted at $F95E

;-------------------------------------------------------------------------------
; $00AE-$00B5 CHR bank numbers, held in RAM and pushed to the Namco-163 CHR
; registers by bank $1F ChrBankSwitch ($F206)
;-------------------------------------------------------------------------------
addr_chr_bank_0              = $00AE  ; CHR bank 0 ($8000)
addr_chr_bank_1              = $00AF  ; CHR bank 1 ($8800)
addr_chr_bank_2              = $00B0  ; CHR bank 2 ($9000)
addr_chr_bank_3              = $00B1  ; CHR bank 3 ($9800)
addr_chr_bank_4              = $00B2  ; CHR bank 4 ($A000)
addr_chr_bank_5              = $00B3  ; CHR bank 5 ($A800)
addr_chr_bank_6              = $00B4  ; CHR bank 6 ($B000)
addr_chr_bank_7              = $00B5  ; CHR bank 7 ($B800)

;-------------------------------------------------------------------------------
; $0400-$04D8 Scene, menu and army context, shared by the tactical ($08-$0D),
; strategy ($1B-$1C), command ($1D-$1E) and display ($17-$18) layers
;-------------------------------------------------------------------------------
scene_callback_id            = $0400  ; Scene callback id queued for the next frame ($0D = post-battle)
scene_callback_st            = $0401  ; Scene callback state counter
province_idx                 = $0402  ; Current province index (map bounds calc, province data window)
menu_scroll_state            = $0420  ; Menu scroll / render state
menu_cursor_col              = $0424  ; Menu cursor column (0-based, stepped by bank $1F MenuStep)
menu_cursor_page             = $0425  ; Menu cursor page (0-based; the strategy dialog reads it as the cursor row at $D64A)
anim_ppu_ptr_lo              = $0470  ; Animation PPU pointer lo
anim_ppu_ptr_hi              = $0471  ; Animation PPU pointer hi
map_scroll_ptr_lo            = $0472  ; Map scroll source pointer lo
map_scroll_ptr_hi            = $0473  ; Map scroll source pointer hi
army_slot_base               = $04D8  ; Army group slot array base, 8 bytes = two slots (+0 owner / target officer index, +1 target X, +2 target Y, +3 timer; +4..+7 the second group); $FF = empty slot

;-------------------------------------------------------------------------------
; $0500-$0513 War scene handoff (owner: banks $08/$09, posted by the battle
; engine $0E/$0F and read back by the bank $1F map scroll restore)
;-------------------------------------------------------------------------------
war_scene_id                 = $0500  ; Battle scene / command id (state select)
war_scene_phase              = $0501  ; Battle scene phase / state index
map_scroll_y_hi              = $0511  ; Map scroll Y high
map_scroll_x_hi              = $0513  ; Map scroll X high

;-------------------------------------------------------------------------------
; $6F8B Battery-backed SRAM
;-------------------------------------------------------------------------------
sram_request_mailbox         = $6F8B  ; Strategy-layer request mailbox: $00 idle, $01 consumed ack, $F8 province transfer (needs an answer), $F9 absorb sweep, $FA province sweep, $FB officer record deleted, $FC officer swapped in, $FD province conquered (computer defender), $FE war pending (human defender), $FF turn exhausted. Posted by the $08/$09 and $0A/$0B engines, consumed by prg_19_1a StrategyRequestDispatch $C773

.endif ; GUARD_RAM_GLOBALS_H
