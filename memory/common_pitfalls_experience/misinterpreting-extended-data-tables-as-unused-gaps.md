# Misinterpreting extended data tables as unused gaps

- **Category:** common_pitfalls_experience
- **Memory ID:** d79affb1-c2e1-4906-9c3f-c788d16a7f12
- **Keywords:** data table boundaries, unused gap detection, table extension verification, indexing formula

## Content

When analyzing data regions, assume contiguous tables extend until explicitly broken by code or logical boundaries. In BattleRosterSetup ($B548-$B86F), an initial assumption that $B7DC-$B7EB was unused leftover data was corrected after verifying the pattern: the block contained rank 6-7 boundary pairs matching the format of ranks 0-5 in BattleUnitGradeLimitTable. Root cause: failing to verify if apparent gaps matched the indexing formula ((rank<<2 | grade)*2). Always cross-check suspected gaps against table access patterns before labeling as unused.
