-- Mesen2 Lua script: Dump CHR bank registers and PPU pattern table
-- Usage: Load game, navigate to a text screen, then run this script

function dumpChrBanks()
    -- Read CHR bank registers $00AE-$00B5 from CPU memory
    -- NesMemory = 9 (enum index from MemoryType.h, after non-NES entries)
    -- Actually Mesen2 uses emu.memType.NesMemory
    local chrBanks = {}
    for i = 0, 7 do
        chrBanks[i] = emu.read(0x00AE + i, emu.memType.NesMemory)
    end
    return chrBanks
end

function dumpPpuTile(tileIndex)
    -- Read 16 bytes of PPU pattern table data for a single tile
    -- Each tile is 16 bytes (8 bytes bitplane 0 + 8 bytes bitplane 1)
    -- PPU VRAM starts at $0000, pattern table 0 at $0000, pattern table 1 at $1000
    local baseAddr = tileIndex * 16
    local data = {}
    for i = 0, 15 do
        data[i] = emu.read(baseAddr + i, emu.memType.NesPpuMemory)
    end
    return data
end

function renderTile(data)
    -- Render a tile as 8x8 text using block characters
    local lines = {}
    for row = 0, 7 do
        local bp0 = data[row]      -- bitplane 0
        local bp1 = data[row + 8]  -- bitplane 1
        local line = ""
        for col = 7, 0, -1 do
            local bit0 = (bp0 >> col) & 1
            local bit1 = (bp1 >> col) & 1
            local pixel = bit0 | (bit1 << 1)
            if pixel == 0 then
                line = line .. " "
            elseif pixel == 1 then
                line = line .. "."
            elseif pixel == 2 then
                line = line .. "o"
            else
                line = line .. "#"
            end
        end
        lines[row] = line
    end
    return lines
end

function dumpInfo()
    -- Dump CHR bank registers
    local chrBanks = dumpChrBanks()
    local bankStr = "CHR Banks [$00AE-$00B5]:"
    for i = 0, 7 do
        bankStr = bankStr .. string.format(" %02X", chrBanks[i])
    end
    emu.drawString(8, 8, bankStr, 0xFFFFFF, 0xFF000000)

    -- Also log to console
    emu.log(bankStr)

    -- Dump $00E2 (current PRG bank for window)
    local e2 = emu.read(0x00E2, emu.memType.NesMemory)
    emu.log(string.format("$00E2 = %02X", e2))

    -- Read hero name buffer at $03B1-$03BA (first hero)
    local nameStr = "Name buf $03B1:"
    for i = 0, 9 do
        local b = emu.read(0x03B1 + i, emu.memType.NesMemory)
        nameStr = nameStr .. string.format(" %02X", b)
    end
    emu.log(nameStr)

    -- Dump PPU pattern table 0 tiles 4-56 (the katakana range)
    emu.log("=== PPU Pattern Table 0, Tiles 4-56 ===")
    for t = 4, 56 do
        local data = dumpPpuTile(t)
        local lines = renderTile(data)
        local hexStr = string.format("Tile %02X:", t)
        for i = 0, 15 do
            hexStr = hexStr .. string.format(" %02X", data[i])
        end
        emu.log(hexStr)
        for row = 0, 7 do
            emu.log(string.format("  %s", lines[row]))
        end
    end

    emu.log("=== Dump complete ===")
    emu.displayMessage("Script", "CHR dump complete - check log")
end

-- Run once immediately
dumpInfo()

-- Also register for frame callback to show overlay
function showOverlay()
    local chrBanks = dumpChrBanks()
    local bankStr = "CHR:"
    for i = 0, 7 do
        bankStr = bankStr .. string.format(" %02X", chrBanks[i])
    end
    emu.drawRectangle(8, 8, 280, 16, 0xC0000000, true, 1)
    emu.drawString(12, 10, bankStr, 0xFFFFFF, 0xFF000000, 1)

    -- Show tile 4 rendered
    local data = dumpPpuTile(4)
    local lines = renderTile(data)
    for row = 0, 7 do
        emu.drawString(12, 28 + row * 8, lines[row], 0xFFFFFF, 0xFF000000, 1)
    end
end

emu.addEventCallback(showOverlay, emu.eventType.endFrame)
