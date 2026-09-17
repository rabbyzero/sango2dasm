# Phase 5 side event handler decoding in BattleOverlayDispatch

- **Category:** task_summary_experience
- **Memory ID:** 1a0ccb6b-8909-49df-9140-b01d21e28d00
- **Keywords:** phase 5, side event, BattleOverlayDispatch, sub-dispatch, roster commit, retreat marking

## Content

## Task description
- Core requirement: analyze and decode phase 5 side event handlers in prg_0e_0f.asm at addresses $CD43-$CE24
- Task background: The battle overlay dispatch state machine (BattleOverlayDispatch) includes phase 5 as a side event handler triggered when units move to column 0/$0B. The raw .byte blob at $CD43-$CD4E was misidentified as data; it actually contains the sub-dispatch entry point. Three sub-handlers ($CD4F, $CD59, $CDCF) needed decoding and semantic naming.

## Execution process
1. Verified bytes $CD43-$CD4E via tools/verify_0e_0f.py (16384 bytes, 0 mismatches)
2. Decoded $CD43-$CD4E as inline dispatch pattern: LDA $0541, JSR B1F_CallbackDispatcher, .word table pointing to Loc_CD4F, Loc_CD59, Loc_CDCF
3. Replaced raw .byte blob with .proc Phase5SideEventSubDispatch containing the inline .word table
4. Updated phase table entry at $A079 from Loc_CD43 to Phase5SideEventSubDispatch with comment "phase 5: side event"
5. Decoded sub 0 ($CD4F): calls B1F_PaletteCopyBuffer, then BattleOverlayTotalRefresh ($CA3F) to commit troop counts and HP sums to commander roster records
6. Decoded sub 1 ($CD59): waits for VBlank sync, calls B1F_NmiDisable, sets flash counter, assigns overlay strip pointers to $04AD/$04AE based on pad modes $0562/$0563 (direct or swapped order), sets AI flags $04AB/$04AC to $80 when mode=3
7. Decoded sub 2 ($CDCF): reloads troop counts from roster records via B1F_GetOfficerRecordAddr, calls Phase5RetreatSlotMark helper twice, exits by setting $0540←0, $0541←1 (re-enters phase 0 sub 1)
8. Named helper routine Loc_CE10 as Phase5RetreatSlotMark: compares strip pointer against $0560, sets $0550/$0554 (side A/B action slot 0) when flag==1 (retreat)
9. Renamed Loc_CA3F to BattleOverlayTotalRefresh across all 5 call sites ($A3EE, $A42C, $A4A9, $A4D4, $CD55)
10. Verified byte-exactness again: 16384 bytes, 0 mismatches
11. Confirmed build failure is pre-existing (symbol conflicts in other banks)

## Related files
- asm/banks/prg_0e_0f.asm

## Notes
- Pre-existing build failures unrelated to changes; confirmed via git stash test
- Cross-bank helpers already named in functions.h: B1F_PaletteCopyBuffer, B1F_NmiDisable, B1F_GetOfficerRecordAddr
- Inline dispatch pattern matches Phase0IntroSubDispatch structure
- Shared exit labels must be bare globals between .proc scopes (Phase5WaitExit at $CD58)

## Task overview
Successfully decoded and renamed phase 5 side event handlers: Phase5SideEventSubDispatch ($CD43), Phase5SideEventRosterCommit ($CD4F), Phase5SideEventPanelSetup ($CD59), Phase5SideEventClose ($CDCF), Phase5RetreatSlotMark ($CE10), and BattleOverlayTotalRefresh ($CA3F). All changes verified byte-exact with 0 mismatches.
