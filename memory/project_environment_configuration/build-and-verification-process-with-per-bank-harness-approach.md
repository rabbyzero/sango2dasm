# Build and verification process with per-bank harness approach

- **Category:** project_environment_configuration
- **Memory ID:** 88c6bf8e-6e02-44d4-9598-f086599459a9
- **Keywords:** make, bank-pair verification, per-bank harness, byte-exact check, build process

## Content

The build environment uses Makefile for assembling PRG banks, but `make all` may fail due to pre-existing duplicate-symbol errors in certain banks. For byte-exact verification when full build is broken, use per-bank harness scripts (e.g., `tools/verify_0e_0f.py` for banks $0E+$0F) which assemble only the target banks and compare against ROM. Success is indicated by "compared N bytes, 0 mismatches". The project does not use a generic `verify_rom.py` script; verification is done via bank-specific Python harnesses that generate temporary linker configs and compare built binaries against rom/prg/*.bin files.
