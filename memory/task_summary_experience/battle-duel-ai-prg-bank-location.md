# Battle and duel mode AI decision PRG bank location analysis

- **Category:** task_summary_experience
- **Memory ID:** 484d8de0-2bc6-4873-91e7-43cccc422fff
- **Keywords:** battle mode, duel mode, AI decision, PRG bank, tactical war layer, game mode hierarchy, prg_0e_0f, prg_17_18, prg_08_09

## Content

## Task description
- Core requirement: locate AI action decision PRG banks for battle and duel modes in Sangokushi 2 disassembly
- Task background: user initially conflated Tactical Mode with Battle Mode; needed clarification on game mode hierarchy (Strategy > Tactical > Battle > Duel) and exact bank locations

## Execution process
1. Searched codebase for "AI action decision battle duel mode tactical AI dispatch PRG bank" to identify relevant files
2. Grep'd for "duel|Duel" in functions.h and asm/banks to locate duel-related code
3. Read prg_17_18.asm to analyze DuelDispatch and Duel_RandomEvent logic
4. Read prg_0e_0f.asm file header to confirm Battle Mode overlay + animation/sound engine location
5. Read prg_0c_0d.asm file header to verify stratagem system location
6. Grep'd for BattleInitDispatch/BattleSetup_Exec in prg_17_18.asm to find entry points
7. Cross-referenced memory about semantic distinction between war/tactical layer and Battle Mode
8. Verified that prg_08_09.asm is Tactical/War layer (not Battle Mode) per terminology authority
9. Synthesized answer distinguishing: prg_0e_0f.asm (Battle Mode core), prg_17_18.asm (entry/init), prg_08_09.asm (Tactical war AI)

## Related files
- /home/zero/project/sango2dasm/asm/banks/prg_0e_0f.asm
- /home/zero/project/sango2dasm/asm/banks/prg_17_18.asm
- /home/zero/project/sango2dasm/asm/banks/prg_08_09.asm
- /home/zero/project/sango2dasm/code/bank_switch_map.md
- /home/zero/project/sango2dasm/code/tactical_ai_decision_tree.md

## Notes
- User misconception: thought prg_08_09.asm was Battle Mode; actually it's Tactical/War layer
- Battle Mode is a sub-scenario of Tactical Mode, not a peer
- Duel Mode has no separate AI brain; uses player-alternating state machine

## Task overview
Completed: Identified exact PRG bank locations for battle and duel mode AI decisions. Battle Mode core is prg_0e_0f.asm ($0E+$0F); duel mode logic is in prg_17_18.asm; tactical war AI is in prg_08_09.asm. Clarified game mode hierarchy and corrected terminology confusion.
