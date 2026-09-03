# Update code with analysis results

- **Category:** development_practice_specification
- **Memory ID:** 9526f7e9-cc42-4884-bd98-eb3b72c42936
- **Keywords:** analysis results, update code, apply changes, asm files, analysis documents
- **Usage scenarios:**
  - After completing code analysis, applying results to .asm files
  - When using subagent analysis output, ensuring code is updated
  - After creating analysis/plan markdown, syncing findings back to source code

## Content

When performing code analysis (semantic renaming, data label identification, comment improvement, proc boundary restructuring, etc.), always apply the analysis results to the actual assembly source files (.asm), not just to analysis markdown or plan documents. Analysis documents and plans are intermediate artifacts; the final deliverable is the updated code. Do not leave analysis as notes only — apply every renaming, comment, label, and structural improvement directly to the corresponding .asm file. This is especially relevant when using subagents or producing analysis plans: after receiving analysis output, immediately update the target .asm files with the findings.
