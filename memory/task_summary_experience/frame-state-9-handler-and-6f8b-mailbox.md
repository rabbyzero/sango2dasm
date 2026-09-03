# Frame state 9 handler and $6F8B strategy-layer mailbox protocol in prg_19_1a.asm

- **Category:** task_summary_experience
- **Memory ID:** b31911c0-9db6-4a4e-ac60-999aec65b594
- **Keywords:** frame state 9, $6F8B mailbox, ResolveCountryAbsorb, banked callback dispatcher, inline dispatch table, MenuAction08, ArmyDeployDispatch, AI budget gates
- **Usage scenarios:**
  - Decoding map screen response to war/battle requests
  - Analyzing cross-bank SRAM communication patterns
  - Tracing army deployment trigger flow

## Content

Frame state 9 handler (prg_19_1a.asm $C773-$CD8B) is the map screen's response to strategy-layer requests via the $6F8B mailbox. The handler structure: LDA $0401 (sub-state) / JSR B1F_CallbackDispatcher / 16-entry .word table at $C779-$C79C.

$6F8B request codes and handlers:
- $FE (battle pending): Set by ResolveCountryAbsorb at prg_0a_0b:$A8C1 when defender has remaining forces. Handler: sub-state 4 ($C7E0) polls/idle; transitions to sub-state 5 ($C9D2) after menu closes; sub-state 6 ($CA42) triggers army deploy scene.
- $FD (fully absorbed): Set by ResolveCountryAbsorb at prg_0a_0b:$A8D3. Handler: sub-state 8 ($CA42) triggers army deploy.
- $FC: Set by ResolveCountryAbsorb at prg_0a_0b:$B788. Handler: sub-state 9 ($CA84).
- $FB: Set by prg_0a_0b:$BB3D. Handler: sub-states C/D ($CB7F/$CB9D) wait for $6F8B=$01 ack.
- $FA: Set by prg_0a_0b:$BD33. Handler: sub-state A ($CAD4).
- $F9: Set by prg_0a_0b:$BE3F. Handler: sub-state B ($CB2F).
- $F8: Set by ResolveCountryAbsorb at prg_0a_0b:$B788. Handler: sub-state E ($CB7F).
- $FF (turn complete): Set by battle banks $08/$09 at end of combat. Handler: sub-state F ($CBC3) increments turn counter $040C; after 32 turns returns to frame state 0.

Key RAM semantics:
- $0400 = scene_callback_id (map screen frame state)
- $0401 = scene_callback_st (sub-state)
- $040C = detail_cursor_x / step counter / turn counter
- $04A0 = menu_dispatch_flg (9 = MenuAction08_GoldDistribution/war declaration)
- $04D6 = menu_action_extra ($47 or $A2)
- $0038-$0043 = strategy-layer result parameters (province id, officer ids, flags)
- $0150 = palette mask / hemisphere scroll flag (computed from zone X origin bit7)
- $0140 = screen-transition busy flag ($80 = transitioning)
- $0300/$0304 = overlay slot sentinels ($FF = idle)
- $6F05 = SRAM game-state flag (clamped to >=1 if game in progress)
- $6F5B = iteration counter / AI budget source
- $6F5D = AI action budget ($6F05*10 max 130)
- $6F62 = global phase / per-officer active flag

Banked call targets:
- Bank $1D $A042 = BankedDataHandler (officer id in $0000, param in $000C)
- Bank $1D $A02A = OfficerDisplay_Lookup
- Bank $1B $A009 = JMP $DF25 (province zone origin lookup)
- Bank $0C $A003 = ExchangeScene_Init (army deploy trigger)
- Bank $1F $EE07 = BankedCallbackTrampoline (Y & $1F mask for target bank)
- Bank $1F $EADE = CallbackDispatcher
- Bank $1F $F368 = GetCountryDataPtr (country slot -> $00/$01 pointer)
- Bank $1F $EDF5 = PointerTableLookup (sprite write helper)
- Bank $1F $ED1E = MenuStep2
- Bank $1F $ECEE = PaletteCopyBuffer
- Bank $1F $F25F = SwitchBank8_B
- Bank $1F $F26D = SetUI0, $F28B = SetUI4

Inline dispatch pattern: JSR followed by .word table at fixed offset (e.g., $CBD6-$CBD8, $CC3C-$CC3F, $CC8F-$CC93). Tables must be recognized as code not data to avoid byte drift.

Entry points:
- $A006 JMP $C773 (frame state 9, human player turn)
- $A000 JMP $CE1F (OfficerCardRender, called with LDX #$00, $0000=officer id, $000A=$A7)
- $A003 JMP $C773 (frame state 9 variant)
- $A009 JMP $C773 (frame state 9 variant)
