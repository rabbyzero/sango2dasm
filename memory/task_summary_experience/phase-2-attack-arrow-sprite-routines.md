# Phase 2 attack arrow sprite routines decoded in prg_0e_0f.asm ($BE76-$BF4B)

- **Category:** task_summary_experience
- **Memory ID:** 9d7047c3-aeae-4e28-ac28-b4380d1ee99c
- **Keywords:** attack arrow sprite, OAM stream table, side action counter, Phase2AttackArrowAnim, SpriteOamWriterScroll

## Content

## Task description
Decoded Loc_BE76 in asm/banks/prg_0e_0f.asm: the phase-2 attack arrow sprite submit routine and its tables ($BE76-$BF4B), previously bare Loc_ labels + raw .byte. Verified byte-exact via tools/verify_0e_0f.py (16384 bytes, 0 mismatches, 10 stubs).

## Key findings
1. Phase2AttackArrowSprSubmit ($BE76, tail-call JMP B1F_SpriteOamWriterScroll) is called by Phase2AttackArrowAnim sub 7 ($A72E). Stream index = acting side $0549 (0-3) plus +4 when the acting slot's side action counter is pending: slot $0545 >= $0B (side B) checks high nibble of $0577, else low nibble (side A). $0577 nibbles are set to 3 for the acting side by the row-effect handler at $B087 and drawn by BattleSideStatusCounterDraw.
2. Sprite position = arrow walk position ($054A row / $054B column, latched <<4 by Phase2AttackSetup, stepped 2/frame by Phase2CursorStepFast) + per-side pixel offsets: Phase2AttackArrowRowOffsetTable $BED5 {00,00,F8,08}, Phase2AttackArrowColOffsetTable $BED9 {F8,08,00,00}. Writer params: $000C=sprite Y, $000A=sprite X.
3. Phase2AttackArrowStreamPtrTable $BEDD (8 words) -> 8 five-byte OAM streams $BEED-$BF14, each one [relY,tile,attr,relX] record + $80 terminator. Direction by side: 0=up tile $84, 1=down tile $94, 2=left tile $A4 attr $42 (h-flip), 3=right tile $A4 attr $02; engaged variants (+4) use tile+1 ($85/$95/$A5).
4. Phase2AttackMarkerSprSubmit ($BF15, called by Phase2AttackAnimCount sub 8 $A74A) draws the 2x2 impact marker (tiles $86/$87/$96/$97, attr $02; Phase2AttackMarkerSprites $BF3B, identical layout to BattleCursorArrowSprMarker) at the final arrow position.
5. B1F_SpriteOamWriterScroll ($F092) record format confirmed from Phase9AdvanceMarkerRender: 4-byte [relY, tile, attr, relX] records, $80 at a record start terminates; $0003=tile bias, $0004=Y clamp, $0002=flip flags, $007C=OAM slot.

## Notes
- Refactor renamed Loc_BE76/Loc_BF15 to .proc Phase2AttackArrowSprSubmit/Phase2AttackMarkerSprSubmit with @SideA/@LookupStream/@Submit locals, symbolic .word pointer table, split data tables; call sites $A72E/$A74A updated.
- Row/col adjust tables overlap the pointer table start region ($BED9-$BEDC precede $BEDD); keep the 4/4/16-byte split exact or byte drift occurs.
