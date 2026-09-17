# MapCameraScrollRepeat and MapProvinceUnderCamera decoded in prg_19_1a.asm

- **Category:** task_summary_experience
- **Memory ID:** 49c5b7ee-95c9-45d1-9af5-9ba08971de92
- **Keywords:** MapCameraScrollRepeat, MapProvinceUnderCamera, prg_19_1a, map camera scroll, SuccessionPickProvince

## Content

Map camera scroll routines in prg_19_1a.asm ($C67C-$C736) decoded, wrapped, and verified:
- $C67C wrapped as .proc MapCameraScrollRepeat: 8-px map camera scroll ($6F3F X / $6F41 Y) from $0083 high nibble (bit7 R/bit6 L/bit5 D/bit4 U), immediate step on direction change, 15-frame delay ($0319 counter) then auto-repeat on 3 of 4 frame ticks ($005E & 3); bounds X [$10,$F8], Y [$10,$94]; diagonals supported.
- $C708 wrapped as .proc MapProvinceUnderCamera: scans 30-entry ProvinceCameraXTable/$C737 + ProvinceCameraYTable/$C755 from Province $1D down, hit when camera within 16x16 of anchor; $FF when camera parked top-left (both < $20) or no hit.
- Tables stay file-scope (also referenced from OfficerStatusScene $A14E and $AEA1); caller SuccessionPickProvince (RulerSuccessionScene sub-state 2) updated to named JSRs; unreferenced mid-sequence labels Loc_C6E7/C6F0/C6F3 dropped.
- prg_1b_1c.asm $DDF2 contains an identical copy of the scroll routine using the same $0318/$0319 cells; cpu_ram_map.md entry corrected from "animation frame counter/state" to scroll latch/repeat counter semantics.
- Verified with tools/verify_19_1a.py: compared 16384 bytes, 0 mismatches.
