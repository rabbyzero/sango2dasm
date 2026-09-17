# $6F8B is the strategy-engine request mailbox (game start flag / presentation request codes)

- **Category:** development_code_specification
- **Memory ID:** 9a4a0ec1-d34e-40ec-b283-da40f38aef3b
- **Keywords:** $6F8B, sram_game_start_flag, request mailbox, StrategyRequestDispatch, strategy engine handshake

## Content

$6F8B (sram_game_start_flag) is a cross-bank request mailbox between the strategy engine and the map screen, not just a game-start flag.
Game-start use (prg_0a_0b.asm B0A_CheckGameStart $A00F-$A042): BMI negative = no game; == $01 takes the new-game path (JSR Proc_D4CB, JMP Proc_A8D7).
Mailbox use: strategy banks write a presentation request then spin-wait; .proc StrategyRequestDispatch (prg_19_1a.asm $C773, map frame state 9) decodes it and acknowledges by writing the result code $040C back into $6F8B (RequestAckReturn $CD6F) or by writing $01 directly.
Codes and requesters: $01 = War phase (prg_0c_0d $A526; consumed by prg_08_09 WarClashResolve); $F8 = Province transfer needing a yes/no answer, requester prg_0a_0b $B786 waits for != $F8 then treats $00 as "do the swap"; $F9 = absorb sweep ($BD31, waits for $00); $FA = post-action Province sweep ($BB3B, waits for $00); $FB = Officer record deleted ($CA7A, waits for $01); $FC = Officer swapped into a record ($CB74, waits for $01); $FD = Country fully absorbed and $FE = defender still has forces (both ResolveCountryAbsorb $A8D1/$A8C1); $FF = turn/action-budget exhausted (prg_0a_0b $D147 @GameOver, prg_08_09 $A093/$BAAD). $00 = idle.
