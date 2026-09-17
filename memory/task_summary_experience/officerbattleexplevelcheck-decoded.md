# OfficerBattleExpLevelCheck decoded in prg_0e_0f.asm ($D7FB-$D8AF)

- **Category:** task_summary_experience
- **Memory ID:** 198ff96f-cd83-4a59-8a17-c3c500b0f828
- **Keywords:** OfficerBattleExpLevelCheck, experience thresholds, MightGain, officer level nibble, record bytes 6-7

## Content

## Task description
Decoded $D7FB-$D8AF in asm/banks/prg_0e_0f.asm as proc OfficerBattleExpLevelCheck: battle experience accrual + level-up check for the commander officer.

## Key findings
1. Input: $000A <- officer id ($0560[acting side] commander), $000B/$000C <- 16-bit damage amount. Callers: bank entry Loc_A006, Phase2DamagePanelUpdate ($A7DC), Phase9AdvanceContactApply ($B4E0).
2. Flow: B1F_GetOfficerRecordAddr -> ($00); amount/2 (LSR/ROR) added to officer record bytes 6-7 = 16-bit Experience (capped at $C34F=49999); level = record byte $0B high nibble (>=7: done); Experience >= OfficerLevelExpThresholds[level] ($D85B, 7 words: $03E8/$07D0/$0DAC/$1388/$1D4C/$2710/$3A98) -> level bump (byte $0B high nibble +1, low nibble kept) plus MightGain to record byte 1 (Might): +6 if <$33, +5 if <$47, +4 if <$51, +2 if <$5A, none if >=$5A.
3. Terminology alignment from docs/manual_kb/terminology.md: Experience/Might/OfficerLevel/LevelUp/MightGain.
4. The following Loc_D8B0 (bank entry Loc_A009) wraps the routine: amount <- record[1]+record[2], $000C<-0, JMP $D7FB.

## Notes
- Pitfall: @-local labels referenced across the mid-proc threshold table (OfficerLevelExpThresholds) broke ca65 local scoping; shared targets DoneNoMight/LevelUp must be bare labels inside the .proc (a non-@ label resets @-local scope).
- Verified byte-exact via tools/verify_0e_0f.py (16384 bytes, 0 mismatches).
