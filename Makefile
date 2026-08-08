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
	@echo "  disasm    - Disassemble a binary (FILE, ADDR, LEN)"
	@echo "  analyze   - Analyze ROM structure"
	@echo "  verify    - Verify built ROM matches original"
	@echo "  clean     - Remove build artifacts"
	@echo "  distclean - Remove all generated files"
	@echo "  help      - Show this help"
	@echo ""
	@echo "Examples:"
	@echo "  make disasm FILE=rom/prg/prg_1f.bin ADDR=8000 LEN=256"
	@echo "  make analyze"

.PHONY: all split banks disasm analyze verify clean distclean help
