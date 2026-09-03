# ca65 cross-scope label references use Proc::Label, not Proc@Label

- **Category:** tool_experience
- **Memory ID:** b0f7349c-d42a-4a08-8975-474f436d923a
- **Keywords:** ca65, scope separator, cheap local label, multi-entry procedure, cross-proc JSR
- **Usage scenarios:**
  - Calling or jumping to a label defined inside another .proc scope in ca65 assembly sources

## Content

## Usage Scenario
Calling or jumping to a label defined inside another .proc scope in ca65 assembly sources.

## Usage Method
Declare the inner entry label WITHOUT the @ prefix inside the .proc, then reference it from other scopes with the scope separator: `JSR ProcName::InnerLabel`. This works for multi-entry procedures whose inner entry is called externally.

## Notes
The `ProcName@InnerLabel` form causes a ca65 parse error ("Expected 'end-of-line' but found '@InnerLabel'") because @-prefixed cheap/local labels are only visible within their own scope. Verified with ca65 2.19-style toolchains: `Foo::Apply` compiles, `Foo@Apply` fails. If the inner label must serve as a shared exit for sibling procs, declare it as a bare global between .endproc and the next .proc instead.
