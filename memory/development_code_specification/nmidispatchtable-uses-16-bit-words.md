# NmiDispatchTable uses 16-bit words

- **Category:** development_code_specification
- **Memory ID:** d958198c-0ebe-46e4-a20c-adf1cc8c0401
- **Keywords:** NmiDispatchTable, 16-bit, .word

## Content

The NmiDispatchTable must be defined using 16-bit words (.word) instead of 8-bit bytes (.byte), as it represents a table of 16-bit addresses. Each entry should be stored in little-endian format.
