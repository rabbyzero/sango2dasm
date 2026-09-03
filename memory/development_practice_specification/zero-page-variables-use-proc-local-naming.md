# Zero-page variables use proc-local naming

- **Category:** development_practice_specification
- **Memory ID:** 544e1c16-5e23-4f1b-8813-07107cf60655
- **Keywords:** zero-page, proc-local, semantic naming, assembly refactoring
- **Usage scenarios:**
  - Refactoring zero-page operand references in assembly code
  - Designing semantic names for shared memory locations
  - Converting global scratch variables to local context-specific names

## Content

The zero-page addresses $0000-$001C in prg_0e_0f.asm are no longer defined as global equates. Instead, each procedure uses locally-scoped semantic names based on the specific role of each cell within that function. This approach allows the same address to have different meaningful names in different contexts (e.g., $0000 as 'damage' in one proc, 'total_a_lo' in another). Per-line overrides are used when a cell's role changes within a single procedure. The refactoring is driven by a per-function manifest (zp_localize_manifest.json) and applied with a scope-limited tool (zp_localize.py), not a universal replacement script.
