# WRAM $0400–$0500 Semantic Map for prg_0c_0d.asm

- **Category:** project_environment_configuration
- **Memory ID:** 4552979d-6963-471c-aa91-e7edb16b7d4d
- **Keywords:** WRAM map, symbolic names, $04xx addresses, memory semantics, prg_0c_0d

## Content

In `prg_0c_0d.asm`, WRAM addresses $0400–$0500 have fixed semantic meanings:
- `$0400-$0401`: scene_callback_id/st (shared)
- `$0402`: province_idx
- `$040C-$040D`: detail_cursor_x/y
- `$0410`: detail_officer_id
- `$0420`: menu_scroll_state (shared)
- `$0424-$0425`: menu_cursor_col/page (shared)
- `$042C-$044B`: officer_sel_list (32-byte array)
- `$044C-$046B`: exchange_disp_base (32-byte stats)
- `$046C-$046F`: kingdom_param_copy
- `$0470-$0473`: anim_ppu_ptr/map_scroll_ptr (shared)
- `$04C8`: exchange_result_cnt
- `$04D2-$04D5`: officer_rec_src/dst (shared)
- `$04D8-$04DF`: army_slot_base (8-byte array)
These symbolic definitions replace raw $04xx references in code for clarity and consistency.
