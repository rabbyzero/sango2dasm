# Fixed Mermaid diagram parse errors in AI architecture documentation

- **Category:** task_summary_experience
- **Memory ID:** 13f7cf07-65d1-4adc-baf5-33f6fcc5f06d
- **Keywords:** Mermaid, diagram syntax, parse error, special characters, quoting labels

## Content

## Task description
- Core requirement: Fix Mermaid diagram parse errors in the AI architecture documentation for prg_0a_0b.asm.
- Task background: The file code/strategy_ai_decision_tree.md (written at the time as code/prg_0a_0b_ai_architecture.md) contained four Mermaid diagrams describing the AiTurnDispatch state machine and project structure. Diagrams failed to render due to unquoted special characters (`@`, `&`, `;`, `<`, `>=`) in node labels, edge labels, and subgraph titles.

## Execution process
1. Diagnosed root cause: Mermaid parser rejected raw special characters in labels (e.g., `subgraph SEL[@AiActionSelect $B5FC]` with leading `@`).
2. Applied systematic fix: Rewrote all four diagram blocks to quote every node label, diamond condition, edge label, and subgraph title as literal strings.
3. Verified syntax: Created a Python script using requests library to send each block to mermaid.ink/img endpoint with a browser User-Agent header; all 4 blocks returned HTTP 200 OK (rendered images), confirming valid syntax.

## Related files
- /home/zero/project/sango2dasm/code/strategy_ai_decision_tree.md (then code/prg_0a_0b_ai_architecture.md)
- /home/zero/project/sango2dasm/tmp_check_mermaid.py (created for validation, then deleted)

## Notes
- Initial attempts to use npx mermaid-cli were skipped due to heavy dependencies (puppeteer/chromium).
- First mermaid.ink validation attempt failed with HTTP 403 due to missing User-Agent; retry with proper headers succeeded.
- Avoided copying raw error messages into documentation; distilled into structured fix description.

## Task overview
Completed: All four Mermaid diagrams now parse successfully. The fix ensures robust rendering by quoting all special characters and using literal string labels throughout the diagrams.
