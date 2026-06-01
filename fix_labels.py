#!/usr/bin/env python3
"""Fix remaining cross-proc label scope issues."""

import re

INPUT = "asm/banks/prg_1f.asm"

with open(INPUT, "r") as f:
    content = f.read()

changes = []

# 1. Move gap byte labels + bytes AFTER .endproc (from inside to between procs)
# Pattern: "pad_XXXX:\n  .byte $00... ; $XXXX: 00\n.endproc"
# Change to: ".endproc\npad_XXXX:\n  .byte $00... ; $XXXX: 00"

for pad_name in ["pad_f027", "pad_f076", "pad_f091", "pad_ef70",
                  "pad_e842", "pad_f421", "pad_fabe", "pad_fad4",
                  "pad_ff9a", "pad_ffd6"]:
    # Find "pad_XXXX:\n  .byte ...\n.endproc"
    pattern = (pad_name + r":\n"
               r"(  \.byte \$[0-9A-F]{2}\s+; \$[0-9A-F]{4}: [0-9A-F]{2}\n)"
               r"\.endproc")
    match = re.search(pattern, content)
    if match:
        byte_line = match.group(1)
        replacement = ".endproc\n" + pad_name + ":\n" + byte_line
        content = content[:match.start()] + replacement + content[match.end():]
        changes.append(f"  Moved {pad_name} after .endproc")

# Special case: pad_e842 has TWO .byte lines
pattern = (r"  \.byte \$00\s+; \$E841: 00\n"
           r"pad_e842:\n"
           r"(  \.byte \$00\s+; \$E842: 00\n)"
           r"\.endproc")
match = re.search(pattern, content)
if match:
    byte_line = match.group(1)
    replacement = ".endproc\n  .byte $00                 ; $E841: 00\npad_e842:\n" + byte_line
    content = content[:match.start()] + replacement + content[match.end():]
    changes.append("  Moved pad_e842 (with $E841 byte) after .endproc")

# 2. Add global aliases for loc_ede2 and loc_eded (they're in different procs)
alias_text = "loc_ede2                               = $EDE2\n"
alias_text += "loc_eded                               = $EDED\n"

# Insert after the existing forward-declared aliases
marker = "IrqFlagWait"
if marker in content and "= $FB28" in content:
    # Find the line with IrqFlagWait alias and add after it
    for line in content.split("\n"):
        if "IrqFlagWait" in line and "= $FB28" in line:
            content = content.replace(line, line + "\n" + alias_text.rstrip())
            changes.append("Added loc_ede2, loc_eded aliases")
            break

# 3. Remove the proc-local definitions of loc_ede2 and loc_eded
content = content.replace("loc_ede2:\n", "")
content = content.replace("loc_eded:\n", "")
changes.append("Removed proc-local loc_ede2/loc_eded definitions")

with open(INPUT, "w") as f:
    f.write(content)

for c in changes:
    print(c)
print(f"\nWrote {len(content.splitlines())} lines to {INPUT}")
