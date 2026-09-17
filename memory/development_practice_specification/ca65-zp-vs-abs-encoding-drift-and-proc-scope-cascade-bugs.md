# ca65 zp-vs-abs encoding drift and .proc scope cascade bugs

- **Category:** development_practice_specification
- **Memory ID:** 995b0af5-0532-41f3-abbe-764eba667b4c
- **Keywords:** ca65, zp-vs-abs drift, forced-absolute prefix, .endproc fix, symbol cascade errors

## Content

When working with ca65 assembly for Sangokushi 2 disassembly, a latent bug class exists where plain zero-page equates (values <$0100) emit zeropage opcodes (85/A5/65/E5) but the ROM uses absolute addressing (8D/AD/6D/ED). The fix is to use forced-absolute `a:` prefix on all $00xx work-cell accesses (e.g., `LDA a:equip_weight` instead of `LDA equip_weight`). Additionally, unclosed `.proc` directives cause cascading undefined-symbol errors because subsequent labels become proc-local and forward references break. Always verify `.proc`/`.endproc` pairing when encountering multiple symbol errors in a bank.
