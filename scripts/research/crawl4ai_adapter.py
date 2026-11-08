"""Offline-only Crawl4AI extraction in a minimal Linux network/mount namespace."""
import json
import os
from pathlib import Path
import stat
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
PIN = 'cae74b203a33994f7e13b9052c3b0d5c93daa0e6'


def sandbox_command(workspace):
    if sys.platform != 'linux':
        raise ValueError('Crawl4AI sandbox requires explicit Linux, no WSL fallback')
    bwrap = Path('/usr/bin/bwrap').resolve()
    info = bwrap.stat()
    if info.st_uid != 0 or stat.S_IMODE(info.st_mode) & 0o022:
        raise ValueError('Root-owned bubblewrap required; install dependency separately')
    venv = workspace / 'tools/crawl4ai/native-github/venv'
    manifest = json.loads((ROOT / 'config/docker_to_github.json').read_text(encoding='utf-8'))
    spec = next(r for r in manifest['tools'] if r['id'] == 'crawl4ai')
    if spec['recipe']['pin'] != PIN:
        raise ValueError('Crawl4AI recipe changed; review extraction contract before use')
    env = {k: v for k, v in os.environ.items() if k in ('PATH', 'HOME', 'LANG', 'LC_ALL')}
    env['OPENCLAW_USER_DATA_DIR'] = str(workspace)
    subprocess.run([sys.executable, '-B', str(ROOT / 'scripts/tools/helpers/native_github_tools.py'), 'crawl4ai', 'doctor'],
                   stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                   env=env, timeout=20, check=True)
    args = [str(bwrap), '--unshare-all', '--die-with-parent', '--new-session', '--clearenv',
            '--setenv', 'HOME', '/tmp', '--setenv', 'PATH', '/usr/bin:/bin',
            '--setenv', 'OPENBLAS_NUM_THREADS', '1', '--setenv', 'OMP_NUM_THREADS', '1',
            '--ro-bind', '/usr', '/usr', '--ro-bind', '/lib', '/lib']
    if Path('/lib64').exists():
        args += ['--ro-bind', '/lib64', '/lib64']
    args += ['--proc', '/proc', '--dev', '/dev', '--tmpfs', '/tmp', '--dir', '/app',
             '--ro-bind', str(venv), '/app/venv', '--ro-bind', str(Path(__file__).with_name('extract_html.py')), '/app/extract_html.py',
             '--chdir', '/tmp', '/app/venv/bin/python', '-I', '-B', '/app/extract_html.py']
    return args, env


def extract(workspace, url, markup):
    if len(markup.encode('utf-8')) > 2 * 1024 ** 2:
        raise ValueError('Extraction input too large')
    command, env = sandbox_command(workspace)
    completed = subprocess.run(command, input=json.dumps(dict(url=url, html=markup)), capture_output=True,
                               text=True, env=env, timeout=20, check=True)
    if len(completed.stdout) > 1024 * 1024:
        raise ValueError('Extraction output too large')
    result = json.loads(completed.stdout)
    if set(result) != {'text'} or not isinstance(result['text'], str) or len(result['text']) > 100000:
        raise ValueError('Invalid extraction result')
    return result['text']
