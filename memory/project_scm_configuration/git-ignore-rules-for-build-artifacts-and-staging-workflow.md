# Git ignore rules for build artifacts and staging workflow

- **Category:** project_scm_configuration
- **Memory ID:** 72e6eedc-750b-492f-b73b-6a9ac684055f
- **Keywords:** .gitignore, build artifacts, object files, git staging
- **Usage scenarios:**
  - Excluding build artifacts from git commits
  - Staging changes before committing bank initialization work
  - Managing .o file exceptions in version control

## Content

The Sangokushi 2 disassembly project uses .gitignore to exclude the build/ directory (containing object files and temporary artifacts). Build artifacts (*.o files) should not be committed; precedent exists for accidental .o commits (e.g., asm/banks/prg_0a_0b.o) but best practice is to exclude them. The output/ directory contains raw disassembly files that are tracked, while build/ intermediate files are ignored. Git commit workflow requires staging changes explicitly and excluding build artifacts from the commit.
