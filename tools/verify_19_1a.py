#!/usr/bin/env python3
"""Standalone byte verification for asm/banks/prg_19_1a.asm.

Assembles the bank file in isolation: external references ($E000-$FFFF
bank-1F helpers, etc.) are stubbed with equates, both segments are laid
out back-to-back at $A000, and the 16KB output is compared against
rom/prg/prg_19.bin + rom/prg/prg_1a.bin.
"""
from _bank_verify_lib import main

main("19", "1a", stub_strategy="regex")
