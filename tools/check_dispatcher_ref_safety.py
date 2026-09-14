#!/usr/bin/env python3
"""Check reference safety for bare-label -> @-local conversion candidates
in prg_19_1a.asm B1F_CallbackDispatcher tables.

A candidate is convertible only if EVERY reference (definition + uses) in the
whole repo is inside the defining proc.
"""
import re, glob

TARGET = "asm/banks/prg_19_1a.asm"
CANDIDATES = [
    ("AttractDemoDispatch", "CountrySelect"), ("AttractDemoDispatch", "OverlayInit"),
    ("AttractDemoDispatch", "OverlayPoll"), ("AttractDemoDispatch", "ResetCheck"),
    ("ProvinceGoldRecount", "GoldRecountApply"),
    ("WarDamageScene", "DamageProvincePoll"), ("WarDamageScene", "DamageCardRedraw"),
    ("TroopLossScene", "LossProvincePoll"), ("TroopLossScene", "LossCardRedraw"),
    ("AnnualProvinceEvent", "AnnualProvincePoll"), ("AnnualProvinceEvent", "AnnualOverlayWait"),
    ("AnnualProvinceEvent", "AnnualOverlayWait2"), ("AnnualProvinceEvent", "AnnualExitCheck"),
    ("OfficerReinforceScene", "ReinforceOverlayWait"), ("OfficerReinforceScene", "ReinforceCardWait"),
    ("OfficerReinforceScene", "ReinforceCardShow"),
    ("ProvinceOfficerRosterDispatch", "CardAnimWait"), ("ProvinceOfficerRosterDispatch", "RosterScroll"),
    ("CardFillDispatch", "BaseKanaCopy"), ("CardFillDispatch", "FlagStatDigitsFill"),
    ("CardFillDispatch", "PortraitLevelTiles"), ("CardFillDispatch", "PortraitAndStatsFill"),
    ("CardFillDispatch", "NamePlateUpper"), ("CardFillDispatch", "NamePlateLower"),
    ("OfficerRemovalScene", "RemovalProvinceScan"), ("OfficerRemovalScene", "RemovalOverlayWait"),
    ("RulerSuccessionScene", "SuccessionPickProvince"), ("RulerSuccessionScene", "SuccessionTransferGate"),
    ("RulerSuccessionScene", "SuccessionMarchAnim"), ("RulerSuccessionScene", "SuccessionArrivalScan"),
    ("RulerSuccessionScene", "SuccessionArrivalApply"), ("RulerSuccessionScene", "SuccessionApplyWait"),
    ("OfficerReassessScene", "ReassessListScan"), ("OfficerReassessScene", "ReassessStrongestScan"),
    ("OfficerReassessScene", "ReassessAnnounce"), ("OfficerReassessScene", "ReassessDelay"),
    ("OfficerReassessScene", "ReassessApply"),
    ("ScenarioHandoffPrep", "HandoffExit"),
    ("StrategyRequestDispatch", "RulerPanelOpen"), ("StrategyRequestDispatch", "RequestPoll"),
    ("StrategyRequestDispatch", "WarMenuCloseWait"), ("StrategyRequestDispatch", "ArmyDeploySceneTrigger"),
    ("StrategyRequestDispatch", "PostWarRulerMenu"), ("StrategyRequestDispatch", "PostWarPairedRulerMenu"),
    ("StrategyRequestDispatch", "WarPhaseHandoff"), ("StrategyRequestDispatch", "NoticeDelayWait"),
    ("StrategyRequestDispatch", "RulerPanelAck"), ("StrategyRequestDispatch", "SweepOfficerPrompt"),
    ("StrategyRequestDispatch", "AbsorbOfficerPrompt"), ("StrategyRequestDispatch", "TransferConfirmPrompt"),
    ("StrategyRequestDispatch", "SweepPromptShow"), ("StrategyRequestDispatch", "SweepPromptAck"),
    ("StrategyRequestDispatch", "AbsorbPromptShow"), ("StrategyRequestDispatch", "AbsorbPromptAck"),
    ("StrategyRequestDispatch", "TransferPromptShow"), ("StrategyRequestDispatch", "TransferPromptChoose"),
    ("StrategyRequestDispatch", "TransferPromptWait"),
]

# build proc ranges for target file
lines = open(TARGET).read().splitlines()
proc_ranges, cur = [], None
for i, ln in enumerate(lines, 1):
    m = re.match(r"\.proc\s+(\S+)", ln)
    if m:
        cur = (i, m.group(1))
    elif ln.strip().startswith(".endproc") and cur:
        proc_ranges.append((cur[0], i, cur[1])); cur = None

def proc_of(n):
    for s, e, name in proc_ranges:
        if s <= n <= e:
            return name
    return None

# scan all asm/include files for references
files = sorted(glob.glob("asm/**/*.asm", recursive=True) + glob.glob("include/*"))
defining_proc = {c[1]: c[0] for c in CANDIDATES}

refs = {c[1]: [] for c in CANDIDATES}
for f in files:
    for i, ln in enumerate(open(f).read().splitlines(), 1):
        for name in refs:
            # token match, not part of longer identifier; allow @name too
            if re.search(r"(?<![\w@])" + re.escape(name) + r"(?![\w@])", ln):
                kind = "def" if re.match(r"^\s*" + re.escape(name) + r"\s*:", ln) else \
                       "procdef" if re.match(r"\.proc\s+" + re.escape(name) + r"\b", ln) else "ref"
                refs[name].append((f, i, kind, proc_of(i) if f == TARGET else "<other file>", ln.strip()))

print("Candidate safety report (convertible only if all refs in defining proc):")
not_ok, ok_count = [], 0
for proc, name in CANDIDATES:
    rs = refs[name]
    external = [r for r in rs if r[3] != proc or r[2] == "procdef"]
    if not rs:
        print(f"  {name}: NO REFERENCES FOUND (?)")
        not_ok.append((proc, name, "no refs"))
    elif external:
        print(f"  {name}: NOT CONVERTIBLE")
        for f, i, kind, p, txt in external:
            print(f"      {f}:{i} [{kind}@{p}] {txt[:90]}")
    else:
        ok_count += 1
        print(f"  {name}: convertible ({len(rs)} refs, all in {proc})")
print(f"\n{ok_count}/{len(CANDIDATES)} convertible; {len(not_ok)} blocked")
