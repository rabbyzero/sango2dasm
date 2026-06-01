#!/usr/bin/env python3
"""Fix forward reference issues by adding global address aliases and
removing conflicting proc-local label definitions."""

import re

INPUT = "asm/banks/prg_1f.asm"

with open(INPUT, "r") as f:
    content = f.read()

changes = []

# Labels that need forward-referenced access
forward_refs = [
    ("PpuCtrlNmiHelpers_NmiDisable", "$E768"),
    ("PpuMaskHelper_Clear", "$E74D"),
    ("WindowDisplaySetup_alt", "$F24B"),
    ("RamIntegrityTest_check", "$F43F"),
    ("IrqFlagWait", "$FB28"),
]

# 1. Add global aliases at top of file
alias_block = "\n;===============================================================================\n"
alias_block += "; Forward-declared internal entry points (for cross-proc access)\n"
alias_block += ";===============================================================================\n"

for label_name, addr in forward_refs:
    alias_block += f"{label_name:40s} = {addr}\n"

insert_marker = "BankXX_Func_A045 = $A045\n"
if insert_marker in content:
    content = content.replace(insert_marker, insert_marker + alias_block)
    changes.append("Added forward-declared aliases")

# 2. Remove proc-local label definitions (avoid duplicate symbol errors)
for label_name, addr in forward_refs:
    old_def = label_name + ":\n"
    if old_def in content:
        content = content.replace(old_def, "")
        changes.append(f"  Removed proc-local '{label_name}:' definition")

# 3. Revert :: namespace references back to plain names
ns_reverts = [
    ("PpuCtrlNmiHelpers::PpuCtrlNmiHelpers_NmiDisable", "PpuCtrlNmiHelpers_NmiDisable"),
    ("PpuMaskHelper::PpuMaskHelper_Clear", "PpuMaskHelper_Clear"),
    ("WindowDisplaySetup::WindowDisplaySetup_alt", "WindowDisplaySetup_alt"),
    ("RamIntegrityTest::RamIntegrityTest_check", "RamIntegrityTest_check"),
    ("ControllerReadBankRestore::IrqFlagWait", "IrqFlagWait"),
]

for old, new in ns_reverts:
    count = content.count(old)
    if count > 0:
        content = content.replace(old, new)
        changes.append(f"  {old} -> {new} ({count})")

# 4. Fix remaining @ references
at_fixes = [
    ("@loc_eded", "loc_eded"),
    ("@loc_ede2", "loc_ede2"),
    ("@pad_f076", "pad_f076"),
    ("@pad_f027", "pad_f027"),
]
for old, new in at_fixes:
    count = content.count(old)
    if count > 0:
        content = content.replace(old, new)
        changes.append(f"  {old} -> {new} ({count})")

with open(INPUT, "w") as f:
    f.write(content)

for c in changes:
    print(c)
print(f"\nWrote {len(content.splitlines())} lines to {INPUT}")
