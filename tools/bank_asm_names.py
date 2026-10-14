"""Canonical asm/banks filenames (bank number -> descriptive filename).

The bank files are named data_NN_<contents>.asm / prg_NN_NN_<function>.asm;
tools that resolve a bank to its file must go through this table so the
names stay in one place.
"""
import os

DATA_BANK_ASM = {
    0x00: 'data_00_terrain.asm',
    0x01: 'data_01_bg_and_sprites.asm',
    0x02: 'data_02_sound.asm',
    0x03: 'data_03_terrain.asm',
    0x04: 'data_04_terrain.asm',
    0x05: 'data_05_terrain.asm',
    0x06: 'data_06_placement_and_scroll.asm',
    0x07: 'data_07_blank.asm',
    0x10: 'data_10_seed.asm',
    0x11: 'data_11_officer.asm',
    0x12: 'data_12_menu_display.asm',
    0x13: 'data_13_menu_display.asm',
    0x14: 'data_14_sprite_set_a.asm',
    0x15: 'data_15_sprite_set_b.asm',
    0x16: 'data_16_menu_oam.asm',
}

PRG_PAIR_ASM = {
    '08_09': 'prg_08_09_tactical_war.asm',
    '0a_0b': 'prg_0a_0b_strategy_ai.asm',
    '0c_0d': 'prg_0c_0d_tactical_commands.asm',
    '0e_0f': 'prg_0e_0f_battle.asm',
    '17_18': 'prg_17_18_display.asm',
    '19_1a': 'prg_19_1a_event_scenes.asm',
    '1b_1c': 'prg_1b_1c_map_screen.asm',
    '1d_1e': 'prg_1d_1e_menu_screens.asm',
    '1f': 'prg_1f_boot.asm',
}


def data_asm_name(bank):
    return DATA_BANK_ASM[bank]


def prg_asm_name(pair):
    return PRG_PAIR_ASM[pair]


def data_asm_path(bank, root=''):
    return os.path.join(root, 'asm', 'banks', data_asm_name(bank))


def prg_asm_path(pair, root=''):
    return os.path.join(root, 'asm', 'banks', prg_asm_name(pair))
