# Menu Data Regeneration and Pool Segmentation from Binary

- **Category:** project_environment_configuration
- **Memory ID:** 185c8352-541a-44cf-9ead-bf7e8e47ad99
- **Keywords:** binary source, data regeneration, pool segmentation, MenuTypeItemListPtrs, MenuItemIndexPool

## Content

The `MenuTypeItemListPtrs` table and `MenuItemIndexPool` data must be regenerated from the original binary file `rom/prg/prg_0c.bin`. The pool is divided into 16 named segments (`MenuItemIndexPool00`–`MenuItemIndexPool0F`) based on actual usage in the pointer table, each starting at offsets derived from binary pointers. The pointer table entries directly reference these named pool segments.
