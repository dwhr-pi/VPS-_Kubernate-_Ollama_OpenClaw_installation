"""Run a bounded set of repository fixture suites and record actual results."""
import argparse
from datetime import datetime, timezone
import io
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import unittest
from audit_reports import write_report

ROOT = Path(__file__).resolve().parents[2]
PATTERNS = (
    'test_master_audit_safety.py', 'test_platform_inventory.py', 'test_repository_audit.py',
    'test_credentials_backup.py', 'test_install_rollback.py', 'test_installation_reset.py',
    'test_installation_inventory.py', 'test_p0_safety.py', 'test_signed_release.py',
    'test_tool_coverage_audit.py', 'test_production_baseline.py', 'test_gpu_platform_blueprint.py',
    'test_vps_delivery.py', 'test_local_ai_benchmarks.py', 'test_rag_compliance_review.py',
    'test_game_engine_tools.py',
)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write-report', action='store_true')
    parser.add_argument('--suite', action='append', choices=PATTERNS,
                        help='Targeted recheck; writes a separate report, preserving the full run')
    args = parser.parse_args()
    # Never resolve Windows bash.exe to the WSL launcher.
    if os.name == 'nt':
        bash = Path('C:/Program Files/Git/bin/bash.exe')
        if not bash.is_file():
            parser.error('Native Git Bash required on Windows; no WSL fallback')
        os.environ['PATH'] = str(bash.parent) + os.pathsep + os.environ.get('PATH', '')
    rows = []
    success = True
    for pattern in args.suite or PATTERNS:
        suite = unittest.TestLoader().discover(str(ROOT / 'tests'), pattern=pattern)
        output = io.StringIO()
        result = unittest.TextTestRunner(stream=output, verbosity=1).run(suite)
        row = {'suite': pattern, 'run': result.testsRun, 'passed': result.testsRun -
               len(result.failures) - len(result.errors) - len(result.skipped) - len(result.expectedFailures),
               'failures': len(result.failures), 'errors': len(result.errors),
               'skipped': [{'test': str(test), 'reason': reason} for test, reason in result.skipped],
               'expected_failures': len(result.expectedFailures)}
        rows.append(row)
        print(json.dumps(row), flush=True)
        if not result.wasSuccessful():
            success = False
            print(output.getvalue(), file=sys.stderr)
    revision = subprocess.run(['git', '-C', str(ROOT), 'rev-parse', 'HEAD'],
                              capture_output=True, text=True, check=True, timeout=30).stdout.strip()
    report = {'timestamp': datetime.now(timezone.utc).isoformat(), 'revision': revision,
              'platform': sys.platform, 'python': sys.version.split()[0],
              'scope': 'selected offline fixtures, not all repository tests or runtime acceptance',
              'runtime_acceptance': False, 'suites': rows, 'successful': success,
              'scanner_availability': {name: bool(shutil.which(name)) for name in ('gitleaks', 'trivy', 'helm', 'kustomize')},
              'totals': {key: sum(row[key] for row in rows) for key in ('run', 'passed', 'failures', 'errors')},
              'skipped': sum(len(row['skipped']) for row in rows)}
    if args.write_report:
        name = 'test_recheck_results.json' if args.suite else 'test_results.json'
        write_report(ROOT, name, json.dumps(report, indent=2) + '\n')
    print(json.dumps({'totals': report['totals'], 'skipped': report['skipped'], 'successful': success}), flush=True)
    return 0 if success else 1


if __name__ == '__main__':
    sys.exit(main())
