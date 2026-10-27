"""Nur signierten, ausdruecklich gewaehlten Release-Tag nach verifiziertem Backup auschecken."""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
MANIFEST_SPEC = importlib.util.spec_from_file_location('verified_release_manifest', Path(__file__).with_name('release_manifest.py'))
manifest_module = importlib.util.module_from_spec(MANIFEST_SPEC)
MANIFEST_SPEC.loader.exec_module(manifest_module)
verify, REPO = manifest_module.verify, manifest_module.REPO
SPEC = importlib.util.spec_from_file_location('release_repo_safety', ROOT / 'scripts/lib/repo_safety.py')
safety = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(safety)


def update(repo, backup_root, manifest, *, apply=False, fetch=False):
    repo = safety.repository(repo)
    if safety.git(repo, 'status', '--porcelain').stdout.strip():
        raise ValueError('Lokale Aenderungen bleiben erhalten; kein Release-Update.')
    if safety.git(repo, 'config', '--get', 'remote.origin.url').stdout.decode().strip() != REPO:
        raise ValueError('Abweichender Origin braucht einen separat signierten Release-Vertrag.')
    if not apply:
        return {'status': 'planned', 'tag': manifest['tag'], 'network': False, 'checkout': False}
    if os.name != 'posix':
        raise ValueError('Apply nur unter Linux/WSL; keine Windows-Backupabnahme.')
    backup_root = safety.backup_path(repo, backup_root)
    with safety.operation_lock(backup_root):
        # Sicherung vor Fetch: auch bewegte Tags und Git-Metadaten bleiben wiederherstellbar.
        snapshot = safety.backup(repo, backup_root)
        safety.verify(snapshot)
        if fetch:
            safety.git(repo, '-c', 'credential.helper=', 'fetch', '--tags', '--no-recurse-submodules', 'origin')
        ref = 'refs/tags/' + manifest['tag']
        target = safety.git(repo, 'rev-parse', '--verify', '--end-of-options', ref + '^{commit}').stdout.decode().strip()
        if target != manifest['commit']:
            raise ValueError('Tag/Commit-Abweichung; Sicherung bleibt erhalten, kein Checkout.')
        if safety.git(repo, 'status', '--porcelain').stdout.strip():
            raise ValueError('Checkout parallel geaendert; nichts ueberschreiben.')
        safety.collision_check(repo, target)
        # Keine Force-Option: selbst nach Pruefung neu entstandene Aenderungen blockieren Git.
        safety.git(repo, 'checkout', '--detach', target)
        return {'status': 'release-checked-out-not-runtime-tested', 'commit': target, 'backup': str(snapshot)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', type=Path, default=ROOT)
    parser.add_argument('--backup-root', type=Path, default=Path.home() / '.openclaw_ultimate_user_data/repo_update_backups')
    parser.add_argument('--artifacts', type=Path, required=True)
    parser.add_argument('--tag', required=True)
    parser.add_argument('--public-key', type=Path, required=True)
    parser.add_argument('--fetch', action='store_true')
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument('--apply', action='store_true')
    mode.add_argument('--dry-run', action='store_true')
    args = parser.parse_args()
    try:
        manifest = verify(args.artifacts, args.tag, args.public_key)
        print(json.dumps(update(args.repo, args.backup_root, manifest, apply=args.apply, fetch=args.fetch)))
    except (ValueError, OSError, subprocess.SubprocessError, safety.SafetyError):
        print('Release-Update abgebrochen; Dateien/Signatur, Arbeitsstatus und vorhandene Sicherungen pruefen. Kein main-Fallback.', file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
