#!/usr/bin/env python3
"""
Restructure Proc_B49C in prg_0a_0b.asm:
- Remove premature .endproc for B49C
- Merge 18 nested procs (B4BF..BF44) into B49C's scope
- Replace individual var defs with unified set at top
- Remove equate label definitions (Lxxx = $xxxx) — code labels provide them
- Remove .global declarations for nested procs
"""
import re

file_path = '/home/zero/project/sango2dasm/asm/banks/prg_0a_0b.asm'

# Nested proc names whose .global should be removed
nested_procs = {
    'Proc_B4BF', 'Proc_B504', 'Proc_B5FC', 'Proc_B7CE', 'Proc_B85F',
    'Proc_B898', 'Proc_B90A', 'Proc_B955', 'Proc_B98B', 'Proc_BA75',
    'Proc_BA7E', 'Proc_BB82', 'Proc_BBB2', 'Proc_BD40', 'Proc_BD7A',
    'Proc_BDD1', 'Proc_BEE6', 'Proc_BF44'
}

# All 24 unique variable definitions (sorted by address)
all_vars = [
    "  math_acc_lo              = $0020\n",
    "  math_acc_mlo             = $0021\n",
    "  math_acc_mhi             = $0022\n",
    "  math_acc_hi              = $0023\n",
    "  math_ext                 = $0024\n",
    "  math_temp1               = $0025\n",
    "  math_temp2               = $0026\n",
    "  math_temp3               = $0027\n",
    "  work_outer_idx           = $0036\n",
    "  work_inner_idx           = $0037\n",
    "  work_inner_idx2          = $0038\n",
    "  work_sub_idx             = $0039\n",
    "  work_limit_a             = $003A\n",
    "  work_limit_b             = $003B\n",
    "  work_temp_0              = $003C\n",
    "  work_temp_1              = $003D\n",
    "  work_temp_2              = $003E\n",
    "  work_record_idx          = $003F\n",
    "  work_record_val          = $0040\n",
    "  work_search_result       = $0041\n",
    "  work_search_max          = $0045\n",
    "  sram_kingdom_index       = $6F02\n",
    "  sram_player_id           = $6F03\n",
    "  sram_game_start_flag     = $6F8B\n",
]

with open(file_path, 'r') as f:
    lines = f.readlines()

output = []

# 0-indexed line numbers
START_LINE = 3527   # .proc Proc_B49C (line 3528)
END_LINE = 5170     # .endproc for BF44 (line 5171)

state = 'NORMAL'
nested_proc_name = None
b49c_vars_replaced = False

var_def_re = re.compile(r'^\s+\w+\s+= \$')
equate_re = re.compile(r'^\w+ = \$')
proc_re = re.compile(r'^\.proc (\S+)')
endproc_re = re.compile(r'^\.endproc')
comment_re = re.compile(r'^;')
blank_re = re.compile(r'^\s*$')

for i, line in enumerate(lines):
    # Phase 1: Remove .global declarations for nested procs (anywhere in file)
    if line.startswith('.global '):
        parts = line.strip().split()
        if len(parts) >= 2 and parts[1] in nested_procs:
            continue  # Skip this .global line

    # Phase 2: Process B49C range (lines 3528-5171)
    if i < START_LINE:
        output.append(line)
        continue
    if i > END_LINE:
        output.append(line)
        continue

    # --- Inside B49C range ---

    # Check for .proc
    m = proc_re.match(line)
    if m:
        proc_name = m.group(1)
        if proc_name == 'Proc_B49C':
            # Keep B49C's .proc, output all unified vars
            output.append(line)
            output.extend(all_vars)
            state = 'SKIP_B49C_VARS'
        else:
            # Nested proc — save name, start skipping header
            nested_proc_name = proc_name
            state = 'IN_NESTED_HEADER'
        continue

    if state == 'SKIP_B49C_VARS':
        # Skip B49C's original 3 var defs
        if var_def_re.match(line):
            continue
        else:
            state = 'NORMAL'
            output.append(line)
            continue

    if state == 'IN_NESTED_HEADER':
        # Skip var defs, blank lines, and comments in header
        if var_def_re.match(line):
            continue
        if blank_re.match(line):
            continue
        if comment_re.match(line):
            continue
        # First instruction — emit label then the instruction
        output.append(f'{nested_proc_name}:\n')
        output.append(line)
        state = 'NORMAL'
        continue

    # state == 'NORMAL'
    # Check for .endproc
    if endproc_re.match(line):
        if i == END_LINE:
            output.append(line)  # Keep BF44's .endproc → B49C's .endproc
        # else: skip (merge into one scope)
        continue

    # Check for equate definitions (Lxxx = $xxxx at column 0)
    if equate_re.match(line):
        continue  # Code labels (Lxxx:) already provide these

    # Normal line — keep
    output.append(line)

with open(file_path, 'w') as f:
    f.writelines(output)

# Print stats
original_lines = len(lines)
new_lines = len(output)
print(f"Original lines: {original_lines}")
print(f"New lines: {new_lines}")
print(f"Removed: {original_lines - new_lines} lines")
