"""Offline desktop/source wiring; no browser, installer, account or CLI is started."""
import contextlib
import importlib
import io
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
from doc_assertions import assert_prose_in, assert_prose_not_in
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'scripts/tools/helpers'))
G = importlib.import_module('gap_tools')
BASH = 'C:/Program Files/Git/bin/bash.exe' if os.name == 'nt' else shutil.which('bash')
SOURCES = ('gemini_desktop_bwendell_source', 'gemini_desktop_dortanes_source')
DESKTOPS = ('gemini_desktop_bwendell', 'gemini_desktop_dortanes')
DOC = ROOT / 'docs/tools/gemini-desktop-clients.md'


class GeminiDesktopClientsTests(unittest.TestCase):
    def test_both_upstreams_are_distinct_and_source_scopes_are_honest(self):
        registry = {t['id']: t for t in json.loads((ROOT / 'config/tools.yml').read_text(encoding='utf-8'))['tools']}
        repos = []
        setup = (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8')
        tracking = (ROOT / 'scripts/helpers/status_tracking.sh').read_text(encoding='utf-8')
        markers = (ROOT / 'scripts/helpers/native_tool_status.sh').read_text(encoding='utf-8')
        for key in SOURCES + DESKTOPS:
            entry = registry[key]
            self.assertFalse(entry['auto_install'])
            self.assertEqual(entry['ports'], [])
            self.assertIn('TOOL_SCRIPT_NAMES["' + entry['name'] + '"]="' + key + '"', setup)
            self.assertIn('"' + entry['name'] + '"', tracking)
            self.assertEqual(entry['doc'], 'docs/tools/gemini-desktop-clients.md')
            for action in ('install', 'uninstall', 'update', 'status', 'check', 'doctor'):
                script = (ROOT / ('scripts/tools/' + key + '_' + action + '.sh')).read_text()
                self.assertIn('github.com/', script)
            if key in SOURCES:
                spec = G.SPECS[key]
                repos.append(spec['repo'])
                self.assertEqual(spec['mode'], 'source')
                self.assertRegex(spec['pin'], r'^[a-f0-9]{40}$')
                self.assertEqual(entry['source_commit'], spec['pin'])
                self.assertIn(entry['name'] + ') marker=' + key + '/ready.json', markers)
            else:
                self.assertEqual(entry['check_type'], 'documentation')
                self.assertEqual(entry['install_mode'], 'desktop-manual')
        self.assertEqual(set(repos), {'bwendell/gemini-desktop', 'dortanes/gemini-desktop'})
        self.assertIn('Gemini_Desktop_Dortanes_Legacy', setup)

    def test_source_plan_and_status_do_not_write_or_call_git(self):
        with tempfile.TemporaryDirectory() as temp, patch.dict(os.environ, {'OPENCLAW_USER_DATA_DIR': temp}), patch.object(G, 'git') as git, patch.object(G, 'run') as run, contextlib.redirect_stdout(io.StringIO()):
            for key in SOURCES:
                self.assertEqual(G.main([key, '--dry-run']), 0)
                self.assertEqual(G.main([key, 'status']), 0)
            self.assertEqual(list(Path(temp).iterdir()), [])
            git.assert_not_called()
            run.assert_not_called()

    @unittest.skipUnless(BASH and Path(BASH).is_file(), 'Native Bash unavailable')
    def test_manual_plans_never_claim_desktop_installation(self):
        for key in DESKTOPS:
            result = subprocess.run([BASH, '--noprofile', '--norc', (ROOT / ('scripts/tools/' + key + '_install.sh')).as_posix(), '--dry-run'], capture_output=True, text=True, input='', timeout=30)
            self.assertEqual(result.returncode, 0, result.stderr)
            record = json.loads(result.stdout)
            self.assertFalse(record['installed'])
            self.assertEqual(record['status'], 'manual-unverified')
            self.assertIn('/releases/tag/v', record['download_page'])

    @unittest.skipUnless(BASH and Path(BASH).is_file(), 'Native Bash unavailable')
    def test_legacy_install_and_open_request_stop_before_browser(self):
        helper = (ROOT / 'scripts/tools/helpers/browser_desktop_common.sh').as_posix()
        for action in ('install', 'update', '--open-download'):
            code = 'source "' + helper + '"; browser_desktop_can_prompt() { return 0; }; powershell.exe() { echo UNEXPECTED_BROWSER; return 99; }; xdg-open() { echo UNEXPECTED_BROWSER; return 99; }; browser_desktop_main gemini_desktop_dortanes ' + action
            result = subprocess.run([BASH, '--noprofile', '--norc', '-c', code], input='j\n\nj\n', capture_output=True, text=True, timeout=30)
            self.assertEqual(result.returncode, 3, result.stderr)
            self.assertIn('webSecurity=false', result.stdout)
            self.assertIn('kein Download', result.stdout)
            self.assertNotIn('UNEXPECTED_BROWSER', result.stdout)

    @unittest.skipUnless(BASH and Path(BASH).is_file(), 'Native Bash unavailable')
    def test_bwendell_noninteractive_skip_does_not_start_browser(self):
        result = subprocess.run([BASH, '--noprofile', '--norc', (ROOT / 'scripts/tools/gemini_desktop_bwendell_install.sh').as_posix()], input='', capture_output=True, text=True, timeout=30)
        self.assertEqual(result.returncode, 3, result.stderr)
        self.assertIn('KEINE Gemini-CLI', result.stdout)
        self.assertIn('Kein Download', result.stdout)

    def test_documentation_explains_cli_web_and_gateway_without_fake_adapter(self):
        text = DOC.read_text(encoding='utf-8')
        for word in ('nicht fuer **Gemini CLI**', 'Pflege', 'Archiviert', 'webSecurity: false',
                     'verifyUpdateCodeSignature: false', 'Direkt umschaltbar: nein.',
                     'kein fertiger Adapter', '18789', 'gemini_desktop_bwendell_source', 'gemini_desktop_dortanes_source'):
            assert_prose_in(self, word, text)
        for key in SOURCES:
            assert_prose_in(self, G.SPECS[key]['pin'], text)
        for target in re.findall(r'\]\(([^)]+)\)', text):
            if '://' not in target:
                self.assertTrue((DOC.parent / target.split('#', 1)[0]).is_file(), target)
        self.assertEqual(text.count('```') % 2, 0)
        for filename in ('TOOLS_CATALOG.md', 'START_HERE.md', 'TESTED_STATUS_MATRIX.md'):
            assert_prose_in(self, 'tools/gemini-desktop-clients.md', (ROOT / 'docs' / filename).read_text(encoding='utf-8'))


if __name__ == '__main__':
    unittest.main()
