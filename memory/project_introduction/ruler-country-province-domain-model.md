# Ruler/Country/Province domain model and 城 City-vs-Castle rule

- **Category:** project_introduction
- **Memory ID:** 755f31f8-4dff-46bc-ab2b-67d5c648daad
- **Keywords:** Province domain model, City vs Castle, GetCountryDataPtr, GetProvinceRecordAddr, Country ownership
- **Usage scenarios:**
  - Naming labels and comments in disassembly banks
  - Translating Japanese manual terms to English
  - Reviewing cross-bank B1F data accessor references

## Content

Sangokushi 2 domain model (user-confirmed, recorded in docs/manual_kb/terminology.md): a Ruler (君主) rules a Country (国, formerly named "kingdom" in this codebase); a Country owns one or more Provinces (州); a Province can be empty or occupied by Officers, one of which is the Governor (太守). In-game a province is sometimes written as 城, which must be translated as City; 城 means Castle only for the castle command menu and the castle in Tactical/Battle Mode. Code identifiers follow this: GetProvinceRecordAddr ($F2AF, B1F_GetProvinceRecordAddr) computes the province record address id*32+$6000; GetCountryDataPtr ($F368, B1F_GetCountryDataPtr, table CountryDataPtrTable $F379) returns the country base address, NOT the ruler's. Former name GetRulerDataPtr was incorrect and renamed across prg_1f/prg_08_09/prg_0c_0d/prg_17_18 and functions.h.
