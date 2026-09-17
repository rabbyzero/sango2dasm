# Map camera scroll routines decoded and refactored in prg_19_1a.asm

- **Category:** task_summary_experience
- **Memory ID:** 0afe1f0d-e6a2-4868-b9ae-91c8e66817bf
- **Keywords:** MapCameraScrollRepeat, MapProvinceUnderCamera, map camera scroll, SuccessionPickProvince, semantic renaming, @-locals, .proc scoping, cpu_ram_map

## Content

## Task description
- Core requirement: Apply the full code analysis workflow (Verify → Replace → Rename → Fix → Explain) to the map camera scroll routines in prg_19_1a.asm ($C67C-$C736).
- Task background: The region contained two unstructured routines with generic Loc_XXXX labels that needed semantic renaming, proper .proc scoping, and inline documentation. The caller SuccessionPickProvince referenced them via numeric addresses.

## Execution process
1. Verify phase: Read lines 5309-5422 of prg_19_1a.asm; confirmed no .byte/.word lines needing conversion; identified all Loc_C* labels and verified scope boundaries; checked external references to ProvinceCameraXTable/ProvinceCameraYTable (file-scope required).
2. Rename + Wrap phase: Replaced `Loc_C67C:` block with `.proc MapCameraScrollRepeat` header comment + 8-px scroll logic; replaced `Loc_C708:` block with `.proc MapProvinceUnderCamera` header comment + province scan logic; renamed all internal branch targets to semantic @-prefixed locals (@NoDirClearCounter, @DirChangedReset, @RepeatHoldExit, @ScrollEdges, @EdgeLeft/Down/Up, @ScrollDone, @ProvinceScanStart/Loop/NextLower/HitReturn); dropped unreferenced mid-sequence labels Loc_C6E7/C6F0/C6F3.
3. Caller update: Changed `JSR $C67C` / `JSR $C708` in RulerSuccessionScene sub-state 2 to `JSR MapCameraScrollRepeat` / `JSR MapProvinceUnderCamera`.
4. Documentation fix: Updated cpu_ram_map.md line 190 entry for `$0318-$0319` from vague "animation frame counter/state" to precise "map camera scroll: direction latch / repeat hold counter"; confirmed identical routine copy at prg_1b_1c.asm $DDF2 using same cells.
5. Verification: Ran tools/verify_19_1a.py — compared 16384 bytes, 0 mismatches; byte-exact parity confirmed.

## Related files
- /home/zero/project/sango2dasm/asm/banks/prg_19_1a.asm
- /home/zero/project/sango2dasm/code/cpu_ram_map.md

## Notes
None — all changes applied directly to source per workflow rule; no detours or tool failures encountered.

## Task overview
Completed: Wrapped both routines into semantic .proc blocks with comprehensive headers, renamed 10+ Loc_* labels to @-locals, updated caller JSRs, corrected RAM documentation, and verified byte-exact parity with 0 mismatches across banks $19+$1A.
