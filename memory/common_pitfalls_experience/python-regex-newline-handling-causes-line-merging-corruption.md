# Python regex newline handling causes line-merging corruption

- **Category:** common_pitfalls_experience
- **Memory ID:** 3bb55af7-04b7-425b-8e58-2f978f6d0982
- **Keywords:** Python regex, newline handling, file transform, line merging bug

## Content

Bug class: File transform script corrupts line structure by dropping trailing newlines
Root cause: Python regex (.*)$ on a line read with trailing newline captures everything including the newline; when rebuilding lines as head + replacement + rest, the trailing newline is lost, merging the current line with the next line. This creates merged lines that break parsing and can cause byte-parity failures.
Fix pattern: When processing text files line-by-line in Python, always split each line into (body, newline) explicitly before applying regex substitutions; rebuild as body + newline after substitution. Never use (.*)$ to capture the entire line including newline.
Reusable lesson: Don't use (.*)$ regex patterns on lines read with trailing newlines because the captured group includes the newline and rebuilding loses it; instead split each line into (body, newline) pairs before substitution. Applies when writing Python scripts that modify assembly or source files line-by-line; does not apply to binary file operations or when using line-oriented APIs that preserve newlines automatically.
