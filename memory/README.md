# Memory Dump

Complete dump of all memory contents retrievable from the memory system,
organized by category into subdirectories. Each file preserves the full
original memory content plus metadata (category, memory ID, keywords, usage scenarios).

## Index

### development_code_specification (12)

- [Assembly procedure wrapping convention](development_code_specification/assembly-procedure-wrapping-convention.md) — `adf7ace8-ae0e-4faa-b3a7-7c11f54429ac`
- [Bank-local labels: @-prefix for nearby refs, bare globals for forward/cross-proc](development_code_specification/bank-local-labels-at-prefix-bare-globals.md) — `efe7d886-f473-4014-bbc5-a6782e89519e`
- [ca65 @-prefixed local labels must be placed inline at target instructions](development_code_specification/ca65-at-prefixed-local-labels-must-be-placed-inline.md) — `152208ab-78ea-4d78-937e-1fdb66ee91a1`
- [Jump table entry label naming: (FunctionName)_Entry](development_code_specification/jump-table-entry-label-naming-functionname-entry.md) — `ead63306-29b6-4c08-875f-1b3eaf9d9cd9`
- [PascalCase semantic English naming convention for procedures and constants](development_code_specification/pascalcase-semantic-english-naming-convention.md) — `5b851c94-fc49-4240-88da-03537515ef43`
- [Replace .byte/.word data lines with disassembled code if they are actually code](development_code_specification/replace-byte-word-data-lines-with-disassembled-code.md) — `cd6e92bd-ff6c-4df9-a1e7-76b15cac841e`
- [Semantic naming convention for common exit routines](development_code_specification/semantic-naming-convention-for-common-exit-routines.md) — `f7908f5f-e89f-4545-9c52-e538e59546ca`
- [Semantic naming for control flow labels](development_code_specification/semantic-naming-for-control-flow-labels.md) — `6c354ee1-5f84-44fd-978e-871b64266810`
- [Semantic naming for local labels applying computed indices](development_code_specification/semantic-naming-for-local-labels-applying-computed-indices.md) — `8b199117-fe91-4ca6-ba6c-17f3a4bfe511`
- [Semantic naming for local skip targets](development_code_specification/semantic-naming-for-local-skip-targets.md) — `304cd88e-df25-4d3f-b4e6-8b3d0cb62c8b`
- [Structured Binary Data Formatting](development_code_specification/structured-binary-data-formatting.md) — `225928fa-f1bd-4cbb-9f31-0cc379366c08`
- [Use symbolic references in dispatch tables](development_code_specification/use-symbolic-references-in-dispatch-tables.md) — `142003aa-4e3d-4561-a1b3-63dd017878cf`

### development_comment_specification (2)

- [Code Comment Convention Requirement](development_comment_specification/code-comment-convention-requirement.md) — `800c9396-5ee1-4ca9-a931-3904c4218871`
- [Inline comment documentation for shared-exit label pattern](development_comment_specification/inline-comment-documentation-for-shared-exit-label-pattern.md) — `4aab0515-b6f0-4d7e-a8c5-f1955b65b333`

### development_practice_specification (16)

- [Apply Analysis Results to Source](development_practice_specification/apply-analysis-results-to-source.md) — `838ee8b2-0b70-40bd-9757-9b70f59d69ec`
- [Code Analysis Workflow: Verify, Replace, Rename, Fix, Explain](development_practice_specification/code-analysis-workflow-verify-replace-rename-fix-explain.md) — `7bd13e28-816c-4786-bfd9-5f8f2ef8867d`
- [Cross-scope .proc reference convention](development_practice_specification/cross-scope-proc-reference-convention.md) — `5cfeeffa-5533-4b91-9590-9458a5865381`
- [Nested functions and data encapsulation within AiTurnDispatch](development_practice_specification/nested-functions-and-data-encapsulation-within-aiturndispatch.md) — `be85a01c-3b7e-4dc1-8f85-cdedebc02291`
- [Pre-commit build verification workflow in sango2dasm](development_practice_specification/pre-commit-build-verification-workflow-in-sango2dasm.md) — `e671c0af-e420-406e-8d7d-e7e02b81dbf6`
- [prg_0e_0f.asm branch line comment column alignment pattern](development_practice_specification/prg-0e-0f-branch-line-comment-column-alignment-pattern.md) — `10951dce-f9f8-40c4-b69b-fd056bb43efc`
- [Scope Rule for $04xx RAM Variables](development_practice_specification/scope-rule-for-04xx-ram-variables.md) — `c2ce8337-f251-4d3f-a1ae-5cba6bd246b4`
- [SearchReplace whitespace anchor requirements and ROM verification workflow](development_practice_specification/searchreplace-whitespace-anchor-requirements-and-rom-verification-workflow.md) — `9c70774c-58b2-4091-90c7-e2169d4184ca`
- [Semantic naming convention for state machine dispatchers](development_practice_specification/semantic-naming-convention-for-state-machine-dispatchers.md) — `abf5b70d-38ed-4775-aa6f-b2cc43f9ec4b`
- [Semantic naming for core loop dispatchers](development_practice_specification/semantic-naming-for-core-loop-dispatchers.md) — `09f8de24-2917-4f8f-aec3-58ec503938aa`
- [Shared exit label scoping rule for ca65 assembly](development_practice_specification/shared-exit-label-scoping-rule-for-ca65-assembly.md) — `16a18700-e457-4ae7-ac39-83f285b5e3d6`
- [Structured Analysis Output Framework](development_practice_specification/structured-analysis-output-framework.md) — `a1ee1788-9edf-4d39-86c3-9787bcfc2ff5`
- [Structured code analysis framework](development_practice_specification/structured-code-analysis-framework.md) — `76b42d87-9757-411e-a53c-5b2616f0d9b1`
- [Update code with analysis results](development_practice_specification/update-code-with-analysis-results.md) — `9526f7e9-cc42-4884-bd98-eb3b72c42936`
- [Use disasm_prg.py for new PRG bank disassembly](development_practice_specification/use-disasm-prg-py-for-new-prg-bank-disassembly.md) — `eb686c7f-3a85-47cb-b7fa-8c1a8a502cee`
- [Zero-page variables use proc-local naming](development_practice_specification/zero-page-variables-use-proc-local-naming.md) — `544e1c16-5e23-4f1b-8813-07107cf60655`

### project_introduction (11)

- [Battlefield Stratagem System with Execution Logic and Terrain Mapping](project_introduction/battlefield-stratagem-system.md) — `b67a21ef-a281-4d51-9b3e-0e5e507a0b19`
- [Game manual knowledge base at docs/manual_kb](project_introduction/game-manual-knowledge-base-at-docs-manual-kb.md) — `b9ddbc81-d067-45b0-a7b2-66fdb624f8d3`
- [Kana/digit char code map (serial gojuon) for officer name strings](project_introduction/kana-digit-char-code-map-serial-gojuon.md) — `08290e6b-ac11-42d0-abe3-37de8bc0ce46`
- [Loc_C983 battle casualty morale resolution data structures](project_introduction/loc_c983-battle-casualty-morale.md) — `124c4366-1c08-466e-ab0e-e107dfc4a570`
- [Nested game mode hierarchy: Strategy > Tactical > Battle > Duel](project_introduction/nested-game-mode-hierarchy.md) — `ec8408a5-4bd9-4f06-90e7-5ebca486eed2`
- [Officer 12-byte record field layout](project_introduction/officer-12-byte-record-field-layout.md) — `b55bc565-336a-48be-a2a2-a0f8d265aece`
- [OfficerSearchAndEvaluate merged proc at $C79A-$C914](project_introduction/officersearchandevaluate-merged-proc.md) — `e7e2e9d4-d47c-4d03-bd01-995943b83257`
- [prg_17_18 war machine: WarClash (engagement calc) and WarResult (war tally) semantics](project_introduction/prg-17-18-war-machine-warclash-warresult.md) — `8847445d-de01-4ef6-b018-0505ae6cf897`
- [Project architecture and cross-bank calling convention](project_introduction/project-architecture-and-cross-bank-calling-convention.md) — `7f8e7f83-fc0f-4abb-a025-2ffa5f3f7431`
- [Ruler/Country/Province domain model and 城 City-vs-Castle rule](project_introduction/ruler-country-province-domain-model.md) — `755f31f8-4dff-46bc-ab2b-67d5c648daad`
- [Sound Engine Procedure Structure and Code Regions](project_introduction/sound-engine-procedure-structure-and-code-regions.md) — `4447e113-bc82-41cf-97f9-f10fca7acc23`

### project_architecture (7)

- [Battle bank RAM semantic map for prg_08_09.asm](project_architecture/battle-bank-ram-semantic-map-prg_08_09.md) — `0395917b-2ffa-4d7f-b791-8f162368af6e`
- [BattleOverlayDispatch state machine structure and RAM semantics](project_architecture/battleoverlaydispatch-state-machine.md) — `12371e24-5423-42eb-afa6-d28d196e0524`
- [Combined PRG bank pair architecture and linker layout pattern](project_architecture/combined-prg-bank-pair-architecture.md) — `60dc689b-8ca3-492f-97c5-5fd3f34480a3`
- [Menu font CHR pages, display records, and verified serial kana name encoding](project_architecture/menu-font-chr-pages-and-kana-name-encoding.md) — `a7d5c77f-12d3-445b-ae11-67f4ba577abf`
- [prg_0e_0f.asm RAM map: btl_ globals plus proc-local zero-page naming](project_architecture/prg_0e_0f-ram-map.md) — `2dd3b789-00bc-4521-9fb6-88310369000b`
- [Semantic distinction: war/tactical layer vs Battle Mode in prg_08_09.asm](project_architecture/semantic-distinction-war-tactical-vs-battle-mode.md) — `85b3ad14-e3cd-49fa-ae07-f59aee85fe4d`
- [Terminology.md as authoritative naming reference for game-domain vocabulary](project_architecture/terminology-md-authoritative-naming-reference.md) — `3d4b68a4-eb9a-4c5b-bdce-ebcead318293`

### project_build_configuration (4)

- [Bank verification tool pattern](project_build_configuration/bank-verification-tool-pattern.md) — `5d8d3378-5e67-4ccb-af26-adc519bacba5`
- [Makefile Build Configuration](project_build_configuration/makefile-build-configuration.md) — `17046208-039a-4b70-85d5-e4e494b99abc`
- [Per-bank verification harness and linker segment configuration](project_build_configuration/per-bank-verification-harness-and-linker-segment-configuration.md) — `c51e49b5-7f40-4bb0-9854-bb8ecda7705b`
- [PRG bank consolidation pattern and memory mapping](project_build_configuration/prg-bank-consolidation-pattern.md) — `adf08ad0-d19c-4a62-bd46-f57ccc237b68`

### project_environment_configuration (2)

- [Git commands require proxychains prefix](project_environment_configuration/git-commands-require-proxychains-prefix.md) — `80b0077c-020b-44f5-9d2a-7c9ae7e16ac5`
- [PRG bank $1D/$1E memory mapping](project_environment_configuration/prg-bank-1d-1e-memory-mapping.md) — `c730631f-c812-4386-9a85-e911d11ae0ef`

### project_scm_configuration (2)

- [Build directory excluded from version control](project_scm_configuration/build-directory-excluded-from-version-control.md) — `30456f58-c2cc-47c4-9c9f-8cd8f6fd3c04`
- [Git ignore rules for build artifacts and staging workflow](project_scm_configuration/git-ignore-rules-for-build-artifacts-and-staging-workflow.md) — `72e6eedc-750b-492f-b73b-6a9ac684055f`

### project_tech_stack (4)

- [Independent Proc Validation Rule](project_tech_stack/independent-proc-validation-rule.md) — `090d4481-e810-47b0-b454-f91b0eeac302`
- [Multi-entry procedure pattern with global inner label support](project_tech_stack/multi-entry-procedure-pattern-with-global-inner-label.md) — `80a3e948-1fbb-45bb-ac53-3a25304e5918`
- [NES Disassembly Tech Stack](project_tech_stack/nes-disassembly-tech-stack.md) — `818e598c-c9a3-4ae9-930c-a162db72ac2a`
- [$6F8B strategy-layer request mailbox protocol and handler flow](project_tech_stack/strategy-layer-request-mailbox-protocol.md) — `2a8ef781-f1d7-44f1-b69a-8e5f895e02e1`

### common_pitfalls_experience (21)

- [Address-operand regex must consume full hex token before \b](common_pitfalls_experience/address-operand-regex-must-consume-full-hex-token.md) — `b44823bb-9182-464f-b1fb-3f5a6e6e0e43`
- [Assembly byte-shift cascade from dropped instruction during refactoring](common_pitfalls_experience/assembly-byte-shift-cascade-from-dropped-instruction.md) — `0b694a9c-ea29-4a4a-9ac6-309204dc1dc5`
- [Avoid f-strings in python3 -c under fish shell](common_pitfalls_experience/avoid-f-strings-in-python3-c-under-fish-shell.md) — `a6d0ed15-b97d-44ff-ba13-c4d7e4e05f62`
- [ca65: Explicit label required after removing .proc](common_pitfalls_experience/ca65-explicit-label-required-after-removing-proc.md) — `6fcd0719-6a88-4a36-b585-7ce74e82355c`
- [ca65 .proc inner label referencing requires Proc::Label syntax](common_pitfalls_experience/ca65-proc-inner-label-referencing-requires-proc-label-syntax.md) — `e550186b-0534-4cb7-bfcf-3df093db45ac`
- [ca65 .proc scope limits label accessibility to external procedures](common_pitfalls_experience/ca65-proc-scope-limits-label-accessibility-to-external-procedures.md) — `5f3e5fbc-df0c-4290-9450-4650f77c9e66`
- [ca65 range errors from numeric branch targets in bank disassembly](common_pitfalls_experience/ca65-range-errors-from-numeric-branch-targets.md) — `c712d7bc-2d87-4298-ba5a-7eed996e6871`
- [ca65 shared-exit labels must be bare globals between procs](common_pitfalls_experience/ca65-shared-exit-labels-must-be-bare-globals-between-procs.md) — `1851c9dc-0aea-4f97-8434-fff1b2a99bb8`
- [Comment block formatting corruption during bulk SearchReplace refactoring](common_pitfalls_experience/comment-block-formatting-corruption-during-bulk-searchreplace.md) — `4650c10e-7e9b-43ce-9b9e-ac4250c24b4c`
- [Cross-bank mid-entry points require separate equates to avoid incorrect address encoding](common_pitfalls_experience/cross-bank-mid-entry-points-require-separate-equates.md) — `b15e085d-8da0-4fbb-89f9-bdae9eee4f45`
- [Data table restructure must preserve physical byte order](common_pitfalls_experience/data-table-restructure-must-preserve-physical-byte-order.md) — `0447754b-c08b-406f-81e1-82e85953c923`
- [Full build broken at HEAD with 53 pre-existing symbol errors](common_pitfalls_experience/full-build-broken-at-head-with-53-pre-existing-symbol-errors.md) — `8ff99533-cb61-4fc4-a375-4f6bae09aa13`
- [Handle JSR spanning bank boundaries with segment split](common_pitfalls_experience/handle-jsr-spanning-bank-boundaries-with-segment-split.md) — `44db742a-2975-4991-a062-5ad477576097`
- [Inline dispatch table recognition and banked callback trampoline decoding pitfalls](common_pitfalls_experience/inline-dispatch-table-and-banked-callback-trampoline-pitfalls.md) — `e82d6c19-6ef0-459a-ba70-414174fd66e9`
- [Legacy label conflicts when establishing new terminology standards in disassembly projects](common_pitfalls_experience/legacy-label-conflicts-when-establishing-new-terminology.md) — `46003d08-1036-4dcb-828e-89dbd0e17d77`
- [Misclassified .byte/.word data containing actual 6502 code](common_pitfalls_experience/misclassified-byte-word-data-containing-actual-6502-code.md) — `6f8810e2-7c27-4810-92e2-f16f4fbc14ea`
- [Removing redundant ROM jumps causes cascading byte-exact drift](common_pitfalls_experience/removing-redundant-rom-jumps-causes-cascading-byte-exact-drift.md) — `10e5ca89-783f-4209-8f8e-f91e18cc31f4`
- [SearchReplace whitespace anchor requirements for assembly files with branch line padding](common_pitfalls_experience/searchreplace-whitespace-anchor-requirements-branch-line-padding.md) — `4ecf05ed-e8da-4a65-91bc-428e93b8350d`
- [Symbolic-reference conversion pitfalls: label drift, @-locals scope, byte-row duplication](common_pitfalls_experience/symbolic-reference-conversion-pitfalls.md) — `5e472fed-3b2d-4502-87a8-51a35c3c90b3`
- [Use tmp files for multi-line scripts in fish shell](common_pitfalls_experience/use-tmp-files-for-multi-line-scripts-in-fish-shell.md) — `c4d25361-82ef-4f13-a72d-5a6b6598732c`
- [Verification harness must exclude pseudo-disassembly lines from absolute-addressing transformation](common_pitfalls_experience/verification-harness-must-exclude-pseudo-disassembly-lines.md) — `3809c7df-61d0-4b0a-8f00-8fd824021ddb`

### important_decision_experience (6)

- [Cross-bank function rename scope boundary decision](important_decision_experience/cross-bank-function-rename-scope-boundary-decision.md) — `e4ea6a05-6fbe-44ac-9143-1183214af0f4`
- [Intra-Bank Label Naming Convention: Bare Names, Prefixes for Cross-Bank Only](important_decision_experience/intra-bank-label-naming-convention.md) — `6bc883a2-52a7-4a4f-b360-fd92b4413313`
- [Merge Two Entry Points into One Proc](important_decision_experience/merge-two-entry-points-into-one-proc.md) — `7e8c1abf-0930-4d2a-bde1-fd1d4fc150e4`
- [Procedure encapsulation decision for BattleResultSlotTemplateApply](important_decision_experience/procedure-encapsulation-decision-battle-result-slot-template-apply.md) — `a780f1d1-c291-45c3-bf1c-eac08209009c`
- [滚动面板行模板命名决策](important_decision_experience/scroll-panel-row-template-naming-decision.md) — `46188581-dfca-47cd-9ea6-e81696be52de`
- [Semantic Routine Renaming Decision - SceneRenderer](important_decision_experience/semantic-routine-renaming-decision-scenerenderer.md) — `c0b6b2f7-6433-412a-96af-d86bc4031d82`

### tool_experience (1)

- [ca65 cross-scope label references use Proc::Label, not Proc@Label](tool_experience/ca65-cross-scope-label-references-proc-label.md) — `b0f7349c-d42a-4a08-8975-474f436d923a`

### history_task_reference_files (1)

- [Files modified for bank boundary JSR fix and segment configuration](history_task_reference_files/files-modified-for-bank-boundary-jsr-fix.md) — `d3360452-7481-43ff-867b-fa4b00408fcc`

### task_summary_experience (7)

- [Bank-wide terminology alignment commit (battle->war) across PRG banks](task_summary_experience/bank-wide-terminology-alignment-commit-battle-to-war.md) — `ae4821b4-d08d-4b50-af5a-183eeb2c86f9`
- [BattleAnimSoundEngine code analysis and refactoring with $DF6E boundary fix](task_summary_experience/battleanimsoundengine-analysis-df6e-fix.md) — `19342ee9-cf52-4a1c-b19f-b5ef1d42f0fb`
- [Frame state 9 handler and $6F8B strategy-layer mailbox protocol in prg_19_1a.asm](task_summary_experience/frame-state-9-handler-and-6f8b-mailbox.md) — `b31911c0-9db6-4a4e-ac60-999aec65b594`
- [Code Analysis Workflow execution on Loc_C983 battle casualty routine](task_summary_experience/loc_c983-code-analysis-workflow.md) — `8fc6c4f0-aedd-4334-b8f1-245d566e4821`
- [PRG bank switch linkage mapping for Sangokushi 2 disassembly](task_summary_experience/prg-bank-switch-linkage-mapping.md) — `81d60193-bb83-4819-a594-2a2f303ca9be`
- [Document shared-exit label pattern rationale in inline comments](task_summary_experience/shared-exit-label-pattern-doc.md) — `961ab3bd-3077-44c3-8eb1-4d846b757fc8`
- [Consolidated semantic English terminology glossary for Sangokushi 2 disassembly](task_summary_experience/terminology-glossary-consolidation.md) — `e9504a26-d39b-47ae-99a2-f8e0807ce836`

Total entries: 96
