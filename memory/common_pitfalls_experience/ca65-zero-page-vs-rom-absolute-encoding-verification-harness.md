# ca65 zero-page vs ROM absolute encoding verification harness

- **Category:** common_pitfalls_experience
- **Memory ID:** 2a3720df-ed97-4f87-a627-b9f16dd6c545
- **Keywords:** zero-page encoding, absolute addressing, byte verification, harness, a: prefix

## Content

ca65 encodes direct $00xx operands as zero-page (e.g., STA $0020 → 85 20), but the Sangokushi 2 ROM uses absolute encoding (8D 20 00) for all zero-page addresses, so assembled output never byte-matches the ROM under default settings. For byte-identity verification of a region, use a harness: extract the region with `.org` at the bank base, stub symbols defined later with equates (exclude any symbol now defined inside the extracted region), force absolute addressing by prefixing direct $00xx operands with `a:` (regex `(?<![#(])\$00xx`, skip immediate/indirect), then assemble, link, and compare against rom/prg/prg_XX.bin. Working harnesses for prg_08_09.asm: tools/tmp_verify_region.py ($A000-$A8A7), tools/verify_find_region.py (through AiFindNearbyOfficers, $A000-$A943), and tools/tmp_verify_b130.py (through AiComputeBattleStats, $A000-$B130, 4400 bytes, verified 0 mismatches); all use build/_stubs.asm and build/_region.cfg. Numeric-literal branch operands (e.g., BMI $A951) fail with "Range error (Address size 2 does not match fragment size 1)" when assembled standalone, but succeed in full-file context, so do not judge standalone extraction failures on untouched code. ca65 cheap (@) labels DO support forward references within a zone. Labels nested inside .proc are referenced externally as `ProcName::LabelName`.

Fresh recurrence (2026-09, TownCommandDispatch work): this also applies to NEWLY emitted instructions, not just pre-existing source. Writing `STX $0010` / `LDY $0010` / `STA $0000` / `STA $00BC` in replacement code silently produced 2-byte zero-page encodings instead of 8E/AC/8D absolute (3-byte), shifting every later label by -7 bytes; caught only by tools/verify_1b_1c.py ("0 mismatches" gate). Rule: any hand-written instruction with a $00xx absolute operand in this project must use the `a:` prefix, matching the surrounding file style.
