#!/usr/bin/env python3
"""Fix ca65 :: syntax errors - convert to proper namespace syntax."""

import re

INPUT = "asm/banks/prg_1f.asm"

with open(INPUT, "r") as f:
    content = f.read()

# 1. Remove :: from .proc declarations
content = content.replace(".proc Reset::", ".proc Reset")
content = content.replace(".proc NmiHandler::", ".proc NmiHandler")
content = content.replace(".proc IrqHandler::", ".proc IrqHandler")

# 2. Remove :: from label definitions inside procs
# (these are internal entry points that need ProcName::LabelName access)
replacements = [
    # (label_def, label_name)
    ("SoundInit_NamcoWrite::\n", "SoundInit_NamcoWrite:\n"),
    ("PpuMaskHelper_Clear::\n", "PpuMaskHelper_Clear:\n"),
    ("PpuCtrlNmiHelpers_NmiDisable::\n", "PpuCtrlNmiHelpers_NmiDisable:\n"),
    ("NametableFill1_PpuAddr::\n", "NametableFill1_PpuAddr:\n"),
    ("WindowDisplaySetup_alt::\n", "WindowDisplaySetup_alt:\n"),
    ("RamIntegrityTest_check::\n", "RamIntegrityTest_check:\n"),
]

for old, new in replacements:
    content = content.replace(old, new)

# 3. Update references to use ProcName::LabelName syntax
# Map: old_reference -> new_reference
ref_map = {
    # SoundInit_NamcoWrite (inside SoundInit proc)
    "JSR SoundInit_NamcoWrite": "JSR SoundInit::SoundInit_NamcoWrite",
    # PpuMaskHelper_Clear (inside PpuMaskHelper proc)
    "JSR PpuMaskHelper_Clear": "JSR PpuMaskHelper::PpuMaskHelper_Clear",
    # PpuCtrlNmiHelpers_NmiDisable (inside PpuCtrlNmiHelpers proc)
    "JSR PpuCtrlNmiHelpers_NmiDisable": "JSR PpuCtrlNmiHelpers::PpuCtrlNmiHelpers_NmiDisable",
    # NametableFill1_PpuAddr (inside NametableFill1 proc)
    "JSR NametableFill1_PpuAddr": "JSR NametableFill1::NametableFill1_PpuAddr",
    # WindowDisplaySetup_alt (inside WindowDisplaySetup proc)
    "JSR WindowDisplaySetup_alt": "JSR WindowDisplaySetup::WindowDisplaySetup_alt",
    # RamIntegrityTest_check (inside RamIntegrityTest proc)
    "JSR RamIntegrityTest_check": "JSR RamIntegrityTest::RamIntegrityTest_check",
    # Also fix JSR RamIntegrityTest_write and _verify (internal refs from MapperInitCtrlCheck)
    "JSR RamIntegrityTest_write": "JSR RamIntegrityTest::RamIntegrityTest_write",
    "JSR RamIntegrityTest_verify": "JSR RamIntegrityTest::RamIntegrityTest_verify",
}

ref_count = 0
for old, new in ref_map.items():
    count = content.count(old)
    if count > 0:
        content = content.replace(old, new)
        ref_count += count
        print(f"  {old} -> {new} ({count} occurrences)")

# 4. Fix duplicate base_ptr_lo/base_ptr_hi in State_DomesticAffairs
# Lines ~395-400 have duplicate definitions. Rename the second pair.
content = content.replace(
    "graphic_ptr_lo = $0A\ngraphic_ptr_hi = $0B\nbase_ptr_lo    = $0C\nbase_ptr_hi    = $0D",
    "graphic_ptr_lo = $0A\ngraphic_ptr_hi = $0B\nbase_ptr_lo2   = $0C\nbase_ptr_hi2   = $0D"
)

with open(INPUT, "w") as f:
    f.write(content)

print(f"\nFixed :: syntax ({ref_count} reference updates)")
print(f"Fixed duplicate base_ptr aliases")
print(f"Removed :: from .proc declarations and label definitions")
