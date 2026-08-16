# 04 — Strategy Mode Commands 戦略モード/コマンド (pp. 14–27)

Sources: scans 09–15. Command selection: move cursor with + button, confirm
with A; the executing general is chosen with + (up/down) + A; numeric inputs
use + (left/right to pick digit, up/down to change value).

Commands are grouped into four categories: **城 (castle)**, **軍隊 (army)**,
**倉 (warehouse)**, **町 (town)**.

## 城のコマンド (castle commands)

### Internal development (国造り, p. 21)

| Command | Reading | Effect |
|---------|---------|--------|
| 土地の開墾 | Tochi no Kairaku (?) | Raises land value → bigger rice harvest (October) |
| 産業の発展 | Sangyou no Hatten | Raises industry → bigger tax income (April) |
| 町の開発 | Machi no Kaihatsu | Raises population → income in April and October |
| 情報集め | Jouhou Atsume | Send scouts to find hidden generals, gold, rice, treasures; results scale with the general's 知力/人徳 |

### Intrigue (策略, pp. 22–23)

| Command | Reading | Effect |
|---------|---------|--------|
| 同盟 | Doumei | Form alliance with another ruler; lasts 12 months, no war between allies; success easier with high 知力 |
| 離間 | Rikan | Sow discord — lower an enemy general's loyalty; needs high 知力/人徳 |
| 引き抜き | Hikinuki | Poach an enemy general to your side; success depends on target's 知力/人徳/忠誠度 |

### Other castle commands (p. 23)

| Command | Reading | Effect |
|---------|---------|--------|
| 武将の移動 | Bushou no Idou | Move generals to an adjacent own country or unclaimed land (up to 10 generals per move) |
| 防災 | Bousai | Raise the disaster-prevention value; high 知力 works better |
| 記録する | Kiroku suru | Save the game to battery backup (continue later with 記録をよむ) |

## 軍隊のコマンド (army commands, pp. 24–25)

| Command | Reading | Effect |
|---------|---------|--------|
| 出陣 | Shutsujin | March out to attack an adjacent enemy country (starts a war). Costs gold/rice to provision the army |
| 偵察 | Teisatsu | Spy on an enemy country: view its data and generals' stats (table shows 体/武/知/忠/経/兵 columns) |
| 徴兵 | Chouhei | Conscript soldiers — **金 20 per 100 men**; assign to generals (max 1000 each); unassigned men go to 控え (reserves); finish with 終わる |
| 任命 | Ninmei | Appoint the 太守 (governor) — one per country; when the country is attacked, the 太守 becomes 総大将 (commander-in-chief). The monarch is automatically 太守 in his home castle |

## 倉のコマンド (warehouse commands, p. 26)

Warehouse data shows 金 / 米 / 宝 (treasure) stored in the country.

| Command | Reading | Effect |
|---------|---------|--------|
| 物資を運ぶ | Busshi wo Hakobu | Transport gold/rice/treasure to an adjacent own country |
| 与える (配下の武将) | Ataeru | Give gold (up to 100) or one treasure to a subordinate general → raises 忠誠度 |
| 与える (城の民衆) | Ataeru | Give gold and/or rice (up to 100 each) to the populace → raises 統治度 |

## 町のコマンド (town commands, p. 27)

Towns contain up to 4 facility types; which exist varies per country
(abbreviations used in tables: 武 / 学 / 病 / 商).

| Facility | Reading | Effect |
|----------|---------|--------|
| 武器屋 | Bukiya | Buy/sell weapons and armor for generals |
| 学問所 | Gakumonjo | Train a general → raises 知力 (costs more for low-INT generals) |
| 病院 | Byouin | Heal a wounded general's 体力 (金 50 per use) |
| 商店 | Shouten | Buy/sell rice and treasures (treasure sells for 金 100) |

## Controller map (戦略モード基本画面, pp. 14–15)

Screen elements: 年月 (date display), マップ部 (map), カーソル (cursor),
メッセージ部 (message area), 命令書の数 (remaining orders).

| Button | Function |
|--------|----------|
| + (D-pad) | Move cursor, select commands/generals/digits |
| A | Confirm, advance messages |
| B | Show 武将データ/国データ, cancel |
| SELECT | Show roads/campaigns (?) |
