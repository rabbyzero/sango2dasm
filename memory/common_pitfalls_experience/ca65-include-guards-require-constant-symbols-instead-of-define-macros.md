# ca65 include guards require constant symbols instead of .define macros

- **Category:** common_pitfalls_experience
- **Memory ID:** 01472f7d-3db6-40bc-a796-e54e4e4e339a
- **Keywords:** include guard, constant symbol, ca65, duplicate symbols, .ifndef

## Content

In ca65, `.define NAME` creates a macro, not a symbol — `.ifndef NAME` cannot see it, so the classic `.ifndef GUARD / .define GUARD` include guard silently fails and headers get processed twice (duplicate-symbol errors). Must use a plain constant instead: `.ifndef GUARD_X / GUARD_X = 1 / ... / .endif`. This applies to all ca65 include guards.
