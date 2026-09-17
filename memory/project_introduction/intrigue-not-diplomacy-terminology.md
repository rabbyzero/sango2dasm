# 策略 translates to Intrigue, not diplomacy

- **Category:** project_introduction
- **Memory ID:** 5ac01b16-612f-43af-b118-c8f399b3d47e
- **Keywords:** Intrigue translation, sakuryaku category, Alliance Discord Poaching, not diplomacy, command category naming

## Content

Sangokushi 2 terminology correction (user-confirmed): the castle command category 策略 (sakuryaku), containing 同盟/Alliance, 離間/Discord, 引き抜き/Poaching, must be translated as Intrigue, NOT "diplomacy". It is also distinct from 計略/Stratagem (tactical-mode stratagems). Code renamed accordingly: IntrigueDispatch/Intrigue_Init/_ShowMenu/_HandleAction ($BC3B-$BCBE, prg_17_18), MenuAction11_Intrigue ($C3F6, prg_1d_1e), NmiState5_Intrigue ($F9A0, prg_1f), @IntriguePath and @ActionCostTable_IntrigueA/B (prg_0a_0b AI cost tables), plus B1F_/B17_18_/B1D_1E_ equates in functions.h. Recorded in docs/manual_kb/terminology.md.
