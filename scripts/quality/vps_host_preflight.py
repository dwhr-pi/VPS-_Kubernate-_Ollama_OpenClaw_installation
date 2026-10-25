#!/usr/bin/env python3
"""Read-only host checks for the local CPU VPS; never change swap or runtimes."""
import argparse
import os
from pathlib import Path
import shutil
import sys


def check(data_dir, meminfo=Path('/proc/meminfo'), swaps=Path('/proc/swaps')):
    if not data_dir.is_absolute() or not data_dir.is_dir():
        raise ValueError('Vorhandenes absolutes k3s-/Container-Datenverzeichnis erforderlich.')
    memory = {}
    for line in meminfo.read_text(encoding='ascii').splitlines():
        key, value = line.split(':', 1)
        memory[key] = int(value.split()[0])
    if memory.get('MemTotal', 0) < 6 * 1024**2 or memory.get('MemAvailable', 0) < 2 * 1024**2:
        raise ValueError('CPU-VPS: mindestens 6 GiB RAM gesamt und 2 GiB aktuell verfuegbar erforderlich.')
    if len(swaps.read_text(encoding='ascii').splitlines()) > 1:
        raise ValueError('Aktiver Swap: kubelet-/MemorySwap-Vertrag separat pruefen; kein automatisches swapoff.')
    required = 64 * 1024**3
    print('RAM-/Swap-Pruefung bestanden; pruefe 64 GiB Diskreserve fuer 50-GiB-Modell-PVC und Runtime.', flush=True)
    if shutil.disk_usage(data_dir).free < required:
        raise ValueError('Weniger als 64 GiB frei am lokalen Runtime-/Storage-Ziel.')
    if os.environ.get('WSL_DISTRO_NAME') and Path('/mnt/c').is_dir():
        if shutil.disk_usage('/mnt/c').free < required:
            raise ValueError('Windows C: unter 64 GiB frei; Linux-VHDX-Kapazitaet reicht als Nachweis nicht.')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--data-dir', required=True, type=Path)
    args = parser.parse_args()
    try:
        check(args.data_dir)
    except (OSError, ValueError) as error:
        print('VPS-Vorpruefung abgebrochen: ' + str(error), file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
