#!/bin/sh
# One-shot terminology alignment for prg_0a_0b.asm (docs/manual_kb/terminology.md)
# kingdom->country, domestic->strategy, entity->province, character->officer
set -e
F=asm/banks/prg_0a_0b.asm

# Pass 1: compound identifiers (order-safe, longest overlaps first)
sed -i \
 -e 's/KingdomExpansionCheck/CountryExpansionCheck/g' \
 -e 's/KingdomTierDispatch/CountryTierDispatch/g' \
 -e 's/ResolveKingdomAbsorb/ResolveCountryAbsorb/g' \
 -e 's/KingdomTierModifiers/CountryTierModifiers/g' \
 -e 's/KingdomActionModifiers/CountryActionModifiers/g' \
 -e 's/CallDomesticDisplay/CallStrategyModeDisplay/g' \
 -e 's/AiDomesticAction/AiStrategyAction/g' \
 -e 's/ExecDomesticAction/ExecStrategyAction/g' \
 -e 's/ActionCostTable_Domestic/ActionCostTable_Strategy/g' \
 -e 's/ActionDomestic/ActionStrategy/g' \
 -e 's/sram_kingdom_index/sram_country_index/g' \
 -e 's/ScanEntityOwnership/ScanProvinceOwnership/g' \
 -e 's/FindEntityForChar/FindProvinceForOfficer/g' \
 -e 's/FindBestOfficerInEntity/FindBestOfficerInProvince/g' \
 -e 's/AiAbsorbEntityAction/AiAbsorbProvinceAction/g' \
 -e 's/RefreshSubCharacterInfo/RefreshSubOfficerInfo/g' \
 -e 's/FindBestSubCharacter/FindBestSubOfficer/g' \
 -e 's/AiAction_CharacterSwap/AiAction_OfficerSwap/g' \
 -e 's/PerEntityLoop/PerProvinceLoop/g' \
 -e 's/LoadEntityPtr/LoadProvincePtr/g' \
 -e 's/OwnedEntity/OwnedProvince/g' \
 -e 's/FoundEntity/FoundProvince/g' \
 -e 's/EntityLoop/ProvinceLoop/g' \
 -e 's/nextEntity/nextProvince/g' \
 -e 's/NextEntity/NextProvince/g' \
 -e 's/entity_idx/province_idx/g' \
 -e 's/entity_score/province_score/g' \
 -e 's/best_entity/best_province/g' \
 -e 's/entity_id/province_id/g' \
 -e 's/kingdom_index/country_index/g' \
 -e 's/kingdom_mod/country_mod/g' \
 -e 's/CopyKingdom/CopyProvinceSlots/g' \
 "$F"

# Pass 2: prose words (word-bounded, case-sensitive)
sed -i \
 -e 's/\bentities\b/provinces/g' \
 -e 's/\bentity\b/province/g' \
 -e 's/\bEntities\b/Provinces/g' \
 -e 's/\bEntity\b/Province/g' \
 -e 's/\bkingdom\b/country/g' \
 -e 's/\bKingdom\b/Country/g' \
 -e 's/\bdomestic\b/strategy/g' \
 -e 's/\bDomestic\b/Strategy/g' \
 -e 's/\bcharacters\b/officers/g' \
 -e 's/\bcharacter\b/officer/g' \
 -e 's/\bCharacters\b/Officers/g' \
 -e 's/\bCharacter\b/Officer/g' \
 "$F"

echo "done"
