# Province data extracted from the ROM

All 30 provinces with their katakana name (as stored in the
ROM), Chinese name, and starting data, read directly out of
the iNES image by `tools/extract_province_data.py`.

* PRG 256 KB, CHR 256 KB, mapper 19 (Namco 163)
* names: PRG `$21A1A`, 8 bytes/entry (CPU `$9A1A`, bank `$30`), `$00`-terminated
* data: PRG `$20C00`, 32 bytes/record (CPU `$8C00`, bank `$30`)
* 30 provinces; record `id * 32 + $6000` once copied to SRAM

## Record layout

The master record is the seed image of the province's SRAM
record at `id * 32 + $6000`, i.e. the new-game starting state;
`SramInit` copies all `$3C0` bytes verbatim. Column names use
the canonical semantic English terms from
`docs/manual_kb/terminology.md`.

| Offset | Field | Notes |
|---|---|---|
| `+0` | 所属国 Country | low nibble = Country id 0-6, `7` = 空白地 UnclaimedLand |
| `+1` | - | always 0 in ROM (runtime field) |
| `+2/+3` | 金 Gold | 16-bit LE; capped at 9999 |
| `+4/+5` | 米 Rice | 16-bit LE; capped at 9999 |
| `+6/+7` | 人口 Population | 16-bit LE, stored / 100 (panel appends two `0` tiles) |
| `+8/+9` | 土地 LandValue | 16-bit LE; capped at 999 |
| `+10` | 防災 DisasterPrevention | capped at 99 |
| `+11` | 統治度 Governance | capped at 100; below 50 the annual check rolls a revolt |
| `+12/+13` | 控え ReserveTroops | 16-bit LE; 徴兵 adds here, capped at 10000 |
| `+14/+15` | 産業 Industry | 16-bit LE; capped at 999 |
| `+16` | 宝 Treasure | capped at 99; 0 in ROM |
| `+17..+26` | 武将 Officer roster | 10 slots (`$11-$1A`), `$FF` = empty |
| `+27` | 反乱クールダウン RevoltCooldown | months, set to 6 on a revolt; 0 in ROM |
| `+28..+31` | - | always 0 in ROM (runtime fields) |

The 現役 (active) soldier total the game shows in the province
panel is not stored here: it is summed on the fly from the
roster officers' 兵数 TroopCount field (officer record `+8/+9`).

## CSV columns

`docs/province_data.csv` column names are the snake_case form
of the canonical semantic English terms in
`docs/manual_kb/terminology.md`.

| Column | 日本語 | Meaning |
|---|---|---|
| `id` | 国番号 | Province id; index into both ROM tables |
| `katakana` | 国名 | Province name as stored in the ROM |
| `zh_hans` | 国名 | Simplified Chinese name |
| `kanji_ja` | 国名 | Japanese kanji name |
| `pinyin` | 国名 | Mandarin reading of the Chinese name |
| `country_id` | 所属国 | Owning Country id (record `+0` low nibble); 7 = 空白地 UnclaimedLand |
| `ruler_officer_id` | 君主 | Ruler: the rostered Officer whose Loyalty is 100 |
| `gold` | 金 | Gold (record `+2/+3`) |
| `rice` | 米 | Rice (record `+4/+5`) |
| `population` | 人口 | Population as displayed (record `+6/+7` x 100) |
| `land_value` | 土地 | LandValue (record `+8/+9`); drives the annual Rice harvest |
| `industry` | 産業 | Industry (record `+14/+15`); drives the annual Gold tax |
| `disaster_prevention` | 防災 | DisasterPrevention (record `+10`) |
| `governance` | 統治度 | Governance (record `+11`) |
| `reserve_troops` | 控え | ReserveTroops (record `+12/+13`) |
| `treasure` | 宝 | Treasure (record `+16`) |
| `officer_count` | 武将数 | Officers on the roster (record `+17..+26`) |
| `active_troops` | 現役 | ActiveTroops: sum of the rostered Officers TroopCount |
| `officer_ids` | 武将 | Roster Officer ids, in slot order |
| `officer_names` | 武将 | Roster Officer names, simplified Chinese |
| `sram_record` | - | SRAM address of the record after SramInit |
| `data_offset` | - | PRG file offset of the record |
| `hex` | - | The raw 32 record bytes |

## Countries at the 189 start

Country ids are the low nibble of record `+0`; the Ruler is the
roster officer whose 忠誠度 Loyalty is 100.

| Country id | Ruler | Home province | Provinces |
|---:|---|---|---|
| 0 | 董卓 トウタク (id 173) | 洛阳 ラクヨウ | 长安, 洛阳 |
| 1 | 袁绍 エンショウ (id 8) | 冀州 キシュウ | 幽州, 青州, 冀州 |
| 2 | 曹操 ソウソウ (id 131) | 兖州 エンシュウ | 兖州, 豫州 |
| 3 | 孙策 ソンサク (id 138) | 江夏 コウカ | 建业, 扬州, 建安, 江夏 |
| 4 | 刘备 リュウビ (id 222) | 并州 ヘイシュウ | 并州 |
| 5 | 刘璋 リュウショウ (id 220) | 成都 セイト | 汉中, 成都, 涪陵, 云南 |
| 6 | 马腾 バトウ (id 182) | 凉州 リョウシュウ | 凉州, 安定, 西平关 |
| 7 | - (空白地 unclaimed) | - | 辽东, 西安阳, 徐州, 新野, 交州, 郁林, 荆州, 襄阳, 长沙, 零陵, 永昌 |

## Province names

| id | addr | bytes | katakana | hiragana | romaji | 日本語 | 繁體 | 简体 | pinyin |
|---:|---|---|---|---|---|---|---|---|---|
| 0 | `$9A1A` | `2B37061706` | リョウトウ | りょうとう | Ryoutou | 遼東 | 遼東 | 辽东 | liáo dōng |
| 1 | `$9A22` | `28060F3606` | ユウシュウ | ゆうしゅう | Yuushuu | 幽州 | 幽州 | 幽州 | yōu zhōu |
| 2 | `$9A2A` | `20050F3606` | ヘイシュウ | へいしゅう | Heishuu | 并州 | 并州 | 并州 | bīng zhōu |
| 3 | `$9A32` | `11050F3606` | セイシュウ | せいしゅう | Seishuu | 青州 | 青州 | 青州 | qīng zhōu |
| 4 | `$9A3A` | `0A0F3606` | キシュウ | きしゅう | Kishuu | 冀州 | 冀州 | 冀州 | jì zhōu |
| 5 | `$9A42` | `110504312906` | セイアンヨウ | せいあんよう | Seianyou | 西安陽 | 西安陽 | 西安阳 | xī ān yáng |
| 6 | `$9A4A` | `2B37060F3606` | リョウシュウ | りょうしゅう | Ryoushuu | 涼州 | 涼州 | 凉州 | liáng zhōu |
| 7 | `$9A52` | `04311605` | アンテイ | あんてい | Antei | 安定 | 安定 | 安定 | ān dìng |
| 8 | `$9A5A` | `1437060431` | チョウアン | ちょうあん | Chouan | 長安 | 長安 | 长安 | cháng ān |
| 9 | `$9A62` | `110520050931` | セイヘイカン | せいへいかん | Seiheikan | 西平関 | 西平關 | 西平关 | xī píng guān |
| 10 | `$9A6A` | `0F39370F3606` | ジョシュウ | じょしゅう | Joshuu | 徐州 | 徐州 | 徐州 | xú zhōu |
| 11 | `$9A72` | `07310F3606` | エンシュウ | えんしゅう | Enshuu | 兗州 | 兗州 | 兖州 | yǎn zhōu |
| 12 | `$9A7A` | `2A0B2906` | ラクヨウ | らくよう | Rakuyou | 洛陽 | 洛陽 | 洛阳 | luò yáng |
| 13 | `$9A82` | `0F3127` | シンヤ | しんや | Shinya | 新野 | 新野 | 新野 | xīn yě |
| 14 | `$9A8A` | `290F3606` | ヨシュウ | よしゅう | Yoshuu | 豫州 | 豫州 | 豫州 | yù zhōu |
| 15 | `$9A92` | `0C310A393706` | ケンギョウ | けんぎょう | Kengyou | 建業 | 建業 | 建业 | jiàn yè |
| 16 | `$9A9A` | `29060F3606` | ヨウシュウ | ようしゅう | Youshuu | 揚州 | 揚州 | 扬州 | yáng zhōu |
| 17 | `$9AA2` | `0C310431` | ケンアン | けんあん | Ken'an | 建安 | 建安 | 建安 | jiàn ān |
| 18 | `$9AAA` | `0D060F3606` | コウシュウ | こうしゅう | Koushuu | 交州 | 交州 | 交州 | jiāo zhōu |
| 19 | `$9AB2` | `050B2B31` | イクリン | いくりん | Ikurin | 郁林 | 鬱林 | 郁林 | yù lín |
| 20 | `$9ABA` | `0D0609` | コウカ | こうか | Kouka | 江夏 | 江夏 | 江夏 | jiāng xià |
| 21 | `$9AC2` | `0C050F3606` | ケイシュウ | けいしゅう | Keishuu | 荊州 | 荊州 | 荆州 | jīng zhōu |
| 22 | `$9ACA` | `0F37062906` | ショウヨウ | しょうよう | Shouyou | 襄陽 | 襄陽 | 襄阳 | xiāng yáng |
| 23 | `$9AD2` | `1437060E` | チョウサ | ちょうさ | Chousa | 長沙 | 長沙 | 长沙 | cháng shā |
| 24 | `$9ADA` | `2D052B3706` | レイリョウ | れいりょう | Reiryou | 零陵 | 零陵 | 零陵 | líng líng |
| 25 | `$9AE2` | `0931143606` | カンチュウ | かんちゅう | Kanchuu | 漢中 | 漢中 | 汉中 | hàn zhōng |
| 26 | `$9AEA` | `110517` | セイト | せいと | Seito | 成都 | 成都 | 成都 | chéng dū |
| 27 | `$9AF2` | `1F2B3706` | フリョウ | ふりょう | Furyou | 涪陵 | 涪陵 | 涪陵 | fú líng |
| 28 | `$9AFA` | `06311831` | ウンナン | うんなん | Unnan | 雲南 | 雲南 | 云南 | yún nán |
| 29 | `$9B02` | `07050F3706` | エイショウ | えいしょう | Eishou | 永昌 | 永昌 | 永昌 | yǒng chāng |

### Reading notes

* **ヘイシュウ** (并州) — Liu Bei's home province at the 189 start
* **ジョシュウ** (徐州) — kana ジョ = 徐 (dakuten $39 after シ)
* **エンシュウ** (兗州) — 兗 (エン); often printed 兖 in simplified text
* **ヨシュウ** (豫州) — 豫 = ヨ (not ヨウ)
* **イクリン** (郁林) — Han commandery 鬱林/郁林; manual map prints 郁林
* **コウカ** (江夏) — Sun Ce's home province at the 189 start
* **ショウヨウ** (襄陽) — 襄 = ショウ; manual scan read as 衡陽(?) — ROM kana gives 襄陽
* **フリョウ** (涪陵) — 涪 = フ; manual scan read as 建寧(?) — ROM kana gives 涪陵
* **エイショウ** (永昌) — manual scan read as 永晶(?) — ROM kana gives 永昌

## Starting data

人口 is the value the game displays (stored value x 100).
兵士 is 現役 (summed from the roster) + 控え (record `+12/+13`).

| id | province | 国 | 金 | 米 | 人口 | 土地 | 産業 | 防災 | 統治度 | 現役 | 控え | 宝 | 武将 |
|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 0 | 辽东 リョウトウ | - | 160 | 240 | 15000 | 20 | 35 | 25 | 35 | 0 | 100 | 0 | 0 |
| 1 | 幽州 ユウシュウ | 1 | 180 | 270 | 20000 | 25 | 40 | 30 | 40 | 2300 | 100 | 0 | 3 |
| 2 | 并州 ヘイシュウ | 4 | 190 | 280 | 21000 | 30 | 35 | 40 | 45 | 2100 | 100 | 0 | 3 |
| 3 | 青州 セイシュウ | 1 | 220 | 330 | 25000 | 35 | 50 | 35 | 50 | 2000 | 100 | 0 | 4 |
| 4 | 冀州 キシュウ | 1 | 270 | 390 | 35000 | 40 | 45 | 45 | 50 | 3500 | 100 | 0 | 4 |
| 5 | 西安阳 セイアンヨウ | - | 150 | 220 | 10000 | 15 | 15 | 20 | 30 | 0 | 100 | 0 | 0 |
| 6 | 凉州 リョウシュウ | 6 | 170 | 250 | 14000 | 15 | 20 | 40 | 45 | 1500 | 100 | 0 | 2 |
| 7 | 安定 アンテイ | 6 | 190 | 280 | 16000 | 20 | 25 | 35 | 40 | 2500 | 100 | 0 | 3 |
| 8 | 长安 チョウアン | 0 | 500 | 700 | 40000 | 30 | 40 | 50 | 20 | 4500 | 100 | 0 | 5 |
| 9 | 西平关 セイヘイカン | 6 | 150 | 220 | 10000 | 15 | 15 | 20 | 30 | 1500 | 100 | 0 | 2 |
| 10 | 徐州 ジョシュウ | - | 190 | 280 | 22000 | 30 | 35 | 45 | 55 | 0 | 100 | 0 | 0 |
| 11 | 兖州 エンシュウ | 2 | 220 | 330 | 21000 | 25 | 30 | 40 | 50 | 2500 | 100 | 0 | 3 |
| 12 | 洛阳 ラクヨウ | 0 | 450 | 640 | 38000 | 35 | 40 | 45 | 20 | 3500 | 100 | 0 | 5 |
| 13 | 新野 シンヤ | - | 200 | 300 | 19000 | 25 | 20 | 40 | 45 | 0 | 100 | 0 | 0 |
| 14 | 豫州 ヨシュウ | 2 | 250 | 360 | 22000 | 20 | 25 | 50 | 50 | 3300 | 100 | 0 | 4 |
| 15 | 建业 ケンギョウ | 3 | 270 | 380 | 26000 | 25 | 30 | 45 | 50 | 1500 | 100 | 0 | 2 |
| 16 | 扬州 ヨウシュウ | 3 | 230 | 340 | 22000 | 30 | 25 | 40 | 45 | 1500 | 100 | 0 | 2 |
| 17 | 建安 ケンアン | 3 | 200 | 300 | 17000 | 25 | 20 | 40 | 40 | 500 | 100 | 0 | 1 |
| 18 | 交州 コウシュウ | - | 140 | 210 | 11000 | 15 | 15 | 20 | 25 | 0 | 100 | 0 | 0 |
| 19 | 郁林 イクリン | - | 160 | 240 | 10000 | 10 | 15 | 25 | 30 | 0 | 100 | 0 | 0 |
| 20 | 江夏 コウカ | 3 | 290 | 420 | 20000 | 25 | 25 | 45 | 45 | 3000 | 100 | 0 | 3 |
| 21 | 荆州 ケイシュウ | - | 280 | 410 | 25000 | 30 | 30 | 60 | 55 | 0 | 100 | 0 | 0 |
| 22 | 襄阳 ショウヨウ | - | 210 | 310 | 18000 | 20 | 25 | 40 | 40 | 0 | 100 | 0 | 0 |
| 23 | 长沙 チョウサ | - | 240 | 360 | 20000 | 25 | 20 | 45 | 45 | 0 | 100 | 0 | 0 |
| 24 | 零陵 レイリョウ | - | 200 | 300 | 17000 | 15 | 20 | 40 | 45 | 0 | 100 | 0 | 0 |
| 25 | 汉中 カンチュウ | 5 | 250 | 370 | 23000 | 20 | 25 | 50 | 45 | 2500 | 100 | 0 | 3 |
| 26 | 成都 セイト | 5 | 240 | 360 | 21000 | 25 | 20 | 45 | 40 | 1800 | 100 | 0 | 4 |
| 27 | 涪陵 フリョウ | 5 | 190 | 280 | 17000 | 20 | 20 | 40 | 40 | 1200 | 100 | 0 | 2 |
| 28 | 云南 ウンナン | 5 | 170 | 250 | 15000 | 20 | 15 | 35 | 35 | 2000 | 100 | 0 | 2 |
| 29 | 永昌 エイショウ | - | 160 | 240 | 15000 | 15 | 20 | 40 | 40 | 0 | 100 | 0 | 0 |

## Starting officer rosters

| id | province | officers (id: name) |
|---:|---|---|
| 0 | 辽东 リョウトウ | - |
| 1 | 幽州 ユウシュウ | 77: 高览 コウラン, 7: 袁熙 エンキ, 27: 郭图 カクト |
| 2 | 并州 ヘイシュウ | 222: 刘备 リュウビ, 38: 关羽 カンウ, 153: 张飞 チョウヒ |
| 3 | 青州 セイシュウ | 134: 沮授 ソジュ, 117: 审配 シンパイ, 9: 袁谭 エンタン, 194: 逄纪 ホウキ |
| 4 | 冀州 キシュウ | 8: 袁绍 エンショウ, 51: 颜良 ガンリョウ, 191: 文丑 ブンシュウ, 167: 田丰 デンホウ |
| 5 | 西安阳 セイアンヨウ | - |
| 6 | 凉州 リョウシュウ | 182: 马腾 バトウ, 44: 韩遂 カンスイ |
| 7 | 安定 アンテイ | 162: 程银 テイギン, 146: 张横 チョウオウ, 148: 赵月 チョウゲツ |
| 8 | 长安 チョウアン | 22: 贾诩 カク, 211: 李傕 リカク, 23: 郭汜 カクシ, 37: 华雄 カユウ, 186: 樊稠 ハンチュウ |
| 9 | 西平关 セイヘイカン | 72: 侯选 コウセン, 120: 成宜 セイギ |
| 10 | 徐州 ジョシュウ | - |
| 11 | 兖州 エンシュウ | 131: 曹操 ソウソウ, 5: 于禁 ウキン, 30: 夏侯惇 カコウトン |
| 12 | 洛阳 ラクヨウ | 173: 董卓 トウタク, 219: 李儒 リジュ, 218: 吕布 リョフ, 106: 徐荣 ジョエイ, 143: 张济 チョウサイ |
| 13 | 新野 シンヤ | - |
| 14 | 豫州 ヨシュウ | 130: 曹仁 ソウジン, 29: 夏侯渊 カコウエン, 126: 曹洪 ソウコウ, 26: 乐进 ガクシン |
| 15 | 建业 ケンギョウ | 96: 朱治 シュチ, 89: 周善 シュウゼン |
| 16 | 扬州 ヨウシュウ | 67: 黄盖 コウガイ, 163: 程普 テイフ |
| 17 | 建安 ケンアン | 158: 陈武 チンブ |
| 18 | 交州 コウシュウ | - |
| 19 | 郁林 イクリン | - |
| 20 | 江夏 コウカ | 138: 孙策 ソンサク, 45: 韩当 カントウ, 141: 太史慈 タイシジ |
| 21 | 荆州 ケイシュウ | - |
| 22 | 襄阳 ショウヨウ | - |
| 23 | 长沙 チョウサ | - |
| 24 | 零陵 レイリョウ | - |
| 25 | 汉中 カンチュウ | 151: 张任 チョウジン, 63: 严颜 ゲンガン, 81: 吴兰 ゴラン |
| 26 | 成都 セイト | 220: 刘璋 リュウショウ, 16: 王甫 オウホ, 70: 黄权 コウケン, 209: 雷铜 ライドウ |
| 27 | 涪陵 フリョウ | 66: 吴懿 ゴイ, 150: 张松 チョウショウ |
| 28 | 云南 ウンナン | 196: 法正 ホウセイ, 201: 孟达 モウタツ |
| 29 | 永昌 エイショウ | - |

## Raw records

32 bytes per province, exactly as stored at PRG `$20C00` (bank `$30` `$8C00`).

```
id  file    sram   bytes
 0  0x20c00 $6000  07 00 A0 00 F0 00 96 00 14 00 19 23 64 00 23 00 00 FF FF FF FF FF FF FF FF FF FF 00 00 00 00 00
 1  0x20c20 $6020  01 00 B4 00 0E 01 C8 00 19 00 1E 28 64 00 28 00 00 4D 07 1B FF FF FF FF FF FF FF 00 00 00 00 00
 2  0x20c40 $6040  04 00 BE 00 18 01 D2 00 1E 00 28 2D 64 00 23 00 00 DE 26 99 FF FF FF FF FF FF FF 00 00 00 00 00
 3  0x20c60 $6060  01 00 DC 00 4A 01 FA 00 23 00 23 32 64 00 32 00 00 86 75 09 C2 FF FF FF FF FF FF 00 00 00 00 00
 4  0x20c80 $6080  01 00 0E 01 86 01 5E 01 28 00 2D 32 64 00 2D 00 00 08 33 BF A7 FF FF FF FF FF FF 00 00 00 00 00
 5  0x20ca0 $60A0  07 00 96 00 DC 00 64 00 0F 00 14 1E 64 00 0F 00 00 FF FF FF FF FF FF FF FF FF FF 00 00 00 00 00
 6  0x20cc0 $60C0  06 00 AA 00 FA 00 8C 00 0F 00 28 2D 64 00 14 00 00 B6 2C FF FF FF FF FF FF FF FF 00 00 00 00 00
 7  0x20ce0 $60E0  06 00 BE 00 18 01 A0 00 14 00 23 28 64 00 19 00 00 A2 92 94 FF FF FF FF FF FF FF 00 00 00 00 00
 8  0x20d00 $6100  00 00 F4 01 BC 02 90 01 1E 00 32 14 64 00 28 00 00 16 D3 17 25 BA FF FF FF FF FF 00 00 00 00 00
 9  0x20d20 $6120  06 00 96 00 DC 00 64 00 0F 00 14 1E 64 00 0F 00 00 48 78 FF FF FF FF FF FF FF FF 00 00 00 00 00
10  0x20d40 $6140  07 00 BE 00 18 01 DC 00 1E 00 2D 37 64 00 23 00 00 FF FF FF FF FF FF FF FF FF FF 00 00 00 00 00
11  0x20d60 $6160  02 00 DC 00 4A 01 D2 00 19 00 28 32 64 00 1E 00 00 83 05 1E FF FF FF FF FF FF FF 00 00 00 00 00
12  0x20d80 $6180  00 00 C2 01 80 02 7C 01 23 00 2D 14 64 00 28 00 00 AD DB DA 6A 8F FF FF FF FF FF 00 00 00 00 00
13  0x20da0 $61A0  07 00 C8 00 2C 01 BE 00 19 00 28 2D 64 00 14 00 00 FF FF FF FF FF FF FF FF FF FF 00 00 00 00 00
14  0x20dc0 $61C0  02 00 FA 00 68 01 DC 00 14 00 32 32 64 00 19 00 00 82 1D 7E 1A FF FF FF FF FF FF 00 00 00 00 00
15  0x20de0 $61E0  03 00 0E 01 7C 01 04 01 19 00 2D 32 64 00 1E 00 00 60 59 FF FF FF FF FF FF FF FF 00 00 00 00 00
16  0x20e00 $6200  03 00 E6 00 54 01 DC 00 1E 00 28 2D 64 00 19 00 00 43 A3 FF FF FF FF FF FF FF FF 00 00 00 00 00
17  0x20e20 $6220  03 00 C8 00 2C 01 AA 00 19 00 28 28 64 00 14 00 00 9E FF FF FF FF FF FF FF FF FF 00 00 00 00 00
18  0x20e40 $6240  07 00 8C 00 D2 00 6E 00 0F 00 14 19 64 00 0F 00 00 FF FF FF FF FF FF FF FF FF FF 00 00 00 00 00
19  0x20e60 $6260  07 00 A0 00 F0 00 64 00 0A 00 19 1E 64 00 0F 00 00 FF FF FF FF FF FF FF FF FF FF 00 00 00 00 00
20  0x20e80 $6280  03 00 22 01 A4 01 C8 00 19 00 2D 2D 64 00 19 00 00 8A 2D 8D FF FF FF FF FF FF FF 00 00 00 00 00
21  0x20ea0 $62A0  07 00 18 01 9A 01 FA 00 1E 00 3C 37 64 00 1E 00 00 FF FF FF FF FF FF FF FF FF FF 00 00 00 00 00
22  0x20ec0 $62C0  07 00 D2 00 36 01 B4 00 14 00 28 28 64 00 19 00 00 FF FF FF FF FF FF FF FF FF FF 00 00 00 00 00
23  0x20ee0 $62E0  07 00 F0 00 68 01 C8 00 19 00 2D 2D 64 00 14 00 00 FF FF FF FF FF FF FF FF FF FF 00 00 00 00 00
24  0x20f00 $6300  07 00 C8 00 2C 01 AA 00 0F 00 28 2D 64 00 14 00 00 FF FF FF FF FF FF FF FF FF FF 00 00 00 00 00
25  0x20f20 $6320  05 00 FA 00 72 01 E6 00 14 00 32 2D 64 00 19 00 00 97 3F 51 FF FF FF FF FF FF FF 00 00 00 00 00
26  0x20f40 $6340  05 00 F0 00 68 01 D2 00 19 00 2D 28 64 00 14 00 00 DC 10 46 D1 FF FF FF FF FF FF 00 00 00 00 00
27  0x20f60 $6360  05 00 BE 00 18 01 AA 00 14 00 28 28 64 00 14 00 00 42 96 FF FF FF FF FF FF FF FF 00 00 00 00 00
28  0x20f80 $6380  05 00 AA 00 FA 00 96 00 14 00 23 23 64 00 0F 00 00 C4 C9 FF FF FF FF FF FF FF FF 00 00 00 00 00
29  0x20fa0 $63A0  07 00 A0 00 F0 00 96 00 0F 00 28 28 64 00 14 00 00 FF FF FF FF FF FF FF FF FF FF 00 00 00 00 00
```

Province name strings, 8 bytes per entry at PRG `$21A1A` (bank `$30` `$9A1A`):

```
 0  0x21a1a $9A1A  2B37061706       リョウトウ    辽东
 1  0x21a22 $9A22  28060F3606       ユウシュウ    幽州
 2  0x21a2a $9A2A  20050F3606       ヘイシュウ    并州
 3  0x21a32 $9A32  11050F3606       セイシュウ    青州
 4  0x21a3a $9A3A  0A0F3606         キシュウ      冀州
 5  0x21a42 $9A42  110504312906     セイアンヨウ  西安阳
 6  0x21a4a $9A4A  2B37060F3606     リョウシュウ  凉州
 7  0x21a52 $9A52  04311605         アンテイ      安定
 8  0x21a5a $9A5A  1437060431       チョウアン    长安
 9  0x21a62 $9A62  110520050931     セイヘイカン  西平关
10  0x21a6a $9A6A  0F39370F3606     ジョシュウ    徐州
11  0x21a72 $9A72  07310F3606       エンシュウ    兖州
12  0x21a7a $9A7A  2A0B2906         ラクヨウ      洛阳
13  0x21a82 $9A82  0F3127           シンヤ        新野
14  0x21a8a $9A8A  290F3606         ヨシュウ      豫州
15  0x21a92 $9A92  0C310A393706     ケンギョウ    建业
16  0x21a9a $9A9A  29060F3606       ヨウシュウ    扬州
17  0x21aa2 $9AA2  0C310431         ケンアン      建安
18  0x21aaa $9AAA  0D060F3606       コウシュウ    交州
19  0x21ab2 $9AB2  050B2B31         イクリン      郁林
20  0x21aba $9ABA  0D0609           コウカ        江夏
21  0x21ac2 $9AC2  0C050F3606       ケイシュウ    荆州
22  0x21aca $9ACA  0F37062906       ショウヨウ    襄阳
23  0x21ad2 $9AD2  1437060E         チョウサ      长沙
24  0x21ada $9ADA  2D052B3706       レイリョウ    零陵
25  0x21ae2 $9AE2  0931143606       カンチュウ    汉中
26  0x21aea $9AEA  110517           セイト        成都
27  0x21af2 $9AF2  1F2B3706         フリョウ      涪陵
28  0x21afa $9AFA  06311831         ウンナン      云南
29  0x21b02 $9B02  07050F3706       エイショウ    永昌
```

## How the field map was verified

Every offset in the record layout above is backed by code, not
guessed from the values:

| Field | Evidence |
|---|---|
| `+0` 所属国 | `ProvinceCountByOwner` (`asm/banks/prg_19_1a.asm`) masks the byte with `#$0F` and compares against a Country id; `FindOfficerProvince` scans the same records |
| `+2/+3` 金 | 徴兵 (`$B294`, `asm/banks/prg_1b_1c.asm`) charges 20 gold per 100 men here; 輸送 (`$B8D7`, `prg_19_1a.asm`) moves it |
| `+4/+5` 米 | 輸送 moves it as the second 16-bit resource; the annual harvest (below) credits it |
| `+6/+7` 人口 | panel stream draws it with 5 digits followed by two literal `$B6` (`0`) tiles, so the stored value is / 100 |
| `+8/+9` 土地 | annual harvest (`$A60B`, `prg_19_1a.asm`): `land / lvl_div * lvl_base / $3C * 統治度tier / 100` is **added to 米** (`+4/+5`) |
| `+10` 防災 | panel stream draws it with 2 digits (max 99) right after 人口, matching the panel order in `docs/manual_kb/03-country-stats.md` |
| `+11` 統治度 | `AnnualTakeoverCheck` (`$AB6E`) rolls a revolt when it is `< 50` (tiers at 50/40/30/20); both income routines scale their yield by its 50/60/70/80/90/100 tier |
| `+12/+13` 控え | 徴兵 adds the recruited men here and clamps at `$2710` (10000) |
| `+14/+15` 産業 | annual tax (`$A446`, `prg_19_1a.asm`): `industry / lvl_div * lvl_base / $50 * 統治度tier / 100` is **added to 金** (`+2/+3`) |
| `+16` 宝 | 輸送 moves it as an 8-bit resource, clamped at 99 |
| `+17..+26` 武将 | `FindOfficerProvince` and the `$F0`/`$F3` panel commands walk slots `$11-$1A` looking for `$FF` |
| `+27` cooldown | `AnnualTakeoverMark` stores 6 there, and the revolt check skips a province while it is non-zero |

The 産業 -> 金 / 土地 -> 米 pair is what disambiguates the two
999-capped 16-bit stats, and it agrees with the panel order
(金, 米, 土地, 産業, 人口, 防災, 武将, 兵士, 統治度) transcribed
from the manual.
