#!/usr/bin/env python3
"""
Globalize $04xx RAM definitions in prg_17_18.asm.

1. Insert a global $04xx definition block (outside .proc)
2. Remove all local $04xx = $04XX definitions from inside .proc blocks
3. Replace old alias names with canonical names in instruction lines
"""

import re
import sys

# Canonical name mapping: address -> (canonical_name, comment)
# Based on analysis of all aliases and usage patterns
CANONICAL = {
    0x0400: ("ptr_0400_lo",          ""),
    0x0401: ("ptr_0400_hi",          ""),
    0x0402: ("state_0402",           ""),
    0x0408: ("scroll_ptr_lo",        ""),
    0x0409: ("scroll_ptr_hi",        ""),
    0x040A: ("state_040a",           ""),
    0x040C: ("ptr_040c_lo",          ""),
    0x040D: ("ptr_040c_hi",          ""),
    0x040E: ("ptr_040e_lo",          ""),
    0x040F: ("ptr_040e_hi",          ""),
    0x0410: ("ptr_0410_lo",          ""),
    0x0411: ("ptr_0410_hi",          ""),
    0x0424: ("ptr_0424_lo",          ""),
    0x0425: ("ptr_0424_hi",          ""),
    0x042C: ("selected_officer_id",  "Active/selected officer ID"),
    0x042D: ("ptr_042c_hi",          ""),
    0x042E: ("state_042e",           ""),
    0x042F: ("ptr_042f_lo",          ""),
    0x0430: ("ptr_042f_hi",          ""),
    0x0431: ("state_0431",           ""),
    0x0435: ("state_0435",           ""),
    0x046C: ("state_046c",           ""),
    0x0470: ("ptr_0470_lo",          ""),
    0x0471: ("ptr_0470_hi",          ""),
    0x0472: ("ptr_0472_lo",          ""),
    0x0473: ("ptr_0472_hi",          ""),
    0x04A8: ("game_state",           "Major game state (0-14), indexes dispatch table"),
    0x04A9: ("sub_state",            "Sub-state within each major state"),
    0x04AA: ("active_player_slot",   "Current player index (0 or 1)"),
    0x04AB: ("player_flag_0",        "Player 0 flag/status byte"),
    0x04AD: ("player_officer_id_0",  "Officer ID for player 0"),
    0x04AE: ("player_officer_id_1",  "Officer ID for player 1"),
    0x04AF: ("name_tile_index",      "Name tile / scroll tile data index"),
    0x04B0: ("state_04b0",           ""),
    0x04B1: ("player_army_value_0",  "Army value for player 0"),
    0x04B2: ("player_army_value_1",  "Army value for player 1"),
    0x04B3: ("player_random_offset_0", "Random offset for player 0"),
    0x04B5: ("player_action_timer_0", "Action timer for player 0"),
    0x04B8: ("anim_timer",           "Animation / scroll timer"),
    0x04B9: ("state_04b9",           ""),
    0x04BA: ("scroll_row_count",     "Scroll row count / sprite base"),
    0x04BB: ("slide_y_pos",          "Slide Y position / state"),
    0x04BC: ("state_04bc",           ""),
    0x04BD: ("display_ptr_lo",       "Display/map pointer low"),
    0x04BE: ("display_ptr_hi",       "Display/map pointer high"),
    0x04BF: ("sub_action_type",      "Sub-action type selector"),
    0x04C0: ("frame_counter",        "Frame counter"),
    0x04C1: ("state_04c1",           ""),
    0x04C3: ("event_overlay_flag",   "Event overlay / battle formation flag"),
    0x04C4: ("state_04c4",           ""),
    0x04C5: ("ptr_04c5_lo",          ""),
    0x04C6: ("ptr_04c5_hi",          ""),
    0x04C9: ("state_04c9",           ""),
    0x04CA: ("ptr_04ca_lo",          ""),
    0x04CB: ("ptr_04ca_hi",          ""),
    0x04CD: ("ptr_04cd_lo",          ""),
    0x04CE: ("ptr_04cd_hi",          ""),
    0x04D2: ("ptr_04d2_lo",          ""),
    0x04D3: ("ptr_04d2_hi",          ""),
    0x04D4: ("ptr_04d4_lo",          ""),
    0x04D5: ("ptr_04d4_hi",          ""),
}

# Build reverse map: old_alias_name -> canonical_name
# We collect ALL alias names seen in the file and map them to canonical
def build_alias_map(lines):
    """Find all local `name = $04XX` definitions and map name -> canonical."""
    pattern = re.compile(r'^\s*(\w+)\s*=\s*\$(04[0-9A-Fa-f]{2})\s*$')
    alias_map = {}
    for line in lines:
        m = pattern.match(line)
        if m:
            name = m.group(1)
            addr = int(m.group(2), 16)
            if addr in CANONICAL:
                canonical = CANONICAL[addr][0]
                if name != canonical:
                    alias_map[name] = canonical
    return alias_map

def make_global_block():
    """Generate the global definition block text."""
    lines = []
    lines.append("; --- Game State RAM ($04xx) ---")
    lines.append("; Shared state variables used across main game dispatch procs.")
    
    # Group by functional area
    groups = {
        "Pointer/State ($0400-$0411)": range(0x0400, 0x0412),
        "Officer/Selection ($0424-$0435)": list(range(0x0424, 0x0426)) + list(range(0x042C, 0x0436)) + [0x046C],
        "Map/Scroll pointers ($0470-$0473)": range(0x0470, 0x0474),
        "Main game state ($04A8-$04C0)": range(0x04A8, 0x04C7),
        "Extended state ($04C9-$04D5)": list(range(0x04C9, 0x04CB)) + list(range(0x04CD, 0x04CF)) + list(range(0x04D2, 0x04D6)),
    }
    
    for group_name, addrs in groups.items():
        # Check if any address in this group is in CANONICAL
        has_entries = any(a in CANONICAL for a in addrs)
        if has_entries:
            lines.append(f"; {group_name}")
            for addr in addrs:
                if addr in CANONICAL:
                    name, comment = CANONICAL[addr]
                    addr_str = f"${addr:04X}"
                    defn = f"{name:<28s} = {addr_str}"
                    if comment:
                        defn += f"  ; {comment}"
                    lines.append(defn)
        # Also handle 0x04C3, 0x04C4 which are in extended range
        if group_name == "Extended state ($04C9-$04D5)":
            pass
    
    # Handle $04C3-$04C4 which fall between main and extended
    # They're already in main range
    
    lines.append("")
    return "\n".join(lines)


def main():
    filepath = "asm/banks/prg_17_18.asm"
    
    with open(filepath, 'r') as f:
        lines = f.readlines()
    
    # Step 1: Build alias map
    alias_map = build_alias_map(lines)
    print(f"Found {len(alias_map)} alias names to remap:")
    for old, new in sorted(alias_map.items()):
        print(f"  {old} -> {new}")
    
    # Step 2: Generate global block
    global_block = make_global_block()
    
    # Step 3: Process file
    output_lines = []
    local_def_pattern = re.compile(r'^\s*(\w+)\s*=\s*\$(04[0-9A-Fa-f]{2})\s*$')
    in_proc = False
    defs_removed = 0
    refs_renamed = 0
    global_inserted = False
    
    for i, line in enumerate(lines):
        # Detect .proc / .endproc
        stripped = line.strip()
        if stripped.startswith('.proc '):
            in_proc = True
        elif stripped == '.endproc':
            in_proc = False
        
        # Remove local $04xx definitions inside .proc blocks
        if in_proc:
            m = local_def_pattern.match(line)
            if m:
                addr = int(m.group(2), 16)
                if addr in CANONICAL:
                    defs_removed += 1
                    continue  # skip this line
        
        # Insert global block before .segment "CODE_BANK17"
        if not global_inserted and stripped == '.segment "CODE_BANK17"':
            output_lines.append(global_block + "\n")
            global_inserted = True
        
        # Rename old aliases in instruction/usage lines
        new_line = line
        for old_name, new_name in alias_map.items():
            # Replace whole-word occurrences of old alias
            # Use word boundary to avoid partial matches
            pattern = re.compile(r'\b' + re.escape(old_name) + r'\b')
            result = pattern.sub(new_name, new_line)
            if result != new_line:
                refs_renamed += 1
                new_line = result
        
        output_lines.append(new_line)
    
    # Step 4: Write output
    with open(filepath, 'w') as f:
        f.writelines(output_lines)
    
    print(f"\nResults:")
    print(f"  Local definitions removed: {defs_removed}")
    print(f"  References renamed: {refs_renamed}")
    print(f"  Global block inserted: {global_inserted}")


if __name__ == "__main__":
    main()
