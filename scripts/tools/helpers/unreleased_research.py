"""Fail-closed documentation-only research entries; no user-data or network access."""
import argparse
import json


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('tool', choices=('songsage',))
    parser.add_argument('action', choices=('install', 'update', 'uninstall', 'status', 'doctor', 'check', 'plan'))
    parser.add_argument('--dry-run', action='store_true')
    args = parser.parse_args(argv)
    print(json.dumps(dict(tool=args.tool, action=args.action, scope='documentation-only',
                         installed=False, source_prepared=False, runtime_tested=False,
                         performed=False, reason='official-github-source-and-license-unconfirmed')))
    return 0 if args.dry_run or args.action in ('plan', 'status', 'uninstall') else 3


if __name__ == '__main__':
    raise SystemExit(main())
