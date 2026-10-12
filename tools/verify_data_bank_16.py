#!/usr/bin/env python3
"""Verify asm/banks/data_16.asm against rom/prg/prg_16.bin byte-for-byte.

Assembles the bank standalone (its own linker config, $8000-$9FFF window) with
the real ca65/ld65 and compares the 8192 built bytes with the stock ROM. On a
mismatch the offset is mapped to its region (pointer table / blob / screen /
filler) so an edited record can be located in human terms.

    python tools/verify_data_bank_16.py
"""
import os
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CC65 = '/home/zero/.local/bin/ca65'
LD65 = '/home/zero/.local/bin/ld65'
BUILD = os.path.join(ROOT, 'build')
BANK = 0x16

LINKER_CFG = ('MEMORY {\n'
              '    BANK16: start = $8000, size = $2000, type = ro, fill = yes,\n'
              '            fillval = $FF, file = "build/_seed16.bin";\n'
              '}\n'
              'SEGMENTS {\n'
              '    CODE_BANK16: load = BANK16, type = ro;\n'
              '}\n')

TABLES = [
    ('MenuAction00_InitialSetup', 0x8000, 2),
    ('MenuAction01_DisplaySetup', 0x80F6, 4),
    ('MenuAction02_LandReclamation', 0x8172, 1),
    ('MenuAction03_DisasterPreventionSetup', 0x81CD, 4),
    ('MenuAction04_DisasterPrevention', 0x8239, 2),
    ('MenuAction05_UnidentifiedCmdSetup', 0x82A7, 4),
    ('MenuAction06_UnidentifiedCmd', 0x8383, 3),
    ('MenuAction07_CountryEnd', 0x8454, 3),
    ('MenuAction08_GoldDistribution', 0x8559, 5),
    ('MenuAction09_RiceDistribution', 0x863C, 4),
    ('MenuAction0A_Conscription', 0x8760, 3),
    ('MenuAction0B_HireOfficer', 0x87D1, 4),
    ('MenuAction0C_TransferOfficer', 0x88D5, 6),
    ('MenuAction0D_UnidentifiedCmd', 0x89B7, 5),
    ('MenuAction0E_UnidentifiedCmd', 0x8A52, 5),
    ('MenuAction0F_GiveItem', 0x8B55, 6),
    ('MenuAction10_SuccessorSelection', 0x8C03, 5),
    ('MenuAction11_Intrigue', 0x8D2E, 3),
    ('MenuAction12_Sortie', 0x8E37, 6),
    ('MenuAction13_Reconnaissance', 0x8EDD, 2),
    ('MenuAction14_Market', 0x8F6B, 4),
    ('MenuAction15_Exchange', 0x9077, 3),
    ('MenuAction16_Trade', 0x9140, 4),
    ('MenuAction17_SearchOfficer', 0x91DC, 4),
    ('MenuAction18_SearchItem', 0x92A0, 6),
    ('MenuAction19_UnidentifiedCmd', 0x9342, 3),
    ('MenuAction1A_OfficerDeath', 0x9477, 6),
    ('MenuAction1B_StrategyCommandDispatch', 0x9691, 6),
    ('MenuAction1C_CopyTileData', 0x9733, 2),
    ('MenuAction1D_SetupActionDisplay', 0x9769, 2),
    ('MenuAction1E_CalcParams', 0x981F, 4),
    ('MenuAction1F_CalcParams2', 0x9893, 4),
    ('MenuAction20_CalcParams3', 0x99DF, 3),
    ('MenuAction21_Finalize', 0x9AE4, 2),
]


def assemble():
    os.makedirs(BUILD, exist_ok=True)
    asm = os.path.join(BUILD, '_seed16.asm')
    cfg = os.path.join(BUILD, '_seed16.cfg')
    obj = os.path.join(BUILD, '_seed16.o')
    out = os.path.join(BUILD, '_seed16.bin')
    with open(os.path.join(ROOT, 'asm', 'banks', 'data_16.asm'),
              encoding='utf-8') as f:
        text = f.read()
    with open(asm, 'w', encoding='utf-8') as f:
        f.write(text)
    with open(cfg, 'w', encoding='utf-8') as f:
        f.write(LINKER_CFG)
    r = subprocess.run([CC65, '-I', os.path.join(ROOT, 'include'),
                        '-I', os.path.join(ROOT, 'asm', 'banks'),
                        asm, '-o', obj], capture_output=True, text=True,
                       cwd=ROOT)
    if r.returncode != 0:
        print('CA65 FAILED:\n%s' % r.stderr[:4000], file=sys.stderr)
        return None
    if r.stderr.strip():
        print('ca65 notes: %s' % r.stderr.strip()[:400])
    r = subprocess.run([LD65, '-C', cfg, obj, '-o', out],
                       capture_output=True, text=True, cwd=ROOT)
    if r.returncode != 0:
        print('LD65 FAILED:\n%s' % r.stderr[:4000], file=sys.stderr)
        return None
    with open(out, 'rb') as f:
        return f.read()


def region_of(offset):
    addr = 0x8000 + offset
    if addr >= 0x9F92:
        return 'filler'
    if addr >= 0x9B92:
        return ('EventMessageSceneScreen ' +
                ('attribute byte' if addr >= 0x9EF2 else
                 'tile row %d' % ((addr - 0x9B92) // 32)))
    for name, tab, count in TABLES:
        nxt = TABLES[TABLES.index((name, tab, count)) + 1][1] \
            if (name, tab, count) != TABLES[-1] else 0x9B92
        if tab <= addr < nxt:
            if addr < tab + 2 * count:
                return '%s ptr table entry %d' % (name, (addr - tab) // 2)
            return '%s blob area' % name
    return 'MenuOam area'


def main():
    built = assemble()
    if built is None:
        return 1
    with open(os.path.join(ROOT, 'rom', 'prg', 'prg_16.bin'), 'rb') as f:
        rom = f.read()
    if len(built) != len(rom):
        print('SIZE MISMATCH: built %d bytes, rom %d bytes'
              % (len(built), len(rom)))
        return 1
    diffs = [i for i in range(len(rom)) if built[i] != rom[i]]
    if not diffs:
        print('compared %d bytes, 0 mismatches' % len(rom))
        return 0
    print('%d mismatches:' % len(diffs))
    for i in diffs[:40]:
        print('  $%04X: asm %02X != rom %02X  (%s)'
              % (0x8000 + i, built[i], rom[i], region_of(i)))
    return 1


if __name__ == '__main__':
    sys.exit(main())
