# Refactor prg_17_18.asm Lines 2204-2370: Proc Naming and Scope

## Context

This task refactors two related procedures in the battle overlay rendering system:
- **Sub_ADBC** ($ADBC-$AEB4): Main CHR/tile decompression routine with RLE processing and adjacency-based attribute patching
- **Sub_AEB5** ($AEB5-$AEED): Palette setup wrapper that computes offsets and delegates to Sub_ADBC

These functions are part of the dispatch chain triggered by `DispatchPaletteSetup` based on bit 4 of $009C, which controls whether offset or default palette setup is used during battle scene rendering.

## Problem

Current issues with the code:
1. Generic names (`Sub_ADBC`, `Sub_AEB5`, `LAE58`) don't convey purpose
2. `LAE58` is a local helper within Sub_ADBC but uses a bare address label instead of being properly scoped
3. Parameter names like `param_byte1`, `param_000e`, `temp_0016` lack semantic meaning
4. Missing documentation about the relationship between Sub_AEB5 and Sub_ADBC

## Solution

### 1. Rename Procs with Meaningful Names

- **Sub_ADBC** → `DecompressBattleOverlayCHR`
  - Reflects its role: decompresses CHR data for battle overlay tiles with RLE and adjacency patching
  
- **Sub_AEB5** → `SetupDefaultPaletteAndDecompress`
  - Indicates it sets up default palette parameters before delegating to DecompressBattleOverlayCHR

- **LAE58** → `MergeAttributeBits` (as a local label within DecompressBattleOverlayCHR)
  - Describes its function: merges attribute byte bits with masking logic based on row/column conditions

### 2. Improve Parameter Names

Within `DecompressBattleOverlayCHR`:
- `param_byte1` → `ppu_addr_lo` (PPU address low byte, initialized to $9C)
- `param_byte2` → `ppu_addr_hi` (PPU address high byte, initialized to $01)
- `rle_marker` → `tile_attr_byte` (RLE-compressed tile attribute from source data)
- `col_counter_hi` → `tile_col_index` (tracks column position across 8-tile boundaries)
- `row_limit` → `current_row` (loop counter for rows)
- `row_count` → `max_rows` (total rows to process, 8 or 9 based on flag)
- `param_0008` → `attr_base_offset` (base offset derived from attr_ptr_lo >> 5)
- `ptr_lo` → `overlay_data_ptr` (pointer to overlay data in current bank)
- `attr_ptr_lo` → `scene_coord_ptr` (pointer to scene coordinate data)
- `param_000e` → `coord_high_bits` (high bits of coordinates, masked with $E0)
- `temp_0016` → `data_ptr_offset` (incremented by 2 each iteration)
- `temp_0018` → `adjacency_ptr_offset` (incremented by 2 each iteration)
- `var_00a8` → `bank_switch_ptr` (indirect pointer for bank-switched data access)
- `var_019e` → `attr_accumulator` (accumulates merged attribute bytes, indexed by X)

Within `SetupDefaultPaletteAndDecompress`:
- `attr_ptr_lo` → `work_ptr_lo` (working pointer low byte)
- `attr_ptr_hi` → `work_ptr_hi` (working pointer high byte)
- `ptr_000e_lo` → `coord_ptr_lo` (coordinate pointer low byte)
- `ptr_000e_hi` → `coord_ptr_hi` (coordinate pointer high byte)

### 3. Proper Proc Scoping

Keep existing `.proc`/`.endproc` boundaries:
- `DecompressBattleOverlayCHR` remains a standalone proc (lines 2207-2334)
- `SetupDefaultPaletteAndDecompress` remains a standalone proc (lines 2338-2370)
- `MergeAttributeBits` becomes a local label within `DecompressBattleOverlayCHR` (currently LAE58)

The scoping is correct because:
- Both procs are independent entry points called via JMP from `DispatchPaletteSetup`
- `SetupDefaultPaletteAndDecompress` always ends with `JMP DecompressBattleOverlayCHR`, making it a tail-call wrapper
- `MergeAttributeBits` is only called from within `DecompressBattleOverlayCHR` and has multiple RTS exits

### 4. Add Documentation Comments

Add header comments explaining:
- The dispatch flow: `DispatchPaletteSetup` → either `SetScrollWorkOffset4` or `SetupDefaultPaletteAndDecompress` → `DecompressBattleOverlayCHR`
- The role of bit 4 of $009C in selecting the path
- How `SetupDefaultPaletteAndDecompress` computes offsets from scene coordinates ($008E-$0091) before delegating
- The RLE decompression loop in `DecompressBattleOverlayCHR` and its use of adjacency maps

## Files to Modify

- `/home/zero/project/sango2dasm/asm/banks/prg_17_18.asm` (lines 2204-2370)

## Verification

After changes:
1. Run `make` to ensure assembly still compiles without errors
2. Verify no references to old labels remain using grep:
   - `grep -n "Sub_ADBC\|Sub_AEB5\|LAE58" asm/banks/prg_17_18.asm` should return 0 results
3. Check that all cross-references are updated (only external calls need Bxx_ prefix per project convention, but these are intra-bank so bare names are correct)
4. Ensure the binary output matches expected behavior by running any existing tests or ROM verification scripts
