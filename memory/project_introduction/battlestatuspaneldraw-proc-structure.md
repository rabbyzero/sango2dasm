# BattleStatusPanelDraw proc $CFA2-$D1EC structure in prg_08_09.asm

- **Category:** project_introduction
- **Memory ID:** b228bd46-1933-4601-9ff5-2db4256e85f1
- **Keywords:** BattleStatusPanelDraw, sprite string format, digit sprite table, panel mode bits, prg_08_09

## Content

In prg_08_09.asm, $CFA2-$D1EC was fully analyzed and restructured (byte-exact verified via tools/tmp_verify_cfa2.py harness, 587 bytes): BattleStatusPanelDraw (.proc $CFA2-$D125, dispatch stub BattleStatusPanelDraw_Entry at $A012) draws the battle status panel sprites via B1F_SpriteOamWriterSimple ($000A=Y base, $000C=X base). Gates: $008F==0, $04C8==0, battle command $0500 < $0C, $005E bit5 set. Draws header icon @PanelHeaderSprite ($D13C), mode block @PanelModeBlock1/$D15D (bit6 set) or @PanelModeBlock0/$D16E, status counter $0505 (2 BCD digits at Y=$20 X=$E0/$E8), round counter $0506 (Y=$10 X=$D0/$D8), and the selected side's strength as 4 BCD digits at Y=$40 X=$D0-$E8 with leading-zero suppression ($0011 = digits drawn). $005E bit6 selects stat pair: clear -> stat A ($0522/$0523 side 0, $0524/$0525 side 1), set -> stat B ($0526/$0527 or $0528/$0529); $0504 bit7 selects side 1. Nested @DrawDigit ($D126) renders one digit as two stacked tiles ($46+d top, $56+d bottom) via @DigitPtrTable ($D17F, 10 words). Sprite string format: 4-byte entries [y_off,tile,attr,x_off] terminated by $80. The former misdisassembled "Code Region" $D141-$D1CA was actually this sprite/pointer data.
