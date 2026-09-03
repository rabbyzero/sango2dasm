# Battle bank RAM semantic map for prg_08_09.asm

- **Category:** project_architecture
- **Memory ID:** 0395917b-2ffa-4d7f-b791-8f162368af6e
- **Keywords:** battle RAM map, semantic equates, prg_08_09, cross-proc globals, faction records
- **Usage scenarios:**
  - Editing or analyzing prg_08_09.asm battle code
  - Naming RAM variables in battle context
  - Cross-bank RAM address lookups

## Content

In `prg_08_09.asm` (battle/AI bank), RAM $0400-$06FF and $6F00-$6FFF are consolidated into semantic equates.

Cross-proc globals at file top:

- battle_scene_id $0500
- battle_scene_phase $0501
- battle_side_flag $0504 (bit7=attacker)
- battle_action_points $0505
- battle_round_counter $0506
- battle_faction_pair $0507 (lo=side0/defender, hi=side1/attacker)
- battle_officer_slot $0509
- battle_scene_index $050A
- battle_province_idx $050E
- battle_attacker_code $050F
- battle_side_selector $0514
- battle_stat_a/b_lo/hi $0522/$0523/$0526/$0527 (side1 at +2)
- battle_target_province/officer/param $052A-$052C
- action_result_lo/hi/cnt $042C-$042E
- result_cursor_x/y $040C/$040D
- result_sel_entry $0410
- result_menu_row $046C
- battle_overlay_flag $04C8
- result_scene_phase $0541
- result_dir_repeat $0545 (+0..+3)
- result_latch_flags $6FEA
- battle_outcome_flag $6F44
- unit_coord_x/y $0600/$0614
- unit_army_array $0628
- unit_state_array $063C
- unit_immobilized $0650
- battle_roster $0664
- officer_state_table $6FA1
- proximity_table $6FC9
- faction_records $6F07 (stride 8)
- faction_rec_status $6F0A
- ai_officer_idx $6F8C
- ai_action_result $6F8F
- side_unit_base $6F91
- officer_scan_idx/acted/valid $6F94-$6F96
- formation_slot0/1_units $6F99/$6F9B
- rng_cursor/rng_x_save $6F92/$6F93

Shared addresses reuse external globals without redefinition:

- menu_cursor_col/page $0424/$0425
- army_slot_base $04D8 (+1..+7 target X/Y/timers)
- sram_game_start_flag $6F8B

Single-proc vars are defined locally inside each `.proc` (scope rule).

Verified byte-exact via tools/tmp_verify_ram_syms.py (bank08 keeps pre-existing $BAF4+ drift, bank09 clean).
