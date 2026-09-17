# AI routine misnomers: AiCheckAdvancedStratagem, AiPickStratagem, AiPickEnemyStratagem

- **Category:** important_decision_experience
- **Memory ID:** f5b20474-b519-4a43-a378-5fac42bdef63
- **Keywords:** AiCheckAdvancedStratagem, rename decision, stratagem codes, Enticement, officer whitelist

## Content

Conclusion: Four AI routines in prg_08_09.asm had misleading names, all renamed after dispatch-table verification: (1) $AAF8 AiCheckRecruit -> AiCheckAdvancedStratagem (attempts stratagems $0A-$0F only, gated by caster officer-ID whitelist AiAdvancedStratagemOfficerTable, formerly AiRecruitClassTable, at $AC65); (2) $A9CF AiCheckAttackFeasible -> AiPickStratagem (tier/budget cascade picking stratagem codes 6,5,8,9,7,1,random(3/2/1),4,0 — no attack logic at all); (3) $A95C AiCheckMove -> AiPickStratagemTarget (was briefly AiPickEnemyStratagem, renamed again as confusing: it picks the TARGET — radius-5 scan strongest-first, first candidate with any feasible stratagem wins; the code is whatever the AiPickStratagem cascade selects, no best-stratagem search); (4) $AC7B AiCheckActionFeasible -> AiCheckStratagemFeasible (pure per-stratagem precondition dispatcher: computes target/self terrain into $0028/$0029 via GetTileTerrainClamped, then CallbackDispatcher on X into the 16-entry AiFeasible_* table; all 14 call sites pass stratagem codes). Caller locals @PickEnemyStratagem(2) -> @PickStratagemTarget(2). Stratagem 8 Enticement (籠絡) is requested only inside AiPickStratagem (@TryEnticement, tier>=8, budget>=$0A).

Rationale: AiCheckStratagemFeasible dispatches X directly through the inline table (entry 8 = AiFeasible_Enticement); the $AAF8 path only passes X=$0A-$0F, and class-table values exceed $64 (officer IDs, not ratings; id $6D unlocks MysticalStasis).

Rejected alternatives: renaming per-stratagem handlers (already glossary-aligned); keeping old labels with comments only. Applicable when naming AI routines: trace the exact X value into AiCheckStratagemFeasible and the routine's actual outputs ($6F8D = stratagem code, $6F8E = target) before assigning names; "CheckMove"/"CheckAttack"/"CheckAction"/"EnemyStratagem" names in this bank were derived from context, not contents.
