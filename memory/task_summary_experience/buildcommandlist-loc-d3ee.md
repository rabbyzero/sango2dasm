# BuildCommandList routine Loc_D3EE analysis and refactoring

- **Category:** task_summary_experience
- **Memory ID:** 2777a6d8-26b8-4aec-a72d-012bd7f65d59
- **Keywords:** BuildCommandList, slot tier table, special officer roster, command menu setup, bank stub A01B

## Content

## Task description
- Analyzed and refactored Loc_D3EE ($D3EE-$D508) in prg_08_09.asm into `.proc BuildCommandList`; bank stub $A01B renamed BuildCommandList_Entry.
- The adjacent routine $D390 was concurrently refactored (separate session) into `.proc ValidateSpecialOfficer` with nested @SpecialOfficerTable ($D3D8); both share the special officer roster semantics.

## Key findings
1. Routine builds the commander's command/slot ID list at $0580-$058F ($FF-filled tail) and stores count-1 into $0542. Commander = $0664[$050A] (battle roster indexed by scene/command id). Officer record via B1F_GetOfficerRecordAddr ($F2D7, $63C0+id*12).
2. Status class = high nibble of record byte 11. Special officers (roster ids: class3=$A1,$63,$A7,$16,$C4,$DB,$EA,$6B,$CE,$EB,$B7; class4=$18,$37,$70,$D5,$6E,$67; class5=$C5,$56,$5D; $6D alone) get extended slot tiers 5-8 by class threshold; everyone else falls back to record byte 2 rating thresholds $28/$3C/$4B/$55 -> tiers 0-4.
3. SlotTierPtrs ($D509, 9 .word entries) maps tier -> SlotList_2/4/6/8/10/12/14/15/16 ($D51B-$D57A), $FF-terminated sequential slot ID lists; converted from raw .byte to labeled .word/.byte.
4. Cross-bank caller: prg_0c_0d CommandState_Init ($A8BB) via B1F_BankedCallbackTrampoline LDY #$28, inline .word $A01B. Consumers use $0542 to pick menu layout (MenuTypeItemListPtrs) and iterate $0580 (CommandPhase_BuildMsg, CommandState_Menu).

## Verification
- make: zero errors in refactored region; all remaining errors pre-existing in undisassembled regions (line 7853+).
- Address arithmetic of converted tables verified (SlotList_N offsets and pointer values match original bytes exactly).

## Notes
- Editor save state was flaky during this session ("save failed, reason: unknown" while edits did apply); always verify actual file content via shell grep/sed before retrying SearchReplace.

## Related files
- /home/zero/project/sango2dasm/asm/banks/prg_08_09.asm
