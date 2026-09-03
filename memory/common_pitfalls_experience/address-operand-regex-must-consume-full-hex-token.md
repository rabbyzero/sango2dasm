# Address-operand regex must consume full hex token before \b

- **Category:** common_pitfalls_experience
- **Memory ID:** b44823bb-9182-464f-b1fb-3f5a6e6e0e43
- **Keywords:** regex token boundary, symbolic conversion, zp vs absolute, replacement script
- **Usage scenarios:**
  - Writing scripts that rename raw operands to symbols
  - Symbolic reference conversion producing zero matches
  - Mixed zp/absolute addressing cleanup

## Content

Bug class: scripted raw-address to symbolic-name conversion in 6502 disassembly missed every operand. Root cause: the address regex `\$([0-7][0-9A-Fa-f]{2})\b` consumed only 3 hex digits of 4-digit tokens like `$0545`, so the trailing `\b` (digit vs digit) never matched, and `\b` after a 1-digit group fails on 2-digit tokens like `$00`. Fix pattern: the regex must consume the complete hex token (`\$([0-7][0-7][0-9A-Fa-f]{2})\b` for absolutes, `\$([0-9A-Fa-f]{2})\b` for zp forms), plus a lookbehind excluding `+` so offsets inside already-symbolic `base+$xx` expressions are untouched. Reusable lesson: in this repo the same zp cell appears both as 2-digit zp-encoded operands (85/A5 opcodes, no `a:` prefix) and 4-digit absolute operands (`a:$0081`, 8D/AD) — both forms must map to the same symbol, and ca65 keeps zp encoding for symbol values below $0100 so byte parity holds. Always validate the replacement script with a match count before trusting a "success" run.
