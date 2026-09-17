# WRAM $0500–$05FF Semantic Map for prg_0c_0d.asm

- **Category:** project_environment_configuration
- **Memory ID:** e0c9c07a-326e-4183-b6da-5662ef0a9c8d
- **Keywords:** WRAM map, $05xx addresses, memory semantics, symbolic names, prg_0c_0d

## Content

In `prg_0c_0d.asm`, WRAM addresses $0500–$05FF have fixed semantic meanings:
- `$0500`: exchange_state (main dispatch state)
- `$0501`: exchange_phase (sub-phase counter)
- `$0504`: exchange_dir_flag (group A/B direction bit)
- `$0505`: move_points_left (army strength/movement)
- `$0506`: ruler_turn_counter (ruler turn tracking)
- `$0507`: packed_ruler_pair (A/B ruler IDs)
- `$0508`: exchange_wait_timer (wait/delay counter)
- `$0509`: src_officer_slot (source slot index)
- `$050A`: dst_officer_slot (target slot/path length)
- `$050B`: cmd_phase_step (command phase step)
- `$050C-$050D`: morale_group_a/b (army morale values)
- `$050E`: province_check_flag (province validation flag)
- `$050F`: ruler_status_flag (ruler alliance status)
- `$0510-$0513`: map_scroll_x/y_lo/hi (scroll position)
- `$051A-$051D`: merit_sum_a/b_lo/hi (16-bit merit sums)
- `$051E-$051F`: officer_count_a/b (army officer counts)
- `$0522-$0525`: province_ptr_a/b_lo/hi (province record pointers)
- `$052A-$052B`: scene_province_idx/sel_officer (scene state)
- `$052C-$052F`: xfer_status/power_0/1 (transfer data)
- `$053D-$053F`: undo_province_x/y/cost (move undo buffer)
- `$0540-$0543`: move_path_x/y/cost/total (path recording)
- `$0544`: action_dispatch_idx (terrain/action index)
- `$0550-$055F`: exchange_sel_list (16-byte selection list)
- `$0560-$0565`: xfer_officer/ruler_* (transfer display)
- `$0580-$059F`: officer_select_flg (32-byte selection flags)
These symbolic definitions replace raw $05xx references for improved code readability.
