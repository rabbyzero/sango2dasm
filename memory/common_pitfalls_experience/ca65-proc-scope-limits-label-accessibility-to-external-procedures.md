# ca65 .proc scope limits label accessibility to external procedures

- **Category:** common_pitfalls_experience
- **Memory ID:** 5f3e5fbc-df0c-4290-9450-4650f77c9e66
- **Keywords:** .proc scope, label accessibility, ca65, undefined symbols, shared subroutines
- **Usage scenarios:**
  - Assembly fails with undefined symbol despite label existing
  - Two procs need to share a subroutine
  - Local label referenced from outside proc

## Content

In 6502 assembly using ca65, labels defined inside a `.proc` are local to that procedure and cannot be accessed from outside. To allow shared access:
- Move commonly used subroutines (like `FindOfficerInRoster`) outside any `.proc` block
- Use standalone labels or define them in a shared utility section
- Ensure all jump/call targets are within scope or relocated appropriately
(Source: Bash with ca65 compiler errors)
