#!/usr/bin/env python3
"""
proc_scope_17_18.py - Add .proc/.endproc scoping to prg_17_18.asm

Transforms the flat label file into properly scoped ca65 assembly with:
- .proc/.endproc around each function
- Semantic B17_18_ names for all procs (no LXXXX proc names)
- @local labels for branch targets within procs
- Data tables outside proc scopes
- Inline dispatch tables (.word after JSR CallbackDispatcher) inside calling proc

Usage:
    python3 tools/proc_scope_17_18.py [--dry-run] [--verbose]
"""

import re
import sys
from pathlib import Path
from collections import defaultdict

# ============================================================================
# Manual name overrides: LXXXX -> semantic B17_18_ name
# Add entries here for important functions before running.
# ============================================================================
NAME_OVERRIDES = {
    # Multi-caller utility subroutines
    # (will be populated after dry-run analysis)
}

# ============================================================================
# Known data regions (from REGION_MAP in transform_17_18.py)
# These are address ranges that contain data, not code.
# ============================================================================
KNOWN_DATA_REGIONS = [
    (0xA06B, 0xA087, "DomesticTilePtrs",
     "Domestic tile/attribute pointer table"),
    (0xA642, 0xA89A, "BattleTileData",
     "Battle screen tile data and PPU address tables"),
    (0xC000, 0xC08A, "TileLookupTable",
     "Tile/map lookup table"),
    (0xDEA0, 0xDEB9, "AnimFrameTable",
     "Animation frame index table"),
    (0xDF4A, 0xE000, "DataRecordPtrs",
     "Data record pointer table + permutation table"),
]

# ============================================================================
# Regex patterns
# ============================================================================
BRANCH_OPS = {'BCC', 'BCS', 'BEQ', 'BNE', 'BMI', 'BPL', 'BVC', 'BVS'}

ADDR_COMMENT_RE = re.compile(r';\s+\$([0-9A-Fa-f]{4}):')
LABEL_DEF_RE = re.compile(r'^(L[A-F0-9]{4}|B17_18_\w+):')
BRANCH_RE = re.compile(
    r'^\s+(BCC|BCS|BEQ|BNE|BMI|BPL|BVC|BVS)\s+(L[A-F0-9]{4}|B17_18_\w+)\b')
JMP_RE = re.compile(
    r'^\s+JMP\s+(L[A-F0-9]{4}|B17_18_\w+)\b')
JSR_RE = re.compile(
    r'^\s+JSR\s+(L[A-F0-9]{4}|B17_18_\w+)\b')
WORD_LABEL_RE = re.compile(
    r'\.word\s+(L[A-F0-9]{4}|B17_18_\w+)\b')
WORD_ADDR_RE = re.compile(
    r'\.word\s+\$([0-9A-Fa-f]{4})\b')
DATA_RE = re.compile(r'^\s*\.(byte|word|addr)\b')
CALLBACK_RE = re.compile(r'JSR\s+B1F_CallbackDispatcher')
COMMENT_BAR_RE = re.compile(r'^;[=]{3,}')
HEADER_BAR = ';' + '=' * 79


# ============================================================================
# Phase 1: Parse
# ============================================================================
def parse_file(lines):
    """Parse file to build label/reference/address maps."""
    label_defs = {}       # name -> line_idx
    label_addrs = {}      # name -> cpu_address
    addr_to_label = {}    # cpu_address -> name
    line_addrs = {}       # line_idx -> cpu_address
    refs = defaultdict(list)  # target_name -> [(line_idx, ref_type)]

    for i, line in enumerate(lines):
        # CPU address from inline comment
        am = ADDR_COMMENT_RE.search(line)
        if am:
            line_addrs[i] = int(am.group(1), 16)

        # Label definition
        lm = LABEL_DEF_RE.match(line)
        if lm:
            name = lm.group(1)
            label_defs[name] = i
            continue

        # Branch reference
        bm = BRANCH_RE.match(line)
        if bm:
            refs[bm.group(2)].append((i, 'branch'))
            continue

        # JMP reference
        jm = JMP_RE.match(line)
        if jm:
            refs[jm.group(1)].append((i, 'jump'))
            continue

        # JSR reference
        sm = JSR_RE.match(line)
        if sm:
            refs[sm.group(1)].append((i, 'call'))
            continue

        # .word reference (label target)
        for wm in WORD_LABEL_RE.finditer(line):
            refs[wm.group(1)].append((i, 'table'))

    # Build address maps
    for name, line_idx in label_defs.items():
        for j in range(line_idx, min(line_idx + 3, len(lines))):
            if j in line_addrs:
                label_addrs[name] = line_addrs[j]
                addr_to_label[line_addrs[j]] = name
                break

    return label_defs, label_addrs, addr_to_label, line_addrs, refs


# ============================================================================
# Phase 2: Data Region Detection
# ============================================================================
def find_data_regions(lines, line_addrs, label_defs, label_addrs):
    """
    Identify data regions that must be outside proc scopes.
    Returns:
      inline_dispatch: set of line indices that are inline .word entries
                       (inside calling proc, after JSR CallbackDispatcher)
      data_ranges: list of (start_line, end_line) for data outside procs
      data_labels: set of label names that define data tables
    """
    inline_dispatch = set()
    data_ranges = []
    data_labels = set()

    # --- Find inline dispatch tables ---
    # Pattern: JSR B1F_CallbackDispatcher followed by .word entries
    # (comment lines like "; --- Inline pointer table ---" may appear between)
    for i, line in enumerate(lines):
        if CALLBACK_RE.search(line):
            # Scan forward for .word entries
            j = i + 1
            while j < len(lines):
                stripped = lines[j].strip()
                # Skip blanks and comment lines
                if stripped == '' or stripped.startswith(';'):
                    j += 1
                    continue
                if stripped.startswith('.word'):
                    inline_dispatch.add(j)
                    j += 1
                else:
                    break

    # --- Find known data regions by address ---
    for start_addr, end_addr, name, desc in KNOWN_DATA_REGIONS:
        # Find line range for this address range
        region_start = None
        region_end = None
        for i, line in enumerate(lines):
            if i in line_addrs:
                addr = line_addrs[i]
                if start_addr <= addr < end_addr:
                    if region_start is None:
                        region_start = i
                    region_end = i
        if region_start is not None:
            # Extend to include comment header above
            # and any label definition at the start
            hdr_start = region_start
            while hdr_start > 0:
                prev = lines[hdr_start - 1].strip()
                if prev == '' or prev.startswith(';') or LABEL_DEF_RE.match(lines[hdr_start - 1]):
                    hdr_start -= 1
                else:
                    break
            data_ranges.append((hdr_start, region_end))
            # Mark label at region start as data label
            if region_start in addr_to_label_local:
                data_labels.add(addr_to_label_local[region_start])

    # --- Find embedded data (data runs after terminators) ---
    # Walk through file, tracking terminators
    i = 0
    while i < len(lines):
        if i in inline_dispatch:
            i += 1
            continue

        stripped = lines[i].strip()

        # Check if this is a terminator instruction
        is_terminator = False
        instr = stripped.split(';', 1)[0].strip()
        if instr in ('RTS', 'RTI'):
            is_terminator = True
        elif instr.startswith('JMP ') and not instr.startswith('JMP ('):
            # Unconditional JMP (tail-call)
            is_terminator = True

        if is_terminator:
            # Look ahead for data after this terminator
            j = i + 1
            # Skip blanks and comment lines
            while j < len(lines):
                s = lines[j].strip()
                if s == '' or s.startswith(';'):
                    j += 1
                else:
                    break

            # Check if data follows
            if j < len(lines) and DATA_RE.match(lines[j]) and j not in inline_dispatch:
                data_start = j
                # Check for comment header above the data
                hdr_start = data_start
                while hdr_start > i + 1:
                    prev = lines[hdr_start - 1].strip()
                    if prev.startswith(';') or prev == '':
                        hdr_start -= 1
                    else:
                        break

                # Find end of data run
                data_end = j
                while data_end < len(lines):
                    s = lines[data_end].strip()
                    if DATA_RE.match(lines[data_end]) and data_end not in inline_dispatch:
                        data_end += 1
                    elif s == '' or s.startswith(';'):
                        data_end += 1
                    else:
                        break
                data_end -= 1

                # Only mark as embedded data if it's at least 1 data line
                has_data = any(DATA_RE.match(lines[k]) for k in range(data_start, data_end + 1))
                if has_data:
                    data_ranges.append((hdr_start, data_end))

                i = data_end + 1
                continue

        i += 1

    return inline_dispatch, data_ranges, data_labels


# ============================================================================
# Phase 3: Label Classification
# ============================================================================
def classify_labels(label_defs, label_addrs, refs, data_labels):
    """Classify each label as proc_start, inner_global, or at_candidate."""
    word_targets = set()
    jsr_callers = defaultdict(set)   # name -> set of source lines
    jmp_callers = defaultdict(set)   # name -> set of source lines

    for name, ref_list in refs.items():
        for src_line, ref_type in ref_list:
            if ref_type == 'table':
                word_targets.add(name)
            elif ref_type == 'call':
                jsr_callers[name].add(src_line)
            elif ref_type == 'jump':
                jmp_callers[name].add(src_line)

    proc_starts = set()
    inner_globals = set()
    at_candidates = set()

    for name in label_defs:
        # Data table labels -> not procs
        if name in data_labels:
            continue

        # Existing B17_18_ names -> always proc_start
        if name.startswith('B17_18_'):
            proc_starts.add(name)
            continue

        # .word dispatch table target -> proc_start
        if name in word_targets:
            proc_starts.add(name)
            continue

        jsr_count = len(jsr_callers.get(name, set()))
        jmp_count = len(jmp_callers.get(name, set()))

        if jsr_count >= 2 or (jsr_count + jmp_count) >= 2:
            # Multiple callers -> own proc
            proc_starts.add(name)
        elif jsr_count == 1:
            # Single JSR target -> inner global (sub-scope inside parent)
            inner_globals.add(name)
        elif name not in refs or len(refs[name]) == 0:
            # Unreferenced -> inner global
            inner_globals.add(name)
        else:
            # Only branch and/or single JMP -> @ candidate
            at_candidates.add(name)

    return proc_starts, inner_globals, at_candidates, word_targets


# ============================================================================
# Phase 4: Proc Boundary Detection
# ============================================================================
def determine_proc_boundaries(proc_starts, inner_globals, label_defs,
                              label_addrs, line_addrs, lines,
                              inline_dispatch, data_ranges):
    """
    Determine proc boundaries.
    Returns list of (start_line, end_line, proc_name) sorted by start_line.
    """
    # Build set of data region lines
    data_lines = set()
    for start, end in data_ranges:
        for k in range(start, end + 1):
            data_lines.add(k)

    # Sort proc starts by line number
    sorted_procs = sorted(proc_starts, key=lambda n: label_defs[n])

    procs = []
    for i, name in enumerate(sorted_procs):
        start_line = label_defs[name]

        # Find the next boundary: next proc_start or data region
        if i + 1 < len(sorted_procs):
            next_proc_line = label_defs[sorted_procs[i + 1]]
        else:
            next_proc_line = len(lines)

        # Find earliest data region start after our start
        next_data_line = next_proc_line
        for ds, de in data_ranges:
            if ds > start_line and ds < next_data_line:
                next_data_line = ds

        max_end = min(next_proc_line, next_data_line) - 1

        # Walk FORWARD from start_line to find the last instruction
        # (RTS, RTI, or JMP) before max_end. This correctly excludes
        # comment headers of subsequent functions.
        end_line = start_line
        has_callback = False
        callback_end = start_line

        for k in range(start_line, max_end + 1):
            stripped = lines[k].strip()

            # Track inline dispatch tables
            if CALLBACK_RE.search(lines[k]):
                has_callback = True
                j = k + 1
                while j <= max_end:
                    s = lines[j].strip()
                    if j in inline_dispatch or s == '' or s.startswith(';'):
                        if j in inline_dispatch:
                            callback_end = max(callback_end, j)
                        j += 1
                    else:
                        break

            # Check if this is a terminator instruction
            instr = stripped.split(';', 1)[0].strip()
            if instr in ('RTS', 'RTI'):
                end_line = k
            elif instr.startswith('JMP ') and not instr.startswith('JMP ('):
                end_line = k
            elif stripped.startswith('.word') and k in inline_dispatch:
                # Inline dispatch .word entry - extend end
                end_line = k

        # If we found a callback, include its dispatch table
        if has_callback and callback_end > end_line:
            end_line = callback_end

        procs.append((start_line, end_line, name))

    return procs


# ============================================================================
# Phase 5: Verify & Promote (Iterative)
# ============================================================================
def verify_at_labels(at_candidates, refs, procs, label_defs):
    """Verify @ candidates: all refs must be from within the same proc."""
    safe = set()
    unsafe = set()

    for name in at_candidates:
        if not name.startswith('L'):
            safe.add(name)
            continue

        if name not in refs:
            safe.add(name)
            continue

        def_line = label_defs[name]
        containing_proc = _find_containing_proc(def_line, procs)

        if containing_proc is None:
            unsafe.add(name)
            continue

        all_in_proc = True
        for src_line, ref_type in refs[name]:
            src_proc = _find_containing_proc(src_line, procs)
            if src_proc != containing_proc:
                all_in_proc = False
                break

        if all_in_proc:
            safe.add(name)
        else:
            unsafe.add(name)

    return safe, unsafe


def _find_containing_proc(line_idx, procs):
    """Find which proc contains a given line."""
    for start, end, name in procs:
        if start <= line_idx <= end:
            return name
    return None


# ============================================================================
# Phase 6: Naming
# ============================================================================
def generate_names(proc_starts, at_labels, label_defs, label_addrs, refs,
                   lines, procs, word_targets):
    """
    Generate names for:
    1. New procs from LXXXX labels (dispatch handlers + multi-caller utils)
    2. @local labels for branch targets
    Returns:
      proc_rename: dict[LXXXX -> B17_18_name] for proc starts
      at_rename: dict[LXXXX -> @name] for @ labels
    """
    proc_rename = {}
    at_rename = {}

    # --- Build dispatch table context ---
    # For each JSR CallbackDispatcher, find the containing proc and collect targets
    dispatch_tables = []  # list of (containing_proc_name, [target_labels])
    for i, line in enumerate(lines):
        if CALLBACK_RE.search(line):
            containing = _find_containing_proc(i, procs)
            targets = []
            j = i + 1
            while j < len(lines):
                stripped = lines[j].strip()
                if stripped == '' or stripped.startswith(';'):
                    j += 1
                    continue
                wm = WORD_LABEL_RE.search(lines[j])
                if wm:
                    targets.append(wm.group(1))
                    j += 1
                else:
                    break
            if containing and targets:
                dispatch_tables.append((containing, targets))

    # --- Name dispatch table targets ---
    # Track which labels have been named
    named = set()

    # First pass: name dispatch targets (use renamed containing proc for prefix)
    for containing, targets in dispatch_tables:
        # Resolve containing proc name through rename map
        resolved = proc_rename.get(containing, containing)
        if resolved.startswith('B17_18_'):
            prefix = resolved.replace('B17_18_', '')
        else:
            prefix = resolved
        for idx, target in enumerate(targets):
            if target in named or target.startswith('B17_18_'):
                continue
            if target in NAME_OVERRIDES:
                proc_rename[target] = NAME_OVERRIDES[target]
            else:
                new_name = f"B17_18_{prefix}_{idx:02d}"
                proc_rename[target] = new_name
            named.add(target)

    # Second pass: name multi-caller procs not yet named
    for name in sorted(proc_starts, key=lambda n: label_defs[n]):
        if name.startswith('B17_18_'):
            continue
        if name in named:
            continue
        if name in NAME_OVERRIDES:
            proc_rename[name] = NAME_OVERRIDES[name]
        else:
            addr = label_addrs.get(name, 0)
            proc_rename[name] = f"B17_18_Sub_{addr:04X}"

    # --- Generate @ names for branch targets ---
    used_per_proc = defaultdict(set)
    sorted_at = sorted(at_labels, key=lambda n: label_defs[n])

    for name in sorted_at:
        if not name.startswith('L'):
            continue

        def_line = label_defs[name]
        ref_list = refs.get(name, [])

        # Determine branch direction
        has_backward = any(src > def_line for src, _ in ref_list)
        has_forward = any(src < def_line for src, _ in ref_list)

        if has_backward and not has_forward:
            base = 'loop'
        elif has_forward and not has_backward:
            # Check if target precedes RTS
            is_rts = False
            for j in range(def_line, min(def_line + 3, len(lines))):
                instr = lines[j].split(';', 1)[0].strip()
                if instr and not instr.startswith(';'):
                    if 'RTS' in instr:
                        is_rts = True
                    break
            base = 'done' if is_rts else 'skip'
        elif has_backward and has_forward:
            base = 'loop'
        else:
            base = 'target'

        # Find containing proc
        proc_name = _find_containing_proc(def_line, procs)

        at_name = f'@{base}'
        if proc_name:
            used = used_per_proc[proc_name]
            if at_name in used:
                suffix = 2
                while f'@{base}_{suffix}' in used:
                    suffix += 1
                at_name = f'@{base}_{suffix}'
            used.add(at_name)

        at_rename[name] = at_name

    return proc_rename, at_rename, dispatch_tables


# ============================================================================
# Phase 7: Emit Output
# ============================================================================
def apply_transformations(lines, procs, proc_rename, at_rename,
                           proc_starts, label_defs, inline_dispatch,
                           data_ranges):
    """Apply .proc/.endproc insertion and label renaming."""
    # Build lookup structures
    proc_start_lines = {}   # line_idx -> proc_name
    proc_end_lines = {}     # line_idx -> proc_name

    for start, end, name in procs:
        proc_start_lines[start] = name
        proc_end_lines[end] = name

    # Build data region set for labels that should stay bare
    data_label_lines = set()
    for ds, de in data_ranges:
        for k in range(ds, de + 1):
            data_label_lines.add(k)

    # Build rename map (combined proc_rename + at_rename)
    rename_map = {}
    rename_map.update(proc_rename)
    rename_map.update(at_rename)

    # Build rename regex patterns (sorted by length desc to avoid partial matches)
    sorted_old_names = sorted(rename_map.keys(), key=len, reverse=True)
    ref_patterns = []
    for old_name in sorted_old_names:
        new_name = rename_map[old_name]
        # Match in instruction contexts
        pat = re.compile(
            r'(\b(?:BCC|BCS|BEQ|BNE|BMI|BPL|BVC|BVS|JMP|JSR)\s+)'
            + re.escape(old_name) + r'\b')
        ref_patterns.append((pat, rf'\1{new_name}'))
        # Match in .word/.addr directives
        pat2 = re.compile(
            r'(\.(?:word|addr)\s+)' + re.escape(old_name) + r'\b')
        ref_patterns.append((pat2, rf'\1{new_name}'))
        # Match label definition
        def_pat = re.compile(r'^' + re.escape(old_name) + r':')
        ref_patterns.append((def_pat, f'{new_name}:'))

    # Generate output
    output = []
    in_proc = False
    current_proc = None
    procs_added = 0
    labels_renamed = 0

    for i, line in enumerate(lines):
        # Check if we need to add .endproc after previous line
        if in_proc and current_proc and (i - 1) in proc_end_lines:
            if proc_end_lines[i - 1] == current_proc:
                output.append('.endproc')
                in_proc = False
                current_proc = None

        # Check if this line starts a new proc
        if i in proc_start_lines:
            pname = proc_start_lines[i]
            # Use renamed name if available
            display_name = proc_rename.get(pname, pname)
            if in_proc and current_proc:
                # Close previous proc first (shouldn't normally happen)
                output.append('.endproc')
            # Generate comment header if this is a renamed proc (was LXXXX)
            if pname in proc_rename:
                # Check if there's already a comment header above
                has_header = False
                if i > 0 and COMMENT_BAR_RE.match(lines[i - 1].strip()):
                    has_header = True
                if not has_header:
                    addr = 0
                    for j in range(i, min(i + 3, len(lines))):
                        am = ADDR_COMMENT_RE.search(lines[j])
                        if am:
                            addr = int(am.group(1), 16)
                            break
                    output.append(HEADER_BAR)
                    output.append(f"; ${addr:04X}: {display_name}")
                    output.append(HEADER_BAR)
            output.append(f'.proc {display_name}')
            in_proc = True
            current_proc = pname
            procs_added += 1

        # Apply label renames
        new_line = line
        for pat, repl in ref_patterns:
            new_line = pat.sub(repl, new_line)

        if new_line != line:
            labels_renamed += 1

        output.append(new_line)

    # Close last proc if still open
    if in_proc:
        output.append('.endproc')
        procs_added += 1

    return output, procs_added, labels_renamed


# ============================================================================
# Main
# ============================================================================
def main():
    global addr_to_label_local

    dry_run = '--dry-run' in sys.argv
    verbose = '--verbose' in sys.argv

    asm_path = Path(__file__).parent.parent / 'asm' / 'banks' / 'prg_17_18.asm'
    lines = asm_path.read_text().splitlines()
    print(f"Read {len(lines)} lines from {asm_path}")

    # Phase 1: Parse
    print("\n=== Phase 1: Parse ===")
    label_defs, label_addrs, addr_to_label, line_addrs, refs = parse_file(lines)
    addr_to_label_local = addr_to_label
    print(f"  Label definitions: {len(label_defs)}")
    print(f"  Labels with references: {len(refs)}")

    # Phase 2: Data Region Detection
    print("\n=== Phase 2: Data Region Detection ===")
    inline_dispatch, data_ranges, data_labels = find_data_regions(
        lines, line_addrs, label_defs, label_addrs)
    print(f"  Inline dispatch entries: {len(inline_dispatch)}")
    print(f"  Data ranges: {len(data_ranges)}")
    print(f"  Data labels: {data_labels}")

    if verbose:
        for ds, de in sorted(data_ranges):
            addr_s = line_addrs.get(ds, '?')
            addr_e = line_addrs.get(de, '?')
            if isinstance(addr_s, int) and isinstance(addr_e, int):
                print(f"    ${addr_s:04X}-${addr_e:04X} (lines {ds}-{de})")
            else:
                print(f"    lines {ds}-{de}")

    # Phase 3: Label Classification
    print("\n=== Phase 3: Label Classification ===")
    proc_starts, inner_globals, at_candidates, word_targets = classify_labels(
        label_defs, label_addrs, refs, data_labels)
    print(f"  Proc starts: {len(proc_starts)}")
    print(f"  Inner globals: {len(inner_globals)}")
    print(f"  @ candidates: {len(at_candidates)}")
    print(f"  .word targets: {len(word_targets)}")

    # Phase 4-5: Iterative boundary detection and verification
    procs = None
    iteration = 0
    while True:
        iteration += 1
        print(f"\n=== Phase 4-5 iteration {iteration} ===")
        procs = determine_proc_boundaries(
            proc_starts, inner_globals, label_defs, label_addrs,
            line_addrs, lines, inline_dispatch, data_ranges)
        safe_at, unsafe_at = verify_at_labels(
            at_candidates, refs, procs, label_defs)
        print(f"  Procs: {len(procs)}, Safe @: {len(safe_at)}, Unsafe: {len(unsafe_at)}")

        if not unsafe_at or iteration > 10:
            break

        # Promote unsafe labels to proc_starts
        for name in unsafe_at:
            proc_starts.add(name)
            at_candidates.discard(name)
        print(f"  Promoted {len(unsafe_at)} labels to proc_starts")

    if verbose and unsafe_at:
        print("\n  Remaining unsafe labels:")
        for name in sorted(unsafe_at, key=lambda n: label_defs.get(n, 0)):
            addr = label_addrs.get(name, 0)
            print(f"    {name} ${addr:04X}")

    # Phase 6: Naming
    print("\n=== Phase 6: Naming ===")
    proc_rename, at_rename, dispatch_tables = generate_names(
        proc_starts, safe_at, label_defs, label_addrs, refs,
        lines, procs, word_targets)
    print(f"  Proc renames: {len(proc_rename)}")
    print(f"  @ renames: {len(at_rename)}")

    if verbose:
        print("\n  Proc renames:")
        for old in sorted(proc_rename.keys(),
                          key=lambda n: label_defs.get(n, 0)):
            addr = label_addrs.get(old, 0)
            print(f"    {old:10s} (${addr:04X}) -> {proc_rename[old]}")

        print("\n  @ renames:")
        for old in sorted(at_rename.keys(),
                          key=lambda n: label_defs.get(n, 0)):
            addr = label_addrs.get(old, 0)
            print(f"    {old:10s} (${addr:04X}) -> {at_rename[old]}")

        print("\n  Dispatch tables:")
        for containing, targets in dispatch_tables:
            print(f"    {containing}: {len(targets)} entries")
            for idx, t in enumerate(targets):
                renamed = proc_rename.get(t, t)
                print(f"      [{idx:2d}] {t} -> {renamed}")

    # Phase 7: Emit
    print("\n=== Phase 7: Emit ===")
    output, procs_added, labels_renamed = apply_transformations(
        lines, procs, proc_rename, at_rename,
        proc_starts, label_defs, inline_dispatch, data_ranges)
    print(f"  .proc/.endproc pairs: {procs_added // 2}")
    print(f"  Lines modified: {labels_renamed}")
    print(f"  Output lines: {len(output)} (was {len(lines)})")

    # Structural verification
    proc_count = sum(1 for l in output if l.strip().startswith('.proc '))
    endproc_count = sum(1 for l in output if l.strip() == '.endproc')
    print(f"\n  Structural check: .proc={proc_count}, .endproc={endproc_count}", end='')
    if proc_count == endproc_count:
        print(" OK")
    else:
        print(" MISMATCH!")

    at_count = sum(1 for l in output if re.match(r'^@\w+:', l.strip()))
    lproc_count = sum(1 for l in output if re.match(r'^\.proc L[A-F0-9]{4}$', l.strip()))
    print(f"  LXXXX proc names: {lproc_count}", end='')
    if lproc_count == 0:
        print(" OK")
    else:
        print(" FAIL - should be 0")

    # Write output
    if dry_run:
        print(f"\n[DRY RUN] Would write {len(output)} lines to {asm_path}")
    else:
        asm_path.write_text('\n'.join(output) + '\n')
        print(f"\nWrote {len(output)} lines to {asm_path}")

    # Summary
    print(f"\n=== Summary ===")
    print(f"  Total labels: {len(label_defs)}")
    print(f"  Proc starts: {len(proc_starts)}")
    print(f"  Inner globals: {len(inner_globals)}")
    print(f"  @ conversions: {len(safe_at)}")
    print(f"  Unsafe (promoted): {len(proc_starts) - len([n for n in proc_starts if n.startswith('B17_18_') or n in word_targets])}")
    print(f"  Dispatch tables found: {len(dispatch_tables)}")


if __name__ == '__main__':
    main()
