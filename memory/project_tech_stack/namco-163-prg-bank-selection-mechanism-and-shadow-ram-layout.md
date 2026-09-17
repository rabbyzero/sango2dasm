# Namco-163 PRG bank selection mechanism and shadow RAM layout

- **Category:** project_tech_stack
- **Memory ID:** e91259f9-c1d8-49e9-ae93-aca5e76597a3
- **Keywords:** Namco-163, PRG bank, bank selection, Shadow RAM, SwitchBank

## Content

The Sangokushi 2 NES disassembly uses the Namco-163 (Mapper 19) with 32 PRG banks (256KB total). Bank selection via Y register follows: effective_bank = Y & $1F (5-bit mask). SwitchBankAC_A/B writes to NAMCO_PRG_A000 ($E800) and NAMCO_PRG_C000 ($F000); SwitchBank8_A/B writes to NAMCO_PRG_8000 ($E000). Shadow RAM addresses: slot A uses $00DE-$00E0 ($8000/$A000/$C000), slot B uses $00E1-$00E3. BankedCallbackTrampoline at $EE07 performs save-switch-call-restore cycle using slot B. All cross-bank function references in functions.h use BXX_YY_* naming where XX = Y & $1F.
