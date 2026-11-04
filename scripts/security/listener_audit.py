"""Read-only host listener check; no services, firewall changes or probe traffic."""
import argparse
import ipaddress
import json
from pathlib import Path
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
MAX_INPUT = 4 * 1024 * 1024
PRIVATE = tuple(ipaddress.ip_network(value) for value in
                ('10.0.0.0/8', '172.16.0.0/12', '192.168.0.0/16', 'fc00::/7',
                 '127.0.0.0/8', '::1/128'))


def registry_ports(path):
    rows = json.loads(Path(path).read_text(encoding='utf-8-sig'))['ports']
    if not isinstance(rows, list):
        raise ValueError('Invalid registry')
    ports = set()
    for row in rows:
        port = row['port']
        if type(port) is not int or not 1 <= port <= 65535 or port in ports:
            raise ValueError('Invalid or duplicate registry port')
        ports.add(port)
    # Control and inference APIs remain protected even if registry entries are absent.
    return ports | {6443, 11434, 18789}


def private_network(value):
    network = ipaddress.ip_network(value, strict=True)
    if not any(network.version == base.version and network.subnet_of(base) for base in PRIVATE):
        raise ValueError('Only explicit private/VPN CIDRs allowed')
    return network


def listeners(text):
    if len(text.encode('utf-8')) > MAX_INPUT:
        raise ValueError('Oversized listener input')
    result = []
    for line in text.splitlines():
        if not line.strip():
            continue
        fields = line.split()
        if len(fields) < 6 or fields[0] not in ('tcp', 'udp'):
            raise ValueError('Unexpected ss format')
        host, separator, port = fields[4].rpartition(':')
        if not separator or not port.isascii() or not port.isdecimal() or not 1 <= int(port) <= 65535:
            raise ValueError('Invalid local endpoint')
        host = host.removeprefix('[').removesuffix(']').split('%', 1)[0]
        address = None if host == '*' else ipaddress.ip_address(host)
        if isinstance(address, ipaddress.IPv6Address) and address.ipv4_mapped:
            address = address.ipv4_mapped
        result.append((fields[0], address, int(port)))
    return result


def assess(text, protected, allowed=()):
    findings = []
    unregistered = set()
    for protocol, address, port in listeners(text):
        if port not in protected:
            unregistered.add((protocol, port))
            continue
        safe = address is not None and (address.is_loopback or (
            not address.is_unspecified and any(address.version == net.version and address in net
                                               for net in allowed)))
        if not safe:
            findings.append({'protocol': protocol, 'port': port,
                             'reason': 'wildcard' if address is None or address.is_unspecified
                             else 'outside-explicit-private-boundary'})
    return {'scope': 'host-listeners-only-not-compose-or-cluster-reachability',
            'findings': findings, 'unregistered_listener_count': len(unregistered),
            'runtime_acceptance': False}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument('--check-host', action='store_true')
    mode.add_argument('--stdin', action='store_true', help='Parse supplied ss -H -lntup output only')
    mode.add_argument('--dry-run', action='store_true')
    parser.add_argument('--allow-cidr', action='append', default=[])
    args = parser.parse_args()
    try:
        allowed = tuple(private_network(value) for value in args.allow_cidr)
        if not args.check_host and not args.stdin:
            print('Nur Plan: Host-TCP/UDP-Listener gegen Registry und explizite VPN-CIDRs pruefen. '
                  'Kein Host-/Netz-/Clusterzugriff, keine Aenderung.')
            return 0
        protected = registry_ports(ROOT / 'config/ports.yml')
        if args.check_host:
            if not sys.platform.startswith('linux'):
                raise ValueError('Native Linux required; no WSL fallback')
            command = shutil.which('ss')
            if not command:
                raise ValueError('ss unavailable; inspection incomplete')
            proc = subprocess.run([command, '-H', '-lntup'], capture_output=True, text=True,
                                  timeout=10, check=True)
            text = proc.stdout
        else:
            text = sys.stdin.read(MAX_INPUT + 1)
        result = assess(text, protected, allowed)
        print(json.dumps(result, sort_keys=True))
        return 1 if result['findings'] else 0
    except (OSError, ValueError, KeyError, TypeError, UnicodeError, subprocess.SubprocessError):
        # Never disclose process command lines, source text or credential-bearing diagnostics.
        print('Listener-Pruefung unvollstaendig; Werkzeug, Format und Registry pruefen. '
              'Keine Sicherheitsfreigabe.', file=sys.stderr)
        return 2


if __name__ == '__main__':
    sys.exit(main())
