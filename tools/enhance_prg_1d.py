#!/usr/bin/env python3
"""
Generate enhanced prg_1d assembly with:
- Entry labels on jump table
- .proc/.endproc blocks for entry-point procedures
- Meaningful procedure names
"""
import re

# Read the raw disassembly
with open('/tmp/disasm_1d_final.txt') as f:
    raw_lines = f.readlines()

# Jump table entries: (index, target_label_in_disasm, proc_name)
JUMP_TABLE = [
    (0,  "Loc_A048", "Entry00_PPUTileRender"),
    (1,  "Loc_A154", "Entry01_MenuUpdate"),
    (2,  "Loc_A11B", "Entry02_VRAMBufferWrite"),
    (3,  "Loc_ABD2", "Entry03_StateHandler"),
    (4,  "Loc_B29F", "Entry04_MapDisplaySetup"),
    (5,  "Loc_B989", "Entry05_OfficerListHandler"),
    (6,  "Loc_BC41", "Entry06_Unknown"),
    (7,  None,        None),          # JMP $DBB1 (bank 1E)
    (8,  None,        None),          # JMP $DD8B (bank 1E)
    (9,  None,        None),          # JMP $DE7E (bank 1E)
    (10, "Loc_A6B6", "Entry10_NumberDisplaySetup"),
    (11, "Loc_A77F", "Entry11_FrameCounterCheck"),
    (12, "Loc_A7B2", "Entry12_BcdDisplayHandler"),
    (13, "Loc_A830", "Entry13_ProvinceDataHandler"),
    (14, "Loc_A890", "Entry14_OfficerLookup"),
    (15, "Loc_A78A", "Entry15_FrameCounterAlt"),
    (16, "Loc_A8A4", "Entry16_NameDisplay"),
    (17, "Loc_A8FD", "Entry17_RecordProcessor"),
    (18, "Loc_BC66", "Entry18_SmallRoutineA"),
    (19, "Loc_BC71", "Entry19_SmallRoutineB"),
    (20, "Loc_A991", "Entry20_DataFormatter"),
    (21, "Loc_BE36", "Entry21_MenuRenderer"),
    (22, "Loc_AA37", "Entry22_BankedDataHandler"),
    (23, None,        None),          # JMP $DEB9 (bank 1E)
]

# Build a map: target_label -> (entry_index, proc_name)
entry_targets = {}
for idx, label, name in JUMP_TABLE:
    if label:
        entry_targets[label] = (idx, name)

# Parse all lines, extracting labels and instructions
class Line:
    def __init__(self, raw, label=None, instruction=None, addr=None, byte_hex=None, is_comment=False):
        self.raw = raw.rstrip('\n')
        self.label = label
        self.instruction = instruction
        self.addr = addr
        self.byte_hex = byte_hex
        self.is_comment = is_comment

parsed = []
for raw in raw_lines:
    line = raw.rstrip('\n')
    # Check if it's a label line
    m = re.match(r'^(Loc_[A-F0-9]{4}):$', line)
    if m:
        parsed.append(Line(raw, label=m.group(1)))
        continue
    # Check if it's a comment-only line
    if line.startswith(';'):
        parsed.append(Line(raw, is_comment=True))
        continue
    # Check if it's an instruction with byte comment
    m = re.match(r'^  (.+?)\s+; \$([A-F0-9]{4}): (.+)$', line)
    if m:
        instr = m.group(1).strip()
        addr = int(m.group(2), 16)
        bhex = m.group(3).strip()
        parsed.append(Line(raw, instruction=instr, addr=addr, byte_hex=bhex))
        continue
    # Check if it's a bare instruction (no byte comment)
    m = re.match(r'^  (.+)$', line)
    if m:
        parsed.append(Line(raw, instruction=m.group(1).strip()))
        continue
    parsed.append(Line(raw))

# Find the line indices for each label
label_line_idx = {}
for i, p in enumerate(parsed):
    if p.label:
        label_line_idx[p.label] = i

# For each entry target, find its procedure boundary
# Procedure starts at the label line, ends at the first RTS after it
# (or just before the next entry target label, whichever comes first)
entry_labels_sorted = sorted(
    [(label_line_idx[lbl], lbl, idx, name)
     for lbl, (idx, name) in entry_targets.items()
     if lbl in label_line_idx],
    key=lambda x: x[0]
)

proc_ranges = []  # (start_line_idx, end_line_idx_exclusive, label, entry_idx, proc_name)

for i, (start_idx, label, eidx, pname) in enumerate(entry_labels_sorted):
    # Find the first RTS after start_idx
    rts_idx = None
    for j in range(start_idx + 1, len(parsed)):
        p = parsed[j]
        if p.instruction and p.instruction.strip() == 'RTS':
            rts_idx = j
            break
        # Also stop if we hit another entry target label
        if p.label and p.label in entry_targets and p.label != label:
            rts_idx = j - 1
            break

    if rts_idx is None:
        # If no RTS found, end at the next entry target or end of file
        if i + 1 < len(entry_labels_sorted):
            rts_idx = entry_labels_sorted[i+1][0] - 1
        else:
            rts_idx = len(parsed) - 1

    proc_ranges.append((start_idx, rts_idx + 1, label, eidx, pname))

# Build a set of line indices that are inside .proc blocks
proc_line_ranges = []
for start, end, label, eidx, pname in proc_ranges:
    proc_line_ranges.append((start, end))

def in_proc(line_idx):
    for s, e in proc_line_ranges:
        if s <= line_idx < e:
            return True
    return False

# Generate output
output = []

# File header
output.append(""";===============================================================================
; PRG Bank $1D - $A000-$BFFF (8KB)
; Sangokushi 2 - Haou no Tairiku (J)
; Namco-163 Mapper 19
;
; Jump table at $A000-$A047 (24 entries)
; Code: $A048-$B304 (with inline data tables)
; Data: $B305-$B988 (tile/map data, ~1636 bytes)
; Code: $B989-$BFFF (menu/UI handler code)
;
; Part of combined 16KB: prg_1d_1e.asm ($A000-$DFFF)
;===============================================================================

.include "6502_registers.h"
.include "namco163.h"
.include "functions.h"

.segment "CODE_BANK1D"
""")

# Process lines
# Track which proc we're currently in
current_proc = None
line_idx = 0

# First, output the jump table section (lines 0-23 are the jump table entries)
# We need to intercept them and add Entry labels
jt_count = 0
for i, p in enumerate(parsed):
    # Handle jump table entries (first 24 JMP instructions)
    if i < 24 and p.instruction and p.instruction.startswith('JMP'):
        entry = JUMP_TABLE[jt_count]
        eidx, label, pname = entry
        entry_label = f"Entry{eidx:02d}"
        if pname:
            output.append(f"{entry_label}:                                       ; {entry_label} -> JMP {label if label else p.instruction.split()[-1]}")
        else:
            target = p.instruction.split()[-1]
            output.append(f"{entry_label}:                                       ; {entry_label} -> JMP {target} (bank $1E)")
        output.append(p.raw)
        jt_count += 1
        line_idx = i + 1
        continue
    elif i < 24:
        output.append(p.raw)
        line_idx = i + 1
        continue
    break

# Now process from line 24 onwards (after jump table)
output.append("")
output.append(";===============================================================================")
output.append("; Code Region ($A048-$B304)")
output.append(";===============================================================================")
output.append("")

# Check if we need to start a proc at line_idx
for start, end, label, eidx, pname in proc_ranges:
    pass  # just building the ranges above

# Process remaining lines
i = line_idx
while i < len(parsed):
    p = parsed[i]

    # Check if this line starts a procedure
    starting_proc = None
    for start, end, label, eidx, pname in proc_ranges:
        if start == i:
            starting_proc = (end, label, eidx, pname)
            break

    if starting_proc:
        end, label, eidx, pname = starting_proc
        entry_label = f"Entry{eidx:02d}"
        output.append(f";-------------------------------------------------------------------------------")
        output.append(f"; {entry_label}: {pname}")
        output.append(f"; Jump table entry {eidx} at $A{eidx*3:03X}")
        output.append(f";-------------------------------------------------------------------------------")
        output.append(f".proc {entry_label}_{pname}")
        # Output the label as a comment since it's now inside .proc
        output.append(f"{label}:")

        # Output all lines in this proc
        j = i + 1
        while j < end:
            pp = parsed[j]
            # Don't output the label again if it's the same one
            if pp.label and pp.label == label:
                j += 1
                continue
            output.append(pp.raw)
            j += 1

        output.append(f".endproc ; {entry_label}_{pname}")
        output.append("")
        i = end
        continue

    # Regular line (not inside a proc)
    if p.label:
        # Check if this label is a sub-procedure target (JSR target)
        output.append(p.raw)
    elif p.is_comment:
        output.append(p.raw)
    else:
        output.append(p.raw)
    i += 1

# Write output
with open('/tmp/prg_1d_enhanced.asm', 'w') as f:
    f.write('\n'.join(output))

print(f"Generated {len(output)} lines")
