# Symbolizing lo/hi immediate pointer constructions in prg_19_1a and prg_1b_1c

- **Category:** task_summary_experience
- **Memory ID:** d1bb1d08-525a-4eaa-a713-a737b353fb49
- **Keywords:** lo hi immediate, pointer construction, #<Label, data region split, menu cursor triplet, byte-exact verify, prg_19_1a, prg_1b_1c

## Content

## Task description
- Core requirement: scan prg_19_1a.asm and prg_1b_1c.asm for unused data regions that are referenced via `#<ADDR`/`#>ADDR` (lo/hi byte immediate loads) rather than direct symbolic references; fix them with semantic labels and `#<Label`/`#>Label` style references. Some data regions were broken into multiple parts with different references.
- Task background: Both files contained menu/cursor triplet data regions (menu window stream + cursor position table + cursor sprite template) that were either unlabeled or had dead labels never referenced. Pointer constructions existed as raw lo/hi immediates (`LDA #$xx` / `STA zp` + `LDA #$yy` / `STA zp+1`) in the same file.

## Execution process
1. Built analysis tool ([tmp_lohi_ptr_scan.py](file:///home/zero/project/sango2dasm/tools/tmp_lohi_ptr_scan.py)): parsed .byte/.word regions with true byte lengths, captured @-labels and .proc scopes, detected pointer constructions (same-register LDA/LDA allowed), filtered to hot regions (unlabeled or unreferenced).
2. Identified 26 cases across both files: 3 in prg_19_1a (Confirm dialog triplet, Succession march confirm triplet, BG strip base) and 23 in prg_1b_1c (13 bare-global triplets, 9 @-local triplets, 3 warehouse rows split).
3. Applied transformations via [tmp_symbolize_lohi.py](file:///home/zero/project/sango2dasm/tools/tmp_symbolize_lohi.py): split concatenated rows (e.g., $B812 row → WarehouseCommandMenuStream/$B815/$B819), converted 138 raw immediates to `#<Label`/`#>Label`, fixed off-by-one comment ($B81A→$B819).
4. Verified byte-exact integrity: tools/verify_19_1a.py and verify_1b_1c.py reported "compared 16384 bytes, 0 mismatches" each.

## Related files
- asm/banks/prg_19_1a.asm
- asm/banks/prg_1b_1c.asm
- tools/tmp_lohi_ptr_scan.py (created)
- tools/tmp_symbolize_lohi.py (created)

## Notes
- fish shell limitation: no heredocs/process substitution — used `bash -c` wrapper for Python scripts.
- Region parsing bug: initial implementation treated each .byte line as 1 byte, hiding mid-row pointer targets; fixed by counting comma-separated items.
- Dead @-labels (@MarketMenuStream etc.) existed from prior passes but were never wired up; now symbolized.
- Left untouched: truly-unreferenced regions ($C000, $D425, $DE32-$DFFF in prg_19_1a; $BFFF/$C000, $C9E6-$C9EE in prg_1b_1c).

## Task overview
Completed: 26 cases fixed with 138 immediate conversions and 5 row splits across both banks; all changes verified byte-exact (0 mismatches). Naming followed project conventions: bare globals for cross-proc refs, @-locals for intra-proc scope.
