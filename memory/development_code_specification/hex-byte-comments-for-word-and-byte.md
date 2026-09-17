# Hex byte comments for .word and .byte

- **Category:** development_code_specification
- **Memory ID:** b971416e-58dc-4ad2-bd7c-f30aa0472fe6
- **Keywords:** hex comments, .word, .byte, little-endian, traceability

## Content

Inline assembly comments for `.word` and `.byte` data must include the actual hexadecimal bytes as they appear in the compiled binary, written in little-endian order for `.word`, to ensure traceability against the ROM image.
