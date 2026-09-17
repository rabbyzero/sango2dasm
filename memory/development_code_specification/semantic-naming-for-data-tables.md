# Semantic naming for data tables

- **Category:** development_code_specification
- **Memory ID:** 278ae8ac-1fb7-43c7-b056-1f2371e4c853
- **Keywords:** semantic naming, data table, label naming, MenuCommandTable

## Content

Data table labels must be semantic and reflect their logical purpose, not generic names like `DataTable`. For example, `@DataTable` was renamed to `@MenuCommandTable` because it maps each menu item index (×6 stride) to target state ($0500), phase ($0501), and screen position coordinates.
