"""Reproducible repository-only evidence bundle; no installation or runtime probes."""
import argparse
import ast
from collections import Counter
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import subprocess
import sys

from platform_inventory import inventory, markdown
from repository_audit import Audit, SKIP
from audit_reports import write_report

ROOT = Path(__file__).resolve().parents[2]
GENERATED_REPORTS = {'docs/audit/' + name for name in
                     ('inventory.json', 'TOOL_INVENTORY.md', 'test_results.json', 'test_recheck_results.json')}


def manifest_digest(files):
    """Bind tracked AND untracked audited content without self-referencing generated reports."""
    canonical = sorted(files, key=lambda row: row['path'])
    return hashlib.sha256(json.dumps(canonical, sort_keys=True, separators=(',', ':')).encode()).hexdigest()


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
    result['working_tree_diff_scope'] = 'tracked diff only; untracked audited files bound by manifest digest'
    audit = Audit(root)
    audit.registry()
    audit.code()
    audit.links()
    result['repository_checks'] = audit.result()
    # Paths/hashes only: never export file contents or inspect external user data.
    result['files'] = []
    result['services_and_integrations'] = []
    test_references = {}
    for path in audit.files():
        rel = path.relative_to(root)
        if rel.as_posix() in GENERATED_REPORTS:
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
        content = path.read_bytes()
        record = {'path': rel.as_posix(), 'bytes': len(content),
                  'sha256': hashlib.sha256(content).hexdigest()}
        result['files'].append(record)
        if rel.parts[0] == 'tests' and path.name.startswith('test_') and path.suffix == '.py':
            try:
                tree = ast.parse(content.decode('utf-8-sig'))
                for node in ast.walk(tree):
                    if isinstance(node, ast.Constant) and isinstance(node.value, str) and len(node.value) < 256:
                        test_references.setdefault(node.value, set()).add(rel.as_posix())
            except (SyntaxError, UnicodeError):
                pass  # Audit.code already reports parse failures without source contents.
        if rel.parts[0] in ('stacks', 'k8s', 'ansible', 'monitoring', 'systemd', 'services', 'skills', 'memory'):
            result['services_and_integrations'].append({
                'path': rel.as_posix(), 'state': 'file-present; runtime-unverified',
                'kind': rel.parts[0], 'sha256': record['sha256']})
    result['summary']['files_by_area'] = dict(sorted(Counter(
        item['path'].split('/')[0] for item in result['files']).items()))
    result['working_tree_manifest_sha256'] = manifest_digest(result['files'])
    result['working_tree_manifest_scope'] = 'bounded repository files, excludes secrets/build caches and four generated audit reports'
    for row in result['rows']:
        references = test_references.get(row['id'], set()) | test_references.get(row['name'], set())
        row['static_test_references'] = sorted(references)
        row['static_test_reference_scope'] = 'exact Python string literal only; not execution or coverage evidence'
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
    files = {'inventory.json': json.dumps(report, indent=2, ensure_ascii=True) + '\n',
             'TOOL_INVENTORY.md': markdown(report, revision=report['revision'])}
    for name, content in files.items():
        write_report(ROOT, name, content)


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
