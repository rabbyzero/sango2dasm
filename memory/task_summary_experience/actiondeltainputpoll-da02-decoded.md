# ActionDeltaInputPoll $DA02 decoded in prg_1b_1c.asm

- **Category:** task_summary_experience
- **Memory ID:** 7eb5e623-15f5-440f-995a-33a2e0eb788a
- **Keywords:** ActionDeltaInputPoll, war scene delta input, prg_1b_1c, AiOfficerActionDispatch caller, digit cursor rendering

## Content

## Task description
- Code analysis of prg_1b_1c.asm Loc_DA02 region ($DA02-$DB71), converting Loc_ labels to @-style locals and semantic naming per terminology.md / 04-strategy-commands.md.

## Findings (verified against callers)
- Loc_DA02 is the war-scene ACTION DELTA INPUT, reached only via entry stub $A003 (JMP $DA02). Callers: prg_08_09 AiOfficerActionDispatch State1_GrowStatA ($C1FC) and State2_GrowStatB ($C2D1), banked callback trampoline Y=$3B. bank_switch_map.md previously mislabeled $A003 as "PPU raw copy helper" — fixed.
- Behavior: edits 4-digit action delta $048E/$048F (caller RAM action_delta_lo/hi) with pad1 edges $0081: bit7 Right = digit cursor $048B-1 (floor 0), bit6 Left = +1 (cap $001F=3), bit5 Down = -step, bit4 Up = +step; step 1/10/100/1000 by cursor ($DB09 helper). Clamped to caller max $0490/$0491 (stat_delta from State0_ShowActionPanel) by restoring entry snapshot $0014/$0015. Render path: $DDAD sentinel idle check, $0081&3 (A/B) latched to $0013, B1F_MathBinToBcd ($E9BA) -> $0007/$0008 -> $048C (tens/ones) / $048D (thousands/hundreds), digit loop Y=2,1,0 over $048B,Y (Y=0 reads the cursor byte itself), tile writer $DB35 (digit tiles $76+n, blank $01 for leading zeros until first nonzero or cursor slot $0011=3-cursor, blink tile $01 on cursor slot while $046C bit3 clear), terminator $80, $0303/$030C=1, queue via $007E bit0.
- Loc_DA04 was an unreferenced artifact label (mid-entry that nothing dispatches to); removed by inlining LDA #$03/STA $001F.

## Changes
- Wrapped $DA02-$DB71 as .proc ActionDeltaInputPoll; helpers $DB09 -> @GetDigitStep, $DB35 -> @DigitTileWrite (plus @DigitBlank/@CursorBlinkCheck/@DigitAdvance matching the OfficerTroopPoolAssignPoll idiom names); branch targets -> @CursorLeftCheck/@DeltaDownCheck/@DeltaUpCheck/@ClampDelta/@RenderDigits/@ExitPoll/@BcdDigitsDraw/@BcdLowDigit. Stub now JMPs ActionDeltaInputPoll. $DB72/$DB87/$DB99 left global (external callers).
- Updated code/bank_switch_map.md (3 spots) to correct the $A003 role.

## Verification
- tools/verify_1b_1c.py: 16384 bytes, 0 mismatches after rename (harness stubs only raw JSR/JMP $xxxx; symbolic stub reference needs no stub entry).

## Notes
- The two trailing tile-stream tiles derived from cursor byte $048B (high nibble 0, low nibble = cursor index) are factual; their on-screen purpose is unconfirmed.
