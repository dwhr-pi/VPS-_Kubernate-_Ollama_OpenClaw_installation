"""Opt-in Pi wake -> worker SSH -> Kubernetes Ready/GPU -> private Ollama version gate."""
import argparse
from concurrent.futures import ThreadPoolExecutor, TimeoutError as FutureTimeout
import ipaddress
import json
import os
from pathlib import Path
import re
import shlex
import stat
import subprocess
import sys
import time
import urllib.request

NETWORKS = tuple(map(ipaddress.ip_network, ('10.0.0.0/8', '172.16.0.0/12', '192.168.0.0/16')))
MAX_OUTPUT = 1024 * 1024


def private_ip(value):
    address = ipaddress.ip_address(value)
    if address.version != 4 or not any(address in network for network in NETWORKS):
        raise ValueError('Only numeric RFC1918 targets allowed')
    return str(address)


def contract(args):
    for name in ('pi_ip', 'worker_ip', 'control_ip'):
        setattr(args, name, private_ip(getattr(args, name)))
    if not re.fullmatch(r'(?:[0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}', args.mac):
        raise ValueError('Invalid MAC')
    if int(args.mac[:2], 16) & 1 or args.mac.replace(':', '') == '0' * 12:
        raise ValueError('Unicast worker MAC required')
    if not re.fullmatch(r'[a-z_][a-z0-9_-]{0,31}', args.ssh_user) or args.ssh_user == 'root':
        raise ValueError('Dedicated non-root SSH user required')
    if not re.fullmatch(r'[a-z0-9][a-z0-9.-]{0,62}', args.node):
        raise ValueError('Invalid node name')
    if not 10 <= args.timeout <= 300:
        raise ValueError('Timeout outside bounded contract')
    return args


def secure_input(path):
    path = Path(path)
    repository = Path(__file__).resolve().parents[2]
    if (not path.is_absolute() or '..' in path.parts or repository in path.parents
            or any(c in str(path) for c in '\r\n\0')):
        raise ValueError('Absolute operator-owned SSH files required')
    for parent in (path, *path.parents):
        if parent.is_symlink() or (hasattr(parent, 'is_junction') and parent.is_junction()):
            raise ValueError('Linked SSH files forbidden')
    info = path.stat()
    if (not stat.S_ISREG(info.st_mode) or info.st_nlink != 1 or info.st_uid != os.geteuid()
            or stat.S_IMODE(info.st_mode) != 0o600):
        raise ValueError('Private SSH input required')


def ssh(args, ip, command):
    return ['/usr/bin/ssh', '-F', '/dev/null', '-T', '-a', '-x', '-o', 'BatchMode=yes', '-o', 'IdentitiesOnly=yes',
            '-o', 'IdentityAgent=none', '-o', 'StrictHostKeyChecking=yes',
            '-o', 'UserKnownHostsFile=' + str(args.known_hosts), '-i', str(args.identity_file),
            '-o', 'ConnectTimeout=5', '-o', 'ConnectionAttempts=1',
            '-o', 'ClearAllForwardings=yes', '-o', 'PermitLocalCommand=no',
            '-o', 'ProxyCommand=none', '-o', 'ProxyJump=none',
            '-o', 'ServerAliveInterval=5', '-o', 'ServerAliveCountMax=1',
            args.ssh_user + '@' + ip, shlex.join(command)]


def bounded_command(command, timeout):
    started = time.monotonic()
    with subprocess.Popen(command, stdin=subprocess.DEVNULL, stdout=subprocess.PIPE,
                          stderr=subprocess.DEVNULL) as process:
        with ThreadPoolExecutor(max_workers=1) as pool:
            future = pool.submit(process.stdout.read, MAX_OUTPUT + 1)
            try:
                data = future.result(timeout=timeout)
                if len(data) > MAX_OUTPUT:
                    raise ValueError('Probe response too large')
                code = process.wait(timeout=max(0.1, timeout - (time.monotonic() - started)))
                if code:
                    raise ValueError('SSH probe failed')
                return data
            except (FutureTimeout, subprocess.TimeoutExpired, ValueError):
                process.kill()
                process.wait(timeout=3)
                raise ValueError('Bounded SSH probe failed') from None


def node_ready(data, name):
    row = json.loads(data)
    if not isinstance(row, dict) or not isinstance(row.get('metadata'), dict):
        return False
    status = row.get('status', {})
    if not isinstance(status, dict) or not isinstance(status.get('conditions'), list):
        return False
    if row.get('metadata', {}).get('name') != name:
        return False
    ready = any(c.get('type') == 'Ready' and c.get('status') == 'True'
                for c in status.get('conditions', []) if isinstance(c, dict))
    def gpu(field):
        container = status.get(field, {})
        if not isinstance(container, dict):
            return False
        value = container.get('nvidia.com/gpu', '')
        return isinstance(value, str) and value.isdecimal() and 1 <= int(value) <= 1024
    return ready and gpu('capacity') and gpu('allocatable')


def ollama_version(ip, timeout):
    # Never use inherited HTTP proxies or DNS names for the private data path.
    class NoRedirect(urllib.request.HTTPRedirectHandler):
        def redirect_request(self, request, fp, code, msg, headers, newurl):
            raise ValueError('Private probe redirects forbidden')
    opener = urllib.request.build_opener(urllib.request.ProxyHandler({}), NoRedirect())
    request = urllib.request.Request(f'http://{private_ip(ip)}:11434/api/version', method='GET')
    with opener.open(request, timeout=timeout) as response:
        if response.status != 200:
            raise ValueError('Ollama unavailable')
        data = response.read(4097)
    if len(data) > 4096:
        raise ValueError('Ollama response oversized')
    row = json.loads(data)
    value = row.get('version') if isinstance(row, dict) else None
    return isinstance(value, str) and 0 < len(value) < 100


def run_gate(args, runner=bounded_command, version=ollama_version, clock=time.monotonic, sleep=time.sleep):
    deadline = clock() + args.timeout
    phases = []
    def probe(name, callback):
        for attempt in range(6):
            remaining = deadline - clock()
            if remaining <= 0:
                break
            try:
                if callback(min(5, remaining)):
                    phases.append(name)
                    return
            except (OSError, ValueError, TypeError, KeyError):
                pass
            sleep(min(2 ** attempt, 5, max(0, deadline - clock())))
        raise ValueError('Health gate failed in phase ' + name)
    # Wake executes on the Pi in the home network, never as an Internet broadcast.
    runner(ssh(args, args.pi_ip, ['wakeonlan', '-i', '255.255.255.255', args.mac]), min(5, args.timeout))
    phases.append('wake-requested')
    probe('worker-ssh', lambda timeout: runner(ssh(args, args.worker_ip, ['true']), timeout) is not None)
    probe('node-ready-gpu', lambda timeout: node_ready(runner(ssh(args, args.control_ip,
          ['kubectl', 'get', 'node', args.node, '-o', 'json', '--request-timeout=5s']), timeout), args.node))
    probe('ollama-version', lambda timeout: version(args.worker_ip, timeout))
    return {'scope': 'wake-and-version-readiness', 'phases': phases, 'inference_tested': False,
            'models_loaded': False, 'shutdown_requested': False}


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    for field in ('pi-ip', 'worker-ip', 'control-ip', 'mac', 'node', 'ssh-user'):
        parser.add_argument('--' + field, required=True)
    parser.add_argument('--identity-file', type=Path)
    parser.add_argument('--known-hosts', type=Path)
    parser.add_argument('--timeout', type=int, default=90)
    parser.add_argument('--apply', action='store_true')
    parser.add_argument('--confirm-wake', action='store_true')
    args = parser.parse_args(argv)
    try:
        contract(args)
        if not args.apply:
            print(json.dumps({'mode': 'plan', 'network_calls': False,
                              'phases': ['pi-wake', 'worker-ssh', 'node-ready-gpu', 'ollama-version']}))
            return 0
        if (os.name != 'posix' or os.geteuid() == 0 or not args.confirm_wake
                or not args.identity_file or not args.known_hosts):
            raise ValueError('Explicit non-root apply and SSH inputs required')
        secure_input(args.identity_file)
        secure_input(args.known_hosts)
        print(json.dumps(run_gate(args)))
        return 0
    except (OSError, ValueError, TypeError, KeyError):
        print('WoL-Health-Gate nicht bestanden; keine Modelle gestartet und kein Shutdown. '
              'Private Ziele, Hostkeys, Rechte und Bereitschaft pruefen.', file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
