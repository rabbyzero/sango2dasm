# Use tmp files for multi-line scripts in fish shell

- **Category:** common_pitfalls_experience
- **Memory ID:** c4d25361-82ef-4f13-a72d-5a6b6598732c
- **Keywords:** fish, shell, multi-line, tmp file, inline execution, python, script
- **Usage scenarios:**
  - Running multi-line Python scripts via Bash tool
  - Executing multi-line shell commands
  - Processing complex inline scripts with special characters

## Content

Fish shell has non-standard inline execution semantics. When running multi-line Python or shell script commands, write the script to a temporary file (e.g., /tmp/tmp_xxx.py) and then execute it, rather than using heredocs or inline multi-line strings. This avoids fish-specific parsing issues with quotes, braces, dollar signs, and other special characters. Single-line commands are generally fine.
