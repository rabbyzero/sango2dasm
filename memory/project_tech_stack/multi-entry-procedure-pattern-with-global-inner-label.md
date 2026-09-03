# Multi-entry procedure pattern with global inner label support

- **Category:** project_tech_stack
- **Memory ID:** 80a3e948-1fbb-45bb-ac53-3a25304e5918
- **Keywords:** multi-entry, fall-through, proc pattern, global inner label, externally referenced
- **Usage scenarios:**
  - Merging two related entry points into one proc when one falls through to the other
  - Encountering a JSR to a label inside another procedure
  - Refactoring auto-disassembled code with spurious dispatch tables
  - Combining address calculation and data copying into a single proc

## Content

Procedures may have multiple entry points when appropriate, such as combining address calculation and data copying into a single proc where the first entry computes an address and falls through to the second entry that performs the copy operation. When a multi-entry procedure has an inner entry point that is externally referenced (e.g., called via JSR from other procedures), that inner label must be declared as a global symbol to ensure it can be linked correctly. This follows the established pattern seen in ProvinceSelect_CheckSlot / ProvinceSelect_GetRecord where a secondary entry within a .proc is globally accessible.
