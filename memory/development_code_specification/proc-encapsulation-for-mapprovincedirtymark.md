# .proc encapsulation for MapProvinceDirtyMark

- **Category:** development_code_specification
- **Memory ID:** 7bd22339-0e40-4596-a7f5-be279e9d87d5
- **Keywords:** .proc, encapsulation, local data, code structure

## Content

The `MapProvinceDirtyMark` routine must be defined as a `.proc` block, encapsulating its private `MapProvinceDirtyBitMaskTable` within the same scope to maintain data locality and follow the project's code organization pattern.
