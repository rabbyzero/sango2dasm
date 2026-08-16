# 02 — General Data 武将データ (戦略モード, pp. 16–17)

Source: scan 10. General data is displayed in Strategy Mode by selecting a
city/country and pressing **B**.

## Attributes

| Abbr | Japanese | Reading | Meaning / gameplay effect |
|------|----------|---------|---------------------------|
| 体 | 体力 | Tairyoku | HP/health of the general; 0 = death (in duel) |
| 知 | 知力 | Chiryoku | Intelligence; success rate of 計略/戦術, 情報集め, intrigue (策略) commands |
| 武 | 武力 | Buryoku | Combat power; strength in battle and duels |
| 徳 | 人徳 | Jintoku | Virtue/charisma; affects recruiting, giving, governance |
| 忠 | 忠誠度 | Chuuseido | Loyalty to the ruler; low loyalty → defection/unreliability |
| レ | レベル | Level | General level (from 経験値) |
| 経 | 経験値 | Keikenchi | Experience points; level-ups at thresholds (see [11-levelup.md](11-levelup.md)) |
| 軍 | 軍の属性 | Gun no Zokusei | Army affinity type (see below) |
| 兵 | 兵数 | Heisuu | Troops commanded (max **1000** per general) |

Example general card shown in the manual (p. 16): 体 85, 徳 60, 知 56,
武 69, 経 0, plus 兵 500.

## 軍の属性 (army affinity)

Three types; each moves differently on the tactical map (movement cost table:
[06-reference-tables.md](06-reference-tables.md)):

| Japanese | Reading | Meaning |
|----------|---------|---------|
| 平軍 | Heigun | Plains army |
| 山軍 | Sangun | Mountain army |
| 水軍 | Suigun | Naval/river army |

(Exact kanji as printed in the manual; the manual describes them as three
army types that affect movement over terrain.)

## 兵数 and troop kinds

- A general can command up to **1000 soldiers**.
- Soldiers come in three kinds (also the 戦闘モード piece types):
  **歩兵 (infantry), 弓隊 (archers), 騎馬 (cavalry)**.
- The 騎/弓/歩 numbers shown in battle status panels give per-type counts
  (example on p. 31: 劉備 体73 / 騎97 / 弓179 / 歩700).

## 武器と防具 (weapons & armor)

- Weapons/armor raise attack/defense; bought and sold at the 武器屋
  (village/town armory).
- Rules stated in the manual:
  1. Some generals cannot equip certain items.
  2. Equipment compatibility affects attack success rate.
  3. Heavier weapons raise attack power but reduce speed.
- Example equipment shown in duel data (p. 45): 呂布 — 武器:方天画戟,
  防具:甲冑.

## Naming hints for disassembly

See the consolidated semantic English glossary:
[terminology.md](terminology.md) → "Officer stats" (e.g. 体力 → `Vitality`,
軍の属性 → `ArmyAffinity`).
