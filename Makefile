# Makefile for Sangokushi 2 - Haou no Tairiku Disassembly
# Namco-163 (Mapper 19)
#
# Requires: cc65 (ca65, ld65), Python 3
# ca65 installed to: /home/zero/.local/bin/

# Toolchain
CC65_HOME := /home/zero/.local
CA65 := $(CC65_HOME)/bin/ca65
LD65 := $(CC65_HOME)/bin/ld65

# Directories
BUILD_DIR := build
ASM_DIR := asm
INC_DIR := include
ROM_DIR := rom

# Source files
ASM_SOURCES := $(ASM_DIR)/main.asm
BANK_SOURCES := $(wildcard $(ASM_DIR)/banks/*.asm)
ASM_INCLUDE := $(INC_DIR)/6502_registers.h $(INC_DIR)/namco163.h $(INC_DIR)/macros.h $(INC_DIR)/functions.h

# Output
PRG_BIN := $(BUILD_DIR)/prg.bin
OUTPUT := $(BUILD_DIR)/sango2.nes

# Flags
CA65_FLAGS := -I $(INC_DIR) -I $(ASM_DIR)/banks -l $(BUILD_DIR)/main.lst
LD65_FLAGS := -C linker.cfg -m $(BUILD_DIR)/map.txt

# Default target
all: $(OUTPUT)
	@echo "Build complete: $(OUTPUT)"
	@ls -lh $(OUTPUT)
	@echo "ROM header:"
	@xxd -l 16 $(OUTPUT)

# Build PRG binary from assembly
$(PRG_BIN): $(ASM_SOURCES) $(BANK_SOURCES) $(ASM_INCLUDE) linker.cfg
	@mkdir -p $(BUILD_DIR)
	@echo "Assembling..."
	$(CA65) $(CA65_FLAGS) $(ASM_SOURCES) -o $(BUILD_DIR)/main.o
	@echo "Linking..."
	$(LD65) $(LD65_FLAGS) $(BUILD_DIR)/main.o -o $(BUILD_DIR)/prg_link.out
	@echo "Concatenating banks..."
	@cat $(BUILD_DIR)/bank00.bin $(BUILD_DIR)/bank01.bin $(BUILD_DIR)/bank02.bin \
	    $(BUILD_DIR)/bank03.bin $(BUILD_DIR)/bank04.bin $(BUILD_DIR)/bank05.bin \
	    $(BUILD_DIR)/bank06.bin $(BUILD_DIR)/bank07.bin $(BUILD_DIR)/bank08.bin \
	    $(BUILD_DIR)/bank09.bin $(BUILD_DIR)/bank0a.bin $(BUILD_DIR)/bank0b.bin \
	    $(BUILD_DIR)/bank0c.bin $(BUILD_DIR)/bank0d.bin $(BUILD_DIR)/bank0e.bin \
	    $(BUILD_DIR)/bank0f.bin $(BUILD_DIR)/bank10.bin $(BUILD_DIR)/bank11.bin \
	    $(BUILD_DIR)/bank12.bin $(BUILD_DIR)/bank13.bin $(BUILD_DIR)/bank14.bin \
	    $(BUILD_DIR)/bank15.bin $(BUILD_DIR)/bank16.bin $(BUILD_DIR)/bank17.bin \
	    $(BUILD_DIR)/bank18.bin $(BUILD_DIR)/bank19.bin $(BUILD_DIR)/bank1a.bin \
	    $(BUILD_DIR)/bank1b.bin $(BUILD_DIR)/bank1c.bin $(BUILD_DIR)/bank1d.bin \
	    $(BUILD_DIR)/bank1e.bin $(BUILD_DIR)/bank1f.bin > $(PRG_BIN)
	@echo "PRG size: $$(wc -c < $(PRG_BIN)) bytes (expected 262144)"

# Create NES ROM with header and CHR
$(OUTPUT): $(PRG_BIN)
	@echo "Creating NES ROM..."
	python3 tools/build_nes.py $(PRG_BIN) $(OUTPUT)

# Disassemble PRG banks (generate stubs)
banks:
	@python3 tools/generate_bank_stubs.py $(ASM_DIR)/banks

# Re-render the annotated seed-data banks (PRG $10/$11) from the ROM, then verify
databanks:
	@python3 tools/gen_data_bank_asm.py --bank all --write
	@$(MAKE) verifydata

# Re-render the seed-data banks from the decoded CSVs (edit docs/*.csv, then run)
databanks-csv:
	@python3 tools/gen_data_bank_asm.py --bank all --from-csv --write
	@$(MAKE) verifydata

# Assemble banks $10/$11 standalone and prove them byte-exact against the ROM
verifydata:
	@python3 tools/verify_data_banks.py

# Re-render the sound/note data bank (PRG $02) from the ROM, then verify
databank02:
	@python3 tools/gen_data_bank_02_asm.py --write
	@$(MAKE) verifydata02

# Assemble bank $02 standalone and prove it byte-exact against the ROM
verifydata02:
	@python3 tools/verify_data_bank_02.py

# Re-render the four terrain banks $00/$03/$04/$05 (30 provinces) as hex plus
# their CSV twins, then verify byte-exact against the stock ROM
terrain:
	@python3 tools/gen_terrain_asm.py --bank all --write --with-csv
	@$(MAKE) verifyterrain

# Re-render the terrain banks from the edited CSVs (docs/terrain_bank_XX.csv).
# Verifies asm == CSV; drift from the stock ROM is expected on this path.
terrain-csv:
	@python3 tools/gen_terrain_asm.py --bank all --from-csv --write
	@python3 tools/verify_terrain_banks.py --bank all --against-csv --allow-edits

# Show the terrain edits that are live relative to the stock ROM
terrain-diff:
	@python3 tools/verify_terrain_banks.py --bank all --allow-edits

# Assemble the terrain banks standalone and prove them byte-exact vs the ROM
verifyterrain:
	@python3 tools/verify_terrain_banks.py --bank all

# Full lossless-loop check: ROM <-> CSV <-> asm <-> editor views
checkterrain:
	@python3 tools/check_terrain_pipeline.py

# Launch the standalone tactical-map GUI editor (needs python3-tk)
map-editor:
	@python3 editor/tactical_map_editor.py

# Split ROM into banks
split:
	@python3 tools/split_rom.py "Sangokushi 2 - Haou no Tairiku (J).nes" $(ROM_DIR)

# Verify ROM matches original
verify: $(OUTPUT)
	@echo "Comparing with original ROM..."
	@python3 tools/verify_rom.py "Sangokushi 2 - Haou no Tairiku (J).nes" $(OUTPUT)

# Disassemble a bank
disasm:
	@python3 tools/disasm_6502.py $(FILE) $(ADDR) $(LEN)

# Analyze ROM
analyze:
	@python3 tools/analyze_rom.py "Sangokushi 2 - Haou no Tairiku (J).nes"

# Enumerate the 256 disaster province-pick RNG sequences, rebuild the coherence doc/CSVs
disasterrng:
	@python3 tools/analyze_disaster_pick_rng.py

# Clean build artifacts
clean:
	@rm -rf $(BUILD_DIR)/*.o $(BUILD_DIR)/*.lst $(BUILD_DIR)/*.txt $(BUILD_DIR)/*.bin $(BUILD_DIR)/*.out
	@rm -f $(PRG_BIN) $(OUTPUT)
	@echo "Cleaned build directory"

# Clean everything including ROM dumps
distclean: clean
	@rm -rf $(ROM_DIR)
	@echo "Cleaned all generated files"

# Show help
help:
	@echo "Sangokushi 2 - Haou no Tairiku Disassembly"
	@echo ""
	@echo "Targets:"
	@echo "  all       - Build NES ROM from assembly (default)"
	@echo "  split     - Split original ROM into PRG/CHR banks"
	@echo "  banks     - Generate PRG bank stub files"
	@echo '  databanks   - Re-render annotated seed-data banks $$10/$$11 from the ROM'
	@echo '  databanks-csv - Re-render them from docs/officer_data.csv/province_data.csv'
	@echo '  verifydata  - Assemble banks $$10/$$11 and prove byte-exactness'
	@echo '  databank02  - Re-render sound/note data bank $$02 from the ROM'
	@echo '  verifydata02 - Assemble bank $$02 and prove byte-exactness'
	@echo '  terrain     - Re-render terrain banks $$00/$$03/$$04/$$05 hex + docs/terrain_bank_XX.csv'
	@echo '  terrain-csv - Re-render them from the edited terrain CSVs (asm == CSV gate)'
	@echo '  terrain-diff - List the terrain edits still live vs the stock ROM'
	@echo '  verifyterrain - Assemble the terrain banks and prove byte-exactness'
	@echo '  checkterrain - Prove the ROM/CSV/asm/editor loop is lossless'
	@echo '  map-editor  - Open the standalone tactical-map GUI editor (editor/)'
	@echo "  disasm    - Disassemble a binary (FILE, ADDR, LEN)"
	@echo "  analyze   - Analyze ROM structure"
	@echo "  disasterrng - Re-enumerate the disaster pick RNG sequences + coherence stats"
	@echo "  verify    - Verify built ROM matches original"
	@echo "  clean     - Remove build artifacts"
	@echo "  distclean - Remove all generated files"
	@echo "  help      - Show this help"
	@echo ""
	@echo "Examples:"
	@echo "  make disasm FILE=rom/prg/prg_1f.bin ADDR=8000 LEN=256"
	@echo "  make analyze"

.PHONY: all split banks databanks databanks-csv verifydata databank02 verifydata02 terrain terrain-csv \
        terrain-diff verifyterrain checkterrain map-editor disasm analyze \
        disasterrng verify clean distclean help
