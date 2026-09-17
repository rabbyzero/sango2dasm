# Proc enclosure pass for prg_1b_1c.asm outside-proc regions

- **Category:** task_summary_experience
- **Memory ID:** 1d64c5e3-078d-4a66-91bb-764b10ce2b8d
- **Keywords:** proc enclosure, prg_1b_1c, data region, byte parity, semantic labels

## Content

Proc-enclosure pass over prg_1b_1c.asm ($D5BD-$DFFF region). Outside-proc regions found and resolved: (1) $D63D confirm-dialog data enclosed in ConfirmDialogPoll with new labels ConfirmDialogItemTable/ConfirmDialogCursorPosTable/ConfirmDialogArrowSprite; (2) $D74C-$D772 tables (OfficerSelectMenuTable/CursorPosTable/CursorSprite) moved inside OfficerSelectDialogPoll before .endproc; (3) bare globals MapRulerMarkerDraw ($DE83, data $DEB1 = MapRulerMarkerSprite) and MapProvinceSpriteRefresh ($DF35) and ProvinceZoneOriginGet ($DF25) wrapped with .proc; (4) MapProvinceSpriteRefresh private tables $DFC0-$DFFF labeled ProvinceMarkerTileTable/AttrTable/ZoneFlagTable (30 zones, $DFD0-$DFED)/AnimMaskTable ($DFEE-$DFF5, FF pad to $DFFF) and moved inside; JMP $F1AD renamed B1F_SpriteOamWriterSimple. Kept outside by shared-use rule: MapZoneOriginXTable/YTable ($DEE9, used by MapProvinceHitTest + ProvinceZoneOriginGet + MapProvinceSpriteRefresh) and the $A000-$A00B dispatch entry stub table (project convention, matches prg_19_1a). Verified via tools/verify_1b_1c.py: 16384 bytes, 0 mismatches.
