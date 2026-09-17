# Cross-bank equate naming convention BXX_YY_* in functions.h

- **Category:** development_code_specification
- **Memory ID:** f560f417-f4f3-44b6-a27f-09b566ae9fe2
- **Keywords:** functions.h, cross-bank naming, BXX_YY_*, equate convention, bank pairs

## Content

Cross-bank procedure equates in Sangokushi 2 disassembly use the format BXX_YY_* where XX and YY are two-digit hex bank numbers (e.g., B1B_1C_OfficerSelectDialogPoll_Entry = $A006). The pattern is:
- B prefix followed by source bank number (2 hex digits)
- Underscore followed by target bank number (2 hex digits)
- Underscore followed by semantic procedure name
- Entry stubs use _Entry suffix (e.g., B1B_1C_ProvinceZoneOriginGet_Entry)
- Direct procedure calls omit _Entry suffix (e.g., B1D_1E_OfficerDisplay_Lookup)

All cross-bank symbols must be defined in include/functions.h SECTION N where N corresponds to the bank pair number. Symbols can only be used if the target bank pair exists in functions.h; otherwise, leave .word targets as raw addresses.

This naming convention enables consistent symbolic references across bank boundaries while maintaining clarity about which banks are involved in each call.
