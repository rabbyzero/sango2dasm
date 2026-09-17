# Mermaid diagram label quoting convention for special characters

- **Category:** development_comment_specification
- **Memory ID:** b8244c5e-d96a-42fe-9a7e-fd67d46229ff
- **Keywords:** Mermaid, diagram syntax, quoting labels, special characters

## Content

Mermaid diagrams require all labels (node labels, diamond conditions, edge labels, and subgraph titles) to be quoted as literal strings to safely handle special characters such as @, &, ;, <, >, :, ==, and (. Unquoted special characters cause parse errors in the Mermaid renderer.
