#!/usr/bin/env python3
"""Verified repository snapshots and explicit, data-preserving source updates."""
import argparse
from contextlib import contextmanager
from datetime import datetime, timezone
import hashlib
import errno
import json
import os
from pathlib import Path, PurePosixPath
import shutil
import stat
import subprocess
import sys
import tarfile
import tempfile
from urllib.parse import urlsplit


class SafetyError(Exception):
    pass


def digest(stream):
    result = hashlib.sha256()
    for block in iter(lambda: stream.read(1024 * 1024), b''):
        result.update(block)
    return result.hexdigest()


def file_digest(file):
    with file.open('rb') as stream:
        return digest(stream)


def git(repo, *args, allowed=(0,)):
    env = dict(os.environ, GIT_OPTIONAL_LOCKS='0', GIT_TERMINAL_PROMPT='0', GIT_LFS_SKIP_SMUDGE='1')
    for key in list(env):
        if key.startswith('GIT_TRACE') or key in ('GIT_CURL_VERBOSE', 'GIT_SSL_NO_VERIFY'):
            env.pop(key)
    command = ['git', '-c', 'core.hooksPath=' + os.devnull, '-c', 'core.fsmonitor=false',
               '-c', 'http.followRedirects=false', '-c', 'http.sslVerify=true']
    if env.get('GIT_ASKPASS'):
        command += ['-c', 'credential.helper=', '-c', 'credential.useHttpPath=false']
    try:
        result = subprocess.run(command + ['-C', str(repo), *args], env=env, capture_output=True,
                                timeout=120 if args and args[0] in ('fetch', 'ls-remote') else 30)
    except subprocess.TimeoutExpired:
        raise SafetyError('Git-Zeitlimit erreicht; keine Erfolgsmeldung. Vorhandene Sicherungen bleiben erhalten.') from None
    if result.returncode not in allowed:
        # Git errors can contain credential-bearing URLs: never echo them.
        raise SafetyError('Git-Schritt fehlgeschlagen; keine Git-Ausgabe mit moeglichen Zugangsdaten ausgegeben.')
    return result


def repository(path):
    raw = Path(path).absolute()
    repo = raw.resolve(strict=True)
    if raw != repo or repo.parent == repo or not (repo / '.git').is_dir() or (repo / '.git').is_symlink():
        raise SafetyError('Normaler, kanonischer Git-Checkout erforderlich; keine Symlinks/Linked Worktrees.')
    top = git(repo, 'rev-parse', '--show-toplevel').stdout.decode().strip()
    if Path(top).resolve() != repo:
        raise SafetyError('Ziel ist nicht die Wurzel des Checkouts.')
    if (repo / '.git/objects/info/alternates').exists():
        raise SafetyError('Shared-Object-Checkout braucht einen gesonderten Sicherungsplan.')
    if any(item.is_symlink() for item in (repo / '.git').rglob('*')):
        raise SafetyError('Verknuepfte Git-Metadaten sind kein eigenstaendig sicherbarer Checkout.')
    if any(line.startswith(b'160000 ') for line in git(repo, 'ls-files', '--stage').stdout.splitlines()):
        raise SafetyError('Submodule brauchen einen gesonderten Sicherungsplan.')
    for item in (repo / '.git').rglob('*.lock'):
        if item.exists():
            raise SafetyError('Git-Lock vorhanden; keine parallele Git-Operation erlaubt.')
    remotes = git(repo, 'config', '--get-regexp', r'^remote\..*\.(url|pushurl)$', allowed=(0, 1)).stdout
    for row in remotes.decode(errors='replace').splitlines():
        parts = row.split(None, 1)
        if len(parts) == 2 and '://' in parts[1]:
            try:
                parsed = urlsplit(parts[1])
                if parsed.username or parsed.password:
                    raise SafetyError('Remote enthaelt Zugangsdaten. URL bereinigen und betroffenen Token pruefen; kein Fetch ausgefuehrt.')
            except ValueError:
                raise SafetyError('Ungueltige Remote-URL; keine Netzwerkaktion.') from None
    return repo


def private_directory(path):
    path = Path(path).absolute()
    if path != path.resolve() or path.parent == path:
        raise SafetyError('Kanonisches privates Sicherungsverzeichnis erforderlich.')
    path.mkdir(mode=0o700, parents=True, exist_ok=True)
    if os.name == 'posix':
        info = path.stat()
        if info.st_uid != os.geteuid() or stat.S_IMODE(info.st_mode) != 0o700:
            raise SafetyError('Sicherungsverzeichnis muss eigen und Modus 0700 sein.')
    return path


def entries(repo):
    result = []
    for directory, dirs, files in os.walk(repo, followlinks=False):
        for name in sorted(dirs + files):
            file = Path(directory) / name
            info = file.lstat()
            row = {'path': file.relative_to(repo).as_posix(), 'mode': stat.S_IMODE(info.st_mode)}
            if stat.S_ISLNK(info.st_mode):
                row.update(type='symlink', target=os.readlink(file))
            elif stat.S_ISDIR(info.st_mode):
                row.update(type='directory')
            elif stat.S_ISREG(info.st_mode):
                row.update(type='file', size=info.st_size, sha256=file_digest(file))
            else:
                raise SafetyError('Spezialdatei im Checkout; Sicherung wird nicht als vollstaendig ausgegeben.')
            result.append(row)
    return sorted(result, key=lambda row: row['path'])


def checked_name(name):
    item = PurePosixPath(name)
    if (not name or item.is_absolute() or '..' in item.parts or '\\' in name or
            ':' in name or item.as_posix() != name or name == '.'):
        raise SafetyError('Unsicherer Archivpfad.')
    return name


def verify(snapshot, require_marker=True):
    snapshot = Path(snapshot).resolve(strict=True)
    for name in ('manifest.json', 'repository.tar') + (('VERIFIED',) if require_marker else ()):
        file = snapshot / name
        if not file.is_file() or file.is_symlink():
            raise SafetyError('Sicherung unvollstaendig oder nicht verifiziert.')
    manifest_bytes = (snapshot / 'manifest.json').read_bytes()
    if require_marker and hashlib.sha256(manifest_bytes).hexdigest() != (snapshot / 'VERIFIED').read_text().strip():
        raise SafetyError('Manifest-Pruefsumme stimmt nicht.')
    manifest = json.loads(manifest_bytes)
    if manifest.get('format') != 1 or file_digest(snapshot / 'repository.tar') != manifest['archive_sha256']:
        raise SafetyError('Archiv-Pruefsumme stimmt nicht.')
    rows = manifest['entries']
    expected = {checked_name(row['path']): row for row in rows}
    if len(expected) != len(rows):
        raise SafetyError('Doppelte Manifestpfade.')
    for name in expected:
        for parent in PurePosixPath(name).parents:
            if str(parent) in expected and expected[str(parent)]['type'] != 'directory':
                raise SafetyError('Archivpfad liegt unter einer Datei oder einem Symlink.')
    seen = set()
    with tarfile.open(snapshot / 'repository.tar', 'r:') as archive:
        for member in archive:
            name = checked_name(member.name)
            if name in seen or name not in expected:
                raise SafetyError('Unerwarteter oder doppelter Archiveintrag.')
            seen.add(name)
            row = expected[name]
            if member.mode != row['mode']:
                raise SafetyError('Dateimodus stimmt nicht.')
            if row['type'] == 'file':
                if not member.isfile() or member.size != row['size']:
                    raise SafetyError('Dateityp oder Groesse stimmt nicht.')
                with archive.extractfile(member) as stream:
                    if digest(stream) != row['sha256']:
                        raise SafetyError('Datei-Pruefsumme stimmt nicht.')
            elif row['type'] == 'directory':
                if not member.isdir():
                    raise SafetyError('Verzeichnistyp stimmt nicht.')
            elif row['type'] == 'symlink':
                if not member.issym() or member.linkname != row['target']:
                    raise SafetyError('Symlink stimmt nicht.')
            else:
                raise SafetyError('Unbekannter Dateityp.')
    if seen != set(expected):
        raise SafetyError('Archiv ist unvollstaendig.')
    return manifest


def backup_path(repo, backup_root):
    root = Path(backup_root).absolute()
    resolved = root.resolve()
    if resolved.is_relative_to(repo) or repo.is_relative_to(resolved):
        raise SafetyError('Sicherungsziel und Checkout duerfen einander nicht enthalten.')
    if root != resolved:
        raise SafetyError('Sicherungsziel darf keine Symlink-Komponenten enthalten.')
    return root


def backup(repo, backup_root):
    repo = repository(repo)
    root = backup_path(repo, backup_root)
    root = private_directory(root)
    before = entries(repo)
    required = sum(row.get('size', 0) for row in before) + len(before) * 2048 + 512 * 1024**2
    if shutil.disk_usage(root).free < required:
        raise SafetyError('Zu wenig Speicher fuer vollstaendige Sicherung plus 512 MiB Reserve; kein Update.')
    snapshot = Path(tempfile.mkdtemp(prefix=datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ-'), dir=root))
    archive_path = snapshot / 'repository.tar'
    # No exclusions: include index, local refs/commits, ignored and untracked files.
    with archive_path.open('xb') as output:
        os.chmod(archive_path, 0o600)
        with tarfile.open(fileobj=output, mode='w', format=tarfile.PAX_FORMAT) as archive:
            for row in before:
                member = tarfile.TarInfo(checked_name(row['path']))
                member.mode = row['mode']
                if row['type'] == 'file':
                    member.size = row['size']
                    with (repo / row['path']).open('rb') as stream:
                        archive.addfile(member, stream)
                else:
                    member.type = tarfile.DIRTYPE if row['type'] == 'directory' else tarfile.SYMTYPE
                    member.linkname = row.get('target', '')
                    archive.addfile(member)
        output.flush()
        os.fsync(output.fileno())
    if entries(repo) != before:
        raise SafetyError('Checkout hat sich waehrend der Sicherung geaendert. Unvollstaendige Sicherung bleibt erhalten; kein Update.')
    manifest = {'format': 1, 'head': git(repo, 'rev-parse', 'HEAD').stdout.decode().strip(),
                'archive_sha256': file_digest(archive_path), 'entries': before}
    manifest_path = snapshot / 'manifest.json'
    manifest_path.write_text(json.dumps(manifest, ensure_ascii=True, sort_keys=True), encoding='utf-8')
    os.chmod(manifest_path, 0o600)
    verify(snapshot, require_marker=False)
    marker = snapshot / 'VERIFIED'
    marker.write_text(file_digest(manifest_path) + '\n', encoding='ascii')
    os.chmod(marker, 0o600)
    verify(snapshot)
    return snapshot


def tracked_clean(repo):
    # Plumbing commands do not refresh the index's cached worktree metadata.
    return (git(repo, 'diff-files', '--quiet', '--', allowed=(0, 1)).returncode == 0 and
            git(repo, 'diff-index', '--cached', '--quiet', 'HEAD', '--', allowed=(0, 1)).returncode == 0)


def restore(snapshot, destination):
    manifest = verify(snapshot)
    destination = Path(destination).absolute()
    if destination.exists() or destination.is_symlink() or destination != destination.resolve():
        raise SafetyError('Restore ist nur in ein neues kanonisches Ziel erlaubt, nie ueber einen vorhandenen Checkout.')
    destination.mkdir(mode=0o700)
    directories = [row for row in manifest['entries'] if row['type'] == 'directory']
    by_name = {row['path']: row for row in manifest['entries']}
    for row in directories:
        (destination / row['path']).mkdir(mode=0o700, parents=True, exist_ok=True)
    with tarfile.open(Path(snapshot) / 'repository.tar', 'r:') as archive:
        for member in archive:
            row = by_name[member.name]
            target = destination / member.name
            if row['type'] == 'file':
                with target.open('xb') as output, archive.extractfile(member) as stream:
                    shutil.copyfileobj(stream, output)
                os.chmod(target, row['mode'])
        # Create symlinks last so extraction never follows an archive-created link.
        for row in manifest['entries']:
            if row['type'] == 'symlink':
                os.symlink(row['target'], destination / row['path'])
    for row in reversed(directories):
        os.chmod(destination / row['path'], row['mode'])
    if entries(destination) != manifest['entries']:
        raise SafetyError('Restore-Vergleich fehlgeschlagen; Ziel bleibt zur Diagnose erhalten.')
    return destination


def collision_check(repo, target):
    tracked = set(git(repo, 'ls-files', '-z').stdout.decode().split('\0'))
    targets = set(git(repo, 'ls-tree', '-r', '--name-only', '-z', target).stdout.decode().split('\0')) - {''}
    for row in entries(repo):
        name = row['path']
        if name == '.git' or name.startswith('.git/') or row['type'] == 'directory' or name in tracked:
            continue
        if any(name == item or name.startswith(item + '/') or item.startswith(name + '/') for item in targets):
            raise SafetyError('Unversionierte/ignorierte Datei kollidiert mit dem Ziel; keine Dateien werden automatisch geloescht.')


@contextmanager
def operation_lock(root):
    root = private_directory(root)
    lock = root / 'update.lock'
    if lock.is_symlink():
        raise SafetyError('Unsichere Lock-Datei.')
    with lock.open('a') as stream:
        os.chmod(lock, 0o600)
        if os.name == 'posix':
            import fcntl
            try:
                fcntl.flock(stream, fcntl.LOCK_EX | fcntl.LOCK_NB)
            except BlockingIOError:
                raise SafetyError('Eine Sicherungs-/Update-Operation laeuft bereits.') from None
        yield


def sync(repo, root, ref, fetch=False):
    repo = repository(repo)
    root = backup_path(repo, root)
    if not ref or ref.startswith('-') or any(char.isspace() for char in ref):
        raise SafetyError('Ungueltige Zielreferenz.')
    before = entries(repo)
    if fetch:
        if ref != 'origin/main':
            raise SafetyError('Automatischer Fetch ist nur fuer origin/main freigegeben.')
        remote = git(repo, 'ls-remote', '--exit-code', 'origin', 'refs/heads/main').stdout.split()
        head = git(repo, 'rev-parse', 'HEAD').stdout.strip()
        if remote and remote[0] == head and tracked_clean(repo):
            return {'status': 'unchanged', 'backup': None}
    snapshot = None
    with operation_lock(root):
        if fetch:
            snapshot = backup(repo, root)
            git(repo, 'fetch', '--no-tags', 'origin', 'main')
            after_fetch = [r for r in entries(repo) if r['path'] != '.git' and not r['path'].startswith('.git/')]
            if after_fetch != [r for r in before if r['path'] != '.git' and not r['path'].startswith('.git/')]:
                raise SafetyError('Arbeitsdateien wurden parallel geaendert; Update abgebrochen.')
        target = git(repo, 'rev-parse', '--verify', '--end-of-options', ref + '^{commit}').stdout.decode().strip()
        collision_check(repo, target)
        head = git(repo, 'rev-parse', 'HEAD').stdout.decode().strip()
        if target == head and tracked_clean(repo):
            return {'status': 'unchanged', 'backup': str(snapshot) if snapshot else None}
        if snapshot is None:
            snapshot = backup(repo, root)
        verify(snapshot)
        # Keep local branch refs/commits and all non-colliding untracked files.
        # A failed checkout is not automatically overwritten by a restore.
        git(repo, 'checkout', '--detach', '--force', target)
        return {'status': 'updated', 'backup': str(snapshot), 'head': target}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=('check', 'backup', 'verify', 'restore', 'sync'))
    parser.add_argument('--repo', type=Path)
    parser.add_argument('--backup-root', type=Path)
    parser.add_argument('--snapshot', type=Path)
    parser.add_argument('--destination', type=Path)
    parser.add_argument('--ref', default='origin/main')
    parser.add_argument('--fetch', action='store_true')
    parser.add_argument('--confirm-discard-local', action='store_true')
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument('--apply', action='store_true')
    mode.add_argument('--dry-run', action='store_true')
    args = parser.parse_args()
    try:
        if args.action == 'verify':
            if args.snapshot is None:
                raise SafetyError('--snapshot erforderlich.')
            verify(args.snapshot)
            print('Sicherung vollstaendig geprueft.')
            return 0
        if args.action in ('check', 'backup', 'sync'):
            if args.repo is None:
                raise SafetyError('--repo erforderlich.')
            repo = repository(args.repo)
            if args.backup_root is not None:
                backup_path(repo, args.backup_root)
        if args.action == 'restore':
            if args.snapshot is None or args.destination is None:
                raise SafetyError('--snapshot und --destination erforderlich.')
            verify(args.snapshot)
            if args.destination.exists() or args.destination.is_symlink():
                raise SafetyError('Restore-Ziel muss neu sein.')
        if not args.apply or args.action == 'check':
            print('Dry-run: lokale Voraussetzungen geprueft; kein Fetch, Backup, Checkout oder Restore ausgefuehrt.')
            return 0
        if os.name != 'posix':
            raise SafetyError('Apply nur unter Linux/WSL; Windows ist keine freigegebene Backup-/ACL-Plattform.')
        if args.action in ('backup', 'sync') and args.backup_root is None:
            raise SafetyError('--backup-root erforderlich.')
        if args.action == 'backup':
            backup_path(repo, args.backup_root)
            with operation_lock(args.backup_root):
                print(backup(repo, args.backup_root))
        elif args.action == 'sync':
            if not args.confirm_discard_local:
                raise SafetyError('Explizite Freigabe --confirm-discard-local erforderlich.')
            print(json.dumps(sync(repo, args.backup_root, args.ref, args.fetch)))
        elif args.action == 'restore':
            if args.snapshot is None or args.destination is None:
                raise SafetyError('--snapshot und --destination erforderlich.')
            print(restore(args.snapshot, args.destination))
    except SafetyError as error:
        print('Abbruch: ' + str(error), file=sys.stderr)
        return 1
    except OSError as error:
        if error.errno == errno.ENOSPC:
            print('Speicherplatzmangel (ENOSPC): kein erfolgreicher Update-/Restore-Abschluss. Partielle Sicherungen bleiben zur Diagnose erhalten.', file=sys.stderr)
        else:
            print('Dateizugriff fehlgeschlagen; kein erfolgreicher Abschluss. Berechtigungen und Speicher pruefen.', file=sys.stderr)
        return 1
    except (ValueError, KeyError, TypeError, tarfile.TarError):
        # Do not expose arbitrary file contents, URLs or exception payloads.
        print('Sicherheitspruefung fehlgeschlagen. Keine Erfolgsmeldung; vorhandene Sicherungen bleiben erhalten. Voraussetzungen, Pfade, Platz und Freigaben pruefen.', file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
