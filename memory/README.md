# Memory Dump

Complete dump of all memory contents retrievable from the memory system,
organized by category into subdirectories. Each file preserves the full
original memory content plus metadata (category, memory ID, keywords).

Regenerated from the on-disk dump by tools/regen_memory_readme.py.

## Index


### common_pitfalls_experience (52)

- [6502 BCC trampoline vs JMP target separation rule](common_pitfalls_experience/6502-bcc-trampoline-vs-jmp-target-separation-rule.md) — `7570b8cc-e3c9-4c00-a454-404de48d2920`
- [Address-operand regex must consume full hex token before \b](common_pitfalls_experience/address-operand-regex-must-consume-full-hex-token.md) — `b44823bb-9182-464f-b1fb-3f5a6e6e0e43`
- [Assembly byte-shift cascade from dropped instruction during refactoring](common_pitfalls_experience/assembly-byte-shift-cascade-from-dropped-instruction.md) — `0b694a9c-ea29-4a4a-9ac6-309204dc1dc5`
- [Avoid disassembling banks 00-07 which are data-only terrain/tile/sprite assets](common_pitfalls_experience/avoid-disassembling-banks-00-07-data-only-assets.md) — `54da40c5-765d-4890-b206-5935faf486ae`
- [Avoid f-strings in python3 -c under fish shell](common_pitfalls_experience/avoid-f-strings-in-python3-c-under-fish-shell.md) — `a6d0ed15-b97d-44ff-ba13-c4d7e4e05f62`
- [BankedCallbackTrampoline .word targets point to OTHER banks, not current file's loaded range](common_pitfalls_experience/bankedcallbacktrampoline-word-targets-point-to-other-banks.md) — `4f6f98fa-cf4a-4550-84dc-61f96183a836`
- [Branch target label confusion during semantic renaming in assembly](common_pitfalls_experience/branch-target-label-confusion-during-semantic-renaming.md) — `1298c9d9-a61a-4aa0-94c6-b0a789c85ea8`
- [ca65 @-label conversion needs address-based fixpoint; git checkout wiped uncommitted prior work](common_pitfalls_experience/ca65-at-label-conversion-needs-address-based-fixpoint.md) — `68ee8f78-4d84-4c44-8ff0-f22f1d70ff69`
- [ca65 branch across .segment boundary requires raw byte emission](common_pitfalls_experience/ca65-branch-across-segment-boundary-requires-raw-byte-emission.md) — `32a9e830-a654-4714-8de4-aeec059e038b`
- [ca65 cheap-local @-label scope breakage on global promotion](common_pitfalls_experience/ca65-cheap-local-at-label-scope-breakage-on-global-promotion.md) — `b7a53cd7-1aca-44ba-9519-44aa9bd237ea`
- [ca65 cheap local symbols scoped by preceding global label, not .proc boundary](common_pitfalls_experience/ca65-cheap-local-symbols-scoped-by-preceding-global-label.md) — `a31f0be7-cb7b-4ae7-b573-385a6660b4a2`
- [ca65: Explicit label required after removing .proc](common_pitfalls_experience/ca65-explicit-label-required-after-removing-proc.md) — `6fcd0719-6a88-4a36-b585-7ce74e82355c`
- [ca65 include guards require constant symbols instead of .define macros](common_pitfalls_experience/ca65-include-guards-require-constant-symbols-instead-of-define-macros.md) — `01472f7d-3db6-40bc-a796-e54e4e4e339a`
- [ca65 .proc inner label referencing requires Proc::Label syntax](common_pitfalls_experience/ca65-proc-inner-label-referencing-requires-proc-label-syntax.md) — `e550186b-0534-4cb7-bfcf-3df093db45ac`
- [ca65 .proc scope limits label accessibility to external procedures](common_pitfalls_experience/ca65-proc-scope-limits-label-accessibility-to-external-procedures.md) — `5f3e5fbc-df0c-4290-9450-4650f77c9e66`
- [ca65 range errors from numeric branch targets in bank disassembly](common_pitfalls_experience/ca65-range-errors-from-numeric-branch-targets.md) — `c712d7bc-2d87-4298-ba5a-7eed996e6871`
- [ca65 shared-exit labels must be bare globals between procs](common_pitfalls_experience/ca65-shared-exit-labels-must-be-bare-globals-between-procs.md) — `1851c9dc-0aea-4f97-8434-fff1b2a99bb8`
- [ca65 zero-page vs ROM absolute encoding verification harness](common_pitfalls_experience/ca65-zero-page-vs-rom-absolute-encoding-verification-harness.md) — `2a3720df-ed97-4f87-a627-b9f16dd6c545`
- [Circular dependency in computed address operands for trampoline returns](common_pitfalls_experience/circular-dependency-in-computed-address-operands-for-trampoline-returns.md) — `3d4bda29-6356-4cf1-b8e8-1ff5826464c6`
- [Comment block formatting corruption during bulk SearchReplace refactoring](common_pitfalls_experience/comment-block-formatting-corruption-during-bulk-searchreplace.md) — `4650c10e-7e9b-43ce-9b9e-ac4250c24b4c`
- [Cross-bank mid-entry points require separate equates to avoid incorrect address encoding](common_pitfalls_experience/cross-bank-mid-entry-points-require-separate-equates.md) — `b15e085d-8da0-4fbb-89f9-bdae9eee4f45`
- [Data table mis-splitting causes ROM overflow during disassembly refactoring](common_pitfalls_experience/data-table-mis-splitting-causes-rom-overflow.md) — `d249ef3e-b69a-4cc5-9276-346255416be9`
- [Data table restructure must preserve physical byte order](common_pitfalls_experience/data-table-restructure-must-preserve-physical-byte-order.md) — `0447754b-c08b-406f-81e1-82e85953c923`
- [Distinguish genuine mechanics from stale naming after semantic refactoring](common_pitfalls_experience/distinguish-genuine-mechanics-from-stale-naming-after-semantic-refactoring.md) — `23a8c164-3927-43b9-b584-053f397e6294`
- [Duel module procs renamed: DuelModeDispatch, duel_state $04A8, verified semantics](common_pitfalls_experience/duel-module-procs-renamed-duelmodedispatch-duel-state-verified-semantics.md) — `d19f0aa9-9def-4d4a-9169-3ccbd491ce79`
- [Duplicate .endproc bug in multi-part proc replacement workflow](common_pitfalls_experience/duplicate-endproc-bug-in-multi-part-proc-replacement-workflow.md) — `53284a58-4225-4460-a7ef-d27ba330bfcd`
- [False trampoline target claims from stale scan data](common_pitfalls_experience/false-trampoline-target-claims-from-stale-scan-data.md) — `e715a4b0-17a0-463f-8873-acf5b3c4ec4e`
- [Full build broken at HEAD with 53 pre-existing symbol errors](common_pitfalls_experience/full-build-broken-at-head-with-53-pre-existing-symbol-errors.md) — `8ff99533-cb61-4fc4-a375-4f6bae09aa13`
- [Grep for address tokens across full codebase, not just decoded regions](common_pitfalls_experience/grep-for-address-tokens-across-full-codebase.md) — `abdcaa66-8699-4e41-9e16-2c1bcb470fe3`
- [Handle JSR spanning bank boundaries with segment split](common_pitfalls_experience/handle-jsr-spanning-bank-boundaries-with-segment-split.md) — `44db742a-2975-4991-a062-5ad477576097`
- [Harness address-skip range overlapping target region corrupts byte verification](common_pitfalls_experience/harness-address-skip-range-overlapping-target-region-corrupts-byte-verification.md) — `856c696c-9acf-4461-901a-4dac6ed1cd9c`
- [Hex transcription errors in large data tables require programmatic generation](common_pitfalls_experience/hex-transcription-errors-in-large-data-tables-require-programmatic-generation.md) — `124ff6df-0472-496c-be8e-861922678b8a`
- [Inline dispatch pattern must not be treated as raw data](common_pitfalls_experience/inline-dispatch-pattern-must-not-be-treated-as-raw-data.md) — `fd4a3783-0e8f-48e0-82ab-f382c041d7a6`
- [Inline dispatch table recognition and banked callback trampoline decoding pitfalls](common_pitfalls_experience/inline-dispatch-table-recognition-trampoline-decoding-pitfalls.md) — `e82d6c19-6ef0-459a-ba70-414174fd66e9`
- [Inline trampoline target word can poison following code into .byte data](common_pitfalls_experience/inline-trampoline-target-word-can-poison-following-code-into-byte-data.md) — `c1b1547f-84bf-49ce-9b2d-002d193b795e`
- [Legacy label conflicts when establishing new terminology standards in disassembly projects](common_pitfalls_experience/legacy-label-conflicts-when-establishing-new-terminology.md) — `46003d08-1036-4dcb-828e-89dbd0e17d77`
- [Misclassified .byte/.word data containing actual 6502 code](common_pitfalls_experience/misclassified-byte-word-data-containing-actual-6502-code.md) — `6f8810e2-7c27-4810-92e2-f16f4fbc14ea`
- [Misinterpreting extended data tables as unused gaps](common_pitfalls_experience/misinterpreting-extended-data-tables-as-unused-gaps.md) — `d79affb1-c2e1-4906-9c3f-c788d16a7f12`
- [Namco-163 bank register masking transformation pitfall](common_pitfalls_experience/namco-163-bank-register-masking-transformation-pitfall.md) — `d030bfe2-1b57-4cc9-8197-7a780cc28128`
- [Overlapping data regions require precise address calculation to avoid overflow](common_pitfalls_experience/overlapping-data-regions-require-precise-address-calculation.md) — `6aa6b1b3-651a-4dd1-826b-b7f4f4086d5f`
- [Pre-existing build failures in Sangokushi 2 disassembly project](common_pitfalls_experience/pre-existing-build-failures-in-sangokushi-2-disassembly-project.md) — `85563596-641a-4d9f-bb45-ff063c4777a5`
- [prg_08_09 DoDispatch drift fixed, structure refactored, harness added](common_pitfalls_experience/prg-08-09-dodispatch-drift-fixed-structure-refactored-harness-added.md) — `5a382388-8286-4674-b27e-928619328f34`
- [Python regex newline handling causes line-merging corruption](common_pitfalls_experience/python-regex-newline-handling-causes-line-merging-corruption.md) — `3bb55af7-04b7-425b-8e58-2f978f6d0982`
- [Removing redundant ROM jumps causes cascading byte-exact drift](common_pitfalls_experience/removing-redundant-rom-jumps-causes-cascading-byte-exact-drift.md) — `10e5ca89-783f-4209-8f8e-f91e18cc31f4`
- [SearchReplace JSON escape sequence pitfalls](common_pitfalls_experience/searchreplace-json-escape-sequence-pitfalls.md) — `484c373b-3e57-4703-8dbc-0b6dfc846521`
- [SearchReplace whitespace anchor requirements for assembly files with branch line padding](common_pitfalls_experience/searchreplace-whitespace-anchor-requirements-branch-line-padding.md) — `4ecf05ed-e8da-4a65-91bc-428e93b8350d`
- [Symbolic-reference conversion pitfalls: label drift, @-locals scope, byte-row duplication](common_pitfalls_experience/symbolic-reference-conversion-pitfalls.md) — `5e472fed-3b2d-4502-87a8-51a35c3c90b3`
- [Trailing literal backslash-dollar in line regex eats comment hex prefixes](common_pitfalls_experience/trailing-literal-backslash-dollar-in-line-regex-eats-comment-hex-prefixes.md) — `9b9da25f-3365-4df6-b430-e3274e52929e`
- [Trampoline target bank must be decoded from LDY, not caller context](common_pitfalls_experience/trampoline-target-bank-must-be-decoded-from-ldy-not-caller-context.md) — `e15f68f1-19d0-4fbf-99de-7d5a96cd3311`
- [Use tmp files for multi-line scripts in fish shell](common_pitfalls_experience/use-tmp-files-for-multi-line-scripts-in-fish-shell.md) — `c4d25361-82ef-4f13-a72d-5a6b6598732c`
- [Verification harness must exclude pseudo-disassembly lines from absolute-addressing transformation](common_pitfalls_experience/verification-harness-must-exclude-pseudo-disassembly-lines.md) — `3809c7df-61d0-4b0a-8f00-8fd824021ddb`
- [Wrapping functions in .proc requires consistent index space and size-filtered ROM gap recovery](common_pitfalls_experience/wrapping-functions-in-proc-requires-consistent-index-space.md) — `bc7b89c2-9422-4893-9268-f87de4a44cb2`

### development_code_specification (42)

- [$6F02 is the game level indicator selected at new game](development_code_specification/6f02-is-the-game-level-indicator-selected-at-new-game.md) — `e8f00569-616f-4180-b3a5-ace2c713dd41`
- [$6F8B is the strategy-engine request mailbox (game start flag / presentation request codes)](development_code_specification/6f8b-is-the-strategy-engine-request-mailbox.md) — `9a4a0ec1-d34e-40ec-b283-da40f38aef3b`
- [AiAction_DomesticTurn procedure end address constraint](development_code_specification/aiturndispatch-procedure-end-address-constraint.md) — `05ae9772-b452-487e-9fa9-5ef22d7c8148`
- [prg_0a_0b AI action step naming: AiActionChoose and AiAction_ steps](development_code_specification/prg-0a-0b-ai-action-step-naming.md) — `f2411ac0-c10a-40e1-868a-e12725a41a55`
- [Assembly @-prefix label style for local scope](development_code_specification/assembly-at-prefix-label-style-for-local-scope.md) — `5946082c-4eeb-4a9d-8bb4-0634867fd0b1`
- [Assembly procedure wrapping convention](development_code_specification/assembly-procedure-wrapping-convention.md) — `adf7ace8-ae0e-4faa-b3a7-7c11f54429ac`
- [Bank-1F cross-bank functions use B1F_* prefix convention in functions.h](development_code_specification/bank-1f-cross-bank-functions-use-b1f-prefix-convention-in-functions-h.md) — `17774e59-d0cf-4215-9b6a-214f90e38cb7`
- [Bank entry point label naming convention](development_code_specification/bank-entry-point-label-naming-convention.md) — `4226dbe7-a8e8-4ae7-9e0f-0e470f74545b`
- [Bank-local labels: @-prefix for nearby refs, bare globals for forward/cross-proc](development_code_specification/bank-local-labels-at-prefix-bare-globals.md) — `efe7d886-f473-4014-bbc5-a6782e89519e`
- [BankedCallbackTrampoline and CallbackDispatcher inline data patterns](development_code_specification/bankedcallbacktrampoline-and-callbackdispatcher-inline-data-patterns.md) — `35c6e1f5-5b7f-48bd-8017-240e2c393b51`
- [BankedCallbackTrampoline .word target naming uses functions.h cross-bank names](development_code_specification/bankedcallbacktrampoline-word-target-naming-uses-functions-h-cross-bank-names.md) — `e4cbc128-797a-49ed-abe9-05812d49edbf`
- [Battlefield Stratagem Naming in prg_0c_0d.asm](development_code_specification/battlefield-stratagem-naming-in-prg-0c-0d.md) — `b1c06a9d-faf8-4615-8225-6e71f48ffba0`
- [ca65 @-prefixed local labels must be placed inline at target instructions](development_code_specification/ca65-at-prefixed-local-labels-must-be-placed-inline.md) — `152208ab-78ea-4d78-937e-1fdb66ee91a1`
- [ca65 qualified references require leading :: for global scope from inside another proc](development_code_specification/ca65-qualified-references-require-leading-colons-for-global-scope.md) — `221f46d4-893c-4800-9b52-1f266e9c3574`
- [CallbackDispatcher naming consistency](development_code_specification/callbackdispatcher-naming-consistency.md) — `02772ee5-5b45-4a3e-b22f-e271f65740de`
- [Cross-bank equate naming convention BXX_YY_* in functions.h](development_code_specification/cross-bank-equate-naming-convention-bxx-yy-in-functions-h.md) — `f560f417-f4f3-44b6-a27f-09b566ae9fe2`
- [Data labeling and directive categorization with code verification](development_code_specification/data-labeling-and-directive-categorization-with-code-verification.md) — `3272bfa3-4e03-426a-8611-01bfefde8d5a`
- [Endproc directive lines must not carry inline address comments](development_code_specification/endproc-directive-lines-must-not-carry-inline-address-comments.md) — `3fcfd6b7-eeee-4f5f-8941-26bfe7f0e5a9`
- [Flat proc structure preference over nested procs](development_code_specification/flat-proc-structure-preference-over-nested-procs.md) — `b7d43d81-cc76-4873-bb18-a5866a41464d`
- [Hex byte comments for traceability](development_code_specification/hex-byte-comments-for-traceability.md) — `96f363e2-8630-4732-8ec5-5f18a5ba26ea`
- [Hex byte comments for .word and .byte](development_code_specification/hex-byte-comments-for-word-and-byte.md) — `b971416e-58dc-4ad2-bd7c-f30aa0472fe6`
- [Hexadecimal Notation with $ Prefix](development_code_specification/hexadecimal-notation-with-dollar-prefix.md) — `6d9a9d8f-2c9a-416e-ba53-d1ab289a2a26`
- [Jump table entry label naming: (FunctionName)_Entry](development_code_specification/jump-table-entry-label-naming-functionname-entry.md) — `ead63306-29b6-4c08-875f-1b3eaf9d9cd9`
- [Meaningful names for DomesticActionDispatch_04 sub-states](development_code_specification/meaningful-names-for-domesticactiondispatch-04-sub-states.md) — `89408a7a-d45a-49aa-8e6f-996d0974d1c3`
- [NmiDispatchTable uses 16-bit words](development_code_specification/nmidispatchtable-uses-16-bit-words.md) — `d958198c-0ebe-46e4-a20c-adf1cc8c0401`
- [OfficerExchangeDispatch procedure end address constraint](development_code_specification/officerexchangedispatch-procedure-end-address-constraint.md) — `26328ea0-ec84-40e4-8ae7-62d1098ed5f9`
- [PascalCase semantic English naming convention for procedures and constants](development_code_specification/pascalcase-semantic-english-naming-convention.md) — `5b851c94-fc49-4240-88da-03537515ef43`
- [.proc encapsulation for MapProvinceDirtyMark](development_code_specification/proc-encapsulation-for-mapprovincedirtymark.md) — `7bd22339-0e40-4596-a7f5-be279e9d87d5`
- [Replace .byte/.word data lines with disassembled code if they are actually code](development_code_specification/replace-byte-word-data-lines-with-disassembled-code.md) — `cd6e92bd-ff6c-4df9-a1e7-76b15cac841e`
- [Semantic naming convention for common exit routines](development_code_specification/semantic-naming-convention-for-common-exit-routines.md) — `f7908f5f-e89f-4545-9c52-e538e59546ca`
- [Semantic naming for control flow labels](development_code_specification/semantic-naming-for-control-flow-labels.md) — `6c354ee1-5f84-44fd-978e-871b64266810`
- [Semantic naming for data tables](development_code_specification/semantic-naming-for-data-tables.md) — `278ae8ac-1fb7-43c7-b056-1f2371e4c853`
- [Semantic naming for local labels applying computed indices](development_code_specification/semantic-naming-for-local-labels-applying-computed-indices.md) — `8b199117-fe91-4ca6-ba6c-17f3a4bfe511`
- [Semantic naming for local skip targets](development_code_specification/semantic-naming-for-local-skip-targets.md) — `304cd88e-df25-4d3f-b4e6-8b3d0cb62c8b`
- [Stratagem handler naming fully aligned with glossary in prg_0c_0d and prg_08_09](development_code_specification/stratagem-handler-naming-aligned-with-glossary.md) — `57f9a843-4c4e-40dd-8d18-3c85eb21cdf7`
- [Structured Binary Data Formatting](development_code_specification/structured-binary-data-formatting.md) — `225928fa-f1bd-4cbb-9f31-0cc379366c08`
- [Terminology.md as authoritative naming source with BXX_YY_* cross-bank convention](development_code_specification/terminology-md-as-authoritative-naming-source-with-bxx-yy-cross-bank-convention.md) — `46dc617a-7aa7-4883-8a0f-2c83a6940c50`
- [Trampoline label naming convention](development_code_specification/trampoline-label-naming-convention.md) — `9cbfca94-fe8c-4832-bacf-b333e2a8a78b`
- [Use semantic procedure names for core mechanisms](development_code_specification/use-semantic-procedure-names-for-core-mechanisms.md) — `0f9d5091-9e15-4bc0-a565-b6c154bd3ab7`
- [Use symbolic references in dispatch tables](development_code_specification/use-symbolic-references-in-dispatch-tables.md) — `142003aa-4e3d-4561-a1b3-63dd017878cf`
- [War* vs Battle* naming convention for tactical layer procedures](development_code_specification/war-vs-battle-naming-convention-for-tactical-layer-procedures.md) — `80566bf3-d55b-4563-bd1b-26dc60ae0da9`
- [.word for address storage](development_code_specification/word-for-address-storage.md) — `d1f4b610-0026-4505-8e81-f35b756f8100`

### development_comment_specification (4)

- [Assembly inline comment format with hex address primary segment](development_comment_specification/assembly-inline-comment-format-with-hex-address-primary-segment.md) — `997af872-d912-4600-8757-f87a047eb26c`
- [Code Comment Convention Requirement](development_comment_specification/code-comment-convention-requirement.md) — `800c9396-5ee1-4ca9-a931-3904c4218871`
- [Inline comment documentation for shared-exit label pattern](development_comment_specification/inline-comment-documentation-for-shared-exit-label-pattern.md) — `4aab0515-b6f0-4d7e-a8c5-f1955b65b333`
- [Mermaid diagram label quoting convention for special characters](development_comment_specification/mermaid-diagram-label-quoting-convention-for-special-characters.md) — `b8244c5e-d96a-42fe-9a7e-fd67d46229ff`

### development_practice_specification (25)

- [Apply Analysis Results to Source](development_practice_specification/apply-analysis-results-to-source.md) — `838ee8b2-0b70-40bd-9757-9b70f59d69ec`
- [Authoritative Code/Data Classification Source](development_practice_specification/authoritative-code-data-classification-source.md) — `f7317bbe-ddb6-4314-a6cd-bd3c3def7c71`
- [ca65 zp-vs-abs encoding drift and .proc scope cascade bugs](development_practice_specification/ca65-zp-vs-abs-encoding-drift-and-proc-scope-cascade-bugs.md) — `995b0af5-0532-41f3-abbe-764eba667b4c`
- [Code Analysis Workflow: Verify, Replace, Rename, Fix, Explain](development_practice_specification/code-analysis-workflow-verify-replace-rename-fix-explain.md) — `7bd13e28-816c-4786-bfd9-5f8f2ef8867d`
- [Cross-boundary instruction segmentation rule](development_practice_specification/cross-boundary-instruction-segmentation-rule.md) — `224b0070-4e6d-4e9a-ae5d-970137a154be`
- [Cross-scope .proc reference convention](development_practice_specification/cross-scope-proc-reference-convention.md) — `5cfeeffa-5533-4b91-9590-9458a5865381`
- [Handling instructions spanning bank boundaries](development_practice_specification/handling-instructions-spanning-bank-boundaries.md) — `6db8881f-0c6a-4f09-8c19-3293313bcf59`
- [Inline dispatch pattern: JSR followed by inline .word table](development_practice_specification/inline-dispatch-pattern-jsr-followed-by-inline-word-table.md) — `ad82a4de-9c42-480d-a44b-f14068540add`
- [Internal procedures must nest within parent proc except when crossing segment boundaries](development_practice_specification/internal-procedures-must-nest-within-parent-proc-except-when-crossing-segment-boundaries.md) — `dc124075-6732-4e9e-8ce1-53ebf6642883`
- [Mermaid diagram syntax validation via mermaid.ink renderer](development_practice_specification/mermaid-diagram-syntax-validation-via-mermaid-ink-renderer.md) — `0b6db7e6-b983-464e-ba2e-f7b98c9a40ad`
- [Nested functions and data encapsulation within AiAction_DomesticTurn](development_practice_specification/nested-functions-and-data-encapsulation-within-aiturndispatch.md) — `be85a01c-3b7e-4dc1-8f85-cdedebc02291`
- [Nested proc coverage by call-graph analysis](development_practice_specification/nested-proc-coverage-by-call-graph-analysis.md) — `146ccffb-3c2a-450e-aea1-7ab97f38b5c5`
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
- [Use symbolic proc names in dispatch tables](development_practice_specification/use-symbolic-proc-names-in-dispatch-tables.md) — `31420274-2c9f-4198-b01e-758cc16132f1`
- [Zero-page variables use proc-local naming](development_practice_specification/zero-page-variables-use-proc-local-naming.md) — `544e1c16-5e23-4f1b-8813-07107cf60655`

### history_task_reference_files (1)

- [Files modified for bank boundary JSR fix and segment configuration](history_task_reference_files/files-modified-for-bank-boundary-jsr-fix.md) — `d3360452-7481-43ff-867b-fa4b00408fcc`

### important_decision_experience (9)

- [AI routine misnomers: AiCheckAdvancedStratagem, AiPickStratagem, AiPickEnemyStratagem](important_decision_experience/ai-routine-misnomers-aicheckadvancedstratagem-aipickstratagem-aipickenemystratagem.md) — `f5b20474-b519-4a43-a378-5fac42bdef63`
- [Banks 00-07 remain .incbin data stubs, not disassembled](important_decision_experience/banks-00-07-remain-incbin-data-stubs-not-disassembled.md) — `3c6bf6c8-54bf-432d-918a-7fa038ba7182`
- [Cross-bank function rename scope boundary decision](important_decision_experience/cross-bank-function-rename-scope-boundary-decision.md) — `e4ea6a05-6fbe-44ac-9143-1183214af0f4`
- [Intra-Bank Label Naming Convention: Bare Names, Prefixes for Cross-Bank Only](important_decision_experience/intra-bank-label-naming-convention.md) — `6bc883a2-52a7-4a4f-b360-fd92b4413313`
- [Merge Two Entry Points into One Proc](important_decision_experience/merge-two-entry-points-into-one-proc.md) — `7e8c1abf-0930-4d2a-bde1-fd1d4fc150e4`
- [Procedure encapsulation decision for BattleResultSlotTemplateApply](important_decision_experience/procedure-encapsulation-decision-battle-result-slot-template-apply.md) — `a780f1d1-c291-45c3-bf1c-eac08209009c`
- [滚动面板行模板命名决策](important_decision_experience/scroll-panel-row-template-naming-decision.md) — `46188581-dfca-47cd-9ea6-e81696be52de`
- [Semantic distinction: war/tactical layer vs Battle Mode in prg_08_09.asm](important_decision_experience/semantic-distinction-war-tactical-vs-battle-mode.md) — `19852f62-c751-46c4-9bae-864f8f449149`
- [Semantic Routine Renaming Decision - SceneRenderer](important_decision_experience/semantic-routine-renaming-decision-scenerenderer.md) — `c0b6b2f7-6433-412a-96af-d86bc4031d82`

### project_architecture (25)

- [Bank file standalone scope for $A000-$DFFF operands](project_architecture/bank-file-standalone-scope-a000-dfff-operands.md) — `16a918fd-e1c7-4652-912e-59df71b5692d`
- [Banked callback trampoline Y=$3B targets bank 1B/1C $A003](project_architecture/banked-callback-trampoline-y-3b-bank-1b-1c.md) — `7b44d044-ae5e-4811-b616-3794c8a0cd0b`
- [BankedCallbackTrampoline target resolution via Y masking formula](project_architecture/bankedcallbacktrampoline-target-resolution-y-masking.md) — `9b1b7d85-37fb-49e8-9ae2-008f39d5eebe`
- [Battle bank RAM semantic map for prg_08_09.asm](project_architecture/battle-bank-ram-semantic-map-prg_08_09.md) — `0395917b-2ffa-4d7f-b791-8f162368af6e`
- [BattleResultSlotTemplateApply proc structure and padding layout](project_architecture/battle-result-slot-template-apply-padding.md) — `dc5643a0-aeea-4387-a2bd-64ec45f2db25`
- [BattleOverlayDispatch state machine structure and RAM semantics](project_architecture/battleoverlaydispatch-state-machine.md) — `12371e24-5423-42eb-afa6-d28d196e0524`
- [ca65 .proc internal label scoping and multi-entry exposure pattern](project_architecture/ca65-proc-internal-label-scoping-multi-entry-exposure.md) — `450f7fec-e851-45d3-bf70-951281650db0`
- [Castle development spend-based gain formula](project_architecture/castle-development-spend-based-gain-formula.md) — `85cc74ac-0af8-4fc3-a1c3-8f4327d0077c`
- [Combined PRG bank pair architecture and linker layout pattern](project_architecture/combined-prg-bank-pair-architecture.md) — `60dc689b-8ca3-492f-97c5-5fd3f34480a3`
- [Consolidated CPU RAM map document code/cpu_ram_map.md](project_architecture/consolidated-cpu-ram-map-document.md) — `8267d997-c17e-4543-b00c-879f80c1975d`
- [$6F02 is game level indexing recount scaling tables](project_architecture/game-level-6f02-recount-scaling-tables.md) — `48a19023-41a8-4262-ab3e-fb5a0871336f`
- [Mapper-19 $F800 WRAM write-protect register and SRAM save protocol](project_architecture/mapper-19-f800-wram-write-protect-register-sram-save-protocol.md) — `df508a07-3f28-4e5b-8578-e4045f9f2a76`
- [Memory retrieval system exposes 96 items vs 271 UI claims](project_architecture/memory-retrieval-system-96-items-vs-271-ui-claims.md) — `c6d69bf8-4afd-40c2-9986-727a62fcba9e`
- [Menu font CHR pages, display records, and verified serial kana name encoding](project_architecture/menu-font-chr-pages-and-kana-name-encoding.md) — `a7d5c77f-12d3-445b-ae11-67f4ba577abf`
- [Multi-alias RAM cells across game modes](project_architecture/multi-alias-ram-cells-across-game-modes.md) — `2f2ebd0f-9e56-4d4e-bdfe-02c34c1759c3`
- [NMI sub_state dispatch table mapping and NmiState5_Duel rename](project_architecture/nmi-sub-state-dispatch-table-nmistate5-duel.md) — `fae9d0a2-db6f-4ae9-be99-e458a384db77`
- [OAM DMA always copies from page $02 ($0200-$02FF)](project_architecture/oam-dma-always-copies-from-page-02.md) — `30fb855a-aba2-4cb2-904c-f9c91f65c4ee`
- [Officer record equipment byte layout and speed calculation semantics](project_architecture/officer-record-equipment-byte-layout-speed-calc.md) — `b81d7697-9306-4a9b-b787-760d29e3e597`
- [PRG bank 0F code/data region boundaries](project_architecture/prg-bank-0f-code-data-region-boundaries.md) — `bd70b98b-b1bc-441c-86c4-6b0d4dc503e4`
- [prg_0e_0f.asm RAM map: btl_ globals plus proc-local zero-page naming](project_architecture/prg_0e_0f-ram-map.md) — `2dd3b789-00bc-4521-9fb6-88310369000b`
- [Province record layout and AI action-to-castle-command mapping](project_architecture/province-record-layout-ai-action-castle-command-mapping.md) — `a58a7941-0f51-4d78-b65e-c5f1a6a7b486`
- [SramSaveCommit $BC02 decoded; mapper-19 WRAM write-protect register semantics](project_architecture/sramsavecommit-bc02-decoded-wram-write-protect.md) — `3c46cc3e-be50-449c-850d-b0c49109354f`
- [Terminology authority for war/tactical vs Battle Mode distinction](project_architecture/terminology-authority-war-tactical-vs-battle-mode.md) — `9af68d5e-65a6-47bb-9a01-81253ae34097`
- [Terminology.md as authoritative naming reference for game-domain vocabulary](project_architecture/terminology-md-authoritative-naming-reference.md) — `dc38da38-69da-4b22-aa66-96fec4957080`
- [Zero-page RAM map for frame state handlers and menu system](project_architecture/zero-page-ram-map-frame-state-handlers-menu-system.md) — `d4286e8b-b2a6-4cee-a62b-2268311b89ba`

### project_build_configuration (7)

- [Bank-pair verification workflow for prg_0e_0f.asm](project_build_configuration/bank-pair-verification-workflow-for-prg-0e-0f.md) — `99822cea-0f28-4eaa-98c5-5cdc85f47db8`
- [Bank verification tool pattern](project_build_configuration/bank-verification-tool-pattern.md) — `5d8d3378-5e67-4ccb-af26-adc519bacba5`
- [Global Definition of $04xx RAM Addresses](project_build_configuration/global-definition-of-04xx-ram-addresses.md) — `78ff8f7c-2a64-48e8-8ab0-21b1254d5c06`
- [Linker configuration for CODE_BANK1D and CODE_BANK1E](project_build_configuration/linker-configuration-for-code-bank1d-and-code-bank1e.md) — `6d4a300b-cf1c-47f3-b4b1-8ebdb55c2a63`
- [Makefile Build Configuration](project_build_configuration/makefile-build-configuration.md) — `17046208-039a-4b70-85d5-e4e494b99abc`
- [Per-bank verification harness and linker segment configuration](project_build_configuration/per-bank-verification-harness-and-linker-segment-configuration.md) — `c51e49b5-7f40-4bb0-9854-bb8ecda7705b`
- [PRG bank consolidation pattern and memory mapping](project_build_configuration/prg-bank-consolidation-pattern.md) — `adf08ad0-d19c-4a62-bd46-f57ccc237b68`

### project_environment_configuration (12)

- [Build and verification process with per-bank harness approach](project_environment_configuration/build-and-verification-process-with-per-bank-harness-approach.md) — `88c6bf8e-6e02-44d4-9598-f086599459a9`
- [Development Environment Setup](project_environment_configuration/development-environment-setup.md) — `e8b1791b-c4cc-47bd-9de6-e66ced7f9ffc`
- [Fish shell git commit message workaround with temp file](project_environment_configuration/fish-shell-git-commit-message-workaround-with-temp-file.md) — `f378d1e9-e1de-4689-970e-54c98b4d2e2b`
- [Git commands require proxychains prefix](project_environment_configuration/git-commands-require-proxychains-prefix.md) — `80b0077c-020b-44f5-9d2a-7c9ae7e16ac5`
- [Menu Data Regeneration and Pool Segmentation from Binary](project_environment_configuration/menu-data-regeneration-and-pool-segmentation-from-binary.md) — `185c8352-541a-44cf-9ead-bf7e8e47ad99`
- [MenuItemIndexPool Binary Source Requirement](project_environment_configuration/menuitemindexpool-binary-source-requirement.md) — `7528344f-03fa-4a5b-93e5-0bef5b8ae472`
- [OAM Sprite Data for Exchange Direction Arrow](project_environment_configuration/oam-sprite-data-for-exchange-direction-arrow.md) — `4c9b17d6-c17c-4462-8b9c-43fae383af41`
- [PRG bank $1D/$1E memory mapping](project_environment_configuration/prg-bank-1d-1e-memory-mapping.md) — `c730631f-c812-4386-9a85-e911d11ae0ef`
- [Symbolic label for $A3D2 in prg_0c_0d.asm](project_environment_configuration/symbolic-label-for-a3d2-in-prg-0c-0d.md) — `bffa21b1-2742-44d1-b026-aa1e465d6c64`
- [Utility scripts relocated to tools directory](project_environment_configuration/utility-scripts-relocated-to-tools-directory.md) — `7c338987-c4b5-4adc-8003-f061af371813`
- [WRAM $0400–$0500 Semantic Map for prg_0c_0d.asm](project_environment_configuration/wram-0400-0500-semantic-map-for-prg-0c-0d.md) — `4552979d-6963-471c-aa91-e7edb16b7d4d`
- [WRAM $0500–$05FF Semantic Map for prg_0c_0d.asm](project_environment_configuration/wram-0500-05ff-semantic-map-for-prg-0c-0d.md) — `e0c9c07a-326e-4183-b6da-5662ef0a9c8d`

### project_introduction (27)

- [AiCheckAttackNearby semantics in prg_08_09.asm](project_introduction/aicheckattacknearby-semantics-in-prg-08-09.md) — `6cf19bd2-ad96-4462-9580-c472b4452308`
- [AiCheckFaction duplicate at $CC92 in prg_09.bin](project_introduction/aicheckfaction-duplicate-at-cc92-in-prg-09-bin.md) — `5bbfdad5-f467-4385-a737-92f6de47ca56`
- [AiCheckFaction function semantics and duplicate](project_introduction/aicheckfaction-function-semantics-and-duplicate.md) — `9c859667-e792-48dc-a35c-880dfa4058f5`
- [AiOfficerActionDispatch state machine $C0BB-$C982 in prg_08_09.asm](project_introduction/aiofficeractiondispatch-state-machine.md) — `(ID not exposed by tooling; b228bd46 belongs to BattleStatusPanelDraw)`
- [AiTurnProcess single proc spans $A02D-$B12F in prg_08_09.asm](project_introduction/aiturnprocess-single-proc-spans-a02d-b12f.md) — `7643c9a3-f753-4d4c-b8d7-3843f5355226`
- [Battle block $B130-$BAB2 structure in prg_08_09.asm](project_introduction/battle-block-b130-bab2-structure.md) — `06a92df9-76c8-4444-affb-b8eab22304d1`
- [Battle scene CHR bank animation mechanism with 8-frame cycle](project_introduction/battle-scene-chr-bank-animation-mechanism.md) — `ed1df3b6-d69e-4b50-ae03-1a94230a0638`
- [Battlefield Stratagem System with Execution Logic and Terrain Mapping](project_introduction/battlefield-stratagem-system.md) — `b67a21ef-a281-4d51-9b3e-0e5e507a0b19`
- [BattleInputPromptDraw Functionality](project_introduction/battleinputpromptdraw-functionality.md) — `683d125e-49ee-4dce-8aae-9790b33082dd`
- [BattlePlayerRequestPoll and BattlePadStateFetch decoded in prg_0e_0f.asm](project_introduction/battleplayerrequestpoll-and-battlepadstatefetch-decoded.md) — `c30cb4ff-548d-4580-a923-08522dcd6d2a`
- [BattleStatusPanelDraw proc $CFA2-$D1EC structure in prg_08_09.asm](project_introduction/battlestatuspaneldraw-proc-structure.md) — `b228bd46-1933-4601-9ff5-2db4256e85f1`
- [CallbackDispatcher call sites in prg_08_09.asm](project_introduction/callbackdispatcher-call-sites-in-prg-08-09.md) — `ed0c00f9-1391-4914-ae2e-36fe90cd53d0`
- [Disassembly Procedure Spanning Non-Contiguous Entries](project_introduction/disassembly-procedure-spanning-non-contiguous-entries.md) — `46195d03-3209-446a-ba56-3140e857d1e3`
- [DrawStratagemTargetMarkers routine $D1ED-$D38F in prg_08_09.asm](project_introduction/drawstratagemtargetmarkers-routine.md) — `73456bfd-a8e7-4c3e-8ac6-1bc6cdb146d3`
- [Game manual knowledge base at docs/manual_kb](project_introduction/game-manual-knowledge-base-at-docs-manual-kb.md) — `b9ddbc81-d067-45b0-a7b2-66fdb624f8d3`
- [策略 translates to Intrigue, not diplomacy](project_introduction/intrigue-not-diplomacy-terminology.md) — `5ac01b16-612f-43af-b118-c8f399b3d47e`
- [Kana/digit char code map (serial gojuon) for officer name strings](project_introduction/kana-digit-char-code-map-serial-gojuon.md) — `08290e6b-ac11-42d0-abe3-37de8bc0ce46`
- [Loc_C983 battle casualty morale resolution data structures](project_introduction/loc_c983-battle-casualty-morale.md) — `124c4366-1c08-466e-ab0e-e107dfc4a570`
- [Nested game mode hierarchy: Strategy > Tactical > Battle > Duel](project_introduction/nested-game-mode-hierarchy.md) — `ec8408a5-4bd9-4f06-90e7-5ebca486eed2`
- [Officer 12-byte record field layout](project_introduction/officer-12-byte-record-field-layout.md) — `b55bc565-336a-48be-a2a2-a0f8d265aece`
- [OfficerSearchAndEvaluate merged proc at $C79A-$C914](project_introduction/officersearchandevaluate-merged-proc.md) — `e7e2e9d4-d47c-4d03-bd01-995943b83257`
- [Phase-8 stratagem row identities confirmed in prg_0e_0f.asm](project_introduction/phase-8-stratagem-row-identities-confirmed.md) — `35b1acb3-829e-435a-b27c-5e5ac00de748`
- [prg_17_18 is the DUEL module; MainGameDispatch->DuelModeDispatch, game_state->duel_state](project_introduction/prg_17_18-duel-module-duelmodedispatch.md) — `8847445d-de01-4ef6-b018-0505ae6cf897`
- [Project architecture and cross-bank calling convention](project_introduction/project-architecture-and-cross-bank-calling-convention.md) — `7f8e7f83-fc0f-4abb-a025-2ffa5f3f7431`
- [Ruler/Country/Province domain model and 城 City-vs-Castle rule](project_introduction/ruler-country-province-domain-model.md) — `755f31f8-4dff-46bc-ab2b-67d5c648daad`
- [Sound Engine Procedure Structure and Code Regions](project_introduction/sound-engine-procedure-structure-and-code-regions.md) — `4447e113-bc82-41cf-97f9-f10fca7acc23`
- [ValidateSpecialOfficer proc $D390-$D3ED structure in prg_08_09.asm](project_introduction/validatespecialofficer-proc-structure.md) — `a92c6d51-41d0-437d-b6e6-c1c1d12ef6c5`

### project_scm_configuration (5)

- [Build directory excluded from version control](project_scm_configuration/build-directory-excluded-from-version-control.md) — `30456f58-c2cc-47c4-9c9f-8cd8f6fd3c04`
- [Git HTTPS Authentication Configuration for GitHub](project_scm_configuration/git-https-authentication-configuration-for-github.md) — `3b1b1d27-bea0-424a-9536-2523cec9c697`
- [Git ignore rules for build artifacts and staging workflow](project_scm_configuration/git-ignore-rules-for-build-artifacts-and-staging-workflow.md) — `72e6eedc-750b-492f-b73b-6a9ac684055f`
- [Segment directive required at clean bank boundary in prg_0c_0d.asm](project_scm_configuration/segment-directive-required-at-clean-bank-boundary.md) — `64517df3-c8c5-41e1-ab15-bb9f0040c74d`
- [Segment split for JSR spanning $BFFF/$C000 in prg_1d_1e.asm](project_scm_configuration/segment-split-for-jsr-spanning-bfff-c000-in-prg-1d-1e.md) — `9e6a49b1-3716-465f-a6f0-47787ee14480`

### project_tech_stack (9)

- [Cross-proc entry points must be bare globals outside .proc scope](project_tech_stack/cross-proc-entry-points-must-be-bare-globals-outside-proc-scope.md) — `06871b5c-298a-4f40-be7a-d867fa93479e`
- [functions.h cross-bank naming uses BXX_YY_* with Y mask](project_tech_stack/functions-h-cross-bank-naming-uses-bxx-yy-with-y-mask.md) — `7c77ffe0-841c-4238-99d3-1747fd5e88a9`
- [Independent Proc Validation Rule](project_tech_stack/independent-proc-validation-rule.md) — `090d4481-e810-47b0-b454-f91b0eeac302`
- [Multi-entry procedure pattern with global inner label support](project_tech_stack/multi-entry-procedure-pattern-with-global-inner-label.md) — `80a3e948-1fbb-45bb-ac53-3a25304e5918`
- [Namco-163 PRG bank selection mechanism and shadow RAM layout](project_tech_stack/namco-163-prg-bank-selection-mechanism-and-shadow-ram-layout.md) — `e91259f9-c1d8-49e9-ae93-aca5e76597a3`
- [Namco-163 PRG bank selection uses 5-bit Y mask](project_tech_stack/namco-163-prg-bank-selection-uses-5-bit-y-mask.md) — `5e7ed971-4779-4e5d-9e44-b7017642ffcd`
- [NES Disassembly Tech Stack](project_tech_stack/nes-disassembly-tech-stack.md) — `818e598c-c9a3-4ae9-930c-a162db72ac2a`
- [$6F8B strategy-layer request mailbox protocol and handler flow](project_tech_stack/strategy-layer-request-mailbox-protocol.md) — `2a8ef781-f1d7-44f1-b69a-8e5f895e02e1`
- [.word directive for 16-bit threshold table](project_tech_stack/word-directive-for-16-bit-threshold-table.md) — `a577ab21-cda6-4753-84a9-1c51d6b977a3`

### task_summary_experience (152)

- [Action delta input poll decoded in prg_1b_1c.asm](task_summary_experience/action-delta-input-poll-decoded.md) — `c73e523a-f149-413b-8da5-eccf21dd732a`
- [ActionDeltaInputPoll $DA02 decoded in prg_1b_1c.asm](task_summary_experience/actiondeltainputpoll-da02-decoded.md) — `7eb5e623-15f5-440f-995a-33a2e0eb788a`
- [Add Section 7 for banks $08+$09 to functions.h with procedure definitions](task_summary_experience/add-section-7-functions-h-banks-08-09.md) — `ff8e9967-10d9-4078-a16b-cc632d4b1e12`
- [AI decision tree doc generated, Action_CaptureProvince renamed to Action_BuyRice, war_rice/war_gold semantics verified](task_summary_experience/ai-decision-tree-doc-action-buyrice.md) — `(ID not recorded)`
- [AI decision tree doc for AiTurnProcess generated](task_summary_experience/ai-decision-tree-doc-aiturnprocess.md) — `a9731985-6e54-4461-b935-3aa3d488b80e`
- [AiCheckFlee flee-gate semantics verified and renamed in prg_08_09](task_summary_experience/aicheckflee-flee-gate-semantics.md) — `fb7eddcb-cc48-4bcd-9278-046459c53ccc`
- [AiOfficerActionDispatch inline jump table fix and ROM verification](task_summary_experience/aiofficeractiondispatch-jump-table-fix.md) — `6439cb66-9d8d-49d7-8c09-0a95d1702fea`
- [ArmyCommandDispatch frame state 3 decoded in prg_1b_1c.asm ($ADF2-$B758)](task_summary_experience/armycommanddispatch-frame-state-3.md) — `acb52320-533c-45a4-983a-13a9d341043b`
- [AttractDemoDispatch Loc_A033 decoded in prg_19_1a.asm](task_summary_experience/attractdemodispatch-loc-a033-decoded.md) — `6619948b-7512-4ea2-b794-640a177c5db6`
- [AttractDemoDispatch sub-state style alignment fix](task_summary_experience/attractdemodispatch-style-alignment-fix.md) — `6cdb426b-4974-4ef9-bfe9-5e1924f34180`
- [Bank switch map rebuild with code/data classification and bank $00 verification](task_summary_experience/bank-switch-map-rebuild-code-data.md) — `506afd3c-2cae-406b-a277-db2a76e483b3`
- [bank_switch_map.md terminology correction: war/tactical vs Battle Mode](task_summary_experience/bank-switch-map-terminology-correction.md) — `c49e1d1f-5f37-4af8-a455-2712a7ad765f`
- [Bank-wide terminology alignment commit (battle→war) across PRG banks](task_summary_experience/bank-wide-terminology-commit.md) — `ae4821b4-d08d-4b50-af5a-183eeb2c86f9`
- [BankedCallbackTrampoline merge and magic number computation fix](task_summary_experience/bankedcallbacktrampoline-merge-magic-number-fix.md) — `27e3dfbe-f737-4153-94d5-fc0e9e34af96`
- [Battle AI decision tree doc generated for prg_0e_0f.asm](task_summary_experience/battle-ai-decision-tree-doc-prg_0e_0f.md) — `f09ad961-34b3-4bf3-b29e-f98698f82ed9`
- [Battle attrition round routine Loc_CD78 analysis and partial refactoring](task_summary_experience/battle-attrition-loc-cd78-partial-refactoring.md) — `88c793ab-fc66-4456-a241-0e72822038a9`
- [Battle casualty morale resolution routine Loc_C983 documentation](task_summary_experience/battle-casualty-loc-c983-documentation.md) — `5ee43417-9c99-47d5-a7a9-6de88e296ffd`
- [Battle cell redraw engine and animation queue decoded in prg_0e_0f.asm](task_summary_experience/battle-cell-redraw-animation-queue.md) — `cec87a17-957a-4c69-91dc-d451d4933d30`
- [Battle combat parameter setup routine decoded and renamed in prg_0e_0f.asm](task_summary_experience/battle-combat-parameter-setup.md) — `d3520820-aa79-4a5b-b2d4-c4a323769018`
- [Battle and duel mode AI decision PRG bank location analysis](task_summary_experience/battle-duel-ai-prg-bank-location.md) — `484d8de0-2bc6-4873-91e7-43cccc422fff`
- [Battle scene stub routines D57B/D66E/D6CD/D70F analysis and refactoring](task_summary_experience/battle-scene-stubs-d57b-d70f.md) — `7a36af46-759b-4c43-8af5-e7c7ecca5f4d`
- [Battle stratagem target marker routine analysis and refactoring at Loc_D1ED](task_summary_experience/battle-stratagem-target-marker-d1ed.md) — `21bfa07e-3b46-46cc-acc5-16df1ce56e41`
- [BattleAnimSoundEngine code analysis and refactoring with $DF6E boundary fix](task_summary_experience/battleanimsoundengine-analysis-refactoring-df6e.md) — `19342ee9-cf52-4a1c-b19f-b5ef1d42f0fb`
- [BattleAnimSoundEngine $DFB5 code/data boundary fix and semantic renaming](task_summary_experience/battleanimsoundengine-dfb5-boundary-fix.md) — `3942cb40-1af5-42bb-beaf-e4602aca68be`
- [BattleAttritionRound routine Loc_CD78 analysis and documentation](task_summary_experience/battleattritionround-loc-cd78-documentation.md) — `2946b252-e9ba-4b71-a4ad-f051b146cbff`
- [BattleCellRedraw block decoded in prg_0e_0f.asm ($B870-$BB8E)](task_summary_experience/battlecellredraw-block-decoded.md) — `4cfc8dce-2be9-453d-b837-1a729eeed8f0`
- [BattleInputPromptDraw decoded in prg_0e_0f.asm ($CCA8-$CCD8)](task_summary_experience/battleinputpromptdraw-decoded.md) — `81547581-8645-4e1f-8221-19ad1b8a2a9a`
- [BattleOverlayDispatch refactor in prg_0e_0f.asm ($A030-$A15E)](task_summary_experience/battleoverlaydispatch-refactor.md) — `69a27d3e-997f-433b-9509-ed05fe1ffcc1`
- [BattlePanelStatsRefresh decoded in prg_0e_0f.asm ($CBF1-$CCA7)](task_summary_experience/battlepanelstatsrefresh-decoded.md) — `f3df5ee1-2df9-42b2-83aa-1abe79c38a56`
- [BattleResultDispatch phase handlers and helpers fully decoded in prg_08_09.asm](task_summary_experience/battleresultdispatch-phase-handlers.md) — `bb23ee86-4c41-402f-921a-b39bd183500e`
- [BattleResultSlotTemplateApply proc encapsulation and padding update](task_summary_experience/battleresultslottemplateapply-encapsulation.md) — `5e1c7ba7-3fee-4712-a54a-51e71ee5941c`
- [BattleRosterSetup decoded in prg_0e_0f.asm ($B548-$B86F)](task_summary_experience/battlerosersetup-decoded.md) — `1517df63-01c2-4b22-808b-3c4c833005e4`
- [BattleSideCombatStatsInit decoded and renamed in prg_0e_0f.asm ($C926-$CA3E)](task_summary_experience/battlesidecombatstatsinit-decoded-renamed.md) — `cced9c1e-31a2-4202-8256-4117f13a60a7`
- [BattleSideStatusCounterDraw pointer table and digit stream decoding](task_summary_experience/battlesidestatuscounterdraw-pointer-table.md) — `925b2408-8ded-4225-b515-4caadb531de0`
- [BattleSideStatusCounterDraw stream table converted to .word and decoded in prg_0e_0f.asm](task_summary_experience/battlesidestatuscounterdraw-stream-table-word.md) — `522b5194-b713-4523-b0e9-245ede1b4574`
- [BuildCommandList routine Loc_D3EE analysis and refactoring](task_summary_experience/buildcommandlist-loc-d3ee.md) — `2777a6d8-26b8-4aec-a72d-012bd7f65d59`
- [CastleCommandDispatch (Loc_A295) castle screen decoded in prg_1b_1c.asm](task_summary_experience/castlecommanddispatch-decoded.md) — `e02a91fa-afe5-4560-abd0-4b3f59db834a`
- [Code Analysis Workflow execution on Loc_C983 battle casualty routine](task_summary_experience/code-analysis-workflow-loc-c983.md) — `8fc6c4f0-aedd-4334-b8f1-245d566e4821`
- [CommandCategoryMenuDispatch state 1 decoded in prg_1b_1c.asm](task_summary_experience/commandcategorymenudispatch-state-1.md) — `e4c997e5-9764-4505-83df-8483c9856bbc`
- [ConfirmDialogPoll confirm dialog decode and renaming in prg_1b_1c.asm](task_summary_experience/confirmdialogpoll-decode-renaming.md) — `8af9b572-5b08-4211-8156-c6268032b5d7`
- [ConfirmDialogPoll decoded and renamed at $D5BD in prg_1b_1c.asm](task_summary_experience/confirmdialogpoll-decoded-d5bd.md) — `91430639-fb40-4065-a027-4e1648ea6047`
- [Consolidated semantic English terminology glossary for Sangokushi 2 disassembly](task_summary_experience/consolidated-terminology-glossary.md) — `e9504a26-d39b-47ae-99a2-f8e0807ce836`
- [Corrected province "morale" field to Population and renamed AI actions](task_summary_experience/corrected-province-morale-field-to-population.md) — `6e387742-75e3-4052-a262-155c8c2f866b`
- [CountryControlToggle $CD8C code analysis and ROM fact verification](task_summary_experience/countrycontroltoggle-rom-verification.md) — `24536ffa-689d-48e0-a496-a6a99de32be2`
- [CPU RAM map consolidation for $0000-$7FF and $6000-$7FFF across all banks](task_summary_experience/cpu-ram-map-consolidation.md) — `db27d1a0-3486-41ed-8f9a-b43b8fa0f480`
- [Correcting cross-bank JSR references using context-aware symbol resolution](task_summary_experience/cross-bank-jsr-context-aware-resolution.md) — `8190fd89-feb7-40c5-a00e-a117f0cbf5ec`
- [DemoEventPlayback $A296-$C434: 28 procs, @-labels, byte-exact](task_summary_experience/demoeventplayback-28-procs.md) — `(ID not recorded)`
- [Document $6F02 game level in prg_19_1a.asm AttractDemoDispatch comments](task_summary_experience/document-6f02-game-level-attractdemo.md) — `75e9c14e-02dc-4969-b2ed-3b6c5a01d40c`
- [Duel mode persuade algorithm verification: no dedicated routine found, only stochastic roll](task_summary_experience/duel-persuade-algorithm-verification.md) — `(ID not recorded)`
- [Equipment catalog adds weight column from ROM table](task_summary_experience/equipment-catalog-weight-column.md) — `0feb9e64-aabd-48fe-81d9-4b17004cfa94`
- [ExchangeMarchCutscene decoded at prg_19_1a.asm $CFD6-$D7FE](task_summary_experience/exchangemarchcutscene-decoded-prg_19_1a.md) — `463e0571-eae2-458b-a732-fc8cfef7aeef`
- [Fix BankedCallbackTrampoline targets and raw address references in prg_08_09.asm](task_summary_experience/fix-bankedcallbacktrampoline-targets-prg-08-09.md) — `c32c72a8-b470-4291-8c36-dd114dbb3f89`
- [Fix ROM table fragmentation in disassembly](task_summary_experience/fix-rom-table-fragmentation.md) — `9c0c5344-7d0e-49a5-8d6f-0fbce4ef5d46`
- [Fix spanning JSR across bank boundary in 6502 assembly](task_summary_experience/fix-spanning-jsr-bank-boundary.md) — `dbd72b88-8a32-417e-8e9b-46fd03ff4f37`
- [Fixed Mermaid diagram parse errors in AI architecture documentation](task_summary_experience/fixed-mermaid-parse-errors-ai-arch.md) — `13f7cf07-65d1-4adc-baf5-33f6fcc5f06d`
- [FormationConfirmPromptDraw refactor: RTS at $C920 and named sprite record inside proc](task_summary_experience/formationconfirmpromptdraw-refactor.md) — `1715c8ad-ac93-42a2-8839-da8c47ba3926`
- [Frame state 9 handler and $6F8B strategy-layer mailbox protocol in prg_19_1a.asm](task_summary_experience/frame-state-9-mailbox-protocol-prg_19_1a.md) — `b31911c0-9db6-4a4e-ac60-999aec65b594`
- [Git commit of bank initialization work and linker layout updates](task_summary_experience/git-commit-bank-init-linker.md) — `34efae64-7145-4d56-8168-f95ff2134af0`
- [Git commit closing prg_0e_0f decoding and adding manual_kb knowledge base](task_summary_experience/git-commit-prg-0e-0f-decoding-manual-kb.md) — `eeb7dd3d-2516-4b90-8a0a-9c3ffb5f4eff`
- [HospitalWoundedRosterBuild decoded in prg_1b_1c.asm ($DC7C-$DCCF)](task_summary_experience/hospitalwoundedrosterbuild-decoded.md) — `38a33d37-c7ae-41d6-be1f-fda898ea8db7`
- [Initialize prg_0e_0f.asm combined PRG bank pair with byte-exact verification](task_summary_experience/init-prg-0e-0f-bank-pair.md) — `414cab10-0e8b-4e23-8d45-63be5efc9ac5`
- [Initialize prg_19_1a.asm combined PRG bank pair with byte-exact verification](task_summary_experience/init-prg-19-1a-bank-pair.md) — `1d31256e-473d-4cce-aba3-c0de0074d855`
- [Initialize prg_1b_1c.asm combined PRG bank pair with byte-exact verification](task_summary_experience/init-prg-1b-1c-bank-pair.md) — `7a911110-32c0-4954-aced-4444b00cdcee`
- [IntrigueCommandDispatch (frame state 6) decoded and renamed in prg_1b_1c.asm](task_summary_experience/intriguecommanddispatch-frame-state-6.md) — `6ca9ae95-a504-4443-87d7-3c27872c0073`
- [prg_0a_0b LevelActionModifiers split into 4 semantic tables, byte-neutral](task_summary_experience/levelactionmodifiers-split-4-tables.md) — `(ID not exposed by tooling; title-only availability)`
- [Loc_DB72 scout roll and math helpers decoded in prg_1b_1c.asm](task_summary_experience/loc-db72-scout-roll-math-helpers.md) — `489d8618-306d-43e2-b301-a4f629cf0e2a`
- [Loc_ label cleanup in prg_1b_1c.asm with semantic .proc conversion](task_summary_experience/loc-label-cleanup-prg-1b-1c.md) — `3bc8ce0e-df76-4ca8-8ae7-576bb3d7043a`
- [lo/hi immediate pointer symbolization in prg_19_1a and prg_1b_1c](task_summary_experience/lohi-immediate-pointer-symbolization.md) — `82fb6077-82bb-4b39-a1fd-1e6a513ed046`
- [Map camera scroll routines decoded and refactored in prg_19_1a.asm](task_summary_experience/map-camera-scroll-routines-decoded.md) — `0afe1f0d-e6a2-4868-b9ae-91c8e66817bf`
- [Map transition save/restore routines decoded and renamed in prg_1b_1c.asm](task_summary_experience/map-transition-save-restore-renamed.md) — `7a01f511-03ba-4ac1-a529-9f9771cb5331`
- [MapCameraScrollRepeat and MapProvinceUnderCamera decoded in prg_19_1a.asm](task_summary_experience/mapcamerascrollrepeat-decoded.md) — `49c5b7ee-95c9-45d1-9af5-9ba08971de92`
- [MapProvinceDirtyMark semantic renaming and .proc encapsulation](task_summary_experience/mapprovincedirtymark-renaming-proc-encapsulation.md) — `b7cd8d0f-92fa-4b60-9eb5-96e115676984`
- [MapRulerIntroInit decoded at Loc_A089 in prg_1b_1c.asm with zero drift](task_summary_experience/maprulerintroinit-decoded.md) — `4862bdec-6c63-41c1-8fb2-e272db0199cd`
- [MapScreenFrameUpdate decoded at Loc_A00C in prg_1b_1c.asm with zero byte drift](task_summary_experience/mapscreenframeupdate-decoded.md) — `c8a9f43e-e39f-44c3-a37e-c070d2ff9ff3`
- [MapScreenFrameUpdate procedure refactoring and cross-bank equate addition](task_summary_experience/mapscreenframeupdate-refactoring-cross-bank-equate.md) — `6e07e276-6f30-423d-a020-f68e02c1d759`
- [MapTransitionStateSave/Restore pair decoded at $D568 in prg_1b_1c.asm](task_summary_experience/maptransitionstatesave-restore-pair.md) — `e2d1cccc-c4ff-4850-913b-d8092622faef`
- [Memory dump task exporting 96 items to filesystem](task_summary_experience/memory-dump-task-exporting-96-items.md) — `45f397d4-7eec-4387-bd30-387459ef43a1`
- [MenuCursorReset $DD70 and hidden call sites decoded in prg_1b_1c.asm](task_summary_experience/menucursorreset-hidden-call-sites.md) — `ac3d2f9c-ffad-4abe-a3a8-f0d797791a25`
- [namcot163-disasm agent stale classification source fixed](task_summary_experience/namcot163-disasm-agent-stale-classification-fixed.md) — `b1183f78-3650-40a3-85ca-2e54251bba1a`
- [OfficerBattleExpLevelCheck decoded in prg_0e_0f.asm ($D7FB-$D8AF)](task_summary_experience/officerbattleexplevelcheck-decoded.md) — `198ff96f-cd83-4a59-8a17-c3c500b0f828`
- [OfficerCardAnimStep $B2D7 verified and entry stub renamed in prg_19_1a.asm](task_summary_experience/officercardanimstep-verified.md) — `4e945286-195f-4565-9715-011d08d23dae`
- [OfficerCardRender decoded and refactored in prg_19_1a.asm ($CE1F)](task_summary_experience/officercardrender-decoded.md) — `907d7832-3808-43fc-8551-1b9449f73517`
- [OfficerSelectDialogPoll dialog system decoded and renamed at $D64A in prg_1b_1c.asm](task_summary_experience/officerselectdialogpoll-decoded.md) — `a156380b-cc85-4c16-a16c-2cab7ad450b3`
- [OfficerStatusScene decoded and style-aligned in prg_19_1a.asm](task_summary_experience/officerstatusscene-decoded.md) — `ad84c284-2912-4608-9fd2-18ff2f86fea1`
- [Phase 1 AI-side refresh decoded in prg_0e_0f.asm ($D067-$D0AD)](task_summary_experience/phase-1-ai-side-refresh.md) — `a9d6c3a5-b2e1-4f08-b1bd-71773c1ca7c7`
- [Phase 1 next-actor selection handler decoded in prg_0e_0f.asm](task_summary_experience/phase-1-next-actor-selection.md) — `f9a88597-49d1-4a17-a157-f5cb753819a4`
- [Phase 2 attack arrow sprite routines decoded in prg_0e_0f.asm ($BE76-$BF4B)](task_summary_experience/phase-2-attack-arrow-sprite-routines.md) — `9d7047c3-aeae-4e28-ac28-b4380d1ee99c`
- [Phase 3 command-selection handlers decoded in prg_0e_0f.asm ($AA23-$ACC4)](task_summary_experience/phase-3-command-selection-handlers.md) — `c88fd950-e722-4ef1-a1fa-af2b1b2ee041`
- [Phase 4 battle-result handlers decoded in prg_0e_0f.asm ($A3BC-$A4F6)](task_summary_experience/phase-4-battle-result-handlers.md) — `77df66db-1683-4e73-8e77-0c00790057d2`
- [Phase 5 side event handler decoding in BattleOverlayDispatch](task_summary_experience/phase-5-side-event-handler.md) — `1a0ccb6b-8909-49df-9140-b01d21e28d00`
- [Phase 7 side B formation-select decoded in prg_0e_0f.asm ($CF67-$D066)](task_summary_experience/phase-7-side-b-formation-select.md) — `d773365a-01ae-413c-8570-8e81d19cf894`
- [Phase 8 point-spend panel decoded in prg_0e_0f.asm ($ACC5-$AEAD)](task_summary_experience/phase-8-point-spend-panel.md) — `1ae87289-b0eb-4e00-96ac-025446c6da58`
- [Phase-8 stratagem row semantic naming correction in prg_0e_0f.asm](task_summary_experience/phase-8-stratagem-row-naming.md) — `946210a8-3f48-4e16-9f27-019f148bcaf7`
- [Phase 9 formation-advance handler decoded in prg_0e_0f.asm ($B1EC-$B547)](task_summary_experience/phase-9-formation-advance-handler.md) — `279cd3f5-4bf7-49ab-a738-ae12a436461f`
- [Phase 2 move-route direction resolver Loc_C20F analysis and refactoring](task_summary_experience/phase2-move-route-resolver-loc-c20f.md) — `ebdf32d3-8333-4426-bb08-d3b9dfe986d6`
- [Phase 2 walk-direction resolver decoded in prg_0e_0f.asm ($C064-$C1CC)](task_summary_experience/phase2-walk-direction-resolver-decoded.md) — `043c27b2-f77c-479e-8ff8-85a7000b31f1`
- [Phase 2 walk-direction resolver Loc_C064 decoded and refactored](task_summary_experience/phase2-walk-direction-resolver-loc-c064.md) — `5067520a-d986-4a6b-9e7f-da3759de3df5`
- [Phase2AttackRouteResolve and terrain probes decoded in prg_0e_0f.asm ($C30F-$C826)](task_summary_experience/phase2attackrouteresolve-terrain-probes.md) — `289cb445-d94e-4c49-aea6-74294d2efb7c`
- [Phase2CursorArrowDraw decoded at Loc_BB8F in prg_0e_0f.asm](task_summary_experience/phase2cursorarrowdraw-loc-bb8f.md) — `3ec0b462-2008-4023-8170-a0b6fa87864e`
- [Phase3CommandMarkerRender decoded and refactored in prg_0e_0f.asm](task_summary_experience/phase3commandmarkerrender-decoded.md) — `9d87bac2-fbdd-4ceb-abed-2e5dafd9c50b`
- [PPUTileRender stream architecture decoding and menu font CHR analysis](task_summary_experience/pputilerender-stream-architecture-decoding.md) — `c108043b-ee0d-4db8-b148-c7478a4fa2f3`
- [PRG banks $08+$09 terminology alignment from battle to war](task_summary_experience/prg-08-09-terminology-alignment.md) — `f94b4639-c548-4081-a2df-3eb5f8d1438a`
- [prg_0a_0b.asm terminology alignment with glossary (zero byte drift)](task_summary_experience/prg-0a-0b-terminology-alignment.md) — `d846e577-483f-48bb-90e8-bb3bb567b162`
- [prg_0e_0f.asm initialization pipeline and verification](task_summary_experience/prg-0e-0f-init-pipeline.md) — `b457d9a6-d6f3-43f4-adbf-7bcad0ab4f0d`
- [prg_0e_0f.asm battle overlay decode commit with functions.h coverage](task_summary_experience/prg-0e-0f-overlay-decode-commit.md) — `0cdd053b-a60a-4416-bde3-6e2fd28ca4cd`
- [prg_0e_0f.asm RAM $0000-$07FF semantic naming and byte-exact verification](task_summary_experience/prg-0e-0f-ram-semantic-naming.md) — `5876869a-94ef-48fa-b870-ec1cc8eaed67`
- [prg_0e_0f.asm raw ROM address cleanup to reference names with zero drift](task_summary_experience/prg-0e-0f-raw-address-cleanup.md) — `d07e5b11-4521-402c-863d-fcd86efe65c5`
- [prg_0e_0f.asm terminology alignment with glossary and zero drift verification](task_summary_experience/prg-0e-0f-terminology-alignment.md) — `34909cdb-3836-4841-ac9e-9e10ceb2766e`
- [PRG bank 0F $DD5E-$DF6D data region misclassification fix](task_summary_experience/prg-0f-dd5e-df6d-data-fix.md) — `a7b2cd2c-fe96-4552-a6e5-be9f9f5662fb`
- [prg_17_18.asm bank-wide terminology alignment with glossary](task_summary_experience/prg-17-18-terminology-alignment.md) — `4a4f987f-b0e7-456e-b522-7f42a600b6bf`
- [prg_17_18 bank-wide terminology alignment and war-mode refactor workflow](task_summary_experience/prg-17-18-war-mode-refactor-workflow.md) — `3619ac53-465f-47c7-81ff-522f387b2f38`
- [prg_19_1a.asm Loc_ label cleanup: 99 labels semantically renamed, byte-exact](task_summary_experience/prg-19-1a-loc-label-cleanup-99.md) — `(ID not exposed by tooling; title-only availability)`
- [prg_19_1a.asm raw $A000-$FFFF address cleanup with byte-exact verification](task_summary_experience/prg-19-1a-raw-address-cleanup.md) — `10093019-46a4-45f9-91cf-bd34a592b65b`
- [prg_19_1a.asm BankedCallbackTrampoline annotation corrections and systematic pattern discovery](task_summary_experience/prg-19-1a-trampoline-annotation-corrections.md) — `3c8a5df9-bfb1-4710-a63c-b2434fff7f2c`
- [prg_19_1a.asm $B7D9-$BBDD war support module decoded and refactored](task_summary_experience/prg-19-1a-war-support-module.md) — `c66a0814-12e1-45cf-a966-0bf3c6df8800`
- [prg_1b_1c.asm raw direct-address symbolization pass](task_summary_experience/prg-1b-1c-raw-address-symbolization.md) — `c22aaff0-4f32-41a0-a842-78aa60674fbe`
- [prg_1d_1e.asm terminology alignment with zero byte drift](task_summary_experience/prg-1d-1e-terminology-alignment.md) — `4a3c66ce-c46d-40d0-b882-12bb72d1f56a`
- [Terminology update for prg_1f.asm with zero drift verification](task_summary_experience/prg-1f-terminology-update.md) — `d5166679-492b-40cb-95c1-742b8e50db92`
- [PRG bank switch linkage map in code/bank_switch_map.md](task_summary_experience/prg-bank-switch-linkage-map.md) — `dc33b0dc-30c3-4236-b28e-a196d4abfad5`
- [PRG bank switch linkage mapping for Sangokushi 2 disassembly](task_summary_experience/prg-bank-switch-linkage-mapping.md) — `81d60193-bb83-4819-a594-2a2f303ca9be`
- [PRG banks 0E-0F consolidation into combined disassembly](task_summary_experience/prg-banks-0e-0f-consolidation.md) — `0375438b-3ed4-40f2-bc46-dad3f5bcb7b2`
- [prg_08_09 DoDispatch hex drift fix and structure refactor](task_summary_experience/prg_08_09-dodispatch-hex-drift-fix.md) — `1b3f760e-30bd-4064-8af9-8a55d2a3a2c4`
- [prg_0e_0f.asm header summary and full B0E_0F_* functions.h coverage](task_summary_experience/prg_0e_0f-header-summary-functions-h.md) — `853d0558-56f4-43fb-83af-4fe35eacd504`
- [Proc enclosure pass for prg_1b_1c.asm outside-proc regions](task_summary_experience/proc-enclosure-pass-prg-1b-1c.md) — `1d64c5e3-078d-4a66-91bb-764b10ce2b8d`
- [ProvinceAdjacencyValidate and OverlayIdleCheck decoded in prg_1b_1c.asm ($DD79-$DDBE)](task_summary_experience/provinceadjacencyvalidate-overlayidlecheck.md) — `7a6db5f6-58e5-4b6a-9696-5720ba30d998`
- [ProvinceOfficerRosterDispatch $AFE5-$B7D8 decoded in prg_19_1a.asm](task_summary_experience/provinceofficerrosterdispatch-decoded.md) — `4972c108-dfa4-458c-ab4e-faecfd21c3fc`
- [ProvinceRulerIdGet/CountryRulerIdGet/OfficerCardShow decoded in prg_1b_1c.asm ($DD4F-$DD6F)](task_summary_experience/provinceruleridget-officercardshow.md) — `6347b92e-85e7-49a3-b3e7-10e29a45be07`
- [ProvinceZoneOriginGet decoded in prg_1b_1c.asm ($DF25-$DF34)](task_summary_experience/provincezoneoriginget-decoded.md) — `4105f816-b3cc-4949-afd3-e3b123a6d72d`
- [Re-apply AttractDemoDispatch decode and helpers after rollback](task_summary_experience/reapply-attractdemodispatch-after-rollback.md) — `5ae9bbdf-5bcb-4802-b828-8cbed1484b6e`
- [Remove obsolete PRG bank assembly files after consolidation](task_summary_experience/remove-obsolete-prg-bank-files.md) — `85259360-5563-413d-8208-00a3f88c8698`
- [Replace trampoline .word addresses with functions.h cross-bank names](task_summary_experience/replace-trampoline-word-addresses.md) — `fc24b67c-bdee-44f2-88ae-b93bb01402ce`
- [Residual coin flip naming cleanup after Phase-8 stratagem renaming](task_summary_experience/residual-coin-flip-cleanup.md) — `46cb8cd5-7f8a-43ce-8338-b7705367c1ed`
- [Revoke bank-pair initialization for prg_00_01.asm and restore stub configuration](task_summary_experience/revoke-prg-00-01-initialization.md) — `8946fb9a-717c-4a70-87c5-35258022261b`
- [Rollback recovery of MapProvinceDirtyMark changes in prg_19_1a.asm](task_summary_experience/rollback-recovery-mapprovincedirtymark.md) — `7ff9a326-65fb-4b46-9dc6-1fdd63d1032b`
- [ROM bank boundary fix for JSR at $BFFF and segment configuration](task_summary_experience/rom-bank-boundary-fix-bfff.md) — `e8cc8daa-4f51-46f4-a361-f57b07b75708`
- [Sangokushi 2 terminology update: Ruler/Country/Province model and game mode hierarchy](task_summary_experience/ruler-country-province-terminology.md) — `910a58e7-4f65-497a-94af-a9a17d33450a`
- [Sangokushi 2 menu font discovery: OfficerParamDisp chain and strategy menu CHR page mapping](task_summary_experience/sangokushi2-menu-font-discovery.md) — `22d34cfc-425d-4fab-90e2-6396da0bba15`
- [Scan for un-disassembled PRG banks using bank-switch call patterns](task_summary_experience/scan-undisassembled-prg-banks.md) — `68c836a6-6326-49a3-899f-2dcffb3c03a4`
- [Document shared-exit label pattern rationale in inline comments](task_summary_experience/shared-exit-label-pattern-documentation.md) — `961ab3bd-3077-44c3-8eb1-4d846b757fc8`
- [StrategyRequestDispatch $C773-$CD8B decoded in prg_19_1a.asm](task_summary_experience/strategyrequestdispatch-decoded.md) — `c9306e7c-6952-424c-93c1-f0b09beb8b62`
- [Symbolize $E000-$FFFF cross-bank calls to bank 1F; revert $A000-$DFFF .word targets targeting other banks](task_summary_experience/symbolize-bank-1f-calls-revert-word-targets.md) — `a772099f-31b8-46d1-a7c8-0f1f48d29509`
- [Symbolizing lo/hi immediate pointer constructions in prg_19_1a and prg_1b_1c](task_summary_experience/symbolizing-lohi-immediate-pointers.md) — `d1bb1d08-525a-4eaa-a713-a737b353fb49`
- [Town command/armory/rice extraction task summary](task_summary_experience/town-command-armory-rice-extraction.md) — `2e21315d-05e9-405e-ba40-d4a3eea1a49d`
- [Town command frame state handler decoding in prg_1b_1c.asm](task_summary_experience/town-command-frame-state-handler.md) — `fba40731-a120-4f15-8862-4589fa634375`
- [TownCommandDispatch state 5 decoded in prg_1b_1c.asm with zero drift](task_summary_experience/towncommanddispatch-state-5-decoded.md) — `624ae1a8-5934-4899-8829-15040abee243`
- [TownFacilityMenuLayoutSelect decoded in prg_1b_1c.asm ($DCD0-$DD24)](task_summary_experience/townfacilitymenulayoutselect-decoded.md) — `30202c11-e0f9-4739-a4ee-68b1d2b2d6aa`
- [UnificationEndingDispatch decoded and refactored in prg_19_1a.asm](task_summary_experience/unificationendingdispatch-decoded.md) — `ab8ca916-b38b-4994-8f32-a7037a1da54c`
- [Verified equipment weight speed calc and renamed StrategyMode_CalcEquipSpeed in prg_17_18.asm](task_summary_experience/verified-equip-speed-calcequipspeed.md) — `d490ea93-0eeb-4f07-b797-d1ceda5e2eb6`
- [war_side_strength lifecycle verification: Vitality snapshot with no re-sync to officer record](task_summary_experience/war-side-strength-lifecycle-verification.md) — `63c69309-d107-4238-b829-900951d6f73a`
- [WarehouseCommandDispatch label style conversion to @-locals](task_summary_experience/warehousecommanddispatch-label-style-conversion.md) — `b9f38de8-11e7-4eaf-bc51-bb61ed57bb57`
- [WarehouseCommandDispatch re-application with corrected naming after revert](task_summary_experience/warehousecommanddispatch-reapplication.md) — `37440d2a-5a97-477d-818f-92e6aa61f894`
- [WarehouseCommandDispatch state 4 decoded in prg_1b_1c.asm with zero drift](task_summary_experience/warehousecommanddispatch-state-4.md) — `479f891f-4114-47ad-8b62-725f507b5688`

### tool_experience (2)

- [ca65 cross-scope label references use Proc::Label, not Proc@Label](tool_experience/ca65-cross-scope-label-references-proc-label.md) — `b0f7349c-d42a-4a08-8975-474f436d923a`
- [File tools may report spurious save failures while applying edits](tool_experience/file-tools-may-report-spurious-save-failures-while-applying-edits.md) — `4b54d2e4-aa22-4363-962e-3e215b2968b1`

## Totals

- Categories: 14
- Memory files: 371

