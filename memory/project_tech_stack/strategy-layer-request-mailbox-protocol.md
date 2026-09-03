# $6F8B strategy-layer request mailbox protocol and handler flow

- **Category:** project_tech_stack
- **Memory ID:** 2a8ef781-f1d7-44f1-b69a-8e5f895e02e1
- **Keywords:** $6F8B mailbox, cross-bank SRAM communication, request/ack handshake, ResolveCountryAbsorb, frame state 9, strategy layer, map screen
- **Usage scenarios:**
  - Tracing war/battle trigger from strategy to map screen
  - Decoding cross-bank SRAM communication patterns
  - Analyzing request/ack handshake protocols

## Content

The $6F8B SRAM byte serves as a strategy-layer to map-screen request mailbox. Strategy banks ($0A/$0B) set $6F8B to a request code; map screen frame state 9 (banks $19/$1A) polls $6F8B and executes corresponding handlers via sub-state machine at $C773-$CD8B.

Request codes and sources:
- $FE: ResolveCountryAbsorb @prg_0a_0b:$A8C1 (battle pending, defender has forces)
- $FD: ResolveCountryAbsorb @prg_0a_0b:$A8D3 (fully absorbed)
- $FC: ResolveCountryAbsorb @prg_0a_0b:$B788 (absorption result)
- $FB: prg_0a_0b:$BB3D (strategy action request)
- $FA: prg_0a_0b:$BD33 (strategy action request)
- $F9: prg_0a_0b:$BE3F (strategy action request)
- $F8: ResolveCountryAbsorb @prg_0a_0b:$B788 (absorption variant)
- $FF: Battle banks $08/$09 (turn complete, battle resolved)

Ack mechanism: For requests $FB/$FC, strategy bank spins-waits checking $6F8B == $01. Map screen handler sets $6F8B = $01 after completing the requested action (sub-states C/D).

Zero-page parameter passing: Requesters set $0038-$0043 before setting $6F8B. Handler reads these for context:
- $0038 = province id / officer id
- $003A = province index
- $003D = officer id for card display
- $0040-$0043 = additional result parameters

Cross-bank function calls use BankedCallbackTrampoline ($EE07) with Y & $1F mask. Target addresses stored inline after JSR as .word. Common targets:
- Bank $1D $A042 = BankedDataHandler (officer data setup)
- Bank $1D $A02A = OfficerDisplay_Lookup
- Bank $1B $A009 = Province zone origin lookup
- Bank $0C $A003 = ExchangeScene_Init (army deploy)
- Bank $1F $EADE = CallbackDispatcher
- Bank $1F $F368 = GetCountryDataPtr

Menu integration: Setting $04A0 = 9 triggers MenuAction08_GoldDistribution (war declaration screen) with extra param $04D6 = $47 or $A2. Menu closes when $04A0 | $0140 == 0 ($0140 = transition busy flag).
