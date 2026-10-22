#!/usr/bin/env python3
"""Standalone byte verification for asm/banks/prg_08_09_tactical_war.asm.

Assembles the bank file in isolation: external references are stubbed with
equates, both segments are laid out back-to-back at $A000, and the 16KB
output is compared against rom/prg/prg_08.bin + rom/prg/prg_09.bin.
"""
from _bank_verify_lib import main

main("08", "09",
     stub_strategy="retry")
