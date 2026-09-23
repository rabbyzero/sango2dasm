#!/usr/bin/env python3
"""Standalone byte verification for asm/banks/prg_0a_0b.asm.

Assembles the bank file in isolation: external references are stubbed with
equates, both segments are laid out back-to-back at $A000, and the 16KB
output is compared against rom/prg/prg_0a.bin + rom/prg/prg_0b.bin.
"""
from _bank_verify_lib import main

main("0a", "0b",
     stub_strategy="retry",
     stub_header="; RAM globals owned by other bank files\n",
     external_ram=[
         "sram_game_start_flag = $6F8B\n",
     ])
