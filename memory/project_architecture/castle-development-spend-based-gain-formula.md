# Castle development spend-based gain formula

- **Category:** project_architecture
- **Memory ID:** 85cc74ac-0af8-4fc3-a1c3-8f4327d0077c
- **Keywords:** castle development, gain formula, DeductRecordStat2, resource spending, Sangokushi 2

## Content

Castle development commands in Sangokushi 2 use a spend-based gain formula: handlers call DeductRecordStat2 (spends base+random Gold from +$02/$03) or DeductRecordStat4 (spends base+random Rice from +$04/$05), then compute gain as spent_amount × level_mod[0-6] / 10, capped at field-specific maximums (Population cap $270F=9999, LandValue cap 999, Governance cap 100). TownDevelopment halves the gain; GovernanceBoost divides gold+rice total by mod[6]. This contradicts earlier misinterpretations that used "province_idx × $0E × mod" formulas.
