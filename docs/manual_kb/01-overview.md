# 01 — Overview (風之章: 総論)

Sources: scans 00–08 (manual pages 1–13).

## Product identity

- Title: **三国志II 覇王の大陸** (Sangokushi II: Haou no Tairiku)
- Publisher: NAMCO (namcot brand), ファミリーコンピュータ (Famicom) cartridge
- Copyright: © 1988, 1992 NAMCO LTD.
- Battery backup (バッテリーバックアップ) for saves; expected battery life ≈ 2 years
- Players: 1人 (single) or 2人 (alternating two-player); Player 1 uses the left
  controller, Player 2 the right controller

## Game premise (ものがたり, pp. 6–7)

The story opens in the mid-180s CE: the long-prosperous Later Han dynasty
(後漢王朝) is declining. The Yellow Turban rebels (黄巾の乱) rise claiming to
reform the world, and the court orders regional warlords to suppress them.
The era that follows — warlords rising across a fractured China — is the age
of the Three Kingdoms. The player takes the role of one of those warlords and
aims to unify China (天下統一).

Tagline (scan 02): 「機は熟した——群雄割拠の中国に英雄たちが立ち上がる。
天下を統べるのは果たして誰だ?!」

## Core concepts (ゲームの遊び方, pp. 8–11)

### 君主と太守 (ruler and governor)

- The player chooses one of **7 monarchs (君主)**.
- Each owned country (国) is governed by one appointed **太守 (governor)**.
- In the castle where the 君主 resides, the monarch is automatically the 太守.

### 中国マップと国 (China map and countries)

- The map contains **30 countries** (国), color-coded by owning ruler; some are
  unclaimed (空白地). See [14-map.md](14-map.md).

### 戦略とは? (what is strategy?)

- In **戦略モード (Strategy Mode)** the player picks a country, assigns
  generals, and issues commands to grow national power and prepare for war.

### 命令書 (order scrolls)

- Commands are consumed from a pool of **命令書** shown at the bottom of the
  screen. Only one command is issued per turn per country; the number of
  available orders grows with the player's level.

### 戦争 (war)

- Wars start from 戦略モード via 出陣; fighting happens on the
  **戦術モード (Tactical Mode)** map; when units clash it zooms into
  **戦闘モード (Battle Mode)**; generals meeting head-on trigger
  **一騎討ちモード (Duel Mode)**. Winning conquers the enemy country.

### ルール (victory/game-over rules, p. 11)

1. Conquer all **30 countries** to win the game.
2. Losing your last country = game over.
3. If your 君主 dies, a subordinate can succeed as the new 君主 and play
   continues (otherwise the game ends).

## Game setup (ゲームの始め方, pp. 12–13)

1. **メニューを選ぶ** — press START at the title screen; choose 1人/2人 game
   or continue from a saved record.
2. **レベルを決める** — select LEVEL 1 / 2 / 3 with + button, confirm with START.
   Higher level = stronger AI opponents.
3. **君主を選ぶ** — pick a monarch with + button, confirm with A. The seven
   selectable rulers and their number of starting cities:
   - 劉備 (Liu Bei) ×1, 馬騰 (Ma Teng) ×3, 董卓 (Dong Zhuo) ×2,
     曹操 (Cao Cao) ×2, 袁紹 (Yuan Shao) ×3, 孫策 (Sun Ce) ×4, 劉璋 (Liu Zhang) ×4

## Mode terminology (for label naming)

| Japanese | Reading | Meaning |
|----------|---------|---------|
| 戦略モード | Senryaku Mode | Grand-strategy / internal-affairs mode |
| 戦術モード | Senjutsu Mode | Tactical war map mode |
| 戦闘モード | Sentou Mode | Unit-vs-unit battle mode |
| 一騎討ちモード | Ikkiuchi Mode | General-vs-general duel mode |
| 命令書 | Meireisho | Order scrolls (per-turn command points) |
| 君主 / 太守 | Kunshu / Taishu | Ruler / governor |
| 空白地 | Kuuhakuchi | Unclaimed territory |
