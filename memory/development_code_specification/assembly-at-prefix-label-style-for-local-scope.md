# Assembly @-prefix label style for local scope

- **Category:** development_code_specification
- **Memory ID:** 5946082c-4eeb-4a9d-8bb4-0634867fd0b1
- **Keywords:** @-label style, local labels, naming convention, terminology alignment, assembly

## Content

Assembly procedure labeling convention: use @-prefix for local labels that are only referenced within the same procedure or dispatch table scope (e.g., sub-state handlers accessed only via inline .word table). Bare global names are reserved for cross-bank stubs (BXX_YY_* prefix) and external entry points. Naming must align with terminology.md for game-domain vocabulary (e.g., Town/町, Market/商店, Academy/学問所, Armory/武器屋) and 04-strategy-commands.md for command-specific semantics.
