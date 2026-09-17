# TownCommandDispatch state 5 decoded in prg_1b_1c.asm with zero drift

- **Category:** task_summary_experience
- **Memory ID:** 624ae1a8-5934-4899-8829-15040abee243
- **Keywords:** TownCommandDispatch, town screen, armory, academy, hospital, market, weapon grid, ExpandFormationSlots reuse, zero-page a: prefix

## Content

## Task
Code analysis of prg_1b_1c.asm frame state 5 ($BFB7-$CADC, formerly Loc_BFB7): decoded as TownCommandDispatch, the Town (町) command screen (state 5, entered from CommandCategoryMenuDispatch category 3 via `STY $0400` = selection+2). Zero byte drift confirmed by tools/verify_1b_1c.py ("0 mismatches").

## Decode findings
24 sub-states (table $BFBD-$BFFC) implementing the manual's four town facilities (04-strategy-commands.md p.27; action codes in table $C10E, 4 per facility set, sets in per-province table $C025, UI modes $C043): 0=Armory 武器屋 (subs $12-$17: weapon grid menu $C7EE, grid cells $044C-$044F filled by banked call to banks $08+$09 $A01E ExpandFormationSlots_Entry — the formation tile layout tables are REUSED as weapon-grid cells (cell $00-$17 weapon / $18-$1D armor) and price records $042C+slot*3; item desc PPU stream from bank $30 $9B12 pointer table; famous-weapon restrictions via @WeaponGateCheck $CA6B: cell $0F needs officer $26, $17 officer $99, $16 Might>=91, $1E Virtue>=91, event bits into $6FE1 via $0472 mask; province $1B special: 4th cell weapon $17 @ $0190). 1=Academy 学問所 (subs $0E-$11: INT tiered fee $0A/$14/$1E for INT $3D-$4F/$1F-$3C/<$1F, Intelligence += rand(0..4)+tier). 2=Hospital 病院 (subs $0A-$0D: fee $32=50 gold, Vitality += $23+rand(0..10) clamped). 3=Market 商店 (subs 2-9: rice buy/sell with per-province rates from bank $30 $8FC0 (2 bytes/province right after the 30 province records; byte0 sell gold-per-100-rice, byte1 buy rice-per-100-gold), treasure sell 宝→金100 exact via B1F_MathMul24x8 product $0006/$0007 and $DB72 32/16 divide quotient $0000/$0001 remainder $0005). Shared result/exit subs $0F-$11. Officer-card cleanup flag $0473.

## Label style
.proc TownCommandDispatch with 24 @-prefixed sub-handlers + @WeaponGateCheck, symbolic .word table, @-labels for all data tables; raw bank-$30 data ($8FC0, $9B12) kept as operands with comments per file convention. Cross-boundary `STA $0473` kept as `.byte $8D` + `.segment "CODE_BANK1C"` + `.word $0473`.

## Pitfalls hit
1. ca65 silently assembles `STX $0010` / `STA $0000` / `LDY $0010` as zero-page (2-byte) — newly emitted instructions need the `a:` prefix (`STX a:$0010`) or they shift all later labels; here a -7 byte drift caught by verify_1b_1c.py.
2. Never run `git checkout -- <file>` in this repo: the working tree often carries uncommitted decode state. This destroyed the uncommitted WarehouseCommandDispatch decode; recovered from dangling stash/blob via `git cat-file --batch-all-objects` scan (blob 4c592380 was the pre-session state), identified by matching comment-wrap details and line count (7818) against session-start reads.

## Files
asm/banks/prg_1b_1c.asm; tools/tmp_town_bfb7.py + tools/tmp_town_header.txt (transform script, idempotent-unsafe: revert file to pre-transform state before rerunning).
