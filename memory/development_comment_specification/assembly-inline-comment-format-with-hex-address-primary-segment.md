# Assembly inline comment format with hex address primary segment

- **Category:** development_comment_specification
- **Memory ID:** 997af872-d912-4600-8757-f87a047eb26c
- **Keywords:** inline comments, hex address, comment format, $ prefix, assembly comments, two-segment format

## Content

Inline comments in assembly files follow a two-segment format when documenting addresses or entries:

Primary segment: `; $ADDR: bytes` - hex address with mandatory `$` prefix followed by instruction bytes
Secondary segment (optional): `; note` - additional context like proc name, table purpose, etc.

Example: `LDA $046C                               ; $D5BD: AD 6C 04  ; ConfirmDialogPoll entry: dialog state gate`

Key rules:
1. Hex addresses must always have `$` prefix (e.g., `$D5BD`, not `D5BD`)
2. Primary segment comes first after sufficient whitespace padding to column ~43
3. Secondary segment follows two spaces after primary segment
4. This format applies to all bank files (.asm) for consistency

The `$` prefix is mandatory; omitting it breaks the hexadecimal notation standard and causes comment misalignment issues.
