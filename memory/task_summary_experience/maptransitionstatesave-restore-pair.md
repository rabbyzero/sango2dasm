# MapTransitionStateSave/Restore pair decoded at $D568 in prg_1b_1c.asm

- **Category:** task_summary_experience
- **Memory ID:** e2d1cccc-c4ff-4850-913b-d8092622faef
- **Keywords:** MapTransitionStateSave, MapTransitionStateRestore, camera snapshot, prg_1b_1c, hemisphere flag

## Content

## Task
Code analysis of prg_1b_1c.asm $D568 region with semantic renaming and byte-exact verification.

## Result
- Renamed Loc_D568 -> MapTransitionStateSave (.proc, $D568-$D58B): sets screen-transition busy $0140=$80, derives hemisphere flag word $0150 from camera X $6F3F bit7 (clear -> $80, set -> $00; low bits stay clear, unlike the inline CommandCategoryMenuScreenInit variant which sets bit0), and saves the camera snapshot $046D-$046F <- camera X $6F3F / camera Y $6F41 / pending province $0402. Called on ~46 command-screen exits that route to another map frame state (existing site comments: "close window", "close command window").
- Renamed Loc_D58C -> MapTransitionStateRestore (.proc, $D58C-$D5BC): A = low-bit flag word ($02/$03 at call sites), restores camera from snapshot, calls MapRulerMarkerDraw ($DE83), restores pending province $0402 then calls B1F_GetProvinceRecordAddr ($F2AF, result unused), re-marks $0140=$80, ORAs hemisphere bit into $0150. ~14 call sites (comments: "restore map scroll"); used after pan-anim completion and result screens.
- Snapshot slot $046D-$046F also read by inline restores at $AFC4 and $B56E; @-locals @StoreFlagWord/$@MergeHemiBit; fixed two "(undocumented bank-$1C helper)" call-site comments; realigned inline comments to column 42.
- Adjacent Loc_D5BD is a separate yes/no confirm-dialog routine (B1F_MenuStep2 + B1F_PointerTableLookup + $DDAD idle check, result in $0013, debounce via $046C) - left untouched.

## Verification
tools/verify_1b_1c.py: "compared 16384 bytes, 0 mismatches".

## Notes
- cpu_ram_map.md line 392 labels $6F3F as camera Y low and $6F41 as X low, but prg_1b_1c.asm consistently treats $6F3F as camera X / $6F41 as camera Y (bank headers, $DEBA comments); docs conflict unresolved.
- Grep tool results were capped at 15 matches, hiding most of the 60 call sites initially; SearchReplace repeatedly failed to match existing text on this file (stale snapshot) and had to be completed via sed.
