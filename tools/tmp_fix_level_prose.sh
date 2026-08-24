#!/bin/sh
# Fix $6F02-derived prose: game level (0-2) selected at new game start
set -e
F=asm/banks/prg_0a_0b.asm
sed -i \
 -e 's/indexed by \[country\*8 + player_id\]/indexed by [level*8 + player_id]/g' \
 -e 's/indexed by \[country\*4 + tier\]/indexed by [level*4 + tier]/g' \
 -e 's/; Country\/region index/; Game level (0-2), selected at new game start/' \
 -e 's/Phase 0\/1: 20% chance/Level 0\/1: 20% chance/g' \
 -e 's/Phase 2:   30% chance/Level 2:   30% chance/' \
 -e 's/- Phase 0: ready/- Level 0: ready/' \
 -e 's/- Phase 1: ready/- Level 1: ready/' \
 -e 's/(sub-phase)$//' \
 -e 's/- Phase 2: always ready/- Level 2: always ready/' \
 -e 's/; Phase 2: 30% chance (more aggressive late-game)/; Level 2: 30% chance (more aggressive at highest level)/' \
 -e 's/@phase0Check/@level0Check/g' \
 -e 's/; phase 0$/; level 0/' \
 -e 's/; phase 2: always ready/; level 2: always ready/' \
 -e 's/; Phase 1: need/; Level 1: need/' \
 -e 's/; Phase 0: need/; Level 0: need/' \
 -e 's/costs\/rendering for the current country\./costs\/rendering based on the game level./' \
 -e 's/action tier (1-4) for current country using a per-phase threshold/action tier (1-4) using a per-level threshold/' \
 -e 's/- Country tier modifiers (12 bytes)/- Level tier modifiers (level*4 + tier, 12 bytes)/' \
 -e 's/- Country action modifiers (12 bytes)/- Level action modifiers (one per level, 12 bytes)/' \
 -e 's/army values and country tier/army values and level tier modifiers/' \
 -e 's/Compute score based on country tier/Compute score based on level tier modifiers/' \
 -e 's/; \$20 = country tier (0-2)/; $20 = tier (0-2)/' \
 -e 's/\*4 (4 entries per country)/*4 (4 entries per level)/' \
 -e 's/(country_index \* 4 + tier)/(game_level * 4 + tier)/' \
 -e 's/probability check vs stat + country tier/probability check vs stat + tier modifier/' \
 -e 's/; country index/; game level/g' \
 -e 's/; country modifier/; level modifier/g' \
 -e 's/Same country modifier table/Same level modifier table/' \
 -e 's/Per-country action modifiers (circular 12-byte table, indexed by country_index)/Per-level action modifiers (12-byte table, indexed by game level)/' \
 -e 's/attempt country assign/attempt officer assignment/' \
 -e 's/iterate country entries/iterate officer records/g' \
 -e 's/country-specific probability thresholds (indexed by \$6F02)/Per-level probability thresholds (indexed by game level)/' \
 -e 's/copy country data from bank \$30/copy province slot data from bank $30/' \
 "$F"
echo pass-ok
