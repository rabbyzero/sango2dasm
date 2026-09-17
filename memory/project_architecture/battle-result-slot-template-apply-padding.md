# BattleResultSlotTemplateApply proc structure and padding layout

- **Category:** project_architecture
- **Memory ID:** dc5643a0-aeea-4387-a2bd-64ec45f2db25
- **Keywords:** BattleResultSlotTemplateApply, proc boundaries, data encapsulation, prg_08_09.asm, padding

## Content

In prg_08_09.asm (Sangokushi 2 NES disassembly):
- BattleResultSlotTemplateApply proc spans $DC9C-$DCD3, encapsulating its exclusive data tables: BattleResult_SlotRecordPtrs (7 words at $DCB7-$DCC4) and BattleResult_SlotRecordTemplate (15 bytes at $DCC5-$DCD3)
- Padding area $DCD4-$DFFF uses .res $032C, $FF directive (812 bytes of $FF padding)
- This follows the encapsulation principle where procedure-specific data tables are kept inside the proc scope rather than scattered globally
