#!/usr/bin/env python3
"""Rename battle->war labels in prg_08_09.asm, functions.h, and prg_1f.asm"""

# Define all replacements as (old, new) pairs
replacements = []

# RAM equates (longer first to avoid substring conflicts)
replacements.extend([
    ('battle_scene_index', 'war_scene_index'),
    ('battle_scene_id', 'war_scene_id'),
    ('battle_target_officer', 'war_target_officer'),
    ('battle_target_province', 'war_target_province'),
    ('battle_target_param', 'war_target_param'),
    ('battle_outcome_flag', 'war_outcome_flag'),
    ('battle_overlay_flag', 'war_overlay_flag'),
    ('battle_action_points', 'war_action_points'),
    ('battle_round_counter', 'war_round_counter'),
    ('battle_side_selector', 'war_side_selector'),
    ('battle_province_idx', 'war_province_idx'),
    ('battle_attacker_code', 'war_attacker_code'),
    ('battle_faction_pair', 'war_faction_pair'),
    ('battle_officer_slot', 'war_officer_slot'),
    ('battle_side_flag', 'war_side_flag'),
    ('battle_stat_a_lo', 'war_stat_a_lo'),
    ('battle_stat_a_hi', 'war_stat_a_hi'),
    ('battle_stat_b_lo', 'war_stat_b_lo'),
    ('battle_stat_b_hi', 'war_stat_b_hi'),
])

# Procedure and data labels (longer first)
replacements.extend([
    ('BattleResultDispatch_Entry', 'WarResultDispatch_Entry'),
    ('BattleResultSceneInit_Entry', 'WarResultSceneInit_Entry'),
    ('BattlePhaseProcess_Entry', 'WarPhaseProcess_Entry'),
    ('BattleCasualtyResolution_Entry', 'WarCasualtyResolution_Entry'),
    ('BattleAttritionRound_Entry', 'WarAttritionRound_Entry'),
    ('BattleStatusPanelDraw_Entry', 'WarStatusPanelDraw_Entry'),
    ('BattleMapScrollUpdate_Entry', 'WarMapScrollUpdate_Entry'),
    ('BattleResultSlotTemplateApply', 'WarResultSlotTemplateApply'),
    ('BattleResultSlotReset', 'WarResultSlotReset'),
    ('BattleResultReadyCheck', 'WarResultReadyCheck'),
    ('BattleResultCursorSpriteDraw', 'WarResultCursorSpriteDraw'),
    ('BattleResultSceneFrameDraw', 'WarResultSceneFrameDraw'),
    ('BattleResultMenuPoll', 'WarResultMenuPoll'),
    ('BattleResultEntryInit', 'WarResultEntryInit'),
    ('BattleResultDispatch', 'WarResultDispatch'),
    ('BattleResult_Finalize', 'WarResult_Finalize'),
    ('BattleResult_InspectEntry', 'WarResult_InspectEntry'),
    ('BattleResult_PickEntry', 'WarResult_PickEntry'),
    ('BattleResult_ConfirmMenuWait', 'WarResult_ConfirmMenuWait'),
    ('BattleResult_SelectMenuEntry', 'WarResult_SelectMenuEntry'),
    ('BattleResult_OpenMenuWait', 'WarResult_OpenMenuWait'),
    ('BattleResult_InitRecords', 'WarResult_InitRecords'),
    ('BattleResult_SceneTick', 'WarResult_SceneTick'),
    ('BattleResult_RowToRecordMap', 'WarResult_RowToRecordMap'),
    ('BattleResult_RecordInitTable', 'WarResult_RecordInitTable'),
    ('BattleResult_EntryOrderList', 'WarResult_EntryOrderList'),
    ('BattleResult_CursorPosTable', 'WarResult_CursorPosTable'),
    ('BattleResult_CursorSpriteLayout', 'WarResult_CursorSpriteLayout'),
    ('BattleResult_FrameSpriteLayout', 'WarResult_FrameSpriteLayout'),
    ('BattleResult_MarkerSpriteLayout', 'WarResult_MarkerSpriteLayout'),
    ('BattleResult_SlotRecordPtrs', 'WarResult_SlotRecordPtrs'),
    ('BattleResult_SlotRecordTemplate', 'WarResult_SlotRecordTemplate'),
    ('BattleResultDirRepeat0', 'WarResultDirRepeat0'),
    ('BattleResultDirRepeat1', 'WarResultDirRepeat1'),
    ('BattleResultDirRepeat2', 'WarResultDirRepeat2'),
    ('BattleResultDirRepeat3', 'WarResultDirRepeat3'),
    ('SetupPostBattleState', 'SetupPostWarState'),
    ('BattleResultProcess', 'WarClashResolve'),
    ('BattleMapScrollUpdate', 'WarMapScrollUpdate'),
    ('BattleResultSceneInit', 'WarResultSceneInit'),
    ('BattleSlotClear', 'WarSlotClear'),
    ('BattleAttackerSetup', 'WarAttackerSetup'),
    ('BattleDefenderSetup', 'WarDefenderSetup'),
    ('BattlePostProcess', 'WarPostProcess'),
    ('BattlePhaseProcess', 'WarPhaseProcess'),
    ('BattleCasualtyResolution', 'WarCasualtyResolution'),
    ('BattleAttritionRound', 'WarAttritionRound'),
    ('BattleStatusPanelDraw', 'WarStatusPanelDraw'),
    ('BattleSetup_Entry', 'WarSetup_Entry'),
    ('BattleSetup', 'WarSetup'),
    ('BattleExecute', 'WarExecute'),
])

# Entry stubs in functions.h
replacements.extend([
    ('B08_09_BattleResultDispatch_Entry', 'B08_09_WarResultDispatch_Entry'),
    ('B08_09_BattleResultSceneInit_Entry', 'B08_09_WarResultSceneInit_Entry'),
    ('B08_09_BattlePhaseProcess_Entry', 'B08_09_WarPhaseProcess_Entry'),
    ('B08_09_BattleCasualtyResolution_Entry', 'B08_09_WarCasualtyResolution_Entry'),
    ('B08_09_BattleAttritionRound_Entry', 'B08_09_WarAttritionRound_Entry'),
    ('B08_09_BattleStatusPanelDraw_Entry', 'B08_09_WarStatusPanelDraw_Entry'),
    ('B08_09_BattleMapScrollUpdate_Entry', 'B08_09_WarMapScrollUpdate_Entry'),
    ('B08_09_BattleSlotClear_Entry', 'B08_09_WarSlotClear_Entry'),
    ('B08_09_BattleSetup_Entry', 'B08_09_WarSetup_Entry'),
])

# Specific comment fixes
replacements.extend([
    ('RAM map (WRAM $0400-$06FF work area, SRAM $6F00-$6FFF) - battle context',
     'RAM map (WRAM $0400-$06FF work area, SRAM $6F00-$6FFF) - war/battle context'),
    ('--- Battle scene state', '--- War scene state'),
    ('AI Officer Action State Machine (battle)',
     'AI Officer Action State Machine (war/tactical layer)'),
])

# Sort by length descending to handle substring conflicts
replacements.sort(key=lambda x: len(x[0]), reverse=True)

# Process files
files = [
    '/home/zero/project/sango2dasm/asm/banks/prg_08_09.asm',
    '/home/zero/project/sango2dasm/include/functions.h',
    '/home/zero/project/sango2dasm/asm/banks/prg_1f.asm',
]

for filepath in files:
    with open(filepath, 'r') as f:
        content = f.read()

    original = content
    count = 0
    for old, new in replacements:
        if old in content:
            occurrences = content.count(old)
            content = content.replace(old, new)
            count += occurrences

    with open(filepath, 'w') as f:
        f.write(content)

    print(f'{filepath}: {count} replacements')

print('Done!')
