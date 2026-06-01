#!/usr/bin/env python3
"""Fix remaining JMP/branch hex targets, insert gap bytes, and balance .proc/.endproc."""

import re

INPUT = "asm/banks/prg_1f.asm"

with open(INPUT, "r") as f:
    lines = f.readlines()

changes = []

# ==========================================================================
# 1. Add BankXX_Func_A012 alias
# ==========================================================================
for i, line in enumerate(lines):
    if line.strip() == "BankXX_Func_A00F = $A00F":
        lines.insert(i + 1, "BankXX_Func_A012 = $A012\n")
        changes.append("Added BankXX_Func_A012 alias")
        break

# ==========================================================================
# 2. JMP hex -> label mapping
# ==========================================================================
jmp_map = {
    "$A006": "BankXX_Func_A006",
    "$A000": "BankXX_Func_A000",
    "$A012": "BankXX_Func_A012",
    "$FBA4": "@sub_state_1",
    "$FBCE": "@sub_state_1a",
    "$FBFC": "@sub_state_1b",
    "$FC2A": "@sub_state_1c",
    "$FC58": "@sub_state_1d",
    "$FC8B": "@sub_state_2",
    "$FD2A": "@sub_state_3",
    "$FD95": "@sub_state_4",
    "$FDF4": "@sub_state_5",
    "$FE03": "@sub_state_6",
    "$FE69": "@sub_state_7",
    "$FE96": "@sub_state_8",
    "$FECD": "@sub_state_9",
    "$FF31": "@sub_state_10",
    "$FF48": "@sub_state_11",
    "$F1C0": "@loc_f1c0",
    "$F1C4": "@loc_f1c4",
    "$F34A": "@loc_f34a",
    "$F8AF": "@loc_f8af",
    "$E9C2": "@loc_e9c2",
    "$EC93": "@loc_ec93",
    "$EDE2": "@loc_ede2",
    "$EE60": "@loc_ee60",
    "$F0F7": "@loc_f0f7",
    "$F272": "@loc_f272",
    "$F41E": "@dead_loop_f41e",
}

jmp_count = 0
for i, line in enumerate(lines):
    m = re.match(r'^(\s+JMP\s+)(\$[0-9A-F]{4})(\s+;.*)$', line.rstrip('\n'))
    if m:
        prefix, addr, suffix = m.groups()
        if addr in jmp_map:
            lines[i] = prefix + jmp_map[addr] + suffix + "\n"
            jmp_count += 1
changes.append(f"JMP replacements: {jmp_count}")

# ==========================================================================
# 3. Branch hex -> label mapping (all targets)
# ==========================================================================
branch_map = {
    "$FB92": "@sub_state_exit_irq",
    "$FBCE": "@sub_state_1a",
    "$E842": "@pad_e842",
    "$EF70": "@pad_ef70",
    "$F027": "@pad_f027",
    "$F076": "@pad_f076",
    "$F091": "@pad_f091",
    "$F421": "@pad_f421",
    "$FABE": "@pad_fabe",
    "$FAD4": "@pad_fad4",
    "$FF9A": "@pad_ff9a",
    "$FFD6": "@pad_ffd6",
}

branch_count = 0
for i, line in enumerate(lines):
    m = re.match(r'^(\s+(?:BEQ|BNE|BCS|BCC|BMI|BPL|BVC|BVS)\s+)(\$[0-9A-F]{4})(\s+;.*)$', line.rstrip('\n'))
    if m:
        prefix, addr, suffix = m.groups()
        if addr in branch_map:
            lines[i] = prefix + branch_map[addr] + suffix + "\n"
            branch_count += 1
changes.append(f"Branch replacements: {branch_count}")

# ==========================================================================
# 4. Insert @-labels at JMP target addresses (within functions)
# ==========================================================================
label_insertions = [
    ("$E9C2", "@loc_e9c2"),
    ("$EC93", "@loc_ec93"),
    ("$EDE2", "@loc_ede2"),
    ("$EE60", "@loc_ee60"),
    ("$F0F7", "@loc_f0f7"),
    ("$F272", "@loc_f272"),
    ("$F41E", "@dead_loop_f41e"),
]

for addr, label in label_insertions:
    for i, line in enumerate(lines):
        comment_match = re.search(r';\s+' + re.escape(addr) + r':\s+[0-9A-F]{2}', line)
        if comment_match:
            lines.insert(i, label + ":\n")
            changes.append(f"Inserted {label}: before line {i+1} ({addr})")
            break
    else:
        changes.append(f"WARNING: Could not find address {addr}")

# ==========================================================================
# 5. Insert gap bytes with labels between functions
#    Uses comment header text as anchor, searches from bottom to avoid
#    line number shifts affecting later insertions.
# ==========================================================================
gap_defs = [
    # (header_comment_text, label, addr_str, include_E841_byte)
    ("; Padding2 ($FFD7-$FFF9)",              "@pad_ffd6",  "$FFD6", False),
    ("; ScrollCalcB ($FF9B-$FFD5)",           "@pad_ff9a",  "$FF9A", False),
    ("; NmiScrollMode ($FAD5-$FB09)",         "@pad_fad4",  "$FAD4", False),
    ("; PaletteSwapB ($FABF-$FAD3)",          "@pad_fabe",  "$FABE", False),
    ("; RamIntegrityTest ($F422-$F475)",      "@pad_f421",  "$F421", False),
    ("; SpriteOamWriterScroll ($F092-$F1AB)", "@pad_f091",  "$F091", False),
    ("; PpuAttrTileWriteAlt ($F028-$F075)",   "@pad_f076",  "$F076", False),
    ("; PpuAttrTileWrite ($EFC0-$F026)",      "@pad_f027",  "$F027", False),
    ("; PpuSpriteTileWrite ($EF71-$EFBF)",    "@pad_ef70",  "$EF70", False),
    ("; RandomBelow100 ($E843-$E849)",        "@pad_e842",  "$E842", True),
]

for header_text, label, addr, include_e841 in gap_defs:
    header_idx = None
    for i, line in enumerate(lines):
        if header_text in line:
            header_idx = i
            break

    if header_idx is None:
        changes.append(f"WARNING: Could not find header '{header_text}'")
        continue

    # Find start of comment block (separator line above header)
    block_start = header_idx
    if header_idx > 0 and lines[header_idx - 1].startswith(";---"):
        block_start = header_idx - 1

    # Build insertion lines
    insert_lines = []
    if include_e841:
        insert_lines.append("  .byte $00                 ; $E841: 00\n")
    insert_lines.append(label + ":\n")
    insert_lines.append(f"  .byte $00                 ; {addr}: 00\n")
    insert_lines.append("\n")

    for j, new_line in enumerate(insert_lines):
        lines.insert(block_start + j, new_line)
    changes.append(f"Inserted gap {addr} ({label})")

# ==========================================================================
# 6. Balance .proc/.endproc
#    Walk forward; when we hit .proc while already in_proc, insert .endproc
#    before the comment block preceding the new .proc.
# ==========================================================================
in_proc = False
endproc_added = 0
i = 0
while i < len(lines):
    stripped = lines[i].strip()
    if stripped.startswith(".proc "):
        if in_proc:
            # Find insertion point: before the comment block above this .proc
            insert_at = i
            # Check for 3-line comment block: sep, comment, sep
            if (i >= 3 and
                lines[i-1].startswith(";---") and
                lines[i-3].startswith(";---")):
                insert_at = i - 3
                # Also skip blank line before the block
                if insert_at > 0 and lines[insert_at - 1].strip() == "":
                    insert_at -= 1
            # Check for blank line immediately before
            elif i > 0 and lines[i-1].strip() == "":
                insert_at = i - 1

            lines.insert(insert_at, ".endproc\n")
            endproc_added += 1
            i += 1  # adjust index for insertion
        in_proc = True
    elif stripped == ".endproc":
        in_proc = False
    i += 1

# Final .endproc if still in proc
if in_proc:
    lines.append(".endproc\n")
    endproc_added += 1

changes.append(f"Added {endproc_added} missing .endproc directives")

# ==========================================================================
# 7. Report
# ==========================================================================
remaining_jmp = 0
remaining_branch = 0
for i, line in enumerate(lines):
    if re.search(r'^\s+JMP\s+\$[0-9A-F]{4}', line):
        remaining_jmp += 1
        changes.append(f"  Remaining JMP hex at line {i+1}: {line.rstrip()}")
    if re.search(r'^\s+(?:BEQ|BNE|BCS|BCC|BMI|BPL|BVC|BVS)\s+\$[0-9A-F]{4}', line):
        remaining_branch += 1
        changes.append(f"  Remaining branch hex at line {i+1}: {line.rstrip()}")

changes.append(f"Remaining JMP hex targets: {remaining_jmp}")
changes.append(f"Remaining branch hex targets: {remaining_branch}")

proc_count = sum(1 for l in lines if l.strip().startswith(".proc "))
endproc_count = sum(1 for l in lines if l.strip() == ".endproc")
changes.append(f"Final balance: {proc_count} .proc, {endproc_count} .endproc")

# ==========================================================================
# Write output
# ==========================================================================
with open(INPUT, "w") as f:
    f.writelines(lines)

for c in changes:
    print(c)
print(f"\nWrote {len(lines)} lines to {INPUT}")
