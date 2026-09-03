# CPU Memory Map: $0000-$07FF and $6000-$7FFF (Consolidated)

Consolidated semantic map of CPU address space used by data: the 2 KB internal
RAM (`$0000-$07FF`) and the battery-backed PRG-RAM window (`$6000-$7FFF`) of
*Sangokushi 2 - Haou no Tairiku (J)*, Namco-163 (mapper 19).

Sources: the analyzed bank files `asm/banks/prg_08_09.asm`, `prg_0a_0b.asm`,
`prg_0c_0d.asm`, `prg_0e_0f.asm`, `prg_17_18.asm`, `prg_19_1a.asm`,
`prg_1b_1c.asm`, `prg_1d_1e.asm`, `prg_1f.asm` (banks `$00-$07` and `$10-$16`
are still unanalyzed stubs), plus the curated notes under `memory/`
(`officer-12-byte-record-field-layout`, `ruler-country-province-domain-model`,
`strategy-layer-request-mailbox-protocol`, `frame-state-9-handler-and-6f8b-mailbox`,
`battle-bank-ram-semantic-map-prg_08_09`, `scope-rule-for-04xx-ram-variables`).
Equate inventories were extracted with `tools/extract_ram_equates.py` (full
dump: `code/ram_equates_full.txt`); raw address usage of the two
comment-documented banks (`prg_19_1a`, `prg_1b_1c`) was scanned with
`tools/scan_raw_ram_refs.py`.

Naming follows the project conventions: shared kernel cells use `addr_*`,
cross-proc mode globals use per-mode prefixes (`btl_`, `war_`, `snd_`, ...),
and zero-page cells `$0000-$001F` are intentionally proc-local in
`prg_0e_0f.asm` (see `code/prg_0e_0f_ram_map.md`).

> **Aliasing caveat.** Outside the kernel cells listed as "consistent meaning
> everywhere", the same address routinely carries a *different* meaning in each
> bank, because only one game mode is resident at a time (`$0500` is
> `war_scene_id` in `prg_08_09` but `exchange_state` in `prg_0c_0d`; `$0540` is
> the battle overlay phase in `prg_0e_0f` but `move_path_x` in `prg_0c_0d`).
> Every table below lists the per-bank meanings side by side rather than picking
> one; do not assume a name from one bank applies in another.


## Hardware layout

| Region        | Hardware role                                                       |
|---------------|---------------------------------------------------------------------|
| `$0000-$07FF` | 2 KB internal RAM (mirrored through `$0800-$1FFF`)                   |
| `$0100-$01FF` | 6502 hardware stack page; upper half reused as scratch buffers       |
| `$0200-$02FF` | OAM DMA shadow buffer — `prg_1f.asm` `$F857` loads `A #$02` then `STA APU_OAM_DMA` (`$4014`), so OAM DMA always copies page `$02` |
| `$6000-$6FFF` | PRG-RAM **working set** — the live game state the engine reads/writes |
| `$7000-$7FFF` | PRG-RAM **saved snapshot** — byte-for-byte backup of `$6000-$6FFF` + checksum |

Writes to `$6000-$7FFF` are gated by the Namco-163 write-protect register at
`$F800` (`NAMCO_CTRL`), whose RAM shadow is `$00A5`. The engine holds it at
`$4C` and switches to `$40` for the duration of the save copy.

---

## Functional group index

| # | Group | Ranges |
|---|-------|--------|
| 1 | Math ABI / proc-local scratch | `$0000-$001F`, `$0020-$0029` |
| 2 | Shared search & work area | `$0030-$0045` |
| 3 | Dispatch, RNG, banked-call trampoline | `$004E-$005D` |
| 4 | Frame / IRQ / NMI kernel cells | `$005E-$0062`, `$0068-$0069`, `$0078-$007E` |
| 5 | Controller latches | `$0081-$0086` |
| 6 | PPU shadows, palette animation, scroll | `$0087-$0099` |
| 7 | Mapper shadows (CHR / PRG / write-protect) | `$00A5`, `$00AE-$00B5`, `$00DE-$00ED` |
| 8 | Scene/state-handler pointers (bank `$1D/$1E`) | `$00A6-$00DD` |
| 9 | Stack page + reused scratch buffers | `$0100-$01FF` |
| 10 | OAM shadow | `$0200-$02FF` |
| 11 | VRAM update queue + display buffers | `$0300-$03FF` |
| 12 | Scene / menu / UI handshake page | `$0400-$04FF` |
| 13 | Mode state machines (war / exchange / battle) | `$0500-$05FF` |
| 14 | Unit rosters and map tile grids | `$0600-$06FF` |
| 15 | Sound engine channel array + scratch | `$0700-$07F9` |
| 16 | Province records (30 × 32 B) | `$6000-$63BF` |
| 17 | Officer records (12 B each) | `$63C0-$6EFF` |
| 18 | Global game state, Country records, AI scratch | `$6F00-$6FFF` |
| 19 | Save snapshot + magic + checksum | `$7000-$7FFF` |

---

## Zero page `$0000-$00FF`

### Kernel / cross-bank cells (consistent meaning everywhere)

| Address        | Name (canonical)                  | Meaning |
|----------------|-----------------------------------|---------|
| `$0000-$0009`  | math ABI cells                    | `B1F_MathMul24x8` (`$EBE9`): multiplicand `$0000-$0002`, multiplier `$0003`, extension `$0004`, 40-bit product `$0005-$0009`. `B1F_MathDiv16` (`$EA7C`): dividend `$0001/$0002`, divisor `$0003/$0004`, quotient `$0001/$0002`, remainder `$0005/$0006`, temp `$0007`. Also the generic `($00)` record pointer filled by `B1F_GetProvinceRecordAddr` / `B1F_GetOfficerRecordAddr`. Otherwise generic pointer/workspace pairs (`zp_ptr_lo/hi` in `prg_1d_1e`, per-proc locals in `prg_0e_0f`) |
| `$000A-$000D`  | OAM/strip writer param quad       | X, X-hi, Y, Y-hi (or buffer ptr hi) for the overlay strip/OAM writers; `banked_work0-2` in `prg_1d_1e`; graphic/base pointer pair in `prg_1f`; BCD digit pairs `$000B/$000C` in the `prg_1f` math library |
| `$0010-$0013`  | tile/stream workspace             | `tile_ptr_lo/hi` `$0010/$0011`, `cmd_byte` `$0012` (menu data-stream command), `vram_tmp_lo` `$0013` (`prg_1d_1e`); menu ptr lo/hi + result in the `prg_1f` MenuStep ABI; cursor/list pointers in other banks |
| `$0020-$0029`  | math accumulator workspace        | `prg_0a_0b` mirror of the bank-`$1F` math ABI, shifted by `$20`: `Multiply32` (`$D438`) 24-bit multiplicand `$0020-$0022` × byte `$0023` → 32-bit product `$0026-$0029`; `Divide16` (`$D40F`) dividend `$0021/$0022` ÷ divisor `$0023/$0024` → quotient `$0021/$0022`, remainder `$0025/$0026`. Named `math_acc_lo/mlo/mhi/hi`, `math_ext`, `math_temp1-3`. `($20)` and `($22)` double as province/officer record pointers |
| `$0036-$0045`  | shared search/work area           | `work_outer_idx` `$0036`, `work_inner_idx` `$0037`, `work_inner_idx2` `$0038`, `work_sub_idx` `$0039`, `work_limit_a/b` `$003A/$003B`, `work_temp_0-2` `$003C-$003E`, `work_record_idx/val` `$003F/$0040`, `work_search_result` `$0041`, `work_search_max` `$0045` (`prg_0a_0b` strategy AI; reused as function params elsewhere). `$0038-$0043` is also the parameter block for the `$6F8B` strategy-layer mailbox |
| `$004E-$004F`  | `addr_dispatch_ptr(_h)`           | Indirect jump target for state dispatch (`prg_1f`, kernel) |
| `$0050-$0055`  | RNG cells                         | `addr_rng_index` `$0050`, `addr_rng_saved_x` `$0051`, variant indexes `$0052-$0055`; `$0050/$0052/$0054/$0055` are advanced every NMI so the sequence depends on frame timing |
| `$0058-$005D`  | BankedCallbackTrampoline ABI      | saved bank `$0058`, return addr `$0059/$005A`, target addr `$005B/$005C`, bank param `$005D` |
| `$005E-$005F`  | `frame_tick`                      | 16-bit free-running frame counter; low byte incremented by NmiEpilogue, high byte carries |
| `$0060`        | IRQ mode (active)                 | Scanline-IRQ dispatch selector read by `IrqHandler` (`$FB3F`); `0` = IRQ work disabled, `1-14` select `IrqMode1..IrqMode14`. Some modes `INC`/`DEC` it to chain to the next raster stage |
| `$0061`        | IRQ mode (reload)                 | Value copied into `$0060` at the top of every NMI (`$F81C`) — the per-frame IRQ program selection |
| `$0062`        | IRQ stage shadow                  | RAM copy of the last value written to `NAMCO_IRQ_HI`; used by the IRQ modes to track the raster stage |
| `$0068-$0069`  | Namco IRQ counter reload          | Written to `NAMCO_IRQ_LO`/`NAMCO_IRQ_HI` (`$5000`/`$5800`) at the top of every NMI (`$F80D-$F818`) to arm the first scanline IRQ of the frame. Reused as `map_data_ptr_lo/hi` (`prg_1f`) and `scene_param0/1` (`prg_1d_1e`) outside the interrupt path |
| `$0078`        | `addr_sub_state`                  | Sub-state within each major game state; the NMI handler dispatches on `$0078 & $0F` |
| `$007A`        | `addr_game_state`                 | Game state counter (0-14), indexes the state VectorTable |
| `$007B`        | NMI busy / re-entry flag          | Set while the NMI handler is running; temp saved around OAM DMA (`prg_1f`) |
| `$007C`        | `addr_sprite_count`               | Current OAM slot write cursor (`btl_oam_slot_cursor` during battle) |
| `$007D`        | `addr_nmi_flag`                   | NMI update pending flag |
| `$007E`        | `addr_nmi_ctrl`                   | NMI sub-dispatch control bits / render-request flags (`frame_flags`, `btl_anim_flags`); bit 2 = queued task done |
| `$0081-$0086`  | controller latches                | pad 1/2 newly-pressed (edge) `$0081/$0082`, pad 1/2 raw `$0083/$0085`, pad 1/2 previous `$0084/$0086`; battle bank aliases them as `btl_pad1_lo/hi`, `btl_pad2_lo/hi`; `prg_1d_1e` reads `input_flags` `$0081` |
| `$0087-$008A`  | palette animation                 | `addr_anim_direction/step/speed/counter` (`$0087` bit 7 = animation halted) |
| `$008B-$008C`  | PPU mirrors                       | RAM copy of PPUCTRL `$008B`, PPUMASK `$008C` |
| `$008E-$0091`  | scroll registers                  | scroll X lo/hi `$008E/$008F`, scroll Y lo/hi `$0090/$0091` (the high bytes carry the nametable-select bit) |
| `$0094-$0095`  | input prev-change flags           | X / Y d-pad change latch |
| `$0098-$0099`  | `addr_display_mode(_h)`           | Display mode parameter |
| `$009C-$009D`  | controller state X/Y              | D-pad state cells |
| `$00A5`        | Namco-163 write-protect shadow    | RAM copy of `NAMCO_CTRL` (`$F800`), the external-RAM write-protect register. Written together with the hardware register at `$E0B5`, `$E587`, and around every SRAM copy. Normal value `$4C`; the save routine (`prg_19_1a` `$BC02`) uses `$40` while copying, then restores `$4C`. **Not** a code patch — `$F800` is a mapper port, not writable ROM (some inline comments still call it "patch NMI handler") |
| `$00A6-$00AD`  | data / bank-switch pointers       | Banked data source pointer pairs used by the bank-switch helpers; `$00A6/$00A7` = menu data-stream pointer (`prg_1d_1e`), `$00A8-$00AD` = bank-switch/ptr work pairs (`prg_17_18`) |
| `$00AE-$00B5`  | CHR bank shadows                  | RAM copies of the 8 CHR bank registers ($8000..$B800 slots) |
| `$00DE-$00E3`  | PRG bank selects                  | select set A `$00DE-$00E0` (restored by NmiEpilogue), set B `$00E1-$00E3` (applied by NmiHandler); `$00E1` also read as `cur_bank_8000` in `prg_1d_1e` |
| `$00E6-$00E9`  | CHR register copies               | `NAMCO_CHR_BANK_0..3` shadows; `$00EA-$00ED` extended bank config |
| `$00F0-$00F1`  | note-stream pointer               | Sound / battle-animation note stream pointer (`prg_0e_0f`) |

### Mode-scoped zero-page cells

| Address | Bank(s) | Meaning |
|---------|---------|---------|
| `$0030-$0032` | 0a_0b | `work_row` / `work_src` / `work_dst` copy helpers |
| `$0044-$0056` | 0a_0b | `compare_mode` `$0044`, `search_max` `$0045`, `work_bound` `$0056` |
| `$0061` | 1d_1e | `disp_row_count` visible rows for list rendering (aliases the IRQ-mode reload cell — the two never overlap in time) |
| `$0068-$0074` | 1d_1e | `scene_param0-9` `$0068-$0071`, `officer_lookup_x/y` `$0072/$0073`, `scene_file_ref` `$0074` (aliases the Namco IRQ reload pair `$0068/$0069`) |
| `$006A-$006D` | 17_18 | proc-local ptr temps (overlaps `scene_param` range; different modes) |
| `$00A6-$00A7` | 1d_1e | menu data stream pointer |
| `$00A8-$00AD` | 17_18 | bank-switch/ptr work pairs |
| `$00BB-$00BD` | 0e_0f | `zp_panel_param_a/b/c` (B1D_1E panel script id / page / panel id); ptr temps in 17_18 |
| `$00BE-$00DD` | 1d_1e | StateHandler pointer/counter pairs: VRAM byte counters, row counters, display pointer temps |
| `$00E1` | 1d_1e | `cur_bank_8000` — current PRG bank mapped at `$8000-$9FFF` |
| `$00F0-$00F1` | 0e_0f | BattleAnimSoundEngine stream pointer (proc-local) |

Zero-page `$0000-$001F` in the battle bank pair (`prg_0e_0f`) is deliberately
**proc-local**: each `.proc` declares its own equate block with role names
(driven by `tools/zp_localize_manifest.json`, applied by `tools/zp_localize.py`).
See `code/prg_0e_0f_ram_map.md` for the full per-proc alias inventory.

---

## Stack page `$0100-$01FF`

The hardware stack grows from `$01FF` downward; the game keeps stack depth
shallow and reuses the upper page as buffers. Because banks `$1D/$1E` occupy
`$0100-$0190` with display tables and tile row buffers, the usable stack is
effectively confined to roughly `$01A0-$01FF`.

| Address | Bank(s) | Meaning |
|---------|---------|---------|
| `$0100` | 17_18 | `attr_buf` attribute buffer |
| `$0100-$0104` | 1d_1e | `disp_ptr_table` display pointer table (copied from `$0110`/`$0120`) |
| `$0110-$0120` | 1d_1e | display pointer sources; `$010C`/`$011C` checksum temps |
| `$0115-$0117` | 17_18 | ptr temp / var |
| `$0140` | 19_1a, 1b_1c | screen-transition busy flag (`$80` = transitioning, `$00` = idle) |
| `$0140-$014B` | 1d_1e | state dispatch: `tile_buf_base`, `state_scroll_x`, `state_vram_hi`, VRAM pos/display/attr addresses, tilemap source ptr |
| `$0142`, `$0166`, `$018A` | 17_18 | proc-local vars |
| `$0150` | 19_1a, 1b_1c | palette mask / hemisphere scroll flag (`(zoneXorigin & $80) ^ $80`) |
| `$0150-$0154` | 1d_1e | `officer_idx_buf`, `officer_list_idx`, name VRAM pos, `state_row_limit` |
| `$0160-$018F` | 1d_1e | `state_buf_end` tile row buffer (56 bytes) + extensions |
| `$0160-$018E` | 19_1a, 1b_1c | scroll/row scratch (`$0151`, `$0160`...) |
| `$0190` | 1d_1e | StateHandler work area |
| `$019E` | 17_18 | attribute accumulator |
| `$01B0-$01B3` | 17_18 | pointer pair workspace |

---

## `$0200-$02FF`: OAM DMA shadow

Page `$02` is the OAM shadow copied by `$4014` DMA every frame
(`STA APU_OAM_DMA` with `A #$02` at `prg_1f.asm:3597`).

| Address | Bank(s) | Meaning |
|---------|---------|---------|
| `$0200-$02FF` | all | OAM shadow buffer: Y, tile, attribute, X per sprite (256 bytes) |
| `$0200` | 17_18 | `sprite_list` base |
| `$0200-$0204` | 1d_1e | `oam_buf_lo/hi/idx/extra` build pointers into the shadow |

---

## `$0300-$03FF`: frame engine / mode buffers

Same addresses carry different payloads per game mode; `$0300`/`$0304` are
always two 4-byte slot headers owned by the frame engine.

| Address | Bank(s) | Meaning |
|---------|---------|---------|
| `$0300`, `$0304` | 0e_0f | tile-animation queue slot headers (`$FF` = empty) |
| `$0300`, `$0304` | 17_18 | confirm-check flags 0/1 (set by display, read by button check) |
| `$0300` | 1d_1e | `menu_status` (`$FF` done, `$00` need init, `$01` active) |
| `$0300`, `$0304` | 19_1a, 1b_1c | overlay slot 0/1 sentinels (`$FF` = idle) |
| `$0310-$0313` | 0e_0f | anim queue slot-0 tile-animation id lo/hi |
| `$0310-$0313` | 17_18 | PPU display queue pointer + `$FF` terminator |
| `$0310-$0313` | 1d_1e | VRAM position circular buffer (4 entries) |
| `$0318-$0319` | 19_1a, 1b_1c | animation frame counter/state |
| `$031C-$034E` | 1d_1e | tile row buffers 1/2 (VRAM hi/lo + data per column) |
| `$0380-$039C` | 0e_0f | `vram_script_buf` VRAM update script (two `$FF`-terminated segments) |
| `$0380` | 17_18 | `sprite_y_buffer` (OAM shadow scratch) |
| `$0380-$0395` | 1d_1e | display/render buffer base + offsets (year display cells `$0384-$038C`) |
| `$0380-$03A5` | 19_1a | overlay strip records (PPU addr hi/lo, tile cells, kana/digit cells, terminator `$03A3`) |
| `$0380` | 1b_1c | render scratch |
| `$037C-$037E` | 1d_1e | sub-state dispatch: main / province timer / officer |
| `$03AA-$03AB` | 1d_1e | overlay BCD digit tiles |
| `$03B7-$03BC` | 17_18 | map scroll PPU pointers 0-2 |
| `$03BA-$03BB` | 19_1a | choice cursor buffer |
| `$03C3` | 1d_1e | scene render flag |

---

## `$0400-$04FF`: shared scene / menu state

This page is the cross-mode handshake area. `$0400-$0402` and `$0420-$0425`
have canonical names used by several banks without redefinition.

| Address | Canonical name | Meaning (owners) |
|---------|----------------|------------------|
| `$0400` | `scene_callback_id` | Next scene callback id (0c_0d, 1d_1e, 19_1a, 1b_1c); strategy dispatch work ptr lo in 17_18; result cursor context in 08_09 |
| `$0401` | `scene_callback_st` | Scene callback sub-state counter |
| `$0402` | `province_idx` | Current province index (0c_0d, 1d_1e, 1b_1c); work offset in 17_18 |
| `$0408-$040A` | — | cursor slot / scroll offset / direction (19_1a); `scroll_ptr_lo/hi`, `scroll_done_flag` (17_18) |
| `$040C-$040D` | — | multi-role cursor pair: detail cursor x/y (0c_0d), result cursor (08_09), strategy cursor (17_18), step/turn counters (19_1a, 1b_1c) |
| `$0410` | — | detail officer id (0c_0d); result selected entry (08_09) |
| `$0420` | `menu_scroll_state` | Menu scroll / render state (0c_0d, 1d_1e, 1f, 1b_1c) |
| `$0424-$0425` | `menu_cursor_col/page` | Menu cursor column/page (0c_0d, 1f `addr_menu_column/page`, 19_1a, 1b_1c); troop-assign counters in 17_18; officer-list flag in 1d_1e |
| `$042C-$042E` | — | most-referenced trio: action result lo/hi/cnt (08_09), formatted number data (1d_1e), selected officer id + ext (17_18), overlay Country/Province display values (19_1a), intro focus province (1b_1c), battle panel params base (0e_0f `btl_panel_params`) |
| `$042F-$0431` | — | menu results / overlay values (19_1a, 1b_1c); damage amounts (17_18) |
| `$0432-$0437` | — | scroll/step scratch (19_1a, 1b_1c, 17_18) |
| `$0435` | `dispatch_timer` | dispatch countdown (17_18) |
| `$044C-$046B` | — | 32-byte display blocks: `exchange_disp_base` (0c_0d), `btl_panel_fields` (0e_0f), formatted numbers (1d_1e) |
| `$046C-$046F` | — | `result_menu_row` / `picked_entry_id` (08_09), `country_param_copy` (0c_0d), menu blink timer (17_18), row cursor (1b_1c) |
| `$0470-$0473` | `anim_ppu_ptr` / `map_scroll_ptr` | Animation PPU pointer lo/hi + map scroll source ptr lo/hi (0c_0d, 17_18); officer list state (1d_1e); scroll ptr slots (19_1a, 1b_1c) |
| `$0478-$047C` | — | officer list control/count/index/max/col (1d_1e, 19_1a, 1b_1c) |
| `$0480-$0486` | — | officer name buffer ($0B) + lengths (1d_1e); work cells (1b_1c) |
| `$048B-$0492` | — | action work area + stat deltas (08_09, 1b_1c) |
| `$0498-$049D` | — | stat snapshot row (19_1a, 1b_1c) |
| `$04A0-$04A5` | `menu_dispatch_*` | `menu_dispatch_flg` `$04A0` (menu id), `menu_row_step` `$04A1`, `menu_dispatch_idx` `$04A2`, `menu_row_inc` `$04A3`, action params `$04A4/$04A5` (1d_1e); `menu_index` `$04A2` = `$04A0 - 1` (19_1a, 1b_1c); `game_state`/`sub_state`/`player_slot` copies `$04A8-$04AA` (17_18) |
| `$04A8-$04B3` | — | player state block (17_18): game state copy, sub state, active player slot, player flags, officer ids, army values, random offsets, timers; `btl_sideev_params` `$04A8-$04AA` (0e_0f side-event panel) |
| `$04B8-$04C0` | — | animation/scroll timers, slide Y, cutscene progress, display ptrs, sub-action type, frame counter (17_18) |
| `$04C1-$04C6` | — | player scene index array, event overlay flag, UI state, name tile ptrs (17_18); `btl_attack_mirror_a/b` `$04C1/$04C2` (0e_0f) |
| `$04C8` | — | `war_overlay_flag` (08_09) / `exchange_result_cnt` (0c_0d) |
| `$04C9-$04CE` | — | dispatch step + src/dst/data/offset pointers (17_18); row/scroll state (19_1a) |
| `$04D0-$04D1` | — | menu display row counter (1d_1e); scroll row (19_1a) |
| `$04D2-$04D5` | `officer_rec_src/dst` | Officer record copy source/dest pointers (0c_0d, 1d_1e); dispatch data/offset ptrs (17_18) |
| `$04D6` | `menu_action_extra` | Menu action extra param (`$47` or `$A2` skips PPU init; 1d_1e, 19_1a, 1b_1c) |
| `$04D8-$04DF` | — | `army_slot_base` 8-byte array (0c_0d, shared with 08_09); `officer_select_flg`-style scratch |
| `$04E0-$04E3` | — | province dirty bitmap: bit = `$04E0[id>>3]` mask `1<<(id&7)` (19_1a, 1b_1c) |
| `$04E4` | — | sprite dirty mark (1b_1c); side-event work (19_1a) |

---

## `$0500-$05FF`: mode state machines

Strategy-command engines each own `$0500-$05xx` while active; the battle
overlay owns `$0540-$05D7`.

| Address | Bank(s) | Meaning |
|---------|---------|---------|
| `$0500-$0501` | — | mode id + sub-phase: `war_scene_id/phase` (08_09), `exchange_state/phase` (0c_0d), `select_mode` (1f), mode scratch (17_18, 19_1a, 1b_1c) |
| `$0504-$0507` | — | direction/side flag, action budget/points, round counter, packed pair — `war_*` (08_09), `exchange_*` (0c_0d), packed_ruler_pair `$0507` |
| `$0508-$050F` | — | timers, officer slots, scene index, province index, attacker code: `war_*` (08_09), `exchange_*` (0c_0d), `territory_event_type` `$050F` (17_18) |
| `$0510-$0513` | — | map scroll X/Y lo/hi (0c_0d, 1f, 19_1a, 1b_1c) |
| `$0514-$0517` | — | `war_side_selector` + strip sel/flags (08_09, 0e_0f `btl_strip_sel/flag`); player officer ids (17_18); province ptrs (0c_0d `$0522-$0525` variant) |
| `$051A-$0525` | — | merit sums, officer counts, province ptr pairs (0c_0d); war stat pairs `$0522-$0527` side A/B (08_09, 0e_0f-adjacent) |
| `$052A-$052F` | — | battle target province/officer/param + special-officer flag (08_09); exchange scene state (0c_0d) |
| `$053D-$053F` | — | undo state snapshot (0c_0d) |
| `$0540-$0544` | — | phase/sub-phase cells: `btl_overlay_phase/sub` `$0540/$0541` (0e_0f), `result_sub_mode/scene_phase` (08_09), `state_sub_dispatch/display_idx` (0a_0b), `move_path_x/y/cost/total` (0c_0d), `strat_scroll_*` (17_18), `battle_phase` `$0544` (0e_0f, also `action_type` in 1f) |
| `$0545-$0549` | — | `btl_scan_col/row/wait` + `btl_frame_counter` + `btl_acting_unit` (0e_0f); `state_overlay_param`/`state_palette_mode` (0a_0b); `result_dir_repeat` 4 bytes `$0545-$0548` (08_09) |
| `$054A-$054F` | — | `btl_walk_row/col`, `btl_recorded_status`, `btl_target_col`, `btl_command` (0e_0f) |
| `$0550-$055B` | — | `btl_order_slots_a/b` `$0550/$0554`, `btl_advance_*` `$0558-$055B` (0e_0f); `unit_ally_counts` `$0550` (08_09); `exchange_sel_list` `$0550-$055F` (0c_0d) |
| `$0560-$056D` | — | `btl_strip_buf_a/b`, input modes, countries, column counts, formations (0e_0f); `xfer_officer/ruler_*` (0c_0d); `sprite_idx1/2` (1f) |
| `$0568-$0569` | — | `btl_player_request_a/b` player handoff flags (0e_0f) |
| `$056A-$0577` | — | combat stats: `btl_attack_a/b`, `btl_defense_a/b`, `btl_edge_bonus_a/b`, `btl_point_budget_a/b`, `btl_status_ctr0-3` (0e_0f) |
| `$0578-$057C` | — | `btl_reload_a/b`, `btl_round_pass`, `btl_input_mask`, `btl_side_index` (0e_0f) |
| `$0580-$05D7` | — | battlefield unit arrays, stride `$0B` side B at `+`: `btl_unit_col_a/b` `$0580/$058B`, `btl_unit_row_a/b` `$0596/$05A1`, `btl_troops_a/b` `$05AC/$05B7`, `btl_roster_code_a/b` `$05C2/$05CD` (0e_0f); `officer_select_flg` `$0580-$059F` (0c_0d); `slot_id_list` `$0580` (08_09); unit columns (19_1a `$0580`) |

---

## `$0600-$07FF`: mode arrays + sound engine

| Address | Bank(s) | Meaning |
|---------|---------|---------|
| `$0600`, `$0614` | 08_09 | `unit_coord_x` / `unit_coord_y` columns, 20 slots (stride `$14` each) |
| `$0600`, `$0614` | 17_18 | `tile_grid_coord_x/y` arrays (20 entries) — reused as OAM x/y during map-screen sprite updates |
| `$0628` | 08_09 | `unit_army_array` army column (bit7 = side flag) |
| `$063C` | 08_09 | `unit_state_array` unit state column |
| `$0650` | 08_09 | `unit_immobilized` state flag column |
| `$0664` | 08_09 | `war_roster` officer id roster column (`$FF` = empty); province data ref (1d_1e, 19_1a, 1b_1c single-cell reuse) |
| `$066E-$0681` | 08_09 | scratch officer-id list (`$14` entries) built by `CollectUnitsBySide` |
| `$0680-$06BF` | 17_18 | `tile_index_grid` 64 bytes (`$FF` = empty) |
| `$06A0/$06C0/$06E0` | 17_18 | adjacency layers: left-right neighbor column, secondary up-down / left-right neighbor columns |
| `$0700-$07F1` | 0e_0f | **Sound channel state: 11 channels × `$16` bytes**, channel `n` at `$0700 + n*$16`. The engine loop walks it with `ADC #$16` / `CMP #$F2` (`prg_0e_0f` `$D8EB-$D957`). Field offsets: `+0` `snd_chan_state` (0 = off, 2 = init, `$FF` = remove), `+1` `snd_chan_hw_idx` (`& 7`), `+2/+3` stream ptr, `+4` duration, `+5` duration ctr, `+6/+7` volume + saved volume, `+8` note ctr, `+9` sweep, `+$A/+$B` vibrato ctrs, `+$C` aux, `+$D` freq period, `+$E` frame ctr, `+$F` decay ctr, `+$10` decay reload, `+$11` decay timer, `+$12` freq accumulator, `+$13` aux, `+$14` cmd reload, `+$15` cmd timer |
| `$07F2-$07F9` | 0e_0f | sound engine scratch: `snd_active_mask`, `snd_hw_index`, `snd_channel_mode`, `snd_reg_base`, `snd_apu_enable` (`$4015` shadow), `snd_freq_lo/hi`, `snd_frame_ctr`; 1f aliases `sound_ram_ptr` `$07F2`, `sound_irq_lo/hi` `$07F6/$07F7`, `sound_channel_ram` `$07F6` |

---

## WRAM `$6000-$7FFF`

The window is split in two halves. `$6000-$6FFF` is the **live working set**:
every record the engine reads or mutates during play. `$7000-$7FFF` is the
**saved snapshot**: a byte-for-byte backup of `$6000-$6FFD` plus a magic and a
checksum. Nothing else lives in `$7000-$7FFF`.

```
$6000 ┌──────────────────────────────┐
      │ 30 Province records × 32 B   │ $6000-$63BF
$63C0 ├──────────────────────────────┤
      │ Officer records × 12 B       │ $63C0-$6EFF  (240 slots)
$6F00 ├──────────────────────────────┤
      │ Global state, 7 Country      │ $6F00-$6FFF
      │ records, AI + war scratch    │
$7000 ├──────────────────────────────┤
      │ snapshot of $6000-$6FFD      │ $7000-$7FFD
      │   (incl. magic at $7FFC/FD)  │
      │ 16-bit checksum              │ $7FFE-$7FFF
$8000 └──────────────────────────────┘
```

### `$6000-$63BF`: Province records (30 × 32 bytes)

Accessor `B1F_GetProvinceRecordAddr` (`prg_1f.asm` `$F2AF`): `A` = province id
(`$00-$1D`), result `($0000/$0001) = id * 32 + $6000`. Banks `$08/$09` wrap it
as `GetProvinceRuntimePtr` returning the pointer in `($20)`; `prg_0a_0b`
`GetProvinceOwner` (`$D105`) resolves the record and returns the owner in `A`.

| Offset | Width | Meaning |
|--------|-------|---------|
| `+$00` | 1 | Owner / ruler code (bits 0-2 select the Country slot); also the officer "home" value |
| `+$01` | 1 | unidentified |
| `+$02/$03` | 2 | Gold (16-bit LE) — action costs are subtracted here (`$BF...`, `DeductRecordStat2`) |
| `+$04/$05` | 2 | unidentified |
| `+$06/$07` | 2 | Morale (16-bit LE), capped at `$270F` (9999) |
| `+$08/$09` | 2 | Troops (16-bit LE), capped at 999 — target of `ReinforceTroops` |
| `+$0A` | 1 | Development stat, capped at 99 |
| `+$0B` | 1 | Loyalty stat, capped at 99 for the plain raise, 100 for the bonus paths |
| `+$0C/$0D` | 2 | unidentified |
| `+$0E/$0F` | 2 | Supplies (16-bit LE) — same algorithm as `ReinforceTroops` |
| `+$10` | 1 | unidentified |
| `+$11-$1A` | 10 | Officer roster: 10 officer-id slots, `$FF` = empty. `CountRosterSlots` (`$D3D5`-ish) counts non-`$FF` entries; a compaction routine (`$D520`-ish) removes `$FF` gaps in place |
| `+$1B-$1F` | 5 | unidentified / padding |

### `$63C0-$6EFF`: Officer records (12 bytes each)

Accessor `B1F_GetOfficerRecordAddr` (`prg_1f.asm` `$F2D7`): `A` = officer id,
result `($0000/$0001) = id * 12 + $63C0`. The ROM master table is fetched by
`GetOfficerRomRecordAddr` (`$F387`), which maps PRG bank `$31` at `$8000` and
computes `id * 12 + $8000` — the SRAM block is initialised from it at new game.
`prg_0a_0b` `ReadRecordField` (`$D283`, alt entry `$D2AB` using `($22)`) reads
individual fields.

| Offset | Meaning |
|--------|---------|
| `+0` | 体力 Vitality |
| `+1` | 武力 Might |
| `+2` | 知力 Intelligence |
| `+3` | 忠誠度 Loyalty (dynamic, clamped to `[10, 90]`; the ROM seed uses `100` to mark the seven playable rulers) |
| `+4` | 人徳 Virtue |
| `+5` | unidentified; always `0` in the ROM seed, so it is a runtime-only field |
| `+6/+7` | 経験値 Experience, 16-bit LE |
| `+8/+9` | 兵数 TroopCount, 16-bit LE |
| `+10` | equipment, packed: bits 0-4 = 武器 Weapon, bits 5-7 = 防具 Armor |
| `+11` | bits 4-7 = レベル OfficerLevel (0-based; the UI shows level+1), bits 0-3 = 軍の属性 ArmyAffinity |

The `+6`-through-`+11` decode is confirmed against the manual's 呂布 duel data
(`docs/manual_kb/10-duel-mode.md`: 武99 知17 忠30 徳10, レベル4, 山軍,
方天画戟, 甲冑), which is exactly what ROM record 218 yields. ArmyAffinity is
`(nibble - 1) / 4` → `0` 平軍 / `1` 山軍 / `2` 水軍; the ROM only ever stores
nibbles `1,2,5,6,9,10` and the distinction inside each pair is not yet
identified. Weapon and armor code tables are listed in `docs/officer_data.md`.
Field names follow `docs/manual_kb/terminology.md`.

The 240-slot capacity follows from the geometry `($6F00 - $63C0) / 12` and is
corroborated by the officer name table in PRG bank `$30` (`id * 10 + $901A`),
whose officer block is exactly 240 entries — index 240/241 already hold the
resource labels キン/コメ. Only 237 of them are populated: the ROM master
record table (bank `$31` at `$8000`, 12 B/record) ends after record 236 and
name slots 237-239 are blank, so ids 237-239 are spare. See
`docs/officer_names.txt` (generated by `tools/extract_officer_names.py`) and
`docs/officer_names_kanji.md` for the kanji/Chinese form of each name, and
`docs/officer_data.md` / `docs/officer_data.csv` (generated by
`tools/extract_officer_data.py` straight from the `.nes` image) for every
officer's decoded starting record.

> A comment at `prg_0a_0b.asm:8151` describes this accessor as "province record
> … A * 24 + $63C0". The code actually computes `A*3 << 2 = A*12` from the
> officer base — the comment is wrong, it is the **officer** record accessor.

### `$6F00-$6FFF`: global state, Country records, AI scratch

| Address | Name(s) | Meaning |
|---------|---------|---------|
| `$6F00-$6F01` | — | attract-demo scratch: demo year tick / rotation step (reused while no game is loaded) |
| `$6F02` | `sram_game_level` (0a_0b) | Game level 0-2, selected at new game start; demo scratch `result_kingdom_idx` latch in 08_09 |
| `$6F03` | `sram_player_id` | Current player country slot / ruler id |
| `$6F04-$6F06` | — | attract-demo scratch: frame divider, Province count display value, camera-focus phase flag |
| `$6F05` | — | SRAM game-state flag (0 = no game, ≥1 = in progress; clamped); also AI budget seed (`$6F5D = $6F05 * 10`, max 130) |
| `$6F07-$6F3E` | `faction_records` / `sram_country_data` | Country records, 7 countries × 8 bytes (stride 8): slots at `$6F07,$6F0F,$6F17,$6F1F,$6F27,$6F2F,$6F37`, resolved by `B1F_GetCountryDataPtr` (`prg_1f` `$F368`) via `CountryDataPtrTable` (`$F379`). Record byte `[0]` = Ruler id (`$FF` = empty), `[1]` = home Province, `[3]` = status/alliance byte (`$6F0A` + stride 8) |
| `$6F3F-$6F42` | `sram_map_cam_y/x` | Map camera position: Y low `$6F3F`, Y high `$6F40`, X low `$6F41`, X high `$6F42` (init `$80`/`$F0` on new game) |
| `$6F3F` / `$6F41` | — | country init params `$80`/`$F0` on new game (17_18 view of the same bytes) |
| `$6F43` | — | latched result parameter / scroll-pending flag |
| `$6F44` | — | multi-alias: battle outcome flag (08_09), target province record field 3 (19_1a), player swap trigger (17_18) |
| `$6F45` | — | attract-demo rotation order index (0-4, randomised by `SramInit`; row base for the 5×8 rotation table) |
| `$6F47-$6F6E` | `reserve_units` | Reserve unit id lists, 2 × `$14` (08_09). Overlaps the counters below — the war engine and the strategy-AI counters are never live at the same time |
| `$6F5B-$6F5D` | — | iteration counter (`sram_counter`), per-turn counter `$6F5C`, AI action-point budget `$6F5D` (seeded as `$6F05 * 10`, max 130, decremented per action) |
| `$6F5E` | — | province index cursor for the AI turn scan |
| `$6F5F-$6F62` | — | computed weight values 0-2 (`$6F5F-$6F61`, used by the weighted-random action dispatcher), global phase / per-officer active flag `$6F62` |
| `$6F72` | — | selected candidate officer id |
| `$6F73-$6F82` | — | AI work area, cleared before each decision pass. `$6F73[0..7]` = per-owner "has active provinces" marks (`$FF` = none, `$00` = has provinces; a helper counts the `$00` entries in `$6F73[0..6]`) |
| `$6F7B-$6F82` | — | transfer/claim buffer, 8 bytes, initialised to `$FF` = unclaimed |
| `$6F83` | — | per-country action counter (`$6F83,X`); after `$1E` actions the global phase advances |
| `$6F8B` | `sram_game_start_flag` | **Strategy-layer request mailbox** — the main cross-bank handshake. Strategy banks `$0A/$0B` post a request code and spin-wait; map-screen frame state 9 (banks `$19/$1A`, `$C773-$CD8B`, 16-entry sub-state table at `$C779`) polls it and acknowledges by writing `$01`. Codes: `$FF` turn complete (posted by `$08/$09`), `$FE` battle pending, `$FD` fully absorbed, `$FC` absorption result, `$FB`/`$FA`/`$F9` strategy actions, `$F8` absorption variant. Parameters travel in zero page `$0038-$0043`. Also set to `$FF` at new game. See `memory/project_tech_stack/strategy-layer-request-mailbox-protocol.md` |
| `$6F8C-$6F8F` | — | AI turn scratch: `ai_officer_idx`, `ai_target_slot`, `ai_target_officer`, `ai_action_result` |
| `$6F91-$6F9B` | — | war AI scratch: `side_unit_base` (0/10), `rng_cursor`, `rng_x_save`, `officer_scan_idx`, `acted_officer_cnt`, `valid_officer_cnt`, `ai_move_cost`, `formation_slot0/1_units` (nibbles, stride 2 at `$6F9A`) |
| `$6FA1-$6FE0` | `officer_state_table` | Officer state / unit placement queue (`$40` bytes) |
| `$6FB5` | `move_reverse_dirs` | Per-officer reverse of last move direction |
| `$6FC9-$6FDC` | `proximity_table` | Proximity scan table (`$14` bytes) |
| `$6FDD-$6FE0` | `adjacent_scan_results` | Adjacent officer scan results, 4 entries in N/S/W/E order (filled by `AiScanAdjacentOfficers`) |
| `$6FE1` | `sram_territory_event` | Territory event flag (bit 0 = capture officer) |
| `$6FE2-$6FE8` | — | per-country event backup flags (one per country; restored if `$6FE2 == $FF` means no backup) |
| `$6FEA` | `result_latch_flags` | Dir-repeat latch / outcome bits |
| `$6FFC-$6FFD` | — | save magic `"ID"` (`$49 $44`), stamped by the save routine immediately before the copy (`prg_19_1a` `$BC0A-$BC11`) |

### `$7000-$7FFF`: save snapshot

Three routines own this half; nothing else touches it.

| Routine | Location | Behaviour |
|---------|----------|-----------|
| **Save** | `prg_19_1a.asm` `$BC02-$BC7F` | Set `$00A5` and `NAMCO_CTRL` (`$F800`) to `$40`; stamp magic `$49`/`$44` at `$6FFC`/`$6FFD`; copy `$6000-$6FFD` → `$7000-$7FFD` while accumulating a 16-bit sum in `$0004/$0005`; store the sum at `$7FFE/$7FFF`; restore `$00A5`/`$F800` to `$4C` |
| **Verify** | `prg_0a_0b.asm` `VerifySramChecksum` `$DC2F` | Check `$7FFC` = `$49` and `$7FFD` = `$44`, re-sum `$7000-$7FFD`, compare against `$7FFE/$7FFF`. Returns `C=1` when the save is valid |
| **Load** | `prg_0a_0b.asm` `CopySramToWork` `$DC97` | Set `$00A5`/`$F800` to `$4C`, then copy all 16 pages `$7000-$7FFF` → `$6000-$6FFF` |

| Address | Meaning |
|---------|---------|
| `$7000-$7FFB` | Snapshot of `$6000-$6FFB` (province records, officer records, `$6F` page) |
| `$7FFC-$7FFD` | Snapshot copy of the magic `"ID"` — the field actually tested by `VerifySramChecksum` |
| `$7FFE-$7FFF` | 16-bit little-endian sum of every byte in `$7000-$7FFD` |

`prg_1f.asm` also contains `WriteRamPattern` (`$F43F`) / `VerifyRamPattern`
(`$F422`), which fill and re-check `$6000-$7FFF` with a pseudo-random sequence
seeded `$AA`. They are only reachable from the anti-piracy path of
`CopyProtectionCheck` (`$F3BD`), which does not run on real hardware.

### Notes

- `$6F00-$6F06` is dual-use: game level/player id during real games, attract
  demo scratch during the demo (the demo runs with no valid save).
- `$6F8B` is the only cross-bank blocking handshake in the codebase; a requester
  writes a code and busy-waits for the handler to write `$01` back.
- Writes to the whole `$6000-$7FFF` window are gated by `NAMCO_CTRL` (`$F800`),
  shadowed at `$00A5`. Save uses `$40`, everything else uses `$4C`.
- The scan tool reports apparent references like `$6160`, `$6800`, `$7170` in
  `prg_19_1a.asm` — these are `.byte` data bytes (tile attr pairs), not RAM
  accesses, and are excluded here.

---

## Per-bank ownership summary

| Bank file | RAM style | Key regions owned |
|-----------|-----------|-------------------|
| `prg_08_09.asm` | file-top equates + proc locals | war engine `$0500-$052F`, result scene `$0540-$0580`, war unit arrays `$0600-$0677`, AI scratch `$6F8C-$6FDC` |
| `prg_0a_0b.asm` | file-top + proc-local equates | strategy AI work `$0020-$0045`, state cells `$0540-$0547`, SRAM game level/player, SRAM verify + load (`$DC2F`/`$DC97`) |
| `prg_0c_0d.asm` | file-top equates | exchange engine `$0500-$0565`, menu/panel `$0400-$04D8` |
| `prg_0e_0f.asm` | `btl_`/`snd_` globals + proc-local zp | battle overlay `$0514-$05D7`, anim queue `$0300-$0311`, vram script `$0380-$039C`, sound `$0700-$07F9` |
| `prg_17_18.asm` | file-top equates | kernel cells, map tile grids `$0600-$06FF`, player state `$04A8-$04C6`, display queue `$0300-$0313` |
| `prg_19_1a.asm` | raw addresses + comments (no equates) | attract demo / map screen frame states `$0400-$0437`, overlay sentinels `$0300-$03BB`, demo SRAM scratch `$6F00-$6F06`, `$6F8B` mailbox handler (frame state 9), SRAM save (`$BC02`) |
| `prg_1b_1c.asm` | raw addresses + comments (no equates) | map screen frame states `$0400-$04E4`, transition busy `$0140/$0150` |
| `prg_1d_1e.asm` | file-top equates | state handler zp `$00A6-$00DD`, render buffers `$0100-$0190`, `$0300-$03C3`, menu system `$0420-$04D6` |
| `prg_1f.asm` | file-top equates | kernel cells (game state, IRQ modes `$0060-$0062`, RNG `$0050-$0055`, trampoline `$0058-$005D`, bank selects `$00DE-$00ED`), menu `$0424/$0425`, map scroll `$0510-$0513`, all SRAM record accessors (`$F2AF`, `$F2D7`, `$F368`) |

## Open questions

- Province record fields `+$01`, `+$04/$05`, `+$0C/$0D`, `+$10`, `+$1B-$1F` are
  still unidentified.
- Officer record field `+5` has no known meaning; it is `0` in every ROM seed
  record, so it is written only at runtime. Within the `+11` army-affinity
  nibble, the pairing (`1`/`2`, `5`/`6`, `9`/`10`) is likewise unexplained.
- Officer starting province and appearance year are not part of the 12-byte
  master record; the scenario table that holds them has not been located.
- The officer *slot* count (240) is derived from the geometry of
  `$63C0-$6EFF`, not from a loop bound; the officer count proper is 237.
- `$0600-$06FF` is documented both as war unit columns (`prg_08_09`) and as the
  map tile grid (`prg_17_18`). Whether these truly alias the same bytes or
  occupy disjoint sub-ranges has not been verified.
- The exact bit semantics of the `NAMCO_CTRL` values `$4C` / `$40` are not
  established; only the observed usage pattern is documented here.


## Verification

- `tools/verify_0e_0f.py` — assembles `prg_0e_0f` in isolation, 16384 bytes, 0
  mismatches vs `rom/prg/prg_0e.bin` + `prg_0f.bin`.
- `tools/tmp_verify_ram_syms.py` — byte parity for `prg_08_09` after RAM symbol
  conversion (bank08 keeps a pre-existing `$BAF4+` drift, bank09 clean).
- `tools/tmp_verify2_1f.py` — equate-aware verification for `prg_1f`.
- Cautions: zp-encoded operands (`A5`-style) must stay zp and absolute-encoded
  zero-page operands must keep the `a:` prefix — changing either shifts all
  later bytes (see `code/prg_0e_0f_ram_map.md`).
