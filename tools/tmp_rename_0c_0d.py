#!/usr/bin/env python3
"""One-shot terminology alignment for stratagem handler labels.

Renames pre-glossary stratagem handler labels to the canonical names in
docs/manual_kb/terminology.md, plus kingdom -> country. Ordered so that
longer compound tokens are replaced before their substrings. Symbol-only
changes: no instruction bytes are altered.

Usage: python tools/tmp_rename_0c_0d.py <file>
"""
import re
import sys

PATH = sys.argv[1]

# (old, new) - order matters (longest / most specific first)
RENAMES = [
    # helper compounds first
    ("CoordinatedStrikeNeighbor", "FriendlyFireNeighbor"),
    ("ChainStratagemProcess", "ChainLinkProcess"),
    ("WaterAttackProcess", "FloodAttackProcess"),
    ("PillageFireCheck", "InfernoCheck"),
    ("PillageFireCalc", "InfernoCalc"),
    # stratagem names (glossary, docs/manual_kb/terminology.md)
    ("AmbushAllSides", "TenfoldAmbush"),      # 11 十面埋伏
    ("RepeatingCrossbow", "SiegeLadder"),     # 13 (glossary slot 14)
    ("QimenDunjia", "MysticalStasis"),        # 15 奇門遁甲
    ("CoordinatedStrike", "FriendlyFire"),    # 7 共殺
    ("ChainStratagem", "ChainLink"),          # 10 連環
    ("WaterAttack", "FloodAttack"),           # 12 水攻
    ("PillageFire", "Inferno"),               # 14 劫火
    ("FallingRocks", "Rockfall"),             # 9 落石
    ("FeintCounter", "CastleRaid"),           # 6 偽撃転殺
    ("MuddyWater", "BoatSabotage"),           # 4 乱水
    ("WinOver", "Enticement"),                # 8 籠絡
    ("FireArrows", "SupplyBurning"),          # 5 火箭 (tactical stratagem)
    # kingdom -> country
    ("kingdom_param_copy", "country_param_copy"),
]

# alphanumeric-only boundaries: Python's \b treats '_' as a word char,
# which would miss identifiers like ValidStratagem_Trap
def bpat(tok):
    return re.compile(r"(?<![A-Za-z0-9])" + re.escape(tok) + r"(?![A-Za-z0-9])")

with open(PATH, encoding="utf-8") as f:
    text = f.read()

total = 0
for old, new in RENAMES:
    text, n = bpat(old).subn(new, text)
    if n:
        print(f"{old:28s} -> {new:24s} {n:4d}")
        total += n

# standalone Trap -> PitfallTrap (won't touch PitfallTrap itself)
text, n = bpat("Trap").subn("PitfallTrap", text)
print(f"{'Trap':28s} -> {'PitfallTrap':24s} {n:4d}")
total += n

with open(PATH, "w", encoding="utf-8") as f:
    f.write(text)
print(f"TOTAL replacements: {total}")
