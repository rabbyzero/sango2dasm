# Data labeling and directive categorization with code verification

- **Category:** development_code_specification
- **Memory ID:** 3272bfa3-4e03-426a-8611-01bfefde8d5a
- **Keywords:** data labeling, .word, .byte, .addr, data verification, code detection

## Content

Raw data blocks should be labeled with meaningful reference names and categorized using appropriate directives (.byte, .word, .addr) based on their logical function, size, and how they are accessed in code. **However, during analysis, every `.byte` and `.word` line must be verified to ensure it is genuinely data and not code encoded as raw bytes.** If a `.byte`/`.word` line is actually an instruction (branch, jump, load, etc.), replace it with the proper disassembled mnemonic. Only genuine data should remain as `.byte`/`.word` directives.
