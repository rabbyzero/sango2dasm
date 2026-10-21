# Menu stream text, callers and validation (data banks $12/$13)

Cross-check of every message stream in `asm/banks/data_12_menu_display.asm` (PRG $12) and
`asm/banks/data_13_menu_display.asm` (PRG $13) against the code that seeds its pos id.

**Bank selection** (`SelectDataBankByPos` $A690, prg_1d_1e_menu_screens): pos ids < $20 always read bank 13;
ids >= $20 read bank 12 when `addr_game_state` ($007A) is 3-8 (war / war-AI / strategy-frame /
duel contexts) and bank 13 otherwise (strategy play, events, new game, ending).
`B1F_OpenMsgWindow0/2/4/5(A)` queues A into `pos_buf_1`; the mode-head stream (a window-blanking
primitive) renders first, then `$80` shifts the queue and the seeded id's stream renders.
Caller tags: `[12]` = war/battle/duel context (prg_08_09_tactical_war / 0c_0d / 0e_0f / duel procs of 17_18),
`[13]` = strategy/event context (prg_19_1a_event_scenes / 1b_1c / EventMessageScene_*).
Placeholders: 〈名〉 officer name, 〈名7 n〉 7-char name slot, 〈名p 20〉 ruler card name,
〈省NN〉 province name, ⟨数n⟩ number slot. JP text is the literal tile decode
(`tools/report_stream_text.py`); EN is a working translation; readings marked (?) are uncertain.

**Validation legend:** ok = caller context and message agree | ok? = plausible, minor uncertainty |
table = no direct OpenMsgWindow caller, seeded via indexed message tables (@ResultMsgTable /
@CancelMsgTable / ExecuteAction routing) | no caller = no OpenMsgWindow/pos_buf seed found (flagged 2026-10-12).


## Bank $12 - war / battle / duel copies (game_state 3-8)

| Pos | JP text | EN translation | Caller(s) | Validation |
|-----|---------|----------------|-----------|------------|
| $20 | -(graphics/no text) | country status overlay clear (graphics, no text) | - | shared id - CountryRotationDispatch renders bank 13 here |
| $21 | 〈名〉の こうげき | <mei>'s attack | DuelCmd_CommandRoute $B4DB | ok - duel (DuelCmd_CommandRoute) |
| $22 | ⟨数⟩の ダメージをあたえた | dealt <su> damage | DuelStrike_ApplyGauge $B998 | ok - DuelStrike_ApplyGauge |
| $23 | 〈名〉の けんせい | <mei>'s Feint (kensei 牽制) | DuelCmd_CommandRoute $B4A2@17 | ok - DuelCmd_CommandRoute |
| $24 | 〈名〉の / すてみのこうげき | <mei>'s desperate attack (sutemi 捨て身) | DuelCmd_CommandRoute $B535 | ok - DuelCmd_CommandRoute |
| $25 | しかし コウゲキはかわされた | but the attack was parried | DuelStrike_ShowParried $B9A2 | ok - DuelStrike_ShowParried |
| $26 | 〈名〉は ついに ちからつきた | <mei>'s strength gave out at last | DuelPursue_CheckDeath $BBBC; MapFade_Draw $C2A7 | ok - DuelPursue_CheckDeath; MapFade_Draw (duel-end fade) |
| $27 | もはやここまでか  む むねん | So this is the end... how regrettable (munen 無念) | Surrender_Init $BD1A | ok - Surrender_Init (ruler's last words) |
| $28 | 〈名〉は ホリョになりました | <mei> was taken prisoner (horyo 捕虜) | Surrender_Execute $BDC8 | ok - Surrender_Execute |
| $29 | このショウブ あずけておくぞ! | I leave this bout to you! | DuelPursue_Init $BAA1 | ok - DuelPursue_Init |
| $2A | まて! にげるとは ヒキョウなり! | Halt! Fleeing is cowardice (hikyou 卑怯)! | DuelPursue_SetupPursuer $BAFF | ok - DuelPursue_SetupPursuer |
| $2B | けんせい   たいきゃく / こうげき   こうさん / せんじゅつ  データ / すてみのこうげき | duel tactic menu: feint / retreat / attack / surrender / stratagem / data / desperate attack | DuelCmd_RoundSetup $B3C3; DuelCmd_TacticSelect $B5B7 | ok - DuelCmd_RoundSetup; DuelCmd_TacticSelect (CastleCommandDispatch $2B renders bank 13) |
| $2C | せっとく   ばとう | persuade (setoku 説得) / insult (batou 罵倒) | DuelCmd_CommandMenu $B458 | ok - DuelCmd_CommandMenu |
| $2D | キサマのような ヤツが / ワシを たおそうなどとは / 100ネン はやいわ! | A wretch like you - 100 years too early to defeat me! | - | label DuelRivalTaunt matches; no direct OpenMsgWindow caller (duel route) |
| $2E | ぬぬぬう! / ワシを ぐろうするとは! / ゆるさん! | Grrr! To mock me (gurou 愚弄)! Unforgivable! | - | label DuelRulerAngeredMsg matches; no direct OpenMsgWindow caller |
| $2F | フッ / そのテには のらんぞ! | Heh - I won't fall for that trick! | - | label DuelRefuseTaunt matches; no direct OpenMsgWindow caller |
| $30 | しょせん オマエたちでは / わがグンには かてん / おとなしく コウフクしろ | In the end you lot are no match for my army - surrender quietly (koufuku 降伏) | - | no OpenMsgWindow caller found (war taunt/surrender set) |
| $31 | そのカラダで たたかえると / おもっているのか ムダに / イノチをすてることはない | Think you can fight in that state? Do not throw your life away | - | no OpenMsgWindow caller found |
| $32 | あんなクンシュのために / イノチをかけることはない / おとなしくグンをひかないか | No life should be risked for such a lord - why not stand down your army? | - | no OpenMsgWindow caller found |
| $33 | キミほどの ジンブツを / テキに したくはない / われらとトモに たたかわぬか | I'd rather not face a man of your caliber - fight alongside us? | - | no OpenMsgWindow caller found |
| $34 | ほざくなっ ゲロウがっ! | Silence, you cur (gerou 下郎)! | - | no OpenMsgWindow caller found |
| $35 | しかたがない / ショウブは ゴジツにつけるぞ! | It cannot be helped - the bout is settled in 5 days (gojitsu 後日?) | - | no OpenMsgWindow caller found |
| $36 | そうかもしれんな | Perhaps you are right | - | no OpenMsgWindow caller found |
| $37 | これも テンメイかもしれん / キミのコトバに したがおう | This too may be heaven's will (tenmei 天命) - I will follow your word | - | no OpenMsgWindow caller found |
| $38 | 〈名〉が / ハイカにくわわりました | <mei> joined your ranks (haika 配下) | TacticDialog_Execute $C1CE | ok - TacticDialog_Execute (duel persuade success) |
| $39 | しかし / ダメージをあたえられない | but no damage can be dealt | DuelStrike_ApplyGauge $B99D | ok - DuelStrike_ApplyGauge (OfficerReinforceScene $39 renders bank 13) |
| $3A | われこそは 〈名〉なり / いざジンジョウにショウブせよ | I am <mei>! Settle this on the field (jinjou 陣上)! | - | no OpenMsgWindow caller found |
| $3B | あいてにとって フソクはない / かかってこい! | No weakness on my side - come at me! | - | no OpenMsgWindow caller found (CastleCommandDispatch $3B renders bank 13) |
| $3C | ニゲアシばかり はやいヤツめ! | All you are quick at is running away! | DuelPursue_EscapeRoll $BB35 | ok - DuelPursue_EscapeRoll |
| $3D | 〈名〉は おいうちにあい / ⟨数⟩の ダメージをうけた | <mei> was caught in the pursuit and took <su> damage | DuelPursue_ApplyStrike $BB90 | ok - DuelPursue_ApplyStrike |
| $3E | 〈名〉は セイコウのケンを / てに いれました | <mei> obtained the Seikou (青釭) Sword | - | ok - Spoils_GrantWeapon (item-indexed); kanji confirmed vs equipment_catalog.csv id 5 |
| $3F | 〈名〉は イテンのケンを / てに いれました | ...the Yitian (iten 倚天) Sword | - | ok - Spoils_GrantWeapon (item-indexed) |
| $40 | 〈名〉は シチセイホウケンを / てに いれました | ...the Seven-Star Treasure Sword (shichisei houken 七星宝剣) | - | ok - Spoils_GrantWeapon (item-indexed) |
| $41 | 〈名〉は リュウガトウを / てに いれました | ...the Ryuga (龍牙) Blade | - | ok - Spoils_GrantWeapon (item-indexed); kanji confirmed vs equipment_catalog.csv id 14 |
| $42 | 〈名〉は リュウリンのヨロイを / てに いれました | ...the Ryurin (竜鱗) Armor | Spoils_GrantArmor $C44C | ok - Spoils_GrantArmor; kanji confirmed vs equipment_catalog.csv id 31 (竜鱗の鎧, 竜 not 龍) |
| $C0 | 〈名〉さま / どのブショウにメイレイをだしますか | My lord <mei> - to which officer do you give orders? | WarOrder_Wait $A09F | ok - WarOrder_Wait |
| $C1 | いどう       こうげき / けいりゃく     たいき / たいきゃく / メイレイを してください | menu: move / attack / stratagem / hold / retreat - give your orders | WarOrder_Input $A0EF | ok - WarOrder_Input |
| $C2 | どのブタイをテイサツしますか | Which unit shall be scouted? | - | ok - runtime arg (TurnEndState_Confirm loads $050A) |
| $C3 | どのテキにコウゲキを しかけますか | Which enemy shall we attack? | UnitAttack_Init $A2A9 | ok - UnitAttack_Init |
| $C4 | そこにはテキはおりません | There is no enemy there | - | ok - runtime/table arg |
| $C5 | かならずやテキを けちらして / まいります | We shall surely rout the enemy and return | - | ok - UnitAttack_SelectTarget (seeds shared $CB) |
| $C6 | どこへ イドウしますか / コマをすすめてください | Where to move? Advance the piece | MoveState_Init $A472 | ok - MoveState_Init |
| $C7 | どのようなケイリャクを もちいりましょう | Which stratagem (keiryaku 計略) shall we employ? | StratagemState_MenuSetup $A8DA | ok - StratagemState_MenuSetup |
| $C8 | メイレイとあれば しかたありません / シロへ タイキャクしましょう | If it is your order, so be it - we withdraw to the castle | RetreatState_PickCastle $BA2D | ok - RetreatState_PickCastle |
| $C9 | メイレイとあれば しかたありません / ゼングンをひきいて ひとまず / シロへ タイキャクしましょう | ...leading the whole army, we withdraw to the castle | - | ok - RetreatState_PickCastle branch (no direct seed found) |
| $CA | ここは ぜんぐんタイキして / テキのでかたを まちましょう | All armies hold position and await the enemy's move | TurnEndState_Init $BCBA | ok - TurnEndState_Init (taiki たいき) |
| $CB $CC $CD $CE $CF $D0 | かならずやテキを けちらして / まいります | We shall surely rout the enemy and return | UnitAttack_SelectTarget $A308 | ok - UnitAttack_SelectTarget (shared stream $CB-$D0) |
| $D1 | ⟨数00⟩ / ⟨数01⟩ / ⟨数02⟩ / ⟨数03⟩ | unit gauge panel <su00-03> | CommandPanelInit $AA57 | ok - CommandPanelInit |
| $D2 | 〈名〉さま / かくブタイにメイレイをだしてください | My lord - give orders to each unit | SideAFormationMenuInput $CE9D; SideBFormationMenuInput $CFF7 | ok - SideA/BFormationMenuInput |
| $D3 | 〈名〉は / ついに ちからつきた | <mei>'s strength gave out | BattleDefeatEventCheck $A2DE; BattleDefeatEventCheck $A321; BattleResultDamageApply $A4B1 | ok - BattleDefeatEventCheck x2; BattleResultDamageApply |
| $D4 | ジンケイをきめてください | Choose your formation (jinkei 陣形) | SideAFormationPanelInit $CE47@0E; SideBFormationPanelOpen $CFA4 | ok - SideA/BFormationPanelInit |
| $D5 | ⟨数00⟩イ⟨数01⟩イ / ⟨数02⟩⟨数03⟩ / ⟨数04⟩⟨数05⟩ | strength gauge panel | WarResultPanel $C9A3; WarResultPanel $CA2B | no war-context caller found (CountryRotationDispatch renders bank 13) |
| $D6 | 〈名〉さま / どのシロに たいきゃくしますか | My lord - to which castle do we retreat? | RetreatState_Init $B966 | ok - RetreatState_Init |
| $D7 | 〈省00〉⟨数00⟩  〈省01〉⟨数01⟩ / 〈省02〉⟨数02⟩  〈省03〉⟨数03⟩ / 〈省04〉⟨数04⟩  〈省05〉⟨数05⟩ / 〈省06〉⟨数06⟩  〈省07〉⟨数07⟩ | province roster <sho NN><su> list | RetreatState_Select $B996; UnitWithdraw $CD95; UnitGarrison $D326 | ok - RetreatState_Select |
| $D8 | ぶじ シロへもどりました | Returned safely to the castle | RetreatState_Confirm $BA60 | ok - RetreatState_Confirm |
| $D9 | もどるシロが ありません | There is no castle to return to | RetreatState_Select $B9B2 | ok - RetreatState_Select (empty list) |
| $DA | そのシロには たいきゃくできません | Cannot retreat to that castle | CountrySelect_InitRecords $D774; CountrySelect_SelectMenuEntry $D809; RetreatState_PickCastle $BA16 | ok - RetreatState_PickCastle; CountrySelect_InitRecords |
| $DB | たたかいは おわりました | The battle is over | CountrySelect_PickEntry $D89D | ok - CountrySelect_PickEntry |
| $DC | 〈名p 20〉さま / どのシロに たいきゃくしますか | My lord (ruler card) - to which castle retreat? | UnitWithdraw $CD48 | ok? - UnitWithdraw (garrison-swap castle pick) |
| $DD | 〈名p 20〉さま / たいきゃくするブショウをえらんでください | My lord - choose the officers to withdraw | - | no direct OpenMsgWindow caller (EventMessageScene_HeroNamePanel renders bank 13) |
| $DE | 〈名7 00〉  〈名7 01〉  〈名7 02〉 / 〈名7 03〉  〈名7 04〉  〈名7 05〉 / 〈名7 06〉  〈名7 07〉  〈名7 08〉 / 〈名7 09〉  〈名7 0A〉  〈名7 0B〉 / 〈名7 0C〉  〈名7 0D〉  〈名7 0E〉 / 〈名7 0F〉  〈名7 10〉  〈名7 11〉 / 〈名7 12〉  〈名7 13〉  〈名7 14〉 | officer selection grid <mei7 00-14> | UnitWithdraw $CE6F; UnitGarrison $D3D0 | ok - UnitWithdraw; UnitGarrison |
| $DF | 〈名p 20〉さま / このシロにはいるブショウが10にんを / こえました ほかのシロへいどうしてください | Officers entering this castle would exceed 10 - move some elsewhere | UnitGarrison $D306 | ok - UnitGarrison |
| $E0 | -(graphics/no text) | garrison-result graphics panel (no text) | - | ok - WarResultPanel (direct $0310 write) |
| $E1 | -(graphics/no text) | garrison-result graphics panel (no text) | - | push target of bank-12 streams; no OpenMsgWindow caller |
| $E2 | -(graphics/no text) | garrison-result graphics panel (no text) | - | push target; no OpenMsgWindow caller |
| $E3 | -(graphics/no text) | garrison-result graphics panel (no text) | - | push target; no OpenMsgWindow caller |
| $E4 | -(graphics/no text) | garrison-result graphics panel (no text) | - | ok - StrategyRequestDispatch $CD3C - but strategy context renders bank 13 |
| $E5 | 〈名p 20〉さま / ざいやにおとすブショウをえらんでください | My lord - choose the officers to leave in the field | UnitWithdraw $CE4F; UnitGarrison $D3A8 | ok - UnitWithdraw |
| $E6 | 〈名p 20〉さま / ブショウは ざいやにおちました | The officer was left behind in the field | UnitWithdraw $CEFD; UnitGarrison $D456 | ok - UnitWithdraw; UnitGarrison |
| $E7 $FF | ゜ / ホイント  ⟨数00⟩ | hint <su00> panel (shared with $FF) | BattleTacticsMenuInit $AD1A | ok - BattleTacticsMenuInit |
| $E8 | -(graphics/no text) | graphics panel (no text) | - | no caller - ProvinceRebellionEvent $E8 renders bank 13 |
| $E9 | ⟨数00⟩ア   ⟨数01⟩ア / ⟨数02⟩ア   ⟨数03⟩ア / ⟨数04⟩ア   ⟨数05⟩ア / ⟨数06⟩    ⟨数07⟩ | cavalry-count gauge panel | - | no OpenMsgWindow caller found |
| $EA | ちょうはつに せいこうしました | The taunt (chouhatsu 挑発) succeeded | BattleTacticsRowTaunt $AFC0 | ok - BattleTacticsRowTaunt |
| $EB | ちょうはつは しっぱいにおわりました | The taunt (挑発) failed | BattleTacticsRowTaunt $AFCB | ok - BattleTacticsRowTaunt |
| $EC | 〈名〉は とうぶんのあいだ / うごけないでしょう | <mei> will be immobile for a while | BattleTacticsRowBind $AFE4 | ok - BattleTacticsRowBind (hit) |
| $ED | ジュバクは しっぱいにおわりました | The bind (jubaku 縛) failed | BattleTacticsRowBind $AFDE | ok - BattleTacticsRowBind (miss) |
| $EE | ゆみやが とおくへ とぶでしょう | The arrows will fly far | BattleTacticsRowCrossbowVolley $B010 | ok - BattleTacticsRowCrossbowVolley |
| $EF | とうぶんのあいだ / シキがあがるでしょう | Morale (shiki 士気) will rise for a while | BattleTacticsRowMoraleBoost $B030 | ok - BattleTacticsRowMoraleBoost |
| $F0 | ゆみやに ひをつけましょう | Set the arrows alight | BattleTacticsRowFireArrows $B07E | ok - BattleTacticsRowFireArrows |
| $F1 | ひをはなちましょう | Loose the fire | BattleTacticsRowExplosion $B0A8; AiTacticPointSpend $D49A | ok - BattleTacticsRowExplosion; AiTacticPointSpend |
| $F2 | マジックポイントが たりません | tactic-point graphics panel (no text) | - | no OpenMsgWindow caller found |
| $F3 | -(graphics/no text) | blank placeholder (single $80) | - | ok - StratagemState_Init (direct $0310=$F3, war context) |
| $F4 | どのテキにケイリャクを かけましょう | On which enemy shall we use the stratagem? | StratagemState_Menu_Enough $A9D6 | ok - StratagemState_Menu_Enough |
| $F5 | ケイリャクは せいこうです | The stratagem succeeded | - | table - @ResultMsgTable via StratagemPhase_ShowResultMsg |
| $F6 | 〈名〉に ケイリャクをかけましょう | Use the stratagem on <mei> | - | table - @ResultMsgTable |
| $F7 | ここでは ほかの ケイリャクを / もちいたほうが よいでしょう | A different stratagem would serve better here | StratagemState_SelectTarget_Proceed $AA19 | ok - StratagemState_SelectTarget_Proceed |
| $F8 | ケイリャクは しっぱいに おわりました / もうしわけ ありません | The stratagem failed - our apologies | - | ok - StratagemState_Cancel (@CancelMsgTable) |
| $F9 | 〈名〉さま / ブショウをどこに はいちしますか / ばしょを きめてください | My lord - where shall the officers be placed? Choose the spot | ArmyDeploy $C273; ArmyDeploy $C2B2 | ok - ArmyDeploy x2 |
| $FA | 〈名〉は / たいきゃくしました | <mei> withdrew | BattleRetreatEventCheck $A360; BattleRetreatEventCheck $A392 | ok - BattleRetreatEventCheck x2 |
| $FB | それでは ひをはなってテキのブタイを / やきはらいましょう | Loose fire and burn away the enemy unit | - | table - stratagem confirm panels $FB-$FE |
| $FC | それでは ワナをしかけてテキのブショウに / いたでをおわせましょう | Set a trap and wound the enemy officer | - | table |
| $FD | テキのまわりでケムリをたき / テキをあしどめしましょう | Raise smoke and pin the enemy in place | - | table |
| $FE | フクヘイをおいてキシュウを / かけましょう | Set ambushers (fukuhei 伏兵) and launch a surprise attack (kishuu 奇襲) | - | table |
| $60 | カワをはんらんさせすいじょうのテキを / しずめてしまいましょう | Flood the river and sink the enemy on the water | - | table - ExecuteAction stratagem plan panels $60-$6B |
| $61 | それでは ひやをはなち テキのコメを / やきはらいましょう | Loose fire arrows and burn the enemy's rice | - | table |
| $62 | ジョウナイのブタイにキシュウを / しかけましょう | Surprise-attack the units inside the castle | - | table |
| $63 | テキのブタイをかくらんし どうしうちを / させましょう | Throw the enemy unit into confusion and cross-fire | - | table |
| $64 | テキのブショウをせっとくし みかたに / つけましょう | Persuade the enemy officer to join our side | - | table |
| $65 | おおきなイシをなげおとしテキのヘイを / たおしましょう | Drop great stones and crush the enemy soldiers | - | table |
| $66 | テキのふねをクサリでつなぎカワを / わたれないようにしましょう | Chain the enemy boats together so they cannot cross the river | - | table |
| $67 | モリのナカに ヘイシを / マイフクさせましょう | Have soldiers lie in ambush (maifuku 埋伏) in the woods | - | table |
| $68 | せきをつくり ほうかいさせることで / テキをスイボツさせましょう | Build a dam and drown the enemy in the flood (suibotsu 水没) | - | table |
| $69 | レンドをつかってテキヘイを / たおしましょう | Mow down the enemy soldiers with repeating crossbows (rendo 連弩) | - | table |
| $6A | しほうから ひをはなって テキヘイを / やきはらいましょう | Set fires on all four sides and burn the enemy out | - | table |
| $6B | セキジンをきずきテキブタイを / ほうむりましょう | Raise stone sentinels (sekijin 石人) and bury the enemy unit | - | table |
| $6C | テキのヘイが ⟨数⟩にん へりました | The enemy's soldiers fell by <su> | StratagemState_Cancel $AB14 (@indexed @CancelMsgTable) | table - stratagem results $6C-$73 |
| $6D | テキのブショウのタイリョクが / ⟨数⟩へりました | The enemy officer's strength fell by <su> | StratagemState_Cancel $AB14 (@indexed @CancelMsgTable) | table |
| $6E | テキは しばらく うごけないでしょう | The enemy cannot move for a while | StratagemState_Cancel $AB14 (@indexed @CancelMsgTable) | table |
| $6F | テキのヒョウロウが⟨数⟩へりました | The enemy's provisions (hyourou 兵糧) fell by <su> | StratagemState_Cancel $AB14 (@indexed @CancelMsgTable) | table |
| $70 | 〈名〉をみかたにつけました | Won <mei> over to our side | StratagemState_Cancel $AB14 (@indexed @CancelMsgTable) | table |
| $71 | テキはしばらく カワをわたれないでしょう | The enemy will be unable to cross the river for a while | StratagemState_Cancel $AB14 (@indexed @CancelMsgTable) | table |
| $72 | テキはセキジンにまよいこみました | The enemy wandered into the stone sentinels | StratagemState_Cancel $AB14 (@indexed @CancelMsgTable) | table |
| $73 | けいりゃくは しっぱいに おわりました / もうしわけありません | The stratagem failed - our apologies | StratagemState_Cancel $AAD2 | ok - StratagemState_Cancel (@CancelMsgTable) |
| $74 | われこそは〈名〉! てきしょう〈名〉よ / ショウブしろ | I am <mei>, rival general (tekishou 敵将) of <mei>! Fight me! | - | table - enemy strategist duel challenge |
| $75 | おムてきしょうをジュバクしました | Bound the enemy champion (jubaku 縛) | - | table |
| $77 | ジュバクにしっぱいしました | Failed to bind the enemy champion | - | table |
| $78 | ゴウドをつかって こうげきをします | Attack using the crossbow volley (ゴウド = 強弩 kyoudo) | - | ok (user-confirmed) - battle-mode crossbow-volley tactic; code = BattleTacticsRowCrossbowVolley $B00E (prg_0e_0f_battle); label renamed MenuStream_pos78_CrossbowVolleyAttackMsg |
| $79 | シキをコウジョウさせました | Morale (shiki 志気) was raised | - | table - battle-mode morale-boost tactic announcement; code = BattleTacticsRowMoraleBoost $B02E (prg_0e_0f_battle) |
| $7A | ヒヤをつかって こうげきをします | Attack using fire arrows (hiya 火矢) | - | table - battle-mode fire-arrows tactic announcement; code = BattleTacticsRowFireArrows $B07C (prg_0e_0f_battle) |
| $7B | みうごきが とれません | Cannot move | AiTauntSceneOpen $D6D6 | ok - AiTauntSceneOpen |
| $7C | うける     ことわる / 〈名〉が / いっきうちを もうしこんできました | accept / refuse - <mei> challenges you to single combat (ikkiuchi 一騎打ち) | AiTauntSceneStep $D74D | ok - AiTauntSceneStep |
| $7D | 〈名〉は コウフクしました | <mei> surrendered (降伏) | AiCommanderRoutCheck $D2A7; AiCommanderRoutCheck $D2D0 | ok - AiCommanderRoutCheck x2 |
| $7E | 〈名〉は おいうちにあい / ⟨数⟩の ダメージをうけた | caught in the pursuit - took <su> damage | BattleResultRetreatInputWait $A44A@0E | ok - BattleResultRetreatInputWait |
| $A0 | テキが コウゲキをしかけてきました | The enemy launched an attack | AiMarch $BFB5 | ok - AiMarch |
| $A1 | テキが ケイリャクをしかけてきました | The enemy used a stratagem | AiMarch $C038 | ok - AiMarch |
| $A2 | しかし シッパイにおわったようです | ...but it appears to have failed | AiMarch $C0BB | ok - AiMarch |
| $A3 | ヘイが ⟨数⟩ニンへりました | Soldiers fell by <su> | AiMarch $C0F8 (@indexed @CancelMsgTable) | ok - AiMarch |
| $A4 | タイリョクが ⟨数⟩へりました | Strength fell by <su> | AiMarch $C0F8 (@indexed @CancelMsgTable) | ok - runtime/table arg |
| $A5 | うごきが とれなくなりました | Movement was lost | AiMarch $C0F8 (@indexed @CancelMsgTable) | ok - runtime/table arg |
| $A6 | ヒョウロウが ⟨数⟩へりました | Provisions fell by <su> | AiMarch $C0F8 (@indexed @CancelMsgTable) | ok - runtime/table arg |
| $A7 | はい       いいえ / ムラに はいりますか | yes/no - enter the village? | MoveState_CheckDest_Found $A51C | ok - MoveState_CheckDest_Found; CastleCommandDispatch x2; WarehouseCommandDispatch |
| $A8 | かう      うる / ここは コメヤです なにをしますか | buy / sell - this is the rice shop; what will you do? | WarTownActionDispatch/State1_BuyRice $C217; WarTownActionDispatch/State2_SellRice $C2EE; WarTownActionDispatch/State9_RouteNextAction $C824 | ok - WarTownActionDispatch x3 |
| $A9 | コメ / キン100で コメ⟨数⟩がソウバです / コメをどれだけ かいますか | <su> rice per 100 gold (souba 相場 market rate) - how much to buy? | WarTownActionDispatch/State0_ShowActionPanel $C1DB | ok - WarTownActionDispatch |
| $AA | コメ / コメ100で キン⟨数⟩がソウバです / コメをどれだけ うりますか | <su> gold per 100 rice - how much to sell? | WarTownActionDispatch/State0_ShowActionPanel $C16C | ok - WarTownActionDispatch |
| $AB | コメ⟨数⟩を コウニュウしました | Bought <su> rice (kounyuu 購入) | WarTownActionDispatch/State1_BuyRice $C2BD | ok - WarTownActionDispatch |
| $AC | キン⟨数⟩を てにいれました | Gained <su> gold | WarTownActionDispatch/State2_SellRice $C38F | ok - WarTownActionDispatch |
| $AD | ここはブキヤです なにをかいますか | This is the armory - what will you buy? | WarTownActionDispatch/State7_ArmoryPurchaseApply $C677; WarTownActionDispatch/State9_RouteNextAction $C837 | ok - WarTownActionDispatch |
| $AE | ⟨数⟩ / ⟨数⟩ / ⟨数⟩ / ⟨数⟩ / どれをかいますか | <su> x4 price list - which one? | WarTownActionDispatch/State5_ArmoryGridSetup $C50F | ok - WarTownActionDispatch |
| $AF | あたらしいブキを かいました / いままで つかっていたブキは / ブキヤに ひきとってもらいます | Bought a new weapon - the old one is bought back by the armory | WarTownActionDispatch/State7_ArmoryPurchaseApply $C725 | ok - WarTownActionDispatch |
| $B0 | キンが たりません | Not enough gold | WarTownActionDispatch/State4_HospitalHeal $C447; WarTownActionDispatch/State7_ArmoryPurchaseApply $C6B6 | ok - WarTownActionDispatch x2 |
| $B1 | ここは ビョウインです | This is the hospital (byouin 病院) | WarTownActionDispatch/State9_RouteNextAction $C841 | ok - WarTownActionDispatch |
| $B2 | はい       いいえ / チリョウに キン50かかります / よろしいですか | yes/no - treatment costs 50 gold; proceed? | WarTownActionDispatch/State3_CheckVitalityDeficit $C3E6 | ok - WarTownActionDispatch |
| $B3 | あなたには チリョウのヒツヨウが / ありません | You need no treatment | WarTownActionDispatch/State3_CheckVitalityDeficit $C3CB | ok - WarTownActionDispatch |
| $B4 | ブショウの タイリョクが / ⟨数⟩ かいふくしました | Strength restored by <su> | WarTownActionDispatch/State4_HospitalHeal $C4A8 | ok - WarTownActionDispatch |
| $B5 | 〈名〉さま およろこびください / テキは タイキャクしたもようです | My lord, rejoice - the enemy appears to have withdrawn | - | table/runtime arg |
| $B6 | セキジンに まよいこんで / しまいました | Wandered into the stone sentinels (sekijin 石人) | AiMarch $C0F8 (@indexed @CancelMsgTable) | table/runtime arg |
| $B7 | 〈名〉は テキにねがえりました | This country has no officers | AiMarch $C0FD; AiMarch $C0F8 (@indexed @CancelMsgTable) | ok - AiMarch - but strategy context renders bank 13 |
| $B8 | テキのフクヘイに キシュウをうけ / ヘイが ⟨数⟩ニンへりました | Ambushed by enemy ambushers - soldiers fell by <su> | MoveState_Select $A5B6 | ok - MoveState_Select (march ambush) |
| $B9 | フクヘイが キシュウをかけて / テキのヘイが ⟨数⟩ニンへりました | Our ambushers struck - enemy soldiers fell by <su> | - | table/runtime arg |
| $BA | ヘイ100ニンを マイフクしました | Buried 100 soldiers in ambush (maifuku 埋伏) | StratagemState_Cancel $AB14 (@indexed @CancelMsgTable) | table/runtime arg |
| $BB | テキのブショウのタイリョクが ⟨数⟩ / テキのヘイが ⟨数⟩ニンへりました | Enemy officer's strength <su>; enemy soldiers fell by <su> | StratagemState_Cancel $AB14 (@indexed @CancelMsgTable) | FLAG 2026-10-12: no war-context caller; bank-13 copy is blank; the $BB 'ruler status overlay' seeders render bank 13 |
| $BC | テキのケイリャクに かかって / うごきが とれません | Caught by the enemy's stratagem - cannot move | WarOrder_Menu $A171 | ok - WarOrder_Menu |
| $BD | 〈名〉は / タイキャクしたようです | <mei> appears to have withdrawn | AiMarch $C175 | ok - AiMarch |
| $BE | 〈名〉さま / タタカイが ながびいておりますので / いったん タイキャクせねばなりません | The battle drags on - we must withdraw for now | - | table/runtime arg |
| $BF | 〈名〉さま / ヒョウロウが つきてしまいました / これいじょうは たたかえません | Provisions are spent - we can fight no longer | - | table/runtime arg |
| $48 | あなたでは このブキを / つかいこなすことは ふかのうです | You cannot master this weapon | WarTownActionDispatch/CheckSpecialEquipment $C78E | ok - WarTownActionDispatch |
| $49 | すみません / それは うりきれてしまいました | Sorry - that is sold out | WarTownActionDispatch/CheckSpecialEquipment $C7AB | ok - WarTownActionDispatch |
| $4A | 〈名〉は レベルがあがりました / ブリョクが ⟨数⟩あがりました | <mei> leveled up; Might (buryoku 武力) +<su> | - | table/runtime arg |
| $4B | 〈名〉は あたらしいケイリャクを / おぼえました | <mei> learned a new stratagem | MoveState_Cancel $A647; StratagemState_CancelConfirm $AB8D; TurnEndState_Cancel $BD8B; OfficerLevelUp $C6E7 | ok - OfficerLevelUp |
| $4C | もうすこし ちかづかなければ / ケイリャクを しかけることはできません | Must close in further before using a stratagem | StratagemState_SelectTarget_ShowFull $AA2B | ok - StratagemState_SelectTarget_ShowFull |
| $4D | 〈名〉は レベルがあがりました | <mei> leveled up | OfficerLevelUp $C758; UnitGarrison/OfficerLevelUpCheck $DF20 | ok - OfficerLevelUp; TacticalMapScene |
| $4E | 〈名〉は / ついに ちからつきた | <mei>'s strength gave out | StratagemState_Cancel $AB0E; AiMarch $C0F2 | ok - AiMarch; StratagemState_Cancel (@CancelMsgTable) |
| $4F | ヘイが ⟨数⟩ニン / タイリョクが ⟨数⟩へりました | Soldiers fell by <su>; strength fell by <su> | AiMarch $C0F8 (@indexed @CancelMsgTable) | table/runtime arg |
| $50 | 〈名〉さま およろこびください / テキのシロを センリョウしました | My lord, rejoice - we captured the enemy castle (senryou 占領) | - | table/runtime arg |
| $51 | 〈名〉さま / シロが センリョウされてしまいました / これいじょうは たたかえません | My lord - our castle was captured; we can fight no longer | - | table/runtime arg |
| $52 | ぜんぐんタイキャクをして / たいせいを たてなおしましょう | Withdraw the whole army and regroup | RetreatState_PickCastle $BA28 | ok - RetreatState_PickCastle (all-army branch) |
| $53 | 〈名〉さま / テキは そうだいしょうをうしなって / タイキャクしていきます | The enemy lost its commander-in-chief (soudaishou 総大将) and is withdrawing | - | table |
| $54 | 〈名〉さま / わがグンは そうだいしょうをうしなって / そうくずれです | We lost our commander-in-chief - total collapse | - | table |
| $55 | 〈名〉グンは ゼンメツしました | The army of <mei> was annihilated (zenmetsu 全滅) | UnitGarrison/WarCollapseCheck $DE7F | ok - TacticalMapScene |

## Bank $13 - strategy / event / new-game copies (other states)

| Pos | JP text | EN translation | Caller(s) | Validation |
|-----|---------|----------------|-----------|------------|
| $1F | 〈名〉さま / どのシロに メイレイを あたえますか | My lord <mei> - to which castle do you give orders? | MapRulerIntroDispatch/MapRulerIntroInit $A0DC | ok - MapRulerIntroDispatch |
| $20 | 〈名〉さま / こんげつのメイレイショは ⟨数⟩まいです | This month's command sheets (meireisho 命令書): <su> | CountryRotationDispatch/OverlayInit $A131 | ok - CountryRotationDispatch |
| $21 | 〈名〉さま シロなどありません | There is no castle there | RulerSuccessionScene $BEC9; MapRulerIntroDispatch/MapRulerIntroCameraOffMapExit $A124 | ok - MapRulerIntroDispatch; RulerSuccessionScene |
| $22 | 〈名〉さま テキコクのシロです | That is an enemy country's castle | RulerSuccessionScene $BECE; MapRulerIntroDispatch/MapRulerIntroCameraNotOwnedExit $A129 | ok - MapRulerIntroDispatch; RulerSuccessionScene |
| $23 | どこへ いきますか | Where to go? | CommandCategoryMenuDispatch/CommandCategoryMenuScreenInit $A1CC | ok - CommandCategoryMenuDispatch |
| $24 | そこには シロなどありません | There is no castle there | CastleCommandDispatch/CastleMoveTargetSelect $A774; ArmyCommandDispatch/SortieTargetPadPoll $AFA6; ArmyCommandDispatch/ReconTargetPadPoll $B4A7; WarehouseCommandDispatch/WarehouseDestProvinceSelect $B861; IntrigueCommandDispatch $CF84 | ok - CastleCommandDispatch; ArmyCommandDispatch |
| $25 | クニづくり     ブショウのいどう / ジョウホウあつめ  ボウサイ / サクリャク     キロクする / ここはシロです メイレイをしてください | castle menu: land dev / industry / town dev - this is the castle; give your orders | CastleCommandDispatch/CastleMenuScreenInit $A2F5 | ok - CastleCommandDispatch |
| $26 | トチの カイコン / サンギョウの ハッテン / マチの カイハツ / なにを なさいますか | land reclamation / industry development / town development - what will you do? | CastleCommandDispatch/CastleCommandRouteDispatch $A370; CastleCommandDispatch/CastleDevAnimWait $A499; CastleCommandDispatch/CastleDevConfirmGate $A534 | ok - CastleCommandDispatch |
| $27 | だれに いかせますか で えらんでください | Who shall be sent? Choose | CastleCommandDispatch/CastleCommandRouteDispatch $A39F; CastleCommandDispatch/CastleDevTargetMenu $A45C; CastleCommandDispatch/CastleMoveTargetSelect $A757; CastleCommandDispatch/CastleDisasterCapCheck $ABFD; ArmyCommandDispatch/SortieTargetPadPoll $AF9C; ArmyCommandDispatch/SortieProvisionDialog $B123; IntrigueCommandDispatch $CD1E; IntrigueCommandDispatch $CFC2 | ok - CastleCommandDispatch x3; ArmyCommandDispatch |
| $28 | キン ⟨数⟩が ヒツヨウです | Requires <su> gold | TownCommandDispatch $C53E; TownCommandDispatch $C6D5 | ok - CastleCommandDispatch; TownCommandDispatch; WarehouseCommandDispatch |
| $29 | はい      いいえ / メイレイショが 1マイ ヒツヨウです | yes/no - requires 1 command sheet (命令書) | CastleCommandDispatch/CastleDevAmountCheck $A563; CastleCommandDispatch/CastleMoveProceedSelect $A80B; CastleCommandDispatch/CastleScoutAnimWait $A8A6; CastleCommandDispatch/CastleSavePromptWait $AC1E; ArmyCommandDispatch/ArmyCommandMenuInput $AEC1; ArmyCommandDispatch/SortieMarchDialogSetup $B240; ArmyCommandDispatch/ConscriptionPanelInput $B361; WarehouseCommandDispatch/WarehouseGoodsAmountPanel $B97B; WarehouseCommandDispatch/WarehouseOfficerGiveGate $BCE3; WarehouseCommandDispatch/WarehousePopulaceAmountPanel $BDFE; TownCommandDispatch $C336; TownCommandDispatch $C411; TownCommandDispatch $C494; TownCommandDispatch $C574; TownCommandDispatch $C9AF; IntrigueCommandDispatch $CD7B; IntrigueCommandDispatch $D00C | ok - CastleCommandDispatch; ArmyCommandDispatch; WarehouseCommandDispatch |
| $2A | いま このシロには それほどの / キンが ありません / べつのメイレイを してください | This castle lacks that much gold - choose another order | CastleCommandDispatch/CastleDevAmountCheck $A56D; CastleCommandDispatch/CastleScoutFindDialog $ABBE; TownCommandDispatch $C57E; IntrigueCommandDispatch $D2D3 (@X = $2A gold gift) | ok - CastleCommandDispatch x2; WarehouseCommandDispatch |
| $2B | トチのカチが ⟨数⟩あがりました | Land value +<su> | CastleCommandDispatch/CastleDevExecute $A623 | ok - CastleCommandDispatch |
| $2C | サンギョウチが ⟨数⟩あがりました | Industry +<su> | CastleCommandDispatch/CastleDevExecute $A636 | ok - CastleCommandDispatch |
| $2D | ジンコウが ⟨数⟩00ふえました | Population +<su>00 | CastleCommandDispatch/CastleDevExecute $A65E | ok - CastleCommandDispatch |
| $2E | どこへ イドウさせますか / で えらんでください | Where shall the officers be transferred? (castle command bushou no idou 武将の移動) | CastleCommandDispatch/CastleCommandRouteDispatch $A387 | ok - CastleCommandDispatch |
| $2F | そのシロへは イドウできません / べつの シロを えらんでください | Cannot move there - pick another castle | CastleCommandDispatch/CastleMoveTargetSelect $A779 | ok - CastleCommandDispatch |
| $30 | 〈名〉さま / 〈名〉が セイジンして / ハイカに くわわりました | <mei> came of age (seijin 成人) and joined your ranks (haika 配下) | OfficerReinforceScene/ReinforceOverlayWait $AF87 | ok - OfficerReinforceScene |
| $31 | では いってまいります | Then I shall be on my way | CastleCommandDispatch/CastleMoveDestOwner $A878; CastleCommandDispatch/CastleScoutDialogWait $A8D9; WarehouseCommandDispatch/WarehouseGoodsTransferApply $B9FB | ok - CastleCommandDispatch |
| $32 | はい        いいえ / このシロを すてるのですか | yes/no - abandon this castle? | CastleCommandDispatch/CastleMoveListAnimWait $A7BC; ArmyCommandDispatch/SortieRosterTroopSumLoop $B044 | ok - CastleCommandDispatch |
| $33 | なかなかみどころのある ブショウを / みつけました | Found a most promising officer | CastleCommandDispatch/CastleScoutExecute $A92C | ok - CastleCommandDispatch |
| $34 | タカラを ⟨数⟩つ みつけました / クラに しまっておきます | Found <su> treasures - stored them in the warehouse | CastleCommandDispatch/CastleScoutFoundTreasure $A96B | ok - CastleCommandDispatch |
| $35 | ざんねんですが / なにも みつかりませんでした | Regrettably, nothing was found | CastleCommandDispatch/CastleScoutNothingFound $A93B | ok - CastleCommandDispatch |
| $36 | はい      いいえ / しかし かんたんには ハイカに / なってくれそうでは ありません / みずから せっとくに いきますか | They will not join easily - go persuade (setoku 説得) them yourself? | CastleCommandDispatch/CastleScoutResultGate $AA2C | ok - CastleCommandDispatch |
| $37 | はい      いいえ / ハイカに いたしますか | yes/no - shall I join your ranks (配下)? | CastleCommandDispatch/CastleScoutResultGate $AA22 | ok - CastleCommandDispatch |
| $38 | はい      いいえ / しかし そのブショウは / キン ⟨数⟩を ようきゅうしています / あたえますか | That officer demands <su> gold - pay it? | CastleCommandDispatch/CastleScoutResultGate $AA86 | ok - CastleCommandDispatch |
| $39 | ごきたいに そえるよう / ゼンリョクで ドリョクします | I shall strive with all my might to your liking | OfficerReinforceScene/ReinforceCardWait $AFB5; CastleCommandDispatch/CastleScoutRecruitDone $AD3E | ok - OfficerReinforceScene |
| $3A | わたしは まだ ひとにつかえるきは / ありません / きょうのところは おひきとりください | I am not yet fit to serve - come for me another day | CastleCommandDispatch/CastleScoutFindDialog $ABA1 | ok - CastleCommandDispatch |
| $3B | ドウメイ      リカン / ヒキヌキ / どの サクリャクを つかいますか | alliance / discord / poaching - which scheme (sakuryaku 策略) will you use? | CastleCommandDispatch/CastleCommandRouteDispatch $A3C0; IntrigueCommandDispatch $CD85 | ok - CastleCommandDispatch |
| $3C | クニを えらんでください | Choose a country | IntrigueCommandDispatch $CBDC | ok - IntrigueCommandDispatch |
| $3D | どのクニと ドウメイを むすびますか | With which country shall we form an alliance? | - | ok - IntrigueCommandDispatch |
| $3E | どのシロの ブショウにしかけるのか / えらんでください | Pick which castle's officer to scheme against | IntrigueCommandDispatch $CB78; IntrigueCommandDispatch $CF0C | ok - IntrigueCommandDispatch |
| $3F | たいへんです 〈省00〉でも / ヒデリがはっせいしました | Disaster - drought (hideri 日照) has struck, even in <sho> | DroughtDamageScene/DamageProvinceApply $A85C | ok - DroughtDamageScene |
| $40 | それは ジコクの シロです | That is your own castle | IntrigueCommandDispatch $CF89 | ok - IntrigueCommandDispatch |
| $41 | そのクニは ドウメイコクです | That country is an ally | ArmyCommandDispatch/SortieTargetPadPoll $AFA1 | ok - ArmyCommandDispatch |
| $42 | およろこびください / 〈名〉との ドウメイが / せいりつ いたしました | Rejoice - the alliance with <mei> is concluded | - | table - alliance result route |
| $43 | ざんねんですが / 〈名〉は ドウメイの / もうしこみを ことわりました | Regrettably, <mei> declined the alliance | - | table |
| $44 | 〈名〉との ドウメイを / ハキしました | Dissolved (haki 破棄) the alliance with <mei> | IntrigueCommandDispatch $CEF4 | ok - IntrigueCommandDispatch |
| $45 | たいへんです 〈省00〉でも / コウズイがはっせいしました | Disaster - flood (kouzui 洪水) has struck, even in <sho> | FloodDamageScene/LossProvinceApply $AADB | ok - FloodDamageScene |
| $46 | そのクニには ブショウはいません | That country has no officers | IntrigueCommandDispatch $CF7F | table |
| $47 | これいじょう このシロに / ブショウをいれることはできません | No more officers can be placed in this castle | IntrigueCommandDispatch $CF1B | ok - IntrigueCommandDispatch (roster-full) |
| $48 | どのブショウにしかけるのか えらんでください | Pick which officer to scheme against | IntrigueCommandDispatch $CF5B | ok - IntrigueCommandDispatch |
| $49 | クンシュがいるシロは / クンシュがタイシュになります | In a castle with its lord, the lord becomes the vanguard | ArmyCommandDispatch/ArmyCommandMenuInput $AED4 | ok - ArmyCommandDispatch |
| $4A | そのブショウは クンシュです | That officer is the lord | WarehouseCommandDispatch/WarehouseOfficerGiveGate $BBF8; IntrigueCommandDispatch $CFD1 | ok - WarehouseCommandDispatch |
| $4B | およろこびください / 〈名〉は あなたのハイカに / なりました | Rejoice - <mei> became your vassal (配下) | - | table |
| $4C | すみません / サクリャクは しっぱいにおわりました | Sorry - the scheme (策略) failed | - | table |
| $4D | しかし ゴアンシンください / ヒガイは ありませんでした | But rest assured - no harm was done | DroughtDamageScene/DamageCardRedraw $A892; FloodDamageScene/LossCardRedraw $AB11 | ok - DroughtDamageScene; FloodDamageScene (no-damage variant) |
| $4E | フッフッフッ / 〈名〉と クンシュのなかは / かくじつに わるくなったでしょう | Heh heh heh - the lord's standing with <mei> has surely soured | - | table - Discord (離間) success |
| $4F | サイガイに そなえるためには / キン ⟨数⟩がヒツヨウです | <su> gold is needed to prepare for disasters | CastleCommandDispatch/CastleCommandRouteDispatch $A3AD; CastleCommandDispatch/CastleDevAmountRoll $A502 | ok - CastleCommandDispatch |
| $50 | ボウサイチが ⟨数⟩あがりました | Disaster-preparedness (bousaichi 防災値) +<su> | CastleCommandDispatch/CastleDevExecute $A68D | ok - CastleCommandDispatch |
| $51 | これまでの データを キロクします | Recording the data so far (save) | CastleCommandDispatch/CastleCommandRouteDispatch $A3CA | ok - CastleCommandDispatch |
| $52 | ⟨数⟩ネン ⟨数⟩ガツの / データを キロクしました | Saved the <year>/<month> data | CastleCommandDispatch/CastleSaveExecute $AC73 | ok - CastleCommandDispatch |
| $53 | ブッシをはこぶ / あたえる / ここはクラです メイレイをしてください | carry goods / give - this is the warehouse; give your orders | WarehouseCommandDispatch/WarehouseMenuScreenInit $B7A3 | ok - WarehouseCommandDispatch |
| $54 | どのシロに はこびますか / で えらんでください | Carry to which castle? Choose | WarehouseCommandDispatch/WarehouseCommandMenuInput $B7F1 | ok - WarehouseCommandDispatch |
| $55 | そのシロへは はこべません | Cannot carry there | WarehouseCommandDispatch/WarehouseDestProvinceSelect $B866 | ok - WarehouseCommandDispatch (TacticalMapScene $55 renders bank 12) |
| $56 | そのシロの クラのなかは / すでに いっぱいになっています | The warehouse there is already full | - | table |
| $57 | キン     0  コメ     0 / タカラ    0 / なにを どれだけ はこびますか | gold <su> / rice <su> / treasure <su> - what and how much to carry? | WarehouseCommandDispatch/WarehouseDestProvinceSelect $B894 | ok - WarehouseCommandDispatch |
| $58 | ハイカの ブショウ / シロの ミンシュウ / どちらに あたえますか | your officers / the castle's people - to whom shall it be given? | WarehouseCommandDispatch/WarehouseCommandMenuInput $B7FE; WarehouseCommandDispatch/WarehouseOfficerGiveMenu $BB6C; WarehouseCommandDispatch/WarehousePopulaceAmountPanel $BDA8 | ok - WarehouseCommandDispatch |
| $59 | キン    0   コメ    0 / ミンシュウに どれだけ あたえますか | gold <su> / rice <su> - how much to the people? | WarehouseCommandDispatch/WarehouseGiveMenuInput $BABF | ok - WarehouseCommandDispatch |
| $5A | ミンシュウが よろこんでいます / トウチドが ⟨数⟩あがりました | The people rejoice - governance (touchido 統治度) +<su> | WarehouseCommandDispatch/WarehousePopulaceGiveApply $BF02 | ok - WarehouseCommandDispatch |
| $5B | キン    0 / キンを いくら あたえますか | gold <su> - how much to give? | WarehouseCommandDispatch/WarehouseOfficerGiveMenu $BB33 | ok - WarehouseCommandDispatch |
| $5C | タカラ / タカラを いくら あたえますか | treasure - how much to give? | - | ok - WarehouseCommandDispatch |
| $5D | どの ブショウに あたえますか | To which officer? | WarehouseCommandDispatch/WarehouseOfficerGiveMenu $BB52; WarehouseCommandDispatch/WarehouseGoldAmountPrompt $BBB1 | ok - WarehouseCommandDispatch |
| $5E | わたしに そのようなものは / ひつようありません | I have no need for such a thing | WarehouseCommandDispatch/WarehouseOfficerGiveGate $BC0E | ok - WarehouseCommandDispatch |
| $5F | ブショウの チュウセイドが / ⟨数⟩ あがりました | Loyalty (chuuseido 忠誠度) +<su> | - | ok - WarehouseCommandDispatch |
| $60 | シュツジン     チョウヘイ / テイサツ      ニンメイ / ここはグンタイです メイレイをしてください | sortie / conscript / scout / appoint - this is the army; give your orders | ArmyCommandDispatch/ArmyMenuScreenInit $AE51 | ok - ArmyCommandDispatch |
| $61 | どのシロに せめこみますか | Which castle to attack? | ArmyCommandDispatch/ArmyCommandMenuInput $AE9F; ArmyCommandDispatch/SortieRosterAnimWait $AFD5 | ok - ArmyCommandDispatch |
| $62 | そこへは シュツジンすることが / できません | Cannot sortie there | ArmyCommandDispatch/SortieTargetPadPoll $AFAB | ok - ArmyCommandDispatch |
| $63 | キン        コメ / キンとコメを どれだけ もっていきますか | How much gold and rice shall we take along? | ArmyCommandDispatch/SortieProvisionSeed $B0BF | ok - ArmyCommandDispatch |
| $64 | 〈名〉は / タイシュに なりました | <mei> became the vanguard (taishu 先鋒) | ArmyCommandDispatch/GovernorRosterSlideWait $B73B | ok - ArmyCommandDispatch |
| $65 | はい        いいえ / それでは   ヘイリョク ⟨数⟩ / キン  ⟨数⟩  コメ  ⟨数⟩ / で シュツジンします よろしいですか | yes/no - sortie with force <su>, gold <su>, rice <su>? | ArmyCommandDispatch/SortieProvisionDialog $B175 | ok - ArmyCommandDispatch |
| $66 | そうだいしょうを きめてください | Choose the commander-in-chief (soudaishou 総大将) | ArmyCommandDispatch/SortieMemberMenu $B202 | ok - ArmyCommandDispatch |
| $67 | かならずや シロをおとしてまいります | We shall surely take that castle | ArmyCommandDispatch/SortieWarRequestGate $B275 | ok - ArmyCommandDispatch |
| $68 | ヘイ 100ニンにつき キン20が / ひつようです | 20 gold is needed per 100 soldiers | ArmyCommandDispatch/ArmyCommandMenuInput $AEAD | ok - ArmyCommandDispatch |
| $69 | ヘイ      00ニン | soldiers: <su> | ArmyCommandDispatch/ConscriptionPanelWait $B339 | ok - ArmyCommandDispatch |
| $6A | ヒカエヘイ / だれに どれだけ ヘイを あたえますか | reserve troops (hikaehei 控え兵) - who receives how many soldiers? | ArmyCommandDispatch/ResultPanPrompt $B42D | ok - ArmyCommandDispatch |
| $6B | どのシロを テイサツしますか | Which castle to scout? | ArmyCommandDispatch/ReconPromptWait $B471; ArmyCommandDispatch/ReconExitMenu $B56B | ok - ArmyCommandDispatch |
| $6C | だれを タイシュにニンメイしますか | Whom to appoint as vanguard? | ArmyCommandDispatch/ArmyCommandMenuInput $AEEB | ok - ArmyCommandDispatch |
| $6D | はい        いいえ / ほかの シロも テイサツしますか | yes/no - scout another castle too? | ArmyCommandDispatch/ReconTargetPadPoll $B4A2@1B; ArmyCommandDispatch/ReconExitPromptInit $B525 | ok - ArmyCommandDispatch |
| $6E | ここはマチです どこへいきますか | This is town - where will you go? | TownCommandDispatch $C021 (@indexed @TownFacilityUiTable) | ok - TownCommandDispatch |
| $6F | コメ        タカラ / ここは ショウテンです / なにの とりひきをいたしますか | rice / treasure - this is the shop; what business? | TownCommandDispatch $C0B6; TownCommandDispatch $C203; TownCommandDispatch $C4A4 | ok - TownCommandDispatch x3 |
| $70 $D6 $D7 $FA $FB $FC $FD $FE $FF | タカラ / タカラなら 1つにつき / キン100で ひきとりましょう | treasure - we buy each at 100 gold | TownCommandDispatch $C19E | ok - TownCommandDispatch ($70); $D6/$D7/$FA-$FF share this stream with no other callers |
| $71 | キン ⟨数⟩が てにはいりました | Gained <su> gold | - | table |
| $72 | かう        うる / コメを どうしますか | buy / sell - what shall we do with rice? | TownCommandDispatch $C17D; TownCommandDispatch $C2E8; TownCommandDispatch $C3C5 | ok - TownCommandDispatch |
| $73 | コメ / キン100で コメ⟨数⟩がソウバです / コメをどれだけ かいますか | <su> rice per 100 gold - how much to buy? | TownCommandDispatch $C2B5 | ok - TownCommandDispatch |
| $74 | コメ / コメ100で キン⟨数⟩がソウバです / コメをどれだけ うりますか | <su> gold per 100 rice - how much to sell? | TownCommandDispatch $C251 | ok - TownCommandDispatch |
| $75 | コメ⟨数⟩を コウニュウしました | Bought <su> rice | TownCommandDispatch $C397 | ok - TownCommandDispatch |
| $76 | キン⟨数⟩を てにいれました | Gained <su> gold | TownCommandDispatch $C461; TownCommandDispatch $C50C | ok - TownCommandDispatch |
| $77 | だれを ビョウインへ いかせますか | Who to send to the hospital (byouin 病院)? | TownCommandDispatch $C0FC | ok - TownCommandDispatch |
| $78 | だれを ガクモンジョへ いかせますか | Who to send to the academy (gakumonjo 学府所)? | TownCommandDispatch $C0DE | ok - TownCommandDispatch |
| $79 | わたしに そのような / ひつようは ありません | I have no need of that (intelligence maxed) | TownCommandDispatch $C6EE | ok - TownCommandDispatch |
| $7A | では しばらく ようじょういたします | Then I shall rest and recuperate for a while | TownCommandDispatch $C5C9 | ok - TownCommandDispatch |
| $7B | ブショウの タイリョクが / ⟨数⟩ かいふくしました | Strength restored by <su> | TownCommandDispatch $C64F | ok - TownCommandDispatch |
| $7C | しっかり ベンキョウいたします | I shall study diligently | TownCommandDispatch $C5CE | ok - TownCommandDispatch |
| $7D | ブショウの チリョクが / ⟨数⟩ あがりました | Intelligence (chiryoku 知力) +<su> | TownCommandDispatch $C67C | ok - TownCommandDispatch |
| $7E | キン        タカラ / どちらを あたえますか | gold / treasure - which to give? | WarehouseCommandDispatch/WarehouseGiveMenuInput $BA54; WarehouseCommandDispatch/WarehouseGoldAmountPrompt $BBC2; WarehouseCommandDispatch/WarehouseOfficerGiveGate $BC1F; WarehouseCommandDispatch/WarehouseResultRouteBack $BF85 | ok - WarehouseCommandDispatch x2 |
| $7F | あれた トチが あります / そこを セイビしてつかいましょう / キン10が ひつようです | proposal: reclaim the barren land (10 gold needed) | - | table - advisor proposal panels $7F-$99 |
| $80 | モリを きりひらいて ノウチを / つくりましょう / キン12が ひつようです | proposal: clear forest into farmland (12) | - | table |
| $81 | ヌマチを うめたて ノウチに / しましょう / キン14が ひつようです | proposal: fill the marsh for farmland (14) | - | table |
| $82 | カワから ミズをひいて スイロを / もうけましょう / キン16が ひつようです | proposal: draw water from the river (16) | - | table |
| $83 | スイモンを つくって ミズを / ためておきましょう / キン110が ひつようです | proposal: build a reservoir (110) | - | table |
| $84 | トチにあった サクモツを / あらたに うえましょう / キン20が ひつようです | proposal: plant fitting crops (20) | - | table |
| $85 | サクモツが よくそだつように / ヒリョウを あたえましょう / キン22が ひつようです | proposal: fertilize the crops (22) | - | table |
| $86 | もっとつかいやすいノウグを / ノウミンに あたえましょう / キン24が ひつようです | proposal: give better tools to farmers (24) | - | table |
| $87 | ヒンシュカイリョウをして / よいナエを つくりましょう / キン26が ひつようです | proposal: improve seed strains (26) | - | table |
| $88 | つかっていないトチに / サギョウジョウをつくりましょう / キン10が ひつようです | proposal: build a work site (10) | - | table |
| $89 | セイサンリョクを あげるため / ロウドウシャを やといましょう / キン12が ひつようです | proposal: hire labourers (12) | - | table |
| $8A | マチのチュウオウに イチバを / つくってはいかがでしょう / キン14が ひつようです | proposal: open a market (14) | - | table |
| $8B | にぐるまを つかって ショウヒンの / リュウツウをよくしましょう / キン16が ひつようです | proposal: carts for distribution (16) | - | table |
| $8C | コウザンをほって コウセキを / あつめましょう / キン110が ひつようです | proposal: mine the mountains (110) | - | table |
| $8D | おおくのコウセキをとるために / あたらしいヤマをほってみましょう / キン20が ひつようです | proposal: open a new mine (20) | - | table |
| $8E | あらたに ショクニンをよんで / あたらしいギジュツをまなびましょう / キン22が ひつようです | proposal: invite craftsmen, learn new techniques (22) | - | table |
| $8F | ショクニンたちのつかっているドウグを / カイリョウしてはどうでしょう / キン24が ひつようです | proposal: improve craftsmen's tools (24) | - | table |
| $90 | ショクニンたちをあつめて / セイサンリョクを たかめましょう / キン26が ひつようです | proposal: gather craftsmen, raise output (26) | - | table |
| $91 | マチジュウの ミチを / セイビしては いかがでしょう / キン10が ひつようです | proposal: pave the town roads (10) | - | table |
| $92 | マチジュウを きれいにして / すみやすくいたしましょう / キン12が ひつようです | proposal: clean up the town (12) | - | table |
| $93 | ミチをひろげて コウツウのベンを / よくしましょう / キン14が ひつようです | proposal: widen the roads (14) | - | table |
| $94 | マチを すみよくするために / ヒロバを つくりましょう / キン16が ひつようです | proposal: build a plaza (16) | - | table |
| $95 | マチのなかのアキチに イエを / たてましょう / キン110が ひつようです | proposal: build houses on vacant lots (110) | - | table |
| $96 | マチの ヒトビトのために / シュウカイジョウをつくりましょう / キン20が ひつようです | proposal: build a meeting hall (20) | - | table |
| $97 | もっとたくさんのヒトがすめるように / マチを ひろげましょう / キン22が ひつようです | proposal: expand the town (22) | - | table |
| $98 | マチのチアンをまもるために / ヤクニンを ハイチしましょう / キン24が ひつようです | proposal: post officials for public order (24) | - | table |
| $99 | かくちのヤマをけずり / イエをたてては いかがでしょう / キン26が ひつようです | proposal: level the hills for housing (26) | - | table |
| $9A | あなたでは このブキを / つかいこなすことは ふかのうです | You cannot master this weapon | TownCommandDispatch $CAC0 | ok - TownCommandDispatch |
| $9B | すみません / それは うりきれてしまいました | Sorry - that is sold out | TownCommandDispatch $CADA | ok - TownCommandDispatch |
| $9C | -(graphics/no text) | blank placeholder (single $80) | - | unseeded padding |
| $9D $9E | -(graphics/no text) | blank placeholder (single $80) | - | unseeded padding ($9D/$9E shared) |
| $9F | -(graphics/no text) | blank placeholder (single $80) | - | unseeded padding |
| $A0 | -(graphics/no text) | blank placeholder (single $80) | - | unseeded padding |
| $A1 | -(graphics/no text) | blank placeholder (single $80) | - | unseeded padding |
| $A2 | -(graphics/no text) | blank placeholder (single $80) | - | unseeded padding |
| $A3 | ここは ブキヤです | This is the armory | - | table/runtime arg |
| $A4 | ここは ブキヤです だれが ブキを かいますか | Armory - who will buy weapons? | TownCommandDispatch $C0CA; TownCommandDispatch $C7EA | ok - TownCommandDispatch x2 |
| $A5 | どれを かいますか | Which one to buy? | TownCommandDispatch $C765; TownCommandDispatch $C94C | ok - TownCommandDispatch |
| $A6 | ⟨数⟩ / ⟨数⟩ / ⟨数⟩ / ⟨数⟩ / どれをかいますか | <su> x4 price list - which one? | TownCommandDispatch $C7D5 | ok - TownCommandDispatch |
| $A7 | これいじょう キンをついやすことは / ムイミかと おもわれますが | yes/no - enter the village? | CastleCommandDispatch/CastleDevTargetMenu $A44A@1B; CastleCommandDispatch/CastleDisasterCapCheck $ABE4; WarehouseCommandDispatch/WarehouseGiveMenuInput $BA6C | ok - CastleCommandDispatch x2; WarehouseCommandDispatch x2 |
| $A8 | もう ドウメイのヒツヨウはありません | There is no longer any need for an alliance | IntrigueCommandDispatch $CBEB | ok - IntrigueCommandDispatch (no-rivals notice) |
| $A9 | -(graphics/no text) | blank placeholder (single $80) | - | unseeded padding |
| $AA | そのブキをかうには キンがたりません | Not enough gold for that weapon | TownCommandDispatch $C9BC | ok - TownCommandDispatch |
| $AB | あたらしいブキを かいました / いままで つかっていたブキは / ブキヤに ひきとってもらいます | Bought a new weapon - the old one is bought back by the armory | TownCommandDispatch $CA62 | ok - TownCommandDispatch |
| $AC | いま このシロには タカラは / ありません / べつの メイレイを してください | No treasure in this castle - choose another order | WarehouseCommandDispatch/WarehouseOfficerGiveMenu $BB5C; TownCommandDispatch $C1A8 | ok - TownCommandDispatch x2; WarehouseCommandDispatch |
| $AD | このシロには ケガをしている / ブショウは いません / べつの メイレイを してください | No injured officers here - choose another order | TownCommandDispatch $C106 | ok - TownCommandDispatch |
| $AE | ここはマチです どこへいきますか | This is town - where will you go? (variant window) | TownCommandDispatch $C021 (@indexed @TownFacilityUiTable) | shared variant streams $AE-$B6 (+$C4-$C6); some seeded by TownCommandDispatch |
| $AF | ここはマチです どこへいきますか | This is town - where will you go? (variant window) | TownCommandDispatch $C021 (@indexed @TownFacilityUiTable) | shared variant $AF/$C5; no direct OpenMsgWindow seed found |
| $B0 | ここはマチです どこへいきますか | This is town - where will you go? (variant window) | TownCommandDispatch $C021 (@indexed @TownFacilityUiTable) | shared variant $B0/$C6; no direct OpenMsgWindow seed found |
| $B1 | ここはマチです どこへいきますか | This is town - where will you go? (variant window) | TownCommandDispatch $C021 (@indexed @TownFacilityUiTable) | shared variant $B1; no direct OpenMsgWindow seed found |
| $B2 | ここはマチです どこへいきますか | This is town - where will you go? (variant window) | TownCommandDispatch $C021 (@indexed @TownFacilityUiTable) | shared variant $B2; no direct OpenMsgWindow seed found |
| $B3 | ここはマチです どこへいきますか | This is town - where will you go? (variant window) | TownCommandDispatch $C021 (@indexed @TownFacilityUiTable) | shared variant $B3; no direct OpenMsgWindow seed found |
| $B4 $C4 | ここはマチです どこへいきますか | This is town - where will you go? (variant window) | TownCommandDispatch $C021 (@indexed @TownFacilityUiTable) | shared variant $B4/$C4; no direct OpenMsgWindow seed found |
| $B5 $C5 | ここはマチです どこへいきますか | This is town - where will you go? (variant window) | TownCommandDispatch $C021 (@indexed @TownFacilityUiTable) | shared variant $B5/$C5; no direct OpenMsgWindow seed found |
| $B6 $C6 | ここはマチです どこへいきますか | This is town - where will you go? (variant window) | TownCommandDispatch $C021 (@indexed @TownFacilityUiTable) | shared variant $B6/$C6; no direct OpenMsgWindow seed found |
| $B7 $C7 | このクニに ブショウはいません | This country has no officers | ArmyCommandDispatch/ReconTargetPadPoll $B4EB | ok - ArmyCommandDispatch |
| $B8 $C8 | マチはずれに シュツボツしていた / ゾクをつかまえ キン ⟨数⟩を / ボッシュウしました | Caught bandits lurking outside town - seized <su> gold | - | table/event-driven |
| $B9 $C9 | ジョウカにすんでいる フゴウが / コメ ⟨数⟩を キフしてくれました | A wealthy man (fugou 富豪) of the town donated <su> rice | CastleCommandDispatch/CastleScoutReportMenu $A9F8 | table/event-driven |
| $BA $CA | ジョウカにすんでいる フゴウが / キン ⟨数⟩を キフしてくれました | A wealthy man of the town donated <su> gold | - | table/event-driven |
| $CB | -(graphics/no text) | blank placeholder (single $80) | - | unseeded padding |
| $BC $CC | 4がつです / ゼイキンがあつまりキンがふえました | It is April - taxes gathered, gold increased | TaxCollectionEvent $A3F3 | ok - TaxCollectionEvent |
| $BD $CD | 10がつです / コメのシュウカクのきせつです | It is October - the rice harvest season | RiceHarvestEvent $A5B8 | ok - RiceHarvestEvent |
| $BE $CE | かくちでヒデリが はっせいしています | Drought is striking everywhere | DroughtDamageScene $A70F | ok - DroughtDamageScene |
| $BF $CF $E7 | かくちでコウズイが はっせいしています | Flood is striking everywhere | FloodDamageScene $A9C0 | ok - FloodDamageScene |
| $C0 | 〈名〉ぐん セントウチュウ | Army <mei> - in battle | - | table/shared (no OpenMsgWindow seed found) |
| $C1 | 〈名〉が シボウしました | <mei> has died | OfficerNaturalDeathScene/RosterSlotScanLoop $BCF1; RulerSuccessionScene $BE22; SuccessionApplyScene $C154; StrategyRequestDispatch $C90D | ok - StrategyRequestDispatch |
| $C2 | 〈名〉が / あとをついでクンシュとなります | <mei> succeeds and becomes the new lord | SuccessionApplyScene/SuccessionApplyAnnounce $C27D; StrategyRequestDispatch/NoticeDelayWait $CB91 | ok - SuccessionApplyScene |
| $C3 | 〈名〉が シボウして / 〈名〉いちぞくは めつぼうしました | <mei> died and the clan of <mei> perished | ScenarioHandoffPrep $C391; StrategyRequestDispatch $C92C | ok - StrategyRequestDispatch; ScenarioHandoffPrep |
| $D0 | あらたな クンシュをきめます / アトツギのいる シロをえらんでください | Choose a new lord - pick the castle with an heir | RulerSuccessionScene $BE7F; RulerSuccessionScene $BEF9 | ok - RulerSuccessionScene x2 |
| $D1 | どのブショウを アトツギとしますか | Which officer shall be the heir (atotsugi 跡継ぎ)? | RulerSuccessionScene $BEC3; RulerSuccessionScene $BF81 | ok - RulerSuccessionScene x2 |
| $D2 | はい      いいえ / 〈名〉で よろしいですか | yes/no - is <mei> acceptable? | RulerSuccessionScene $BF2C | ok - RulerSuccessionScene |
| $D3 | 〈名〉は クンシュになりました | <mei> became the lord | RulerSuccessionScene $BFA9 | ok - RulerSuccessionScene |
| $D4 | 〈名〉は ザイヤにくだりました | <mei> stepped down to private life (zaiya 在野) | RulerSuccessionScene/ArrivalShiftRoster $C0E2 | ok - RulerSuccessionScene |
| $D8 | ⟨数⟩ねん ⟨数⟩がつ 〈名〉は / 〈名〉グンに やぶれさった / こうして 〈名〉のいちぞくは / タイリクから そのすがたをけした | In <year>/<month> <mei> was crushed by the army of <mei> - thus the clan vanished from history | EventMessageScene_ChronPanel $D6CD | ok - EventMessageScene_ChronPanel (war_result_phase != $FF; ending chronicle) |
| $D9 | ⟨数⟩ねん ⟨数⟩がつ 〈名〉は / こころざし なかばにして このよをさった / こうして 〈名〉のいちぞくは / タイリクから そのすがたをけした | <mei> left this world with the ambition half-fulfilled - thus the clan vanished from history | - | ok - EventMessageScene_ChronPanel (war_result_phase = $FF; death chronicle) |
| $E0 | 〈名〉が ねがえって / 〈名〉の ハイカになってしまいました | <mei> defected and became the vassal of <mei> | StrategyRequestDispatch/SweepOfficerPrompt $CC03 | ok - StrategyRequestDispatch |
| $E1 | 〈名〉が 〈名〉のハイカと / なにやら はなしていたようですが | <mei> appears to have been talking with the camp of <mei>... | StrategyRequestDispatch/AbsorbOfficerPrompt $CC66 | ok - StrategyRequestDispatch |
| $E2 | 〈名〉さま 〈名〉のハイカの / 〈名〉が ドウメイのししゃとして / まいりました | My lord - <mei> of the camp of <mei> has come as an alliance envoy | StrategyRequestDispatch/ReqTransferConfirm $C9BF@19; IntrigueCommandDispatch $D11C | ok - StrategyRequestDispatch |
| $E3 | はい      いいえ / 〈名〉どの ドウメイをむすぶなら / キン⟨数⟩を けんじょう しましょう / ドウメイを むすびますか | yes/no - to ally with lord <mei>, offer <su> gold; conclude the alliance? | - | table - IntrigueCommandDispatch message route |
| $E4 | 〈名〉と ドウメイを むすびました | Allied with <mei> | StrategyRequestDispatch/TransferPromptChoose $CD3C; IntrigueCommandDispatch $D226; IntrigueCommandDispatch $D2C4 | ok - StrategyRequestDispatch; IntrigueCommandDispatch x3 |
| $E5 | 〈名〉との ドウメイを ことわりました | Declined the alliance with <mei> | StrategyRequestDispatch/TransferPromptChoose $CD42; IntrigueCommandDispatch $D22B; IntrigueCommandDispatch $D28C | ok - StrategyRequestDispatch; IntrigueCommandDispatch x2 |
| $E6 | 〈名〉さま 〈名〉がなにか / サクリャクを しかけてきたようですぞ | My lord - <mei> appears to be scheming against us! | StrategyRequestDispatch/ReqProvinceSweepNotice $C950; StrategyRequestDispatch/ReqAbsorbSweepNotice $C98B | ok - StrategyRequestDispatch |
| $DA | プレーヤー⟨数⟩の クンシュを / えらんでください | Choose the lord of player <su> | - | no OpenMsgWindow caller (new-game flow) |
| $DB | わたしは すでに えらばれています / ほかの クンシュを おえらびください | I am already chosen - pick another lord | - | no OpenMsgWindow caller (WarResultPanel $DB renders bank 12) |
| $DC | ⟨数00⟩ ネンものあいだつづいた センランは / イダイなる エイユウのシュツゲンによって / おわりをつげた | The great war that raged <su>00 years ended with the rise of a mighty hero | EventMessageScene_HeroRisePanel $D7D0 | ok - EventMessageScene_HeroRisePanel (ending card) |
| $DD | いくつものトウソウを くりひろげ / タイリクをせいはした エイユウこそ / 〈名〉であった | Waging countless campaigns and mastering the age - the hero was <mei> | EventMessageScene_HeroNamePanel $D860 | ok - EventMessageScene_HeroNamePanel (ending card) |
| $DE | ⟨数⟩ネン ⟨数⟩ガツ 〈名〉は / ゼンコクトウイツのユメを はたしました / レベル⟨数01⟩  トウイツドは⟨数⟩です | In <y>/<m>, <mei> fulfilled the dream of unification; level <su>, unification score <su> | EventMessageScene_UnifyScorePanel $D8EF | ok - EventMessageScene_UnifyScorePanel (ending stats) |
| $DF | 〈名〉さま ゼンコクトウイツ / おめでとうございます | My lord - congratulations on total unification! | UnificationEndingDispatch $C5DC | ok - UnificationEndingDispatch |
| $D5 | もはや このニンズウでは / ゼンコクトウイツは フカノウです / もういちどはじめから チャレンジしてください | Unification is impossible with this many rulers - try again from the start | CountryRotationDispatch $A0A2 | ok - CountryRotationDispatch (game-over check) |
| $E8 | たいへんです 〈省20〉で / ハンランが おこりました | Disaster - a revolt (hanran 反乱) broke out in <sho> | ProvinceRebellionEvent/RebellionProvinceHit $AC4A; ProvinceRebellionEvent/RebellionOverlayWait $AC97 | ok - ProvinceRebellionEvent x2 |
| $E9 | シロのミンシュウが つぎつぎと / クニから でていっています | The castle's people are leaving the country one after another | - | table/event-driven |
| $EA | ミンシュウが ダンケツして / シロのクラを おそっています | The people banded together and raid the granary | - | table/event-driven |
| $EB | ロウドウシャたちが てをくんで / シゴトを さぼっています | The labourers band together and shirk their work | - | table/event-driven |
| $EC | はい      いいえ / 〈名〉は ドウメイのジョウケンに / 〈名〉⟨数⟩を ヨウキュウしてきました / ヨウキュウをうけますか | yes/no - <mei> demands <mei><su> as alliance terms; accept the demand? | - | table/AI-driven |
| $ED | いま このシロには それほどの / コメが ありません / べつのメイレイを してください | This castle lacks that much rice - choose another order | IntrigueCommandDispatch $D2D3 (@X = $ED rice gift) | table |
| $EE | はい      いいえ / 〈名〉どの ドウメイをむすぶなら / コメ⟨数⟩を けんじょう しましょう / ドウメイを むすびますか | yes/no - to ally with lord <mei>, offer <su> rice; conclude the alliance? | StrategyRequestDispatch/TransferConfirmPrompt $CCBC | ok - StrategyRequestDispatch |
| $EF | はい      いいえ / 〈名〉どの リョウゴクのへいわのために / ドウメイを むすびましょう | yes/no - for the peace of both lands, let us ally, lord <mei> | IntrigueCommandDispatch $D1B5 | ok - StrategyRequestDispatch |
| $F0 | 〈名7 00〉 / 〈名7 01〉 | two 7-char name slots (hall-of-fame rows) | - | ok - EventMessageScene officer-roll flow (bank-13 context) |
| $F1 | タイリクをセイハしたおとこたち | caption: 'the men who dominated their age' | OfficerRoll_BuildList $DA3D | ok - OfficerRoll_BuildList - FLAG: generator comment wrongly says 'explosion/tactic point overlay' (bank-12 meaning) |
| $F2 | スタッフ | STAFF (caption) | - | no OpenMsgWindow caller (event-script chain after unification) |
| $F3 | コーディネーター / くれいじーホース / きだんしゃ / ラーフス | coordinator credits (Crazy Horse, etc.) | - | no OpenMsgWindow caller; StratagemState_Init's $F3 seed renders the bank-12 blank in war mode |
| $F4 | プログラマー / ハマー / こうちゃん | programmer credits (Hammer, Kou-chan) | - | no OpenMsgWindow caller; generator comment wrongly says 'command menu (funds ok) panel' |
| $F5 | キャラクターデザイナー / あきちゃん / ひですけちゃん | character designer credits (Aki-chan, Hidesuke-chan) | - | no OpenMsgWindow caller |
| $F6 | コンポーザー / あまにし ばんじろう | composer credits (Amanishi Banjiro) | - | no OpenMsgWindow caller |
| $F7 | ディレクター / ひで | director credits (Hide) | - | no OpenMsgWindow caller; generator comment wrongly says 'select target proceed panel' |
| $F8 | -(graphics/no text) | ending blank panel (graphics) | - | no OpenMsgWindow caller; generator comment wrongly says 'army deploy panel' |
| $F9 | -(graphics/no text) | ending graphics tile-row panel | - | no OpenMsgWindow caller |
| $00 $06 $08 $0A $0C $0E $10 $12 $14 $16 $18 $1A $1C $1E $BB | -(graphics/no text) | blank-window primitive at $22A8 (mode-0 head / ClearUI idle) | EventMessageScene_HeroRisePanel $D836; EventMessageScene_HeroNamePanel $D8C5; DroughtDamageScene/DamageListAdvance $A75F; FloodDamageScene/LossListAdvance $AA10; ProvinceRebellionEvent/RebellionPollAdvance $ABC5; ProvinceRebellionEvent/RebellionOverlayWait2 $ACB9; OfficerReinforceScene/ReinforceRosterInsert $AF71; MapRulerIntroDispatch/MapRulerIntroInit $A0C4; MapRulerIntroDispatch/MapRulerIntroPadAdvance $A15D; CommandCategoryMenuDispatch/CommandCategoryMenuInput $A228; CastleCommandDispatch/CastleScoutRecruitDialog $AAD6; CastleCommandDispatch/CastleScoutFindDialog $AB31; CastleCommandDispatch/CastleScreenIdleWait $ACD2; ArmyCommandDispatch/ReconTargetPadPoll $B504; TownCommandDispatch $C087; IntrigueCommandDispatch $CCF4; IntrigueCommandDispatch $CD30 | ok - many callers use it as a blank helper ($00 seeds) |
| $03 | -(graphics/no text) | 32-tile blank-row push macro (one window row) | - | ok - pushed by bank-12 streams and pos 04/05 |
| $02 | -(graphics/no text) | blank-window primitive at $2428 (mode-2 head) | - | ok - OpenMsgWindow2 head callers |
| $04 | -(graphics/no text) | blank-window primitive at $22A0 (mode-4 head) | - | ok - OpenMsgWindow4 head callers; WarResultPanel; WarehouseCommandDispatch; TownCommandDispatch |
| $05 | -(graphics/no text) | blank-window primitive at $2420 (mode-5 head) | - | ok - blank-helper seeds (FinishSequence, TurnEndState_Select, ...) |
