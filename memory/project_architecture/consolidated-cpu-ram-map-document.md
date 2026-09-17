# Consolidated CPU RAM map document code/cpu_ram_map.md

- **Category:** project_architecture
- **Memory ID:** 8267d997-c17e-4543-b00c-879f80c1975d
- **Keywords:** RAM map, consolidated, OAM DMA page 02, SRAM layout, checksum, mailbox

## Content

Consolidated CPU RAM map exists at `code/cpu_ram_map.md` covering $0000-$07FF and $6000-$7FFF, derived from all nine analyzed bank files. Key global facts recorded there: OAM DMA always copies page $02 (prg_1f.asm $F857 loads A #$02 before STA $4014); stack page $0100 upper half is scratch (transition busy flag $0140, palette mask $0150); $0300/$0304 are two 4-byte frame-engine slot headers with per-mode payloads; SRAM persistent layout lives in page $6Fxx: country records $6F07-$6F3E (7 x 8 bytes stride 8, status byte at +3), map camera $6F3F-$6F42, game level $6F02, player id $6F03, game-state flag $6F05, game-start/mailbox flag $6F8B ($01 = war request consumed by banks $08+$09), AI scratch $6F8C-$6FDC, save magic "ID" at $6FFC-$6FFD and 16-bit checksum at $7FFE-$7FFF over $6000-$7FFD (prg_19_1a routine at $BC02-$BC75); $6F00-$6F06 is dual-use attract-demo scratch. prg_19_1a and prg_1b_1c have no equates (raw addresses + comments); their usage was scanned by tools/scan_raw_ram_refs.py. Full per-bank equate inventory: code/ram_equates_full.txt via tools/extract_ram_equates.py. Known multi-alias cells documented: $6F44 (battle outcome / province field 3 / player swap), $042C-$042E, $0540-$0544.
