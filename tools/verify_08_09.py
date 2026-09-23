#!/usr/bin/env python3
"""Standalone byte verification for asm/banks/prg_08_09.asm.

Assembles the bank file in isolation: external references are stubbed with
equates, both segments are laid out back-to-back at $A000, and the 16KB
output is compared against rom/prg/prg_08.bin + rom/prg/prg_09.bin.
"""
from _bank_verify_lib import main

main("08", "09",
     stub_strategy="retry",
     stub_header="; RAM globals owned by other bank files (addresses per prg_08_09.asm header)\n",
     external_ram=[
         "menu_cursor_col = $0424\n",
         "menu_cursor_page = $0425\n",
         "army_slot_base = $04D8\n",
         "sram_game_start_flag = $6F8B\n",
     ])
