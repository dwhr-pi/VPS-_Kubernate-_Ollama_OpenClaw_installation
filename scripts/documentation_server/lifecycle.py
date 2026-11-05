"""Optional native source installation. No services, browser, Docker or PyPI."""
import argparse
import ast
from contextlib import contextmanager
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import stat
import subprocess
import sys
import tarfile
import tempfile
import uuid

ROOT = Path(__file__).resolve().parents[2]
UPSTREAM = 'https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation.git'
MARKDOWN = 'https://github.com/Python-Markdown/markdown.git'
MARKDOWN_PIN = 'b41e0aaf1181f1a8cb200cf5a815aad7c0020d23'
EXT = {'.md', '.py', '.sh', '.yaml', '.yml', '.json', '.toml', '.txt', '.conf', '.png', '.jpg', '.jpeg', '.gif', '.webp'}


def private_directory(path):
    if not path.is_absolute():
        raise ValueError('Absoluter Workspace erforderlich')
    for part in [*reversed(path.parents), path]:
        if part.is_symlink() or (hasattr(part, 'is_junction') and part.is_junction()):
            raise ValueError('Workspace-Links abgelehnt')
    if path.exists():
        info = path.stat()
        if not path.is_dir() or (hasattr(os, 'getuid') and info.st_uid != os.getuid()):
            raise ValueError('Workspace gehoert nicht diesem Benutzer')
        if os.name != 'nt' and stat.S_IMODE(info.st_mode) & 0o077:
            raise ValueError('Workspace muss privat sein (0700)')
    else:
        path.mkdir(mode=0o700)


def base_path(create=False):
    workspace = Path(os.environ.get('OPENCLAW_USER_DATA_DIR', str(Path.home() / '.openclaw_ultimate_user_data')))
    if workspace.resolve().is_relative_to(ROOT.resolve()):
        raise ValueError('Workspace muss ausserhalb des Repositorys liegen')
    if create:
        private_directory(workspace)
        private_directory(workspace / 'tools')
        private_directory(workspace / 'tools/markdown_docs_server')
    else:
        for path in (workspace, workspace / 'tools', workspace / 'tools/markdown_docs_server'):
            if path.exists() or path.is_symlink():
                private_directory(path)
    return workspace / 'tools/markdown_docs_server'


def write_new(path, data):
    descriptor, temporary = tempfile.mkstemp(prefix='.metadata-', dir=path.parent)
    temporary = Path(temporary)
    try:
        with os.fdopen(descriptor, 'w', encoding='utf-8', newline='\n') as stream:
            json.dump(data, stream, sort_keys=True, indent=2)
            stream.write('\n')
            stream.flush()
            os.fsync(stream.fileno())
        os.link(temporary, path)  # Atomic publication without replacing an existing file.
    finally:
        temporary.unlink()


@contextmanager
def lease(base):
    path = base / 'operation.lock'
    try:
        descriptor = os.open(path, os.O_CREAT | os.O_EXCL | os.O_WRONLY, 0o600)
    except FileExistsError as error:
        raise ValueError('Server/Aktion aktiv oder alte Sperre: zuerst manuell pruefen; nichts geloescht') from error
    identity = os.fstat(descriptor)
    os.write(descriptor, str(os.getpid()).encode('ascii'))
    os.close(descriptor)
    try:
        yield
    finally:
        current = path.lstat()
        if (identity.st_ino, identity.st_dev) != (current.st_ino, current.st_dev):
            raise ValueError('Sperrdatei wurde ausgetauscht; bleibt erhalten')
        path.unlink()


def inventory(app):
    if app.is_symlink() or not app.is_dir():
        raise ValueError('App-Verzeichnis ungueltig')
    result = {}
    for path in sorted(app.rglob('*')):
        if path.is_symlink() or (hasattr(path, 'is_junction') and path.is_junction()):
            raise ValueError('App enthaelt einen Dateilink')
        if path.is_file():
            if path.stat().st_nlink != 1 or path.stat().st_size > 20 * 1024 ** 2:
                raise ValueError('App enthaelt ungueltige Datei')
            result[path.relative_to(app).as_posix()] = hashlib.sha256(path.read_bytes()).hexdigest()
    return result


def verified(base):
    marker = base / 'OWNED.json'
    if marker.is_symlink() or not marker.is_file() or marker.stat().st_nlink != 1 or marker.stat().st_size > 4 * 1024 ** 2:
        raise ValueError('Privater Besitznachweis fehlt')
    data = json.loads(marker.read_text(encoding='utf-8'))
    if data.get('kind') != 'offline-docs-source-v1' or data.get('files') != inventory(base / 'app'):
        raise ValueError('App veraendert oder Besitznachweis ungueltig; keine Aktion')
    return data


def git_env():
    allowed = {'path', 'systemroot', 'windir', 'temp', 'tmp', 'home', 'lang', 'lc_all', 'ssl_cert_file', 'ssl_cert_dir'}
    env = {k: v for k, v in os.environ.items() if k.casefold() in allowed}
    env.update(GIT_CONFIG_NOSYSTEM='1', GIT_CONFIG_GLOBAL=os.devnull, GIT_TERMINAL_PROMPT='0', GCM_INTERACTIVE='never', PYTHONDONTWRITEBYTECODE='1')
    return env


def command(args, **kwargs):
    timeout = kwargs.pop('timeout', 300)
    return subprocess.run(args, env=git_env(), check=True, timeout=timeout, **kwargs)


def source_archive(url, commit, temp, label, paths):
    if not re.fullmatch('[0-9a-f]{40}', commit):
        raise ValueError('Vollstaendiger gepruefter Commit-SHA erforderlich')
    repo = temp / label
    prefix = ['git', '-c', 'core.hooksPath=/dev/null', '-c', 'core.fsmonitor=false', '-c', 'credential.helper=']
    command(prefix + ['init', '--bare', str(repo)], stdout=subprocess.DEVNULL)
    git = prefix + ['--git-dir=' + str(repo)]
    command(git + ['fetch', '--depth=1', '--no-tags', url, commit], stdout=subprocess.DEVNULL)
    actual = command(git + ['rev-parse', 'FETCH_HEAD^{commit}'], capture_output=True, text=True).stdout.strip()
    if actual != commit:
        raise ValueError('GitHub-Quellstand stimmt nicht ueberein')
    archive = temp / (label + '.tar')
    with archive.open('wb') as stream:
        command(git + ['archive', '--format=tar', commit, '--', *paths], stdout=stream)
    if archive.stat().st_size > 128 * 1024 ** 2:
        raise ValueError('Quellarchiv zu gross')
    return archive


def copy_archive(archive, destination, select):
    total = 0
    with tarfile.open(archive, 'r:') as source:
        members = source.getmembers()
        if len(members) > 20000:
            raise ValueError('Zu viele Quelldateien')
        for item in members:
            name = item.name.rstrip('/') if item.isdir() else item.name
            if name.startswith('/') or '\\' in name or ':' in name or any(p in ('', '.', '..') for p in name.split('/')):
                raise ValueError('Unsicherer Archivpfad')
            if item.isdir():
                continue
            if not item.isfile():
                raise ValueError('Links und Spezialdateien sind nicht erlaubt')
            target_name = select(name)
            if target_name is None:
                continue
            if target_name.startswith('content/') and Path(name).suffix.lower() not in {'.png', '.jpg', '.jpeg', '.gif', '.webp'} and item.size > 1024 ** 2:
                continue  # Large inventories are not browser pages; keep request limits meaningful.
            total += item.size
            if item.size > 20 * 1024 ** 2 or total > 128 * 1024 ** 2:
                raise ValueError('Dokumentarchiv ueberschreitet Groessenlimit')
            target = destination / target_name
            target.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
            with source.extractfile(item) as incoming, target.open('xb') as outgoing:
                shutil.copyfileobj(incoming, outgoing)
            target.chmod(0o600)


def select_project(name):
    prefix = 'scripts/documentation_server/'
    if name.startswith(prefix) and name[len(prefix):] in {'server.py', 'web/app.js', 'web/style.css', 'web/index.html'}:
        return name[len(prefix):]
    if name in {'readme.md', 'LICENSE'} or (name.startswith(('docs/', 'config/', 'scripts/')) and Path(name).suffix.lower() in EXT):
        if any(p.startswith('.') for p in name.split('/')):
            return None
        return 'content/' + name
    return None


def install(base, commit, update):
    if shutil.disk_usage(base).free < 512 * 1024 ** 2:
        raise ValueError('Mindestens 512 MiB freier Speicher erforderlich')
    if (base / 'app').exists() or (base / 'OWNED.json').exists():
        if not update:
            raise ValueError('Bereits vorhanden: doctor oder update verwenden')
        verified(base)
    elif update:
        raise ValueError('Zuerst installieren')
    with tempfile.TemporaryDirectory(prefix='source-', dir=base) as temporary:
        temp = Path(temporary)
        stage = temp / 'app'
        stage.mkdir(mode=0o700)
        project = source_archive(UPSTREAM, commit, temp, 'project', ['readme.md', 'LICENSE', 'docs', 'config', 'scripts'])
        copy_archive(project, stage, select_project)
        dependency = source_archive(MARKDOWN, MARKDOWN_PIN, temp, 'markdown', ['markdown', 'LICENSE.md'])
        copy_archive(dependency, stage / 'vendor', lambda n: n if n == 'LICENSE.md' or (n.startswith('markdown/') and n.endswith('.py')) else None)
        content = stage / 'content'
        index = sorted(p.relative_to(content).as_posix() for p in content.rglob('*') if p.is_file())
        write_new(content / 'DOCS_INDEX.json', index)
        for path in stage.rglob('*.py'):
            ast.parse(path.read_text(encoding='utf-8'), filename=str(path))
        command([sys.executable, '-I', '-B', str(stage / 'server.py'), 'check'])
        metadata = dict(kind='offline-docs-source-v1', source=UPSTREAM, source_commit=commit,
                        markdown_commit=MARKDOWN_PIN, files=inventory(stage), runtime_verified=False)
        backup = None
        if update:
            history = base / 'history'
            private_directory(history)
            backup = history / uuid.uuid4().hex
            backup.mkdir(mode=0o700)
            (base / 'app').rename(backup / 'app')
            try:
                (base / 'OWNED.json').rename(backup / 'OWNED.json')
            except BaseException:
                (backup / 'app').rename(base / 'app')
                raise
        try:
            stage.rename(base / 'app')
            write_new(base / 'OWNED.json', metadata)
        except BaseException:
            # Roll back only this new snapshot, never a foreign user directory.
            if (base / 'app').exists():
                shutil.rmtree(base / 'app')
            if backup:
                (backup / 'app').rename(base / 'app')
                (backup / 'OWNED.json').rename(base / 'OWNED.json')
            raise
    print('Quellen eingerichtet und Parser geprueft. Kein Server/Browser gestartet.')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=['install', 'update', 'uninstall', 'status', 'check', 'doctor', 'serve'])
    parser.add_argument('--apply', action='store_true')
    parser.add_argument('--source-commit')
    parser.add_argument('--port', type=int, default=8765)
    args = parser.parse_args()
    if sys.version_info < (3, 11):
        parser.error('Python >=3.11 erforderlich')
    if args.action in {'install', 'update', 'uninstall', 'serve'} and not args.apply:
        print(json.dumps(dict(action=args.action, apply=False, source=UPSTREAM, docker=False, automatic_start=False)))
        return
    if args.action in {'install', 'update'} and not re.fullmatch('[0-9a-f]{40}', args.source_commit or ''):
        parser.error('--source-commit mit bewusst geprueftem GitHub-Commit erforderlich')
    base = base_path(create=args.action == 'install')
    if args.action in {'status', 'check', 'doctor'}:
        data = verified(base)
        print(json.dumps(dict(installed=True, source_commit=data['source_commit'], runtime_verified=False)))
        return
    with lease(base):
        if args.action in {'install', 'update'}:
            install(base, args.source_commit, args.action == 'update')
        elif args.action == 'uninstall':
            verified(base)
            shutil.rmtree(base / 'app')
            (base / 'OWNED.json').unlink()
            print('Nur gepruefte App entfernt; Workspace, Messwerte und Update-Historie bleiben.')
        elif args.action == 'serve':
            verified(base)
            # Foreground child and exclusive lease prevent updates while serving.
            try:
                command([sys.executable, '-I', '-B', str(base / 'app/server.py'), 'serve', '--port', str(args.port)], timeout=None)
            except KeyboardInterrupt:
                pass


if __name__ == '__main__':
    try:
        main()
    except (ValueError, OSError, subprocess.SubprocessError) as error:
        print('Dokumentationsserver: ' + str(error), file=sys.stderr)
        sys.exit(1)
