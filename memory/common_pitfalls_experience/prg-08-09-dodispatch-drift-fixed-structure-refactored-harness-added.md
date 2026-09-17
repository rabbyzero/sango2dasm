# prg_08_09 DoDispatch drift fixed, structure refactored, harness added

- **Category:** common_pitfalls_experience
- **Memory ID:** 5a382388-8286-4674-b27e-928619328f34
- **Keywords:** prg_08_09, byte drift, inline dispatch table, DoDispatch, WarUnitMatchRun, cheap-local scope, verify_08_09 harness

## Content

## Bug class
Pre-existing byte drift in prg_08_09.asm inline-dispatch region $BC4C-$BC6C (DoDispatch after JSR B1F_CallbackDispatcher at $BC49). FIXED and region-verified 2026-09-09; structure also refactored same day.

## Root cause
The file encoded dispatch entries 1/2 as big-endian `.byte $BD,$59` / `.byte $FF,$E0` while ROM stores little-endian words ($BC4E: 59 BD = $BD59; $BC50: 67 BD = $BD67 = @WarExecuteAlt, not $FFE0). The entry-0 body was misdecoded one byte late: ROM has JSR CollectUnitsBySide ($BDCD) at $BC52, then LDA $050E / STA $0002 / LDA #$11 / STA $0003 / LDA #$00 / STA $0004 / JSR FindDefenderMatch ($BD96) / CPX #$FF / BNE WarUnitMatcher ($BC6D) / RTS.

## Fix pattern (applied)
Entry 0 renamed @WarSeedProvinceRoster (DoDispatch-scope @-local), re-disassembled correctly, falls through into WarUnitMatcher on match. Entries 1/2 promoted from @WarExecute/@WarExecuteAlt (trapped in WarUnitMatcher's cheap-local scope) to bare globals WarUnitMatchRun ($BD59) / WarUnitMatchRunAlt ($BD67) — names avoid collision with .proc WarExecute ($BB93 phase handler) — and the table now uses three .word entries, all little-endian.

## Structure-review companion fixes (same session)
Bank never assembled at HEAD. Fixed all ca65 undefined-symbol errors: BEQ @SwapFound→@DoSwap ($BC28); BCC @PopCount→@CountAllies ($BEF7); promoted cheap-local helpers to bare globals PushY/ComputeCoord ($BFB3/$BFB5), CheckFaction ($CC92, dup of AiCheckFaction), ComputeAverageStats ($CCAA), ComputeScaledStats ($CD00); JSR ApplyCoordDeltas from .proc WarExecute uses qualified WarPhaseProcess::UpdateOfficerCoords::ApplyCoordDeltas; cross-segment branch at $C00C emitted as raw .byte $90,$EB (precedent: prg_1d_1e.asm $BFF6).

## Remaining known issue
Whole-bank byte verification (tools/verify_08_09.py, modeled on verify_0e_0f.py) now ASSEMBLES cleanly but shows 15101/16384 byte mismatches from pre-existing layout drift starting $A0E1 in Action_DefaultDecision: file decodes 2-byte zero-page STA $20 where ROM has 3-byte absolute 8D 20 00; drift accumulates to -$1B9 by CallbackDispatcher ($B517 computed as $B35E). DoDispatch region itself is annotation-verified byte-exact.

## Reusable lesson
B1F_CallbackDispatcher ($EADE) reads its inline table low-byte-first; every entry must be little-endian. ca65 cheap-local @-labels attach to the last non-local label — promoting one helper to a bare global creates a new scope boundary that can break other @-refs (cascade: ComputeAverageStats promotion broke @CheckFaction/@ComputeScaledStats refs). Annotation-vs-ROM comparison (verify "; $ADDR: HH HH" comments against bank binaries at offset addr-$A000) is the reliable check while the bank cannot fully assemble.
