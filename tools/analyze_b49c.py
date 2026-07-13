#!/usr/bin/env python3
"""
Analyze and improve Proc_B49C in prg_0a_0b.asm:
1. Fix .byte branch lines → proper mnemonics with target labels
2. Rename Proc_Bxxx and LBxxxx labels to semantic names
3. Add inline comments for non-trivial logic
"""
import re

file_path = '/home/zero/project/sango2dasm/asm/banks/prg_0a_0b.asm'

with open(file_path, 'r') as f:
    content = f.read()
    lines = content.split('\n')

# ── 1. Define rename maps ──────────────────────────────────────────────────

# Proc label renames (definition + all references)
proc_renames = {
    'Proc_B49C':  'AiTurnDispatch',
    'Proc_B4BF':  'AiSearchPhase1',
    'Proc_B504':  'AiSearchPhase2',
    'Proc_B5FC':  'AiActionSelect',
    'Proc_B7CE':  'AdjustSwapPositions',
    'Proc_B85F':  'AiFindStrongestAdjacent',
    'Proc_B898':  'AiCountActiveKingdoms',
    'Proc_B90A':  'AiSwapProvinceOwner',
    'Proc_B955':  'AiFindProvinceByOwner',
    'Proc_B98B':  'AiDomesticAction',
    'Proc_BA75':  'AiRandomCheck',
    'Proc_BA7E':  'AiEndTurn',
    'Proc_BB82':  'AiScanMaxResource',
    'Proc_BBB2':  'AiRecruitAction',
    'Proc_BD40':  'AiFindBestProvince',
    'Proc_BD7A':  'AiTurnLoop',
    'Proc_BDD1':  'AiEvaluateProvince',
    'Proc_BEE6':  'AiIncrementTurn',
    'Proc_BF44':  'AiApplyDomesticChanges',
}

# LB label renames
lb_renames = {
    'LB5C8':  '@loop_end',
    'LB613':  '@action_domestic',
    'LB639':  '@count_loop',
    'LB648':  '@count_next',
    'LB656':  '@exit_to_turn',
    'LB68A':  '@province_loop',
    'LB6A8':  '@province_next',
    'LB73A':  '@alloc_done',
    'LB78B':  '@wait_vblank',
    'LB7BF':  '@use_field_b',
    'LB7F1':  '@use_field_b_2',
    'LB854':  '@scan_next',
    'LB86A':  '@adjacent_loop',
    'LB89F':  '@clear_loop',
    'LB8AF':  '@kingdom_loop',
    'LB8C6':  '@adj_check',
    'LB8E1':  '@adj_next',
    'LB8FE':  '@count_active',
    'LB904':  '@count_active_next',
    'LB943':  '@set_high_nybble',
    'LB94C':  '@set_low_nybble',
    'LB964':  '@search_loop',
    'LB97A':  '@search_next_adj',
    'LB97F':  '@search_next',
    'LB99B':  '@domestic_loop',
    'LB9C1':  '@domestic_next',
    'LB9E5':  '@domestic_scan',
    'LB9F3':  '@domestic_scan_next',
    'LBA47':  '@tier_select',
    'LBA70':  '@positive_balance',
    'LBA8D':  '@transfer_province',
    'LBB40':  '@wait_event',
    'LBB45':  '@exit_recruit',
    'LBB53':  '@recruit_scan',
    'LBB77':  '@recruit_scan_next',
    'LBB8D':  '@resource_scan',
    'LBBE6':  '@recruit_loop',
    'LBC10':  '@recruit_loop_next',
    'LBC28':  '@clear_table',
    'LBC3E':  '@fill_loop',
    'LBC5C':  '@fill_next',
    'LBC62':  '@fill_skip',
    'LBC96':  '@alloc_check',
    'LBCDE':  '@alloc_store',
    'LBD36':  '@wait_event_2',
    'LBD4D':  '@best_loop',
    'LBF07':  '@reset_counter',
    'LBF16':  '@random_tier',
    'LBF22':  '@tier_mid',
    'LBF41':  '@tier_high',
}

# All renames combined
all_renames = {**proc_renames, **lb_renames}

# ── 2. Build address→line-index map ────────────────────────────────────────

# Parse addresses from comments: "; $B4A7: B0 03"
addr_re = re.compile(r'; \$(\w{4}):')

# B49C range: lines 3510-4945 (0-indexed: 3509-4944)
START = 3509
END = 4944

addr_to_lineidx = {}  # addr → line index in lines[]
for i in range(START, END + 1):
    m = addr_re.search(lines[i])
    if m:
        addr = int(m.group(1), 16)
        addr_to_lineidx[addr] = i

# ── 3. Build address→label map ─────────────────────────────────────────────

addr_to_label = {}
for i in range(START, END + 1):
    line = lines[i]
    # Match label definitions: "LabelName:" at start of line
    m = re.match(r'^(\w+):', line)
    if m:
        label = m.group(1)
        # Get address from next non-empty line or same line comment
        for j in range(i, min(i + 3, END + 1)):
            am = addr_re.search(lines[j])
            if am:
                addr = int(am.group(1), 16)
                addr_to_label[addr] = label
                break

# ── 4. Add missing labels for branch targets ──────────────────────────────

branch_opcodes = {
    0x10: 'BPL', 0x30: 'BMI', 0x50: 'BVC', 0x70: 'BVS',
    0x90: 'BCC', 0xB0: 'BCS', 0xD0: 'BNE', 0xF0: 'BEQ',
}

# Find all .byte branch lines and their targets
missing_labels = {}  # addr → generated label name
label_counter = 0

for i in range(START, END + 1):
    line = lines[i]
    # Match .byte $XX,$YY patterns (branch instructions)
    m = re.match(r'\s+\.byte \$(\w{2}),\$(\w{2})\s+; \$(\w{4}):', line)
    if m:
        opcode = int(m.group(1), 16)
        offset = int(m.group(2), 16)
        addr = int(m.group(3), 16)
        if opcode in branch_opcodes:
            signed = offset if offset < 0x80 else offset - 0x100
            target = addr + 2 + signed
            if target not in addr_to_label and target not in missing_labels:
                # Generate a label name
                gen_name = f'@branch_{target:04X}'
                missing_labels[target] = gen_name
                addr_to_label[target] = gen_name

# Insert missing labels into the code
for target_addr, label_name in sorted(missing_labels.items(), reverse=True):
    if target_addr in addr_to_lineidx:
        idx = addr_to_lineidx[target_addr]
        lines.insert(idx, f'{label_name}:')

# Rebuild addr_to_lineidx after insertions
addr_to_lineidx = {}
for i in range(len(lines)):
    m = addr_re.search(lines[i])
    if m:
        addr = int(m.group(1), 16)
        addr_to_lineidx[addr] = i

# ── 5. Convert .byte branch lines to proper mnemonics ──────────────────────

for i in range(len(lines)):
    line = lines[i]
    m = re.match(r'(\s+)\.byte \$(\w{2}),\$(\w{2})\s+; \$(\w{4}):', line)
    if m:
        indent = m.group(1)
        opcode = int(m.group(2), 16)
        offset = int(m.group(3), 16)
        addr = int(m.group(4), 16)
        if opcode in branch_opcodes:
            signed = offset if offset < 0x80 else offset - 0x100
            target = addr + 2 + signed
            mnemonic = branch_opcodes[opcode]
            target_label = addr_to_label.get(target, f'${target:04X}')
            # Apply rename
            if target_label in all_renames:
                target_label = all_renames[target_label]
            # Build new line, preserving comment style
            old_bytes = f'${m.group(2)},${m.group(3)}'
            new_mnemonic = f'{mnemonic} {target_label}'
            # Replace .byte with mnemonic, keep the rest of the line
            new_line = line.replace(f'.byte {old_bytes}', new_mnemonic, 1)
            # Clean up comment
            new_line = re.sub(r'\(.*mid-instruction target\)', f'; branch to {target_label}', new_line)
            new_line = re.sub(r'\(.*cross-proc\)', f'; branch to {target_label}', new_line)
            new_line = re.sub(r'\(.*cross-bank\)', f'; branch to {target_label}', new_line)
            lines[i] = new_line

# ── 6. Rename all labels (definitions and references) ──────────────────────

# Also rename raw address jumps to labeled targets
raw_addr_labels = {
    0xB616: '@exit_to_turn',   # JMP $B616 → common exit
    0xBEC7: '@end_turn_process',  # JMP $BEC7 → shared end-turn
    0xBFC3: '@apply_domestic_b',  # JMP $BFC3 → domestic apply path B
    0xC1E0: 'Proc_C1E0',       # JMP $C1E0 → external (bank 0B)
    0xBF33: '@check_kingdom_count',  # JMP $BF33
}

# Add labels for raw address targets that don't have labels yet
for addr, label in raw_addr_labels.items():
    if addr not in addr_to_label:
        # Find the line with this address
        if addr in addr_to_lineidx:
            idx = addr_to_lineidx[addr]
            lines.insert(idx, f'{label}:')
            # Rebuild map
            addr_to_label[addr] = label

# Rebuild addr_to_lineidx after insertions
addr_to_lineidx = {}
for i in range(len(lines)):
    m = addr_re.search(lines[i])
    if m:
        addr = int(m.group(1), 16)
        addr_to_lineidx[addr] = i

# Now rename all labels in the file
# Build replacement list sorted by length (longest first to avoid partial matches)
renames_sorted = sorted(all_renames.items(), key=lambda x: len(x[0]), reverse=True)

for i in range(len(lines)):
    line = lines[i]
    for old_name, new_name in renames_sorted:
        # Replace whole-word matches only
        line = re.sub(r'\b' + re.escape(old_name) + r'\b', new_name, line)
    lines[i] = line

# Also rename raw address references (JMP $B616 → JMP @exit_to_turn, etc.)
for i in range(len(lines)):
    line = lines[i]
    for addr, label in raw_addr_labels.items():
        addr_str = f'${addr:04X}'
        # Only replace JMP/JSR references, not comment addresses
        line = re.sub(r'(JMP|JSR)\s+\$' + f'{addr:04X}', r'\1 ' + label, line)
    lines[i] = line

# ── 7. Rename the proc itself ──────────────────────────────────────────────

# Update .global declaration
for i in range(len(lines)):
    if lines[i].strip() == '.global Proc_B49C':
        lines[i] = '.global AiTurnDispatch'
        break

# Update jump table entry
for i in range(len(lines)):
    if '.word Proc_B49C' in lines[i]:
        lines[i] = lines[i].replace('Proc_B49C', 'AiTurnDispatch')
        break

# Rename .proc directive
for i in range(len(lines)):
    if lines[i].strip() == '.proc Proc_B49C':
        lines[i] = '.proc AiTurnDispatch'
        break

# Update comment header
for i in range(len(lines)):
    if '$B49C: Proc_B49C' in lines[i]:
        lines[i] = lines[i].replace('Proc_B49C', 'AiTurnDispatch')
        break

# ── 8. Add section comments ────────────────────────────────────────────────

section_comments = {
    0xB49C: ';-------------------------------------------------------------------------------\n; $B49C: AiTurnDispatch — AI turn entry point (jump table entry 1)\n; Generates random number <50. If <10, do province search (AiSearchPhase1/2).\n; Otherwise, jump to AiActionSelect for AI action selection.\n;-------------------------------------------------------------------------------',
    0xB4BF: ';-------------------------------------------------------------------------------\n; $B4BF: AiSearchPhase1 — Phase 1 province search loop\n; Iterates 30 provinces. For each non-excluded, non-enemy province with value\n; >=