#!/usr/bin/env python3
"""Read-only host checks for the local CPU VPS; never change swap or runtimes."""
import argparse
import os
from pathlib import Path
import shutil
import subprocess
import sys


def check(data_dir, meminfo=Path('/proc/meminfo'), swaps=Path('/proc/swaps'), *, cpu_count=None):
    if not data_dir.is_absolute() or not data_dir.is_dir():
        raise ValueError('Vorhandenes absolutes k3s-/Container-Datenverzeichnis erforderlich.')
    if any(path.is_symlink() for path in (data_dir, *data_dir.parents)):
        raise ValueError('Verlinktes Runtime-/Storage-Ziel erfordert eine separate Pfadpruefung.')
    cpus = os.cpu_count() if cpu_count is None else cpu_count
    if type(cpus) is not int or cpus < 2:
        raise ValueError('CPU-VPS: mindestens zwei erkannte logische CPUs erforderlich.')
    memory = {}
    for line in meminfo.read_text(encoding='ascii').splitlines():
        key, value = line.split(':', 1)
        memory[key] = int(value.split()[0])
    if memory.get('MemTotal', 0) < 6 * 1024**2 or memory.get('MemAvailable', 0) < 3 * 1024**2:
        raise ValueError('CPU-VPS: mindestens 6 GiB RAM gesamt und 3 GiB aktuell verfuegbar erforderlich.')
    if len(swaps.read_text(encoding='ascii').splitlines()) > 1:
        raise ValueError('Aktiver Swap: kubelet-/MemorySwap-Vertrag separat pruefen; kein automatisches swapoff.')
    required = 64 * 1024**3
    print('RAM-/Swap-Pruefung bestanden; pruefe 64 GiB Diskreserve fuer 50-GiB-Modell-PVC und Runtime.', flush=True)
    if shutil.disk_usage(data_dir).free < required:
        raise ValueError('Weniger als 64 GiB frei am lokalen Runtime-/Storage-Ziel.')
    if os.environ.get('WSL_DISTRO_NAME') and Path('/mnt/c').is_dir():
        if shutil.disk_usage('/mnt/c').free < required:
            raise ValueError('Windows C: unter 64 GiB frei; Linux-VHDX-Kapazitaet reicht als Nachweis nicht.')


def check_runtime(unit):
    # Service state only: no CRI RPC, kubeconfig access, start, restart or repair.
    if unit not in ('k3s', 'k3s-agent', 'containerd'):
        raise ValueError('Runtime-Unit nicht freigegeben.')
    binary = shutil.which('systemctl')
    if not binary:
        raise ValueError('systemctl fehlt; Runtime-Status nicht pruefbar.')
    result = subprocess.run([binary, 'is-active', '--quiet', unit], stdin=subprocess.DEVNULL,
                            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                            check=False, timeout=10)
    if result.returncode != 0:
        raise ValueError('Runtime-Unit nicht aktiv oder Status nicht pruefbar.')
    print('Runtime-Unit aktiv; CRI-/GPU-/Cluster-Gesundheit damit NICHT nachgewiesen.')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--data-dir', required=True, type=Path)
    parser.add_argument('--runtime-unit', choices=('k3s', 'k3s-agent', 'containerd'))
    args = parser.parse_args()
    try:
        check(args.data_dir)
        if args.runtime_unit:
            check_runtime(args.runtime_unit)
    except (OSError, ValueError, subprocess.SubprocessError) as error:
        print('VPS-Vorpruefung abgebrochen: ' + str(error), file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
