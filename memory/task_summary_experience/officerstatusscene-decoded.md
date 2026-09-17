# OfficerStatusScene decoded and style-aligned in prg_19_1a.asm

- **Category:** task_summary_experience
- **Memory ID:** ad84c284-2912-4608-9fd2-18ff2f86fea1
- **Keywords:** OfficerStatusScene, prg_19_1a, frame state 0D, succession handoff, 0507 packed countries, style alignment, byte-exact

## Content

## Task description
Code analysis of OfficerStatusScene ($AD81-$AEBF) in prg_19_1a.asm with style alignment to the fully-decoded ProvinceOfficerRosterDispatch format (header block, per-sub-state headers, @-locals, inline comments), byte-exact.

## Execution process
1. Verified semantics: OfficerStatusScene is map frame state $0D (entered from prg_1b_1c state $0D stub $A00C; armed by prg_0a_0b $DB11 ClearOverlayWait). Processes the two Countries packed in $0507 (low nibble = first processed, high = second; writers: prg_0a_0b $A887 ($6F03<<4 | prov[0]&7), prg_19_1a $B7FC/$B854). Sub 1/2 check each Country's Ruler Officer record status (record[$0B]&3): 3 = out of office -> arm $0470-$0473 and enter RulerSuccessionScene (sub 4). Sub 3 @StatusApply splits on Country control flag (($EE) byte[3]): $03 = player-controlled (CountryControlToggle $CD8C documents record[3]=$03=player) -> UI $BB + frame state 9 sub 1 RequestPoll + $6F8B mailbox reset; else $6F44 latch, fix home Province via FindOfficerProvince ($A1EB), camera, YearDisplaySetup, frame state 0.
2. Verified $0470-$0473 consumers: $0470 = RulerSuccessionScene resume sub-state (read at $C00A after SuccessionArrivalScan), $0471 = no-slot exit sub-state ($BE64), $0472/$0473 = final exit frame state/sub-state consumed by ScenarioHandoffPrep HandoffExit ($C423). Sub 1 arms $02/$06/$0D/$03 (exit back to @StatusApply); sub 2 arms $03/$06/$0B/$00 (exit frame state $0B = title/attract cycle).
3. Style edits: renamed Loc_A00C -> OfficerStatusScene_Entry; added 29-line proc header + per-sub-state header blocks; pointer table comments "sub N" -> "sub-state N"; intra-proc labels @-prefixed/renamed: @StatusDstSetup, @StatusApply, @NmiIdle (was Loc_ADB0), @ArmSuccessionHandoff (was StatusDstHandoff), @EnterSuccessionScene (was StatusDstPoll), @StatusApplyMapReturn (was @StatusApplyMarch); trampoline .word $A01E -> B1D_1E_YearDisplaySetup; JSR $A1EB -> FindOfficerProvince; inline semantic comments throughout.
4. Verified with tools/verify_19_1a.py: compared 16384 bytes, 0 mismatches.

## Notes
- Full make build has pre-existing duplicate-symbol baseline (prg_19_1a vs prg_1b_1c Loc_ labels); per-bank harness is the workflow.
- Read tool and Grep output can strip leading indentation of asm lines; verify exact whitespace with `sed | cat -A` before SearchReplace on this file.
- Shared sub-states 4-6 are the same procs as demo sub-states $C-$E of DemoEventPlaybackDispatch.
