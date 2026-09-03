# OfficerSearchAndEvaluate merged proc at $C79A-$C914

- **Category:** project_introduction
- **Memory ID:** e7e2e9d4-d47c-4d03-bd01-995943b83257
- **Keywords:** OfficerSearchAndEvaluate, merged proc, $C79A, prg_0a_0b, AiRecruit, SwapOfficerSlots
- **Usage scenarios:**
  - Editing or analyzing the officer search/recruitment/swap code in prg_0a_0b.asm
  - Understanding the control flow between fill-slots, validate, eligibility check, and swap logic
  - Debugging stack issues in the AI recruitment path

## Content

The 7 procs at $C79A-$C914 in prg_0a_0b.asm (OfficerSearchAndEvaluate, AiRecruit_FillSlots, AiRecruit_ValidateAndMark, CheckOfficerEligibility, AiTransfer_FillSlots, AiTransfer_ValidateAndMark, SwapOfficerSlots) were merged into a single `.proc OfficerSearchAndEvaluate` with local @labels (@FillSlots, @ValidateAndMark, @CheckEligibility, @TransferFillSlots, @TransferValidate, @SwapSlots). Stack unwinding PLAs were removed since inter-section calls use JMP instead of JSR. Only OfficerSearchAndEvaluate remains as .global.
