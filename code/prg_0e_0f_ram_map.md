# prg_0e_0f.asm RAM Map Analysis ($0000-$07FF)

Analysis of all RAM references in the $0000-$07FF range (zero page + low
WRAM) in `asm/banks/prg_0e_0f.asm`, with semantic names assigned to the
cross-procedure parameters and global variables. The raw-operand usage
inventory this analysis is based on is preserved in
`code/prg_0e_0f_ram_usage.txt` (generated pre-rename by
`tools/tmp_ram_usage_0e0f.py`).

## Region overview

| Region        | Contents                                                     |
|---------------|--------------------------------------------------------------|
| $0000-$001F   | Zero-page call-register cells (per-proc local semantic names) |
| $005E-$00BD   | Engine/hardware cells (frame tick, pads, NMI flags, panel params) |
| $0100-$02FF   | Not referenced by this bank (stack page / unused here)       |
| $0300-$0311   | Tile-animation queue (slot headers + slot 0 anim id)         |
| $0380-$039C   | VRAM update script buffer (two FF-terminated segment records)|
| $0424-$04D8   | Shared menu/panel state (menu cursor, panel param/field blocks, side-event panel) |
| $0500-$0501   | War scene id/phase (shared with prg_08_09.asm)               |
| $0514-$057C   | Battle overlay state machine, per-side combat stats, AI tactic state |
| $0580-$05D7   | Battlefield unit arrays (columns/rows/HP/roster codes, side B at +$0B) |
| $0700-$0715   | Sound channel state (parallel arrays indexed by channel base, stride $16) |
| $07F2-$07F9   | Sound engine scratch (masks, mode byte, freq divisors)       |

## Naming decisions

- Cross-proc globals: file-top equate block in `prg_0e_0f.asm`, `btl_`
  prefix for battle-scene variables, `snd_chan_*`/`snd_*` for the sound
  engine. All names verified unique across the whole ca65 assembly (all
  banks share one namespace).
- **Zero-page cells $0000-$001F are proc-local**: each proc defines its own
  "zero-page work cells" equate block right after `.proc` with names that
  describe the cell's role in that proc (e.g. `damage`/`troops_pre` in
  Phase2AttackDamageApply vs `total_a_lo`..`total_b_hi` in
  BattleOutnumberedCheck for the same cells). A cell may carry several
  local aliases in one proc for sequential-reuse lifecycles (e.g.
  `rank_a_work` -> `success_chance` chains, or `strip_ptr_lo` and
  `country_ptr` both = $0000 with per-line usage). The manifest driving
  this per-function design is `tools/zp_localize_manifest.json`, applied by
  `tools/zp_localize.py` (supports default cell maps, per-line overrides
  keyed by ROM-address comment, and raw $00XX operand renames).
- The $0000-$0008 cells double as the B1F_MathMul24x8 / B1F_MathDiv16 ABI
  (24-bit multiplicand $0000-$0002, product in $0006/$0007, dividend
  $0001/$0002, divisor $0003/$0004, quotient $0001, remainder $0005); procs
  calling those helpers name their locals accordingly (dividend_lo,
  divisor_lo, product_lo, ...). $000A-$000D are the OAM/strip writer
  parameter quad (X, X hi, Y, Y hi or buffer ptr hi depending on writer).
- Addresses owned by other scenes reuse the canonical names from the
  owning bank files (no redefinition): `menu_cursor_col`/`menu_cursor_page`
  ($0424/$0425, prg_0c_0d.asm), `war_scene_id`/`war_scene_phase`
  ($0500/$0501, prg_08_09.asm).
- The pre-existing proc-local equates `frame_tick` ($005E) and
  `battle_phase` ($0544) were promoted to the file-top block: replacements
  use them bank-wide, and proc-local scope would hide them from other
  procedures.
- Remaining raw zero-page addresses outside $00-$1F keep raw form where
  single-proc and minor: $00AE-$00DD CHR bank shadows (BattleChrBankAnimate
  / Phase9AdvanceInit marker OAM rows), $00E2 and $00F0/$00F1
  (BattleAnimSoundEngine stream pointer), $00B7 (BattleSideStatusCounterDraw).

## Highlights per group

- **Overlay state machine**: `btl_overlay_phase` $0540 (0-6, $B flash),
  `btl_overlay_sub` $0541 (per-phase sub-state, INC-advanced),
  `btl_scan_col/row/wait` $0545-$0547 (roster scan cursor),
  `btl_frame_counter` $0548, `btl_acting_unit` $0549 (bit7 = none),
  `btl_walk_row/col` $054A/$054B and `btl_recorded_status` $054C
  (dual use as phase/sub resume latch during player-request entry),
  `btl_target_col` $054D, `btl_command` $054F.
- **Per-side stats**: attack $056A/$056B (mirror $04C1/$04C2, reload latch
  $0578/$0579), edge defense $056E/$056F, edge bonus $0570/$0571, tactic
  point budget $0572/$0573, troop counts $05AC/$05B7, status counters
  $0574-$0577 (two nibble counters per byte).
- **Side setup**: input modes $0562/$0563 (3 = AI), countries $0564/$0565,
  formation indexes $056C/$056D, column counts $0566/$0567, player-request
  handoff $0568/$0569, strip buffers/records $0560/$0561 + $0514-$0517.
- **Sound**: channels are state arrays at $0700+channel*$16 with named
  fields (state, hw index, stream ptr, duration, volume, sweep, vibrato,
  decay, command timers); engine scratch $07F2-$07F9 (active mask, mode
  byte, register base, APU enable shadow, frequency divisors).

## Verification

`tools/verify_0e_0f.py` (extended to inject the external RAM globals
owned by other bank files) assembles the bank pair in isolation and
compares against `rom/prg/prg_0e.bin` + `rom/prg/prg_0f.bin`:
**compared 16384 bytes, 0 mismatches** after the rename and after the
subsequent per-proc localization of the $00-$1F cells.

Caution for future edits: zp-encoded operands (`A5`-style, no `a:`
prefix) must stay zp and absolute-encoded zero-page operands (`AD`, with
`a:` prefix) must keep the prefix -- dropping or adding it changes the
instruction length and shifts all following bytes. When introducing a
local name for `$0006`-style cells that were absolute-encoded, write
`LDA a:name`.
