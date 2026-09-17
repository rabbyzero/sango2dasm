# Avoid f-strings in python3 -c under fish shell

- **Category:** common_pitfalls_experience
- **Memory ID:** a6d0ed15-b97d-44ff-ba13-c4d7e4e05f62
- **Keywords:** fish, f-string, Bash, python3 -c

## Content

Fish shell does not support Python f-string syntax (e.g., `${len(raw):X}`) when invoking Python via `python3 -c`. Use standalone `.py` scripts instead for complex string formatting. (Source: Bash)
