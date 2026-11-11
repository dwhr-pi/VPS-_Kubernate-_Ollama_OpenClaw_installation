"""Read-only diagnostics: offline by default; bounded local probes require explicit approval."""
import argparse
import http.client
import json
import math
import os
from pathlib import Path
import re
import shutil
import socket
import stat
import subprocess
import sys
import threading
import time

ROOT = Path(__file__).resolve().parents[2]
SERVICES = {
    'ollama': (11434, '/api/tags'),
    'openclaw': (18789, '/readyz'),
    'open-webui': (3000, '/health/db'),
    'inference-gateway': (4000, '/health/liveliness'),
    'n8n': (5678, '/healthz'),
}
HOSTS = ('wireguard', 'k3s', 'gpu')
TIMEOUT = 3
MAX_BODY = 65536


def interrupt_socket(sock):
    # Interrupt slow headers/body reads as well as ordinary socket timeouts.
    try:
        sock.shutdown(socket.SHUT_RDWR)
    except OSError:
        pass


def http_probe(name):
    # No proxies, DNS, redirects, credentials, model calls or response logging.
    port, path = SERVICES[name]
    connection = http.client.HTTPConnection('127.0.0.1', port, timeout=TIMEOUT)
    deadline = time.monotonic() + TIMEOUT
    timer = None
    try:
        connection.connect()
        sock = connection.sock
        timer = threading.Timer(max(0.001, deadline - time.monotonic()), interrupt_socket, args=(sock,))
        timer.daemon = True
        timer.start()
        connection.request('GET', path, headers={'Connection': 'close'})
        sock.settimeout(max(0.001, deadline - time.monotonic()))
        response = connection.getresponse()
        if response.status != 200:
            return False, 'HTTP-Status nicht 200; Inhalt nicht protokolliert'
        data = bytearray()
        while True:
            remaining = deadline - time.monotonic()
            if remaining <= 0:
                return False, 'HTTP-Zeitbudget ueberschritten'
            sock.settimeout(remaining)
            chunk = response.read1(min(4096, MAX_BODY + 1 - len(data)))
            if time.monotonic() > deadline:
                return False, 'HTTP-Zeitbudget ueberschritten'
            if not chunk:
                break
            data.extend(chunk)
            if len(data) > MAX_BODY:
                return False, 'HTTP-Antwort zu gross'
        if name == 'ollama':
            body = json.loads(data)
            if not isinstance(body, dict) or not isinstance(body.get('models'), list):
                return False, 'Ollama-Antwortformat ungueltig'
        return True, 'Lokaler Health-Endpunkt antwortet; keine Inferenz-/Auth-Abnahme'
    except (OSError, ValueError, http.client.HTTPException):
        return False, 'HTTP-Pruefung fehlgeschlagen; Antwortinhalt bleibt privat'
    finally:
        if timer is not None:
            timer.cancel()
        connection.close()


def host_probe(name, unit):
    commands = {
        'wireguard': ['ip', '-json', 'link', 'show', 'dev', 'wg0'],
        'k3s': ['systemctl', 'is-active', '--quiet', unit],
        'gpu': ['nvidia-smi', '--query-gpu=name', '--format=csv,noheader'],
    }
    command = commands[name]
    executable = shutil.which(command[0])
    if not executable:
        return False, 'Pruefprogramm fehlt; kein Download'
    try:
        result = subprocess.run([executable, *command[1:]], stdout=subprocess.PIPE,
                                stderr=subprocess.DEVNULL, timeout=TIMEOUT, check=False)
        passed = result.returncode == 0
        if name == 'wireguard' and passed:
            links = json.loads(result.stdout)
            passed = isinstance(links, list) and bool(links) and all(
                isinstance(row, dict) and 'UP' in row.get('flags', []) for row in links)
        if name == 'gpu':
            passed = passed and bool(result.stdout.strip())
        return passed, {'wireguard': 'Nur wg0-Linkstatus; kein Handshake-/Routing-Nachweis',
                        'k3s': 'Nur Unit-Status; keine Cluster-/Node-Abnahme',
                        'gpu': 'Nur Treibersicht; keine CUDA-/VRAM-/Inferenz-Abnahme'}[name]
    except (OSError, ValueError, TypeError, subprocess.TimeoutExpired):
        return False, 'Pruefung fehlgeschlagen oder Zeitbudget ueberschritten'


def private_metadata(path):
    path = Path(os.path.abspath(path))
    for part in (path, *path.parents):
        if part.is_symlink() or (hasattr(part, 'is_junction') and part.is_junction()):
            raise ValueError('Linked metadata path')
    info = path.stat()
    if not stat.S_ISREG(info.st_mode):
        raise ValueError('Regular file required')
    return info


def pin_check(root):
    rows = json.loads((root / 'config/docker_to_github.json').read_text(encoding='utf-8'))['tools']
    if not isinstance(rows, list) or not all(isinstance(row, dict) for row in rows):
        raise ValueError('Invalid recipe registry')
    recipes = [row['recipe'] for row in rows if row.get('recipe')]
    if not all(isinstance(recipe, dict) for recipe in recipes):
        raise ValueError('Invalid recipe')
    valid = all(re.fullmatch('[0-9a-f]{40}', recipe.get('pin', '')) for recipe in recipes)
    tools = json.loads((root / 'config/tools.yml').read_text(encoding='utf-8'))['tools']
    if not isinstance(tools, list) or not all(isinstance(row, dict) for row in tools):
        raise ValueError('Invalid tool registry')
    provided = [row['source_commit'] for row in tools if 'source_commit' in row]
    valid = valid and all(isinstance(pin, str) and re.fullmatch('[0-9a-f]{40}', pin) for pin in provided)
    return bool(recipes) and valid, (f'{len(recipes)} Rezept-Pins und {len(provided)} Registry-Pins geprueft; '
                                  'keine transitive Supply-Chain-/Image-/Build-Abnahme')


def run(args, root=ROOT):
    checks = []

    def add(name, passed, message, severity='P1'):
        checks.append({'check': name, 'status': 'passed' if passed else 'failed',
                       'severity': severity, 'message': message})

    if args.mode == 'doctor':
        try:
            passed, message = pin_check(root)
            add('pins', passed, message, 'P0')
        except (OSError, ValueError, KeyError, TypeError):
            add('pins', False, 'Pin-Metadaten fehlen oder sind ungueltig', 'P0')
    selected = list(dict.fromkeys(args.require))
    runtime = bool(args.runtime and not args.dry_run)
    if runtime:
        if args.mode == 'doctor':
            add('disk', shutil.disk_usage(root).free >= args.min_free_gib * 1024**3,
                'Nur Dateisystem des Checkouts; kein Windows-Host-/VRAM-Nachweis', 'P0')
        for name in selected:
            passed, message = http_probe(name) if name in SERVICES else host_probe(name, args.k3s_unit)
            add(name, passed, message)
        if args.secret_metadata:
            try:
                info = private_metadata(args.secret_metadata)
                passed = (os.name == 'posix' and info.st_uid == os.getuid()
                          and stat.S_IMODE(info.st_mode) & 0o077 == 0)
                add('secret-metadata', passed, 'Nur Besitzer/Unix-Modus; keine Inhalts-/History-Pruefung', 'P0')
            except (OSError, ValueError):
                add('secret-metadata', False, 'Metadaten nicht sicher pruefbar', 'P0')
        if args.backup_evidence:
            try:
                info = private_metadata(args.backup_evidence)
                age = time.time() - info.st_mtime
                add('backup-age', 0 <= age <= args.max_backup_age_hours * 3600,
                    'Nur Dateialter; kein Inhalts-, Offsite-, DB- oder Restore-Nachweis')
            except (OSError, ValueError):
                add('backup-age', False, 'Backup-Nachweisdatei fehlt oder ist unsicher')
    else:
        selected = []
    failed = any(row['status'] == 'failed' for row in checks)
    report = {'schema': 1, 'mode': args.mode, 'runtime_requested': runtime,
              'runtime_acceptance': False, 'selected_probes_passed': bool(runtime and selected and not failed),
              'scope': 'selected-local-health-only' if runtime else 'offline-pin-metadata-only',
              'not_checked': ([name for name in (*SERVICES, *HOSTS) if name not in selected]
                              + ([] if runtime and args.secret_metadata else ['secret-metadata'])
                              + ([] if runtime and args.backup_evidence else ['backup-age'])
                              + ([] if runtime and args.mode == 'doctor' else ['disk'])),
              'backup_contents_verified': False, 'secret_contents_read': False, 'checks': checks}
    return report, 1 if failed else (0 if runtime and selected else 3)


def positive(value):
    number = float(value)
    if not math.isfinite(number) or number <= 0:
        raise argparse.ArgumentTypeError('Positive finite number required')
    return number


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('mode', choices=('doctor', 'smoke'))
    parser.add_argument('--json', action='store_true')
    parser.add_argument('--dry-run', '--plan', action='store_true')
    parser.add_argument('--runtime', action='store_true')
    parser.add_argument('--require', action='append', choices=(*SERVICES, *HOSTS), default=[])
    parser.add_argument('--k3s-unit', choices=('k3s', 'k3s-agent'), default='k3s')
    parser.add_argument('--min-free-gib', type=positive, default=8)
    parser.add_argument('--secret-metadata', type=Path)
    parser.add_argument('--backup-evidence', type=Path)
    parser.add_argument('--max-backup-age-hours', type=positive, default=48)
    args = parser.parse_args(argv)
    try:
        report, code = run(args)
    except OSError:
        report, code = {'error': 'Dateisystem nicht pruefbar', 'runtime_acceptance': False}, 1
    print(json.dumps(report, indent=None if args.json else 2, ensure_ascii=True))
    return code


if __name__ == '__main__':
    sys.exit(main())
