#!/usr/bin/env python3
"""Debug: check region transitions in transform_17_18.py"""
import re
from pathlib import Path

REGION_MAP = [
    (0xA000, 0xA02A, "JumpTable", "table", "Jump Table"),
    (0xA02A, 0xA04A, "DomesticDisplay", "func", "Entry0C"),
    (0xA04A, 0xA06B, "SetupDisplayPtrs", "func", "Setup display pointers"),
    (0xA06B, 0xA087, "DomesticTilePtrs", "table", "Tile pointer table"),
    (0xA087, 0xA0D2, "PpuWriteRle", "func", "Entry00"),
    (0xA0D2, 0xA0E4, "AdvanceSrcPtr", "func", "Advance source ptr"),
    (0xA0E4, 0xA1A4, "PpuWriteRawRows", "func", "PPU raw row writer"),
    (0xA1A5, 0xA209, "ReadRleByte", "func", "Read RLE byte"),
    (0xA209, 0xA212, "AdvanceSrcPtr2", "func", "Advance ptr v2"),
    (0xA212, 0xA24E, "PpuCopyRaw", "func", "Entry01"),
    (0xA24E, 0xA2E4, "PpuWriteTileOffset", "func", "Entry02"),
    (0xA2E4, 0xA2ED, "AdvanceTilePtr", "func", "Advance tile ptr"),
    (0xA2ED, 0xA2FF, "RewindTilePtr16", "func", "Rewind tile ptr"),
    (0xA2FF, 0xA387, "DisplayScrollLoop", "func", "Entry03"),
    (0xA387, 0xA3B1, "DisplayAndChrSetup", "func", "Entry04"),
    (0xA3B1, 0xA3BC, "DisplayUpdateScroll", "func", "Update scroll"),
    (0xA3BC, 0xA61C, "DisplayRenderScene", "func", "Render scene"),
    (0xA61C, 0xA642, "BattleDispatch", "func", "Entry06"),
    (0xA642, 0xA89A, "BattleTileData", "table", "Battle tile data"),
    (0xA89A, 0xA983, "BattleAttrAndHelpers", "func", "Battle attr+helpers"),
    (0xA983, 0xAB53, "AdvisorDialogue", "func", "Entry08"),
    (0xAB53, 0xAEF0, "BattleEffects", "func", "Entry05"),
    (0xAEF0, 0xB100, "OverlayWindow", "func", "Entry07"),
    (0xB100, 0xB144, "MainGameDispatch", "func", "Entry09"),
    (0xB144, 0xB15A, "SubDispatch_Mode09", "func", "Sub-dispatch"),
    (0xC000, 0xC08A, "TileLookupTable", "table", "Tile lookup"),
    (0xD693, 0xD69E, "DomesticActionDispatch", "func", "Entry0A"),
    (0xD69E, 0xD6AA, "DomAction_State0_Init", "func", "Entry0A state 0"),
    (0xDE25, 0xDE34, "AnimationDispatch", "func", "Entry0B"),
    (0xDEA0, 0xDEB9, "AnimFrameTable", "table", "Anim frame table"),
    (0xDEFA, 0xDF15, "SpriteFromTable", "func", "Sprite from table"),
    (0xDF15, 0xDF4A, "DataRecordLoader", "func", "Entry0D"),
    (0xDF4A, 0xE000, "DataRecordPtrs", "table", "Data record ptrs"),
]

asm_path = Path("/home/zero/project/sango2dasm/asm/banks/prg_17_18.asm")
lines = asm_path.read_text().splitlines()

addr_re = re.compile(r';\s+\$([0-9A-Fa-f]{4}):')
label_re = re.compile(r'^(L[A-Fa-f0-9]{4}|B17_18_\w+):$')

addr_to_line = {}
for i, line in enumerate(lines):
    m = addr_re.search(line)
    if m:
        addr_to_line[int(m.group(1), 16)] = i

label_to_addr = {}
label_line_idx = {}
for i, line in enumerate(lines):
    m = label_re.match(line)
    if m:
        lbl = m.group(1)
        label_line_idx[lbl] = i
        for j in range(i, min(i + 3, len(lines))):
            am = addr_re.search(lines[j])
            if am:
                label_to_addr[lbl] = int(am.group(1), 16)
                break

sorted_regions = sorted(REGION_MAP, key=lambda x: x[0])
line_region = [None] * len(lines)

for ri, (start, end, name, ftype, desc) in enumerate(sorted_regions):
    for addr, li in addr_to_line.items():
        if start <= addr < end:
            line_region[li] = ri
    for lbl, addr in label_to_addr.items():
        if addr == start:
            li = label_line_idx.get(lbl)
            if li is not None and line_region[li] is None:
                line_region[li] = ri

# Count transitions
transitions = 0
current_region = None
for i in range(len(lines)):
    ri = line_region[i]
    if ri is not None and ri != current_region:
        transitions += 1
        start, end, name, ftype, desc = sorted_regions[ri]
        if transitions <= 50:
            print(f"  Transition at line {i}: entering region {name} (${start:04X})")
        current_region = ri
    elif ri is None and current_region is not None:
        if transitions <= 50:
            print(f"  Transition at line {i}: LEAVING region (line: {lines[i][:60]!r})")
        current_region = None

print(f"\nTotal region entries: {transitions}")
print(f"Expected: {len(sorted_regions)}")
