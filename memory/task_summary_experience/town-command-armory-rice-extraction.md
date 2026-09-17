# Town command/armory/rice extraction task summary

- **Category:** task_summary_experience
- **Memory ID:** 2e21315d-05e9-405e-ba40-d4a3eea1a49d
- **Keywords:** town commands, armory stock, rice prices, CSV extraction, facility anchors

## Content

Task: extract per-province town commands, armory weapon/armor buy lists, and rice prices to docs/*.csv.

Result: new tools/extract_town_data.py writes docs/town_commands.csv (30 provinces x 4 facility flags + town type + armory formation id), docs/armory_stock.csv (480 province-item-price rows), docs/equipment_catalog.csv (32 cells: 5 剣, 6 刀, 6 槍, 6 防具 + hidden ids 15/22/23/30/31), docs/rice_prices.csv (buy/sell rates; 23 market provinces, 7 without 商店 have $00 rates). Zero byte drift - read-only extraction from rom/prg/*.bin.

Method that worked: (1) found the town dispatch as state 5 of MapScreenFrameStateTable ($BFB7, raw region in an otherwise-disassembled bank pair); (2) decoded pointer tables by hand, then disassembled handlers with tools/disasm_6502.py (note: bank pairs map at $A000/$C000, so CPU $Cxxx = file offset - $C000 of the odd bank); (3) naive whole-ROM scans (facility bitmask, price runs) produced only false positives - tracing code references was decisive; (4) facility screen ids identified by their handler behavior (hospital = 50g heal text, market = treasure check at rec +$10, academy = INT tier costs 10/20/30) and confirmed by 4 manual anchors (pp. 54-55 ruler guide facility tables); (5) armory item identity = cell index == officer equipment id (glyph-count fingerprint of icon blocks + shared officer-id gaps); icon blocks in prg_10 at $9B52+ are 17-byte [attr][16 tile] graphics, rendered via PIL to view as images (ASCII art of kanji was unreliable; images showed item ICONS not text). Watch out: virtual bank $30 = physical prg_10 (bank id & $1F), CPU $8FC0 = offset 0x0FC0 not 0x1FC0.

Unresolved: hidden item names for ids 15/22/23/30/31 (labeled by class in CSV); sell-rate formula direction assumed symmetric with buy (rice = gold*rate/100).
