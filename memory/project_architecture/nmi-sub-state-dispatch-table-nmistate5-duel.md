# NMI sub_state dispatch table mapping and NmiState5_Duel rename

- **Category:** project_architecture
- **Memory ID:** fae9d0a2-db6f-4ae9-be99-e458a384db77
- **Keywords:** NmiDispatchTable, NmiState5_Duel, addr_sub_state, Tactical Mode, MainGameDispatch

## Content

NMI VBlank handler dispatch in prg_1f.asm ($F800 NmiHandler) indexes NmiDispatchTable ($F87B) by addr_sub_state ($0078) & $0F. Verified mapping of sub_state writer to handler: 2=State_NewGameInit->NmiState2_MapScreen, 3=$E18E handler->NmiState3_Battle, 4=$E22F handler->NmiState4_Menu, 5=State_TacticalMode ($E2ED)->NmiState5_Duel, 6=State_CountryMapView->NmiState6_Event, 7=State_AdvisorCouncil->NmiState7_Strategy, 8=State_TurnSummary->NmiState8_Officer. NmiState5 was originally misnamed NmiState5_Intrigue (策略); corrected: it is the Tactical Mode frame handler whose sole game-logic payload is B17_18_MainGameDispatch ($B100), a 22-entry duel-scene dispatcher (DuelScene/DuelCommand/DuelAi/DuelStrikeResolve/Surrender/Persuade/Insult/Strike/Feint/Desperate etc.). Only bank $1F writes $0078. The old Intrigue name was wrong on both counts: not the stratagem system, and driven by Tactical Mode.
