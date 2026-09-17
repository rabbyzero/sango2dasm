# IntrigueCommandDispatch (frame state 6) decoded and renamed in prg_1b_1c.asm

- **Category:** task_summary_experience
- **Memory ID:** 6ca9ae95-a504-4443-87d7-3c27872c0073
- **Keywords:** IntrigueCommandDispatch, frame state 6, alliance nibble, AllianceGiftDialog, misclassified code, GoodsSendApply

## Content

## Task
Code analysis of prg_1b_1c.asm Loc_CADF ($CADF-$D2D5, map frame state 6) with label-style conversion to @-locals; naming per terminology.md and docs/manual_kb/04-strategy-commands.md.

## Result
- Identified state 6 as the 策略 Intrigue (strategy-commands pp.22-23) command screen, entered from castle command 4. Renamed Loc_CADF -> IntrigueCommandDispatch (.proc) with an 18-entry @-scoped sub-state table: 0 @MenuScreenInput, 1 @AllianceRulerListBuild, 2 @AllianceRulerSelect, 3 @AllianceAnimWait, 4 @AllianceConfirmGate, 5 @AllianceDialogCloseWait, 6 @AllianceDissolveGate, 7 @PoachProvincePrep, 8 @TargetProvincePick, 9 @TargetOfficerSelect, 10 @CommandConfirmGate, 11 @CommandExecute, 12 @ResultRedrawGate, 13 @ResultRoute, 14 @MessageWaitRoute, 15 @CardOpenWait, 16 @CardCloseRoute, 17 @AllianceGiftDialog.
- Key semantics decoded: country record byte[0]=ruler ($FF dead), byte[3]=status, +$04-$07 = one alliance-state nibble per country (even id low nibble); $0473 gate values 1=ruler-card alliance, 2=poach transfer, 3=AllianceGiftDialog, $80/$81/$FF message variants; $6F44 = alliance-formed toggle; $D0D0-$D0DA is an unreferenced alternate tail (message $4D).
- Fixed misclassified code-as-data regions $D23C-$D27A and $D294-$D2C6 (were .byte); trampoline inline .words now use B19_1A_GoodsSendPrepare ($A027), B19_1A_GoodsSendApply ($A030), B1D_1E_OfficerDisplay_Lookup ($A02A), B1D_1E_ImmediateOverlay ($A024), B19_1A_StrategyRequestDispatch ($A006).
- Wrapped helpers as .procs: PoachOddsCalc ($D2E3, loyalty-tier table), DiscordLoyaltyDropCalc ($D3C5), PoachRosterTransfer ($D41B), AllianceListRowRender ($D472), AllianceStateGet ($D4ED), AllianceStateSet ($D508), MapCursorArrowDraw ($D543, uses B1F_SpriteOamWriterSimple), ProvinceOfficerCount ($DC6B), CountryProvinceCount ($DDBF).

## Verification
tools/verify_1b_1c.py: "compared 16384 bytes, 0 mismatches" after fixing three branch targets ($D142/$D14C/$D192 branch into the shared @MsgCardClose tail at $D183, not sub-local exits) and restoring the @AnimBusyExit label on the stray RTS padding byte at $CD88.

## Notes
ProvinceOfficerCount and CountryProvinceCount are shared with castle/army dispatches (other call sites keep raw JSR $DC6B/$DDBF).
