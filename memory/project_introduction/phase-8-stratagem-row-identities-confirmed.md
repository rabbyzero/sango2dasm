# Phase-8 stratagem row identities confirmed in prg_0e_0f.asm

- **Category:** project_introduction
- **Memory ID:** 35b1acb3-829e-435a-b27c-5e5ac00de748
- **Keywords:** Phase-8 stratagem rows, Bind, Taunt, CrossbowVolley, MoraleBoost, FireArrows, Explosion, cost ladder

## Content

Sangokushi 2 disassembly project Phase-8 point-spend panel stratagem identities (prg_0e_0f.asm): row 0 = Bind (Jubaku), row 1 = Taunt (Chouhatsu), row 2 = CrossbowVolley, row 3 = MoraleBoost, row 4 = FireArrows, row 5 = Explosion (Bakuen). The cost ladder is @RowCostTable 3/5/7/8/$A/$C matching docs/manual_kb/06-reference-tables.md. Apply multi-entry tails are shared with AI ladder AiTacticPointSpend (@BindPurchase cost 3 → phase A sub 0, @TauntPurchase cost 5 → phase A sub 4, @ExplosionPurchase cost $0C, @FireArrowsPurchase $0A, @MoraleBoostPurchase $08, @CrossbowVolleyPurchase $07). Cross-bank equates B0E_0F_Phase8Row* in include/functions.h follow this naming.
