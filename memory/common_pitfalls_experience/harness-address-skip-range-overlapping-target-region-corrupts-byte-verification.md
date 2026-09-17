# Harness address-skip range overlapping target region corrupts byte verification

- **Category:** common_pitfalls_experience
- **Memory ID:** 856c696c-9acf-4461-901a-4dac6ed1cd9c
- **Keywords:** verification harness, address range overlap, zero-page encoding, byte shift, cheap label zones

## Content

Byte-verification harnesses that force absolute addressing (a: prefix on $00xx operands) and exempt an address range by parsing the "; $XXXX:" trace comments caused silent corruption: the exempt range ($D13C-$D1EE, meant for a pseudo-disassembly block) overlapped the target routine starting at $D1ED, so its zero-page operands kept 2-byte zp encoding (A5 instead of AD xx 00), shifting every following byte and producing hundreds of mismatches that looked like real regressions. Must keep exempt address ranges strictly below the region under test, and when mismatch storms start exactly at a region boundary, check the harness transform rules before doubting the source. Also: slice-based harnesses break ca65 cheap-label (@) zone resolution for a few forward references that resolve in full-file builds; substitute those operands with absolute addresses in the harness copy only, never in the source.
