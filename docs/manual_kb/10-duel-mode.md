# 10 — Duel Mode 一騎討ちモード (pp. 44–45)

Source: scan 24.

## Trigger

A duel starts during 戦闘モード when:
- two generals clash directly (pieces meet), or
- the battle tactic **挑発 (provocation)** succeeds.

## Screen elements

| Element | Japanese | Notes |
|---------|----------|-------|
| Health gauge | 体力ゲージ | red bar above each general; 0 = death |
| General data | 武将データ | portrait + 体/徳/レ/知/忠/軍/武/経 + 武器/防具 |
| Commands | コマンド | one command per turn, chosen with + |

Example shown: 呂布 vs 夏侯惇 — 呂布 体91 徳10 レベル4 知17 忠30 山軍379 武99
経78, 武器:方天画戟, 防具:甲冑.

## Operation method (操作法)

1. Enter one command per turn with + button.
2. Both sides can take damage in the exchange; at 体力 0 the general dies.
   Lighter/faster side acts first (?).
3. Win by defeating, forcing surrender, or routing the opponent; victory
   returns to 戦闘モード.

## Commands コマンド

| Command | Reading | Effect |
|---------|---------|--------|
| 牽制 | Kensei | Probe attack — can deal damage; no 武力 bonus applied |
| 攻撃 | Kougeki | Full attack — deals damage; may be countered |
| 戦術 → 説得 | Settoku | Persuade the opponent to surrender; on failure the opponent may avoid further duels |
| 戦術 → 罵倒 | Batou | Insult — lowers the opponent's attack success rate |
| 戦術 → 捨て身の攻撃 | Sutemi no Kougeki | Desperate attack — high power; self-damage if it fails |
| 退却 | Taijaku | Flee the duel; opponent may pursue |
| 降参 | Kouzan | Surrender (becomes prisoner) |
| データ | Data | Toggle general data display with + up/down |

## Disassembly naming hints

See the consolidated semantic English glossary:
[terminology.md](terminology.md) → "Duel Mode" (e.g. 一騎討ち → `Duel`,
体力ゲージ → `HealthGauge`, commands `Feint`/`Strike`/`Persuade`/`Insult`/
`DesperateAttack`/`Flee`/`Surrender`).
