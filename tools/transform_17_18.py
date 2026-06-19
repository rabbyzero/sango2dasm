#!/usr/bin/env python3
"""
transform_17_18.py - Transform prg_17_18.asm with section headers
and semantic B17_18_ naming.

Pass 1: Jump table entries and their immediate callees.
- Adds section headers for identified functions and data regions
- Renames LXXXX labels to semantic B17_18_ names
- Replaces JSR/JMP/.word references to renamed labels
- Does NOT add .proc/.endproc (deferred to pass 2 to avoid scoping issues)

Usage:
    python3 tools/transform_17_18.py [--dry-run]
"""

import re
import sys
from pathlib import Path

# ============================================================================
# Region Map for Pass 1
#
# Each entry: (start_addr, end_addr_exclusive, name, type, description)
# type: 'func', 'data', 'table'
#
# Boundaries determined by tracing through the assembly.
# Functions end at RTS, tail-call JMP, or the start of the next region.
# ============================================================================

REGION_MAP = [
    # === Bank $17 ($A000-$BFFF) ===

    # Jump table: 14 JMP entries ($A000-$A029)
    (0xA000, 0xA02A, "JumpTable", "table",
     "Jump Table - Public entry points ($A000-$A029)"),

    # Entry0C target: domestic affairs display
    (0xA02A, 0xA04A, "DomesticDisplay", "func",
     "Entry0C: Domestic affairs display (switches bank $21)"),

    # Helper: setup display pointers from $0544
    (0xA04A, 0xA06B, "SetupDisplayPtrs", "func",
     "Setup display pointers from $0544 index"),

    # Data: tile pointer table (28 bytes)
    (0xA06B, 0xA087, "DomesticTilePtrs", "table",
     "Domestic tile/attribute pointer table"),

    # Entry00: RLE PPU writer
    (0xA087, 0xA0D2, "PpuWriteRle", "func",
     "Entry00: RLE-encoded PPU data writer"),

    # Helper: increment $000A/B source pointer
    (0xA0D2, 0xA0E4, "AdvanceSrcPtr", "func",
     "Advance source data pointer ($000A/$000B)"),

    # Raw PPU row writer (multiple exit paths)
    (0xA0E4, 0xA1A4, "PpuWriteRawRows", "func",
     "PPU raw row writer with RLE decompression"),

    # Orphan byte at $A1A4

    # Read next byte from RLE stream
    (0xA1A5, 0xA209, "ReadRleByte", "func",
     "Read next byte from RLE-encoded data stream"),

    # Second pointer increment helper
    (0xA209, 0xA212, "AdvanceSrcPtr2", "func",
     "Advance source pointer ($000A/$000B) - variant 2"),

    # Entry01: raw PPU copy
    (0xA212, 0xA24E, "PpuCopyRaw", "func",
     "Entry01: Raw 1KB PPU data copy"),

    # Entry02: tile data with offset calculation
    (0xA24E, 0xA2E4, "PpuWriteTileOffset", "func",
     "Entry02: PPU tile data write with offset calculation"),

    # Helper: advance tile pointer
    (0xA2E4, 0xA2ED, "AdvanceTilePtr", "func",
     "Advance tile data pointer"),

    # Helper: subtract 16 from tile pointer
    (0xA2ED, 0xA2FF, "RewindTilePtr16", "func",
     "Rewind tile pointer by 16 bytes"),

    # Entry03: scroll + render loop
    (0xA2FF, 0xA387, "DisplayScrollLoop", "func",
     "Entry03: Display scroll and render loop"),

    # Entry04: display coordinate check
    (0xA387, 0xA3B1, "DisplayAndChrSetup", "func",
     "Entry04: Display coordinate check + CHR setup"),

    # Helper called from DisplayAndChrSetup
    (0xA3B1, 0xA3BC, "DisplayUpdateScroll", "func",
     "Display update scroll registers"),

    # Large rendering function
    (0xA3BC, 0xA61C, "DisplayRenderScene", "func",
     "Display render scene (bank switching + rendering + helpers)"),

    # Entry06: battle dispatch
    (0xA61C, 0xA642, "BattleDispatch", "func",
     "Entry06: Battle dispatch (bank switch + pointer lookup)"),

    # Data: battle screen tile/attribute data + PPU address tables
    (0xA642, 0xA89A, "BattleTileData", "table",
     "Battle screen tile data and PPU address tables"),

    # Battle attribute setup + helper subroutines
    (0xA89A, 0xA983, "BattleAttrAndHelpers", "func",
     "Battle attribute setup + helper subroutines"),

    # Entry08: advisor dialogue system
    (0xA983, 0xAB53, "AdvisorDialogue", "func",
     "Entry08: Advisor/council dialogue system"),

    # Entry05: battle visual effects
    (0xAB53, 0xAEF0, "BattleEffects", "func",
     "Entry05: Battle visual effects (animations, palette, sprites)"),

    # Entry07: overlay/window rendering
    (0xAEF0, 0xB100, "OverlayWindow", "func",
     "Entry07: Overlay/window rendering (bank switch + dispatch)"),

    # Entry09: main game mode dispatcher (22-entry table)
    (0xB100, 0xB144, "MainGameDispatch", "func",
     "Entry09: Main game mode dispatcher (22-entry dispatch table)"),

    # Sub-dispatcher: 8-entry table for mode 09
    (0xB144, 0xB15A, "SubDispatch_Mode09", "func",
     "Sub-dispatcher: mode 09 (8-entry dispatch table)"),

    # === Bank $18 ($C000-$DFFF) ===

    # Data: tile/map lookup table
    (0xC000, 0xC08A, "TileLookupTable", "table",
     "Tile/map lookup table ($C000-$C089)"),

    # Entry0A: domestic action dispatch (6-entry table)
    (0xD693, 0xD69E, "DomesticActionDispatch", "func",
     "Entry0A: Domestic action dispatch (6-entry dispatch table)"),

    # Entry0A state 0: init
    (0xD69E, 0xD6AA, "DomAction_State0_Init", "func",
     "Domestic action state 0: Initialize"),

    # Entry0B: animation dispatch (5-entry table)
    (0xDE25, 0xDE34, "AnimationDispatch", "func",
     "Entry0B: Animation dispatch"),

    # Data: animation frame index table
    (0xDEA0, 0xDEB9, "AnimFrameTable", "table",
     "Animation frame index table"),

    # Sprite placement from table
    (0xDEFA, 0xDF15, "SpriteFromTable", "func",
     "Sprite OAM placement from table"),

    # Entry0D: data record loader
    (0xDF15, 0xDF4A, "DataRecordLoader", "func",
     "Entry0D: Data record loader (pointer table lookup)"),

    # Data: pointer + permutation tables
    (0xDF4A, 0xE000, "DataRecordPtrs", "table",
     "Data record pointer table + permutation table"),
]


def main():
    dry_run = "--dry-run" in sys.argv

    asm_path = Path(__file__).parent.parent / "asm" / "banks" / "prg_17_18.asm"
    lines = asm_path.read_text().splitlines()

    # --- Regex patterns ---
    addr_re = re.compile(r';\s+\$([0-9A-Fa-f]{4}):')
    label_re = re.compile(r'^(L[A-Fa-f0-9]{4}|B17_18_\w+):$')
    # Labels that may appear at region boundaries (also match B17_18_Target*)
    known_label_re = re.compile(r'^(L[A-Fa-f0-9]{4}|B17_18_\w+):')

    # --- Build address index ---
    addr_to_line = {}  # cpu_address -> line_index
    for i, line in enumerate(lines):
        m = addr_re.search(line)
        if m:
            addr = int(m.group(1), 16)
            addr_to_line[addr] = i

    # --- Build label -> address map ---
    label_to_addr = {}
    label_line_idx = {}  # label_name -> line_index
    for i, line in enumerate(lines):
        m = label_re.match(line)
        if m:
            lbl = m.group(1)
            label_line_idx[lbl] = i
            # Find address from next line with address comment
            for j in range(i, min(i + 3, len(lines))):
                am = addr_re.search(lines[j])
                if am:
                    label_to_addr[lbl] = int(am.group(1), 16)
                    break

    # --- Build address -> new_name map ---
    addr_to_name = {}
    for start, end, name, ftype, desc in REGION_MAP:
        if name != "JumpTable":
            full_name = f"B17_18_{name}"
            addr_to_name[start] = full_name

    # --- Build label -> new_name map ---
    label_to_name = {}
    for lbl, addr in label_to_addr.items():
        if addr in addr_to_name:
            label_to_name[lbl] = addr_to_name[addr]

    # --- Build set of addresses that start a region ---
    region_starts = set()
    for start, end, name, ftype, desc in REGION_MAP:
        region_starts.add(start)

    # --- Sort regions by start address ---
    sorted_regions = sorted(REGION_MAP, key=lambda x: x[0])

    # --- Determine which region each line belongs to ---
    line_region = [None] * len(lines)

    # Step 1: Assign lines with known addresses to regions
    for ri, (start, end, name, ftype, desc) in enumerate(sorted_regions):
        for addr, li in addr_to_line.items():
            if start <= addr < end:
                line_region[li] = ri

    # Step 2: Assign non-addressed lines (labels, comments, blanks) to the
    # region of the immediately following line. Only if the next line is
    # already in a region, to avoid crossing region boundaries.
    for i in range(len(lines) - 2, -1, -1):
        if line_region[i] is None and line_region[i + 1] is not None:
            line = lines[i]
            # Assign labels, comments, and blank lines that are sandwiched
            # between addressed lines in the same region
            if (label_re.match(line) or line.strip() == ""
                    or line.lstrip().startswith(";")):
                line_region[i] = line_region[i + 1]

    # --- Build label rename regex cache ---
    # Sort by length descending to avoid partial matches
    rename_patterns = []
    for old_lbl, new_name in sorted(label_to_name.items(),
                                     key=lambda x: -len(x[0])):
        # Match label as operand in JSR, JMP, .word, branch instructions
        pat = re.compile(rf'(\b(?:JSR|JMP|BEQ|BNE|BCC|BCS|BMI|BPL|BVC|BVS)\s+){re.escape(old_lbl)}\b')
        rename_patterns.append((pat, rf'\1{new_name}'))
        # Match in .word directives
        pat2 = re.compile(rf'(\.word\s+){re.escape(old_lbl)}\b')
        rename_patterns.append((pat2, rf'\1{new_name}'))

    # --- Emit transformed output ---
    output = []
    current_region = None
    header_bar = ";=" * 40
    regions_emitted = 0
    labels_renamed = 0

    def emit_region_header(ri):
        nonlocal regions_emitted
        start, end, name, ftype, desc = sorted_regions[ri]
        output.append("")
        output.append(f"{header_bar}")
        if ftype == "func":
            output.append(f"; ${start:04X}: B17_18_{name}")
        else:
            output.append(f"; ${start:04X}: {desc}")
        output.append(f"; {desc}")
        output.append(f"{header_bar}")
        regions_emitted += 1

    for i, line in enumerate(lines):
        ri = line_region[i]
        lm = label_re.match(line)

        # --- Region transition ---
        if ri is not None and ri != current_region:
            # Entering a new region
            emit_region_header(ri)
            current_region = ri

            # If this line is a label for the region start, rename it
            if lm and lm.group(1) in label_to_name:
                new_name = label_to_name[lm.group(1)]
                output.append(f"{new_name}:")
                labels_renamed += 1
                continue

        elif ri is None and current_region is not None:
            # Leaving a region - no footer needed (no .proc)
            current_region = None

        # --- Rename standalone label lines ---
        if lm and lm.group(1) in label_to_name:
            new_name = label_to_name[lm.group(1)]
            output.append(f"{new_name}:")
            labels_renamed += 1
            continue

        # --- Rename label references in instruction operands ---
        new_line = line
        for pat, repl in rename_patterns:
            new_line = pat.sub(repl, new_line)

        output.append(new_line)

    # --- Remove leading blank line if added ---
    if output and output[0] == "":
        output[0] = output[0]  # keep it, it's fine

    # --- Output ---
    if dry_run:
        print(f"Would write {len(output)} lines to {asm_path}")
        print(f"\nRegions: {regions_emitted}")
        print(f"Labels renamed: {labels_renamed}")
        print(f"Lines: {len(lines)} -> {len(output)}")

        print("\nRegion summary:")
        for start, end, name, ftype, desc in sorted_regions:
            size = end - start
            print(f"  ${start:04X}-${end:04X} ({size:4d} bytes) "
                  f"[{ftype:5s}] B17_18_{name}")

        print("\nLabel renames:")
        for old_lbl in sorted(label_to_name.keys(),
                               key=lambda x: label_to_addr[x]):
            addr = label_to_addr[old_lbl]
            new_name = label_to_name[old_lbl]
            print(f"  {old_lbl} (${addr:04X}) -> {new_name}")
    else:
        asm_path.write_text("\n".join(output) + "\n")
        print(f"Wrote {len(output)} lines to {asm_path}")
        print(f"\nRegions: {regions_emitted}")
        print(f"Labels renamed: {labels_renamed}")
        print(f"Lines: {len(lines)} -> {len(output)}")


if __name__ == "__main__":
    main()
