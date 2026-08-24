#!/usr/bin/env python3
"""Brute-force identify the menu text font page.

Anchor facts:
  - digit tiles = $76 + n (CmdDrawNumber)
  - $01 = space (CmdDrawNameFromData padding)
  - strategy prompts end in します (shimasu)
  - command names from manual KB (土地の開墾, 防災, 徴兵, 出陣, ...)

For every 1KB page in every chr file, score how well tiles $40-$7F support
the kana needed by known strings.
"""

KANA_NEEDED = set('しますかをにのでとがはもへたたてきくけこらりるれろ'
                  'しんちとうへいめいしゅつじんていさつちょうりくがく'
                  'ぼうちょうしゅうこめきんどひょうりょくちゅうせい')

# The most common static suffix across streams: "$4F $74 $46" = します
SUFFIX = [(0x4F, 'し'), (0x74, 'ま'), (0x46, 'す')]
# "$62 $4F $53" common too -> ?します? $62=? , $53=?  ($53 also ends $00 stream words)


def page_score(chunk):
    # digits $76-$7F should be digit-like: density 8-40, not solid
    dens = []
    for t in range(0x76, 0x80):
        o = (t & 0x3F) * 16
        n = sum(bin(b).count('1') for b in chunk[o:o + 16])
        dens.append(n)
    if any(n < 6 or n > 44 for n in dens):
        return -1
    # $01 = space -> bonus if blank (slot4 may differ, so not a hard fail)
    sp = sum(bin(b).count('1') for b in chunk[0x10:0x20])
    space_bonus = 3 if sp <= 4 else 0
    # kana-range tiles $47-$75 mostly non-blank, medium density
    kana_ok = 0
    for t in range(0x47, 0x76):
        o = (t & 0x3F) * 16
        n = sum(bin(b).count('1') for b in chunk[o:o + 16])
        if 8 <= n <= 52:
            kana_ok += 1
    # $4F/$74/$46 must be kana-like (not solid/frame)
    for t, _ in SUFFIX:
        o = (t & 0x3F) * 16
        n = sum(bin(b).count('1') for b in chunk[o:o + 16])
        if not (6 <= n <= 52):
            return -1
    return kana_ok + space_bonus


results = []
for bank in range(32):
    with open('rom/chr/chr_%02x.bin' % bank, 'rb') as f:
        data = f.read()
    for sl in range(8):
        chunk = data[sl * 0x400:sl * 0x400 + 0x400]
        s = page_score(chunk)
        if s >= 0:
            results.append((s, bank, sl))

results.sort(reverse=True)
for s, bank, sl in results[:20]:
    page = bank * 8 + sl
    print('score %2d  chr_%02x @ $%04X  (page $%02X)' % (s, bank, sl * 0x400, page))
