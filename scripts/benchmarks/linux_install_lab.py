"""Native Linux lab provisioning is separate, explicit and never adopts existing users."""
import argparse
import io
import json
import os
from pathlib import Path
import re
import stat
import subprocess
import sys
import tarfile
import uuid

# Imports are reviewed repository modules, not downloaded applications.
sys.path.insert(0, str(Path(__file__).resolve().parent))
import install_lab as lab
import install_lab_reports as reports

USER = 'oc-install-lab'
BASE = Path('/var/lib/openclaw-install-lab')


def root_guard():
    if sys.platform != 'linux' or os.geteuid() != 0:
        raise ValueError('Explicit root preparation on a dedicated Linux test host required')
    if 'microsoft' in Path('/proc/sys/kernel/osrelease').read_text().lower():
        raise ValueError('Use the separate WSL launcher, not native host preparation')
    if Path('/proc/1/comm').read_text().strip() != 'systemd':
        raise ValueError('Native test host requires systemd and cgroup v2')
    if not Path('/sys/fs/cgroup/cgroup.controllers').is_file():
        raise ValueError('Cgroup v2 required')
    if __import__('shutil').which('docker') or __import__('shutil').which('podman'):
        raise ValueError('Use a clean test host without container tools')
    for parent in (BASE, *BASE.parents):
        if parent.is_symlink():
            raise ValueError('Linked lab path refused')


def run(argv, **kwargs):
    env = {'PATH': '/usr/sbin:/usr/bin:/sbin:/bin', 'LANG': 'C.UTF-8', 'HOME': '/root',
           'GIT_TERMINAL_PROMPT': '0', 'GIT_CONFIG_GLOBAL': '/dev/null', 'GIT_CONFIG_NOSYSTEM': '1',
           'DEBIAN_FRONTEND': 'noninteractive'}
    return subprocess.run(argv, env=env, check=True, **kwargs)


def prepare(args):
    import grp
    import pwd
    root_guard()
    if not args.confirm_dedicated_test_host or not re.fullmatch(r'[a-f0-9]{40}', args.source_commit or ''):
        raise ValueError('Dedicated host approval and full reviewed source commit required')
    if lab.MARKER.exists() or lab.MARKER.is_symlink() or BASE.exists():
        raise ValueError('Existing lab/identity preserved; no overwrite or adoption')
    for key in (USER, 20000):
        try:
            pwd.getpwnam(key) if isinstance(key, str) else pwd.getpwuid(key)
        except KeyError:
            pass
        else:
            raise ValueError('Existing user or UID refused')
    try:
        grp.getgrnam(USER)
    except KeyError:
        pass
    else:
        raise ValueError('Existing group refused')
    approvals = lab.read_json(Path(args.approvals or ''))
    if not isinstance(approvals, dict) or not any(row['eligible'] and lab.approved(row, approvals) for row in lab.plan()):
        raise ValueError('At least one reviewed recipe/license approval required')
    git = ['git', '-c', 'core.hooksPath=/dev/null', '-c', 'core.fsmonitor=false', '-c', 'credential.helper=',
           '-c', 'safe.directory=' + str(lab.ROOT), '-C', str(lab.ROOT)]
    if run(git + ['cat-file', '-t', args.source_commit], capture_output=True).stdout.strip() != b'commit':
        raise ValueError('A real reviewed commit is required, not a tag/tree/blob')
    for name in ('linux_install_lab.py', 'install_lab.py', 'install_lab_reports.py'):
        content = run(git + ['show', args.source_commit + ':scripts/benchmarks/' + name], capture_output=True).stdout
        if content != Path(__file__).with_name(name).read_bytes():
            raise ValueError('Preparation code must equal the reviewed commit')
    run(git + ['diff', '--no-ext-diff', '--no-textconv', '--quiet', args.source_commit, '--', 'scripts', 'config'])
    data = run(git + ['archive', '--format=tar', args.source_commit], capture_output=True).stdout
    if len(data) > 128 * lab.MIB:
        raise ValueError('Source snapshot too large')
    if args.install_base_deps:
        release = Path('/etc/os-release').read_text()
        if not re.search(r'^ID=(?:"?)(?:ubuntu|debian)(?:"?)$', release, re.M):
            raise ValueError('Automatic base dependencies only on Debian/Ubuntu')
        run(['apt-get', 'update'])
        run(['apt-get', 'install', '-y', '--no-install-recommends', 'python3', 'python3-venv', 'git',
             'ca-certificates', 'curl', 'build-essential', 'pkg-config', 'xz-utils', 'unzip'])
    nonce = uuid.uuid4().hex
    BASE.mkdir(mode=0o755)
    stage = BASE / nonce
    stage.mkdir(mode=0o755)
    source = stage / 'repo'
    source.mkdir(mode=0o755)
    with tarfile.open(fileobj=io.BytesIO(data), mode='r:') as archive:
        for member in archive:
            name = Path(member.name)
            if name.is_absolute() or '..' in name.parts or not (member.isdir() or member.isfile()):
                raise ValueError('Unsafe source archive')
            archive.extract(member, path=source, filter='data')
    home = stage / 'home'
    run(['useradd', '--create-home', '--user-group', '--uid', '20000', '--home-dir', str(home),
         '--shell', '/bin/bash', USER])
    home.chmod(0o700)
    approval_path = home / 'approvals.json'
    lab.write_report(approval_path, approvals)
    os.chown(approval_path, 20000, pwd.getpwnam(USER).pw_gid)
    identity = {'schema': 2, 'mode': 'linux', 'distribution': 'OpenClaw-InstallLab-Linux',
                'nonce': nonce, 'uid': 20000, 'source_root': str(source), 'source_commit': args.source_commit}
    lab.write_report(lab.MARKER, identity)
    lab.MARKER.chmod(0o644)
    print(json.dumps({'prepared': True, 'executed': False, 'identity': identity}))


def start(args):
    root_guard()
    if not args.confirm_build_and_uninstall:
        raise ValueError('Separate build/uninstall approval required')
    identity = lab.read_json(lab.MARKER)
    info = lab.MARKER.lstat()
    if (info.st_uid != 0 or not stat.S_ISREG(info.st_mode) or info.st_nlink != 1 or
            stat.S_IMODE(info.st_mode) != 0o644 or lab.MARKER.is_symlink() or
            identity.get('mode') != 'linux' or not re.fullmatch(r'[a-f0-9]{32}', identity.get('nonce', ''))):
        raise ValueError('Root-owned native lab identity required')
    stage = BASE / identity['nonce']
    source = stage / 'repo'
    home = stage / 'home'
    if (identity.get('source_root') != str(source) or stage.is_symlink() or source.is_symlink() or
            stage.stat().st_uid != 0 or source.stat().st_uid != 0):
        raise ValueError('Lab source ownership mismatch')
    lab.write_report(stage / 'STARTED.json', {'source_commit': identity['source_commit']})
    unit = 'openclaw-install-lab-' + identity['nonce']
    description = 'OpenClaw install-lab ' + identity['nonce']
    command = ['systemd-run', '--quiet', '--wait', '--collect', '--unit=' + unit,
               '--description=' + description,
               '--uid=' + USER, '--gid=' + USER, '--setenv=HOME=' + str(home),
               '--property=MemoryMax=' + str(args.memory_mib) + 'M', '--property=CPUQuota=200%',
               '--property=TasksMax=512', '--property=KillMode=control-group', '--property=RuntimeMaxSec=86400',
               '--property=NoNewPrivileges=yes', '--property=CapabilityBoundingSet=',
               '--property=ProtectSystem=strict', '--property=ProtectHome=yes', '--property=PrivateTmp=yes',
               '--property=ProtectKernelTunables=yes', '--property=ProtectKernelModules=yes',
               '--property=ProtectControlGroups=yes', '--property=ReadWritePaths=' + str(home),
               '/usr/bin/python3', '-I', '-B', str(source / 'scripts/benchmarks/install_lab.py'), 'run-all',
               '--distribution', identity['distribution'], '--nonce', identity['nonce'],
               '--approvals', str(home / 'approvals.json'), '--confirm-build-and-uninstall']
    status = 2
    try:
        run(command)
        status = 0
    except subprocess.CalledProcessError:
        print('Lab unit failed; incomplete measurements are not successful installations.', file=sys.stderr)
    except BaseException:
        # Interrupting the systemd-run client does not itself prove the service stopped.
        actual = run(['systemctl', 'show', unit + '.service', '--property=Description', '--value'],
                     capture_output=True, text=True).stdout.strip()
        if actual != description:
            raise ValueError('Unit ownership unconfirmed; stop refused, manual review required') from None
        run(['systemctl', 'stop', unit + '.service'])
        raise
    finally:
        if (home / 'cycles.jsonl').exists():
            reports.backup_report(home / 'cycles.jsonl', stage / 'measurements-backup.tar',
                                  batch_complete=not (home / 'CYCLE_INCOMPLETE').exists())
            print('Measurement-only backup: ' + str(stage / 'measurements-backup.tar'))
    return status


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=('plan', 'prepare', 'run'), nargs='?', default='plan')
    parser.add_argument('--source-commit')
    parser.add_argument('--approvals')
    parser.add_argument('--confirm-dedicated-test-host', action='store_true')
    parser.add_argument('--install-base-deps', action='store_true')
    parser.add_argument('--confirm-build-and-uninstall', action='store_true')
    parser.add_argument('--memory-mib', type=int, default=4096)
    args = parser.parse_args(argv)
    if args.action == 'plan':
        print(json.dumps({'executed': False, 'mode': 'native-linux', 'tools': lab.plan()}, indent=2))
        return 0
    if not 2048 <= args.memory_mib <= 32768:
        raise ValueError('Finite memory budget required')
    if args.action == 'prepare':
        prepare(args)
        return 0
    return start(args)


if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except (OSError, ValueError, KeyError, TypeError, subprocess.SubprocessError):
        print('Native lab refused; existing accounts, data and services are not adopted.', file=sys.stderr)
        raise SystemExit(2)
