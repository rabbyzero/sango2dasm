# Loc_DB72 scout roll and math helpers decoded in prg_1b_1c.asm

- **Category:** task_summary_experience
- **Memory ID:** 489d8618-306d-43e2-b301-a4f629cf0e2a
- **Keywords:** CastleScoutOutcomeRoll, MathDivideProduct, ActionDeltaWorkReset, scout outcome table, prg_1b_1c

## Content

Loc_DB72 chunk ($DB72-$DC6A) of prg_1b_1c.asm decoded and refactored into three .procs with @-locals, byte parity re-verified 0 mismatches via tools/verify_1b_1c.py.

1. MathDivideProduct ($DB72-$DB84, bank $1C): tail-call wrapper — copies the B1F_MathMul24x8 product from $0006-$0008 into dividend $0000-$0002 and JMPs to B1F_MathDiv24 ($EAA5; dividend $00-$02, 16-bit divisor $03/$04, quotient $00-$02, remainder $05-$07). 8 call sites in the bank pair (castle dev $A5A3/$A5CF, warehouse give $BCC9, populace give $BE8E/$BEAB, market rice buy/sell $C291/$C317/$C3F4); one site ($C294) clamps a zero remainder up to 1.
2. ActionDeltaWorkReset ($DB87-$DB98): clears the shared numeric-input work area $048B-$048F (digit cursor, BCD pairs, delta value); 17 call sites, all amount-entry seeds (e.g. SortieProvisionSeed $B08C).
3. CastleScoutOutcomeRoll ($DB99-$DC22): scout (情報集め) outcome roll called only from CastleScoutExecute sub 13 with acting officer in $0481; result class 0-8 -> $0470. Virtue (+$04) base 0/$18/$30 (thresholds $29/$51) + Intelligence (+$02) offset 0/$08/$10 select a group in the new 72-byte CastleScoutOutcomeTable ($DC23-$DC6A, 9x8) indexed + B1F_RandomMod8. Roster-full flag $0011 bit7 (ProvinceOfficerCount == 10). Open roster + class 5-7 -> banked call Y=$39 to B19_1A_OfficerArrivalScan (found: $0472 id/$0473 param/$0470=$07 or unchanged if id misses ArrivalParamTable; not found: $0011=$80 -> retry); full roster retries classes >=5; class 8 passes through without scan.
Key fixes: bytes $DC1B-$DC1C were the inline trampoline .word (now .word B19_1A_OfficerArrivalScan) and $DC1D-$DC22 (LDA $0011/BMI/RTS) were code misclassified as .byte data; class-8 note: prior label CastleScoutFoundOfficer routes to sub $16/CastleScreenIdleWait with panel $00A4=4, UI $35.
ROM quirk documented: on the Virtue<$29 path X is not reloaded, so the table base is the leftover roster count from ProvinceOfficerCount (0-10) instead of 0.
Ca65 note: verify_1b_1c.py caught the omission immediately — always rerun the per-bank harness after refactoring; an undefined @-label means a dropped code block, check byte drift.
