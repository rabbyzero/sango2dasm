# StrategyRequestDispatch $C773-$CD8B decoded in prg_19_1a.asm

- **Category:** task_summary_experience
- **Memory ID:** c9306e7c-6952-424c-93c1-f0b09beb8b62
- **Keywords:** StrategyRequestDispatch, $6F8B request mailbox, map frame state 9, inline dispatch table entry count, byte parity probe

## Content

## Goal
Decode the raw/mis-disassembled region at $C773 in asm/banks/prg_19_1a.asm and refactor it into semantic `.proc` form with byte-exact ROM parity.

## Steps
1. Fixed the region boundary first: the preceding bytes are two 30-entry camera tables (ProvinceCameraXTable $C737, ProvinceCameraYTable $C755) ending at $C772; $C773-$CD8B (1561 bytes) is one procedure; $CD8C starts a separate routine. Renamed/split the camera tables and symbolized their 6 reference sites so the boundary is explicit.
2. Traced the caller: prg_1b_1c MapScreenFrameStateDispatch state 9 -> LDY #$39 -> B1F_BankedCallbackTrampoline -> banks $19+$1A stub $A006 -> `JMP $C773`. Result: the region is the map screen's Strategy Mode playback state.
3. Decoded the inline `B1F_CallbackDispatcher` table. Byte-offset arithmetic ($C779 + N*2) proved **17 entries**, not 18 as first assumed; the wrong count produced an apparently unreachable handler, which was the tell.
4. Decoded each cross-bank trampoline target from its own `LDY` (Y & $1F): $3D->bank $1D, $3B->bank $1B, $2C->bank $0C.
5. Established the `$6F8B` request/acknowledge mailbox by grepping every `STA $6F8B` in prg_0a_0b/prg_08_09 and reading each requester's spin-wait condition.
6. Wrapped the whole region in one `.proc StrategyRequestDispatch` (no external references besides the $A006 stub), renamed the $A006 stub to `StrategyRequestDispatch_Entry`, and renamed the following `Loc_CD8C` to `CountryControlToggle`.

## Notes
- When a build fails with a `Range error` on a branch *downstream* of the edited region, the cause is a byte shortfall upstream. Build a standalone probe (`.org <region start>`, stub the few external symbols, link into a fixed-size region, byte-compare against the ROM slice) to localize it to a few bytes instead of guessing.
- The shortfall here was a real instruction `INC $040C` ($C815: EE 0C 04) hidden inside a legacy blob `.byte $42,$A0,$EE,$0C,$04`, i.e. trampoline-target word plus following code merged into data. It also changed semantics: the first poll tick does the card refresh and then arms the mailbox decode path.
- Two overlay-idle `BNE`s at $CD19/$CD20 target the handler's own trailing RTS ($CD45), not the shared prompt exit ($CCD7); only the button-check `BEQ` at $CD27 does. Verify every branch offset against the ROM byte rather than assuming a shared exit.
- A shared exit referenced from more than one handler must be a non-local inner label, because ca65 cheap-local `@label` scope is terminated by any non-cheap label.
- The verification harness's "external stubs" count can rise harmlessly when new comments contain text like `-> JMP $AA37:`, which its regex picks up in the temp file.
- fish rejects `python3 - <<'PY'` heredocs; write probe scripts to files under tools/ instead.

## Corrections (2026-09-08, CountryControlToggle $CD8C-$CE1E analysis)
- CountryControlToggle is now wrapped in `.proc CountryControlToggle` with @Exit/$CDDC and @BackupAndTakeover/$CDDD locals; verify_19_1a.py passes with 0 mismatches.
- The combo is **Start held + A newly pressed**, NOT Select+A: ControllerRead (prg_1f $E6C6) shifts buttons in standard order, so bit0=A, bit1=B, bit2=Select, bit3=Start (high nibble bit7 Right/bit6 Left/bit5 Down/bit4 Up). Any comment reading `$0083 AND #$08` as Select is wrong.
- Fixed-bank padding byte CPU $FFF9 (prg_1f.bin offset $1FF9) is **$00** in the shipped ROM, not $FF: the arm gate always fails and CountryControlToggle is INERT unless that byte is patched to $FF. The earlier header comment claiming it reads $FF was wrong.
- Country record field [3] semantics are not firmly established: $6F0A+stride8 slots verified, but meaning of $03 has competing interpretations in the codebase ("player controlled" / "AI-controlled" / "dismissed") — do not treat "player controlled" as settled.
