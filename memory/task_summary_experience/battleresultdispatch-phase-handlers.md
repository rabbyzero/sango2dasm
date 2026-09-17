# BattleResultDispatch phase handlers and helpers fully decoded in prg_08_09.asm

- **Category:** task_summary_experience
- **Memory ID:** bb23ee86-4c41-402f-921a-b39bd183500e
- **Keywords:** BattleResultDispatch, phase handlers, prg_08_09, padding, DCD4, DFFF, BattleResultSlotTemplateApply

## Content

## Task description
Analyzed and refactored BattleResultDispatch ($D70F) in prg_08_09.asm: all 7 phase handlers ($D73A-$D905), helpers ($D906-$DB0F), dir-repeat handlers ($DB10-$DC49) and slot reset ($DC4A-$DCB6). Bank 09 verified byte-exact $C000-$DFFF (tools/tmp_verify_d70f.py).

## Key findings
1. Phases are nested .procs inside BattleResultDispatch: InitRecords, OpenMenuWait, SelectMenuEntry, ConfirmMenuWait, PickEntry, InspectEntry, Finalize. Flow: init 7 entry records ($6F07..$6F3A, ids AD,08,83,8A,DE,DC,B6, status byte at +3) -> wait A/B -> menu select (clears status; $6F43 decides confirm-wait vs direct finalize) -> pick (status 0: banked slot clear $A02A bank $3D + UI $DB; status!=0: consumed -> phase 6) -> inspect (banked $A000 bank $39; A/B -> DEC back to phase 4 with id in $0410) -> finalize (banked $A000; $0087<0 -> BattleResultSlotReset).
2. Hidden code recovered: phase 5 body after trampoline word $A000 (incl. DEC $0541 cancel); phase 6 (LDA $0087/BPL/STA $007A/JMP $DC4A); BattleResultMenuPoll $D932-$D979 (two trampoline words $A000/$A012, B1F_MenuStep2 over EntryOrderList); phase 4 tail after word $A02A (LDA #$DB; JMP B1F_SetUI0).
3. $DA68-$DAD8 is ONE 28-record OAM layout terminated by $80 (previous asm split it at $DA8C and misdisassembled $DA8D-$DAD8 as garbage code). Tables: $DA07 RowToRecordMap, $DA0F RecordInitTable (7x4), $DA2B EntryOrderList, $DA35 CursorPosTable (7 x Y,X bases for B1F_PointerTableLookup), $DA43 cursor layout, $DAF9 marker layout, $DCB7 SlotRecordPtrs, $DCC5 SlotRecordTemplate (copied with Y=2..$10).
4. Dir-repeat groups 0-3: counters $0545-$0548, latch bits 0-3 in $6FEA, sound $62 via B1F_SoundWrapperE; groups 0/1 gated to phases 1/3, 2/3 ungated. Group 2 edge masks are 80 80 20 20 10 20 10 20 (misread as three $80s from misaligned dump).
5. $DCD4-$DFFF is $FF padding, now .res $032C. BattleResultSlotTemplateApply proc spans $DC9C-$DCD3 (code + data tables encapsulated).
6. Pitfall: merging the two consecutive RTS bytes ($DB50/$DB51 pattern) of dir-repeat groups shifts branch offsets; keep both RTS instructions (@Done/@Done2).

## Related files
asm/banks/prg_08_09.asm, tools/tmp_verify_d70f.py
