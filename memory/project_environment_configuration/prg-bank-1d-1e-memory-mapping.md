# PRG bank $1D/$1E memory mapping

- **Category:** project_environment_configuration
- **Memory ID:** c730631f-c812-4386-9a85-e911d11ae0ef
- **Keywords:** PRG bank, $A000, $DFFF, memory map, Namco 163
- **Usage scenarios:**
  - Configuring linker segments for prg_1d_1e
  - Verifying bank address ranges

## Content

The combined PRG bank file `prg_1d_1e.asm` must map to memory range $A000-$DFFF, covering both original banks $1D ($A000-$BFFF) and $1E ($C000-$DFFF) in a single 16KB address space.
