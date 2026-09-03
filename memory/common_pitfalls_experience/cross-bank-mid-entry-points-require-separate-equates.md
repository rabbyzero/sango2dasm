# Cross-bank mid-entry points require separate equates to avoid incorrect address encoding

- **Category:** common_pitfalls_experience
- **Memory ID:** b15e085d-8da0-4fbb-89f9-bdae9eee4f45
- **Keywords:** cross-bank reference, mid-entry point, equates, sprite OAM writer, banked callbacks
- **Usage scenarios:**
  - When implementing cross-bank references for procedures with multiple entry points
  - When debugging incorrect JSR/JMP byte encoding in banked callback systems

## Content

Bug class: Cross-bank mid-entry points encoded incorrectly when using main procedure label as equate
Root cause: When a procedure has multiple entry points (e.g., SpriteOamWriterScroll at $F092 with mid-entry at $F09C), defining an equate like `B1F_SpriteOamWriterScroll = $F09C` and calling it via `JSR B1F_SpriteOamWriterScroll` causes ca65 to assemble the wrong bytes (`20 92 F0` instead of `20 9C F0`) because the equate is just a numeric constant, not a label. The assembler uses the value for the operand but doesn't know which address was intended if there's ambiguity. In the Sangokushi 2 project, all B1F_ symbols are equates in functions.h, so the call site must explicitly use the correct equate name for the desired entry point.
Fix pattern: Create separate equates for each mid-entry point with distinct names (e.g., `B1F_SpriteOamWriterScroll_NoInit = $F09C`) and update all call sites to use the specific equate matching the intended entry point. Do not rely on the main procedure label or assume a single equate covers all entry points.
Reusable lesson: Don't use a single equate for procedures with multiple entry points because the assembler will encode the wrong address; instead, create distinct equates for each entry point with descriptive suffixes (_NoInit, _Alt, etc.) and update all call sites to use the appropriate equate. Applies when working with banked callback systems that have mid-procedure entry points; does not apply to procedures with only a single entry point.
