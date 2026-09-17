# .word directive for 16-bit threshold table

- **Category:** project_tech_stack
- **Memory ID:** a577ab21-cda6-4753-84a9-1c51d6b977a3
- **Keywords:** .word directive, 16-bit table, little-endian, indexed access

## Content

The `OfficerLevelExpThresholds` table uses the `.word` directive to define 16-bit values in little-endian byte order, ensuring correct indexed access via `OfficerLevelExpThresholds,Y` while maintaining byte-exact compatibility.
