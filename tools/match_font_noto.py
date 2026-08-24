#!/usr/bin/env python3
"""Match strategy-menu font tiles against Noto Sans CJK renderings.

Tiles (from code/font_analysis.md):
  page $70 = chr_0e @ $0000, tiles $00-$3F (pure kana)
  page $95 = chr_12 @ $1400, tiles $00-$3F (strategy-menu low half)
  page $78 = chr_0f @ $0000, tiles $40-$7F (strategy-menu high half + digits)

Score = best pixel IoU over +-1 px shifts of the binarized font rendering.
"""
import os
from PIL import Image, ImageDraw, ImageFont

CHR_DIR = os.path.join(os.path.dirname(__file__), '..', 'rom', 'chr')
FONT_PATH = '/usr/share/fonts/noto-cjk/NotoSansCJK-Regular.ttc'
FONT_SIZE = 8

KATAKANA = ('アイウエオカキクケコサシスセソタチツテトナニヌネノ'
            'ハヒフヘホマミムメモヤユヨラリルレロワヲンー'
            'ガギグゲゴザジズゼゾダヂヅデドバビブベボ'
            'パピプペポャュョッァィゥェォ')
HIRAGANA = ('あいうえおかきくけこさしすせそたちつてとなにぬねの'
            'はひふへほまみむめもやゆよらりるれろわをんー'
            'がぎぐげござじずぜぞだぢづでどばびぶべぼ'
            'ぱぴぷぺぽゃゅょっぁぃぅぇぉ')
KANJI = ('土地開墾産業発展町情報集同盟離間引抜武将移動防災記録'
         '出陣偵察徴兵任命太守総大将物資運与配下城民衆金米宝'
         '武器屋学問所病院商店年月起命令数終了終君主体力知人徳忠'
         '誠度経験値兵糧攻撃防御戦略術火計水伏兵乱戦一騎打勝負勝'
         '敗撤退進待軍師参謀将軍隊士気訓練休憩探索登用説得謀反処'
         '断追放贈答交換取外交同盟約期限成功失敗実施確認取消選択'
         '決定入力上下左右前後東西南北国郡県関砦港橋山森川湖原野'
         '沙漠畑田商業農業治水城壁門堀矢玉鉄砲甲冑剣刀槍弓弩馬車'
         '船輸送補給損耗負傷死亡捕虜解放登用降伏説得失敗報告書'
         '月日現在残全回復上昇下降変化影響範囲対象距離方向位置'
         '誰何何时幾多大小强弱早遅新旧本丸二丸三丸曲輪兵種歩兵'
         '騎兵弓兵鉄砲兵水軍工作兵輸送兵部隊編成配置交代解散集'
         '結集合待機巡回警備見張哨戒夜襲奇襲火攻水攻兵糧攻囲籠')
DIGITS = '0123456789'
SYMBOLS = '。，・？！＝−〜／＼＋×○●△▲▽▼★☆■□→←↑↓々〃仝'

CANDIDATES = list(dict.fromkeys(
    list(KATAKANA) + list(HIRAGANA) + list(KANJI) + list(DIGITS) + list(SYMBOLS)))


def load(name):
    with open(os.path.join(CHR_DIR, name), 'rb') as f:
        return f.read()


def tile_mask(data, base, idx):
    off = base + idx * 16
    lo, hi = data[off:off + 8], data[off + 8:off + 16]
    m = set()
    for y in range(8):
        for x in range(8):
            if (lo[y] >> (7 - x)) & 1 or (hi[y] >> (7 - x)) & 1:
                m.add((x, y))
    return m


def font_mask(ch, font):
    """Render char into an 8x8 binary mask (thresholded coverage)."""
    img = Image.new('L', (8, 8), 0)
    d = ImageDraw.Draw(img)
    # try a couple of vertical offsets; font metrics vary
    best = None
    for dy in (-2, -1, 0):
        tmp = Image.new('L', (8, 12), 0)
        dd = ImageDraw.Draw(tmp)
        dd.text((0, dy), ch, font=font, fill=255)
        tmp = tmp.crop((0, 0, 8, 8))
        mask = frozenset((x, y) for y in range(8) for x in range(8)
                         if tmp.getpixel((x, y)) >= 96)
        if best is None or len(mask) > len(best):
            best = mask
    return set(best)


def iou_shift(a, b):
    """Best IoU over +-1 px shifts of b."""
    best = 0.0
    for dx in (-1, 0, 1):
        for dy in (-1, 0, 1):
            bs = {(x + dx, y + dy) for (x, y) in b
                  if 0 <= x + dx < 8 and 0 <= y + dy < 8}
            if not bs:
                continue
            inter = len(a & bs)
            union = len(a | bs)
            if union and inter / union > best:
                best = inter / union
    return best


def main():
    font = ImageFont.truetype(FONT_PATH, FONT_SIZE)
    ref = {}
    for ch in CANDIDATES:
        ref[ch] = font_mask(ch, font)

    pages = [
        ('chr_0e.bin', 0x0000, range(0x00, 0x40), 'page $70 kana font', 0),
        ('chr_12.bin', 0x1400, range(0x00, 0x40), 'page $95 low half', 0),
        ('chr_0f.bin', 0x0000, range(0x00, 0x40), 'page $78 high half (bytes $40-$7F)', 0x40),
    ]
    for fname, base, tiles, label, byte_ofs in pages:
        data = load(fname)
        print(f'=== {label} ===')
        for t in tiles:
            tm = tile_mask(data, base, t)
            if not tm:
                print(f'${t + byte_ofs:02X}: <blank>')
                continue
            scored = sorted(((iou_shift(tm, rm), ch) for ch, rm in ref.items()),
                            reverse=True)
            top = '  '.join(f'{ch}={s:.2f}' for s, ch in scored[:3])
            print(f'${t + byte_ofs:02X}: {top}   (px={len(tm)})')
        print()


if __name__ == '__main__':
    main()
