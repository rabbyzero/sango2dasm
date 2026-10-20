#!/usr/bin/env python3
"""Standalone byte verification for asm/banks/prg_17_18_duel_and_display.asm.

Assembles the bank pair in isolation: external references are stubbed with equates,
both segments are laid out back-to-back at $A000, and the 16KB output is compared
against rom/prg/prg_17.bin + rom/prg/prg_18.bin.
"""
from _bank_verify_lib import main

main("17", "18", stub_strategy="regex")
