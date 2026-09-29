# Ruler card decode — `RulerCardRefresh` (bank $1D $AA37) and its banked name data

Scope: what `RulerCardRefresh` / `OfficerNameSpritePost` (formerly the generic
names `BankedDataHandler` / `SetupBankedData`) actually do, the display-stream
layout they build, and the bank-$31 Officer name-glyph record format they read.
Everything below was verified against the ROM bytes and the per-bank harness
(`tools/verify_1d_1e.py`, `tools/verify_19_1a.py`, `tools/verify_1b_1c.py`).

## 1. Names and roles

| Old name | New name | Address | Role |
|---|---|---|---|
| `BankedDataHandler_Entry` | `RulerCardRefresh_Entry` | `$A042` | bank-$1D entry stub (`JMP $AA37`) |
| `BankedDataHandler` | `RulerCardRefresh` | `$AA37-$AB07` | composes the Ruler card: BG label kanji row + name sprites |
| `SetupBankedData` | `OfficerNameSpritePost` | `$AB38-$ABB7` code, `$ABB8-$ABD1` tables | posts the Officer's name kanji as sprites from banked ROM |
| `@DisplayData_Table` | `@RulerCardLabelTiles` | `$AB08-$AB37` | 4 card-label variants × 12 nametable tile halves |
| `@SpriteX_Table` / `@SpriteY_Table` | `@NameSpriteY_Table` / `@NameSpriteX_Table` | `$ABB8-$ABC4` / `$ABC5-$ABD1` | the old names were swapped: byte 0 of an OAM entry is Y, byte 3 is X. Both tables are 13 entries; the earlier listing cut the X table at 11 bytes and disassembled its last two bytes as code (see §6) |
| `BankedDataHandler_tail` | *(removed)* | `$ABD0-$ABD1` | not code at all — `58 60` are `@NameSpriteX_Table` slots 11/12 (see §6) |

The BG part writes the **card header label** (a fixed 2-3 kanji word chosen by
the caller), the sprite part writes the **Officer's own name** (2-3 kanji).
Together they are the Ruler card of the strategy map screen — hence
`RulerCardRefresh`, matching the callers' own wording ("card refresh",
"clears the Ruler card").

## 2. `RulerCardRefresh` ABI

Input cells (set by the caller before the banked call, `Y=$3D`):

| Cell | Meaning | Effect |
|---|---|---|
| `$000B` | Officer id | `$FF` → skip `OfficerNameSpritePost` (no name sprites) |
| `$000A` | card label variant 0-3 | `$FF` → skip the `@RulerCardLabelTiles` lookup (label cells stay blank) |
| `$000C` | refresh mode | `0` → clear + rebuild the tile stream; non-zero → **return at `$AA5E`** after the name sprites only |

`$000A/$000B/$000C` are saved and restored on the stack at `$AA37-$AA56`, so the
call is parameter-transparent. Outputs: display stream `$0380-$03A6`, appended
OAM shadow entries through the slot cursor `$007C`, panel param
`$00BD ← $76`, and `$007E |= $04` (render request consumed by `PPUTileRender` /
`VRAMBufferWrite`).

Flow:

```
$AA37  save $000A/$000B/$000C
$AA43  $000B == $FF ? -> $AA4D       : else JSR OfficerNameSpritePost ($AB38)
$AA4D  restore the three cells
$AA59  $000C != 0  ? -> RTS ($AA5E)  : name-sprite-only refresh
$AA5F  fill $0380-$03B0 with $01 (blank tile), 49 bytes
$AA69  $000A == $FF ? -> $AADE       : else Y = $000A * $0C, copy 12 label tiles
$AA7B  @RulerCardLabelTiles+0..5  -> $038D-$0392   (label row, top halves)
$AA9F  @RulerCardLabelTiles+6..11 -> $03A0-$03A5   (label row, bottom halves)
$AAC3  $00BD <- $76
$AAC8  static label kanji: $0389/$038A <- $C0/$C1, $039C/$039D <- $D0/$D1
$AADC  $03A6 <- $FF (stream terminator)
$AADE  block headers: $0380 <- $10, $0381/$0382 <- $22/$C8 (block 1 -> $22C8);
       $0393 <- $10, $0394/$0395 <- $22/$E8 (block 2 -> $22E8)
$AB04  $007E |= $04 ; RTS
```

Note the jump target: with `$000A == $FF` the code jumps straight to `$AADE`, so
the stream still gets both block headers and the fixed label kanji, only the
variant cells stay at the blank `$01`.

## 3. The display stream it builds

`$0380` holds `VRAMBufferWrite`-style blocks — `[count][VRAM hi][VRAM lo][tiles]`
— terminated by `$FF` (renderer: `VRAMBufferWrite` `$A11B`, upload path
`PPUTileRender` `$A048`). `RulerCardRefresh` emits exactly two blocks:

| Buffer | Value | Meaning |
|---|---|---|
| `$0380/$0381/$0382` | `$10, $22, $C8` | block 1: 16 tiles at VRAM `$22C8` |
| `$0389/$038A` | `$C0/$C1` | fixed label kanji, top-left/top-right halves |
| `$038D-$0392` | variant tiles `+0..+5` | variant kanji 1-3, top halves |
| `$0393/$0394/$0395` | `$10, $22, $E8` | block 2: 16 tiles at VRAM `$22E8` |
| `$039C/$039D` | `$D0/$D1` | fixed label kanji, bottom halves |
| `$03A0-$03A5` | variant tiles `+6..+11` | variant kanji 1-3, bottom halves |
| `$03A6` | `$FF` | stream terminator |

VRAM `$22C8` and `$22E8` are nametable `$2200` **rows 6 and 7**, columns 8-23:
block 1 covers row 6 cols 8-23, block 2 row 7 cols 8-23. A 16×16 kanji therefore
occupies one cell in row 6 plus the cell directly below it in row 7, i.e. tile
ids `(n, n+1)` over `(n+$10, n+$11)`. That is why every second row of
`@RulerCardLabelTiles` is always the first row `+$10`.

Column map of the label area (both rows):

| Cols | Content |
|---|---|
| 8-13 | blank (`$01` from the clear pass) |
| 14-15 | fixed kanji, font base `$00` (`$C0/$C1` over `$D0/$D1`) |
| 16-17 | blank (`$038B/$038C`, `$039E/$039F` never written) |
| 18-23 | up to 3 kanji from `@RulerCardLabelTiles`, `$01` = blank cell |

### `@RulerCardLabelTiles` (font-page-relative)

Tile id minus `$C0` = kanji index inside the card's font page:

| Variant | Kanji bases | Filled cells |
|---|---|---|
| 0 | `$02, $04, $06` | 3 |
| 1 | `$08, $0A` | 2 + 2 blank |
| 2 | `$02, $0C, $06` | 3 |
| 3 | `$0E, $10` | 2 + 2 blank |

Callers pick the variant per presentation (see §5); the glyphs themselves cannot
be read off the ROM image without the CHR font work, so the strings are an
explicit open item (§7).

## 4. `OfficerNameSpritePost` and the bank-$31 name records

1. `$8000-$9FFF ← PRG bank $31` via `B1F_SwitchBank8_B` (shadow `$00E1`, which
   the NMI re-applies every frame — so the switch survives interrupts; nothing
   here restores the previous bank, the next banked-data user re-selects it).
2. Record pointer = `$8DB4 + Officer id × $0D` (`B1F_MathMul24x8` with `$0003 = $0D`).
   Physical file: `rom/prg/prg_11.bin` offset `$0DB4 + id × 13`.
3. Record layout, 13 bytes:

   | Offset | Content |
   |---|---|
   | `[0]` | name-font CHR page id → `$00B9` (no disassembled reader) |
   | `[1..12]` | up to 3 kanji × 4 tile ids (`00-$3F`), `$FF` terminated and padded |

   One kanji = the 4 ids `(n, n+1, n+$10, n+$11)` = top-left, top-right,
   bottom-left, bottom-right 8×8 tiles of a 16×16 glyph. So a font page holds
   16 kanji (64 tiles = the `$C0-$FF` sprite page after the `+$C0` bias).
4. Two passes over the record: the first walks slots 1/5/9 looking for `$FF` and
   derives the X shift `$0002 = $30 − $10 × (groups scanned)`; the second emits
   one sprite per tile id: pattern `= id + $C0`, attribute `$01`, coordinates
   `@NameSpriteY_Table[slot]` → OAM byte 0 and `@NameSpriteX_Table[slot] + $0002`
   → OAM byte 3, appended through the slot cursor `$007C` (`STX $007C` at
   `$ABB4`; the NMI zeroes `$007C` every frame, so the card must be re-posted
   every frame — that is what the mode≠0 refresh path does).

### Verified evidence that `[1..12]` is the kanji name

Joining the records against `docs/officer_names_kanji.csv` shows surname/group
behaviour that only a name encoding can produce:

| Officer ids | kanji | record cells (tiles) | page id `[0]` |
|---|---|---|---|
| 3, 4 | 尹楷 / 尹賞 | `00 01 10 11` \| `04 05 14 15` / `06 07 16 17` | `$62` |
| 7, 8, 9 | 袁煕 / 袁紹 / 袁譚 | `20 21 30 31` \| `22..`/`24..`/`26..` | `$62` |
| 11-17 | 王建/粲/双/忠/平/甫/累 | `00 01 10 11` \| 2nd kanji differs | `$61` |
| 29-33 | 夏侯淵/惇/覇/楙/蘭 | `00 01 10 11` \| `02 03 12 13` \| 3rd differs | `$66` |
| 0 | 阿会喃 (3 kanji) | 12 entries = 3 kanji | `$6A` |

Entry count is always 8 (2 kanji) or 12 (3 kanji) for the 237 real officers, and
the X shift `$20/$10/$00` right-aligns a 1-2 kanji name inside the 3-cell row
(X cells `$38/$48/$58`, Y cells `$AF/$B7`).

## 5. Callers (11 sites, all in `prg_19_1a.asm` `StrategyRequestDispatch`)

| Site | Handler | variant `$000A` | mode `$000C` | Officer `$000B` |
|---|---|---|---|---|
| `$C810` | RequestPoll first tick | 0 | `$040C` = 0 | current Ruler |
| `$C835` | RequestPoll armed ticks | 0 | `$040C` (≠0) | current Ruler |
| `$C893` | RequestPoll teardown | `$FF` | 0 | `$FF` |
| `$C8B5` | ReqWarPending (`$FE`) | 1 | 0 | current Ruler |
| `$C8EE` | ReqCountryAbsorbed (`$FD`) | 1 | 0 | current Ruler |
| `$C9EE` | WarMenuCloseWait | 1 | 1 | current Ruler |
| `$CAA0` | PostWarRulerMenu | 1 | 1 | current Ruler |
| `$CAC6` | PostWarRulerMenu 2nd card | 2 | 0 | current Ruler |
| `$CAF0` | PostWarPairedRulerMenu | 1 | 1 | current Ruler |
| `$CB21` | PostWarPairedRulerMenu 2nd card | 3 | 0 | opposing Ruler |
| `$CB56` | WarPhaseHandoff | 1 | 1 | opposing Ruler |

No other bank reaches it: a ROM-wide byte scan for `20 07 EE 42 A0`
(`JSR $EE07` + inline word `$A042`) across all 32 PRG banks returns exactly these
11, and there is no intra-bank `JSR/JMP` to `$AA37`/`$A042` (`build/scan_banked_data_handler_callers.py`).

## 6. `$ABD0/$ABD1` are data, not a `CLI / RTS` tail

An earlier pass (including the first draft of this document) carried a stub proc
`BankedDataHandler_tail` / `RulerCardRefresh_OrphanTail` at `$ABD0`, disassembling
`58 60` as `CLI` / `RTS` and calling it "unreachable". That conclusion was wrong
in both directions, and the unreachable-ness was actually the evidence:

- **It is data.** `rom/prg/prg_1d.bin` `$0BD0/$0BD1` = `58 60`, and the full run
  `$0BB8-$0BD1` is two symmetric 13-entry tables:
  `F0 AF AF B7 B7 AF AF B7 B7 AF AF B7 B7` (Y, `$ABB8-$ABC4`) and
  `F0 38 40 38 40 48 50 48 50 58 60`**`58 60`** (X, `$ABC5-$ABD1`).
  `58 60` are the third kanji cell's two tile rows (slots 11/12), continuing the
  `$38/$40`, `$48/$50`, `$58/$60` cell pattern exactly.
- **The loop requires it.** `@copy_name_loop` indexes both tables with `Y` up to
  `12` (`CPY #$0D / BCC`), so the X table must be 13 bytes; a 11-byte table would
  read into "code" for slots 11/12 and mis-position the third kanji.
- **Code resumes at `$ABD2`.** `AD 7C 03` = `LDA $037C`, the head of
  `ProvinceDataWindowFrame` (`B1D_1E_ProvinceDataWindowFrame_Proc = $ABD2`), so
  there is no room for a two-byte routine between `$ABD1` and `$ABD2`.
- **No `SEI` anywhere** in `$AA37-$ABD1`, and no `JSR/JMP $ABD0` or trampoline
  target in any of the 32 PRG banks — a `CLI` with no matching `SEI` and no
  caller is a tell, not a leftover stub.

Fixed: the two bytes are folded into `@NameSpriteX_Table` (`slot 10-12 row`), and
the bogus `.proc` is deleted. `tools/verify_1d_1e.py` → 16384 bytes, 0 mismatches
(the file assembled before and after the change is byte-identical, since the
emitted bytes are the same either way — which is why the byte harness alone did
not catch it; the table length and the index bound did).

Lesson recorded: a plausible-looking 2-byte instruction pair that (a) sits at the
end of a data table, (b) has no referencing code, and (c) breaks the table's
index bound is data, not code. Verify table lengths against the maximum loop
index before declaring a stub "orphan code".

## 7. Open items

- Which kanji the four label variants spell: needs the card font page identified
  in CHR (`tools/render_font_chunks.py` / `dump_record_fonts.py` are the
  starting point).
- Who consumes the name-font page id in `$00B9` (presumably the CHR page upload
  for the card font). No disassembled bank reads `$00B8/$00B9` — consistent with
  the note in `OfficerCardRender` (`prg_19_1a.asm:6822`). The writer is most
  likely in the not-yet-disassembled banks `$10-$16`.
- `$00BD ← $76`: `prg_0e_0f` labels `$00BB/$00BC/$00BD` as
  `zp_panel_param_a/b/c` (script id / page / panel id) and other banks write
  `$0C/$0D/$8C` there; `$76` is the digit tile base (`'0' = $76`) used by the
  BCD paths, so this write is either a panel id that happens to be `$76` or a
  tile-base seed for a panel that reads it. Not resolved here.

## 8. Related documents

- `code/request_poll_mechanics.md` — the caller side (frame state 9 poll loop).
- `code/pputilerender_stream_architecture.md` — the stream/block format.
- `code/cpu_ram_map.md` — `$0380` display buffer, `$0200` OAM shadow, `$007C`.
