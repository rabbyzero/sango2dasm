# Bank verification tool pattern

- **Category:** project_build_configuration
- **Memory ID:** 5d8d3378-5e67-4ccb-af26-adc519bacba5
- **Keywords:** verification tools, bank initialization, linkage validation, Python scripts
- **Usage scenarios:**
  - When verifying newly disassembled banks match original ROM
  - When checking cross-bank call linkage integrity

## Content

The project uses Python verification tools in the tools/ directory to validate bank initialization and cross-bank linkage. Key tools include: init_XX_YY.py (initializes combined bank pairs), verify_XX_YY.py (verifies byte-exact matching with original binary), scan_bank_links.py (scans for cross-bank call patterns). Additional tmp_verify_*.py scripts are created for specific routine verification during disassembly work. These tools ensure that consolidated bank files maintain byte-exact correspondence with the original ROM binaries.
