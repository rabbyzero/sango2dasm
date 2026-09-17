# Phase 7 side B formation-select decoded in prg_0e_0f.asm ($CF67-$D066)

- **Category:** task_summary_experience
- **Memory ID:** d773365a-01ae-413c-8570-8e81d19cf894
- **Keywords:** phase 7 handler, formation select side B, resume latch 7/4, trampoline target word, byte parity

## Content

Phase 7 (side B pre-battle formation select) decoded in prg_0e_0f.asm $CF67-$D066, replacing raw .byte code. Procs: Phase7FormationSelectSubDispatch ($CF67, 5-entry inline table on $0541), Phase7FormationPanelInit ($CF77: random formation seed into $056D, input mode $0563==3 AI jumps straight to battle start, clears anim id/slot $0310/$0300, resets menu cursor $0424/$0425), Phase7FormationPanelOpen ($CF9D: anim-idle gate, UI panel $D4, B1D_1E_OfficerDisplay_Render via trampoline with buffer $0561, params $00BB=9/$00BC=$7D), Phase7FormationMenuInput ($CFC2: bank-$19 strip render, FormationSelectMenu with Y=1, selected item to $056D, on A: panel $D2 + country $0565 ruler id to $042C), Phase7FormationConfirmWait ($D008: prompt draw, on A: phase 3 handoff acting side $0549=1 with resume latch $054B/$054C=7/4), Phase7BattleModeStart ($D054: phase/sub 0/1, clear $0548, BattleRosterSetup). Key gotcha: trampoline target words ($CFB5/$CFD4/$D01A) look like data but belong to preceding JSR $EE07; byte $D005 is 8D 2C 04 = STA $042C (not $0424). Verified byte-exact via tools/verify_0e_0f.py (16384 bytes, 0 mismatches).
