"""Reproducible repository-only evidence bundle; no installation or runtime probes."""
import argparse
from collections import Counter
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import subprocess
import sys

from platform_inventory import inventory, markdown
from repository_audit import Audit, SKIP

ROOT = Path(__file__).resolve().parents[2]


def git(root, *args):
    return subprocess.run(['git', '-C', str(root), *args], check=True, capture_output=True,
                          text=True, timeout=60).stdout.strip()


def snapshot(root=ROOT):
    root = Path(root).resolve()
    result = inventory(root)
    result['scope'] = 'offline-static-audit; no runtime or historical secret-scan certification'
    result['generated_at'] = datetime.now(timezone.utc).isoformat()
    result['revision'] = git(root, 'rev-parse', 'HEAD')
    result['working_tree_dirty'] = bool(git(root, 'status', '--porcelain'))
    result['working_tree_diff_sha256'] = hashlib.sha256(
        git(root, 'diff', '--no-ext-diff', '--no-textconv', 'HEAD').encode()).hexdigest()
    audit = Audit(root)
    audit.registry()
    audit.code()
    audit.links()
    result['repository_checks'] = audit.result()
    # Paths/hashes only: never export file contents or inspect external user data.
    result['files'] = []
    result['services_and_integrations'] = []
    for path in audit.files():
        rel = path.relative_to(root)
        if rel.as_posix() in ('docs/audit/inventory.json', 'docs/audit/TOOL_INVENTORY.md'):
            continue
        if (any(part in SKIP or part == '.codex-build' for part in rel.parts) or
                (hasattr(path, 'is_junction') and path.is_junction())):
            continue
        if path.name.startswith('.env') and not path.name.endswith(('.example', '.template')):
            continue
        if path.suffix.lower() in ('.age', '.key', '.pem', '.p12', '.log', '.db', '.sqlite', '.gguf'):
            continue
        if path.stat().st_size > 8 * 1024**2:
            continue
        # Resolve again before reading: do not follow parent symlinks out of the repo.
        if not path.resolve().is_relative_to(root):
            continue
        record = {'path': rel.as_posix(), 'bytes': path.stat().st_size,
                  'sha256': hashlib.sha256(path.read_bytes()).hexdigest()}
        result['files'].append(record)
        if rel.parts[0] in ('stacks', 'k8s', 'ansible', 'monitoring', 'systemd', 'services', 'skills', 'memory'):
            result['services_and_integrations'].append({
                'path': rel.as_posix(), 'state': 'file-present; runtime-unverified',
                'kind': rel.parts[0], 'sha256': record['sha256']})
    result['summary']['files_by_area'] = dict(sorted(Counter(
        item['path'].split('/')[0] for item in result['files']).items()))
    tools = [row for row in result['rows'] if row['kind'] == 'tools']
    result['summary']['metadata_gaps'] = {
        'missing_license': sum(row['license'] == 'not-declared' for row in tools),
        'missing_source': sum(row['source'] == 'not-declared' for row in tools),
        'unreviewed_maintenance': sum(row['maintenance'] == 'not-reviewed' for row in tools)}
    result['not_verified'] = ['Git history secrets', 'installed versions', 'upstream licenses of every pin',
                              'container CVEs', 'GPU', 'TLS/CNI/RBAC enforcement', 'real restore',
                              'provider costs', 'end-to-end agent/RAG/game workflows']
    return result


def write_reports(report):
    directory = ROOT / 'docs/audit'
    # Fixed output boundary; refuse linked paths, not arbitrary --output destinations.
    for path in (ROOT / 'docs', directory):
        if path.is_symlink() or (hasattr(path, 'is_junction') and path.is_junction()):
            raise ValueError('Linked report directory rejected')
    directory.mkdir(exist_ok=True)
    files = {'inventory.json': json.dumps(report, indent=2, ensure_ascii=True) + '\n',
             'TOOL_INVENTORY.md': markdown(report, revision=report['revision'])}
    for name, content in files.items():
        path = directory / name
        if path.is_symlink() or (path.exists() and path.stat().st_nlink != 1):
            raise ValueError('Linked report file rejected')
        path.write_text(content, encoding='utf-8', newline='\n')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write-reports', action='store_true')
    args = parser.parse_args()
    report = snapshot()
    if args.write_reports:
        write_reports(report)
    print(json.dumps({'revision': report['revision'], 'summary': report['summary'],
                      'checks': {key: value for key, value in report['repository_checks'].items()
                                 if key != 'issues'}, 'reports_written': args.write_reports}, indent=2))
    return bool(report['repository_checks']['errors'])


if __name__ == '__main__':
    sys.exit(main())
