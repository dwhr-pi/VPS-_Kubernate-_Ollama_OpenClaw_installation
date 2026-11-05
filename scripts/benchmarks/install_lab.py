"""Disposable Linux/WSL build/uninstall measurements. Default: offline plan only."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import platform
import re
import shutil
import signal
import stat
import subprocess
import sys
import tempfile
import time
import uuid

ROOT = Path(__file__).resolve().parents[2]
SUPPORTED = frozenset(('caddy', 'kubeseal', 'traefik', 'argocd_cli', 'cloudflared',
                       'cadvisor', 'minio', 'node_exporter', 'opentelemetry', 'watchtower'))
SAFE_PROBES = {key: ['--version'] for key in SUPPORTED}
SAFE_PROBES.update(caddy=['version'], traefik=['version'], watchtower=['--help'],
                   argocd_cli=['version', '--client', '--short'])
MARKER = Path('/etc/openclaw-install-lab.json')
MIB = 1024 ** 2
ACTIVE_CGROUP = None


def read_json(path):
    if path.is_symlink() or path.stat().st_size > 4 * MIB:
        raise ValueError('Regular bounded JSON file required')
    return json.loads(path.read_text(encoding='utf-8-sig'))


def installer_contract(root):
    digest = hashlib.sha256()
    for path in sorted((root / 'scripts/tools/helpers').iterdir(), key=lambda item: item.name):
        if path.suffix not in ('.py', '.json'):
            continue
        if path.is_symlink() or not path.is_file() or path.stat().st_size > 4 * MIB:
            raise ValueError('Reviewed regular installer inputs required')
        digest.update(path.name.encode() + b'\0')
        # Git archives use LF; approvals must also work from CRLF Windows checkouts.
        digest.update(hashlib.sha256(path.read_bytes().replace(b'\r\n', b'\n')).digest())
    return digest.hexdigest()


def recipe_hash(spec, contract):
    value = {'recipe': spec, 'installer_contract': contract}
    return hashlib.sha256(json.dumps(value, sort_keys=True, separators=(',', ':')).encode()).hexdigest()


def plan(root=ROOT):
    registry = read_json(root / 'config/tools.yml')['tools']
    recipes = {r['id']: r for r in read_json(root / 'config/docker_to_github.json')['tools']}
    contract = installer_contract(root)
    rows = []
    for tool in sorted(registry, key=lambda r: r['id'].casefold()):
        key = tool['id']
        spec = recipes.get(key, {})
        recipe = spec.get('recipe') or {}
        eligible = (key in SUPPORTED and recipe.get('kind') == 'go' and
                    not spec.get('blocked_reason') and
                    recipe.get('source_host', 'github.com') == 'github.com' and
                    bool(re.fullmatch(r'[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+', recipe.get('repo', ''))) and
                    bool(re.fullmatch(r'[a-f0-9]{40}', recipe.get('pin', ''))) and
                    bool(re.fullmatch(r'[a-zA-Z0-9_-]+', recipe.get('binary', ''))) and
                    recipe.get('probe') == SAFE_PROBES.get(key) and
                    type(recipe.get('disk_mb')) is int and recipe['disk_mb'] > 0)
        rows.append({'tool': key, 'eligible': bool(eligible), 'source':
                     'https://github.com/' + recipe['repo'] if eligible else None,
                     'pin': recipe.get('pin') if eligible else None,
                     'recipe_sha256': recipe_hash(spec, contract) if eligible else None,
                     'build_reserve_mib': recipe.get('disk_mb') if eligible else None,
                     'status': 'awaiting_license_approval' if eligible else 'skipped_unsupported_contract',
                     'installed_after_cycle': False, 'executed': False})
    return rows


def approved(row, approvals):
    item = approvals.get(row['tool'], {})
    return (isinstance(item, dict) and item.get('recipe_sha256') == row['recipe_sha256'] and
            item.get('source_and_dependency_terms_reviewed') is True)


def skip_reason(row, approvals, linux_free_mib, host_free_mib, host_reserve_mib):
    if not row['eligible']:
        return 'skipped_unsupported_contract'
    if not approved(row, approvals):
        return 'skipped_license_not_approved'
    required = row['build_reserve_mib'] + 2048
    if linux_free_mib < required or host_free_mib < required + host_reserve_mib:
        return 'skipped_insufficient_space'
    return None


def allocated_mib(path):
    total = 0
    for directory, _dirs, files in os.walk(path, followlinks=False):
        for name in files:
            info = (Path(directory) / name).lstat()
            if stat.S_ISREG(info.st_mode):
                total += getattr(info, 'st_blocks', (info.st_size + 511) // 512) * 512
    return (total + MIB - 1) // MIB


def memory_available_mib():
    for line in Path('/proc/meminfo').read_text().splitlines():
        if line.startswith('MemAvailable:'):
            return int(line.split()[1]) // 1024
    raise ValueError('Available memory cannot be determined')


def validate_lab(name, nonce, marker=MARKER):
    if platform.system() != 'Linux' or os.getuid() == 0:
        raise ValueError('Non-root Linux lab user required; no implicit WSL launch')
    if not re.fullmatch(r'OpenClaw-InstallLab-[A-Za-z0-9-]{1,48}', name):
        raise ValueError('Dedicated lab distribution name required')
    info = marker.lstat()
    if (not stat.S_ISREG(info.st_mode) or info.st_uid != 0 or
            stat.S_IMODE(info.st_mode) != 0o644 or info.st_nlink != 1):
        raise ValueError('Root-owned lab identity required')
    identity = read_json(marker)
    if (identity.get('schema') != 2 or identity.get('distribution') != name or
            identity.get('nonce') != nonce or identity.get('uid') != os.getuid() or
            identity.get('mode') not in ('linux', 'wsl') or
            identity.get('source_root') != str(ROOT) or
            not re.fullmatch(r'[a-f0-9]{40}', identity.get('source_commit', ''))):
        raise ValueError('Lab identity mismatch')
    if not re.fullmatch(r'[a-f0-9]{32}', nonce):
        raise ValueError('Invalid lab identity')
    is_wsl = 'microsoft' in Path('/proc/sys/kernel/osrelease').read_text().lower()
    if identity['mode'] == 'wsl':
        if not is_wsl:
            raise ValueError('WSL lab required')
        mounts = Path('/proc/mounts').read_text()
        if any('drvfs' in line for line in mounts.splitlines()):
            raise ValueError('Windows drive mounts must be disabled')
        interop = Path('/proc/sys/fs/binfmt_misc/WSLInterop')
        if interop.exists() and interop.read_text().splitlines()[0] != 'disabled':
            raise ValueError('Windows interop must be disabled')
    else:
        if is_wsl:
            raise ValueError('Native Linux mode cannot bypass WSL restrictions')
        validate_cgroup(nonce)
    if shutil.which('docker') or shutil.which('podman'):
        raise ValueError('Container tooling is not permitted in this lab')
    if not shutil.rmtree.avoids_symlink_attacks:
        raise ValueError('Descriptor-based cleanup required')
    return identity


def validate_cgroup(nonce):
    global ACTIVE_CGROUP
    suffix = '/openclaw-install-lab-' + nonce + '.service'
    rows = Path('/proc/self/cgroup').read_text().splitlines()
    paths = [line[3:] for line in rows if line.startswith('0::') and line.endswith(suffix)]
    if len(paths) != 1 or '..' in Path(paths[0]).parts:
        raise ValueError('Dedicated systemd cgroup-v2 unit required')
    group = Path('/sys/fs/cgroup') / paths[0].lstrip('/')
    memory = (group / 'memory.max').read_text().strip()
    pids = (group / 'pids.max').read_text().strip()
    cpu = (group / 'cpu.max').read_text().split()
    if (not memory.isdecimal() or not 512 * MIB <= int(memory) <= 32768 * MIB or
            not pids.isdecimal() or not 1 <= int(pids) <= 1024 or
            len(cpu) != 2 or not all(p.isdecimal() for p in cpu) or
            int(cpu[1]) < 1 or not 0 < int(cpu[0]) / int(cpu[1]) <= 2):
        raise ValueError('Finite CPU, RAM and PID limits required')
    if not re.search(r'^NoNewPrivs:\s+1$', Path('/proc/self/status').read_text(), re.M):
        raise ValueError('NoNewPrivileges required')
    ACTIVE_CGROUP = group


def write_report(path, data):
    # New output only. Never overwrite unrelated reports or follow links.
    fd = os.open(path, os.O_CREAT | os.O_EXCL | os.O_WRONLY, 0o600)
    with os.fdopen(fd, 'w', encoding='utf-8') as out:
        json.dump(data, out, indent=2)
        out.flush()
        os.fsync(out.fileno())


def command(args, env, log, seconds, reserve_mib=2048):
    before = shutil.disk_usage(log.parent).free
    minimum = before
    started = time.monotonic()
    reason = None
    with log.open('xb') as out:
        os.chmod(log, 0o600)
        process = subprocess.Popen(args, env=env, stdin=subprocess.DEVNULL, stdout=out,
                                   stderr=subprocess.STDOUT, start_new_session=True)
        try:
            while process.poll() is None:
                minimum = min(minimum, shutil.disk_usage(log.parent).free)
                if time.monotonic() - started > seconds:
                    reason = 'timeout'
                if minimum < reserve_mib * MIB:
                    reason = 'disk_reserve_exhausted'
                if memory_available_mib() < 512:
                    reason = 'memory_reserve_exhausted'
                if reason:
                    os.killpg(process.pid, signal.SIGTERM)
                    try:
                        process.wait(timeout=10)
                    except subprocess.TimeoutExpired:
                        os.killpg(process.pid, signal.SIGKILL)
                        process.wait(timeout=10)
                    break
                time.sleep(0.5)
        except BaseException:
            if process.poll() is None:
                os.killpg(process.pid, signal.SIGKILL)
                process.wait(timeout=10)
            raise
    # An orphaned build must block cleanup and the next tool, not be silently ignored.
    try:
        os.killpg(process.pid, 0)
    except ProcessLookupError:
        group_gone = True
    else:
        group_gone = False
    if ACTIVE_CGROUP is not None:
        group_gone = group_gone and not (
            set((ACTIVE_CGROUP / 'cgroup.procs').read_text().split()) - {str(os.getpid())})
    minimum = min(minimum, shutil.disk_usage(log.parent).free)
    return {'returncode': process.returncode, 'seconds': round(time.monotonic() - started, 3),
            'observed_peak_disk_delta_mib': max(0, before - minimum) // MIB,
            'stop_reason': reason, 'process_group_gone': group_gone}


def cycle(row, approvals, args, root=ROOT):
    home = Path.home()
    if home.is_symlink() or not home.is_dir() or home.stat().st_uid != os.getuid():
        raise ValueError('Owned lab home required')
    reason = skip_reason(row, approvals, shutil.disk_usage(home).free // MIB,
                         args.host_free_mib, args.host_reserve_mib)
    if not reason and memory_available_mib() < 4096:
        reason = 'skipped_insufficient_ram'
    result = dict(row, status=reason or 'running', runtime_verified=False,
                  backend=getattr(args, 'backend', 'unknown'))
    if reason:
        return result
    cycle_started = time.monotonic()
    parent = home / 'install-lab-runs'
    if parent.is_symlink():
        raise ValueError('Linked report root refused')
    parent.mkdir(mode=0o700, exist_ok=True)
    if parent.stat().st_uid != os.getuid() or stat.S_IMODE(parent.stat().st_mode) != 0o700:
        raise ValueError('Private owned report root required')
    run = Path(tempfile.mkdtemp(prefix=row['tool'] + '-', dir=parent))
    data = run / 'data'
    data.mkdir(mode=0o700)
    token = uuid.uuid4().hex
    write_report(data / '.install-lab-owner.json', {'token': token})
    env = {'PATH': '/usr/local/bin:/usr/bin:/bin', 'HOME': str(home), 'LANG': 'C.UTF-8',
           'OPENCLAW_USER_DATA_DIR': str(data), 'PYTHONDONTWRITEBYTECODE': '1',
           'GIT_TERMINAL_PROMPT': '0', 'GIT_CONFIG_NOSYSTEM': '1', 'GIT_CONFIG_GLOBAL': '/dev/null',
           'CI': 'true', 'GOMAXPROCS': '2', 'GOMEMLIMIT': '2GiB'}
    # The helper imports reviewed sibling modules; the child environment has no PYTHONPATH.
    helper = [sys.executable, '-B', str(root / 'scripts/tools/helpers/native_github_tools.py'), row['tool']]
    prefix = data / 'tools' / row['tool'] / 'native-github'
    specs = read_json(root / 'config/docker_to_github.json')['tools']
    recipe = next(s['recipe'] for s in specs if s['id'] == row['tool'])
    result.update(executed=True, report_dir=str(run), phases={}, license_approval=row['recipe_sha256'],
                  source_commit=getattr(args, 'source_commit', None),
                  host_free_mib_before=args.host_free_mib, installed_after_cycle=None,
                  installed_artifacts_verified=False, cleanup_ok=False)
    safe_cleanup = True
    try:
        for phase, argv in (
                ('install', helper + ['install', '--install-build-deps']),
                ('doctor', helper + ['doctor']),
                ('probe', [str(prefix / 'bin' / recipe['binary'])] + recipe['probe'])):
            measurement = command(argv, env, run / (phase + '.log'), args.timeout_seconds)
            result['phases'][phase] = measurement
            safe_cleanup = measurement['process_group_gone'] and not measurement['stop_reason']
            if measurement['returncode'] or measurement['stop_reason'] or not safe_cleanup:
                result['status'] = 'failed_' + phase
                break
        else:
            result.update(status='passed_build_probe', installed_artifacts_verified=True,
                          installed_after_cycle=True, installed_tree_allocated_mib=allocated_mib(prefix),
                          data_with_build_caches_mib=allocated_mib(data))
        if safe_cleanup:
            measurement = command(helper + ['uninstall'], env, run / 'uninstall.log', args.timeout_seconds)
            result['phases']['uninstall'] = measurement
            safe_cleanup = (measurement['returncode'] == 0 and not measurement['stop_reason'] and
                            measurement['process_group_gone'] and not prefix.exists())
            if not safe_cleanup:
                result.update(status='failed_cleanup', installed_after_cycle=None)
        else:
            result['status'] = 'failed_process_cleanup'
        if safe_cleanup:
            # All data/toolchains here were created in this unique run, never in the normal workspace.
            cleanup_started = time.monotonic()
            if (data.parent != run or data.is_symlink() or data.stat().st_uid != os.getuid() or
                    read_json(data / '.install-lab-owner.json') != {'token': token}):
                raise ValueError('Cleanup ownership mismatch')
            shutil.rmtree(data)
            result.update(cleanup_ok=True, installed_after_cycle=False,
                          cleanup_data_seconds=round(time.monotonic() - cleanup_started, 3))
            if result['status'] == 'passed_build_probe':
                result['status'] = 'passed_build_probe_uninstall'
    except (OSError, ValueError, subprocess.SubprocessError):
        result.update(status='failed_supervisor', cleanup_ok=False)
    finally:
        result['total_cycle_seconds'] = round(time.monotonic() - cycle_started, 3)
        result['linux_free_mib_after'] = shutil.disk_usage(run).free // MIB
        result['observed_peak_disk_delta_mib'] = max(
            (m['observed_peak_disk_delta_mib'] for m in result['phases'].values()), default=0)
        write_report(run / 'report.json', result)
    return result


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=('plan', 'run-one', 'run-all'), nargs='?', default='plan')
    parser.add_argument('--tool')
    parser.add_argument('--distribution')
    parser.add_argument('--nonce')
    parser.add_argument('--approvals')
    parser.add_argument('--host-free-mib', type=int, default=0)
    parser.add_argument('--host-reserve-mib', type=int, default=8192)
    parser.add_argument('--timeout-seconds', type=int, default=18000)
    parser.add_argument('--confirm-build-and-uninstall', action='store_true')
    args = parser.parse_args(argv)
    rows = plan()
    if args.action == 'plan':
        print(json.dumps({'executed': False, 'tools': rows}, indent=2))
        return 0
    if not args.confirm_build_and_uninstall or not 60 <= args.timeout_seconds <= 86400:
        raise ValueError('Explicit cycle approval and bounded timeout required')
    identity = validate_lab(args.distribution or '', args.nonce or '')
    args.source_commit = identity['source_commit']
    args.backend = 'wsl2' if identity['mode'] == 'wsl' else 'native-linux'
    if identity['mode'] == 'wsl':
        if args.host_reserve_mib < 2048 or args.host_free_mib < 0 or args.action != 'run-one':
            raise ValueError('WSL requires host-supervised single cycles with a host reserve')
    else:
        args.host_reserve_mib = 0
        args.host_free_mib = shutil.disk_usage(Path.home()).free // MIB
    approvals_path = Path(args.approvals or '')
    approvals = read_json(approvals_path)
    if not isinstance(approvals, dict):
        raise ValueError('Approval mapping required')
    if args.action == 'run-all':
        output = Path.home() / 'cycles.jsonl'
        incomplete = Path.home() / 'CYCLE_INCOMPLETE'
        write_report(incomplete, {'batch_complete': False})
        fd = os.open(output, os.O_CREAT | os.O_EXCL | os.O_WRONLY, 0o600)
        blocked = False
        failed = False
        with os.fdopen(fd, 'w', encoding='utf-8') as stream:
            for row in rows:
                args.host_free_mib = shutil.disk_usage(Path.home()).free // MIB
                if blocked:
                    result = dict(row, status='not_attempted_cleanup_blocked', executed=False)
                else:
                    result = cycle(row, approvals, args)
                stream.write(json.dumps(result) + '\n')
                stream.flush()
                if result.get('executed') and not result.get('cleanup_ok'):
                    blocked = True
                if result['status'].startswith('failed_'):
                    failed = True
        # The owning systemd unit reaps every remaining descendant on exit.
        if not blocked:
            incomplete.unlink()
        return 2 if blocked else (1 if failed else 0)
    row = next((r for r in rows if r['tool'] == args.tool), None)
    if row is None:
        raise ValueError('Registered tool required')
    result = cycle(row, approvals, args)
    print(json.dumps(result))
    if result.get('executed') and not result.get('cleanup_ok'):
        return 2
    return 1 if result['status'].startswith('failed_') else 0


if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except (OSError, ValueError, TypeError, KeyError) as error:
        print(json.dumps({'status': 'refused', 'error_type': type(error).__name__, 'executed': False}))
        raise SystemExit(2)
