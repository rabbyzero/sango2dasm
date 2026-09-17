# Phase2CursorArrowDraw decoded at Loc_BB8F in prg_0e_0f.asm

- **Category:** task_summary_experience
- **Memory ID:** 3ec0b462-2008-4023-8170-a0b6fa87864e
- **Keywords:** Phase2CursorArrowDraw, cursor arrow sprite, BattleCursorArrowSpritePtrs, sprite stream, sprite OAM writer

## Content

In asm/banks/prg_0e_0f.asm, Loc_BB8F became .proc Phase2CursorArrowDraw ($BB8F-$BBFC): draws the walk-cursor arrow sprite each frame (called from Phase2CursorWalkInit $A5EF and Phase2CursorWalkStep $A5F3). Sprite stream picked from BattleCursorArrowSpritePtrs ($BBFD, 64 words, symbolic .word targets with inline hex comments) with word index = (((($05C2[$0545] status nibble)<<2) | (action bits &3))<<2 | frame), frame = bits 3:2 of $005E; frames alternate between the stream pair every 4 ticks. Position X=$054B, Y=$054A+8; flip flags $0002: bit 6 (vertical flip, XORed into sprite attrs) when status nibble==3, bit 0 for unit columns ($0545<$0B); tail JMP B1F_SpriteOamWriterScroll ($F092). Streams at $BC7D-$BE75 are 4-sprite [X,tile,attr,Y] records with $80 terminator; 24 streams labeled BattleCursorArrowSpr* (Tiles40/Tiles60 arrow glyphs + Box* 4x4 brackets, several exact duplicates). Data region cleanup: Loc_BC88/BC8D/BC99/BCAA/BCBB/BDDC/BDED misdisassembled code merged back into streams; dead code $BE15-$BE5C (unreferenced earlier marker-draw duplicate, terminator of Box22 stream sits at $BE14) kept as .byte; stale prefix bytes $BE5D-$BE64 before BattleCursorArrowSprMarker ($BE65). Verified byte-exact via tools/verify_0e_0f.py (16384 bytes, 0 mismatches) and per-line hex/addr audit tools/tmp_verify_bbfd_be75.py (56 .byte + 32 .word lines, 0 errors).
