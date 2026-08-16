# 07 — War Rules 戦争のルールと進め方 (pp. 30–31, 48–49)

Sources: scans 17 and 26.

## War flow

1. **宣戦/出陣** — a war starts when an army marches out (出陣) against an
   adjacent enemy country.
2. **戦術モード** — armies (generals + troops) are deployed on the tactical
   map and take turns issuing commands.
3. **戦闘モード** — when opposing units engage, the fight resolves in battle
   mode.
4. **一騎討ちモード** — generals that clash directly fight a duel.

## ルール (win/loss conditions, p. 31)

| Condition | Japanese | Rule |
|-----------|----------|------|
| Commander slain/captured | 総大将 | Win by defeating, capturing, or routing the enemy 総大将 |
| Castle capture | 城の占領 | Win by occupying the enemy castle |
| Starvation | 兵糧切れ | Rice reaches 0 → army retreats from starvation |
| Time limit | 期限切れ | If the war exceeds **30 days**, the attacking side retreats |

## まとめ (p. 31)

The three war modes can be used separately or combined:
- 戦術モード is the standard layer;
- 戦闘モード whittles down enemy forces;
- 一騎討ち is especially effective against high-武力 generals and for
  surprise situations.

## 戦争が終わると… (p. 48, war-end processing)

- **Victory**: the conquering general becomes governor of the taken country;
  wounded generals are treated and replenished.
- **Defeat**: generals survive but must retreat. The manual shows a retreat
  selection step (choose which generals pull back) with a results panel:
  - 結果 / 敗戦, 損兵 (troop losses), 損将 (general losses),
    降将 (generals surrendered to the enemy)
  - Example panel: 劉備軍 vs 袁紹軍, 損兵 292 vs 1000, 損将 0 vs 0, 降将 0 vs 0.
- Captured enemy generals may be recruited later (see 人材の発掘 in
  [12-strategy-advice.md](12-strategy-advice.md)).

## Disassembly naming hints

See the consolidated semantic English glossary:
[terminology.md](terminology.md) → "War rules" (e.g. 総大将 →
`CommanderInChief`, 兵糧切れ → `Starvation`, war-result fields `TroopLosses` /
`OfficerLosses` / `DefectedOfficers`).
