#!/usr/bin/env python3
"""Check candidate RAM symbol names against all existing ca65 symbol definitions."""
import re, glob, sys

names = """zp_arg0 zp_arg1 zp_arg2 zp_arg3 zp_arg4 zp_arg5 zp_arg6 zp_bcd_lo zp_bcd_hi
zp_draw_arg0 zp_draw_arg1 zp_draw_arg2 zp_draw_arg3 zp_grid_col zp_grid_row
zp_work_mode zp_work_slot zp_marker_row zp_marker_col zp_slot_cursor
zp_panel_param_a zp_panel_param_b zp_panel_param_c
btl_flash_counter btl_oam_slot_cursor btl_anim_flags btl_pad1_lo btl_pad2_lo
btl_pad1_hi btl_pad2_hi btl_frame_flag btl_battle_flag
btl_overlay_phase btl_overlay_sub btl_scan_col btl_scan_row btl_scan_wait
btl_frame_counter btl_acting_unit btl_walk_row btl_walk_col btl_recorded_status
btl_target_col btl_command btl_order_slots_a btl_order_slots_b
btl_advance_base btl_advance_dir btl_advance_marker_row btl_advance_marker_col
btl_strip_buf_a btl_strip_buf_b btl_strip_sel_a btl_strip_flag_a
btl_strip_sel_b btl_strip_flag_b
btl_input_mode_a btl_input_mode_b btl_country_a btl_country_b
btl_col_count_a btl_col_count_b btl_player_request_a btl_player_request_b
btl_attack_a btl_attack_b btl_formation_a btl_formation_b
btl_defense_a btl_defense_b btl_edge_bonus_a btl_edge_bonus_b
btl_point_budget_a btl_point_budget_b btl_status_ctr0 btl_status_ctr1
btl_status_ctr2 btl_status_ctr3 btl_reload_a btl_reload_b btl_round_pass
btl_input_mask btl_side_index
btl_unit_col_a btl_unit_col_b btl_unit_row_a btl_unit_row_b
btl_troops_a btl_troops_b btl_roster_code_a btl_roster_code_b
btl_panel_params btl_panel_fields btl_sideev_params btl_sideev_troop_a
btl_sideev_troop_b btl_sideev_strip_a btl_sideev_strip_b btl_strip_row_param
btl_attack_mirror_a btl_attack_mirror_b
anim_queue_hdr0 anim_queue_hdr1 anim_queue_id0_lo anim_queue_id0_hi
vram_script_buf
snd_chan_state snd_chan_hw_idx snd_chan_stream_lo snd_chan_stream_hi
snd_chan_duration snd_chan_dur_ctr snd_chan_volume snd_chan_volume_sv
snd_chan_note_ctr snd_chan_sweep snd_chan_vib_ctr0 snd_chan_vib_ctr1
snd_chan_aux0c snd_chan_freq_period snd_chan_frame_ctr
snd_chan_decay_ctr snd_chan_decay_rld snd_chan_decay_tmr snd_chan_freq_acc
snd_chan_aux13 snd_chan_cmd_rld snd_chan_cmd_tmr
snd_active_mask snd_hw_index snd_channel_mode snd_reg_base snd_apu_enable
snd_freq_lo snd_freq_hi snd_frame_ctr""".split()

pat = re.compile(r'^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=')
existing = {}
files = glob.glob('asm/**/*.asm', recursive=True) + glob.glob('include/*.h')
for f in files:
    for line in open(f, errors='ignore'):
        m = pat.match(line)
        if m:
            existing.setdefault(m.group(1), []).append(f)
coll = [n for n in names if n in existing]
print("collisions:", coll if coll else "none")
if len(sys.argv) > 1:
    for n in sys.argv[1:]:
        print(n, '->', existing.get(n, 'MISSING'))
