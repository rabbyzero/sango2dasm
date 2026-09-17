# BattleAttritionRound routine Loc_CD78 analysis and documentation

- **Category:** task_summary_experience
- **Memory ID:** 2946b252-e9ba-4b71-a4ad-f051b146cbff
- **Keywords:** BattleAttritionRound, prg_08_09, attrition resolution, bank pair 2E, officer 6D, outcome scene

## Content

## Task description
- Analyzed and documented Loc_CD78 ($CD78-$CFA1) in prg_08_09.asm: renamed to proc BattleAttritionRound, bank stub $A00F renamed BattleAttritionRound_Entry.

## Key findings
1. Routine runs one battle round: if round counter $0506 >= $1F (30 rounds) -> stalemate; else ComputeScaledStats (BattleCasualtyResolution::SetScaleFactor, entry $CD06) with scale $01 rolls per-round losses ($001A/$001B ally, $001C/$001D enemy).
2. Side B stat A ($0524/$0525) -= ally roll -> zero means annihilation ($0000=$80) and ally-side outcome ($CEAB); side A stat A ($0522/$0523) -= enemy roll -> zero -> enemy-side outcome ($CF06). Both survive -> two attrition passes over $0650 slot table (lo nibble mask $0F/-1, then hi nibble mask $F0/-16 with random officer troop damage $50-$96 into record bytes 8-9, accumulated in $000B/$000C).
3. Special officer id $6D in $0664 roster: if Power (record byte 1) != 0, JSR $EE07 trampoline with inline .word $A006 maps bank pair $2E ($A000<-prg $0E, $C000<-prg $0F), jumps to bank $0E $A006 stub -> JMP $D7FB in bank $0F, which updates officer $6D record bytes 6-9 from $000B/$000C. Inline .byte was corrected to .word.
4. Outcome variables: $050A scene id ($B5 special, $BE stalemate, $BF annihilation), $0514 side selector (1=ally branch, 0=enemy branch), $0509 variant, $00A4 event index, $042C ruler id from $0507 nibbles, $6F44 SRAM ruler result flag.
5. @SetScaleFactor promoted to bare label SetScaleFactor: ca65 cannot reference @ cheap-local labels across procs via Scope::@label.
6. Ends with 5-slot action timers $04DB expiring into $04D8 flags, then RTS.

## Verification
- All instruction byte comments in proc verified against prg_09.bin (0 mismatches); make shows no new errors (remaining errors are pre-existing undisassembled regions $D15C+).

## Related files
- /home/zero/project/sango2dasm/asm/banks/prg_08_09.asm
