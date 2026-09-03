# Merge Two Entry Points into One Proc

- **Category:** important_decision_experience
- **Memory ID:** 7e8c1abf-0930-4d2a-bde1-fd1d4fc150e4
- **Keywords:** assembly, entry point, proc merge, disassembly
- **Usage scenarios:**
  - Combining two assembly procedures that share code and entry points

## Content

## Decision Scenario
Combining two assembly procedures that share code and entry points under one `.proc` block

## Decision Content
- Merge `LoadOverlayPrimary` into `OverlayWindow` as a single procedure
- Keep both labels globally accessible within one `.proc` block
- Use inline comments to document entry point behaviors and shared outputs

## Applicable Scope
Assembly-level ROM disassembly projects where multiple entry points exist in shared code blocks
