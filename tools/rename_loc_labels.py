#!/usr/bin/env python3
"""Replace Loc_ADDR labels with meaningful local/group labels in prg_1d_1e.asm."""
import re

FILE = '/home/zero/project/sango2dasm/asm/banks/prg_1d_1e.asm'

# =============================================================================
# Label mapping: Loc_ADDR -> new name
# @ prefix = proc-local label; no prefix = module-level (cross-proc) label
# =============================================================================
RENAME_MAP = {
    # --- PPUTileRender ---
    'Loc_A050': '@check_flag2',
    'Loc_A058': '@check_flag3',
    'Loc_A060': '@check_mask',
    'Loc_A06B': '@render_single',
    'Loc_A0B2': '@inc_and_exit',
    'Loc_A0B6': '@reset_tile',
    'Loc_A0C4': '@render_row1',
    'Loc_A0D5': '@row1_loop',
    'Loc_A0E3': '@check_row2',
    'Loc_A0F9': '@row2_loop',
    'Loc_A107': '@render_done',

    # --- VRAMBufferWrite ---
    'Loc_A132': '@vram_loop',
    'Loc_A146': '@vram_write_loop',
    'Loc_A152': '@vram_done',

    # --- Cross-proc: defined in VRAMBufferWrite, referenced from MenuUpdate ---
    'Loc_A153': 'MenuUpdate_Exit',

    # --- MenuUpdate ---
    'Loc_A164': '@check_cmd',
    'Loc_A1AC': '@init_render',
    'Loc_A1C8': '@dispatch',
    'Loc_A1D9': '@store_tile',
    'Loc_A1E7': '@adv_ptr_done',
    'Loc_A1F5': '@store_offset',
    'Loc_A1FE': '@store_indirect',
    'Loc_A202': '@dispatch_cmd',
    'Loc_A280': '@clear_exit',
    'Loc_A341': '@process_entry',
    'Loc_A37A': '@scan_loop',
    'Loc_A38F': '@scan_done',
    'Loc_A411': '@tile_convert',
    'Loc_A41A': '@tile_write',
    'Loc_A425': '@tile_done',
    'Loc_A44A': '@write_zero_loop',
    'Loc_A460': '@process_large',
    'Loc_A475': '@tile_loop',
    'Loc_A47B': '@tile_store',
    'Loc_A48B': '@inc_offset',
    'Loc_A48E': '@tile_next',
    'Loc_A498': '@pad_loop',
    'Loc_A4A8': '@pad_done',
    'Loc_A503': '@tile2_loop',
    'Loc_A509': '@tile2_store',
    'Loc_A519': '@inc2_offset',
    'Loc_A51C': '@tile2_next',
    'Loc_A526': '@pad2_loop',
    'Loc_A536': '@pad2_done',
    'Loc_A57D': '@check_ff',
    'Loc_A58C': '@format_num',
    'Loc_A5DE': '@dec_counter',
    'Loc_A5F4': '@write_tile_off',
    'Loc_A600': '@write_and_inc',
    'Loc_A606': '@dec_return',
    'Loc_A613': '@clear_buf_loop',
    'Loc_A650': '@load_ptr_lo',
    'Loc_A661': '@load_ptr_hi',
    'Loc_A69C': '@switch_bank',

    # --- YearDisplaySetup ---
    'Loc_A722': '@calc_offset',

    # --- FrameCounterAlt ---
    'Loc_A7A0': '@copy_table_loop',
    'Loc_A7B1': '@frame_exit',

    # --- BcdDisplayHandler ---
    'Loc_A7CA': '@bcd_copy_loop',
    'Loc_A7E2': '@bcd_low_digit',

    # --- ProvinceDataHandler ---
    'Loc_A832': '@prov_copy_loop',

    # --- Cross-proc: defined in RecordProcessor, referenced from multiple procs ---
    'Loc_A957': 'DisplayScaledName',
    'Loc_A976': 'DisplayScaledNumber',

    # --- NameDisplay ---
    'Loc_A8A6': '@name_copy_loop',

    # --- RecordProcessor ---
    'Loc_A8FF': '@rec_copy_loop',
    'Loc_A95D': '@name_scan_loop',
    'Loc_A96E': '@name_scan_done',
    'Loc_A97C': '@num_scan_loop',
    'Loc_A98C': '@num_scan_next',
    'Loc_A990': '@num_scan_done',

    # --- DataFormatter ---
    'Loc_A998': '@fmt_copy_loop1',
    'Loc_A9A4': '@fmt_setup2',
    'Loc_A9A6': '@fmt_copy_loop2',
    'Loc_A9AF': '@fmt_process',

    # --- BankedDataHandler ---
    'Loc_AA4D': '@skip_jsr',
    'Loc_AA5F': '@clear_display',
    'Loc_AA63': '@clear_loop',
    'Loc_AA73': '@calc_index',
    'Loc_AADE': '@init_display',
    'Loc_AB27': '@data_bytes',
    'Loc_AB38': '@setup_bank_data',
    'Loc_AB6F': '@copy_data_loop',
    'Loc_AB82': '@copy_data_done',
    'Loc_AB8A': '@copy_name_loop',
    'Loc_ABB4': '@copy_name_done',

    # --- StateHandler ---
    'Loc_ABE8': '@check_sub1',
    'Loc_ABF4': '@check_state',
    'Loc_AC15': '@jmp_dispatch',
    'Loc_AC18': '@clear_state',
    'Loc_AC27': '@check_val',
    'Loc_AC30': '@store_flags',
    'Loc_AC38': '@state_rts',
    'Loc_AC39': '@init_state5',
    'Loc_AC5C': '@setup_coords1',
    'Loc_AC80': '@set_scroll',
    'Loc_AC95': '@setup_case3',
    'Loc_ACAF': '@setup_case5',
    'Loc_ACBE': '@setup_case4',
    'Loc_ACCD': '@setup_case1',
    'Loc_ACF1': '@load_table_addr',
    'Loc_AD03': '@init_timers',
    'Loc_AD16': '@set_counters1',
    'Loc_AD1F': '@set_counters2',
    'Loc_AD5B': '@setup_pos1',
    'Loc_AD6E': '@update_pos',
    'Loc_AD92': '@init_window',
    'Loc_ADBC': '@setup_pos2',
    'Loc_ADCA': '@update_pos2',
    'Loc_ADF3': '@advance_state',
    'Loc_AE0B': '@copy_buf_loop',
    'Loc_AE19': '@handle_special',
    'Loc_AE1C': '@check_copy_done',
    'Loc_AE4A': '@copy_3bytes',
    'Loc_AE85': '@check_province',
    'Loc_AEA5': '@action_0',
    'Loc_AEAD': '@action_1',
    'Loc_AEB8': '@action_2',
    'Loc_AEC0': '@state_done',
    'Loc_AEC9': '@advance_draw',
    'Loc_AEDF': '@copy_row',
    'Loc_AEE1': '@copy_row_loop',
    'Loc_AF20': '@copy_4bytes',
    'Loc_AF66': '@add_offset',
    'Loc_AF77': '@store_extra',
    'Loc_AFC0': '@init_ptrs1',
    'Loc_AFD3': '@init_ptrs2',
    'Loc_AFDE': '@scan_entries',
    'Loc_AFE7': '@scan_next',
    'Loc_AFEF': '@init_ptrs3',
    'Loc_AFFA': '@scan_officers',
    'Loc_B021': '@scan_done2',
    'Loc_B032': '@format_bcd',
    'Loc_B040': '@format_digits',
    'Loc_B062': '@digit_ones',
    'Loc_B06A': '@digit_hi',
    'Loc_B074': '@digit_lo',
    'Loc_B07C': '@digit_thousands',
    'Loc_B091': '@write_digit',
    'Loc_B09C': '@write_offset_digit',
    'Loc_B0A9': '@inc_index',
    'Loc_B0F8': '@copy_name7',
    'Loc_B105': '@copy_name12',
    'Loc_B12C': '@process_chars',
    'Loc_B141': '@store_back',
    'Loc_B145': '@inc_char_idx',
    'Loc_B14B': '@char_done',
    'Loc_B158': '@setup_render',
    'Loc_B173': '@load_tile_addr',
    'Loc_B1E5': '@copy_officer_data',
    'Loc_B21E': '@officer_done',
    'Loc_B254': '@load_name_scale',
    'Loc_B25E': '@name_scan2',
    'Loc_B26D': '@name_adjust',
    'Loc_B274': '@name_next',
    'Loc_B279': '@name_rts',
    'Loc_B27A': '@draw_name_scaled',
    'Loc_B287': '@name_scan3',
    'Loc_B29A': '@name_next3',
    'Loc_B29E': '@name_rts2',

    # --- MapDisplaySetup ---
    'Loc_B2BE': '@write_row',
    'Loc_B2C0': '@write_row_loop',
    'Loc_B2F9': '@write_4bytes',

    # --- OfficerListHandler ---
    'Loc_B99F': '@check_sub_state',
    'Loc_B9CB': '@goto_scroll',
    'Loc_B9CE': '@officer_exit',
    'Loc_B9EA': '@scroll_update',
    'Loc_BA05': '@fill_ff_loop',
    'Loc_BA41': '@count_officers',
    'Loc_BA4B': '@count_next',
    'Loc_BA53': '@check_selection',
    'Loc_BA65': '@load_province',
    'Loc_BA6C': '@copy_province',
    'Loc_BA78': '@copy_prov_next',
    'Loc_BA7E': '@update_display',
    'Loc_BA90': '@no_selection',
    'Loc_BA9D': '@list_dispatch',
    'Loc_BAB7': '@copy_tile_data',
    'Loc_BAC5': '@copy_64bytes',
    'Loc_BAE3': '@fill_ones',
    'Loc_BAE7': '@fill_loop',
    'Loc_BAEF': '@advance_list',
    'Loc_BB03': '@fill_aa',
    'Loc_BB07': '@fill_aa_loop',
    'Loc_BB1C': '@finish_list',
    'Loc_BB2C': '@fill_value_loop',
    'Loc_BB3C': '@format_officer',
    'Loc_BB4E': '@officer_adjust',
    'Loc_BB52': '@officer_next',
    'Loc_BB57': '@officer_setup',
    'Loc_BB68': '@init_officer_ptr',
    'Loc_BB80': '@format_and_draw',
    'Loc_BB89': '@advance_offset',
    'Loc_BBB3': '@load_extra',
    'Loc_BBF1': '@format_extra',
    'Loc_BC15': '@advance_list2',
    'Loc_BC32': '@write_terminator',

    # --- Unknown ---
    'Loc_BC5A': '@vram_fill_loop',

    # --- SmallRoutineA ---
    'Loc_BC6A': '@clear_0140_loop',

    # --- SmallRoutineB ---
    'Loc_BCBF': '@copy_page_loop',
    'Loc_BCFA': '@set_flag_exit',
    'Loc_BD37': '@render_exit1',
    'Loc_BD59': '@inc_and_jmp',
    'Loc_BD5F': '@render_exit2',
    'Loc_BD91': '@render_exit3',
    'Loc_BDAA': '@fill_aa_page',
    'Loc_BDEA': '@fill_0470',
    'Loc_BDF0': '@sub_exit',
    'Loc_BDF1': '@check_game_state',
    'Loc_BDFD': '@state_rts2',
    'Loc_BDFE': '@init_timer',

    # --- MenuRenderer ---
    'Loc_BE3C': '@menu_dispatch',
    'Loc_BE52': '@setup_menu',
    'Loc_BE5D': '@check_low',
    'Loc_BE64': '@render_menu',
    'Loc_BE7B': '@data_bytes2',
    'Loc_BEC9': '@load_row0',
    'Loc_BEE2': '@set_row',
    'Loc_BEFE': '@load_row1',
    'Loc_BF1F': '@load_table',
    'Loc_BF3D': '@load_row2',
    'Loc_BF61': '@clear_sprites',
    'Loc_BF6D': '@menu_return',
    'Loc_BF88': '@load_row3',
    'Loc_BFD2': '@load_row4',
}

# =============================================================================
# Read file
# =============================================================================
with open(FILE) as f:
    content = f.read()

# =============================================================================
# Verify all Loc_ labels in the file are covered by the map
# =============================================================================
all_loc_in_file = set(re.findall(r'Loc_[0-9A-Fa-f]+', content))
mapped = set(RENAME_MAP.keys())
unmapped = all_loc_in_file - mapped
if unmapped:
    print(f"WARNING: {len(unmapped)} Loc_ labels NOT in rename map:")
    for label in sorted(unmapped):
        print(f"  {label}")
    print()

extra = mapped - all_loc_in_file
if extra:
    print(f"NOTE: {len(extra)} labels in map but NOT in file:")
    for label in sorted(extra):
        print(f"  {label}")
    print()

# =============================================================================
# Perform replacements (longest labels first to avoid partial matches)
# =============================================================================
# Sort by label length descending, then alphabetically
sorted_labels = sorted(RENAME_MAP.keys(), key=lambda x: (-len(x), x))

count = 0
for old_label in sorted_labels:
    new_label = RENAME_MAP[old_label]
    # Use word boundary to avoid partial replacements
    # Loc_A050 should not match inside Loc_A0500 (not that it exists)
    pattern = re.compile(rf'\b{re.escape(old_label)}\b')
    new_content, n = pattern.subn(new_label, content)
    if n > 0:
        content = new_content
        count += n
        print(f"  {old_label} -> {new_label}  ({n} occurrences)")

print(f"\nTotal replacements: {count}")

# =============================================================================
# Write output
# =============================================================================
with open(FILE, 'w') as f:
    f.write(content)

print(f"File written: {FILE}")

# =============================================================================
# Verify no Loc_ labels remain
# =============================================================================
remaining = re.findall(r'Loc_[0-9A-Fa-f]+', content)
if remaining:
    print(f"\nWARNING: {len(set(remaining))} unique Loc_ labels still remain:")
    for label in sorted(set(remaining)):
        print(f"  {label} ({remaining.count(label)} occurrences)")
else:
    print("\nAll Loc_ labels successfully replaced!")
