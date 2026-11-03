"""Opt-in history scan; emit only finding metadata, never matches or secrets."""
import argparse
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile


def metadata(rows):
    if not isinstance(rows, list) or any(not isinstance(row, dict) for row in rows):
        raise ValueError('Invalid scan document')
    result = []
    for row in rows:
        commit = row.get('Commit', '')
        rule = row.get('RuleID', '')
        line = row.get('StartLine', 0)
        if (not re.fullmatch('[0-9a-f]{40}', commit) or not re.fullmatch('[a-zA-Z0-9_-]+', rule)
                or type(line) is not int or line < 1):
            raise ValueError('Invalid scan metadata')
        result.append({'commit': commit, 'rule': rule, 'file': row['File'], 'line': line,
                       'triage': 'unreviewed', 'credential_validity': 'not-tested'})
    return result


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--run', action='store_true')
    args = parser.parse_args(argv)
    if not args.run:
        print('Plan: gitleaks git HEAD, fully redacted, metadata only; no rotation or provider calls. Use --run.')
        return 3
    root = Path(__file__).resolve().parents[2]
    scanner = shutil.which('gitleaks')
    if not scanner:
        print('Gitleaks missing; install via approved Git-source path.', file=sys.stderr)
        return 2
    try:
        with tempfile.TemporaryDirectory(prefix='redacted-history-') as temp:
            os.chmod(temp, 0o700)
            report = Path(temp) / 'redacted.json'
            result = subprocess.run([scanner, 'git', '--redact=100', '--no-banner', '--no-color',
                                     '--log-opts=HEAD', '--report-format=json', '--report-path', str(report), '.'],
                                    cwd=root, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                                    timeout=600, check=False)
            if result.returncode not in (0, 1) or not report.is_file() or report.stat().st_size > 16 * 1024**2:
                raise ValueError('Scan incomplete')
            rows = metadata(json.loads(report.read_text(encoding='utf-8')))
        print(json.dumps({'scope': 'reachable-HEAD-history', 'findings': rows,
                          'rotation_performed': False, 'history_rewritten': False}, ensure_ascii=True))
        return 1 if rows else 0
    except (OSError, ValueError, KeyError, TypeError, subprocess.SubprocessError):
        print('History scan incomplete; no raw scanner output disclosed.', file=sys.stderr)
        return 2


if __name__ == '__main__':
    sys.exit(main())
