"""Repository-only SSH command catalog. Read-only by default; no shell evaluation."""
import argparse
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
ACTIONS = ('install', 'update', 'uninstall', 'doctor', 'status')
CONFIG = {'ollama': 'scripts/ollama_modelfile_assistant.sh',
          'openclaw': 'scripts/openclaw_config_manager.sh',
          'huginn': 'scripts/huginn_config_manager.sh',
          'markdown_docs_server': 'scripts/markdown_docs_server_menu.sh'}
TARGET = 'docs/generated/HEADLESS_TOOL_COMMANDS.md'


def file_in_repo(root, value):
    if not isinstance(value, str) or not re.fullmatch(r'[A-Za-z0-9_.\-/]+', value):
        return None
    if value.startswith('/') or any(p in ('', '.', '..') or p.startswith('.') for p in value.split('/')):
        return None
    path = root
    for part in value.split('/'):
        path /= part
        if path.is_symlink() or (hasattr(path, 'is_junction') and path.is_junction()):
            return None
    return value if path.is_file() else None


def read(root, name):
    path = file_in_repo(root, name)
    if not path or (root / path).stat().st_size > 4 * 1024 ** 2:
        raise ValueError('Repository-Manifest fehlt oder ist unsicher')
    return json.loads((root / path).read_text(encoding='utf-8'))


def catalog(root=ROOT):
    rows = read(root, 'config/tools.yml')['tools']
    recipes = read(root, 'config/docker_to_github.json')['tools']
    native = {r['id']: r for r in recipes}
    if len(native) != len(recipes):
        raise ValueError('Doppelte native Tool-ID')
    result = []
    seen = set()
    for row in sorted(rows, key=lambda item: item['id'].casefold()):
        key = row['id']
        if not re.fullmatch('[a-z0-9_]+', key) or key in seen:
            raise ValueError('Ungueltige oder doppelte Tool-ID')
        seen.add(key)
        spec = native.get(key, {})
        recipe = spec.get('recipe') or {}
        approved = bool(recipe and not spec.get('blocked_reason') and
                        recipe.get('source_host', 'github.com') == 'github.com' and
                        re.fullmatch(r'[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+', recipe.get('repo', '')) and
                        re.fullmatch('[0-9a-f]{40}', recipe.get('pin', '')))
        helper = file_in_repo(root, 'scripts/tools/helpers/native_github_tools.py')
        approved = approved and bool(helper)
        actions = {}
        for action in ACTIONS:
            script = file_in_repo(root, row.get(action + '_script'))
            command = ['python3', '-B', helper, key, action] if approved and helper else None
            actions[action] = dict(command=command, registered_script=script,
                                   requires_apply=action in ('install', 'update', 'uninstall'))
        result.append(dict(id=key, name=row.get('name', key), status=row.get('status', 'unknown'),
                           readiness=row.get('readiness', 'unknown'),
                           unattended='native-helper-explicit-approval' if approved else 'not-reviewed',
                           blocked_reason=spec.get('blocked_reason'),
                           doc=file_in_repo(root, row.get('doc')),
                           config_script=file_in_repo(root, CONFIG.get(key)),
                           configuration='interactive-wizard' if file_in_repo(root, CONFIG.get(key)) else 'see-doc-or-manual-review',
                           native_source_repo=recipe.get('repo'), native_source_commit=recipe.get('pin'),
                           disk_reserve_mib=recipe.get('disk_mb'),
                           actions=actions, plan=['python3', '-I', '-B', 'scripts/tool_commands.py', 'show', key],
                           runtime_verified=False))
    return result


def one(key, root=ROOT):
    for item in catalog(root):
        if item['id'] == key:
            return item
    raise ValueError('Unbekannte Tool-ID; list zeigt die registrierten IDs')


def run(item, action, apply=False, confirm=None, deps=False):
    command = item['actions'][action]['command']
    if not command:
        raise ValueError('Kein gepruefter Docker-freier Headless-Adapter; Anleitung und registriertes Skript manuell reviewen')
    if action in ('install', 'update', 'uninstall') and (not apply or confirm != item['id'] + ':' + action):
        raise ValueError('--apply und --confirm TOOL:AKTION erforderlich; keine Aktion ausgefuehrt')
    if deps and action not in ('install', 'update'):
        raise ValueError('Build-Abhaengigkeiten nur fuer Install/Update')
    if sys.platform != 'linux':
        raise ValueError('Ausfuehrung nur im bewusst gewaehlten Linux-/WSL-Terminal; kein automatischer WSL-Aufruf')
    args = [sys.executable, '-B', str(ROOT / command[2]), *command[3:]]
    if deps:
        args.append('--install-build-deps')
    # No caller-supplied flags, shell expansion, Python injection or noninteractive auto-yes.
    allowed = {'path', 'home', 'user', 'logname', 'systemroot', 'windir', 'tmp', 'temp', 'lang', 'lc_all',
               'openclaw_user_data_dir', 'native_source_python_bin'}
    env = {key: value for key, value in os.environ.items() if key.casefold() in allowed}
    env.update(PYTHONDONTWRITEBYTECODE='1', PYTHONUTF8='1', GIT_TERMINAL_PROMPT='0', GCM_INTERACTIVE='never')
    return subprocess.run(args, cwd=ROOT, env=env, stdin=subprocess.DEVNULL, check=False).returncode


def render(root=ROOT):
    lines = ['# SSH-/Headless-Befehle fuer alle Tools', '',
             'Generiert aus `config/tools.yml` und dem nativen Buildmanifest. Nicht manuell bearbeiten.', '',
             'Alle Befehle setzen das gepruefte Repository als Arbeitsverzeichnis voraus. Keine Installation durch diese Liste.',
             'Skript vorhanden bedeutet weder Docker-frei noch unbeaufsichtigt abgenommen. Nicht gepruefte Adapter bleiben gesperrt.',
             'Konfiguration ohne Wizard: verlinkte Dokumentation lesen; kein erfundener Silent-/Force-Schalter.', '',
             '[SSH-Anleitung und Sicherheitsgrenzen](../HEADLESS_SETUP.md)', '',
             '| Tool-ID | Status / Bereitschaft | Plan (immer offline) | Freigegebene Headless-Aktionen | Konfiguration / Anleitung |',
             '| --- | --- | --- | --- | --- |']
    for row in catalog(root):
        key = row['id']
        approved = row['unattended'] != 'not-reviewed'
        command = f'`python3 -I -B scripts/tool_commands.py show {key}`'
        actions = ('`run ' + key + ' --action install --apply --confirm ' + key + ':install`; update/uninstall analog; status/doctor ohne Freigabe') if approved else 'Nicht freigegeben; kein unbeaufsichtigter Installationsbefehl'
        docs = ('[Anleitung](../../' + row['doc'] + ')') if row['doc'] else 'Keine gepruefte Anleitung registriert'
        if row['config_script']:
            docs += '; SSH-TTY: `bash ' + row['config_script'] + '`'
        lines.append(f"| {key} | {row['status']} / {row['readiness']} | {command} | {actions} | {docs} |")
    lines += ['', 'In der Aktionsspalte ist `run` die Kurzform fuer `python3 -I -B scripts/tool_commands.py run`.',
              'Die JSON-Detailansicht zeigt alle registrierten Install/Update/Uninstall/Doctor/Status-Pfade, auch bei fehlender Freigabe.',
              'Fehlende Skripte oder Anleitung sind ausdrueckliche Luecken, kein Installationserfolg.', '']
    return '\n'.join(lines)


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest='mode', required=True)
    sub.add_parser('list')
    for name in ('show', 'plan'):
        sub.add_parser(name).add_argument('tool')
    execute = sub.add_parser('run')
    execute.add_argument('tool')
    execute.add_argument('--action', choices=ACTIONS, required=True)
    execute.add_argument('--apply', action='store_true')
    execute.add_argument('--confirm')
    execute.add_argument('--install-build-deps', action='store_true')
    docs = sub.add_parser('docs')
    docs.add_argument('--write', action='store_true')
    args = parser.parse_args(argv)
    if args.mode == 'docs':
        expected = render()
        path = ROOT / TARGET
        for component in (ROOT / 'docs', path.parent, path):
            if component.is_symlink() or (hasattr(component, 'is_junction') and component.is_junction()):
                raise ValueError('Verlinktes Ausgabeziel')
        if args.write:
            with tempfile.NamedTemporaryFile('w', encoding='utf-8', newline='\n', dir=path.parent, delete=False) as stream:
                temporary = Path(stream.name)
                stream.write(expected)
            try:
                os.replace(temporary, path)
            finally:
                temporary.unlink(missing_ok=True)
        drift = not path.is_file() or path.read_text(encoding='utf-8') != expected
        print(json.dumps(dict(executed=False, write=args.write, drift=drift)))
        return int(drift)
    if args.mode == 'list':
        print(json.dumps(dict(executed=False, tools=catalog()), ensure_ascii=True))
    elif args.mode in ('show', 'plan'):
        print(json.dumps(dict(executed=False, tool=one(args.tool)), ensure_ascii=True, indent=2))
    else:
        return run(one(args.tool), args.action, args.apply, args.confirm, args.install_build_deps)
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (ValueError, OSError, KeyError, TypeError) as error:
        print('Tool-Befehl abgelehnt: ' + str(error), file=sys.stderr)
        sys.exit(2)
