# False trampoline target claims from stale scan data

- **Category:** common_pitfalls_experience
- **Memory ID:** e715a4b0-17a0-463f-8873-acf5b3c4ec4e
- **Keywords:** stale scan data, trampoline targets, ROM byte verification, bank $00, false positive

## Content

## Bug class: False trampoline target claims from stale scan data

## Root cause
The bank_switch_scan_raw.txt file was generated before an asm fix that corrected `LDY #$20` to `LDY #$28` at prg_0c_0d.asm:$A022. The stale scan recorded a phantom `$00+$01` code edge that never existed in the actual code.

## Fix pattern
Always verify bank-switch claims against actual ROM bytes when encountering unexpected target banks. Use `xxd -s <offset> -l <bytes>` on rom/prg/prg_XX.bin to confirm the actual instruction bytes (e.g., A0 28 = LDY #$28, not A0 20 = LDY #$20). Calculate effective_bank = Y & $1F and cross-check with functions.h entries.

## Reusable lesson
Don't trust stale scan files or old documentation for trampoline target claims without ROM byte verification because pre-existing fixes may have changed the actual Y values; instead always verify against rom/prg/prg_XX.bin using xxd/od commands. Applies when analyzing BankedCallbackTrampoline targets or any code using Y register for bank switching; does not apply to fresh scans generated from current asm files.
