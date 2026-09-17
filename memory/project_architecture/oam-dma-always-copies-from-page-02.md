# OAM DMA always copies from page $02 ($0200-$02FF)

- **Category:** project_architecture
- **Memory ID:** 30fb855a-aba2-4cb2-904c-f9c91f65c4ee
- **Keywords:** OAM DMA, page $02, sprite buffer, APU $4014, NES hardware

## Content

OAM DMA source page invariant: The NES APU OAM DMA register at $4014 always copies 256 bytes from page $02 ($0200-$02FF). Verified in prg_1f.asm line 3597 where LDA #$02 loads A=$02 before STA $4014 triggers the DMA transfer. This makes $0200-$02FF the global OAM shadow buffer used by all game modes; no other page can be used as the DMA source. All banks must respect this constraint when allocating sprite buffers.
