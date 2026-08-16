# 14 — China Map 三国志マップ (pp. 68–71)

Source: scan 36. Two-page map of all **30 countries** with starting faction
ownership ("城の色分けはスタート時の設定です").

## Faction legend

| Marker | Faction |
|--------|---------|
| 黒 (black) | 劉備 |
| 黄 (yellow) | 孫策 |
| 赤 (red) | 馬騰 |
| 白 (white) | 董卓 |
| 緑 (green) | 曹操 |
| えんじ (crimson) | 袁紹 |
| 桃 (pink) | 劉璋 |
| □ (white square) | 空白地 (unclaimed) |

> Marker colors above follow the manual legend; the scan reproduction makes
> some hues hard to distinguish, so ownership per country below is the
> authoritative part (cross-checked against [13-ruler-guide.md](13-ruler-guide.md)).

## Starting country ownership (30 countries)

| Faction | Countries |
|---------|-----------|
| 劉備 | 并州 |
| 馬騰 | 涼州, 西平関, 安定 |
| 董卓 | 洛陽, 長安 |
| 曹操 | 兗州, 豫州 |
| 袁紹 | 冀州, 幽州, 青州 |
| 孫策 | 建業, 江夏, 揚州, 建安 |
| 劉璋 | 成都, 漢中, 雲南(?), 衡陽(?) |
| 空白地 | 西安陽, 新野, 徐州, 荊州, 長沙, 交州, 遼東, 郁林, 永昌(?), others |

## Province name list (as printed on the map)

Left (western) half: 西安陽, 涼州, 西平関, 安定, 長安, 漢中, 成都, 衡陽,
建寧(?), 雲南, 永晶(?), 郁林.

Right (eastern) half: 幽州, 并州, 青州, 冀州, 洛陽, 新野, 豫州, 揚州, 江夏,
荊州, 長沙, 建安, 徐州, 交州, 遼東.

> Some province names on the printed map are stylized; readings marked (?)
> were hard to resolve. The game's canonical 30-country list should be
> cross-checked against the ROM's country-name data during disassembly.

## Disassembly notes

- Country index order in ROM may follow this map's layout; useful when
  decoding country tables.
- 空白地 (unclaimed) countries can be taken by 武将の移動 without war.
