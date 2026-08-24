# Semantic English Terminology (consolidated glossary)

Consolidated from all manual KB files. This is the **authoritative vocabulary
for naming labels, procs, and RAM symbols** in the disassembly. It follows the
project's established PascalCase semantic-English convention (e.g.
`BankSwitch`, `CallbackDispatcher`, `DomesticActionDispatch`), NOT romaji.
Romaji readings are kept only as pronunciation aids for reading the Japanese
source material.

Conventions:
- **English term** column = canonical semantic name to use in code.
- Composed identifiers use PascalCase: 計略実行 → `StratagemExecute`,
  陣形選択 → `FormationSelect`.
- Dispatch/handler routines follow existing style: `<Domain>ActionDispatch`,
  `<Domain>CommandSelect`, etc.

## Game modes & core concepts

| Japanese | Reading | Semantic English |
|----------|---------|------------------|
| 戦略モード | senryaku | Strategy Mode |
| 戦術モード | senjutsu | Tactical Mode |
| 戦闘モード | sentou | Battle Mode |
| 一騎討ちモード | ikkiuchi | Duel Mode |
| 君主 | kunshu | Ruler |
| 太守 | taishu | Governor |
| 総大将 | soudaishou | CommanderInChief |
| 武将 | bushou | Officer (generic) / General |
| 兵士 / 兵 | heishi | Soldier / Troops |
| 国 | kuni | Country |
| 州 | shuu | Province |
| 城 | shiro | City (province on the strategy map) / Castle (castle command menu, castle in Tactical/Battle Mode) |
| 町 | machi | Town |
| 空白地 | kuuhakuchi | UnclaimedLand |
| 命令書 | meireisho | OrderScroll (command points) |
| レベル | reberu | Level (difficulty 1–3; officer level) |
| 記録する | kiroku | SaveGame |
| 記録をよむ | — | LoadGame |

### Game mode hierarchy

The four modes nest; they are not peers:

- **Strategy Mode** (戦略モード) — the map-level domestic/foreign affairs
  loop. What older code called "DomesticAffairs" belongs here
  (e.g. `State_StrategyMode`, state 5).
- **Tactical Mode** (戦術モード) — the field/army movement layer. What older
  code called "BattlePhase" is actually Tactical Mode
  (e.g. `State_TacticalMode`, state 7).
- **Battle Mode** (戦闘モード) — a sub-scenario of Tactical Mode.
- **Duel Mode** (一騎討ちモード) — a sub-scenario of Battle Mode.

### Domain model: Ruler / Country / Province

- A **Ruler** (君主) is the ruler of a **Country** (国; formerly named
  "kingdom" in this codebase).
- A **Country** can have one or more **Provinces** (州).
- A **Province** can be empty (unclaimed) or occupied by some **Officers**;
  among them, one is the **Governor** (太守).
- In the game, a province is sometimes called 城. In that sense it should be
  translated to **City**. Only when 城 refers to the castle command menu or
  the castle in Tactical/Battle Mode does it mean **Castle**.
- Code identifiers: `GetProvinceRecordAddr` ($F2AF) computes the province
  record address (id*32+$6000); `GetCountryDataPtr` ($F368) returns the
  **country** base address (not the ruler's), looked up from
  `CountryDataPtrTable` ($F379).

## Officer stats (武将データ)

| Japanese | Reading | Semantic English |
|----------|---------|------------------|
| 体力 | tairyoku | Vitality (HP) |
| 知力 | chiryoku | Intelligence |
| 武力 | buryoku | Might |
| 人徳 | jintoku | Virtue |
| 忠誠度 | chuuseido | Loyalty |
| 経験値 | keikenchi | Experience |
| レベル | reberu | OfficerLevel |
| 軍の属性 | gun no zokusei | ArmyAffinity |
| 平軍 | heigun | PlainsArmy |
| 山軍 | sangun | MountainArmy |
| 水軍 | suigun | NavalArmy |
| 兵数 | heisuu | TroopCount |
| 現役 | gen'eki | ActiveTroops |
| 控え | hikae | ReserveTroops |
| 武器 / 防具 | buki / bougu | Weapon / Armor |

## Country stats (国のデータ)

| Japanese | Reading | Semantic English |
|----------|---------|------------------|
| 統治度 | touchido | Governance |
| 金 | kin | Gold |
| 米 | kome | Rice |
| 土地 | tochi | LandValue |
| 産業 | sangyou | Industry |
| 人口 | jinkou | Population |
| 防災 | bousai | DisasterPrevention |
| 宝 | takara | Treasure |

## Strategy Mode commands

### Castle commands (城)

| Japanese | Reading | Semantic English |
|----------|---------|------------------|
| 土地の開墾 | tochi no kairaku | LandReclamation |
| 産業の発展 | sangyou no hatten | IndustryDevelopment |
| 町の開発 | machi no kaihatsu | TownDevelopment |
| 情報集め | jouhou atsume | IntelligenceGathering |
| 策略 | sakuryaku | Intrigue (castle command category: Alliance/Discord/Poaching; NOT "diplomacy"; distinct from 計略/Stratagem) |
| 同盟 | doumei | Alliance |
| 離間 | rikan | Discord |
| 引き抜き | hikinuki | Poaching |
| 武将の移動 | bushou no idou | OfficerTransfer |
| 防災 | bousai | DisasterPrevention (command) |
| 記録する | kiroku suru | SaveGame |

### Army commands (軍隊)

| Japanese | Reading | Semantic English |
|----------|---------|------------------|
| 出陣 | shutsujin | Sortie |
| 偵察 | teisatsu | Reconnaissance |
| 徴兵 | chouhei | Conscription |
| 任命 | ninmei | GovernorAppointment |

### Warehouse commands (倉)

| Japanese | Reading | Semantic English |
|----------|---------|------------------|
| 物資を運ぶ | busshi wo hakobu | SupplyTransport |
| 与える (配下の武将) | ataeru | OfficerGift (raises Loyalty) |
| 与える (城の民衆) | ataeru | CivilianRelief (raises Governance) |

### Town facilities (町)

| Japanese | Reading | Semantic English |
|----------|---------|------------------|
| 武器屋 | bukiya | Armory |
| 学問所 | gakumonjo | Academy |
| 病院 | byouin | Hospital |
| 商店 | shouten | Market |

## Events (イベント)

| Japanese | Reading | Semantic English |
|----------|---------|------------------|
| 税金の徴収 | zeikin no choushuu | TaxCollection |
| 洪水 | kouzui | Flood |
| 日照り | hideri | Drought |
| 米の収穫 | kome no shuukaku | RiceHarvest |
| 反乱 | hanran | Rebellion |

## War rules

| Japanese | Reading | Semantic English |
|----------|---------|------------------|
| 戦争 | sensou | War |
| 宣戦布告 | sensen fukoku | WarDeclaration |
| 兵糧切れ | hyourougire | Starvation (rice depleted) |
| 期限切れ | kigengire | TimeLimitExpired (30 days) |
| 城の占領 | shiro no senryou | CastleCapture |
| 退却 | taijaku | Retreat |
| 損兵 | sonpei | TroopLosses |
| 損将 | sonshou | OfficerLosses |
| 降将 | koushou | DefectedOfficers |
| 捕虜 | horyo | Prisoner |

## Tactical Mode (戦術モード)

| Japanese | Reading | Semantic English |
|----------|---------|------------------|
| 機動力 | kidouryoku | Mobility (action points) |
| 経過日数 | keika nissuu | DaysElapsed |
| 残りの金 / 米 | — | RemainingGold / RemainingRice |
| 移動 | idou | Move |
| 攻撃 | kougeki | Attack |
| 計略 | keiryaku | Stratagem |
| 待機 | taiki | Wait |
| 退却 | taijaku | Retreat |

### Terrain (地形)

| Japanese | Reading | Semantic English |
|----------|---------|------------------|
| 平地 | heichi | Plain |
| 林 | hayashi | Forest |
| 山 | yama | Mountain |
| 川 | kawa | River |
| 砂地 | sunaji | Sandland |
| 城 | shiro | Castle |
| 村 | mura | Village |
| 民家 | minka | House |

### Stratagems (計略一覧)

| Japanese | Reading | Semantic English |
|----------|---------|------------------|
| 火計 | kakei | FireAttack |
| 陥穽 | kansei | PitfallTrap |
| 虚兵 | kyohei | FeintTroops |
| 要撃 | yougeki | AmbushStrike |
| 乱水 | ransui | BoatSabotage |
| 火箭 | kasen | SupplyBurning (fire arrows vs. rice) |
| 偽撃転殺 | gigitensatsu | CastleRaid |
| 共殺 | kyousatsu | FriendlyFire |
| 落石 | rakuseki | Rockfall |
| 連環 | renkan | ChainLink (immobilize) |
| 籠絡 | rouraku | Enticement (turn officer) |
| 十面埋伏 | juumen maifuku | TenfoldAmbush |
| 水攻 | suikou | FloodAttack |
| 連弩 | rendou | RepeatingCrossbow |
| 劫火 | gouka | Inferno |
| 奇門遁甲 | kimon tonkou | MysticalStasis |

## Battle Mode (戦闘モード)

### Pieces (駒)

| Japanese | Reading | Semantic English |
|----------|---------|------------------|
| 武将 | bushou | CommanderPiece |
| 歩兵 | hohei | Infantry |
| 弓隊 | kyuutai | Archers |
| 騎馬 | kiba | Cavalry |

### Formations (陣形)

| Japanese | Reading | Semantic English |
|----------|---------|------------------|
| 長蛇の陣 | chouda no jin | SerpentFormation |
| 雁行の陣 | gankou no jin | GooseFormation |
| 錐行の陣 | suikou no jin | WedgeFormation |
| 魚鱗の陣 | gyorin no jin | FishScaleFormation |

### Commands & tactics

| Japanese | Reading | Semantic English |
|----------|---------|------------------|
| 前進 | zenshin | Advance |
| 後退 | koutai | Withdraw |
| 待機 | taiki | Hold |
| 包囲 | houi | Surround |
| 戦術 | senjutsu | Tactic |
| 戦術ポイント | — | TacticPoints |
| 挑発 | chouhatsu | Taunt |
| 呪縛 | jubaku | Bind |
| 強弩 | kyoudo | CrossbowVolley |
| 士気向上 | shiki koujou | MoraleBoost |
| 火矢 | hiya | FireArrows |
| 爆炎 | bakuen | Explosion |

## Duel Mode (一騎討ちモード)

| Japanese | Reading | Semantic English |
|----------|---------|------------------|
| 一騎討ち | ikkiuchi | Duel |
| 体力ゲージ | tairyoku geji | HealthGauge |
| 牽制 | kensei | Feint |
| 攻撃 | kougeki | Strike |
| 戦術 | senjutsu | DuelTactic |
| 説得 | settoku | Persuade |
| 罵倒 | batou | Insult |
| 捨て身の攻撃 | sutemi no kougeki | DesperateAttack |
| 退却 | taijaku | Flee |
| 降参 | kouzan | Surrender |
| データ | deta | DataDisplay |

## Level up (レベルアップ)

| Japanese | Reading | Semantic English |
|----------|---------|------------------|
| レベルアップ | reberu appu | LevelUp |
| 武力アップ | — | MightGain |
| 兵の編成 | hei no hensei | TroopComposition |

## Example identifier composition

| Routine concept | Suggested identifier |
|-----------------|----------------------|
| Dispatch over tactical commands (移動/攻撃/計略/待機/退却) | `TacticalCommandDispatch` |
| Stratagem selection menu | `StratagemSelect` |
| Stratagem effect handler table | `StratagemEffectTable` |
| Formation selection before battle | `FormationSelect` |
| Battle command handler (前進…) | `BattleCommandDispatch` |
| Tactic point cost table | `TacticCostTable` |
| Duel command dispatch | `DuelCommandDispatch` |
| Officer stat block in RAM | `OfficerStats` (fields `Vitality`, `Intelligence`, `Might`, `Virtue`, `Loyalty`, `Experience`) |
| Country data block | `CountryData` (fields `Governance`, `Gold`, `Rice`, …) |
| Monthly event dispatch | `MonthlyEventDispatch` |
| War result tally (損兵/損将/降将) | `WarResultTally` |
