"""Consent-gated metadata discovery; no execution, icon reads, registration or network."""
import argparse
import configparser
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import plistlib
import re
import stat
import sys
import time
from xml.parsers.expat import ExpatError

ROOT = Path(__file__).resolve().parents[2]
PLATFORMS = ('windows', 'macos', 'linux', 'android', 'ios')
MAX_BYTES = 128 * 1024
MAX_ENTRIES = 2000
MAX_ROOTS = 8
MAX_DEPTH = 3
SCAN_SECONDS = 5
SENSITIVE = {'.ssh', '.aws', '.azure', '.gnupg', '.git', '.codex', '.kube',
             'cookies', 'credentials', 'secrets', 'keychains'}
AI_HINT = re.compile(r'(?i)(qwen|gemini|ollama|chatgpt|gpt4all|anythingllm|claude|copilot|\bllm\b|\bai\b)')
DEVICE_ID = re.compile(r'[A-Za-z0-9][A-Za-z0-9_.-]{0,63}\Z')


def host_platform():
    if hasattr(sys, 'getandroidapilevel'):
        return 'android'
    return {'win32': 'windows', 'darwin': 'macos', 'ios': 'ios'}.get(sys.platform, 'linux')


def clean(value):
    if not isinstance(value, str):
        return ''
    return re.sub(r'[\x00-\x1f\x7f<>]', '', value).strip()[:120]


def normalized(value):
    return re.sub(r'[^a-z0-9]', '', value.casefold())


def load_hints():
    data = json.loads((ROOT / 'config/desktop_app_hints.json').read_text(encoding='utf-8'))
    ids = {row['id'] for row in json.loads((ROOT / 'config/tools.yml').read_text(encoding='utf-8'))['tools']}
    hints = {}
    for row in data['hints']:
        if not set(row['registry_candidates']) <= ids:
            raise ValueError('Hint references an unknown registry ID')
        for name in row['names']:
            hints.setdefault(normalized(name), set()).update(row['registry_candidates'])
    return hints


def linked(path):
    info = path.lstat()
    return stat.S_ISLNK(info.st_mode) or bool(getattr(info, 'st_file_attributes', 0) & 0x400)


def safe_path(path, root):
    path.relative_to(root)
    for part in (path, *path.parents):
        if linked(part):
            raise ValueError('Linked path refused')
        if part == root:
            break


def checked_root(value):
    raw = os.fspath(value)
    path = Path(raw).expanduser()
    if (raw.startswith(('\\\\', '//')) or not path.is_absolute() or '..' in path.parts
            or path == Path(path.anchor) or path == Path.home()
            or path.name.casefold() in {'users', 'home', 'root', 'appdata'}
            or any(part.casefold() in SENSITIVE for part in path.parts)):
        raise ValueError('Explicit narrow local application directory required')
    for part in (path, *path.parents):
        if linked(part):
            raise ValueError('Linked root refused')
    if not path.is_dir():
        raise ValueError('Application directory unavailable')
    return path


def read_metadata(path, root):
    safe_path(path, root)
    before = path.lstat()
    if not stat.S_ISREG(before.st_mode) or before.st_nlink != 1 or before.st_size > MAX_BYTES:
        raise ValueError('Unsupported metadata file')
    flags = os.O_RDONLY | getattr(os, 'O_NOFOLLOW', 0) | getattr(os, 'O_NONBLOCK', 0) | getattr(os, 'O_BINARY', 0)
    fd = os.open(path, flags)
    with os.fdopen(fd, 'rb') as stream:
        after = os.fstat(stream.fileno())
        if (not stat.S_ISREG(after.st_mode) or after.st_nlink != 1
                or (before.st_dev, before.st_ino) != (after.st_dev, after.st_ino)):
            raise ValueError('Metadata changed during open')
        data = stream.read(MAX_BYTES + 1)
    if len(data) > MAX_BYTES:
        raise ValueError('Metadata too large')
    return data


def metadata(path, root, platform):
    if platform == 'windows' and path.suffix.casefold() == '.exe' and path.is_file():
        # A filename is only a candidate; do not read PE resources or trust a signature here.
        if re.search(r'(?i)(unins|uninstall|setup|installer|updater)', path.stem):
            return None
        return {'name': clean(path.stem), 'identity': clean(path.name), 'version': '', 'icon': ''}
    if platform == 'macos' and path.suffix.casefold() == '.app' and path.is_dir():
        raw = read_metadata(path / 'Contents/Info.plist', root)
        if b'<!ENTITY' in raw.upper() or b'<!DOCTYPE' in raw.upper():
            # Normal Apple XML plists contain a public DOCTYPE, but no entities are needed.
            if b'<!ENTITY' in raw.upper() or b'[' in raw.split(b'<!DOCTYPE', 1)[-1].split(b'>', 1)[0]:
                raise ValueError('Entity declarations refused')
        data = plistlib.loads(raw)
        if not isinstance(data, dict):
            raise ValueError('Invalid application plist')
        return {'name': clean(data.get('CFBundleDisplayName') or data.get('CFBundleName') or path.stem),
                'identity': clean(data.get('CFBundleIdentifier')), 'version': clean(data.get('CFBundleShortVersionString')),
                'icon': clean(data.get('CFBundleIconFile'))}
    if platform == 'linux' and path.suffix == '.desktop' and path.is_file():
        parser = configparser.ConfigParser(interpolation=None, strict=True)
        parser.optionxform = str
        parser.read_string(read_metadata(path, root).decode('utf-8-sig'))
        row = parser['Desktop Entry']
        if row.get('Type') != 'Application' or row.get('Hidden', '').casefold() == 'true':
            return None
        return {'name': clean(row.get('Name')), 'identity': clean(path.name),
                'version': '', 'icon': clean(row.get('Icon'))}
    return None


def record(info, path, platform, hints, include_paths, device_id):
    matches = sorted(hints.get(normalized(info['name']), set()))
    looks_ai = bool(matches or AI_HINT.search(info['name']))
    result = {
        'candidate_id': hashlib.sha256((device_id + '\0' + platform + '\0' + str(path)).encode()).hexdigest()[:24],
        'platform': platform, 'display_name': info['name'], 'identity_hint': info['identity'],
        'version_hint': info['version'], 'registry_candidates': matches,
        'match_basis': 'name-hint' if matches else ('ai-name-heuristic' if looks_ai else 'unclassified'),
        'discovery_state': 'metadata-only', 'installation_status': 'unverified',
        'launch_enabled': False, 'confirmation_required': True,
        'icon': {'state': 'reference-only' if info['icon'] else 'placeholder',
                 'name_hint': clean(Path(info['icon'].replace('\\', '/')).name) if info['icon'] else ''},
    }
    if include_paths:
        result['local_metadata_path'] = str(path)
    return result


def scan(roots, platform, hints, *, max_depth=1, include_unclassified=False,
         include_paths=False, device_id='local', limit=MAX_ENTRIES, clock=time.monotonic):
    if platform not in ('windows', 'macos', 'linux'):
        raise ValueError('Mobile discovery requires a future native app')
    if not 1 <= len(roots) <= MAX_ROOTS or not 0 <= max_depth <= MAX_DEPTH or not 1 <= limit <= MAX_ENTRIES:
        raise ValueError('Scan limits exceeded')
    if not DEVICE_ID.fullmatch(device_id):
        raise ValueError('Invalid local device alias')
    approved = list(dict.fromkeys(checked_root(value) for value in roots))
    deadline = clock() + SCAN_SECONDS
    queue = [(root, root, 0) for root in approved]
    seen = set()
    candidates = {}
    visited = skipped = errors = 0
    complete = True
    while queue:
        directory, root, depth = queue.pop(0)
        if directory in seen:
            continue
        seen.add(directory)
        try:
            safe_path(directory, root)
            with os.scandir(directory) as entries:
                for entry in entries:
                    if visited >= limit or clock() >= deadline:
                        complete = False
                        break
                    visited += 1
                    path = Path(entry.path)
                    if path.name.startswith('.') or path.name.casefold() in SENSITIVE:
                        skipped += 1
                        continue
                    try:
                        safe_path(path, root)
                        info = metadata(path, root, platform)
                        if info and info['name']:
                            row = record(info, path, platform, hints, include_paths, device_id)
                            if include_unclassified or row['match_basis'] != 'unclassified':
                                candidates[row['candidate_id']] = row
                        # Never descend into app bundles or arbitrary hidden/private trees.
                        if (depth < max_depth and path.is_dir()
                                and path.suffix.casefold() != '.app'):
                            queue.append((path, root, depth + 1))
                    except (OSError, ValueError, KeyError, configparser.Error, plistlib.InvalidFileException, ExpatError):
                        errors += 1
        except (OSError, ValueError):
            errors += 1
        if not complete:
            break
    return {
        'schema_version': 1, 'kind': 'openclaw-app-discovery', 'platform': platform,
        'device_id': device_id,
        'created_at': datetime.now(timezone.utc).isoformat(), 'scope': 'explicit-application-directories',
        'max_depth': max_depth,
        'complete_scope': complete and errors == 0, 'full_os_inventory': False,
        'stats': {'roots': len(approved), 'visited': visited, 'skipped': skipped, 'errors': errors},
        'local_paths_included': include_paths, 'executed': False, 'network_requested': False,
        'registration_changed': False, 'candidates': sorted(candidates.values(), key=lambda row: row['candidate_id']),
    }


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--scan', action='store_true')
    parser.add_argument('--approve-local-inventory', action='store_true')
    parser.add_argument('--platform', choices=PLATFORMS, default=host_platform())
    parser.add_argument('--root', action='append', default=[])
    parser.add_argument('--max-depth', type=int, choices=range(MAX_DEPTH + 1), default=1)
    parser.add_argument('--include-unclassified', action='store_true')
    parser.add_argument('--include-local-paths', action='store_true')
    parser.add_argument('--device-id', default='local')
    args = parser.parse_args(argv)
    if not DEVICE_ID.fullmatch(args.device_id):
        parser.error('Use a bounded non-sensitive local device alias')
    if not args.scan:
        print(json.dumps({'schema_version': 1, 'action': 'plan', 'platform': args.platform, 'device_id': args.device_id,
                          'scan_performed': False, 'executed': False, 'registration_changed': False,
                          'desktop_metadata_adapters': ['windows', 'macos', 'linux'],
                          'mobile_adapters': {'android': 'planned-filtered-packages', 'ios': 'planned-known-links-only'}}))
        return 0
    if not args.approve_local_inventory or not args.root or args.platform != host_platform():
        parser.error('Scan requires consent, explicit roots and the actual host platform')
    try:
        report = scan(args.root, args.platform, load_hints(), max_depth=args.max_depth,
                      include_unclassified=args.include_unclassified, include_paths=args.include_local_paths,
                      device_id=args.device_id)
        print(json.dumps(report, ensure_ascii=True, indent=2))
        return 0 if report['complete_scope'] else 3
    except (OSError, ValueError, KeyError):
        print('Local metadata scan refused; no app was started or registered.', file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
