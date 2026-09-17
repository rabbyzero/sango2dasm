# .word for address storage

- **Category:** development_code_specification
- **Memory ID:** d1f4b610-0026-4505-8e81-f35b756f8100
- **Keywords:** .word directive, address storage, assembly table

## Content

Use `.word` directive instead of paired `.byte >label, <label` when storing 16-bit addresses in tables, relying on the assembler to emit the correct byte sequence. Note: `.word` emits little-endian (low-byte first), so ensure runtime compatibility with the reading routine's expected byte order.
