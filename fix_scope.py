#!/usr/bin/env python3
"""Fix ca65 cross-proc scoping issues for @-labels and undefined symbols."""

import re

INPUT = "asm/banks/prg_1f.asm"

with open(INPUT, "r") as f:
    content = f.read()

changes = []

# ==========================================================================
# 1. Convert @sub_state_* to non-@ labels (cross-proc references)
#    These labels are defined in NmiHandler but referenced from IrqHandler
# ==========================================================================
sub_state_labels = [
    "@sub_state_exit_irq",
    "@sub_state_1", "@sub_state_1a", "@sub_state_1b",
    "@sub_state_1c", "@sub_state_1d",
    "@sub_state_2", "@sub_state_3", "@sub_state_4",
    "@sub_state_5", "@sub_state_6", "@sub_state_7",
    "@sub_state_8", "@sub_state_9",
    "@sub_state_10", "@sub_state_11",
]

for label in sub_state_labels:
    non_at = label.replace("@", "")  # e.g., "sub_state_exit_irq"
    count = content.count(label)
    if count > 0:
        content = content.replace(label, non_at)
        changes.append(f"  {label} -> {non_at} ({count} occurrences)")

# ==========================================================================
# 2. Fix cross-proc @loc references
#    @loc_f8af: defined in NmiHandler, referenced from NmiScrollMode
#    @loc_e74f: defined in PpuMaskHelper, may be referenced from outside
#    @loc_e770: defined in PpuCtrlNmiHelpers, may be referenced from outside
#    @loc_eded: check scope
#    @loc_ede2: check scope
# ==========================================================================

# @loc_f8af is referenced from NmiScrollMode (different proc)
# Convert to non-@ and use namespace, OR just make non-@
# Since it's a simple label, convert to non-@
content = content.replace("@loc_f8af", "loc_f8af")
changes.append("  @loc_f8af -> loc_f8af (cross-proc)")

# @loc_e74f inside PpuMaskHelper - check if referenced from outside
# It's a local branch target, should be within scope
# @loc_e770 inside PpuCtrlNmiHelpers - same
# These might be referenced from outside due to .endproc placement
# Let's check and convert if needed
content = content.replace("@loc_e74f", "loc_e74f")
content = content.replace("@loc_e770", "loc_e770")
changes.append("  @loc_e74f, @loc_e770 -> non-@ (possible cross-proc)")

# @loc_eded - might be inside MenuItemLookup, referenced from outside
content = content.replace("@loc_eded", "loc_eded")
changes.append("  @loc_eded -> loc_eded")

# @loc_ede2 - check if it's cross-proc
content = content.replace("@loc_ede2", "loc_ede2")
changes.append("  @loc_ede2 -> loc_ede2")

# ==========================================================================
# 3. Fix @pad labels that might be in wrong scope
#    Gap bytes between procs should use non-@ labels
# ==========================================================================
pad_labels = [
    "@pad_e842", "@pad_ef70", "@pad_f027", "@pad_f076",
    "@pad_f091", "@pad_f421", "@pad_fabe", "@pad_fad4",
    "@pad_ff9a", "@pad_ffd6",
]
for pad in pad_labels:
    non_at = pad.replace("@", "")
    content = content.replace(pad, non_at)
    changes.append(f"  {pad} -> {non_at}")

# ==========================================================================
# 4. Define SpriteHide label at $E830
#    SpriteBufferInit RTS is at $E82F, code after is SpriteHide
#    Need to close SpriteBufferInit before $E830 and define SpriteHide
# ==========================================================================
# Find the RTS at $E82F and insert .endproc + SpriteHide label after it
old_sprite = "  RTS                       ; $E82F: 60\n  LDX $007C"
new_sprite = "  RTS                       ; $E82F: 60\n.endproc\n\nSpriteHide:\n  LDX $007C"
if old_sprite in content:
    content = content.replace(old_sprite, new_sprite)
    changes.append("  Defined SpriteHide label after SpriteBufferInit .endproc")
else:
    changes.append("  WARNING: Could not find SpriteBufferInit RTS for SpriteHide")

# ==========================================================================
# 5. Fix IrqFlagWait - inside ControllerReadBankRestore, referenced from outside
# ==========================================================================
content = content.replace(
    "JSR IrqFlagWait",
    "JSR ControllerReadBankRestore::IrqFlagWait"
)
changes.append("  JSR IrqFlagWait -> JSR ControllerReadBankRestore::IrqFlagWait")

# Also fix self-reference inside ControllerReadBankRestore
# (IrqFlagWait references itself with BNE IrqFlagWait - that's fine as-is)

# ==========================================================================
# 6. Fix remaining unnamespaced cross-proc references
#    These were supposed to be fixed by fix_syntax.py but may have been missed
# ==========================================================================
# Map: function_name -> enclosing_proc_name
cross_proc_funcs = {
    "NametableFill1_PpuAddr": "NametableFill1",
    "PpuMaskHelper_Clear": "PpuMaskHelper",
    "PpuCtrlNmiHelpers_NmiDisable": "PpuCtrlNmiHelpers",
    "WindowDisplaySetup_alt": "WindowDisplaySetup",
    "SoundInit_NamcoWrite": "SoundInit",
    "RamIntegrityTest_check": "RamIntegrityTest",
    "RamIntegrityTest_write": "RamIntegrityTest",
    "RamIntegrityTest_verify": "RamIntegrityTest",
}

for func, proc in cross_proc_funcs.items():
    # Find JSR/JMP references that don't already have :: prefix
    pattern = r'((?:JSR|JMP)\s+)' + re.escape(func) + r'\b'
    namespaced = proc + "::" + func

    def replace_ref(m):
        prefix = m.group(1)
        # Don't replace if already namespaced
        full = m.group(0)
        if "::" in full:
            return full
        return prefix + namespaced

    new_content, count = re.subn(pattern, replace_ref, content)
    if count > 0:
        content = new_content
        changes.append(f"  {func} -> {namespaced} ({count} additional refs)")

# ==========================================================================
# Write output
# ==========================================================================
with open(INPUT, "w") as f:
    f.write(content)

for c in changes:
    print(c)
print(f"\nWrote {len(content.splitlines())} lines to {INPUT}")
