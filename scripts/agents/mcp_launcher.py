"""Allowlisted stdio MCP entry point; only the existing read-only audio planner."""
import argparse
import json
import os
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[2]
SERVER = ROOT / 'scripts/audio/mcp_audio_server.py'


def command():
    return [sys.executable, '-I', '-B', str(SERVER)]


def environment():
    env = {key: value for key, value in os.environ.items() if key in ('SystemRoot', 'SYSTEMROOT', 'LANG', 'LC_ALL')}
    env.update(PYTHONUTF8='1', PYTHONDONTWRITEBYTECODE='1')
    return env


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', nargs='?', default='plan', choices=('plan', 'config', 'run'))
    parser.add_argument('--approve', choices=('audio_plan',))
    args = parser.parse_args(argv)
    if args.action in ('run', 'config') and args.approve != 'audio_plan':
        parser.error('Explicit --approve audio_plan required; clients may auto-start configured servers')
    if args.action == 'plan':
        print(json.dumps(dict(server='audio_plan', transport='stdio', apply=False,
                              command=command(), read_only=True, remote_enabled=False,
                              filesystem_tool_enabled=False, sandbox_verified=False)))
        return 0
    if args.action == 'config':
        print(json.dumps({'mcpServers': {'audio_plan': {'command': sys.executable,
            'args': ['-I', '-B', str(Path(__file__).resolve()), 'run', '--approve', 'audio_plan']}}}, indent=2))
        return 0
    # No arbitrary executable, path, environment override, shell or network adapter.
    if not SERVER.is_file() or SERVER.is_symlink():
        raise ValueError('Reviewed local planner unavailable')
    os.execve(sys.executable, command(), environment())
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, ValueError):
        print('MCP planner launch rejected', file=sys.stderr)
        sys.exit(1)
