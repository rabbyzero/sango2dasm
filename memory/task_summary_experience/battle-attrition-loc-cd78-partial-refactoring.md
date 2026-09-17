# Battle attrition round routine Loc_CD78 analysis and partial refactoring

- **Category:** task_summary_experience
- **Memory ID:** 88c793ab-fc66-4456-a241-0e72822038a9
- **Keywords:** battle attrition, Loc_CD78, bank trampoline, JSR $EE07, inline .word, prg_08_09.asm, BattleAttritionRound

## Content

## Task description
- Core requirement: analyze and refactor Loc_CD78 in prg_08_09.asm, a per-round battle attrition/outcome resolution routine
- Task background: Loc_CD78 is immediately after Loc_C983 (battle casualty morale resolution); spans $CD78-$CFA1 with six nested helpers; called via bank entry stub at $A00F; uses JSR $EE07 trampoline pattern with inline .word parameter to switch banks; RAM addresses $05xx hold battle state, $000A holds officer ID parameter

## Execution process
1. Read prg_08_09.asm around $CD78-$CF06 and $CF06-$CFA2 to map the full routine structure
2. Traced bank-switching: JSR $EE07 with Y=$2E (bank param), inline word $A006 → resolves to bank 0E $A006 (JMP $D7FB in bank 0F)
3. Verified bytes at $CE19: A0 2E (LDY #$2E), 20 07 EE (JSR $EE07), 06 A0 (inline .word $A006)
4. Mapped RAM semantics: $0506=round number, $050F=attacking side, $0522/$0523 side 0 stat A, $0524/$0525 side 1 stat A, $000B/$000C=troop damage totals
5. Identified six nested helpers: $CE40 (slot attrition), $CE60 (officer troop damage), $CF60 (special officer data load), $CF92 (ruler flag store), plus $CEAB/$CF06 control flow points
6. Renamed stub Loc_A00F to BattleAttritionRound_Entry (successful)
7. Attempted full refactoring with semantic names and documentation; failed on second SearchReplace due to inconsistent indentation (some lines lacked leading spaces)

## Related files
- /home/zero/project/sango2dasm/asm/banks/prg_08_09.asm

## Notes
- SearchReplace failed when original_text didn't match due to hidden indentation inconsistencies; always re-read exact file content before large replacements
- Bank masking logic: Y=$2E & $1F = $0E for 32-bank ROM; $A000 window gets bank 0E, $C000 gets bank 0F (IN Y'd); target JMP $D7FB lands in bank 0F's $C000 window
- Inline .word after JSR trampoline is valid pattern: parameter consumed by callee, execution resumes at next label

## Task overview
Partially completed: successfully renamed bank entry stub Loc_A00F to BattleAttritionRound_Entry; fully analyzed routine semantics and cross-bank calling convention; failed to apply full semantic refactoring due to indentation mismatches in source file. Remaining work: fix indentation or use multi-step replace strategy for remaining body.
