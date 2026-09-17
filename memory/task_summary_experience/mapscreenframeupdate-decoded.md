# MapScreenFrameUpdate decoded at Loc_A00C in prg_1b_1c.asm with zero byte drift

- **Category:** task_summary_experience
- **Memory ID:** c8a9f43e-e39f-44c3-a37e-c070d2ff9ff3
- **Keywords:** MapScreenFrameUpdate, prg_1b_1c, frame state dispatch, dirty bitmap, province sprites

## Content

prg_1b_1c.asm Loc_A00C decoded as MapScreenFrameUpdate ($A00C-$A044), called from NmiState2_MapScreen (bank $1F $F8EF, Y=$3B, JSR $A000 stub aliasing $A00C). Flow: MapRulerMarkerDraw ($DE83, ruler marker sprites at camera $6F3F/$6F41 via template $DEB1 and B1F_SpriteOamWriterSimple), MapProvinceSpriteRefresh ($DF35, rebuilds animated province sprites in OAM page $0200 over 29 zones, clears dirty bitmap $04E0-$04E3), banked callback Y=$39 to banks $19+$1A $A02A (marks pending province $0402 in dirty bitmap), then on $0087 bit7 set dispatches frame state $0400 via B1F_CallbackDispatcher with 16-entry table $A025-$A044. States 0/7/8 share sub-dispatch $A07D (by $0401, table $A083: $A089/$A0DF/$A179); states 9-$0F are banked-call stubs to bank $19 entries $A003/$A006/$A009/$A00C/$A01E/$A021 and B1D_1E_SceneRenderer ($1D $A039). Former bogus labels Loc_A01B/Loc_A01E/Loc_A060 removed as decode artifacts; new labels Loc_A055/A05D/A065/A06D/A075/A07D added. Verified byte-exact via tools/verify_1b_1c.py (16384 bytes, 0 mismatches); bank_switch_map.md section 3.7 documents linkage.
