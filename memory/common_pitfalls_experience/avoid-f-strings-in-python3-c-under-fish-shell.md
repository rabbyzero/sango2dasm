# Avoid f-strings in python3 -c under fish shell

- **Category:** common_pitfalls_experience
- **Memory ID:** a6d0ed15-b97d-44ff-ba13-c4d7e4e05f62
- **Keywords:** fish, f-string, Bash, python3 -c
- **Usage scenarios:**
  - Running inline Python commands in fish shell fails with 'fish: ${ is not a valid variable'
  - Debugging shell command failures where Python code contains f-strings

## Content

Fish shell does not support Python f-string syntax (e.g., `${len(raw):X}`) when invoking Python via `python3 -c`. Use standalone `.py` scripts instead for complex string formatting. (Source: Bash)
