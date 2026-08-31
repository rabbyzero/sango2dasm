#!/usr/bin/env python3
"""Replace raw $0000-$07FF operand addresses in prg_0e_0f.asm with the
semantic RAM symbols defined in the file-top RAM map block.

Only instruction operand positions are rewritten (never immediates, never
comments, never data directives, never the equate definitions themselves).
Idempotent: re-running on an already-symbolic file changes nothing.
"""
import re

SRC = "asm/banks/prg_0e_0f.asm"

# address (4-hex-digit, no $) -> symbolic replacement text
NAMES = {
    # zero-page call-register file
    "0000": "zp_arg0", "0001": "zp_arg1", "0002": "zp_arg2", "0003": "zp_arg3",
    "0004": "zp_arg4", "0005": "zp_div_remain",
    "0007": "zp_bcd_lo", "0008": "zp_bcd_hi",
    "000A": "zp_draw_arg0", "000B": "zp_draw_arg1",
    "000C": "zp_draw_arg2", "000D": "zp_draw_arg3",
    "0010": "zp_grid_col", "0011": "zp_grid_row",
    "0012": "zp_work_mode", "0013": "zp_work_slot",
    "001A": "zp_marker_row", "001B": "zp_marker_col", "001C": "zp_slot_cursor",
    # zero-page engine/hardware cells
    "005E": "frame_tick",
    "007A": "btl_flash_counter", "007C": "btl_oam_slot_cursor",
    "007E": "btl_anim_flags",
    "0081": "btl_pad1_lo", "0082": "btl_pad2_lo",
    "0083": "btl_pad1_hi", "0085": "btl_pad2_hi",
    "0087": "btl_frame_flag", "008F": "btl_battle_flag",
    "00BB": "zp_panel_param_a", "00BC": "zp_panel_param_b",
    "00BD": "zp_panel_param_c",
    # tile-animation queue
    "0300": "anim_queue_hdr0", "0304": "anim_queue_hdr1",
    "0310": "anim_queue_id0_lo", "0311": "anim_queue_id0_hi",
    # VRAM script buffer $0380-$039C
    **{"%04X" % (0x380 + n): "vram_script_buf+$%02X" % n
       for n in range(0x01, 0x1D)},
    "0380": "vram_script_buf",
    # shared panel/menu globals
    "0424": "menu_cursor_col", "0425": "menu_cursor_page",
    "042C": "btl_panel_params",
    "042D": "btl_panel_params+1", "042E": "btl_panel_params+2",
    "042F": "btl_panel_params+3", "0430": "btl_panel_params+4",
    "0431": "btl_panel_params+5",
    "044C": "btl_panel_fields",
    **{"04" + "%02X" % n: "btl_panel_fields+$%X" % (n - 0x4C)
       for n in range(0x4D, 0x63)},
    "04A8": "btl_sideev_params", "04A9": "btl_sideev_params+1",
    "04AA": "btl_sideev_params+2",
    "04AB": "btl_sideev_troop_a", "04AC": "btl_sideev_troop_b",
    "04AD": "btl_sideev_strip_a", "04AE": "btl_sideev_strip_b",
    "04BC": "btl_strip_row_param",
    "04C1": "btl_attack_mirror_a", "04C2": "btl_attack_mirror_b",
    # war scene shared
    "0500": "war_scene_id", "0501": "war_scene_phase",
    # overlay strip records
    "0514": "btl_strip_sel_a", "0515": "btl_strip_flag_a",
    "0516": "btl_strip_sel_b", "0517": "btl_strip_flag_b",
    # battle overlay state machine
    "0540": "btl_overlay_phase", "0541": "btl_overlay_sub",
    "0544": "battle_phase",
    "0545": "btl_scan_col", "0546": "btl_scan_row", "0547": "btl_scan_wait",
    "0548": "btl_frame_counter", "0549": "btl_acting_unit",
    "054A": "btl_walk_row", "054B": "btl_walk_col",
    "054C": "btl_recorded_status", "054D": "btl_target_col",
    "054F": "btl_command",
    "0550": "btl_order_slots_a", "0551": "btl_order_slots_a+1",
    "0552": "btl_order_slots_a+2", "0553": "btl_order_slots_a+3",
    "0554": "btl_order_slots_b", "0555": "btl_order_slots_b+1",
    "0556": "btl_order_slots_b+2", "0557": "btl_order_slots_b+3",
    "0558": "btl_advance_base", "0559": "btl_advance_dir",
    "055A": "btl_advance_marker_row", "055B": "btl_advance_marker_col",
    "0560": "btl_strip_buf_a", "0561": "btl_strip_buf_b",
    "0562": "btl_input_mode_a", "0563": "btl_input_mode_b",
    "0564": "btl_country_a", "0565": "btl_country_b",
    "0566": "btl_col_count_a", "0567": "btl_col_count_b",
    "0568": "btl_player_request_a", "0569": "btl_player_request_b",
    "056A": "btl_attack_a", "056B": "btl_attack_b",
    "056C": "btl_formation_a", "056D": "btl_formation_b",
    "056E": "btl_defense_a", "056F": "btl_defense_b",
    "0570": "btl_edge_bonus_a", "0571": "btl_edge_bonus_b",
    "0572": "btl_point_budget_a", "0573": "btl_point_budget_b",
    "0574": "btl_status_ctr0", "0575": "btl_status_ctr1",
    "0576": "btl_status_ctr2", "0577": "btl_status_ctr3",
    "0578": "btl_reload_a", "0579": "btl_reload_b",
    "057A": "btl_round_pass", "057B": "btl_input_mask",
    "057C": "btl_side_index",
    # battlefield unit arrays
    "0580": "btl_unit_col_a", "058B": "btl_unit_col_b",
    "0596": "btl_unit_row_a", "05A1": "btl_unit_row_b",
    "05AC": "btl_troops_a", "05B7": "btl_troops_b",
    "05C2": "btl_roster_code_a",
    # sound channel state
    "0700": "snd_chan_state", "0701": "snd_chan_hw_idx",
    "0702": "snd_chan_stream_lo", "0703": "snd_chan_stream_hi",
    "0704": "snd_chan_duration", "0705": "snd_chan_dur_ctr",
    "0706": "snd_chan_volume", "0707": "snd_chan_volume_sv",
    "0708": "snd_chan_note_ctr", "0709": "snd_chan_sweep",
    "070A": "snd_chan_vib_ctr0", "070B": "snd_chan_vib_ctr1",
    "070C": "snd_chan_aux0c", "070D": "snd_chan_freq_period",
    "070E": "snd_chan_frame_ctr", "070F": "snd_chan_decay_ctr",
    "0710": "snd_chan_decay_rld", "0711": "snd_chan_decay_tmr",
    "0712": "snd_chan_freq_acc", "0713": "snd_chan_aux13",
    "0714": "snd_chan_cmd_rld", "0715": "snd_chan_cmd_tmr",
    # sound engine scratch
    "07F2": "snd_active_mask", "07F3": "snd_hw_index",
    "07F4": "snd_channel_mode", "07F5": "snd_reg_base",
    "07F6": "snd_apu_enable", "07F7": "snd_freq_lo",
    "07F8": "snd_freq_hi", "07F9": "snd_frame_ctr",
}

ADDR = re.compile(r"\$([0-7][0-7][0-9A-Fa-f]{2})\b")
# 2-digit zero-page operand forms (ROM-encoded as zp, e.g. 85 00); the lookbehind
# also excludes '+' so offsets inside already-symbolic base+$xx expressions stay.
SHORT = re.compile(r"(?<![#\w$+])\$([0-9A-Fa-f]{2})\b")
SHORT_NAMES = {
    "00": "zp_arg0", "01": "zp_arg1", "02": "zp_arg2", "03": "zp_arg3",
    "04": "zp_arg4", "06": "zp_arg6", "07": "zp_bcd_lo",
    "0A": "zp_draw_arg0", "0B": "zp_draw_arg1", "0C": "zp_draw_arg2",
}
INSTR = re.compile(r'^\s*(?:@?[\w]+:)?\s*[A-Za-z]{3}\s')
EQUATE = re.compile(r'^\s*[A-Za-z_][A-Za-z0-9_]*\s*=')

out = []
replaced = 0
for line in open(SRC).read().splitlines(keepends=True):
    nl = "\n" if line.endswith("\n") else ""
    body = line.rstrip("\n")
    code, sep, comment = body.partition(";")
    if INSTR.match(code) and "$" in code and not EQUATE.match(body):
        def sub(m):
            global replaced
            name = NAMES.get(m.group(1).upper())
            if name is None:
                return m.group(0)
            replaced += 1
            return name
        newcode = ADDR.sub(sub, code)
        newcode = SHORT.sub(
            lambda m: SHORT_NAMES.get(m.group(1).upper(), m.group(0)),
            newcode)
        body = newcode + sep + comment
    out.append(body + nl)

open(SRC, "w").write("".join(out))
print("replaced operands:", replaced)
