# Git ignore rules for build artifacts and staging workflow

- **Category:** project_scm_configuration
- **Memory ID:** 72e6eedc-750b-492f-b73b-6a9ac684055f
- **Keywords:** gitignore, staging workflow, memory dump tracked, build artifacts, pycache exclusion

## Content

The project's .gitignore excludes build/, res/, *.nes, *.bin; object files must not be committed (the tracked asm/banks/prg_0a_0b.o was removed as cleanup). The memory/ directory (markdown dump of retrieved project memories plus README index) IS meant to be version-controlled — the user explicitly asked to include it in commits after it was initially left untracked. Still keep out of commits: tools/__pycache__/*.pyc and one-off tools/tmp_*.py scripts.
