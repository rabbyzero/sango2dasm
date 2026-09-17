# Battle scene stub routines D57B/D66E/D6CD/D70F analysis and refactoring

- **Category:** task_summary_experience
- **Memory ID:** 7a36af46-759b-4c43-8af5-e7c7ecca5f4d
- **Keywords:** BattleResultDispatch, BattleMapScrollUpdate, BattleSlotClear, inline dispatch table, bank stub collision

## Content

## Task description
- Analyzed and refactored four bank-entry routines in prg_08_09.asm: Loc_D57B, Loc_D66E, Loc_D6CD, Loc_D70F (stubs $A021/$A027/$A02A/$A024).

## Key findings
1. BattleMapScrollUpdate ($D57B-$D66D): per-frame map scroll for scenes $0500 < $0C; $0508 bit7/6/5/4 = scroll_x+=2/scroll_x-=2/scroll_y-=2/scroll_y+=2; facing flags in $009C; bits cleared on carry/borrow, ($008E & $0E)==0, or scroll_y >= $90; $0000 is a secondary direction mirror cleared on entry. Prologue $D583-$D591 was hidden code (.byte dump) — decoded to 6 instructions.
2. BattleResultSceneInit ($D66E-$D6CC): attacker $050F==3 -> ally victory (ruler flag via B1F_GetRulerDataPtr byte 3, scene $050A=$51, event 4, low nibble of $0507); else defeat ($6F44=attacker, scene $50, event 3, high nibble). Enters state $0500=7, $0501=2.
3. BattleSlotClear ($D6CD-$D70E): slot index in $0000; clears column of 7 record tables ($0600/$0614/$0628/$063C/$0650/$0664/$6FA1) plus the 4-byte timer group ($04D8 or $04DC) whose owner matches.
4. BattleResultDispatch ($D70F-$D739): called every frame from NmiState7_Strategy ($FA44, prg_1f) with banks 08/09; runs dir-repeat handlers $DB10/$DB62/$DBB4/$DBFF, then two B1F_CallbackDispatcher inline tables ($0540 single entry -> Loc_D723; $0541 seven phases Loc_D73A..Loc_D8E4). Dispatcher pops JSR return and JMPs, so phase RTS tail-returns to the NMI caller.
5. Stub addresses collide across bank pairs: .word $A027 with LDY #$3D targets prg_1d_1e ProvinceDataHandler, only LDY #$28 targets bank 08/09 stubs — check the LDY bank param before attributing trampoline targets.
6. $D8C3 in phase 5 is DEC $0541 (cancel/back to phase 4), not JSR $41CE — the old disassembler mis-split the branch offset byte as an opcode.

## Verification
- tools/tmp_verify_d57b.py: bank 09 ($C000-$D739) byte-exact, 0 mismatches; build error count unchanged (182 pre-existing, all corrupted regions $DA8D+). Bank 08 has 923 pre-existing mismatches ($BAF4+) from earlier unverified working-tree drift in BattleAttackerSetup (@AttNotAtWar misplaced) — unrelated to this task.

## Related files
- /home/zero/project/sango2dasm/asm/banks/prg_08_09.asm
- /home/zero/project/sango2dasm/tools/tmp_verify_d57b.py
