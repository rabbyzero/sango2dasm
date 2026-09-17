# lo/hi immediate pointer symbolization in prg_19_1a and prg_1b_1c

- **Category:** task_summary_experience
- **Memory ID:** 82fb6077-82bb-4b39-a1fd-1e6a513ed046
- **Keywords:** lo hi immediate, pointer construction, #<Label, data region split, menu cursor triplet, byte-exact verify, prg_19_1a, prg_1b_1c

## Content

## Task
Scan prg_19_1a.asm / prg_1b_1c.asm for data regions with no direct references; those used via raw lo/hi immediate pairs (LDA #$lo / LDA #$hi stored into consecutive zp) were to get semantic labels and #<Label/#>Label references. User confirmed bank files are standalone: every $A000-$DFFF raw operand in a file refers to that file's own banks; never cross-check between bank files.

## Method (tools/tmp_lohi_ptr_scan.py, tools/tmp_symbolize_lohi.py)
1. Parse each file's .byte/.word regions (byte length from item count, not line count — a single 13-byte .byte row is one region); capture labels incl. @-prefix with pending-label resolution (label line often has no $XXXX comment) and .proc scope of both label and use site.
2. Detect pointer constructions: immediate load (LDA/LDX/LDY #$xx) + STA zp within 3 instrs, two such events writing zp addresses differing by 1; lo/hi order either way. CRITICAL: allow same-register pairs (LDA/LDA is the dominant construction — excluding reg_a==reg_b hides nearly all hits); parse 4-digit `STA a:$00xx` zp form.
3. Hot regions = unlabeled or label unreferenced; filter pairs to hot targets; verify each case by reading context; confirm use-scope == label-scope (same .proc → @-label refs valid, else bare global).
4. Apply: split concatenated rows (stream 3-4B + pos table 4B + cursor sprite 5B) into labeled parts; convert immediates via unique anchor `;$XXXX: yy` + expected operand. Verify with tools/verify_19_1a.py + verify_1b_1c.py (16384 bytes, 0 mismatches each).

## Result (26 cases, 138 immediate conversions, 5 row splits)
- prg_19_1a: Confirm triplet $CD46/$CD4A/$CD4E (labels existed, unused); RulerSuccessionScene $BFAC 13-byte row split into SuccessionConfirmValidTable/$BFB0 CursorPosTable/$BFB4 CursorSprite; $D7FF BG strip base labeled @SceneBgStripBase (base+$00/$20/$40 via #$FF+ADC trick — #<#> still byte-exact).
- prg_1b_1c: 13 bare-global triplets (CommandCategory, CastleCommand, CastleDev, CastleMove, CastleScoutRecruit/Find, ArmyMenu/Provision/Member/ReconExit, ConfirmDialog, OfficerSelect, MapRulerMarkerSprite) wired to their existing labels; 9 @-local triplets wired (@Market*, @RiceTrade*, @Armory*, @ArmoryBuy*, @Command*, @RulerSelect*, @CardClose*, @GiftDialog*, @ArrowSprite); 3 warehouse rows split into new bare labels WarehouseCommand*/WarehouseGive*/WarehouseOfficerGive* (MenuStream + CursorPosTable + CursorSprite); fixed stale $B81A comment to $B819 (ROM-verified).

## Notes
- Regions left untouched (no refs of any kind): prg_19_1a $C000, $D425, $DE32-$DFFF; prg_1b_1c $BFFF/$C000, $C9E6-$C9EE (BNE branch target at $C9EE implies last byte is code, not data).
- Dead @-labels (@MarketMenuStream etc.) existed from a prior pass but were never referenced — the immediates were never symbolized.
- fish shell: no heredocs/process substitution in Bash tool — use `bash -c` wrapper.
