# Overlapping data regions require precise address calculation to avoid overflow

- **Category:** common_pitfalls_experience
- **Memory ID:** 6aa6b1b3-651a-4dd1-826b-b7f4f4086d5f
- **Keywords:** overlapping data, segment overflow, address calculation, data layout

## Content

Bug class: Overlapping data region misplacement causing segment overflow
Root cause: Placing the 8-byte wobble offset table at $B2F5 instead of $B2ED (where it overlaps with the tail of the 13-byte strip draw descriptor) caused an 8-byte insertion, resulting in a +7-byte CODE_BANK0E overflow (the descriptor head was 5 bytes, so 13-5=8, but only 7 were needed). The overlap is intentional: the SBC instruction at $B2C7 reads 8 entries from $B2ED ($B2ED-$B2F4), and the descriptor writer reads from $B2E8. The two regions share bytes $B2ED-$B2F4.
Fix pattern: Calculate overlapping regions by identifying which instructions access which addresses. For descriptor+wobble patterns, the descriptor starts at the base address, and the wobble table starts where the first data-accessing instruction references. Verify total size = max(descriptor_end, wobble_end) - base_address.
Reusable lesson: Don't place overlapping data regions at separate non-overlapping addresses because they cause segment overflow; instead calculate the true overlap boundary by tracing all instruction references to the region. Applies when refactoring inline data tables that serve multiple purposes (e.g., descriptor + lookup table); does not apply to non-overlapping sequential data blocks.
