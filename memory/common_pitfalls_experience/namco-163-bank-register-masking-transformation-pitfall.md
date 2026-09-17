# Namco-163 bank register masking transformation pitfall

- **Category:** common_pitfalls_experience
- **Memory ID:** d030bfe2-1b57-4cc9-8197-7a780cc28128
- **Keywords:** Namco-163, bank register, ROM offset, mapper addressing, NES disassembly

## Content

Bug class: Namco-163 PRG bank register value misinterpretation causing incorrect ROM offset calculation

Root cause: For Namco-163, the PRG bank register at $E000 uses bits D4-D0 (masked with $3F). Register value $30 & $3F = $30, but physical bank index is ($30 >> 1) = $18 due to 4KB sub-bank addressing in the mapper. Using the raw register value directly as file offset causes off-by-one bank errors.

Fix pattern: Always apply mask ($value & $3F) then shift right by 1 bit to get physical bank index; multiply by 8KB (0x2000) to get combined ROM file offset.

Reusable lesson: Don't use Namco-163 PRG register values directly as file offsets because the mapper's 4KB sub-bank addressing requires masking and shifting; instead apply ($value & $3F) >> 1 to get physical bank index. Applies when mapping Namco-163 bank registers to PRG ROM files in NES disassembly; does not apply to other mappers like Nintendo MMC1 which use direct bank numbers.
