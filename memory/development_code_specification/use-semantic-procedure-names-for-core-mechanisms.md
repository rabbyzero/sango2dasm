# Use semantic procedure names for core mechanisms

- **Category:** development_code_specification
- **Memory ID:** 0f9d5091-9e15-4bc0-a565-b6c154bd3ab7
- **Keywords:** semantic naming, procedure name, InlineDispatch, code refactoring

## Content

Procedures implementing core mechanisms like inline dispatch should be renamed from generic `Loc_xxxx` labels to meaningful `.proc` names (e.g., `.proc InlineDispatch`) that reflect their functional role. This improves code readability and maintainability by replacing address-based identifiers with semantic ones.
