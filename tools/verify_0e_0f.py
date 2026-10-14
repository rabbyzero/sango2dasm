#!/usr/bin/env python3
"""Standalone byte verification for asm/banks/prg_0e_0f_battle.asm.

Assembles the bank file in isolation: external references ($E000-$FFFF
bank-1F helpers, etc.) are stubbed with equates, both segments are laid
out back-to-back at $A000, and the 16KB output is compared against
rom/prg/prg_0e.bin + rom/prg/prg_0f.bin.
"""
from _bank_verify_lib import main

main("0e", "0f",
     stub_strategy="regex",
     external_ram=[
         "menu_cursor_col = $0424\n",
         "menu_cursor_page = $0425\n",
         "war_scene_id = $0500\n",
         "war_scene_phase = $0501\n",
     ])
