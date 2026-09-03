#!/usr/bin/env python3
"""Join the ROM officer katakana names with their kanji / Chinese equivalents.

The ROM only stores katakana (the game's font has no kanji), so the kanji form
of each officer name is external knowledge.  tools/data/officer_kanji.tsv holds
the curated id -> kanji map; this script joins it against the names decoded
straight out of the ROM by tools/extract_officer_names.py and writes:

    docs/officer_names_kanji.csv   id, katakana, hiragana, romaji, kanji, zh, pinyin
    docs/officer_names_kanji.md    same data as a readable table

It also re-validates the map every run:

  * every non-blank ROM slot 0-236 has exactly one mapped name and vice versa
  * kanji_ja / zh_hant / zh_hans are each one-to-one (no two officers share one)
  * every kanji reading is reachable from the ROM katakana by composing the
    on-yomi of its characters (see ONYOMI below)

Usage:
    python tools/map_officer_kanji.py            # write output files
    python tools/map_officer_kanji.py --check    # validate only
"""
import argparse
import csv
import itertools
import os
import sys
import unicodedata

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from extract_officer_names import load_entries  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MAP_PATH = os.path.join(ROOT, 'tools', 'data', 'officer_kanji.tsv')
NAMED_MAX = 236               # slots 237-239 are blank

# On-yomi of every kanji used by the 237 names, so the readings can be checked
# without pulling in KANJIDIC.  Only the readings that matter for these names
# are listed.  向 = ショウ is the irregular reading Japanese sources use for
# 向寵 (しょうちょう); its regular on-yomi is コウ.
ONYOMI = {
    '阿': 'ア', '会': 'カイ,エ', '喃': 'ナン', '韋': 'イ', '康': 'コウ',
    '伊': 'イ', '籍': 'セキ', '尹': 'イン', '楷': 'カイ', '賞': 'ショウ',
    '于': 'ウ', '禁': 'キン', '越': 'エツ', '吉': 'キツ,キチ', '袁': 'エン',
    '煕': 'キ', '紹': 'ショウ', '譚': 'タン', '閻': 'エン', '圃': 'ホ',
    '王': 'オウ', '建': 'ケン', '粲': 'サン', '双': 'ソウ', '忠': 'チュウ',
    '平': 'ヘイ,ヒョウ', '甫': 'ホ,フ', '累': 'ルイ', '蒯': 'カイ',
    '良': 'リョウ', '賈': 'カ', '華': 'カ,ケ', '歆': 'キン', '詡': 'ク',
    '郭': 'カク', '汜': 'シ', '嘉': 'カ', '郝': 'カク', '昭': 'ショウ',
    '楽': 'ガク,ラク', '進': 'シン', '図': 'ト,ズ', '淮': 'ワイ',
    '夏': 'カ,ゲ', '侯': 'コウ', '淵': 'エン', '惇': 'トン,ジュン',
    '覇': 'ハ', '楙': 'ボウ', '蘭': 'ラン', '雅': 'ガ', '丹': 'タン',
    '鄂': 'ガク', '煥': 'カン', '範': 'ハン', '雄': 'ユウ', '関': 'カン',
    '羽': 'ウ', '韓': 'カン', '瑛': 'エイ', '琪': 'キ', '玄': 'ゲン',
    '興': 'コウ,キョウ', '索': 'サク', '遂': 'スイ', '当': 'トウ',
    '徳': 'トク', '甘': 'カン', '寧': 'ネイ', '猛': 'モウ', '簡': 'カン',
    '雍': 'ヨウ', '顔': 'ガン', '魏': 'ギ', '延': 'エン', '義': 'ギ',
    '渠': 'キョ', '牛': 'ギュウ', '金': 'キン', '姜': 'キョウ',
    '維': 'イ', '許': 'キョ', '攸': 'ユウ', '褚': 'チョ', '嬀': 'ギ',
    '覧': 'ラン', '紀': 'キ', '霊': 'レイ', '環': 'カン', '結': 'ケツ',
    '虞': 'グ', '翻': 'ホン', '邢': 'ケイ', '道': 'ドウ', '栄': 'エイ',
    '厳': 'ゲン,ゴン', '畯': 'シュン', '綱': 'コウ', '呉': 'ゴ',
    '懿': 'イ', '黄': 'コウ', '蓋': 'ガイ', '高': 'コウ', '幹': 'カン',
    '翔': 'ショウ', '権': 'ケン', '成': 'セイ,ジョウ', '選': 'セン',
    '公': 'コウ', '孫': 'ソン', '定': 'テイ,ジョウ', '兀': 'ゴツ',
    '突': 'トツ', '骨': 'コツ', '顧': 'コ', '胡': 'コ', '車': 'シャ',
    '児': 'ジ,ニ', '崔': 'サイ', '琰': 'エン', '蔡': 'サイ',
    '陽': 'ヨウ', '諒': 'リョウ', '史': 'シ', '渙': 'カン',
    '司': 'シ', '馬': 'バ,マ', '師': 'シ', '周': 'シュウ',
    '善': 'ゼン', '倉': 'ソウ', '泰': 'タイ', '魴': 'ホウ', '瑜': 'ユ',
    '朱': 'シュ', '桓': 'カン', '然': 'ゼン,ネン', '治': 'チ,ジ',
    '褒': 'ホウ', '荀': 'ジュン', '彧': 'イク', '淳': 'ジュン,シュン',
    '瓊': 'ケイ', '諶': 'シン,ジン', '蔣': 'ショウ', '鍾': 'ショウ',
    '琬': 'エン,カン', '向': 'ショウ,コウ', '寵': 'チョウ', '徐': 'ジョ',
    '諸': 'ショ', '葛': 'カツ', '瑾': 'キン', '瞻': 'セン', '亮': 'リョウ',
    '恪': 'カク', '晃': 'コウ', '庶': 'ショ', '盛': 'セイ,ジョウ',
    '任': 'ジン,ニン', '峻': 'シュン', '申': 'シン', '耽': 'タン',
    '審': 'シン', '配': 'ハイ', '辛': 'シン', '毗': 'ヒ,ビ',
    '評': 'ヒョウ', '宜': 'ギ', '薛': 'セツ', '綜': 'ソウ', '全': 'ゼン',
    '琮': 'ソウ', '曹': 'ソウ', '叡': 'エイ', '休': 'キュウ',
    '宋': 'ソウ', '憲': 'ケン', '洪': 'コウ', '彰': 'ショウ',
    '植': 'ショク', '真': 'シン', '仁': 'ジン,ニ', '操': 'ソウ',
    '丕': 'ヒ', '熊': 'ユウ', '沮': 'ソ', '授': 'ジュ', '蘇': 'ソ',
    '飛': 'ヒ', '乾': 'カン,ケン', '策': 'サク', '翊': 'ヨク',
    '礼': 'レイ', '太': 'タイ,タ', '慈': 'ジ', '済': 'サイ,セイ',
    '張': 'チョウ', '趙': 'チョウ', '雲': 'ウン', '衛': 'エイ',
    '横': 'オウ,コウ', '嶷': 'ギ', '月': 'ゲツ', '郃': 'コウ',
    '松': 'ショウ', '南': 'ナン', '苞': 'ホウ', '翼': 'ヨク',
    '遼': 'リョウ', '陳': 'チン', '震': 'シン', '武': 'ブ,ム',
    '琳': 'リン', '程': 'テイ', '昱': 'イク', '銀': 'ギン',
    '普': 'フ', '秉': 'ヘイ', '典': 'テン', '田': 'デン',
    '疇': 'チュウ', '豊': 'ホウ,ブ', '董': 'トウ', '允': 'イン',
    '鄧': 'トウ', '艾': 'ガイ', '芝': 'シ', '襲': 'シュウ',
    '荼': 'ト,ダ', '奴': 'ヌ,ド', '卓': 'タク', '玩': 'ガン',
    '謖': 'ショク', '遵': 'ジュン', '岱': 'タイ', '超': 'チョウ',
    '鉄': 'テツ', '騰': 'トウ', '万': 'バン,マン', '潘': 'ハン',
    '璋': 'ショウ', '樊': 'ハン', '稠': 'チュウ', '費': 'ヒ',
    '禕': 'イ', '糜': 'ビ,ミ', '竺': 'ジク,トク', '芳': 'ホウ',
    '傅': 'フ', '嬰': 'エイ', '文': 'ブン,モン', '醜': 'シュウ',
    '聘': 'ヘイ', '安': 'アン', '国': 'コク', '逢': 'ホウ',
    '龐': 'ホウ', '柔': 'ジュウ', '法': 'ホウ', '正': 'セイ,ショウ',
    '統': 'トウ', '歩': 'ホ,ブ', '騭': 'シツ', '孟': 'モウ',
    '獲': 'カク', '達': 'タツ', '優': 'ユウ', '闓': 'ガイ,カイ',
    '楊': 'ヨウ', '儀': 'ギ', '修': 'シュウ,シュ', '阜': 'フ',
    '雷': 'ライ', '薄': 'ハク', '銅': 'ドウ', '李': 'リ',
    '異': 'イ', '傕': 'カク', '陸': 'リク', '績': 'セキ',
    '遜': 'ソン', '湛': 'タン,チン', '孚': 'フ', '呂': 'リョ',
    '布': 'フ,ホ', '儒': 'ジュ', '劉': 'リュウ', '度': 'ド,タク',
    '備': 'ビ', '留': 'リュウ,ル', '封': 'ホウ,フウ', '曄': 'ヨウ',
    '廖': 'リョウ', '化': 'カ,ケ', '梁': 'リョウ', '凌': 'リョウ',
    '凱': 'ガイ,カイ', '曠': 'コウ', '虔': 'ケン', '蒙': 'モウ',
    '魯': 'ロ', '粛': 'シュク', '珪': 'ケイ,ケ',
}
_SMALL = str.maketrans('ャュョッ', 'ヤユヨツ')
_VOICED = str.maketrans('ガギグゲゴザジズゼゾダヂヅデドバビブベボパピプペポ',
                        'カキクケコサシスセソタチツテトハヒフヘホハヒフヘホ')


def _norm(kana):
    """Fold small kana and dakuten away so on-yomi can be compared loosely."""
    return kana.translate(_SMALL).translate(_VOICED)


def reading_matches(kanji, katakana):
    """True if some combination of the characters' on-yomi spells katakana."""
    target = _norm(katakana)
    pools = []
    for ch in kanji:
        readings = ONYOMI.get(ch)
        if not readings or readings == 'x':
            return None
        pools.append(readings.split(','))
    for combo in itertools.product(*pools):
        if _norm(''.join(combo)) == target:
            return True
        # sokuon assimilation, e.g. ガク + カン -> ガッカン (鄂煥)
        parts = [_norm(p) for p in combo]
        for i in range(len(parts) - 1):
            if parts[i][-1] in 'クツチキ':
                alt = list(parts)
                alt[i] = alt[i][:-1] + 'ツ'
                if _norm(''.join(alt)) == target:
                    return True
    return False


def load_map(path=MAP_PATH):
    rows = {}
    with open(path, encoding='utf-8') as f:
        lines = [ln for ln in f if not ln.startswith('#')]
    for r in csv.DictReader(lines, delimiter='\t'):
        rows[int(r['id'])] = r
    return rows


def build_rows():
    rom = {r['id']: r for r in load_entries()}
    mapping = load_map()
    rows = []
    for oid in sorted(mapping):
        rom_row = rom[oid]
        m = mapping[oid]
        rows.append({
            'id': oid,
            'katakana': rom_row['katakana'],
            'hiragana': rom_row['hiragana'],
            'romaji': rom_row['romaji'],
            'kanji_ja': m['kanji_ja'],
            'zh_hant': m['zh_hant'],
            'zh_hans': m['zh_hans'],
            'pinyin': m['pinyin'],
            'note': m['note'],
        })
    return rom, rows


def check(rom, rows):
    problems = []
    mapped = {r['id'] for r in rows}
    named = {oid for oid, r in rom.items() if not r['blank'] and oid <= NAMED_MAX}
    if mapped != named:
        problems.append(f'id set mismatch: only in map {sorted(mapped - named)}, '
                        f'only in ROM {sorted(named - mapped)}')
    for col in ('kanji_ja', 'zh_hant', 'zh_hans'):
        seen = {}
        for r in rows:
            seen.setdefault(r[col], []).append(r['id'])
        dupes = {k: v for k, v in seen.items() if len(v) > 1}
        if dupes:
            problems.append(f'{col} not one-to-one: {dupes}')
    for r in rows:
        if rom[r['id']]['katakana'] != r['katakana']:
            problems.append(f'id {r["id"]}: map katakana {r["katakana"]!r} != '
                            f'ROM {rom[r["id"]]["katakana"]!r}')
        got = reading_matches(r['kanji_ja'], r['katakana'])
        if got is None:
            problems.append(f'id {r["id"]}: no on-yomi data for {r["kanji_ja"]}')
        elif not got:
            problems.append(f'id {r["id"]}: {r["kanji_ja"]} does not read '
                            f'{r["katakana"]}')
    return problems


def _pad(text, width):
    cells = sum(2 if unicodedata.east_asian_width(c) in 'WF' else 1 for c in text)
    return text + ' ' * max(0, width - cells)


def write_csv(rows, path):
    cols = ['id', 'katakana', 'hiragana', 'romaji', 'kanji_ja',
            'zh_hant', 'zh_hans', 'pinyin', 'note']
    with open(path, 'w', encoding='utf-8', newline='') as f:
        w = csv.DictWriter(f, fieldnames=cols)
        w.writeheader()
        for r in rows:
            w.writerow({c: r[c] for c in cols})


HEADER = """# Officer names: katakana, kanji and Chinese

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

"""


def write_md(rows, path):
    with open(path, 'w', encoding='utf-8') as f:
        f.write(HEADER)
        f.write('| id | katakana | romaji | kanji (ja) | 繁體 | 简体 | pinyin | note |\n')
        f.write('|---:|---|---|---|---|---|---|---|\n')
        for r in rows:
            f.write(f'| {r["id"]} | {r["katakana"]} | {r["romaji"]} | '
                    f'{r["kanji_ja"]} | {r["zh_hant"]} | {r["zh_hans"]} | '
                    f'{r["pinyin"]} | {r["note"]} |\n')


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--check', action='store_true', help='validate only')
    ap.add_argument('--print', dest='dump', action='store_true',
                    help='also dump the table to stdout')
    args = ap.parse_args()

    rom, rows = build_rows()
    problems = check(rom, rows)
    for p in problems:
        print(f'FAIL: {p}', file=sys.stderr)
    if problems:
        return 1
    print(f'ok: {len(rows)} officer names mapped and reading-checked')

    if not args.check:
        out_dir = os.path.join(ROOT, 'docs')
        os.makedirs(out_dir, exist_ok=True)
        csv_path = os.path.join(out_dir, 'officer_names_kanji.csv')
        md_path = os.path.join(out_dir, 'officer_names_kanji.md')
        write_csv(rows, csv_path)
        write_md(rows, md_path)
        print(f'wrote {os.path.relpath(csv_path, ROOT)}')
        print(f'wrote {os.path.relpath(md_path, ROOT)}')

    if args.dump:
        for r in rows:
            print(f'{r["id"]:3d}  {_pad(r["katakana"], 14)}{_pad(r["kanji_ja"], 8)}'
                  f'{_pad(r["zh_hant"], 8)}{_pad(r["zh_hans"], 8)}{r["pinyin"]}')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
