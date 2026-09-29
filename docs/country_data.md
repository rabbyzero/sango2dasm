# Country data extracted from the ROM

The 7 Countries (国) at the 189 new-game start: each Ruler (君主), their home Province, the Provinces they own, and their aggregated resources, read out of the iNES image by `tools/extract_country_data.py`.

A Country owns one or more Provinces; its resources are the sum over those Provinces (there is no per-country stat table in ROM). Column names use the canonical semantic English terms from `docs/manual_kb/terminology.md`.

* Country -> Ruler seed: `WarResult_RecordInitTable`, bank $08/$09 CPU `$DA0F` (7 x 4 B, byte [0] = Ruler id)
* Country record (SRAM): 7 x 8 B at `$6F07` (stride 8), via `B1F_GetCountryDataPtr` ($F368) / `CountryDataPtrTable` ($F379)
* Province -> Country: low nibble of province master record `+0` (bank $30 CPU `$8C00`)
* Per-country stats are the 189 new-game start, summed over the owned Province master records

## Country record layout (SRAM `$6F07`)

Seven 8-byte records at `$6F07`, `$6F0F`, ... `$6F37` (stride 8), resolved by `B1F_GetCountryDataPtr` ($F368). The seed below is written by `WarResultEntryInit` ($D97A) from `WarResult_RecordInitTable` ($DA0F).

| Offset | Field | Notes |
|---|---|---|
| `[0]` | Ruler officer id | `$FF` = Country destroyed |
| `[1]` | Home Province id | the Ruler's seat |
| `[2]` | - | 0 in the seed |
| `[3]` | status byte | 0 normal, 3 = at war / AI ruler (seed value `$03`) |
| `[4..7]` | alliance nibbles | packed, one per rival Country; any non-zero nibble = allied |

## CSV columns

`docs/country_data.csv` column names are the snake_case form of the canonical semantic English terms in `docs/manual_kb/terminology.md`.

| Column | 日本語 | Meaning |
|---|---|---|
| `id` | 国番号 | Country id (low nibble of province record `+0`) |
| `ruler_officer_id` | 君主 | Ruler Officer id (Country record `[0]`) |
| `ruler_katakana` | 君主 | Ruler name as stored in the ROM |
| `ruler_zh_hans` | 君主 | Ruler name, simplified Chinese |
| `ruler_pinyin` | 君主 | Mandarin reading of the Ruler name |
| `home_province_id` | 本拠地 | Home Province id (Country record `[1]`) |
| `home_province` | 本拠地 | Home Province name, simplified Chinese |
| `province_count` | 州数 | Number of Provinces owned |
| `province_ids` | 州 | Owned Province ids, ascending |
| `province_names` | 州 | Owned Province names, simplified Chinese |
| `total_troops` | 兵士 | 兵士: 現役 active + 控え reserve |
| `gold` | 金 | Gold (sum of owned provinces, record `+2/+3`) |
| `rice` | 米 | Rice (sum of owned provinces, record `+4/+5`) |
| `population` | 人口 | Population (sum of owned provinces x 100) |
| `land_value` | 土地 | LandValue (sum of owned provinces, record `+8/+9`) |
| `industry` | 産業 | Industry (sum of owned provinces, record `+14/+15`) |
| `reserve_troops` | 控え | ReserveTroops (sum of owned provinces, record `+12/+13`) |
| `treasure` | 宝 | Treasure (sum of owned provinces, record `+16`) |
| `officer_count` | 武将数 | Officers on the provincial rosters (sum) |
| `active_troops` | 現役 | ActiveTroops: sum of rostered Officers TroopCount |

## Countries at the 189 start

| Country id | Ruler | Home province | Provinces |
|---:|---|---|---|
| 0 | 董卓 トウタク (dǒng zhuó) (id 173) | 洛阳 (id 12) | 长安 洛阳 |
| 1 | 袁绍 エンショウ (yuán shào) (id 8) | 冀州 (id 4) | 幽州 青州 冀州 |
| 2 | 曹操 ソウソウ (cáo cāo) (id 131) | 兖州 (id 11) | 兖州 豫州 |
| 3 | 孙策 ソンサク (sūn cè) (id 138) | 江夏 (id 20) | 建业 扬州 建安 江夏 |
| 4 | 刘备 リュウビ (liú bèi) (id 222) | 并州 (id 2) | 并州 |
| 5 | 刘璋 リュウショウ (liú zhāng) (id 220) | 成都 (id 26) | 汉中 成都 涪陵 云南 |
| 6 | 马腾 バトウ (mǎ téng) (id 182) | 凉州 (id 6) | 凉州 安定 西平关 |

## Aggregated resources

人口 is the value the game shows (stored / 100 x 100). 兵士 is 現役 (summed from the roster) + 控え (ReserveTroops).

| id | Ruler | 州 | 金 | 米 | 人口 | 土地 | 産業 | 宝 | 武将 | 現役 | 控え | 兵士 |
|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 0 | 董卓 | 2 | 950 | 1340 | 78000 | 65 | 80 | 0 | 10 | 8000 | 200 | 8200 |
| 1 | 袁绍 | 3 | 670 | 990 | 80000 | 100 | 135 | 0 | 11 | 7800 | 300 | 8100 |
| 2 | 曹操 | 2 | 470 | 690 | 43000 | 45 | 55 | 0 | 7 | 5800 | 200 | 6000 |
| 3 | 孙策 | 4 | 990 | 1440 | 85000 | 105 | 100 | 0 | 8 | 6500 | 400 | 6900 |
| 4 | 刘备 | 1 | 190 | 280 | 21000 | 30 | 35 | 0 | 3 | 2100 | 100 | 2200 |
| 5 | 刘璋 | 4 | 850 | 1260 | 76000 | 85 | 80 | 0 | 11 | 7500 | 400 | 7900 |
| 6 | 马腾 | 3 | 510 | 750 | 40000 | 50 | 60 | 0 | 7 | 5500 | 300 | 5800 |

## Province breakdown

Every owned Province with its own starting stats (the rows that sum into the table above).

| Country | Province | 金 | 米 | 人口 | 土地 | 産業 | 防災 | 統治度 | 現役 | 控え | 武将 |
|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 0 | 8 长安 チョウアン | 500 | 700 | 40000 | 30 | 40 | 50 | 20 | 4500 | 100 | 5 |
| 0 | 12 洛阳 ラクヨウ | 450 | 640 | 38000 | 35 | 40 | 45 | 20 | 3500 | 100 | 5 |
| 1 | 1 幽州 ユウシュウ | 180 | 270 | 20000 | 25 | 40 | 30 | 40 | 2300 | 100 | 3 |
| 1 | 3 青州 セイシュウ | 220 | 330 | 25000 | 35 | 50 | 35 | 50 | 2000 | 100 | 4 |
| 1 | 4 冀州 キシュウ | 270 | 390 | 35000 | 40 | 45 | 45 | 50 | 3500 | 100 | 4 |
| 2 | 11 兖州 エンシュウ | 220 | 330 | 21000 | 25 | 30 | 40 | 50 | 2500 | 100 | 3 |
| 2 | 14 豫州 ヨシュウ | 250 | 360 | 22000 | 20 | 25 | 50 | 50 | 3300 | 100 | 4 |
| 3 | 15 建业 ケンギョウ | 270 | 380 | 26000 | 25 | 30 | 45 | 50 | 1500 | 100 | 2 |
| 3 | 16 扬州 ヨウシュウ | 230 | 340 | 22000 | 30 | 25 | 40 | 45 | 1500 | 100 | 2 |
| 3 | 17 建安 ケンアン | 200 | 300 | 17000 | 25 | 20 | 40 | 40 | 500 | 100 | 1 |
| 3 | 20 江夏 コウカ | 290 | 420 | 20000 | 25 | 25 | 45 | 45 | 3000 | 100 | 3 |
| 4 | 2 并州 ヘイシュウ | 190 | 280 | 21000 | 30 | 35 | 40 | 45 | 2100 | 100 | 3 |
| 5 | 25 汉中 カンチュウ | 250 | 370 | 23000 | 20 | 25 | 50 | 45 | 2500 | 100 | 3 |
| 5 | 26 成都 セイト | 240 | 360 | 21000 | 25 | 20 | 45 | 40 | 1800 | 100 | 4 |
| 5 | 27 涪陵 フリョウ | 190 | 280 | 17000 | 20 | 20 | 40 | 40 | 1200 | 100 | 2 |
| 5 | 28 云南 ウンナン | 170 | 250 | 15000 | 20 | 15 | 35 | 35 | 2000 | 100 | 2 |
| 6 | 6 凉州 リョウシュウ | 170 | 250 | 14000 | 15 | 20 | 40 | 45 | 1500 | 100 | 2 |
| 6 | 7 安定 アンテイ | 190 | 280 | 16000 | 20 | 25 | 35 | 40 | 2500 | 100 | 3 |
| 6 | 9 西平关 セイヘイカン | 150 | 220 | 10000 | 15 | 15 | 20 | 30 | 1500 | 100 | 2 |

## Ruler seed cross-check

The `WarResult_RecordInitTable` seed (Country slot -> Ruler id) is independent of the province-derived Ruler (the roster officer whose Loyalty is 100). They agree for every Country:

| Country id | seed Ruler | derived Ruler | match |
|---:|---:|---:|:---:|
| 0 | 173 | 173 | ✓ |
| 1 | 8 | 8 | ✓ |
| 2 | 131 | 131 | ✓ |
| 3 | 138 | 138 | ✓ |
| 4 | 222 | 222 | ✓ |
| 5 | 220 | 220 | ✓ |
| 6 | 182 | 182 | ✓ |

## How the mapping was verified

| Fact | Evidence |
|---|---|
| Country slot -> Ruler id | `WarResult_RecordInitTable` ($DA0F, `asm/banks/prg_08_09.asm`) and its inlined copy in `WarResultEntryInit` ($D97A) write `$AD,$08,$83,$8A,$DE,$DC,$B6` into `[0]` of the 7 records at `$6F07` |
| Ruler == Loyalty-100 officer | `extract_province_data.load_provinces` flags the roster officer whose Loyalty is 100; the two agree for all 7 Countries (cross-check table above) |
| Province -> Country id | `ProvinceCountByOwner` / `FindOfficerProvince` (`asm/banks/prg_19_1a.asm`) mask province record `+0` with `#$0F` and compare to the acting Country id; `7` = `UnclaimedLand` |
| Country record base | `B1F_GetCountryDataPtr` ($F368) / `GetCountryRecordPtr` ($D319) / `@CountryRecordPtrTable` ($A0D6) all index the 7 pointers `$6F07, $6F0F, ... $6F37` |
| Alliance nibbles `[4..7]` | `@MarkAllianceNibbles` / `@ApplyNibbleMarker` (`asm/banks/prg_0a_0b.asm`) set one nibble per rival in `[4..7]`; `@CountCountriesLoop` treats `[0] == $FF` as an empty Country |
| Home Province `[1]` | `AttractDemoDispatch` (@CountrySelect, `asm/banks/prg_19_1a.asm`) resolves the Ruler's Province via `FindOfficerProvince` and stores it in record `[1]` |
| Resources = sum of Provinces | No per-country stat table exists in ROM; the stats panel (`docs/manual_kb/03-province-stats.md`) and the AI budget (`@OrderScrollByProvinceTable`) are computed per-province and per-owned-province-count respectively |
