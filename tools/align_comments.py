#!/usr/bin/env python3
# Align inline comments to column 48 in prg_1f.aligned.asm
COMMENT_COL = 48

with open('asm/banks/prg_1f.aligned.asm', 'r') as f:
    lines = f.readlines()

output = []
changes = 0

for line in lines:
    stripped = line.rstrip('\n')
    
    if not stripped:
        output.append(line)
        continue
    
    if stripped.lstrip().startswith(';'):
        output.append(line)
        continue
    
    semi_pos = stripped.find(';')
    if semi_pos <= 0:
        output.append(line)
        continue
    
    code_part = stripped[:semi_pos].rstrip()
    comment_part = stripped[semi_pos:]
    current_col = len(code_part)
    
    if current_col < COMMENT_COL:
        new_line = code_part + ' ' * (COMMENT_COL - current_col) + comment_part + '\n'
        if new_line != line:
            changes += 1
        output.append(new_line)
    elif current_col > COMMENT_COL:
        new_line = code_part + '  ' + comment_part + '\n'
        if new_line != line:
            changes += 1
        output.append(new_line)
    else:
        output.append(line)

with open('asm/banks/prg_1f.aligned.asm', 'w') as f:
    f.writelines(output)

print(f'Aligned {changes} lines to comment column {COMMENT_COL}')
