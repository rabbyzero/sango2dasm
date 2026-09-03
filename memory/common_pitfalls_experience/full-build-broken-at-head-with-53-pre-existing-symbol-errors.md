# Full build broken at HEAD with 53 pre-existing symbol errors

- **Category:** common_pitfalls_experience
- **Memory ID:** 8ff99533-cb61-4fc4-a375-4f6bae09aa13
- **Keywords:** pre-existing build failure, duplicate symbol errors, standalone harness verification, error list diff
- **Usage scenarios:**
  - Diagnosing make or ca65 build failures
  - Verifying bank changes without working full build
  - Assessing regression of assembly errors

## Content

Bug class: `make` (full-tree ca65) fails with 53 pre-existing errors at HEAD d74639e, unrelated to new bank work.
Root cause: duplicate cheap @-labels and file-scope equates inside prg_0a_0b.asm (e.g. @EntityLoop, math_acc_lo defined twice), duplicate equates across prg_17_18.asm vs prg_0c_0d.asm/prg_0a_0b.asm (anim_ppu_ptr_lo/hi, map_scroll_ptr_lo/hi, sram_game_start_flag), and prg_17_18.asm additionally has an unclosed .proc AdvanceSrcPtr; stale tracked build/main.o (3910 bytes, Jul 30) masks the broken state.
Fix pattern: verify a new/edited bank with a standalone ca65+ld65 harness (.org at bank bases, compare output against rom/prg binaries) instead of relying on `make verify`; to prove no regressions, diff sorted ca65 error lists between a HEAD git worktree and the working tree.
Reusable lesson: always check whether the baseline build passes before attributing failures to your change; if it already fails, isolate your verification from the broken files. Applies while those 53 errors remain unfixed; re-check after they are repaired.
