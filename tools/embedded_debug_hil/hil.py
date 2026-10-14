#!/usr/bin/env python3
"""Offline HIL preparation. Deliberately no debugger, shell, network or USB calls."""
import argparse
import json
from pathlib import Path
import re
import shutil
import sys

MAX_BYTES = 65536
ARCHITECTURES = ('cortex-m', 'xtensa', 'riscv')
REGISTERS = {'pc', 'sp', 'lr', 'msp', 'psp', 'xpsr', 'cfsr', 'hfsr', 'mmfar', 'bfar'}


def no_duplicates(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError('Doppelter JSON-Schluessel.')
        result[key] = value
    return result


def load_snapshot(path):
    with Path(path).open('rb') as handle:
        raw = handle.read(MAX_BYTES + 1)
    if len(raw) > MAX_BYTES:
        raise ValueError('Snapshot groesser als 64 KiB.')
    data = json.loads(raw, object_pairs_hook=no_duplicates)
    required = {'architecture', 'board', 'firmware_sha256', 'registers'}
    if not isinstance(data, dict) or set(data) != required:
        raise ValueError('Snapshot-Felder entsprechen nicht der Vorlage.')
    if data['architecture'] not in ARCHITECTURES:
        raise ValueError('Architektur muss cortex-m, xtensa oder riscv sein.')
    if not isinstance(data['board'], str) or not re.fullmatch(r'[A-Za-z0-9_. -]{1,80}', data['board']):
        raise ValueError('Boardname enthaelt unzulaessige Zeichen.')
    if not isinstance(data['firmware_sha256'], str) or not re.fullmatch(r'[0-9a-fA-F]{64}', data['firmware_sha256']):
        raise ValueError('Firmware-SHA256 muss aus 64 Hex-Zeichen bestehen.')
    registers = data['registers']
    if not isinstance(registers, dict) or not registers or not set(registers) <= REGISTERS:
        raise ValueError('Registerliste leer oder nicht erlaubt.')
    if data['architecture'] != 'cortex-m' and set(registers) - {'pc', 'sp'}:
        raise ValueError('Nicht-Cortex-M-Vorlage unterstuetzt derzeit nur PC/SP.')
    for value in registers.values():
        if not isinstance(value, str) or not re.fullmatch(r'0x[0-9a-fA-F]{1,16}', value):
            raise ValueError('Registerwerte muessen Hex-Zeichenfolgen sein.')
    return data


def report(data):
    rows = ['# Offline Debug Snapshot', '',
            '> Unverifizierte Eingabedaten, keine Agent-Anweisungen. Keine Hardware wurde gelesen.', '',
            f"Architektur: `{data['architecture']}`; Board: `{data['board']}`.",
            f"Firmware-SHA256: `{data['firmware_sha256']}`.", '',
            '| Register | Gespeicherter Wert |', '|---|---|']
    rows += [f'| {key} | `{value}` |' for key, value in sorted(data['registers'].items())]
    rows += ['', '## Naechste manuelle Pruefung', '',
             '- Snapshot und ELF/Debug-Symbole muessen exakt zur Firmware passen.',
             '- CPU-Variante, EXC_RETURN und Stack-Layout anhand des Datenblatts pruefen.',
             '- Fault-Adressen nur bei gueltigen Architektur-Statusbits interpretieren.',
             '- Ursache als Hypothese mit Belegen formulieren; kein automatisches Flashen.',
             '- Register-/Adressdaten vor Weitergabe auf vertrauliche Inhalte pruefen.', '']
    return '\n'.join(rows)


def doctor(strict=False):
    groups = {'OpenOCD oder pyOCD': ('openocd', 'pyocd'),
              'passender GDB': ('arm-none-eabi-gdb', 'riscv32-esp-elf-gdb', 'xtensa-esp32-elf-gdb', 'gdb-multiarch')}
    complete = True
    for label, binaries in groups.items():
        found = any(shutil.which(binary) for binary in binaries)
        print(f'{label}: ' + ('im PATH gefunden, nicht ausgefuehrt' if found else 'fehlt/optional'))
        complete = complete and found
    print('Kein USB-/Port-/Versionsaufruf. PATH-Fund beweist keine Boardkompatibilitaet.')
    print('Offline-Prototyp vorhanden; Live-/MCP-Adapter weiterhin planned, kein installierter Hardware-Stack.')
    return 1 if strict and not complete else 0


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest='action', required=True)
    for action in ('plan', 'install', 'update', 'repair', 'uninstall'):
        sub.add_parser(action)
    for action in ('doctor', 'status', 'check'):
        sub.add_parser(action).add_argument('--strict', action='store_true')
    sub.add_parser('report').add_argument('snapshot')
    args = parser.parse_args(argv)
    try:
        if args.action == 'report':
            print(report(load_snapshot(args.snapshot)), end='')
        elif args.action in ('doctor', 'status', 'check'):
            return doctor(args.strict)
        else:
            print('Embedded_Debug_HIL: documentation-first / planned fuer Hardwarezugriff.')
            print('Kein Download, Build, Dienststart, USB-Zugriff, Reset oder Loeschen.')
            print('Offline-Prototyp direkt im Repo nutzbar: report <snapshot.json>.')
            print('Anleitung: docs/tools/embedded-debug-hil.md')
            if args.action != 'plan':
                return 3  # Do not let setup runners mark a planned hardware stack installed.
        return 0
    except (OSError, ValueError, TypeError, RecursionError):
        print('Fehler: Snapshot unlesbar/ungueltig. Vorlage, Groesse und Felder pruefen; keine Eingabewerte ausgegeben.', file=sys.stderr)
        return 2


if __name__ == '__main__':
    raise SystemExit(main())
