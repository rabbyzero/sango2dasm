# Structured Binary Data Formatting

- **Category:** development_code_specification
- **Memory ID:** 225928fa-f1bd-4cbb-9f31-0cc379366c08
- **Keywords:** data formatting, structured layout, binary data
- **Usage scenarios:**
  - Formatting binary data tables in disassembly output

## Content

Binary data tables should be formatted in a structured layout when possible: group by major entry (e.g. 25 entries), then subdivide (e.g. 5 tiles per entry), then list individual elements (e.g. 8 bytes per tile). Use comments to label each level, and insert blank lines between top-level entries for clarity.
