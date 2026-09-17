# CountryControlToggle $CD8C code analysis and ROM fact verification

- **Category:** task_summary_experience
- **Memory ID:** 24536ffa-689d-48e0-a496-a6a99de32be2
- **Keywords:** CountryControlToggle, $CD8C, ROM verification, inert switch, Start+A combo, controller bit order

## Content

## Task description
- Core requirement: Code analysis of prg_19_1a.asm at address $CD8C (CountryControlToggle region)
- Task background: Region bounded by StrategyRequestDispatch (ends $CD8B) and Loc_CE1F; called via RequestPoll JSR every tick in Strategy Mode sub-states 1-3; existing header claimed "$FFF9 reads $FF" and "Select held" which needed verification against shipped ROM.

## Execution process
1. Verified byte-exact baseline: tools/verify_19_1a.py passed with 0 mismatches (16384 bytes)
2. Discovered factual corrections via ROM analysis:
   - CPU $FFF9 (fixed bank $E000-$FFFF) reads $00 in shipped ROM, not $FF → arm gate always fails, switch is INERT unless patched
   - ControllerRead shifts buttons A,B,Select,Start into bits 0,1,2,3 respectively → $0083 bit 3 = Start held, not Select
   - Combo is Start held + A newly pressed ($0081 bit 0 edge), not Select+A
3. Refactored region $CD8C-$CE1E into `.proc CountryControlToggle` / `.endproc`
4. Symbolized branch targets: BNE/BEQ $CDDC → @Exit, BEQ $CDDD → @BackupAndTakeover
5. Rewrote header comment with corrected gates, inert-switch note, and two toggle paths (save-then-force-to-$03 vs restore-from-backup)
6. Synced caller annotation at line 5545 (RequestPoll JSR comment)
7. Verified final build: tools/verify_19_1a.py → 16384 bytes, 0 mismatches

## Related files
- asm/banks/prg_19_1a.asm

## Notes
- The $FFF9 check is a developer debug hook enabled only by patching that single byte to $FF; it's inert in the shipped ROM.
- Same controller-read evidence implies recurring "A or Start" comments elsewhere in the file are mislabeled (should be "A or B" since bit1=B).
- Country record field [3] == $03 semantics have competing interpretations in codebase ("player controlled" / "AI-controlled" / "dismissed") — not firmly established.

## Task overview
Completed: Wrapped CountryControlToggle in .proc with semantic locals, verified two factual corrections to prior header (inert switch, Start+A combo), rewrote header documentation, byte-exact verification passed with 0 mismatches.
