# functions.h cross-bank naming uses BXX_YY_* with Y mask

- **Category:** project_tech_stack
- **Memory ID:** 7c77ffe0-841c-4238-99d3-1747fd5e88a9
- **Keywords:** functions.h, cross-bank naming, BXX_YY_*, BankedCallbackTrampoline, Y mask

## Content

In functions.h, cross-bank function names follow the pattern `BXX_YY_*` where XX is the lower 5 bits of the Y register value used in banked callbacks (Y & $1F). For example: Y=$3D & $1F = $1D → `B1D_1E_OfficerDisplay_Lookup`, Y=$2C & $1F = $0C → `B0C_0D_OfficerTransferCalc_Entry`. The YY portion represents the second half of the 16KB bank pair (e.g., $1D+$1E for banks at $A000-$DFFF). Bank pairs are combined (e.g., $08+$09, $17+$18, $1D+$1E). Only banks with documented procedures in functions.h can be symbolized; undisassembled banks remain as raw addresses. The B1F_* prefix is used for bank $1F (fixed engine bank) which has no pair. This naming convention must be used when annotating BankedCallbackTrampoline .word targets instead of local assembly labels.
