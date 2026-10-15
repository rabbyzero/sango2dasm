#!/usr/bin/env python3
"""Standalone byte verification for asm/banks/prg_1b_1c_strategy_mode.asm.

Assembles the bank file in isolation: external references ($E000-$FFFF
bank-1F helpers, etc.) are stubbed with equates, both segments are laid
out back-to-back at $A000, and the 16KB output is compared against
rom/prg/prg_1b.bin + rom/prg/prg_1c.bin.
"""
from _bank_verify_lib import main

main("1b", "1c", stub_strategy="regex")
