# MenuItemIndexPool Binary Source Requirement

- **Category:** project_environment_configuration
- **Memory ID:** 7528344f-03fa-4a5b-93e5-0bef5b8ae472
- **Keywords:** binary source, data regeneration, ROM fidelity

## Content

The `MenuItemIndexPool` data must be regenerated from the original binary file `rom/prg/prg_0c.bin`, ensuring byte-level accuracy for the 0xB0-byte region starting at offset 0x1ABF (mapped to $BABF).
