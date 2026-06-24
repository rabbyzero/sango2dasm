#!/usr/bin/env python3
"""
Automatically add local parameter names to all .proc blocks in prg_17_18.asm

This script:
1. Parses all .proc/.endproc blocks
2. Extracts zero-page / RAM memory addresses used in each proc
3. Skips addresses that are already globally defined
4. Generates meaningful local parameter names based on context
5. Inserts parameter definitions at start of each .proc block
6. Replaces raw addresses in proc body with named parameters
"""

import re
import sys
from collections import defaultdict
from typing import Dict, List, Optional, Set, Tuple


# ─── Constants ───────────────────────────────────────────────────────────────

# Address ranges to skip (hardware registers, ROM, etc.)
# Only skip non-RAM ranges. Zero page ($0000-$01FF) and work RAM are kept.
SKIP_RANGES = [
    (0x2000, 0x3FFF),   # PPU registers + mirrors
    (0x4000, 0x401F),   # APU / I/O registers + test
    (0x4020, 0x5FFF),   # Expansion ROM
    (0x6000, 0x7FFF),   # SRAM (battery-backed, only if mapper uses it)
    (0x8000, 0xFFFF),   # ROM space
]

# Well-known address names (override generic naming)
WELL_KNOWN = {
    '$0000': 'param_byte1',
    '$0001': 'param_byte2',
    '$000A': 'ptr_lo',
    '$000B': 'ptr_hi',
    '$000C': 'attr_ptr_lo',
    '$000D': 'attr_ptr_hi',
    '$0002': 'rle_marker',
    '$0004': 'col_counter_lo',
    '$0005': 'col_counter_hi',
    '$0006': 'row_limit',
    '$0007': 'row_count',
}


# ─── Helpers ─────────────────────────────────────────────────────────────────

def should_skip_addr(addr_val: int) -> bool:
    """Return True if this address is in a hardware/ROM range."""
    for lo, hi in SKIP_RANGES:
        if lo <= addr_val <= hi:
            return True
    return False


def extract_global_defs(filepath: str) -> Dict[str, str]:
    """Extract global address definitions from file header (before first .segment)."""
    global_defs = {}
    with open(filepath, 'r') as f:
        for line in f:
            # Stop at first .segment directive
            if line.strip().startswith('.segment'):
                break
            match = re.match(r'^(\w+)\s*=\s*(\$[0-9A-Fa-f]{4})', line.strip())
            if match:
                global_defs[match.group(2).upper()] = match.group(1)
    return global_defs


def find_proc_blocks(lines: List[str]) -> List[Tuple[int, int, str]]:
    """Find all .proc/.endproc blocks → (start_line, end_line, proc_name).
    Handles missing .endproc by treating the line before the next .proc as the end."""
    blocks = []
    i = 0
    while i < len(lines):
        m = re.match(r'^\.proc\s+(\w+)', lines[i].strip())
        if m:
            proc_name = m.group(1)
            start = i
            j = i + 1
            found_end = False
            while j < len(lines):
                stripped = lines[j].strip()
                if stripped.startswith('.endproc'):
                    blocks.append((start, j, proc_name))
                    found_end = True
                    i = j + 1
                    break
                # If we hit another .proc, the previous one ended implicitly
                if re.match(r'^\.proc\s+\w+', stripped):
                    # End at the line before this new .proc
                    end = j - 1
                    # Walk back past blank lines/comments to find actual end
                    while end > start and not lines[end].strip():
                        end -= 1
                    blocks.append((start, end, proc_name))
                    found_end = True
                    i = j  # Don't skip the new .proc
                    break
                j += 1
            if not found_end:
                # Proc without .endproc at end of file
                blocks.append((start, len(lines) - 1, proc_name))
                break
            continue  # i was already advanced
        i += 1
    return blocks


def extract_addresses(lines: List[str], start: int, end: int) -> Dict[str, dict]:
    """
    Extract all RAM addresses used in a proc block.
    Returns dict mapping 4-digit address ($XXXX) → usage info.
    """
    usage = defaultdict(lambda: {'count': 0, 'reads': 0, 'writes': 0, 'instrs': []})

    # Regex for instructions that reference memory
    mem_ops = r'(?:LDA|STA|LDX|STX|LDY|STY|CMP|CPX|CPY|ADC|SBC|AND|ORA|EOR|BIT|INC|DEC)'

    for i in range(start, end + 1):
        line = lines[i].strip()
        if not line or line.startswith(';') or line.startswith('.'):
            continue
        if line.endswith(':'):  # local label
            continue

        # 1. Absolute: OP a:$XXXX  or  OP $XXXX
        for m in re.finditer(mem_ops + r'\s+(?:a:)?(\$[0-9A-Fa-f]{4})', line):
            addr = m.group(1).upper()
            val = int(addr[1:], 16)
            if should_skip_addr(val):
                continue
            _record(usage, addr, line)

        # 2. Indirect indexed: OP ($XX),Y
        for m in re.finditer(mem_ops + r'\s+\(\$([0-9A-Fa-f]{2})\),Y', line):
            addr = '$' + m.group(1).zfill(4).upper()
            _record(usage, addr, line)

        # 3. Indirect: OP ($XX)
        for m in re.finditer(mem_ops + r'\s+\(\$([0-9A-Fa-f]{2})\)', line):
            addr = '$' + m.group(1).zfill(4).upper()
            _record(usage, addr, line)

        # 4. Indexed: OP $XXXX,X  or  OP $XXXX,Y
        for m in re.finditer(mem_ops + r'\s+(?:a:)?(\$[0-9A-Fa-f]{4}),[XY]', line):
            addr = m.group(1).upper()
            val = int(addr[1:], 16)
            if should_skip_addr(val):
                continue
            _record(usage, addr, line)

    return dict(usage)


def _record(usage, addr: str, line: str):
    """Record one address access."""
    instr = line.split()[0]
    usage[addr]['count'] += 1
    if instr.startswith(('ST', 'INC', 'DEC')):
        usage[addr]['writes'] += 1
    else:
        usage[addr]['reads'] += 1
    usage[addr]['instrs'].append(instr)


def has_existing_params(lines: List[str], start: int, end: int) -> bool:
    """Check if a proc already has local parameter definitions."""
    for i in range(start + 1, min(start + 10, end)):
        line = lines[i].strip()
        if re.match(r'^\w+\s*=\s*\$[0-9A-Fa-f]{4}', line):
            return True
        if line and not line.startswith(';') and not line.endswith(':'):
            break
    return False


def generate_name(addr: str, info: dict, proc_name: str, taken: Set[str]) -> str:
    """Generate a meaningful parameter name."""
    addr_upper = addr.upper()

    # Well-known overrides
    if addr_upper in WELL_KNOWN:
        name = WELL_KNOWN[addr_upper]
        if name not in taken:
            return name

    val = int(addr_upper[1:], 16)

    # Pointer pair detection: if addr N and N+1 both exist, name them lo/hi
    # (handled in a post-pass below)

    # Loop variable detection
    all_instrs = ' '.join(info['instrs'])
    if 'DEX' in all_instrs or 'DEY' in all_instrs:
        if 'counter' not in taken:
            return 'counter'
        if 'loop_var' not in taken:
            return 'loop_var'

    # Flag detection: read+write with branch instructions
    branch_ops = {'BEQ', 'BNE', 'BMI', 'BPL', 'BCC', 'BCS', 'BVC', 'BVS'}
    has_branch = any(op in all_instrs for op in branch_ops)
    if info['reads'] > 0 and info['writes'] > 0 and has_branch:
        if 'flag' not in taken:
            return 'flag'
        if 'status' not in taken:
            return 'status'

    # Address-range-based naming
    if val < 0x0010:
        prefix = 'param'
    elif val < 0x0100:
        if info['writes'] > info['reads'] * 2:
            prefix = 'temp'
        elif info['reads'] > 0 and info['writes'] > 0:
            prefix = 'work'
        else:
            prefix = 'var'
    elif 0x0400 <= val < 0x0500:
        prefix = 'state'
    elif 0x0500 <= val < 0x0600:
        prefix = 'param'
    else:
        prefix = 'var'

    base = f'{prefix}_{val:04x}'
    candidate = base
    n = 1
    while candidate in taken:
        candidate = f'{base}_{n}'
        n += 1
    return candidate


def detect_pointer_pairs(addr_to_name: Dict[str, str], taken: Set[str]) -> Dict[str, str]:
    """Detect consecutive addresses that form pointer pairs and rename them."""
    rename = {}
    addrs = sorted(addr_to_name.keys(), key=lambda a: int(a[1:], 16))
    addr_set = set(addr_to_name.keys())
    used_pairs = set()  # Track which pair bases we've used

    for addr in addrs:
        if addr in rename:
            continue
        val = int(addr[1:], 16)
        next_addr = f'${val + 1:04X}'
        if next_addr in addr_set and next_addr not in rename:
            old_lo = addr_to_name[addr]
            old_hi = addr_to_name.get(next_addr, '')
            
            # Skip if either already has a well-known name
            if addr in WELL_KNOWN or next_addr in WELL_KNOWN:
                continue
            
            # Skip if names don't look generic
            generic_prefixes = ('var_', 'work_', 'temp_', 'param_', 'state_')
            if not (old_lo.startswith(generic_prefixes) or old_hi.startswith(generic_prefixes)):
                continue
            
            # Generate a unique pair name
            # Extract a base name from the current name
            base = old_lo.rsplit('_', 1)[0] if '_' in old_lo else 'ptr'
            # Remove any trailing hex digits from the base
            base = re.sub(r'_[0-9a-f]{4}$', '', base)
            if not base or base in ('var', 'work', 'temp', 'param', 'state'):
                base = f'ptr_{val:04x}'
            
            # Ensure uniqueness
            lo_name = f'{base}_lo'
            hi_name = f'{base}_hi'
            n = 2
            while lo_name in taken or hi_name in taken or lo_name in used_pairs:
                lo_name = f'{base}_{n}_lo'
                hi_name = f'{base}_{n}_hi'
                n += 1
            
            # Remove old names from taken, add new ones
            taken.discard(old_lo)
            taken.discard(old_hi)
            
            rename[addr] = lo_name
            rename[next_addr] = hi_name
            taken.add(lo_name)
            taken.add(hi_name)
            used_pairs.add(lo_name)

    return rename


# ─── Main ────────────────────────────────────────────────────────────────────

def process_file(input_path: str, output_path: str):
    print(f"Reading {input_path}...")
    with open(input_path, 'r') as f:
        content = f.read()

    lines = content.split('\n')
    global_defs = extract_global_defs(input_path)
    print(f"Found {len(global_defs)} global address definitions")

    proc_blocks = find_proc_blocks(lines)
    print(f"Found {len(proc_blocks)} proc blocks")

    modified = lines[:]
    offset = 0  # track line insertions
    processed = 0
    skipped = 0

    for start, end, proc_name in proc_blocks:
        adj_start = start + offset
        adj_end = end + offset

        # Skip procs that already have local params
        if has_existing_params(modified, adj_start, adj_end):
            skipped += 1
            continue

        # Extract addresses
        addr_info = extract_addresses(modified, adj_start, adj_end)
        if not addr_info:
            skipped += 1
            continue

        # Filter out globals
        local = {a: info for a, info in addr_info.items() if a not in global_defs}
        if not local:
            skipped += 1
            continue

        # Generate names
        taken = set()
        addr_to_name = {}
        for addr in sorted(local.keys()):
            name = generate_name(addr, local[addr], proc_name, taken)
            addr_to_name[addr] = name
            taken.add(name)

        # Detect pointer pairs
        pair_renames = detect_pointer_pairs(addr_to_name, taken)
        for addr, new_name in pair_renames.items():
            old_name = addr_to_name[addr]
            taken.discard(old_name)
            addr_to_name[addr] = new_name
            taken.add(new_name)

        # Build parameter definition lines
        param_lines = []
        for addr in sorted(addr_to_name.keys(), key=lambda a: int(a[1:], 16)):
            name = addr_to_name[addr]
            param_lines.append(f"  {name:<16}= {addr}")

        # Insert after .proc line
        insert_pos = adj_start + 1
        for j, pl in enumerate(param_lines):
            modified.insert(insert_pos + j, pl)

        # Now replace addresses in the proc body
        body_start = insert_pos + len(param_lines)
        body_end = adj_end + len(param_lines) + 1

        for i in range(body_start, body_end):
            if i >= len(modified):
                break
            line = modified[i]

            # Split code / comment
            if ';' in line:
                code, comment = line.split(';', 1)
                comment = ';' + comment
            else:
                code, comment = line, ''

            # Replace addresses (longest first to avoid partial matches)
            for addr in sorted(addr_to_name.keys(), key=lambda a: -len(a)):
                name = addr_to_name[addr]

                # Replace a:$XXXX form
                code = code.replace(f'a:{addr}', name)

                # Replace $XXXX form (not preceded by #)
                code = re.sub(r'(?<!#)' + re.escape(addr) + r'(?!\d)', name, code)

                # For zero-page addresses, also replace 2-digit form
                val = int(addr[1:], 16)
                if val < 0x100:
                    # Build the short form: $0A, $00, etc.
                    short = f'${val:02X}'
                    # Replace ($XX),Y form
                    code = code.replace(f'({short}),Y', f'({name}),Y')
                    # Replace ($XX) form
                    code = code.replace(f'({short})', f'({name})')
                    # Replace bare $XX form (not preceded by # or another hex digit)
                    code = re.sub(r'(?<!#)(?<!\d)' + re.escape(short) + r'(?!\d)', name, code)

            modified[i] = code + comment

        offset += len(param_lines)
        processed += 1

    print(f"\nProcessed {processed} procs, skipped {skipped} procs")
    print(f"Writing output to {output_path}...")

    with open(output_path, 'w') as f:
        f.write('\n'.join(modified))

    print("Done!")


if __name__ == '__main__':
    input_file = '/home/zero/project/sango2dasm/asm/banks/prg_17_18.asm'
    output_file = '/home/zero/project/sango2dasm/asm/banks/prg_17_18_new.asm'
    process_file(input_file, output_file)
