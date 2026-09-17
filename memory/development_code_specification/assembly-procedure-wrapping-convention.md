# Assembly procedure wrapping convention

- **Category:** development_code_specification
- **Memory ID:** adf7ace8-ae0e-4faa-b3a7-7c11f54429ac
- **Keywords:** assembly, .proc, inner labels, code encapsulation

## Content

Procedures in assembly are wrapped using `.proc` and `.endproc` directives when they encapsulate a self-contained state machine or function with no external references to internal labels. Sub-states are defined as inner labels (e.g., `Proc::Entry`) and the dispatch table uses bare inner names. Global entry stubs remain outside the proc if called externally (e.g., `JMP ProcName`).
