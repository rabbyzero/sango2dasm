#!/usr/bin/env python3
"""Render the tactical terrain banks $00/$03/$04/$05 as `.byte` hex + CSV twins.

The four data banks that hold the game's 120 terrain quadrant crops (30
provinces x 4) used to be blind `.incbin "rom/prg/prg_XX.bin"` stubs. This tool
writes each one out as labelled `.byte` rows - one line per 16 map cells - so the
tactical maps are readable and editable in the tree, and keeps a CSV twin per
bank (`docs/terrain_bank_XX.csv`) as the comfortable editing surface:

    TerrainCrop_Z032_P08_TL:                    ; zone 32 - province 8 TL crop
      .byte $1C, $1C, ...                       ; $89A6  z032 P08 TL  r00  pppp...

Two sources for the bytes:

  default     read them straight from rom/prg/prg_XX.bin (the stock ROM)
  --from-csv  rebuild a bank from the tile bytes of its CSV, i.e. edit the CSV
              (or editor/tactical_map_editor.py), regenerate the assembly.
              tools/verify_terrain_banks.py then reports the drift from the stock
              ROM in human terms (which province, which quadrant, which cell).

The CSV is lossless in both directions: every byte of a bank has exactly one
owner row, and the ribbon's overlapping crop windows are resolved through that
owner (see tools/terrain_model.py). Layout evidence: code/bank_00_data_layout.md.

Usage:
    python tools/gen_terrain_asm.py                      # preview bank $00
    python tools/gen_terrain_asm.py --bank all --write    # update all four asm files
    python tools/gen_terrain_asm.py --bank all --make-csv # write the four CSVs
    python tools/gen_terrain_asm.py --bank 03 --from-csv --write
"""
import argparse
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import terrain_model as model                   # noqa: E402


def load_rows(bank, from_csv, csv_file=None):
    """(rows, source_note) - the bank either from its CSV or from the stock ROM."""
    path = csv_file or model.csv_path(bank)
    if from_csv:
        if not os.path.exists(path):
            raise SystemExit('--from-csv needs %s; run --make-csv first'
                             % os.path.relpath(path, model.ROOT))
        note = ('%s - edit that CSV and rerun with --from-csv'
                % os.path.relpath(path, model.ROOT))
        return model.csv_read(path, bank), note
    note = ('rom/prg/prg_%02x.bin (stock ROM, read-only reference)' % bank)
    return model.rows_from_bank(bank, model.read_bank(bank)), note


def banks_arg(text):
    """'00' / '3' / 'all' -> the physical bank numbers to process."""
    if text == 'all':
        return list(model.TERRAIN_BANKS)
    values = text.replace('$', '').split(',')
    out = []
    for value in values:
        bank = int(value, 16)
        if bank not in model.TERRAIN_BANKS:
            raise SystemExit('bank $%02X holds no terrain zones (%s)'
                             % (bank, '/'.join('$%02X' % b
                                               for b in model.TERRAIN_BANKS)))
        out.append(bank)
    return out


def main():
    ap = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--bank', default='00',
                    help='terrain bank: 00, 03, 04, 05, a comma list, or all')
    ap.add_argument('--from-csv', action='store_true',
                    help='take the tile bytes from the CSV instead of the ROM')
    ap.add_argument('--write', action='store_true',
                    help='update asm/banks/data_XX.asm (default: stdout)')
    ap.add_argument('--with-csv', action='store_true',
                    help='with --write: also refresh the CSV twin')
    ap.add_argument('--make-csv', action='store_true',
                    help='write the CSV only, leave the assembly untouched')
    ap.add_argument('--csv', help='override the CSV path (single bank only)')
    ap.add_argument('--asm', help='override the asm path (single bank only)')
    args = ap.parse_args()

    if (args.csv or args.asm) and len(banks_arg(args.bank)) != 1:
        raise SystemExit('--csv/--asm accept a single --bank value')
    banks = banks_arg(args.bank)

    if args.make_csv:
        for bank in banks:
            rows, _ = load_rows(bank, from_csv=False)
            path = args.csv or model.csv_path(bank)
            model.csv_write(path, rows)
            print('wrote %s (%d rows, %d bytes)'
                  % (os.path.relpath(path, model.ROOT), len(rows),
                     model.BANK_SIZE))
        return 0

    for bank in banks:
        rows, note = load_rows(bank, args.from_csv, args.csv)
        text = model.asm_text(bank, rows, note)
        rebuilt = model.bank_from_rows(bank, rows)
        if args.write:
            path = args.asm or model.asm_path(bank)
            os.makedirs(os.path.dirname(path), exist_ok=True)
            with open(path, 'w', encoding='utf-8') as f:
                f.write(text)
            print('wrote %s (%d lines, %d bytes of data)'
                  % (os.path.relpath(path, model.ROOT), text.count('\n'),
                     model.BANK_SIZE))
            if args.with_csv:
                model.csv_write(args.csv or model.csv_path(bank),
                                model.rows_from_bank(bank, rebuilt))
        else:
            sys.stdout.write(text)
    if not args.write:
        print('; preview only: banks %s'
              % ', '.join('$%02X' % b for b in banks), file=sys.stderr)
    return 0


if __name__ == '__main__':
    sys.exit(main())
