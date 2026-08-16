# 03 — Country Data 国のデータ (戦略モード, pp. 18–19)

Source: scan 11. Country data is shown when selecting a city/country in
Strategy Mode. Example panel (并州): 金 5066, 米 8006(?), 土地 427(?),
産業 440(?), 人口 47100, 防災 99, 武将 4, 兵士 4000, 統治度 100.

## Statistics

| Japanese | Reading | Meaning / effects |
|----------|---------|-------------------|
| 統治度 | Touchido | Governance/control. Low values cause unrest and rebellion; high values stabilize the country |
| 金 | Kin | Gold. Spent on commands, conscription, equipment; income from taxes (April-ish cycle) |
| 米 | Kome | Rice. Army food supply in war (0 → starvation retreat); harvest in October/November; tradable at 商店 |
| 土地 | Tochi | Land value. Development raises rice harvests |
| 産業 | Sangyou | Industry. Development raises tax income |
| 人口 | Jinkou | Population. Raises tax and harvest yield, also affects conscription pool |
| 防災 | Bousai | Disaster prevention. Reduces damage from floods/droughts |
| 武将 | Bushou | Number of generals stationed (up to 10 per country) |
| 兵士 | Heishi | Total soldiers: 現役 (assigned to generals) + 控え (reserves) |

## Soldier pools (軍隊データ, p. 24)

The army data panel distinguishes:

| Japanese | Reading | Meaning |
|----------|---------|---------|
| 現役 | Gen'eki | Soldiers assigned under generals |
| 控え | Hikae | Reserve soldiers not yet assigned (conscripts waiting for assignment; max 1000 per general on assignment) |

## Economic loop summary

- 土地開墾 → higher rice harvest (米の収穫 event)
- 産業発展 → higher tax income (税金の徴収 event)
- 町開発 → higher population → better taxes/harvests
- 防災 command → mitigates 洪水/日照り damage
- See [05-events.md](05-events.md) for the monthly event calendar.
