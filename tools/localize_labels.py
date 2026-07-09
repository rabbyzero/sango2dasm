#!/usr/bin/env python3
"""
localize_labels.py - Add .proc/.endproc and convert branch-only labels to @local
in prg_17_18.asm, matching the convention from prg_1f.asm.

Phase 1: Parse and build reference map
Phase 2: Classify labels (proc-start, inner-global, @local)
Phase 3: Determine proc boundaries
Phase 4: Verify safety of @ conversions
Phase 5: Generate @ names
Phase 6: Apply transformations (.proc, .endproc, label rename)

Usage:
    python3 tools/localize_labels.py [--dry-run] [--verbose]
"""

import re
import sys
from pathlib import Path
from collections import defaultdict

BRANCH_OPS = {'BCC', 'BCS', 'BEQ', 'BNE', 'BMI', 'BPL', 'BVC', 'BVS'}
BRANCH_RE = re.compile(
    r'^\s+(BCC|BCS|BEQ|BNE|BMI|BPL|BVC|BVS)\s+(L[A-F0-9]{4}|B17_18_\w+)\b')
JMP_RE = re.compile(
    r'^\s+JMP\s+(L[A-F0-9]{4}|B17_18_\w+)\b')
JSR_RE = re.compile(
    r'^\s+JSR\s+(L[A-F0-9]{4}|B17_18_\w+)\b')
WORD_RE = re.compile(
    r'\.word\s+(L[A-F0-9]{4}|B17_18_\w+)\b')
LABEL_DEF_RE = re.compile(
    r'^(L[A-F0-9]{4}|B17_18_\w+):')
ADDR_COMMENT_RE = re.compile(
    r';\s+\$([0-9A-Fa-f]{4}):')
COMMENT_BLOCK_BAR = ';' + '=' * 79


def parse_file(lines):
    """Parse file to extract label definitions and references."""
    label_defs = {}         # name -> line_idx
    label_addrs = {}        # name -> cpu_address
    addr_to_label = {}      # cpu_address -> name
    line_addrs = {}         # line_idx -> cpu_address

    refs = defaultdict(list)  # target_name -> [(line_idx, ref_type)]

    for i, line in enumerate(lines):
        # Extract CPU address from inline comment
        am = ADDR_COMMENT_RE.search(line)
        if am:
            addr = int(am.group(1), 16)
            line_addrs[i] = addr

        # Label definition
        lm = LABEL_DEF_RE.match(line)
        if lm:
            name = lm.group(1)
            label_defs[name] = i
            continue

        # Strip comment for instruction parsing
        instr = line.split(';', 1)[0]

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

        # .word reference
        for wm in WORD_RE.finditer(line):
            refs[wm.group(1)].append((i, 'table'))

    # Build address maps from label defs + nearby address comments
    for name, line_idx in label_defs.items():
        for j in range(line_idx, min(line_idx + 3, len(lines))):
            if j in line_addrs:
                label_addrs[name] = line_addrs[j]
                addr_to_label[line_addrs[j]] = name
                break

    return label_defs, label_addrs, addr_to_label, line_addrs, refs


def classify_labels(label_defs, refs):
    """Classify each L-label as proc-start, inner-global, or candidate for @local."""
    word_targets = set()
    jsr_call_counts = defaultdict(set)   # name -> set of source line indices
    jmp_call_counts = defaultdict(set)   # name -> set of source line indices

    for name, ref_list in refs.items():
        for src_line, ref_type in ref_list:
            if ref_type == 'table':
                word_targets.add(name)
            elif ref_type == 'call':
                jsr_call_counts[name].add(src_line)
            elif ref_type == 'jump':
                jmp_call_counts[name].add(src_line)

    proc_starts = set()    # Labels that start a new .proc
    inner_globals = set()  # Labels that stay global inside a proc (sub-scope)
    at_candidates = set()  # Labels that can become @local

    for name in label_defs:
        if name.startswith('B17_18_'):
            proc_starts.add(name)
            continue

        if name in word_targets:
            proc_starts.add(name)
            continue

        jsr_count = len(jsr_call_counts.get(name, set()))
        jmp_count = len(jmp_call_counts.get(name, set()))

        combined_call_jump = jsr_count + jmp_count

        if jsr_count >= 2 or combined_call_jump >= 2:
            # Called/jumped from multiple places: shared subroutine -> own proc
            proc_starts.add(name)
        elif jsr_count == 1:
            # Single JSR target: stays global (creates sub-scope for its internal labels)
            inner_globals.add(name)
        elif name not in refs or len(refs[name]) == 0:
            # Unreferenced label: keep as-is
            inner_globals.add(name)
        else:
            # Only branch and/or single JMP references: @ candidate
            at_candidates.add(name)

    return proc_starts, inner_globals, at_candidates, word_targets


def determine_proc_boundaries(proc_starts, inner_globals, label_defs, label_addrs, lines):
    """
    Determine proc boundaries.
    A proc starts at a proc_start label and ends just before the next proc_start label
    (accounting for data regions and comment blocks in between).
    Returns: list of (start_line, end_line, proc_name) sorted by start_line.
    """
    # Sort proc starts by line number
    sorted_procs = sorted(proc_starts, key=lambda n: label_defs[n])

    # For each proc_start, determine where it ends
    # The proc includes all code and inner_global labels up to (but not including)
    # the next proc_start or a data-only gap.
    procs = []

    for i, name in enumerate(sorted_procs):
        start_line = label_defs[name]

        # Find the next proc_start line
        if i + 1 < len(sorted_procs):
            next_proc_line = label_defs[sorted_procs[i + 1]]
        else:
            next_proc_line = len(lines)

        # The proc extends from start_line to just before next_proc_line
        # But we need to exclude trailing data/comment blocks
        end_line = next_proc_line - 1

        # Walk backward from end_line to find the last content line
        # Skip blank lines and non-separator comment lines
        while end_line > start_line:
            stripped = lines[end_line].strip()
            if stripped == '':
                end_line -= 1
            elif stripped.startswith(';') and not stripped.startswith(';='):
                end_line -= 1
            else:
                break

        # If we stopped at a ;=== comment bar, exclude the entire comment block
        # (typically 3 lines: bar + content + bar, preceded by optional blank line)
        if end_line > start_line and lines[end_line].strip().startswith(';='):
            end_line -= 1  # skip this bar
            if end_line > start_line and lines[end_line].strip().startswith(';'):
                end_line -= 1  # skip content line
            if end_line > start_line and lines[end_line].strip().startswith(';='):
                end_line -= 1  # skip top bar
            # Also skip a preceding ;--- section marker
            if end_line > start_line and re.match(r'^;---', lines[end_line].strip()):
                end_line -= 1
            # Skip blank lines before the comment block
            while end_line > start_line and lines[end_line].strip() == '':
                end_line -= 1

        # If the last line is a comment or directive, check if there's a
        # .word dispatch table that should be included (follows JSR CallbackDispatcher)
        # Walk backward past comments and .word/.byte to find last code line
        code_end = end_line
        while code_end > start_line:
            stripped = lines[code_end].strip()
            if stripped == '' or stripped.startswith(';') or stripped.startswith('.'):
                code_end -= 1
            else:
                break

        # Check if the code is followed by a .word dispatch table
        # (pattern: JSR B1F_CallbackDispatcher then .word entries)
        if code_end >= start_line:
            code_line = lines[code_end]
            if 'CallbackDispatcher' in code_line:
                # Include all .word entries that follow
                scan = code_end + 1
                while scan <= end_line:
                    stripped = lines[scan].strip()
                    if stripped.startswith('.word') or stripped.startswith(';') or stripped == '':
                        scan += 1
                    else:
                        break
                end_line = scan - 1

        # If the proc is all non-code, skip it
        if code_end < start_line:
            end_line = start_line

        procs.append((start_line, end_line, name))

    return procs


def find_containing_proc(line_idx, procs):
    """Find which proc contains a given line. Returns proc name or None."""
    for start, end, name in procs:
        if start <= line_idx <= end:
            return name
    return None


def verify_at_labels(at_candidates, refs, procs, label_defs):
    """
    Verify each @ candidate: all references must be from within the same proc.
    Returns (safe_set, unsafe_set).
    """
    safe = set()
    unsafe = set()

    for name in at_candidates:
        if name not in refs:
            # No references at all - safe to convert (dead label)
            safe.add(name)
            continue

        def_line = label_defs[name]
        containing_proc = find_containing_proc(def_line, procs)

        if containing_proc is None:
            # Label not in any proc - keep global
            unsafe.add(name)
            continue

        all_in_proc = True
        for src_line, ref_type in refs[name]:
            src_proc = find_containing_proc(src_line, procs)
            if src_proc != containing_proc:
                all_in_proc = False
                break

        if all_in_proc:
            safe.add(name)
        else:
            unsafe.add(name)

    return safe, unsafe


def generate_at_names(at_labels, label_defs, refs, lines):
    """
    Generate descriptive @names for each @ label.
    Uses branch direction and context to pick meaningful names.
    """
    rename_map = {}  # old_name -> @new_name
    used_names_per_proc = defaultdict(set)

    # Sort by line number for deterministic ordering
    sorted_labels = sorted(at_labels, key=lambda n: label_defs[n])

    for name in sorted_labels:
        def_line = label_defs[name]
        ref_list = refs.get(name, [])

        # Determine branch direction
        has_backward = any(src > def_line for src, _ in ref_list)
        has_forward = any(src < def_line for src, _ in ref_list)

        if has_backward and not has_forward:
            base = 'loop'
        elif has_forward and not has_backward:
            # Check if it's an RTS
            next_code = ''
            for j in range(def_line, min(def_line + 3, len(lines))):
                stripped = lines[j].split(';', 1)[0].strip()
                if stripped and not stripped.startswith(';'):
                    next_code = stripped
                    break
            if 'RTS' in next_code:
                base = 'done'
            else:
                base = 'skip'
        elif has_backward and has_forward:
            base = 'loop'  # Both directions: likely a loop with exit
        else:
            base = 'target'

        # Try simple name first, then add suffix
        at_name = f'@{base}'

        # Find the containing proc for uniqueness check
        proc_name = None
        for start, end, pname in procs_data:
            if start <= def_line <= end:
                proc_name = pname
                break

        if proc_name:
            used = used_names_per_proc[proc_name]
            if at_name in used:
                # Add numeric suffix
                suffix = 2
                while f'@{base}_{suffix}' in used:
                    suffix += 1
                at_name = f'@{base}_{suffix}'
            used.add(at_name)

        rename_map[name] = at_name

    return rename_map


def apply_transformations(lines, procs, rename_map, proc_starts, label_defs, dry_run=False):
    """Apply .proc/.endproc insertion and label renaming."""
    # Build lookup structures
    proc_start_lines = {}   # line_idx -> proc_name
    proc_end_lines = {}     # line_idx -> proc_name

    for start, end, name in procs:
        proc_start_lines[start] = name
        proc_end_lines[end] = name

    # Build set of lines that need label renames
    # (both definitions and references)
    rename_targets = set(rename_map.keys())

    # Build regex for replacing references
    # Sort by length descending to avoid partial matches
    sorted_old_names = sorted(rename_targets, key=len, reverse=True)
    ref_patterns = []
    for old_name in sorted_old_names:
        new_name = rename_map[old_name]
        # Match in branch, JMP, JSR, .word contexts
        pat = re.compile(
            r'(\b(?:BCC|BCS|BEQ|BNE|BMI|BPL|BVC|BVS|JMP|JSR)\s+)'
            + re.escape(old_name) + r'\b')
        ref_patterns.append((pat, rf'\1{new_name}'))
        # Also match label definition
        def_pat = re.compile(r'^' + re.escape(old_name) + r':')
        ref_patterns.append((def_pat, f'{new_name}:'))

    # Generate output
    output = []
    in_proc = False
    current_proc = None
    procs_added = 0
    labels_renamed = 0

    for i, line in enumerate(lines):
        # Check if we need to add .endproc before this line
        if in_proc and current_proc and i - 1 in proc_end_lines:
            if proc_end_lines[i - 1] == current_proc:
                output.append('.endproc')
                in_proc = False
                current_proc = None

        # Check if this line starts a new proc
        if i in proc_start_lines:
            pname = proc_start_lines[i]
            if in_proc and current_proc:
                # Close previous proc first
                output.append('.endproc')
                procs_added += 1
            output.append(f'.proc {pname}')
            in_proc = True
            current_proc = pname
            procs_added += 1

        # Apply label renames to this line
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


def main():
    global procs_data

    dry_run = '--dry-run' in sys.argv
    verbose = '--verbose' in sys.argv

    asm_path = Path(__file__).parent.parent / 'asm' / 'banks' / 'prg_17_18.asm'
    lines = asm_path.read_text().splitlines()
    print(f"Read {len(lines)} lines from {asm_path}")

    # Phase 1: Parse
    print("\n=== Phase 1: Parse and build reference map ===")
    label_defs, label_addrs, addr_to_label, line_addrs, refs = parse_file(lines)
    print(f"  Label definitions: {len(label_defs)}")
    print(f"  Labels with references: {len(refs)}")

    # Phase 2: Classify
    print("\n=== Phase 2: Classify labels ===")
    proc_starts, inner_globals, at_candidates, word_targets = classify_labels(
        label_defs, refs)
    print(f"  Proc starts: {len(proc_starts)}")
    print(f"  Inner globals (sub-scope): {len(inner_globals)}")
    print(f"  @ candidates: {len(at_candidates)}")
    print(f"  .word targets: {len(word_targets)}")

    if verbose:
        print("\n  Proc starts:")
        for name in sorted(proc_starts, key=lambda n: label_defs.get(n, 0)):
            addr = label_addrs.get(name, 0)
            print(f"    {name:30s} ${addr:04X} (line {label_defs.get(name, '?')})")

    # Phase 3-4: Iterative boundary determination and verification
    # Promote unsafe @ candidates to proc_starts until no unsafe labels remain
    iteration = 0
    while True:
        iteration += 1
        print(f"\n=== Phase 3-4 iteration {iteration} ===")
        procs = determine_proc_boundaries(
            proc_starts, inner_globals, label_defs, label_addrs, lines)
        safe_at, unsafe_at = verify_at_labels(at_candidates, refs, procs, label_defs)
        print(f"  Procs: {len(procs)}, Safe: {len(safe_at)}, Unsafe: {len(unsafe_at)}")

        if not unsafe_at or iteration > 10:
            break

        # Promote unsafe labels to proc_starts (they have cross-proc refs)
        promoted = set()
        for name in unsafe_at:
            proc_starts.add(name)
            at_candidates.discard(name)
            promoted.add(name)
        print(f"  Promoted {len(promoted)} labels to proc_starts: {sorted(promoted)}")

    procs_data = procs

    if unsafe_at and verbose:
        print("\n  Remaining unsafe labels (keeping global):")
        for name in sorted(unsafe_at, key=lambda n: label_defs.get(n, 0)):
            addr = label_addrs.get(name, 0)
            ref_info = [(src, rt) for src, rt in refs.get(name, [])]
            print(f"    {name} ${addr:04X}: refs={ref_info}")

    # Phase 5: Generate @ names
    print("\n=== Phase 5: Generate @ names ===")
    rename_map = generate_at_names(safe_at, label_defs, refs, lines)
    print(f"  Labels to rename: {len(rename_map)}")

    if verbose:
        print("\n  Rename map:")
        for old, new in sorted(rename_map.items(), key=lambda x: label_defs.get(x[0], 0)):
            addr = label_addrs.get(old, 0)
            print(f"    {old:10s} (${addr:04X}) -> {new}")

    # Phase 6: Apply transformations
    print("\n=== Phase 6: Apply transformations ===")
    output, procs_added, labels_renamed = apply_transformations(
        lines, procs, rename_map, proc_starts, label_defs, dry_run)
    print(f"  .proc/.endproc pairs added: {procs_added // 2}")
    print(f"  Lines modified: {labels_renamed}")
    print(f"  Output lines: {len(output)} (was {len(lines)})")

    # Write output
    if dry_run:
        print(f"\n[DRY RUN] Would write to {asm_path}")
        # Show first few procs as sample
        print("\n  Sample output (first 50 lines with .proc):")
        shown = 0
        for i, line in enumerate(output):
            if '.proc' in line or '.endproc' in line or line.startswith('@'):
                print(f"    {i:5d}: {line}")
                shown += 1
                if shown > 50:
                    break
    else:
        asm_path.write_text('\n'.join(output) + '\n')
        print(f"\nWrote {len(output)} lines to {asm_path}")

    # Summary
    print(f"\n=== Summary ===")
    print(f"  Total labels: {len(label_defs)}")
    print(f"  Proc starts: {len(proc_starts)}")
    print(f"  Inner globals: {len(inner_globals)}")
    print(f"  @ conversions: {len(safe_at)}")
    print(f"  Unsafe (kept global): {len(unsafe_at)}")
    print(f"  .proc blocks: {procs_added // 2}")


if __name__ == '__main__':
    main()
