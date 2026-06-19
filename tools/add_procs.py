#!/usr/bin/env python3
"""Transform prg_17_18.asm: add .proc/.endproc scoping."""

import re
import sys

def main():
    infile = sys.argv[1] if len(sys.argv) > 1 else 'asm/banks/prg_17_18.asm'
    
    with open(infile) as f:
        lines = f.readlines()
    
    # --- Step 1: Identify all cross-referenced Lxxxx labels ---
    word_refs = set()
    jsr_jmp_refs = set()
    for line in lines:
        parts = line.split(';', 1)
        instr = parts[0]
        for m in re.finditer(r'\.word\s+(L[A-F0-9]+)', instr):
            word_refs.add(m.group(1))
        for m in re.finditer(r'(?:JSR|JMP)\s+(L[A-F0-9]+)', instr):
            jsr_jmp_refs.add(m.group(1))
    
    cross_refs = word_refs | jsr_jmp_refs
    
    # --- Step 2: Parse file into blocks ---
    # A block is either:
    # - section header (3 lines: bar + content + bar)
    # - minor separator (1 line)
    # - label definition (Lxxxx: or B17_18_Name:)
    # - code/data line
    # - blank line
    # - RAM definitions block
    # - .segment directive
    # - .include directive
    
    BAR = ';' + '=' * 79
    blocks = []
    i = 0
    while i < len(lines):
        line = lines[i].rstrip('\n')
        
        # Section header (3 lines)
        if line == BAR and i + 2 < len(lines) and lines[i+2].rstrip('\n') == BAR:
            content = [lines[j].rstrip('\n') for j in range(i+1, i+2)]
            blocks.append({'type': 'section_header', 'start': i, 'end': i+2, 
                         'content': content, 'bar': BAR})
            i += 3
            continue
        
        # Minor separator
        if re.match(r'^;--- .+ ---$', line):
            blocks.append({'type': 'minor_sep', 'start': i, 'end': i, 'text': line})
            i += 1
            continue
        
        # .segment directive
        if line.startswith('.segment'):
            blocks.append({'type': 'segment', 'start': i, 'end': i, 'text': line})
            i += 1
            continue
        
        # .include directive
        if line.startswith('.include'):
            blocks.append({'type': 'include', 'start': i, 'end': i, 'text': line})
            i += 1
            continue
        
        # RAM definition (= with description)
        if re.match(r'^[a-z_]+\s*=\s*\$[0-9A-Fa-f]+', line):
            blocks.append({'type': 'ram_def', 'start': i, 'end': i, 'text': line})
            i += 1
            continue
        
        # B17_18_* label
        m = re.match(r'^(B17_18_\w+):', line)
        if m:
            blocks.append({'type': 'named_label', 'start': i, 'end': i, 
                         'name': m.group(1), 'text': line})
            i += 1
            continue
        
        # Lxxxx label
        m = re.match(r'^(L[A-F0-9]+):', line)
        if m:
            blocks.append({'type': 'l_label', 'start': i, 'end': i,
                         'name': m.group(1), 'text': line})
            i += 1
            continue
        
        # Data directive (.byte, .word, .addr) at column 0 or indented
        if re.match(r'^\s*\.(byte|word|addr)\s', line):
            blocks.append({'type': 'data', 'start': i, 'end': i, 'text': line})
            i += 1
            continue
        
        # Code line (instruction)
        if re.match(r'^\s{2,}(LDA|STA|LDX|STX|LDY|STY|ADC|SBC|AND|ORA|EOR|CMP|CPX|CPY|'
                     r'INC|DEC|INX|INY|DEX|DEY|ASL|LSR|ROL|ROR|BIT|JMP|JSR|RTS|RTI|'
                     r'BRK|NOP|SEC|CLC|SED|CLD|SEI|CLI|CLV|TAX|TXA|TAY|TYA|TSX|TXS|'
                     r'PHA|PLA|PHP|PLP|BCC|BCS|BEQ|BNE|BMI|BPL|BVC|BVS)\b', line):
            blocks.append({'type': 'code', 'start': i, 'end': i, 'text': line})
            i += 1
            continue
        
        # Blank line
        if line.strip() == '':
            blocks.append({'type': 'blank', 'start': i, 'end': i})
            i += 1
            continue
        
        # Comment-only line
        if line.strip().startswith(';'):
            blocks.append({'type': 'comment', 'start': i, 'end': i, 'text': line})
            i += 1
            continue
        
        # Anything else
        blocks.append({'type': 'other', 'start': i, 'end': i, 'text': line})
        i += 1
    
    print(f"Parsed {len(blocks)} blocks from {len(lines)} lines")
    
    # --- Step 3: Group blocks into regions ---
    # Identify regions: code routines, data tables, jump table, etc.
    regions = []
    current_region = None
    
    for bi, block in enumerate(blocks):
        btype = block['type']
        
        if btype == 'section_header':
            # Start a new region
            if current_region:
                regions.append(current_region)
            # Parse address from section header content
            content_text = ' '.join(block['content'])
            addr_match = re.search(r'\$([A-F0-9]+)', content_text)
            addr = int(addr_match.group(1), 16) if addr_match else None
            
            # Check if it's a data section (contains .byte, .word in description)
            is_data = any(kw in content_text.lower() for kw in 
                        ['table', 'data', 'tile', 'lookup', 'pointer', 'permutation',
                         'padding', 'unused'])
            
            current_region = {
                'type': 'data' if is_data else 'code',
                'header': block,
                'blocks': [],
                'addr': addr,
                'name': None
            }
            # Try to extract name from header
            name_match = re.search(r'B17_18_(\w+)', content_text)
            if name_match:
                current_region['name'] = 'B17_18_' + name_match.group(1)
            continue
        
        if btype == 'segment':
            if current_region:
                regions.append(current_region)
            regions.append({'type': 'segment', 'header': block, 'blocks': [block]})
            current_region = None
            continue
        
        if current_region:
            current_region['blocks'].append(block)
        else:
            # Before first section header
            if not regions or regions[-1].get('type') != 'preamble':
                regions.append({'type': 'preamble', 'header': None, 'blocks': []})
            regions[-1]['blocks'].append(block)
    
    if current_region:
        regions.append(current_region)
    
    print(f"Found {len(regions)} regions")
    for r in regions:
        rtype = r['type']
        name = r.get('name', '')
        nblocks = len(r.get('blocks', []))
        hdr = ''
        if r.get('header') and r['header']['type'] == 'section_header':
            hdr = ' | '.join(r['header']['content'])
        print(f"  {rtype:8s} {name:35s} {nblocks:3d} blocks  {hdr}")

if __name__ == '__main__':
    main()
