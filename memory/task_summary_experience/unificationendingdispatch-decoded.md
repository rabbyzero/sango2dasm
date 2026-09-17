# UnificationEndingDispatch decoded and refactored in prg_19_1a.asm

- **Category:** task_summary_experience
- **Memory ID:** ab8ca916-b38b-4994-8f32-a7037a1da54c
- **Keywords:** UnificationEndingDispatch, prg_19_1a, unification ending, frame state 0F, verdict tier, census

## Content

## Task description
- Code Analysis Workflow (Verify/Replace/Rename/Fix/Explain) on prg_19_1a.asm $C435, the previously bare-label region between ScenarioHandoffPrep and StrategyRequestDispatch.

## Findings
- $C435-$C67B is the map-screen frame state $0F handler: the unification ending, entered via banks $19+$1A entry stub $A01E (prg_1b_1c MapScreenFrameStateDispatch state $0F) when MapRulerIntroInit finds the player Ruler owning all 30 Provinces.
- Dispatches sub-states by $0401 via B1F_CallbackDispatcher inline table: 0 $C441 census + unification score, 1 $C5B9 best-Officer card, 2 $C5DF verdict.
- Census ($C441): player Ruler id from SRAM country record (($EE) byte 0) -> $042C; sums Province byte [$0B] over 30 records into $0012/$0013; sums Officer record byte [+3] over roster slots [$11]-[$1A] (skip $FF and Ruler id) into $0010/$0011 with count in $0014.
- Score in $0435-$0437 = (avg Officer [+3] + count*100/130 + avg Province [$0B]) / 3, built via helper $C59A (B1F_MathDiv16 + 16-bit accumulate into $0435-$0437) and B1F_MathDiv24 by 3.
- Calendar display values derived from $6F00-$6F02: year = $6F00+$64 (matches bank $1D YearDisplaySetup $A6B6 exactly), month = $6F01+1, day = $6F02+1, reign years = $6F00-$59.
- Sub 1 waits on $007E (addr_nmi_ctrl), finds highest Officer record [+2] in Provinces owned by $6F03 (sram_player_id), shows his card via bank $1D $A02A (B1D_1E_OfficerDisplay_Lookup, NOT bank $19's MapProvinceDirtyMark — Y=$3D selects banks $1D+$1E), then $00A4=3, INC $0401, B1F_SetUI0 with UI card $DF (tail JMP $F26D).
- Sub 2 redraws card via $CE1F, waits for $0300/$0304 == $FF, polls $A1C2; A-button edge ($0081 bit0 via LSR) sets addr_game_state $007A = $0D and stores verdict tier $0541 from $0435: >=$46 -> 1, >=$28 -> 2, else 3; clears $04C9/$04CA. Sub 2 is terminal — the exit is the game-state change.
- $C67C-$C772 (camera scroll helpers + ProvinceCameraX/YTable) are shared with RulerSuccessionScene ($BE83/$BE9B) and were deliberately left outside the new .proc as bare globals.

## Changes
- Wrapped $C435-$C67B in .proc UnificationEndingDispatch / .endproc with full header comment; renamed Loc_C441/C459/C47E/C4A4/C59A/C5B9/C5BF/C5DF/C61A/C625/C626/C62E/C640/C646/C654/C674 to semantic @-labels; all branches symbolized; $A01E stub -> JMP UnificationEndingDispatch; converted the .byte dispatch table to .word @-entries and the $C5D0 trampoline row to .word B1D_1E_OfficerDisplay_Lookup + re-disassembled inline code (LDA #$03/STA $00A4/INC $0401/LDA #$DF/JMP B1F_SetUI0); updated prg_1b_1c.asm $A07A comment.

## Verification
- tools/verify_19_1a.py and tools/verify_1b_1c.py: 16384 bytes compared, 0 mismatches each (baseline was also 0).
