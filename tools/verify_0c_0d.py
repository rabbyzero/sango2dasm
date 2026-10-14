#!/usr/bin/env python3
"""Standalone byte verification for asm/banks/prg_0c_0d_tactical_commands.asm.

Assembles the bank file in isolation: external references are stubbed with
equates, both segments are laid out back-to-back at $A000, and the 16KB
output is compared against rom/prg/prg_0c.bin + rom/prg/prg_0d.bin.
"""
from _bank_verify_lib import main

main("0c", "0d",
     stub_strategy="retry",
     stub_header="; RAM globals owned by other bank files (addresses per prg_0c_0d_tactical_commands.asm header)\n")
