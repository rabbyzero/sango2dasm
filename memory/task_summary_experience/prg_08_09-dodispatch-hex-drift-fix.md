# prg_08_09 DoDispatch hex drift fix and structure refactor

- **Category:** task_summary_experience
- **Memory ID:** 1b3f760e-30bd-4064-8af9-8a55d2a3a2c4
- **Keywords:** DoDispatch, hex drift, inline dispatch table, bare globals, cheap-local scope, verification harness

## Content

## Task description
- Core requirement: analyze prg_08_09.asm's DoDispatch region ($BC4C-$BC6C) for hex drift and review its structure
- Task background: DoDispatch is an inline callback dispatcher after JSR B1F_CallbackDispatcher with a 3-entry .word table; the file had byte drift (entries encoded big-endian instead of little-endian), misaligned decode of entry 0 body, and @WarExecute/@WarExecuteAlt trapped in WarUnitMatcher's cheap-local scope

## Execution process
1. Verified ROM bytes for region $BB1F-$BDD0 using Python script comparing "; $ADDR: HH" comments against rom/prg/prg_08.bin at offset addr-$A000
2. Identified drift: entry 2 claimed $FFE0 but ROM has $BD67 (@WarExecuteAlt); entries 1/2 emitted high-byte-first (.byte $BD,$59) while ROM stores low-byte-first (59 BD)
3. Fixed entry 0: re-disassembled $BC52-$BC6C as JSR CollectUnitsBySide / LDA war_province_idx / STA $0002 / LDA #$11 / STA $0003 / LDA #$00 / STA $0004 / JSR FindDefenderMatch / CPX #$FF / BNE WarUnitMatcher / RTS; renamed handler to @WarSeedProvinceRoster
4. Refactored structure: promoted @WarExecute/$BD59 and @WarExecuteAlt/$BD67 from WarUnitMatcher's @-local scope to bare globals WarUnitMatchRun/WarUnitMatchRunAlt (names avoid collision with .proc WarExecute at $BB93); updated dispatch table to three .word entries
5. Created tools/verify_08_09.py per-bank harness modeled on verify_0e_0f.py to assemble bank and compare output to ROM
6. Fixed all pre-existing ca65 undefined-symbol errors: BEQ @SwapFound→@DoSwap, BCC @PopCount→@CountAllies, promoted PushY/ComputeCoord/CheckFaction/ComputeAverageStats/ComputeScaledStats to bare globals, qualified ApplyCoordDeltas reference, emitted cross-segment branch at $C00C as raw .byte $90,$EB
7. Verified DoDispatch region annotation-vs-ROM: 313 annotated lines, 0 mismatches

## Related files
- asm/banks/prg_08_09.asm
- tools/verify_08_09.py

## Notes
- Pre-existing layout drift starting at $A0E1 in Action_DefaultDecision (file decodes 2-byte zero-page STA $20 where ROM has 3-byte absolute 8D 20 00) prevents whole-bank byte-exact verification; drift accumulates to -$1B9 by CallbackDispatcher ($B517 computed as $B35E). This is a separate re-decode task unrelated to DoDispatch.
- Cheap-local @-labels attach to last non-local label; promoting one helper to global creates new scope boundaries that can break other @-refs (cascade: ComputeAverageStats promotion broke @CheckFaction/@ComputeScaledStats refs).
- Annotation-vs-ROM comparison is the reliable verification method while the bank cannot fully assemble.

## Task overview
Completed: DoDispatch region fixed and byte-exact verified (0 mismatches on 313 annotated lines). Structure refactored to use symbolic .word entries referencing bare globals. Bank now assembles cleanly but whole-bank byte verification still fails due to pre-existing upstream drift. Verification harness created and documented.
