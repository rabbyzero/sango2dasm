# BattleInputPromptDraw Functionality

- **Category:** project_introduction
- **Memory ID:** 683d125e-49ee-4dce-8aae-9790b33082dd
- **Keywords:** input prompt, blinking sprite, battle UI, $005E tick counter, sprite OAM

## Content

The region $CCA8-$CCD8 implements `BattleInputPromptDraw`, responsible for drawing the blinking input-prompt sprite during player input waits in battle. It contains a main entry at $CCA8 (X base $000A ← $D8) and an alternate unreferenced entry at $CCB5 (X base ← $E0). The routine checks frame counter $005E bit 4 to control blink visibility, then writes a single sprite record (`00 04 00 00 80`) via `B1F_SpriteOamWriterSimple`. Six callers across phase 4 and phase 8 use it to prompt A/B button presses. This replaces incorrect prior comments about panel input setup.
