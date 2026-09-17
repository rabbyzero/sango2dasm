# ProvinceOfficerRosterDispatch $AFE5-$B7D8 decoded in prg_19_1a.asm

- **Category:** task_summary_experience
- **Memory ID:** 4972c108-dfa4-458c-ab4e-faecfd21c3fc
- **Keywords:** ProvinceOfficerRosterDispatch, frame state $0C, card carousel, PPU strip record, CardFillDispatch, roster scroll

## Content

## Task description
Analyze and semantically decode Loc_AFE5 in asm/banks/prg_19_1a.asm (banks $19+$1A), applied as .proc ProvinceOfficerRosterDispatch ($AFE5-$B7D8), byte-exact verified via tools/verify_19_1a.py (16384 bytes, 0 mismatches).

## Findings
1. Machine = map-screen frame state $0C handler (from prg_1b_1c MapScreenFrameStateDispatch via bank $19 entry $A021); also driven by AttractDemoDispatch OverlayPoll during the attract demo. Shows the focused Province ($0402) Officer roster as a scrolling card carousel. Dispatch head by $0401 via B1F_CallbackDispatcher + inline 5-word table: 0=RosterLoadInit $AFF5 (commits pending Officer transfer via trampoline to $A015->$B7D9, loads Province roster offsets $11-$1A into $0410-$0419), 1=CardPanelSetup $B041, 2=RosterPoll $B086 (draws cursor card via $CE1F menu id $AE; Up/Down edge $0083 bit4/5 via PadEdgeCursorMove $B209; A/B exit handoff $0400<-$0470/$0401<-$0471 with $0140/$0472 window-flash sequence), 3=CardAnimWait $B136, 4=RosterScroll $B155 (40-frame scroll rows $AC/$FC or $60/$B0, commit via ScrollStepAdvance $B260).
2. Card animation: OfficerCardAnimStep $B2D7 builds a 32-byte PPU strip record at $0380-$03A3 per frame $040D (0-9 then $FF); PPU address = CardRowBaseTable $B4B9 (slot mod 3 via B1F_MathDiv16 remainder -> $2400/$2540/$2680) + frame*$20; tile patterns CardAnimPatternPtrs $B385 -> CardAnimPatternFrames $B399 (9 x 32 bytes; frames 8/9 share $B499; roster id $FE selects frame 8). CardFillDispatch $B4BF fills Officer cells by frame via inline 10-word table: 0=NameMarksOverlay $B508 (dakuten $39/handakuten $3A over name cells $038A+), 1=BaseKanaCopy $B52D (base kana $038B+, falls into StatDigitsFill $B54D), 2/9=FrameNoop $B507, 3=FlagStatDigitsFill $B5A6 (record[$0B]>>4+1 -> $0391; record[$02] -> $0398/9; record[$03] capped 100 -> $039E/F, 100 = tile $32 max mark), 4=PortraitLevelTiles $B630 (PortraitTilesAttr $B647), 5=PortraitAndStatsFill $B64D (PortraitTilesLevel $B713 + stat digit groups via DigitStoreUpper/Lower/Ones $B719/$B71D/$B727), 6=NamePlateUpper $B730 / 7=NamePlateLower $B770 (name-plate glyph strips from $9B12 table in bank $30 via NamePlateStripSetup $B7C1 + NamePlateCopy $B7A2; frame 6 stores marker coords $040E/$040F), 8=MarkerCoordCommit $B4F3. Digit tiles start at $76; Officer record fields read: [0],[1],[2],[3],[4],[6],[7],[8],[9] (16-bit with [9]&3 hi), [$0A] name plate, [$0B] flag byte; BCD via B1F_MathBinToBcd $E9BA.
3. Pitfalls hit: the sub-0 body after JSR B1F_BankedCallbackTrampoline was misclassified as .byte (re-disassembled $AFFF-$B01E; trampoline target .word $A015); table splits must preserve byte counts (initially dropped the 12 pattern bytes $B399-$B3A4 when converting the pointer table, causing a bank-wide -12 byte shift visible as wrong JMP target bytes); CardFillDispatch frame 3 entry is $B5A6 not $B54D. ca65 cheap @labels cannot cross an intervening non-local label (BEQ to a label defined after another global fails).
4. RAM: $0408 cursor slot, $0409 scroll offset (0-$4F), $040A direction, $040C target slot, $040D anim frame, $040E/$040F marker coords, $0470/$0471 pending handoff frame state/sub-state, $0472/$0473 window-flash step/palette toggle, $0098 marker bob counter, $0380-$03A3 strip record, $007E bit2 card-anim busy.

## Related files
asm/banks/prg_19_1a.asm (modified), asm/banks/prg_1b_1c.asm (caller context only).
