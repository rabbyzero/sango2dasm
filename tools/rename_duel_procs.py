#!/usr/bin/env python3
"""One-shot mechanical rename of the mislabeled duel-module identifiers.

Applies whole-word replacements (longest-first) to prg_17_18.asm and the
B17_18_* aliases in include/functions.h. Idempotent: already-renamed
occurrences are untouched.
"""
import re
import sys

REnames = [
    # longest-first within shared prefixes
    "EventCutsceneDispatch2:TacticDialogDispatch",
    "EventCutscene2_Init:TacticDialog_Init",
    "EventCutscene2_LoadData:TacticDialog_LoadName",
    "EventCutscene2_Show:TacticDialog_ShowAppeal",
    "EventCutscene2_Execute:TacticDialog_Execute",
    "EventCutscene_LoadOverlay:TacticDialog_LoadCards",
    "EventCutsceneDispatch:SurrenderSceneDispatch",
    "EventCutscene_Init:Surrender_Init",
    "EventCutscene_ShowText:Surrender_ShowText",
    "EventCutscene_Display:Surrender_Display",
    "EventCutscene_NoEvent:Surrender_NoEvent",
    "EventCutscene_Execute:Surrender_Execute",
    "EventCutscene_Cleanup:Surrender_Cleanup",
    "EventCutscene_NoOp:Surrender_NoOp",
    "StrategyModeDispatch:DuelSceneDispatch",
    "StrategyMode_StoreOfficerSlot:DuelScene_StoreNameTile",
    "StrategyMode_InitOfficers:DuelScene_InitOfficers",
    "StrategyMode_ShowMessage:DuelScene_ShowMsg",
    "StrategyMode_ShowDialog:DuelScene_ShowDialog",
    "StrategyMode_LoadPortrait:DuelScene_LoadPortrait",
    "StrategyMode_BuildSpriteData:DuelScene_BuildRiderSprites",
    "StrategyMode_FinalizeSprites:DuelScene_FinalizeSprites",
    "StrategyMode_CalcEquipSpeed:DuelScene_CalcEquipSpeed",
    "StrategyMode_SetupDisplay:DuelScene_ShowChallenge",
    "StrategyMode_NameTileLookup:DuelScene_NameTileLookup",
    "StrategyMode_EquipWeightTable:DuelScene_EquipWeightTable",
    "TroopAssignmentDispatch:DuelCommandDispatch",
    "TroopAssign_SelectTarget:DuelCmd_RoundSetup",
    "TroopAssign_Execute:DuelCmd_RenderStats",
    "TroopAssign_ShowMenu:DuelCmd_CommandMenu",
    "TroopAssign_HandleResult:DuelCmd_CommandRoute",
    "TroopAssign_Confirm:DuelCmd_TacticConfirm",
    "TroopAssign_ShowSummary:DuelCmd_TacticSelect",
    "TroopAssign_NextState:DuelCmd_FillStatTiles",
    "TroopAssign_MenuData:DuelCommandMenuData",
    "TroopAssign_SummaryMenuData:DuelTacticMenuData",
    "troop_assign_counter_lo:menu_cursor_col",
    "troop_assign_counter_hi:menu_cursor_page",
    "WarClash_CompareForces:DuelAi_SurrenderCheck",
    "WarClash_MoraleCheck:DuelAi_DesperateCheck",
    "WarClash_DefenseCheck:DuelAi_StrikeCheck",
    "WarClash_OfficerDuel:DuelAi_TacticCheck",
    "WarClash_DetermineOutcome:DuelAi_PickFeintStrike",
    "WarClash_OutcomeTable:DuelAi_FeintStrikeTable",
    "WarClash_SetActionResult:DuelAi_CommitCommand",
    "WarClash_LoyaltyCalc:DuelAi_SurrenderThreshold",
    "WarClash_DefenseCalc:DuelAi_DesperateThreshold",
    "WarClash_LeadershipCheck:DuelAi_StrikeThreshold",
    "WarClash_DuelCheck:DuelAi_PersuadeThreshold",
    "WarClash_FinalCalc:DuelAi_InsultThreshold",
    "WarClashDispatch:DuelAiDispatch",
    "WarResult_Calculate:DuelStrike_Resolve",
    "WarResult_ApplyTroopLoss:DuelStrike_ApplyGauge",
    "WarResult_ShowVictory:DuelStrike_ShowParried",
    "WarResult_CheckContinue:DuelStrike_WaitConfirm",
    "WarResult_Finalize:DuelStrike_NextRound",
    "WarResult_ComputeDifferential:DuelStrike_ComputeDifferential",
    "WarResultDispatch:DuelStrikeResolveDispatch",
    "Duel_ShowMenu2:DuelPursue_WindowSlideOut",
    "Duel_ShowMenu:DuelPursue_WindowSlideIn",
    "Duel_CheckContinue:DuelPursue_WaitIntro",
    "Duel_CheckFlee:DuelPursue_CheckDeath",
    "Duel_CheckEnd:DuelPursue_EscapeFinish",
    "Duel_PlayerAction:DuelPursue_SetupPursuer",
    "Duel_RandomEvent:DuelPursue_EscapeRoll",
    "Duel_ApplyDamage:DuelPursue_ApplyStrike",
    "Duel_NextRound:DuelPursue_DeadHandoff",
    "Duel_Init:DuelPursue_Init",
    "DuelDispatch:DuelPursueDispatch",
    "Intrigue_HandleAction:DuelData_HandleInput",
    "Intrigue_ShowMenu:DuelData_ShowCard",
    "Intrigue_Init:DuelData_Init",
    "IntrigueDispatch:DuelDataToggleDispatch",
    "BattleInit_Setup:PersuadeRollEvent",
    "BattleInit_Position:Persuade_FadeOut",
    "BattleInit_Configure:Persuade_WaverHandoff",
    "BattleInit_Finalize:Persuade_AcceptHandoff",
    "BattleInit_FormationData:PersuadeEventTable",
    "BattleInitDispatch:PersuadeResolveDispatch",
    "BattleSetup_Exec:InsultResolve_Exec",
    "TerritoryEvent_ApplyResult:Spoils_ApplyItem",
    "TerritoryEvent_CaptureOfficer:Spoils_CaptureOfficer",
    "TerritoryEvent_Finalize:Spoils_Finalize",
    "TerritoryEvent_Execute:Spoils_Execute",
    "TerritoryEvent_Check:Spoils_FadeGate",
    "TerritoryEvent_Init:Spoils_Init",
    "TerritoryEventDispatch:SpoilsEventDispatch",
    "territory_event_type:spoils_event_type",
    "sub_action_type:duel_command_code",
    "MapScrollDispatch_A:FeintSceneDispatch",
    "MapScrollDispatch_B:StrikeSceneDispatch",
    "MapScrollDispatch_C:DesperateSceneDispatch",
    "MapScrollA_:FeintScene_",
    "MapScrollB_:StrikeScene_",
    "MapScrollC_:DesperateScene_",
    "MapSlideDispatch_A:StrikeSlideDispatch",
    "MapSlideDispatch_B:DuelMenuSlideInDispatch",
    "MapSlideDispatch_C:DuelMenuSlideOutDispatch",
    "MapSlideA_:StrikeSlide_",
    "MapSlideB_:DuelMenuSlideIn_",
    "MapSlideC_:DuelMenuSlideOut_",
]

FILES = [
    "/home/zero/project/sango2dasm/asm/banks/prg_17_18.asm",
    "/home/zero/project/sango2dasm/include/functions.h",
]

for path in FILES:
    with open(path) as f:
        text = f.read()
    total = 0
    for pair in REnames:
        old, new = pair.split(":")
        # functions.h aliases carry the B17_18_ prefix; accept an underscore
        # boundary when it is part of that prefix.
        pats = [
            re.compile(r"(?<![A-Za-z0-9_])" + re.escape(old) + r"(?![A-Za-z0-9_])"),
            re.compile(r"\bB17_18_" + re.escape(old) + r"(?![A-Za-z0-9_])"),
        ]
        for pat in pats:
            text, n = pat.subn(new, text)
            total += n
    with open(path, "w") as f:
        f.write(text)
    print(f"{path}: {total} replacements")

# leftover audit
LEFTOVER = ["TroopAssign", "WarClash", "WarResult_", "Duel_", "Intrigue",
            "EventCutscene", "BattleInit", "BattleSetup", "TerritoryEvent",
            "MapScrollA_", "MapScrollB_", "MapScrollC_", "MapScrollDispatch",
            "MapSlideA_", "MapSlideB_", "MapSlideC_", "MapSlideDispatch",
            "StrategyMode_", "StrategyModeDispatch", "sub_action_type",
            "troop_assign_counter"]
for path in FILES:
    with open(path) as f:
        text = f.read()
    bad = [w for w in LEFTOVER if w in text]
    print(f"{path}: leftovers={bad if bad else 'NONE'}")
