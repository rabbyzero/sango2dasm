# prg_0e_0f.asm RAM $0000-$07FF semantic naming and byte-exact verification

- **Category:** task_summary_experience
- **Memory ID:** 5876869a-94ef-48fa-b870-ec1cc8eaed67
- **Keywords:** prg_0e_0f, RAM naming, battle overlay, sound channel, zero-page registers, regex token boundary

## Content

## Task description
- Core requirement: analyze RAM region $0000-$07FF in prg_0e_0f.asm and rename raw addresses to semantic names for parameters and global variables.
- Task background: prg_0e_0f.asm (battle overlay/battlefield bank pair) had only 2 existing RAM equates; ~220 distinct addresses were used as zero-page call registers, battle state cells, panel params, and sound engine channels. The file uses a single ca65 unit across all banks, so RAM names must be unique globally.

## Execution process
1. Generated usage inventory: grep all `$0[0-7]xx` operands in prg_0e_0f.asm, identified ~220 distinct addresses with semantics from comments and code context.
2. Checked cross-bank name collisions: searched all bank files for existing equates at $0000-$07FF; found shared addresses (menu_cursor_col/page, war_scene_id/phase) owned by other banks.
3. Created file-top RAM map block (~130 equates): `zp_*` for zero-page call-register file ($0000-$001C), `btl_*` for battle globals ($042C-$05D7), `snd_chan_*`/`snd_*` for sound channel arrays ($0700-$07F9). Promoted `frame_tick` ($005E) and `battle_phase` ($0544) from proc-local to file-top globals.
4. Wrote replacement script: regex-based operand renaming with two passes (4-digit absolute and 2-digit zp forms); added lookbehind to skip offsets inside `base+$xx` expressions. Encountered and fixed regex bug: `\b` after 3-digit group never matched 4-digit tokens like `$0545`; fixed by consuming full hex token before `\b`.
5. Applied replacements: replaced ~2,100 operand references with symbolic names; kept single-proc scratch cells as raw addresses per scope rule.
6. Verified byte-exact parity: patched tools/verify_0e_0f.py to inject external RAM equates; assembled banks 0E+0F standalone; compared against ROM binaries: 16384 bytes, 0 mismatches.

## Related files
- asm/banks/prg_0e_0f.asm — added RAM map block at file top; replaced all $0000-$07FF operand references with semantic symbols
- tools/verify_0e_0f.py — injected external RAM equates (menu_cursor_col/page, war_scene_id/phase) into harness
- code/prg_0e_0f_ram_usage.txt — generated usage inventory report (pre-symbolic analysis artifact)
- code/prg_0e_0f_ram_map.md — documented naming decisions and region semantics

## Notes
- Full `make` build fails on pre-existing duplicate-symbol errors in prg_0a_0b/prg_0c_0d/prg_17_18; per-bank harness is the verification path.
- Regex pitfall: address regex must consume the full hex token before `\b`; `\$([0-7][0-9A-Fa-f]{2})\b` failed on 4-digit tokens because `\b` between digit and digit never matches. Fixed pattern: `\$([0-7][0-7][0-9A-Fa-f]{2})\b` for absolutes, `\$([0-9A-Fa-f]{2})\b` for zp forms.
- Mixed 2-digit zp-encoded operands (85/A5 opcodes) and 4-digit absolute operands (`a:$0081`, 8D/AD) for the same cell both map to the same symbol; ca65 keeps zp encoding for values < $0100, so byte parity holds.

## Task overview
Completed: analyzed $0000-$07FF usage in prg_0e_0f.asm, implemented ~130 semantic RAM equates with zp_/btl_/snd_ prefixes, fixed regex token-boundary bug in replacement script, verified byte-exact parity (16384 bytes, 0 mismatches) using per-bank harness. Artifacts: usage inventory report and naming decision doc saved in code/.
