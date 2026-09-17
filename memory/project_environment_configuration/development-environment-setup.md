# Development Environment Setup

- **Category:** project_environment_configuration
- **Memory ID:** e8b1791b-c4cc-47bd-9de6-e66ced7f9ffc
- **Keywords:** cc65, Python 3, original ROM, setup, startup command

## Content

Runtime Requirements:
- `cc65` installed (specifically `ca65`, `ld65`) — expected at `/home/zero/.local/bin/`
- `Python 3` — for custom scripts
- Original ROM: `Sangokushi 2 - Haou no Tairiku (J).nes`

Environment Setup:
1. Install cc65 to specified path or update `CC65_HOME`
2. Place original ROM in root directory
3. Run `make split` before disassembling

Startup Command: `make all` to build ROM
