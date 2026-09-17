# ca65 qualified references require leading :: for global scope from inside another proc

- **Category:** development_code_specification
- **Memory ID:** 221f46d4-893c-4800-9b52-1f266e9c3574
- **Keywords:** ca65, qualified references, Proc::Label, leading ::, scope resolution, global scope

## Content

In ca65 assembly, qualified label references using `Proc::Label` resolve only within the referencing scope's own scope chain. When a reference is made from inside one `.proc` block to a label defined inside another `.proc` block, the form `Inner::Helper` will fail even if `Inner` is a global symbol. To resolve a label from the global scope while inside another proc, the leading-global form `::Inner::Helper` must be used. Example: Inside `DirtyMarkAndCard`, the call `JSR MapProvinceDirtyMark::ByZone` fails; changing to `JSR ::MapProvinceDirtyMark::ByZone` succeeds. From file scope (global), unqualified `Proc::Label` works because file scope == global scope.
