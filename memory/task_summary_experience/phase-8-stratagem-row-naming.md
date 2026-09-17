# Phase-8 stratagem row semantic naming correction in prg_0e_0f.asm

- **Category:** task_summary_experience
- **Memory ID:** 946210a8-3f48-4e16-9f27-019f148bcaf7
- **Keywords:** Phase-8 stratagem rows, Bind, Taunt, CrossbowVolley, MoraleBoost, FireArrows, Explosion, AiTacticPointSpend, semantic renaming

## Content

## Task description
- Core requirement: apply user-confirmed semantic naming corrections to Phase-8 panel row handlers in prg_0e_0f.asm
- Task background: the phase-8 point-spend panel uses auto-generated counter names (CoinFlip, StatCheck, Counter575/576/577, Advance) that do not match the game's actual stratagem identities; user confirmed the correct names from the manual_kb glossary

## Execution process
1. prg_0e_0f.asm: renamed Phase8RowCoinFlip → Phase8RowBind ($AFD2), Phase8RowStatCheck → Phase8RowTaunt ($AF26), Phase8RowCounter575 → Phase8RowCrossbowVolley ($B00E), Phase8RowCounter576 → Phase8RowMoraleBoost ($B02E), Phase8RowCounter577 → Phase8RowFireArrows ($B07C), Phase8RowAdvance → Phase8RowExplosion ($B09C)
2. prg_0e_0f.asm: updated AI purchase ladder AiTacticPointSpend labels (@CoinFlipPurchase/@StatEdgeCheck/Purchase/@Counter575/576/7Purchase/@AdvancePurchase → @BindPurchase/@TauntCheck/TauntPurchase/@CrossbowVolley/MoraleBoost/FireArrowsPurchase/@ExplosionPurchase); fixed inline ::Apply references
3. prg_0e_0f.asm: corrected comment headers for each row handler to include stratagem names and cost ladder mapping; updated PhaseATauntSubDispatch and PhaseATauntSceneOpen documentation
4. include/functions.h: updated B0E_0F_Phase8Row* equates to match new names with proper column alignment
5. code/battle_ai_decision_tree.md: updated purchase-ladder table, mermaid node labels, and quirk notes to reflect new stratagem identities
6. Verification: ran tools/verify_0e_0f.py confirming 16384 bytes compared, 0 mismatches (zero drift)

## Related files
- asm/banks/prg_0e_0f.asm
- include/functions.h
- code/battle_ai_decision_tree.md

## Notes
- The replace_all tool was unreliable for many matches across the file; used a Python script (tools/tmp_rename_0e_0f_rows.py) to ensure all occurrences were renamed deterministically
- Comment fixes required multiple SearchReplace attempts due to whitespace inconsistencies in branch-line comments
- Phase8RowCounter574 intentionally retained its name as it serves as the bind counter tail shared with PhaseATauntSceneOpen

## Task overview
Completed: All six Phase-8 stratagem row identities are now aligned with the game manual (Bind, Taunt, CrossbowVolley, MoraleBoost, FireArrows, Explosion). Cross-file consistency maintained via functions.h and battle_ai_decision_tree.md updates. Byte-exactness verified with zero drift.
