#!/usr/bin/env python3
"""Greedy group-safe @-local conversion for B1F_CallbackDispatcher targets
in prg_19_1a.asm.

Step 1: revert the earlier blanket conversion (including the dup renames
@KanaScan/@AckStillWait/@*Exit) back to the pre-session state.
Step 2: try converting each candidate label (refs+defs inside its proc) to
@-local style one at a time; keep the conversion only if the whole file
stays group-consistent (ca65 cheap-local resolution + dup detection).
"""
import re

PATH = "asm/banks/prg_19_1a.asm"
lines = open(PATH).read().splitlines()

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

# ---- step 1: revert blanket conversion -------------------------------------
DUP_REVERTS = [("@KanaScan", "@Scan"), ("@AckStillWait", "@StillWaiting"),
               ("@SweepPromptExit", "@PhaseExit"), ("@SweepAckExit", "@PhaseExit"),
               ("@AbsorbPromptExit", "@PhaseExit"), ("@AbsorbAckExit", "@PhaseExit")]
for new, old in DUP_REVERTS:
    for i, ln in enumerate(lines):
        code, sep, comment = ln.partition(";")
        if new in code:
            lines[i] = code.replace(new, old) + sep + comment

proc_ranges, cur = [], None
for i, ln in enumerate(lines, 1):
    m = re.match(r"\.proc\s+(\S+)", ln)
    if m:
        cur = (i, m.group(1))
    elif ln.strip().startswith(".endproc") and cur:
        proc_ranges.append((cur[0], i, cur[1])); cur = None
proc_span = {n: (s, e) for s, e, n in proc_ranges}

def convert(ls, proc, name, to_local):
    s, e = proc_span[proc]
    if to_local:
        pat = re.compile(r"(?<![\w@])" + re.escape(name) + r"(?![\w@])")
        target = "@" + name
    else:
        pat = re.compile(r"(?<![\w@])@" + re.escape(name) + r"(?![\w@])")
        target = name
    n_total = 0
    for i in range(s, e + 1):
        ln = ls[i - 1]
        code, sep, comment = ln.partition(";")
        new_code, n = pat.subn(target, code)
        if n:
            ls[i - 1] = new_code + sep + comment
            n_total += n
    return n_total

# revert the 57 candidate labels inside their procs
for proc, names in CANDIDATES.items():
    for name in names:
        convert(lines, proc, name, to_local=False)

# ---- group-consistency check (in-memory) -----------------------------------
def group_check(ls):
    """Return list of error strings; [] means consistent."""
    errs = []
    groups = {}
    # pass 1: defs
    cur_global = "<scope-start>"
    for i, ln in enumerate(ls, 1):
        code = ln.partition(";")[0]
        if re.match(r"\s*\.proc\b", code):
            cur_global = "<scope-start>"; continue
        m = re.match(r"^\s*([A-Za-z_][A-Za-z0-9_]*):", code)
        if m:
            cur_global = m.group(1); continue
        m = re.match(r"^\s*@([A-Za-z0-9_]+):", code)
        if m:
            key = (cur_global, m.group(1))
            if key in groups:
                errs.append(f"line {i}: DUP @{m.group(1)} in group {cur_global}")
            groups[key] = i
    # pass 2: refs
    cur_global = "<scope-start>"
    for i, ln in enumerate(ls, 1):
        code = ln.partition(";")[0]
        if re.match(r"\s*\.proc\b", code):
            cur_global = "<scope-start>"; continue
        m = re.match(r"^\s*([A-Za-z_][A-Za-z0-9_]*):", code)
        if m:
            cur_global = m.group(1); continue
        if re.match(r"^\s*@[A-Za-z0-9_]+:", code):
            continue
        for m in re.finditer(r"(?<![\w@])@([A-Za-z0-9_]+)", code):
            if (cur_global, m.group(1)) not in groups:
                errs.append(f"line {i}: ref @{m.group(1)} undefined in group {cur_global}")
    return errs

assert group_check(lines) == [], "reverted state not group-consistent!"

# ---- step 2: greedy conversion (iterate to fixpoint, max 3 passes) ---------
converted, skipped = [], []
pending = [(p, n) for p, names in CANDIDATES.items() for n in names]
for _pass in range(3):
    still_pending = []
    for proc, name in pending:
        trial = list(lines)
        n = convert(trial, proc, name, to_local=True)
        if group_check(trial):
            still_pending.append((proc, name))
        else:
            lines = trial
            converted.append(f"{proc}:{name} ({n} refs)")
    if len(still_pending) == len(pending):
        break   # no progress this pass
    pending = still_pending
skipped = [f"{p}:{n}" for p, n in pending]

if group_check(lines):
    print("FINAL GROUP ERRORS:")
    print("\n".join(group_check(lines)))
    raise SystemExit(1)

open(PATH, "w").write("\n".join(lines) + "\n")
print(f"converted ({len(converted)}):")
for c in converted:
    print("  " + c)
print(f"\nkept bare global ({len(skipped)}):")
for s in skipped:
    print("  " + s)
