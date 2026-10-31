"""Optional local coding workbench with enforced, one-shot Linux isolation."""
import argparse
from contextlib import contextmanager
import hashlib
import json
import os
from pathlib import Path
import platform
import re
import shutil
import stat
import subprocess
import sys
import tempfile
import uuid

ROOT = Path(__file__).resolve().parents[2]
LIMITS = {'memory': '2g', 'cpus': '2', 'pids': 128, 'seconds': 900, 'model_requests': 16}
sys.path.insert(0, str(ROOT / 'scripts/lib'))
sys.path.insert(0, str(Path(__file__).resolve().parent))
from repo_safety import git, SafetyError
from model_broker import Broker, endpoint, model_name, start
from worker_entry import configurations


class CleanupUnconfirmed(ValueError):
    pass


def catalog():
    return json.loads((ROOT / 'config/agents/workbench.json').read_text())


def safe(path):
    path = Path(path)
    if not path.is_absolute() or '..' in path.parts or path.parent == path or any(c in str(path) for c in ',\r\n\x00'):
        raise ValueError('Canonical absolute non-root path required')
    for part in (path, *path.parents):
        if part.is_symlink() or (hasattr(part, 'is_junction') and part.is_junction()):
            raise ValueError('Symlink/junction path denied')
    if path != path.resolve():
        raise ValueError('Non-canonical path denied')
    return path


def private_directory(path):
    safe(path).mkdir(parents=True, mode=0o700, exist_ok=True)
    if os.name == 'posix':
        info = path.stat()
        if info.st_uid != os.getuid() or stat.S_IMODE(info.st_mode) != 0o700:
            raise ValueError('Existing private directory must be owned with mode 0700')
    return path


def private_root():
    path = safe(Path(os.environ.get('OPENCLAW_USER_DATA_DIR', str(Path.home() / '.openclaw_ultimate_user_data'))))
    if path == Path.home().resolve() or path == ROOT or path.is_relative_to(ROOT):
        raise ValueError('Separate private workspace required')
    return path


def encode(value):
    return (json.dumps(value, indent=2, ensure_ascii=True) + '\n').encode()


def write_new(path, payload):
    safe(path)
    if path.exists():
        if path.stat().st_nlink != 1 or path.read_bytes() != payload:
            raise ValueError('Existing modified/linked file preserved; choose a new configuration')
        if os.name == 'posix' and (path.stat().st_uid != os.getuid() or stat.S_IMODE(path.stat().st_mode) != 0o600):
            raise ValueError('Existing configuration ownership/mode is unsafe')
        return
    descriptor = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
    with os.fdopen(descriptor, 'wb') as output:
        output.write(payload)
        output.flush()
        os.fsync(output.fileno())


@contextmanager
def locked(base):
    lock = safe(base / '.operation-lock')
    lock.mkdir(mode=0o700)
    retain = False
    try:
        yield
    except CleanupUnconfirmed:
        retain = not (base / '.cleanup-review-required').is_file()
        raise
    finally:
        if not retain:
            lock.rmdir()


def configure(agent, model, base, apply=False):
    if agent not in catalog()['agents']:
        raise ValueError('Unknown adapter')
    model_name(model)
    endpoint(base)
    target = private_root() / 'coding_workbench' / agent
    value = configurations(agent, model, 'plan', base=base.rstrip('/'))
    result = {'agent': agent, 'target': str(target), 'action': 'configure-only',
              'model': model, 'model_verified': False, 'runtime_started': False}
    if apply:
        private_directory(private_root())
        private_directory(target)
        with locked(target):
            content = value.encode() if isinstance(value, str) else encode(value)
            write_new(target / ('config.toml' if agent == 'codex_cli' else 'client.json'), content)
            write_new(target / 'configured.json', encode(result))
    return result


def create_worktree(repo, destination, branch, apply=False):
    repo, destination = safe(Path(repo)), safe(Path(destination))
    if not re.fullmatch(r'agents/[A-Za-z0-9][A-Za-z0-9_-]{0,63}', branch):
        raise ValueError('Dedicated agents/NAME branch required')
    if destination.exists() or destination.is_relative_to(repo) or repo.is_relative_to(destination):
        raise ValueError('New separate worktree destination required')
    revision = git(repo, 'rev-parse', 'HEAD').stdout.decode().strip()
    if not re.fullmatch(r'[a-f0-9]{40}', revision):
        raise ValueError('Expected full source commit')
    if git(repo, 'status', '--porcelain').stdout.strip():
        raise ValueError('Source repository must be clean')
    if apply:
        git(repo, 'worktree', 'add', '-b', branch, str(destination), revision)
    return {'branch': branch, 'destination': str(destination), 'commit': revision, 'created': apply}


def validate_worktree(path):
    path = safe(Path(path))
    control = safe(path / '.git')
    if not control.is_file() or control.stat().st_nlink != 1:
        raise ValueError('Linked Git worktree required; main checkout is not an agent workspace')
    top = git(path, 'rev-parse', '--show-toplevel').stdout.decode().strip()
    branch = git(path, 'branch', '--show-current').stdout.decode().strip()
    if Path(top).resolve() != path or not re.fullmatch(r'agents/[A-Za-z0-9][A-Za-z0-9_-]{0,63}', branch):
        raise ValueError('Only dedicated agents/NAME worktrees may be mounted')
    if git(path, 'status', '--porcelain').stdout.strip():
        raise ValueError('Worktree must be clean before a new run')
    # Filename guard is not a DLP scanner. User must review the selected source tree.
    for directory, dirs, files in os.walk(path, followlinks=False):
        for name in dirs + files:
            item = safe(Path(directory) / name)
            info = item.lstat()
            if not (stat.S_ISDIR(info.st_mode) or stat.S_ISREG(info.st_mode)):
                raise ValueError('Special files and host sockets are not agent input')
            if stat.S_ISREG(info.st_mode) and info.st_nlink != 1:
                raise ValueError('Hardlinked project files are not isolated')
            if item == control:
                continue
            if (name in ('.ssh', '.aws', '.kube', '.gnupg', 'secrets', 'auth.json', 'wallet.json') or
                    name.endswith(('.pem', '.key', '.p12', '.age')) or
                    (name.startswith('.env') and not name.endswith(('.example', '.template')))):
                raise ValueError('Potential credential material in worktree; remove it before mounting')
    return hashlib.sha256(control.read_bytes()).hexdigest()


def image(value):
    if not re.fullmatch(r'[a-z0-9][a-z0-9./:_-]+@sha256:[a-f0-9]{64}', value):
        raise ValueError('Explicit reviewed OCI image digest required; tags are insufficient')
    return value


def docker_command(agent, role, model, worktree, image_ref, run_dir, run_id):
    limits = LIMITS
    readonly = role != 'implement'
    return ['docker', '--host', 'unix:///var/run/docker.sock', 'run', '--rm', '--pull=never',
            '--name', run_id, '--label', 'llmops.run=' + run_id, '--network', 'none',
            '--read-only', '--cap-drop=ALL', '--security-opt=no-new-privileges:true',
            '--user', str(os.getuid()) + ':' + str(os.getgid()), '--init',
            '--cpus', limits['cpus'], '--memory', limits['memory'], '--memory-swap', limits['memory'],
            '--pids-limit', str(limits['pids']), '--ulimit', 'nofile=256:256',
            '--ulimit', 'fsize=8388608:8388608',
            '--log-driver', 'none', '--tmpfs', '/tmp:rw,nosuid,nodev,noexec,size=512m,mode=1777',
            '--mount', 'type=bind,src=' + str(worktree) + ',dst=/workspace' + (',readonly' if readonly else ''),
            '--mount', 'type=bind,src=' + str(worktree / '.git') + ',dst=/workspace/.git,readonly',
            '--mount', 'type=bind,src=' + str(ROOT / 'scripts/agents') + ',dst=/runner,readonly',
            '--mount', 'type=bind,src=' + str(run_dir / 'policy') + ',dst=/policy,readonly',
            '--mount', 'type=bind,src=' + str(run_dir / 'broker') + ',dst=/broker,readonly',
            '--mount', 'type=bind,src=' + str(run_dir / 'result.txt') + ',dst=/result.txt',
            '--workdir', '/workspace', '--entrypoint', 'python3', image_ref, '-B', '/runner/worker_entry.py']


def run_worker(args):
    model_name(args.model)
    endpoint(args.ollama_url)
    image(args.image)
    tree = safe(Path(args.worktree))
    if args.agent not in catalog()['agents'] or args.role not in catalog()['roles']:
        raise ValueError('Unknown agent or role')
    # Pure plan does not read secrets, probe Git/Docker/Ollama or create directories.
    if not args.run:
        return {'action': 'offline-plan', 'agent': args.agent, 'role': args.role, 'image': args.image,
                'worktree': str(tree), 'model': args.model, 'network': 'none',
                'requires': ['Linux nonroot worker', 'reviewed local image with Python+CLI/SDK',
                             'clean agents/NAME worktree', 'explicit --run --confirm', 'present local model']}
    if not args.confirm:
        raise ValueError('Run requires separate --confirm')
    if platform.system() != 'Linux' or os.geteuid() == 0:
        raise ValueError('Execution currently requires a nonroot Linux worker; no implicit WSL/SSH')
    if safe(private_root() / 'coding_workbench/.cleanup-review-required').exists():
        raise CleanupUnconfirmed('Previous container cleanup needs manual review')
    control_hash = validate_worktree(tree)
    prompt_path = safe(Path(args.prompt_file))
    if not prompt_path.is_file() or prompt_path.stat().st_size > 64 * 1024:
        raise ValueError('Regular prompt file, at most 64 KiB required')
    prompt = prompt_path.read_bytes()
    prompt.decode('utf-8')
    root = private_directory(private_root())
    base = private_directory(root / 'coding_workbench')
    if (base / '.cleanup-review-required').exists():
        raise CleanupUnconfirmed('Previous container cleanup needs manual review')
    if any(shutil.disk_usage(path).free < 512 * 1024**2 for path in (base, tree)):
        raise ValueError('At least 512 MiB free workspace reserve required; no cleanup attempted')
    run_id = 'llmops-agent-' + uuid.uuid4().hex
    # Lock outside the agent mount. Crash leftovers block, never get auto-unlocked.
    with locked(base), tempfile.TemporaryDirectory(prefix='run-', dir=base) as temporary:
        if safe(base / '.cleanup-review-required').exists():
            raise CleanupUnconfirmed('Previous container cleanup needs manual review')
        run_dir = Path(temporary)
        (run_dir / 'policy').mkdir(mode=0o700)
        (run_dir / 'broker').mkdir(mode=0o700)
        write_new(run_dir / 'policy/prompt.txt', prompt)
        write_new(run_dir / 'policy/run.json', encode({'agent': args.agent, 'role': args.role, 'model': args.model}))
        write_new(run_dir / 'result.txt', b'')
        env = {key: value for key, value in os.environ.items() if key in ('PATH', 'LANG', 'LC_ALL')}
        env.update(HOME=str(run_dir), DOCKER_CONFIG=str(run_dir / 'docker-config'))
        docker = ['docker', '--host', 'unix:///var/run/docker.sock']
        # Local inspect only. Never pulls/builds images or starts Docker.
        subprocess.run(docker + ['image', 'inspect', args.image], env=env, check=True,
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=15)
        broker = Broker(args.ollama_url, args.model, LIMITS['model_requests'], LIMITS['seconds'])
        digest = broker.local_model()
        server = start(run_dir / 'broker/model.sock', broker)
        result = None
        try:
            try:
                result = subprocess.run(docker_command(args.agent, args.role, args.model, tree, args.image, run_dir, run_id),
                                        env=env, check=False, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                                        timeout=LIMITS['seconds'])
            finally:
                # Remove only this run's labelled container, including on timeout.
                try:
                    state = subprocess.run(docker + ['inspect', '--format', '{{json .Config.Labels}}', run_id],
                                           env=env, capture_output=True, text=True, timeout=15)
                    if state.returncode == 0:
                        labels = json.loads(state.stdout)
                        if labels.get('llmops.run') != run_id:
                            raise CleanupUnconfirmed('Container ownership mismatch; cleanup refused')
                        subprocess.run(docker + ['rm', '--force', run_id], env=env, check=True,
                                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=20)
                    else:
                        absent = subprocess.run(docker + ['container', 'ls', '--all', '--filter',
                                                'name=^/' + run_id + '$', '--format', '{{.ID}}'],
                                                env=env, capture_output=True, text=True, timeout=15)
                        if absent.returncode or absent.stdout.strip():
                            raise CleanupUnconfirmed('Container absence could not be confirmed')
                except BaseException:
                    try:
                        write_new(base / '.cleanup-review-required', encode({'run': run_id,
                                  'worktree': str(tree), 'reason': 'container termination unconfirmed'}))
                    finally:
                        raise CleanupUnconfirmed('Container termination unconfirmed; manual review required') from None
        finally:
            server.shutdown()
            server.server_close()
            report = safe(run_dir / 'result.txt')
            if report.stat().st_nlink != 1 or report.stat().st_size > 8 * 1024 * 1024:
                raise ValueError('Worker report ownership/size check failed')
            reports = private_directory(base / 'reports')
            write_new(reports / (run_id + '.txt'), report.read_bytes())
            print('Private untrusted worker transcript: ' + str(reports / (run_id + '.txt')), file=sys.stderr)
        if hashlib.sha256((tree / '.git').read_bytes()).hexdigest() != control_hash:
            raise ValueError('Git control file changed; no further Git operation permitted')
        if result is None or result.returncode:
            raise ValueError('Worker failed; project changes preserved, no commit/push/deploy')
        return {'action': 'completed', 'agent': args.agent, 'role': args.role, 'model_digest': digest,
                'report': str(reports / (run_id + '.txt')),
                'remaining_model_requests': broker.remaining, 'committed': False, 'published': False}


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest='action', required=True)
    build = commands.add_parser('image-plan')
    build.add_argument('--base-image', required=True)
    cfg = commands.add_parser('configure')
    cfg.add_argument('--agent', choices=catalog()['agents'], required=True)
    cfg.add_argument('--model', required=True)
    cfg.add_argument('--ollama-url', default='http://127.0.0.1:11434')
    cfg.add_argument('--apply', action='store_true')
    wt = commands.add_parser('worktree')
    wt.add_argument('--repo', required=True)
    wt.add_argument('--destination', required=True)
    wt.add_argument('--branch', required=True)
    wt.add_argument('--confirm', action='store_true')
    run = commands.add_parser('worker')
    run.add_argument('--agent', choices=catalog()['agents'], required=True)
    run.add_argument('--role', choices=catalog()['roles'], default='plan')
    run.add_argument('--model', required=True)
    run.add_argument('--image', required=True)
    run.add_argument('--worktree', required=True)
    run.add_argument('--prompt-file')
    run.add_argument('--ollama-url', default='http://127.0.0.1:11434')
    run.add_argument('--run', action='store_true')
    run.add_argument('--confirm', action='store_true')
    args = parser.parse_args(argv)
    try:
        if args.action == 'image-plan':
            result = {'action': 'build-plan-only', 'executed': False, 'argv': ['docker', 'build',
                      '--build-arg', 'BASE_IMAGE=' + image(args.base_image), '--tag', 'llmops-openhands-worker:reviewed',
                      str(ROOT / 'containers/openhands-worker')]}
        elif args.action == 'configure':
            result = configure(args.agent, args.model, args.ollama_url, args.apply)
        elif args.action == 'worktree':
            result = create_worktree(args.repo, args.destination, args.branch, args.confirm)
        else:
            result = run_worker(args)
        print(json.dumps(result, indent=2))
        return 0
    except (ValueError, OSError, TypeError, SafetyError, subprocess.SubprocessError):
        print('Coding workbench refused or failed; no automatic retry/deploy/rollback of project data.', file=sys.stderr)
        return 2


if __name__ == '__main__':
    sys.exit(main())
