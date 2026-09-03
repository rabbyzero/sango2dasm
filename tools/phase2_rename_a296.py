#!/usr/bin/env python3
"""Phase 2: semantic renaming + .proc wrapping for the $A296-$C434
DemoEventPlayback region in prg_19_1a.asm.

- Renames Loc_XXXX labels per RENAME (whole-word).
- Converts raw JSR/JMP/branch $XXXX operands whose target is in RENAME
  to symbolic references. Leaves .word data bytes untouched.
- Wraps self-contained sub-state machines into .proc/.endproc blocks.
Cross-machine JSR helpers (ClampStatPair, ProvincePickListBuild,
ProvinceTroopDeduct, ProvinceTroopSubtract, DirtyMarkAndCard,
RosterSwapFirst, SuccessionOfficerTable) stay as bare globals because
ca65 forbids plain cross-proc references to proc-internal labels.
"""
import re

ASM = "asm/banks/prg_19_1a.asm"
src = open(ASM).read()

RENAME = {
    "A009": "DemoEventPlaybackDispatch_Entry",
    "A296": "DemoEventPlaybackDispatch",
    "A2BC": "PlaybackPaceGate",
    "A2D9": "PaceGateDone",
    "A2DA": "PaceCheckTroopStep",
    "A2EF": "PaceCheckGoldStep",
    "A301": "PaceRouteAnnual",
    "A30C": "PlaybackStepRoute",
    "A317": "StepRouteDamage",
    "A322": "StepRouteLossCheck",
    "A32D": "StepRouteLoss",
    "A338": "StepRouteAdvance",
    "A33C": "PlaybackSeverityArm",
    "A34D": "SeverityTierWrite",
    "A35F": "SeverityArmAdvance",
    "A389": "PlaybackRulerLoad",
    "A39B": "PlaybackRulerSplit",
    "A3E1": "RulerSplitAdvance",
    "A363": "PlaybackExitRoute",
    "A37B": "PlaybackExitDemo",
    "A3E5": "ProvinceTroopRecount",
    "A3F1": "TroopRecountWindow",
    "A404": "TroopRecountOverlayWait",
    "A420": "TroopRecountApply",
    "A429": "TroopRecountScan",
    "A42B": "TroopRecountScanLoop",
    "A4D3": "TroopRecountTierCap",
    "A523": "TroopRecountScanDone",
    "A52A": "ClampStatPair",
    "A53F": "ClampStatPairDone",
    "A524": "TroopRecountFactorTable",
    "A5AA": "ProvinceGoldRecount",
    "A5B6": "GoldRecountWindow",
    "A5C9": "GoldRecountOverlayWait",
    "A5E5": "GoldRecountApply",
    "A5EE": "GoldRecountScan",
    "A5F0": "GoldRecountScanLoop",
    "A698": "GoldRecountTierCap",
    "A6E8": "GoldRecountScanDone",
    "A6E9": "GoldRecountFactorTable",
    "A6EF": "WarDamageScene",
    "A6FD": "DamageListBuild",
    "A70D": "DamageWindowOpen",
    "A720": "DamageOverlayWait",
    "A741": "DamageProvincePoll",
    "A74B": "DamageListAdvance",
    "A763": "DamageProvinceApply",
    "A789": "DamageTroopDeduct",
    "A7DF": "DamageRosterScan",
    "A814": "DamageRosterNext",
    "A81B": "DamageCountryCheck",
    "A82D": "DamageMarkerArm",
    "A85F": "DamageCardRedraw",
    "A886": "DamageCardWait",
    "A895": "DamageCardWaitExit",
    "A896": "ProvincePickListBuild",
    "A89A": "ProvincePickFillLoop",
    "A8A5": "ProvincePickRoll",
    "A8B9": "ProvincePickSkip",
    "A8C0": "ProvincePickTableA",
    "A8D0": "ProvincePickTableB",
    "A8E0": "ProvinceTroopDeduct",
    "A910": "TroopDeductTierSel",
    "A91A": "TroopDeductRandLoop",
    "A929": "TroopDeductRandStore",
    "A936": "TroopDeductRosterPtr",
    "A93E": "ProvinceTroopSubtract",
    "A974": "TroopSubtractApply",
    "A985": "DirtyMarkAndCard",
    "A9A0": "TroopLossScene",
    "A9AE": "LossListBuild",
    "A9BE": "LossWindowShow",
    "A9D1": "LossWindowOpen",
    "A9F2": "LossProvincePoll",
    "A9FC": "LossListAdvance",
    "AA14": "LossProvinceApply",
    "AA3A": "LossTroopDeduct",
    "AA9A": "LossCountryCheck",
    "AAAC": "LossMarkerArm",
    "AADE": "LossCardRedraw",
    "AB05": "LossScreenAdvance",
    "AB15": "AnnualProvinceEvent",
    "AB25": "AnnualEventGate",
    "AB39": "AnnualListBuild",
    "AB47": "AnnualProvinceLoop",
    "AB60": "AnnualProvinceNext",
    "AB6E": "AnnualTakeoverCheck",
    "AB8A": "AnnualTierSel",
    "AB9A": "AnnualTakeoverMark",
    "ABA9": "AnnualProvincePoll",
    "ABB1": "AnnualPollAdvance",
    "ABC9": "AnnualProvinceHit",
    "AC4D": "AnnualOverlayWait",
    "AC72": "AnnualOverlayAck",
    "AC9A": "AnnualOverlayWait2",
    "ACBD": "AnnualExitCheck",
    "ACCD": "AnnualGoldDec",
    "ACE9": "AnnualTroopDec",
    "AD14": "AnnualFoodDec",
    "AD3F": "StatPairSubtract",
    "AD81": "OfficerStatusScene",
    "AD95": "StatusSceneInit",
    "ADAA": "StatusSrcSetup",
    "AE0D": "StatusDstSetup",
    "ADD9": "StatusAdvance",
    "ADDD": "StatusDstHandoff",
    "ADF1": "StatusDstPoll",
    "AE4D": "StatusDstAdvance",
    "AE51": "StatusApply",
    "AE8B": "StatusApplyMarch",
    "AEC0": "OfficerReinforceScene",
    "AECE": "ReinforceScan",
    "AF19": "ReinforceScanFail",
    "AF1F": "ReinforceRosterInsert",
    "AF74": "ReinforceOverlayWait",
    "AF8B": "ReinforceCardWait",
    "AFB8": "ReinforceCardShow",
    "AFE4": "ReinforceExit",
    "BC80": "OfficerRemovalScene",
    "BC8C": "RemovalScanInit",
    "BC95": "RemovalProvinceScan",
    "BD28": "RemovalChanceRoll",
    "BD5B": "RemovalKill",
    "BD60": "RemovalChanceTable",
    "BD67": "RemovalOverlayWait",
    "BD86": "ProvinceRosterCompact",
    "BDBB": "OfficerKill",
    "BE01": "RulerSuccessionScene",
    "BE17": "SuccessionNotice",
    "BE2E": "SuccessionFindSlot",
    "BE83": "SuccessionPickProvince",
    "BED1": "SuccessionTransferGate",
    "BEFD": "SuccessionMarchSetup",
    "BF2F": "SuccessionMarchAnim",
    "BFB9": "SuccessionArrivalScan",
    "BFFE": "ArrivalScanFound",
    "C01E": "SuccessionArrivalApply",
    "C075": "ArrivalRosterAdvance",
    "C091": "ArrivalShiftRoster",
    "C0E5": "SuccessionApplyWait",
    "C101": "RosterSwapFirst",
    "C342": "SuccessionOfficerTable",
    "C132": "OfficerReassessScene",
    "C144": "ReassessInit",
    "C158": "ReassessListScan",
    "C1A1": "ProvinceOfOfficerFind",
    "C1DB": "ReassessStrongestScan",
    "C211": "ReassessNoneExit",
    "C21D": "StrongestOfficerFind",
    "C25D": "ReassessAnnounce",
    "C280": "ReassessDelay",
    "C289": "ReassessApply",
    "C28E": "ReassessBoostAndExit",
    "C2A6": "ReassessRosterScan",
    "C301": "ReassessScanNext",
    "C318": "ArrivalRosterShift",
    "C37A": "ScenarioHandoffPrep",
    "C386": "HandoffParamLoad",
    "C3B7": "HandoffParamAdvance",
    "C3BB": "HandoffParamTable",
    "C3C2": "HandoffSentinelWait",
    "C3DA": "HandoffWaitExit",
    "C41E": "HandoffExit",
}

for old, new in RENAME.items():
    src = re.sub(r"\bLoc_%s\b" % old, new, src)
for old, new in RENAME.items():
    src = re.sub(r"((?:JSR|JMP|BCC|BCS|BEQ|BNE|BMI|BPL|BVC|BVS)\s+)\$%s\b"
                 % old, r"\1%s" % new, src)

# .proc wrapping: (start label, endproc anchor line prefix)
PROCS = [
    ("DemoEventPlaybackDispatch", "ProvinceTroopRecount:"),
    ("ProvinceTroopRecount",      "ClampStatPair:"),
    ("ProvinceGoldRecount",       "WarDamageScene:"),
    ("WarDamageScene",            "ProvincePickListBuild:"),
    ("TroopLossScene",            "AnnualProvinceEvent:"),
    ("AnnualProvinceEvent",       "OfficerStatusScene:"),
    ("OfficerStatusScene",        "OfficerReinforceScene:"),
    ("OfficerReinforceScene",     "; $AFE5: ProvinceOfficerRosterDispatch"),
    ("OfficerRemovalScene",       "RulerSuccessionScene:"),
    ("RulerSuccessionScene",      "RosterSwapFirst:"),
    ("OfficerReassessScene",      "SuccessionOfficerTable:"),
    ("ScenarioHandoffPrep",       "Loc_C435:"),
]

lines = src.split("\n")

def find_idx(prefix):
    for i, ln in enumerate(lines):
        if ln.startswith(prefix):
            return i
    raise SystemExit("anchor not found: %r" % prefix)

# insert .endproc blocks bottom-up so indices stay valid
ends = sorted(((find_idx(anchor), name) for name, anchor in PROCS),
              reverse=True)
for end_idx, _ in ends:
    lines.insert(end_idx, ".endproc")
    lines.insert(end_idx + 1, "")

# convert each proc start label line into a .proc directive
for name, _ in PROCS:
    i = find_idx(name + ":")
    lines[i] = ".proc " + name

open(ASM, "w").write("\n".join(lines))
print("phase 2 applied: %d renames, %d procs" % (len(RENAME), len(PROCS)))
