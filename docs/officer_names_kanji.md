# Officer names: katakana, kanji and Chinese

The ROM's font has no kanji, so all 237 officer names are stored as katakana
only (see [officer_names.txt](officer_names.txt) for the raw extraction and
`tools/extract_officer_names.py` for how it is decoded).  This file adds the
kanji form of each name plus its Chinese readings.

## How the kanji were established

1. `tools/extract_officer_names.py` decodes the katakana for all 240 name
   slots out of PRG bank `$30` (`$901A`, 10 bytes/entry); 237 are filled in.
2. Published transcriptions of this ROM's roster list every officer with the
   kanji name *and* the five visible stats.  Each roster row was joined to a ROM
   officer id by an exact match on `(体力, 武力, 知力, 忠誠度, 人徳)` read from the
   master stat table in PRG bank `$31` (`$8000`, 12 bytes/record).  236 of 237
   rows matched exactly one id; the last one (`張遼`, id 156) fell out by
   elimination.
3. Every kanji name was then reading-checked against the ROM katakana by
   composing the on-yomi of its characters, which caught a dozen transcription
   slips in the published lists (`於禁`->`于禁`, `盧翻`->`虞翻`, `朱恆`->`朱桓`,
   `程乘`->`程秉`, `尚寵`->`向寵`, `藩璋`->`潘璋`, ...).  See the `note` column.
4. `kanji_ja` is the Japanese shinjitai form (as ja.wikipedia writes it).
   `zh_hant`/`zh_hans` are the standard Chinese forms and `pinyin` is Hanyu
   Pinyin with tone marks.  Where Chinese usage differs from the Japanese form
   the difference is called out in `note` (e.g. `逢紀` / `逄纪`).

`tools/data/officer_kanji.tsv` is the checked-in map; run
`python tools/map_officer_kanji.py` to regenerate this file and
[officer_names_kanji.csv](officer_names_kanji.csv) from it.  The script
re-validates the map (one-to-one, ids match the ROM, readings compose) on every
run, so it fails loudly if the table and the ROM ever drift apart.

## Caveats

* Two names are in-game abbreviations rather than real names: id 53 `ギキョ`
  drops the surname of `蔣義渠`, and id 60 `キンカンケツ` shortens `金環三結` to
  fit the 7-glyph name field.
* id 115 `ジンソウ` = `任双` has no canonical Three Kingdoms referent; it is the
  form Yoshikawa Eiji's novel uses for the Yanyi character `任夔`.
* Names that the game shares with the Romance of the Three Kingdoms novel but
  not with the historical records (`関興`, `関索`, `蔡陽`, `董荼奴`, `雅丹`, ...)
  are kept in the novel's spelling, which is what the game used.

## Table

| id | katakana | romaji | kanji (ja) | 繁體 | 简体 | pinyin | note |
|---:|---|---|---|---|---|---|---|
| 0 | アカイナン | Akainan | 阿会喃 | 阿會喃 | 阿会喃 | ā huì nán |  |
| 1 | イコウ | Ikou | 韋康 | 韋康 | 韦康 | wéi kāng |  |
| 2 | イセキ | Iseki | 伊籍 | 伊籍 | 伊籍 | yī jí |  |
| 3 | インカイ | Inkai | 尹楷 | 尹楷 | 尹楷 | yǐn kǎi |  |
| 4 | インショウ | Inshou | 尹賞 | 尹賞 | 尹赏 | yǐn shǎng |  |
| 5 | ウキン | Ukin | 于禁 | 于禁 | 于禁 | yú jìn | page transcription 於禁 corrected (於=オ); ROM reads ウキン |
| 6 | エツキツ | Etsukitsu | 越吉 | 越吉 | 越吉 | yuè jí |  |
| 7 | エンキ | Enki | 袁煕 | 袁熙 | 袁熙 | yuán xī |  |
| 8 | エンショウ | Enshou | 袁紹 | 袁紹 | 袁绍 | yuán shào |  |
| 9 | エンタン | Entan | 袁譚 | 袁譚 | 袁谭 | yuán tán |  |
| 10 | エンホ | Enho | 閻圃 | 閻圃 | 阎圃 | yán pǔ |  |
| 11 | オウケン | Ouken | 王建 | 王建 | 王建 | wáng jiàn |  |
| 12 | オウサン | Ousan | 王粲 | 王粲 | 王粲 | wáng càn |  |
| 13 | オウソウ | Ousou | 王双 | 王雙 | 王双 | wáng shuāng |  |
| 14 | オウチュウ | Ouchuu | 王忠 | 王忠 | 王忠 | wáng zhōng |  |
| 15 | オウヘイ | Ouhei | 王平 | 王平 | 王平 | wáng píng |  |
| 16 | オウホ | Ouho | 王甫 | 王甫 | 王甫 | wáng fǔ |  |
| 17 | オウルイ | Ourui | 王累 | 王累 | 王累 | wáng lèi |  |
| 18 | カイエツ | Kaietsu | 蒯越 | 蒯越 | 蒯越 | kuǎi yuè |  |
| 19 | カイリョウ | Kairyou | 蒯良 | 蒯良 | 蒯良 | kuǎi liáng |  |
| 20 | カカ | Kaka | 賈華 | 賈華 | 贾华 | jiǎ huá |  |
| 21 | カキン | Kakin | 華歆 | 華歆 | 华歆 | huà xīn |  |
| 22 | カク | Kaku | 賈詡 | 賈詡 | 贾诩 | jiǎ xǔ |  |
| 23 | カクシ | Kakushi | 郭汜 | 郭汜 | 郭汜 | guō sì |  |
| 24 | カクカ | Kakuka | 郭嘉 | 郭嘉 | 郭嘉 | guō jiā |  |
| 25 | カクショウ | Kakushou | 郝昭 | 郝昭 | 郝昭 | hǎo zhāo |  |
| 26 | ガクシン | Gakushin | 楽進 | 樂進 | 乐进 | yuè jìn |  |
| 27 | カクト | Kakuto | 郭図 | 郭圖 | 郭图 | guō tú |  |
| 28 | カクワイ | Kakuwai | 郭淮 | 郭淮 | 郭淮 | guō huái |  |
| 29 | カコウエン | Kakouen | 夏侯淵 | 夏侯淵 | 夏侯渊 | xià hóu yuān |  |
| 30 | カコウトン | Kakouton | 夏侯惇 | 夏侯惇 | 夏侯惇 | xià hóu dūn | page transcription 夏候惇 corrected |
| 31 | カコウハ | Kakouha | 夏侯覇 | 夏侯霸 | 夏侯霸 | xià hóu bà |  |
| 32 | カコウボウ | Kakoubou | 夏侯楙 | 夏侯楙 | 夏侯楙 | xià hóu mào |  |
| 33 | カコウラン | Kakouran | 夏侯蘭 | 夏侯蘭 | 夏侯兰 | xià hóu lán |  |
| 34 | ガタン | Gatan | 雅丹 | 雅丹 | 雅丹 | yǎ dān |  |
| 35 | ガッカン | Gakkan | 鄂煥 | 鄂煥 | 鄂焕 | è huàn |  |
| 36 | カハン | Kahan | 賈範 | 賈範 | 贾范 | jiǎ fàn | page transcription had a stray trailing kana |
| 37 | カユウ | Kayuu | 華雄 | 華雄 | 华雄 | huà xióng |  |
| 38 | カンウ | Kan'u | 関羽 | 關羽 | 关羽 | guān yǔ |  |
| 39 | カンエイ | Kan'ei | 韓瑛 | 韓瑛 | 韩瑛 | hán yīng |  |
| 40 | カンキ | Kanki | 韓琪 | 韓琪 | 韩琪 | hán qí |  |
| 41 | カンゲン | Kangen | 韓玄 | 韓玄 | 韩玄 | hán xuán |  |
| 42 | カンコウ | Kankou | 関興 | 關興 | 关兴 | guān xīng |  |
| 43 | カンサク | Kansaku | 関索 | 關索 | 关索 | guān suǒ |  |
| 44 | カンスイ | Kansui | 韓遂 | 韓遂 | 韩遂 | hán suì |  |
| 45 | カントウ | Kantou | 韓当 | 韓當 | 韩当 | hán dāng |  |
| 46 | カントク | Kantoku | 韓徳 | 韓德 | 韩德 | hán dé |  |
| 47 | カンネイ | Kannei | 甘寧 | 甘寧 | 甘宁 | gān níng |  |
| 48 | カンペイ | Kanpei | 関平 | 關平 | 关平 | guān píng |  |
| 49 | カンモウ | Kanmou | 韓猛 | 韓猛 | 韩猛 | hán měng |  |
| 50 | カンヨウ | Kanyou | 簡雍 | 簡雍 | 简雍 | jiǎn yōng |  |
| 51 | ガンリョウ | Ganryou | 顔良 | 顏良 | 颜良 | yán liáng |  |
| 52 | ギエン | Gien | 魏延 | 魏延 | 魏延 | wèi yán |  |
| 53 | ギキョ | Gikyo | 義渠 | 義渠 | 义渠 | yì qú | in-game name drops the surname of 蔣義渠 (Jiang Yiqu) |
| 54 | ギュウキン | Gyuukin | 牛金 | 牛金 | 牛金 | niú jīn |  |
| 55 | キョウイ | Kyoui | 姜維 | 姜維 | 姜维 | jiāng wéi |  |
| 56 | キョユウ | Kyoyuu | 許攸 | 許攸 | 许攸 | xǔ yōu |  |
| 57 | キョチョ | Kyocho | 許褚 | 許褚 | 许褚 | xǔ chǔ | page transcription 許緒 corrected (許褚, キョチョ) |
| 58 | ギラン | Giran | 嬀覧 | 媯覽 | 妫览 | guī lǎn |  |
| 59 | キレイ | Kirei | 紀霊 | 紀靈 | 纪灵 | jì líng |  |
| 60 | キンカンケツ | Kinkanketsu | 金環結 | 金環結 | 金环结 | jīn huán jié | in-game name shortens 金環三結 to fit the 7-glyph name field |
| 61 | グホン | Guhon | 虞翻 | 虞翻 | 虞翻 | yú fān | page transcription 盧翻 corrected (虞翻, グホン) |
| 62 | ケイドウエイ | Keidouei | 邢道栄 | 邢道榮 | 邢道荣 | xíng dào róng | page transcription 刑道榮 corrected (邢道栄) |
| 63 | ゲンガン | Gengan | 厳顔 | 嚴顏 | 严颜 | yán yán |  |
| 64 | ゲンシュン | Genshun | 厳畯 | 嚴畯 | 严畯 | yán jùn |  |
| 65 | ゲンコウ | Genkou | 厳綱 | 嚴綱 | 严纲 | yán gāng |  |
| 66 | ゴイ | Goi | 呉懿 | 吳懿 | 吴懿 | wú yì |  |
| 67 | コウガイ | Kougai | 黄蓋 | 黃蓋 | 黄盖 | huáng gài |  |
| 68 | コウカン | Koukan | 高幹 | 高幹 | 高干 | gāo gàn |  |
| 69 | コウショウ | Koushou | 高翔 | 高翔 | 高翔 | gāo xiáng |  |
| 70 | コウケン | Kouken | 黄権 | 黃權 | 黄权 | huáng quán |  |
| 71 | コウセイ | Kousei | 侯成 | 侯成 | 侯成 | hóu chéng |  |
| 72 | コウセン | Kousen | 侯選 | 侯選 | 侯选 | hóu xuǎn |  |
| 73 | コウソンエン | Kouson'en | 公孫淵 | 公孫淵 | 公孙渊 | gōng sūn yuān |  |
| 74 | コウソンコウ | Kousonkou | 公孫康 | 公孫康 | 公孙康 | gōng sūn kāng |  |
| 75 | コウチュウ | Kouchuu | 黄忠 | 黃忠 | 黄忠 | huáng zhōng |  |
| 76 | コウテイ | Koutei | 高定 | 高定 | 高定 | gāo dìng |  |
| 77 | コウラン | Kouran | 高覧 | 高覽 | 高览 | gāo lǎn |  |
| 78 | ゴツトツコツ | Gotsutotsukotsu | 兀突骨 | 兀突骨 | 兀突骨 | wù tū gǔ |  |
| 79 | コヨウ | Koyou | 顧雍 | 顧雍 | 顾雍 | gù yōng |  |
| 80 | コシャジ | Koshaji | 胡車児 | 胡車兒 | 胡车儿 | hú chē ér |  |
| 81 | ゴラン | Goran | 呉蘭 | 吳蘭 | 吴兰 | wú lán |  |
| 82 | サイエン | Saien | 崔琰 | 崔琰 | 崔琰 | cuī yǎn |  |
| 83 | サイヨウ | Saiyou | 蔡陽 | 蔡陽 | 蔡阳 | cài yáng | Sanguozhi writes 蔡揚; the game/Yanyi form 蔡陽 is used here |
| 84 | サイリョウ | Sairyou | 崔諒 | 崔諒 | 崔谅 | cuī liàng |  |
| 85 | シカン | Shikan | 史渙 | 史渙 | 史涣 | shǐ huàn |  |
| 86 | シバイ | Shibai | 司馬懿 | 司馬懿 | 司马懿 | sī mǎ yì |  |
| 87 | シバシ | Shibashi | 司馬師 | 司馬師 | 司马师 | sī mǎ shī |  |
| 88 | シバショウ | Shibashou | 司馬昭 | 司馬昭 | 司马昭 | sī mǎ zhāo |  |
| 89 | シュウゼン | Shuuzen | 周善 | 周善 | 周善 | zhōu shàn |  |
| 90 | シュウソウ | Shuusou | 周倉 | 周倉 | 周仓 | zhōu cāng |  |
| 91 | シュウタイ | Shuutai | 周泰 | 周泰 | 周泰 | zhōu tài |  |
| 92 | シュウホウ | Shuuhou | 周魴 | 周魴 | 周鲂 | zhōu fáng |  |
| 93 | シュウユ | Shuuyu | 周瑜 | 周瑜 | 周瑜 | zhōu yú |  |
| 94 | シュカン | Shukan | 朱桓 | 朱桓 | 朱桓 | zhū huán | page transcription 朱恆 corrected (朱桓, シュカン) |
| 95 | シュゼン | Shuzen | 朱然 | 朱然 | 朱然 | zhū rán |  |
| 96 | シュチ | Shuchi | 朱治 | 朱治 | 朱治 | zhū zhì |  |
| 97 | シュホウ | Shuhou | 朱褒 | 朱褒 | 朱褒 | zhū bāo |  |
| 98 | シュレイ | Shurei | 朱霊 | 朱靈 | 朱灵 | zhū líng |  |
| 99 | ジュンイク | Jun'iku | 荀彧 | 荀彧 | 荀彧 | xún yù |  |
| 100 | ジュンウケイ | Jun'ukei | 淳于瓊 | 淳于瓊 | 淳于琼 | chún yú qióng | page transcription 淳於瓊 corrected (於=オ) |
| 101 | ジュンジン | Junjin | 荀諶 | 荀諶 | 荀谌 | xún chén |  |
| 102 | ショウカン | Shoukan | 蔣幹 | 蔣幹 | 蒋干 | jiǎng gàn |  |
| 103 | ショウカイ | Shoukai | 鍾会 | 鍾會 | 钟会 | zhōng huì |  |
| 104 | ショウエン | Shouen | 蔣琬 | 蔣琬 | 蒋琬 | jiǎng wǎn |  |
| 105 | ショウチョウ | Shouchou | 向寵 | 向寵 | 向宠 | xiàng chǒng | page transcription 尚寵 corrected (向寵, ショウチョウ) |
| 106 | ジョエイ | Joei | 徐栄 | 徐榮 | 徐荣 | xú róng |  |
| 107 | ショカツキン | Shokatsukin | 諸葛瑾 | 諸葛瑾 | 诸葛瑾 | zhū gě jǐn |  |
| 108 | ショカツセン | Shokatsusen | 諸葛瞻 | 諸葛瞻 | 诸葛瞻 | zhū gě zhān |  |
| 109 | ショカツリョウ | Shokatsuryou | 諸葛亮 | 諸葛亮 | 诸葛亮 | zhū gě liàng |  |
| 110 | ショカツカク | Shokatsukaku | 諸葛恪 | 諸葛恪 | 诸葛恪 | zhū gě kè |  |
| 111 | ジョコウ | Jokou | 徐晃 | 徐晃 | 徐晃 | xú huǎng |  |
| 112 | ジョショ | Josho | 徐庶 | 徐庶 | 徐庶 | xú shù |  |
| 113 | ジョセイ | Josei | 徐盛 | 徐盛 | 徐盛 | xú shèng |  |
| 114 | ジンシュン | Jinshun | 任峻 | 任峻 | 任峻 | rèn jùn |  |
| 115 | ジンソウ | Jinsou | 任双 | 任雙 | 任双 | rèn shuāng | no canonical Three Kingdoms referent; 任双 is Yoshikawa’s form of Yanyi’s 任夔 |
| 116 | シンタン | Shintan | 申耽 | 申耽 | 申耽 | shēn dān |  |
| 117 | シンパイ | Shinpai | 審配 | 審配 | 审配 | shěn pèi |  |
| 118 | シンピ | Shinpi | 辛毗 | 辛毗 | 辛毗 | xīn pí | 辛毘 and 辛毗 are variants of the same name |
| 119 | シンピョウ | Shinpyou | 辛評 | 辛評 | 辛评 | xīn píng |  |
| 120 | セイギ | Seigi | 成宜 | 成宜 | 成宜 | chéng yí |  |
| 121 | セッソウ | Sessou | 薛綜 | 薛綜 | 薛综 | xuē zōng |  |
| 122 | ゼンソウ | Zensou | 全琮 | 全琮 | 全琮 | quán cóng |  |
| 123 | ソウエイ | Souei | 曹叡 | 曹叡 | 曹叡 | cáo ruì |  |
| 124 | ソウキュウ | Soukyuu | 曹休 | 曹休 | 曹休 | cáo xiū |  |
| 125 | ソウケン | Souken | 宋憲 | 宋憲 | 宋宪 | sòng xiàn |  |
| 126 | ソウコウ | Soukou | 曹洪 | 曹洪 | 曹洪 | cáo hóng |  |
| 127 | ソウショウ | Soushou | 曹彰 | 曹彰 | 曹彰 | cáo zhāng |  |
| 128 | ソウショク | Soushoku | 曹植 | 曹植 | 曹植 | cáo zhí |  |
| 129 | ソウシン | Soushin | 曹真 | 曹真 | 曹真 | cáo zhēn |  |
| 130 | ソウジン | Soujin | 曹仁 | 曹仁 | 曹仁 | cáo rén |  |
| 131 | ソウソウ | Sousou | 曹操 | 曹操 | 曹操 | cáo cāo |  |
| 132 | ソウヒ | Souhi | 曹丕 | 曹丕 | 曹丕 | cáo pī |  |
| 133 | ソウユウ | Souyuu | 曹熊 | 曹熊 | 曹熊 | cáo xióng |  |
| 134 | ソジュ | Soju | 沮授 | 沮授 | 沮授 | jǔ shòu |  |
| 135 | ソヒ | Sohi | 蘇飛 | 蘇飛 | 苏飞 | sū fēi |  |
| 136 | ソンカン | Sonkan | 孫乾 | 孫乾 | 孙乾 | sūn qián | OpenCC would give 孙干; the correct simplified form is 孙乾 |
| 137 | ソンケン | Sonken | 孫権 | 孫權 | 孙权 | sūn quán | 孫権, not 孫堅 - 孫策 is the playable Wu ruler in this game |
| 138 | ソンサク | Sonsaku | 孫策 | 孫策 | 孙策 | sūn cè |  |
| 139 | ソンヨク | Sonyoku | 孫翊 | 孫翊 | 孙翊 | sūn yì |  |
| 140 | ソンレイ | Sonrei | 孫礼 | 孫禮 | 孙礼 | sūn lǐ |  |
| 141 | タイシジ | Taishiji | 太史慈 | 太史慈 | 太史慈 | tài shǐ cí |  |
| 142 | タンユウ | Tanyuu | 譚雄 | 譚雄 | 谭雄 | tán xióng |  |
| 143 | チョウサイ | Chousai | 張済 | 張濟 | 张济 | zhāng jì |  |
| 144 | チョウウン | Chouun | 趙雲 | 趙雲 | 赵云 | zhào yún |  |
| 145 | チョウエイ | Chouei | 張衛 | 張衛 | 张卫 | zhāng wèi |  |
| 146 | チョウオウ | Chouou | 張横 | 張橫 | 张横 | zhāng héng |  |
| 147 | チョウギ | Chougi | 張嶷 | 張嶷 | 张嶷 | zhāng yí |  |
| 148 | チョウゲツ | Chougetsu | 趙月 | 趙月 | 赵月 | zhào yuè |  |
| 149 | チョウコウ | Choukou | 張郃 | 張郃 | 张郃 | zhāng hé |  |
| 150 | チョウショウ | Choushou | 張松 | 張松 | 张松 | zhāng sōng |  |
| 151 | チョウジン | Choujin | 張任 | 張任 | 张任 | zhāng rèn |  |
| 152 | チョウナン | Chounan | 張南 | 張南 | 张南 | zhāng nán |  |
| 153 | チョウヒ | Chouhi | 張飛 | 張飛 | 张飞 | zhāng fēi |  |
| 154 | チョウホウ | Chouhou | 張苞 | 張苞 | 张苞 | zhāng bāo |  |
| 155 | チョウヨク | Chouyoku | 張翼 | 張翼 | 张翼 | zhāng yì |  |
| 156 | チョウリョウ | Chouryou | 張遼 | 張遼 | 张辽 | zhāng liáo |  |
| 157 | チンシン | Chinshin | 陳震 | 陳震 | 陈震 | chén zhèn |  |
| 158 | チンブ | Chinbu | 陳武 | 陳武 | 陈武 | chén wǔ |  |
| 159 | チンラン | Chinran | 陳蘭 | 陳蘭 | 陈兰 | chén lán |  |
| 160 | チンリン | Chinrin | 陳琳 | 陳琳 | 陈琳 | chén lín |  |
| 161 | テイイク | Teiiku | 程昱 | 程昱 | 程昱 | chéng yù |  |
| 162 | テイギン | Teigin | 程銀 | 程銀 | 程银 | chéng yín |  |
| 163 | テイフ | Teifu | 程普 | 程普 | 程普 | chéng pǔ |  |
| 164 | テイヘイ | Teihei | 程秉 | 程秉 | 程秉 | chéng bǐng | page transcription 程乘 corrected (程秉, テイヘイ) |
| 165 | テンイ | Ten'i | 典韋 | 典韋 | 典韦 | diǎn wéi |  |
| 166 | デンチュウ | Denchuu | 田疇 | 田疇 | 田畴 | tián chóu |  |
| 167 | デンホウ | Denhou | 田豊 | 田豐 | 田丰 | tián fēng |  |
| 168 | トウイン | Touin | 董允 | 董允 | 董允 | dǒng yǔn |  |
| 169 | トウガイ | Tougai | 鄧艾 | 鄧艾 | 邓艾 | dèng ài |  |
| 170 | トウシ | Toushi | 鄧芝 | 鄧芝 | 邓芝 | dèng zhī |  |
| 171 | トウシュウ | Toushuu | 董襲 | 董襲 | 董袭 | dǒng xí |  |
| 172 | トウトヌ | Toutonu | 董荼奴 | 董荼奴 | 董荼奴 | dǒng tú nú | page transcription 董茶奴 corrected; Yanyi also writes 董荼那 |
| 173 | トウタク | Toutaku | 董卓 | 董卓 | 董卓 | dǒng zhuó |  |
| 174 | バエン | Baen | 馬延 | 馬延 | 马延 | mǎ yán |  |
| 175 | バガン | Bagan | 馬玩 | 馬玩 | 马玩 | mǎ wán |  |
| 176 | バキュウ | Bakyuu | 馬休 | 馬休 | 马休 | mǎ xiū |  |
| 177 | バショク | Bashoku | 馬謖 | 馬謖 | 马谡 | mǎ sù |  |
| 178 | バジュン | Bajun | 馬遵 | 馬遵 | 马遵 | mǎ zūn |  |
| 179 | バタイ | Batai | 馬岱 | 馬岱 | 马岱 | mǎ dài |  |
| 180 | バチョウ | Bachou | 馬超 | 馬超 | 马超 | mǎ chāo |  |
| 181 | バテツ | Batetsu | 馬鉄 | 馬鐵 | 马铁 | mǎ tiě |  |
| 182 | バトウ | Batou | 馬騰 | 馬騰 | 马腾 | mǎ téng |  |
| 183 | バリョウ | Baryou | 馬良 | 馬良 | 马良 | mǎ liáng |  |
| 184 | バンイク | Ban'iku | 万彧 | 萬彧 | 万彧 | wàn yù |  |
| 185 | ハンショウ | Hanshou | 潘璋 | 潘璋 | 潘璋 | pān zhāng | page transcription 藩璋 corrected (潘璋, ハンショウ) |
| 186 | ハンチュウ | Hanchuu | 樊稠 | 樊稠 | 樊稠 | fán chóu |  |
| 187 | ヒイ | Hii | 費禕 | 費禕 | 费祎 | fèi yī |  |
| 188 | ビジク | Bijiku | 糜竺 | 麋竺 | 麋竺 | mí zhú | Yanyi writes 糜竺, Sanguozhi 麋竺 |
| 189 | ビホウ | Bihou | 糜芳 | 麋芳 | 麋芳 | mí fāng | Yanyi writes 糜芳, Sanguozhi 麋芳 |
| 190 | フエイ | Fuei | 傅嬰 | 傅嬰 | 傅婴 | fù yīng |  |
| 191 | ブンシュウ | Bunshuu | 文醜 | 文醜 | 文丑 | wén chǒu |  |
| 192 | ブンペイ | Bunpei | 文聘 | 文聘 | 文聘 | wén pìn |  |
| 193 | ブアンコク | Buankoku | 武安国 | 武安國 | 武安国 | wǔ ān guó |  |
| 194 | ホウキ | Houki | 逢紀 | 逄紀 | 逄纪 | páng jì | zh.wikipedia writes the surname 逄 (Pang); ja/Yanyi use 逢 |
| 195 | ホウジュウ | Houjuu | 龐柔 | 龐柔 | 庞柔 | páng róu |  |
| 196 | ホウセイ | Housei | 法正 | 法正 | 法正 | fǎ zhèng |  |
| 197 | ホウトウ | Houtou | 龐統 | 龐統 | 庞统 | páng tǒng |  |
| 198 | ホウトク | Houtoku | 龐徳 | 龐德 | 庞德 | páng dé |  |
| 199 | ホシツ | Hoshitsu | 歩騭 | 步騭 | 步骘 | bù zhì |  |
| 200 | モウカク | Moukaku | 孟獲 | 孟獲 | 孟获 | mèng huò |  |
| 201 | モウタツ | Moutatsu | 孟達 | 孟達 | 孟达 | mèng dá |  |
| 202 | モウユウ | Mouyuu | 孟優 | 孟優 | 孟优 | mèng yōu |  |
| 203 | ヨウガイ | Yougai | 雍闓 | 雍闓 | 雍闿 | yōng kǎi | ROM has an explicit dakuten (ヨウガイ) so 雍闓, not 楊懐 |
| 204 | ヨウギ | Yougi | 楊儀 | 楊儀 | 杨仪 | yáng yí |  |
| 205 | ヨウコウ | Youkou | 楊洪 | 楊洪 | 杨洪 | yáng hóng |  |
| 206 | ヨウシュウ | Youshuu | 楊修 | 楊修 | 杨修 | yáng xiū |  |
| 207 | ヨウフ | Youfu | 楊阜 | 楊阜 | 杨阜 | yáng fù |  |
| 208 | ライハク | Raihaku | 雷薄 | 雷薄 | 雷薄 | léi bó |  |
| 209 | ライドウ | Raidou | 雷銅 | 雷銅 | 雷铜 | léi tóng |  |
| 210 | リイ | Rii | 李異 | 李異 | 李异 | lǐ yì |  |
| 211 | リカク | Rikaku | 李傕 | 李傕 | 李傕 | lǐ jué |  |
| 212 | リクセキ | Rikuseki | 陸績 | 陸績 | 陆绩 | lù jì |  |
| 213 | リクソン | Rikuson | 陸遜 | 陸遜 | 陆逊 | lù xùn |  |
| 214 | リゲン | Rigen | 李厳 | 李嚴 | 李严 | lǐ yán |  |
| 215 | リタン | Ritan | 李湛 | 李湛 | 李湛 | lǐ zhàn |  |
| 216 | リテン | Riten | 李典 | 李典 | 李典 | lǐ diǎn |  |
| 217 | リフ | Rifu | 李孚 | 李孚 | 李孚 | lǐ fú |  |
| 218 | リョフ | Ryofu | 呂布 | 呂布 | 吕布 | lǚ bù |  |
| 219 | リジュ | Riju | 李儒 | 李儒 | 李儒 | lǐ rú |  |
| 220 | リュウショウ | Ryuushou | 劉璋 | 劉璋 | 刘璋 | liú zhāng |  |
| 221 | リュウド | Ryuudo | 劉度 | 劉度 | 刘度 | liú dù |  |
| 222 | リュウビ | Ryuubi | 劉備 | 劉備 | 刘备 | liú bèi |  |
| 223 | リュウヘイ | Ryuuhei | 留平 | 留平 | 留平 | liú píng |  |
| 224 | リュウホウ | Ryuuhou | 劉封 | 劉封 | 刘封 | liú fēng |  |
| 225 | リュウヨウ | Ryuuyou | 劉曄 | 劉曄 | 刘晔 | liú yè |  |
| 226 | リョウカ | Ryouka | 廖化 | 廖化 | 廖化 | liào huà |  |
| 227 | リョウコウ | Ryoukou | 梁興 | 梁興 | 梁兴 | liáng xīng |  |
| 228 | リョウトウ | Ryoutou | 凌統 | 凌統 | 凌统 | líng tǒng |  |
| 229 | リョガイ | Ryogai | 呂凱 | 呂凱 | 吕凯 | lǚ kǎi |  |
| 230 | リョコウ | Ryokou | 呂曠 | 呂曠 | 吕旷 | lǚ kuàng |  |
| 231 | リョケン | Ryoken | 呂虔 | 呂虔 | 吕虔 | lǚ qián |  |
| 232 | リョショウ | Ryoshou | 呂翔 | 呂翔 | 吕翔 | lǚ xiáng |  |
| 233 | リョハン | Ryohan | 呂範 | 呂範 | 吕范 | lǚ fàn |  |
| 234 | リョモウ | Ryomou | 呂蒙 | 呂蒙 | 吕蒙 | lǚ méng |  |
| 235 | ロシュク | Roshuku | 魯粛 | 魯肅 | 鲁肃 | lǔ sù |  |
| 236 | リケイ | Rikei | 李珪 | 李珪 | 李珪 | lǐ guī |  |
