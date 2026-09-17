# Hexadecimal Notation with $ Prefix

- **Category:** development_code_specification
- **Memory ID:** 6d9a9d8f-2c9a-416e-ba53-d1ab289a2a26
- **Keywords:** hexadecimal, $ prefix, assembly syntax, inline comments, address notation, comment format

## Content

Hexadecimal values are written with a $ prefix (e.g., $A983, $AB25) rather than 0x notation. This applies to all assembly code including:
- Address operands in instructions (LDA $046C, STA $D5BD)
- Inline address comments (; $D5BD: AD 6C 04)
- Data directives (.word $A024, .byte $FF)
- Label definitions and references

The $ prefix is mandatory; omitting it (e.g., writing A983 instead of $A983) breaks the repository's hexadecimal notation standard and causes comment misalignment issues.
