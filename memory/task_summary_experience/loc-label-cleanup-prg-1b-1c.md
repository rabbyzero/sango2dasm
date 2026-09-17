# Loc_ label cleanup in prg_1b_1c.asm with semantic .proc conversion

- **Category:** task_summary_experience
- **Memory ID:** 3bc8ce0e-df76-4ca8-8ae7-576bb3d7043a
- **Keywords:** Loc labels, prg_1b_1c, MapCameraScroll, MapProvinceHitTest, ClampProvinceGoldRice, entry stubs

## Content

All 29 Loc_ADDR labels in prg_1b_1c.asm eliminated with byte-exact verification (16384 bytes, 0 mismatches via tools/verify_1b_1c.py):

1. Entry stubs $A003/$A006 renamed to ActionDeltaInputPoll_Entry / OfficerSelectDialogPoll_Entry, matching the existing MapScreenFrameUpdate_Entry / ProvinceZoneOriginGet_Entry stub naming. Not referenced elsewhere; no functions.h entries added (intra-bank only).

2. $DDDC-$DDF1 wrapped as .proc ClampProvinceGoldRice: clamps the 16-bit province record field at ($00)+Y (Y=$02 Gold, Y=$04 Rice) to 9999 ($270F) by testing subtract $2710; 7 raw JSR $DDDC call sites updated. Field semantics confirmed from docs/province_data.md record layout.

3. $DDF2-$DE82 wrapped as .proc MapCameraScroll: D-pad camera scroll with auto-repeat, byte-identical twin of MapCameraScrollRepeat ($C67C, prg_19_1a.asm). Naming aligned to the twin's decoded semantics (bit7 Right/bit6 Left/bit5 Down/bit4 Up; $0318 latched nibble, $0319 hold counter, X [$10,$F8] Y [$10,$94]); @-label names mirrored from the twin (@NoDirClearCounter, @DirChangedReset, @RepeatHoldExit, @ScrollEdges, @EdgeLeft/Down/Up, @ScrollDone). 6 raw JSR $DDF2 sites updated; the old "province sprite animation tick" comments were wrong and corrected.

4. $DEBA-$DEE8 wrapped as .proc MapProvinceHitTest: camera position -> Province id in Y ($FF if none), twin of MapProvinceUnderCamera ($C708). 7 raw JSR $DEBA sites and 7 prose comment references updated.

5. MapRulerMarkerDraw internals: Loc_DEB0 -> @RulerMarkerSkip (3 BNE targets); unreferenced fallthrough labels Loc_DE77, Loc_DE7C, Loc_DEA5, Loc_DF6E, Loc_DF97 deleted (address comments on instructions already anchor positions).

6. MapProvinceSpriteRefresh internals (bare global retained): @ZoneLoop, @DirtyClear, @ZoneSpriteEmit (was JSR $DF62), @AnimMaskCheck, @ZoneEmitExit.

Lesson: cross-bank duplicate routines get distinct global names (twin exists as MapCameraScrollRepeat in prg_19_1a), and instruction trailing address comments like "; $DDF2: A9 00" make naive replace_all of "$DDF2" dangerous - must scope replacements to "JSR $ADDR" substrings.
