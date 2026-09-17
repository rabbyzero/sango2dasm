# BattleInputPromptDraw decoded in prg_0e_0f.asm ($CCA8-$CCD8)

- **Category:** task_summary_experience
- **Memory ID:** 81547581-8645-4e1f-8221-19ad1b8a2a9a
- **Keywords:** BattleInputPromptDraw, prompt sprite, blink gate, pseudo-disassembly restore, SpriteOamWriterSimple

## Content

## Task description
Decoded prg_0e_0f.asm $CCA8-$CCD8 via the Code Analysis Workflow: wrapped in multi-entry .proc BattleInputPromptDraw; updated 6 call sites ($A3DC, $A40F, $A490, $A4BD, $AE11, $AE8E) and fixed the Phase4ResultDefeatInputWait header.

## Key findings
1. BattleInputPromptDraw draws the blinking input-prompt sprite (tile $04) at Y base $A0 used by all A/B input-wait states (phase 4 defeat/retreat/damage/confirm, phase 8 panel confirm/advance). Blink gate: frame tick counter $005E bit 4 — drawn only while clear (16-tick period). Submits BattleInputPromptSprite ($CCD9: 00 04 00 00 80, single $80-terminated record) to B1F_SpriteOamWriterSimple ($F1AD) with flip flags $0002 <- 0.
2. $CCB5 was code misclassified as .byte (pseudo-disassembly): unreferenced alternate entry BattleInputPromptDrawAlt with X base $E0 instead of $D8 (prompt shifted 8px right). Restored as code; main entry's JMP $CCBF skips it.
3. Inner labels BattleInputPromptDrawAlt / BattleInputPromptBlinkDraw are bare (non-cheap) labels inside the .proc per the ProvinceSelect multi-entry pattern; @Done cheap label placed after the last bare label to avoid cheap-scope termination pitfalls.
4. Old "panel input check setup" inline comments and the header's "($CCA8 -> $CD22, ...)" phrasing were inaccurate: the routine only draws the prompt sprite; pad state comes from BattleBothPadsStateFetch ($CD22).

## Notes
- $000A = X base, $000C = Y base, $0000/$0001 = sprite record ptr, $007C = OAM slot cursor for B1F_SpriteOamWriterSimple.
- Verified byte-exact via tools/verify_0e_0f.py (16384 bytes, 0 mismatches).

## Task overview
Fully decoded and renamed the $CCA8-$CCD8 blinking input-prompt sprite routine with zero byte drift.
