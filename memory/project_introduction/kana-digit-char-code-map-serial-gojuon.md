# Kana/digit char code map (serial gojuon) for officer name strings

- **Category:** project_introduction
- **Memory ID:** 08290e6b-ac11-42d0-abe3-37de8bc0ce46
- **Keywords:** charmap, serial gojuon, katakana codes, dakuten postfix, name encoding, $901A
- **Usage scenarios:**
  - Decoding officer name byte strings from bank $30 $901A
  - Labeling kana text data or tile streams in disassembly
  - Extending or auditing the char map in tools/charmap_kana.py

## Content

Name-string char code map (bank $30 $901A table, 237 entries x 10 bytes, $00-terminated; entry index = officer id = (sram-$63C0)/12). Code space is SERIAL gojuon; verified via anchors リュウビ/カンウ/チョウヒ/ショカツリョウ/セッソウ/ガクシン. Authoritative decoder: tools/charmap_kana.py.

Control: $00 = terminator, $01 = space tile.
Katakana block: $04=ア $05=イ $06=ウ $07=エ $08=オ / $09=カ $0A=キ $0B=ク $0C=ケ $0D=コ / $0E=サ $0F=シ $10=ス $11=セ $12=ソ / $13=タ $14=チ $15=ツ $16=テ $17=ト / $18=ナ $19=ニ $1A=ヌ $1B=ネ $1C=ノ / $1D=ハ $1E=ヒ $1F=フ $20=ヘ $21=ホ / $22=マ $23=ミ $24=ム $25=メ $26=モ / $27=ヤ $28=ユ $29=ヨ / $2A=ラ $2B=リ $2C=ル $2D=レ $2E=ロ / $2F=ワ $30=ヲ $31=ン.
Small kana + sokuon: $32=ァ $33=ィ $34=ゥ (serial guess, unused in names) $35=ャ $36=ュ $37=ョ $38=ッ.
Combining marks (POSTFIX, apply to previous char): $39=゛ dakuten (カ->ガ, サ->ザ, タ->ダ, ハ->バ, ウ->ヴ; ヒ゛=ビ), $3A=゜ handakuten (ハ->パ).
Hiragana: same codes read as hiragana mirror (ア->あ ... ッ->っ); decoder applies dakuten in both scripts.
Digits: NOT in this code space; numbers are drawn tile-level as tile = nibble + $76 (CmdDrawNumber/CmdDrawFormattedNumber; digits on strategy font page $78 tiles $76-$7F).
GetNameDisplayScale ($F308, prg_1f) computes name addr = id*10+$901A and counts $39/$3A as width-only bytes; DisplayScaledName routes them to the dakuten overlay at $03A5+scale.
