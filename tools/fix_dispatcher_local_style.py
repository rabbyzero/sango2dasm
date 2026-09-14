#!/usr/bin/env python3
"""Convert bare-global labels that are B1F_CallbackDispatcher targets defined
inside their own proc to @-local style (prg_19_1a.asm).

Renames every non-comment occurrence of the label within the defining proc:
table .word entries, `Name:` definitions, and in-proc code references.
Comment-only mentions are left untouched. Cross-proc / cross-file references
were validated by tools/check_dispatcher_ref_safety.py.
"""
import re

PATH = "asm/banks/prg_19_1a.asm"
src = open(PATH).read()
lines = src.splitlines()

# proc ranges (1-based inclusive)
proc_ranges, cur = [], None
for i, ln in enumerate(lines, 1):
    m = re.match(r"\.proc\s+(\S+)", ln)
    if m:
        cur = (i, m.group(1))
    elif ln.strip().startswith(".endproc") and cur:
        proc_ranges.append((cur[0], i, cur[1])); cur = None
proc_span = {}
for s, e, n in proc_ranges:
    proc_span[n] = (s, e)

CANDIDATES = {
    "AttractDemoDispatch": ["CountrySelect", "OverlayInit", "OverlayPoll", "ResetCheck"],
    "ProvinceGoldRecount": ["GoldRecountApply"],
    "WarDamageScene": ["DamageProvincePoll", "DamageCardRedraw"],
    "TroopLossScene": ["LossProvincePoll", "LossCardRedraw"],
    "AnnualProvinceEvent": ["AnnualProvincePoll", "AnnualOverlayWait", "AnnualOverlayWait2", "AnnualExitCheck"],
    "OfficerReinforceScene": ["ReinforceOverlayWait", "ReinforceCardWait", "ReinforceCardShow"],
    "ProvinceOfficerRosterDispatch": ["CardAnimWait", "RosterScroll"],
    "CardFillDispatch": ["BaseKanaCopy", "FlagStatDigitsFill", "PortraitLevelTiles",
                         "PortraitAndStatsFill", "NamePlateUpper", "NamePlateLower"],
    "OfficerRemovalScene": ["RemovalProvinceScan", "RemovalOverlayWait"],
    "RulerSuccessionScene": ["SuccessionPickProvince", "SuccessionTransferGate", "SuccessionMarchAnim",
                             "SuccessionArrivalScan", "SuccessionArrivalApply", "SuccessionApplyWait"],
    "OfficerReassessScene": ["ReassessListScan", "ReassessStrongestScan", "ReassessAnnounce",
                             "ReassessDelay", "ReassessApply"],
    "ScenarioHandoffPrep": ["HandoffExit"],
    "StrategyRequestDispatch": ["RulerPanelOpen", "RequestPoll", "WarMenuCloseWait", "ArmyDeploySceneTrigger",
                                "PostWarRulerMenu", "PostWarPairedRulerMenu", "WarPhaseHandoff",
                                "NoticeDelayWait", "RulerPanelAck", "SweepOfficerPrompt",
                                "AbsorbOfficerPrompt", "TransferConfirmPrompt", "SweepPromptShow",
                                "SweepPromptAck", "AbsorbPromptShow", "AbsorbPromptAck",
                                "TransferPromptShow", "TransferPromptChoose", "TransferPromptWait"],
}

# collision guard: no existing @<name> local in the target proc
existing_locals = set()
for i, ln in enumerate(lines, 1):
    m = re.match(r"^\s*@([A-Za-z0-9_]+):", ln)
    if m:
        for s, e, n in proc_ranges:
            if s <= i <= e:
                existing_locals.add((n, m.group(1)))
for proc, names in CANDIDATES.items():
    for name in names:
        if (proc, name) in existing_locals:
            raise SystemExit(f"COLLISION: @{name} already exists in {proc}")

changed = 0
for proc, names in CANDIDATES.items():
    s, e = proc_span[proc]
    for name in names:
        pat = re.compile(r"(?<![\w@])" + re.escape(name) + r"(?![\w@])")
        count = 0
        for i in range(s, e + 1):
            ln = lines[i - 1]
            code, sep, comment = ln.partition(";")
            new_code, n = pat.subn("@" + name, code)
            if n:
                lines[i - 1] = new_code + sep + comment
                count += n
        if count < 2:  # at minimum: table entry + definition
            print(f"WARN {proc}:{name} only {count} replacements")
        changed += count
        print(f"{proc}: {name} -> @{name}  ({count} refs)")

open(PATH, "w").write("\n".join(lines) + "\n")
print(f"\ntotal replacements: {changed}")
