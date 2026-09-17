# Terminology.md as authoritative naming source with BXX_YY_* cross-bank convention

- **Category:** development_code_specification
- **Memory ID:** 46dc617a-7aa7-4883-8a0f-2c83a6940c50
- **Keywords:** terminology.md, semantic naming, cross-bank naming, BXX_YY_*, multi-entry procedure

## Content

Game-domain vocabulary must use semantic English from docs/manual_kb/terminology.md (e.g., 君主=Ruler, 国=Country, 武将=Officer, 城=Castle, 戦略=Strategy Mode). All procedure labels and constants follow PascalCase semantic English naming. Cross-bank references use BXX_YY_* prefix where XX = Y & $1F (effective bank after 5-bit mask), YY = second half of 16KB pair (e.g., B1D_1E_OfficerDisplay_Lookup for Y=$3D→$1D+$1E). Intra-bank references use bare names; only cross-bank JSR/JMP calls get Bxx_ prefix. Multi-entry procedures require secondary entry points to be bare global labels placed outside .proc/.endproc blocks (hoist .endproc above shared label) to avoid ca65 scoping errors.
