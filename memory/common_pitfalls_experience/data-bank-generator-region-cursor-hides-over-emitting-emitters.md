# Data-bank generator region cursor hides over-emitting emitters

- **Category:** common_pitfalls_experience
- **Memory ID:** 0c76a0bd-6eca-4e12-96b4-b980e469c0aa
- **Keywords:** gen_data_bank_asm region overflow, render_bank declared length, unclamped chunk slice, check_bank_tiling tool, seed data bank verify

## Content

Bug class: a generated seed-data bank overflows its 8KB window (`ld65: Segment
'CODE_BANK10' overflows memory area 'BANK10' by N bytes`) even though the edit
only touched comment text.

Root cause: `tools/gen_data_bank_asm.py` `render_bank()` advances
`cursor = start + length` using each region's DECLARED length from
`bank_regions()`, never the number of bytes the emitter actually appended. An
emitter that over- or under-emits is therefore invisible to the renderer; the
surplus silently shifts every later region and only the linker notices. Concrete
case: `emit_province_trade()`'s last 8-entry chunk sliced
`data[base + n*2 : base + (n+8)*2]` with `PROV_COUNT = 30`, so the final `.word`
line emitted 8 words (16 bytes) instead of 6 (12) and duplicated the first 4
bytes of `ProvinceFlagTable`.

Fix pattern: clamp the last chunk (`last = min(n + 8, PROV_COUNT)`, slice to
`last * 2`), exactly as the flag loop below it already did, then regenerate.

Reusable lesson: after ANY change to `gen_data_bank_asm.py`, run
`python3 tools/check_bank_tiling.py` (added for this) plus
`tools/verify_data_banks.py --bank all`. `check_bank_tiling.py` walks the emitted
address comments and reports the first line where the byte stream and the comment
disagree, which localises the offending emitter instead of merely reporting an
overflow size. Applies to any generator whose region cursor is driven by declared
sizes rather than by emitted bytes.
