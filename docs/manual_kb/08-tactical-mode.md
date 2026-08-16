# 08 — Tactical Mode 戦術モード (pp. 32–37)

Sources: scans 18–20.

## Basic screen (基本画面, p. 32)

| Element | Japanese | Notes |
|---------|----------|-------|
| Map area | マップ部 | battlefield terrain |
| Cursor | カーソル | unit/cell selection |
| Message area | メッセージ部 | bottom text panel |
| Commander mark | 総大将マーク | marks the army commander |
| Troop count | 兵数 | remaining soldiers |
| Army attribute | 軍の属性 | 平/山/水 army type |
| Days elapsed | 経過日数 | war day counter (limit 30) |
| Mobility | 機動力 | action points; commands consume it; 0 → turn ends |
| Remaining gold/rice | 残りの金 / 残りの米 | consumed during war (rice per day by troop count) |

## Controller (p. 33)

| Button | Function |
|--------|----------|
| + | Move cursor, enter numbers |
| A | Confirm command / unit assignment |
| B | Select unit, show 武将データ (ally or enemy), cancel |

Turn flow: the defending side places/acts first (?); select unit → command →
target. Units may only issue commands while they have mobility left; unused
mobility of a 待機 unit carries partially to the next day.

## Terrain 地形 (pp. 34–35)

| Terrain | Japanese | Notes |
|---------|----------|-------|
| Plain | 平地 | Easy movement for all armies; vulnerable to fire attacks |
| Forest | 林 | Hard for 山軍/水軍(?); dangerous ground for stratagems; ambush terrain |
| Mountain | 山 | Rough; disadvantage for some army types; 落石 usable |
| River | 川 | Water armies move best; crossing is risky; 乱水/連環/水攻 terrain |
| Sand | 砂地 | Slow movement; few stratagem options |
| Castle | 城 | Defender advantage; assault directly only with care |
| Village | 村 | Contains houses (民家), 武器屋, 病院 — can be used to block advance |

Village facilities on the tactical map:
- 民家 (house) — buy rice
- 武器屋 — buy weapons/armor
- 病院 — restore general's 体力

## Commands コマンド (pp. 36–37)

| Command | Reading | Notes |
|---------|---------|-------|
| 移動 | Idou | Move unit; costs mobility per terrain (table in [06-reference-tables.md](06-reference-tables.md)) |
| 攻撃 | Kougeki | Attack adjacent enemy unit; costs 2 mobility |
| 計略 | Keiryaku | Stratagems — damage/effects scale with 知力; success higher when enemy INT is low (full list in [06-reference-tables.md](06-reference-tables.md)) |
| 待機 | Taiki | Wait; leftover mobility can carry over to next day |
| 退却 | Taijaku | Withdraw from the war back home |

## Disassembly naming hints

See the consolidated semantic English glossary:
[terminology.md](terminology.md) → "Tactical Mode" (e.g. 機動力 → `Mobility`,
計略 → `Stratagem`, terrain 平地/林/山/川/砂地 → `Plain`/`Forest`/`Mountain`/
`River`/`Sandland`).
