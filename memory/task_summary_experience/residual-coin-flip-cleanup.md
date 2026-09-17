# Residual coin flip naming cleanup after Phase-8 stratagem renaming

- **Category:** task_summary_experience
- **Memory ID:** 46cb8cd5-7f8a-43ce-8338-b7705367c1ed
- **Keywords:** coin flip naming, Bind stratagem, semantic cleanup, generated dump sync, comment rewording

## Content

## Task description
- Core requirement: scan for and fix remaining "coin flip" naming references that described the old Bind stratagem identity
- Task background: after Phase-8 stratagem row semantic renaming (Bind/Taunt/CrossbowVolley/etc.), some comment text still used "coin flip" as the row's identity rather than describing it as a mechanic; also generated dumps and documentation carried stale identifiers

## Execution process
1. Residual scan: grep for "coinflip"/"coin flip"/"CoinFlip" across asm/include/code/docs/memory/tools directories
2. Identified three categories of matches: (a) genuine 50/50 mechanic descriptions (kept), (b) identity-flavored comments needing rewording (fixed), (c) stale identifiers in generated docs (synced)
3. Fixed prg_0e_0f.asm line 2864: rewrote "row 0 (Bind) is a coin flip that targets..." → "row 0 (Bind) coin-flips and on a hit targets..." to make coin flip the mechanic, not identity
4. Fixed include/functions.h line 1244: updated B0E_0F_Phase8RowBind comment from "Bind coin-flip effect" → "Bind effect (coin-flip hit)"
5. Synced code/prg_0e_0f_ram_usage.txt (generated dump): ran Python script to replace 67 occurrences of old proc names (Phase8RowCoinFlip→Phase8RowBind, Phase8RowStatCheck→Phase8RowTaunt, etc.)
6. Fixed memory/project_architecture/battleoverlaydispatch-state-machine.md: replaced @CoinFlipPurchase/@StatEdgePurchase → @BindPurchase/@TauntPurchase
7. Verification: grep confirmed no CoinFlip identifiers remain; tools/verify_0e_0f.py reported 16384 bytes compared, 0 mismatches

## Related files
- asm/banks/prg_0e_0f.asm
- include/functions.h
- code/prg_0e_0f_ram_usage.txt
- memory/project_architecture/battleoverlaydispatch-state-machine.md

## Notes
- Genuine coin-flip mechanics (B1F_RandomByte bit-0 rolls, order-slot $80 Advance/Hold flip) were intentionally kept as they describe real game logic, not naming errors
- Generated dumps require periodic sync when proc names change; manual updates via targeted Python scripts are more reliable than search-replace for bulk replacements

## Task overview
Completed: all "coin flip" naming remnants fixed where they incorrectly identified the Bind stratagem; genuine mechanic descriptions preserved; zero-drift verification passed
