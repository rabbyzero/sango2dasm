# Multi-alias RAM cells across game modes

- **Category:** project_architecture
- **Memory ID:** 2f2ebd0f-9e56-4d4e-bdfe-02c34c1759c3
- **Keywords:** multi-alias RAM, address reuse, game mode sharing, naming collision, symbolic equates

## Content

Multi-alias RAM cells in Sangokushi 2 disassembly: Certain addresses serve different purposes depending on the active game mode and must be explicitly documented to avoid naming conflicts. Key examples: $6F44 serves as battle_outcome_flag during battle scenes, province_field_3 during strategy layer, and player_swap flag during exchange mode. $042C-$042E function as menu_fmt_data0/1/2 for formatted number display in multiple contexts. $6F00-$6F06 is dual-use: during normal gameplay these hold game_level ($6F02) and player_id ($6F03), but during the attract demo they become scratch variables for demo year tick, rotation step, focused country slot, province count display, and camera-focus phase flag. When adding new symbolic names, always check if the address already has an existing alias in another mode before creating a new equate.
