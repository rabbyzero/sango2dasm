# Zero-page RAM map for frame state handlers and menu system

- **Category:** project_architecture
- **Memory ID:** d4286e8b-b2a6-4cee-a62b-2268311b89ba
- **Keywords:** $0400-$040C RAM, zero-page frame state vars, menu dispatch flags, overlay sentinels, AI budget registers, frame state machine

## Content

Zero-page RAM map for frame state handlers (prg_19_1a.asm $C773-$CD8B region):

$0400 = scene_callback_id (map screen frame state, 0-15)
$0401 = scene_callback_st (sub-state within frame state, 0-15+)
$0402 = province_idx / sub-sub-state
$040C = detail_cursor_x / officer_param_base / result cursor / step counter / turn counter
$042C-$042E = menu_fmt_data0/1/2 (formatted number display data)
$04A0 = menu_dispatch_flg (menu id, 9 = MenuAction08; high bit set during transition)
$04A2 = menu_index ($04A0 - 1 when positive)
$04D6 = menu_action_extra ($47 or $A2, skips PPU init when $47)
$0150 = palette mask / hemisphere scroll flag (computed as (zoneXorigin & $80) ^ $80)
$0140 = screen-transition busy flag ($80 = transitioning, $00 = idle)
$0300 = overlay slot 0 sentinel ($FF = idle)
$0304 = overlay slot 1 sentinel ($FF = idle)
$007A = addr_game_state (state counter 0-14, indexes VectorTable)
$000A/$000B = 16-bit officer id (hi/lo bytes)
$000C = banked handler parameter
$0038 = province id / officer id (strategy input)
$003A = province index
$003D = officer id for card display
$0040-$0043 = strategy-layer result parameters
$0041 = work_search_result

SRAM variables:
$6F05 = SRAM game-state flag (0 = no game, 1 = game in progress, clamped ≥1)
$6F5B = iteration counter / AI budget source
$6F5D = AI action budget ($6F05 * 10, max 130)
$6F62 = global phase / per-officer active flag
$6F8B = strategy-layer request mailbox / game-start flag
$6F8D = strategy ack response
$6F03 = current player country slot
$6F44 = target province record field 3
$042F/$0430/$0431 = menu results / overlay values
$04E0-$04E3 = bitmap byte index array (bit = $04E0[id>>3] mask 1<<(id&7))
