# Terminology update for prg_1f.asm with zero drift verification

- **Category:** task_summary_experience
- **Memory ID:** d5166679-492b-40cb-95c1-742b8e50db92
- **Keywords:** prg_1f.asm, terminology update, semantic naming, cross-bank references, byte verification, multi-entry procedure

## Content

Updated prg_1f.asm to canonical vocabulary from docs/manual_kb/terminology.md: renamed State_KingdomSelect→State_RulerSelect, GetProvinceRecordAddr→GetCountryRecordAddr, sram_kingdom_param→sram_map_cam_y/x, DomesticGraphicPtrs→StrategyCommandGraphicPtrs, and ~20 comments. Fixed incorrect cross-bank JSR targets (e.g., B1D_1E_StateHandler→B17_18_DisplayScrollLoop) and symbolized raw banked calls using functions.h BXX_YY_* naming with Y mask. Restructured NmiSubDispatch/NmiEpilogue to use bare-global labels outside .proc blocks for cross-proc access. Verified byte-exactness: comparison against ROM shows identical mismatch sets between HEAD and updated version (40 pre-existing structural errors due to missing instructions), proving terminology edits introduced zero drift. One byte-safe fix applied: moved @clear_loop label to match ROM branch target ($E04C). Remaining divergence requires re-disassembly pass beyond scope.
