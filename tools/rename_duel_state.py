#!/usr/bin/env python3
"""Rename the duel-mode main dispatcher and its state cell.

MainGameDispatch -> DuelModeDispatch  (the $B100 dispatcher is the duel mode
only, not the full game).  game_state ($04A8) -> duel_state (duel state cell,
distinct from the NMI's addr_game_state $007A).  Comment phrasing "game $XX"
-> "state $XX" inside prg_17_18.  Idempotent, whole-word replacements.
"""
import re

FILES = [
    "asm/banks/prg_17_18.asm",
    "asm/banks/prg_1f.asm",
    "include/functions.h",
]

# Longest-first, whole-word.
RENAMES = [
    ("MainGameDispatch_Entry", "DuelModeDispatch_Entry"),
    ("MainGameDispatch", "DuelModeDispatch"),
    ("game_state", "duel_state"),
]

# Whole-line comment rewrites (only applied when the old text is present).
LINE_FIXES = [
    # prg_17_18.asm
    ("; Main game state ($04A8-$04C0)", "; Duel mode state ($04A8-$04C0)"),
    ("game_state                   = $04A8  ; Duel/war-scene state (0-$15), indexes MainGameDispatch",
     "duel_state                   = $04A8  ; Duel state (0-$15), indexes DuelModeDispatch"),
    (";--- $B100: Main Game Dispatch ---", ";--- $B100: Duel Mode Dispatch ---"),
    ("; Main dispatcher of the duel/war-scene module (22-entry game_state table;",
     "; Main dispatcher of the duel mode (22-entry duel_state table;"),
    # prg_1f.asm
    ("  JSR B17_18_MainGameDispatch                   ; $F9CD: 20 1B A0  Main game dispatch (bank $17)",
     "  JSR B17_18_DuelModeDispatch                   ; $F9CD: 20 1B A0  Duel mode dispatch (bank $17)"),
    # functions.h
    ("B17_18_MainGameDispatch   = $A01B   ; MainGameDispatch_Entry: Main game mode dispatcher",
     "B17_18_DuelModeDispatch   = $A01B   ; DuelModeDispatch_Entry: Duel mode main dispatcher"),
    ("runs Duel Mode dispatcher (MainGameDispatch, bank $17/$18)",
     "runs Duel Mode dispatcher (DuelModeDispatch, bank $17/$18)"),
]

for path in FILES:
    with open(path) as f:
        text = f.read()
    total = 0
    for old, new in LINE_FIXES:
        if old in text:
            text = text.replace(old, new)
            total += 1
    for old, new in RENAMES:
        pat = re.compile(r"(?<![A-Za-z0-9_])" + re.escape(old) + r"(?![A-Za-z0-9_])")
        text, n = pat.subn(new, text)
        total += n
    # "game $XX" -> "state $XX" in prg_17_18 comment text only ("game $" never
    # appears in an operand).
    if path == "asm/banks/prg_17_18.asm":
        text, n = re.subn(r"(;[^;\r\n]*?)game \$", r"\1state $", text)
        total += n
    with open(path, "w") as f:
        f.write(text)
    print(f"{path}: {total} replacements")
