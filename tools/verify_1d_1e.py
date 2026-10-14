#!/usr/bin/env python3
"""Standalone byte verification for asm/banks/prg_1d_1e_menu_screens.asm.

Assembles the bank file in isolation: external references are stubbed with
equates, both segments are laid out back-to-back at $A000, and the 16KB
output is compared against rom/prg/prg_1d.bin + rom/prg/prg_1e.bin.
"""
from _bank_verify_lib import main

main("1d", "1e", stub_strategy="regex")
