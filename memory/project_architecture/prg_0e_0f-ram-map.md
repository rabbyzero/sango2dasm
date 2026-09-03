# prg_0e_0f.asm RAM map: btl_ globals plus proc-local zero-page naming

- **Category:** project_architecture
- **Memory ID:** 2dd3b789-00bc-4521-9fb6-88310369000b
- **Keywords:** prg_0e_0f, RAM map, btl_ prefix, proc-local zero-page, zp_localize, battle overlay, sound channel
- **Usage scenarios:**
  - Editing or analyzing prg_0e_0f.asm battle overlay code
  - Naming RAM variables in battle context
  - Looking up cross-bank RAM address ownership

## Content

In `prg_0e_0f.asm` (battle overlay/battlefield bank pair), RAM $0000-$07FF naming:

The file-top block holds only true cross-proc globals (`btl_*` battle vars):

- btl_overlay_phase $0540
- btl_overlay_sub $0541
- btl_scan_col/row/wait $0545-$0547
- btl_frame_counter $0548
- btl_acting_unit $0549
- btl_walk_row/col $054A/$054B
- btl_recorded_status $054C
- btl_target_col $054D
- btl_command $054F
- order slots $0550/$0554
- attack/defense/bonus/budget pairs $056A-$0573
- status counters $0574-$0577
- unit arrays $0580/$058B/$0596/$05A1
- troops $05AC/$05B7
- roster codes $05C2/$05CD
- panel_params $042C
- panel_fields $044C
- frame_tick $005E
- battle_phase $0544
- `snd_chan_*` $0700-$0715 and `snd_*` $07F2-$07F9

Zero-page cells $0000-$001F are deliberately NOT global: each proc defines its own local equate block ("zero-page work cells (proc-local)") right after `.proc` with per-proc role names, including multiple aliases for one address when roles alternate (per-line overrides keyed by the ROM-address comment).

Design manifest: tools/zp_localize_manifest.json; scoped applier: tools/zp_localize.py (`--overrides-only` re-applies just per-line renames).

Key ABI facts:

- $0000-$0008 double as B1F_MathMul24x8/B1F_MathDiv16 cells (multiplicand $0000-$0002, multiplier $0003, product $0006/$0007, dividend $0001/$0002, divisor $0003/$0004, quotient $0001, remainder $0005)
- $000A-$000D are the OAM/strip writer param quad
- BattlePadStateFetch returns merged pad hi in $0000 / lo in $0001

Shared with other banks without redefinition:

- menu_cursor_col/page $0424/$0425 (prg_0c_0d)
- war_scene_id/phase $0500/$0501 (prg_08_09)

CRITICAL: keep `a:` prefixes on absolute-encoded zp operands (dropping one changed LDA to 2-byte zp and shifted all later bytes); ca65 gives zp encoding for symbol values <$0100.

Verified: tools/verify_0e_0f.py -> 16384 bytes, 0 mismatches.

Docs: code/prg_0e_0f_ram_map.md; raw usage inventory: code/prg_0e_0f_ram_usage.txt.
