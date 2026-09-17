# Province record layout and AI action-to-castle-command mapping

- **Category:** project_architecture
- **Memory ID:** a58a7941-0f51-4d78-b65e-c5f1a6a7b486
- **Keywords:** province record, CPU RAM layout, castle development, AI actions, Sangokushi 2

## Content

The Sangokushi 2 disassembly uses a 32-byte province record in CPU RAM with the following verified layout: +$00 owner code, +$01 unused/flags, +$02/$03 Gold (reserve), +$04/$05 Rice (米), +$06/$07 Population ÷100 (人口), +$08/$09 LandValue (土地, cap 999), +$0A DisasterPrevention (防災, cap 99), +$0B Governance (統治度, cap 100), +$0C/$0D ReserveTroops (控え, cap 10000), +$0E/$0F Industry (産業, cap 999), +$10+ officer roster pointers. The AI turn engine's stat-boost actions are direct implementations of castle development commands: @AiAction_TownDevelopment writes to +$06/$07 Population, @AiAction_LandReclamation writes to +$08/$09 LandValue (April–August only), @AiAction_IndustryDevelopment writes to +$0E/$0F Industry, @AiAction_DisasterPrevention writes to +$0A, and @AiAction_GovernanceBoost spends Gold AND Rice via DeductRecordStat2/Stat4 to raise +$0B Governance. Dev gain formulas are "spend × level_mod / 10" (TownDevelopment halves it), not "province_idx × $0E × mod".
