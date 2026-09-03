# Officer 12-byte record field layout

- **Category:** project_introduction
- **Memory ID:** b55bc565-336a-48be-a2a2-a0f8d265aece
- **Keywords:** officer record, 12 bytes, HP, Power, Intelligence, Loyalty, Benevolence, $63C0
- **Usage scenarios:**
  - Analyzing or modifying officer data in SRAM or ROM bank $11
  - Understanding AI officer evaluation and training logic
  - Interpreting officer record byte offsets in disassembly code

## Content

The officer data record is 12 bytes per entry (SRAM base $63C0, ROM base $8000 in bank $11). This is NOT a KOEI game. Byte layout:
- Byte 0: HP (hit points)
- Byte 1: Power (used for military evaluation: Power/2 + Loyalty; summed for army totals)
- Byte 2: Intelligence/Wisdom (AI trains this; combined with Power for civil eval)
- Byte 3: Loyalty (dynamic; modified by ArmyValueCalc clamped [10,90]; AI boosts when <70, skips at 100)
- Byte 4: Benevolence (used by FindBestInCategory for category matching; input to ArmyValueCalc: Benevolence/10 + 70 - target_loyalty)
- Byte 5: unknown
- Bytes 6-7: Troops or exp
- Bytes 8-9: Troops or exp
- Byte 10: equipments?
- Byte 11: Status flags
