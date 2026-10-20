;===============================================================================
; Include every PRG bank: code pairs as prg_NN_NN_<function>.asm, the
; $8000-window data banks (see code/bank_switch_map.md 5.2) as
; data_NN_<contents>.asm
;===============================================================================

.include "data_00_terrain.asm"
.include "data_01_bg_and_sprites.asm"
.include "data_02_sound.asm"
.include "data_03_terrain.asm"
.include "data_04_terrain.asm"
.include "data_05_terrain.asm"
.include "data_06_placement_and_scroll.asm"
.include "data_07_blank.asm"
.include "prg_08_09_tactical_war.asm"
.include "prg_0a_0b_strategy_ai.asm"
.include "prg_0c_0d_tactical_commands.asm"
.include "prg_0e_0f_battle.asm"
.include "data_10_seed.asm"
.include "data_11_officer.asm"
.include "data_12_menu_display.asm"
.include "data_13_menu_display.asm"
.include "data_14_sprite_set_a.asm"
.include "data_15_sprite_set_b.asm"
.include "data_16_menu_oam.asm"
.include "prg_17_18_duel_and_display.asm"
.include "prg_19_1a_event_scenes.asm"
.include "prg_1b_1c_strategy_mode.asm"
.include "prg_1d_1e_menu_screens.asm"
.include "prg_1f_boot.asm"

