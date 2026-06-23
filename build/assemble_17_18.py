#!/usr/bin/env python3
"""Assemble prg_17_18.asm standalone and compare with raw binaries."""
import subprocess
import sys
import os

os.chdir('/home/zero/project/sango2dasm')

# Create a minimal wrapper that includes the bank file
wrapper = """
.segment "CODE_BANK17"
.include "prg_17_18.asm"
"""

# Assemble directly
result = subprocess.run([
    '/home/zero/.local/bin/ca65',
    '-I', 'include',
    '-I', 'asm/banks',
    'asm/banks/prg_17_18.asm',
    '-o', 'build/test_17_18_new.o',
    '-l', 'build/test_17_18_new.lst'
], capture_output=True, text=True)

print("STDOUT:", result.stdout)
print("STDERR:", result.stderr)
print("Return code:", result.returncode)
