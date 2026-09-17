# ProvinceRulerIdGet/CountryRulerIdGet/OfficerCardShow decoded in prg_1b_1c.asm ($DD4F-$DD6F)

- **Category:** task_summary_experience
- **Memory ID:** 6347b92e-85e7-49a3-b3e7-10e29a45be07
- **Keywords:** Loc_DD4F, ProvinceRulerIdGet, CountryRulerIdGet, OfficerCardShow, ruler id, virtue loyalty gain, prg_1b_1c

## Content

## Task description
- Full 5-step code analysis workflow (Verify/Replace/Rename/Fix/Explain) on Loc_DD4F and adjacent Loc_DD56/Loc_DD5E raw regions in prg_1b_1c.asm bank $1C, with source application and byte-exact verification.

## Execution process
1. Decoded the three raw entries into two + one procedures:
   - ProvinceRulerIdGet ($DD4F-$DD55): A = province id -> JSR B1F_GetProvinceRecordAddr, returns province record byte 0 (low nibble = owner Country id), falls through into CountryRulerIdGet.
   - CountryRulerIdGet ($DD56-$DD5D): A = country id -> B1F_GetCountryDataPtr ($F368, masks low nibble, 8-byte block at $6F07+id*8), returns byte 0 = Ruler officer id ($FF = country destroyed).
   - OfficerCardShow ($DD5E-$DD6F): A = Officer id -> $0000, X = 0 strip, $000A <- $A7 sprite X base, banked call Y=$39 to B19_1A_OverlayStripRender_Entry ($A000 = JMP OfficerCardRender at $CE1F in prg_19_1a.asm).
2. Key semantic findings: country record byte 0 = Ruler officer id; officer record +$04 = 人徳 Virtue (docs/officer_data.md), +$03 = Loyalty. At @GiveGateRedraw ($BC26) the 授与 gift loyalty gain is scaled by the owning country Ruler's Virtue. $000A is the X base param of B1F_SpriteOamWriterSimple ($F1AD doc: $0A = X base, $0C = Y base); OfficerCardRender fills $000C from $04BC (default $10) itself.
3. Renamed all 12 call sites (8 JSR + 4 JMP tail: $A508, $AA32, $AADC, $AB37, $ACB4, $ACDC, $BC26, $BF65, $C5DA, $C740, $D18B, $D1BC, $D23F = 13 total incl. province entry) and fixed 4 doc-comment references. Close-path callers ($D18B/$D1BC/$D23F) re-draw the card while dismissing the overlay.

## Related files
- /home/zero/project/sango2dasm/asm/banks/prg_1b_1c.asm
- /home/zero/project/sango2dasm/asm/banks/prg_19_1a.asm (OfficerCardRender)
- /home/zero/project/sango2dasm/asm/banks/prg_1f.asm ($F2AF/$F2D7/$F368, $F1AD)

## Notes
- ca65 pitfall: an inner entry label inside .proc is proc-scoped; cross-proc JSR fails with "Symbol undefined". Repo convention (no .globl usage anywhere) is separate adjacent .proc blocks for multi-entry fall-through chains, matching the "bare globals between procs" rule.
- SearchReplace reported spurious "save failed, reason: unknown" twice while actually applying all replacements — always re-verify file state with grep before retrying.
- Grep result cap (25) hid 3 call sites of $DD5E in the same file; use targeted greps per pattern when counts approach the cap.
