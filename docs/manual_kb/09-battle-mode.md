# 09 — Battle Mode 戦闘モード (pp. 38–43)

Sources: scans 21–23.

## Operation method (操作法, pp. 38–39)

1. Before the fight, choose the **陣形 (formation)** with +, confirm with A.
2. Command display appears: pick piece type with +, issue commands; pressing A
   switches to the troop-count display.
3. During the fight, press A to change commands mid-battle (commands can fail
   if the battle stalls).
4. When attacked, units counter-attack automatically; both sides lose troops
   until one reaches zero.
5. If the general is pressed, the 戦術 command or a duel challenge can be
   used; success can flip the momentum.
6. Defeating/capturing/routing the enemy general returns to 戦術モード.

Controller:
| Button | Function |
|--------|----------|
| + | Select piece type / command |
| A | Confirm command, show messages |
| B | Show remaining troops per unit |

## Piece types 駒の種類 (p. 40)

| Piece | Japanese | Movement / attack profile |
|-------|----------|---------------------------|
| General | 武将 | Mobility of cavalry plus extra offense/defense; decides victory/defeat (武将は体力 — the general himself is the win condition) |
| Infantry | 歩兵 | Moves 1, attacks 1 per turn; weak attack; (manual: cannot attack while facing forward (?)) |
| Archers | 弓隊 | Moves 1, attacks 1 per turn; weakest melee but can shoot distant enemies |
| Cavalry | 騎馬 | Moves 2 per turn; can attack twice, or move 1 + attack 1 |

## Formations 陣形 (p. 41)

Four formations, chosen before battle:

| Formation | Japanese | Reading | Character |
|-----------|----------|---------|-----------|
| Long snake | 長蛇の陣 | Chouda no Jin | Wide coverage, flanking; weak center |
| Wild geese | 雁行の陣 | Gankou no Jin | Fanned line; flexible ranged support; weak center |
| Wedge | 錐行の陣 | Suikou no Jin | Tight spearhead; strong frontal assault |
| Fish scale | 魚鱗の陣 | Gyolin no Jin | Overlapping rows; strong frontal assault |

## Commands コマンド (pp. 42–43)

| Command | Reading | Effect |
|---------|---------|--------|
| 前進 | Zenshin | Advance toward the enemy general; attack on contact |
| 後退 | Koutai | Withdraw from the front; exit the screen when complete; if the general retreats, the battle resets to 戦術モード |
| 待機 | Taiki | Hold position; attack enemies that approach |
| 包囲 | Houi | Close in and surround the enemy general without direct attack → forces surrender and drains stamina |
| 戦術 | Senjutsu | Spend tactic points (higher 知力 = more points); one tactic per turn; points refresh next turn. List in [06-reference-tables.md](06-reference-tables.md) |

## Disassembly naming hints

See the consolidated semantic English glossary:
[terminology.md](terminology.md) → "Battle Mode" (e.g. 陣形 → `Formation` with
`SerpentFormation`/`GooseFormation`/`WedgeFormation`/`FishScaleFormation`,
commands `Advance`/`Withdraw`/`Hold`/`Surround`, 戦術ポイント → `TacticPoints`).
