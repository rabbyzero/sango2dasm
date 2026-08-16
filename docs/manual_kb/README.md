# Sangokushi II: Haou no Tairiku — Original Manual Knowledge Base

Digitized knowledge extracted from the scanned Japanese instruction manual
(`res/manual_jpn/Sangokushi2-NN.jpg`, 37 scans). This KB exists so that agents
working on the disassembly can look up **canonical Japanese game terminology**
(command names, stat names, mode names, stratagem names, etc.) without having
to read the JPG scans.

> **Use for disassembly naming:** [terminology.md](terminology.md) is the
> consolidated semantic-English glossary (Japanese → reading → English term)
> and is the authoritative vocabulary source when naming labels/procs/RAM
> symbols (e.g. 計略 → `Stratagem`, 前進 → `Advance`, 一騎討ち → `Duel`),
> consistent with the project's PascalCase semantic convention. Romaji
> readings are retained only as pronunciation aids for the Japanese source.

## Scan → manual page map

Each scan is one two-page spread (front/back cover scans are exceptions).

| Scan | Manual pages | Content | KB file |
|------|--------------|---------|---------|
| 00 | box art | Cartridge box front/back | [01-overview](01-overview.md) |
| 01 | covers | Manual front/back cover | [01-overview](01-overview.md) |
| 02 | 1–3 | Usage precautions (使用上の注意), intro text | [01-overview](01-overview.md) |
| 03–04 | 4–7 | Table of contents; 風之章 (総論) title | [01-overview](01-overview.md) |
| 05 | 6–7 | ① ものがたり (historical story) | [01-overview](01-overview.md) |
| 06 | 8–9 | ゲームの遊び方 (1): 君主と太守 / 中国マップと国 / 戦略とは？ | [01-overview](01-overview.md) |
| 07 | 10–11 | ゲームの遊び方 (2): 命令書 / 戦争 / まとめ / ルール | [01-overview](01-overview.md), [07-war-rules](07-war-rules.md) |
| 08 | 12–13 | ゲームの始め方: メニュー / レベル / 君主選択; 林之章 (戦略篇) title | [01-overview](01-overview.md) |
| 09 | 14–15 | 戦略モード/操作法: 基本画面, コントローラー | [04-strategy-commands](04-strategy-commands.md) |
| 10 | 16–17 | 戦略モード/武将データ | [02-general-stats](02-general-stats.md) |
| 11 | 18–19 | 戦略モード/国のデータ | [03-country-stats](03-country-stats.md) |
| 12 | 20–21 | 戦略モード/コマンド(1): 城のコマンド(1) | [04-strategy-commands](04-strategy-commands.md) |
| 13 | 22–23 | 戦略モード/コマンド(2): 城のコマンド(2) | [04-strategy-commands](04-strategy-commands.md) |
| 14 | 24–25 | 戦略モード/コマンド(3): 軍隊のコマンド | [04-strategy-commands](04-strategy-commands.md) |
| 15 | 26–27 | 戦略モード/コマンド(4): 倉のコマンド, 町のコマンド | [04-strategy-commands](04-strategy-commands.md) |
| 16 | 28–29 | ⑤ イベント; 火之章 (戦争篇) title | [05-events](05-events.md) |
| 17 | 30–31 | 戦争のルールと進め方 | [07-war-rules](07-war-rules.md) |
| 18 | 32–33 | 戦術モード/操作法 | [08-tactical-mode](08-tactical-mode.md) |
| 19 | 34–35 | 戦術モード/地形 | [08-tactical-mode](08-tactical-mode.md) |
| 20 | 36–37 | 戦術モード/コマンド | [08-tactical-mode](08-tactical-mode.md) |
| 21 | 38–39 | 戦闘モード/操作法 | [09-battle-mode](09-battle-mode.md) |
| 22 | 40–41 | 戦闘モード/駒の種類, 陣形 | [09-battle-mode](09-battle-mode.md) |
| 23 | 42–43 | 戦闘モード/コマンド | [09-battle-mode](09-battle-mode.md) |
| 24 | 44–45 | 一騎討ちモード | [10-duel-mode](10-duel-mode.md) |
| 25 | 46–47 | 武将のレベルアップ | [11-levelup](11-levelup.md) |
| 26 | 48–49 | 戦争が終わると…; 山之章 (資料篇) title | [07-war-rules](07-war-rules.md) |
| 27 | 50–51 | 戦略アドバイス (1) | [12-strategy-advice](12-strategy-advice.md) |
| 28 | 52–53 | 戦略アドバイス (2) | [12-strategy-advice](12-strategy-advice.md) |
| 29 | 54–55 | 君主別攻略ガイド: 表の見方, 劉備 | [13-ruler-guide](13-ruler-guide.md) |
| 30 | 56–57 | 君主別攻略ガイド: 孫策, 馬騰 | [13-ruler-guide](13-ruler-guide.md) |
| 31 | 58–59 | 君主別攻略ガイド: 董卓, 曹操 | [13-ruler-guide](13-ruler-guide.md) |
| 32 | 60–61 | 君主別攻略ガイド: 袁紹, 劉璋 | [13-ruler-guide](13-ruler-guide.md) |
| 33 | 62–63 | 操作一覧表: 戦略モード | [06-reference-tables](06-reference-tables.md) |
| 34 | 64–65 | 操作一覧表: 戦術モード, 移動消費機動力, 計略一覧 | [06-reference-tables](06-reference-tables.md) |
| 35 | 66–67 | 操作一覧表: 戦闘/一騎討ち, 戦術一覧, 部隊編成一覧 | [06-reference-tables](06-reference-tables.md) |
| 36 | 68–71 | 三国志マップ (30-country faction map) | [14-map](14-map.md) |

## Manual chapter structure

The manual is organized into four named chapters:

| Chapter | Japanese | Theme | Pages |
|---------|----------|-------|-------|
| 風之章 | かぜのしょう | 総論 (overview): story, how to play, setup | 6–13 |
| 林之章 | はやし の しょう | 戦略篇 (strategy mode) | 14–29 |
| 火之章 | ひ の しょう | 戦争篇 (war: tactics/battle/duel) | 30–49 |
| 山之章 | やま の しょう | 資料篇 (reference: advice, tables, map) | 50–71 |

## Files

0. [terminology.md](terminology.md) — **consolidated semantic English glossary** (primary naming reference)
1. [01-overview.md](01-overview.md) — game premise, modes, victory rules, setup flow
2. [02-general-stats.md](02-general-stats.md) — 武将データ (general attributes)
3. [03-country-stats.md](03-country-stats.md) — 国のデータ (province statistics)
4. [04-strategy-commands.md](04-strategy-commands.md) — 戦略モード commands (城/軍隊/倉/町)
5. [05-events.md](05-events.md) — monthly events (tax/flood/drought/harvest)
6. [06-reference-tables.md](06-reference-tables.md) — 操作一覧表: movement costs, 計略一覧, 戦術一覧, troop composition, duel commands
7. [07-war-rules.md](07-war-rules.md) — war rules, victory conditions, war-end processing
8. [08-tactical-mode.md](08-tactical-mode.md) — 戦術モード: screen, terrain, commands
9. [09-battle-mode.md](09-battle-mode.md) — 戦闘モード: pieces, formations, commands
10. [10-duel-mode.md](10-duel-mode.md) — 一騎討ちモード commands
11. [11-levelup.md](11-levelup.md) — 武将のレベルアップ
12. [12-strategy-advice.md](12-strategy-advice.md) — 戦略アドバイス
13. [13-ruler-guide.md](13-ruler-guide.md) — 君主別攻略ガイド (7 rulers)
14. [14-map.md](14-map.md) — 三国志マップ (30 countries, starting ownership)

## Transcription notes

- Content was extracted by visually reading the scans; small numerical values
  in dense tables (e.g., per-cell formation ratios) may be approximate. Where a
  reading is uncertain the entry is marked `(?)`.
- Furigana readings in the manual are given in hiragana; romanizations in this
  KB follow Hepburn style for use as label names.
- The manual prints stat abbreviations: 体(力) / 知(力) / 武(力) / 徳(人徳) /
  忠(誠度) / レ(ベル) / 経(験値) / 軍(の属性) — see [02-general-stats.md](02-general-stats.md).
