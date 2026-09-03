# Pre-commit build verification workflow in sango2dasm

- **Category:** development_practice_specification
- **Memory ID:** e671c0af-e420-406e-8d7d-e7e02b81dbf6
- **Keywords:** build verification, make, check_baseline.py, check_diff.py, git workflow, pre-commit checks
- **Usage scenarios:**
  - Before committing large refactors
  - When validating ROM integrity after changes
  - When setting up CI checks for NES ASM projects

## Content

In sango2dasm, recommended pre-commit verification includes running `make` to detect compilation/linker issues (e.g., duplicate symbols), followed by `python3 check_baseline.py` to compare against baseline ROM images, and `python3 check_diff.py` to inspect ROM drift. Although some projects may have pre-existing build errors unrelated to current changes, these steps help isolate regressions introduced by modifications. Git workflow: `git status`, `git diff --stat`, review key diffs, stage with `git add -A`, then commit with a concise yet descriptive message covering terminology changes, symbol updates, and new assets.
